# Checkpoint — SAP GUI noVNC publik: monitor dan override

Tanggal: 2026-09-15 WIB

## Endpoint publik

- Monitor view-only: `https://pc.abap.web.id/vnc.html`
- Override writable: `https://pcr.abap.web.id/vnc.html`

DNS kedua hostname diarahkan ke Cloudflare Tunnel `862b6d68-11e7-4468-b81a-3390defd19f0.cfargotunnel.com` melalui record CNAME proxied di zona `abap.web.id`.

## Arsitektur aktif

```text
pc.abap.web.id  -> Cloudflare Tunnel -> 127.0.0.1:6080 -> noVNC/websockify -> x11vnc :99 port 5999 (view-only)
pcr.abap.web.id -> Cloudflare Tunnel -> 127.0.0.1:6081 (nginx)
                    ├─ /login, /logout               -> 127.0.0.1:6082 oidc-auth-server (form pcr, verifikasi ke MCP)
                    ├─ /websockify (WebSocket VNC)   -> 127.0.0.1:6082 (cek sesi) -> 127.0.0.1:6083 websockify -> x11vnc :99 port 5998 (writable)
                    └─ / (file statis noVNC)         -> auth_request ke 6082 -> 127.0.0.1:6083
```

- Raw VNC port 5998/5999 hanya bind localhost.
- `pc` tidak meminta login dan tidak dapat dikendalikan, karena x11vnc memakai `-viewonly`.
- `pcr` login memakai akun MCP lewat form pcr (lihat bagian "Login pcr via MCP" di bawah). Basic Auth/htpasswd tidak dipakai lagi sejak 2026-11-20.
- Service persistensi gateway: `~/.config/systemd/user/pcr-auth-proxy.service` (nginx) dan `pcr-session-auth.service` (oidc-auth-server), keduanya enabled dan active.
- Service stack SAP GUI/noVNC: `sap-gui-monitor.service`.

## Verifikasi end-to-end aktual

Dilakukan 2026-09-15:

- `https://pc.abap.web.id/vnc.html` -> HTTP 200.
- WebSocket `pc.abap.web.id/websockify` -> HTTP 101 Switching Protocols.
- `https://pcr.abap.web.id/vnc.html` tanpa kredensial -> HTTP 401 Unauthorized.
- `pcr` dengan username benar tetapi password salah -> HTTP 401 Unauthorized.
- `pcr` dengan kredensial benar -> HTTP 200; WebSocket -> HTTP 101 Switching Protocols.

Ini membuktikan halaman noVNC dan koneksi WebSocket melewati Cloudflare berfungsi; bukan sekadar halaman HTTP yang merespons.

## URL ringkas (wrapper domain)

`/home/abap/.local/opt/novnc-web/index.html` adalah wrapper root noVNC. Ia otomatis mengarahkan domain root ke `/vnc.html?autoconnect=1&reconnect=1` dan meneruskan query tambahan bila ada.

- Cukup buka `https://pc.abap.web.id` untuk monitor.
- Cukup buka `https://pcr.abap.web.id` untuk override. Browser meminta Basic Auth sebelum wrapper/noVNC dimuat.

Uji 2026-09-15: `pc` root memuat wrapper; `pcr` root tanpa login -> 401, dengan login benar memuat wrapper; kedua target `vnc.html` -> 200.

## Re-autentikasi setelah sesi lama

Basic Auth dapat ditolak pada WebSocket ketika halaman noVNC lama masih terbuka. Browser tidak selalu menampilkan dialog Basic Auth untuk penolakan WebSocket; gejalanya sebelumnya adalah `Failed to reconnect` sampai halaman di-refresh.

`app/ui.js` noVNC diperbarui untuk hostname `pcr.abap.web.id`: pada disconnect tidak bersih, halaman otomatis sekali kembali ke root gateway yang dilindungi (`/?reauth=<timestamp>`). Root ini menghasilkan challenge Basic Auth browser sehingga popup muncul tanpa refresh manual. Batas 30 detik pada `sessionStorage` mencegah refresh-loop bila origin sedang benar-benar mati. `pc` tidak berubah dan tetap memakai auto-reconnect biasa.

Verifikasi 2026-09-15: patch JavaScript terlihat melalui HTTPS pada `pc` dan `pcr`; `pcr` dengan kredensial valid tetap HTTP 200.

## Operasional

Baginda dan teman kantor dapat membuka `pc` untuk melihat. Akses `pcr` memakai akun MCP yang aktif (sejak 2026-11-20). SAP login tetap lapisan terpisah setelah noVNC tersambung.

## Login pcr via MCP (2026-11-20)

Menggantikan htpasswd. Tampilan login tetap form pcr yang lama (`login.html`), tetapi username/password diverifikasi di belakang layar ke Central OIDC MCP (`https://mcp.abap.web.id`, database `ai_auth` di 192.168.1.162), sama seperti ABAP Git. Semua user MCP yang aktif boleh masuk; tidak ada password lokal.

