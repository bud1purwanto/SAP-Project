*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T691L_SELECT                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  T691L_TEXT_SELECT
*&---------------------------------------------------------------------*
*       Text zur Absicherungsform ermitteln                            *
*----------------------------------------------------------------------*
FORM T691L_TEXT_SELECT
     USING    VALUE(H_ABFOR) LIKE LIPS-ABFOR
     CHANGING H_ABFOR_BEZEI  LIKE T691L-BEZEI.

  IF NOT ( H_ABFOR IS INITIAL ).
    IF H_ABFOR NE T691L-ABSFO.
      SELECT SINGLE * FROM T691L
                      WHERE SPRAS EQ SY-LANGU
                        AND ABSFO EQ H_ABFOR.
      IF SY-SUBRC IS INITIAL.
        H_ABFOR_BEZEI = T691L-BEZEI.
      ELSE.
        CLEAR: H_ABFOR_BEZEI.
      ENDIF.
    ELSE.
      H_ABFOR_BEZEI = T691L-BEZEI.
    ENDIF.
  ELSE.
    CLEAR: H_ABFOR_BEZEI.
  ENDIF.

ENDFORM.
*eject