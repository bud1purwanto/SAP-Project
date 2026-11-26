*eject
*---------------------------------------------------------------------*
*       FORM STRUKT_MATERIAL_VORBEREITEN                              *
*---------------------------------------------------------------------*
*       Das strukturierte Material wird vorbereitet.                  *
*---------------------------------------------------------------------*
FORM strukt_material_vorbereiten USING s-matbf LIKE mseg-matbf
                                       s-werks LIKE mseg-werks
                                       s-lgort LIKE mseg-lgort
                                       s-charg LIKE mseg-charg
                                       s-attyp LIKE vm07m-attyp
                                       s-bflme LIKE vm07m-bflme
                                       s-xchpf LIKE vm07m-xchpf
                                       s-sobkz LIKE mseg-sobkz
                                       s-lbbsa LIKE vm07m-lbbsa
                                       s-shkzg LIKE mseg-shkzg
                                       s-xauto LIKE mseg-xauto
                                       s-subrc LIKE sy-subrc
                                       s-budat LIKE mkpf-budat.

  DATA: ls_isu_fusszeile_wa_pruefen TYPE isu_fusszeile_wa_pruefen. "IS2ERP

  s-subrc = 4.
* Begin note 663537 - Fashion
   DATA: CONSI_ACTIVE_SM      type XFELD.
   perform check_consi_procg CHANGING CONSI_ACTIVE_SM.
*\  CHECK s-xchpf IS INITIAL AND s-sobkz IS INITIAL AND
*\     ( s-attyp = attyp-vks OR s-attyp = attyp-lot OR
*\       s-attyp = attyp-dis OR NOT s-bflme IS INITIAL )
*\     AND s-lbbsa = '01'.
  CHECK s-xchpf IS INITIAL AND ( s-sobkz IS INITIAL OR
                                 s-sobkz = K       AND
                             NOT CONSI_ACTIVE_SM IS INITIAL ) AND
     ( s-attyp = attyp-vks OR s-attyp = attyp-lot OR
       s-attyp = attyp-dis OR NOT s-bflme IS INITIAL )
     AND s-lbbsa = '01'.
* End note 663537 - Fashion

  CALL FUNCTION 'MB_SHOW_MATERIAL_STRUCTURE'
       EXPORTING matbf   = s-matbf
                 werks   = s-werks
                 f_attyp = s-attyp
                 datab   = s-budat
                 datbi   = s-budat
                 f_menge = omseg-menge
                 meins   = omseg-meins
                 f_kzbwa = ovm07m-kzbwa
                 f_bflme = s-bflme
       IMPORTING subrc   = s-subrc
       TABLES    xstru   = xstru.
  CHECK s-subrc IS INITIAL.

  data: p_line_count type mb_line_depth.                   "note 544663
  describe table xstru lines p_line_count.                 "note 544663
  if ovm07m-kzbwa <> kzbwa-sz.                             "note 598289
* movement type 319 has no second header!                  "note 598289
  add 1 to p_line_count.                                   "note 544663
  endif.                                                   "note 598289
* second header-line!                                      "note 544663
  field-symbols <FS_yvm07m> like vm07m.                    "note 544663
  read table yvm07m assigning <fs_yvm07m>                  "note 544663
    with key zeilv = omseg-zeile.                          "note 544663
  if              sy-subrc = 0 and                         "note 544663
     not <fs_yvm07m>-xstor = 1 and  "MBRL                  "note 544663
     not <fs_yvm07m>-xstor = 3.     "MBSU                  "note 544663
    add p_line_count to <fs_yvm07m>-line_count.            "note 544663
*   add: xauto = u ! (same form, same parent_id)           "note 544663
*   MBRL and MBSU: already done in beleg_ergaenzen (MM07MFB1)   "544663
  endif.                                                   "note 544663

* if xmbwl is initial.
    REFRESH: yfuss, zfuss.
    LOOP AT fuss.
      IF fuss-urzei = omseg-zeile.
        yfuss = fuss.
        APPEND yfuss.
      ELSE.
        zfuss = fuss.
        APPEND zfuss.
      ENDIF.
    ENDLOOP.
