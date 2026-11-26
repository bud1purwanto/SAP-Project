*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WE_PRUEFEN                                    *
*---------------------------------------------------------------------*
*        Die Fusszeile fuer die Transaktionen Wareneingang zur        *
*        Bestellung bei Neueingabe der Bestellung wird geprueft.      *
*---------------------------------------------------------------------*
FORM fusszeile_we_pruefen USING xkont TYPE c
                                IS_ENHANCEMENT TYPE ISU_FUSSZEILE_WE_PRUEFEN."#EC *

  DATA: l_kzbws TYPE kzbws,                                    " 607325
        l_xkzbws_change TYPE c.                                " 627312

  DATA: LS_ISU_UMRECHNEN_ME TYPE ISU_UMRECHNEN_ME,          "IS2ERP
        LS_ISU_MATERIAL_PRUEFEN TYPE ISU_MATERIAL_PRUEFEN,  "IS2ERP
* The following variable have no effect for the Core Code
* conditions, its value changes only in the switched code.
* This usage makes possible to avoid enh. sections.
        lv_ad_rec_po_gr VALUE space.   "EHP604 ADSUB GM080415

ENHANCEMENT-POINT FUSSZEILE_WE_PRUEFEN_01 SPOTS ES_SAPMM07M.


  PERFORM werk_pruefen(sapfm07m) USING    x
                                       mseg-werks
                                      vm07m-bwkey
                                      dm07m-bwmod
                                      dm07m-xeink
                                      dm07m-xbkng
                                      vm07m-xvkbw
                                       mseg-bukrs
                                      dm07m-ktopl
                                      dm07m-periv
                                       mseg-waers
                                       mkpf-budat
                                       mseg-gjahr
                                      vm07m-monat
                                       mseg-xruem
                                       mseg-xruej
                                      vm07m-lfgja
                                      vm07m-lfmon
                                      dm07m-fabkl
                                      dm07m-kzxab.
  dm07m-xlbpd = t001k-xlbpd.
  dm07m-xewrx = t001k-xewrx.
  dm07m-xefre = t001k-xefre.
  dm07m-efrej = t001k-efrej.
  dm07m-x2fdo = t001k-x2fdo.
  dm07m-xelik = t159l-xelik.
  dm07m-xlaut = t159l-xlaut.
  dm07m-xwmhd = t159l-xwmhd.
  IF NOT xmbwl IS INITIAL AND xmigo IS INITIAL AND              "1040234
           mseg-kzbew = f AND xcanc IS INITIAL.                 "1040234
       dm07m-elikz_input = mseg-elikz.                         "n1058907
  ENDIF.                                                       "n1058907
  IF mseg-parbu IS INITIAL OR NOT mseg-kzbew = f.
    mseg-parbu = mseg-bukrs.
  ENDIF.
  PERFORM sonderbestkz_pruefen(sapfm07m) USING mseg-sobkz
                                              vm07m-sobfi
                                              vm07m-soblo
                                              vm07m-sobvo.
  IF mseg-matnr IS INITIAL.
    mseg-menge = 0.
  ELSE.
    biwe-lgort = mseg-lgort.
    biwe-charg = mseg-charg.
    DATA: lifnr LIKE mseg-lifnr,
          kunnr LIKE mseg-kunnr,
          kdauf LIKE mseg-kdauf,
          kdpos LIKE mseg-kdpos,
          plpla LIKE mseg-plpla,
          bwtar LIKE mseg-bwtar,
          pspnr LIKE mseg-ps_psp_pnr.

ENHANCEMENT-POINT FUSSZEILE_WE_PRUEFEN_04 SPOTS ES_SAPMM07M STATIC.

    DATA: sobkz LIKE mseg-sobkz.
    DATA: soblo LIKE vm07m-soblo.
    sobkz = mseg-sobkz.
    soblo = vm07m-soblo.

ENHANCEMENT-POINT FUSSZEILE_WE_PRUEFEN_05 SPOTS ES_SAPMM07M.

    CLEAR: lifnr, kunnr, kdauf, kdpos, plpla, pspnr.
    bwtar = mseg-bwtar.
    IF mseg-sobkz = o AND mseg-kzbew = b.
      CLEAR: sobkz, soblo.
    ENDIF.
    IF mseg-sobkz = e AND NOT mseg-kzbws IS INITIAL.
      kdauf = mseg-mat_kdauf.
      kdpos = mseg-mat_kdpos.
    ENDIF.
    IF mseg-sobkz = q AND NOT mseg-kzbws IS INITIAL.
      pspnr = mseg-mat_pspnr.
    ENDIF.
