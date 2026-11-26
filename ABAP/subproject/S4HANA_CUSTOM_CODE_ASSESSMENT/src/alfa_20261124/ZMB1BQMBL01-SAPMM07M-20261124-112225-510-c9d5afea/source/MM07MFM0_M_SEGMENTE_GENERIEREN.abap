*----------------------------------------------------------------------*
*       FORM M-SEGMENTE_GENERIEREN                                     *
*----------------------------------------------------------------------*
*       Die Segmente des Materialbelegs werden generiert.              *
*       Ausserdem werden ggf. DISP-Sätze erzeugt.                      *
*----------------------------------------------------------------------*

* avoid error KI 235 during cancellation of GR document;    "n1335853
* consider the values of the related entry of table ZDM07M  "n1335853

FORM m-segmente_generieren.

  TYPES: BEGIN OF ty_s_struct_map_table,
           parent_id TYPE mb_line_id,
           line_id   TYPE mb_line_id,
         END OF ty_s_struct_map_table.
  DATA: cuobj LIKE dm07m-cuobj,
        stdpd LIKE dm07m-stdpd,
        status_not_allowed(1)  TYPE c,
        l_fullprod_transfer_line_id TYPE mb_line_id,
        lt_struct_map_table TYPE SORTED TABLE OF ty_s_struct_map_table
                            WITH NON-UNIQUE KEY parent_id,
        ls_struct_map_table TYPE ty_s_struct_map_table.
  DATA: ls_isu_umrechnen_me TYPE isu_umrechnen_me.          "IS2ERP

* A&D GPD-MM interface check - EhP4
  DATA: lt_imseg TYPE STANDARD TABLE OF imseg,
        ls_mseg  TYPE mseg,
        ls_imseg TYPE imseg,
        ls_imkpf TYPE imkpf.

* BP0110622: EHP604 Retrofit A&D SUB conflict with IS-OIL
  DATA: lv_sub_oil_conflict TYPE c.

  FIELD-SYMBOLS: <ls_mseg> TYPE mseg.

ENHANCEMENT-POINT M-SEGMENTE_GENERIEREN_02 SPOTS ES_SAPMM07M STATIC .

ENHANCEMENT-POINT M-SEGMENTE_GENERIEREN_03 SPOTS ES_SAPMM07M .

  PERFORM jv_komv_clear.
  CLEAR: a_zeile,
         index_l,
         kanba,
         xoarc,
         matnum,
         charge,
         cuobj,
         stdpd.

* begin ----------------------------------------------------"MAA2
* check and adapt the field MAA_URZEI
  IF NOT xmbwl           IS INITIAL     AND
     NOT xaccounting[]   IS INITIAL.

    CALL METHOD go_mmim_maa_2->reorganize_maa_urzei
      CHANGING
        ct_xmseg = zmseg[].
  ENDIF.
* end ------------------------------------------------------"MAA2

  LOOP AT zmseg.
ENHANCEMENT-POINT M-SEGMENTE_GENERIEREN_01 SPOTS ES_SAPMM07M.
    IF NOT mbval IS INITIAL.
      zmseg-xwoff = x.
    ENDIF.
    READ TABLE zdm07m INDEX zmseg-zeile.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'ZDM07M' zmseg-zeile.
    ENDIF.
    READ TABLE zvm07m INDEX zmseg-zeile.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'ZVM07M' zmseg-zeile.
    ENDIF.
    a_zeile = a_zeile + 1.
    IF druck IS INITIAL.
      IF NOT zdm07m-kzdru IS INITIAL.
        druck = x.
      ENDIF.
    ENDIF.
    IF kanba IS INITIAL.
      IF NOT zdm07m-kanba IS INITIAL.
        kanba = zdm07m-kanba.
      ENDIF.
    ENDIF.
    IF xoarc IS INITIAL.
      IF NOT zdm07m-xoarc IS INITIAL.
        xoarc = x.
      ENDIF.
    ENDIF.
    IF zvm07m-xstor = eins.
      CLEAR: zmseg-smbln,
             zmseg-sjahr,
             zmseg-smblp.
    ENDIF.

    IF mseg-kzbew = b AND upd_ean11 IS INITIAL.
