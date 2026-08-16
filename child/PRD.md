# Product Requirements Document (PRD)

## Aplikasi Monitoring Ibadah Harian Muslim

**Nama sementara produk:** IbadahKu  
**Platform awal:** Android  
**Teknologi yang direkomendasikan:** Flutter + Firebase  
**Versi dokumen:** 1.1  
**Status:** Draft awal  
**Bahasa aplikasi:** Bahasa Indonesia  

---

## 1. Ringkasan Produk

IbadahKu adalah aplikasi Android pribadi untuk membantu pengguna mencatat, mengingat, dan mengevaluasi ibadah harian umat Islam, mulai dari bangun pada sepertiga malam hingga sebelum tidur.

Aplikasi menggunakan pendekatan timeline harian. Setiap aktivitas ibadah ditampilkan berdasarkan urutan waktu, seperti Tahajud, Witir, shalat fardhu, shalat sunnah rawatib, Dhuha, dzikir pagi-petang, dzikir setelah shalat, serta doa sebelum tidur.

Aplikasi bersifat pribadi, tidak memiliki fitur sosial, leaderboard, atau perbandingan ibadah antar pengguna.

---

## 2. Latar Belakang

Banyak umat Islam ingin menjaga konsistensi ibadah harian, tetapi sering mengalami kendala seperti:

- Lupa melakukan ibadah sunnah.
- Tidak memiliki catatan ibadah yang terstruktur.
- Sulit mengevaluasi konsistensi ibadah.
- Pengingat shalat hanya terbatas pada jadwal azan.
- Tidak adanya satu aplikasi yang menggabungkan shalat, dzikir, doa, dan riwayat ibadah pribadi dalam satu alur harian.

Aplikasi ini dibuat sebagai alat bantu pencatatan pribadi, bukan sebagai alat untuk menilai tingkat keimanan pengguna.

---

## 3. Tujuan Produk

### 3.1 Tujuan Utama

- Membantu pengguna mengingat ibadah harian.
- Memudahkan pengguna mencatat pelaksanaan ibadah.
- Menampilkan aktivitas ibadah berdasarkan urutan waktu.
- Menyediakan doa dan dzikir dalam teks Arab, Latin, dan arti.
- Menyediakan riwayat ibadah harian, mingguan, dan bulanan.
- Menjaga data pengguna melalui akun dan sinkronisasi cloud.
- Tetap dapat digunakan ketika koneksi internet tidak tersedia.

### 3.2 Tujuan yang Tidak Termasuk

Aplikasi tidak bertujuan untuk:

- Mengukur atau menilai tingkat keimanan.
- Membandingkan ibadah antar pengguna.
- Membuat leaderboard.
- Menampilkan skor religius atau persentase keimanan.
- Menjadi pengganti bimbingan ulama atau guru agama.
- Menjadi aplikasi komunitas atau media sosial.

---

## 4. Target Pengguna

### 4.1 Pengguna Utama

Muslim dewasa atau remaja yang ingin:

- Meningkatkan konsistensi ibadah.
- Membuat catatan ibadah pribadi.
- Mendapat pengingat shalat dan ibadah sunnah.
- Membaca dzikir dan doa harian.
- Melihat riwayat pelaksanaan ibadah.

### 4.2 Karakteristik Pengguna

- Menggunakan perangkat Android.
- Memiliki akun Google atau email.
- Memahami penggunaan aplikasi mobile dasar.
- Membutuhkan aplikasi sederhana dan tidak rumit.
- Mengutamakan privasi data ibadah.

---

## 5. Platform dan Strategi Rilis

### 5.1 Platform MVP

- Android.

### 5.2 Rekomendasi Teknologi

- Flutter untuk aplikasi mobile.
- Firebase Authentication untuk login.
- Cloud Firestore untuk penyimpanan cloud.
- Penyimpanan lokal untuk mode offline.
- Local notification dan alarm Android untuk pengingat.
- Perhitungan jadwal shalat berdasarkan lokasi pengguna.

### 5.3 Rencana Platform Berikutnya

- iOS dapat dikembangkan setelah versi Android stabil.
- Pengembangan menggunakan Flutter agar sebagian besar kode dapat digunakan kembali.

---

## 6. Ruang Lingkup MVP

MVP mencakup:

1. Registrasi dan login.
2. Pengaturan profil dasar.
3. Penentuan lokasi dan jadwal shalat.
4. Timeline ibadah harian.
5. Checklist shalat fardhu.
6. Checklist Tahajud.
7. Checklist Witir.
8. Checklist Dhuha.
9. Checklist shalat sunnah rawatib.
10. Doa bangun tidur.
11. Dzikir setelah shalat.
12. Dzikir pagi.
13. Dzikir petang.
14. Dzikir sebelum tidur.
15. Doa sebelum tidur.
16. Notifikasi azan atau notifikasi biasa.
17. Riwayat harian, mingguan, dan bulanan.
18. Dashboard statistik dan chart aktivitas ibadah.
19. Sinkronisasi cloud.
20. Mode offline.
21. Pengaturan kondisi khusus seperti musafir dan haid/nifas.

---

## 7. Struktur Navigasi

Navigasi utama aplikasi terdiri dari empat menu:

1. **Hari Ini**
2. **Bacaan**
3. **Riwayat**
4. **Statistik**
5. **Pengaturan**

---

## 8. Fitur dan Kebutuhan Fungsional

# 8.1 Registrasi dan Login

## Deskripsi

Pengguna harus login sebelum menggunakan aplikasi.

## Metode Login