*   protect KZBWS against changes, same logic as in FUSSZEILE_WA_PRUEFEN
*   KZBWS is finally checked and set in LAGERORTDATEN (MM07MFL0)
    l_kzbws = mseg-kzbws.                                       " 607325

ENHANCEMENT-POINT FUSSZEILE_WE_PRUEFEN_06 SPOTS ES_SAPMM07M.

    PERFORM material_pruefen(sapfm07m) USING mseg-matnr
                                            vm07m-bwkey
                                             MSEG-BWTAR
                                             mseg-werks
                                                  space
                                                  space
                                             mseg-shkzg
                                                  sobkz
                                            vm07m-sobfi
                                                  soblo
                                            vm07m-sobvo
                                                  lifnr
                                                  kunnr
                                                  kdauf
                                                  kdpos
                                                  plpla
                                            vm07m-lfgja
                                            vm07m-lfmon
                                                  x
                                                  space
                                             mseg-xruem
                                            vm07m-xvkbw
                                            dm07m-xbkng
                                            dm07m-xlong
                                            dm07m-xsmng
                                            dm07m-xsvng
                                            dm07m-xskng
                                            dm07m-xsong
                                            dm07m-xswng
                                            dm07m-xseng
                                            dm07m-xsqng
                                            vm07m-xstau
                                                  pspnr
                                            mseg-kzbws
                                            dm07m-xlaut
                                            dm07m-berid         " 454320
                                            LS_ISU_MATERIAL_PRUEFEN    "IS2ERP
                                    CHANGING    l_xkzbws_change." 627312

ENHANCEMENT-POINT FUSSZEILE_WE_PRUEFEN_07 SPOTS ES_SAPMM07M.

    mseg-kzbws = l_kzbws.                                      " 607325
    IF NOT dm07m-rmbew  IS INITIAL AND mseg-kzbew = b
      AND NOT mseg-kzvbr IS INITIAL AND NOT mseg-bwtar IS INITIAL
      AND mseg-kzbws IS INITIAL.
      CALL FUNCTION 'MB_CHECK_T160M'
           EXPORTING
                i_msgnr  = '326'
                i_msgv1  = vm07m-bwkey
                i_msgv2  = mseg-matnr
                i_output = x.
    ENDIF.
    mseg-lgort = biwe-lgort.
    mseg-charg = biwe-charg.
    mseg-bwtar = bwtar.
    IF ( vm07m-xchpf IS INITIAL AND NOT dm07m-xchar IS INITIAL
         AND NOT mseg-kzbew = o AND NOT mseg-bwtar IS INITIAL ) OR
       ( NOT vm07m-xchpf IS INITIAL AND mseg-charg IS INITIAL
         AND NOT mseg-kzbew = o AND NOT vm07m-kzbaa IS INITIAL ).
ENHANCEMENT-POINT EHP604_FUSSZEILE_WE_PRUEFEN_01 SPOTS ES_SAPMM07M.
*     for MIGO this is processed after user entry               "782011
*       -> allow <blank> batch for internal numbering           "782011
*          but only PO-based with autom.batch                   "917127
      IF NOT ( xmigo = x AND mseg-kzbew = b                     "917127
               AND vm07m-kzbaa = x )                            "917127
         AND lv_ad_rec_po_gr IS INITIAL.                     "GM0804015
        mseg-charg = mseg-bwtar.
      ENDIF.                                                    "782011
    ENDIF.
* if mb_create.. supplies us with a qty in base unit of measure
* -> take over this qty and don't calculate (xnocon);
* if it's a reversal -> no unit conversion, take over from original doc.
    IF DM07M-XNOCON IS INITIAL AND                 "note 162969 + 318320
       not vm07m-xstor = zwei.
      mseg-menge = 0.
      IF mseg-bstme  = mseg-erfme.
        dm07m-umrez = vm07m-bumrz.
        dm07m-umren = vm07m-bumrn.
      ELSE.
        CLEAR: dm07m-umrez,dm07m-umren.
      ENDIF.
ENHANCEMENT-POINT FUSSZEILE_WE_PRUEFEN_02 SPOTS ES_SAPMM07M.
      PERFORM UMRECHNEN_ME(SAPFM07M) USING MSEG-MATNR
                                           mseg-charg    "ALRK014884 SW
                                           mseg-werks    "ALRL014884 SW
