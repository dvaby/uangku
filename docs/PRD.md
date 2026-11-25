PRODUCT REQUIREMENTS DOCUMENT (PRD)

## 1. Ringkasan Produk

Uangku adalah aplikasi keuangan pribadi Android yang membantu pengguna
mengelola pemasukan, pengeluaran, akun keuangan, anggaran berbasis
siklus gajian, tagihan, dan tabungan. Aplikasi didistribusikan melalui
APK dan dirancang local-first/offline-first.

Aplikasi mendukung **dua profil lokal yang terpisah**. Data, database,
dan kunci masing-masing profil harus terisolasi; satu profil tidak boleh
membaca atau mengubah data profil lain.

### Prinsip produk

1.  **Otomatis terlebih dahulu, manual tetap tersedia.** Transaksi dapat
    dikenali dari sumber otomatis yang telah didukung, tetapi pengguna
    selalu dapat menambah atau mengoreksi transaksi secara manual.
2.  **Privasi dan kendali lokal.** Data keuangan inti disimpan di
    perangkat; tidak ada backend atau sinkronisasi cloud untuk fungsi
    inti.
3.  **Mengatur uang, bukan sekadar mencatat.** Siklus gajian, anggaran,
    saldo aman, tagihan, dan target tabungan menjadi bagian alur utama.
4.  **Akurasi lebih penting daripada otomatisasi yang menebak.** Data
    yang tidak yakin diparse harus masuk status perlu ditinjau, bukan
    langsung dipastikan.
5.  **Keputusan harus dapat diuji.** Parser, perhitungan saldo,
    transfer, dan isolasi profil memiliki test yang dapat diulang.

## 2. Platform, Pengguna, dan Batasan

  -----------------------------------------------------------------------
  Area                                Ketentuan
  ----------------------------------- -----------------------------------
  Platform                            Android saja; distribusi APK, bukan
                                      Play Store untuk rilis awal

  Minimum OS                          Android 10 / API 29 sebagai
                                      baseline sementara

  Perangkat target                    Samsung Galaxy S10 dan Samsung
                                      Galaxy A23

  Kompatibilitas                      One UI 3+ merupakan asumsi
                                      sementara; versi aktual setiap
                                      perangkat wajib diverifikasi
                                      sebelum QA perangkat

  Pengguna                            Dua profil lokal, terpisah
                                      sepenuhnya

  Mode data                           Local-first/offline-first

  Backend                             Tidak ada server untuk fungsi inti

  Bahasa dan mata uang                Bahasa Indonesia; Rupiah (IDR)

  Editor utama                        VS Code pada Linux

  Arsitektur                          Flutter UI, Kotlin untuk integrasi
                                      Android, Go untuk domain/business
                                      logic melalui gomobile, SQLite
                                      lokal

  Distribusi                          APK; mekanisme pembaruan melalui
                                      GitHub Releases dapat dikembangkan
                                      sesuai prioritas rilis
  -----------------------------------------------------------------------

## 3. Ruang Lingkup Versi 1.0.0

### Masuk 1.0.0

-   Dua profil lokal dengan isolasi data dan kunci.
-   Onboarding profil, termasuk tanggal gajian dan akun penerima gaji.
-   Akun keuangan, termasuk seluruh e-wallet milik pengguna yang ingin
    dicatat.
-   Ledger transaksi pemasukan, pengeluaran, transfer internal, dan
    penyesuaian yang terkontrol.
-   Dashboard ringkasan keuangan.
-   Pelacakan otomatis melalui NotificationListenerService untuk parser
    yang telah memiliki sampel valid dan lulus pengujian.
-   Kategori dan pemetaan merchant dasar.
-   Siklus gajian dan anggaran kategori.
-   Tabungan digital dan fisik dengan target dan riwayat.
-   Modul tagihan dan pengingat lokal sesuai prioritas implementasi yang
    telah disepakati.
-   Backup dan restore terenkripsi.
-   PIN/biometrik dan perlindungan tampilan sensitif.
-   Smart Automation yang tidak bergantung pada server.

### Di luar 1.0.0

-   Bot/chat Telegram dan integrasi chat.
-   OCR nota/foto.
-   PDF/reporting lanjutan.
-   Audit hardening lanjutan di luar kebutuhan keamanan rilis awal.
-   Sinkronisasi cloud atau antar pengguna.
-   Aplikasi iOS/web.
-   Integrasi API bank.
-   Fitur investasi.
-   Backend atau LLM API.

