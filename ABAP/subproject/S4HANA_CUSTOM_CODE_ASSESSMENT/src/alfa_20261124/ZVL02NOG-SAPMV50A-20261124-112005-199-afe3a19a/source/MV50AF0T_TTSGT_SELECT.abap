*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TTSGT_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TTSGT_SELECT                                              *
*---------------------------------------------------------------------*
*       Transportsperrgrund                                            *
*       aus Tuninggründen wird nur die Texttabelle gelesen            *
*---------------------------------------------------------------------*
FORM ttsgt_select USING tt_trspg LIKE ttsgt-trspg
                        tt_error TYPE c
                        tt_subrc LIKE sy-subrc.

  tt_subrc = 0.
  CHECK: tt_trspg NE ttsgt-trspg.

  IF tt_trspg EQ space.
    CLEAR: ttsgt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM ttsgt WHERE spras EQ sy-langu
                               AND trspg EQ tt_trspg.

  IF sy-subrc NE 0.
    CLEAR ttsgt.
    tt_subrc = 0.
*   IF TT_ERROR EQ CHARX.
* internes Fehlerhandling
*      MESSAGE I??? WITH TT_TRSPG.
*   ELSE.
* externes Fehlerhandling
*     TT_SUBRC = SY-SUBRC.
*   ENDIF.
  ENDIF.

ENDFORM.                    "TTSGT_SELECT
*eject