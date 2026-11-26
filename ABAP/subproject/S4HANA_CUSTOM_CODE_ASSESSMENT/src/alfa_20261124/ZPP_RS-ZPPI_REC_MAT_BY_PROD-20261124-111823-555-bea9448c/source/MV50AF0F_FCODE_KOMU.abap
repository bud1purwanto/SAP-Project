***INCLUDE MV50AF0F_FCODE_KOMU .
*---------------------------------------------------------------------*
*       FORM FCODE_KOMU                                               *
*---------------------------------------------------------------------*
*       Die Kommissioniermengen werden als Liefermengen übernommen    *
*---------------------------------------------------------------------*
FORM fcode_komu.

  TYPES:                                                    "v_n_747160
    BEGIN OF ixlips_s,
      tabix TYPE sytabix,
      xlips TYPE lipsvb,
    END OF ixlips_s.

  DATA:
    lt_ixlips_old TYPE TABLE OF ixlips_s
  , ls_ixlips TYPE ixlips_s
  , ls_cvbfs_save like line of cvbfs                          "n_1055366
  , lt_cvbfs_old type table of VBFS
  , lf_msgno TYPE symsgno                                   "^_n_747160
  , lf_msgty_set_for_vbfs LIKE v50agl-msgty_set_for_vbfs    "n_761857
  , lf_subrc                   TYPE sysubrc
  , ls_vbapf                   TYPE vbapf

  , BEGIN OF da_splitpos OCCURS 0
  ,             posnr          LIKE vbup-posnr
  , END   OF da_splitpos
  , if_save_kommirueck LIKE v50agl-kommirueckmeldung

  , save_ilips LIKE ilips OCCURS 15
  , lf_msgty LIKE sy-msgty VALUE 'E'
  , lf_rcode LIKE sy-subrc
  .

  DATA:

  lf_sy-subrc LIKE sy-subrc,

  BEGIN OF ls_vbfa OCCURS 0,
             erdat LIKE vbfa-erdat,
             erzet LIKE vbfa-erzet,
             plmin LIKE vbfa-plmin,
             taqui LIKE vbfa-taqui,
             flag  LIKE vbfa-taqui,
             rfmng LIKE vbfa-rfmng,
             updkz LIKE xvbfa-updkz,
  END OF ls_vbfa.

  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.
  FIELD-SYMBOLS: <ls_xlips_korr> LIKE LINE OF xlips,
                 <ls_ixlips> TYPE ixlips_s.                 "n_747160

  DATA: v50agl-msgty_set_for_vbfs_old LIKE v50agl-msgty_set_for_vbfs. "_n_1636578

  save_ilips[] = ilips[].
  REFRESH ilips.

  REFRESH da_splitpos.
  LOOP AT xlips ASSIGNING <ls_xlips>.

    IF <ls_xlips>-updkz NE updkz_delete.
      ilips-posnr = <ls_xlips>-posnr.
      ilips-tabix = sy-tabix.
      APPEND ilips.
      ls_ixlips-tabix = ilips-tabix.                         "v_n_871125
      ls_ixlips-xlips = <ls_xlips>.
      append ls_ixlips to lt_ixlips_old.                     "^_n_871125
    ENDIF.

    IF v50agl-kommirueckmeldung = charx.
      PERFORM xvbapf_lesen_direkt(sapfv50p)
                     USING    <ls_xlips>-vbeln
                              <ls_xlips>-posnr
                     CHANGING ls_vbapf
                              sy-subrc.
      IF <ls_xlips>-kzfme CA kzfme_ws.
        <ls_xlips>-pikmg = ls_vbapf-qmengev.
      ELSEIF NOT ls_vbapf-qmenge_f IS INITIAL.               "v_n_997511
        <ls_xlips>-pikmg = ls_vbapf-qmenge_f
                           * <ls_xlips>-umvkn / <ls_xlips>-umvkz.
      ELSE.                                                  "^_n_997511
        <ls_xlips>-pikmg = ls_vbapf-qmenge
                           * <ls_xlips>-umvkn / <ls_xlips>-umvkz.
      ENDIF.
      <ls_xlips>-vrkmp = <ls_xlips>-vrkme.
    ENDIF.

    IF NOT <ls_xlips>-uecha IS INITIAL AND <ls_xlips>-pikmg = 0.
      READ TABLE xlips WITH KEY vbeln = lips-vbeln
                                posnr = lips-uecha
                                BINARY SEARCH ASSIGNING
                                <ls_xlips_korr>.
      IF sy-subrc = 0.
        IF <ls_xlips_korr>-uepos IS INITIAL AND NOT
           <ls_xlips_korr>-grkor IS INITIAL.
          da_splitpos-posnr = <ls_xlips>-uecha.
          COLLECT da_splitpos.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT <ls_xlips>-uecha IS INITIAL AND                  "v_n_542596
           <ls_xlips>-pikmg >= 0.                           "^_n_542596
      da_splitpos-posnr = <ls_xlips>-uecha.
      COLLECT da_splitpos.