Fitur di luar 1.0.0 tidak boleh diam-diam ditambahkan oleh Copilot saat
mengerjakan spike atau modul inti.

## 4. Akun dan Sumber Transaksi

### Akun keuangan

-   Semua akun bank dan e-wallet milik pengguna yang ingin dikelola
    direpresentasikan sebagai **Financial Account**.
-   Akun memiliki pemilik/profil, nama, jenis, institusi/sumber,
    identifikasi rekening seperlunya, dan status pelacakan.
-   Saldo yang berasal dari pencatatan transaksi dihitung dari ledger;
    jangan menganggap saldo bank telah disinkronkan langsung.
-   ShopeePay dan GoPay, jika dimiliki dan ingin dicatat, tetap
    dimodelkan sebagai akun keuangan. Dukungan parser otomatis hanya
    boleh diaktifkan setelah ada sampel yang tervalidasi.

### Status sampel parser yang diketahui

  -----------------------------------------------------------------------
  Sumber                  Status sampel           Kebijakan
  ----------------------- ----------------------- -----------------------
  myBCA                   Sampel tersedia         Parser hanya
                                                  mengaktifkan pola yang
                                                  benar-benar didukung
                                                  sampel

  DANA                    Sampel tersedia         Parser hanya
                                                  mengaktifkan pola yang
                                                  benar-benar didukung
                                                  sampel

  SeaBank                 Sampel tersedia         Parser hanya
                                                  mengaktifkan pola yang
                                                  benar-benar didukung
                                                  sampel

  Livin Mandiri           Belum ada sampel yang   Jangan mengaktifkan
                          dikonfirmasi dalam      parser produksi
                          keputusan terbaru       

  BSI                     Belum ada sampel yang   Jangan mengaktifkan
                          dikonfirmasi dalam      parser produksi
                          keputusan terbaru       

  GoPay                   Belum ada sampel yang   Jangan mengaktifkan
                          dikonfirmasi            parser produksi

  ShopeePay               Belum ada sampel yang   Jangan mengaktifkan
                          dikonfirmasi            parser produksi
  -----------------------------------------------------------------------

Sampel harus dianonimkan, diperoleh dengan izin, diperiksa skemanya, dan
dimasukkan ke golden/regression test. Jangan commit notifikasi asli yang
mengandung data pribadi ke repositori.

### Aturan parser

-   Parser hanya membaca notifikasi dari aplikasi dalam allowlist yang
    dikonfigurasi.
-   Simpan RawEvent minimum yang diperlukan untuk diagnosis lokal dan
    pemrosesan ulang, dengan perlindungan data.
-   Notifikasi promo/non-transaksi harus disaring.
-   Jika arah atau nominal tidak dapat dipastikan, tandai **Perlu
    Dicek**.
-   Deduplikasi harus mencegah satu transaksi masuk lebih dari sekali.
-   Transfer antar akun milik profil yang sama tidak dihitung sebagai
    pemasukan atau pengeluaran gabungan.
-   Jangan menyimpulkan transaksi yang tidak didukung sampel.

## 5. Aturan Bisnis Keuangan

### Jenis transaksi

1.  **Pemasukan** --- menambah total pemasukan.
2.  **Pengeluaran** --- menambah total pengeluaran.
3.  **Transfer Internal** --- memindahkan nilai antar akun milik profil
    yang sama; tidak mengubah total pemasukan/pengeluaran.
4.  **Penyesuaian saldo** --- tindakan eksplisit untuk mengoreksi saldo
    awal/selisih; wajib memiliki alasan dan jejak audit.

### Prinsip perhitungan

-   Semua nominal disimpan sebagai integer rupiah (`int64` pada domain
    Go); jangan gunakan floating point untuk uang.
-   Total dashboard dihitung dari transaksi yang telah dikonfirmasi
    sesuai aturan status.
-   Transfer internal harus memiliki pasangan debit/kredit yang
    konsisten atau status rekonsiliasi yang jelas.
-   Refund/reversal harus merujuk transaksi asal bila tersedia; jangan
    menghapus histori secara diam-diam.
-   Saldo akun = saldo awal + posting ledger yang relevan.
-   Total kekayaan tidak boleh menghitung transfer internal sebagai
    pemasukan/pengeluaran baru.