- Login dengan Google.
- Login dengan email dan password.
- Registrasi dengan email dan password.
- Lupa password.
- Logout.
- Hapus akun.

## Aturan

- Setiap pengguna hanya dapat melihat datanya sendiri.
- Seluruh data ibadah harus terkait dengan ID pengguna.
- Setelah login pada perangkat baru, data harus dapat dipulihkan.
- Pengguna tetap dapat melihat data lokal terakhir ketika koneksi internet terputus.

## Acceptance Criteria

- Pengguna dapat membuat akun.
- Pengguna dapat login menggunakan Google.
- Pengguna dapat login menggunakan email dan password.
- Pengguna dapat meminta reset password.
- Pengguna dapat logout.
- Pengguna dapat menghapus akun dan seluruh data terkait.

---

# 8.2 Onboarding

## Tujuan

Mengumpulkan pengaturan awal sebelum pengguna masuk ke halaman utama.

## Data yang Dikumpulkan

- Nama panggilan.
- Jenis kelamin.
- Lokasi otomatis atau lokasi manual.
- Metode perhitungan jadwal shalat.
- Mazhab perhitungan waktu Ashar.
- Pilihan suara azan atau notifikasi.
- Izin lokasi.
- Izin notifikasi.
- Izin alarm presisi jika diperlukan.

## Acceptance Criteria

- Pengguna dapat menyelesaikan onboarding.
- Pengguna dapat melewati pengaturan yang tidak wajib.
- Pengguna dapat mengubah seluruh pengaturan onboarding melalui menu Pengaturan.

---

# 8.3 Halaman Hari Ini

## Deskripsi

Halaman utama menampilkan timeline ibadah berdasarkan urutan waktu dari sepertiga malam hingga sebelum tidur.

## Kelompok Timeline

### A. Sepertiga Malam

- Doa bangun tidur.
- Shalat Tahajud.
- Shalat Witir.

### B. Subuh

- Qabliyah Subuh 2 rakaat.
- Shalat Subuh.
- Dzikir setelah shalat.
- Dzikir pagi.

### C. Pagi

- Shalat Dhuha.

### D. Dzuhur

- Qabliyah Dzuhur 4 rakaat.
- Shalat Dzuhur.
- Ba'diyah Dzuhur 2 rakaat.
- Dzikir setelah shalat.

### E. Ashar

- Shalat Ashar.
- Dzikir setelah shalat.
- Dzikir petang.
- Qabliyah Ashar 4 rakaat sebagai pilihan tambahan.

### F. Maghrib

- Shalat Maghrib.
- Ba'diyah Maghrib 2 rakaat.
- Dzikir setelah shalat.

### G. Isya

- Shalat Isya.
- Ba'diyah Isya 2 rakaat.
- Dzikir setelah shalat.

### H. Sebelum Tidur

- Dzikir sebelum tidur.
- Doa sebelum tidur.

## Aturan Tampilan

- Timeline mengikuti jadwal shalat pengguna.
- Aktivitas yang sudah selesai diberi status selesai.
- Aktivitas yang belum dilakukan tetap dapat diisi selama tanggal terkait belum dikunci.
- Pengguna dapat membuka tanggal sebelumnya melalui halaman Riwayat.
- Urutan shalat sunnah harus tampil sebelum atau sesudah shalat fardhu sesuai jenisnya.

## Acceptance Criteria

- Semua aktivitas tampil dalam urutan waktu.
- Status checklist tersimpan.
- Data tetap terlihat setelah aplikasi ditutup dan dibuka kembali.
- Data dapat disinkronkan ke cloud.

---

# 8.4 Checklist Shalat Fardhu

## Shalat yang Didukung

- Subuh.
- Dzuhur.
- Ashar.
- Maghrib.
- Isya.
- Jumat sebagai pengganti Dzuhur untuk pengguna yang melaksanakannya.

## Field Checklist

### Status

- Sudah dikerjakan.
- Belum dikerjakan.
- Terlewat.
- Qadha.
- Uzur syar'i.

### Tempat

- Masjid.
- Musala.
- Rumah.
- Tempat kerja.
- Tempat lainnya.

### Pelaksanaan

- Berjamaah.
- Sendiri.

### Waktu

- Awal waktu.
- Masih dalam waktu.
- Akhir waktu.
- Di luar waktu atau qadha.

### Catatan

- Opsional.
- Maksimal 500 karakter.

## Aturan Bisnis

- Tempat, pelaksanaan, dan waktu adalah kategori terpisah.
- Jika status `Uzur syar'i`, field tempat, pelaksanaan, dan waktu tidak wajib.
- Jika status `Qadha`, kategori waktu otomatis menjadi `Di luar waktu atau qadha`.
- Jika status `Belum dikerjakan`, data belum dianggap selesai.
- Pengguna dapat memperbarui checklist selama tanggal masih dapat diedit.
- Aplikasi tidak memberikan penilaian moral atas pilihan pengguna.

## Acceptance Criteria

- Pengguna dapat mengisi seluruh field.
- Pengguna dapat mengubah data.
- Data tersimpan dengan tanggal, waktu, dan ID pengguna.
- Status tampil di timeline dan riwayat.

---

# 8.5 Shalat Tahajud

## Pilihan Rakaat

- 2 rakaat.
- 4 rakaat.
- 6 rakaat.
- 8 rakaat.
- Isi sendiri.

## Aturan

- Input manual harus berupa angka genap.
- Minimal 2 rakaat.
- Batas maksimal default 100 rakaat.
- Pengguna dapat menambahkan catatan opsional.
- Tahajud dan Witir disimpan sebagai aktivitas terpisah.

