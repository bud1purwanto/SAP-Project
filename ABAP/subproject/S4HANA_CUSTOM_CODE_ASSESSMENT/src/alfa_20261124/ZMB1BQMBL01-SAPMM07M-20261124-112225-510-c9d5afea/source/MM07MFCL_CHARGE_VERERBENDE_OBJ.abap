*eject
*---------------------------------------------------------------------*
*       FORM CHARGE_VERERBENDE_OBJEKTE
*---------------------------------------------------------------------*
*       Cursor auf gewuenschtes Feld positionieren                    *
*---------------------------------------------------------------------*
FORM charge_vererbende_objekte.

  DATA: loc_mtcom LIKE mtcom.
  DATA: loc_mtcor LIKE mtcor.
  DATA: BEGIN OF loc_dummy_tab OCCURS 0, dummy, END OF loc_dummy_tab.

* Schlüssel für Lesebaustein füllen
  loc_mtcom-kenng = 'MARA'.
  IF kzdch EQ charge_auf_werk.
    loc_mtcom-matnr = cl_mcha-matnr.
  ELSE.
    loc_mtcom-matnr = cl_mch1-matnr.
  ENDIF.

* Materialstamm lesen
  CALL FUNCTION 'MATERIAL_READ'
    EXPORTING
      schluessel         = loc_mtcom
    IMPORTING
      matdaten           = cl_mara
      return             = loc_mtcor
    TABLES
      seqmat01           = loc_dummy_tab
    EXCEPTIONS
      material_not_found = 04
      OTHERS             = 08.

* Übertragen in Klassenstrukturen
  IF NOT sy-subrc IS INITIAL.
    CLEAR cl_mara.
* classification requires all the time an entry for MARA and MAKT
*   also when data is empty (MCHx is allready appended)
*   when it is later on called again with values
    clear cl_objecttab.
    cl_objecttab-tname = 'MARA'.
    append cl_objecttab.
    clear cl_objecttab.
    cl_objecttab-tname = 'MAKT'.
    append cl_objecttab.
  else.
    CALL FUNCTION 'CLUC_CONVERT_STRUCTURE'
      EXPORTING
        i_workarea = cl_mara
        i_tabname  = 'MARA'
      IMPORTING
        e_object   = cl_objecttab.
    APPEND cl_objecttab.

*-- Materialtext lesen
    CALL FUNCTION 'MAKT_SINGLE_READ'
      EXPORTING
        matnr      = cl_mara-matnr
        spras      = sy-langu
      IMPORTING
        wmakt      = cl_makt
      EXCEPTIONS
        wrong_call = 1
        not_found  = 2
        OTHERS     = 3.

*-- Übertragen in Klassenstrukturen
    IF NOT sy-subrc IS INITIAL.
      CLEAR cl_makt.
    ELSE.
      cl_objecttab-tname = 'MAKT'.
      IF cl_makt-spras IS INITIAL.
        MOVE sy-langu TO cl_makt-spras.
      ENDIF.
      CALL FUNCTION 'CLUC_CONVERT_STRUCTURE'
        EXPORTING
          i_workarea = cl_makt
          i_tabname  = 'MAKT'
        IMPORTING
          e_object   = cl_objecttab.
      APPEND cl_objecttab.
    ENDIF.
  ENDIF.

ENDFORM.                    "CHARGE_VERERBENDE_OBJEKTE