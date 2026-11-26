*eject
*&---------------------------------------------------------------------*
*&      Form  VAR_WERT_AUS_MATRIX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VAR_VALUES  text                                           *
*----------------------------------------------------------------------*
FORM VAR_WERT_AUS_MATRIX USING P_MODE
                               P_FWERT
                               P_CWERT .
  CASE P_MODE.
    WHEN E.
      VAR_FUSS-ERFMG     = P_FWERT * 1000.
      MSEG-ERFMG = MSEG-ERFMG + VAR_FUSS-ERFMG.
*   when k. var_fuss-elikz     = p_cwert.
    WHEN L. VAR_FUSS-LSMNG     = P_FWERT * 1000.
    WHEN C. VAR_FUSS-CHARG     = P_CWERT.
    WHEN H. VAR_FUSS-LICHA     = P_CWERT.
    WHEN B. VAR_FUSS-INSMK     = P_CWERT.
    WHEN O. VAR_FUSS-LGORT     = P_CWERT.
    WHEN M. VAR_FUSS-BSMNG     = P_FWERT * 1000.
*   when N. var_fuss-ean11_kon = p_cwert.
  ENDCASE.

ENDFORM.                               " VAR_WERT_AUS_MATRIX