## Acceptance Criteria

- Pengguna dapat memilih jumlah rakaat.
- Pengguna dapat mengisi jumlah rakaat manual.
- Sistem menolak angka ganjil.
- Data tampil dalam riwayat.

---

# 8.6 Shalat Witir

## Pilihan Rakaat

- 1 rakaat.
- 3 rakaat.
- Isi sendiri.

## Aturan

- Input manual harus berupa angka ganjil.
- Minimal 1 rakaat.
- Batas maksimal default 99 rakaat.
- Pengguna dapat mengisi Witir meskipun tidak mengisi Tahajud.

## Acceptance Criteria

- Pengguna dapat memilih 1 atau 3 rakaat.
- Pengguna dapat mengisi angka ganjil lain.
- Sistem menolak angka genap.

---

# 8.7 Shalat Dhuha

## Pilihan Rakaat

- 2 rakaat.
- 4 rakaat.
- 6 rakaat.
- 8 rakaat.
- Isi sendiri.

## Aturan

- Input manual harus berupa angka genap.
- Minimal 2 rakaat.
- Batas maksimal default 100 rakaat.

## Acceptance Criteria

- Pengguna dapat memilih atau mengisi jumlah rakaat.
- Sistem menolak angka ganjil.
- Data masuk ke riwayat.

---

# 8.8 Shalat Sunnah Rawatib

## Daftar Rawatib Utama

- 2 rakaat sebelum Subuh.
- 4 rakaat sebelum Dzuhur.
- 2 rakaat setelah Dzuhur.
- 2 rakaat setelah Maghrib.
- 2 rakaat setelah Isya.

## Aktivitas Sunnah Tambahan Opsional

- 4 rakaat sebelum Ashar.
- 2 rakaat sebelum Maghrib.
- 2 rakaat sebelum Isya.

## Aturan Tampilan

- Qabliyah tampil sebelum shalat fardhu terkait.
- Ba'diyah tampil setelah shalat fardhu terkait.
- Aktivitas sunnah tambahan tidak aktif secara default.
- Aktivitas tambahan dapat diaktifkan melalui Pengaturan.

## Data yang Disimpan

- Jenis shalat sunnah.
- Jumlah rakaat.
- Status selesai.
- Tanggal dan waktu pencatatan.
- Catatan opsional.

---

# 8.9 Doa dan Dzikir

## Konten MVP

### Doa

- Doa bangun tidur.
- Doa sebelum tidur.

### Dzikir

- Dzikir setelah shalat.
- Dzikir pagi.
- Dzikir petang.
- Dzikir sebelum tidur.

## Format Konten

Setiap bacaan harus memiliki:

- Teks Arab.
- Transliterasi Latin.
- Arti Bahasa Indonesia.
- Referensi atau sumber.
- Urutan bacaan.
- Jumlah pengulangan jika ada.

## Interaksi

- Pengguna dapat menandai setiap bacaan sebagai selesai.
- Pengguna dapat menandai seluruh rangkaian sebagai selesai.
- Pengguna dapat memperbesar ukuran teks.
- Pengguna dapat memilih menampilkan atau menyembunyikan Latin.
- Pengguna dapat memilih menampilkan atau menyembunyikan arti.

## Aturan Konten

- Konten harus ditinjau oleh pihak yang memahami ilmu agama sebelum publikasi.
- Aplikasi harus menghindari klaim agama tanpa referensi.
- Audio tidak termasuk dalam MVP.

## Acceptance Criteria

- Teks Arab tampil dengan benar.
- Latin dan arti tampil sesuai pengaturan.
- Status selesai tersimpan.
- Sumber bacaan dapat dilihat.

---

# 8.10 Jadwal Shalat

## Deskripsi

Jadwal shalat dihitung berdasarkan lokasi pengguna.

## Input

- Lokasi otomatis melalui GPS.
- Pemilihan kota secara manual.
- Metode perhitungan.
- Mazhab perhitungan Ashar.
- Koreksi menit per waktu shalat.

## Waktu yang Ditampilkan

- Subuh.
- Terbit.
- Dhuha.
- Dzuhur.
- Ashar.
- Maghrib.
- Isya.
- Sepertiga malam.

## Aturan

- Jadwal terakhir harus tetap tersedia secara offline.
- Pengguna dapat memperbarui lokasi.
- Sistem harus menampilkan waktu pembaruan jadwal terakhir.
- Pengguna dapat mengoreksi jadwal masing-masing shalat dalam satuan menit.

---

# 8.11 Notifikasi dan Azan

## Pilihan Pengingat

Untuk setiap shalat dan aktivitas tertentu, pengguna dapat memilih:

- Suara azan.
- Notifikasi biasa.
- Getar.
- Tanpa pengingat.

## Aktivitas yang Mendukung Pengingat

- Tahajud.
- Witir.
- Subuh.
- Dhuha.
- Dzuhur.
- Ashar.
- Dzikir petang.
- Maghrib.
- Isya.
- Doa dan dzikir sebelum tidur.
- Rawatib sebelum shalat.

## Pengaturan Waktu

- Tepat saat masuk waktu.
- 5 menit sebelumnya.
- 10 menit sebelumnya.
- 15 menit sebelumnya.
- 30 menit sebelumnya.
- Waktu khusus.

## Aturan

