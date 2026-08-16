import 'package:flutter/material.dart';

import '../../services/reminder_service.dart';
import '../bacaan/bacaan_screen.dart';
import '../pengaturan/pengaturan_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../statistik/statistik_screen.dart';
import 'today_screen.dart';

/// Indeks tab aktif — dipakai lintas layar (mis. Riwayat → Hari Ini).
final ValueNotifier<int> homeTabIndex = ValueNotifier(0);

/// Kerangka navigasi utama — 5 menu: Hari Ini, Bacaan, Riwayat, Statistik, Pengaturan.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    homeTabIndex.addListener(_onTab);
  }

  @override
  void dispose() {
    homeTabIndex.removeListener(_onTab);
    super.dispose();
  }

  void _onTab() => setState(() => _index = homeTabIndex.value);

  @override
  Widget build(BuildContext context) {
    final pages = const [
      TodayScreen(),
      BacaanScreen(),
      RiwayatScreen(),
      StatistikScreen(),
      PengaturanScreen(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: pages),
          // Kontrol azan — tampil saat audio azan sedang diputar.
          Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder<bool>(
              valueListenable: ReminderService.instance.azan.playing,
              builder: (context, playing, _) => playing
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 84),
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(32),
                        color: Theme.of(context).colorScheme.inverseSurface,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.music_note,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text('Azan sedang diputar',
                                  style: TextStyle(color: Colors.white, fontSize: 13)),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.stop, color: Colors.white),
                                tooltip: 'Hentikan azan',
                                onPressed: () =>
                                    ReminderService.instance.azan.stop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Bacaan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
