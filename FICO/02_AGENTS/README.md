# 02_AGENTS — Persona Agent Modul FICO

Daftar spesialisasi agent yang dapat dipanggil untuk menangani analisa, QA, dan perancangan solusi pada modul FICO.

> Aturan global di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/).

## Daftar Agent

| Agent | Deskripsi Peran | Mode Akses |
|---|---|---|
| [fico-consultant](fico-consultant.md) | Lead konsultan FICO: closing keuangan, rekonsiliasi GL, tax DJP, CO-PA, dan costing. | Read-Only |
| [fico-analyst](fico-analyst.md) | Spesialis analisa jurnal (BKPF/BSEG), open items AP/AR, clearing, variance analysis, settlement. | Read-Only |
| [fico-reviewer](fico-reviewer.md) | Review akurasi tax code, withholding tax, chart of accounts, dan compliance. | Read-Only |

## Cara Pakai
Sebut nama agent atau file di awal perintah:
```
Ikuti 02_AGENTS/fico-consultant.md, lalu analisa kasus di subproject/<NAMA>/
```
