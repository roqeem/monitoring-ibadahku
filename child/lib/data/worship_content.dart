/// Konten bacaan (doa & dzikir) — Arab, Latin, arti, referensi.
///
/// Catatan penting (sesuai PRD 8.9): konten agama wajib ditinjau ulang oleh
/// pihak yang memahami ilmu agama sebelum rilis publik. Teks di bawah adalah
/// bacaan standar yang umum dikenal dengan referensi hadis utama.
library;

class DhikrItem {
  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String meaning;
  final String reference;
  final int repeat; // jumlah pengulangan
  const DhikrItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.meaning,
    required this.reference,
    this.repeat = 1,
  });
}

class DhikrSequence {
  final String id;
  final String title;
  final String subtitle;
  final List<DhikrItem> items;
  const DhikrSequence({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  DhikrItem? itemById(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }
}

const List<DhikrSequence> kDhikrSequences = [
  // ---------------------------------------------------------------
  // DOA BANGUN TIDUR
  // ---------------------------------------------------------------
  DhikrSequence(
    id: 'doa_bangun_tidur',
    title: 'Doa Bangun Tidur',
    subtitle: 'Dibaca ketika terbangun dari tidur malam.',
    items: [
      DhikrItem(
        id: 'doa_bangun_tidur_1',
        title: 'Doa bangun tidur',
        arabic: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، الْحَمْدُ لِلَّهِ، وَسُبْحَانَ اللهِ، وَلَا إِلَهَ إِلَّا اللهُ، وَاللهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
        latin: 'Lā ilāha illallāhu waḥdahu lā syarīka lah, lahul-mulku wa lahul-ḥamdu, wa huwa ʿalā kulli syaiʾin qadīr. Alḥamdulillāh, wa subḥānallāh, wa lā ilāha illallāh, wallāhu akbar, wa lā ḥaula wa lā quwwata illā billāh.',
        meaning: 'Tiada Tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Mahakuasa atas segala sesuatu. Segala puji bagi Allah, Mahasuci Allah, tiada Tuhan selain Allah, Allah Mahabesar, dan tiada daya dan kekuatan kecuali dengan (pertolongan) Allah.',
        reference: 'HR. Bukhari no. 1154',
      ),
    ],
  ),

  // ---------------------------------------------------------------
  // DZIKIR SETELAH SHALAT
  // ---------------------------------------------------------------
  DhikrSequence(
    id: 'dzikir_setelah_shalat',
    title: 'Dzikir Setelah Shalat',
    subtitle: 'Dzikir ringkas setelah shalat fardhu.',
    items: [
      DhikrItem(
        id: 'dzikir_setelah_shalat_1',
        title: 'Istighfar',
        arabic: 'أَسْتَغْفِرُ اللهَ',
        latin: 'Astaghfirullâh.',
        meaning: 'Aku memohon ampun kepada Allah.',
        reference: 'HR. Muslim no. 591',
        repeat: 3,
      ),
      DhikrItem(
        id: 'dzikir_setelah_shalat_2',
        title: 'Salam penutup',
        arabic: 'اَللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        latin: 'Allâhumma antas-salâm wa minkas-salâm, tabârakta yâ dzal-jalâli wal-ikrâm.',
        meaning: 'Ya Allah, Engkau Maha Sejahtera dan dari-Mu kesejahteraan. Maha Berkah Engkau, wahai Pemilik keagungan dan kemuliaan.',
        reference: 'HR. Muslim no. 591',
      ),
      DhikrItem(
        id: 'dzikir_setelah_shalat_3',
        title: 'Doa setelah salam',
        arabic: 'اَللّٰهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ وَلَا مُعْطِيَ لِمَا مَنَعْتَ وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
        latin: 'Allâhumma lâ mâni‘a limâ a‘thaita wa lâ mu‘thiya limâ mana‘ta wa lâ yanfa‘u dzal-jaddi minkal-jadd.',
        meaning: 'Ya Allah, tidak ada yang mencegah apa yang Engkau berikan, tidak ada yang memberi apa yang Engkau cegah, dan kekayaan tidak bermanfaat bagi pemiliknya dari-Mu.',
        reference: 'HR. Bukhari no. 844, Muslim no. 593',
      ),
      DhikrItem(
        id: 'dzikir_setelah_shalat_4',
        title: 'Ayat Kursi',
        arabic: 'اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ الْحَيُّ الْقَيُّوْمُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَّلَا نَوْمٌ ۗ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِ ۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖ ۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۖ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
        latin: 'Allâhu lâ ilâha illâ huwal-hayyul-qayyûm, lâ ta’khudzuhû sinatuw wa lâ naum, lahû mâ fis-samâwâti wa mâ fil-ardh, man dzal-ladzî yasyfa‘u ‘indahû illâ bi-idznih, ya‘lamu mâ baina aidîhim wa mâ khalfahum, wa lâ yuhîthûna bisyai’in min ‘ilmihî illâ bimâ syâ’a, wasi‘a kursiyyuhus-samâwâti wal-ardh, wa lâ ya’ûduhû hifzhuhumâ, wa huwal-‘aliyyul-‘azhîm.',
        meaning: 'Allah, tidak ada ilah selain Dia, Yang Maha Hidup lagi terus mengurus makhluk-Nya. Tidak mengantuk dan tidak tidur. Milik-Nya apa yang di langit dan di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan dan di belakang mereka. Mereka tidak mengetahui sesuatu dari ilmu-Nya kecuali apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi, dan Dia tidak merasa berat memelihara keduanya. Dialah Yang Maha Tinggi lagi Maha Agung.',
        reference: 'QS. Al-Baqarah: 255',
      ),
      DhikrItem(
        id: 'dzikir_setelah_shalat_5',
        title: 'Tasbih, tahmid, takbir',
        arabic: 'سُبْحَانَ اللهِ . اَلْحَمْدُ لِلّٰهِ . اَللهُ أَكْبَرُ',
        latin: 'Subhânallâh. Alhamdulillâh. Allâhu akbar.',
        meaning: 'Maha Suci Allah. Segala puji bagi Allah. Allah Maha Besar.',
        reference: 'HR. Muslim no. 597',
        repeat: 33,
      ),
      DhikrItem(
        id: 'dzikir_setelah_shalat_6',
        title: 'Penyempurna tasbih',
        arabic: 'لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيْرٌ',
        latin: 'Lâ ilâha illallâhu wahdahû lâ syarîka lah, lahul-mulku wa lahul-hamdu wa huwa ‘alâ kulli syai’in qadîr.',
        meaning: 'Tidak ada ilah yang berhak disembah selain Allah semata, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan pujian, dan Dia Maha Kuasa atas segala sesuatu.',
        reference: 'HR. Muslim no. 597',
      ),
    ],
  ),

  // ---------------------------------------------------------------
  // DZIKIR PAGI
  // ---------------------------------------------------------------
  DhikrSequence(
    id: 'dzikir_pagi',
    title: 'Dzikir Pagi',
    subtitle: 'Dibaca setelah shalat Subuh hingga terbit matahari.',
    items: [
      DhikrItem(
        id: 'dzikir_pagi_1',
        title: 'Sayyidul Istighfar',
        arabic: 'اَللّٰهُمَّ أَنْتَ رَبِّيْ لَا إِلٰهَ إِلَّا أَنْتَ، خَلَقْتَنِيْ وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَإِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ',
        latin: 'Allâhumma anta rabbî lâ ilâha illâ ant, khalaqtanî wa anâ ‘abduk, wa anâ ‘alâ ‘ahdika wa wa‘dika mastatha‘t. A‘ûdzu bika min syarri mâ shana‘t. Abû’u laka bini‘matika ‘alayya, wa abû’u bidzanbî faghfir lî fa innahû lâ yaghfirudz-dzunûba illâ ant.',
        meaning: 'Ya Allah, Engkau Rabb-ku, tidak ada ilah selain Engkau. Engkau menciptakanku dan aku hamba-Mu. Aku di atas perjanjian-Mu semampuku. Aku berlindung kepada-Mu dari keburukan perbuatanku. Aku mengakui nikmat-Mu kepadaku dan mengakui dosaku, maka ampunilah aku. Sungguh tidak ada yang mengampuni dosa kecuali Engkau.',
        reference: 'HR. Bukhari no. 6306',
      ),
      DhikrItem(
        id: 'dzikir_pagi_2',
        title: 'Perlindungan dari siksa',
        arabic: 'اَللّٰهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوْتُ، وَإِلَيْكَ النُّشُوْرُ',
        latin: 'Allâhumma bika ashbahnâ, wa bika amsainâ, wa bika nahyâ, wa bika namûtu, wa ilaikan-nusyûr.',
        meaning: 'Ya Allah, dengan-Mu kami memasuki pagi, dengan-Mu kami memasuki petang, dengan-Mu kami hidup, dengan-Mu kami mati, dan kepada-Mu kebangkitan.',
        reference: 'HR. Tirmidzi no. 3391',
      ),
      DhikrItem(
        id: 'dzikir_pagi_3',
        title: 'Tiga Qul',
        arabic: 'قُلْ هُوَ اللهُ أَحَدٌ ۝ اللهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُوْلَدْ ۝ وَلَمْ يَكُنْ لَّهُ كُفُوًا أَحَدٌ',
        latin: 'Qul huwallâhu ahad. Allâhush-shamad. Lam yalid wa lam yûlad. Wa lam yakul lahû kufuwan ahad.',
        meaning: 'Katakanlah: Dialah Allah Yang Maha Esa. Allah tempat meminta segala sesuatu. Dia tidak beranak dan tidak diperanakkan. Dan tidak ada seorang pun yang setara dengan Dia.',
        reference: 'QS. Al-Ikhlas: 1-4',
        repeat: 3,
      ),
      DhikrItem(
        id: 'dzikir_pagi_4',
        title: 'Tasbih dan tahmid',
        arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        latin: 'Subhânallâhi wa bihamdih.',
        meaning: 'Maha Suci Allah dan segala puji bagi-Nya.',
        reference: 'HR. Muslim no. 2692',
        repeat: 100,
      ),
      DhikrItem(
        id: 'dzikir_pagi_5',
        title: 'Doa pagi hari',
        arabic: 'اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
        latin: 'Allâhumma innî as’alukal-‘afwa wal-‘âfiyata fid-dunyâ wal-âkhirah.',
        meaning: 'Ya Allah, aku memohon ampunan dan keselamatan di dunia dan akhirat.',
        reference: 'HR. Abu Dawud no. 5074',
      ),
    ],
  ),

  // ---------------------------------------------------------------
  // DZIKIR PETANG
  // ---------------------------------------------------------------
  DhikrSequence(
    id: 'dzikir_petang',
    title: 'Dzikir Petang',
    subtitle: 'Dibaca setelah shalat Ashar hingga terbenam matahari.',
    items: [
      DhikrItem(
        id: 'dzikir_petang_1',
        title: 'Sayyidul Istighfar',
        arabic: 'اَللّٰهُمَّ أَنْتَ رَبِّيْ لَا إِلٰهَ إِلَّا أَنْتَ، خَلَقْتَنِيْ وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَإِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ',
        latin: 'Allâhumma anta rabbî lâ ilâha illâ ant, khalaqtanî wa anâ ‘abduk, wa anâ ‘alâ ‘ahdika wa wa‘dika mastatha‘t. A‘ûdzu bika min syarri mâ shana‘t. Abû’u laka bini‘matika ‘alayya, wa abû’u bidzanbî faghfir lî fa innahû lâ yaghfirudz-dzunûba illâ ant.',
        meaning: 'Ya Allah, Engkau Rabb-ku, tidak ada ilah selain Engkau. Engkau menciptakanku dan aku hamba-Mu. Aku di atas perjanjian-Mu semampuku. Aku berlindung kepada-Mu dari keburukan perbuatanku. Aku mengakui nikmat-Mu kepadaku dan mengakui dosaku, maka ampunilah aku. Sungguh tidak ada yang mengampuni dosa kecuali Engkau.',
        reference: 'HR. Bukhari no. 6306',
      ),
      DhikrItem(
        id: 'dzikir_petang_2',
        title: 'Perlindungan dari siksa',
        arabic: 'اَللّٰهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوْتُ، وَإِلَيْكَ الْمَصِيْرُ',
        latin: 'Allâhumma bika amsainâ, wa bika ashbahnâ, wa bika nahyâ, wa bika namûtu, wa ilaikal-mashîr.',
        meaning: 'Ya Allah, dengan-Mu kami memasuki petang, dengan-Mu kami memasuki pagi, dengan-Mu kami hidup, dengan-Mu kami mati, dan kepada-Mu tempat kembali.',
        reference: 'HR. Tirmidzi no. 3391',
      ),
      DhikrItem(
        id: 'dzikir_petang_3',
        title: 'Tiga Qul',
        arabic: 'قُلْ هُوَ اللهُ أَحَدٌ ۝ اللهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُوْلَدْ ۝ وَلَمْ يَكُنْ لَّهُ كُفُوًا أَحَدٌ',
        latin: 'Qul huwallâhu ahad. Allâhush-shamad. Lam yalid wa lam yûlad. Wa lam yakul lahû kufuwan ahad.',
        meaning: 'Katakanlah: Dialah Allah Yang Maha Esa. Allah tempat meminta segala sesuatu. Dia tidak beranak dan tidak diperanakkan. Dan tidak ada seorang pun yang setara dengan Dia.',
        reference: 'QS. Al-Ikhlas: 1-4',
        repeat: 3,
      ),
      DhikrItem(
        id: 'dzikir_petang_4',
        title: 'Tasbih dan tahmid',
        arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        latin: 'Subhânallâhi wa bihamdih.',
        meaning: 'Maha Suci Allah dan segala puji bagi-Nya.',
        reference: 'HR. Muslim no. 2692',
        repeat: 100,
      ),
      DhikrItem(
        id: 'dzikir_petang_5',
        title: 'Doa petang hari',
        arabic: 'اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
        latin: 'Allâhumma innî as’alukal-‘afwa wal-‘âfiyata fid-dunyâ wal-âkhirah.',
        meaning: 'Ya Allah, aku memohon ampunan dan keselamatan di dunia dan akhirat.',
        reference: 'HR. Abu Dawud no. 5074',
      ),
    ],
  ),

  // ---------------------------------------------------------------
  // DZIKIR SEBELUM TIDUR
  // ---------------------------------------------------------------
  DhikrSequence(
    id: 'dzikir_sebelum_tidur',
    title: 'Dzikir Sebelum Tidur',
    subtitle: 'Dibaca sebelum tidur.',
    items: [
      DhikrItem(
        id: 'dzikir_sebelum_tidur_1',
        title: 'Ayat Kursi',
        arabic: 'اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ الْحَيُّ الْقَيُّوْمُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَّلَا نَوْمٌ ۗ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِ ۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖ ۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۖ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
        latin: 'Allâhu lâ ilâha illâ huwal-hayyul-qayyûm, lâ ta’khudzuhû sinatuw wa lâ naum, lahû mâ fis-samâwâti wa mâ fil-ardh, man dzal-ladzî yasyfa‘u ‘indahû illâ bi-idznih, ya‘lamu mâ baina aidîhim wa mâ khalfahum, wa lâ yuhîthûna bisyai’in min ‘ilmihî illâ bimâ syâ’a, wasi‘a kursiyyuhus-samâwâti wal-ardh, wa lâ ya’ûduhû hifzhuhumâ, wa huwal-‘aliyyul-‘azhîm.',
        meaning: 'Allah, tidak ada ilah selain Dia, Yang Maha Hidup lagi terus mengurus makhluk-Nya. Tidak mengantuk dan tidak tidur. Milik-Nya apa yang di langit dan di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan dan di belakang mereka. Mereka tidak mengetahui sesuatu dari ilmu-Nya kecuali apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi, dan Dia tidak merasa berat memelihara keduanya. Dialah Yang Maha Tinggi lagi Maha Agung.',
        reference: 'QS. Al-Baqarah: 255',
      ),
      DhikrItem(
        id: 'dzikir_sebelum_tidur_2',
        title: 'Surat Al-Ikhlas',
        arabic: 'قُلْ هُوَ اللهُ أَحَدٌ ۝ اللهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُوْلَدْ ۝ وَلَمْ يَكُنْ لَّهُ كُفُوًا أَحَدٌ',
        latin: 'Qul huwallâhu ahad. Allâhush-shamad. Lam yalid wa lam yûlad. Wa lam yakul lahû kufuwan ahad.',
        meaning: 'Katakanlah: Dialah Allah Yang Maha Esa. Allah tempat meminta segala sesuatu. Dia tidak beranak dan tidak diperanakkan. Dan tidak ada seorang pun yang setara dengan Dia.',
        reference: 'QS. Al-Ikhlas: 1-4',
        repeat: 3,
      ),
      DhikrItem(
        id: 'dzikir_sebelum_tidur_3',
        title: 'Surat Al-Falaq',
        arabic: 'قُلْ أَعُوْذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفّٰثٰتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        latin: 'Qul a‘ûdzu birabbil-falaq. Min syarri mâ khalaq. Wa min syarri ghâsiqin idzâ waqab. Wa min syarri nnaffâtsâti fil-‘uqad. Wa min syarri hâsidin idzâ hasad.',
        meaning: 'Katakanlah: Aku berlindung kepada Tuhan yang menguasai subuh, dari kejahatan makhluk yang Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan perempuan-perempuan penyihir yang meniup pada buhul-buhul, dan dari kejahatan orang yang dengki apabila ia dengki.',
        reference: 'QS. Al-Falaq: 1-5',
        repeat: 3,
      ),
      DhikrItem(
        id: 'dzikir_sebelum_tidur_4',
        title: 'Surat An-Nas',
        arabic: 'قُلْ أَعُوْذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
        latin: 'Qul a‘ûdzu birabbin-nâs. Malikinnâs. Ilâhinnâs. Min syarril-waswâsil-khannâs. Alladzî yuwaswisu fî shudûrin-nâs. Minal-jinnati wan-nâs.',
        meaning: 'Katakanlah: Aku berlindung kepada Tuhannya manusia, Raja manusia, sesembahan manusia, dari kejahatan bisikan setan yang bersembunyi, yang membisikkan ke dalam dada manusia, dari golongan jin dan manusia.',
        reference: 'QS. An-Nas: 1-6',
        repeat: 3,
      ),
      DhikrItem(
        id: 'dzikir_sebelum_tidur_5',
        title: 'Tasbih, tahmid, takbir',
        arabic: 'سُبْحَانَ اللهِ . اَلْحَمْدُ لِلّٰهِ . اَللهُ أَكْبَرُ',
        latin: 'Subhânallâh. Alhamdulillâh. Allâhu akbar.',
        meaning: 'Maha Suci Allah. Segala puji bagi Allah. Allah Maha Besar.',
        reference: 'HR. Bukhari no. 6318',
        repeat: 33,
      ),
      DhikrItem(
        id: 'dzikir_sebelum_tidur_6',
        title: 'Doa penutup malam',
        arabic: 'اَللّٰهُمَّ قِنِيْ عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        latin: 'Allâhumma qinî ‘adzâbaka yauma tab‘atsu ‘ibâdak.',
        meaning: 'Ya Allah, lindungilah aku dari siksa-Mu pada hari Engkau membangkitkan hamba-hamba-Mu.',
        reference: 'HR. Abu Dawud no. 5045',
      ),
    ],
  ),

  // ---------------------------------------------------------------
  // DOA SEBELUM TIDUR
  // ---------------------------------------------------------------
  DhikrSequence(
    id: 'doa_sebelum_tidur',
    title: 'Doa Sebelum Tidur',
    subtitle: 'Dibaca ketika hendak tidur.',
    items: [
      DhikrItem(
        id: 'doa_sebelum_tidur_1',
        title: 'Doa sebelum tidur',
        arabic: 'بِاسْمِكَ اللّٰهُمَّ أَمُوْتُ وَأَحْيَا',
        latin: 'Bismika allâhumma amûtu wa ahyâ.',
        meaning: 'Dengan nama-Mu ya Allah, aku mati dan aku hidup.',
        reference: 'HR. Bukhari no. 6324',
      ),
    ],
  ),
];

DhikrSequence sequenceById(String id) =>
    kDhikrSequences.firstWhere((s) => s.id == id);

/// Daftar kota Indonesia untuk pemilihan lokasi manual (koordinat perkiraan).
class CityInfo {
  final String name;
  final double lat;
  final double lon;
  const CityInfo(this.name, this.lat, this.lon);
}

const List<CityInfo> kCities = [
  CityInfo('Jakarta', -6.2088, 106.8456),
  CityInfo('Bandung', -6.9175, 107.6191),
  CityInfo('Surabaya', -7.2575, 112.7521),
  CityInfo('Medan', 3.5952, 98.6722),
  CityInfo('Makassar', -5.1477, 119.4327),
  CityInfo('Yogyakarta', -7.7956, 110.3695),
  CityInfo('Semarang', -6.9667, 110.4167),
  CityInfo('Palembang', -2.9761, 104.7754),
  CityInfo('Denpasar', -8.6705, 115.2126),
  CityInfo('Banda Aceh', 5.5483, 95.3238),
  CityInfo('Padang', -0.9471, 100.4172),
  CityInfo('Pekanbaru', 0.5071, 101.4478),
  CityInfo('Banjarmasin', -3.3186, 114.5944),
  CityInfo('Pontianak', -0.0263, 109.3425),
  CityInfo('Samarinda', -0.5022, 117.1536),
  CityInfo('Manado', 1.4748, 124.8421),
  CityInfo('Jayapura', -2.5916, 140.6690),
  CityInfo('Kupang', -10.1772, 123.6070),
  CityInfo('Ambon', -3.6954, 128.1814),
  CityInfo('Mataram', -8.5833, 116.1167),
];

/// Daftar shalat fardhu urut waktu.
const List<String> kFardhuOrder = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