- Pengguna dapat memilih pengaturan berbeda untuk setiap shalat.
- Notifikasi harus dijadwalkan ulang ketika lokasi berubah.
- Notifikasi harus dijadwalkan ulang ketika koreksi jadwal berubah.
- Pengguna harus diberi informasi jika izin notifikasi tidak aktif.
- Pengguna harus diberi informasi jika alarm presisi tidak aktif.
- Aplikasi harus menangani restart perangkat dan menjadwalkan ulang alarm.
- Azan harus dapat dihentikan dari notifikasi.
- Volume azan mengikuti pengaturan yang disediakan aplikasi dan batas sistem Android.

## Acceptance Criteria

- Pengingat muncul sesuai pengaturan.
- Pengingat tetap bekerja setelah perangkat restart.
- Pengingat dapat dimatikan per aktivitas.
- Aplikasi menampilkan peringatan bila izin penting belum diberikan.

---

# 8.12 Riwayat Ibadah

## Tampilan

Halaman Riwayat berfokus pada data per tanggal. Visualisasi grafik lengkap tersedia pada menu Statistik.

### Harian

Menampilkan semua aktivitas pada satu tanggal.

### Mingguan

Menampilkan ringkasan tujuh hari.

### Bulanan

Menampilkan kalender dan ringkasan satu bulan.

## Data Ringkasan

- Jumlah shalat fardhu tercatat.
- Jumlah shalat berjamaah.
- Jumlah shalat di awal waktu.
- Jumlah shalat di masjid.
- Jumlah Tahajud.
- Jumlah Witir.
- Jumlah Dhuha.
- Jumlah rawatib.
- Jumlah dzikir pagi.
- Jumlah dzikir petang.
- Jumlah doa sebelum tidur.

## Aturan

- Tidak ada skor keimanan.
- Tidak ada perbandingan dengan pengguna lain.
- Ringkasan menggunakan bahasa netral.
- Pengguna dapat melihat detail per tanggal.
- Pengguna dapat memperbaiki data tanggal sebelumnya.

## Contoh Narasi

- `Bulan ini Anda mencatat 18 shalat Subuh berjamaah.`
- `Dzikir pagi tercatat pada 20 dari 30 hari.`
- `Tahajud tercatat sebanyak 8 kali bulan ini.`

---

# 8.13 Dashboard Statistik dan Chart

## Deskripsi

Dashboard Statistik menampilkan ringkasan visual dari data ibadah yang telah dicatat pengguna. Statistik bersifat pribadi dan digunakan untuk membantu pengguna melihat pola serta konsistensi pencatatan ibadah.

Dashboard tidak boleh menampilkan skor keimanan, peringkat, penilaian moral, atau perbandingan dengan pengguna lain.

## Filter Periode

- 7 hari terakhir.
- 30 hari terakhir.
- Bulan berjalan.
- Bulan sebelumnya.
- Rentang tanggal khusus.

## Filter Data

- Semua kegiatan.
- Shalat fardhu.
- Shalat sunnah.
- Dzikir dan doa.
- Jenis shalat tertentu.
- Tempat pelaksanaan.
- Berjamaah atau sendiri.
- Kategori waktu pelaksanaan.

## Chart yang Ditampilkan

### A. Line Chart Konsistensi Harian

Menampilkan jumlah kegiatan ibadah yang tercatat setiap hari.

Aturan:

- Satu titik mewakili satu hari.
- Chart mengikuti urutan tanggal.
- Hari tanpa aktivitas tetap ditampilkan dengan nilai nol.

### B. Bar Chart Shalat Fardhu

Menampilkan perbandingan Subuh, Dzuhur, Ashar, Maghrib, Isya, dan Jumat jika digunakan.

Metrik:

- Sudah dikerjakan.
- Berjamaah.
- Sendiri.
- Awal waktu.
- Akhir waktu.
- Qadha.
- Masjid.
- Rumah.

### C. Bar Chart Ibadah Sunnah

Menampilkan jumlah pelaksanaan:

- Tahajud.
- Witir.
- Dhuha.
- Qabliyah Subuh.
- Qabliyah Dzuhur.
- Ba'diyah Dzuhur.
- Ba'diyah Maghrib.
- Ba'diyah Isya.
- Sunnah tambahan yang diaktifkan pengguna.

### D. Bar Chart Dzikir dan Doa

Menampilkan jumlah penyelesaian:

- Doa bangun tidur.
- Dzikir setelah shalat.
- Dzikir pagi.
- Dzikir petang.
- Dzikir sebelum tidur.
- Doa sebelum tidur.

### E. Pie atau Donut Chart Tempat Shalat

Menampilkan komposisi:

- Masjid.
- Musala.
- Rumah.
- Tempat kerja.
- Tempat lainnya.

Chart harus menampilkan jumlah dan persentase.

### F. Pie atau Donut Chart Pelaksanaan Shalat

Menampilkan komposisi:

- Berjamaah.
- Sendiri.

### G. Pie atau Donut Chart Ketepatan Waktu

Menampilkan komposisi:

- Awal waktu.
- Masih dalam waktu.
- Akhir waktu.
- Di luar waktu atau qadha.

### H. Kalender Konsistensi

Menampilkan kalender bulanan dengan indikator:

- Tidak ada data.
- Ada sebagian aktivitas tercatat.
- Aktivitas utama tercatat lengkap.
- Ada kondisi khusus seperti haid/nifas atau musafir.

Pengguna dapat menekan tanggal untuk membuka detail harian.

## Ringkasan Angka

- Total shalat fardhu tercatat.
- Total shalat berjamaah.
- Total shalat awal waktu.
- Total Tahajud.
- Total Witir.
- Total Dhuha.
- Total rawatib.
- Total dzikir pagi.
- Total dzikir petang.

