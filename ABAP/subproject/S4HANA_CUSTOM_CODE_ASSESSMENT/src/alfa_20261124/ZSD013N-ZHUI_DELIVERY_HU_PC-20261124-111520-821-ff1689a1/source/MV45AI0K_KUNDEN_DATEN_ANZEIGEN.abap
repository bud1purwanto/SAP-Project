*----------------------------------------------------------------------*
*   INCLUDE MV45AI0K_KUNDEN_DATEN_ANZEIGEN                             *
*----------------------------------------------------------------------*
MODULE KUNDEN_DATEN_ANZEIGEN .

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  IF FCODE EQ 'ITEM' OR                " F2 overview screen
     FCODE EQ 'TEDE' OR                " F2 header screen
     FCODE EQ 'SHLI'.              " F2 item screen, or read GUI status
    GET CURSOR FIELD CURSORFIELD.
    IF SY-SUBRC EQ 0.
      IF CURSORFIELD EQ 'KUWEV-KUNNR'.
        IF SY-DYNGR EQ 'POSI'.
          GL_FCODE = 'PPAR_SUB'.
        ELSE.
          GL_FCODE = 'KPAR_SUB'.
        ENDIF.
      ELSEIF CURSORFIELD EQ 'KUAGV-KUNNR'.
        GL_FCODE = 'KPAR_SUB'.
      ELSE.
        CLEAR GL_FCODE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                             " KUNDEN_DATEN_ANZEIGEN  INPUT