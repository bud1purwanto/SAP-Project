************************************************************************
*                                                                      *
* Unterroutinen fuer den Versand                                       *
*     Routinen für die Datenbankschnittstelle                          *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       FORM LIKP_SELECT                                              *
*---------------------------------------------------------------------*
*       Lieferungskopf lesen                                          *
*---------------------------------------------------------------------*
FORM likp_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE likp-vbeln
                 CHANGING cf_subrc LIKE sy-subrc.           "n_527241

  DATA: lf_msgtxt TYPE c.                                   "n_574894

  SELECT SINGLE *
         INTO likp
         FROM likp
         WHERE vbeln = likp-vbeln.
  cf_subrc = sy-subrc.                                      "n_527241
  IF cf_subrc > 0.
    PERFORM lieferung_entsperren USING vs_vbeln.
    MESSAGE e302 WITH likp-vbeln INTO lf_msgtxt.            "n_574894
  ENDIF.

ENHANCEMENT-POINT LIKP_SELECT_01 SPOTS ES_SAPMV50A.
ENDFORM.                    "likp_select
*eject


*---------------------------------------------------------------------*
*       FORM LIPS_SELECT                                              *
*---------------------------------------------------------------------*
*       Lieferposition lesen                                          *
*---------------------------------------------------------------------*
FORM lips_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE lips-vbeln.
ENHANCEMENT-POINT LIPS_SELECT_01 SPOTS ES_SAPMV50A STATIC.
  lieferung_or = charx.

  SELECT * FROM lips
           INTO TABLE xlips
           WHERE vbeln EQ vs_vbeln
           ORDER BY PRIMARY KEY.                            "n_641688

* Buffered lock and read for the predecessors
  PERFORM lock_and_fill_buffer(sapmv50a).

  LOOP AT xlips.
    lips = xlips.
    CLEAR lipsd.
    MOVE-CORRESPONDING lipsd TO xlips.
ENHANCEMENT-POINT LIPS_SELECT_02 SPOTS ES_SAPMV50A.

ENHANCEMENT-POINT LIPS_SELECT_05 SPOTS ES_SAPMV50A.
    PERFORM lips_x_aufbauen USING sy-tabix.
    IF xlips-vgbel NE space.
      lieferung_or = space.
ENHANCEMENT-POINT LIPS_SELECT_03 SPOTS ES_SAPMV50A.
    ENDIF.
ENHANCEMENT-POINT LIPS_SELECT_04 SPOTS ES_SAPMV50A.
  ENDLOOP.

*  SELECT *
*         INTO LIPS
*         FROM LIPS
*              WHERE VBELN  = :VS_VBELN.
*    PERFORM LIPS_X_AUFBAUEN.
*    IF LIPS-VGBEL NE SPACE.
*      LIEFERUNG_OR = SPACE.
*    ENDIF.
*  ENDSELECT.

  READ TABLE xlips INDEX 1.
  IF sy-subrc EQ 0.
    rv50a-vtweg = xlips-vtweg.
    rv50a-spart = xlips-spart.
  ENDIF.

ENDFORM.                    "lips_select
*eject


*---------------------------------------------------------------------*
*       FORM LIPS_X_AUFBAUEN                                          *
*---------------------------------------------------------------------*
*       Die interne Tabelle XLIPS wird aus der Datenbank-tabelle      *
*       LIPS aufgebaut.                                               *
*       Die Chargendaten werden dazu gelesen.                         *
*       Ferner wird die Indextabelle ILIPS entsprechend dem Umfang    *
*       mitgepflegt.                                                  *
*       Die Tabelle ULIPS wird erst nach dem Lesen aller Positionen   *
*       gepflegt.                                                     *
*---------------------------------------------------------------------*
FORM lips_x_aufbauen USING value(if_tabix) TYPE sytabix.

  DATA: lf_qmenge_flo TYPE f.
  DATA: lf_pikmg_delta_b LIKE xvbapf-qmenge.                "v_n_640199
  DATA: lf_pikmg_delta_s LIKE xvbapf-qmenge.                "^_n_640199
  DATA: lf_lips_hsdat like lips-hsdat,                        "n_1644031
        lf_lips_vfdat like lips-vfdat.                        "n_1644031

  FIELD-SYMBOLS: <ls_batch_item_num> LIKE gt_batch_item_num.

  PERFORM xvbapf_lesen(sapfv50p) USING likp-vbeln lips-posnr sy-subrc.
* if lips-kzfme ca kzfme_ws or xvbapf-qmengev ge 0.          "hp_304041
  IF lips-kzfme CA kzfme_ws OR xvbapf-qmengev GT 0.         "hp_317761
*     xlips-pikmg = xvbapf-qmengev.

    DATA: if_pikmg_delta  LIKE xvbapf-qmenge.
    CONSTANTS: cf_delta_low LIKE  xvbapf-qmenge VALUE '0.002-'.
    CONSTANTS: cf_delta_high LIKE xvbapf-qmenge VALUE '0.002'.


    IF NOT xvbapf-qmenge_f IS INITIAL.                      "v_n_659168
      xlips-pikmg = xvbapf-qmenge_f * lips-umvkn / lips-umvkz.
    ELSE.
      xlips-pikmg = xvbapf-qmenge * lips-umvkn / lips-umvkz.
    ENDIF.                                                  "^_n_659168
ENHANCEMENT-POINT LIPS_X_AUFBAUEN_02 SPOTS ES_SAPMV50A.
    if_pikmg_delta =  xlips-pikmg - xvbapf-qmengev.
    IF ( if_pikmg_delta > cf_delta_low AND
   if_pikmg_delta < cf_delta_high
* bei Z > N beinhält qmengev u.U. Rundungsfehler
       AND lips-umvkn > lips-umvkz )
    OR ( lips-kzfme CA kzfme_ws
       AND lips-umvkn > lips-umvkz )
   .
      IF  lips-kzfme IS INITIAL AND                         "v_n_640199
          xvbup-lvsta CA 'ABC' AND
          if_pikmg_delta <> 0.
*  quantity from calculation of base unit of measure
        lf_pikmg_delta_b = xlips-lfimg - xlips-pikmg.
        IF lf_pikmg_delta_b = 0.
*  picking quanity from base unit measure calulation should be the one
        ELSE.
*  quantity from calculation of sales unit of measure
          lf_pikmg_delta_s = xlips-lfimg - xvbapf-qmengev.
          IF lf_pikmg_delta_s = 0.
