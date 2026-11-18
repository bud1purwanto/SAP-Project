# Checklist: Aplikasi Fiori Pertama (List Report PO Items) — BAS → BTP

**Service OData:** `ZMM_PUR_POITEMS_MONI_SRV` (versi 0001, aktif di ADB, dicek 2026-11-18)
**Destination:** `S4HANA_ONPREM` | **Dev space:** `FioriDev`
**Status:** Siap dikerjakan (langkah B manual di browser BAS)

> Jangan tulis password ke file ini. Password destination hanya disimpan di BTP Cockpit.

## 0. Prasyarat (cek sekali)
- [ ] Cloud Connector status Connected, mapping `/sap` aktif.
- [ ] Destination `S4HANA_ONPREM` → Check Connection sukses.
- [ ] Dev space `FioriDev` berstatus RUNNING.
- [ ] (Opsional) `$metadata` terbuka dengan login user uji:
      `http://192.168.1.199:8080/sap/opu/odata/sap/ZMM_PUR_POITEMS_MONI_SRV/$metadata?sap-client=130`
      Catat nama EntitySet utama: `____________`

## 1. Generate aplikasi di BAS
1. Buka `FioriDev` → **View → Command Palette → Fiori: Open Application Generator**.
2. Template: **List Report Page** → Next.
3. Data source: **Connect to a System** → pilih `S4HANA_ONPREM`.
4. Service: pilih `ZMM_PUR_POITEMS_MONI_SRV` (bila tidak muncul di katalog, lihat bagian Troubleshooting).
5. Entity: **Main entity** = EntitySet item PO; Navigation entity = None.
6. Project attributes:
   - Module name: `zpoitems` (huruf kecil, tanpa spasi)
   - Application title: `Monitor PO Items`
   - Namespace: `zbtp`
   - Add deployment configuration: **Yes** → Cloud Foundry
   - Add FLP configuration: **Yes** (Semantic Object `POItems`, Action `monitor`)
   - Use virtual endpoint untuk deploy: biarkan default
7. Finish, lalu tunggu `npm install` selesai.

## 2. Atur tabel List Report
- Buka **Application Info → Page Map → List Report**.
- Tambah kolom: PO, item, material, qty, plant (sesuai field di metadata).
- Tambah filter bar field: PO, plant, tanggal (bila ada).

## 3. Preview lokal
- Terminal BAS: `npm start` (atau Application Info → Preview Application).
- Pilih halaman `index.html` dengan `sap-client=130`.
- Verifikasi: tabel terisi data nyata dari ADB, filter dan sort jalan.
- Screenshot ke `docs/attachments/09_bas_list_report_preview.png`.

## 4. Siapkan service di BTP (sekali saja)
Di BTP Cockpit trial → Entitlements / Service Marketplace:
- [ ] **HTML5 Application Repository** plan `app-host` (+ `app-runtime` jika ada)
- [ ] **Destination** service plan `lite`
- [ ] **SAP Build Work Zone, standard edition** (subscription) — kalau quota habis, lewati dan akses lewat HTML5 Repository saja
- [ ] Role collection Work Zone (`Launchpad_Admin`) ditambahkan ke user

## 5. Deploy
1. Login CF dari terminal BAS:
   `cf login -a https://api.cf.us10.hana.ondemand.com` (pakai SSO / Universal ID)
2. Pilih org & space (biasanya `dev`).
3. Build & deploy:
   ```bash
   npm run build
   npm run deploy
   ```
   (script ini dibuat generator saat memilih deployment config; membangun MTAR lalu `cf deploy`)
4. Verifikasi: `cf apps` dan `cf html5-list` menampilkan `zpoitems`.

## 6. Tambah ke Launchpad (Work Zone)
1. Work Zone → **Channel Manager** → refresh **HTML5 Apps**.
2. **Content Manager** → New → App → pilih `zpoitems`, isi semantic object/action.
3. Buat Group + Role, assign ke user, lalu Site → Edit → tambah Role.
4. Buka URL site, pastikan tile muncul dan data tampil.

## 7. Selesai = dokumentasikan
- [ ] Update `CHECKPOINT.md` subproject dan `/data/Projects/SAP/ABAP/CHECKPOINT.md`.
- [ ] Simpan screenshot ke `docs/attachments/`.
- [ ] Source app ke `src/zpoitems/`.

## Troubleshooting
| Gejala | Penyebab / solusi |
|---|---|
| Service tidak muncul di wizard | Pastikan destination punya `HTML5.DynamicDestination=true`, `WebIDEUsage=odata_abap`; atau pilih "Enter service URL" dengan path `/sap/opu/odata/sap/ZMM_PUR_POITEMS_MONI_SRV` |
| 401 saat preview | Basic Auth di destination salah / user terkunci |
| 403 / "No authorization" | Otorisasi `S_SERVICE` / role user belum mencakup service |
| Data kosong di preview | Tambahkan `sap-client=130` (properti destination `sap-client`) |
| `cf deploy` gagal quota | Hapus app/service trial yang tidak dipakai di space |
| Work Zone tidak tersedia | Quota trial; gunakan akses via HTML5 Repository |
