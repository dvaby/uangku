# UANGKU --- MASTER PROJECT DOCUMENT

## PRD + Development Blueprint + GitHub Copilot Prompt

**Versi kerja:** 1.0.0\
**Tanggal konsolidasi:** 25 November 2026\
**Lingkungan pengembangan:** Linux + VS Code\
**Status:** Dokumen acuan kerja; implementasi belum dianggap teruji
sampai hasil pengujian nyata tersedia.

> **Catatan sumber dan konsolidasi:** Dokumen PRD Uangku v0.2 yang
> tersimpan digunakan sebagai sumber dasar. Dokumen ini mengintegrasikan
> keputusan lanjutan yang telah dikunci sampai keputusan #240 dan
> merangkum kembali Development Blueprint yang sebelumnya disusun.
> Karena naskah asli PRD v1.0 dan Blueprint sebelumnya tidak tersedia
> sebagai file yang dapat dibuka ulang secara utuh, bagian yang
> diperbarui/dirapikan di sini adalah konsolidasi kerja, bukan klaim
> salinan kata-per-kata dari artefak lama. Jika ada perbedaan, keputusan
> terbaru #1--240 yang telah dikunci menjadi acuan.

------------------------------------------------------------------------

# BAGIAN I --- PRODUCT REQUIREMENTS DOCUMENT (PRD)

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

------------------------------------------------------------------------

# BAGIAN II --- DEVELOPMENT BLUEPRINT UANGKU 1.0.0

## 1. Tujuan Blueprint

Blueprint menerjemahkan PRD menjadi struktur teknis, kontrak
antarlapisan, model data awal, urutan spike, backlog, dan gerbang
kualitas. Ini adalah rencana implementasi, bukan bukti bahwa arsitektur
telah tervalidasi di perangkat.

## 2. Arsitektur Target

``` text
┌───────────────────────────────────────────────────┐
│ Flutter Presentation (Dart)                       │
│ Screens · Widgets · State · Navigation            │
└──────────────────────┬────────────────────────────┘
                       │ Platform Channel / JSON
┌──────────────────────▼────────────────────────────┐
│ Android Native Layer (Kotlin)                     │
│ MainActivity · NotificationListenerService        │
│ Android Keystore · WorkManager · Alarm/Receivers  │
└──────────────────────┬────────────────────────────┘
                       │ gomobile bridge / JSON
┌──────────────────────▼────────────────────────────┐
│ Go Application + Domain                           │
│ Use Cases · Entities · Rules · Validation         │
│ Repositories · Financial Ledger                    │
└──────────────────────┬────────────────────────────┘
                       │ Repository / SQL
┌──────────────────────▼────────────────────────────┐
│ Local SQLite Storage                              │
│ Profile-scoped data · migrations · encryption     │
└───────────────────────────────────────────────────┘
```

Prinsip: - Flutter bertanggung jawab atas UI dan state presentasi. -
Kotlin menangani integrasi Android yang membutuhkan API platform. - Go
menjadi sumber utama aturan domain dan perhitungan bisnis. - Database
hanya diakses melalui repository. - Pertukaran data lintas bahasa
menggunakan kontrak JSON yang terversi dan tervalidasi. - Jangan menaruh
aturan finansial inti di widget Flutter atau Activity Kotlin. - Jangan
menganggap pemilihan driver SQLite/enkripsi final sebelum Spike 03
lulus.

## 3. Risiko Arsitektur yang Wajib Divalidasi

Risiko utama: kompatibilitas driver SQLite, enkripsi, CGO/non-CGO,
gomobile, ABI Android, dan build pada Linux.

Rencana: 1. Uji Go murni dan binding gomobile terlebih dahulu. 2. Uji
apakah driver SQLite pilihan dapat dibangun untuk ABI Android target
tanpa merusak integrasi. 3. Uji penyimpanan terenkripsi dan lifecycle
kunci. 4. Jika Go-driven SQLite/encrypted driver tidak kompatibel atau
tidak stabil, evaluasi fallback **Kotlin-managed encrypted SQLite**
dengan Go mengakses melalui repository/bridge yang jelas. 5. Jangan
mengunci fallback atau mengubah arsitektur tanpa hasil spike dan
keputusan eksplisit.

## 4. Model Data Logis Awal

