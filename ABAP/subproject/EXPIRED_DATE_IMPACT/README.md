# EXPIRED_DATE_IMPACT

Impact analysis ABAP untuk usulan perubahan perhitungan Expired Date / Best Used roll (email "FW: Ref. Roll number and best used", 24 Nov 2026).

## Isi folder

| Folder | Isi |
|---|---|
| `docs/` | `IMPACT_ANALYSIS_ABAP_20261124.md`: hasil analisis teknis |
| `outputs/` | `Impact_Expired_Date_ABAP_20261124.xlsx` (laporan untuk Alfa), `screenshots_20261124/`, hasil scan JSON |
| `src/dev_20261124/` | Source program dari DEV AIX yang dipindai (read-only) |
| `scripts/` | Script ambil source lewat gateway MCP SAP |

## Objek kunci

- Karakteristik batch `ZZEXPIREDLIVE` (umur simpan, hari)
- FM `Z_GET_PRODUCTION_DATE` (tanggal produksi = GR 101 non-reversal, fallback `MCH1-ERSDA`)
- Dispatcher label `ZMMR_LABELROL` + tabel `ZMAP_LABEL`
