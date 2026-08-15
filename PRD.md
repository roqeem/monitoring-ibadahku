# Product Requirements Document (PRD)

## Monitoring IbadahKu

**Nama produk:** Monitoring IbadahKu  
**Jenis produk:** Aplikasi pendamping untuk IbadahKu  
**Platform MVP:** Android  
**Teknologi yang direkomendasikan:** Flutter + Firebase  
**Versi dokumen:** 1.0  
**Status:** Draft untuk ditinjau  
**Bahasa aplikasi:** Bahasa Indonesia  

---

## 1. Ringkasan Produk

Monitoring IbadahKu adalah aplikasi Android untuk orang tua atau wali yang ingin memantau kegiatan ibadah anak yang dicatat melalui aplikasi IbadahKu.

Aplikasi ini memungkinkan wali melihat seluruh data ibadah yang dibagikan anak, termasuk status aktivitas, waktu, tempat, cara pelaksanaan, riwayat, statistik, dan catatan pribadi. Wali juga dapat mengirim pengingat standar kepada anak untuk aktivitas tertentu, tetapi tidak dapat membuat, mengubah, atau menghapus catatan ibadah anak.

Akses hanya diberikan melalui undangan yang disetujui secara eksplisit oleh anak. Anak dapat menolak atau mencabut akses kapan saja. Produk harus menggunakan bahasa yang netral, tidak menghakimi, dan tidak menyamakan pencatatan aplikasi dengan kualitas keimanan seseorang.

---

## 2. Latar Belakang

Aplikasi IbadahKu membantu pengguna mencatat kegiatan ibadah pribadi. Dalam konteks keluarga, orang tua atau wali terkadang ingin mendampingi anak membangun kebiasaan ibadah yang konsisten tanpa mengambil alih pencatatan anak.

Kebutuhan utama yang ingin diselesaikan:

- Orang tua sulit mengetahui kegiatan ibadah yang telah dicatat anak.
- Pendampingan sering dilakukan melalui pertanyaan berulang yang dapat terasa menghakimi.
- Belum tersedia ringkasan terstruktur untuk beberapa anak dalam satu keluarga.
- Pengingat dari orang tua belum terhubung langsung dengan aktivitas di IbadahKu.
- Data ibadah dan catatan pribadi merupakan data sensitif sehingga akses keluarga memerlukan persetujuan serta kontrol privasi yang jelas.

Monitoring IbadahKu dibuat sebagai sarana pendampingan keluarga, bukan alat pengawasan mutlak atau penilaian keimanan.

---

## 3. Tujuan Produk

### 3.1 Tujuan Utama

- Membantu orang tua atau wali mendampingi kegiatan ibadah anak.
- Menampilkan data yang dicatat anak secara terstruktur dan mendekati real-time.
- Mendukung satu wali memantau beberapa anak.
- Mendukung satu anak terhubung dengan beberapa wali.
- Memungkinkan wali mengirim pengingat standar yang netral.
- Menjamin bahwa akses hanya aktif setelah persetujuan anak.
- Memungkinkan anak mencabut akses kapan saja.
- Menjaga keamanan dan kerahasiaan data ibadah keluarga.

### 3.2 Tujuan yang Tidak Termasuk

Aplikasi tidak bertujuan untuk:

- Menilai keimanan atau kualitas agama anak.
- Membandingkan anak dengan saudara atau pengguna lain.
- Menampilkan skor religius, leaderboard, atau peringkat.
- Memberikan hukuman atau konsekuensi otomatis.
- Mengizinkan wali mengubah catatan ibadah anak.
- Menyediakan chat atau pesan bebas pada MVP.
- Menggantikan komunikasi keluarga, bimbingan orang tua, guru agama, atau ulama.
- Memastikan bahwa aktivitas yang belum dicatat benar-benar belum dilakukan.

---

## 4. Prinsip Produk

1. **Persetujuan eksplisit** — akses tidak pernah aktif tanpa tindakan persetujuan anak.
2. **Kendali tetap pada pemilik data** — anak dapat menolak atau mencabut akses.
3. **Akses baca saja** — wali tidak dapat mengubah data anak.
4. **Bahasa netral** — `Belum tercatat` tidak boleh ditampilkan sebagai kegagalan.
5. **Tidak ada kompetisi** — tidak ada perbandingan antar-anak.
6. **Transparansi** — anak mengetahui data apa yang dilihat dan pengingat apa yang dikirim.
7. **Minimasi penyalahgunaan** — pengingat dibatasi dan hanya menggunakan pesan standar.
8. **Keamanan sejak desain awal** — relasi keluarga diverifikasi pada setiap akses.

---

## 5. Target Pengguna

### 5.1 Pengguna Utama

Orang tua atau wali Muslim yang:

- Memiliki satu atau beberapa anak pengguna IbadahKu.
- Ingin mendampingi konsistensi ibadah anak.
- Membutuhkan ringkasan harian dan riwayat yang mudah dipahami.
- Menggunakan perangkat Android.
- Memiliki akun Google atau email.

### 5.2 Pengguna Pendukung

Anak pengguna IbadahKu yang:

- Menerima, menolak, dan mengelola akses wali.
- Membagikan seluruh detail data ibadah setelah memberikan persetujuan.
- Menerima pengingat standar melalui aplikasi IbadahKu.

### 5.3 Definisi Wali

Pada MVP, istilah wali berarti pengguna Monitoring IbadahKu yang memperoleh persetujuan akses dari pengguna IbadahKu. Sistem tidak memverifikasi hubungan keluarga secara hukum. Hal ini harus dijelaskan dalam syarat penggunaan.