*  picking quanity from sales unit measure calculation should be theone
            xlips-pikmg = xvbapf-qmengev.
          ELSE.
            IF lf_pikmg_delta_s < 0.
              lf_pikmg_delta_s = lf_pikmg_delta_s * ( -1 ).
            ENDIF.
            IF lf_pikmg_delta_b < 0.
              lf_pikmg_delta_b = lf_pikmg_delta_b * ( -1 ).
            ENDIF.
            IF lf_pikmg_delta_b > lf_pikmg_delta_s.
              xlips-pikmg = xvbapf-qmengev.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        xlips-pikmg = xvbapf-qmengev.
      ENDIF.                                                "^_n_640199
*          xlips-pikmg = xvbapf-qmengev.                   "del_n_640199
    ENDIF.
  ELSE.
    lf_qmenge_flo = xvbapf-qmenge.
    IF lips-umrev > 0.
      xlips-pikmg = lf_qmenge_flo / lips-umrev.
    ELSE.
      xlips-pikmg = lf_qmenge_flo / lips-umvkz
                                  * lips-umvkn.
    ENDIF.
  ENDIF.

  IF lips-vrkme = lips-meins.
    xlips-pikmg = xvbapf-qmenge.
  ENDIF.

*...cumulated goods receipt posted quantity                   "v_XAN-SPM
  IF likp-vbtyp = vbtyp_lire OR likp-vbtyp = vbtyp_liav.
*  cumulated quantity in BUOM
    xlips-vbumg_bme = xvbapf-rmenge_p.
*  cumulated quantity in SUOM
    xlips-vbumg     = xvbapf-rmenge_pv.
  ENDIF.                                                      "^_XAN-SPM

*...SPE Determination of confirmation of service              "v_XAN-SPM
  CALL FUNCTION 'LE_MOVEMENT_IS_QUITL_DETERMINE'
    EXPORTING
      if_vbeln     = xlips-vbeln
      if_posnr     = xlips-posnr
      if_lfimg     = xlips-lfimg
      if_lgmng     = xlips-lgmng
      if_lfimg_flo = xlips-lfimg_flo
      if_lgmng_flo = xlips-lgmng_flo
      if_vbumg     = xlips-vbumg
      if_vbumg_bme = xlips-vbumg_bme
      if_nowab     = xlips-nowab
      if_bwart     = xlips-bwart
      if_sobkz     = xlips-sobkz
      if_vgtyp     = xlips-vgtyp
      if_posar     = xlips-posar
      if_xchar     = xlips-xchar
      if_xchpf     = xlips-xchpf
      if_uecha     = xlips-uecha
      if_kcmeng    = xlips-kcmeng
      if_werks     = xlips-werks
      if_mtart     = xlips-mtart
      if_ebumg     = xlips-ebumg                            "n_880596
    IMPORTING
*     ES_V134W     =
      ef_is_quitl  = xlips-is_quitl.                    "^_XAN-SPM

  xlips-vrkmp = lips-vrkme.
*  MOVE-CORRESPONDING LIPS TO XLIPS.

  IF aufrufer NE chart.                                     "n_1343345
*   Not in case of transports...
    IF NOT lips-charg IS INITIAL.                           "v_n_563149
*    if not lips-charg is initial and
*       fcode(4) ne 'WABU'.        "<<<< note 115538/46A BEY "^_n_563149

      lf_lips_hsdat = lips-hsdat.                             "n_1644031
      lf_lips_vfdat = lips-vfdat.                             "n_1644031

      PERFORM lips_fuellen_charge(sapfv50p).

      if not lf_lips_vfdat is initial.                      "v_n_1644031
        lips-vfdat = lf_lips_vfdat.
      endif.
      if not lf_lips_hsdat is initial.
        lips-hsdat = lf_lips_hsdat.
      endif.                                                "^_n_1644031

      xlips-verab = lipsd-verab.
      xlips-vfdat = lips-vfdat.
      xlips-hsdat = lips-hsdat.                             "n_1104315
    ELSEIF gf_docubatch_active EQ 'X' AND
           V50AGL-LATE_DELIVERY_UPD IS INITIAL AND          "n_1589850
         ( likp-vbtyp EQ vbtyp_lino   OR
           likp-vbtyp EQ vbtyp_liav ).
      DATA:
        lv_process_id          TYPE docubatch_process_id,
        lv_ebeln               TYPE ebeln,
        lv_ebelp               TYPE ebelp,
        lv_pikmg               LIKE xlips-pikmg,
        lv_vrkmp               LIKE xlips-vrkmp,
        ls_XVBUP               LIKE LINE OF XVBUP,
        lv_movement_cancelled  TYPE xfeld,
        lv_display_only        TYPE xfeld,                  "n_1402303
        ls_docubatch_com       TYPE docubatch_com.

      MOVE-CORRESPONDING xlikp
        TO ls_docubatch_com.
      MOVE-CORRESPONDING xlips
        TO ls_docubatch_com.
      MOVE-CORRESPONDING v50agl                             "n_1619203
        TO LS_DOCUBATCH_COM.

      IF t180-trtyp EQ chara                                "v_n_1402303
        OR ( t180-trtyp EQ charv AND fcode = 'PRNT_T' ).    "n_1505553
        lv_display_only = abap_true.
      ENDIF.
      READ TABLE XVBUP into ls_XVBUP
    WITH KEY vbeln = xlips-vbeln
                 POSNR = XLIPS-POSNR.
      IF SY-SUBRC <> 0 or
        ( ls_XVBUP-WBSTA <> 'C' AND ls_XVBUP-WBSTA <> 'B').
        clear ls_XVBUP-WBSTA.
      ENDIF.                                                "^_n_1402303
      READ TABLE xvbfa
        TRANSPORTING NO FIELDS
        WITH KEY vbelv   = xlips-vbeln
                 posnv   = xlips-posnr
                 vbtyp_n = vbtyp_wa_storno.
      IF sy-subrc IS INITIAL.
        lv_movement_cancelled = abap_true.
      ENDIF.

      PERFORM determine_process_id(sapmv50a)
        USING
          xlips-vgbel
          xlips-vgpos
        CHANGING
          lv_process_id
          lv_ebeln
          lv_ebelp.

      IF /spe/cl_ctrl=>is_ewm( i_lgnum = likp-lgnum ) EQ gc_true. "n_1494625
        CASE xlikp-vbtyp.
          WHEN vbtyp_liav. " '7' inbound deliveries
            lv_pikmg = xlips-ebumg.
            lv_vrkmp = xlips-vrkme.
          WHEN vbtyp_lino. " 'J' outbound deliveries
            lv_pikmg = xlips-lfimg.
            lv_vrkmp = xlips-vrkme.
          WHEN OTHERS.
            lv_pikmg = xlips-pikmg.
            lv_vrkmp = xlips-vrkmp.
        ENDCASE.
      ELSEIF xvbup-kosta IS INITIAL.
        lv_pikmg = xlips-lfimg.
        lv_vrkmp = xlips-vrkme.
      ELSE.
        lv_pikmg = xlips-pikmg.
        lv_vrkmp = xlips-vrkmp.
      ENDIF.

      CALL FUNCTION 'VBDBDM_DATA_READ_FOR_DELIVERY'
        EXPORTING
          i_matnr              = xlips-matnr
          i_werks              = xlips-werks
          i_quantity           = lv_pikmg
          i_uom                = lv_vrkmp
          i_process_id         = lv_process_id
          i_ebeln              = lv_ebeln
          i_ebelp              = lv_ebelp
          i_vbeln              = xlips-vbeln
          i_posnr              = xlips-posnr
          I_MOVEMENT_POSTED    = LS_XVBUP-WBSTA
          i_movement_cancelled = lv_movement_cancelled
          i_display_only       = lv_display_only            "n_1402303
          is_docubatch_com     = ls_docubatch_com
        IMPORTING
          e_control            = xlips-docubatch_control
          e_docubatch_charg    = xlips-docubatch_charg
          e_mult_entries       = xlips-docubatch_mult_entries
        EXCEPTIONS
          OTHERS               = 0.
    ENDIF.
  ENDIF.                                                    "n_1343345
