
## Urutan & Konsistensi (merge ADT AGENTS)
- [ ] Semua aturan blocking dicek sebelum BAPI / COMMIT pertama
- [ ] Multi-step COMMIT punya guard idempotensi / kompensasi
- [ ] Hasil BDC/BAPI diverifikasi di database, semua message TYPE dievaluasi
- [ ] Komentar, FS/TS, dan konstanta cocok dengan kode

## Format Laporan QA

| Cek | Hasil (PASS / WARN / FAIL / NOT RUN) | Bukti |
|---|---|---|
| Objek tidak ada yang inaktif (`DWINACTIV`) | | |
| Syntax check | | |
| Test normal + data kosong + error | | |
| Short dump terbaru (`SNAP` / ST22) | | |
| Review statis (Critical/Major/Minor) | | |

Vonis: READY / READY WITH WARNINGS / NOT READY — langkah berikutnya: ...
Cek yang tidak dijalankan = NOT RUN + alasan, bukan PASS.
