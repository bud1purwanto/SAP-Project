*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_T156B_SELECT                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  T156B_SELECT
*&---------------------------------------------------------------------*
*       T156B lesen
*----------------------------------------------------------------------*
*      --> US_BWART      Bewegungsart
*      --> US_SOBKZ      Sonderbestandskennzeichen
*      --> US_SUBRC      Returncode
*----------------------------------------------------------------------*
FORM T156B_SELECT USING  US_BWART
                         US_SOBKZ
                         US_SUBRC.

  CLEAR US_SUBRC.
  CHECK US_BWART NE T156B-BWART OR
        US_SOBKZ NE T156B-SOBKZ.

  IF US_BWART IS INITIAL.
    CLEAR T156B.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T156B WHERE BWART = US_BWART AND
                                   SOBKZ = US_SOBKZ.

  US_SUBRC = SY-SUBRC.

  IF SY-SUBRC > 0.
    CLEAR T156B.
  ENDIF.

ENDFORM.                    " T156B_SELECT