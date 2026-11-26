*---------------------------------------------------------------------*
*       FORM KUAGV_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftraggeber von der Datenbank lesen                          *
*
*       Neu zu 4.0: Parameter us_we = Warenempfänger
*       Zweck : Hat der Benutzer schon einen Warenempfänger eingegeben,
*               dann wird das Auswahl-Popup für Warenempfänger (bei
*               mehreren WEs) nicht mehr hochgefahren, sondern der
*               eingegebene WE wird übernommen (falls er in der KNVP
*               des AG existiert; falls nicht, wird er ignoriert und das
*               Popup wie gehabt hochgefahren.
*---------------------------------------------------------------------*
form kuagv_select using us_ag
                        us_we.
  data: da_busobj type swo_objtyp,
        da_objkey type swo_typeid.

  data: ls_cpd_address type sadrvb,
        lf_called_by_lord type xfeld.

  if vtcomag-kunnr ne us_ag or
     vtcomag-vkorg ne vbak-vkorg or
     vtcomag-vtweg ne vbak-vtweg or
     vtcomag-spart ne vbak-spart or
     kuagv-name1   eq ' '.
    clear vtcomag.
    vtcomag-kunnr = us_ag.
    vtcomag-vbtyp = vbak-vbtyp.
    vtcomag-vbeln = vbak-vbeln.
    vtcomag-vkorg = vbak-vkorg.
    vtcomag-vtweg = vbak-vtweg.
    vtcomag-spart = vbak-spart.
    vtcomag-pargr = tvak-pargr.
    vtcomag-auart = tvak-auart.
    vtcomag-hityp_pr = tvak-hityp_pr.
    vtcomag-vbobj = 'A'.

enhancement-point kuagv_select_10 spots es_sapmv45a.
    da_busobj = businessobjekt.
    da_objkey = vbak-vbeln.

    if call_activity eq gc_activity_lord.
*     lf_no_dialog = charx.
      lf_called_by_lord = charx.
      ls_cpd_address-name1 = gs_cpd_address-name.
      ls_cpd_address-stras = gs_cpd_address-street.
      ls_cpd_address-hausn = gs_cpd_address-hnum.
      ls_cpd_address-pstlz = gs_cpd_address-pcode.
      ls_cpd_address-ort01 = gs_cpd_address-city.
      ls_cpd_address-land1 = gs_cpd_address-country.
      ls_cpd_address-spras = gs_cpd_address-language.
    endif.

*   Auftraggeberview
    call function 'VIEW_KUAGV'
      exporting
        adresse_ag         = ls_cpd_address
        comwa              = vtcomag
        we_input           = us_we
        fif_objecttype     = da_busobj
        fif_objectkey      = da_objkey
        fif_called_by_lord = lf_called_by_lord
      importing
        agwa               = kuagv
        es_address         = ls_cpd_address
      tables
        xvbpa              = xvbpa
        vbuv_tab           = xvbuv
        xsadr              = xvbadr
      exceptions
        others             = 1.
    if sy-subrc <> 0.
      if call_activity eq gc_activity_lord.
        if sy-msgty eq chare.
          clear save-we.
          gs_cpd_address-name = ls_cpd_address-name1.
          gs_cpd_address-street = ls_cpd_address-stras.
          gs_cpd_address-pcode = ls_cpd_address-pstlz.
          gs_cpd_address-city = ls_cpd_address-ort01.
          gs_cpd_address-country = ls_cpd_address-land1.
          gs_cpd_address-language = ls_cpd_address-spras.
        endif.
      endif.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    if call_activity eq gc_activity_lord.
      if not kuagv-kunnr is initial.
        clear gs_cpd_address.
      endif.
    endif.
    perform kuagv-txtpa_ermitteln.
enhancement-point kuagv_select_11 spots es_sapmv45a.
  endif.
endform.                    "KUAGV_SELECT