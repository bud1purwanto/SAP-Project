*&---------------------------------------------------------------------*
*&  Include           MV45AI0V_VBAP_MATNR_LIST_EXCL                    *
*&---------------------------------------------------------------------*
MODULE VBAP_MATNR_LIST_EXCL.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  DATA: DA_SUBRC_LIST_EXCL LIKE SY-SUBRC.

  CLEAR DA_SUBRC_LIST_EXCL.

  PERFORM VBAP_MATNR_LIST_EXCL(SAPFV45P) CHANGING DA_SUBRC_LIST_EXCL.

  IF DA_SUBRC_LIST_EXCL = 6.
    MESSAGE E117 WITH VBAP-MATNR.
  ENDIF.
  IF DA_SUBRC_LIST_EXCL = 8.
    MESSAGE E118 WITH VBAP-MATNR.
  ENDIF.

ENDMODULE.