Model berikut adalah rancangan awal yang harus ditinjau sebelum
migration dibuat.

  -----------------------------------------------------------------------
  Entitas                             Fungsi / atribut inti
  ----------------------------------- -----------------------------------
  Profile                             id, nama, status, key reference,
                                      created_at

  FinancialAccount                    id, profile_id, nama, jenis,
                                      institusi, identitas tersamar,
                                      tracked

  Category                            id, profile_id/global flag, nama,
                                      tipe, ikon

  Transaction                         id, profile_id, account_id, tipe,
                                      amount_minor, occurred_at,
                                      merchant, category_id, note,
                                      source, status, dedup_hash

  TransactionPosting                  id, transaction_id, account_id,
                                      debit/credit, amount_minor

  RawEvent                            id, profile_id, source_app, payload
                                      terenkripsi/terproteksi,
                                      received_at, parse_status

  BudgetCycle                         id, profile_id, start_date,
                                      end_date, salary_date

  BudgetAllocation                    id, cycle_id, category_id,
                                      allocated_amount

  SavingsGoal                         id, profile_id, nama, tipe,
                                      target_amount, due_date

  SavingsContribution                 id, goal_id, amount, occurred_at,
                                      linked_transaction_id

  Bill                                id, profile_id, nama, amount,
                                      due_rule, recurrence, active

  BillPayment                         id, bill_id, period_key, paid_at,
                                      transaction_id

  BackupRecord                        id, profile_id, created_at,
                                      schema_version, checksum, file
                                      metadata

  AuditLog                            id, profile_id, actor/action,
                                      entity, timestamp, reason, metadata
  -----------------------------------------------------------------------

Ketentuan: - Setiap tabel data pengguna memiliki `profile_id` atau
keterkaitan yang menjamin isolasi. - Gunakan foreign key dan
constraint. - Gunakan integer untuk uang. - Tambahkan unique/index
sesuai kebutuhan deduplikasi dan query. - Jangan menyimpan rahasia dalam
bentuk plaintext. - Skema final harus ditinjau dan diuji sebelum
migration dianggap stabil.

## 5. Financial Engine

Use case domain minimal: - CreateTransaction - ConfirmTransaction -
UpdateTransaction - Delete/ReverseTransaction sesuai kebijakan histori -
CreateInternalTransfer - ReconcileTransferPair - ComputeAccountBalance -
ComputeIncomeExpenseSummary - ComputeBudgetUsage - ComputeSafeToSpend -
ChangePayCycleSettings tanpa mengubah histori transaksi -
AddSavingsContribution / WithdrawSavings

Invariant wajib: - Jumlah debit dan kredit transfer internal seimbang. -
Transfer internal tidak mengubah total income/expense. - Semua operasi
terikat pada satu profile. - Nilai uang tidak menggunakan float. -
Mutasi penting atomik di dalam transaksi database. - Perubahan tanggal
gajian tidak mengubah timestamp transaksi lama. - Refund/reversal
mempertahankan relasi ke transaksi asal bila diketahui.

## 6. Struktur Repository yang Disarankan

``` text
uangku/
├── android/
│   └── app/src/main/kotlin/<package_name>/
│       ├── MainActivity.kt
│       └── notification/
├── core/                         # Go domain & application
│   ├── domain/
│   ├── usecase/
│   ├── port/
│   ├── adapter/
│   │   ├── sqlite/
│   │   ├── parser/
│   │   └── security/
│   └── api/                      # gomobile facade; JSON in/out
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── bridge/
│   │   ├── routing/
│   │   └── theme/
│   └── features/
│       ├── home/
│       ├── transactions/
│       ├── budget/
│       ├── savings/
│       ├── accounts/
│       ├── bills/
│       └── settings/
├── test/
├── docs/
│   ├── MASTER_PROJECT_DOCUMENT.md
│   ├── PRD.md
│   ├── DEVELOPMENT_BLUEPRINT.md
│   ├── TECHNICAL_DECISIONS.md
│   └── SPIKE_RESULTS/
├── scripts/
├── pubspec.yaml
├── go.mod
└── README.md
```

Struktur aktual boleh menyesuaikan repository yang sudah ada. Copilot
harus memeriksa struktur sebelum membuat atau memindahkan file dan tidak
boleh merusak file yang sudah ada.

## 7. Kontrak Flutter ↔ Kotlin ↔ Go

### Flutter ↔ Kotlin

-   Gunakan MethodChannel dengan nama channel yang konsisten.
-   Payload dan response harus terdefinisi.
-   Tangani `PlatformException`, `MissingPluginException`, dan method
    yang tidak dikenal.
-   Jangan mengirim objek Dart kompleks tanpa serialisasi yang
    disepakati.

### Kotlin ↔ Go

-   Gunakan facade gomobile yang tipis.
-   Gunakan JSON string untuk input/output bila diperlukan oleh batasan
    gomobile.
-   Validasi JSON, versi kontrak, dan error code.
-   Jangan letakkan aturan bisnis pada Kotlin.
-   Jangan mengekspos tipe Go yang tidak didukung gomobile.

Contoh kontrak konseptual:

