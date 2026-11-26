*&---------------------------------------------------------------------*
*&      Form  GRULI_VEDA_CHECK
*&---------------------------------------------------------------------*
*       Blättern im Tablecontrol
*&---------------------------------------------------------------------*
FORM GRUKO_BLAETTERN.
  DATA: DUMMY LIKE SY-TABIX VALUE 2.

  DESCRIBE TABLE GRUKO LINES SY-TFILL.

  IF SY-TFILL > 0.
    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              ENTRY_ACT      = GRUKO_TABIX_ZEILE_1
              ENTRY_TO       = SY-TFILL
              LOOPS          = GRUKO_LOOPC
              OK_CODE        = FCODE
              PAGE_GO        = DUMMY
              PAGE_ACT       = DUMMY
              OVERLAPPING    = SPACE
              LAST_PAGE_FULL = CHARX
         IMPORTING
              ENTRY_NEW      = GRUKO_TABIX_ZEILE_1.
  ENDIF.

ENDFORM.