---

## 6. Platform dan Arsitektur

### 6.1 Platform MVP

- Android 9 atau lebih baru.
- Aplikasi dibangun dengan Flutter.
- Bahasa awal Bahasa Indonesia.

### 6.2 Arsitektur yang Dipilih

Monitoring IbadahKu merupakan aplikasi terpisah yang menggunakan backend Firebase bersama dengan IbadahKu.

Komponen:

- **IbadahKu:** pencatatan ibadah dan pengelolaan persetujuan oleh anak.
- **Monitoring IbadahKu:** pemantauan baca-saja dan pengiriman pengingat oleh wali.
- **Firebase Authentication:** autentikasi akun.
- **Cloud Firestore:** data ibadah, profil, relasi keluarga, undangan, dan audit.
- **Cloud Functions:** operasi sensitif dan validasi server-side.
- **Firebase Cloud Messaging:** push notification.
- **Penyimpanan lokal terenkripsi bila tersedia:** cache data terakhir.

### 6.3 Batas Akses Aplikasi

- Monitoring IbadahKu hanya dapat membaca data anak yang memiliki relasi aktif dengan wali.
- Perubahan data ibadah hanya dapat dilakukan oleh pemilik data melalui IbadahKu.
- Pembuatan undangan, penerimaan, pencabutan, dan pengiriman pengingat diproses melalui Cloud Functions.
- Aplikasi klien tidak boleh menentukan sendiri bahwa sebuah relasi valid.

---

## 7. Ruang Lingkup MVP

MVP mencakup:

1. Registrasi dan login wali.
2. Onboarding dan profil wali.
3. Pembuatan kode atau tautan undangan.
4. Persetujuan undangan melalui IbadahKu.
5. Penolakan, kedaluwarsa, pembatalan, dan pencabutan akses.
6. Dukungan banyak wali dan banyak anak.
7. Dashboard ringkasan semua anak.
8. Detail aktivitas ibadah anak per hari.
9. Riwayat harian, mingguan, dan bulanan.
10. Statistik ibadah anak.
11. Akses ke detail tempat, waktu, pelaksanaan, dan catatan pribadi.
12. Pengiriman pengingat standar.
13. Riwayat pengingat.
14. Notifikasi perubahan status undangan atau relasi.
15. Cache data terakhir untuk tampilan offline.
16. Pengaturan akun, notifikasi, privasi, dan relasi keluarga.
17. Audit aktivitas sensitif.
18. Penghapusan akun wali.

---

## 8. Struktur Navigasi

Navigasi utama terdiri dari empat menu:

1. **Beranda**
2. **Anak**
3. **Notifikasi**
4. **Pengaturan**

---

## 9. Kebutuhan Fungsional

### 9.1 Registrasi dan Login

#### Metode

- Login dengan Google.
- Registrasi dengan email dan password.
- Login dengan email dan password.
- Lupa password.
- Logout.
- Hapus akun.

#### Aturan

- Satu akun dapat menjadi wali bagi beberapa anak.
- Akun Monitoring IbadahKu tidak otomatis memperoleh akses ke akun IbadahKu dengan email yang sama.
- Semua akses data tetap bergantung pada relasi keluarga aktif.

#### Acceptance Criteria

- Wali dapat membuat akun dan login.
- Wali dapat meminta reset password.
- Sesi disimpan secara aman.
- Wali dapat logout.
- Wali dapat menghapus akun sesuai alur penghapusan data.

---

### 9.2 Onboarding Wali

#### Data yang Dikumpulkan

- Nama panggilan.
- Foto profil opsional.
- Hubungan umum dengan anak: ayah, ibu, wali, atau lainnya.
- Preferensi notifikasi.
- Persetujuan kebijakan privasi dan syarat penggunaan.

#### Acceptance Criteria

- Wali dapat menyelesaikan onboarding.
- Field opsional dapat dilewati.
- Data dapat diubah melalui Pengaturan.
- Aplikasi menjelaskan bahwa hubungan keluarga tidak diverifikasi secara hukum pada MVP.

---

### 9.3 Undangan dan Persetujuan Anak

#### Pembuatan Undangan

Wali dapat membuat:

- Kode undangan.
- Tautan undangan/deep link.

Undangan harus:

- Terikat pada ID wali pembuat.
- Memiliki token acak yang tidak mudah ditebak.
- Sekali pakai.
- Berlaku selama 24 jam.
- Dapat dibatalkan sebelum diterima.
- Tidak menampilkan data akun anak sebelum diterima.

#### Tampilan Persetujuan di IbadahKu

Sebelum menerima, anak harus melihat:

- Nama dan foto wali jika tersedia.
- Jenis hubungan yang dinyatakan wali.
- Penjelasan bahwa hubungan tidak diverifikasi secara hukum.
- Daftar data yang akan dapat dibaca wali.
- Penjelasan bahwa data mencakup waktu, tempat, status, statistik, dan catatan pribadi.
- Penjelasan bahwa wali dapat mengirim pengingat standar.
- Penjelasan bahwa wali tidak dapat mengubah data.
- Tombol `Setujui` dan `Tolak` dengan penekanan visual yang setara.
- Informasi bahwa akses dapat dicabut kapan saja.

#### Status Undangan

- `pending`
- `accepted`
- `rejected`
- `cancelled`
- `expired`
- `revoked`

#### Acceptance Criteria

