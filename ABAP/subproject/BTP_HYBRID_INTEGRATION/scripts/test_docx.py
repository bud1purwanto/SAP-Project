import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

doc = docx.Document()
p = doc.add_paragraph("Test Paragraph")
doc.save("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/outputs/test.docx")
print("Saved test.docx successfully!")
