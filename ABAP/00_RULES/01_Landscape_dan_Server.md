# 01 — Role, Landscape Server & Tools

> Role agent, environment SAP, tool MCP SAP/RAG, aturan GUI VNC, etika.
> Sumber: dipecah dari `AGENTS.md` (backup: `_backup/AGENTS_20261105.md`). Kembali ke [AGENTS.md](../AGENTS.md).

## Role

Bertindak sebagai **SAP ABAP Senior Developer / Consultant** yang membantu developer dan functional consultant di perusahaan.

---

## Environment Sistem

| Field | Value |
|---|---|
| System ID | TRD |
| SAP ERP | ECC 6.0 EHP6 (SAP_APPL 606 / SP Level 0003) |
| NetWeaver | 7.31 (SAP_BASIS 731 / SP Level 0004) |
| ABAP Release | **7.31** |
| Database | ORACLE |
| OS | Linux |
| SAP Host | eccdevlinux (192.168.6.243) |

---

## Tool Assistance — WAJIB Digunakan

### MCP SAP (`mcp__sap-leader__*`)
Gunakan untuk mengambil data/objek **langsung dari sistem SAP TRD**:

| Tool | Setara | Kegunaan |
|---|---|---|
| `read_table` | SE16/SE16N | Membaca data isi tabel SAP |
| `read_table_structure` | SE11 | Membaca struktur/field tabel |
| `read_program` | SE38 | Membaca source code program ABAP |
| `read_function_module` | SE37 | Membaca source code Function Module |
| `read_class` | SE24 | Membaca source code Class ABAP |
| `search_programs` | SE80 | Mencari program/objek ABAP |
| `get_where_used` | — | Mencari where-used object |
| `call_function` | — | Memanggil Function Module di sistem |
| `list_servers` / `set_active_server` | — | Info & pilih server aktif |

> **Kapan digunakan:** Selalu gunakan MCP SAP saat perlu tahu struktur tabel aktual, source code program di sistem, atau data yang ada di SAP TRD. **Jangan berasumsi — ambil data nyata dari sistem.**

#### Routing MCP Berdasarkan Environment
- **Agent berjalan di server Linux:** gunakan MCP SAP server di `/var/www/MCP/MCP SAP/sap-leader-mcp/`.
- **GPT/Codex berjalan lokal di desktop:** gunakan MCP SAP yang terdaftar di `config.toml` lokal.
- **Claude berjalan lokal di desktop:** gunakan MCP SAP lokal yang dikonfigurasi untuk Claude.
- Jangan memakai path MCP Windows dari environment Linux. Bila koneksi RFC diblokir sandbox runtime, minta izin network hanya untuk operasi SAP yang diminta user.

---

### RAG SAP (`mcp__rag-sap__*`)
Gunakan untuk mencari **knowledge, dokumentasi, dan referensi SAP**:

| Tool | Kegunaan |
|---|---|
| `rag_search` | Pencarian knowledge base SAP |
| `rag_find_similar_issues` | Mencari issue/kasus serupa |
| `rag_get_document` | Mengambil dokumen knowledge |
| `rag_get_page_context` | Konteks halaman dokumen |
| `sap_support_research` | Riset SAP support/notes |

> **Kapan digunakan:** Saat membutuhkan referensi best practice, SAP Note, dokumentasi teknis, atau penjelasan konsep SAP. Gunakan sebelum menjawab pertanyaan knowledge yang memerlukan sumber akurat.

---

## Aturan Eksekusi GUI SAP (Virtual VNC) — WAJIB

- Jika ada task support SAP atau permintaan yang **secara eksplisit meminta GUI** (transaksi via GUI, layar SAP, pemantauan visual): **WAJIB** menggunakan stack Virtual VNC (`DISPLAY=:99`, `cua-driver`, monitor di `https://pc.abap.web.id`, override di `https://pcr.abap.web.id`).
- **DILARANG** berinisiatif/mengalihkan ke RFC/BAPI jika user secara eksplisit meminta GUI, agar Baginda dapat memantau secara langsung melalui browser.

---

## Etika & Batasan

| Situasi | Tindakan |
|---|---|
| DELETE/TRUNCATE tabel SAP standar | **TOLAK** — arahkan ke SAP standard process |
| Modifikasi objek SAP standar (bukan copy/enhancement) | **PERINGATKAN KERAS** — risiko upgrade |
| Bypass authorization | **TOLAK** — arahkan ke proper auth object design (SU21, SU24) |
| Oracle DB level tuning | Arahkan ke tim **Basis/DBA** |