## Aturan Data

- Chart hanya menggunakan data pengguna yang sedang login.
- Data haid/nifas tidak dihitung sebagai shalat terlewat.
- Data `Belum dikerjakan` tidak dihitung sebagai selesai.
- Data `Uzur syar'i` dipisahkan dari data terlewat.
- Perubahan riwayat harus langsung memperbarui statistik.
- Perhitungan chart harus konsisten antara Android dan Web.
- Statistik terakhir tetap dapat dilihat saat offline.
- Periode dan timezone mengikuti pengaturan pengguna.
- Tampilan tidak menggunakan skor keimanan atau bahasa yang menghakimi.

## Empty State

`Belum ada data yang cukup untuk menampilkan statistik pada periode ini.`

## Acceptance Criteria

- Pengguna dapat memilih periode statistik.
- Pengguna dapat memfilter jenis aktivitas dan metrik.
- Line chart menampilkan data harian secara berurutan.
- Bar chart menampilkan perbandingan antar jenis ibadah.
- Pie atau donut chart menampilkan jumlah dan persentase.
- Kalender dapat membuka detail per tanggal.
- Statistik berubah setelah data ibadah diperbarui.
- Kondisi haid/nifas tidak dihitung sebagai ibadah terlewat.
- Statistik terakhir dapat dilihat saat offline.
- Tidak ada skor keimanan, leaderboard, atau perbandingan antar pengguna.

---

# 8.14 Mode Kondisi Khusus

## Mode yang Didukung

- Haid atau nifas.
- Musafir.
- Sakit.
- Jamak.
- Qashar.

## Haid atau Nifas

- Dapat diaktifkan untuk rentang tanggal.
- Shalat fardhu pada periode tersebut tidak ditandai terlewat.
- Pengguna tetap dapat melihat doa dan dzikir yang relevan.
- Riwayat menampilkan status khusus tanpa penilaian negatif.

## Musafir

- Pengguna dapat mengaktifkan mode musafir.
- Pilihan jamak dan qashar tersedia.
- Pengguna dapat menentukan waktu mulai dan selesai mode musafir.

## Sakit

- Pengguna dapat memberi status sakit.
- Checklist shalat tetap tersedia.
- Catatan kondisi dapat diisi secara opsional.

---

# 8.15 Hari Jumat

## Fitur

Untuk hari Jumat, aplikasi dapat menampilkan:

- Mandi Jumat.
- Membaca Surah Al-Kahfi.
- Shalat Jumat.
- Datang lebih awal.
- Sedekah Jumat.
- Memperbanyak shalawat.

## Scope

- Fitur Jumat dapat masuk MVP jika waktu memungkinkan.
- Jika tidak, dimasukkan ke fase setelah MVP.
- Shalat Jumat dapat menggantikan checklist Dzuhur pada tanggal tersebut.

---

# 8.16 Pengaturan

## Pengaturan Akun

- Nama panggilan.
- Email.
- Metode login.
- Logout.
- Hapus akun.

## Pengaturan Tampilan

- Ukuran teks Arab.
- Tampilkan atau sembunyikan Latin.
- Tampilkan atau sembunyikan arti.
- Tema terang.
- Tema gelap.
- Ikuti sistem.

## Pengaturan Jadwal

- Lokasi.
- Metode perhitungan.
- Mazhab Ashar.
- Koreksi waktu shalat.
- Format waktu 12 atau 24 jam.

## Pengaturan Pengingat

- Pilihan azan atau notifikasi.
- Suara azan.
- Volume.
- Getar.
- Waktu pengingat.
- Pengingat per aktivitas.

## Pengaturan Ibadah

- Aktifkan Qabliyah Ashar.
- Aktifkan Qabliyah Maghrib.
- Aktifkan Qabliyah Isya.
- Aktifkan fitur Jumat.
- Atur waktu pengingat sebelum tidur.

## Pengaturan Data

- Status sinkronisasi terakhir.
- Sinkronkan sekarang.
- Hapus data lokal.
- Hapus seluruh riwayat.
- Hapus akun.

---

## 9. User Flow Utama

# 9.1 User Flow Registrasi

1. Pengguna membuka aplikasi.
2. Pengguna melihat halaman pembuka.
3. Pengguna memilih login Google atau email.
4. Pengguna berhasil login.
5. Pengguna masuk ke onboarding.
6. Pengguna memilih lokasi dan pengaturan jadwal.
7. Pengguna memberikan izin notifikasi.
8. Pengguna masuk ke halaman Hari Ini.

# 9.2 User Flow Checklist Shalat

1. Pengguna membuka Hari Ini.
2. Pengguna menekan item shalat.
3. Pengguna memilih status.
4. Pengguna memilih tempat.
5. Pengguna memilih berjamaah atau sendiri.
6. Pengguna memilih kategori waktu.
7. Pengguna menyimpan.
8. Timeline berubah menjadi selesai.
9. Data disimpan lokal dan disinkronkan.

# 9.3 User Flow Tahajud

1. Pengguna menekan item Tahajud.
2. Pengguna memilih jumlah rakaat.
3. Jika memilih isi sendiri, pengguna memasukkan angka.
4. Sistem melakukan validasi angka genap.
5. Pengguna menyimpan.
6. Aktivitas tercatat.

# 9.4 User Flow Dzikir

