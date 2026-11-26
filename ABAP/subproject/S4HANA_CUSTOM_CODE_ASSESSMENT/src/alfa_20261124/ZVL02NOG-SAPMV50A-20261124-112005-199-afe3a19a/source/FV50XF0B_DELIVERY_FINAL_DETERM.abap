***INCLUDE FV50XF0B_DELIVERY_FINAL_DETERM .
*---------------------------------------------------------------------*
*       FORM DELIVERY_FINAL_DETERMINATIONS                            *
*---------------------------------------------------------------------*
*  -->  IF_VBELN                                                      *
*  -->  IF_XLIKP_TABIX                                                *
*---------------------------------------------------------------------*
form delivery_final_determinations using if_vbeln if_xlikp_tabix.

  data: lf_subrc like sy-subrc.
  data: lf_pr_type type komv-ksteu.                          "470

* determine new picking date in delivery header
* -> already done before inBELEG_SICHERN_VORBEREITEN (4.6A)

* correct kcmeng if necessary
  if xlikp_updkz ne updkz_delete.
    perform batchsplit_kcmeng_correction using if_xlikp_tabix.
  endif.

* determine warehouse number in delivery header
* performance: not during pick confirmation
  if v50agl-no_whouse_det is initial.
    if xlikp_updkz ne updkz_delete.
      move-corresponding xlikp to likp.
      perform delivery_set_lgnum_and_vlstk using    charx
                                           changing likp
                                                    lf_subrc.
      move-corresponding likp to xlikp.
      modify xlikp.
    endif.
  endif.

* determine gate and staging area in delivery header
* warehouse number is possibly known at this time yet
* performance: not during pick confirmation
  if v50agl-no_gate_det is initial.
    if not xlikp-lgnum is initial.
      if xlikp-lgtor is initial or xlikp-lgbzo is initial.
        move-corresponding xlikp to likp.
        call function 'SD_GATE_DETERMINE'
          exporting
            ilikp  = likp
          importing
            elgtor = likp-lgtor
            elgbzo = likp-lgbzo
          exceptions
            others = 0.
        move-corresponding likp to xlikp.
        modify xlikp.
      endif.
    endif.
  endif.

* create request for picking list
* performance: not during pick confirmation
  if v50agl-no_sd_pick_list is initial.
    perform beleg_kommiliste_anstossen.
  endif.

* Create or renumber inpection lot. If goods movement posting is active
* the inspection lot has been created in routine WARENAUSGANG_BUCHEN. If
* this has been done in VL01(N) the inspection lot has to updated with
* the new delivery number because this number is not known at lot
* creation                                                  "HP_368559
  if v50agl-warenausgang eq charx and
     t180-trtyp eq charh.
    perform inspection_lot_renumber using if_vbeln.
  elseif v50agl-warenausgang eq space and
         xvbuk-wbstk ne charc         and
         xlikp-updkz ne updkz_delete.
    perform create_inspection_lot using if_vbeln.
  endif.

* Pricing complete when group-conditions with scales
* or header-conditions
  read table gt_pricing_type_save with key                       "470
                                  vbeln = xlikp-vbeln
                                  binary search.
  if sy-subrc eq 0
     and not gt_pricing_type_save-pricing_type is initial.
    lf_pr_type = gt_pricing_type_save-pricing_type .
  else.
    lf_pr_type = chare.
    loop at tkomv transporting no fields
                  where knumv eq xlikp-knump and
                        ( ( kgrpe ne space and
                            ( krech ca 'BT' or
                              kzbzg ne space         ) ) or
                          ( kposn is initial and
                            kherk eq charc             ) ).
      exit.
    endloop.
  endif.
  if sy-subrc eq 0 or v50agl-extend_delivery = 'X'.         "HP_767191
    move-corresponding xlikp to likp.
    move-corresponding xlikp to *likp.
*   pricing need correct kuwev
    perform tvko_select(sapmv50a) using likp-vkorg          "v_n_1658254
                                        space
                                        lf_subrc.
    perform warenempfaenger_bereitstellen(sapmv50a).        "^_n_1658254
*   pricing complete needs sorted tkomv
    sort tkomv by knumv kposn stunr zaehk .
    perform preisfindung_gesamt(sapmv50a) using lf_pr_type.
    move-corresponding likp to xlikp.
    modify xlikp.
  endif.

endform.                    "delivery_final_determinations