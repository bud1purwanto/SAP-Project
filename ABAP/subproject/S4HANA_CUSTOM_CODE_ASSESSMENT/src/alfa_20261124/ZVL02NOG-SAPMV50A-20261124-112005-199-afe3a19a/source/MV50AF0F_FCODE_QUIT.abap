***INCLUDE MV50AF0F_FCODE_QUIT .
*---------------------------------------------------------------------*
*       FORM FCODE_QUIT                                               *
*---------------------------------------------------------------------*
FORM FCODE_QUIT.
  LOOP AT XVBFA WHERE LGNUM IS INITIAL AND
                      UPDKZ NE UPDKZ_DELETE AND
                      VBTYP_N = CHARQ       AND
                      TAQUI = SPACE.
    VBFA = XVBFA. VBFA-TAQUI = CHARX.
    CALL FUNCTION 'RV_XVBFA_MAINTAIN'
         EXPORTING
              F_VORGANG = CHARV
              FVBFA     = VBFA
         TABLES
              FXVBFA    = XVBFA
              FYVBFA    = YVBFA
              FXVBAPF   = XVBAPF.
    CHECK NOT VBFA-POSNV IS INITIAL.
    CALL FUNCTION 'LIPS_STATUS_MAINTAIN'
         EXPORTING
              F_POSNR = VBFA-POSNV
              F_LIKP  = LIKP
         TABLES
              FXLIPS  = XLIPS
              FXVBAPF = XVBAPF
              FXVBUP  = XVBUP
              FYVBUP  = YVBUP
              fxvbfa  = xvbfa.                                  "XAN-SPE

  ENDLOOP.
  IF SY-SUBRC = 0.
    PERFORM XVBUK_PFLEGEN IN PROGRAM (KOPFPROGRAMM).
  ENDIF.
  MESSAGE S169.

ENDFORM.