*eject
*---------------------------------------------------------------------*
*       FORM STUECKLISTE_LESEN                                        *
*---------------------------------------------------------------------*
*       Lesen der Stückliste und Aufbauen der Auswahlliste.           *
*---------------------------------------------------------------------*
FORM stueckliste_lesen.

  IF rm07m-capid IS INITIAL.
    SET CURSOR FIELD 'RM07M-CAPID'.
    PERFORM no_input(sapfm07m) USING 'RM07M' 'CAPID'.
  ENDIF.
  IF rm07m-matnr IS INITIAL AND rm07m-equnr IS INITIAL.
    MESSAGE e118.
  ENDIF.
  IF NOT rm07m-matnr IS INITIAL AND NOT rm07m-equnr IS INITIAL.
    MESSAGE e119.
  ENDIF.
  IF rm07m-smeng IS INITIAL.
    SET CURSOR FIELD 'RM07M-SMENG'.
    PERFORM no_input(sapfm07m) USING 'RM07M' 'SMENG'.
  ENDIF.
  IF NOT rm07m-matnr IS INITIAL.

    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
         EXPORTING
              ftrel                 = x
              auskz                 = x
              bgixo                 = x
              ehndl                 = '1'
              brems                 = rm07m-brems
              capid                 = rm07m-capid
              datuv                 = mkpf-budat
              delnl                 = space
              emeng                 = rm07m-smeng
              mdmps                 = rm07m-brems
              mehrs                 = x
              mtnrv                 = rm07m-matnr
              stlal                 = rm07m-stlal
              werks                 = rm07m-werks
         TABLES
              stb                   = xstpox
              matcat                = xmatcat
         EXCEPTIONS
              alt_not_found         = 01
              call_invalid          = 02
              material_not_found    = 03
              missing_authorization = 04
              no_bom_found          = 05
              no_plant_data         = 06
              no_suitable_bom_found = 07.

    CASE sy-subrc.
      WHEN 3.
        SET CURSOR FIELD 'RM07M-MATNR'.
        MESSAGE e530 WITH rm07m-matnr.
      WHEN 6.
        SET CURSOR FIELD 'RM07M-MATNR'.
        MESSAGE e531 WITH rm07m-matnr rm07m-werks.
      WHEN 5.
        SET CURSOR FIELD 'RM07M-MATNR'.
        MESSAGE e532 WITH rm07m-matnr rm07m-capid.
      WHEN 7.
        SET CURSOR FIELD 'RM07M-MATNR'.
        MESSAGE e533 WITH mkpf-budat.
      WHEN 1.
        SET CURSOR FIELD 'RM07M-MATNR'.
        MESSAGE e534 WITH rm07m-stlal.
      WHEN 4.
        SET CURSOR FIELD 'RM07M-MATNR'.
        MESSAGE e537.
    ENDCASE.
  ENDIF.
  IF NOT rm07m-equnr IS INITIAL.

    CALL FUNCTION 'CS_BOM_EXPL_EQU_V2'
         EXPORTING
              ehndl                 = '1'
              auskz                 = x
              bgixo                 = x
              brems                 = rm07m-brems
              capid                 = rm07m-capid
              datuv                 = mkpf-budat
              delnl                 = space
              emeng                 = rm07m-smeng
              eqnrv                 = rm07m-equnr
              mdmps                 = rm07m-brems
              mehrs                 = x
              stlal                 = rm07m-stlal
              werks                 = rm07m-werks
         TABLES
              stb                   = xstpox
              matcat                = xmatcat
         EXCEPTIONS
              alt_not_found         = 01
              call_invalid          = 02
              equipment_not_found   = 03
              missing_authorization = 04
              no_bom_found          = 05
              no_plant_data         = 06
              no_suitable_bom_found = 07.
    CASE sy-subrc.
      WHEN 3.
        SET CURSOR FIELD 'RM07M-EQUNR'.
        MESSAGE e530 WITH rm07m-equnr.
      WHEN 6.
        SET CURSOR FIELD 'RM07M-EQUNR'.
        MESSAGE e531 WITH rm07m-equnr rm07m-werks.
      WHEN 5.
*       PERFORM STUECKLISTE_EQUIMAT_LESEN.
*       IF NOT RC IS INITIAL.
        SET CURSOR FIELD 'RM07M-EQUNR'.
        MESSAGE e536 WITH rm07m-equnr rm07m-capid.
*       ENDIF.
      WHEN 7.
        SET CURSOR FIELD 'RM07M-EQUNR'.
        MESSAGE e533 WITH mkpf-budat.
      WHEN 4.
*       SET CURSOR FIELD 'RM07M-EQUNR'.
*       MESSAGE E537.
    ENDCASE.
  ENDIF.
  READ TABLE xstpox INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e535 WITH rm07m-matnr rm07m-werks.
  ENDIF.
  REFRESH yfuss.
* Materialprefetch da Nichtlagerpos. wegen Pipeline mitgegeben
  REFRESH: prefetch01,
           prefetch02.
  LOOP AT xstpox WHERE NOT idnrk IS INITIAL.
    MOVE xstpox-idnrk TO prefetch02-matnr.
    MOVE rm07m-werks  TO prefetch02-werks.
    MOVE rm07m-lgort  TO prefetch02-lgort.
    COLLECT prefetch02.
  ENDLOOP.
  PERFORM prefetch_ausfuehren USING x
                                    space.
  TABLES: t418.
  LOOP AT xstpox.
    IF NOT xstpox-postp = t418-postp.
      SELECT SINGLE * FROM t418 WHERE postp = xstpox-postp.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'T418' xstpox-postp.
      ENDIF.
    ENDIF.
