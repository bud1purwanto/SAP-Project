*eject
*---------------------------------------------------------------------*
*       FORM VERSANDVORSCHRIFT_PRUEFEN                                *
*---------------------------------------------------------------------*
*       Sofern in der Bestellposition eine Versandvorschrift definiert*
*       wurde, wird ein Funktionsbaustein aufgerufen, der die Be-     *
*       stätigung der Versandvorschrift abfragt.                  -   *
*---------------------------------------------------------------------*
FORM VERSANDVORSCHRIFT_PRUEFEN.

  DATA: XEVERE LIKE MSEG-EVERE.

  CLEAR VW.
  IF NOT T158-TRTYP = H.
    VW = X.
  ENDIF.
  CALL FUNCTION 'ME_SHIPPING_INSTRUCTIONS'
       EXPORTING
            I_CUATX = TEXT-C01
            I_EVERS = MSEG-EVERS
            I_EVERE = MSEG-EVERE
            DISPLAY = VW
            DIRCALL = XPF02
       IMPORTING
            E_EVERE = XEVERE.

  IF T158-TRTYP = H.
    MSEG-EVERE = XEVERE.
  ENDIF.
ENDFORM.