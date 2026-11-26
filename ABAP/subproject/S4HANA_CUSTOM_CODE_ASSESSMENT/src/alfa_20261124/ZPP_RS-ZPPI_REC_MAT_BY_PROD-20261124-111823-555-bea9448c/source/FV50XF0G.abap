*-------------------------------------------------------------------
***INCLUDE FV50XF0G .
*    PERFORM gg_final_check.
*    PERFORM gg_manual_check.
*    PERFORM gg_check_active_simple.
*    PERFORM gg_daten_uebernahme.
*    PERFORM gg_lipsdg_maintain.
*    PERFORM gg_lipsdg_read.
*    PERFORM gg_lipsdg_refresh.
*    PERFORM gg_lipsdg_rename.
*    PERFORM gg_lipsdg_update.
*-------------------------------------------------------------------
TYPE-POOLS vlggt.
*eject
*&---------------------------------------------------------------------*
*&      Form  GG_FINAL_CHECK
*&---------------------------------------------------------------------*
*       Aufruf der Gefahrgutprfungen wâ rend Beleg sichern
*----------------------------------------------------------------------*
FORM gg_final_check USING ev_beleg_sichern_abbrechen LIKE sy-subrc
                          value(if_xlikp_tabix)      LIKE sy-tabix.

  DATA: lf_startmodus TYPE vlggt_startmodus_f,
        lf_msgty      LIKE sy-msgty.

  DATA  BEGIN OF ls_likp.
          INCLUDE STRUCTURE likpvb.
  DATA  END   OF ls_likp.

  DATA lt_balmi TYPE balmi OCCURS 0.

* Ausfhrung der Gefahrgutprâ´­fungen nur, wenn kein Fehler bei der
* Template-Material-Abwicklung aufgetreten ist.
  CHECK ev_beleg_sichern_abbrechen IS INITIAL.

* handling of dang. goods for subseq. deli.split done in V53S
  CHECK v50agl-split IS INITIAL.

*Gefahrgut nur fr Auslieferungen, fâ r Anlieferungen nicht implementier
  CHECK xlikp-vbtyp CA vbtyp_lief.

  IF NOT v50agl-sammelgang IS INITIAL
  OR NOT v50agl-kommirueckmeldung IS INITIAL
  OR     v50agl-split       = charx
   .                                   "Startmode without
    lf_startmodus = '3'.               "messages/popups/Dialog
  ELSE.
    lf_startmodus = '2'.
  ENDIF.

  ls_likp = xlikp.

  CALL FUNCTION 'WS_GG_CHECK_COMPLETE'
    EXPORTING
      is_tvst                        = tvst
      if_startmodus                  = lf_startmodus
      it_vbpa                        = xvbpa[]
    TABLES
      it_lips                        = xlips
      ct_balmi                       = lt_balmi
    CHANGING
      cs_likp                        = ls_likp
      cf_dataloss                    = r185d-dataloss
    EXCEPTIONS
      pruefung_nicht_aktiv           = 1
      keine_gg_relevanten_positionen = 2
      OTHERS                         = 3.

  CASE sy-subrc.
    WHEN 1.
      EXIT.
    WHEN 2."PERFORM message_handling USING 0 407 'I' 'DG'
      "                               space space space space.
*           Beim Sichern doch keine message von uns.
    WHEN 3.
  ENDCASE.


  CASE ls_likp-voggt.
    WHEN 'C'.
      ev_beleg_sichern_abbrechen = 1.
      PERFORM finchdel_handling(sapfv50p)
              USING ls_likp-vbeln '03' " VBELN PRUEFUNG
                    'E' 'VL' '766'     " MSGTY MSGID MSGNO
                    space space space space   " MSGV1 MSGV2 MSGV3 MSGV4
                    gt_finchdel.
  ENDCASE.

* Daten, Messages (ins Fehlerprotokoll der Lieferung)
  PERFORM gg_daten_uebernahme TABLES lt_balmi
                              USING  ls_likp if_xlikp_tabix.

ENDFORM.                    "gg_final_check


