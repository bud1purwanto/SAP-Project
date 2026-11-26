*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TMFGT_SELECT                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TMFGT_SELECT
*&---------------------------------------------------------------------*
*       Text zur Materialfrachtgruppe lesen
*----------------------------------------------------------------------*
*      -->US_MFRGR : Materialfrachtgruppe                              *
*      -->US_ERROR : Errorhandling                                     *
*      <--CH_SUBRC : Returncode                                        *
*----------------------------------------------------------------------*
FORM tmfgt_select USING   us_mfrgr LIKE lips-mfrgr
                          us_error TYPE c
                          ch_subrc LIKE sy-subrc.

  ch_subrc = 0.
  CHECK  us_mfrgr NE tmfgt-mfrgr.

  IF us_mfrgr = space.
    CLEAR: tmfgt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tmfgt WHERE spras = sy-langu AND
                                   mfrgr = us_mfrgr.

  IF sy-subrc NE 0.
    CLEAR tmfgt.
    IF us_error = charx.
* internes Fehlerhandling
*  Keine meldung vorgesehen
*     message ennn with us_mfrgr.
    ELSE.
* externes Fehlerhandling
      ch_subrc = sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                               " TMFGT_SELECT