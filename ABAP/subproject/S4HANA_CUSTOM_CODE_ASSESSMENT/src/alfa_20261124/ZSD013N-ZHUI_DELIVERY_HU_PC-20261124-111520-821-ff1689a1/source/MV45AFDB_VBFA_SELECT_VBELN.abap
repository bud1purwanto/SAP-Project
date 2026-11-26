*---------------------------------------------------------------------*
*       FORM VBFA_SELECT_VBELN                                        *
*---------------------------------------------------------------------*
*       Belegfluß Auftrag lesen                                       *
*       In dieser routine wird  der Belegfluß performanter gelesen.   *
*---------------------------------------------------------------------*
FORM VBFA_SELECT_VBELN USING VALUE(VS_MANDT)
                             VALUE(VS_VBELV)
                             VALUE(VS_VBAPF).

  CHECK NOT VS_VBELV IS INITIAL.
  READ TABLE XVBFA WITH KEY MANDT = VS_MANDT
                            VBELV = VS_VBELV
                            BINARY SEARCH.
  CHECK SY-SUBRC NE 0.

  IF T180-TRTYP EQ CHARA.
    SELECT * FROM VBFA
             APPENDING TABLE XVBFA
             WHERE VBELV EQ VS_VBELV
               AND VBELN EQ VBAK-VBELN.
  ELSE.
    SELECT * FROM VBFA
             APPENDING TABLE XVBFA
             WHERE VBELV EQ VS_VBELV.
  ENDIF.

* XVBFA kann schon Einträge für andere Belege enthalten
  SORT XVBFA BY MANDT VBELV POSNV VBELN POSNN VBTYP_N.

  CHECK VS_VBAPF NE SPACE.
* kumulierten Belegfluß aufbauen
ENHANCEMENT-SECTION     VBFA_SELECT_VBELN_10 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'RV_XVBAPF_CREATE'
    EXPORTING
      VBELN   = VS_VBELV
    TABLES
      FXVBFA  = XVBFA
      FXVBAPF = XVBAPF.
END-ENHANCEMENT-SECTION.

ENDFORM.                    "VBFA_SELECT_VBELN