*eject
*&---------------------------------------------------------------------*
*&      Form  GG_MANUAL_CHECK
*&---------------------------------------------------------------------*
*      Ruft die Gefahrgutprfung im Dialog auf.
*      â bernimmt in likp xlikp die Gefahrgut-Informationen
*      xlikp-voggt
*      xlikp-proli   likp-proli
*----------------------------------------------------------------------*
FORM gg_manual_check.

  DATA: ls_likpvb TYPE vlggt_likpvb_s.
  DATA  lt_balmi  TYPE balmi OCCURS 0.

  PERFORM xlikp_aus_likp_fuellen.

  CHECK xlikp-updkz <> updkz_delete.
  ls_likpvb = likp.
  CHECK v50agl-sammelgang IS INITIAL.

  CALL FUNCTION 'WS_GG_CHECK_COMPLETE'
    EXPORTING
      is_tvst                        = tvst
      if_startmodus                  = '1'
      it_vbpa                        = xvbpa[]
    TABLES
      it_lips                        = xlips
      ct_balmi                       = lt_balmi
    CHANGING
      cs_likp                        = ls_likpvb
      cf_dataloss                    = r185d-dataloss
    EXCEPTIONS
      pruefung_nicht_aktiv           = 1
      keine_gg_relevanten_positionen = 2
      OTHERS                         = 3.

* message im Dialog bereits in EH&S detaillierter, hier nicht mehr ntig
* CASE sy-subrc.
*   WHEN 0.
*     CASE ls_likpvb-voggt.
*       WHEN chara. sy-msgno = '764'.   "Keine Probleme
*       WHEN charb. sy-msgno = '765'.   "Sichern nur mit UV mâ glich
*       WHEN charc. sy-msgno = '766'.   "Sichern nicht mglich
*     ENDCASE.
*   WHEN 1.         sy-msgno = '767'.   "Prâ fung nicht aktiv
*   WHEN 2.         sy-msgno = '768'.   "Keine GG-relevanten Positionen
* ENDCASE.
* sy-msgid = 'VL'.
* sy-msgty = 'S'.
* PERFORM message_handling_default USING '000000'.

* Fehlerdialog nun doch bei uns fr bestimmte Fehlerkonstellation
  CASE sy-subrc.
    WHEN 1.
      EXIT.
    WHEN 2.
      PERFORM message_handling USING posnr_low 407 'S' 'DG'
                                     space space space space.
      EXIT.
    WHEN 3.
  ENDCASE.

  PERFORM gg_daten_uebernahme TABLES lt_balmi
                              USING  ls_likpvb 1.

ENDFORM.                    "gg_manual_check

*&---------------------------------------------------------------------*
*&      Form  GG_CHECK_ACTIVE_SIMPLE
*&---------------------------------------------------------------------*
*       Prâ fen, ob Gefahrgutprfungen aktiv sind
*  --> likp (im Dialog ohne dynamischen Teil
*            FUGR arbeitet nur mit dynamischem Teil)
*  <-- ef_active: Gefahrgutprâ fung aktiv, wenn nicht initial
*----------------------------------------------------------------------*
FORM gg_check_active_simple CHANGING ef_aktiv LIKE tdga1-dgchka.

  DATA ls_likpvb TYPE vlggt_likpvb_s.

  CHECK NOT likp-vbtyp IS INITIAL AND                       "n_532605
        NOT likp-lfart IS INITIAL.

  MOVE-CORRESPONDING likp TO ls_likpvb.

  CALL FUNCTION 'WS_GG_CHECK_ACTIVE_SIMPLE'
    EXPORTING
      is_likp  = ls_likpvb
    IMPORTING
      ef_aktiv = ef_aktiv
    EXCEPTIONS
      OTHERS   = 1.

ENDFORM.                    "gg_check_active_simple

*eject
*&---------------------------------------------------------------------*
*&      Form  GG_DATEN_UEBERNAHME
*&---------------------------------------------------------------------*
*       Datenbernahme in Likp nach Gefahrgutprâ fung im EHS
*----------------------------------------------------------------------*
*      -->IS_LIKPVB     LIKP incl dyn. Teil, der von WS_GG_ zurckkommt
*      -->if_likp_tabix sy-tabix der aktuellen xlips
*      <--LIKP          globale Daten
*      <--XLIKP         globale Daten
*----------------------------------------------------------------------*
FORM gg_daten_uebernahme TABLES it_balmi       STRUCTURE balmi
                         USING  is_likp        TYPE vlggt_likpvb_s
                                if_xlikp_tabix LIKE sy-tabix.

