*---------------------------------------------------------------------*
*   INCLUDE MV45AF0X_XVBAP_DETAIL                                     *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM XVBAP_DETAIL                                             *
*---------------------------------------------------------------------*
*       Die aktuelle Position auf dem Positionsdetailscreen wird      *
*       gelesen                                                       *
*---------------------------------------------------------------------*
form xvbap_detail.

  perform xvbap_markieren(sapfv45p).
* Wenn eine Position selektiert war muss dies zurückgesetzt werden
  loop at ivbap where selkz eq selektiert.
    perform ivbap-selkz_reset(sapfv45p) using ivbap-posnr.
  endloop.

endform.                    "XVBAP_DETAIL


*&---------------------------------------------------------------------*
*&      Form  xvbap_item_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form xvbap_item_detail.

  data: lt_ivbap like ivbap[].

  case old_fcode.
    when 'ITNE'.
      clear : svbap-tabix, svbep-tabix, item_detail_tabix.
    when others.
      if dpp_active is initial.
        read table ivbap with key tabix = item_detail_tabix.
      else.
        read table ivbap_pv with key tabix = item_detail_tabix.
      endif.
      if sy-subrc = 0.
        if sy-tabix >=  ivbap_tabix_zeile_1.
        else.
          tc_selline = ivbap_tabix_zeile_1.
          if dpp_active is initial.
            read table ivbap index ivbap_tabix_zeile_1.
            item_detail_tabix = ivbap-tabix.
          else.
            read table ivbap_pv index ivbap_tabix_zeile_1.
            item_detail_tabix = ivbap_pv-tabix.
          endif.
        endif.
      else.
        read table svbap index tc_selline.
        if sy-subrc = 0.
          if sy-tabix >= ivbap_tabix_zeile_1.
            read table svbap index tc_selline.
            item_detail_tabix = svbap-tabix.
          else.
            tc_selline = 1.
            read table svbap index tc_selline.
            if sy-subrc = 0.
              item_detail_tabix = svbap-tabix.
            else.
              clear item_detail_tabix.
            endif.
          endif.
        else.
          tc_selline = 1.
          read table ivbap index tc_selline.
          if sy-subrc = 0.
            item_detail_tabix = ivbap-tabix.
          else.
            clear item_detail_tabix.
          endif.
        endif.
      endif.
      read table svbap with key tabix = item_detail_tabix.
      if sy-subrc = 0.
        tc_selline = sy-tabix.
        read table svbap index tc_selline.
        if sy-subrc = 0 and old_fcode ne 'MKAL'.
          perform xvbap_detail.
        endif.
      else.
        clear : svbap-tabix, svbep-tabix, item_detail_tabix.
      endif.
  endcase.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  if vbkd-posnr is initial.
    perform xvbkd_lesen_direkt(sapfv45k) using vbkd-posnr
                                               svbkd-tabix.
  endif.

endform.                    "xvbap_item_detail