************************************************************************
*        Übergabestabelle bei Mehrfachselektion für Wareneingang       *
************************************************************************

DATA: BEGIN OF COMMON PART FM06LU02.

* Änderung der WEUB für Integration der VL07 in die MB01; 15.07.96
DATA: BEGIN OF WUEB OCCURS 0.
        INCLUDE STRUCTURE WUEB.
DATA: END OF WUEB.

DATA: WUEB-CALKZ,
      WUEB-NRCFD.

DATA: END OF COMMON PART.