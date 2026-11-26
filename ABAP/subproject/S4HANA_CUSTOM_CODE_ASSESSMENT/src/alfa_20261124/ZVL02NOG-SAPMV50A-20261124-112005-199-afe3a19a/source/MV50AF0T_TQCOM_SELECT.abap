*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TQCOM_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TQCOM_SELECT                                             *
*---------------------------------------------------------------------*
*       Identifikation des sendenden Systems bei                      *
*       dezentralem Versand                                           *
*---------------------------------------------------------------------*
FORM tqcom_select USING ts_commn LIKE tqcom-commn.

  SELECT SINGLE * FROM tqcom WHERE commn EQ ts_commn.

  IF sy-subrc NE 0.
    CLEAR tqcom.
    MESSAGE e093 WITH ts_commn.
  ENDIF.

ENDFORM.                    "TQCOM_SELECT
*eject