* Prüfen, ob überhaupt irgendetwas geändert wurde.
  IF    is_likp-proli   <> xlikp-proli
  OR    is_likp-cont_dg <> xlikp-cont_dg
  OR    is_likp-voggt   <> xlikp-voggt.

*   Änderungsflag setzen nur, wenn Datenbank-Werte geändert wurden,
*   likpd ist nicht relevant
    IF is_likp-proli   <>  xlikp-proli
    OR is_likp-cont_dg <>  xlikp-cont_dg.
      r185d-dataloss = charx.
    ENDIF.

*   Gefahrgutprofil
    IF NOT is_likp-proli IS INITIAL.
      xlikp-proli = is_likp-proli.
    ENDIF.
*   Unvollstndigkeit nur im dynamischen Teil des Lieferkopfes
    xlikp-voggt  = is_likp-voggt.
*   Kennzeichen: Lieferung enthâ lt Gefahrgutdaten
    xlikp-cont_dg = is_likp-cont_dg.


*   Datenbernahme in globale Bereich Lieferung
    READ TABLE xlikp INDEX if_xlikp_tabix
                     TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      MODIFY xlikp INDEX sy-tabix.
    ENDIF.
    MOVE               xlikp TO likp.
    MOVE-CORRESPONDING xlikp TO likpd.

    PERFORM uc_upd_request(sapfv50u) USING charx posnr_low  "n_531900
                                           posnr_low posnr_low.

  ENDIF.

  IF NOT it_balmi[] IS INITIAL.
*   â bernahme Fehlermeldungen aus Gefahrgut-Prfung in Fehlerprotokoll
    PERFORM gg_daten_uebernahme_balmi TABLES it_balmi.
  ENDIF.

ENDFORM.                               " GG_DATEN_UEBERNAHME


*eject
*&---------------------------------------------------------------------*
*&      Form  GG_LIPSDG_MAINTAIN
*&---------------------------------------------------------------------*
*       Aufruf der Gefahrgutzusatzdatenpflege
*  --> IS_LIKP
*  -_> IS_LIPS
*----------------------------------------------------------------------*
FORM gg_lipsdg_maintain USING is_likp STRUCTURE likp
                              is_lips STRUCTURE lips.

  DATA: lf_trtyp    LIKE t180-trtyp,
        lf_dataloss LIKE r185d-dataloss.

  IF is_lips-profl IS INITIAL.
    PERFORM message_handling USING posnr_low 762 'I' 'VL'
                                   space space space space.
    EXIT.
  ENDIF.
  CHECK NOT gi_badi_instance_ehs001 IS INITIAL.    "n_530754/n_637289
  lf_trtyp = t180-trtyp.
  PERFORM xvbup_lesen(sapfv50p) USING is_likp-vbeln
                                      is_lips-posnr.
  IF xvbup-wbsta = charc.
    lf_trtyp = chara.
  ENDIF.

  CALL METHOD gi_badi_instance_ehs001->lipsdg_maintain
    EXPORTING
      imlikp         = is_likp
      imlips         = is_lips
      i_trtyp        = lf_trtyp
    IMPORTING
      cf_dataloss    = lf_dataloss
    EXCEPTIONS
      no_export_data = 1
      OTHERS         = 2.

  IF NOT sy-subrc IS INITIAL.
    sy-msgty = 'I'.
    PERFORM message_handling_default USING posnr_low.
  ENDIF.

  IF NOT lf_dataloss IS INITIAL.
    r185d-dataloss = lf_dataloss.
  ENDIF.

ENDFORM.                    "gg_lipsdg_maintain

*&---------------------------------------------------------------------*
*&      Form  GG_LIPSDG_READ
*&---------------------------------------------------------------------*
*      -->IF_VBELN
*----------------------------------------------------------------------*
FORM gg_lipsdg_read USING value(if_vbeln) LIKE likp-vbeln.

  RANGES: r_vbeln FOR lipsdg-vbeln.

  CHECK NOT gi_badi_instance_ehs001 IS INITIAL.    "n_530754/n_637289

  r_vbeln-sign   = 'I'.
  r_vbeln-option = 'EQ'.
  r_vbeln-low    = if_vbeln.
  r_vbeln-high   = if_vbeln.
  APPEND r_vbeln.

  CALL METHOD gi_badi_instance_ehs001->lipsdg_read
