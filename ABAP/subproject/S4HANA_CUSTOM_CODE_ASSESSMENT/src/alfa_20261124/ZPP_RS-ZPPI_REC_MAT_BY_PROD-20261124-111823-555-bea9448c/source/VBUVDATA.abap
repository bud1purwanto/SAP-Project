DATA:    BEGIN OF COMMON PART VBUVCOM.

* Tabelle der Belegunvollständigkeiten: neuer Stand
DATA:    BEGIN OF XVBUV OCCURS 9.
           INCLUDE STRUCTURE VBUVVB.
DATA:    END OF XVBUV.

* Tabelle der Belegunvollständigkeiten: gemeldete Fehler
DATA:    BEGIN OF HVBUV OCCURS 9.
           INCLUDE STRUCTURE VBUVVB.
DATA:    END OF HVBUV.

* Tabelle der Belegunvollständigkeiten: gemeldete Fehler
DATA:    BEGIN OF DVBUV OCCURS 9.
           INCLUDE STRUCTURE VBUVVB.
DATA:    END OF DVBUV.

* Tabelle der Belegunvollständigkeiten: alter Stand
DATA:    BEGIN OF YVBUV OCCURS 9.
           INCLUDE STRUCTURE VBUVVB.
DATA:    END OF YVBUV.


************************************************************************
************************************************************************
* Unvollständigkeit -> ALV

* type-pools
TYPE-POOLS: slis.

* structures types
TYPES: BEGIN OF G_TY_S_UVPROT_OUTTAB,
         CHECKBOX(1)     TYPE C,
         ANZEIGEPOS(6)   TYPE C,
         AUSGABETEXT(25) TYPE C,
         FELD(22)        TYPE C,
         FEHLERFELD      TYPE TBFDNAM_VB,
       END   OF G_TY_S_UVPROT_OUTTAB.
TYPES: G_TY_T_UVPROT_OUTTAB TYPE TABLE OF G_TY_S_UVPROT_OUTTAB.

* data
DATA: GT_UVPROT_LIST TYPE G_TY_T_UVPROT_OUTTAB,
      LISTWA         LIKE LINE OF GT_UVPROT_LIST.

* Constants for ALV
CONSTANTS :
  GC_UVPROT_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'UV_TOP_OF_PAGE',
  GC_UVPROT_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'UV_USER_COMMAND',
  GC_UVPROT_STRUNAME   TYPE DD02L-TABNAME VALUE 'G_TY_S_UVPROT_OUTTAB',
  GC_UVPROT_STATUS_SET TYPE SLIS_FORMNAME VALUE 'UV_PF_STATUS_SET',
  GC_X                 TYPE C VALUE 'X'.

* ALV Declaration
DATA: GV_UVPROT_REPID TYPE SY-REPID.
DATA: GT_UVPROT_FIELDCAT TYPE
                         SLIS_T_FIELDCAT_ALV, "ALV Field Catalog Table
      GS_UVPROT_LAYOUT   TYPE  SLIS_LAYOUT_ALV,      "Layout Structure
      GT_UVPROT_EVENTS   TYPE  SLIS_T_EVENT,         "For Event Handle
      GT_UVPROT_LIST_TOP_OF_PAGE TYPE
                         SLIS_T_LISTHEADER,   "ALV List Header Table
      GV_UVPROT_TITLE    TYPE SY-TITLE.       "ALV List Title

************************************************************************
************************************************************************

DATA:   END OF COMMON PART.

TABLES: FTEXT.
DATA: FEHLEREXIT TYPE C.
ENHANCEMENT-POINT VBUVDATA_01 SPOTS ES_VBUVDATA STATIC INCLUDE BOUND.