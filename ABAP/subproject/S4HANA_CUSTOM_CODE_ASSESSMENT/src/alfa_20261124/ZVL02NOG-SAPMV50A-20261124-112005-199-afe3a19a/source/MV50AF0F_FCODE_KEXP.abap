***INCLUDE MV50AF0F_FCODE_KEXP .
*---------------------------------------------------------------------*
*       FORM FCODE_KEXP                                               *
*---------------------------------------------------------------------*
*       Übergang zum Kopf-Exportdaten                                 *
*---------------------------------------------------------------------*
FORM FCODE_KEXP USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: NEUE_EXNUM     LIKE LIKP-EXNUM,
        LOC_TRTYP      LIKE T180-TRTYP,
        LOC_HLAND      LIKE TVST-ALAND,
        LOC_PARTNER    LIKE LIKP-KUNNR.

  DATA: MERK_AHBAS     LIKE EIKP-AHBAS.

  DATA: LOC_DATALOSS   LIKE T185F-DATALOSS.
  CLEAR: LOC_DATALOSS.

  T185 = H185.
  T185F = H185F.
  T185V = H185V.
  PERFORM CUA_SETZEN.

  PERFORM TVST_SELECT USING LIKP-VSTEL
                            SPACE
                            SY-SUBRC.

* wenn Lieferung fakturiert nur Anzeigw
  LOC_TRTYP = T180-TRTYP.
  IF T180-TRTYP NE CHARA.
    PERFORM XVBUK_PFLEGEN(SAPFV50K).
    IF XVBUK-FKSTK CA 'BC'.
      LOC_TRTYP = CHARA.
      MESSAGE W131.
    ENDIF.
  ENDIF.

* setzen Partner
  IF LIKP-VBTYP CA VBTYP_MMLI.
    LOC_PARTNER = LIKP-LIFNR.
    READ TABLE XLIPS INDEX 1.
    IF SY-SUBRC EQ 0.
      PERFORM T001W_SELECT USING XLIPS-WERKS
                                 SPACE
                                 SY-SUBRC.
      IF SY-SUBRC EQ 0.
        LOC_HLAND   = T001W-LAND1.
      ENDIF.
    ENDIF.
  ELSE.
    LOC_PARTNER = KUWEV-KUNNR.
    LOC_HLAND   = TVST-ALAND.
  ENDIF.

*------- Setzen des korrekten Außenhandelsbasisbelegs
  IF ( LIKP-VBTYP EQ VBTYP_LIAV ) OR
     ( LIKP-VBTYP EQ VBTYP_GRWE ) .
    MERK_AHBAS = '1LA'.
  ELSE.
    MERK_AHBAS = '2LI'.
  ENDIF.


  CALL FUNCTION 'EXPIMP_GENERAL_DATA_MAINTAIN'
       EXPORTING
            EXNUM          = LIKP-EXNUM
            LAND           = KUWEV-LAND1
            NAME1          = KUWEV-NAME1
            PARTNER        = LOC_PARTNER
            TRTYP          = LOC_TRTYP
            HLAND          = LOC_HLAND
            I_FT_BASIS     = MERK_AHBAS
       IMPORTING
            NEXNUM         = NEUE_EXNUM
            E_DATALOSS     = LOC_DATALOSS
       EXCEPTIONS
            NO_EXPORT_DATA = 01.

  IF SY-SUBRC GT 0.
    IF LIKP-VBTYP CA VBTYP_MMLI.
      MESSAGE I134.                                        "n_1060974
      EXIT.
    ELSE.
      MESSAGE I130.                                        "n_1060974
      EXIT.
    ENDIF.
  ENDIF.

  IF NOT NEUE_EXNUM IS INITIAL.
     *LIKP = LIKP.
    LIKP-EXNUM = NEUE_EXNUM.
    IF LIKP-EXPKZ IS INITIAL.
      LIKP-EXPKZ = CHARX.
    ENDIF.
    PERFORM LIKP_AENDERN(SAPFV50K).
  ENDIF.

  IF NOT ( LOC_DATALOSS IS INITIAL ).
    R185D-DATALOSS = CHARX.
  ENDIF.

ENDFORM.