*     consider the values of the related entry of ZDM07M    "n1335853
      IF NOT zdm07m-ean11     IS INITIAL OR                 "n1335853
         NOT zdm07m-ean11_bme IS INITIAL OR                 "n1335853
         NOT zdm07m-ean11_kon IS INITIAL.                   "n1335853
        upd_ean11 = x.
      ENDIF.
    ENDIF.

    xmseg = zmseg.
    xvm07m = zvm07m.
    xmseg-zeile = a_zeile.
    xvm07m-zeilv = xmseg-zeile.
    IF NOT inventur IS INITIAL.
      yibuz-zeili = zmseg-zeile.
      yibuz-zeile = xmseg-zeile.
      APPEND yibuz.
    ENDIF.
    ymbuz-zeile = ymbuz-zeilz = zmseg-zeile.
*   ymbuz-xauto = xmseg-xauto.
    CLEAR ymbuz-xauto.

ENHANCEMENT-SECTION     M_SEGMENTE_GENERIEREN_01 SPOTS ES_SAPMM07M.
    IF NOT xvm07m-smard IS INITIAL OR
       xmseg-sobkz = e OR xmseg-sobkz = q
       OR xmseg-sobkz = o.
      MOVE-CORRESPONDING zdm07m TO xmdcp.
      MOVE-CORRESPONDING xvm07m TO xmdcp.
      MOVE-CORRESPONDING xmseg TO xmdcp.
      IF xmseg-sobkz = o.
        xmdcp-lbear = xmseg-emlif.
      ENDIF.
      xmdcp-bemng = xmseg-menge.
      IF xmseg-kzbew = b OR xmseg-kzbew = f.
        IF zdm07m-umrez IS INITIAL.
          zdm07m-umrez = zdm07m-umren = 1.
        ENDIF.

        xmdcp-urmng = 0.
        IF t158-vgart <> vgart_ws.                          "401524


          PERFORM umrechnen_me(sapfm07m) USING xmseg-matnr
                                               xmseg-charg  "ALR014884
                                               xmseg-werks  "ALR014884
*                                              xmseg-cuobj    "ALR014884
                                               xmseg-meins
                                               zmseg-bstme
                                               xmdcp-urmng
                                              zdm07m-bsmng
                                              zdm07m-umrez
                                              zdm07m-umren
                                              ls_isu_umrechnen_me. "IS2ERP
        ENDIF.                                              "401524
        xmdcp-gemng = 0.
        PERFORM umrechnen_me(sapfm07m) USING xmseg-matnr
                                             xmseg-charg    "ALR014884
                                             xmseg-werks    "ALR014884
*                                            xmseg-cuobj     "ALR014884
                                             xmseg-meins
                                             zmseg-bstme
                                             xmdcp-gemng
                                            zdm07m-wemng
                                            zdm07m-umrez
                                            zdm07m-umren
                                            ls_isu_umrechnen_me. "IS2ERP
        IF xmseg-kzbew = f.
          xmdcp-bdter = zdm07m-dgltp.
        ENDIF.
      ELSE.
        IF xmseg-kzbew IS INITIAL.                          "204573
          IF NOT xmseg-rspos IS INITIAL.
            xmdcp-urmng = zdm07m-bdmng.
            xmdcp-gemng = zdm07m-enmng.
          ENDIF.
        ENDIF.
      ENDIF.
      APPEND xmdcp.
*     Bei der Einlagerung einer Zwei-Schritt-Umlagerung ohne Umlagerbe-
*     stellung muß ein zweiter MDCP-Satz erzeugt werden (ohne Lagerort)
      IF xvm07m-kbbsa = '05'
         AND zdm07m-kzuml IS INITIAL.
        CLEAR xmdcp-lgort.
        APPEND xmdcp.
      ENDIF.
    ENDIF.
