path = 'CHECKPOINT.md'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

target = "| 2026-11-19 10:45 | Antigravity / Windows | BTP_HYBRID_INTEGRATION | Aplikasi Fiori zpoitems (List Report) sukses terhubung live end-to-end ke S/4HANA via SCC & OData berparameter (HTTP 200 OK) | Selesai | Opsi A (Input dummy PO di S/4HANA) & Opsi C (Deploy ke BTP Launchpad) |"

new_row = "| 2026-11-19 11:58 | Antigravity / Windows | BTP_HYBRID_INTEGRATION | Seeding 10 Data PO di S/4HANA (Client 130) via BAPI & ABAP; OData MM_PUR_POITEMS_MONI_SRV verified 10 records (HTTP 200 OK) | Selesai | Opsi C (Deploy aplikasi zpoitems ke BTP Launchpad / HTML5 Repository) |\n" + target

if target in content:
    content = content.replace(target, new_row)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Root CHECKPOINT.md updated successfully!")
else:
    print("Target not found in root CHECKPOINT.md!")