1. Pengguna membuka item dzikir.
2. Pengguna membaca teks Arab, Latin, dan arti.
3. Pengguna menandai bacaan satu per satu atau seluruh rangkaian.
4. Sistem menyimpan status selesai.
5. Timeline diperbarui.

# 9.5 User Flow Ganti Perangkat

1. Pengguna memasang aplikasi pada perangkat baru.
2. Pengguna login menggunakan akun yang sama.
3. Aplikasi mengambil data dari cloud.
4. Riwayat dan pengaturan dipulihkan.
5. Pengingat dijadwalkan ulang pada perangkat baru.

---

# 9.6 User Flow Statistik

1. Pengguna membuka menu Statistik.
2. Sistem menampilkan periode default.
3. Pengguna memilih periode dan filter.
4. Sistem memperbarui kartu ringkasan dan chart.
5. Pengguna menekan elemen chart atau tanggal kalender.
6. Sistem membuka detail data terkait.

---

## 10. Model Data Awal

# 10.1 User

- user_id
- display_name
- email
- gender
- created_at
- updated_at
- last_login_at

# 10.2 User Settings

- user_id
- latitude
- longitude
- city_name
- calculation_method
- asr_method
- time_adjustments
- language
- theme
- show_latin
- show_translation
- arabic_font_size
- notification_preferences
- optional_worship_preferences
- updated_at

# 10.3 Daily Worship Record

- record_id
- user_id
- worship_date
- timezone
- created_at
- updated_at
- sync_status

# 10.4 Prayer Record

- prayer_record_id
- daily_record_id
- prayer_name
- status
- place
- congregation_type
- time_category
- rakaat
- notes
- completed_at
- updated_at

# 10.5 Sunnah Prayer Record

- sunnah_record_id
- daily_record_id
- sunnah_type
- rakaat
- completed
- completed_at
- notes

# 10.6 Dhikr and Dua Record

- content_record_id
- daily_record_id
- content_type
- content_id
- completed
- completed_items
- total_items
- completed_at

# 10.7 Special Condition

- condition_id
- user_id
- condition_type
- start_date
- end_date
- notes
- created_at
- updated_at

# 10.8 Notification Settings

- notification_id
- user_id
- worship_type
- reminder_type
- reminder_offset
- sound_id
- vibration_enabled
- enabled
- updated_at

---

# 10.9 Statistik Agregat

Statistik dapat dihitung langsung dari data transaksi atau menggunakan agregasi untuk meningkatkan performa.

Field awal:

- user_id
- period_start
- period_end
- metric_type
- worship_type
- category
- total_count
- percentage
- generated_at
- source_updated_at

Aturan:

- Agregasi tidak boleh mencampurkan data antar pengguna.
- Data agregat harus dapat dibangun ulang dari data transaksi.
- Perubahan riwayat harus memicu perhitungan ulang statistik terkait.

---

## 11. Sinkronisasi dan Mode Offline

## Kebutuhan

- Semua perubahan disimpan terlebih dahulu secara lokal.
- Aplikasi dapat digunakan tanpa internet.
- Data disinkronkan ketika koneksi tersedia.
- Konflik data diselesaikan berdasarkan perubahan terbaru.
- Pengguna dapat melihat waktu sinkronisasi terakhir.
- Pengguna dapat memicu sinkronisasi manual.
- Kegagalan sinkronisasi tidak boleh menghapus data lokal.

## Status Sinkronisasi

- Tersinkron.
- Menunggu sinkronisasi.
- Gagal sinkronisasi.
- Sedang sinkronisasi.

---

## 12. Privasi dan Keamanan

## Prinsip

Data ibadah termasuk data pribadi dan harus diperlakukan secara sensitif.

## Kebutuhan

- Data pengguna hanya dapat diakses oleh pemilik akun.
- Akses database harus dibatasi berdasarkan user ID.
- Seluruh komunikasi menggunakan koneksi terenkripsi.
- Password tidak disimpan langsung oleh aplikasi.
- Pengguna dapat menghapus akun dan data.
- Pengguna harus mengetahui data apa saja yang disimpan.
- Aplikasi tidak menjual data pengguna.
- Aplikasi tidak menggunakan data ibadah untuk iklan yang dipersonalisasi.
- Log aplikasi tidak boleh menyimpan isi catatan pribadi secara terbuka.
- Token autentikasi harus disimpan secara aman.

## Penguncian Aplikasi

Fitur berikut direkomendasikan setelah MVP:

- PIN aplikasi.
- Sidik jari.
- Face unlock melalui autentikasi perangkat.

---

## 13. Kebutuhan Nonfungsional

# 13.1 Performa

- Halaman utama terbuka maksimal 3 detik pada perangkat menengah.
- Interaksi checklist terasa langsung.
- Penyimpanan lokal tidak bergantung pada koneksi internet.
- Sinkronisasi berjalan tanpa menghalangi penggunaan aplikasi.

# 13.2 Keandalan

- Data tidak hilang ketika aplikasi ditutup paksa.
- Alarm dijadwalkan ulang setelah restart.
- Jadwal shalat terakhir tetap tersedia secara offline.
- Kegagalan jaringan tidak menyebabkan aplikasi crash.

# 13.3 Aksesibilitas

- Ukuran teks dapat diperbesar.
- Kontras teks harus jelas.
- Tombol checklist memiliki area sentuh yang cukup.
- Aplikasi mendukung pembaca layar semampunya.
- Teks Arab tidak boleh terpotong.

# 13.4 Kompatibilitas

- Target awal Android 9 atau lebih baru.
- Layout harus mendukung berbagai ukuran layar.
- Aplikasi harus diuji pada perangkat dengan mode hemat baterai.

