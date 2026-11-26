
*----------------------------------------------------------------------*
*   INCLUDE FV50XFEN                                                   *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KOPIEREN_ENDRUNDE                                        *
*---------------------------------------------------------------------*
*       Endrunde, die nach jedem Kopiervorgang aufgerufen wird.       *
*       Hier können alle Formroutinen aufgerufen werden, die nach     *
*       jedem Kopiervorgang (VL01, VL04, VL02) aufgerufen werden      *
*       müssen.                                                       *
*       Bitte hier nur PERFORM-Aufrufe eintragen !                    *
*       Bitte hier allgemeingültige für alle Vorgängerobjekte         *
*       gültige Formroutinen eintragen.
*---------------------------------------------------------------------*
form kopieren_endrunde.

  data:
    lf_flag_kodat_changed      type c
  , lf_xlikp_tabix             type sytabix
  , lf_tabix                   type sytabix
  , lf_vbeln                   type vbeln
  , lt_finchdel                type vlikp_t_finchdel          "50A
  , i_dnact                    like rdgdnact.

  field-symbols:
    <ls_likp>                  type likpvb
  , <ls_lips>                  type lipsvb
  .


* guarantee that content of likp is copied to xlikp
  perform xlikp_aus_likp_fuellen.

  if v50agl-sammelgang = charx.

*   Entfernen von leeren Köpfen
    perform steuerung_leere_koepfe_loesch(saplv50s).

    perform tor_bereitstellzone_finden(saplv50s).

ENHANCEMENT-POINT EHP_KOPIEREN_ENDRUNDE_01 SPOTS ES_FV50XFEN INCLUDE BOUND .
    if v50agl-create_decentral  ne space
    or v50agl-create_uclief     eq charx                              "AIP
    or v50agl-ucdel_to_del_comb eq charx                 "SPE order comb.
    or v50agl-save_texts        eq charx.
      perform gn_match_texts_wms(saplv50s).
    endif.

  endif.

  lf_tabix = 0.
  sort xlikp by vbeln.

* one call for this copying of reference data
  perform delivery_final_copy using xlikp[]
                                    xlips[].

  loop   at xlikp assigning     <ls_likp>
                  where          updkz <> updkz_delete
                    and          updkz <> updkz_mark_del.          "SPE

    loop at xlips assigning     <ls_lips>
                  from           lf_tabix
                  where      not vgtyp is initial.

      if     <ls_lips>-vbeln > <ls_likp>-vbeln.
        exit.
      elseif <ls_lips>-vbeln < <ls_likp>-vbeln.
        lf_tabix = lf_tabix + 1.
        continue.
      endif.
      lf_tabix = lf_tabix + 1.

      if <ls_lips>-updkz = updkz_new.

        if lf_vbeln <> <ls_likp>-vbeln.
          lf_vbeln =  <ls_likp>-vbeln.
*          one call for each delivery, that conatines a new item.
          perform delivery_final_copy_document using <ls_likp>
                                                      xlips[].
        endif.

*       copy dependant data for this new delivery item
        perform delivery_final_copy_item using <ls_likp>
                                               <ls_lips>.

ENHANCEMENT-POINT EHP605_KOPIEREN_ENDRUNDE_01 SPOTS ES_FV50XFEN INCLUDE BOUND .

      endif.

    endloop.
*   Check if templatematerial processing should be processed
    if v50agl-tppr_active is initial.
      move-corresponding <ls_likp> to i_dnact.
      call function 'EHS003_CHECK_TPPR_ACTIVE'
        exporting
          i_dnact     = i_dnact
          i_vbtyp     = <ls_likp>-vbtyp
        exceptions
          tppr_active = 1
          others      = 2.
      if sy-subrc eq 1.
*       EH&S functionality is active
        v50agl-tppr_active = charx.
      endif.
    endif.

  endloop.


  v50agl-kopieren = space.
  v50agl-deliver_sales_order = space.                       "n_546203
  gs_mhpar-refmd = gc_refmd-change_create_delete.

  if v50agl-sammelgang eq space.
