*&---------------------------------------------------------------------*
*&      Form  AUTOMATISCHE_SERIALNUMMERN
*&---------------------------------------------------------------------*
*       Automatische Serialnummernvergabe sofern dies im
*       Customizing des Serialnummernprofils so definiert ist
*       (--> Prüfung in SERIALPROFILE_CHECK).
*       Bei Fehler: Popup und Rücksprung in den Beleg (US_SUBRC = 1)
*----------------------------------------------------------------------*
form automatische_serialnummern.

  data: da_anzsn like vbap-anzsn,
        da_anzsn_temp like vbap-anzsn,
        da_vbeln like vbap-vbeln,
        da_serpflicht like t377-serpflicht,
        da_dataloss  like r185d-dataloss,
        da_stdpd like maepv-stdpd,
        da_error(1) type c.
  data  da_werks like vbap-werks.        "EHP603

ENHANCEMENT-POINT AUTOMATISCHE_SERIALNUMMERN_01 SPOTS ES_SAPMV45A STATIC.



  check t180-trtyp ne chara.

* In Anfragen, Angeboten und Positionsvorschlag:
* --> Keine automatische Serialnummernvergabe
  if vbak-vbtyp na vbtyp_agan and
     vbak-vbtyp na vbtyp_sort.

    loop at xvbap where updkz eq updkz_new or
                        updkz eq updkz_update.

ENHANCEMENT-POINT AUTOMATISCHE_SERIALNUMMERN_04 SPOTS ES_MV45ATOP.
*     im Reparaturfall macht das meist keinen Sinn
      if xvbap-vkgru(1) eq vkgru_rma                 or
         xvbap-vkgru    eq vkgru_rep_reparaturanfo.
        check xvbap-vkgru eq vkgru_rep_leihgeraetbes or
              xvbap-vkgru eq vkgru_rep_austauschteil.
      endif.

*     Nur bei vorhandener Auftragsmenge (--> Einteilungen erlaubt)
      if not xvbap-kwmeng is initial and
         not xvbap-serail is initial.
        da_anzsn = xvbap-kwmeng * xvbap-umvkz / xvbap-umvkn / 1000.




ENHANCEMENT-POINT AUTOMATISCHE_SERIALNUMMERN_02 SPOTS ES_SAPMV45A.

ENHANCEMENT-POINT EHP603_AUTOMATISCHE_SERIAL_01 SPOTS ES_SAPMV45A.


ENHANCEMENT-SECTION     AUTOMATISCHE_SERIALNUMMERN_03 SPOTS ES_SAPMV45A.
*       Nur, wenn noch Serialnummern fehlen
        if xvbap-anzsn < da_anzsn.

*         Automatische Serialnummernvergabe im Serialnummernprofil?
          select single serpflicht into (da_serpflicht) from t377
                        where serail = xvbap-serail  and
                              beleg  = vrgng_sdau.

          if sy-subrc = 0 and
             da_serpflicht = '04'.     " Automatische Vergabe

* Falls noch keine Belegnummer vergeben wurde, immer mit '$' arbeiten
            if xvbap-vbeln is initial.
              da_vbeln = char$.
            else.
              da_vbeln = xvbap-vbeln.
            endif.

*           Standardproduktnummer lesen und übergeben
            perform maepv_select(sapfv45p) using xvbap-matnr
                                                 xvbap-werks
                                                 xvbap-berid
                                                 xvbap-lgort
                                                 space
                                                 space
                                                 sy-subrc.

            da_stdpd = maepv-stdpd.
* wenn STDPD nicht sitzt muss das Feld aus Matnr gefuellt werden
            if da_stdpd is initial and
              not ( xvbap-cuobj is initial ).
              da_stdpd = xvbap-matnr.
            endif.

* Automatische Serialnummernvergabe

* not for configurable material where configuration is missing
            perform t459a_select(sapmv45a) using xvbap-bedae
                                                 space
                                                 sy-subrc.

            perform t459k_select(sapfv45v) using t459a-bedar
                                                 space
                                                 sy-subrc.

            perform maapv_select(sapfv45p) using xvbap-matnr
                                                 vbak-vkorg
                                                 vbak-vtweg
                                                 space
                                                 sy-subrc.

            perform tvap_select(sapmv45a) using xvbap-pstyv
                                                space
                                                sy-subrc.

            if ( t459k-konfi ne config_muss and
                 tvap-strum na config_tvap ) or
                 not xvbap-cuobj is initial or
                 maapv-attyp eq sam_typ.

              call function 'SERIALPROFILE_CHECK'
                exporting
                  operation          = vrgng_sdau
                  activity           = t180-trtyp
                  document           = da_vbeln
                  item               = xvbap-posnr
                  material           = xvbap-matnr
                  profile            = xvbap-serail
                  quantity           = da_anzsn
                  j_vorgang          = vrgng_pms2
                  debitor            = vbak-kunnr
                  kmatnr             = da_stdpd
                  cuobj              = xvbap-cuobj
                  m_charge           = xvbap-charg
                  m_werk             = da_werks             "EHP603
                  vbtyp              = vbak-vbtyp
                  sd_auart           = vbak-auart
                  sd_postyp          = xvbap-pstyv
                  automatic          = charx
                importing
                  anzsn              = da_anzsn
                  serial_commit      = da_dataloss
                  status_not_allowed = da_error.

              if not da_dataloss is initial.
                serial_dataloss = da_dataloss.
                if cl_mmpur_switch_check=>get_serial01_switch_state( ) eq charx.
                  read table gt_serial_changed
                       transporting no fields
                       with key table_line = xvbap-posnr
                       binary search.
                  if sy-subrc <> 0.
                    insert xvbap-posnr into gt_serial_changed index sy-tabix.
                  endif.
                endif.
              endif.

            else.
              da_anzsn = xvbap-anzsn.
              da_error = charx.
            endif.

*           Wenn ein Fehler aufgetreten ist --> UV-Protokoll
            if not da_error is initial.
*             Fehlergruppe bestimmen
              select single * from tvap where pstyv = xvbap-pstyv.
              if sy-subrc = 0.
*               xvbap-anzsn temporär zurücksetzen
                da_anzsn_temp = xvbap-anzsn.
                clear xvbap-anzsn.
*               Unvollständigkeit setzen falls nötig
                call function 'RV_CHECK_DOCUMENT_INPUT'
                  exporting
                    fehgr     = tvap-fehgr
                    vbxx_wa   = xvbap
                    tbnam     = 'VBAP      '
                    dialog    = space
                    fdnam     = 'ANZSN'
                  tables
                    vbuv_tab  = xvbuv
                    vbuv_last = hvbuv.
*               XVBAP-ANZSN wieder mit altem Wert füllen
                xvbap-anzsn = da_anzsn_temp.
              endif.
            endif.

            if r185d-dataloss is initial.
              r185d-dataloss = da_dataloss.
            endif.

*           Neue Anzahl Serialnummern in XVBAP stellen
            if not da_anzsn is initial and
               da_anzsn ne xvbap-anzsn.
              xvbap-anzsn = da_anzsn.
              modify xvbap.
            endif.
          endif.
        endif.
END-ENHANCEMENT-SECTION.


      endif.
    endloop.
  endif.

endform.                               " AUTOMATISCHE_SERIALNUMMERN