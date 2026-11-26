*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVAP_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVAP_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftragspositionstypentabelle lesen                           *
*---------------------------------------------------------------------*
FORM tvap_select USING ts_pstyv LIKE tvap-pstyv
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_pstyv NE tvap-pstyv.

  IF ts_pstyv = space.
    CLEAR: tvap.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvap WHERE pstyv = ts_pstyv.
  IF sy-subrc NE 0.
    CLEAR: tvap, tvapt.
    ts_subrc = 4.
  ENDIF.

ENDFORM.                    "TVAP_SELECT
*eject