***INCLUDE FV50XF0B_B_ABHAENGIGE_TABELLEN .
*---------------------------------------------------------------------*
*       FORM B_ABHAENGIGE_TABELLEN_UPDATEN                            *
*---------------------------------------------------------------------*
*                                                                     *
*       In den abhängigen Tabellen wird die richtige Belegnummer      *
*       der Lieferung eingesetzt                                      *
*                                                                     *
*       Der aktuelle Kopf steht in XLIKP                              *
*---------------------------------------------------------------------*
form b_abhaengige_tabellen_updaten using atu_temp_vbeln like likp-vbeln.

  data: begin of atukey,
                 mandt like vbup-mandt,
                 vbeln like vbup-vbeln,
        end of   atukey.
  data: begin of vblskey,
                 mandt like vbls-mandt,
                 sammg like vbls-sammg,
                 vbeln like vbls-vbeln,
        end of   vblskey.
  data: atu_tabix like sy-tabix.
ENHANCEMENT-POINT EHP_B_ABHAENGIGE_TABELLEN_U_01 SPOTS ES_FV50XF0B_B_ABHAENGIGE_TABEL STATIC INCLUDE BOUND .

  atukey-mandt = xlikp-mandt.
  atukey-vbeln = atu_temp_vbeln.

ENHANCEMENT-POINT FV50XF0B_B_ABHAENGIGE_TABEL_01 SPOTS ES_FV50XF0B_B_ABHAENGIGE_TABEL INCLUDE BOUND.
* Tabelle XLIPS
  sort xlips by mandt vbeln posnr.
  read table xlips with key atukey binary search.

  while xlips-vbeln = atu_temp_vbeln   and
        sy-subrc = 0.
    atu_tabix = sy-tabix + 1.
    xlips-vbeln = xlikp-vbeln.
    modify xlips index sy-tabix.
    read table xlips index atu_tabix.
  endwhile.
  sort xlips by mandt vbeln posnr.

* Tabelle XVBUP
  sort xvbup by mandt vbeln posnr.
  read table xvbup with key atukey binary search.

  while xvbup-vbeln = atu_temp_vbeln   and
        sy-subrc = 0.
    atu_tabix = sy-tabix + 1.
    xvbup-vbeln = xlikp-vbeln.
    modify xvbup index sy-tabix.
    read table xvbup index atu_tabix.
  endwhile.
  sort xvbup by mandt vbeln posnr.

* Tabelle XVBUK
  sort xvbuk by mandt vbeln.
  read table xvbuk with key atukey binary search.
  if sy-subrc = 0.
    xvbuk-vbeln = xlikp-vbeln.
    modify xvbuk index sy-tabix.
  endif.
  sort xvbuk by mandt vbeln.

* Tabelle XVBPA
  sort xvbpa by mandt vbeln posnr.
  read table xvbpa with key atukey binary search.

  while xvbpa-vbeln = atu_temp_vbeln   and
        sy-subrc = 0.
    atu_tabix = sy-tabix + 1.
    xvbpa-vbeln = xlikp-vbeln.
    modify xvbpa index sy-tabix.
    read table xvbpa index atu_tabix.
  endwhile.
  sort xvbpa by mandt vbeln posnr.

* Tabelle XVBFA
  sort xvbfa by mandt vbelv posnv vbeln posnn vbtyp_n.
  loop at xvbfa where vbelv = atu_temp_vbeln  or
                      vbeln = atu_temp_vbeln.
    if xvbfa-vbelv = atu_temp_vbeln.
      xvbfa-vbelv = xlikp-vbeln.
* Redesign of notes 571904 and 576034                      "del_n_633739
    endif.
    if xvbfa-vbeln = atu_temp_vbeln.
      xvbfa-vbeln = xlikp-vbeln.
    endif.
    modify xvbfa.
  endloop.
  LOOP AT XVBFA WHERE VBTYP_N EQ CHARR AND                   "v_n_633739
                      VBELN+3(4) IS INITIAL.
    XVBFA-VBELN+3(4) = XLIKP-VBELN+6(4).
    MODIFY XVBFA.
  ENDLOOP.                                                   "^_n_633739
  SORT XVBFA BY MANDT VBELV POSNV VBELN POSNN VBTYP_N.

