*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T377_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T377_SELECT                                              *
*---------------------------------------------------------------------*
FORM t377_select USING us_serail LIKE t377-serail
                       us_vorga  LIKE t377-beleg
                       us_subrc  LIKE sy-subrc.

  CHECK us_serail NE t377-serail OR
        us_vorga  NE t377-beleg.

  SELECT SINGLE * FROM t377 WHERE serail = us_serail
                            AND   beleg  = us_vorga.
  us_subrc = sy-subrc.
  IF sy-subrc NE 0.
    CLEAR t377.
  ENDIF.

ENDFORM.                    "T377_SELECT