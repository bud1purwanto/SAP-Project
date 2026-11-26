***INCLUDE RQALVTOP .

TABLES:  T370A, SSCRFIELDS, RIHQMAM, TSTCT.
TABLES: QALS_QAVE. "needed for springing to trans. from hotspots
* MONITOR FUNCTION
DATA: BEGIN OF G_MONITOR_TAB OCCURS 5,
       COUNTER  LIKE RIHEA-PM_SELFIELD,
       TEXTLINE LIKE RIHEA-PM_REFFIELD,
       FIELDNAME LIKE DFIES-FIELDNAME,
      END OF G_MONITOR_TAB.

* PARAMETERS
* VARIANT und MONITOR sind wegen Reihenfolge in den Reports definiert
*parameters: variant like disvariant-variant.
*parameters: monitor like rihea-pm_selfield.
DATA:
  DY_SELM VALUE '0',
  DY_TCODE LIKE SY-TCODE.
*--- Type pool für SALV Listviewer ---------------------------------*
TYPE-POOLS: SLIS.
TYPE-POOLS: KKBLO.

DATA: G_FIELDCAT_TAB     TYPE SLIS_T_FIELDCAT_ALV.
DATA: G_EVENT_EXIT_TAB   TYPE SLIS_T_EVENT_EXIT.
DATA: G_LISTHEADER_TAB   TYPE SLIS_T_LISTHEADER.
DATA: G_FIELDGROUPS_TAB  TYPE SLIS_T_SP_GROUP_ALV.
DATA: G_SORTFIELDS_TAB   TYPE SLIS_T_SORTINFO_ALV.
DATA: G_EVENTS_TAB       TYPE SLIS_T_EVENT.
DATA: G_PRINT            TYPE SLIS_PRINT_ALV.
DATA: G_SCROLL           TYPE SLIS_LIST_SCROLL.
DATA: G_LAYOUT           TYPE SLIS_LAYOUT_ALV.
DATA: G_FILTER_TAB       TYPE SLIS_T_FILTER_ALV.
DATA: G_FILTERED_ENTRIES_TAB  TYPE SLIS_T_FILTERED_ENTRIES.
DATA: GT_EXTAB           TYPE SLIS_T_EXTAB.

DATA: G_REPID            LIKE SY-REPID.
DATA: G_VARIANT          LIKE DISVARIANT.
DATA: GX_VARIANT         LIKE DISVARIANT.
DATA: G_VARIANT_SAVE     VALUE 'U'.    "Customizing variant.
* Screen coordinates for making list a popup
DATA: G_SCREEN_START_COLUMN TYPE I.
DATA: G_SCREEN_START_LINE   TYPE I.
DATA: G_SCREEN_END_COLUMN   TYPE I.
DATA: G_SCREEN_END_LINE     TYPE I.
*--- Form-Routinen in jedem Report für interaktion mit SALV --------*
DATA: G_FORM_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE_L'.
DATA: G_FORM_SET_PF_STAT  TYPE SLIS_FORMNAME VALUE 'SET_PF_STAT_L'.
DATA: G_FORM_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND_L'.
*GRID creates space for top-of-page, even if empty.
DATA: G_EVENT_NEEDED.
*--- Tabelle mit Selektionsrelevanten Feldern für dynam.Select -----*
DATA: BEGIN OF G_SELFIELDS_TAB OCCURS 20,
        FIELD(72),
      END OF G_SELFIELDS_TAB.

*--- Standard Fcode mit Einfluß auf Anwendung ----------------------*
DATA G_OL0 LIKE SY-UCOMM VALUE '&OL0'.
DATA G_OAD LIKE SY-UCOMM VALUE '&OAD'.
DATA G_OLX LIKE SY-UCOMM VALUE '&OLX'.
DATA G_ETA LIKE SY-UCOMM VALUE '&ETA'.
DATA G_LIS LIKE SY-UCOMM VALUE '&LIS'.
DATA G_ICI LIKE SY-UCOMM VALUE '&ICI'.
DATA G_IC1 LIKE SY-UCOMM VALUE '&IC1'.
DATA G_ILT LIKE SY-UCOMM VALUE '&ILT'.
DATA G_NFO LIKE SY-UCOMM VALUE '&NFO'.
* Allgemeine Daten
DATA:  G_A            VALUE 'A',
       G_S            VALUE 'S',
       G_U            VALUE 'U',
       G_X            VALUE 'X'.


DATA G_UCOMM    LIKE SY-UCOMM.
DATA G_SUBMIT   LIKE QM00-QKZ.         " needed for the refresh function

*missing
DATA: G_SELMOD,                        "Selektionsmodus
     SELMOD_0      VALUE '0',          "Keine Selektion
     SELMOD_S      VALUE 'S',          "Submit nur durch Variante
     SELMOD_1      VALUE '1',          "Selektion eines Objekts
     SELMOD_X      VALUE 'X',          "Selektion mehrerer Objekte
     SELMOD_D      VALUE 'D',          "Selektion aller Objekte dunkel
     G_TABNAME LIKE TIH01-TABNAME,
     IND_EMPTY,
    G_INDEX LIKE SY-TABIX,             "Globales Hilfsfeld für HIDEein
       YES      VALUE '+',
       NEVER    VALUE '-',
       NO       VALUE '.'.
*for qa32/33
DATA G_AKTYP.       " has value V(display) or A(change)
* BATCH INPUT
DATA: BDCDATA_TAB LIKE BDCDATA    OCCURS 0,
      BDCDATA_WA  LIKE LINE OF BDCDATA_TAB,
      MESSAGE_TAB LIKE BDCMSGCOLL OCCURS 0.

DATA C_TCODE_VE        LIKE SY-TCODE       VALUE 'QA11'.
DATA G_QAVE_FLAG.  "VE wird gewünscht für GET QAPO. Performance QA32/33
* Viewed lines in list are checked off.
INCLUDE <SYMBOL>.                      " for checkmark (Haken) in lists

*User parameter g_alv_grid_active is set to 'X' if grid control is
* desired, otherwise classic ALV is used.
DATA: G_GRID TYPE QKZ.