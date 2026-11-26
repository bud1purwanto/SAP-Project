*---------------------------------------------------------------------*
*       FORM DATUM_VON_BIS_PRUEFEN                                    *
*---------------------------------------------------------------------*
*       Prüfen, ob Von-Datum < Bis-Datum                              *
*---------------------------------------------------------------------*

FORM DATUM_VON_BIS_PRUEFEN USING DP_ABDATUM
                                 DP_BISDATUM.

  CHECK DP_ABDATUM > 0 AND DP_BISDATUM > 0.

  IF DP_ABDATUM > DP_BISDATUM.
    MESSAGE E444.
  ENDIF.

ENDFORM.