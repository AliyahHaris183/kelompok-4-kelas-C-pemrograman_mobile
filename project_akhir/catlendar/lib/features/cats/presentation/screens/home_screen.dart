import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca daftar kucing milik pengguna dari Firestore
    final userCatsAsync = ref.watch(userCatsProvider);

    // MOCK DATA PENGGUNA (Sementara sampai Orang 1 selesai dengan profil USERS)
    const mockUserName = 'Anya';
    const mockUserAge = '19';
    const mockUserGender = 'Female';

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
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          mockUserName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '$mockUserAge • $mockUserGender',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
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

              const SizedBox(height: 40),

              // 2. BAGIAN KUCING: Judul & Carousel Avatar Kucing
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

              const SizedBox(height: 40),

              // 3. KARTU PENGINGAT KALENDER
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
                      "Don't Forget to check your calendar, $mockUserName!",
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