- Data tidak dapat dibaca saat status masih `pending`.
- Anak dapat menerima atau menolak undangan.
- Undangan tidak dapat digunakan setelah diterima, dibatalkan, ditolak, atau kedaluwarsa.
- Relasi aktif dibuat hanya melalui Cloud Function setelah persetujuan valid.
- Wali menerima notifikasi perubahan status tanpa memperoleh data anak ketika undangan ditolak.

---

### 9.4 Pengelolaan Relasi Keluarga

#### Aturan

- Satu wali dapat memantau beberapa anak.
- Satu anak dapat dipantau beberapa wali.
- Setiap relasi memiliki persetujuan dan status sendiri.
- Anak dapat mencabut akses wali kapan saja dari IbadahKu.
- Wali dapat berhenti memantau anak.
- Pencabutan akses berlaku segera pada backend.
- Cache data anak harus dihapus dari perangkat wali setelah aplikasi menerima status pencabutan atau pada pemeriksaan sesi berikutnya.

#### Acceptance Criteria

- Daftar anak hanya menampilkan relasi aktif.
- Pencabutan satu wali tidak memengaruhi wali lain.
- Penghapusan satu relasi tidak menghapus catatan ibadah anak.
- Wali yang aksesnya dicabut tidak dapat membuka data melalui deep link, cache aplikasi, atau permintaan langsung.

---

### 9.5 Beranda

#### Konten

- Salam dan nama wali.
- Daftar anak terhubung.
- Ringkasan pencatatan hari ini per anak.
- Jumlah aktivitas `Tercatat`, `Belum tercatat`, `Terlewat`, `Qadha`, dan `Uzur syar'i`.
- Waktu pembaruan data terakhir.
- Undangan yang masih menunggu.
- Status offline atau gangguan sinkronisasi.

#### Aturan

- Setiap kartu harus menampilkan identitas anak dengan jelas.
- Tidak ada total skor gabungan keluarga.
- Tidak ada urutan anak berdasarkan jumlah ibadah.
- `Belum tercatat` tidak boleh diubah menjadi `Belum dilakukan`.

#### Acceptance Criteria

- Wali dapat membuka detail anak dari kartu.
- Ringkasan diperbarui ketika catatan anak berubah.
- Data setiap anak tidak tercampur.
- Empty state tersedia ketika belum ada anak terhubung.

---

### 9.6 Detail Anak

#### Informasi Profil

- Nama panggilan.
- Foto profil jika dibagikan.
- Status hubungan.
- Waktu pembaruan terakhir.

#### Tab Detail

1. **Hari Ini**
2. **Riwayat**
3. **Statistik**
4. **Pengingat**

#### Data yang Dapat Dilihat

- Shalat fardhu dan Jumat.
- Tahajud, Witir, Dhuha, dan rawatib.
- Doa dan dzikir.
- Kondisi khusus seperti haid/nifas, musafir, sakit, jamak, dan qashar.
- Status pelaksanaan.
- Jumlah rakaat.
- Tempat.
- Berjamaah atau sendiri.
- Kategori waktu.
- Waktu pencatatan dan penyelesaian.
- Catatan pribadi.

#### Aturan

- Semua tampilan bersifat baca-saja.
- Data sensitif seperti catatan pribadi diberi label `Data pribadi yang dibagikan`.
- Aplikasi tidak menyediakan tombol edit atau hapus data anak.
- Perubahan yang dibuat anak harus muncul mendekati real-time ketika online.

#### Acceptance Criteria

- Wali dapat memilih tanggal.
- Wali dapat membuka detail aktivitas.
- Seluruh field yang dibagikan tampil sesuai sumber data IbadahKu.
- Wali tidak dapat memodifikasi data melalui antarmuka maupun request backend.

---

### 9.7 Riwayat Ibadah Anak

#### Tampilan

- Harian.
- Ringkasan tujuh hari.
- Kalender dan ringkasan bulanan.

#### Filter

- Semua aktivitas.
- Shalat fardhu.
- Shalat sunnah.
- Dzikir dan doa.
- Status aktivitas.
- Tempat.
- Berjamaah atau sendiri.
- Kategori waktu.

#### Aturan

- Riwayat hanya tersedia selama relasi aktif.
- Zona waktu mengikuti zona waktu catatan anak.
- Kondisi haid/nifas dan uzur tidak dihitung sebagai aktivitas terlewat.
- Wali tidak dapat mengoreksi data masa lalu.

#### Acceptance Criteria

- Filter menghasilkan data yang konsisten.
- Kalender dapat membuka detail tanggal.
- Hari tanpa data diberi label `Belum ada catatan`.
- Data cache terakhir dapat dilihat saat offline dengan indikator yang jelas.

---

### 9.8 Statistik Anak

#### Periode

- 7 hari terakhir.
- 30 hari terakhir.
- Bulan berjalan.
- Bulan sebelumnya.
- Rentang tanggal khusus.

#### Komponen

- Ringkasan angka pencatatan.
- Line chart aktivitas harian.
- Bar chart shalat fardhu.
- Bar chart ibadah sunnah.
- Bar chart dzikir dan doa.
- Donut chart tempat shalat.
- Donut chart berjamaah atau sendiri.
- Donut chart kategori waktu.
- Kalender konsistensi.

#### Aturan

- Statistik ditampilkan per anak, bukan sebagai perbandingan keluarga.
- Tidak ada skor keimanan atau label baik/buruk.
- Hari tanpa catatan tetap ditampilkan sebagai `Tidak ada data`, bukan bukti bahwa ibadah ditinggalkan.
- Perubahan data anak memperbarui statistik.
- Kondisi khusus dihitung sesuai aturan IbadahKu.

