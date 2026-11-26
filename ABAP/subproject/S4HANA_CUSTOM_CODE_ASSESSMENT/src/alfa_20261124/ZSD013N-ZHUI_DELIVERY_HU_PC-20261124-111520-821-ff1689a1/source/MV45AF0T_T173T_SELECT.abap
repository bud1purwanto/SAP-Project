*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_T173T_SELECT                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  T173T_SELECT
*&---------------------------------------------------------------------*
*
*       Routes: Transportation by dispatch
*         type: Texts Check
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM T173T_SELECT USING US_VSART
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VSART NE T173T-VSART.

  IF US_VSART = SPACE.
    CLEAR: T173T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T173T WHERE SPRAS = SY-LANGU
                               AND VSART = US_VSART.

  IF SY-SUBRC NE 0.
    CLEAR T173T.
  ENDIF.


ENDFORM.                    " T173T_SELECT



















