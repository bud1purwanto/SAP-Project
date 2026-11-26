FORM STATISTIK_UPDATE.
RANGES: MCINF FOR TMC4-MCINF.


* Statistik-Fortschreibung nicht bei Bedarfsplanerfassung
ENHANCEMENT-SECTION     STATISTIK_UPDATE_10 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'MCV_STATISTICS_ORDER'
    EXPORTING TRTYP       = T180-TRTYP
              XVBAK       = VBAK
              YVBAK       = YVBAK
              XVBAK_UPDKZ = XVBAK_UPDKZ
              YVBAK_UPDKZ = YVBAK_UPDKZ
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
              YVBAPF      = YVBAPF
              MCINF       = MCINF
              XFPLA       = XFPLA
              YFPLA       = YFPLA
              XFPLT       = XFPLT
              YFPLT       = YFPLT.
END-ENHANCEMENT-SECTION.

ENDFORM.