*     lines deleted                                             n_812394
    ENDIF.
*   lines deleted                                               n_871125
  ENDLOOP.

* lines deleted                                                 n_812394
* store new messages in cvbfs
  lt_cvbfs_old[] = cvbfs[].
  REFRESH cvbfs.                                  "v_n_761857 ^_n_747160
* line deleted
  lf_msgty_set_for_vbfs = v50agl-msgty_set_for_vbfs.
  v50agl-msgty_set_for_vbfs = 'EWIS'.                       "^_n_761857

  SORT da_splitpos.
  SORT ilips BY posnr.

  LOOP AT xlips WHERE updkz NE updkz_delete.
    slips-tabix = ilips-tabix = sy-tabix.                   "n_747160
    lips = xlips.
     *lips = lips.
    PERFORM lips_referenz_lesen(sapfv50p).
    PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
*...                                 WA schon gebucht?
*   if xvbup-wbsta = 'C'.
* Teil-WE
ENHANCEMENT-SECTION     mv50af0f_fcode_komu_05 SPOTS es_sapmv50a.
    IF xvbuk-wbstk = 'C' AND v50agl-spe_inb_dlv IS INITIAL.
      MESSAGE e602.
      EXIT.
    ENDIF.
END-ENHANCEMENT-SECTION.

*...                                 fakturiert?
    IF xvbup-fksta = 'C'.
      PERFORM message_handling_variabel(sapmv50a)
                                   USING lips-posnr
                                         '186'
                                         lf_msgty
                                         'VL'
                                         space
                                         space
                                         space
                                         space
                                         gs_mhpar
                                         v50agl-msgvs
                                CHANGING lf_msgty
                                         lf_rcode.
      IF lf_msgty CA 'AEX'.
        EXIT.
      ENDIF.
    ENDIF.
    IF xvbup-kosta CA 'BC'.

ENHANCEMENT-POINT fcode_komu_01 SPOTS es_sapmv50a.

* Teil-WE: die folgenden Zeilen werden durchlaufen, wenn
*  - kein Teil-WE vorliegt (status quo) oder
*  - die Pickmenge größer als die Liefermenge ist
      IF xlips-pikmg > xlips-lfimg OR likpd-kzebu IS INITIAL.
        PERFORM check_and_set_pikmg_lfimg CHANGING lf_subrc.
        CHECK lf_subrc = 0.
      ENDIF.

ENHANCEMENT-SECTION     mv50af0f_fcode_komu_02 SPOTS es_sapmv50a.
      PERFORM pod_inbound_data_processing.
END-ENHANCEMENT-SECTION.

*     Checks on main items of a batch split are performed later when
*     the cumulated quantities are known.
      IF lips-uecha IS INITIAL.
        READ TABLE da_splitpos WITH KEY posnr = lips-posnr
                               BINARY SEARCH
                               TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.                                   "n_540968
          IF tvlp-chhpv  NE space AND
             ( xvbup-pksta CA 'BC' OR xvbuk-trsta CA 'BC' ).
            PERFORM check_cum_pack_quantity(sapfv50p) TABLES xlips
                                                             ilips
                                                             save_ilips
                                                      USING  lips-vbeln
                                                             lips-posnr.
          ENDIF.
        ENDIF.
      ELSEIF v50agl-confirm_central EQ space.
*       Check serial numbers and packed quantity for batch split items
        PERFORM lips-lfimg_pruefen(sapfv50p) USING '78'.
      ENDIF.

      PERFORM lips_bearbeiten(sapfv50p).

    ELSE.
