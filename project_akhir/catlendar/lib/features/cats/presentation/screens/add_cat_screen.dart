import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/avatar_presets.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/core/services/image_upload_service.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/data/models/medical_history.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/features/cats/presentation/widgets/breed_picker_field.dart';

class _PendingMedicalHistory {
  const _PendingMedicalHistory({
    required this.conditionName,
    this.notes,
  });

  final String conditionName;
  final String? notes;
}

class AddCatScreen extends ConsumerStatefulWidget {
  const AddCatScreen({super.key});

  @override
  ConsumerState<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends ConsumerState<AddCatScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _medicalConditionController;
  late TextEditingController _medicalNotesController;

  String _selectedAvatarId = AvatarPresets.catAvatarIds.first;
  bool _isUploadingPhoto = false;
  DateTime? _selectedDate;
  String? _selectedBreed = 'Domestic';
  String? _selectedGender;
  String? _selectedNeuterStatus;
  String? _selectedColor;

  final List<_PendingMedicalHistory> _pendingHistories = [];

  final _genderOptions = ['Male', 'Female'];
  final _neuterOptions = ['Neutered', 'Spayed', 'Intact'];
  final _colorOptions = [
    'Black',
    'White',
    'Orange',
    'Grey',
    'Calico',
    'Tabby',
    'Bicolor',
    'Tortoiseshell',
    'Cream',
    'Brown',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _medicalConditionController = TextEditingController();
    _medicalNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _medicalConditionController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _uploadCatPhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      final imageUrl = await ImageUploadService.pickAndUploadCatImage();
      if (imageUrl != null && mounted) {
        setState(() => _selectedAvatarId = imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addMedicalHistory() {
    final condition = _medicalConditionController.text.trim();
    final notes = _medicalNotesController.text.trim();

    if (condition.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a condition name first')),
      );
      return;
    }

    setState(() {
      _pendingHistories.add(
        _PendingMedicalHistory(
          conditionName: condition,
          notes: notes.isEmpty ? null : notes,
        ),
      );
      _medicalConditionController.clear();
      _medicalNotesController.clear();
    });
  }

  void _onContinue(String ownerId) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of birth')),
      );
      return;
    }

    final newCatId = ref.read(catRepositoryProvider).newId();
    final now = DateTime.now();

    final newCat = Cat(
      catId: newCatId,
      ownerId: ownerId,
      name: _nameController.text.trim(),
      dateOfBirth: _selectedDate!,
      breed: _selectedBreed ?? 'Domestic',
      gender: _selectedGender!,
      neuterStatus: _selectedNeuterStatus!,
      color: _selectedColor,
      avatarId: _selectedAvatarId,
      createdAt: now,
      updatedAt: now,
    );

    ref.read(catDraftProvider.notifier).setDraft(newCat);

    final allPending = List<_PendingMedicalHistory>.from(_pendingHistories);
    final trailingCondition = _medicalConditionController.text.trim();
    final trailingNotes = _medicalNotesController.text.trim();
    if (trailingCondition.isNotEmpty) {
      allPending.add(
        _PendingMedicalHistory(
          conditionName: trailingCondition,
          notes: trailingNotes.isEmpty ? null : trailingNotes,
        ),
      );
    }

    if (allPending.isNotEmpty) {
      final repo = ref.read(medicalHistoryRepositoryProvider);
      final drafts = allPending
          .map(
            (item) => MedicalHistory(
              historyId: repo.newId(),
              catId: newCatId,
              ownerId: ownerId,
              conditionName: item.conditionName,
              notes: item.notes,
              createdAt: now,
              updatedAt: now,
            ),
          )
          .toList();
      ref.read(medicalHistoryDraftProvider.notifier).setDrafts(drafts);
    } else {
      ref.read(medicalHistoryDraftProvider.notifier).clearDrafts();
    }

    context.pushNamed(AppRoutes.catSummary.name);
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(currentUserIdProvider);
    final breedsAsync = ref.watch(breedsProvider);
    final catsAsync = ref.watch(userCatsProvider);
    final hasCats = catsAsync.asData?.value.isNotEmpty ?? false;

    if (ownerId == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid session. Please log in again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF111111),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text(
                      hasCats ? 'Add a New Cat' : 'Add Your First Cat',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CatAvatar(
                        avatarId: _selectedAvatarId,
                        catColor: _selectedColor,
                        radius: 46,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _isUploadingPhoto ? null : _uploadCatPhoto,
                        icon: _isUploadingPhoto
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.photo_library_outlined, size: 16),
                        label: Text(
                          _isUploadingPhoto
                              ? 'Uploading...'
                              : (_selectedAvatarId.startsWith('http')
                                  ? 'Change profile picture'
                                  : 'Edit profile picture'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 58,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AvatarPresets.catAvatarIds.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final presetId = AvatarPresets.catAvatarIds[index];
                          final isSelected = presetId == _selectedAvatarId;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedAvatarId = presetId),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF111111)
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: CatAvatar(
                                avatarId: presetId,
                                catColor: _selectedColor,
                                radius: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        prefixIcon: Icon(Icons.pets, size: 18),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => _pickDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of birth *',
                          prefixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select Date',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedDate != null
                                ? const Color(0xFF111111)
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    breedsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => TextFormField(
                        initialValue: _selectedBreed,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Breed *',
                          prefixIcon: Icon(Icons.pets_outlined, size: 18),
                        ),
                        onChanged: (val) => _selectedBreed = val.trim(),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Breed is required'
                            : null,
                      ),
                      data: (breeds) {
                        final breedNames = <String>{
                          'Domestic',
                          if (_selectedBreed != null) _selectedBreed!,
                          ...breeds.map((b) => b.name),
                        }.toList();
                        return BreedPickerField(
                          selectedBreed: breedNames.contains(_selectedBreed)
                              ? _selectedBreed
                              : 'Domestic',
                          breedNames: breedNames,
                          onChanged: (val) =>
                              setState(() => _selectedBreed = val),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111111),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: Icon(Icons.wc, size: 18),
                      ),
                      items: _genderOptions
                          .map(
                            (g) => DropdownMenuItem<String>(
                              value: g,
                              child: Text(g),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                      validator: (val) =>
                          val == null ? 'Gender is required' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedNeuterStatus,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111111),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Neuter status *',
                        prefixIcon: Icon(Icons.medical_services_outlined, size: 18),
                      ),
                      items: _neuterOptions
                          .map(
                            (n) => DropdownMenuItem<String>(
                              value: n,
                              child: Text(n),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedNeuterStatus = val),
                      validator: (val) =>
                          val == null ? 'Neuter status is required' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedColor,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111111),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        prefixIcon: Icon(Icons.palette_outlined, size: 18),
                      ),
                      items: _colorOptions
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedColor = val),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Medical History (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_pendingHistories.isNotEmpty) ...[
                      ..._pendingHistories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD0D0D0)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.conditionName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (item.notes != null)
                                      Text(
                                        item.notes!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B6B6B),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(
                                      () => _pendingHistories.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                    TextFormField(
                      controller: _medicalConditionController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Condition Name (e.g. Asthma, Allergy)',
                        prefixIcon: Icon(Icons.healing_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _medicalNotesController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: const Icon(Icons.notes_outlined, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Color(0xFFD0D0D0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Color(0xFFD0D0D0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Color(0xFF111111)),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _addMedicalHistory,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Medical History'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        shape: const StadiumBorder(),
                      ),
                    ),
                    const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => _onContinue(ownerId),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
