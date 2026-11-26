***INCLUDE MV50AF0F_FCODE_SICH .
*---------------------------------------------------------------------*
*       FORM FCODE_SICH                                               *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges                                     *
*---------------------------------------------------------------------*
FORM fcode_sich.


  DATA: ls_finchdel TYPE vlikp_s_finchdel.                  "HP_368181

* If the change management is active additional messages from the check
* of the distributed delivery are collected in CVBFS. Therefore
* initialization of the message table is necessary before final checks
  IF v50agl-dlv_change NE space.
    REFRESH cvbfs.
  ENDIF.

* Sicherung
  IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.            "v_SIT
    PERFORM sit_buchen.
  ENDIF.                                                             "^_SIT


ENHANCEMENT-POINT MV50AF0F_FCODE_SICH_01 SPOTS ES_SAPMV50A.
  PERFORM beleg_sichern USING charx.

ENHANCEMENT-POINT FCODE_SICH_01 SPOTS ES_SAPMV50A.
* rename the SD-monitor-protocol, but only if protocol is to be saved
* and not in CHANGE-mode because then the document number is known
  IF t180-aktyp = aktyp-create.
    IF xsdctrlflag IS INITIAL.
      CALL FUNCTION 'SD_MONITOR_CONTROL_FLAGS_GET'
        IMPORTING
          fsdctrlflag = xsdctrlflag
        EXCEPTIONS
          OTHERS      = 1.
    ENDIF.
    IF xsdctrlflag-protsave = yes.
      CALL FUNCTION 'SD_MONITOR_PROTOCOL_RENAME'
        EXPORTING
          fpappl = protocolcaller-sdl
          fvbeln = likp-vbeln
        EXCEPTIONS
          OTHERS = 1.
      CALL FUNCTION 'SD_MONITOR_PROTOCOL_EXPORT'
        EXPORTING
          fpappl = protocolcaller-sdl
          fvbeln = likp-vbeln
        EXCEPTIONS
          OTHERS = 1.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT FCODE_SICH_02 SPOTS ES_SAPMV50A.
* Output of final check errors in case of batch input
  IF sy-binpt NE space.                                     "HP_368181
    LOOP AT gt_finchdel INTO ls_finchdel
                        WHERE msgty CA 'AEX'.
      MESSAGE ID     ls_finchdel-msgid
              TYPE   ls_finchdel-msgty                      "n_595608
              NUMBER ls_finchdel-msgno
              WITH   ls_finchdel-msgv1
                     ls_finchdel-msgv2
                     ls_finchdel-msgv3
                     ls_finchdel-msgv4.
    ENDLOOP.
  ENDIF.

* Sichern im Verändern springt zum ersten Bild der jeweiligen Tr.
ENHANCEMENT-SECTION     FCODE_SICH_03 SPOTS ES_SAPMV50A.
  IF t180-trtyp EQ charv.
    IF gf_param_tcode IS INITIAL.                           "v_n_532957
      fcode+3(1) = char1.
      PERFORM fcode_bearbeiten.
    ELSE.
      LEAVE TO TRANSACTION gf_param_tcode.
    ENDIF.                                                  "^_n_532957
  ENDIF.
END-ENHANCEMENT-SECTION.

* Sichern beim Anlegen LO: Sprung auf voreingestellte Übersicht
  IF t180-trtyp   EQ charh AND
     lieferung_or EQ charx.
    IF     t180-bldgr NE gc_new_dialog_outb
       AND t180-bldgr NE gc_new_dialog_inb.
      PERFORM tvlk_select USING likp-lfart
                                space
                                sy-subrc.
      IF tvlk-uevor NE space.
        fcode = tvlk-uevor.
        PERFORM fcode_bearbeiten.
      ENDIF.
    ELSE.
*     Refresh text dialog
      CALL FUNCTION 'SD_WORD_PROCESSING_INIT'.              "HP_359556
*     Initialize callback handling for partner processing
      PERFORM partner_initialize_callback.                  "470
      PERFORM navigation_data_init(sapfv50p).
      IF taxi_screen_group(1) EQ c_taxi_scrgrp_overview(1).
        fcode = 'ITOV_T'.
      ELSE.
        gf_process_view = gc_view_general.
        fcode = 'OVER_T'.
      ENDIF.
      PERFORM fcode_bearbeiten.
    ENDIF.
  ENDIF.