*     If cumulated quantity of main item is packed: special check is
*     necessary before the main item is changed
      READ TABLE da_splitpos WITH KEY posnr = lips-posnr
                             BINARY SEARCH
                             TRANSPORTING NO FIELDS.
      IF sy-subrc    EQ 0     AND
         tvlp-chhpv  NE space AND
         ( xvbup-pksta CA 'BC' OR xvbuk-trsta CA 'BC' ).
        PERFORM check_cum_pack_quantity(sapfv50p) TABLES xlips
                                                         ilips
                                                         save_ilips
                                                  USING  lips-vbeln
                                                         lips-posnr.
      ENDIF.
    ENDIF.
  ENDLOOP.

  xlips_chsp_rueckmeldung = charx.
  if_save_kommirueck = v50agl-kommirueckmeldung.
  CLEAR v50agl-kommirueckmeldung.
  PERFORM position_gewichtsupdate_chsp(sapfv50p) USING charx.
  v50agl-kommirueckmeldung = if_save_kommirueck.
  xlips_chsp_rueckmeldung = space.

  LOOP AT xlips WHERE updkz NE updkz_delete.
    slips-tabix = ilips-tabix = sy-tabix.                   "n_747160
    lips = xlips.
     *lips = lips.
    PERFORM lips_referenz_lesen(sapfv50p).
    PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
*...                                 WA schon gebucht?
*   if xvbup-wbsta = 'C'.
* Teil-WE
ENHANCEMENT-SECTION     mv50af0f_fcode_komu_04 SPOTS es_sapmv50a.
    IF xvbuk-wbstk = 'C' AND v50agl-spe_inb_dlv IS INITIAL.
      MESSAGE e602.
      EXIT.
    ENDIF.
END-ENHANCEMENT-SECTION.

*...                                 fakturiert?
    IF xvbup-fksta = 'C'.
      PERFORM message_handling_variabel(sapmv50a)
                                   USING lips-posnr
                                         '186'
                                         lf_msgty
                                         'VL'
                                         space
                                         space
                                         space
                                         space
                                         gs_mhpar
                                         v50agl-msgvs
                                CHANGING lf_msgty
                                         lf_rcode.
      IF lf_msgty CA 'AEX'.
        EXIT.
      ENDIF.
    ENDIF.
    IF xvbup-kosta CA ' A'.
      READ TABLE da_splitpos WITH KEY xvbup-posnr BINARY SEARCH.

*...Prüfung ob jüngster, existierender VBFA TA-Satz ein aus der
*   LT0G Transaktion erzeugter ist.
*   In diesem Fall möchte man noch keine Anpassung.
*   Dies soll bei einer Pikmg = 0 gelten.
      IF xlips-pikmg = 0.
        CLEAR: ls_vbfa.

        lf_sy-subrc = sy-subrc.

        LOOP AT xvbfa WHERE vbelv   = xlips-vbeln AND
                            posnv   = xlips-posnr AND
                            vbtyp_n = 'Q'.

          IF ls_vbfa IS INITIAL.
            ls_vbfa-erdat = xvbfa-erdat.
            ls_vbfa-erzet = xvbfa-erzet.
            ls_vbfa-taqui = xvbfa-taqui.
            ls_vbfa-plmin = xvbfa-plmin.
            ls_vbfa-rfmng = xvbfa-rfmng.
            ls_vbfa-updkz = xvbfa-updkz.
          ELSEIF ( xvbfa-erdat > ls_vbfa-erdat ) OR
                 ( xvbfa-erdat = ls_vbfa-erdat AND
                   xvbfa-erzet >= ls_vbfa-erzet ).
            IF NOT ls_vbfa-updkz IS INITIAL.                "n_559049
              EXIT.                                         "n_559049
            ENDIF.                                          "n_559049
            ls_vbfa-erdat = xvbfa-erdat.
            ls_vbfa-erzet = xvbfa-erzet.
            ls_vbfa-plmin = xvbfa-plmin.
            ls_vbfa-taqui = xvbfa-taqui.
            ls_vbfa-rfmng = xvbfa-rfmng.
            ls_vbfa-updkz = xvbfa-updkz.
          ENDIF.
        ENDLOOP.
        IF ls_vbfa-plmin = '-'.
        ELSEIF ls_vbfa-taqui = 'X' AND
*           ( ls_vbfa-updkz = charu or
*             ls_vbfa-updkz = chari ).
            ( ( ls_vbfa-updkz = charu OR                    "n_559049
                ls_vbfa-updkz = chari ) OR                  "n_559049
*            gs_mhpar-glomd = GC_GLOMD-DIALOG ) .            "n_559049
*            gs_mhpar-glomd CA 'AB' ).                       "n_652270
                gs_mhpar-glomd = gc_glomd-dialog OR         "v_n_712106
              ( v50agl-kommirueckmeldung NE charx AND
                      sy-binpt = charx ) ) .                "^_n_712106


          ls_vbfa-flag = 'X'.
        ENDIF.

        sy-subrc = lf_sy-subrc.

      ENDIF.

      IF sy-subrc = 0 OR xvbup-koqua = 'C' OR xvbup-lvsta = 'C'
                      OR ls_vbfa-flag = 'X'.

