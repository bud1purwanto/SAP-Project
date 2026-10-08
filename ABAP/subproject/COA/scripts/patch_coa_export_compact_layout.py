from copy import deepcopy
from pathlib import Path

from lxml import etree


root_dir = Path(__file__).resolve().parent.parent
source = root_dir / "outputs" / "ZQMF_COA_EXPORT_sandbox-new_before_compact_layout.xml"
reference = root_dir / "outputs" / "ZQMF_COA_BATCH_sandbox-new_layout_reference.xml"
target = root_dir / "outputs" / "ZQMF_COA_EXPORT_compact_candidate.xml"
parser = etree.XMLParser(remove_blank_text=False)
tree = etree.parse(str(source), parser)
ref_tree = etree.parse(str(reference), parser)
ns = {
    "i": "urn:sap-com:sdixml-ifr:2000",
    "s": "urn:sap-com:SmartForms:2000:internal-structure",
}
ifr = "{urn:sap-com:sdixml-ifr:2000}"
smart = "{urn:sap-com:SmartForms:2000:internal-structure}"


def one(nodes, label):
    if len(nodes) != 1:
        raise RuntimeError(f"Expected one {label}, found {len(nodes)}")
    return nodes[0]


interface = one(tree.xpath("//i:INTERFACE", namespaces=ns), "interface")
old_params = []
for item in interface.findall("i:item", namespaces=ns):
    name = item.findtext("i:NAME", namespaces=ns)
    if name in {f"EXTRA_INFO{number}" for number in range(1, 12)}:
        old_params.append(item)
if len(old_params) != 11:
    raise RuntimeError("Expected eleven old extra parameters")
for item in old_params:
    interface.remove(item)
for number in range(1, 12):
    for prefix, type_name in [("EXTRA_LABEL", "CHAR30"), ("EXTRA_VALUE", "CHAR80")]:
        item = etree.SubElement(interface, ifr + "item")
        for tag, value in [
            ("IOTYPE", "I"), ("NAME", f"{prefix}{number}"),
            ("TYPING", "TYPE"), ("TYPENAME", type_name),
            ("OPTIONAL", "X"),
        ]:
            etree.SubElement(item, ifr + tag).text = value

main = one(
    tree.xpath('//s:NODE[s:OBJ/s:WINDOW/i:NAME/i:INAME="MAIN"]', namespaces=ns),
    "main window",
)
main_succ = one(main.xpath("./s:OBJ/s:WINDOW/s:PROC_CTRL/s:NODE/s:SUCC", namespaces=ns), "main successor")
template = one(
    main_succ.xpath('./s:item/s:NODE[s:OBJ/s:SECTION/i:NAME/i:INAME="%TEMPLATE1"]', namespaces=ns),
    "header template",
)
spacer = one(
    main_succ.xpath('./s:item/s:NODE[s:OBJ/s:TEXT/i:NAME/i:INAME="%TEXT_SPC_MIC"]', namespaces=ns),
    "MIC spacer",
)
spacer_item = spacer.getparent()
insert_at = list(main_succ).index(spacer_item)

condition_ref = one(ref_tree.xpath("//s:NODE[s:COND]/s:COND", namespaces=ns)[:1], "reference condition")

for number in range(1, 12):
    clone = deepcopy(template)
    section = one(clone.xpath("./s:OBJ/s:SECTION", namespaces=ns), "template section")
    for container_name in ("STATLINES", "CELLS"):
        container = one(section.findall("i:" + container_name, namespaces=ns), container_name)
        for row in list(container):
            if row.findtext("i:NAME", namespaces=ns) != "%C1":
                container.remove(row)
    children = one(clone.xpath("./s:SUCC", namespaces=ns), "template children")
    for child in list(children):
        child_name = child.xpath("./s:NODE/s:OBJ/*/i:NAME/i:INAME/text()", namespaces=ns)
        if child_name not in [["%TEXT11"], ["%TEXT12"]]:
            children.remove(child)

    replacements = {
        "%TEMPLATE1": f"%TEMPLATE_EXTRA_{number:02d}",
        "%OUTATTRIB30": f"%OUTATTR_EXTRA_{number:02d}",
        "%C1": f"%C_EXTRA_{number:02d}",
        "%TEXT11": f"%TEXT_EXTRA_{number:02d}_LABEL",
        "%TEXT12": f"%TEXT_EXTRA_{number:02d}_VALUE",
        "%OUTATTRIB4": f"%OUTATTR_EXTRA_{number:02d}_LABEL",
        "%OUTATTRIB5": f"%OUTATTR_EXTRA_{number:02d}_VALUE",
    }
    for element in clone.iter():
        if element.text in replacements:
            element.text = replacements[element.text]
    text_nodes = clone.xpath("./s:SUCC/s:item/s:NODE/s:OBJ/s:TEXT", namespaces=ns)
    if len(text_nodes) != 2:
        raise RuntimeError("Expected two text cells in extra template")
    label_line = one(text_nodes[0].xpath("./i:TEXT/i:item/i:TDLINE", namespaces=ns), "label line")
    value_line = one(text_nodes[1].xpath("./i:TEXT/i:item/i:TDLINE", namespaces=ns), "value line")
    label_line.text = f"<H1>&EXTRA_LABEL{number}&</>"
    value_line.text = f"<H1>: &EXTRA_VALUE{number}(C)&</>"

    condition = deepcopy(condition_ref)
    cond_name = one(condition.xpath("./s:CONDITION/i:NAME/i:INAME", namespaces=ns), "condition name")
    cond_name.text = f"%COND_EXTRA_{number:02d}"
    cond_caption = one(condition.xpath("./s:CONDITION/i:CAPTION", namespaces=ns), "condition caption")
    cond_caption.text = f"Extra Header {number}"
    operand = one(condition.xpath("./s:CONDITION/i:COND/i:item", namespaces=ns), "condition operand")
    operand.find("i:COP", namespaces=ns).text = "NE"
    operand.find("i:OP1", namespaces=ns).text = f"EXTRA_LABEL{number}"
    operand.find("i:OP2", namespaces=ns).text = "SPACE"
    for element in condition.xpath(".//i:FORMNAME", namespaces=ns):
        element.text = "ZQMF_COA_EXPORT"
    for element in condition.xpath(".//i:INAME", namespaces=ns):
        if element is not cond_name:
            element.text = f"%COND_EXTRA_{number:02d}"
    for element in condition.xpath(".//i:CAPTION", namespaces=ns):
        element.text = f"Extra Header {number}"
    clone.insert(list(clone).index(one(clone.xpath("./s:SUCC", namespaces=ns), "successor")), condition)
    wrapper = etree.Element(smart + "item")
    wrapper.append(clone)
    main_succ.insert(insert_at + number - 1, wrapper)

spacer_text = one(spacer.xpath("./s:OBJ/s:TEXT/i:TEXT", namespaces=ns), "spacer text")
for child in list(spacer_text):
    spacer_text.remove(child)
blank = etree.SubElement(spacer_text, ifr + "item")
etree.SubElement(blank, ifr + "TDFORMAT").text = "D1"

tree.write(str(target), encoding="utf-8", xml_declaration=True)
print(target)
print("extra rows=11, conditional and aligned to base template")