- Server: `/home/abap/.local/opt/pcr-auth-proxy/oidc-auth-server.py` (aiohttp di `venv/`), port 6082, service `pcr-session-auth.service`. Konfigurasi lewat `Environment=PCR_*` di unit systemd.
- Login: form `POST /login` -> MCP `POST /v1/auth/login`. Sukses -> sesi server-side menyimpan refresh token MCP; browser hanya memegang cookie `pcr_sid` acak (HttpOnly, Secure). Sesi disimpan di `sessions.json` (mode 600, kunci = hash cookie). Pilihan masa berlaku di form (7 hari, 30 hari, 24 jam, selama browser dibuka) tetap berlaku.
- Akun yang wajib ganti password ditolak dengan pesan untuk ganti dulu di mcp.abap.web.id.
- Pencabutan akses: tiap `PCR_REVALIDATE_SECONDS` (120 dtk) sesi diperpanjang lewat MCP `POST /v1/auth/refresh`. MCP mencabut semua refresh token saat password diganti (sendiri, admin, atau lupa password) dan saat user dinonaktifkan, sehingga refresh ditolak -> sesi pcr dihapus dan WebSocket VNC yang terbuka diputus (close code 4401). Bila MCP tidak bisa dihubungi, sesi bertahan paling lama 10 menit sejak validasi terakhir lalu ditutup (fail-closed).
- WebSocket VNC `/websockify` diproksikan lewat server ini (bukan langsung nginx) agar koneksi yang berjalan bisa diputus.
- Logout pcr juga mencabut refresh token sesi itu di MCP.
- OAuth client `pcr-operator` sempat didaftarkan di MCP untuk alur redirect, tapi tidak dipakai lagi (user memilih tetap pakai form pcr).
- File lama: `session-auth-server.py.disabled-20261120` (berisi password cadangan hardcoded, jangan diaktifkan lagi), `.htpasswd`, `nginx.conf.bak-20261120`, `pcr-session-auth.service.bak-20261120`.

Verifikasi 2026-11-20: tanpa sesi `/`, `/vnc.html`, `/?reauth=` -> 302 ke `/login` (form lama tampil); password salah -> 401 dengan pesan; `/websockify` tanpa cookie -> 401; logout -> `/login?logged_out=1`. Uji sesi palsu dengan refresh token tidak valid: WebSocket VNC tersambung lewat proxy, lalu sekitar 40 detik kemudian MCP menolak refresh (401), sesi dihapus dan WebSocket diputus 4401. Login sukses dengan akun MCP nyata belum diuji (menunggu operator).

## Perbaikan tampilan dobel noVNC (2026-11-20)

Gejala: di `pc`/`pcr` layar SAP tampil dua kali bertumpuk vertikal dan halaman bisa di-scroll. Penyebab: `vnc.html` memuat `app/ui.js?v=...` sedangkan `app/mobile-assistant.js` meng-import `./ui.js` tanpa query; browser menganggapnya dua modul berbeda sehingga UI noVNC berjalan dua kali (dua koneksi RFB, dua canvas). Perbaikan: keduanya memakai URL yang sama persis (`ui.js?v=20261120_1`). Kalau versi cache-bust diganti, ubah di **kedua** tempat. Backup: `vnc.html.bak-20261120`, `app/mobile-assistant.js.bak-20261120`.

## Chip user & tombol Keluar di pcr (2026-11-20)

`app/mobile-assistant.js` (`createSessionChip`) memanggil `/oidc/whoami`; bila login, chip nama user + tombol "Keluar" tampil di kanan atas, satu grup dengan chip Clipboard (`#sma-top-right`). Di `pc` endpoint itu 404 sehingga chip tidak tampil. CSS di akhir `app/styles/mobile-assistant.css`. Versi cache: `mobile-assistant.js?v=20261120_2` dan `mobile-assistant.css?v=20261120_2` (`ui.js` tetap `20261120_1`, harus sama dengan import di mobile-assistant.js). Backup: `*.bak-20261120b`.

## Double-tap = double-click di HP (2026-11-20)

Sebelumnya `setupTouchGestures` di `app/mobile-assistant.js` menangkap tap kedua untuk toggle zoom Fit ⇄ 100%, sehingga SAP tidak pernah menerima double-click. Sekarang di mode **Klik** double-tap diteruskan ke noVNC (noVNC menyamakan posisi tap kedua dengan tap pertama) = double-click mouse. Toggle zoom lewat double-tap hanya di mode **Geser**; zoom tetap bisa lewat tombol Fit dan cubit 2 jari. Versi: `mobile-assistant.js?v=20261120_3`. Uji emulasi iPhone di port view-only 6080 dengan pengiriman klik diganti perekam: 2x tekan+lepas di koordinat sama, jarak 130 ms, skala zoom tidak berubah.