*                                          mseg-cuobj   "ALRK014884 SW
                                           mseg-meins
                                           mseg-erfme
                                           mseg-menge
                                           mseg-erfmg
                                          dm07m-umrez
                                          dm07m-umren
                                          LS_ISU_UMRECHNEN_ME.   "IS2ERP

ENHANCEMENT-POINT FUSSZEILE_WE_PRUEFEN_03 SPOTS ES_SAPMM07M.

    ENDIF.
  ENDIF.
  PERFORM mengenstring_finden(sapfm07m) USING mseg-bwart
                                              mseg-wertu
                                              mseg-mengu
                                              mseg-sobkz
                                              mseg-kzbew
                                              mseg-kzzug
                                              mseg-kzvbr
                                              mseg-matnr
                                              mseg-kzbws.
  PERFORM segmentdaten_t156s_setzen(sapfm07m).
  PERFORM bewegungstext_lesen(sapfm07m) USING mseg-bwart
                                              mseg-sobkz
                                              mseg-kzbew
                                              mseg-kzzug
                                              mseg-kzvbr
                                             dm07m-btext.

*-- Remove batch if not necessary                           "note 327693
  IF MSEG-MATNR IS INITIAL OR DM07M-XCHAR IS INITIAL OR     "note 327693
     ( VM07M-KZWES = S AND t156-bustr NE '107'              "SIT
       AND t156-bustr NE '167') OR                          "SIT
     ( VM07M-XCHPF IS INITIAL AND DM07M-XLORT IS INITIAL    "note 327693
       AND t156-bustr NE '107' AND t156-bustr NE '167' ).   "SIT
    CLEAR MSEG-CHARG.                                     "note 327693
  ENDIF.                                                    "note 327693
* IF ( mseg-kzbew = b AND NOT mseg-kzvbr IS INITIAL ) OR    "note 584843
  IF ( mseg-kzbew = b ) OR                                  "note 584843
     ( mseg-kzbew = f AND ( mseg-kzbws = a OR mseg-kzbws IS INITIAL ) ).
*-- Prüfen Charge auf Sonderzeichen
    DATA: local_charg like mseg-charg.
    MOVE mseg-charg to local_charg.
    CONDENSE local_charg no-gaps.
    IF NOT mseg-charg IS INITIAL AND NOT vm07m-xchpf IS INITIAL AND
       NOT local_charg EQ '*'.
      DATA: flag1, char1.
      PERFORM charge_character_check(sapfm07m) USING mseg-charg
                                            CHANGING flag1
                                                     char1.
      IF NOT flag1 IS INITIAL.
        SET CURSOR FIELD 'MSEG-CHARG'.
        MESSAGE e567(m3) WITH char1.
      ENDIF.
    ENDIF.

    PERFORM kontierung_lesen USING  mseg-parbu
                                   dm07m-parwk
                                   dm07m-umkpl
                                   dm07m-umper
                                   dm07m-umwae
                                    mkpf-budat
                                   dm07m-umgja
                                   dm07m-ummon
                                   dm07m-konto
                                    mseg-anln1.

*-- Kontierung prüfen bei WE zum Auftrag hier nur, wenn bereits
*-- Bewertungsart gesetzt ist. Ansonsten erst in Lagerortdaten...
    IF mseg-kzbew = f AND NOT dm07m-bwtty IS INITIAL.
      CHECK NOT mseg-bwtar IS INITIAL AND NOT dm07m-bklas IS INITIAL.
    ENDIF.

*   IF MSEG-KZBEW = F AND VM07M-XCHPF IS INITIAL AND
*      NOT DM07M-XCHAR IS INITIAL AND NOT MSEG-BWTAR IS INITIAL.
    PERFORM kontierung_pruefen.
*   ENDIF.
  ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*        FORM FUSSZEILE_ASN_WE_PRUEFEN                                *
*---------------------------------------------------------------------*
*        Die Fusszeile fuer die Transaktionen Wareneingang zur        *
*        Bestellung bei Neueingabe der Bestellung wird geprueft.      *
*---------------------------------------------------------------------*
* SPE ST 27.05.2004
* VL-MM Consistency
* The new form calls the Function 'BORWE_VL_MM_CHECK_ASN_WE', which makes new checking
* for inbound delivery and fills the global field g_vbtyp_v and tables gt_lips, gt_likp.
* The form is being used for normal goods movement and return delivery processes.

