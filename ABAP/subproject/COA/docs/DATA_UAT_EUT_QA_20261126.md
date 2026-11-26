# Data UAT & EUT COA (ZQM002 / ZQMI_COA) di QA (TRQ Client 320)

- **Tanggal Pembuatan:** 2026-11-26
- **Sistem Target:** SAP QA (`TRQ`, Client `320`, Host `192.168.2.7`)
- **Metode Eksekusi:** 100% via RFC/BAPI (`BAPI_BATCH_CREATE`, `BAPI_OBJCL_CREATE`, `BAPI_OBJCL_CHANGE`, `BAPI_GOODSMVT_CREATE`, `BAPI_SALESORDER_CREATEFROMDAT2`, `BAPI_OUTB_DELIVERY_CREATE_SLS`, `BAPI_OUTB_DELIVERY_CHANGE`) melalui `prepare_sap_transaction` + `execute_sap_transaction`.
- **Referensi Sumber:** Excel `00_Data.xlsx` (sheet `Film Makking` & `BF - CONV`) + Skenario Testing COA DEV AIX.

---

## 1. Ringkasan Capaian di QA (`TRQ 320`)

| Komponen | Jumlah | Nomor / Detail Terverifikasi di Database QA |
|---|---|---|
| Sales Order (`VBAK`) | **18 SO** | `0000015855` s/d `0000015872` (`BSTNK` berawalan `UAT-COA-*`) |
| Outbound Delivery (`LIKP`/`LIPS`) | **18 DO** (52 item `LIPS`) | `0085051549` s/d `0085051583` (seluruh batch split `900001`/`900002` terisi) |
| Batch Baru + Klasifikasi (`MCH1`) | **2 Batch** | `SRVC2I 0003885919` (`ZZSRCPP`, `ZZGRADE=9P`), `SREASI 0003885920` (`ZZSRMETZ`, `ZZGRADE=9P`) |
| Material Document `309` Change Grade (`MSEG`) | **2 MatDoc** | `4903968712` (`SRVC2I 0003884850 -> 0003885919`, 100 KG), `4903968713` (`SREASI 0003885202 -> 0003885920`, 200 KG) |
| Klasifikasi `ZZALIAS` (`AUSP`, `ATINN=0000000844`) | **4 Batch** | `SRAABI 0003885659/5660/5661` = `PLE-22`; `SRAAAI 0003871415` = `PLE-18` |

---

## 2. Daftar Lengkap 18 Skenario SO & DO di QA (`TRQ 320`)