END-ENHANCEMENT-SECTION.
    IF xvm07m-pstyp = drei AND xmseg-kzbew = b
       AND NOT xmseg-xauto = l.  "not for empties               "1017190
      READ TABLE zmbuz INDEX zmseg-zeile.
*     This coding is only processed for the goods receipt position
*     in case of subcontracting. Therefore we can read the components
*     from ZEKLB.
*     Note 380695 and 329696 changed meaning of ZMBUZ-URZEY:     "488743
*     URZEY is a pointer to URZEI in ZMSEG                       "488743
*     ('ZMBUZ-URZEY=ZMSEG-URZEI' in form BUCHEN_INITIALISIEREN)  "488743
*     ZEKLB-ZEILO has the same meaning, so that URZEY can be     "488743
*     used to read ZEKLB.                                        "488743
      LOOP AT zeklb WHERE zeilo = zmbuz-urzey.              "488743
        zeklb-zeilx = xmseg-zeile.
        MODIFY zeklb.
      ENDLOOP.
    ENDIF.
    IF xmseg-bustw <> bustw_wa04.
      xvm07m-xlifu = zdm07m-xlifo.
    ENDIF.
*   Note 365071 makes an attempt to improve the situation.
*   Cannot be implemented in this support package. See internal memo.
    IF NOT zdm07m-kzuml IS INITIAL.
      IF xmseg-pprctr IS INITIAL.
        xmseg-pprctr = zdm07m-umprc.
      ENDIF.
      IF xmseg-pargb IS INITIAL.
        xmseg-pargb  = zdm07m-umgsb.
      ENDIF.
    ENDIF.
    IF NOT zdm07m-kzuml IS INITIAL AND xmseg-shkzg = h.
      CLEAR xvm07m-xfmat.
    ENDIF.
ENHANCEMENT-POINT MM07MFM0_M_SEGMENTE_GENERIE_07 SPOTS ES_SAPMM07M.

*   takeover delivery number                                   "1668550
    IF NOT zvm07m-vbelp IS INITIAL.                            "1673670
      xmseg-vbeln_im = zvm07m-vbeln.                           "1668550
      xmseg-vbelp_im = zvm07m-vbelp.                           "1668550
    ELSE.                                                      "1668550
      xmseg-vbeln_im = zdm07m-vbeln_vl.                        "1668550
      xmseg-vbelp_im = zdm07m-vbelp_vl.                        "1668550
    ENDIF.                                                     "1668550

    APPEND xvm07m.
    APPEND xmseg.
    APPEND ymbuz.
    PERFORM jv_umlager_konditionen_a.
