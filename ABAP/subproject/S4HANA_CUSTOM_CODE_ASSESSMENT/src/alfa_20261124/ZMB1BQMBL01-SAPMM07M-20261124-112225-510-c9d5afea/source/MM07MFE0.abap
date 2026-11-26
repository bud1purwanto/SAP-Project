*---------------------------------------------------------------------*
*       FORM EAN_CHECK                                                *
*---------------------------------------------------------------------*
*       Aufruf des Funktionsbausteins zum prüfen der EAN.             *
*---------------------------------------------------------------------*
FORM EAN_CHECK USING    I_MATNR LIKE MSEG-MATNR
                        I_MEINH LIKE MSEG-MEINS
                        I_MEINS LIKE MSEG-MEINS
               CHANGING I_EAN_NEU
                        I_ETYP_NEU.
   CHECK NOT I_MATNR IS INITIAL.
   CLEAR I_ETYP_NEU.
   CALL FUNCTION 'EAN_CHECK'
        EXPORTING ARTIKEL  = I_MATNR
                  EAN_NEU  = I_EAN_NEU
                  ETYP_NEU = I_ETYP_NEU
                  MEINH    = I_MEINH
                  MEINS    = I_MEINS
                  POSNR    = MSEG-ZEILE
        IMPORTING EAN_NEU  = I_EAN_NEU
                  ETYP_NEU = I_ETYP_NEU.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM EAN_PRUEFEN                                              *
*---------------------------------------------------------------------*
*       Die EAN-Nummern werden geprüft.                               *
*---------------------------------------------------------------------*
FORM EAN_PRUEFEN.
  DATA: ETYP LIKE MARM-NUMTP.
  CHECK T158-TRTYP = H AND NOT MSEG-MATNR IS INITIAL AND
     NOT VM07M-XSTOR = ZWEI AND NOT MSEG-KZBEW = O.
  IF AKTYP = H.
    CLEAR: YDM07M-EAN11_BME,
           YDM07M-EANME,
           YDM07M-EAN11_KON.
  ENDIF.
  IF MSEG-ERFME NE MSEG-BSTME AND
     DM07M-EAN11_BME = DM07M-EAN11.
    CLEAR: DM07M-EAN11_BME, YDM07M-EAN11_BME.
  ENDIF.
  IF DM07M-EAN11_BME NE YDM07M-EAN11_BME AND
     NOT DM07M-EAN11_BME IS INITIAL.
    IF NOT YDM07M-EAN11_BME IS INITIAL OR
       DM07M-EAN11_BME NE DM07M-EAN11.
      PERFORM EAN_CHECK USING    MSEG-MATNR
                                 MSEG-ERFME
                                 MSEG-MEINS
                        CHANGING DM07M-EAN11_BME
                                 ETYP.
    ENDIF.
  ENDIF.
  IF ( ( DM07M-EAN11_KON NE YDM07M-EAN11_KON ) OR
       ( DM07M-EANME     NE YDM07M-EANME ) )
        AND NOT DM07M-EAN11_KON IS INITIAL.
    PERFORM EAN_CHECK USING    MSEG-MATNR
                               DM07M-EANME
                               MSEG-MEINS
                      CHANGING DM07M-EAN11_KON
                               ETYP.
  ENDIF.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM ERWEITERTE_AUSWAHL                                       *
*---------------------------------------------------------------------*
*       Auf den Dialogfenster zu Reserierung suchen usw.              *
*       kann eine erweiterte Auswahl aufgerufen werden.               *
*---------------------------------------------------------------------*
FORM ERWEITERTE_AUSWAHL.
  OLD_PFSTA = PFSTA.
  OLD_TIT   = TIT.
  SELECT SINGLE * FROM T063C WHERE CCODE = CCODE.
  IF SY-SUBRC IS INITIAL.
    XPF02 = T063C-XPF02.
    WHILE CCODE NE SPACE AND T063C-XMODA = SPACE.
      PERFORM DYNPRO_CALL.
    ENDWHILE.
    CLEAR CCODE.
  ENDIF.
ENDFORM.
*eject