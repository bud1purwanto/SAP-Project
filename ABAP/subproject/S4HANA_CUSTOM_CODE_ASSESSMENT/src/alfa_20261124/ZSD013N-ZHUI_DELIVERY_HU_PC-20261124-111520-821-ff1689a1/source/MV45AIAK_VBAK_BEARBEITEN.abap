*---------------------------------------------------------------------*
*       MODULE VBAK_BEARBEITEN                                        *
*---------------------------------------------------------------------*
*       Bearbeiten des Auftragskopfes                                 *
*---------------------------------------------------------------------*
MODULE VBAK_BEARBEITEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  IF VBAKIN-VSBED IS INITIAL.
    VBAKIN-VSBED = VBAK-VSBED.
  ENDIF.

  PERFORM VBAK_BEARBEITEN(SAPFV45K).
**** DSEG *****
CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
       EXPORTING
            BUKRS                = T001-BUKRS
            COMPONENT            = 'BR'
       EXCEPTIONS
            COMPONENT_NOT_ACTIVE = 02.

if sy-subrc = 0.
  PERFORM J_1B_0303_CHECK(J_1BV45A) using vbak *vbak.
endif.

**** DSEG ****

ENDMODULE.