ENHANCEMENT-POINT MM07MFM0_M_SEGMENTE_GENERIE_03 SPOTS ES_SAPMM07M.
    IF NOT zdm07m-kzuml IS INITIAL.
      a_zeile = a_zeile + 1.
      xmseg = zmseg.
      xvm07m = zvm07m.
      xmseg-matnr = zmseg-ummat.
      xmseg-matbf = zmseg-ummab.
      xmseg-werks = zmseg-umwrk.
      xmseg-lgort = zmseg-umlgo.
      xmseg-charg = zmseg-umcha.
      xmseg-zustd = zmseg-umzst.
      xmseg-bwtar = zmseg-umbar.
      xmseg-sobkz = zmseg-umsok.
      xmseg-mat_kdauf = zmseg-kdauf.
      xmseg-mat_kdpos = zmseg-kdpos.
      xmseg-mat_pspnr = zmseg-ps_psp_pnr.
      xmseg-kzbws = zdm07m-umkzbws.
      xmseg-xruem = zdm07m-umxrm.
      xmseg-xruej = zdm07m-umxrj.
      xmseg-bukrs = zdm07m-umbuk.
      xmseg-gjahr = zdm07m-umgja.
      xmseg-waers = zdm07m-umwae.
      xmseg-mengu = zdm07m-ummen.
      xmseg-wertu = zdm07m-umwer.
      xmseg-vprsv = zdm07m-umvpr.
      xmseg-lbkum = zdm07m-umlbk.
      xmseg-salk3 = zdm07m-umsal.
      xvm07m-smarc = zdm07m-umarc.
      xvm07m-smard = zdm07m-umard.
      xvm07m-smchb = zdm07m-umchb.
      xvm07m-smbpr = zdm07m-umbpr.
      xvm07m-smlib = zdm07m-umlib.
      xvm07m-smkol = zdm07m-umkol.
      xvm07m-smeik = zdm07m-umeik.
      xvm07m-smklk = zdm07m-umklk.
      xvm07m-smkub = zdm07m-umkub.
      xvm07m-sekpo = zdm07m-uekpo.
      xvm07m-sekla = zdm07m-uekla.
      xvm07m-sfaup = zdm07m-ufaup.
      xvm07m-smres = zdm07m-umres.
      xvm07m-bwkey = zdm07m-umbwk.
      xvm07m-mlmaa = zdm07m-ummlm.
      xvm07m-mlast = zdm07m-ummla.
      xvm07m-lfgja = zdm07m-umlfg.
      xvm07m-lfmon = zdm07m-umlfm.
      xvm07m-lbbsa = zdm07m-umlbb.
      xvm07m-kbbsa = zdm07m-umkbb.
      xvm07m-eisbe = zdm07m-umeis.
      xvm07m-minbe = zdm07m-umminbe.
      xvm07m-diskz = zdm07m-umdis.
      xvm07m-disst = zdm07m-umdit.
      xvm07m-mtvfp = zdm07m-ummtv.
      xvm07m-miskz = zdm07m-ummis.
      xvm07m-vrmod = zdm07m-umvrm.
      xvm07m-vint1 = zdm07m-umvi1.
      xvm07m-vint2 = zdm07m-umvi2.
      xvm07m-hrkft = zdm07m-umhrk.
      xvm07m-hkmat = zdm07m-umhkm.
      xvm07m-xvkbw = zdm07m-umxvk.
      xvm07m-dismm = zdm07m-umdismm.
      xvm07m-prdha = zdm07m-umprdha.
      xvm07m-satnr = zdm07m-umsatnr.
      xvm07m-bwvor = zdm07m-umbwvor.
      xvm07m-bwscl = zdm07m-umbwscl.
      xvm07m-saiso = zdm07m-umsaiso.
      xvm07m-saisj = zdm07m-umsaisj.
      xvm07m-voleh = zdm07m-umvoleh.
      xvm07m-plgtp = zdm07m-umplgtp.
      xvm07m-servg = zdm07m-umservg.
      xvm07m-kzbaa = zdm07m-umkzbaa.
      xvm07m-xchpf = zdm07m-umxch.
      xvm07m-attyp = zdm07m-umatt.
      xvm07m-kaln1 = zdm07m-umkal.
      xvm07m-kalnr = zdm07m-umkalnr.
      xvm07m-mtart = zdm07m-ummta.
      xvm07m-xhead = zdm07m-umxhead.
      xvm07m-bflme = zdm07m-umbflme.
      xmseg-ummat  = zmseg-matnr.
      xmseg-ummab  = zmseg-matbf.
      xmseg-umwrk  = zmseg-werks.
      xmseg-umlgo  = zmseg-lgort.
      xmseg-umcha  = zmseg-charg.
      xmseg-umzst  = zmseg-zustd.
      xmseg-umbar  = zmseg-bwtar.
      xmseg-umsok  = zmseg-sobkz.
      xmseg-kdauf = zmseg-mat_kdauf.
      xmseg-kdpos = zmseg-mat_kdpos.
      xmseg-ps_psp_pnr  = zmseg-mat_pspnr.
      xmseg-zustd_t156m = zdm07m-umzst_t156m.
      xmseg-cuobj_ch    = zdm07m-umcuobj_ch.
      xmseg-vkwrt  = zdm07m-umvkw.
      xmseg-vkwra  = zdm07m-umvka.
      xmseg-lgnum  = zdm07m-umlgn.
      xmseg-lgtyp  = zdm07m-umlgt.
      xmseg-lgpla  = zdm07m-umlgp.
      xmseg-bestq  = zdm07m-umbsq.
      xmseg-bwlvs  = zdm07m-umblv.
      xmseg-xblvs  = zdm07m-umxbl.
      xmseg-vschn  = zdm07m-umvos.
      xmseg-nschn  = zdm07m-umnas.
      xmseg-dypla  = zdm07m-umdyp.
      xvm07m-tbfkz = zdm07m-umtbf.
      xvm07m-autta = zdm07m-umaut.
      xvm07m-trart = zdm07m-umtra.
      xvm07m-betyp = zdm07m-umbty.
      xvm07m-benum = zdm07m-umben.
      xvm07m-monat = zdm07m-ummon.                          "HW 165054
      xvm07m-lgntb = zdm07m-umlgntb.
      xmseg-tbpri  = zdm07m-umtbp.
