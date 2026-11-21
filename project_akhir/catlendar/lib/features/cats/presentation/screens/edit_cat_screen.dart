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

class EditCatScreen extends ConsumerStatefulWidget {
  const EditCatScreen({super.key, required this.catId});

  final String catId;

  @override
  ConsumerState<EditCatScreen> createState() => _EditCatScreenState();
}

class _EditCatScreenState extends ConsumerState<EditCatScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _newConditionController;
  late TextEditingController _newNotesController;

  bool _initialized = false;
  bool _isUploadingPhoto = false;
  bool _isDeleting = false;
  String? _selectedAvatarId;
  DateTime? _selectedDate;
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedNeuterStatus;
  String? _selectedColor;

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
    _newConditionController = TextEditingController();
    _newNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newConditionController.dispose();
    _newNotesController.dispose();
    super.dispose();
  }

  Future<void> _uploadCatPhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      final imageUrl = await ImageUploadService.pickAndUploadCatImage();
      if (imageUrl != null && mounted) {
        setState(() => _selectedAvatarId = imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('The cat photo has been uploaded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload cat photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _confirmAndDeleteCat(Cat cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Profile ${cat.name}?'),
        content: const Text(
          'The cat profile and all associated medical history will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(catRepositoryProvider).deleteCat(cat.catId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'The profile for ${cat.name} has been deleted successfully.')),
      );
      while (context.canPop()) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete profile: $e')),
        );
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

  void _onContinue(Cat originalCat, String ownerId) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of birth')),
      );
      return;
    }

    final now = DateTime.now();
    final updatedCat = Cat(
      catId: originalCat.catId,
      ownerId: ownerId,
      name: _nameController.text.trim(),
      dateOfBirth: _selectedDate!,
      breed: _selectedBreed ?? 'Domestic',
      gender: _selectedGender!,
      neuterStatus: _selectedNeuterStatus!,
      color: _selectedColor,
      avatarId: _selectedAvatarId,
      createdAt: originalCat.createdAt,
      updatedAt: now,
    );

    ref.read(catDraftProvider.notifier).setDraft(updatedCat);

    final condition = _newConditionController.text.trim();
    final notes = _newNotesController.text.trim();
    if (condition.isNotEmpty) {
      final historyId = ref.read(medicalHistoryRepositoryProvider).newId();
      ref.read(medicalHistoryDraftProvider.notifier).setDrafts([
        MedicalHistory(
          historyId: historyId,
          catId: originalCat.catId,
          ownerId: ownerId,
          conditionName: condition,
          notes: notes.isEmpty ? null : notes,
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    } else {
      ref.read(medicalHistoryDraftProvider.notifier).clearDrafts();
    }

    context.pushNamed(AppRoutes.catSummary.name);
  }

  @override
  Widget build(BuildContext context) {
    final catAsync = ref.watch(catByIdProvider(widget.catId));
    final historiesAsync = ref.watch(medicalHistoryByCatProvider(widget.catId));
    final ownerId = ref.watch(currentUserIdProvider);
    final breedsAsync = ref.watch(breedsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF111111),
      ),
      body: catAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (cat) {
          if (cat == null) {
            return const Center(
                child: Text('The cat profile could not be found.'));
          }
          if (ownerId == null) {
            return const Center(child: Text('The session is invalid.'));
          }

          if (!_initialized) {
            _initialized = true;
            _nameController.text = cat.name;
            _selectedAvatarId =
                cat.avatarId ?? AvatarPresets.catAvatarIds.first;
            _selectedDate = cat.dateOfBirth;
            _selectedBreed = cat.breed;
            _selectedGender = cat.gender;
            _selectedNeuterStatus = cat.neuterStatus;
            _selectedColor = cat.color;
          }

          final isNetworkPhoto = _selectedAvatarId != null &&
              _selectedAvatarId!.startsWith('http');

          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        const Text(
                          'Edit Cat Profile',
                          style: TextStyle(
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
                            onPressed:
                                _isUploadingPhoto ? null : _uploadCatPhoto,
                            icon: _isUploadingPhoto
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.photo_library_outlined,
                                    size: 16),
                            label: Text(
                              _isUploadingPhoto
                                  ? 'Uploading...'
                                  : (isNetworkPhoto
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final presetId =
                                  AvatarPresets.catAvatarIds[index];
                              final isSelected = presetId == _selectedAvatarId;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _selectedAvatarId = presetId),
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
                              style: const TextStyle(fontSize: 14),
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
                          ),
                          data: (breeds) {
                            final breedNames = <String>{
                              'Domestic',
                              if (_selectedBreed != null) _selectedBreed!,
                              ...breeds.map((b) => b.name),
                            }.toList();
                            return BreedPickerField(
                              selectedBreed: _selectedBreed,
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
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
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
                            prefixIcon:
                                Icon(Icons.medical_services_outlined, size: 18),
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
                          initialValue: _colorOptions.contains(_selectedColor)
                              ? _selectedColor
                              : null,
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
                          onChanged: (val) =>
                              setState(() => _selectedColor = val),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Saved Medical History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 8),
                        historiesAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) =>
                              const Text('Failed to load medical history.'),
                          data: (histories) {
                            if (histories.isEmpty) {
                              return const Text(
                                'No saved medical history available.',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 13,
                                ),
                              );
                            }
                            return Column(
                              children: histories
                                  .map(
                                    (h) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFD0D0D0),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  h.conditionName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (h.notes != null &&
                                                    h.notes!.isNotEmpty)
                                                  Text(
                                                    h.notes!,
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
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            onPressed: () => ref
                                                .read(
                                                    medicalHistoryRepositoryProvider)
                                                .deleteHistory(h.historyId),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Add New Medical History (Optional)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newConditionController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Condition Name (e.g. Asthma, Allergy)',
                            prefixIcon: Icon(Icons.healing_outlined, size: 18),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newNotesController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            prefixIcon:
                                const Icon(Icons.notes_outlined, size: 18),
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
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: _isDeleting
                              ? null
                              : () => _onContinue(cat, ownerId),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Continue'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            minimumSize: const Size.fromHeight(50),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _isDeleting
                              ? null
                              : () => _confirmAndDeleteCat(cat),
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              : const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        _isDeleting ? 'Deleting...' : 'Delete Cat Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