* Begin Correction 13.05.2003 598954 ***********************************
    EXPORTING
      i_rvbeln  = r_vbeln
* End Correction 13.05.2003 598954 *************************************
    CHANGING
      i_rvbeln_tab = r_vbeln[].

ENDFORM.                    "gg_lipsdg_read



*&---------------------------------------------------------------------*
*&      Form  GG_LIPSDG_REFRESH
*&---------------------------------------------------------------------*
FORM gg_lipsdg_refresh.
  DATA:   l_badi_instance TYPE REF TO if_ex_ehs_dg_001.
  IF gi_badi_instance_ehs001 IS INITIAL.

* Begin Correction 24.07.2003 644437 **********************************
    CALL FUNCTION 'EHS002_CHECK_EHS_ACTIVE'
    EXCEPTIONS
      EHS_NOT_EXIST = 1
      OTHERS        = 2.

    IF SY-SUBRC = 0. " EHS is active
      CALL METHOD cl_exithandler=>get_instance
        EXPORTING
          exit_name        = 'EHS_DG_001'                     "n_572145
          null_instance_accepted = 'X'                        "n_572145
*     Lines deleted n_530754/n_637289
        CHANGING
          instance         = gi_badi_instance_ehs001
        EXCEPTIONS
          OTHERS           = 1.
    ENDIF.
  ENDIF.
* End Correction 24.07.2003 644437 *************************************
  CHECK NOT gi_badi_instance_ehs001 IS INITIAL.    "n_530754/n_637289

  CALL METHOD gi_badi_instance_ehs001->lipsdg_refresh.

ENDFORM.                               " GG_LIPSDG_REFRESH

*&---------------------------------------------------------------------*
*&      Form  GG_LIPSDG_RENAME
*&---------------------------------------------------------------------*
*      -->IF_TEMP_VBELN  Alte, temporâ re Nummer, zu ersetzen
*      -->IF_VBELN       Neue Nummer, aus Nummernkreis
*----------------------------------------------------------------------*
FORM gg_lipsdg_rename USING value(if_temp_vbeln) LIKE likp-vbeln
                            value(if_vbeln)      LIKE likp-vbeln.

  CHECK NOT gi_badi_instance_ehs001 IS INITIAL.    "n_530754/n_637289

  CALL METHOD gi_badi_instance_ehs001->lipsdg_rename
    EXPORTING
      i_oldnum       = if_temp_vbeln
      i_newnum       = if_vbeln
    EXCEPTIONS
      no_export_data = 1
      OTHERS         = 2.

ENDFORM.                               " GG_LIPSDG_RENAME

*&---------------------------------------------------------------------*
*&      Form  GG_LIPSDG_UPDATE
*&---------------------------------------------------------------------*
FORM gg_lipsdg_update.

  CHECK NOT gi_badi_instance_ehs001 IS INITIAL.    "n_530754/n_637289

  CALL METHOD gi_badi_instance_ehs001->lipsdg_update
    EXPORTING
      synchron   = v50agl-synchron
* Begin Correction 26.05.2003 598954  **********************************
      I_LIPS        = xlips
      I_LIKP        = xlikp
* End Correction 26.05.2003 598954  ************************************
    CHANGING
      ixlips_tab = xlips[]
      ixlikp_tab = xlikp[].

ENDFORM.                               " GG_LIPSDG_UPDATE

*&---------------------------------------------------------------------*
*&      Form  GG_LIkp_proli_input_check
*&---------------------------------------------------------------------*
FORM gg_likp_proli_input_check USING cf_proli LIKE likp-proli.

  CHECK NOT gi_badi_instance_ehs001 IS INITIAL.    "n_530754/n_637289

  CALL METHOD gi_badi_instance_ehs001->proli_dialog_check
    EXPORTING
      i_proli     = cf_proli
    IMPORTING
      e_proli     = cf_proli
    EXCEPTIONS
      wrong_proli = 1
      OTHERS      = 2.

  IF sy-subrc <> 0.
    MESSAGE ID     sy-msgid
            TYPE   sy-msgty
            NUMBER sy-msgno
            WITH   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                               " GG_Likp_proli_input_check


