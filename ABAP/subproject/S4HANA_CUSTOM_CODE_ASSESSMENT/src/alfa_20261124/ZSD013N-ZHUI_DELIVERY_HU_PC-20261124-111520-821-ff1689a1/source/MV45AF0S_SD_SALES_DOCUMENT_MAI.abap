*eject
*---------------------------------------------------------------------*
*       FORM SD_SALES_DOCUMENT_MAINTAIN                               *
*---------------------------------------------------------------------*
*       Aufruf eines CALL DIALOGS zur Auftragspflege                  *
*---------------------------------------------------------------------*
form sd_sales_document_maintain using us_display_only.

* Nur Anzeigen, wenn Flag entsprechend sitzt
  if not us_display_only is initial.
    t180-trtyp = chara.
  endif.

  status_buff_init = space.

  perform call_dialog_export.

* Da die internen Preisfindungstabellen auch nicht in den anderen
* Rollbereich übernommen werden, TKOMK initialisieren
  refresh tkomk.

  call dialog 'SD_SALES_DOCUMENT_MAINTAIN'
       exporting
            call_activity
            call_dialog          from charx
            call_dialog_folge
            bedarf_trennen
            ale_flag
            berechtigung_block
            berechtigung_unblock
            berechtigung_ccard
            vbak
            xvbak_updkz
            *vbak
            yvbak
            yvbak_updkz
            svbak-tabix
            status_buff_init
            kuagv
            vtcomag
            businessobjekt
            kuwev
            vtcomwe
            kurgv
            vtcomrg
            tvta
            tvko
            tvko_sadr
            t001
            tvkgr
            tvgrt
            tvbur
            tvkbt
            tvak
            tvakt
            t185f
            t185
            t180
            t185v
            t683v
            rv45a
            r185d
            xkomv
            konv_gelesen
            konv_geaendert
            xvbap
            ivbap
            hvbap
            uvbap
            gvbap
            xvbap_high_posnr
            xvbbe
            avbbd
            xvbbs
            xvbep
            ivbep
            ivbep1
            xvbkd
            xvbfa
            xvbapf
            xvbpa
            xvbup
            xvbuk
            xthead
            yvbap
            yvbbe
            yvbbs
            yvbep
            yvbfa
            yvbkd
            yvbpa
            yvbup
            yvbuk
            xvbuv
            yvbuv
            xvbadr
            yvbadr
            xvbsn
            yvbsn
            xveda
            yveda
            xfpla
            yfpla
            xfplt
            yfplt
            checked_vdatu
            vbap_kzvbr_e
            dia_vbap_vgbel
            dia_vbap_vgpos
            dia_vbap_vgtyp
*           tkomk                  "PU Hinweis 96480
            cam_memory_id
       importing
            old_fcode
            bedarf_trennen
            ale_flag
            vbak
            xvbak_updkz
            *vbak
            yvbak
            yvbak_updkz
            svbak-tabix
            kuagv
            vtcomag
            kuwev
            vtcomwe
            kurgv
            vtcomrg
            tvak
            t185f
            t185
            t180
            t185v
            rv45a
            r185d
            xkomv
            konv_gelesen
            konv_geaendert
            xvbap
            ivbap
            hvbap
            uvbap
            gvbap
            xvbap_high_posnr
            xvbbe
            avbbd
            xvbbs
            xvbep
            ivbep
            ivbep1
            xvbkd
            xvbfa
            xvbapf
            xvbpa
            xvbup
            xvbuk
            xthead
            yvbap
            yvbbe
            yvbbs
            yvbep
            yvbfa
            yvbkd
            yvbpa
            yvbup
            yvbuk
            xvbuv
            yvbuv
            xvbadr
            yvbadr
            xvbsn
            yvbsn
            xveda
            yveda
            xfpla
            yfpla
            xfplt
            yfplt
            checked_vdatu
            vbap_kzvbr_e.              "PU Hinweis 96480
*           tkomk.          "PU Hinweis 96480

  perform call_dialog_import.

  if call_dialog_folge is initial.
    call_dialog_folge = charx.
    if old_fcode = fcode_ende or
       old_fcode = fcode_abbrechen1.
      no_rv_delivery_init = charx.
      perform beleg_initialisieren.
    endif.
  endif.


endform.                    "sd_sales_document_maintain