* Mengenumrechnung: Füllen alter Belege mit den Floatfeldern
  IF xlips-lfimg_flo = 0 AND
     xlips-lgmng_flo = 0 AND
     xlips-kcmeng_flo = 0.
    xlips-lfimg_flo = xlips-lfimg.
    xlips-lgmng_flo = xlips-lgmng.
    xlips-kcmeng_flo = xlips-kcmeng.
    IF xlips-kcmengvmef = 0 AND xlips-kzfme CA kzfme_ws.
      xlips-kcmengvmef = xlips-kcmengvme.
    ENDIF.
  ENDIF.

  IF xlips-vgtyp CA vbtyp_lp.
    CALL FUNCTION 'SD_DELIVERY_CUMULATIVE_SET'
      EXPORTING
        f_xlips = xlips
        f_kuwev = kuwev
        f_likp  = likp
      EXCEPTIONS
        OTHERS  = 6.
  ENDIF.

   *lips = lips.
  IF aufrufer NE chart.                                     "n_1343345
*   Not in case of transports...
    PERFORM lips_referenz_lesen(sapfv50p).
  ENDIF.                                                    "n_1343345

* Cumulate flags for shipping and transportation scheduling activation
* into dynamic part of delivery header
  IF likpd-vstrm IS INITIAL.
    likpd-vstrm = tvak-vstrm.
  ENDIF.
  IF likpd-trtrm IS INITIAL.
    likpd-trtrm = tvak-trtrm.
  ENDIF.

  MODIFY xlips INDEX if_tabix.

* Determine highest number for batch split or packing items
  IF xlips-posnr GT '900000'.
    READ TABLE gt_batch_item_num ASSIGNING <ls_batch_item_num>
                                 WITH KEY vbeln = likp-vbeln
                                 BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF xlips-posnr GT <ls_batch_item_num>-posnr_last.
        <ls_batch_item_num>-posnr_last = xlips-posnr.
        posnr_last = xlips-posnr.
      ENDIF.
    ELSE.
      gt_batch_item_num-vbeln = likp-vbeln.
      gt_batch_item_num-posnr_last = xlips-posnr.
      INSERT gt_batch_item_num INDEX sy-tabix.
      posnr_last = xlips-posnr.
    ENDIF.
  ENDIF.

* Performance : not twice during picking confirmation
  CHECK v50agl-no_ilips_maint IS INITIAL.

* Ggfs. Eintrag in zugehöriger Indextabelle pflegen
  PERFORM ilips_anlegen_datenbank(sapfv50p) USING if_tabix.

ENHANCEMENT-POINT LIPS_X_AUFBAUEN_01 SPOTS ES_SAPMV50A.
ENDFORM.                    "lips_x_aufbauen
*eject


*---------------------------------------------------------------------*
*       FORM VBAK_SELECT                                              *
*---------------------------------------------------------------------*
*       Kundenauftragskopf lesen                                      *
*---------------------------------------------------------------------*
FORM vbak_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE vbak-vbeln.

  SELECT SINGLE *
         INTO vbak
         FROM vbak
         WHERE vbeln = vs_vbeln.
  IF sy-subrc > 0 .
    PERFORM auftrag_entsperren USING vs_vbeln.
    IF t180-trtyp EQ chara.
      MESSAGE i303(vl) WITH vs_vbeln.
    ELSE.
      PERFORM message_handling(sapmv50a) USING posnr_low
                                               '303'
                                               'E'
                                               'VL'
                                               vs_vbeln
                                               space
                                               space
                                               space.
    ENDIF.
  ELSE.
    cvbak = vbak.
    rv50a-vtweg = vbak-vtweg.
    rv50a-spart = vbak-spart.
  ENDIF.

ENDFORM.                    "vbak_select
*eject