#### Acceptance Criteria

- Wali dapat memilih periode dan filter.
- Grafik menampilkan data anak yang sedang dipilih.
- Jumlah pada grafik konsisten dengan detail riwayat.
- Tidak ada fitur untuk membandingkan dua anak.

---

### 9.9 Pengingat dari Wali

#### Cara Mengirim

1. Wali membuka detail anak.
2. Wali memilih aktivitas yang mendukung pengingat.
3. Sistem menampilkan pesan standar.
4. Wali menekan `Kirim pengingat`.
5. Cloud Function memvalidasi relasi dan rate limit.
6. Anak menerima push notification.
7. Notifikasi membuka aktivitas terkait di IbadahKu.

#### Aktivitas yang Didukung

- Tahajud.
- Witir.
- Shalat fardhu.
- Dhuha.
- Rawatib.
- Dzikir pagi.
- Dzikir petang.
- Dzikir setelah shalat.
- Doa dan dzikir sebelum tidur.

#### Pesan Standar

Contoh:

- `Pengingat lembut untuk mencatat Shalat Subuh di IbadahKu.`
- `Saat sempat, silakan periksa aktivitas Dzikir Pagi di IbadahKu.`

Pesan harus:

- Netral dan tidak menghakimi.
- Tidak menyatakan bahwa anak pasti belum beribadah.
- Tidak dapat diedit wali pada MVP.
- Menyebutkan identitas wali pengirim.

#### Batas Pengiriman

- Hanya untuk relasi aktif.
- Maksimal satu pengingat dari wali yang sama untuk aktivitas, anak, dan tanggal yang sama dalam 6 jam.
- Maksimal 10 pengingat per wali dalam 24 jam untuk seluruh anak.
- Tidak dapat dikirim untuk aktivitas berstatus `Tercatat`, `Qadha`, `Terlewat`, atau `Uzur syar'i`, kecuali status berubah kembali menjadi `Belum tercatat`.
- Anak dapat membisukan pengingat dari wali tertentu tanpa mencabut akses baca.

#### Acceptance Criteria

- Pengingat yang valid diterima anak ketika perangkat dan izin mendukung.
- Deep link membuka aktivitas yang benar.
- Permintaan yang melampaui batas ditolak dengan pesan jelas.
- Kegagalan push notification tidak mengubah data ibadah.
- Riwayat pengingat dapat dilihat wali dan anak.

---

### 9.10 Notifikasi untuk Wali

#### Jenis Notifikasi

- Undangan diterima.
- Undangan ditolak.
- Undangan kedaluwarsa.
- Akses dicabut anak.
- Pengingat gagal dikirim.
- Informasi keamanan akun.

#### Di Luar MVP

- Notifikasi otomatis setiap kali anak mencatat ibadah.
- Notifikasi otomatis ketika aktivitas belum tercatat.

#### Acceptance Criteria

- Wali dapat mengaktifkan atau menonaktifkan kategori notifikasi.
- Notifikasi tidak membocorkan detail ibadah pada lock screen secara default.
- Menekan notifikasi membuka halaman yang relevan jika akses masih tersedia.

---

### 9.11 Pengaturan

#### Akun

- Nama panggilan.
- Foto profil.
- Email.
- Logout.
- Hapus akun.

#### Notifikasi

- Status izin notifikasi.
- Preferensi per kategori.
- Privasi tampilan lock screen.

#### Keluarga

- Daftar anak terhubung.
- Daftar undangan aktif.
- Batalkan undangan.
- Berhenti memantau anak.

#### Data dan Privasi

- Penjelasan data yang dapat dibaca.
- Status sinkronisasi terakhir.
- Hapus cache lokal.
- Kebijakan privasi.
- Syarat penggunaan.
- Hapus akun.

---

### 9.12 Penghapusan Akun Wali

#### Aturan

- Wali harus melakukan autentikasi ulang.
- Seluruh relasi wali dinonaktifkan.
- Undangan yang masih aktif dibatalkan.
- Cache lokal dihapus.
- Catatan ibadah anak tidak dihapus.
- Audit keamanan minimum dapat dipertahankan sesuai kebijakan retensi dan hukum yang berlaku, tanpa menyimpan isi catatan pribadi lebih lama dari yang diperlukan.

#### Acceptance Criteria

- Akun tidak dapat digunakan setelah penghapusan selesai.
- Anak tidak lagi melihat wali sebagai relasi aktif.
- Tidak ada data ibadah anak yang ikut terhapus.

---

## 10. Perubahan yang Dibutuhkan pada IbadahKu

Agar Monitoring IbadahKu dapat berfungsi, aplikasi pertama memerlukan fitur pendukung berikut:

1. Halaman `Akses Keluarga`.
2. Pemindai/input kode undangan dan dukungan deep link.
3. Layar persetujuan dengan rincian data yang dibagikan.
4. Aksi menerima dan menolak undangan.
5. Daftar wali yang memiliki akses.
6. Aksi mencabut akses wali.
7. Opsi membisukan pengingat per wali.
8. Riwayat pengingat yang diterima.
9. Deep link dari pengingat ke aktivitas terkait.
10. Notifikasi ketika hubungan atau izin berubah.

Fitur keluarga yang sebelumnya berada di luar MVP IbadahKu menjadi dependensi wajib untuk peluncuran Monitoring IbadahKu.

---

## 11. User Flow Utama

### 11.1 Menghubungkan Wali dan Anak

