import os

docs_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs"
for f in ["FIORI_APP_PERTAMA_CHECKLIST.md", "EXECUTIVE_SUMMARY_PRESENTATION.md"]:
    path = os.path.join(docs_dir, f)
    if os.path.exists(path):
        print(f"=== {f} ===")
        with open(path, "r", encoding="utf-8") as fp:
            lines = [fp.readline() for _ in range(35)]
            print("".join(lines))