* TABELLE XVBBE
  sort xvbbe by mandt vbeln posnr.
  loop at xvbbe where vbeln = atu_temp_vbeln.
    if xvbbe-vbeln = atu_temp_vbeln.
      xvbbe-vbeln = xlikp-vbeln.
    endif.
    modify xvbbe index sy-tabix.
  endloop.
  sort xvbbe by mandt vbeln posnr.

* Tabelle CVBLS
  sort cvbls by mandt sammg vbeln_lif.
  vblskey-mandt = xlikp-mandt.
  vblskey-sammg = vbsk-sammg.
  vblskey-vbeln = atu_temp_vbeln.
  read table cvbls with key vblskey binary search.

  while cvbls-vbeln_lif = atu_temp_vbeln   and
        sy-subrc = 0.
    atu_tabix = sy-tabix + 1.
    cvbls-vbeln_lif = xlikp-vbeln.
    modify cvbls index sy-tabix.
    read table cvbls index atu_tabix.
  endwhile.
  sort cvbls by mandt sammg vbeln_lif.

* S073 processing:
  call function 'SD_DELIVERY_CUMULATIVE_RENAME'
    exporting
      vbeln_old = atu_temp_vbeln
      vbeln_new = xlikp-vbeln
    exceptions
      others    = 1.

* Findungsprotokoll
  if lepad_pakti-uname = sy-uname and
     not lepad_pakti-kzakt is initial.
    call function 'LE_PAD_RENAME'
      exporting
        vbeln_old = atu_temp_vbeln
        vbeln_new = xlikp-vbeln.
  endif.
* Tabelle XVBUV
  sort xvbuv by mandt vbeln .
  read table xvbuv with key atukey binary search.

  while xvbuv-vbeln = atu_temp_vbeln   and
        sy-subrc = 0.
    atu_tabix = sy-tabix + 1.
    xvbuv-vbeln = xlikp-vbeln.
    modify xvbuv index sy-tabix.
    read table xvbuv index atu_tabix.
  endwhile.
  sort xvbuv.

* Tabelle Neuterminierung
  sort neuterminierung by vbeln.
  read table neuterminierung with key atu_temp_vbeln binary search.
  if sy-subrc = 0.
    neuterminierung-vbeln = xlikp-vbeln.
    modify neuterminierung index sy-tabix.
  endif.
  sort neuterminierung by vbeln.

* Tabelle likp_dat
  sort likp_dat by vbeln_vl.
  read table likp_dat with key
                      vbeln_vl = atu_temp_vbeln
             binary search.
  while likp_dat-vbeln_vl = atu_temp_vbeln and
        sy-subrc = 0.
    atu_tabix = sy-tabix + 1.
    likp_dat-vbeln_vl = xlikp-vbeln.
    modify likp_dat index sy-tabix.
    read table likp_dat index atu_tabix.
  endwhile.
  sort likp_dat by vbeln_vl.

* pricing-type                                             "470
  SORT GT_PRICING_TYPE_SAVE BY VBELN.
  READ TABLE GT_PRICING_TYPE_SAVE WITH KEY
                      VBELN = ATU_TEMP_VBELN
                      BINARY SEARCH.
  IF SY-SUBRC = 0.
    GT_PRICING_TYPE_SAVE-VBELN = XLIKP-VBELN.
    MODIFY GT_PRICING_TYPE_SAVE INDEX SY-TABIX.
    SORT GT_PRICING_TYPE_SAVE BY VBELN.
  ENDIF.

* Tabelle VLBL
  if not tvshp-xsiactive is initial.
    call function 'XSI_TABLE_RENAME'
      exporting
        i_vbeln_temp = atu_temp_vbeln
        i_vbeln      = xlikp-vbeln
      exceptions
        others       = 1.
    if sy-subrc ne 0.
* -- ?
    endif.
  endif.
*........ renumber packing data
  data: lf_number_new like vekp-vpobjkey,
        lf_number_old like vekp-vpobjkey.
  lf_number_new = xlikp-vbeln.
  lf_number_old = atu_temp_vbeln.
  call function 'V51P_PACKING_RENAME'
    exporting
      if_object          = vpobj
      if_document_nr_new = lf_number_new
      if_document_nr_old = lf_number_old.
ENHANCEMENT-POINT EHP_B_ABHAENGIGE_TABELLEN_U_02 SPOTS ES_FV50XF0B_B_ABHAENGIGE_TABEL INCLUDE BOUND .
endform.                    "B_ABHAENGIGE_TABELLEN_UPDATEN