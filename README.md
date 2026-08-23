# GAAFTBLL ⚽

Game bola arcade 11 vs 11 dibuat dengan **Flutter (Dart) + Kotlin native**,
terinspirasi gaya kontrol eFootball/PES: **LARI, LAWAN, TENDANG, OPER**.

Resolusi desain dunia game: **1920 x 1080 px**.

---

## ✅ Fitur yang sudah ada di starter project ini

- 11 pemain per tim (formasi 4-4-2), lengkap kiper, bek, gelandang, penyerang
- Tim lawan dikendalikan AI (mengejar bola, menjaga posisi formasi)
- Deteksi **gawang / gol**
- Deteksi **bola keluar (out)** → throw-in, sepak pojok (corner), sepak gawang
- **Wasit otomatis**: mendeteksi pelanggaran (foul) saat tekel, memberi
  **kartu kuning & kartu merah** (2x kuning = merah)
- Kontrol ala eFootball: joystick gerak + tombol **LARI (sprint)**,
  **OPER (passing)**, **TENDANG (shoot)**, **LAWAN (tackle)**, ganti pemain
- HUD skor, waktu, babak 1 & 2, commentary singkat
- Layar hasil akhir pertandingan
- Integrasi **Kotlin native** (MainActivity.kt) via MethodChannel untuk efek
  getar HP saat gol/tekel/kartu — contoh nyata kombinasi Flutter + Kotlin
- Icon aplikasi sudah dibuat (`assets/icon/app_icon.png`) + konfigurasi
  `flutter_launcher_icons` di `pubspec.yaml`
- Nama aplikasi sudah diset **GAAFTBLL** di `AndroidManifest.xml` & `strings.xml`

### 🎥 Kamera dinamis ala broadcast (v1.1)

- Kamera **mengikuti bola** dengan pergerakan halus (smooth follow), bukan
  statis melihat seluruh lapangan sekaligus
- **Zoom otomatis**: mendekat saat aksi terjadi di kotak penalti, melebar saat
  bola di tengah lapangan
- **Camera shake**: getar layar singkat saat gol tercipta & saat tekel keras
- **Slow-motion replay** ±1.4 detik otomatis setiap gol (gerakan diperlambat,
  waktu pertandingan tetap normal)
- **Banner "GOAL!"** animasi muncul di tengah layar saat gol
- **Trail bola** (jejak memudar) saat bola melaju kencang
- Vignette gelap di tepi layar untuk kesan sinematik ala siaran TV

> ⚠️ Catatan jujur soal grafis: Flutter + Flame adalah **engine 2D**, jadi
> tidak mungkin menyamai grafis 3D real seperti PS5 (butuh engine 3D seperti
> Unity/Unreal + aset 3D + tim besar). Yang sudah dibuat di atas adalah
> **kamera dinamis & efek sinematik** (follow, zoom, shake, slow-motion,
> replay gol) yang membuat gameplay 2D ini terasa lebih hidup dan dramatis,
> sesuai batas kemampuan engine yang dipakai.

### 📴 Mode Offline

Game ini **100% offline** — semua logic (fisika bola, AI, wasit, skor)
berjalan lokal di HP, tidak ada request internet sama sekali:
- Izin `INTERNET` sudah **dihapus** dari `AndroidManifest.xml`
- Tidak ada login, ads, atau server backend
- Badge "MODE OFFLINE" ditampilkan di menu utama
- Aman untuk diisi di **Data Safety form** Play Console sebagai "tidak
  mengumpulkan data pengguna" (selama Anda tidak menambahkan SDK iklan/analytics)

> ⚠️ Catatan jujur: ini adalah **base/prototype yang fungsional**, bukan
> game sekelas eFootball asli (grafis 3D, animasi motion-capture, lisensi
> pemain/klub, dsb — itu butuh tim besar bertahun-tahun). Tapi semua mekanik
> inti yang Anda minta (11 pemain, lawan, gawang, wasit, out, kartu,
> pelanggaran, tombol LARI/LAWAN/TENDANG/OPER, kamera dinamis, offline)
> sudah berjalan dan bisa langsung di-build ke APK, lalu Anda kembangkan
> lebih lanjut (grafis, sprite/animasi, sound effect, level AI, dll) sebelum
> rilis final.

---

## 📁 Struktur Project

```
GAAFTBLL/
├── pubspec.yaml              # dependencies (flame, flutter_launcher_icons, dst)
├── lib/
│   ├── main.dart             # entry point
│   ├── match_screen.dart     # layar pertandingan (GameWidget + HUD + kontrol)
│   ├── game/
│   │   ├── gaaftbll_game.dart   # inti game engine (Flame)
│   │   ├── field_component.dart # lapangan, gawang, garis (1920x1080)
│   │   ├── player_component.dart# komponen pemain
│   │   ├── ball_component.dart  # komponen bola
│   │   ├── ai_logic.dart        # AI pemain non-kontrol
│   │   ├── referee.dart         # wasit: out, gol, foul, kartu
│   │   └── match_state.dart     # skor, waktu, kartu (ChangeNotifier)
│   └── ui/
│       ├── main_menu.dart
│       ├── control_overlay.dart # joystick + tombol LARI/OPER/TENDANG/LAWAN
│       ├── hud_overlay.dart
│       └── result_overlay.dart
├── android/
│   └── app/src/main/kotlin/com/gaaftbll/game/MainActivity.kt  # Kotlin native
└── assets/icon/app_icon.png  # icon aplikasi
```