1. Wali login ke Monitoring IbadahKu.
2. Wali memilih `Tambah anak`.
3. Sistem membuat kode dan tautan yang berlaku 24 jam.
4. Wali membagikan undangan kepada anak.
5. Anak membuka undangan di IbadahKu.
6. Anak membaca identitas wali dan cakupan data.
7. Anak memilih `Setujui`.
8. Backend membuat relasi aktif.
9. Wali menerima notifikasi.
10. Data anak tampil di aplikasi wali.

### 11.2 Menolak Undangan

1. Anak membuka undangan.
2. Anak memilih `Tolak`.
3. Token dinonaktifkan.
4. Wali menerima status bahwa undangan ditolak.
5. Wali tidak memperoleh data akun atau ibadah anak.

### 11.3 Memantau Aktivitas Anak

1. Wali membuka Beranda.
2. Wali memilih kartu anak.
3. Wali memilih tanggal.
4. Sistem menampilkan aktivitas dan status pencatatannya.
5. Wali membuka detail untuk melihat waktu, tempat, pelaksanaan, atau catatan.

### 11.4 Mengirim Pengingat

1. Wali membuka aktivitas berstatus `Belum tercatat`.
2. Wali menekan `Kirim pengingat`.
3. Sistem menampilkan pesan standar dan konfirmasi.
4. Backend memvalidasi relasi dan batas pengiriman.
5. Anak menerima notifikasi.
6. Anak membuka aktivitas melalui deep link.
7. Pengiriman dicatat dalam riwayat.

### 11.5 Mencabut Akses

1. Anak membuka `Akses Keluarga` di IbadahKu.
2. Anak memilih wali.
3. Anak menekan `Cabut akses` dan mengonfirmasi.
4. Backend menonaktifkan relasi.
5. Aplikasi wali menghapus anak dari daftar dan membersihkan cache terkait.
6. Wali menerima pemberitahuan bahwa akses telah berakhir.

---

## 12. Model Data Awal

### 12.1 Guardian Profile

- guardian_id
- display_name
- email
- photo_url
- declared_relationship
- created_at
- updated_at
- last_login_at

### 12.2 Family Invitation

- invitation_id
- token_hash
- guardian_id
- status
- expires_at
- created_at
- accepted_by_child_id
- accepted_at
- rejected_at
- cancelled_at

Token mentah tidak disimpan dalam log dan hanya hash token yang disimpan di database.

### 12.3 Family Relationship

- relationship_id
- guardian_id
- child_id
- invitation_id
- status
- consent_version
- consented_at
- revoked_by
- revoked_at
- created_at
- updated_at

### 12.4 Shared Data Permission

Untuk MVP, cakupan akses bersifat tetap dan mencakup seluruh detail data yang disepakati.

- relationship_id
- permission_scope: `full_worship_read`
- reminder_permission: `standard_reminder_send`
- reminder_muted_by_child
- effective_from
- effective_until
- updated_at

### 12.5 Reminder

- reminder_id
- guardian_id
- child_id
- relationship_id
- worship_date
- worship_type
- activity_id
- template_id
- delivery_status
- requested_at
- delivered_at
- failure_code

### 12.6 Notification Preference

- user_id
- invitation_updates_enabled
- relationship_updates_enabled
- reminder_failures_enabled
- lock_screen_detail_enabled
- updated_at

### 12.7 Audit Event

- audit_id
- actor_id
- actor_role
- action_type
- relationship_id
- target_user_id
- resource_type
- resource_id_hash
- result
- occurred_at
- device_or_session_id_hash

Audit log tidak boleh menyimpan isi catatan pribadi atau token undangan mentah.

### 12.8 Data Ibadah

Model data ibadah tetap mengikuti definisi pada PRD IbadahKu, termasuk:

- Daily Worship Record.
- Prayer Record.
- Sunnah Prayer Record.
- Dhikr and Dua Record.
- Special Condition.
- Statistik agregat.

Monitoring IbadahKu tidak membuat salinan permanen data transaksi baru di backend terpisah.

---

## 13. Aturan Keamanan Backend

- Setiap pembacaan data ibadah memerlukan autentikasi.
- `guardian_id` pada relasi harus sama dengan UID pengguna yang meminta data.
- `child_id` pada data harus sama dengan anak pada relasi.
- Status relasi harus `active` dan belum dicabut.
- Query lintas anak harus memvalidasi setiap relasi, bukan hanya parameter klien.
- Wali tidak memiliki izin write pada koleksi catatan ibadah anak.
- Undangan tidak memberikan akses sebelum diterima.
- Operasi undangan dan pengingat menggunakan Cloud Functions atau endpoint tepercaya.
- App Check diaktifkan untuk mengurangi akses dari klien tidak sah.
- Security Rules diuji dengan Firebase Emulator Suite.
- Perubahan izin harus mencabut sesi/cache akses sesegera mungkin.
- Respons error tidak boleh mengungkap apakah sebuah akun anak terdaftar.

---

## 14. Sinkronisasi dan Mode Offline

### 14.1 Kebutuhan

- Data online diperbarui mendekati real-time.
- Data terakhir dapat disimpan sebagai cache untuk dibaca ketika offline.
- Tampilan offline menunjukkan `Data terakhir diperbarui pada ...`.
- Wali tidak dapat mengirim pengingat saat offline.
- Aplikasi memeriksa ulang status relasi saat kembali online.
- Cache anak dihapus setelah pencabutan diketahui.
- Cache sensitif tidak boleh muncul setelah logout.

