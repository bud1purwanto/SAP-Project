*&---------------------------------------------------------------------*
*&      Module  TCTRL_U_ERF_AUFTRAG_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls (GROENE)
*----------------------------------------------------------------------*
MODULE TCTRL_U_ERF_AUFTRAG_BLAETTERN INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_AUFTRAG-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

  DESCRIBE TABLE SVBAP LINES SY-TFILL.
  IF SY-TFILL EQ 1 AND TC_SELLINE GT 1.
    TC_SELLINE = 1.            " If we have single line, take this line
  ENDIF.

  IF TC_SELLINE IS INITIAL             " The cursor is in header screen
     AND FCODE EQ 'ITEM'.              " action is double click
    FCODE = 'KKAU'.                    " so we go to head detail
  ENDIF.

ENDMODULE.                 " TCTRL_U_ERF_AUFTRAG_BLAETTERN  INPUT