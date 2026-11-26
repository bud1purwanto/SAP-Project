*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBAK_SET_DATA                                     *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  VBAK_SET_DATA  INPUT
*&---------------------------------------------------------------------*
*       VBAK-Daten, die neu berechnet aber durch einen Feldtransport
*       mit dem alten Dynprowert überschrieben wurden, auf den
*       richtigen Wert zurücksetzen
*----------------------------------------------------------------------*
MODULE VBAK_SET_DATA INPUT.

* Die durch den Feldtransport übertragenen Daten müssen durch die
* bereits neu ermittelten Kopfdaten überschrieben werden. Die ist
* nur bei Auftraggeberänderung relevant.

  IF XVBAK-AGUPDA = CHARX.
    VBAK-AUTLF = XVBAK-AUTLF.
    VBAK-VKBUR = XVBAK-VKBUR.
    VBAK-VKGRP = XVBAK-VKGRP.
    VBAK-WAERK = XVBAK-WAERK.
    VBAK-VSBED = XVBAK-VSBED.
    VBAK-KVGR1 = XVBAK-KVGR1.
    VBAK-KVGR2 = XVBAK-KVGR2.
    VBAK-KVGR3 = XVBAK-KVGR3.
    VBAK-KVGR4 = XVBAK-KVGR4.
    VBAK-KVGR5 = XVBAK-KVGR5.
  ENDIF.

* Verkäufergruppe nach Feldtransport wieder zurücksetzen, falls
* sie bei AG Ermittlung ungültig war
if vkgrp_clear = charx.
 clear vbak-vkgrp.
endif.

ENDMODULE.                 " VBAK_SET_DATA  INPUT