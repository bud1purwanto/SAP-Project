*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVTY_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVTY_SELECT                                              *
*---------------------------------------------------------------------*
*       Transporttyp                                                  *
*       aus Tuninggründen wird nur die Texttabelle gelesen            *
*---------------------------------------------------------------------*
FORM tvty_select USING ts_traty LIKE tvty-traty
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_traty NE tvty-traty.

  IF ts_traty EQ space.
    CLEAR: tvty, tvtyt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVTY WHERE TRATY EQ TS_TRATY
                              AND VELTP EQ CHARA.           "N_410079
  IF sy-subrc NE 0.
    CLEAR: tvty, tvtyt.
    IF ts_error = charx.
      MESSAGE e144 WITH ts_traty.
      EXIT.
    ELSE.
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tvtyt WHERE spras EQ sy-langu
                               AND traty EQ ts_traty.

  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR tvtyt.
  ENDIF.

ENDFORM.                    "TVTY_SELECT
*eject