* APO: reaching here is not expected: SICH or SIC2 would convert to
*     SIC1 -> tcod -> leave to transaction sy-tcode with DELTA reset.
*     safety first:
  PERFORM nmodul_for_tcode_apo.

ENDFORM.                    "fcode_sich

*&---------------------------------------------------------------------*
*&      Form  vbfa_erzeugen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VE_KZ_BEREL  text
*----------------------------------------------------------------------*
FORM vbfa_erzeugen USING ve_kz_berel.

  CLEAR vbfa.
  DATA:    lf_day(3)      TYPE n,
           lf_help(4)     TYPE c VALUE '0101',
           lf_dat1        TYPE sy-datlo,
           lf_dat2        TYPE sy-datlo,
           lv_is_kit_head TYPE xflag,
           lt_hus         TYPE hum_venum_t,
           ls_venum       TYPE hum_venum,
           lf_matbel      TYPE vpobjkey.
  STATICS  lf_count(3) TYPE n.


  DATA: ls_t156 TYPE t156.

*... Artikel bestandsgeführt oder Wertfortschreibung
  IF ve_kz_berel EQ charx.

*... Einträge aus Belegfluß des WA übernehmen
    vbfa = zvbfa.

*... Weitere Daten hinzufügen
    vbfa-mandt   = sy-mandt.
    vbfa-vbelv   = xlips-vbeln.
    vbfa-posnv   = xlips-posnr.

*... Storno-Bewegungsart setzen
    READ TABLE xt156n WITH KEY fcode = 'ST'
                               bwart = zvbfa-bwart BINARY SEARCH.
    IF sy-subrc NE 0.
      vbfa-bwart = xlips-bwart.
    ELSE.
      vbfa-bwart = xt156n-bwart_next.
    ENDIF.
    vbfa-vbeln     = emkpf-mblnr.
*   VBFA-POSNN     = ZVBFA-POSNN.
*   VBFA-RFWRT     = ZVBFA-RFWRT.
*   VBFA-WAERS     = ZVBFA-WAERS.
*   VBFA-RFMNG     = ZVBFA-RFMNG.
*   VBFA-MEINS     = ZVBFA-MEINS.
*   VBFA-VRKME     = ZVBFA-VRKME.
*   VBFA-MATNR     = ZVBFA-MATNR.
*   VBFA-RFMNG_FLT = ZVBFA-RFMNG_FLT.
*   VBFA-RFMNG_FLO = ZVBFA-RFMNG_FLO.
  ELSE.
*... Leistungsposition
    vbfa-mandt     = sy-mandt.
    vbfa-vbelv     = xlips-vbeln.
    vbfa-posnv     = xlips-posnr.
*... Erstellen von VBFA-VBELN bei Quittierung Leistung nach
*... folgendem Schema: Die ersten drei Stellen repräsentieren den Tag
*... des jeweiligen Jahres. Es folgen die letzten vier Stellen der
*... zugehörigen Liefernummer. Bei den abschließenden drei Stellen
*... handelt es sich um einen Zähler innerhalb eines Lieferbelegs. Damit
*... sind Dopplungen mehr als unwahrscheinlich.
    lf_dat1      = sy-datlo.
    lf_dat2      = sy-datlo(4).
    lf_dat2+4    = lf_help.
    lf_day       = lf_dat1 - lf_dat2.
    ADD 1 TO lf_day.
    vbfa-vbeln     = lf_day.
    vbfa-vbeln+3   = xlips-vbeln+6.
    vbfa-vbeln+7   = lf_count.
    ADD 1 TO lf_count.

    vbfa-posnn     = sy-timlo.
    vbfa-bwart     = space.
    vbfa-rfwrt     = 0.
    vbfa-rfmng     = xlips-lgmng.
    vbfa-meins     = xlips-meins.
    vbfa-vrkme     = xlips-vrkme.
    vbfa-matnr     = xlips-matnr.
    vbfa-rfmng_flt = xlips-lfimg * xlips-umvkz / xlips-umvkn.
    vbfa-rfmng_flo = xlips-lfimg_flo.

    PERFORM tvko_select(sapmv50a) USING likp-vkorg
                                        'X'
                                        sy-subrc.
    vbfa-waers     = tvko-waers.
  ENDIF.

  IF vbfa-vbeln EQ space OR vbfa-vbelv = vbfa-vbeln.
    MESSAGE a659(vl) WITH xlips-vbeln.
  ENDIF.