ENHANCEMENT-POINT fcode_komu_02 SPOTS es_sapmv50a.

* Teil-WE: die folgenden Zeilen werden durchlaufen, wenn
*  - kein Teil-WE vorliegt (status quo) oder
*  - die Pickmenge größer als die Liefermenge ist
        IF xlips-pikmg > xlips-lfimg OR likpd-kzebu IS INITIAL.
          PERFORM check_and_set_pikmg_lfimg CHANGING lf_subrc.
          CHECK lf_subrc = 0.
        ENDIF.


ENHANCEMENT-SECTION     mv50af0f_fcode_komu_03 SPOTS es_sapmv50a.
        PERFORM pod_inbound_data_processing.
END-ENHANCEMENT-SECTION.

*       Checks on main items of a batch split are performed later when
*       the cumulated quantities are known.
        IF ( NOT lips-uecha IS INITIAL ) AND                "n_v_540968
             v50agl-confirm_central EQ space.               "n_^_540968
*        Check serial numbers and packed quantity for batch split items
          PERFORM lips-lfimg_pruefen(sapfv50p) USING '78'.
        ENDIF.

        PERFORM lips_bearbeiten(sapfv50p).
      ENDIF.
    ENDIF.
  ENDLOOP.


  xlips_chsp_rueckmeldung = charx.
  if_save_kommirueck = v50agl-kommirueckmeldung.
  CLEAR v50agl-kommirueckmeldung.
  PERFORM position_gewichtsupdate_chsp(sapfv50p)
                         USING charx.
  v50agl-kommirueckmeldung = if_save_kommirueck.
  xlips_chsp_rueckmeldung = space.

* Perform checks on batch split main items (cumulated quantities are
* consolidated here): All checks except picked quantity check
  LOOP AT da_splitpos.
    READ TABLE ilips WITH KEY posnr = da_splitpos-posnr
                          BINARY SEARCH.
    READ TABLE xlips INDEX ilips-tabix.
    slips-tabix = ilips-tabix = sy-tabix.                   "n_747160
    lips = xlips.
    IF ( lips-uepos IS INITIAL AND NOT
           lips-grkor IS INITIAL ).
      PERFORM korr_mengen_aendern(sapmv50a) USING lips-posnr.
    ENDIF.

     *lips = lips.
    IF v50agl-confirm_central EQ space OR
       lips-uepvw             EQ chara.
      PERFORM lips_referenz_lesen(sapfv50p).
      PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
      IF v50agl-confirm_central EQ space.
        PERFORM lips-lfimg_pruefen(sapfv50p) USING '1234578'.
        IF v50agl-chargensplitbild = 'X'.                  "v_n_1636578
         v50agl-msgty_set_for_vbfs_old = v50agl-msgty_set_for_vbfs.
         PERFORM lips-kztlf_pruefen(sapfv50p).
* Restore old value of 'v50agl-msgty_set_for_vbfs'.
         v50agl-msgty_set_for_vbfs = v50agl-msgty_set_for_vbfs_old.
        ENDIF.                                             "^_n_1636578
      ENDIF.
      IF lips-uepvw EQ chara.
        PERFORM lips_prodsel_hpupd(sapfv50p) USING chars.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH ilips.
  ilips[] = save_ilips[].

* error handling                                             "v_n_747160
  CLEAR: cvbfs.
* line deleted                                                 "n_761857
  read table cvbfs with key msgty = 'E'.
  if sy-subrc eq 0. "error -> restore original xlips
    ls_cvbfs_save = cvbfs.                                    "n_1055366
* restore batch split sub items
    LOOP AT lt_ixlips_old ASSIGNING <ls_ixlips>
      WHERE xlips-uecha NE space.
      READ TABLE xlips INDEX <ls_ixlips>-tabix.
      ilips-tabix = slips-tabix = sy-tabix.
      PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
      MOVE-CORRESPONDING <ls_ixlips>-xlips TO lips.
      PERFORM lips_bearbeiten(sapfv50p).
    ENDLOOP.
