# ADT_VSCODE — Buka program SAP langsung di VSCode via ADT

| Atribut | Isi |
|---|---|
| Program utama | — (konfigurasi sistem: ICF `/sap/bc/adt`, ICM HTTP 8000) |
| TCODE | `SICF`, `SMICM`, `RZ10` |
| Modul | ABAP / Basis |
| Server analisa | dev-aix, sandbox-new |
| Server write | `sandbox-new` (host 192.168.6.243, client 130; `SY-SYSID` aktual = `TRD`) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| Terakhir diperbarui | 2026-11-05 |

## 1. Tujuan

Buka, edit, simpan, dan aktivasi program ABAP sandbox-new langsung dari VSCode seperti Eclipse ADT,
memakai extension `murbani.vscode-abap-remote-fs`.

## 2. Isi Folder

| Folder | Isi |
|---|---|
| `scripts/setup_adt_trs.mjs` | `status` / `apply` / `rollback` ICF `/sap/bc/adt` + ICM HTTP 8000 (guard sandbox-new) |
| `scripts/adt_proxy.mjs` | Proxy lokal `127.0.0.1:8100 -> 192.168.6.243:8000`, sisip header `X-Requested-With` |
| `scripts/adt-proxy-trs.service` | Unit systemd user untuk proxy (belum di-enable) |
| `outputs/` | Snapshot before/after setup, backup `settings.json` VSCode |

## 3. Arsitektur

```
VSCode (ABAP FS ext) --> 127.0.0.1:8100 adt_proxy.mjs (+X-Requested-With)
                     --> 192.168.6.243:8000 ICM HTTP --> ICF /sap/bc/adt (CL_ADT_WB_RES_APP)
```

Kenapa butuh proxy: `CL_REST_HTTP_HANDLER` di SAP_BASIS 731 SP4 memakai proteksi CSRF lama —
POST/PUT/DELETE tanpa header `X-Requested-With` dijawab `403` body kosong. Server **tidak** mengeluarkan
`x-csrf-token`. Extension VSCode tidak mengirim header itu dan tidak punya opsi custom header.

## 4. Aturan Khusus Sub-Project

- Koneksi VSCode hanya ke sandbox-new. Jangan tambah koneksi dev/QA/prod untuk write (aturan emas #1).
- Port ICM 8000 dibuat **dinamis** (SMICM). Hilang saat SAP/ICM restart. Permanen: Basis set profil
  `icm/server_port_<n> = PROT=HTTP,PORT=8000` di `RZ10`.
- Rollback: `node scripts/setup_adt_trs.mjs rollback`.

## 5. Objek SAP Terkait

| Objek | Jenis | Keterangan |
|---|---|---|
| `/default_host/sap/bc/adt` | ICF node | Diaktifkan 2026-11-05 (`HTTP_ACTIVATE_NODE`) |
| ICM service HTTP 8000 | ICM (dinamis) | Dibuat via `ICM_CHANGE_SERV` ACTION 21 |
| `CL_ADT_WB_RES_APP` | Class (handler ICF) | Standar, tidak diubah |
| `CL_REST_HTTP_HANDLER` | Class | Standar, cek `X-Requested-With` |
