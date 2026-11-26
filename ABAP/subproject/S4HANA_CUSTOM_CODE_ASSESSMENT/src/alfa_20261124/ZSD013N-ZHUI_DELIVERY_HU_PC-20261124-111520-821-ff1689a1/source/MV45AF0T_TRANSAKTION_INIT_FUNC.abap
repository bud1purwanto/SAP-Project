*---------------------------------------------------------------------*
*       FORM TRANSAKTION_INIT_FUNCTION                                *
*---------------------------------------------------------------------*
*       Startwerte der Transaktion bei Aufruf aus Funktionsbaustein   *
*---------------------------------------------------------------------*
FORM TRANSAKTION_INIT_FUNCTION USING US_AVAILIBILITY
                                     US_AENDERN.

  DATA: DA_TCODE LIKE SY-TCODE VALUE 'VA02'.

  IF US_AENDERN = CHARA.
    DA_TCODE = 'VA03'.
  ENDIF.
* Kein Dialog bei der Verfügbarkeitsprüfung
  IF US_AVAILIBILITY NE SPACE.
    CASE TVTA-REVFP.
      WHEN SPACE.
        TVTA-REVFP = CHARB.
      WHEN CHARD.
        TVTA-REVFP = CHARA.
      WHEN CHARE.
        TVTA-REVFP = CHARC.
    ENDCASE.
  ENDIF.

  IF NOT TVAK-AUART IS INITIAL.
    DA_TCODE+2(1) = TVAK-TRVOG.
    CASE US_AENDERN.
      WHEN CHARA.
        DA_TCODE+3 = '3'.
      WHEN CHARV.
        DA_TCODE+3 = '2'.
      WHEN OTHERS.
        DA_TCODE+3 = '1'.
    ENDCASE.
  ENDIF.
* Sonderbehandlung für MD81
  IF DA_TCODE(3) = 'VAB'.
    DA_TCODE(3) = 'MD8'.
  ENDIF.

* Kennzeichen, daß im Call Function gearbeitet wird.
  CALL_FUNCTION = CHARX.

  PERFORM TRANSAKTION_INIT USING DA_TCODE.


ENDFORM.