# Subproject: BTP_HYBRID_INTEGRATION

**Judul:** SAP S/4HANA 1909 On-Premise to SAP BTP Hybrid Cloud Integration  
**Owner:** Baginda  
**Server Target:** Linux Remote `100.73.54.71` / `192.168.254.58`  
**ERP Target:** S/4HANA 1909 (SID: `ADB`, Client: `130`, Host: `192.168.1.199:8080`)  
**Status:** **100% Selesai & Terverifikasi**  

---

## Struktur Direktori Subproject

```text
/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/
├── README.md                               <-- File ini (Indeks Subproject)
├── docs/
│   ├── DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx <-- Dokumen Word Resmi Siap Share
│   ├── STEP_BY_STEP_IMPLEMENTATION_GUIDE.md <-- Panduan teknis lengkap & detail per-langkah
│   ├── EXECUTIVE_SUMMARY_PRESENTATION.md   <-- Format presentasi eksekutif & alur demo
│   └── attachments/                        <-- Arsip 29 screenshot bukti verifikasi integrasi
│       └── annotated/                      <-- 29 Screenshot Beranotasi Visual (Kotak Merah & Badge Aksi)
│       ├── 01_onprem_fiori_launchpad_login.png
│       ├── 02_scc_initial_dashboard.jpg
│       ├── 03_scc_subaccount_connected.png
│       ├── 04_scc_resources_mapping.png
│       ├── 05_btp_create_destination_scratch.png
│       ├── 06_btp_destination_check_success.jpg
│       ├── 07_bas_devspace_running.png
│       └── 08_bas_fiori_generator_destination.png
├── scripts/                                <-- Skrip Docker & deployment otomatisasi SCC
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── entrypoint.sh
├── src/                                    <-- Source code aplikasi UI5 / Fiori masa depan
└── outputs/                                <-- DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx (Versi 2.0 - 3.6 MB, 39 Screenshots Beranotasi)
```

## Ringkasan Konfigurasi Utama

| Komponen | Identitas / Nilai |
| :--- | :--- |
| **S/4HANA Endpoint** | `http://192.168.1.199:8080` (Client 130) |
| **SAP Cloud Connector** | Docker container di `https://100.73.54.71:8443` |
| **BTP Subaccount ID** | `4b0c5dbd-a7d7-4799-aaf2-08438302d5cd` |
| **BTP Region** | `cf.us10.hana.ondemand.com` (US East - AWS) |
| **Virtual Host** | `s4hana-onprem:8080` (Path: `/sap` with all sub-paths) |
| **BTP Destination** | `S4HANA_ONPREM` (`ProxyType=OnPremise`, `Auth=Basic`) |
| **BTP Dynamic Flag** | `HTML5.DynamicDestination = true` |
| **SAP BAS Dev Space** | `FioriDev` (SAP Fiori Template) |

---
*Dokumentasi ini dikelola secara terpusat di server remote sesuai aturan kerja SAP-Remote.*
