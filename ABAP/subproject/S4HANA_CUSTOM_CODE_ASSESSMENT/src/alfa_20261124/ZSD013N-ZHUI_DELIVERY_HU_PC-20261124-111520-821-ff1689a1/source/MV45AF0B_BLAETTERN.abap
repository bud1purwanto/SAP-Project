*---------------------------------------------------------------------*
*       FORM BLAETTERN                                                *
*---------------------------------------------------------------------*
*       Blättern in Übersichtsbildern                                 *
*---------------------------------------------------------------------*
FORM BLAETTERN USING B_TABIX_ZEILE_1
                     B_TFILL
                     B_LOOPC.

  DATA: DUMMY LIKE SY-TABIX VALUE 1.

  IF B_TABIX_ZEILE_1 < 1.
    B_TABIX_ZEILE_1 = 1.
  ENDIF.
  IF B_TFILL > 0.
    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              ENTRY_ACT      = B_TABIX_ZEILE_1
              ENTRY_TO       = B_TFILL
              LOOPS          = B_LOOPC
              OK_CODE        = FCODE
              PAGE_GO        = DUMMY
              PAGE_ACT       = DUMMY
              OVERLAPPING    = SPACE
              LAST_PAGE_FULL = SPACE
         IMPORTING
              ENTRY_NEW      = B_TABIX_ZEILE_1.
  ENDIF.

ENDFORM.