-   Semua query dan mutasi wajib dibatasi oleh `profile_id`.

### Status transaksi otomatis

Transaksi hasil parser dapat berstatus Perlu Dicek sampai pengguna
mengonfirmasi atau aturan auto-confirm yang telah disepakati berlaku.
Jangan mengubah status atau durasi auto-confirm berdasarkan asumsi baru;
implementasikan sesuai keputusan produk yang terkunci dan dokumentasikan
bila aturan final belum terwakili di spesifikasi teknis.

## 6. Onboarding dan Profil

-   Aplikasi menyediakan dua profil lokal yang terisolasi.
-   Setiap profil memiliki pengaturan, akun, transaksi, siklus gajian,
    anggaran, tabungan, dan tagihan sendiri.
-   **Tanggal gajian wajib diisi saat onboarding untuk setiap profil.**
-   **Akun penerima gaji wajib dipilih saat onboarding untuk setiap
    profil.**
-   Pengguna dapat mengubah tanggal gajian dan akun penerima gaji
    kemudian.
-   Perubahan pengaturan tersebut tidak boleh menulis ulang atau
    mengubah histori transaksi masa lalu.
-   Kunci enkripsi dan akses data tiap profil harus diisolasi.

## 7. Modul Produk

### M1. Beranda / Dashboard

-   Ringkasan pemasukan, pengeluaran, saldo, dan sisa dana siklus
    berjalan.
-   Ringkasan akun keuangan.
-   Ringkasan anggaran dan progres tabungan.
-   Peringatan transaksi yang perlu ditinjau dan tagihan mendekati jatuh
    tempo.
-   Semua angka harus berasal dari domain/ledger, bukan angka dummy pada
    build produksi.

### M2. Transaksi

-   Daftar transaksi dengan filter tanggal/periode, akun, kategori,
    tipe, dan sumber.
-   Tambah, edit, koreksi, konfirmasi, dan hapus sesuai kebijakan audit.
-   Detail transaksi memuat sumber, status, waktu, akun, nominal,
    kategori, dan catatan.
-   Transaksi otomatis yang tidak pasti tetap dapat ditinjau.

### M3. Budget / Anggaran

-   Anggaran mengikuti siklus gajian per profil.
-   Pengguna dapat membagi alokasi ke kategori.
-   Tampilkan alokasi, terpakai, sisa, dan indikator pemakaian.
-   Notifikasi ambang anggaran mengikuti aturan produk yang telah
    dikunci.
-   Safe to Spend harus dihitung konsisten dengan sisa anggaran dan
    kewajiban yang relevan.

### M4. Tabungan

-   Tabungan digital dan fisik/celengan.
-   Target, tenggat opsional, setoran, penarikan, histori, dan progres.
-   Pemindahan uang ke tabungan yang masih merupakan akun milik sendiri
    tidak boleh dihitung sebagai pengeluaran konsumsi.

### M5. Lainnya

-   Pengelolaan akun keuangan dan kategori.
-   Tagihan dan pengingat.
-   Pengaturan profil, tanggal gajian, akun gaji, keamanan,
    backup/restore, dan informasi aplikasi.
-   Modul lain yang tidak termasuk 1.0.0 tetap disembunyikan/tidak
    diimplementasikan.

## 8. Navigasi dan UI/UX

Navigasi bawah lima tab: 1. Beranda 2. Transaksi 3. Budget 4. Tabungan
5. Lainnya

Arah visual: - Modern, minimalis, tenang, mudah dibaca. - Material 3. -
Tema alam dengan warna hijau sebagai warna utama dan latar netral
hangat. - Mendukung dark mode. - Nominal uang menggunakan angka tabular
dan format Rupiah. - Warna bukan satu-satunya pembeda; gunakan ikon,
label, tanda plus/minus, dan status. - Target sentuh minimal 48 dp. -
Kontras teks memenuhi aksesibilitas yang layak. - Hindari dekorasi
berlebihan pada layar data padat.

Palet referensi dari PRD awal (boleh disesuaikan hanya bila ada
keputusan desain baru): \| Peran \| Warna \| \|---\|---\| \| Latar \|
`#F6F3EA` \| \| Kartu \| `#FFFDF8` \| \| Primer \| `#2F4A3A` \| \| Aksen
\| `#6B8F71` \| \| Aksen hangat \| `#C47A5A` \| \| Pemasukan \|
`#4E8B5F` \| \| Pengeluaran \| `#B5483A` \| \| Teks utama \| `#1F2A24`
\| \| Garis \| `#E3D9C3` \|

