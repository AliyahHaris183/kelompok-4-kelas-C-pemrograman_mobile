import 'package:flutter/material.dart';

class BreedPickerField extends StatelessWidget {
  const BreedPickerField({
    super.key,
    required this.selectedBreed,
    required this.breedNames,
    required this.onChanged,
  });

  final String? selectedBreed;
  final List<String> breedNames;
  final ValueChanged<String> onChanged;

  Future<void> _openSearchSheet(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _BreedSearchSheet(
        breedNames: breedNames,
        selectedBreed: selectedBreed,
      ),
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: selectedBreed,
      validator: (_) => (selectedBreed == null || selectedBreed!.trim().isEmpty)
          ? 'Breed is required'
          : null,
      builder: (state) {
        return InkWell(
          onTap: () => _openSearchSheet(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Breed *',
              prefixIcon: const Icon(Icons.pets_outlined, size: 18),
              suffixIcon: const Icon(Icons.search, size: 18),
              errorText: state.errorText,
            ),
            child: Text(
              selectedBreed ?? 'Select Breed',
              style: TextStyle(
                color:
                    selectedBreed != null ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BreedSearchSheet extends StatefulWidget {
  const _BreedSearchSheet({
    required this.breedNames,
    required this.selectedBreed,
  });

  final List<String> breedNames;
  final String? selectedBreed;

  @override
  State<_BreedSearchSheet> createState() => _BreedSearchSheetState();
}

class _BreedSearchSheetState extends State<_BreedSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredBreeds;

  @override
  void initState() {
    super.initState();
    _filteredBreeds = widget.breedNames;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredBreeds = widget.breedNames;
      } else {
        _filteredBreeds = widget.breedNames
            .where((b) => b.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select Cat Breed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Search breed (e.g. Persian, British, Domestic)...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filter('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            Expanded(
              child: _filteredBreeds.isEmpty
                  ? const Center(
                      child: Text(
                        'No cat breeds found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredBreeds.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final breed = _filteredBreeds[index];
                        final isSelected = breed == widget.selectedBreed;
                        return ListTile(
                          title: Text(
                            breed,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.black)
                              : null,
                          onTap: () => Navigator.pop(context, breed),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