### 14.2 Konflik dan Sumber Kebenaran

- Backend adalah sumber kebenaran untuk relasi dan izin.
- IbadahKu milik anak adalah sumber perubahan data ibadah.
- Monitoring IbadahKu tidak melakukan resolusi konflik karena bersifat baca-saja.

---

## 15. Privasi dan Perlindungan Data

### 15.1 Klasifikasi Data

Data ibadah, kondisi khusus, lokasi pelaksanaan, dan catatan pribadi diperlakukan sebagai data sensitif.

### 15.2 Kebutuhan

- Persetujuan mencantumkan cakupan akses secara jelas.
- Anak dapat melihat daftar wali aktif.
- Anak dapat mencabut akses tanpa perlu persetujuan wali.
- Wali hanya melihat data selama relasi aktif.
- Data tidak dijual atau digunakan untuk iklan personal.
- Isi catatan pribadi tidak dikirim ke layanan analitik umum.
- Detail ibadah disembunyikan dari lock screen secara default.
- Cache lokal dilindungi menggunakan fasilitas keamanan perangkat.
- Screenshot tidak diblokir pada MVP, tetapi aplikasi memperingatkan bahwa data yang disimpan di luar aplikasi tidak dapat ditarik kembali setelah akses dicabut.
- Kebijakan privasi menjelaskan retensi, penghapusan, dan keterbatasan pencabutan akses.

### 15.3 Akun Anak dan Persetujuan

Karena usia minimum, persetujuan digital, dan perlindungan anak berbeda menurut wilayah distribusi, peluncuran publik harus mengikuti kebijakan Google Play dan hukum wilayah target. MVP tidak mengklaim melakukan verifikasi usia atau hubungan keluarga secara hukum.

---

## 16. Audit dan Pencegahan Penyalahgunaan

### 16.1 Event yang Diaudit

- Pembuatan dan pembatalan undangan.
- Penerimaan dan penolakan undangan.
- Pembuatan dan pencabutan relasi.
- Pengiriman dan kegagalan pengingat.
- Upaya akses yang ditolak.
- Penghapusan akun.

Pembacaan data sensitif dicatat secara agregat per sesi atau halaman untuk keamanan, tanpa menyimpan isi data yang dibaca.

### 16.2 Pencegahan Spam

- Rate limit pengingat diterapkan di server.
- Token undangan memiliki masa berlaku dan sekali pakai.
- Aktivitas mencurigakan dapat memicu pembatasan sementara.
- Anak dapat membisukan pengingat per wali.
- Anak dapat mencabut akses kapan saja.

---

## 17. Penanganan Error dan Empty State

### 17.1 Error Utama

- **Undangan kedaluwarsa:** minta wali membuat undangan baru.
- **Undangan sudah digunakan:** jangan membuka identitas atau data anak.
- **Akses dicabut:** tutup halaman, bersihkan cache, dan kembali ke daftar anak.
- **Tidak ada jaringan:** tampilkan cache terakhir dan nonaktifkan aksi online.
- **Pengingat dibatasi:** tampilkan waktu paling awal pengiriman berikutnya.
- **Notifikasi gagal:** catat kegagalan tanpa mengubah data ibadah.
- **Data tidak ditemukan:** tampilkan pesan netral tanpa menyimpulkan aktivitas tidak dilakukan.

### 17.2 Empty State

- `Belum ada anak yang terhubung.`
- `Belum ada catatan pada tanggal ini.`
- `Data belum cukup untuk menampilkan statistik.`
- `Tidak ada notifikasi baru.`

---

## 18. Kebutuhan Nonfungsional

### 18.1 Performa

- Beranda terbuka maksimal 3 detik pada perangkat Android menengah dengan cache tersedia.
- Perubahan online tampil maksimal 10 detik setelah backend menerima pembaruan dalam kondisi jaringan normal.
- Pergantian profil anak terasa responsif dan tidak mencampur data.

### 18.2 Keandalan

- Kegagalan jaringan tidak menyebabkan crash.
- Kegagalan notifikasi tidak memengaruhi data ibadah.
- Status akses diverifikasi ulang ketika aplikasi aktif kembali.
- Penghapusan cache tidak menghapus data sumber anak.

### 18.3 Aksesibilitas

- Mendukung ukuran teks sistem.
- Kontras memenuhi WCAG AA sejauh relevan untuk aplikasi mobile.
- Area sentuh minimal 44 × 44 logical pixels.
- Mendukung label pembaca layar.
- Grafik memiliki ringkasan teks alternatif.
- Status tidak dibedakan hanya berdasarkan warna.

### 18.4 Kompatibilitas

- Android 9 atau lebih baru.
- Mendukung berbagai ukuran layar ponsel.
- Mode tablet dan iOS berada di luar MVP.

### 18.5 Observabilitas

- Crash reporting tanpa isi data ibadah atau catatan pribadi.
- Monitoring kegagalan Cloud Functions.
- Monitoring latensi dan kegagalan notifikasi.
- Alert untuk lonjakan akses ditolak atau spam pengingat.

---

## 19. Desain dan Pengalaman Pengguna

### 19.1 Prinsip Visual

- Tenang dan sederhana.
- Tidak menghakimi.
- Identitas setiap anak selalu jelas.
- Tidak menggunakan pola desain kompetitif.
- Warna merah hanya untuk error sistem atau aksi destruktif, bukan aktivitas belum tercatat.
- Grafik menggunakan warna yang tetap terbaca bagi pengguna dengan gangguan persepsi warna.

### 19.2 Bahasa Antarmuka

