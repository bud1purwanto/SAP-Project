*----------------------------------------------------------------------*
*   INCLUDE MV45AF0R_RV45A_KPRGBZ_VALUES                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RV45A_KPRGBZ_VALUES
*&---------------------------------------------------------------------*
*       F4 für Wunschlieferdatum unter Beachtung des Datumformats
*----------------------------------------------------------------------*
*      -->P_KPRGBZ   Datumformattyp
*----------------------------------------------------------------------*
FORM RV45A_KPRGBZ_VALUES CHANGING   P_KPRGBZ.

  DATA: DA_KPRGBZ LIKE RV45A-KPRGBZ.

  CALL FUNCTION 'ME_VALUES_TPRG'
       IMPORTING
            E_LPEIN = DA_KPRGBZ.

  IF DA_KPRGBZ NE SPACE.
    P_KPRGBZ = DA_KPRGBZ.
  ENDIF.

ENDFORM.                               " RV45A_KPRGBZ_VALUES