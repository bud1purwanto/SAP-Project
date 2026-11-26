***INCLUDE MV50AF0F_FCODE_IFLU_U0 .
*---------------------------------------------------------------------*
*       FORM FCODE_IFLU_U0                                            *
*---------------------------------------------------------------------*
*       Anzeige Belegfluß vom Übersichtsbild aus                      *
*---------------------------------------------------------------------*
FORM FCODE_IFLU_U0 USING US_T185F
                         US_T185
                         US_T185V.

  DATA: LF_SUBRC TYPE SYSUBRC.

  PERFORM XLIPS_BEREITSTELLEN(SAPFV50P) USING LF_SUBRC.
  IF LF_SUBRC = 0.
    LIPS = XLIPS.
    PERFORM ILIPS-SELKZ_RESET(SAPFV50P) USING LIPS-POSNR.

    PERFORM FCODE_IFLU_POSITION USING US_T185F
                                      US_T185
                                      US_T185V.
  ELSE.
    PERFORM FCODE_IFLU_KOPF USING US_T185F
                                  US_T185
                                  US_T185V.
  ENDIF.

ENDFORM.