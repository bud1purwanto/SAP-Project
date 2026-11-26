*eject
*&---------------------------------------------------------------------*
*&      Form  KLAH_SWOR_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VBAP-WGRU  text                                            *
*----------------------------------------------------------------------*
FORM KLAH_SWOR_SELECT USING    P_WGRU
                               P_ERROR
                               P_SUBRC
                               P_STUFE.

  DATA: WGRU_H_TXT LIKE SWOR-KSCHL.

* den richtigen Text sichern
  IF P_STUFE = '1'.
    WGRU_H_TXT = WGRU_1_TXT.
  ELSE.
    WGRU_H_TXT = WGRU_2_TXT.
  ENDIF.
  P_SUBRC = 0.

* muß was gelesen werden ?
  IF P_WGRU     = KLAH-CLASS  AND
    WGRU_H_TXT = SWOR-KSCHL.
    EXIT.
  ENDIF.

  CLEAR WGRU_H_TXT.
  IF NOT P_WGRU IS INITIAL.
    SELECT SINGLE * FROM KLAH WHERE KLART = '026' AND
                                    CLASS = P_WGRU.
    IF SY-SUBRC   = 0  AND
       KLAH-WWSKZ = '0'.               "Warengruppenhierarchie
*    Text dazu lesen
      SELECT SINGLE * FROM SWOR WHERE SPRAS = SY-LANGU AND
                                      CLINT = KLAH-CLINT.
      IF SY-SUBRC = 0.
        WGRU_H_TXT = SWOR-KSCHL.
      ENDIF.
    ELSE.
      P_SUBRC = 4.
    ENDIF.
* else.
*   clear wgru_h_txt.
  ENDIF.

  IF P_STUFE = '1'.
    WGRU_1_TXT = WGRU_H_TXT.
  ELSE.
    WGRU_2_TXT = WGRU_H_TXT.
  ENDIF.

  IF P_SUBRC <> 0.
    IF P_ERROR EQ CHARX.
      MESSAGE E645 WITH P_WGRU '026'.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                               " KLAH_SWOR_SELECT