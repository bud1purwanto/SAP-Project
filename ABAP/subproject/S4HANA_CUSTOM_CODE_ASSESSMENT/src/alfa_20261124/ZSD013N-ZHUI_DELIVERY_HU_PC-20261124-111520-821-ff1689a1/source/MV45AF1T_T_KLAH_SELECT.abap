*&---------------------------------------------------------------------*
*&      Form  T_KLAH_SELECT
*&---------------------------------------------------------------------*
*       Warengruppenhierarchie Text lesen
*----------------------------------------------------------------------*
*      -->P_WGRU1  Hierarchiestufe 1                                   *
*      -->P_WGRU2  Hierarchiestufe 2                                   *
*      -->P_SUBRC  text                                                *
*----------------------------------------------------------------------*
FORM T_KLAH_SELECT USING    P_WGRU1
                            P_WGRU2
                            P_SUBRC.

  P_SUBRC = 0.

  IF P_WGRU1 IS INITIAL.
    CLEAR WGRU_1_TXT.
  ELSE.
    SELECT SINGLE * FROM KLAH WHERE KLART = '026' AND
                                    CLASS = P_WGRU1.
    P_SUBRC = SY-SUBRC.
    IF P_SUBRC = 0.
      SELECT SINGLE * FROM SWOR WHERE SPRAS = SY-LANGU AND
                                      CLINT = KLAH-CLINT.
      IF SY-SUBRC = 0.
        WGRU_1_TXT = SWOR-KSCHL.
      ENDIF.
    ENDIF.
  ENDIF.

  IF P_WGRU2 IS INITIAL.
    CLEAR WGRU_2_TXT.
  ELSE.
    SELECT SINGLE * FROM KLAH WHERE KLART = '026' AND
                                    CLASS = P_WGRU2.
    P_SUBRC = SY-SUBRC.
    IF P_SUBRC = 0.
      SELECT SINGLE * FROM SWOR WHERE SPRAS = SY-LANGU AND
                                      CLINT = KLAH-CLINT.
      IF SY-SUBRC = 0.
        WGRU_2_TXT = SWOR-KSCHL.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " T_KLAH_SELECT