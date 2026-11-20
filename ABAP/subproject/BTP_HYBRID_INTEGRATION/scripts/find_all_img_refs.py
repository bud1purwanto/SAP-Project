import os, re

docs_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs"
for root, dirs, files in os.walk(docs_dir):
    for fname in files:
        if fname.endswith(".md"):
            p = os.path.join(root, fname)
            with open(p, "r", encoding="utf-8") as f:
                content = f.read()
            matches = re.findall(r'!\[(.*?)\]\((.*?)\)', content)
            if matches:
                print(f"=== {p} ({len(matches)} images) ===")
                for alt, path in matches:
                    print(f"  {alt} -> {path}")