* endif.
  CLEAR rm07m-kzbew.
  IF aktyp = h.
    REFRESH: prefetch01,
             prefetch02,
             prefetch03.
    LOOP AT xstru.
      MOVE-CORRESPONDING xstru TO prefetch02.
      prefetch02-werks = omseg-werks.
      prefetch02-lgort = omseg-lgort.
      COLLECT prefetch02.
      MOVE-CORRESPONDING xstru TO prefetch03.
      COLLECT prefetch03.
    ENDLOOP.
    PERFORM prefetch_ausfuehren USING x
                                      space.
    DATA: kshkzg LIKE mseg-shkzg,
          pshkzg LIKE mseg-shkzg.
    CLEAR: dm07m, vm07m, mseg, fuss.
    mseg-zeile = omseg-zeile + 1.
    IF ovm07m-kzbwa = kzbwa-sz.
      IF s-shkzg = s.
        pshkzg = h.
      ELSEIF s-shkzg = h.
        pshkzg = s.
      ENDIF.
      kshkzg = s-shkzg.
    ELSE.
      IF s-shkzg = s.
        kshkzg = h.
      ELSEIF s-shkzg = h.
        kshkzg = s.
      ENDIF.
      pshkzg = s-shkzg.
    ENDIF.
    IF kshkzg = h.
      IF odm07m-xstbw IS INITIAL.
        SELECT SINGLE * FROM t156n WHERE fcode = fcod-msth
                                    AND  bwart = space.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'T156N' fcod-msth.
        ENDIF.
      ELSE.
        SELECT SINGLE * FROM t156n WHERE fcode = fcod-msss
                                    AND  bwart = space.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'T156N' fcod-msss.
        ENDIF.
      ENDIF.
    ELSE.
      IF odm07m-xstbw IS INITIAL.
        SELECT SINGLE * FROM t156n WHERE fcode = fcod-msts
                                    AND  bwart = space.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'T156N' fcod-msts.
        ENDIF.
      ELSE.
        SELECT SINGLE * FROM t156n WHERE fcode = fcod-mssh
                                    AND  bwart = space.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'T156N' fcod-mssh.
        ENDIF.
      ENDIF.
    ENDIF.
* begin note 663537 - Fashion
    PERFORM call_badi_consi_GetCsgmtMvt using s-sobkz
                                              odm07m-xstbw
                                              kshkzg
                                     changing T156N-bwart_next.
* end note 663537 - Fashion
    mseg-bwart = msegk-bwart = t156n-bwart_next.
    mseg-urzei = omseg-zeile.
    dm07m-urerfmg = omseg-erfmg.
    mseg-xauto = s-xauto.
    CLEAR: y_zeile.
    PERFORM fcode_lesen USING fcod-nl.
    IF ovm07m-kzbwa = kzbwa-sz.
      MOVE-CORRESPONDING omseg TO msegk.
      MOVE-CORRESPONDING msegk TO mseg.
* begin note 663537 - Fashion
      IF NOT CONSI_ACTIVE_SM IS INITIAL AND
             s-sobkz = K.
        mseg-werks = omseg-werks.
        mseg-matnr = omseg-matnr.
      ENDIF.
* end note 663537 - Fashion
    ELSE.
      mseg-matnr = s-matbf.
      mseg-werks = s-werks.
      mseg-lgort = s-lgort.
      mseg-charg = s-charg.
      mseg-erfmg = omseg-erfmg.
      mseg-erfme = omseg-erfme.
      mseg-exbwr = omseg-exbwr.
      mseg-exvkw = omseg-exvkw.
      mseg-shkzg = msegk-shkzg = kshkzg.
      mseg-lifnr = omseg-lifnr.                            "note 557339
      vm07m-xhead = x.
* begin note 663537 - Fashion
      IF NOT CONSI_ACTIVE_SM IS INITIAL AND
             s-sobkz = K.
        mseg-sobkz = s-sobkz.
      ENDIF.
* end note 663537 - Fashion

      PERFORM fusszeile_wa_pruefen USING space
                                         ls_isu_fusszeile_wa_pruefen. "IS2ERP
      fuss-xselp = x.
      mseg-zeile = y_zeile + 1.
      CLEAR MSEGK-PARBU.                                  "note 326621
*                         *  write down Retail-specific    "note 328675
*                         *  article structure infos for   "note 328675
*                         *  afterwards consistence-checks "note 328675
      PERFORM RETAIL_STRUCT_ARTICLES.                      "note 328675
      clear mseg-line_id.                              "Always a new one
      call method cl_mmim_line_id_manager=>line_id_get
        changing c_line_id = mseg-line_id.
      mseg-parent_id  = omseg-line_id.
      mseg-line_depth = omseg-line_depth + 1.
