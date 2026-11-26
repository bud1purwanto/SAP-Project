*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVEPZ_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVEPZ_SELECT                                             *
*---------------------------------------------------------------------*
*       Einteilungszuordnung für Bedarfsart lesen                     *
*---------------------------------------------------------------------*
FORM tvepz_select USING ts_pstyv LIKE tvepz-pstyv
                        ts_dismm LIKE tvepz-dismm
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_pstyv NE tvepz-pstyv OR
         ts_dismm NE tvepz-dismm.

  IF ts_pstyv EQ space AND ts_dismm EQ space.
    CLEAR: tvepz.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvepz WHERE pstyv EQ ts_pstyv
                               AND dismm EQ ts_dismm.

  IF sy-subrc NE 0.
    CLEAR tvepz.
    IF ts_error EQ charx.
* internes Fehlerhandling
      MESSAGE e373 WITH ts_pstyv
                        ts_dismm.
    ELSE.
* externes Fehlerhandling
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                    "TVEPZ_SELECT
*eject