*----------------------------------------------------------------------*
*       INCLUDE MV50AF0T_TVKBT_SELECT                       n_679719  *
*                                                                     *
*       FORM TVKBT_SELECT                                             *
*---------------------------------------------------------------------*
*       Sales office text                                             *
*---------------------------------------------------------------------*
FORM TVKBT_SELECT USING LF_VKBUR.                          "n_679719

  CHECK: LF_VKBUR NE TVKBT-VKBUR.
  IF LF_VKBUR = SPACE.
    CLEAR: TVKBT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVKBT WHERE SPRAS = SY-LANGU
                             AND   VKBUR = LF_VKBUR.
  IF SY-SUBRC NE 0.
    CLEAR TVKBT.
  ENDIF.

ENDFORM.