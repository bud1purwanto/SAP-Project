*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TLGR_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TLGR_SELECT                                              *
*---------------------------------------------------------------------*
*       Ladegruppe                                                    *
*       aus Tuninggründen wird nur die Texttabelle gelesen            *
*---------------------------------------------------------------------*
FORM tlgr_select USING ts_ladgr LIKE tlgrt-ladgr
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_ladgr NE tlgrt-ladgr.

  IF ts_ladgr EQ space.
    CLEAR: tlgrt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tlgrt WHERE spras EQ sy-langu
                               AND ladgr EQ ts_ladgr.

  IF sy-subrc NE 0.
    CLEAR tlgrt.
    ts_subrc = 0.
*   IF TS_ERROR EQ CHARX.
* internes Fehlerhandling
*      MESSAGE I330 WITH TS_LADGR.
*   ELSE.
* externes Fehlerhandling
*     TS_SUBRC = SY-SUBRC.
*   ENDIF.
  ENDIF.

ENDFORM.                    "TLGR_SELECT
*eject