* begin note 663537 - Fashion
      IF NOT CONSI_ACTIVE_SM IS INITIAL AND
*             s-sobkz = K                AND
             rm07m-kzbew is initial     AND
             NOT xmbwl IS INITIAL.
        msegk-sobkz = mseg-sobkz.
        msegk-lifnr = mseg-lifnr.
      ENDIF.
* end note 663537 - Fashion
*     no transfer material to material possible
*     in case of transfers to PO with MIGO this is necessary
      msegk-ummat = mseg-ummat.
      PERFORM fuss_fuellen USING x.
    ENDIF.
    MOVE-CORRESPONDING mseg TO msegk.
    msegk-shkzg = pshkzg.
    CLEAR: vm07m-xhead, mseg-exbwr, mseg-exvkw.
* begin note 663537 - Fashion
    PERFORM call_badi_consi_ChPriceSArt using  mseg-lifnr
                                               mseg-bwart
                                               mseg-sobkz
                                               mseg-matnr
                                               mseg-werks
                                               omseg-menge
                                               omseg-meins
                                               xstru[].
* end note 663537 - Fashion
    LOOP AT xstru.
      MOVE-CORRESPONDING xstru TO mseg.
      mseg-werks = s-werks.
      mseg-lgort = s-lgort.
      mseg-charg = s-charg.
      PERFORM fusszeile_wa_pruefen USING space
                                         ls_isu_fusszeile_wa_pruefen. "IS2ERP
      fuss-xselp = x.
      mseg-shkzg = pshkzg.
      mseg-zeile = y_zeile + 1.
*                         *  write down Retail-specific    "note 328675
*                         *  article structure infos for   "note 328675
*                         *  afterwards consistence-checks "note 328675
      PERFORM RETAIL_STRUCT_ARTICLES.                      "note 328675
      clear mseg-line_id.                              "Always a new one
      call method cl_mmim_line_id_manager=>line_id_get
        changing c_line_id = mseg-line_id.
      mseg-parent_id  = omseg-line_id.
      mseg-line_depth = omseg-line_depth + 1.
      PERFORM fuss_fuellen USING x.
    ENDLOOP.
  ELSEIF aktyp = k.
    PERFORM fcode_lesen USING fcod-kl.
    LOOP AT ymseg WHERE urzei = omseg-zeile
                  AND   xauto = s-xauto.
      READ TABLE yvm07m INDEX ymseg-zeile.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'YVM07M' ymseg-zeile.
      ENDIF.
      READ TABLE ydm07m INDEX ymseg-zeile.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'YDM07M' ymseg-zeile.
      ENDIF.
      IF ymseg-matnr = omseg-matnr.
        IF NOT ydm07m-urerfmg = omseg-erfmg.
          ydm07m-urerfmg = omseg-erfmg.
        ENDIF.
        CHECK NOT ymseg-erfmg = omseg-erfmg.
        ymseg-erfmg = omseg-erfmg.
      ELSE.
        LOOP AT xstru WHERE matnr = ymseg-matnr.
          EXIT.
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE a001 WITH 'XSTRU' ymseg-matnr.
        ENDIF.
        IF NOT ydm07m-urerfmg = omseg-erfmg.
          ydm07m-urerfmg = omseg-erfmg.
          MODIFY ydm07m INDEX ydm07m-zeild.
        ENDIF.
        CHECK NOT ymseg-erfmg = xstru-erfmg.
        ymseg-erfmg = xstru-erfmg.
      ENDIF.
      CLEAR yfuss.
      MOVE-CORRESPONDING ydm07m TO yfuss.
      MOVE-CORRESPONDING yvm07m TO yfuss.
      MOVE-CORRESPONDING ymseg TO yfuss.
      IF omseg-xauto = d.
        yfuss-xauto = d.
        CLEAR yfuss-erfmg.
      ENDIF.
      yfuss-xselk = x.
      yfuss-xselp = x.
      yfuss-xprue = x.
      yfuss-fcode = fcod-kp.
      APPEND yfuss.
      IF fcode_next = fcod-kp.
        fcode_next = fcod-ab.
      ENDIF.
    ENDLOOP.
  ENDIF.
  FREE: xstru.

ENDFORM.