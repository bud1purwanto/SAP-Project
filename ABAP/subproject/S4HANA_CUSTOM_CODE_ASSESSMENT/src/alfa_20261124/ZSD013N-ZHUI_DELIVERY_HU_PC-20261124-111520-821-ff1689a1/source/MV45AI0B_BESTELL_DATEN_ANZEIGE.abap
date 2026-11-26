*----------------------------------------------------------------------*
*   INCLUDE MV45AI0B_BESTELL_DATEN_ANZEIGE                             *
*----------------------------------------------------------------------*
MODULE BESTELL_DATEN_ANZEIGEN .

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  IF FCODE EQ 'ITEM' OR                " F2 overview screen
     FCODE EQ 'TEDE' OR                " F2 header screen
     FCODE EQ 'SHLI'.              " F2 item screen, or read GUI status
    GET CURSOR FIELD CURSORFIELD.
    IF SY-SUBRC EQ 0.
      IF CURSORFIELD EQ 'VBKD-BSTDK' OR
         CURSORFIELD EQ 'VBKD-BSTKD'.
        IF SY-DYNGR EQ 'POSI'.
          GL_FCODE = 'PBES'.
        ELSE.
          GL_FCODE = 'KBES'.
        ENDIF.
      ELSE.
        CLEAR GL_FCODE.
      ENDIF.
    ENDIF.
  ENDIF.


ENDMODULE.                             " BESTELL_DATEN_ANZEIGEN  INPUT