*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_LIEFERGRUPPE_LOE                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KORR_LIEFERGRUPPE_LOESCHEN                                *
*---------------------------------------------------------------------*
*       Beim Löschen einer Position. die zu einer Liefergruppe        *
*       gehört, werden die abhängigen Positionen gelöscht             *
*---------------------------------------------------------------------*
form korr_liefergruppe_loeschen  using da_posnr like vbap-posnr
                                       da_all   type c.

  data:  hpos_grkor like lips-grkor,
         upos_posnr like lips-posnr,
         upos_lfimg like lips-lfimg value 0,                       "#&rm
         charg_hpos like lips,
         da_msgty like sy-msgty,
         LF_SUBRC   LIKE SY-SUBRC,                            "n_502457
         BEGIN OF LT_SUBITEMS OCCURS 0,                     "v_n_752921
           POSNR TYPE POSNR_VL,
           UPDKZ TYPE UPDKZ_D,
         END OF LT_SUBITEMS.                                "^_n_752921

* kein rekursiver Aufruf zulässig, weil alles in einem loop ueber UVBAP
  check: strukturpflege_rekursiv_lips = space.
  hpos_grkor = xlips-grkor.

* Aufbauen der Tabelle der Positionstruktur
  perform korr_uvbap_aufbauen.

* bestimmen der abhängigen Positionen
  loop at uvbap where uepos = da_posnr.
    perform xlips_lesen_direkt(sapfv50p) using uvbap-posnr
                                               sy-tabix.
    if xlips-kcmeng gt 0  and
       xlips-prosa ne chara.
      upos_posnr = xlips-posnr.
      charg_hpos = xlips.
      loop at xlips where uecha eq upos_posnr
                      and vbeln eq likp-vbeln.                "n_736032
        lips = xlips.
        strukturpflege_rekursiv_lips = charx.
        perform xlips_loeschen(sapfv50p) using charx tabix_0.
        strukturpflege_rekursiv_lips = space.
        LT_SUBITEMS-POSNR = XLIPS-POSNR.                    "v_n_752921
        LT_SUBITEMS-UPDKZ = XLIPS-UPDKZ.
        APPEND LT_SUBITEMS.                                 "^_n_752921
      endloop.
      xlips = charg_hpos.
    endif.
    lips = xlips.
     *lips = xlips.                                         "wbr 46c
    strukturpflege_rekursiv_lips = charx.
    perform xlips_loeschen(sapfv50p) using charx tabix_0.
    strukturpflege_rekursiv_lips = space.
    LT_SUBITEMS-POSNR = XLIPS-POSNR.                        "v_n_752921
    LT_SUBITEMS-UPDKZ = XLIPS-UPDKZ.
    APPEND LT_SUBITEMS.                                     "^_n_752921
  endloop.
  lf_subrc = sy-subrc.

  check v50agl-new_del_mode eq space.                       "n_587009

* entsprechende Meldungen ausgeben, falls nicht löschen der Lieferung
  if da_all ne charx.
    if lf_subrc ne 0 or not cvbap-grkor is initial.
      if slips-tabix = 0.              "Position wird beim anlegen gel.
        if v50agl-sammelgang ne charx.
          da_msgty = chari.
        else.
          da_msgty = chare.
        endif.
        perform message_handling(sapmv50a) using cvbap-posnr
                                                 '119'
                                                 da_msgty
                                                 'VL'
                                                 space
                                                 hpos_grkor
                                                 space
                                                 space.
      else.
        perform message_handling(sapmv50a) using cvbap-posnr
                                                 '119'
                                                 'W'
                                                 'VL'
                                                 da_posnr
                                                 hpos_grkor
                                                 space
                                                 space.
      endif.
    endif.
*   lines deleted                                              n_752921
  endif.

* delete UEPOS of remaining sub items                       "v_n_752921
  LOOP AT LT_SUBITEMS WHERE UPDKZ NE 'D'.
    READ TABLE XLIPS WITH KEY VBELN = LIKP-VBELN
                              POSNR = LT_SUBITEMS-POSNR.
    IF XLIPS-UPDKZ EQ 'D'. "POSNR not unique in XLIPS
      LOOP AT XLIPS WHERE VBELN EQ LIKP-VBELN AND
                          POSNR EQ LT_SUBITEMS-POSNR AND
                          UPDKZ NE 'D'.
        EXIT.
      ENDLOOP.
      CHECK SY-SUBRC EQ 0.
    ENDIF.

    SLIPS-TABIX = ILIPS-TABIX = SY-TABIX.
    PERFORM LIPS_BEARBEITEN_VORBEREITEN(SAPFV50P).
    CLEAR LIPS-UEPOS.
    PERFORM XLIPS_AENDERN(SAPFV50P).
  ENDLOOP.
  LF_SUBRC = SY-SUBRC.

* are all items deleted or has delivery group become incomplete?
  IF DA_ALL NE CHARX.
    IF LF_SUBRC NE 0. "all depending items deleted
      MESSAGE S179.
    ELSE. "delivery group incomplete
      MESSAGE S089 WITH HPOS_GRKOR.
    ENDIF.
  ENDIF.                                                    "^_n_752921

endform.                    "KORR_LIEFERGRUPPE_LOESCHEN
*eject