* Neu Pipeline
    CHECK NOT xstpox-idnrk IS INITIAL.
    CLEAR mtcom.
    mtcom-kenng = 'MBEFU'.
    mtcom-matnr = xstpox-idnrk.
    mtcom-werks = rm07m-werks.
    CALL FUNCTION 'MATERIAL_READ'
         EXPORTING
              schluessel = mtcom
         IMPORTING
              matdaten   = mbefu
              return     = mtcor.
    IF t156-shkzg = h.
      CHECK NOT mbefu-mengu IS INITIAL OR
      ( mbefu-mengu IS INITIAL AND NOT mbefu-kzpip IS INITIAL ).
    ELSE.
      CHECK NOT mbefu-mengu IS INITIAL."Nur Lager
    ENDIF.
    IF t418-kzbsf IS INITIAL.
      CHECK NOT mbefu-kzpip IS INITIAL.
    ENDIF.
* Ende neu Pipeline
    IF NOT rm07m-schgt IS INITIAL.
      CHECK xstpox-schgt IS INITIAL AND xstpox-mschg IS INITIAL.
    ENDIF.
    IF NOT rm07m-beikz IS INITIAL.
      CHECK xstpox-beikz NE  l.
    ENDIF.
    CLEAR: mseg, dm07m, vm07m, fuss.
*   DATA: LS_460A LIKE T460A.                              "note 215540
*   CHECK XSTPOX-XTLNR IS INITIAL.                         "note 215540
*   IF NOT XSTPOX-XTLNR IS INITIAL.                        "note 215540
*     Dummybaugruppen: T460A-DUMPS = X und XSTPOX-DUMPS = X
*     => wird NICHT übernommen
*     Dummybaugruppen, die in der Stückliste zurückgenommen wurden:
*     T460A-DUMPS = X und XSTPOX-DUMPS initial
*     => wird übernommen
*     CHECK XSTPOX-DUMPS IS INITIAL.                       "note 215540
*     IF NOT XSTPOX-SOBSL IS INITIAL.                      "note 215540
*       SELECT SINGLE * FROM T460A INTO LS_460A            "note 215540
*                       WHERE WERKS EQ RM07M-WERKS         "note 215540
*                       AND   SOBSL EQ XSTPOX-SOBSL.       "note 215540
*       IF SY-SUBRC <> 0.                                  "note 215540
*         Sonderbeschaffung & für Werk & nicht gepflegt    "note 215540
*         MESSAGE E703(MD) WITH XSTPOX-SOBSL RM07M-WERKS.  "note 215540
*       ENDIF.                                             "note 215540
*       CHECK LS_460A-DUMPS EQ X.                          "note 215540
*     ENDIF.                                               "note 215540
*   ENDIF.                                                 "note 215540
* Note 389884: If the indicator 'limited explosion' (RM07M-BREMS) is
* populated, phantom assemblies must be sorted out. This is done by
* by checking 'XSTPOX-DUMPS IS INITIAL'. Non-stock assemblies are ex-
* ploded by function 'CS_BOM_EXPL_MAT_V2'. For that reason there is no
* further check necessary. Stock assemblies are only sorted out if
* limited explosion is switched off. This is done by checking
* 'XSTPOX-XTLNR IS INITIAL'.
    IF NOT RM07M-BREMS IS INITIAL.                          "note 389884
      CHECK XSTPOX-DUMPS IS INITIAL.                        "note 389884
    ELSE.                                                   "note 389884
      CHECK XSTPOX-XTLNR IS INITIAL AND                     "note 389884
            XSTPOX-DUMPS IS INITIAL.                        "note 389884
    ENDIF.                                                  "note 389884
    IF xstpox-nfgrp IS INITIAL.
      mseg-erfmg = xstpox-mngko.
    ELSE.
      CLEAR mseg-erfmg.
    ENDIF.
    CHECK mseg-erfmg >= 0.
    MOVE-CORRESPONDING msegk TO mseg.
    dm07m-konto = msegk-konto.
    mseg-bwart  = rm07m-bwart.
    mseg-sobkz  = rm07m-sobkz.
    mseg-matnr  = xstpox-idnrk.
    mseg-werks  = rm07m-werks.
    mseg-lgort  = xstpox-lgort.
    IF mseg-lgort IS INITIAL.
      mseg-lgort  = rm07m-lgort.
    ENDIF.
    mseg-erfme  = xstpox-meins.
    dm07m-maktx = xstpox-ojtxp.
    PERFORM fusszeile_bew_pruefen.

*   manuelle Sachkonteneingabe bei Stücklisten?
    IF NOT msegk-konto IS INITIAL.
      dm07m-xkman = x.
    ENDIF.
    PERFORM fuss_ergaenzen.
    CLEAR fuss-xprue.
    fuss-fcode = fcod-np.
    fuss-xselp = fcausw-xselp.
    fuss-xsels = fcausw-xselp.
    IF NOT fcausw-xlist IS INITIAL.
      fuss-xselk = t158-xsele.
    ENDIF.
    IF fuss-erfmg IS INITIAL.
      CLEAR fuss-xselk.
    ENDIF.
    PERFORM fuss_nach_yfuss.
  ENDLOOP.
  PERFORM fuss_aus_yfuss.
  FREE xstpox.
  CLEAR: index_l, index_z.
  CLEAR: rm07m-capid, rm07m-matnr, rm07m-smeng, rm07m-stlal.
  IF xaktiv IS INITIAL.
    xaktiv = x.
  ENDIF.
  IF xt437e_check IS INITIAL.
    xt437e_check = x.
  ENDIF.

ENDFORM.