*&---------------------------------------------------------------------*
*&      Form  TVKGG_SELECT
*&---------------------------------------------------------------------*
*       Kundenattribute lesen
*----------------------------------------------------------------------*
*      -->P_KDKGX     Kundenattribute10-15  zur Preisfindung           *
*      -->P_CHARX                                                      *
*      -->P_SUBRC                                                      *
*----------------------------------------------------------------------*
FORM TVKGG_SELECT USING    P_KDKGX
                           P_ERROR
                           P_SUBRC.

  P_SUBRC = 0.
  IF P_KDKGX IS INITIAL.
    CLEAR: TVKGG, TVKGGT.
    EXIT.
  ENDIF.
  SELECT SINGLE * FROM TVKGG WHERE KDKGR = P_KDKGX.
  IF SY-SUBRC NE 0.
    CLEAR: TVKGG, TVKGGT.

    IF P_ERROR NE SPACE.
      MESSAGE E647 WITH P_KDKGX.
    ELSE.
      P_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                               " TVKGG_SELECT