FORM fusszeile_asn_we_pruefen.

  DATA:
    l_vbeln      LIKE lips-vbeln,
    l_vbelp      LIKE lips-posnr,
    l_md_storno  TYPE xfeld VALUE space,

    ls_likp LIKE likpvb,
    ls_prot TYPE sprot_u,

    lt_lips LIKE lipsvb OCCURS 0,
    lt_prot TYPE sprot_u_tab.

    CHECK fuss-matnr = mseg-matnr.
*   Determine VBELN, VBELP
    IF NOT ( fuss-vbeln IS INITIAL ) AND
       NOT ( fuss-vbelp IS INITIAL ).
       l_vbeln = fuss-vbeln.
       l_vbelp = fuss-vbelp.
    ELSEIF NOT ( dm07m-vbeln_vl IS INITIAL ) and
           NOT ( dm07m-vbelp_vl IS INITIAL ).
       l_vbeln = dm07m-vbeln_vl.
       l_vbelp = dm07m-vbelp_vl.
    ENDIF.
*   Reversal ?
    IF FUSS-XSTOR EQ '2' .                              "n_1452282
      l_md_storno = 'X'.
    ENDIF.
*   Checks
    IF NOT ( l_vbeln IS INITIAL ) AND
       NOT ( L_VBELP IS INITIAL ) AND                       "v_n_1248915
             IM_PROCESS <> 'L'    AND "delivery posts
             XDELIV     <> 'X'    AND "delivery is created
             MKPF-BFWMS <> '1'    AND                       "^_n_1248915
             T156-KZWES <> 'S'.       "2-step-GR               n_1373027
      REFRESH lt_prot[].
      IF xebefu-pstyp NE '3' OR t158-kzbew NE 'O'.
      CALL FUNCTION 'BORWE_VL_MM_CHECK_ASN_WE'
        EXPORTING
          I_VBELN                = l_vbeln
          I_POSNR                = l_vbelp
          I_ERFMG                = mseg-erfmg
          I_ERFME                = mseg-erfme
          I_BWART                = mseg-bwart
          IF_MD_STORNO           = l_md_storno
          IS_MSEG                = mseg
        IMPORTING
          ES_LIKP                = ls_likp
        TABLES
          ET_LIPS                = lt_lips
          ET_PROT                = lt_prot.
      ENDIF.
      LOOP AT lt_prot INTO ls_prot.
         MESSAGE ID ls_prot-ag TYPE ls_prot-severity
                 NUMBER ls_prot-msgnr
                 WITH ls_prot-var1 ls_prot-var2
                      ls_prot-var3 ls_prot-var4.
      ENDLOOP.
      READ TABLE gt_likp WITH KEY vbeln = ls_likp-vbeln
           TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND ls_likp TO gt_likp.
        APPEND LINES OF lt_lips TO gt_lips.
      ENDIF.
* new added delivery lines within the same MIGO call       "v_n_1429149
      READ TABLE GT_LIPS WITH KEY VBELN = L_VBELN
                                  POSNR = L_VBELP
           TRANSPORTING NO FIELDS.
      IF SY-SUBRC <> 0.
        REFRESH GT_LIPS.
        APPEND LINES OF LT_LIPS TO GT_LIPS.
      ENDIF.                                               "^_n_1429149
    ENDIF.

ENDFORM.

*---- GET_COMMON_TAB --------------------------------------------------
FORM get_common_tab
        using i_iname type char30
              et_tab  type standard table.
  DATA:
    l_error     type xfeld value space,
    l_iname     like i_iname,
    lr_itab     type ref to data.

  FIELD-SYMBOLS:
    <ls_itab> TYPE ANY,
    <lt_itab> TYPE STANDARD TABLE,
    <ls_any>  TYPE ANY.

  CONCATENATE i_iname '[]' INTO l_iname.
* Header is referenced
  ASSIGN (i_iname) TO <ls_itab>.
  CHECK sy-subrc = 0.
* Internal table is referenced
  ASSIGN (l_iname) TO <lt_itab>.
  CHECK sy-subrc = 0.
  REFRESH et_tab.
* Read all entries
  LOOP AT <lt_itab> ASSIGNING <ls_itab>.
    GET REFERENCE OF <ls_itab> INTO lr_itab.
*   Fill pointer lr_itab in pointer <ls_any>
    ASSIGN lr_itab->* TO <ls_any>.
    IF sy-subrc <> 0.
      l_error = 'X'. EXIT.
    ENDIF.
    APPEND <ls_any> TO et_tab.
  ENDLOOP.
  IF l_error IS INITIAL.
    CLEAR sy-subrc.
  ENDIF.

ENDFORM.