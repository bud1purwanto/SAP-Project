import re

with open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/STEP_BY_STEP_IMPLEMENTATION_GUIDE.md", "r", encoding="utf-8") as f:
    text = f.read()

matches = re.findall(r'!\[(.*?)\]\((.*?)\)', text)
print(f"Total images referenced in STEP_BY_STEP: {len(matches)}")
for alt, path in matches:
    print(f"Alt: {alt:50} | Path: {path}")