---

## 🚀 Cara Build (langkah demi langkah)

Prasyarat: **Flutter SDK** sudah terpasang (`flutter doctor` OK) dan Android
SDK tersedia.

1. **Extract** file zip ini, lalu buka terminal di folder `GAAFTBLL`.

2. **Regenerasi file wrapper platform** (gradlew, dsb yang tidak ikut di-zip
   karena berupa file besar/binary). Jalankan:
   ```bash
   flutter create .
   ```
   Perintah ini AMAN — akan melengkapi file pendukung Android tanpa menghapus
   kode `lib/` dan `android/` yang sudah dibuat khusus untuk GAAFTBLL.

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Generate icon aplikasi otomatis** (memakai `assets/icon/app_icon.png`
   yang sudah disediakan) ke semua ukuran mipmap Android:
   ```bash
   dart run flutter_launcher_icons
   ```

5. **Coba jalankan di emulator/HP** untuk testing:
   ```bash
   flutter run
   ```

6. **Build APK / App Bundle untuk rilis:**
   ```bash
   flutter build apk --release
   # atau (disarankan Play Store, format .aab):
   flutter build appbundle --release
   ```
   Hasil build ada di:
   - `build/app/outputs/flutter-apk/app-release.apk`
   - `build/app/outputs/bundle/release/app-release.aab`

---

## 🎮 Kontrol Permainan

| Kontrol   | Fungsi                                              |
|-----------|------------------------------------------------------|
| Joystick  | Menggerakkan pemain yang dikendalikan                |
| LARI      | Tahan untuk berlari/sprint lebih cepat                |
| OPER      | Umpan ke rekan setim terdekat                         |
| TENDANG   | Tembak bola ke arah gawang lawan                      |
| LAWAN     | Coba rebut bola (tekel) dari lawan terdekat           |
| ⇄ (switch)| Pindah kontrol otomatis ke pemain terdekat dari bola  |
| ⏸️ (pause)| Jeda pertandingan                                     |

Wasit otomatis: bola keluar → throw-in/corner/goal-kick; tekel berisiko bisa
menghasilkan pelanggaran + kartu kuning/merah, sesuai probabilitas di
`lib/game/referee.dart` (bisa Anda atur ulang angkanya).

---

## 🔑 Rilis ke Play Store (ringkasan penting)

1. **Ganti `applicationId`** di `android/app/build.gradle` (baris
   `applicationId "com.gaaftbll.game"`) dengan ID unik milik Anda, contoh
   `com.namaanda.gaaftbll`, karena `com.gaaftbll.game` di file ini hanya
   contoh placeholder.

2. **Buat keystore rilis** (sekali saja, simpan baik-baik file `.jks` ini,
   jangan hilang — tanpa ini Anda tidak bisa update app di Play Store):
   ```bash
   keytool -genkey -v -keystore gaaftbll-release.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias gaaftbll
   ```
   Simpan file `gaaftbll-release.jks` di folder `android/` (satu level di
   atas folder `app/`).

3. **Salin** `android/key.properties.example` menjadi `android/key.properties`
   lalu isi password & alias sesuai keystore yang barusan dibuat.
   File `key.properties` sudah otomatis diabaikan oleh `.gitignore` (jangan
   sampai bocor ke publik).

4. Jalankan ulang:
   ```bash
   flutter build appbundle --release
   ```
   Build ini otomatis akan pakai signing rilis Anda (dideteksi dari
   `key.properties`).

5. Buka **Google Play Console** → buat aplikasi baru → upload file
   `app-release.aab` → lengkapi:
   - Nama aplikasi, deskripsi, screenshot (ambil dari `flutter run` di HP)
   - Ikon 512x512 (bisa export ulang dari `assets/icon/app_icon.png`)
   - Feature graphic 1024x500
   - Kebijakan privasi (privacy policy URL) — wajib meskipun app sederhana
   - Rating konten (isi kuesioner IARC)
   - Target audience & data safety form

6. Submit untuk review.

---

## 🛠️ Ide Pengembangan Lanjutan

- Ganti gambar pemain dari bentuk lingkaran polos (`player_component.dart`)
  jadi sprite/animasi berjalan-lari-tendang
- Tambah sound effect (peluit wasit, tendangan, sorak penonton) — bisa pakai
  package `audioplayers` atau `flame_audio`
- Tambah pilihan tim/jersey, mode karier, multiplayer lokal 2 pemain
- Tambah efek animasi kartu kuning/merah muncul di layar
- Tingkatkan AI (formasi lebih realistis, offside, GK menerjang bola)

Selamat mengembangkan GAAFTBLL! ⚽🔥
