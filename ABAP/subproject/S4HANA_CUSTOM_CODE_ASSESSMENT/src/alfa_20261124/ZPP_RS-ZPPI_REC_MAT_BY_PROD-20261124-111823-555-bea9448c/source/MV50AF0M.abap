************************************************************************
* Unterroutinen RV-Versand alphabetisch sortiert:                      *
* -----------------------------------------------                      *
* Buchstabe M:                                                         *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       FORM MSEG_FUELLEN                                             *
*---------------------------------------------------------------------*
*       Aufgrund der Bildschirmeingabe wird durch die                 *
*       FIELD- Anweisung im Dynpro die Workarea MSEG gepflegt.        *
*       In dieser Routine erfolgt das Zurückschreiben der             *
*       Workarea MSEG in die interne Tabelle XMSEG.                   *
*---------------------------------------------------------------------*
FORM MSEG_FUELLEN.

  R185D-DATALOSS = CHARX.
  XMSEG = MSEG.
  MODIFY XMSEG INDEX SLIPS-TABIX.

  PERFORM ILIPS_AENDERN(SAPFV50P).

ENDFORM.
*eject


*---------------------------------------------------------------------*
*       FORM MSEG-ERFMG_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       bei Eingabe einer Erfassungsmenge wird                        *
*       . diese in die Lagermengeneinheit umgerechnet                 *
*       . ggf. gegen die Lieferposition gerpüft                       *
*---------------------------------------------------------------------*
FORM MSEG-ERFMG_PRUEFEN.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
       EXPORTING
            INPUT                = MSEG-ERFMG
            KZMEINH              = 'X'
            MATNR                = LIPS-MATNR
            MEINH                = MSEG-ERFME
            MEINS                = MSEG-MEINS
       IMPORTING
            OUTPUT               = MSEG-MENGE
       EXCEPTIONS
            CONVERSION_NOT_FOUND = 01
            INPUT_INVALID        = 02
            MATERIAL_NOT_FOUND   = 03
            MEINH_NOT_FOUND      = 04
            MEINS_MISSING        = 05
            NO_MEINH             = 06
            OUTPUT_INVALID       = 07
            OVERFLOW             = 08.

  IF SY-SUBRC NE 0.
    SET CURSOR FIELD 'MSEG-ERFMG' LINE SY-STEPL.
*       MESSAGE E384 WITH LIPS-VRKME
*                         LIPS-POSNR.
  ENDIF.

ENDFORM.
*eject


*---------------------------------------------------------------------*
*       FORM MSEG-MATNR_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       bei Eingabe eines Lagerortes wird geprüft, ob dies ein        *
*       gültiger ist                                                  *
*---------------------------------------------------------------------*
FORM MSEG-MATNR_PRUEFEN.

* Nur prüfen falls Lagerort angegeben
  CHECK MSEG-LGORT NE SPACE.


* Prüfen, ob Eingabe ein gültiger Lagerort ist
  PERFORM T001L_SELECT USING MSEG-WERKS
                             MSEG-LGORT
                             CHARX
                             SY-SUBRC.

  IF SY-SUBRC NE 0.
    SET CURSOR FIELD 'MSEG-LGORT' LINE SY-STEPL.
    MESSAGE E366 WITH MSEG-LGORT
                      MSEG-WERKS.
  ENDIF.

* Prüfen, ob Material in diesem Lager liegen kann
* IF LIPS-MATNR NE SPACE AND
*    MSEG-LGORT NE SPACE.
*    PERFORM MAEPV_SELECT(SAPFV50P) USING LIPS-MATNR
*                                         MSEG-WERKS
*                                         MSEG-LGORT
*                                         CHARX
*                                         CHARX
*                                         SY-SUBRC.
* ELSE.
*    CLEAR MTCOM.
*    CLEAR MAEPV.
* ENDIF.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  MPN_CHECK
*&---------------------------------------------------------------------*
* check material parts number
*----------------------------------------------------------------------*
*      -->MATNR  material                                              *
*      -->EMATN  parts number (new)                                    *
*      -->EMATO  parts number (old)
*      -->MPROF  profile                                               *
*      -->WERKS  plant                                                 *
*----------------------------------------------------------------------*
FORM MPN_CHECK USING MATNR
                     EMATN
                     EMATO
                     MPROF
                     WERKS.

  CALL FUNCTION 'MB_MPN_CHANGE_READ_DATA'
       EXPORTING
            O_EMATN = *LIPS-EMATN
            MATNR   = LIPS-MATNR
            N_EMATN = LIPS-EMATN
            WERKS   = LIPS-WERKS
            MPROF   = LIPS-MPROF
*           revlv   =
*      importing
*           mfrnr   =
*           mfrpn   =
*           emnfr   =
*           txz01   = lips-arktx
       EXCEPTIONS
            OTHERS  = 1.
  IF SY-SUBRC <> 0. ENDIF.


