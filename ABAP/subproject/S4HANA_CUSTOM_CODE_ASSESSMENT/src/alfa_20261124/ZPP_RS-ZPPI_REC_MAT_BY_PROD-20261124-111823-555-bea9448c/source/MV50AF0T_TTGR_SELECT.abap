*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TTGR_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TTGR_SELECT                                              *
*---------------------------------------------------------------------*
*       Transportgruppe                                               *
*       aus Tuninggründen wird nur die Texttabelle gelesen            *
*---------------------------------------------------------------------*
FORM ttgr_select USING ts_tragr LIKE ttgrt-tragr
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_tragr NE ttgrt-tragr.

  IF ts_tragr EQ space.
    CLEAR: ttgrt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM ttgrt WHERE spras EQ sy-langu
                               AND tragr EQ ts_tragr.

  IF sy-subrc NE 0.
    CLEAR ttgrt.
    ts_subrc = 0.
*   IF TS_ERROR EQ CHARX.
* internes Fehlerhandling
*      MESSAGE I325 WITH TS_TRAGR.
*   ELSE.
* externes Fehlerhandling
*     TS_SUBRC = SY-SUBRC.
*   ENDIF.
  ENDIF.

ENDFORM.                    "TTGR_SELECT
*eject