*     takeover delivery number for xauto line                  "1668550
      IF NOT zvm07m-vbelp IS INITIAL.                          "1673670
        xmseg-vbeln_im = zvm07m-vbeln.                         "1668550
        xmseg-vbelp_im = zvm07m-vbelp.                         "1668550
      ELSE.                                                    "1668550
        xmseg-vbeln_im = zdm07m-vbeln_vl.                      "1668550
        xmseg-vbelp_im = zdm07m-vbelp_vl.                      "1668550
      ENDIF.                                                   "1668550
*     If the partner posting is a material posting, PRCTR and GSBER
*     are filled with the data from the material. Otherwise,
*     take the fields from the accounting side of the line.
*     Implemented for SDP 4.62, but the effect is also visible
*     for integrated postings.
      IF  cl_mmim_cross_system=>valuated_movement_check(    "sdp462
            i_wertu = zdm07m-umwer                          "sdp462
            i_sobkz = zmseg-umsok                           "sdp462
            i_kzbws = zdm07m-umkzbws                        "sdp462
            i_kzvbr = zmseg-kzvbr ) = abap_true.            "sdp462
        xmseg-gsber  = zdm07m-umgsb.                        "sdp462
        xmseg-prctr  = zdm07m-umprc.                        "sdp462
      ELSE.                                                 "sdp462
*BEGIN NOTE 978159
* If there is no cost object involved, profit center should be
* taken from the material as field 'zmseg-pprctr' will be blank
* during manual entry. Posting via MB_CREATE, field 'zmseg-pprctr'
* is always filled.
        IF ( mseg-kostl IS INITIAL AND mseg-aufnr IS INITIAL AND
             mseg-ps_psp_pnr IS INITIAL AND mseg-kdauf IS INITIAL AND
             xmbwl IS INITIAL  ).
          IF zmseg-pprctr IS INITIAL.
            xmseg-prctr = zdm07m-umprc.
          ELSE.
            xmseg-prctr = zmseg-pprctr.
          ENDIF.

          IF zmseg-pargb IS INITIAL.
            xmseg-gsber = zdm07m-umgsb.
          ELSE.
            xmseg-gsber = zmseg-pargb.
          ENDIF.
        ELSE.
          xmseg-prctr = zmseg-pprctr.
          xmseg-gsber = zmseg-pargb.
        ENDIF.
      ENDIF.
*END NOTE 978159
      xmseg-pargb  = zmseg-gsber.
      xmseg-pprctr = zmseg-prctr.
      xmseg-vfdat = zdm07m-umvfdat.
      xmseg-hsdat = zdm07m-umhsdat.
      xmseg-xauto = x.
