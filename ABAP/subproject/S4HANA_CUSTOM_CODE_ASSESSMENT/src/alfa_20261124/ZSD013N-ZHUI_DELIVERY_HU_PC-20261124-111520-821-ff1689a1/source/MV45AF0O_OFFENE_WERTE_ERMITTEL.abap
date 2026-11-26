***********************************************************************
*  Unterroutinen RV-Auftragsabwicklung alphabetisch sortiert:         *
*  ----------------------------------------------------------         *
*  Buchstabe O:                                                       *
*                                                                     *
***********************************************************************
FORM OFFENE_WERTE_ERMITTELN TABLES OPEN_VALUES STRUCTURE BEZS132
                            USING US_SIS_SIMULATION
                                  US_VBAP_TABIX.
TABLES: *T691K.
DATA: DA_OLFMNG LIKE VBEPVB-OLFMNG.
DATA: OLFMNG_Q15 TYPE MC_OLIMEAU.
DATA: DA_TABIX_XVBAP LIKE SY-TABIX.
DATA: BEGIN OF DA_XVBEP OCCURS 10.
        INCLUDE STRUCTURE VBEPVB.
DATA: END   OF DA_XVBEP.
DATA: BEGIN OF DA_XVBAP OCCURS 10.
        INCLUDE STRUCTURE VBAPVB.
DATA: END   OF DA_XVBAP.

  REFRESH OPEN_VALUES.

  IF US_SIS_SIMULATION IS INITIAL.
    LOOP AT XVBAP FROM US_VBAP_TABIX.
      DA_TABIX_XVBAP = SY-TABIX.
      IF NOT US_VBAP_TABIX IS INITIAL AND
         DA_TABIX_XVBAP GT US_VBAP_TABIX.
*       Bei Positionsverarbeitung nur eine Position
        EXIT.
      ENDIF.
      READ TABLE XVBUP WITH KEY MANDT = XVBAP-MANDT
                                VBELN = XVBAP-VBELN
                                POSNR = XVBAP-POSNR
                                         BINARY SEARCH.
      READ TABLE XVBKD WITH KEY MANDT = XVBAP-MANDT
                                VBELN = XVBAP-VBELN
                                POSNR = XVBAP-POSNR
                                         BINARY SEARCH.
      IF SY-SUBRC NE 0.
        READ TABLE XVBKD WITH KEY MANDT = XVBAP-MANDT
                                  VBELN = XVBAP-VBELN
                                           BINARY SEARCH.
      ENDIF.
      IF XVBUP-LFGSA CA 'AB'.
        READ TABLE IVBEP1 WITH KEY XVBAP-POSNR BINARY SEARCH.
        IF SY-SUBRC EQ 0.
          REFRESH DA_XVBEP.
          LOOP AT IVBEP1 FROM SY-TABIX.
            IF IVBEP1-POSNR NE XVBAP-POSNR. EXIT. ENDIF.
            READ TABLE XVBEP INDEX IVBEP1-TABIX.
            CHECK XVBEP-UPDKZ NE UPDKZ_DELETE.
            MOVE XVBEP TO DA_XVBEP. APPEND DA_XVBEP.
          ENDLOOP.
          REFRESH DA_XVBAP.
          MOVE XVBAP TO DA_XVBAP.
          APPEND DA_XVBAP.
          CALL FUNCTION 'RV_SCHEDULE_CHECK_DELIVERIES'
              EXPORTING
                   FBELEG                  = XVBAP-VBELN
                   FPOSNR                  = XVBAP-POSNR
                   FVERRECHNUNG            = ' '
              TABLES
                   FVBFA                   = XVBFA
                   FVBUP                   = XVBUP
                   FXVBEP                  = DA_XVBEP
                   FVBAP                   = DA_XVBAP.
          LOOP AT DA_XVBEP.
