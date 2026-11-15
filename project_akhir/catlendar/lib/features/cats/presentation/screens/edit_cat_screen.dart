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
          const SnackBar(content: Text('Foto kucing berhasil diunggah!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto: $e')),
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
        title: Text('Hapus Profil ${cat.name}?'),
        content: const Text(
          'Profil kucing dan data terkait akan dihapus permanen dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
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
        SnackBar(content: Text('Profil ${cat.name} berhasil dihapus')),
      );
      while (context.canPop()) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus profil: $e')),
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
        title: const Text('Edit Cat Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: catAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (cat) {
          if (cat == null) {
            return const Center(child: Text('Kucing tidak ditemukan'));
          }
          if (ownerId == null) {
            return const Center(child: Text('Sesi tidak valid'));
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CatAvatar(
                      avatarId: _selectedAvatarId,
                      catColor: _selectedColor,
                      radius: 44,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _isUploadingPhoto ? null : _uploadCatPhoto,
                      icon: _isUploadingPhoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_library_outlined, size: 18),
                      label: Text(
                        _isUploadingPhoto
                            ? 'Uploading...'
                            : (isNetworkPhoto
                                ? 'Change Photo from Gallery'
                                : 'Upload Photo from Gallery'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 60,
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
                                    ? Colors.black
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
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _pickDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of birth *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select Date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  breedsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => TextFormField(
                      initialValue: _selectedBreed,
                      decoration: const InputDecoration(
                        labelText: 'Breed *',
                        border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedNeuterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Neuter status *',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _colorOptions.contains(_selectedColor)
                        ? _selectedColor
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 32),
                  const Text(
                    'Saved Medical History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  historiesAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Gagal memuat riwayat medis'),
                    data: (histories) {
                      if (histories.isEmpty) {
                        return const Text(
                          'Belum ada riwayat medis tersimpan.',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return Column(
                        children: histories
                            .map(
                              (h) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(h.conditionName),
                                subtitle: h.notes != null && h.notes!.isNotEmpty
                                    ? Text(h.notes!)
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => ref
                                      .read(medicalHistoryRepositoryProvider)
                                      .deleteHistory(h.historyId),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Add New Medical History (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newConditionController,
                    decoration: const InputDecoration(
                      labelText: 'Condition Name (e.g. Asthma, Allergy)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          _isDeleting ? null : () => _onContinue(cat, ownerId),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed:
                          _isDeleting ? null : () => _confirmAndDeleteCat(cat),
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(Icons.delete_outline),
                      label: Text(
                        _isDeleting ? 'Menghapus...' : 'Delete Cat Profile',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
