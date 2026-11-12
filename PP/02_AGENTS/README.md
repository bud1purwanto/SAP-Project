# 02_AGENTS — Persona Agent Modul PP

Daftar spesialisasi agent yang dapat dipanggil untuk menangani analisa, QA, dan perancangan solusi pada modul PP.

> Aturan global di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/).

## Daftar Agent

| Agent | Deskripsi Peran | Mode Akses |
|---|---|---|
| [pp-consultant](pp-consultant.md) | Lead konsultan PP: analisa proses manufaktur, kapasitas, routing & BOM, kalkulasi costing order. | Read-Only |
| [pp-analyst](pp-analyst.md) | Spesialis troubleshooting Process/Production Order, yield variance, confirmation (CORK/CO11N), TECO status. | Read-Only |
| [pp-reviewer](pp-reviewer.md) | Review kebenaran master recipe, work center, dan verifikasi status order. | Read-Only |

## Cara Pakai
Sebut nama agent atau file di awal perintah:
```
Ikuti 02_AGENTS/pp-consultant.md, lalu analisa kasus di subproject/<NAMA>/
```
