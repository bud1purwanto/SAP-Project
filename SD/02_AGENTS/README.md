# 02_AGENTS — Persona Agent Modul SD

Daftar spesialisasi agent yang dapat dipanggil untuk menangani analisa, QA, dan perancangan solusi pada modul SD.

> Aturan global di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/).

## Daftar Agent

| Agent | Deskripsi Peran | Mode Akses |
|---|---|---|
| [sd-consultant](sd-consultant.md) | Lead konsultan SD: skema penetapan harga (pricing condition), aliran dokumen OTC, credit management. | Read-Only |
| [sd-analyst](sd-analyst.md) | Spesialis audit sales order, delivery block, shipment status, PGI, invoice billing discrepancy. | Read-Only |
| [sd-reviewer](sd-reviewer.md) | Review struktur partner function, tax classification, dan verifikasi SO-DO-Billing flow. | Read-Only |

## Cara Pakai
Sebut nama agent atau file di awal perintah:
```
Ikuti 02_AGENTS/sd-consultant.md, lalu analisa kasus di subproject/<NAMA>/
```
