# 02 — Master Data, Tabel Kunci & TCODE SQL_OLAP

> Peta master data, tabel utama, dan transaksi standar untuk modul SQL_OLAP.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Ruang Lingkup Modul SQL_OLAP
Database Catalog, Star Schema & Cube Design, SQL Query Optimization, Execution Plan Profiling, Collation & Timezone Alignment, Read-Only Live Data Extraction.

---

## Tabel Kunci

| Objek Sistem / DMVs | Deskripsi | Penggunaan |
|---|---|---|
| `sys.tables` / `sys.columns` | Metadata Tabel & Kolom | Cek struktur tabel, tipe data, skema |
| `sys.views` / `sys.procedures` | Definisi View & Stored Procedure | Review logika view analitik dan SP ETL |
| `sys.dm_db_index_physical_stats` | Statistik Fragmentasi Index | Analisa performa dan kebutuhan rebuild/reorganize index |
| `sys.dm_exec_query_stats` | Statistik Eksekusi Query | Identifikasi query lambat (high CPU / I/O) |
| `sys.dm_exec_sql_text` | SQL Text dari Handle | Membaca statement SQL aktif / lambat |
| `sys.dm_tran_locks` | Lock & Blocker Active | Diagnosa deadlock / lock escalation pada database analitik |

---

## TCODE Standar SQL_OLAP

| Kategori | Tool / Perintah | Keterangan |
|---|---|---|
| Koneksi | `set_active_server` | Atur target server analitik / OLAP via MCP |
| Metadata | `list_tables` / `describe_table` | Eksplorasi schema database secara aman |
| Query | `run_query` / `run_parameterized_query` | Eksekusi query analitik (Read-Only) |
| Analisa | `explain_query` | Ambil Query Execution Plan |
| Profiling | `get_table_stats` | Cek row count, index fragmentation, data size |
