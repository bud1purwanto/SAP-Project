*&---------------------------------------------------------------------*
*&      Module  RV45A-S_WERKS_INPUT  INPUT
*&---------------------------------------------------------------------*
*       check factory calendar
*----------------------------------------------------------------------*
MODULE RV45A-S_WERKS_INPUT INPUT.

  CLEAR: DA_NOCHANGE, DA_SUBRC1.

  LOOP AT IVBAP WHERE SELKZ = SELEKTIERT.

    READ TABLE XVBAP INDEX IVBAP-TABIX.
    IF SY-SUBRC NE 0.
      MESSAGE E333 WITH XVBAP-POSNR 'IVBAP'.
    ELSE.
      SVBAP-TABIX = SY-TABIX.
      IF NOT VBAK-VBKLT EQ VBKLT_AUSL_AUFT AND
         NOT VBAK-VBKLT EQ VBKLT_AUSL_AUFT_KORR.

        READ TABLE IVBEP1 WITH KEY POSNR = XVBAP-POSNR.
        IF SY-SUBRC = 0.
          PERFORM DATUM_PRUEFEN_WERK_FK(SAPMV45A) USING RV45A-S_WERKS
                                                        IVBEP1-EDATU
                                                        SPACE
                                                        SPACE
                                               CHANGING DA_SUBRC1.
          IF DA_SUBRC1 = 3 OR
             DA_SUBRC1 = 4 OR
             DA_SUBRC1 = 6.
            DA_NOCHANGE = CHARX.
           PERFORM IVBAP-SELKZ_ABGEARBEITET(SAPFV45P) USING XVBAP-POSNR.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF DA_NOCHANGE = CHARX.
    MESSAGE I140(V2).
  ENDIF.

ENDMODULE.                 " RV45A-S_WERKS_INPUT  INPUT