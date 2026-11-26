***INCLUDE MV50AF0F_ZUKV .
*---------------------------------------------------------------------*
*       FORM FCODE_ZUKV                                               *
*---------------------------------------------------------------------*
*       Anzeige Kreditversicherung vom Übersichtsbild aus             *
*---------------------------------------------------------------------*
FORM FCODE_ZUKV    USING US_T185F
                         US_T185
                         US_T185V.

  PERFORM XLIPS_BEREITSTELLEN(SAPFV50P) USING SY-SUBRC.
  IF SY-SUBRC = 0.
    LIPS = XLIPS.
    PERFORM ILIPS-SELKZ_RESET(SAPFV50P) USING LIPS-POSNR.

    PERFORM FCODE_ZUKV_POSITION USING US_T185F
                                      US_T185
                                      US_T185V.
  ELSE.
    PERFORM FCODE_ZUKV_KOPF USING US_T185F
                                  US_T185
                                  US_T185V.
  ENDIF.

ENDFORM.