Gunakan:

- `Tercatat`
- `Belum tercatat`
- `Dicatat sebagai qadha`
- `Uzur syar'i`
- `Data terakhir diperbarui ...`
- `Pengingat telah dikirim`

Hindari:

- `Anak Anda gagal`
- `Anak tidak taat`
- `Ibadah buruk`
- `Skor rendah`
- `Kalah dari saudara`
- `Belum beribadah` jika sistem hanya mengetahui bahwa data belum dicatat

---

## 20. Analitik Produk

### 20.1 Event yang Boleh Dicatat

- Registrasi dan login berhasil.
- Onboarding selesai.
- Undangan dibuat.
- Undangan diterima, ditolak, atau kedaluwarsa secara agregat.
- Halaman dibuka.
- Pengingat berhasil atau gagal secara agregat.
- Sinkronisasi berhasil atau gagal.
- Error dan crash.

### 20.2 Data yang Dilarang dalam Analitik Umum

- Isi catatan pribadi.
- Detail aktivitas ibadah anak.
- Nama aktivitas yang dikaitkan dengan identitas anak untuk pemasaran.
- Lokasi pelaksanaan ibadah.
- Kondisi haid/nifas atau kondisi kesehatan.
- Token undangan.

---

## 21. Indikator Keberhasilan MVP

### 21.1 Indikator Produk

- Wali berhasil membuat undangan.
- Anak memahami cakupan data dan dapat memberi keputusan.
- Relasi aktif hanya terbentuk setelah persetujuan.
- Wali dapat memantau beberapa anak tanpa data tercampur.
- Pengingat sampai dan membuka aktivitas yang benar.
- Pencabutan akses menghentikan pembacaan data.
- Tidak ada kebocoran data antar-keluarga.

### 21.2 Metrik Awal

- Persentase onboarding selesai.
- Persentase undangan yang memperoleh respons.
- Waktu median dari undangan dibuat sampai direspons.
- Jumlah relasi aktif per wali secara agregat.
- Keberhasilan pengiriman push notification.
- Jumlah pengingat yang ditolak rate limit.
- Keberhasilan pencabutan akses.
- Crash-free sessions.
- Jumlah insiden akses tidak sah yang terkonfirmasi, dengan target nol.

Metrik tidak boleh digunakan untuk menilai kualitas ibadah anak.

---

## 22. Strategi Pengujian

### 22.1 Unit Test

- Transisi status undangan.
- Kedaluwarsa 24 jam.
- Relasi banyak wali dan banyak anak.
- Rate limit pengingat.
- Perhitungan statistik dan kondisi khusus.

### 22.2 Integration Test

- Undangan dari wali sampai persetujuan anak.
- Penolakan dan pembatalan undangan.
- Pencabutan akses oleh anak.
- Berhenti memantau oleh wali.
- Pengiriman pengingat dan deep link.
- Penghapusan akun wali.

### 22.3 Security Test

- Wali membaca data anak tanpa relasi.
- Wali mencoba mengubah catatan anak.
- Penggunaan token kedaluwarsa atau token kedua kali.
- Manipulasi `child_id` pada request.
- Akses cache setelah logout atau pencabutan.
- Pengujian Firestore Security Rules melalui emulator.

### 22.4 UI dan Perangkat

- Beberapa anak dengan nama atau foto mirip.
- Jaringan lambat dan offline.
- Izin notifikasi dinonaktifkan.
- Android 9 sampai versi Android target terbaru.
- Ukuran font besar dan pembaca layar.
- Deep link ketika aplikasi tertutup, terbuka, atau belum terpasang.

---

## 23. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Data anak diakses wali yang tidak sah | Tinggi | Persetujuan eksplisit, token acak, Security Rules, Cloud Functions, audit |
| Catatan pribadi terlihat tanpa pemahaman anak | Tinggi | Rincian cakupan data sebelum persetujuan dan kemampuan mencabut akses |
| Pengingat digunakan untuk menekan atau melakukan spam | Tinggi | Pesan standar, rate limit, mute per wali, riwayat pengingat |
| Wali salah menganggap belum tercatat sebagai belum dilakukan | Tinggi | Bahasa netral dan penjelasan konsisten pada dashboard |
| Data cache tetap tersedia setelah akses dicabut | Tinggi | Pemeriksaan relasi saat resume, purge cache, enkripsi lokal |
| Data beberapa anak tercampur | Tinggi | Pemisahan query/cache per child ID dan pengujian lintas akun |
| Token undangan bocor | Tinggi | Kedaluwarsa 24 jam, sekali pakai, hash token, pembatalan |
| Push notification terlambat atau gagal | Sedang | Status pengiriman, retry terbatas, penjelasan bahwa push tidak dijamin |
| Implikasi hukum perlindungan anak | Tinggi | Review hukum dan kebijakan store sebelum rilis publik |
| Scope integrasi aplikasi pertama membesar | Tinggi | Jadikan fitur akses keluarga sebagai dependensi rilis terpisah |

---

## 24. Fitur di Luar MVP

- iOS.
- Web dashboard.
- Chat keluarga.
- Pesan pengingat bebas.
- Target ibadah dari orang tua.
- Persetujuan data per field.
- Notifikasi otomatis untuk setiap catatan baru.
- Pengingat otomatis berdasarkan aktivitas belum tercatat.
- Perbandingan antar-anak.
- Ekspor PDF atau berbagi laporan.
- Verifikasi dokumen hubungan keluarga.
- Akun anak yang dibuat dan dikelola penuh oleh wali.
- Integrasi sekolah, pesantren, atau guru.
- AI pembimbing ibadah.

