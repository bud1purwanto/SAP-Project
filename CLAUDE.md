# Aturan project SAP

## Testing SAP GUI = di server lewat SSH (bukan laptop user)
Kalau user minta testing/uji lewat SAP GUI, jalankan di SAP GUI Java yang ada di server (display virtual Xvfb `:99`), jangan pakai desktop/laptop user (jangan pakai tool computer-use yang mengendalikan laptop).

Cara (terbukti 18 Nov 2026):
- Kendali input: `DISPLAY=:99 xdotool` (klik, ketik, F8, F3). Screenshot: `PIL.ImageGrab.grab(xdisplay=':99')`. Tidak ada ImageMagick. Window SAP GUI 1440x900, command field di (108,66).
- Login: double-click koneksi (mis. Development AIX), isi client, user, password dari pesan user. Jangan tulis password ke file, script, dokumen, atau memory.
- Python paket (openpyxl dll.): pakai venv di scratchpad (`python3 -m venv --system-site-packages`), pip sistem diblok PEP 668.
- Setiap aksi diverifikasi dengan screenshot. Popup "Leave List?" muncul saat F3 dari ALV: klik Yes.
- Selesai uji: logout (`/nex`).
- Detail dan koordinat: `subproject/SAP_GUI_AUTOMATION/README.md`, memory `sap-gui-test-server`.
- Aturan lain tetap berlaku: DEV hanya diubah user, uji GUI bersifat baca (jangan posting/commit tanpa diminta).

## Hasil uji GUI
Simpan screenshot dan laporan di `outputs/` subproject terkait. Format Excel: satu sheet per skenario/DO, markdown per skenario (lihat aturan subproject).
