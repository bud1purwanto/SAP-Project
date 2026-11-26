*&---------------------------------------------------------------------*
*&  Include           MV50AF0T_TVSAK_SELECT                            *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       FORM TVSAK_SELECT                                              *
*----------------------------------------------------------------------*
FORM TVSAK_SELECT USING TS_SDABW
                        TS_ERROR
                        TS_SUBRC.

  TS_SUBRC = 0.
  CHECK: TS_SDABW NE TVSAKT-SDABW.

  IF TS_SDABW EQ SPACE.
    CLEAR: TVSAKT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVSAKT WHERE SPRAS EQ SY-LANGU
                                AND SDABW EQ TS_SDABW.

  IF SY-SUBRC NE 0.
    TS_SUBRC = 0.
    CLEAR TVSAKT.
  ENDIF.

ENDFORM.