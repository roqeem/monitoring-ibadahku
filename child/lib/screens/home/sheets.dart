import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/worship_content.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

// ---------------------------------------------------------------------------
// Sheet pencatatan shalat fardhu
// ---------------------------------------------------------------------------

class PrayerSheet extends StatefulWidget {
  final DateTime date;
  final String prayerName;
  const PrayerSheet({super.key, required this.date, required this.prayerName});

  @override
  State<PrayerSheet> createState() => _PrayerSheetState();
}

class _PrayerSheetState extends State<PrayerSheet> {
  late PrayerRecord _rec;
  late bool _haid;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _rec = state.prayer(widget.date, widget.prayerName).copy();
    _haid = state.hasCondition(widget.date, SpecialConditionType.haid);
  }

  bool get _uzur => _rec.status == PrayerStatus.uzur;

  /// Opsi status di sheet: qadha legacy disembunyikan, diganti Jama/Qasar.
  List<PrayerStatus> get _statusOptions => PrayerStatus.values
      .where((s) => s != PrayerStatus.qadha)
      .toList();

  @override
  Widget build(BuildContext context) {
    final name = PrayerName.fromKey(widget.prayerName).label;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Shalat $name',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            Text(formatDateShort(widget.date),
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            if (_haid) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.uzurSoft, borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Tertera kondisi haid/nifas pada tanggal ini. Shalat tidak dianggap terlewat.',
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.uzur),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ChipSelect<PrayerStatus>(
              options: _statusOptions,
              selected: _rec.status,
              labelOf: (s) => s.label,
              onSelected: (s) => setState(() {
                _rec.status = s;
                if (s == PrayerStatus.uzur) {
                  _rec.place = null;
                  _rec.congregation = null;
                  _rec.timeCategory = null;
                }
              }),
            ),
            const SizedBox(height: 20),

            if (!_uzur) ...[
              const Text('Tempat', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ChipSelect<Place>(
                options: Place.values,
                selected: _rec.place,
                labelOf: (p) => p.label,
                iconOf: (p) => switch (p) {
                  Place.masjid => Icons.mosque_outlined,
                  Place.musala => Icons.place_outlined,
                  Place.rumah => Icons.home_outlined,
                  Place.kerja => Icons.business_outlined,
                  Place.lain => Icons.more_horiz,
                },
                onSelected: (p) => setState(() => _rec.place = p),
              ),
              const SizedBox(height: 20),

              const Text('Pelaksanaan', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ChipSelect<Congregation>(
                options: Congregation.values,
                selected: _rec.congregation,
                labelOf: (c) => c.label,
                iconOf: (c) => c == Congregation.jamaah
                    ? Icons.groups_outlined
                    : Icons.person_outline,
                onSelected: (c) => setState(() => _rec.congregation = c),
              ),
              const SizedBox(height: 20),

              const Text('Waktu', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ChipSelect<TimeCategory>(
                  options: TimeCategory.values,
                  selected: _rec.timeCategory,
                  labelOf: (t) => t.label,
                  onSelected: (t) => setState(() => _rec.timeCategory = t),
                ),
              const SizedBox(height: 20),

              TextField(
                controller: TextEditingController(text: _rec.notes),
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  hintText: 'cth: berjamaah di masjid dekat kantor',
                ),
                onChanged: (v) => _rec.notes = v,
              ),
            ],

            const SizedBox(height: 12),
            PrimaryButton(
              onPressed: () async {
                _rec.completedAt = DateTime.now();
                await context.read<AppState>().setPrayer(
                    widget.date, widget.prayerName, _rec);
                if (context.mounted) Navigator.pop(context);
              },
              label: 'Simpan',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet pencatatan shalat sunnah (Tahajud, Witir, Dhuha, Rawatib, Jumat)
// ---------------------------------------------------------------------------

class SunnahSheet extends StatefulWidget {
  final DateTime date;
  final String type;
  const SunnahSheet({super.key, required this.date, required this.type});

  @override
  State<SunnahSheet> createState() => _SunnahSheetState();
}

class _SunnahSheetState extends State<SunnahSheet> {
  late SunnahRecord _rec;
  final _customCtrl = TextEditingController();
  bool _custom = false;

  @override
  void initState() {
    super.initState();
    _rec = context.read<AppState>().sunnah(widget.date, widget.type).copy();
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  String get _title => switch (widget.type) {
        'tahajud' => 'Shalat Tahajud',
        'witir' => 'Shalat Witir',
        'dhuha' => 'Shalat Dhuha',
        'qabliyah_subuh' => 'Qabliyah Subuh',
        'qabliyah_dzuhur' => 'Qabliyah Dzuhur',
        'badiyah_dzuhur' => "Ba'diyah Dzuhur",
        'qabliyah_ashar' => 'Qabliyah Ashar',
        'qabliyah_maghrib' => 'Qabliyah Maghrib',
        'badiyah_maghrib' => "Ba'diyah Maghrib",
        'qabliyah_isya' => 'Qabliyah Isya',
        'badiyah_isya' => "Ba'diyah Isya",
        'jumat_mandi' => 'Mandi Jumat',
        'jumat_kahfi' => 'Membaca Surah Al-Kahfi',
        'jumat_datang_awal' => 'Datang Lebih Awal',
        'jumat_sedekah' => 'Sedekah Jumat',
        'jumat_shalawat' => 'Memperbanyak Shalawat',
        'baca_quran_100' => "Baca Al-Qur'an minimal 100 ayat",
        'wudhu_sebelum_tidur' => 'Berwudhu sebelum tidur',
        _ => 'Ibadah Sunnah',
      };

  bool get _isFlexible => widget.type == 'tahajud' || widget.type == 'witir' || widget.type == 'dhuha';
  bool get _isJumat => widget.type.startsWith('jumat_');
  /// Item checklist sederhana: tanpa rakaat, cukup toggle selesai.
  bool get _isChecklist =>
      _isJumat || widget.type == 'baca_quran_100' || widget.type == 'wudhu_sebelum_tidur';

  String? get _hadith => switch (widget.type) {
        'baca_quran_100' =>
            "Siapa yang membaca 100 ayat (Al-Qur'an) pada suatu malam, maka ditulis baginya pahala shalat semalam penuh (atau dicatat termasuk kelompok orang-orang yang taat/qanitin). (HR. Ahmad no. 17620 dan An-Nasa'i dalam As-Sunan al-Kubra, dishahihkan oleh Syaikh Al-Albani)",
        'wudhu_sebelum_tidur' =>
            "Barangsiapa yang tidur dalam keadaan suci, maka malaikat akan bersamanya di dalam pakaiannya. Dia tidak akan bangun melainkan malaikat berdoa: 'Ya Allah, ampunilah hamba-Mu si fulan karena ia tidur dalam keadaan suci.' (HR. Ibn Hibban, dishahihkan oleh Syaikh Al-Albani)",
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_title,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            Text(formatDateShort(widget.date),
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            if (_isChecklist) ...[
              if (_hadith != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1D2927)
                        : AppColors.pendingSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _hadith!,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFB9C7C3)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SwitchListTile(
                value: _rec.completed,
                onChanged: (v) => setState(() => _rec.completed = v),
                title: Text('Selesai dilakukan', style: TextStyle(fontSize: 14.5)),
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppColors.primary,
              ),
            ] else ...[
              const Text('Jumlah rakaat', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (_isFlexible)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChipSelect<int>(
                      options: widget.type == 'witir' ? const [1, 3] : const [2, 4, 6, 8],
                      selected: _custom ? null : _rec.rakaat,
                      labelOf: (r) => '$r rakaat',
                      onSelected: (r) => setState(() {
                        _custom = false;
                        _rec.rakaat = r;
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Isi sendiri',
                        hintText: widget.type == 'witir'
                            ? 'Angka ganjil (1–99)'
                            : 'Angka genap (2–100)',
                        prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          setState(() {
                            _custom = true;
                            _rec.rakaat = n;
                          });
                        }
                      },
                    ),
                  ],
                )
              else
                ChipSelect<int>(
                  options: _fixedRakaat(),
                  selected: _rec.rakaat == 0 ? null : _rec.rakaat,
                  labelOf: (r) => '$r rakaat',
                  onSelected: (r) => setState(() => _rec.rakaat = r),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _rec.completed,
                onChanged: (v) => setState(() => _rec.completed = v),
                title: const Text('Selesai dikerjakan'),
                subtitle: const Text('Tandai setelah melaksanakan'),
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppColors.primary,
              ),
            ],

            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: _rec.notes),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'cth: tahajud 2 rakaat sebelum subuh',
              ),
              onChanged: (v) => _rec.notes = v,
            ),

            const SizedBox(height: 12),
            PrimaryButton(
              onPressed: _canSave ? () => _save(state) : null,
              busy: _saving,
              label: 'Simpan',
            ),
          ],
        ),
      ),
    );
  }

  List<int> _fixedRakaat() => switch (widget.type) {
        'qabliyah_dzuhur' || 'badiyah_dzuhur' => const [2, 4],
        'qabliyah_ashar' => const [4],
        _ => const [2],
      };

  bool get _saving => false;
  bool get _canSave {
    if (_rec.completed && _rec.rakaat == 0 && !_isChecklist) return false;
    if (_isFlexible && _custom) {
      final n = _rec.rakaat;
      if (widget.type == 'witir') {
        if (n == 0 || n.isEven || n > 99) return false;
      } else if (n == 0 || n.isOdd || n > 100) {
        return false;
      }
    }
    return true;
  }

  Future<void> _save(AppState state) async {
    // validasi rakaat manual
    if (_isFlexible && _custom) {
      final n = _rec.rakaat;
      if (n == 0) {
        _err('Masukkan jumlah rakaat.');
        return;
      }
      if (widget.type == 'witir') {
        if (n.isEven || n < 1 || n > 99) {
          _err('Witir harus angka ganjil antara 1–99.');
          return;
        }
      } else {
        if (n.isOdd || n < 2 || n > 100) {
          _err('${_title.split(' ').last} harus angka genap antara 2–100.');
          return;
        }
      }
    }
    if (_rec.completed && _rec.rakaat == 0 && !_isChecklist) {
      _err('Pilih jumlah rakaat terlebih dahulu.');
      return;
    }
    _rec.completedAt = _rec.completed ? DateTime.now() : _rec.completedAt;
    await state.setSunnah(widget.date, widget.type, _rec);
    if (mounted) Navigator.pop(context);
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------
// Sheet/reader dzikir & doa
// ---------------------------------------------------------------------------

class DhikrSheet extends StatefulWidget {
  final DateTime date;
  final String contentId;
  final String? block;
  const DhikrSheet({super.key, required this.date, required this.contentId, this.block});

  @override
  State<DhikrSheet> createState() => _DhikrSheetState();
}

class _DhikrSheetState extends State<DhikrSheet> {
  late DhikrSequence _seq;
  late bool _showLatin;
  late bool _showArti;

  /// Rekaman live dari state — selalu terbaru setelah tap checkbox.
  DhikrRecord get _rec =>
      context.read<AppState>().dhikr(widget.date, widget.contentId,
          block: widget.block);

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _seq = sequenceById(widget.contentId);
    _showLatin = state.settings.showLatin;
    _showArti = state.settings.showTranslation;
  }

  bool _isChecked(int index) => index < _rec.completedItems;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fontScale = state.settings.arabicFontSize / 22.0;
    final done = _rec.completed;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      maxChildSize: 0.98,
      minChildSize: 0.5,
      builder: (context, scrollCtrl) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_seq.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          Text(
                            _rec.completedItems > 0
                                ? '${_rec.completedItems} dari ${_rec.totalItems} bacaan selesai'
                                : _seq.subtitle,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFB9C7C3)
                                    : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Perbesar teks',
                      icon: const Icon(Icons.text_increase),
                      onPressed: () {
                        final s = state.settings.copy();
                        s.arabicFontSize = (s.arabicFontSize + 2).clamp(16, 40);
                        state.updateSettings(s);
                      },
                    ),
                    IconButton(
                      tooltip: 'Perkecil teks',
                      icon: const Icon(Icons.text_decrease),
                      onPressed: () {
                        final s = state.settings.copy();
                        s.arabicFontSize = (s.arabicFontSize - 2).clamp(16, 40);
                        state.updateSettings(s);
                      },
                    ),
                    IconButton(
                      tooltip: 'Tampilkan/sembunyikan Latin & arti',
                      icon: const Icon(Icons.tune),
                      onPressed: () => setState(() {
                        _showLatin = !_showLatin;
                        _showArti = !_showArti;
                      }),
                    ),
                    IconButton(
                      tooltip: 'Tutup',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  itemCount: _seq.items.length + 1,
                  itemBuilder: (context, i) {
                    if (i == _seq.items.length) {
                      return const SizedBox(height: 100);
                    }
                    final item = _seq.items[i];
                    final checked = _isChecked(i);
                    final dark = Theme.of(context).brightness == Brightness.dark;
                    // Warna adaptif: dark mode -> kartu hijau gelap + teks terang,
                    // light mode -> hijau muda + teks gelap.
                    final body = dark ? Colors.white : AppColors.textPrimary;
                    final sub =
                        dark ? const Color(0xFFB9C7C3) : AppColors.textSecondary;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        color: checked
                            ? (dark ? const Color(0xFF1E3A30) : AppColors.doneSoft)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: checked
                                            ? (dark
                                                ? const Color(0xFF7FD1A8)
                                                : AppColors.done)
                                            : null),
                                  ),
                                ),
                                if (item.repeat > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: dark
                                          ? Colors.white12
                                          : AppColors.pendingSoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('${item.repeat}×',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: dark
                                                ? const Color(0xFFB9C7C3)
                                                : AppColors.textPrimary)),
                                  ),
                                const SizedBox(width: 6),
                                Checkbox(
                                  value: checked,
                                  activeColor:
                                      dark ? const Color(0xFF7FD1A8) : AppColors.done,
                                  onChanged: (v) => state.toggleDhikrItem(
                                      widget.date, widget.contentId,
                                      block: widget.block,
                                      itemId: item.id,
                                      checked: v ?? false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.arabic,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 22 * fontScale,
                                height: 1.9,
                                fontWeight: FontWeight.w600,
                                color: body,
                              ),
                            ),
                            if (_showLatin) ...[
                              const SizedBox(height: 8),
                              Text(item.latin,
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.5,
                                      color: sub,
                                      fontStyle: FontStyle.italic)),
                            ],
                            if (_showArti) ...[
                              const SizedBox(height: 6),
                              Text(item.meaning,
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.5,
                                      color: body)),
                            ],
                            const SizedBox(height: 8),
                            Text('Referensi: ${item.reference}',
                                style:
                                    TextStyle(fontSize: 11.5, color: sub)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // tombol aksi bawah
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: done
                            ? null
                            : () async {
                                state.setDhikrAll(widget.date, widget.contentId,
                                    block: widget.block, done: true);
                                if (context.mounted) Navigator.pop(context);
                              },
                        icon: done
                            ? const Icon(Icons.check_circle, color: AppColors.done, size: 20)
                            : const Icon(Icons.done_all, size: 20),
                        label: Text(done
                            ? 'Rangkaian selesai'
                            : 'Tandai semua selesai'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.done,
                          side: const BorderSide(color: AppColors.done),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _rec.completedItems == 0
                          ? null
                          : () => state.setDhikrAll(widget.date, widget.contentId,
                              block: widget.block, done: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ulang'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
