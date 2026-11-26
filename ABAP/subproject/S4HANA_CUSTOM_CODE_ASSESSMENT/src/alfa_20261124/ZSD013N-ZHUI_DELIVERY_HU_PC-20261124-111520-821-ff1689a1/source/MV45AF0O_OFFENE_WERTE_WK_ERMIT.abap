FORM OFFENE_WERTE_WK_ERMITTELN.
* Simulation Statistiken für Infostrukturen Wertkontrakt
  INCLUDE RMCSSU01.
  RANGES: MCINF FOR TMC4-MCINF.

  MOVE 'I'    TO MCINF-SIGN.
  MOVE 'EQ'   TO MCINF-OPTION.
  MOVE 'S135' TO MCINF-LOW.
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
              SROUT       = MCCONTROL-SROUT    "Default 'OUT_S135'
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
ENDFORM.