---

## 25. Tahapan Pengembangan

### Fase 1 — Fondasi Bersama

- Finalisasi model relasi keluarga.
- Firebase Authentication.
- Security Rules dan App Check.
- Cloud Functions untuk undangan dan relasi.
- Audit event dasar.

### Fase 2 — Perubahan IbadahKu

- Halaman Akses Keluarga.
- Penerimaan dan penolakan undangan.
- Daftar wali dan pencabutan akses.
- Preferensi pengingat per wali.
- Deep link aktivitas.

### Fase 3 — Fondasi Monitoring IbadahKu

- Setup Flutter Android.
- Login dan onboarding wali.
- Navigasi utama.
- Pembuatan dan status undangan.
- Daftar anak.

### Fase 4 — Monitoring

- Beranda multi-anak.
- Detail harian.
- Riwayat.
- Statistik.
- Cache offline baca-saja.

### Fase 5 — Pengingat dan Notifikasi

- Template pesan standar.
- Rate limit server-side.
- Firebase Cloud Messaging.
- Deep link.
- Riwayat pengingat.

### Fase 6 — Privasi dan Keamanan

- Pencabutan akses dan purge cache.
- Penghapusan akun.
- Audit keamanan.
- Uji Security Rules.
- Kebijakan privasi dan syarat penggunaan.

### Fase 7 — QA dan Rilis

- Pengujian lintas akun dan multi-anak.
- Pengujian perangkat nyata.
- Uji jaringan buruk dan offline.
- Review bahasa antarmuka.
- Review hukum serta kebijakan Google Play.
- Closed testing.
- Rilis bertahap.

---

## 26. Acceptance Criteria MVP Keseluruhan

MVP siap diuji apabila:

1. Wali dapat registrasi dan login.
2. Wali dapat membuat undangan yang aman dan kedaluwarsa dalam 24 jam.
3. Anak dapat menerima atau menolak undangan di IbadahKu.
4. Tidak ada data anak yang dapat dibaca sebelum persetujuan.
5. Satu wali dapat terhubung dengan beberapa anak.
6. Satu anak dapat terhubung dengan beberapa wali.
7. Wali dapat melihat seluruh detail ibadah yang dibagikan.
8. Wali tidak dapat membuat, mengubah, atau menghapus data anak.
9. Dashboard tidak membandingkan anak.
10. Riwayat dan statistik konsisten dengan IbadahKu.
11. Wali dapat mengirim pengingat standar dalam batas yang ditentukan.
12. Anak dapat membisukan pengingat per wali.
13. Anak dapat mencabut akses kapan saja.
14. Pencabutan akses menghentikan akses backend dan membersihkan cache aplikasi wali.
15. Wali dapat berhenti memantau tanpa menghapus data anak.
16. Data keluarga lain tidak dapat diakses.
17. Data cache terakhir dapat dilihat saat offline dengan penanda waktu.
18. Pengingat tidak dapat dikirim saat offline.
19. Penghapusan akun wali tidak menghapus catatan anak.
20. Tidak ada skor keimanan, leaderboard, atau bahasa menghakimi.
21. Security Rules dan alur utama lulus pengujian otomatis.
22. Aplikasi tidak crash pada alur utama.
23. Kebijakan privasi dan syarat penggunaan tersedia sebelum closed testing.

---

## 27. Keputusan Produk yang Disepakati

- Nama aplikasi adalah `Monitoring IbadahKu`.
- Aplikasi kedua terpisah dari IbadahKu.
- Platform MVP adalah Android dengan Flutter.
- Kedua aplikasi menggunakan backend Firebase bersama.
- Akses dibuat melalui undangan dan persetujuan anak.
- Wali dapat memantau beberapa anak.
- Anak dapat terhubung dengan beberapa wali.
- Wali dapat melihat seluruh data, termasuk tempat, waktu, dan catatan pribadi.
- Wali hanya memiliki akses baca.
- Wali dapat mengirim pengingat standar.
- Pesan bebas dan target ibadah tidak termasuk MVP.
- Anak dapat mencabut akses kapan saja.
- Tidak ada leaderboard, skor keimanan, atau perbandingan antar-anak.

---

## 28. Definition of Done

Sebuah fitur dianggap selesai jika:

- Memenuhi acceptance criteria.
- Memiliki validasi otorisasi server-side.
- Tidak membocorkan data antar-akun.
- Memiliki unit atau integration test sesuai risikonya.
- Menangani kondisi offline dan error jika relevan.
- Tidak menggunakan bahasa menghakimi.
- Mendukung aksesibilitas dasar.
- Tidak mengirim data sensitif ke log atau analitik umum.
- Telah melalui code review.
- Telah diuji pada perangkat Android nyata.
- Dokumentasi keamanan dan perilaku data telah diperbarui.

---

## 29. Dependensi Rilis

Monitoring IbadahKu hanya dapat dirilis setelah hal berikut tersedia:

1. Fitur Akses Keluarga pada IbadahKu.
2. Model relasi dan Security Rules yang telah diuji.
3. Cloud Functions untuk operasi sensitif.
4. Firebase Cloud Messaging dan deep link pada kedua aplikasi.
5. Mekanisme pencabutan akses serta penghapusan cache.
6. Kebijakan privasi dan syarat penggunaan yang mencakup data anak dan data ibadah.
7. Review kepatuhan terhadap kebijakan Google Play dan hukum wilayah distribusi.
