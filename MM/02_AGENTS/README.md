# 02_AGENTS — Persona Agent Modul MM

Daftar spesialisasi agent yang dapat dipanggil untuk menangani analisa, QA, dan perancangan solusi pada modul MM.

> Aturan global di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/).

## Daftar Agent

| Agent | Deskripsi Peran | Mode Akses |
|---|---|---|
| [mm-consultant](mm-consultant.md) | Lead konsultan MM: analisa proses pengadaan, strategi inventory, integrasi OBYC. | Read-Only |
| [mm-analyst](mm-analyst.md) | Spesialis audit stok batch, selisih invoice (MIRO/MRBR), movement reversal (SMBLN). | Read-Only |
| [mm-reviewer](mm-reviewer.md) | Review kesesuaian master data, release strategy PO/PR, dan verifikasi guardrail. | Read-Only |

## Cara Pakai
Sebut nama agent atau file di awal perintah:
```
Ikuti 02_AGENTS/mm-consultant.md, lalu analisa kasus di subproject/<NAMA>/
```
