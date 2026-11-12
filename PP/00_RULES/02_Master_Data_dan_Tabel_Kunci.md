# 02 — Master Data, Tabel Kunci & TCODE PP

> Peta master data, tabel utama, dan transaksi standar untuk modul PP.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Ruang Lingkup Modul PP
Master Data BOM/Routing/Work Center/Master Recipe, Planned Order & MRP (MD04), Production/Process Order (COR1/CO01), Confirmation (CORK/CO11N), TECO / Closing, Backflush GI (261) & GR (101).

---

## Tabel Kunci

| Tabel | Deskripsi | Field Kunci |
|---|---|---|
| `AUFK` | Order Master Data | AUFNR, AUFART, AUTYP, KTEXT, BUKRS, WERKS |
| `AFKO` / `AFPO` | Order Header Data PP / Order Item | AUFNR, GLTRP, GSTRP, FTRMS, GAMNG, GMEIN, MATNR, CHARG, WEMNG, PSMNG |
| `RESB` | Reservation / Order Dependent Requirements (Komponen) | RSNUM, RSPOS, RSART, BDART, MATNR, WERKS, LGORT, BDMNG, ENMNG, SHKZG |
| `AFVC` / `AFVV` | Order Operations / Operation Quantities & Dates | AUFPL, APLZL, VORNR, ARBID, LTXA1, BMSCH, MEINH |
| `AFRU` | Order Confirmations | RUECK, RMZHL, AUFNR, VORNR, LMNGA, XMNGA, ISM01-ISM06, BUDAT, STOKZ, STZHL |
| `CRHD` | Work Center Header | OBJTY, OBJID, ARBPL, WERKS, VERWE, KTEXT |
| `PLKO` / `PLPO` | Routing Header / Operation | PLNTY, PLNNR, PLNAL, ZAEHL, VORNR, STEUS, ARBID, LTXA1 |
| `MAST` / `STKO` / `STPO` | Material to BOM / BOM Header / BOM Item | MATNR, WERKS, STLAN, STLNR, STLAL, IDNRK, MENGE, MEINS |
| `JEST` / `TJ02T` | Individual Object Status / Status Text | OBJNR, STAT, INACT, TXT04, TXT30 |
| `PLAF` | Planned Order (MRP Output) | PLNUM, MATNR, WERKS, PLWRK, GSMNG, PEDTR, PERTR |

---

## TCODE Standar PP

| Kategori | TCODE | Keterangan |
|---|---|---|
| Master Data | `CS01` / `CS02` / `CS03` | Create / Change / Display Material BOM |
| Master Data | `CA01` / `CA02` / `CA03` | Create / Change / Display Routing |
| Master Data | `CR01` / `CR02` / `CR03` | Create / Change / Display Work Center |
| Master Data | `C201` / `C202` / `C203` | Create / Change / Display Master Recipe (PP-PI) |
| Order Processing | `CO01` / `CO02` / `CO03` | Production Order (Discrete) |
| Order Processing | `COR1` / `COR2` / `COR3` | Process Order (PP-PI) |
| Order Processing | `COOIS` / `COOISPI` | Production Order Information System |
| Shop Floor | `CO11N` / `CO15` | Confirmation Production Order |
| Shop Floor | `CORK` / `CORS` | Confirmation Process Order (PP-PI) / Cancel |
| MRP | `MD04` / `MD02` | Stock/Requirements List / Single-Item MRP Run |
| Status / Closing | `CO02` / `COR2` | Technical Completion (TECO) / Close (CLSD) |