*&---------------------------------------------------------------------*
*&      Form  GG_DATEN_UEBERNAHME_BALMI
*&---------------------------------------------------------------------*
FORM gg_daten_uebernahme_balmi TABLES it_balmi STRUCTURE balmi.

* bernahme der Gefahrgut-Fehlermeldungen ins Protokoll nur, wenn
  CHECK NOT v50agl-sammelgang IS INITIAL                  "Sammelgang
*    OR NOT v50agl-split      IS inital                   "Liefersplit
      .

  LOOP AT it_balmi.

    PERFORM message_handling_balmi(sapmv50a) USING 0 it_balmi.

  ENDLOOP.

ENDFORM.                               " GG_DATEN_UEBERNAHME_BALMI


*&---------------------------------------------------------------------*
*&      Form  GG_LIPSDG_COPY1
*&---------------------------------------------------------------------*
FORM gg_lipsdg1_copy USING is_likp TYPE likpvb
                           is_lips TYPE lipsvb.


* call function '........'
* exporting is_lips = is_lips.


ENDFORM.                               " GG_LIPSDG_COPY1


*&---------------------------------------------------------------------*
*&      Form  GG_LIPSDG_COPY2
*&---------------------------------------------------------------------*
FORM gg_lipsdg2_copy USING is_likp TYPE likpvb
                           is_lips TYPE lipsvb.

* copy of dgmsd data (template material processing)
  CALL FUNCTION 'EHS003_DGMSD_DLV_COPY_READ'
    EXPORTING
      is_likp = is_likp
      is_lips = is_lips
    EXCEPTIONS
      others_ = 1.

ENDFORM.                               " GG_LIPSDG_COPY2
*&---------------------------------------------------------------------*
*&      Form  DGMSD_DETERMINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EV_BELEG_SICHERN_ABBRECHEN  text
*      -->P_L_IDX  text
*----------------------------------------------------------------------*
FORM dgmsd_determine  USING
                      ev_beleg_sichern_abbrechen
                      value(if_xlikp_tabix) LIKE sy-tabix.

  DATA: lf_startmodus TYPE vlggt_startmodus_f,
        msgid LIKE balmi-msgid,
        msgno LIKE balmi-msgno,
        tppr_active  TYPE c,
        dgmsd_wa LIKE rdgsdiot,
        i_dgmsd_tab LIKE dgmsd OCCURS 0,
        dg_error TYPE c,
        text  LIKE t100-text,
        text1 LIKE t100-text,
        text2 LIKE t100-text,
        text3 LIKE t100-text,
        text4 LIKE t100-text,
        flg_msg TYPE c,
        l_answer,
        lt_balmi TYPE balmi OCCURS 0,
        l_subrc TYPE sy-subrc.
  DATA  BEGIN OF ls_likp.
          INCLUDE STRUCTURE likpvb.
  DATA  END   OF ls_likp.
  DATA: l_badi_instance TYPE REF TO if_ex_ehs_dg_002.
  DATA: e_usx_logtab LIKE balmi OCCURS 5 WITH HEADER LINE.

  CLEAR l_subrc.

* handling of dang. goods for subseq. deli.split done in V53S
  CHECK v50agl-split IS INITIAL.

* Check if functionality should be processed
  CALL FUNCTION 'EHS003_TPPR_GET'
    IMPORTING
      e_tppr_active = tppr_active
    EXCEPTIONS
      others_       = 1.

  CHECK tppr_active = charx.

  ls_likp = xlikp.

  IF NOT v50agl-sammelgang IS INITIAL
  OR NOT v50agl-kommirueckmeldung IS INITIAL
  OR     v50agl-split       = charx
   .                                   "Startmode without
    lf_startmodus = '2'.               "messages/popups/Dialog
  ELSE.
    lf_startmodus = '1'.
  ENDIF.

* get instance
  CALL FUNCTION 'EHS003_BADI_EHS_DG_002_GET_OBJ'
    IMPORTING
      e_badi_object = l_badi_instance.

*check for t/s-material
  CALL METHOD l_badi_instance->tpmat_check
    EXPORTING
      i_vbtyp        = ls_likp-vbtyp
      i_vbeln        = ls_likp-vbeln
    CHANGING
      i_xlips_tab    = xlips[]
    EXCEPTIONS
      no_tpmat_exist = 1
      wrong_param    = 2
      no_profl_found = 3
      others_        = 4.

  IF sy-subrc <> 0.
