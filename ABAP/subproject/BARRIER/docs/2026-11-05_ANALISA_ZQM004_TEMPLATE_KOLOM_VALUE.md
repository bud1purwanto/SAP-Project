# Analisa — ZQM004 Template Excel hanya kolom Value 1

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-05 |
| Program | `ZQMI_PENDING_BARRIER` (TCODE ZQM004), form `DOWNLOAD_EXCEL_PENDING` |
| Source dianalisa | `src/ZQMI_PENDING_BARRIER.abap` (identik `outputs/ZQMI_PENDING_BARRIER_live_TRS.abap`) — SAP MCP down, belum re-fetch server |
| Status | AGREED → patched & pushed `sandbox-new` (TRS) 2026-11-05, GENERATE_OK. Backup: `outputs/ZQMI_PENDING_BARRIER_sandbox_new_TRS_before_template_cycle_20261105.abap` |

## Gejala
Pending Barrier, status NOT YET, CYCLE = 3. Tombol **Template** (fcode `XLSX`) → Excel cuma `Batch SR | Inspection Type | Value 1`. Harusnya Value 1..3 sesuai sampling procedure (CYCLE = STPRUMF).

## Root cause
ALV (fieldcat, ±baris 923–1052) tampilkan VALUEn pakai `LV_MAX_CYCLE` (max `CYCLE`).
Template (`DOWNLOAD_EXCEL_PENDING`, ±baris 3740–3757) tampilkan Value 2/3/4 **hanya jika ada data** (`VALUEn IS NOT INITIAL`).
Data NOT YET → semua value 0 → `LV_SHOW_V2/3/4` kosong → hanya Value 1.

## Patch usulan (minimal diff, 3 baris)
```abap
      IF WA_OUTPUT-VALUE2 IS NOT INITIAL OR WA_OUTPUT-CYCLE >= 2.
        LV_SHOW_V2 = 'X'.
      ENDIF.
      IF WA_OUTPUT-VALUE3 IS NOT INITIAL OR WA_OUTPUT-CYCLE >= 3.
        LV_SHOW_V3 = 'X'.
      ENDIF.
      IF WA_OUTPUT-VALUE4 IS NOT INITIAL OR WA_OUTPUT-CYCLE >= 4.
        LV_SHOW_V4 = 'X'.
      ENDIF.
```
Upload parser sudah baca posisi kolom 3–6 = Value 1–4 → tidak perlu diubah.
