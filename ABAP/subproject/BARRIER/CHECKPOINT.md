# CHECKPOINT — BARRIER

## Terakhir Dikerjakan
| Atribut | Isi |
|---|---|
| Waktu | 2026-11-26 |
| Pekerjaan | Analisa laporan tester: NCR approval "hilang" di ZQM004 setelah update WVTR/OTR (DEV, batch SRRPAI/0000407498) |
| Temuan | Approval TIDAK terhapus di ZLOG_BARRIER (guard v8 jalan). `GET_JUDGEMENT` mengabaikan baris jika UD R/C/L lebih baru dari CPUDT/CPUTM baris → tampil kosong, dan `GET_SHIPMENT` menimpa CANBESHIP=X. Direproduksi read-only di DEV |
| Status | Keputusan: approval dibekukan. Patch `GET_JUDGEMENT` + syarat hitung ulang pushed sandbox-new, GENERATE_OK, TRS = lokal, uji dummy T1/T2 LULUS. Belum ke DEV (oleh user), belum uji GUI ZQM004 |
| Dokumen | `outputs/uji_ncr_20261126/ANALISA_NCR_HILANG_DEV_20261126.md` |
| Backup | `outputs/ZQMI_BARRIER_PASS_FAIL_dev_TRD_20261126.abap` |

## Sebelumnya (19 Nov)
| Atribut | Isi |
|---|---|
| Waktu | 2026-11-19 |
| Pekerjaan | Re-apply guard NCR approval (v8) ke `ZQMI_BARRIER_PASS_FAIL` setelah sandbox ditimpa source dev terbaru (subcont 541/543 + FM `ZQM_GET_BATCH_CHANGE_GRADE`) |
| Alasan | Dev masih pakai `MODIFY ZLOG_BARRIER FROM WA_JUDGEMENT` (full row dari WA basi) di `INSERT_JUDGEMENT` & `GET_SHIPMENT`: approval NCR (form `APPROVAL`) bisa tertimpa kosong saat job/re-run berjalan bersamaan, dan batch Approved di-soft-delete + versi baru |
| Status | Pushed sandbox-new, GENERATE_OK, TRS = lokal. Uji RFC batch dummy LULUS (S1–S5), data asli tidak berubah: `outputs/uji_ncr_20261119/`. Belum uji GUI, belum ke DEV |
| Next step | Bawa guard ke DEV (oleh user) supaya tidak hilang lagi; opsional uji GUI ZQM004 layar NCR Approval |
| Backup | `outputs/ZQMI_BARRIER_PASS_FAIL_sandbox_new_TRS_20261119_from_dev.abap` |

## Sebelumnya
| Atribut | Isi |
|---|---|
| Waktu | 2026-11-05 |
| Pekerjaan | Analisa ZQM004 template Excel cuma kolom Value 1 (data NOT YET) |
| Status | Patched (3 baris `DOWNLOAD_EXCEL_PENDING`) & pushed sandbox-new via `Z_RFC_PROGRAM_UPDATE`, GENERATE_OK, source TRS diverifikasi = lokal |
| Next step | Uji GUI ZQM004 di TRS: data NOT YET cycle 3 → Template harus Value 1–3; upload balik. Lalu transport ke dev/QA |
| Dokumen | `docs/2026-11-05_ANALISA_ZQM004_TEMPLATE_KOLOM_VALUE.md` |
| Backup | `outputs/ZQMI_PENDING_BARRIER_sandbox_new_TRS_before_template_cycle_20261105.abap` |
