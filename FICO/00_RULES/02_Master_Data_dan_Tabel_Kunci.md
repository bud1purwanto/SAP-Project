# 02 — Master Data, Tabel Kunci & TCODE FICO

> Peta master data, tabel utama, dan transaksi standar untuk modul FICO.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Ruang Lingkup Modul FICO
General Ledger (GL), Accounts Payable (AP), Accounts Receivable (AR), Asset Accounting (AA), Cost Center Accounting (CO-OM-CCA), Profit Center Accounting (PCA), Tax Faktur Pajak DJP, Period End Closing.

---

## Tabel Kunci

| Tabel | Deskripsi | Field Kunci |
|---|---|---|
| `BKPF` | Accounting Document Header | BUKRS, BELNR, GJAHR, BLART, BLDAT, BUDAT, MONAT, USNAM, WAERS, XBLNR |
| `BSEG` | Accounting Document Segment (Item) | BUKRS, BELNR, GJAHR, BUZEI, BSCHL, KOART, SHKZG, GSBER, MWSKZ, DMBTR, WRBTR, SGTXT, HKONT, KUNNR, LIFNR, KOSTL, AUFNR |
| `SKA1` / `SKB1` | G/L Account Master (Chart of Accounts / Company Code) | KTOPL, SAKNR, BUKRS, WAERS, XOPVW (Open item mgmt) |
| `BSIS` / `BSAS` | Open Items / Cleared Items for G/L Accounts | BUKRS, HKONT, AUGDT, AUGBL, BELNR, GJAHR, DMBTR |
| `BSIK` / `BSAK` | Open Items / Cleared Items for Vendors (AP) | BUKRS, LIFNR, AUGDT, AUGBL, BELNR, GJAHR, DMBTR |
| `BSID` / `BSAD` | Open Items / Cleared Items for Customers (AR) | BUKRS, KUNNR, AUGDT, AUGBL, BELNR, GJAHR, DMBTR |
| `CSKS` / `CSKT` | Cost Center Master Data / Text | KOKRS, KOSTL, DATBI, KTEXT, VERAK |
| `CEPC` / `CEPCT` | Profit Center Master Data / Text | KOKRS, PRCTR, DATBI, KTEXT |
| `ANLA` / `ANLP` | Asset Master Record Segment / Asset Periodic Values | BUKRS, ANLN1, ANLN2, AKTIV, GJAHR, AFABE, NAFAQ |
| `BSET` | Tax Data Document Segment | BUKRS, BELNR, GJAHR, BUZEI, MWSKZ, HWBAS, FWSTE, HWSTE |

---

## TCODE Standar FICO

| Kategori | TCODE | Keterangan |
|---|---|---|
| Master Data | `FS00` | G/L Account Master Centrally |
| Master Data | `KS01` / `KS03` | Create / Display Cost Center |
| Master Data | `AS01` / `AS03` | Create / Display Asset Master |
| Document Entry | `FB01` / `FB50` / `F-02` | Post Accounting Document / G/L Account Document |
| Document Display | `FB03` | Display Accounting Document |
| Reporting | `FBL1N` / `FBL3N` / `FBL5N` | Vendor / G/L / Customer Line Items |
| Clearing | `F-32` / `F-44` / `F-03` | Clear Customer / Vendor / G/L Account |
| Closing | `FAGLB03` | G/L Account Balance Display |
| Asset | `AW01N` | Asset Explorer |
