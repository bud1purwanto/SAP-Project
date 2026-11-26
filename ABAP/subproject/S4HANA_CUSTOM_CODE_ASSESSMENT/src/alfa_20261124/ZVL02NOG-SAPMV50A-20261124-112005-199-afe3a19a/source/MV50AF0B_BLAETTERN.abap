*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BLAETTERN                                         *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BLAETTERN                                                *
*---------------------------------------------------------------------*
*       Blättern in Übersichtsbildern                                 *
*---------------------------------------------------------------------*
FORM blaettern USING b_tabix_zeile_1 LIKE sy-tabix
                     b_tfill         LIKE sy-tfill
                     b_loopc         LIKE sy-loopc.

  DATA: dummy LIKE sy-tabix VALUE 2.

  IF b_tfill > 0.

*   Translate FCODES for the new dialog
    IF t180-bldgr EQ gc_new_dialog_outb
       OR t180-bldgr EQ gc_new_dialog_inb.
      CASE fcode.
        WHEN 'FPAG_T'.
          fcode = 'P--'.
        WHEN 'PPAG_T'.
          fcode = 'P-'.
        WHEN 'NPAG_T'.
          fcode = 'P+'.
        WHEN 'LPAG_T'.
          fcode = 'P++'.
      ENDCASE.
    ENDIF.

    IF b_tabix_zeile_1 = 0.
      b_tabix_zeile_1 = 1.
    ENDIF.

    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = b_tabix_zeile_1
        entry_to       = b_tfill
        loops          = b_loopc
        ok_code        = fcode
        page_go        = dummy
        page_act       = dummy
        overlapping    = space
        last_page_full = charx
      IMPORTING
        entry_new      = b_tabix_zeile_1.
  ENDIF.

ENDFORM.                    "BLAETTERN