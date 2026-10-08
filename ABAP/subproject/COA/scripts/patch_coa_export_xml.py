from lxml import etree
from pathlib import Path


root_dir = Path(__file__).resolve().parent.parent
source = root_dir / "outputs" / "ZQMF_COA_EXPORT_candidate.xml"
target = root_dir / "outputs" / "ZQMF_COA_EXPORT_header_candidate.xml"
parser = etree.XMLParser(remove_blank_text=False)
tree = etree.parse(str(source), parser)
ns = {"i": "urn:sap-com:sdixml-ifr:2000", "s": "urn:sap-com:SmartForms:2000:internal-structure"}
ifr = "{urn:sap-com:sdixml-ifr:2000}"

text_map = {
    "<H1>Customer</>": "<H1>&H_LABEL1&</>",
    "<H1>Delivery Number</>": "<H1>&H_LABEL2&</>",
    "<H1>Product</>": "<H1>&H_LABEL3&</>",
    "<H1>Quantity</>": "<H1>&H_LABEL4&</>",
    "<H1>Width</>": "<H1>&H_LABEL5&</>",
    "<H1>: &QUANTITY(C)& kg</>": "<H1>: &QUANTITY(C)&</>",
    "<H1>: &WIDTH(C)& mm</>": "<H1>: &WIDTH(C)&</>",
}
counts = {key: 0 for key in text_map}
for node in tree.xpath("//i:TDLINE", namespaces=ns):
    if node.text in text_map:
        counts[node.text] += 1
        node.text = text_map[node.text]
if any(count == 0 for count in counts.values()):
    raise RuntimeError(f"Missing expected text node: {counts}")

interface = tree.find("i:INTERFACE", namespaces=ns)
if interface is None:
    raise RuntimeError("Smart Form interface missing")
for item in interface.findall("i:item", namespaces=ns):
    name = item.findtext("i:NAME", namespaces=ns)
    if name in {"CUSTOMER", "DELIVERY", "PRODUCT", "QUANTITY", "WIDTH"}:
        item.find("i:TYPING", namespaces=ns).text = "TYPE"
        item.find("i:TYPENAME", namespaces=ns).text = "CHAR80"
for name, type_name in [
    ("H_LABEL1", "CHAR30"), ("H_LABEL2", "CHAR30"),
    ("H_LABEL3", "CHAR30"), ("H_LABEL4", "CHAR30"),
    ("H_LABEL5", "CHAR30")
]:
    item = etree.SubElement(interface, ifr + "item")
    for tag, value in [
        ("IOTYPE", "I"), ("NAME", name), ("TYPING", "TYPE"),
        ("TYPENAME", type_name), ("OPTIONAL", "X")
    ]:
        etree.SubElement(item, ifr + tag).text = value

extra_nodes = tree.xpath(
    '//s:NODE[s:OBJ/s:TEXT/i:NAME/i:INAME="%TEXT_SPC_MIC"]',
    namespaces=ns,
)
if len(extra_nodes) != 1:
    raise RuntimeError("Expected one spacer text node before MIC table")
extra_text = extra_nodes[0].find("s:OBJ/s:TEXT/i:TEXT", namespaces=ns)
extra_t_text = extra_nodes[0].find("s:OBJ/s:TEXT/i:T_TEXT", namespaces=ns)
if extra_text is None:
    raise RuntimeError("Spacer text structure missing")
for child in list(extra_text):
    extra_text.remove(child)
if extra_t_text is not None:
    for child in list(extra_t_text):
        extra_t_text.remove(child)
for number in range(1, 12):
    name = f"EXTRA_INFO{number}"
    item = etree.SubElement(interface, ifr + "item")
    for tag, value in [
        ("IOTYPE", "I"), ("NAME", name), ("TYPING", "TYPE"),
        ("TYPENAME", "CHAR100"), ("OPTIONAL", "X")
    ]:
        etree.SubElement(item, ifr + tag).text = value
    line = f"<H1>&{name}&</>"
    text_item = etree.SubElement(extra_text, ifr + "item")
    etree.SubElement(text_item, ifr + "TDFORMAT").text = "D2"
    etree.SubElement(text_item, ifr + "TDLINE").text = line
    if extra_t_text is not None:
        translation = etree.SubElement(extra_t_text, ifr + "item")
        for tag, value in [
            ("SPRAS", "E"), ("TXTYPE", "F"),
            ("FORMNAME", "ZQMF_COA_EXPORT"),
            ("INAME", "%TEXT_SPC_MIC"),
            ("LINENR", f"{number:06d}"),
            ("TDFORMAT", "D2"), ("TDLINE", line)
        ]:
            etree.SubElement(translation, ifr + tag).text = value

tree.write(str(target), encoding="utf-8", xml_declaration=True)
print(target)
print(counts)