* no relevant materials in the document --> exit and save
    IF sy-subrc = 1.
      ls_likp-voggt = 'A'.
* update / correct x_dgmsd_tab and xvbuv-entries
      CALL METHOD l_badi_instance->dgmsd_vbuv_update
        EXPORTING
          i_vbtyp = ls_likp-vbtyp
          i_error = charx
        CHANGING
          x_xvbuv = xvbuv[]
        EXCEPTIONS
          others_ = 1.

* set data to SD header
      PERFORM gg_daten_uebernahme TABLES lt_balmi
                                  USING  ls_likp if_xlikp_tabix.
      EXIT.
    ELSEIF sy-subrc > 1.
      dg_error = charx.

* make entry in log of batch processing (Sammelgang)
      IF lf_startmodus = '2'.
        PERFORM finchdel_handling(sapfv50p)
                 USING xlikp-vbeln '03' " VBELN PRUEFUNG
                       'E' 'CB01' '411'     " MSGTY MSGID MSGNO
                     space space space space   " MSGV1 MSGV2 MSGV3 MSGV4
                       gt_finchdel.
* Begin Correction 1132891 16.01.2008 ***************************
      ELSE.
*       set message for PopUp
        msgid = 'CB01'.
        msgno = '411'.
* End Correction 1132891 16.01.2008 *****************************
      ENDIF.
    ENDIF.

  ENDIF.

*get dangerous goods data
  IF dg_error <> charx.
    CALL METHOD l_badi_instance->md_det_delivery
      EXPORTING
        i_likptab                    = ls_likp
        i_lipstab                    = xlips[]
        i_tvsttab                    = tvst
        i_vbpatab                    = xvbpa[]
        i_trtyp                      = t180-trtyp
        i_dg_start                   = lf_startmodus
      CHANGING
        e_usx_logtab                 = e_usx_logtab[]
      EXCEPTIONS
        no_tpma_exist                = 1
        no_release_status_determined = 2
        no_ctry_dgmot_determined     = 3
        error_ctry_dgmot             = 4
        no_shipping_types_determined = 5
        no_dgmat_available           = 6
        no_tdg41_idgtp               = 7
        no_dg_mat_to_matnr           = 8
        no_lwdg_found                = 9
        no_ship_to_country           = 10
        dg_master_not_released       = 11
        non_disjunct_validity_areas  = 12
        dg_master_deleted            = 13
        no_dg_mat_found              = 14
        error_by_det_check_methods   = 15
        no_dgdata_mntce              = 16
        others_                      = 17.

    l_subrc = sy-subrc.
* update / correct x_dgmsd_tab1 and xvbuv-entries
    CALL METHOD l_badi_instance->dgmsd_vbuv_update
      EXPORTING
        i_vbtyp = ls_likp-vbtyp
      CHANGING
        x_xvbuv = xvbuv[]
      EXCEPTIONS
        others_ = 1.

* Begin Correction 25.09.2007 1095897 *****************************
    IF l_subrc > 1.
*     exception NO_TPMA_EXIST means that we have a pipeline transport
*     or a material where no DG checks or papers are relevant
* End Correction 25.09.2007 1095897 *******************************
      dg_error = charx.

      CASE l_subrc.
        WHEN '2'.
          msgid = 'DG'.
          msgno = '422'.
        WHEN '3'.
          msgid = 'DG'.
          msgno = '406'.
        WHEN '4'.
          msgid = 'DG'.
          msgno = '462'.
        WHEN '5'.
          msgid = 'DG'.
          msgno = '401'.
        WHEN '6'.
          msgid = 'DG'.
          msgno = '464'.
        WHEN '7'.
          msgid = 'CB01'.
          msgno = '403'.
        WHEN '8'.
          msgid = 'CB01'.
          msgno = '404'.
        WHEN '9'.
          msgid = 'CB01'.
          msgno = '405'.
        WHEN '10'.
          msgid = 'CB01'.
          msgno = '406'.
        WHEN '11'.
          msgid = 'CB01'.
          msgno = '407'.
        WHEN '12'.
          msgid = 'DG'.
          msgno = '453'.
        WHEN '13'.
          msgid = 'DG'.
          msgno = '457'.
        WHEN '14'.
          msgid = 'CB01'.
          msgno = '408'.
        WHEN '15'.
          msgid = 'CB01'.
          msgno = '409'.
        WHEN '16'.
          msgid = 'CB01'.
          msgno = '410'.
          CLEAR dg_error.
          flg_msg = charx.
      ENDCASE.