## 9. Keamanan, Privasi, dan Backup

-   Data keuangan inti tetap lokal.
-   Database lokal harus menggunakan pendekatan enkripsi yang telah
    ditetapkan untuk implementasi; jangan menganggap SQLite plaintext
    sebagai hasil akhir.
-   Kunci disimpan melalui Android Keystore dan dipisahkan per profil
    sesuai rancangan keamanan.
-   PIN/biometrik untuk membuka aplikasi.
-   Gunakan `FLAG_SECURE` untuk mencegah tampilan sensitif muncul pada
    screenshot/recents sesuai keputusan produk.
-   Backup harus terenkripsi, mencakup data yang diperlukan dan metadata
    pemulihan.
-   Restore harus memvalidasi integritas, versi skema, dan kepemilikan
    profil sebelum menulis data.
-   Jangan pernah mencatat token, PIN, key material, atau isi notifikasi
    sensitif ke log.
-   Jangan commit secret, keystore, file backup, atau sampel notifikasi
    mentah ke Git.
-   Tidak ada telemetry tersembunyi.

## 10. Non-Fungsional dan Kualitas

-   Android 10/API 29+ sebagai baseline sementara.
-   Target perangkat Samsung S10 dan A23; versi Android/One UI aktual
    wajib dicatat sebelum QA.
-   Bahasa Indonesia dan Rupiah.
-   Aplikasi harus tetap dapat mencatat/membaca data inti tanpa
    internet.
-   Service notifikasi harus pulih sesuai batasan Android dan kebijakan
    baterai OEM; jangan menjanjikan proses yang tidak dijamin OS.
-   Data dua profil tidak boleh bocor silang.
-   Perhitungan uang harus deterministik.
-   Parser harus memiliki golden tests dan regression tests.
-   Use case domain diuji tanpa perangkat/DB melalui repository fake.
-   Jangan menyatakan performa, keamanan, atau kompatibilitas lulus
    tanpa hasil uji.

## 11. Roadmap Ringkas

Urutan kerja teknis yang disepakati: 1. Technical Spike 01 --- Flutter ↔
Kotlin MethodChannel. 2. Technical Spike 02 --- Kotlin ↔ Go melalui
gomobile. 3. Technical Spike 03 --- Go ↔ SQLite terenkripsi; validasi
driver dan kompatibilitas gomobile. 4. Technical Spike 04 --- Android
NotificationListenerService. 5. Technical Spike 05 --- APK integrasi,
isolasi dua profil, dan pengujian pada perangkat target. 6. Setelah
spike lulus: fondasi domain/ledger, akun/profil, transaksi, dashboard,
budget, tabungan, tagihan, keamanan, backup/restore, parser yang
didukung sampel.

Estimasi lama pada PRD awal sekitar 16 minggu adalah perkiraan kasar,
bukan komitmen jadwal atau bukti progres.

## 12. Keputusan dan Governance Dataset Parser

Keputusan teknis/produk #1--240 dinyatakan terkunci. Jangan dibuka ulang
kecuali pengguna meminta atau ditemukan kontradiksi nyata yang harus
dilaporkan.

Kebijakan status dataset/parser yang telah dikunci: - **ACTIVE:** boleh
digunakan sesuai ruang lingkup versi dan persetujuan. - **DEPRECATED:**
dilarang untuk test baru; hanya boleh dipakai untuk reproduksi
historis. - **WITHDRAWN:** dilarang untuk test baru dan rerun atas
sampel terdampak; hasil historis tetap disimpan. -
**EMERGENCY_BLOCKED:** CI wajib menolak versi dan paket turunan yang
terdampak. - Pada EMERGENCY_BLOCKED, Privacy Responsible dapat langsung
memblokir dataset. Contribution Manager dan Privacy Responsible
melakukan review. Jika kecurigaan tidak terbukti, versi lama tetap
nonaktif dan menjadi DEPRECATED. Jika terbukti, status menjadi
WITHDRAWN. Pengganti wajib berupa versi baru, divalidasi, mendapat dua
persetujuan independen, lalu dirilis ACTIVE. - Sampel harus dianonimkan,
disetujui pemiliknya, dan memiliki provenance yang jelas.