*   A final scheduling is performed if the delivery has been created in
*   dialog or if the delivery is expanded by new sales order items
*   -> The user can work with the current shipping dates.
    read table xlikp with key vbeln = likp-vbeln.
    lf_xlikp_tabix = sy-tabix.
    likp = xlikp.
    perform likp_kodat_ermitteln(sapfv50k) using likp
                                                 likp
                                                 xlikp-vstrm
                                                 xlikp-trtrm
                                                 lf_flag_kodat_changed.
    move-corresponding likp to xlikp.
    modify xlikp index lf_xlikp_tabix.
*   The credit status must be determined before returning to dialog in
*   order to prevent subsequent functions that are actually not allowed
*   due to the credit status
    perform kreditcheck(sapfv50k) using    charx space      "50A
                                  changing kvbuk
                                           lt_finchdel.

*   The incompletion check should be performed at the end of the copy
*   process, to avoid that the check for subsequent functions is
*   perfomed without the current incompletion data
    perform uc_internal_update(sapfv50u).                     "n_841109

  endif.

* The incompletion check should also be performed during the creation
* of inbound deliveries
  if xlikp-vbeln eq '$       1'.                            "v_n_855542
    if xlikp-vbtyp ca vbtyp_mmli.
      move-corresponding xlikp to likp.
      read table xlips with key vbeln = xlikp-vbeln.
      move-corresponding xlips to lips.
      perform uc_internal_update(sapfv50u).
      delete xvbuv where vbeln ne xlikp-vbeln.
    endif.
  endif.                                                    "^_n_855542

endform.                    "kopieren_endrunde


*---------------------------------------------------------------------*
*       FORM KOPIEREN_BEENDEN                                         *
*---------------------------------------------------------------------*
*       Kopiermodus wird beendet ohne erfolgreiches Kopieren          *
*---------------------------------------------------------------------*
form kopieren_beenden.

  v50agl-kopieren = space.
  v50agl-deliver_sales_order = space.                       "n_546203
  gs_mhpar-refmd = gc_refmd-change_create_delete.

endform.                    "kopieren_beenden
*---------------------------------------------------------------------*
*       FORM KOPIEREN_BEGINN                                          *
*---------------------------------------------------------------------*
*       Kooiermodus wird begonnen                                     *
*---------------------------------------------------------------------*
form kopieren_beginn.

  v50agl-kopieren = charx.
  gs_mhpar-refmd = gc_refmd-reference.

endform.                    "kopieren_beginn


*&---------------------------------------------------------------------*
*&      Form  delivery_final_copy
*&---------------------------------------------------------------------*
*
*       for each deliveryprocessing, that creates items with reference
*       to a predecessing document, this routine is called once
*       watch out ! it_lips containes also items to be deleted !
*
*----------------------------------------------------------------------*
form delivery_final_copy using it_likp type shp_vl10_likp_t
                               it_lips type shp_vl10_lips_t.





endform.                    " delivery_final_copy


*&---------------------------------------------------------------------*
*&      Form  delivery_final_copy_document
*&---------------------------------------------------------------------*
*
*       for each delivery, for which an item is created eith reference
*       to a predecesing document, this call is done once to be able to
*       copy header data without copying item data
*       watch out ! it_lips containes also items to be deleted !
*----------------------------------------------------------------------*
form delivery_final_copy_document using is_likp type likpvb
                                        it_lips type shp_vl10_lips_t.





endform.                    " delivery_final_copy_document


*&---------------------------------------------------------------------*
*&      Form  delivery_final_copy_item
*&---------------------------------------------------------------------*
*
*       for each created delivery item this is the possibility to copy
*       dependant data not held in delivery data
*
*----------------------------------------------------------------------*
form delivery_final_copy_item using is_likp type likpvb
                                    is_lips type lipsvb.



* Dangerous goods
  if not is_lips-profl is initial.
    perform gg_lipsdg1_copy using is_likp is_lips.
    perform gg_lipsdg2_copy using is_likp is_lips.
  endif.

* next application to be added
* ...

endform.                    " delivery_final_copy_item