``` json
{
  "contractVersion": 1,
  "requestId": "uuid",
  "operation": "healthCheck",
  "payload": {}
}
```

Response konseptual:

``` json
{
  "contractVersion": 1,
  "requestId": "uuid",
  "success": true,
  "data": {},
  "error": null
}
```

Ini contoh format, bukan kontrak final untuk seluruh use case. Kontrak
final ditetapkan setelah spike terkait.

## 8. Technical Spike Sequence

### Spike 01 --- Flutter ↔ Kotlin MethodChannel

Tujuan: membuktikan Flutter dapat memanggil kode Kotlin native dan
menerima response. Kriteria lulus: - Method `ping` berhasil dipanggil
dari Flutter. - Kotlin mengembalikan message, platform, dan SDK Android
aktual. - Error unknown method dan error bridge tertangani. -
`flutter analyze`, test yang relevan, dan debug APK build dijalankan
serta hasilnya dicatat. - Tidak mengubah scope menjadi aplikasi penuh.

### Spike 02 --- Kotlin ↔ Go gomobile

Tujuan: membuktikan Kotlin memanggil facade Go hasil gomobile. Kriteria
lulus: - Binding berhasil dibuat untuk ABI target. - Kotlin memanggil
fungsi Go dan menerima JSON. - Error dan invalid JSON ditangani. - Build
dapat diulang dari instruksi yang terdokumentasi.

### Spike 03 --- Go ↔ SQLite terenkripsi

Tujuan: validasi penyimpanan lokal, driver, enkripsi, migration, dan
transaksi. Kriteria lulus: - CRUD sederhana berhasil. - Data tersimpan
setelah proses ditutup/dibuka ulang. - Uji isolasi profil berhasil. -
Kunci tidak ditulis ke log. - Backup/restore dasar dapat diverifikasi. -
Jika pendekatan Go DB gagal, dokumentasikan bukti dan evaluasi fallback
Kotlin-managed encrypted SQLite.

### Spike 04 --- Notification Listener

Tujuan: menerima notifikasi dari allowlist secara aman. Kriteria
lulus: - Izin dan status service terdeteksi. - Hanya package yang
diizinkan diproses. - Payload sensitif tidak masuk log. -
Restart/lifecycle dan pembatasan baterai diuji. - Parser hanya aktif
untuk sampel yang disetujui.

### Spike 05 --- APK Integrasi dan Profile Isolation

Tujuan: menguji integrasi Flutter, Kotlin, Go, storage, dan profil.
Kriteria lulus: - APK debug terpasang dan berjalan pada
emulator/perangkat. - Dua profil tidak dapat membaca atau memodifikasi
data satu sama lain. - Kunci dan backup profile-scoped. - Smoke test
pada Samsung S10 dan A23 setelah versi OS aktual dicatat.

**Jangan lanjut ke spike berikutnya hanya karena kode berhasil dibuat.
Lanjut setelah kriteria spike sebelumnya dibuktikan dan hasilnya
dicatat.**

## 9. Development Epics

1.  Fondasi repository, build, lint, dan CI lokal.
2.  Profil lokal, onboarding, dan isolasi kunci.
3.  Financial Account dan kategori.
4.  Ledger transaksi dan financial engine.
5.  Dashboard dan ringkasan.
6.  Siklus gajian dan budget.
7.  Tabungan dan target.
8.  Tagihan dan pengingat lokal.
9.  NotificationListener dan pipeline RawEvent.
10. Parser yang didukung sampel + golden tests.
11. Keamanan, backup, dan restore.
12. Integrasi akhir, QA perangkat, dokumentasi, dan APK release.

Urutan detail dapat berubah hanya setelah dependency dan hasil spike
dievaluasi.

## 10. QA dan Definition of Done

Setiap task dinyatakan selesai hanya jika: - Scope sesuai PRD dan
keputusan terkunci. - Perubahan kode minimal dan tidak merusak area
lain. - Lint/analyzer lulus. - Unit/widget/integration test relevan
lulus. - Build target yang relevan berhasil. - Error state ditangani. -
Tidak ada secret atau data pribadi di source/log. - Dokumentasi
diperbarui. - Hasil aktual dicatat: PASS, FAIL, BLOCKED, atau NOT RUN.

Dilarang menyebut test PASS jika perintah tidak dijalankan atau
outputnya tidak diperiksa.

## 11. Perintah Lingkungan Linux

Perintah diagnostik awal:

``` bash
flutter doctor -v
flutter doctor --android-licenses
flutter devices
```

Untuk project Flutter yang sudah ada:

``` bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Jangan menjalankan perintah destruktif atau mengganti versi
SDK/Gradle/AGP tanpa menjelaskan alasan dan meminta persetujuan bila
berisiko pada project.

------------------------------------------------------------------------


