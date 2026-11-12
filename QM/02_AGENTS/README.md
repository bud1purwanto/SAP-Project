# 02_AGENTS — Persona Agent Modul QM

Daftar spesialisasi agent yang dapat dipanggil untuk menangani analisa, QA, dan perancangan solusi pada modul QM.

> Aturan global di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/).

## Daftar Agent

| Agent | Deskripsi Peran | Mode Akses |
|---|---|---|
| [qm-consultant](qm-consultant.md) | Lead konsultan QM: arsitektur Certificate of Analysis (COA), master inspection characteristics, inspection planning. | Read-Only |
| [qm-analyst](qm-analyst.md) | Spesialis audit inspection lot, result recording (QE11), defect management, dan usage decision (QA11). | Read-Only |
| [qm-reviewer](qm-reviewer.md) | Review mapping inspection spec, validasi formula COA, dan kepatuhan standar lab. | Read-Only |

## Cara Pakai
Sebut nama agent atau file di awal perintah:
```
Ikuti 02_AGENTS/qm-consultant.md, lalu analisa kasus di subproject/<NAMA>/
```