# 13.5 Lokalitas

- Bahasa awal adalah Bahasa Indonesia.
- Zona waktu mengikuti perangkat.
- Format tanggal mengikuti lokal Indonesia.
- Dukungan bahasa lain berada di luar MVP.

---

## 14. Desain dan Pengalaman Pengguna

## Prinsip Desain

- Tenang.
- Sederhana.
- Tidak menghakimi.
- Mudah dipahami.
- Tidak terlalu banyak warna.
- Mengutamakan keterbacaan teks Arab.

## Rekomendasi Visual

- Warna utama hijau gelap atau biru kehijauan.
- Warna status selesai menggunakan warna yang lembut.
- Hindari penggunaan warna merah untuk ibadah yang belum dilakukan kecuali benar-benar diperlukan.
- Gunakan kartu timeline sederhana.
- Gunakan ikon yang mudah dipahami.
- Hindari animasi berlebihan.

## Bahasa Antarmuka

Gunakan bahasa netral seperti:

- `Belum dicatat`
- `Sudah dikerjakan`
- `Terlewat`
- `Dicatat sebagai qadha`
- `Tidak wajib karena uzur syar'i`

Hindari bahasa seperti:

- `Anda gagal`
- `Iman Anda menurun`
- `Ibadah Anda buruk`
- `Skor Anda rendah`

---

## 15. Analitik Produk

Analitik hanya digunakan untuk meningkatkan aplikasi dan tidak boleh menyimpan isi ibadah pribadi secara rinci.

## Event yang Boleh Dicatat

- Login berhasil.
- Onboarding selesai.
- Halaman dibuka.
- Notifikasi diaktifkan.
- Sinkronisasi berhasil atau gagal.
- Error aplikasi.
- Fitur yang digunakan secara agregat.

## Event yang Tidak Boleh Dicatat untuk Analitik Umum

- Isi catatan pribadi.
- Detail lokasi shalat.
- Detail status ibadah per pengguna untuk iklan.
- Isi doa atau kebiasaan ibadah yang dapat mengidentifikasi pengguna.

---

## 16. Indikator Keberhasilan MVP

- Pengguna berhasil menyelesaikan onboarding.
- Pengguna dapat mencatat shalat tanpa error.
- Notifikasi bekerja secara konsisten.
- Data tetap tersedia setelah logout dan login kembali.
- Data dapat dipulihkan di perangkat baru.
- Pengguna dapat melihat riwayat.
- Pengguna dapat menggunakan aplikasi tanpa internet.
- Tidak ada kebocoran data antar akun.
- Tingkat crash aplikasi rendah.

## Metrik Awal

- Persentase pengguna yang menyelesaikan onboarding.
- Persentase pengguna yang mengaktifkan notifikasi.
- Pengguna aktif harian.
- Pengguna aktif mingguan.
- Retensi hari ke-7 dan hari ke-30.
- Keberhasilan sinkronisasi.
- Keberhasilan pengiriman notifikasi lokal.
- Jumlah crash per sesi.

---

## 17. Fitur di Luar MVP

Fitur berikut tidak termasuk versi pertama:

- Aplikasi iOS.
- Audio doa dan dzikir.
- Wear OS.
- Widget homescreen.
- Integrasi smartwatch.
- Fitur keluarga.
- Leaderboard.
- Komunitas.
- Chat.
- Berbagi hasil ibadah.
- Target tilawah.
- Target sedekah.
- Target puasa sunnah.
- Konsultasi ustaz.
- AI pembimbing ibadah.
- Panel admin lengkap.
- Multi-bahasa.
- Kunci aplikasi dengan biometrik.
- Ekspor laporan PDF.
- Backup manual ke Google Drive.

---

## 18. Tahapan Pengembangan

# Fase 1 — Fondasi

- Setup project Flutter.
- Firebase Authentication.
- Database cloud.
- Penyimpanan lokal.
- Struktur navigasi.
- Onboarding.

# Fase 2 — Jadwal dan Timeline

- Lokasi.
- Perhitungan jadwal shalat.
- Timeline Hari Ini.
- Pengaturan koreksi waktu.
- Sepertiga malam.

# Fase 3 — Checklist Ibadah

- Shalat fardhu.
- Tahajud.
- Witir.
- Dhuha.
- Rawatib.
- Kondisi khusus.

# Fase 4 — Bacaan

- Doa bangun tidur.
- Dzikir setelah shalat.
- Dzikir pagi.
- Dzikir petang.
- Dzikir sebelum tidur.
- Doa sebelum tidur.

# Fase 5 — Notifikasi

- Local notification.
- Azan.
- Alarm presisi.
- Penjadwalan ulang.
- Penanganan restart perangkat.

# Fase 6 — Riwayat, Statistik, dan Sinkronisasi

- Riwayat harian.
- Ringkasan mingguan.
- Ringkasan bulanan.
- Dashboard statistik.
- Line chart konsistensi.
- Bar chart shalat dan ibadah sunnah.
- Pie atau donut chart komposisi.
- Kalender konsistensi.
- Sinkronisasi.
- Pemulihan data perangkat baru.

# Fase 7 — QA dan Rilis

- Pengujian fungsional.
- Pengujian offline.
- Pengujian notifikasi.
- Pengujian keamanan.
- Pengujian perangkat nyata.
- Review konten agama.
- Closed testing.
- Rilis Google Play.

---

