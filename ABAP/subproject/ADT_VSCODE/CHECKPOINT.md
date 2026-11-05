# CHECKPOINT — ADT_VSCODE (ICF `/sap/bc/adt` + ICM 8000)

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-05 |
| Status | Setup sandbox-new selesai; proxy belum jalan permanen |
| Server source terakhir | sandbox-new (192.168.6.243 client 130, SY-SYSID TRD) |
| Jumlah baris source | — |
| Backup terakhir | `outputs/before_apply_*.json`, `outputs/vscode_machine_settings_before_20261105.json` |

## Log Sesi (terbaru di atas, wajib — lihat [08](../../00_RULES/08_Checkpoint_Wajib.md))
| Waktu | AI / device | Pekerjaan | Status | Next step |
|---|---|---|---|---|
| 2026-11-05 | Claude / VSCode remote | Aktifkan ICF ADT + ICM HTTP 8000 di sandbox-new, proxy X-Requested-With, install ext ABAP FS, setting `abapfs.remote.TRS` | Menunggu Baginda | Jalankan proxy (systemd) lalu connect di VSCode |

## 1. Yang Sudah Selesai
- Analisa: SAP_BASIS 731 SP0004, package `SADT_*` ada, ICF ADT tadinya non-aktif, ICM HTTP port 0 (tidak listen).
- `HTTP_ACTIVATE_NODE` URL `/sap/bc/adt/` → `ICFACTIVE = X`.
- `ICM_CHANGE_SERV` ACTION 21 → service HTTP 8000 aktif (`ICM_SUBRC 0`).
- Tes `abap-adt-api` 9.2.0 via proxy: login, search, objectStructure, source, nodeContents `$TMP`, lock/unlock `ZQMI_COA`, syntaxCheck, codeCompletion, inactiveObjects → OK.
- Tanpa proxy: semua POST (lock, nodeContents) → 403.
- Extension `murbani.vscode-abap-remote-fs` 2.13.1 terpasang (ikut `larshp.vscode-abap`, `hudakf.cds`).
- `~/.vscode-server/data/Machine/settings.json`: `abapfs.remote.TRS` → `http://127.0.0.1:8100`, user TRSTDEV, client 130 (password diminta saat connect).

## 2. Perubahan Terakhir
| Tanggal | Perubahan | Objek / FORM | Bukti (push / test) |
|---|---|---|---|
| 2026-11-05 | Aktifkan ICF | `/sap/bc/adt` | `outputs/result_apply_*.json` |
| 2026-11-05 | ICM service dinamis | HTTP 8000 | `outputs/result_apply_*.json`, curl 401 → 200 dengan login |

## 3. Keputusan Baginda
| Tanggal | Keputusan |
|---|---|
| 2026-11-05 | Pilih Opsi A (ADT asli di VSCode), setup di sandbox-new |

## 4. Masih Terbuka / Next Step
- [ ] Enable proxy permanen: `systemctl --user enable --now` unit `scripts/adt-proxy-trs.service` (ditolak permission mode agent → Baginda jalankan).
- [ ] Basis: profil `RZ10` `icm/server_port_<n> = PROT=HTTP,PORT=8000` agar port tidak hilang saat restart.
- [ ] Uji edit + save + activate program `$TMP` dari VSCode.

## 5. Risiko / Catatan
- Port 8000 HTTP plain (tanpa TLS); password Basic Auth lewat LAN. Proxy hanya listen `127.0.0.1`.
- Fitur ADT SP4 terbatas: tidak ada `checkruns` (ATC/check run baru), logout endpoint 403. Debugger belum diuji.
