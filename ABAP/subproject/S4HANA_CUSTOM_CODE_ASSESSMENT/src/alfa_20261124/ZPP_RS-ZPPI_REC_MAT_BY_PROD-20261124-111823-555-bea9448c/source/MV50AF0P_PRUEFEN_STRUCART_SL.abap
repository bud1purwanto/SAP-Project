*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PRUEFEN_STRUCART_SL                               *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM PRUEFEN_STRUCTART_SL                                     *
*---------------------------------------------------------------------*
*       Anhand der Stücklistenherkunft prüfen, ob es sich um eine     *
*       Stückliste für strukturierte Materialien handelt und wenn ja, *
*       um welche                                                     *
*---------------------------------------------------------------------*
FORM pruefen_structart_sl CHANGING kz_strtyp LIKE tmgw2-strtp
                                   stkey     LIKE vbap-stkey.
  IF tmgw2-stlan = stkey.
    kz_strtyp = tmgw2-strtp.
  ELSE.
    SELECT * FROM tmgw2 WHERE stlan = stkey.
      kz_strtyp = tmgw2-strtp.
      EXIT.
    ENDSELECT.
  ENDIF.

ENDFORM.                    "PRUEFEN_STRUCTART_SL
*eject