## 19. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Notifikasi azan terlambat | Tinggi | Gunakan alarm lokal, uji mode hemat baterai, berikan panduan izin |
| Jadwal shalat tidak sesuai | Tinggi | Sediakan metode perhitungan dan koreksi manual |
| Konten doa tidak akurat | Tinggi | Review oleh ahli agama dan tampilkan referensi |
| Data ibadah bocor | Tinggi | Aturan database ketat, enkripsi, pengujian keamanan |
| Sinkronisasi gagal | Sedang | Simpan lokal terlebih dahulu dan retry otomatis |
| Pengguna salah memahami status ibadah | Sedang | Gunakan bahasa netral dan penjelasan singkat |
| Scope terlalu besar | Tinggi | Fokus pada MVP dan tunda fitur tambahan |
| Azan dibatasi sistem Android | Tinggi | Deteksi izin, panduan baterai, fallback ke notifikasi |
| Pengguna mengganti zona waktu | Sedang | Simpan timezone per catatan dan jadwalkan ulang alarm |

---

## 20. Acceptance Criteria MVP Keseluruhan

MVP dinyatakan siap diuji apabila:

1. Pengguna dapat registrasi dan login.
2. Pengguna dapat menyelesaikan onboarding.
3. Jadwal shalat tampil berdasarkan lokasi.
4. Timeline harian tampil berurutan.
5. Pengguna dapat mencatat lima shalat fardhu.
6. Pengguna dapat mencatat Tahajud, Witir, dan Dhuha.
7. Pengguna dapat mencatat rawatib.
8. Pengguna dapat membaca doa dan dzikir dalam Arab, Latin, dan arti.
9. Pengguna dapat mengatur azan atau notifikasi.
10. Pengingat tetap berfungsi setelah restart perangkat.
11. Pengguna dapat melihat riwayat harian dan bulanan.
12. Pengguna dapat melihat dashboard statistik dan chart berdasarkan periode.
13. Data tetap dapat dicatat tanpa internet.
14. Data tersinkron ketika internet tersedia.
15. Data dapat dipulihkan setelah login pada perangkat baru.
16. Data satu pengguna tidak dapat dilihat pengguna lain.
17. Pengguna dapat menghapus akun dan seluruh datanya.
18. Aplikasi tidak crash pada alur utama.
19. Konten agama telah ditinjau sebelum rilis publik.

---

## 21. Keputusan Produk yang Sudah Disepakati

- Aplikasi digunakan untuk pribadi.
- Pengguna wajib login.
- Data perlu disinkronkan ke cloud.
- Konten doa dan dzikir menggunakan Arab, Latin, dan arti.
- Pengingat dapat berupa suara azan atau notifikasi biasa.
- Tidak ada target sedekah, tilawah, puasa sunnah, istighfar, atau shalawat pada MVP.
- Platform pertama adalah Android.
- Teknologi yang direkomendasikan adalah Flutter agar dapat dikembangkan ke iOS pada fase berikutnya.
- Tidak ada leaderboard atau fitur sosial.
- Tidak ada skor keimanan.

---

## 22. Pertanyaan Terbuka

Pertanyaan berikut perlu diputuskan sebelum desain final dan pengembangan:

1. Apa nama resmi aplikasi?
2. Apakah login Google wajib tersedia pada versi pertama?
3. Apakah pengguna perempuan wajib memilih jenis kelamin saat onboarding?
4. Apakah fitur haid/nifas masuk MVP atau fase setelah MVP?
5. Metode perhitungan jadwal shalat apa yang menjadi default?
6. Mazhab Ashar apa yang menjadi default?
7. Apakah seluruh suara azan disediakan aplikasi atau pengguna dapat memilih file sendiri?
8. Apakah pengguna dapat mengubah checklist tanggal sebelumnya tanpa batas?
9. Berapa lama data lokal disimpan setelah logout?
10. Apakah catatan pribadi perlu dienkripsi tambahan di perangkat?
11. Siapa yang akan meninjau dan menyetujui konten doa dan dzikir?
12. Apakah fitur Jumat masuk MVP?
13. Apakah aplikasi akan gratis sepenuhnya?
14. Apakah aplikasi akan menampilkan iklan?
15. Apakah aplikasi membutuhkan kebijakan privasi dan syarat penggunaan sebelum closed testing?

---

## 23. Rekomendasi Keputusan Awal

Untuk menjaga MVP tetap realistis:

- Gunakan nama sementara `IbadahKu`.
- Sediakan login Google dan email.
- Masukkan mode haid/nifas serta musafir ke MVP.
- Gunakan jadwal lokal dengan pilihan metode perhitungan.
- Batasi edit riwayat maksimal 30 hari ke belakang, tetapi dapat diubah kemudian.
- Jangan gunakan iklan pada versi awal.
- Jangan memasukkan audio doa.
- Masukkan fitur Jumat jika pengembangan inti sudah stabil.
- Tinjau seluruh konten agama sebelum closed testing.
- Buat kebijakan privasi sebelum aplikasi diuji melalui Google Play.

---

## 24. Definition of Done

Sebuah fitur dianggap selesai jika:

- Sesuai desain.
- Memenuhi acceptance criteria.
- Berfungsi dalam kondisi online dan offline jika relevan.
- Data tersimpan dengan benar.
- Tidak menyebabkan crash.
- Memiliki validasi input.
- Sudah diuji pada perangkat Android nyata.
- Sudah melalui code review.
- Memiliki penanganan error.
- Teks Bahasa Indonesia telah diperiksa.
- Konten agama telah ditinjau jika fitur memuat bacaan atau aturan ibadah.