*---------------------------------------------------------------------*
*       FORM VBAP_SELECT                                              *
*---------------------------------------------------------------------*
*       Kundenauftragspositionen lesen                                *
*---------------------------------------------------------------------*
* note 152894
* Changing-Parameters are only to be changed,
* if   using-paramter if_check_grkor = 'X'
* and  deliverygroup is selected incomplete.
* FORM KZKOR_Determine says, whether incomplete deliverygroup
* - is completed,  thus the range of vs_abpos to vs_bipos is extended or
* - is not selected, thus the range of vs_abpos to vs_bipos is reduced
*
*---------------------------------------------------------------------*
FORM vbap_select USING          if_check_grkor TYPE c
                          value(vs_mandt) LIKE sy-mandt
                          value(vs_vbeln) LIKE vbap-vbeln
                 CHANGING       vs_abpos  LIKE vbap-posnr
                                vs_bipos  LIKE vbap-posnr.

  FIELD-SYMBOLS:
       <ls_vbap>     LIKE vbapvb
      .
  DATA: lf_kzkor
      , lt_vbap      LIKE vbapvb     OCCURS 0
      , lf_posnr_min LIKE vbap-posnr
      , lf_posnr_max LIKE vbap-posnr
      .
  DATA: BEGIN OF lt_kor OCCURS 0,
                  grkor     LIKE vbap-grkor,
                  posnr_min LIKE vbap-posnr,
                  posnr_max LIKE vbap-posnr,
        END   OF lt_kor.

  DATA: BEGIN OF lt_vbap_prosa OCCURS 0,
                  vbeln     LIKE vbap-vbeln,
                  posnr     LIKE vbap-posnr,
        END   OF lt_vbap_prosa.

  CLEAR cvbap.
  CLEAR text_value_item.
  SELECT *
         INTO vbap
         FROM vbap
              WHERE vbeln  = :vs_vbeln
              AND   posnr >= :vs_abpos
              AND   posnr <= :vs_bipos.

    IF   vbap-grkor     >  0
    AND  if_check_grkor = charx
    AND (  vs_abpos     > posnr_low
        OR vs_bipos     < posnr_high
        ).
      READ TABLE lt_kor WITH KEY grkor = vbap-grkor
                        BINARY SEARCH.
      IF sy-subrc = 0.
        IF lt_kor-posnr_min > vbap-posnr.
          lt_kor-posnr_min = vbap-posnr.
          MODIFY lt_kor INDEX sy-tabix.
        ENDIF.
        IF lt_kor-posnr_max < vbap-posnr.
          lt_kor-posnr_max = vbap-posnr.
          MODIFY lt_kor INDEX sy-tabix.
        ENDIF.
      ELSE.
        lt_kor-grkor     = vbap-grkor.
        lt_kor-posnr_min = vbap-posnr.
        lt_kor-posnr_max = vbap-posnr.
        INSERT lt_kor INDEX sy-tabix.
      ENDIF.
    ENDIF.

ENHANCEMENT-SECTION     VBAP_SELECT_04 SPOTS ES_SAPMV50A.
    PERFORM vbap_c_aufbauen.
    IF vbap-posar EQ chara OR vbap-posar EQ charb.
      text_value_item = charx.
    ENDIF.

* in case of productselection all subitems should be read
    IF vbap-prosa EQ chara AND
       ( vs_abpos > posnr_low OR vs_bipos < posnr_high ).
      MOVE-CORRESPONDING vbap TO lt_vbap_prosa.
      APPEND lt_vbap_prosa.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDSELECT.


* selected items are in delivery groups, check, if groups are complete
  IF NOT lt_kor[] IS INITIAL.

    SELECT * INTO TABLE lt_vbap
                  FROM     vbap
                  FOR ALL ENTRIES IN lt_kor
                  WHERE    vbeln = vs_vbeln
                    AND (  posnr < vs_abpos OR posnr > vs_bipos )
                    AND    grkor = lt_kor-grkor.

    IF sy-subrc = 0.         "delivery-groups are selected incomplete

*     Determine, what to do, with incomplete selected delivery groups
      PERFORM kzkor_determine CHANGING lf_kzkor.

      CASE lf_kzkor.

*      message about incomplete delivered delivery groups
        WHEN space.                    "nop. as before.

          REFRESH lt_kor.
          LOOP AT lt_vbap ASSIGNING <ls_vbap>.
            lt_kor-grkor = <ls_vbap>-grkor.
            COLLECT lt_kor.
          ENDLOOP.
          LOOP AT lt_kor.
            PERFORM message_handling(sapmv50a) USING  vs_abpos
                                                      '278' 'I' 'VL'
                                                      vs_abpos
                                                      vs_bipos
                                                      lt_kor-grkor
                                                      space.
          ENDLOOP.

*      Add not yet selected items of incomplete delivery groups
        WHEN '1'.

          APPEND LINES OF lt_vbap TO cvbap.

*        Extend item-range for selection of other DB-tables
          lf_posnr_min = vs_abpos.
          lf_posnr_max = vs_bipos.
          LOOP AT lt_vbap ASSIGNING <ls_vbap>.
            IF lf_posnr_min >       <ls_vbap>-posnr.
              lf_posnr_min =       <ls_vbap>-posnr.
            ENDIF.
            IF lf_posnr_max <       <ls_vbap>-posnr.
              lf_posnr_max =       <ls_vbap>-posnr.
            ENDIF.
          ENDLOOP.
          vs_abpos = lf_posnr_min.
          vs_bipos = lf_posnr_max.

*        message about additional items to complete deliverygroups
          REFRESH lt_kor.
          LOOP AT lt_vbap ASSIGNING <ls_vbap>.
            lt_kor-grkor =  <ls_vbap>-grkor.
            COLLECT lt_kor.
          ENDLOOP.
          LOOP AT lt_kor.
            PERFORM message_handling(sapmv50a) USING vs_abpos
                                                     '276' 'I' 'VL'
                                                     vs_abpos
                                                     vs_bipos
                                                     lt_kor-grkor
                                                     space.
          ENDLOOP.

*        handle text and value items if selected first in addition
          IF text_value_item <> charx.
            LOOP AT lt_vbap TRANSPORTING NO FIELDS
                            WHERE vbeln =   vs_vbeln
                              AND posar CA 'AB'.
              EXIT.
            ENDLOOP.
            IF sy-subrc = 0.
              text_value_item = charx.
            ENDIF.
          ENDIF.

*      Avoid delivery of items in incomplete delivery groups
        WHEN '2'.

          REFRESH lt_kor.
          LOOP AT lt_vbap ASSIGNING <ls_vbap>.
            lt_kor-grkor = <ls_vbap>-grkor.
            COLLECT lt_kor.
          ENDLOOP.
          LOOP AT lt_kor.

*          Delete order-item-entries from incomplete delivery groups
            DELETE cvbap WHERE grkor = lt_kor-grkor.

            PERFORM message_handling(sapmv50a) USING vs_abpos
                                                     '277' 'I' 'VL'
                                                     vs_abpos
                                                     vs_bipos
                                                     lt_kor-grkor
                                                     space.
          ENDLOOP.

*        handle text and value items again,
*        relevant items might have been deleted
          text_value_item = space.
          LOOP AT cvbap TRANSPORTING NO FIELDS
                        WHERE posar CA 'AB'.
            text_value_item = 'X'.
            EXIT.
          ENDLOOP.
      ENDCASE.
    ENDIF.
  ENDIF.

