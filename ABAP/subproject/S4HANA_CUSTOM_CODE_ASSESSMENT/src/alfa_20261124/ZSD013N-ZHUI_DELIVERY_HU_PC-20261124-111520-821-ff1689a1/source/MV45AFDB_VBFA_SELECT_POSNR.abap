*&---------------------------------------------------------------------*
*&  Include           MV45AFDB_VBFA_SELECT_POSNR                       *
*&---------------------------------------------------------------------*

FORM VBFA_SELECT_POSNR USING VALUE(VS_VBELV)
                             VALUE(VS_POSNV).

  CHECK: NOT VS_VBELV IS INITIAL,
         NOT VS_POSNV IS INITIAL.

  READ TABLE XVBFA WITH KEY VBELV = VS_VBELV
                            POSNV = VS_POSNV
                            BINARY SEARCH.
  IF SY-SUBRC NE 0.
ENHANCEMENT-POINT VBFA_SELECT_POSNR_01 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT VBFA_SELECT_POSNR_02 SPOTS ES_SAPMV45A.
    SELECT * FROM VBFA
      APPENDING TABLE XVBFA
      WHERE VBELV EQ VS_VBELV AND
            POSNV EQ VS_POSNV.
      IF SY-SUBRC = 0.
* XVBFA KANN SCHON EINTRÄGE FÜR ANDERE BELEGE ENTHALTEN
        SORT XVBFA BY MANDT VBELV POSNV VBELN POSNN VBTYP_N.
      ENDIF.
* kumulierten Belegfluß aufbauen
    call function 'RV_XVBAPF_CREATE'
         exporting
            vbeln   = vs_vbelv
         tables
            fxvbfa  = xvbfa
            fxvbapf = xvbapf.
  endif.


ENDFORM.                    "VBFA_SELECT_POSNV