* make entry in error log of batch processing
      IF lf_startmodus = '2'.
        PERFORM finchdel_handling(sapfv50p)
                 USING xlikp-vbeln '03' " VBELN PRUEFUNG
                       'E' msgid msgno     " MSGTY MSGID MSGNO
                     space space space space   " MSGV1 MSGV2 MSGV3 MSGV4
                       gt_finchdel.
      ENDIF.

    ELSE.
* no error by determination of dg data
      ls_likp-voggt = 'A'.
    ENDIF.
  ENDIF.

* error message in dialog processing
  IF lf_startmodus = '1' AND
     ( dg_error = charx OR flg_msg = charx ).

* conversion of message to text
*   TEXTLINE3
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        language = sy-langu
        MESSAGE  = msgno
        workarea = msgid
      IMPORTING
        text     = text.
*   TEXT_OPTION1
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        language = sy-langu
        MESSAGE  = '413'
        workarea = 'CB01'
      IMPORTING
        text     = text1.
*   TEXT_OPTION2
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        language = sy-langu
        MESSAGE  = '414'
        workarea = 'CB01'
      IMPORTING
        text     = text2.
*   Titel
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        language = sy-langu
        MESSAGE  = '415'
        workarea = 'CB01'
      IMPORTING
        text     = text3.
*   TEXTLINE1
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        language = sy-langu
        MESSAGE  = '416'
        workarea = 'CB01'
      IMPORTING
        text     = text4.

    l_answer = char2.

    WHILE  l_answer = char2.
      CALL FUNCTION 'POPUP_TO_DECIDE'
           EXPORTING
                defaultoption     = '2'
                textline1         = text4
*         TEXTLINE2         = ' '
                textline3         = text
                text_option1      = text1
                text_option2      = text2
                icon_text_option1 = 'ICON_SYSTEM_SAVE'
                icon_text_option2 = 'ICON_INFORMATION'
                titel             = text3
                start_column      = 25
                start_row         = 6
                cancel_display    = 'X'
           IMPORTING
                answer            = l_answer.

      CASE l_answer.

        WHEN char1.
*    Save with incompleteness
          ls_likp-voggt = 'B'.
        WHEN chara.
          l_answer = char9.
*     don't save
          ev_beleg_sichern_abbrechen = '1'.
          PERFORM finchdel_handling(sapfv50p)
                USING xlikp-vbeln '03' " VBELN PRUEFUNG
                      'E' msgid msgno     " MSGTY MSGID MSGNO
                     space space space space   " MSGV1 MSGV2 MSGV3 MSGV4
                      gt_finchdel.
        WHEN char2.
*     show long text
          CALL FUNCTION 'EHS003_MESSAGE_OUTPUT'
            EXPORTING
              sprsl   = sy-langu
              arbgb   = msgid
              msgnr   = msgno
            EXCEPTIONS
              others_ = 1.

      ENDCASE.
    ENDWHILE.
    IF l_answer = char9.
      EXIT.
    ENDIF.
  ENDIF.

* set data to SD header
  PERFORM gg_daten_uebernahme TABLES lt_balmi
                              USING  ls_likp if_xlikp_tabix.

* check incompleteness of dgmsd fields
  CALL FUNCTION 'EHS003_CHECK_INCOMPLETENESS'
    EXPORTING
      dialog      = space
      fehgr       = tvak-fehgr
      tbnam       = 'DGMSD'
      i_vbtyp     = ls_likp-vbtyp
      i_vbeln     = ls_likp-vbeln
      i_likp      = ls_likp
    TABLES
      i_vbuv_last = hvbuv
      i_vbuv_tab  = xvbuv
      i_vbuv_dia  = dvbuv
      i_lips      = xlips
    EXCEPTIONS
      others_     = 1.

ENDFORM.                    " DGMSD_DETERMINE