* in case of productselection all subitems should be read
  LOOP AT lt_vbap_prosa.
    SELECT *
           INTO vbap
           FROM vbap
                WHERE vbeln  = :vs_vbeln
                AND   uepos  = lt_vbap_prosa-posnr.

      READ TABLE cvbap WITH KEY vbap(19).
      IF sy-subrc NE 0.
        CLEAR cvbap.
        PERFORM vbap_c_aufbauen.
        IF vbap-posnr < vs_abpos.
          vs_abpos = vbap-posnr.
        ENDIF.
        IF vbap-posnr > vs_bipos.
          vs_bipos = vbap-posnr.
        ENDIF.
      ENDIF.
    ENDSELECT.
  ENDLOOP.

  SORT cvbap BY vbeln posnr.
ENHANCEMENT-POINT VBAP_SELECT_03 SPOTS ES_SAPMV50A.

ENDFORM.                    "vbap_select
*eject



*---------------------------------------------------------------------*
*       FORM VBAP_SELECT_single                                       *
*---------------------------------------------------------------------*
*       eine Kundenauftragsposition lesen                             *
*---------------------------------------------------------------------*

FORM vbap_select_single USING value(vs_mandt) LIKE sy-mandt
                              value(vs_vbeln) LIKE vbap-vbeln
                              value(vs_abpos) LIKE vbap-posnr.

  DATA: help_vbap LIKE vbapvb.

  CLEAR cvbap.
  SELECT SINGLE *
           INTO vbap
           FROM vbap
                WHERE vbeln  = :vs_vbeln
                AND   posnr  = :vs_abpos.
  PERFORM vbap_c_aufbauen.

* im Falle der product selection werden die abhängigen Positionen
* ebenfalls gelesen
  IF vbap-prosa EQ chara.
    help_vbap = cvbap.
    SELECT *
           INTO vbap
           FROM vbap
                WHERE vbeln  = :vs_vbeln
                AND   uepos  = :vs_abpos.

      READ TABLE xvbap WITH KEY vbap(19).
      IF sy-subrc NE 0.
        CLEAR xvbap.
        MOVE-CORRESPONDING vbap TO xvbap.
        APPEND xvbap.
      ENDIF.
      READ TABLE cvbap WITH KEY vbap(19).
      IF sy-subrc NE 0.
        cvbap = xvbap.
        APPEND cvbap.
      ENDIF.
    ENDSELECT.
    cvbap = help_vbap.
  ENDIF.

  SORT cvbap BY vbeln posnr.

ENDFORM.                    "vbap_select_single
*eject

*---------------------------------------------------------------------*
*       FORM VBAP_C_AUFBAUEN                                         *
*---------------------------------------------------------------------*
*       Die interne Tabelle CVBAP wird aus der Datenbank-Tabelle      *
*       VBAP aufgebaut.                                               *
*---------------------------------------------------------------------*

FORM vbap_c_aufbauen.

  FIELD-SYMBOLS: <ls_vbak> TYPE vbak.

* CVBAP = VBAP.
  MOVE-CORRESPONDING vbap TO cvbap.

  IF cvbak-vbeln EQ vbap-vbeln.
    ASSIGN cvbak TO <ls_vbak>.
  ELSE.
    READ TABLE cvbak ASSIGNING <ls_vbak>
                     WITH KEY vbeln = vbap-vbeln.
  ENDIF.
  IF <ls_vbak> IS ASSIGNED.
    CALL FUNCTION 'SHP_FILL_DYN_PART_XVBAP'
      CHANGING
        cs_vbap        = cvbap
        is_vbak        = <ls_vbak>
      EXCEPTIONS
        internal_error = 1
        wrong_call     = 2
        OTHERS         = 3
               .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  APPEND cvbap.

ENDFORM.                    "vbap_c_aufbauen
*eject



*---------------------------------------------------------------------*
*       FORM VBUK_SELECT_PROBE                                        *
*---------------------------------------------------------------------*
*       Vertriebsbelegkopf zum Prüfen einer externen Nummer           *
*---------------------------------------------------------------------*
FORM vbuk_select_probe USING value(mandt) LIKE sy-mandt
                             value(vbeln) LIKE vbuk-vbeln.
  SELECT SINGLE *
         FROM vbuk
         WHERE vbeln = likp-vbeln.
  IF sy-subrc = 0.
    PERFORM lieferung_entsperren USING likp-vbeln.
    MESSAGE e008 WITH likp-vbeln.
  ENDIF.

ENDFORM.                    "vbuk_select_probe
*eject


*---------------------------------------------------------------------*
*       FORM VBEP_SELECT                                              *
*---------------------------------------------------------------------*
*       Kundenauftragseinteilungen zur Position lesen                 *
*---------------------------------------------------------------------*

FORM vbep_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE vbep-vbeln
                       value(vs_abpos) LIKE vbep-posnr
                       value(vs_bipos) LIKE vbep-posnr.

  SELECT *
           APPENDING TABLE cvbep
           FROM vbep
                WHERE vbeln  = :vs_vbeln
                AND   posnr >= :vs_abpos
                AND   posnr <= :vs_bipos.

  SORT cvbep BY posnr edatu etenr.

  DELETE ADJACENT DUPLICATES FROM cvbep COMPARING vbeln posnr etenr.

ENDFORM.                    "vbep_select
*eject

*---------------------------------------------------------------------*
*       FORM VBEP_SELECT_SINGLE
*
*---------------------------------------------------------------------*
*       Kundenauftragseinteilungen zur einer Position lesen           *
*---------------------------------------------------------------------*

FORM vbep_select_single
                 TABLES ct_vbep STRUCTURE vbepvb
                 USING  value(vs_vbeln) LIKE vbep-vbeln
                        value(vs_posnr) LIKE vbep-posnr.

  SELECT *
           APPENDING TABLE cvbep
           FROM vbep
                WHERE vbeln  = :vs_vbeln
                AND   posnr  = :vs_posnr.

  SORT cvbep BY posnr edatu etenr.

  DELETE ADJACENT DUPLICATES FROM cvbep COMPARING vbeln posnr etenr.

  ct_vbep[] = cvbep[].

ENDFORM.                    "vbep_select_single
*eject


*---------------------------------------------------------------------*
*       FORM VBFA_SELECT                                              *
*---------------------------------------------------------------------*
*       Belegfluß Auftrag lesen                                       *
*---------------------------------------------------------------------*
FORM vbfa_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbelv) LIKE vbfa-vbelv.

  SELECT *
         APPENDING TABLE cvbfa
         FROM vbfa
              WHERE vbelv = :vs_vbelv.

  SORT cvbfa BY mandt vbelv posnv vbeln posnn vbtyp_n.

