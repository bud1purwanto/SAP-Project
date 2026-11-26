*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_RANGES                                *
*----------------------------------------------------------------------*
*    Ranges versorgen, falls Bestellungen über Einkaufsreport          *
*    selektiert werden                                                 *
*----------------------------------------------------------------------*
FORM BEST_SUCHEN_RANGES.

  REFRESH RPSTYP.
  IF NOT PSTYP IS INITIAL.
    RPSTYP-LOW    = PSTYP.
    RPSTYP-SIGN   = 'I'.
    RPSTYP-OPTION = 'EQ'.
    APPEND RPSTYP.
  ENDIF.
  REFRESH RLIFNR.
  IF NOT AM07M-LIFNR IS INITIAL.
    RLIFNR-LOW    = AM07M-LIFNR.
    RLIFNR-SIGN   = 'I'.
    RLIFNR-OPTION = 'EQ'.
    APPEND RLIFNR.
  ENDIF.
  REFRESH RIDNLF.
  IF NOT RM07M-IDNLF IS INITIAL.
    RIDNLF-LOW    = RM07M-IDNLF.
    RIDNLF-SIGN   = 'I'.
    RIDNLF-OPTION = 'EQ'.
    APPEND RIDNLF.
  ENDIF.
  REFRESH REAN11.
  IF NOT RM07M-EAN11 IS INITIAL.
    REAN11-LOW    = RM07M-EAN11.
    REAN11-SIGN   = 'I'.
    REAN11-OPTION = 'EQ'.
    APPEND REAN11.
  ENDIF.
  CLEAR RRESWK.
  REFRESH RRESWK.
  IF NOT AM07M-RESWK IS INITIAL.
    RRESWK-LOW    = AM07M-RESWK.
    RRESWK-SIGN   = 'I'.
    RRESWK-OPTION = 'EQ'.
    APPEND RRESWK.
  ENDIF.
  CLEAR RWERKS.
  REFRESH RWERKS.
  IF NOT RM07M-WERKS IS INITIAL.
    RWERKS-LOW    = RM07M-WERKS.
    RWERKS-SIGN   = 'I'.
    RWERKS-OPTION = 'EQ'.
    APPEND RWERKS.
  ENDIF.
  REFRESH REINDT.
  IF NOT RM07M-EINDT IS INITIAL.
    IF RM07M-EINDB IS INITIAL.
      REINDT-LOW    = RM07M-EINDT.
      REINDT-SIGN   = 'I'.
      REINDT-OPTION = 'EQ'.
    ELSE.
      REINDT-LOW    = RM07M-EINDT.
      REINDT-HIGH   = RM07M-EINDB.
      REINDT-SIGN   = 'I'.
      REINDT-OPTION = 'BT'.
    ENDIF.
    APPEND REINDT.
  ELSEIF NOT RM07M-EINDB IS INITIAL.
    CLEAR REINDT-LOW.
    REINDT-HIGH   = RM07M-EINDB.
    REINDT-SIGN   = 'I'.
    REINDT-OPTION = 'BT'.
    APPEND REINDT.
  ENDIF.
  CLEAR PSTYP.

ENDFORM.