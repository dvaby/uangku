DEVELOPMENT BLUEPRINT UANGKU 1.0.0

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