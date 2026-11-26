*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TPAER_SELECT                                      *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM TPAER_SELECT                                             *
*---------------------------------------------------------------------*
*       Erlaubte Partner prüfen                                       *
*---------------------------------------------------------------------*
FORM tpaer_select USING ts_pargr LIKE tpaer-pargr
                        ts_parvw LIKE tpaer-parvw
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_pargr NE tpaer-pargr OR
         ts_parvw NE tpaer-parvw.

  IF ts_pargr EQ space AND ts_parvw EQ space.
    CLEAR: tpaer.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tpaer WHERE pargr EQ ts_pargr
                               AND parvw EQ ts_parvw.

  IF sy-subrc NE 0.
    CLEAR tpaer.
    IF ts_error EQ charx.
* internes Fehlerhandling
      MESSAGE e372 WITH ts_pargr
                        ts_parvw.
    ELSE.
* externes Fehlerhandling
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                    "TPAER_SELECT
*eject