| No | Skenario | Type | Customer | SO (`VBAK`) | DO (`LIKP`) | Material | Plant/SLoc | Batch Split (`LIPS`) | Qty (KG) | Catatan / Lot Genealogy |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `L-QM01` | `ZDOR` | `1141000004` | `0000015857` | `0085051555` | `SRCADI` | `2000/2306` | `0003817915`, `0003817916` | 703.160 | Single-level BOPP (`351.58` x 2) |
| 2 | `L-QM02` | `ZEOR` | `1800000002` | `0000015856` | `0085051551` | `SRAABI` | `2000/2302` | `0003885650`, `0003885651` | 480.480 | Export `ZEOR`, `JRAABI 3885614` (`040000140841`, `UD=X`) |
| 3 | `L-QM03` | `ZDOR` | `1141000026` | `0000015858` | `0085051556` | `SRGIDI` | `2000/2310` | `0003885074`, `0003885075` | 1,062.440 | `JRGIDI` `100000778545` (`UD=X`) <- `SRALZI` <- `JRALZI` |
| 4 | `L-QM04` | `ZDOR` | `1141000488` | `0000015859` | `0085051557` | `SREWEI` | `2000/2310` | `0003885060`, `0003885122` | 362.880 | `JREWEI` `100000778544` (`UD=X`) <- `SRCGAI` <- `JRCGAI` |
| 5 | `L-QM05/06` | `ZDOR` | `1141000494` | `0000015860` | `0085051562` | `SRVC2I` | `2000/2312` | `0003884850` (orig), **`0003885919`** (`309`) | 200.000 | Change Grade `309` (`4903968712`), `JRVC2I` `100000778538` (`UD=X`) |
| 6 | `L-QM07/08` | `ZDOR` | `1141000516` | `0000015861` | `0085051563` | `SREASI` | `2000/2310` | `0003885202` (orig), **`0003885920`** (`309`) | 400.000 | Change Grade `309` (`4903968713`), `JREASI` `100000778549` (`UD=X`) |
| 7 | `L-QM09` | `ZDOR` | `1141000004` | `0000015855` | `0085051549` | `SRAABI` | `2000/2302` | `0003885641`, `0003885642` | 480.480 | Domestic `ZDOR`, `JRAABI 3885613` (`040000140840`, `UD=X`) |
| 8 | `L-QM10` | `ZDOR` | `1141000004` | `0000015864` | `0085051570` | `SRGJBI` | `2000/2310` | `0003758344`, `0003758354` | 768.740 | Existing QA stock (`384.37` x 2) |
| 9 | `ML-QM01` | `ZDOR` | `1141000131` | `0000015862` | `0085051564` | `SRIA5I` | `2000/2314` | `0003885336`, `0003885337` | 135.120 | 4-stage `JRIA5I` `100000778553` (`UD=X`) <- `SRAKSI` <- `JRAKSI` |
| 10 | `ML-QM02` | `ZDOR` | `1141000265` | `0000015863` | `0085051565` | `SRACBI` | `2000/2302` | `0003885788` (`HSB4-18`), `0003885800` (`HSB-18`) | 609.000 | `JRACBI 3885607/5609` (`040000140834/836`, `UD=X`) |
| 11 | `ML-QM03` | `ZDOR` | `1141000004` | `0000015865` | `0085051571` | `SRGLAI` | `2000/2310` | `0003885234`, `0003885235` | 1,113.840 | 6-stage `JRGLAI` `100000778551` (`UD=X`) <- `SRGKAI` <- `JRGKAI` <- `SRAH8I` <- `JRAH8I` |
| 12 | `ML-QM04` | `ZDOR` | `1141000026` | `0000015866` | `0085051572` | `SRVLCX` | `2000/2804` | `0003883090`, `0003883091` | 1,277.640 | Stock `SRVLCX` (`638.82` x 2) |
| 13 | `AL-STRUKTUR` | `ZDOR` | `1141000004` | `0000015867` | `0085051573` | `SRAABI` | `2000/2302` | `0003885659` (`PLE-22`), `0003885660` (`PLE-22`) | 240.240 | 2 batch dengan `ZZALIAS` identik (`PLE-22`) |
| 14 | `AL-MIXED` | `ZDOR` | `1141000004` | `0000015868` | `0085051577` | `SRAABI` | `2000/2302` | `0003885661` (`PLE-22`), `0003885662` (kosong) | 480.480 | Campuran batch ber-alias & tanpa alias |
| 15 | `AL-VALUE2` | `ZDOR` | `1141000004` | `0000015871` | `0085051582` | `SRAABI` + `SRAAAI` | `2000/2302`, `2000/2326` | `0003885659` (`PLE-22`), `0003871415` (`PLE-18`) | 268.520 | 2 material, 2 nilai `ZZALIAS` berbeda dalam 1 DO |
| 16 | `TTA-Z3` | `ZEOR` | `1800000002` | `0000015872` | `0085051583` | `SRCBUX` | `2000/2804` | `9003874855` (`ZZPRODLINE=Z3`) | 185.470 | Outsource TTA2 -> Plant 2000 (`Z3 SEF 010 001 9C 01 05`) |
| 17 | `TTA-CONV` | `ZDOR` | `1141000004` | `0000015869` | `0085051578` | `SREYAI` | `2000/2062` | `0003203767` (`Z04`, `STAT35=X`) | 990.570 | Converting `SREYAI` dengan inspection lot `Z04` `UD=X` |
| 18 | `SRWCNI` | `ZDOR` | `1141000004` | `0000015870` | `0085051579` | `SRWCNI` | `1000/1813` | `0003879068` (`L16000000004`) | 880.760 | Plant 1000 (`1813`) |

---

## 3. Gap & Prasyarat Sebelum Eksekusi UAT/EUT di QA (`TRQ 320`)

1. **Transport Program & Objek COA Belum Masuk QA:**
   - TCode `ZQM002` di QA saat ini masih menunjuk ke program lama `ZQMI_CERTIFICATE`.
   - Objek `ZQMI_COA`, `ZMAP_COA`, dan `ZLOG_COA` **belum ada** di QA (`ZTMAP_COA` sudah ada). Perlu import Transport Request dari DEV AIX ke QA terlebih dahulu.
2. **Material Master `JRGLBI` Terblokir (`ML-QM03` Stage 7):**
   - `BAPI_PROCORD_CREATE` untuk `JRGLBI` (`Plant 2000`, `ZP03`, `VERID 0001`) ditolak SAP dengan `E CO 050: In-house production is not intended for material JRGLBI status Block for Transaction`.
   - Solusi sementara: DO `0085051571` sudah disiapkan pada level 6-stage `SRGLAI` (`100000778551`). Jika Stage 7 (`JRGLBI` -> `SRGLBI`) wajib diuji, unblock material `JRGLBI` di `MM02` lalu buat Process Order + hasil inspeksi `QE51N`.
3. **Stok `SRCZEI` di Plant `TTA2` Kosong:**
   - Tabel `MCHB` untuk `SRCZEI` pada `WERKS='TTA2'` bernilai 0 row di QA. Skenario TTA sudah dicakup oleh `0085051583` (`SRCBUX` `Z3`) dan `0085051578` (`SREYAI`).
4. **Input Hasil Inspeksi (`QE51N` / `QA01`):**
   - `BAPI_INSPOPER_RECORDRESULTS` dan `ABAP4_CALL_TRANSACTION` diblokir oleh allowlist MCP Gateway; seluruh batch di atas menggunakan batch QA eksisting yang sudah memiliki inspection lot `UD=X` atau hasil inspeksi yang sudah ada di QA.
5. **Customer Master `1141000514` & `1141000517`:**
   - Tidak di-maintain untuk Sales Area `1000/01/00` di QA (`E VP 197`), sehingga skenario terkait menggunakan customer QA yang aktif di `1000/01/00` (`1141000004`, `1141000026`, `1141000488`, `1141000494`, `1141000516`, `1141000131`, `1141000265`).