ENDFORM.                    " MPN_CHECK
*&---------------------------------------------------------------------*
*&      Form  mark_items_for_update (n_603921)
*&---------------------------------------------------------------------*
FORM MARK_ITEMS_FOR_UPDATE.

  FIELD-SYMBOLS: <LS_XLIPS> LIKE LINE OF XLIPS.

  LOOP AT XLIPS ASSIGNING <LS_XLIPS>
                WHERE VBELN EQ LIKP-VBELN
                  AND UPDKZ EQ SPACE.
    APPEND <LS_XLIPS> TO YLIPS.
    <LS_XLIPS>-UPDKZ = UPDKZ_UPDATE.
  ENDLOOP.

ENDFORM.                    " mark_items_for_update


*---------------------------------------------------------------------*
*        FORM MARK_ITEMS_FOR_UPDATE_EXTENDED
*---------------------------------------------------------------------*
FORM MARK_ITEMS_FOR_UPDATE_EXTENDED.

  LOOP AT XLIPS WHERE VBELN EQ LIKP-VBELN AND UPDKZ EQ SPACE.
    ILIPS-TABIX = SLIPS-TABIX = SY-TABIX.
    APPEND XLIPS TO YLIPS.
    XLIPS-UPDKZ = UPDKZ_UPDATE.
    MODIFY XLIPS.
    PERFORM LIPS_BEARBEITEN_VORBEREITEN(SAPFV50P).
    PERFORM LIPS_BEARBEITEN(SAPFV50P).
  ENDLOOP.

ENDFORM.


ENHANCEMENT-POINT MV50AF0M_02 SPOTS ES_SAPMV50A STATIC.
*&---------------------------------------------------------------------*
*&      Form  mail_parameters                                v_n_699554
*&---------------------------------------------------------------------*
FORM MAIL_PARAMETERS USING IF_PARAFELD
                           IF_PARAWERT
                           IS_NAST TYPE NAST.
  DATA:
    LF_POSNR LIKE NAST-OBJKY,                                 "n_1579398
    LF_VBELN TYPE VBELN_VL.

* get likp for nast in case of multiple xlikp entries
  LF_VBELN = IS_NAST-OBJKY(10).
  IF LF_VBELN NE XLIKP-VBELN.                                "n_1365273
    READ TABLE XLIKP WITH KEY VBELN = LF_VBELN.
    MOVE-CORRESPONDING XLIKP TO LIKP.
*   get 1st item for the same likp-vbeln value             "v_n_1365273
    READ TABLE XLIPS WITH KEY VBELN = LF_VBELN.
    MOVE-CORRESPONDING XLIPS TO LIPS.                      "^_n_1365273
  ENDIF.

*   get correct item position                                v_n_1579398
  LF_POSNR = IS_NAST-OBJKY.
  SHIFT LF_POSNR BY 10 PLACES LEFT.
  IF LF_POSNR IS NOT INITIAL.
     READ TABLE XLIPS WITH KEY VBELN = LF_VBELN
                               POSNR = LF_POSNR.
    MOVE-CORRESPONDING XLIPS TO LIPS.
  ENDIF.                                                    "^_n_1579398

* mail execution parameters
  PERFORM MAILAKTIONSPARAMETER USING IF_PARAFELD
                                     IF_PARAWERT
                                     IS_NAST.

ENDFORM.                    " mail_parameters
*&---------------------------------------------------------------------*
*&      Form  mail_texts
*&---------------------------------------------------------------------*
FORM MAIL_TEXTS TABLES IT_XTLINES STRUCTURE TLINE
                USING  IS_XTHEAD TYPE THEAD
                       IS_NAST TYPE NAST.
  DATA:
    LF_POSNR LIKE NAST-OBJKY,                                 "n_1579398
    LF_VBELN TYPE VBELN_VL.

* get likp for nast in case of multiple xlikp entries
  LF_VBELN = IS_NAST-OBJKY(10).
  IF LF_VBELN NE XLIKP-VBELN.                                "n_1365273
    READ TABLE XLIKP WITH KEY VBELN = LF_VBELN.
    MOVE-CORRESPONDING XLIKP TO LIKP.
*   get 1st item for the same likp-vbeln value             "v_n_1365273
    READ TABLE XLIPS WITH KEY VBELN = LF_VBELN.
    MOVE-CORRESPONDING XLIPS TO LIPS.                      "^_n_1365273
  ENDIF.

*   get correct item position                                v_n_1579398
  LF_POSNR = IS_NAST-OBJKY.
  SHIFT LF_POSNR BY 10 PLACES LEFT.
  IF LF_POSNR IS NOT INITIAL.
     READ TABLE XLIPS WITH KEY VBELN = LF_VBELN
                               POSNR = LF_POSNR.
    MOVE-CORRESPONDING XLIPS TO LIPS.
  ENDIF.                                                    "^_n_1579398

* replace text symbols in mail
  PERFORM TEXT_SYMBOL_REPLACE TABLES IT_XTLINES
                               USING IS_XTHEAD
                                     IS_NAST.

ENDFORM.                    " mail_texts                     ^_n_699554