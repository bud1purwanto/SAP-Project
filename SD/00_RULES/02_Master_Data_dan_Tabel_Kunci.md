# 02 — Master Data, Tabel Kunci & TCODE SD

> Peta master data, tabel utama, dan transaksi standar untuk modul SD.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Ruang Lingkup Modul SD
Customer Master, Sales Order Processing (VA01), Pricing Procedure & Condition Technique, Outbound Delivery & Picking/PGI (VL01N), Billing & Invoicing (VF01), Credit Management, Document Flow (VBFA).

---

## Tabel Kunci

| Tabel | Deskripsi | Field Kunci |
|---|---|---|
| `VBAK` | Sales Document Header | VBELN, ERDAT, ERNAM, AUART, VKORG, VTWEG, SPART, KUNNR, NETWR, WAERS |
| `VBAP` | Sales Document Item | VBELN, POSNR, MATNR, CHARG, WERKS, LGORT, KWMENG, VRKME, NETPR, NETWR |
| `VBEP` | Sales Document Schedule Line | VBELN, POSNR, ETENR, EDATU, WMENG, BMENG |
| `LIKP` | Delivery Document Header | VBELN, ERDAT, LFART, VKORG, KUNNR, WADAT_IST (PGI date) |
| `LIPS` | Delivery Document Item | VBELN, POSNR, MATNR, CHARG, WERKS, LGORT, LFIMG, VRKME, VGBEL, VGPOS |
| `VBRK` | Billing Document Header | VBELN, FKART, FKDAT, BUKRS, VKORG, KUNRG, NETWR, MWSBK |
| `VBRP` | Billing Document Item | VBELN, POSNR, FKIMG, VRKME, NETWR, VGBEL, VGPOS, AUBEL, AUPOS |
| `VBFA` | Sales Document Flow (Relasi SO-DO-Billing) | VBELV, POSNV, VBELN, POSNN, VBTYP_N, VBTYP_V |
| `KONV` / `PRCD_ELEMENTS` | Conditions (Transaction Pricing Data) | KNUMV, KPOSN, STUNR, ZAEHK, KSCHL, KBETR, KWERT |
| `KNA1` / `KNVV` | Customer Master General Data / Sales Area Data | KUNNR, NAME1, LAND1, VKORG, VTWEG, SPART, KDGRP, WAERS |

---

## TCODE Standar SD

| Kategori | TCODE | Keterangan |
|---|---|---|
| Master Data | `XD01` / `XD02` / `XD03` | Create / Change / Display Customer Centrally |
| Master Data | `VK11` / `VK12` / `VK13` | Create / Change / Display Condition Records (Pricing) |
| Sales Order | `VA01` / `VA02` / `VA03` | Create / Change / Display Sales Order |
| Sales Order | `VA05` / `VA05N` | List of Sales Orders |
| Delivery | `VL01N` / `VL02N` / `VL03N` | Create / Change / Display Outbound Delivery |
| Delivery | `VL06O` | Outbound Delivery Monitor |
| Billing | `VF01` / `VF02` / `VF03` | Create / Change / Display Billing Document |
| Billing | `VF04` | Billing Due List |
| Document Flow | `VA03` -> Environment -> Flow | Alur Dokumen Sales |
| Credit | `VKM1` / `VKM3` | Blocked SD Documents / Sales Orders |