*           nur offene Mengen
            CHECK NOT DA_XVBEP-OLFMNG IS INITIAL.

            CLEAR OPEN_VALUES.
            MOVE-CORRESPONDING XVBUK    TO OPEN_VALUES.
            MOVE-CORRESPONDING VBAK     TO OPEN_VALUES.
            MOVE-CORRESPONDING XVBKD    TO OPEN_VALUES.
            MOVE-CORRESPONDING XVBAP    TO OPEN_VALUES.
            MOVE-CORRESPONDING DA_XVBEP TO OPEN_VALUES.
            OPEN_VALUES-FKDAT = DA_XVBEP-WADAT.
            OPEN_VALUES-OEIKW_GES = DA_XVBEP-OLFMNG * XVBAP-CMPRE_FLT
                                    / 1000.
            IF NOT XVBAP-ABFOR IS INITIAL.
              IF XVBAP-ABFOR NE *T691K-ABSFO.
                PERFORM ABSICHERUNGSFORM_LESEN(SAPLVKMP)
                  USING XVBAP-ABFOR CHANGING *T691K.
              ENDIF.
              MOVE *T691K-ABSTP TO OPEN_VALUES-ABSTP.
            ENDIF.
            APPEND OPEN_VALUES.
          ENDLOOP.
        ELSE.
          CLEAR XVBAPF.
          READ TABLE XVBAPF WITH KEY VBELN = XVBAP-VBELN
                                     POSNR = XVBAP-POSNR  BINARY SEARCH.
          OLFMNG_Q15 = DA_OLFMNG.
          PERFORM AUFTRAGSMENGE_ERMITTELN(SAPLMCS1)
            USING    XVBUP-FKSAA
                     XVBUP-FKSTA
                     XVBAP-FKREL
                     XVBAP-LSMENG
                     XVBAP-KWMENG
                     XVBAP-ZMENG
                     XVBAPF-REMNG
                     XVBAPF-wEMNG
            CHANGING OLFMNG_Q15.
          DA_OLFMNG = OLFMNG_Q15.
          IF DA_OLFMNG GE XVBAPF-ERLMENGE_F.
            DA_OLFMNG = DA_OLFMNG - XVBAPF-ERLMENGE_F.
          ELSE.
            CLEAR DA_OLFMNG.
          ENDIF.
          CHECK NOT DA_OLFMNG IS INITIAL.
          CLEAR OPEN_VALUES.
          MOVE-CORRESPONDING XVBUK  TO OPEN_VALUES.
          MOVE-CORRESPONDING  VBAK  TO OPEN_VALUES.
          MOVE-CORRESPONDING XVBKD  TO OPEN_VALUES.
          MOVE-CORRESPONDING XVBAP  TO OPEN_VALUES.
          OPEN_VALUES-OEIKW_GES = DA_OLFMNG * XVBAP-CMPRE_FLT
                                    / 1000.
          IF NOT XVBAP-ABFOR IS INITIAL.
            IF XVBAP-ABFOR NE *T691K-ABSFO.
              PERFORM ABSICHERUNGSFORM_LESEN(SAPLVKMP)
                USING XVBAP-ABFOR CHANGING *T691K.
            ENDIF.
            MOVE *T691K-ABSTP TO OPEN_VALUES-ABSTP.
          ENDIF.
          APPEND OPEN_VALUES.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SORT OPEN_VALUES BY MANDT VBELN POSNR ETENR.
  ELSE.
*   Simulation Statistiken für Infostrukturen Akkreditiv und andere
    TABLES: MCCONTROL.
    INCLUDE RMCSSU01.
    RANGES: MCINF FOR TMC4-MCINF.

    MOVE 'I'    TO MCINF-SIGN.
    MOVE 'EQ'   TO MCINF-OPTION.
    MOVE 'S132' TO MCINF-LOW.
    APPEND MCINF.
*
    MCCONTROL-SPROG = 'SAPMV45A'.
    CLEAR MCCONTROL-SROUT.
    CALL FUNCTION 'MCV_STATISTICS_ORDER'
      EXPORTING TRTYP       = T180-TRTYP
                XVBAK       = VBAK
                YVBAK       = YVBAK
                XVBAK_UPDKZ = XVBAK_UPDKZ
                YVBAK_UPDKZ = YVBAK_UPDKZ
                MODUS       = CON_MODUS_SIM      "Simulation
                SPROG       = MCCONTROL-SPROG
                SROUT       = MCCONTROL-SROUT    "Default 'OUT_S132'
                POSITION    = CHARX
      TABLES    XKOMV       = XKOMV
                XVBAP       = XVBAP
                XVBEP       = XVBEP
                XVBKD       = XVBKD
                XVBPA       = XVBPA
                XVBFA       = XVBFA
                XVBUK       = XVBUK
                XVBUP       = XVBUP
                YVBAP       = YVBAP
                YVBEP       = YVBEP
                YVBKD       = YVBKD
                YVBPA       = YVBPA
                YVBFA       = YVBFA
                YVBUK       = YVBUK
                YVBUP       = YVBUP
                VBAPF       = XVBAPF
                MCINF       = MCINF
                XFPLA       = XFPLA
                YFPLA       = YFPLA
                XFPLT       = XFPLT
                YFPLT       = YFPLT.

  ENDIF.
ENDFORM.