ENDFORM.                    "vbfa_select
*eject


*---------------------------------------------------------------------*
*       FORM VBFA_SELECT_POS                                          *
*---------------------------------------------------------------------*
*       Belegfluß Auftrag für eine Position lesen                     *
*---------------------------------------------------------------------*
FORM vbfa_select_pos USING value(vs_mandt) LIKE sy-mandt
                           value(vs_vbelv) LIKE vbfa-vbelv
                           value(vs_abpos) LIKE vbfa-posnv
                           value(vs_bipos) LIKE vbfa-posnv.

  SELECT *
           APPENDING TABLE cvbfa
           FROM vbfa
                WHERE vbelv = :vs_vbelv
                AND   posnv >= :vs_abpos
                AND   posnv <= :vs_bipos.

  SORT cvbfa BY mandt vbelv posnv vbeln posnn vbtyp_n.

ENDFORM.                    "vbfa_select_pos
*eject

*---------------------------------------------------------------------*
*       FORM VBKD_SELECT                                              *
*---------------------------------------------------------------------*
*       Kaufmännische Daten lesen                                     *
*---------------------------------------------------------------------*

FORM vbkd_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE vbkd-vbeln
                       value(vs_abpos) LIKE vbkd-posnr
                       value(vs_bipos) LIKE vbkd-posnr.

  SELECT *
           INTO vbkd
           FROM vbkd
                WHERE vbeln  = :vs_vbeln
                AND   posnr >= :vs_abpos
                AND   posnr <= :vs_bipos.
    PERFORM vbkd_c_aufbauen.
  ENDSELECT.


  SORT cvbkd BY mandt vbeln posnr.

ENDFORM.                    "vbkd_select
*eject


*---------------------------------------------------------------------*
*       FORM VBKD_C_AUFBAUEN
*---------------------------------------------------------------------*
*       Die interne Tabelle CVBKD wird aus der Datenbank-Tabelle      *
*       VBKD aufgebaut.                                               *
*---------------------------------------------------------------------*

FORM vbkd_c_aufbauen.

  MOVE-CORRESPONDING vbkd TO cvbkd.
  APPEND cvbkd.

ENDFORM.                    "vbkd_c_aufbauen
*eject


*---------------------------------------------------------------------*
*       FORM VBPA_SELECT                                              *
*---------------------------------------------------------------------*
*       Belegpartner lesen                                            *
*---------------------------------------------------------------------*
* P30K136610 DS
FORM vbpa_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE vbpa-vbeln.


  CALL FUNCTION 'SD_PARTNER_READ'
    EXPORTING
      f_vbeln  = vs_vbeln
      object   = 'VBPA'
    TABLES
      i_xvbadr = xvbadr
      i_xvbpa  = xvbpa
      i_yvbadr = yvbadr
      i_yvbpa  = yvbpa
    EXCEPTIONS
      OTHERS   = 1.

  SORT xvbadr BY adrnr.                                     "n_623808

ENDFORM.                    "vbpa_select
*eject


*---------------------------------------------------------------------*
*       FORM VBPA_X_AUFBAUEN
*---------------------------------------------------------------------*
*       Die Belegpartner werden von der Datenbank gelesen.            *
*---------------------------------------------------------------------*
FORM vbpa_x_aufbauen.

  xvbpa = vbpa.
  APPEND xvbpa.

ENDFORM.                    "vbpa_x_aufbauen
*eject


*---------------------------------------------------------------------*
*       FORM VBPA_SELECT_COPY                                         *
*---------------------------------------------------------------------*
*       Belegpartner lesen beim kopieren aus einem Auftrag            *
*---------------------------------------------------------------------*

FORM vbpa_select_copy USING value(vs_mandt) LIKE sy-mandt
                            value(vs_vbeln) LIKE vbpa-vbeln
                            value(vs_abpos) LIKE vbpa-posnr
                            value(vs_bipos) LIKE vbpa-posnr.

  DATA: BEGIN OF LT_XVBADR OCCURS 5.                      "V_n_1592689
          INCLUDE STRUCTURE SADRVB.
  DATA: END OF LT_XVBADR.

* Bei Belieferung aus Auftrag bestehende Einträge der XVBADR merken
* und mit neuer XVBADR abmischen
  IF v50agl-deliver_sales_order = 'X'.
    lt_xvbadr[] = xvbadr[].

    CALL FUNCTION 'SD_PARTNER_READ'
      EXPORTING
        f_vbeln  = vs_vbeln
        object   = 'VBPA'
      TABLES
        i_xvbadr = xvbadr
        i_xvbpa  = cvbpa.

    APPEND LINES OF lt_xvbadr TO xvbadr.
    SORT xvbadr BY adrnr.
    DELETE ADJACENT DUPLICATES FROM xvbadr COMPARING adrnr.

  ELSE.                                                   "^_n_1592689

    CALL FUNCTION 'SD_PARTNER_READ'                         "50A TAX
       EXPORTING
            f_vbeln  = vs_vbeln
            object   = 'VBPA'
       TABLES
            i_xvbadr = xvbadr
            i_xvbpa  = cvbpa.

  SORT xvbadr BY adrnr.                                     "n_623808
  ENDIF.                                                    "n_1592689

ENDFORM.                    "vbpa_select_copy
*eject


*---------------------------------------------------------------------*
*       FORM VBPA_C_AUFBAUEN
*---------------------------------------------------------------------*
*       Die interne Tabelle CVBPA wird aus der Datenbank-Tabelle      *
*       VBPA aufgebaut.                                               *
*---------------------------------------------------------------------*

