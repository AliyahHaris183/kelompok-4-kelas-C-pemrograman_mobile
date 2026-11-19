import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/shared/widgets/avatar_image.dart';

const _fallbackCatFacts = [
  'Cats spend about 70% of their lives sleeping, which is around 13 to 16 hours a day.',
  'A group of cats is called a clowder, and a male cat is called a tom.',
  'Cats have over 20 muscles that control their ears, allowing them to rotate 180 degrees.',
  'A cat’s nose print is completely unique, much like a human fingerprint.',
  'Cats can jump up to six times their own length in a single leap.',
];

/// Mengambil fakta singkat tentang kucing dari Cat Fact Ninja API.
final _catFactProvider = FutureProvider.autoDispose<String>((ref) async {
  final randomFallback =
      _fallbackCatFacts[Random().nextInt(_fallbackCatFacts.length)];
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

  try {
    final request = await client.getUrl(
      Uri.parse('https://catfact.ninja/fact?max_length=120'),
    );
    final response = await request.close();
    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final fact = data['fact'] as String?;
      if (fact != null && fact.trim().isNotEmpty) {
        return fact.trim();
      }
    }
    return randomFallback;
  } catch (_) {
    return randomFallback;
  } finally {
    client.close();
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age >= 0 ? '$age' : '0';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca data profil pengguna & daftar kucing dari Firestore
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final userCatsAsync = ref.watch(userCatsProvider);

    final user = userProfileAsync.when(
      data: (u) => u,
      loading: () => null,
      error: (_, __) => null,
    );

    final userName =
        (user != null && user.name.trim().isNotEmpty) ? user.name : 'Cat Lover';

    final subtitleParts = <String>[
      if (user != null) _calculateAge(user.dateOfBirth),
      if (user?.gender != null && user!.gender!.trim().isNotEmpty) user.gender!,
    ];
    final userSubtitle = subtitleParts.join(' • ');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER: Profil Pengguna & Pengaturan
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AvatarImage(
                    avatarId: user?.avatarId,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            userSubtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () =>
                              context.pushNamed(AppRoutes.settings.name),
                          child: const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. KARTU CAT FACT (Tap untuk ganti & otomatis berganti tiap 18 detik)
              const _CatFactCard(),

              const SizedBox(height: 28),

              // 3. BAGIAN KUCING: Judul & Carousel Avatar Kucing
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Take a look on your members',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.pets, color: Colors.redAccent, size: 28),
                ],
              ),
              const SizedBox(height: 16),

              // Daftar Carousel Kucing dari Firestore
              SizedBox(
                height: 110,
                child: userCatsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (cats) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length + 1, // +1 untuk tombol Add
                      itemBuilder: (context, index) {
                        // Tombol Add di ujung kanan carousel
                        if (index == cats.length) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(36),
                                  onTap: () =>
                                      context.pushNamed(AppRoutes.addCat.name),
                                  child: const CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Colors.black,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }

                        // Kartu avatar tiap kucing
                        final cat = cats[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(36),
                                onTap: () => context.push(
                                  AppRoutes.catProfile.location(
                                    pathParameters: {
                                      AppRoutes.catIdParam: cat.catId,
                                    },
                                  ),
                                ),
                                child: CatAvatar(
                                  avatarId: cat.avatarId,
                                  catColor: cat.color,
                                  radius: 36,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 4. KARTU PENGINGAT KALENDER
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Don't Forget to check your calendar, $userName!",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pratinjau Kalender menuju Layar Calendar (Orang 3)
              InkWell(
                onTap: () => context.pushNamed(AppRoutes.calendar.name),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Tap to open Calendar',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatFactCard extends ConsumerStatefulWidget {
  const _CatFactCard();

  @override
  ConsumerState<_CatFactCard> createState() => _CatFactCardState();
}

class _CatFactCardState extends ConsumerState<_CatFactCard> {
  static const _autoRotateInterval = Duration(seconds: 18);

  Timer? _timer;
  String? _displayedFact;

  @override
  void initState() {
    super.initState();
    _startAutoRotateTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRotateTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoRotateInterval, (_) {
      if (mounted) {
        _nextFact(resetTimer: false);
      }
    });
  }

  void _nextFact({required bool resetTimer}) {
    if (ref.read(_catFactProvider).isLoading) return;
    ref.invalidate(_catFactProvider);
    if (resetTimer) {
      _startAutoRotateTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final catFactAsync = ref.watch(_catFactProvider);

    catFactAsync.whenData((fact) {
      _displayedFact = fact;
    });

    final String factText = _displayedFact ??
        catFactAsync.when<String>(
          data: (fact) => fact,
          loading: () => 'Fetching a fun cat fact...',
          error: (_, __) => _fallbackCatFacts.first,
        );

    return Material(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _nextFact(resetTimer: true),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Cat Fact',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Text(
                    'Tap for next',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (catFactAsync.isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.orange,
                      ),
                    )
                  else
                    const Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.black54,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  factText,
                  key: ValueKey(factText),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
