*eject
*---------------------------------------------------------------------*
*       FORM VORGANGSART_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Die Vorgangsart wird geprueft.                                *
*---------------------------------------------------------------------*
FORM VORGANGSART_PRUEFEN.
  CHECK T158-TRTYP = H.
  IF MKPF-BLDAT > SY-DATLO.
    PERFORM NACHRICHTENCODE_ERMITTELN(SAPFM07M) USING 'M7' '088'. "ok
  ENDIF.
  MKPF-MJAHR = MKPF-BUDAT.
  CALL FUNCTION 'NUMBER_GET_INFO'
       EXPORTING
            NR_RANGE_NR        = T003M-NUMKR
            OBJECT             = 'MATBELEG'
            TOYEAR             = MKPF-MJAHR
       EXCEPTIONS
            INTERVAL_NOT_FOUND = 1.
  IF SY-SUBRC = 1.
    MESSAGE E562 WITH T003M-VGART MKPF-MJAHR.
  ENDIF.
  NUMKR = T003M-NUMKR.
  IF NOT RM07M-WERKS IS INITIAL.
    PERFORM WERK_PRUEFEN(SAPFM07M) USING    X
                                        RM07M-WERKS
                                        VM07M-BWKEY
                                        DM07M-BWMOD
                                        DM07M-XEINK
                                        DM07M-XBKNG
                                        VM07M-XVKBW
                                         MSEG-BUKRS
                                        DM07M-KTOPL
                                        DM07M-PERIV
                                         MSEG-WAERS
                                         MKPF-BUDAT
                                         MSEG-GJAHR
                                        VM07M-MONAT
                                         MSEG-XRUEM
                                         MSEG-XRUEJ
                                        VM07M-LFGJA
                                        VM07M-LFMON
                                        DM07M-FABKL
                                        DM07M-KZXAB.
    IF NOT MKPF-BLDAT = MKPF-BUDAT.
      DATA MONAT LIKE VM07M-MONAT.
      DATA GJAHR LIKE MSEG-GJAHR.
      CALL FUNCTION 'FI_PERIOD_DETERMINE'
           EXPORTING
                I_BUKRS = MSEG-BUKRS
                I_BUDAT = MKPF-BLDAT
           IMPORTING
                E_MONAT = MONAT
                E_GJAHR = GJAHR.
      IF NOT MSEG-GJAHR = GJAHR.
        PERFORM NACHRICHTENCODE_ERMITTELN(SAPFM07M) USING 'M7' '089'."ok
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.