## Perbaikan kenyamanan HP, log pemakaian, bersih-bersih (2026-11-20)

**Bersih-bersih keamanan:** dihapus `session-auth-server.py.disabled-20261120` (berisi password cadangan hardcoded), `.htpasswd`, `session.secret`. OAuth client `pcr-operator` di MCP dinonaktifkan (`is_active=false`).

**Log pemakaian pcr:** `/home/abap/.local/opt/pcr-auth-proxy/logs/usage.log` (mode 600, satu JSON per baris). Event: `login` (ip, user agent, masa sesi), `login_failed` (ip, status MCP atau `must_change_password`), `vnc_connect` (ip, jumlah koneksi VNC terbuka), `vnc_disconnect` (detik tersambung), `session_closed` (alasan: logout, MCP menolak refresh, kedaluwarsa). Contoh baca:

```bash
tail -n 50 /home/abap/.local/opt/pcr-auth-proxy/logs/usage.log
```

**Status SAP:** `oidc-auth-server.py` (`sap_state`) membaca judul window di display `:99` lewat `xdotool` (cache 5 dtk): `closed` (window "Connection closed"), `logon` (hanya logon pad), `active`. Dikirim di `/oidc/whoami` sebagai `sap`.

**UI (`app/mobile-assistant.js` + `.css`, versi `20261120_5`):**
- Area layar SAP berhenti di atas toolbar (`--sma-reserve-bottom`, `updateViewportReserve`) sehingga status bar SAP selalu terlihat; saat toolbar dikecilkan ke bubble, area kembali penuh.
- Panel Keyboard maks 60% tinggi layar (52% di HP miring), latar tidak digelapkan penuh. Di HP layar SAP di-fit di atas panel; di desktop tidak. Input tidak auto-fokus di HP. Baris input membungkus di layar sempit sehingga "Kirim + ⏎" tidak terpotong. Tombol Keluar ganda di header panel disembunyikan.
- Banner status SAP ringkas (cek tiap 15 dtk), bisa ditutup; tersembunyi saat panel Keyboard terbuka. Bila `/oidc/whoami` 401 (sesi pcr dicabut), halaman pindah ke `/login?expired=1`.
- Petunjuk cara pakai muncul sekali (localStorage `sma-hint-seen-v1`), versi HP dan desktop.
- Toast dipindah ke bawah chip kanan atas.
- Font SAP GUI Java sengaja tidak diubah: setelan global satu layar bersama, mengurangi isi layar untuk pengguna desktop, dan perlu restart SAP GUI.

Uji emulasi iPhone 13 (tegak & miring) dan desktop 1440x860 di port view-only 6080 (whoami di-mock): bawah canvas SAP selalu di atas toolbar/panel, tombol panel muat di layar, banner & petunjuk tampil dan bisa ditutup, tidak ada error JS.

Tambahan: saat toolbar dikecilkan ke bubble, chip user/Keluar dan chip Clipboard ikut disembunyikan (class `sma-minimized` di `<html>`), muncul lagi saat bubble diketuk. Banner status SAP tetap tampil karena berisi info penting. Versi `20261120_6`.

## Pencabutan sesi lebih cepat (2026-11-20)

Uji user nonaktif oleh operator: sesi pcr memang tertutup, tetapi baru saat revalidasi berikutnya (sampai sekitar 2,5 menit). Sekarang `oidc-auth-server.py` mengecek status user tiap `PCR_CHECK_SECONDS` (15 dtk) lewat MCP `GET /v1/auth/me` memakai access token dari login/refresh. Endpoint ini tidak membuat token baru; ia menolak bila user nonaktif (cek DB) atau token dicabut setelah ganti password (Redis `user:revoked_before`). Bila `/me` menolak, dipastikan dengan refresh; refresh yang ditolak menutup sesi dan memutus VNC. Refresh rutin tiap `PCR_REFRESH_SECONDS` (600 dtk) untuk memperbarui access token (berlaku 15 menit). Uji sesi palsu: diputus 3 detik setelah server mulai. Backup sebelum perubahan: `oidc-auth-server.py.bak-20261120c`.
Uji nyata 2026-11-20 oleh operator: TRST-BUDI login 14:39:33, VNC tersambung 14:39:35, user dinonaktifkan di MCP, sesi ditutup dan VNC diputus 14:40:07; login ulang 14:40:18 ditolak (401).
- 2026-11-20: Zoom out/in di desktop sempat kembali ke 100% karena noVNC (resize=off) mereset skala ke 1.0 setiap ukuran kontainer berubah (mis. scrollbar browser hilang). mobile-assistant.js sekarang menimpa `_updateScale` agar zoom pilihan user tetap; mode Pas Layar ikut menyesuaikan ukuran jendela. Versi aset `?v=20261120_7`.
