import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/avatar_presets.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/data/models/medical_history.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';

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
  DateTime? _selectedDate;
  String? _selectedBreed = 'Domestic';
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

    final condition = _medicalConditionController.text.trim();
    final notes = _medicalNotesController.text.trim();
    if (condition.isNotEmpty) {
      final historyId = ref.read(medicalHistoryRepositoryProvider).newId();
      ref.read(medicalHistoryDraftProvider.notifier).setDrafts([
        MedicalHistory(
          historyId: historyId,
          catId: newCatId,
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
    final ownerId = ref.watch(currentUserIdProvider);
    final breedsAsync = ref.watch(breedsProvider);

    if (ownerId == null) {
      return const Scaffold(
        body: Center(child: Text('Sesi tidak valid. Silakan login kembali.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your First Cat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: CatAvatar(avatarId: _selectedAvatarId, radius: 44)),
              const SizedBox(height: 12),
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
                      onTap: () => setState(() => _selectedAvatarId = presetId),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: CatAvatar(avatarId: presetId, radius: 24),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => TextFormField(
                  initialValue: _selectedBreed,
                  decoration: const InputDecoration(
                    labelText: 'Breed *',
                    border: OutlineInputBorder(),
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
                  return DropdownButtonFormField<String>(
                    initialValue: breedNames.contains(_selectedBreed)
                        ? _selectedBreed
                        : 'Domestic',
                    decoration: const InputDecoration(
                      labelText: 'Breed *',
                      border: OutlineInputBorder(),
                    ),
                    items: breedNames
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedBreed = val),
                    validator: (val) =>
                        val == null ? 'Breed is required' : null,
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
                validator: (val) => val == null ? 'Gender is required' : null,
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
                onChanged: (val) => setState(() => _selectedNeuterStatus = val),
                validator: (val) =>
                    val == null ? 'Neuter status is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedColor,
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
                'Medical History (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalConditionController,
                decoration: const InputDecoration(
                  labelText: 'Condition Name (e.g. Asthma, Allergy)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalNotesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                  onPressed: () => _onContinue(ownerId),
                  child: const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