* restore kcmeng
    xlips_chsp_rueckmeldung = charx.
    if_save_kommirueck = v50agl-kommirueckmeldung.
    CLEAR v50agl-kommirueckmeldung.
    PERFORM position_gewichtsupdate_chsp(sapfv50p) USING charx.
    v50agl-kommirueckmeldung = if_save_kommirueck.
    xlips_chsp_rueckmeldung = space.
* restore batch split main item
    LOOP AT lt_ixlips_old ASSIGNING <ls_ixlips>
      WHERE xlips-uecha EQ space.
      READ TABLE xlips INDEX <ls_ixlips>-tabix.
      ilips-tabix = slips-tabix = sy-tabix.
      PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
      lips = <ls_ixlips>-xlips.
      PERFORM lips_bearbeiten(sapfv50p).
    ENDLOOP.
    cvbfs = ls_cvbfs_save.                                    "n_1055366
  else.
    READ TABLE cvbfs WITH KEY msgty = 'W'.
    IF sy-subrc NE 0.
      READ TABLE cvbfs WITH KEY msgty = 'I'.
    ENDIF.
  ENDIF.
* send message
  v50agl-msgty_set_for_vbfs = lf_msgty_set_for_vbfs.          "n_1055366
  cvbfs[] = lt_cvbfs_old[].
  IF NOT cvbfs-msgty IS INITIAL.
    lf_msgno = cvbfs-msgno.
    PERFORM message_handling
      USING cvbfs-posnr lf_msgno cvbfs-msgty cvbfs-msgid
            cvbfs-msgv1 cvbfs-msgv2 cvbfs-msgv3 cvbfs-msgv4.
  ENDIF.                                                    "^_n_747160

ENDFORM.                    "fcode_komu



*&---------------------------------------------------------------------*
*&      Form  check_and_set_pikmg_lfimg
*&---------------------------------------------------------------------*
*
*       determine picked quantity and set it into lips
*
*&---------------------------------------------------------------------*
FORM check_and_set_pikmg_lfimg CHANGING cf_subrc TYPE sy-subrc.

  DATA:
    lf_action                  TYPE akmng
  , lf_subrc                   TYPE sysubrc
  , ls_vbapf                   TYPE vbapf
  , lf_lfimg                   TYPE lfimg
  , lf_lgmng                   TYPE lgmng
  .
  cf_subrc = 0.

  PERFORM xvbapf_lesen_direkt(sapfv50p)
                 USING    lips-vbeln
                          lips-posnr
                 CHANGING ls_vbapf
                          lf_subrc.
  IF sy-subrc <> 0.
    lips-lfimg = lipsd-pikmg.
    lf_action  = 'A'.
ENHANCEMENT-POINT CHECK_AND_SET_PIKMG_LFIMG_01 SPOTS ES_SAPMV50A.
  ELSEIF xlips-kzfme CA kzfme_ws.
    lips-lfimg = ls_vbapf-qmengev.
    lf_action  = 'A'.

ENHANCEMENT-POINT fcode_komu_03 SPOTS es_sapmv50a.

  ELSE.
    lips-lgmng = ls_vbapf-qmenge.
    lf_action  = 'B'.

ENHANCEMENT-POINT fcode_komu_04 SPOTS es_sapmv50a.

  ENDIF.

  lf_lfimg = lips-lfimg.
  lf_lgmng = lips-lgmng.

  PERFORM lips_quan_set(sapfv50p) USING lf_action space.

  IF  lips-lgmng     = *lips-lgmng
  AND lips-lfimg     = *lips-lfimg
  AND lips-lgmng_flo = *lips-lgmng_flo
  AND lips-lfimg_flo = *lips-lfimg_flo.

*   no further processing in calling routine,
*   if picked quantity = delivered quantity.
    cf_subrc = 1.
ENHANCEMENT-POINT mv50af0f_fcode_komu_01 SPOTS es_sapmv50a.
                                                            "n_v_556261
* In case of using transaction VL08 it can be insufficient
* to make only one attempt to adjust the delivered quantity.
* ---> Error occurs in the first attempt.
* Therefore it is necessary to make an second attempt possible
* to avoid corrupted line items in the delivery note.
* If the flag is set to '0' the xlips will be updated--> updkz = 'U'
    IF sy-tcode = 'VL08                '.
      cf_subrc = 0.
    ENDIF.                                                  "n_^_556261
  ENDIF.

ENDFORM.                               " check_and_set_pikmg_lfimg