ENHANCEMENT-POINT MM07MFM0_M_SEGMENTE_GENERIE_04 SPOTS ES_SAPMM07M.
      xvm07m-vkorg = zdm07m-umvkorg.                        "HUM
      xvm07m-vtweg = zdm07m-umvtweg.                        "HUM
      xvm07m-vstel = zdm07m-umvstel.                        "HUM
      xvm07m-spart = zdm07m-umspart.                        "HUM
      xvm07m-xhupf = zdm07m-umxhupf.                        "HUM
      xvm07m-sdkun = zdm07m-umsdkun.                        "HUM
      xvm07m-sdlif = zdm07m-umsdlif.                        "HUM
      IF NOT xmseg-matnr = zmseg-matnr.
        xmseg-erfme = xmseg-meins.
        xmseg-erfmg = xmseg-menge.
      ENDIF.
      IF NOT xmseg-smblp IS INITIAL.
        xmseg-smblp = xmseg-smblp + 1.
      ENDIF.
      xmseg-shkzg = s.
      IF zmseg-shkzg = s.
        xmseg-shkzg = h.
      ENDIF.
      IF xmseg-shkzg = h.
        CLEAR xvm07m-xfmat.
      ENDIF.
* For BWH Update the GTS Stock type change      *
      xmseg-spe_gts_stock_ty = zdm07m-spe_um_gts_st_ty.
* For BWH Update the GTS Stock type change      *


      IF NOT zdm07m-sernp IS INITIAL AND
      NOT xmseg-kzbew = l AND NOT im_process = l.
*   Systemadministrator benachrichtigen: Fehler bei
        IF NOT zdm07m-kzuml IS INITIAL AND xmseg-shkzg = h.
          cuobj    = zdm07m-cuobj.
          stdpd    = zdm07m-stdpd.
          matnum   = xmseg-ummat.
          charge   = xmseg-umcha.
        ELSE.
          matnum   = xmseg-matnr.
          charge   = xmseg-charg.
          cuobj    = zdm07m-ucuob.
          stdpd    = zdm07m-ustdp.
        ENDIF.
        CALL FUNCTION 'SERIALPROFILE_CHECK'
          EXPORTING
*           material           = xmseg-matnr
            material           = matnum
            operation          = op_mmcc
            profile            = zdm07m-sernp
            quantity           = zdm07m-anzsn
            mblnr              = dmblnr
            mjahr              = mkpf-mjahr
            mblnr_old          = dmblnr
            mjahr_new          = mkpf-mjahr
            zeile              = xmseg-zeile
*           zeile_new          = a_zeile
            zeile_new          = xmseg-zeile
            blart              = mkpf-blart
            bwart              = xmseg-bwart
            shkzg              = xmseg-shkzg
            m_werk             = xmseg-werks
            m_lager            = xmseg-lgort
            m_charge           = charge
            l_charge           = xmseg-charg                "1131392
            cuobj              = cuobj
            kmatnr             = stdpd
          IMPORTING
            status_not_allowed = status_not_allowed.
        IF NOT status_not_allowed IS INITIAL.               "note 639409
*            In case the status_not_allowed flag has been set, a general
*            error has to be issued to prevent postings after cancelling
*            the respective message popup, to complete the error
*            handling from serialprofile_check.
          IF xmigo = x.                                    "note 639409
*            in case of migo, an error message is sufficient to prevent
*            posting and still enable corrections by the user
            MESSAGE e232(io).                              "note 639409
          ELSE.
            MESSAGE a232(io).                              "note 639409
          ENDIF.
        ENDIF.
      ENDIF.
      xmseg-zeile = a_zeile.
      xvm07m-zeilv = xmseg-zeile.
      ymbuz-zeile = ymbuz-zeilz = zmseg-zeile.
      ymbuz-xauto = xmseg-xauto.
