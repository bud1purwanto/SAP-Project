***INCLUDE MV50AF0F_FCODE_KPAR .
*---------------------------------------------------------------------*
*       FORM FCODE_KPAR                                               *
*---------------------------------------------------------------------*
*       Übergang zum Kopfpartnerbild via Dialogbaustein               *
*---------------------------------------------------------------------*
form fcode_kpar using h185f structure t185f
                      h185  structure t185
                      h185v structure t185v.
  data: mv50a_dataloss like r185d-dataloss.
  data: xxtrtyp like t185f-trtyp.
  data: lf_save_route like likp-route,
        lf_save_land1 like vbpa-land1,
        lf_save_lzone like vbpa-lzone.
  data: cam_memory_id type i.

  t185  = h185.
  t185f = h185f.
  t185v = h185v.

  mv50a_dataloss = r185d-dataloss.

  move likp-vbeln  to rv02p-vbeln.
  clear               rv02p-posnr.
  move 'L'         to rv02p-vbobj.
  move likp-vkorg  to rv02p-vkorg.
  move rv50a-vtweg to rv02p-vtweg.
  move rv50a-spart to rv02p-spart.
  move tvlk-lfart  to rv02p-auart.
  move tvlk-vbtyp  to rv02p-vbtyp.
  move rv50a-txt_vbeln to rv02p-vtext.
  move text(60)    to rv02p-title.
  move tvlk-pargr  to rv02p-pargr.
  move kuwev-kunnr to rv02p-kunag.
  xxtrtyp = t185f-trtyp.
  if xvbuk-wbstk = charc or
     ( likp-vlstk eq 'B' and v50agl-dlv_change eq space ) or
     ( likp-vlstk eq 'E' and likp-verursys eq space ) or
     likp-vlstk eq 'C' or
     likp-sakes eq charb.                   "GTS Safe Keeping Status
    t185f-trtyp = chara.
  endif.

  read table xvbpa with key vbeln = likp-vbeln              "40C
                            posnr = posnr_low
                            parvw = parvw_we.
  if sy-subrc eq 0.
    lf_save_land1 = xvbpa-land1.
    lf_save_lzone = xvbpa-lzone.
  endif.

  call function 'SD_CAM_ADDRESS_PUSH'
       importing
            fef_memory_id = cam_memory_id.

* IF FCODE(1) NE 'W'.
  if fcode(1) ne 'X'.
    call dialog 'RV_BELEG_PARTNER'
         exporting
              t185f
              t185
              t185v
              rv02p
              xvbpa
              yvbpa
              kuwev
              xvbuv
              xvbadr
              yvbadr
              fehler
              xvbpakey
              cam_memory_id
         importing
              t185f
              t185
              fcode
              r185d
              xvbpa
              yvbpa
              kuwev
              xvbuv
              xvbadr
              yvbadr
              rv02p.

  else.
    fehler = 'X'.
    move-corresponding xvbuv to xvbpakey.
*   SET PF-STATUS 'FS  ' OF PROGRAM 'SAPMV45B'.
*   T185V-STATUS = 'FS  '.
    call dialog 'RV_BELEG_PARTNER_DETAIL'
         exporting
              t185f
              t185
              t185v
              rv02p
              xvbpa
              yvbpa
              kuwev
              xvbuv
              xvbadr
              yvbadr
              fehler
              xvbpakey
              kuagv-kunnr
              cam_memory_id
         importing
              t185f
              t185
              fcode
              r185d
              xvbpa
              yvbpa
              kuwev
              xvbuv
              xvbadr
              yvbadr
              rv02p.
    clear fehler.
  endif.

  call function 'SD_CAM_ADDRESS_POP'.

* Check whether data relevant for route determination have been changed
  read table xvbpa with key vbeln = likp-vbeln              "40C
                            posnr = posnr_low
                            parvw = parvw_we.
  if sy-subrc eq 0.
    if xvbpa-land1 ne lf_save_land1.                        "46B
*     GGF. werden die Exportdaten neu ermittelt
      perform export_data_redetermine.                      "HP_320996
    endif.
    if ( xvbpa-land1 ne lf_save_land1 or
         xvbpa-lzone ne lf_save_lzone ).
      if tvlk-routf ne space.
        lf_save_route = likp-route.
        perform route_ermitteln(sapfv50k) using likp-route
                                          space
                                          sy-subrc.
        if sy-subrc eq 0.
          if lf_save_route ne likp-route.
            message i466 with likp-route.
          endif.
        else.
          likp-route = lf_save_route.
        endif.
      endif.
    endif.
*   Check whether ship-to party has been changed
    if likp-kunnr ne xvbpa-kunnr.      "45B/46A
      likp-kunnr = xvbpa-kunnr.
    endif.
  endif.

* Check whether sold-to party has been changed
  read table xvbpa with key vbeln = likp-vbeln  "45B/46A
                            posnr = posnr_low
                            parvw = parvw_ag.
  if sy-subrc eq 0.
    likp-kunag = xvbpa-kunnr.
  endif.

* Refresh address string of ship-to party (may be changed)
  perform build_address_dialog.                             "n_532800

  if mv50a_dataloss ne space and r185d-dataloss eq space.
    r185d-dataloss = mv50a_dataloss.
  endif.
  if rv02p-weupd ne space.
    perform warenempfaenger_bereitstellen.
    likp-ablad = xvbpa-ablad.
  endif.

* In case of a delivery w/o reference: Determine invoice calendar
  if lieferung_or eq charx.                                 "HP_383471
    perform invoice_calendar_determine tables   xvbpa
                                       using    kuwev
                                       changing likp-perfk.
  endif.
*------- Außenhandel: Partnerdaten 'retten'
  call function 'FT_SLS_PARTNER_ADDR_MEM_FILL'
       tables
            i_t_vbpavb_partner_new = xvbpa
            i_t_vbpavb_partner_old = yvbpa
            i_t_sadrvb_address_new = xvbadr
            i_t_sadrvb_address_old = yvbadr.

  t185f-trtyp = xxtrtyp.
  h185 = t185.
  h185f = t185f.
  h185v = t185v.

endform.