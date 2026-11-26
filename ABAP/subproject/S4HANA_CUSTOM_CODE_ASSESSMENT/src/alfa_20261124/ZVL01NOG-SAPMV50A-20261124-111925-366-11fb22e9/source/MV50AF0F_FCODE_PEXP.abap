***INCLUDE MV50AF0F_FCODE_PEXP .
*---------------------------------------------------------------------*
*       FORM FCODE_PEXP                                               *
*---------------------------------------------------------------------*
*       Übergang zur Position-Exportdaten                             *
*---------------------------------------------------------------------*
FORM FCODE_PEXP USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: NEUE_EXNUM LIKE LIKP-EXNUM,
        LOC_TRTYP  LIKE T180-TRTYP,
        LOC_HLAND  LIKE T001W-LAND1.

  DATA: MERK_AHBAS LIKE EIKP-AHBAS.

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
    PERFORM XVBUP_LESEN(SAPFV50P) USING LIKP-VBELN
                                        LIPS-POSNR.
    IF XVBUP-FKSTA CA 'BC'.
      LOC_TRTYP = CHARA.
      MESSAGE W131.
    ENDIF.
  ENDIF.

* setzen Hausland
  IF LIKP-VBTYP CA VBTYP_MMLI.
    PERFORM T001W_SELECT USING LIPS-WERKS
                               SPACE
                               SY-SUBRC.
    LOC_HLAND = T001W-LAND1.
  ELSE.
    LOC_HLAND = TVST-ALAND.
  ENDIF.

* Setzen Basisbelegtyp
  IF ( LIKP-VBTYP EQ VBTYP_LIAV ) OR
     ( LIKP-VBTYP EQ VBTYP_GRWE ) .
    MERK_AHBAS = '1LA'.
  ELSE.
    MERK_AHBAS = '2LI'.
  ENDIF.

  CALL FUNCTION 'EXPIMP_ITEM_DATA_MAINTAIN'
       EXPORTING
            EXNUM          = LIKP-EXNUM
            EXPOS          = LIPS-POSNR
            ARKTX          = LIPS-ARKTX
            CHARGE         = LIPS-CHARG
            HLAND          = LOC_HLAND
            MATNR          = LIPS-MATNR
            TRTYP          = LOC_TRTYP
            I_FT_BASIS     = MERK_AHBAS
       IMPORTING
            NEXNUM         = NEUE_EXNUM
            E_DATALOSS     = LOC_DATALOSS
       EXCEPTIONS
            NO_EXPORT_DATA = 01.

  IF SY-SUBRC GT 0.
    IF LIKP-VBTYP CA VBTYP_MMLI.
      MESSAGE I134.                                       "n_1060974
      EXIT.
    ELSE.
      MESSAGE I130.                                       "n_1060974
      EXIT.
    ENDIF.
  ENDIF.


  IF LIKP-EXPKZ IS INITIAL  AND
     NOT NEUE_EXNUM IS INITIAL.
    LIKP-EXPKZ = CHARX.
  ENDIF.

  IF LIKP-EXNUM IS INITIAL.
    LIKP-EXNUM = NEUE_EXNUM.
  ENDIF.

  IF NOT ( LOC_DATALOSS IS INITIAL ).
    R185D-DATALOSS = CHARX.
  ENDIF.

ENDFORM.