*... Gemeinsame Daten ergaenzen
  vbfa-vbtyp_v = likp-vbtyp.
  vbfa-vbtyp_n = vbtyp_docu.
  vbfa-taqui   = space.
  vbfa-erdat   = sy-datum.
  vbfa-erzet   = sy-uzeit.
* Use actual posting year for document flow of mat docs
  vbfa-mjahr   = likp-wadat_ist(4).
  IF vbfa-mjahr IS INITIAL.                                   "n_1579679
    vbfa-mjahr = likp-podat(4).
  ENDIF.

* SPE Kit to Order: For VBFA entries refering to the Kit Header GR
* the PLMIN has to be kept
  IF zvbfa-plmin           =  '0'        AND
     xlips-spe_struc       IS NOT INITIAL AND
     xlikp-spe_le_scenario =  'C'.
    CALL FUNCTION '/SPE/OUTB_KIT_HEADER_CHECK'
      EXPORTING
        is_likp        = xlikp
        is_lips        = xlips
        it_lips        = xlips[]
      IMPORTING
        ev_is_kit_head = lv_is_kit_head.
    IF lv_is_kit_head = space.
      vbfa-plmin   = '-'.
    ENDIF.
  ELSE.
*...VL60                                                      "v_XAN-SPM
    IF NOT vbfa-bwart IS INITIAL AND vbfa-vbtyp_v = char7.
      CLEAR: ls_t156.
      CALL FUNCTION '/SPE/GEN_T156_GET'
        EXPORTING
          if_bwart  = vbfa-bwart
        IMPORTING
          es_t156   = ls_t156
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      IF sy-subrc = 0.
        IF  ls_t156-xstbw = space AND ls_t156-shkzg = chars.
          vbfa-plmin   = '+'.
        ELSE .
          vbfa-plmin   = '-'.
        ENDIF .
      ELSE .
        vbfa-plmin = '-'.
      ENDIF .
    ELSE .
*     Change the direction of cancelled entries
      IF zvbfa-plmin = '+'.                                     "1554198
        vbfa-plmin = '-'.
      ELSEIF zvbfa-plmin = '-'.
        vbfa-plmin = '+'.
      ENDIF.
    ENDIF.                                                    "^_XAN-SPM
  ENDIF.

*... HU-Packstatus in XVBFA-Belegfluss reinitialisieren

  IF xlips-hupos = 'A'.                                    "n_v_1367801
* only set back the status for those HUs that have been
* posted with the material document
    lf_matbel       = zvbfa-vbeln.
    lf_matbel+10(4) = zvbfa-mjahr.
    PERFORM hus_determine_per_matdoc(saplhu_humseg)
                    USING lf_matbel
                    CHANGING lt_hus.
    LOOP AT lt_hus INTO ls_venum.
      READ TABLE xvbfa WITH KEY vbelv   = vbfa-vbelv
                                posnv   = vbfa-posnv
                                vbeln   = ls_venum-venum
                                vbtyp_n = vbtyp_versand
                                vbtyp_v = vbtyp_liav
                                wbsta   = charc.
      IF sy-subrc IS INITIAL.
        CLEAR xvbfa-wbsta.
        xvbfa-updkz = charu.
        MODIFY xvbfa INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

  ELSE.
* set back the status for all HUs of this delivery item
    LOOP AT xvbfa WHERE vbelv   = vbfa-vbelv    AND
                      posnv   = vbfa-posnv    AND
                      vbtyp_n = vbtyp_versand AND
                      vbtyp_v = vbtyp_liav    AND
                      wbsta   = charc.
      CLEAR xvbfa-wbsta.
      xvbfa-updkz = charu.
      MODIFY xvbfa INDEX sy-tabix.
    ENDLOOP.
  ENDIF.                                                   "n_^_1367801
ENDFORM.                    "VBFA_ERZEUGEN