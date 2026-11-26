***INCLUDE MV50AF0F_FCODE_QUIT_MARKIERTE .
*---------------------------------------------------------------------*
*       FORM FCODE_QUIT_MARKIERTE                                     *
*---------------------------------------------------------------------*
*       Note 68226 zu 31H                                             *
*---------------------------------------------------------------------*
FORM FCODE_QUIT_MARKIERTE.
  LOOP AT XLIPS WHERE UPDKZ NE UPDKZ_DELETE.
    IF XLIPS-UECHA IS INITIAL OR XLIPS_UMFANG CA 'EF'.
      READ TABLE ILIPS WITH KEY XLIPS-POSNR BINARY SEARCH.
      CHECK SY-SUBRC = 0 AND ILIPS-SELKZ = CHARX.
    ELSE.
      READ TABLE ILIPS WITH KEY XLIPS-UECHA BINARY SEARCH.
      CHECK SY-SUBRC = 0 AND ILIPS-SELKZ = CHARX.
    ENDIF.
    LOOP AT XVBFA WHERE VBELV = LIKP-VBELN    AND
                        POSNV = XLIPS-POSNR   AND
                        LGNUM IS INITIAL      AND
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
                fxvbfa  = xvbfa.                                "XAN-SPE

    ENDLOOP.
  ENDLOOP.
  IF SY-SUBRC = 0.
    PERFORM XVBUK_PFLEGEN IN PROGRAM (KOPFPROGRAMM).
  ENDIF.
  MESSAGE S169.


ENDFORM.