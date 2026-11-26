*---------------------------------------------------------------------*
*       FORM VBFA_SELECT_VBELN                                        *
*---------------------------------------------------------------------*
*       Document Flow (only header flow)                              *
*---------------------------------------------------------------------*
FORM VBFA_SELECT_HEADER USING VALUE(VS_VBELV).

  CHECK NOT VS_VBELV IS INITIAL.

  READ TABLE XVBFA WITH KEY VBELV = VS_VBELV
                            POSNV = 0
                            BINARY SEARCH.
  IF SY-SUBRC NE 0.
ENHANCEMENT-POINT VBFA_SELECT_HEADER_02 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT VBFA_SELECT_HEADER_01 SPOTS ES_SAPMV45A.

    SELECT * FROM VBFA
             APPENDING TABLE XVBFA
             WHERE VBELV EQ VS_VBELV AND
                   POSNV EQ POSNR_LOW .
    SORT XVBFA BY MANDT VBELV POSNV VBELN POSNN VBTYP_N.
  ENDIF.

  CALL FUNCTION 'RV_XVBAPF_CREATE'
    EXPORTING
      VBELN   = VS_VBELV
    TABLES
      FXVBFA  = XVBFA
      FXVBAPF = XVBAPF.

ENDFORM.                    "VBFA_SELECT_HEADER