ENHANCEMENT-SECTION     M_SEGMENTE_GENERIEREN_02 SPOTS ES_SAPMM07M.
      IF NOT xvm07m-smard IS INITIAL
         OR xmseg-sobkz = o
         OR xmseg-sobkz = e
         OR xmseg-sobkz = q
         OR xvm07m-lbbsa = '05'.
        MOVE-CORRESPONDING xvm07m TO xmdcp.
        MOVE-CORRESPONDING xmseg TO xmdcp.
        xmdcp-berid = zdm07m-umberid.                      "note 520142
        IF xmseg-sobkz = o.
          xmdcp-lbear = xmseg-emlif.
        ENDIF.
        APPEND xmdcp.
      ENDIF.
END-ENHANCEMENT-SECTION.
      IF xmseg-bustw = bustw_wa04.
        xvm07m-xlifu = zdm07m-umxli.
      ENDIF.
*     Automatic line for transfer postings: Parent from original
*     line, depth remains, LINE_ID is always new.
      CLEAR xmseg-line_id.
      CALL METHOD cl_mmim_line_id_manager=>line_id_get
        CHANGING
          c_line_id = xmseg-line_id.
      xmseg-parent_id  = zmseg-line_id.
      xmseg-line_depth = zmseg-line_depth.
      xvm07m-line_count = zvm07m-line_count.               "note 544663
*     However, there are some exceptions...
*     TIED EMPTIES
*     The components of a full product are generated somewhere else
*     (with XAUTO = L), but the transfer lines come from here.
*     However, there parent is created also here, so the LINE_ID
*     of the L-line-children has to be mapped to the X-line from
*     the full product.
*     note 578454:
*     Correction: We have also XAUTO = M,W,F when IM is value-only
*      IF zmseg-xauto <> l.                                "578454
      IF zmseg-xauto <> l AND zmseg-xauto <> f AND          "578454
         zmseg-xauto <> m AND zmseg-xauto <> w.             "578454
        l_fullprod_transfer_line_id   = xmseg-line_id.
      ELSE.
        xmseg-parent_id = l_fullprod_transfer_line_id.
      ENDIF.
*     STRUCTURED MATERIAL
*     For this type of posting, the automatic lines with the
*     components are already generated when entering this routine.
*     Here, only the automatic lines for the header is created.
*     Therefore, the already created children have to be remapped
*     to the new header later on.
      IF NOT zdm07m-umxhead IS INITIAL.
        ls_struct_map_table-parent_id = xmseg-parent_id.
        ls_struct_map_table-line_id   = xmseg-line_id.
        INSERT ls_struct_map_table INTO TABLE lt_struct_map_table.
      ENDIF.
      APPEND xmseg.
      APPEND xvm07m.
      APPEND ymbuz.
      PERFORM jv_umlager_konditionen_a.
    ENDIF.
  ENDLOOP.
* Remapping of the structured articles if necessary
  IF NOT lt_struct_map_table IS INITIAL.
    LOOP AT xmseg ASSIGNING <ls_mseg> WHERE xauto = u.
      READ TABLE lt_struct_map_table INTO ls_struct_map_table
                 WITH TABLE KEY parent_id = <ls_mseg>-parent_id.
      <ls_mseg>-parent_id = ls_struct_map_table-line_id.
    ENDLOOP.
  ENDIF.
  DESCRIBE TABLE xmseg LINES sy-tabix.
  IF sy-tabix > 9999.
    MESSAGE e278.
  ENDIF.
ENHANCEMENT-POINT MM07MFM0_M_SEGMENTE_GENERIE_05 SPOTS ES_SAPMM07M.
  PERFORM jv_umlager_konditionen_b.

ENHANCEMENT-POINT MM07MFM0_M_SEGMENTE_GENERIE_06 SPOTS ES_SAPMM07M.
ENDFORM.