* Includes, die für SAPMV50A und für SAPLV50S gemeinsam genutzt werden
* Alphabetisch gliedert gemaess Logik bis 3.0
INCLUDE FV50XF0B.             "Beleg Sichern
INCLUDE FV50XF0G.             "Gefahrgut
INCLUDE FV50XF0M.             "Message_Handling
INCLUDE FV50XF0N.             "Naturalrabatt

* Thematisch gegliedert
INCLUDE FV50XFEN.
INCLUDE FV50XFIN.             "Final Check
INCLUDE FV50XFAN.
INCLUDE FV50XFGL.
INCLUDE FV50XFPD.             "Proof of Delivery
INCLUDE FV50XFUC.             "Incompleteness
INCLUDE FV50XFSN.             "Serial numbers
INCLUDE FV50XFWC.             "Warehouse component communication
INCLUDE FV50XFWF.             "Workflow
INCLUDE FV50XFDF.             "Not changeable fields maintenance
INCLUDE FV50XFLR.             "LIPS reference data
INCLUDE /SPE/RET_FV50XFWC.
INCLUDE /SPE/FV50XFCD.        "Transportation Cross-Docking
INCLUDE /SPE/FV50XFHU.        "Handling of generated packign items

ENHANCEMENT-POINT FV50XINC_01 SPOTS ES_FV50XINC STATIC INCLUDE BOUND.