FORM vbpa_c_aufbauen.

  CALL FUNCTION 'SD_VBPA_RECORD_COMPLETE'                   "HP_301429
       CHANGING
              frs_vbpa = vbpa.

  cvbpa = vbpa.

  IF vtcom-vkorg IS INITIAL AND NOT cvbak-vkorg IS INITIAL.
    vtcom-vkorg = cvbak-vkorg.
  ENDIF.
  IF vtcom-vtweg IS INITIAL AND NOT cvbak-vtweg IS INITIAL.
    vtcom-vtweg = cvbak-vtweg.
  ENDIF.
  IF vtcom-spart IS INITIAL AND NOT cvbak-spart IS INITIAL.
    vtcom-spart = cvbak-spart.
  ENDIF.

  vtcom-msgkz = 'U'.
  vtcom-parvw = vbpa-parvw.
  vtcom-kunnr = vbpa-kunnr.
  vtcom-lifnr = vbpa-lifnr.
  vtcom-parnr = vbpa-parnr.
  vtcom-pernr = vbpa-pernr.
  CLEAR kupav.

  CALL FUNCTION 'VIEW_KUPAV'
    EXPORTING
      comwa   = vtcom
    IMPORTING
      pawa    = kupav
      tpar_wa = tpar
    EXCEPTIONS
      no_lfa1 = 1
      no_knvk = 2.

  cvbpa-name1 = kupav-name1.
  cvbpa-lzone = kupav-lzone.
  cvbpa-spras = kupav-spras.
  cvbpa-telfx = kupav-telfx.
  cvbpa-teltx = kupav-teltx.
  cvbpa-telx1 = kupav-telx1.

  IF cvbpa-adrnr CN '0 '.
    PERFORM sadr_select USING cvbpa-adrnr cvbpa-adrnp cvbpa-adrda.
    IF sadr-name1 NE ' '.
      MOVE-CORRESPONDING sadr TO xvbadr.                    "SADR40A
      cvbpa-name1 = xvbadr-name1.
      cvbpa-land1 = xvbadr-land1.
      cvbpa-lzone = xvbadr-lzone.
      cvbpa-spras = xvbadr-spras.
      IF cvbpa-parvw = parvw_we.
        kuwev-name1 = cvbpa-name1.
      ENDIF.
    ENDIF.
  ENDIF.

  APPEND cvbpa.

ENDFORM.                    "vbpa_c_aufbauen
*eject




*---------------------------------------------------------------------*
*       FORM VBUK_SELECT                                              *
*---------------------------------------------------------------------*
*       Kundenauftragsstatus lesen                                    *
*---------------------------------------------------------------------*
FORM vbuk_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE vbuk-vbeln.

  DATA: BEGIN OF vbukkey,
                 mandt LIKE vbuk-mandt,
                 vbeln LIKE vbuk-vbeln,
        END OF vbukkey.
  vbukkey-mandt = vs_mandt.
  vbukkey-vbeln = vs_vbeln.
  READ TABLE xvbuk WITH KEY vbukkey BINARY SEARCH.
  IF sy-subrc = 0.
    vbuk = xvbuk.
  ELSE.
    SELECT SINGLE *
           INTO vbuk
           FROM vbuk
                WHERE vbeln  = :vs_vbeln.

    IF sy-subrc = 0.
      cvbuk = vbuk.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT VBUK_SELECT_01 SPOTS ES_SAPMV50A.

ENDFORM.                    "vbuk_select
*eject

*---------------------------------------------------------------------*
*       FORM VBUP_SELECT                                              *
*---------------------------------------------------------------------*
*       Belegstatus Auftrag lesen                                     *
*---------------------------------------------------------------------*
FORM vbup_select USING value(vs_mandt) LIKE sy-mandt
                       value(vs_vbeln) LIKE vbup-vbeln.

  SELECT *
           APPENDING TABLE cvbup
           FROM vbup
                WHERE vbeln  = :vs_vbeln.

  SORT cvbup BY mandt vbeln posnr.

ENDFORM.                    "vbup_select
*eject


*---------------------------------------------------------------------*
*       FORM CHANGE_TEXT_ITEM                                         *
*---------------------------------------------------------------------*
* Text items must not have a route, a plant and a shipping point. To
* avoid an undesired delivery split these data are copied from the first
* item in CVBAP which is still to be delivered (or already delivered in
* the current delivery). In some cases it is necessary to use XVBAP
* because CVBAP contains only the selected items.
*---------------------------------------------------------------------*
FORM change_text_item TABLES it_xvbap STRUCTURE vbapvb
                             ct_cvbap STRUCTURE vbapvb
                             ct_vbup  STRUCTURE vbupvb.

  TYPES: tt_vbapvb TYPE STANDARD TABLE OF vbapvb.

  DATA: lf_text_werks LIKE vbap-werks,
        lf_text_vstel LIKE vbap-vstel,
        lf_text_route LIKE vbap-route,
        lf_flag_txt_found TYPE c,                           "n_744089
        lt_vbap_txt TYPE tt_vbapvb,                         "n_744089
        lf_index  LIKE sy-index,                            "n_1475824
        lf_flag_found TYPE c.

  FIELD-SYMBOLS: <lt_vbap> TYPE tt_vbapvb,
                 <ls_vbap_txt> LIKE vbapvb,                 "n_744089
                 <ls_vbap2> LIKE vbapvb,                    "n_744089
                 <ls_vbap> LIKE vbapvb.

* If no relevant items can be found in CVBAP check XVBAP
  DO 2 TIMES.
    CASE sy-index.
      WHEN 1.
        ASSIGN ct_cvbap[] TO <lt_vbap>.
        APPEND LINES OF ct_cvbap TO lt_vbap_txt.            "n_744089
      WHEN 2.
        ASSIGN it_xvbap[] TO <lt_vbap>.
        APPEND LINES OF ct_cvbap TO lt_vbap_txt.            "n_744089
    ENDCASE.
    SORT  lt_vbap_txt BY vbeln posnr.                       "n_1475824
    LOOP AT <lt_vbap> ASSIGNING <ls_vbap>
                      WHERE updkz NE updkz_delete
                        AND vstel EQ tvst-vstel
                        AND posar NE charb
                        AND posar NE chara.

      READ TABLE lt_vbap_txt TRANSPORTING NO FIELDS         "v_n_1475824
           WITH KEY vbeln = <ls_vbap>-vbeln
                    posnr = <ls_vbap>-posnr
           BINARY SEARCH.
      IF sy-subrc = 0.
        lf_index = sy-index.
        LOOP AT lt_vbap_txt ASSIGNING <ls_vbap_txt>
             FROM lf_index.
          IF NOT ( <ls_vbap_txt>-vbeln = <ls_vbap>-vbeln ).
            EXIT.
          ENDIF.
          IF  <ls_vbap_txt>-updkz NE updkz_delete  AND
            ( <ls_vbap_txt>-posar EQ charb         OR
              <ls_vbap_txt>-posar EQ chara ).
            lf_flag_txt_found  = charx.
            DELETE lt_vbap_txt.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.                                                "^_n_1475824

      IF lf_flag_txt_found  EQ charx.                       "^_n_744089
        READ TABLE ct_vbup WITH KEY mandt = <ls_vbap>-mandt
                                   vbeln = <ls_vbap>-vbeln
                                   posnr = <ls_vbap>-posnr
                          BINARY SEARCH.
        IF sy-subrc = 0.
          IF ct_vbup-lfsta EQ chara OR ct_vbup-lfsta EQ charb.
            lf_text_werks = <ls_vbap>-werks.
            lf_text_vstel = <ls_vbap>-vstel.
            lf_text_route = <ls_vbap>-route.
            lf_flag_found = charx.
          ELSEIF ct_vbup-lfsta EQ charc.
*         Check whether item has already been delivered in current
*         delivery
            READ TABLE xvbfa WITH KEY mandt = sy-mandt
                                      vbelv = <ls_vbap>-vbeln
                                      posnv = <ls_vbap>-posnr
                                      vbeln = likp-vbeln
                             TRANSPORTING NO FIELDS.
            IF sy-subrc EQ 0.
              lf_text_werks = <ls_vbap>-werks.
              lf_text_vstel = <ls_vbap>-vstel.
              lf_text_route = <ls_vbap>-route.
              lf_flag_found = charx.
            ENDIF.
          ENDIF.
          IF lf_flag_found EQ charx.                        "v_n_744089
            LOOP AT ct_cvbap ASSIGNING <ls_vbap2>
                     WHERE updkz NE updkz_delete
                       AND vbeln EQ <ls_vbap>-vbeln
                       AND posar CA 'AB'.
              IF <ls_vbap2>-werks IS INITIAL.
                <ls_vbap2>-werks = lf_text_werks.
              ENDIF.
              IF <ls_vbap2>-vstel IS INITIAL.
                <ls_vbap2>-vstel = lf_text_vstel.
              ENDIF.
              IF <ls_vbap2>-route IS INITIAL.
                <ls_vbap2>-route = lf_text_route.
              ENDIF.
              CLEAR lf_flag_found.
*         line deleted                                         "n_838385
            ENDLOOP.
            DELETE lt_vbap_txt WHERE posar CA 'AB' AND      "n_838385
                                     vbeln EQ <ls_vbap>-vbeln.
            CLEAR lf_flag_txt_found.                        "n_838385
          ENDIF.                                            "^_n_744089
        ENDIF.
      ENDIF.                                                "n_744089
    ENDLOOP.
    REFRESH  lt_vbap_txt.                                   "n_744089
  ENDDO.
ENDFORM.                    "change_text_item
*eject

*---------------------------------------------------------------------*
*       FORM VBUP_SELECT_POS                                          *
*---------------------------------------------------------------------*
*       Belegstatus Auftrag für eine Gruppe Positionen lesen          *
*---------------------------------------------------------------------*
FORM vbup_select_pos USING value(vs_mandt) LIKE sy-mandt
                           value(vs_vbeln) LIKE vbup-vbeln
                           value(vs_abpos) LIKE vbup-posnr
                           value(vs_bipos) LIKE vbup-posnr.

  SELECT *
           APPENDING TABLE cvbup
           FROM vbup
                WHERE vbeln  = :vs_vbeln
                AND   posnr >= :vs_abpos
                AND   posnr <= :vs_bipos.

  SORT cvbup BY mandt vbeln posnr.

ENDFORM.                    "vbup_select_pos
*eject

*---------------------------------------------------------------------*
*       FORM SADR_SELECT                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VS_ADRNR                                                      *
*---------------------------------------------------------------------*
FORM sadr_select USING vs_adrnr LIKE vbpa-adrnr
                       vs_adrnp LIKE vbpa-adrnp
                       vs_adrda LIKE vbpa-adrda.

  DATA: lvs_vbadr   TYPE   vbadr.
  DATA: lvf_persnumber TYPE ad_persnum.

  CLEAR sadr.
  IF vs_adrda CA 'ABC '.
    read_sadr_only = charx.
  ELSE.
    CLEAR read_sadr_only.
  ENDIF.

  address_selection-addrnumber = vs_adrnr.
  address_selection-nation     = space.
  lvf_persnumber               = vs_adrnp.
* address_selection-date       = likp-lfdat.  " not yet implemented
  CALL FUNCTION 'SD_ADDRESS_GET'
    EXPORTING
      fif_address_number      = address_selection-addrnumber
      fif_personal_number     = lvf_persnumber
      fif_address_indicator   = vs_adrda
      fif_read_sadr_only      = read_sadr_only
    IMPORTING
      fes_address             = lvs_vbadr
    EXCEPTIONS
      address_not_found       = 1
      address_type_not_exists = 2
      no_person_number        = 3
      OTHERS                  = 4.                          "SADR40C
  IF sy-subrc = 0.
    MOVE-CORRESPONDING lvs_vbadr TO sadr.
    CLEAR xvbadr.                                           "470
    READ TABLE xvbadr WITH KEY vs_adrnr BINARY SEARCH.
    CASE sy-subrc.
      WHEN 4.
        MOVE-CORRESPONDING lvs_vbadr TO xvbadr.             "SADR40C
        INSERT xvbadr INDEX sy-tabix.
      WHEN 8.
        MOVE-CORRESPONDING lvs_vbadr TO xvbadr.             "SADR40C
        APPEND xvbadr.
    ENDCASE.
  ENDIF.
ENDFORM.                    "sadr_select

*#cj-begin
*---------------------------------------------------------------------*
*       FORM KONV_SELECT                                              *
*---------------------------------------------------------------------*
*  Die interne Tabelle TKOMV wird gefüllt für die Preisfindung        *
*---------------------------------------------------------------------*
FORM konv_select.

  DATA: lf_general_read.                                    "SP_315408

  PERFORM p_komk_komp_fuellen(sapfv50p) USING 'K'.

  IF tkomv[] IS INITIAL.                                    "SP_315408
    lf_general_read = 'X'.
  ENDIF.

  CALL FUNCTION 'RV_KONV_SELECT'
    EXPORTING
      comm_head_i           = tkomk
      general_read          = lf_general_read               "SP_315408
      read_condition_record = 'X'
    IMPORTING
      comm_head_e           = tkomk
    TABLES
      tkomv                 = tkomv.
* MODIFY TKOMK INDEX TKOMK-IX_KOMK.

ENDFORM.                    "konv_select
*#cj-end
*&---------------------------------------------------------------------*
*&      Form  VBUV_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LIKP_VBELN  text                                           *
*----------------------------------------------------------------------*
FORM vbuv_select USING p_likp_vbeln LIKE likp-vbeln.

  SELECT * FROM vbuv INTO TABLE xvbuv WHERE vbeln EQ p_likp_vbeln
         ORDER BY PRIMARY KEY.
  yvbuv[] = xvbuv[].

ENDFORM.                               " VBUV_SELECT