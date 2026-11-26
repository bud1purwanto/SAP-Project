*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_FCODE_STATIC                                  *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CUA_EXCLUDE_STATIC
*&---------------------------------------------------------------------*
*  This form routine controls the activation of FCODES which is
*  - dependent on the delivery document
*  - not changeable and therefore valid for the whole processing
*
* Example: FCODES that are dependend of LIKP-VERURSYS are controlled
*          here, not in CUA_EXCLUDE_DYNAMIC
*          FCODES dependend on SY_CALLD
*----------------------------------------------------------------------*
form cua_exclude_static.

  data: lf_subrc like sy-subrc.

* In CALL mode some functions are not useful since they interrupt
* the call chain (LEAVE TO TRANSACTION)
enhancement-section     cua_exclude_static_01 spots es_sapmv50a.
  if ( t180-bldgr eq gc_new_dialog_outb
       or t180-bldgr eq gc_new_dialog_inb ) and
     sy-calld   ne space.
    perform cua_fcode_allow using 'VL02_T' no.
    perform cua_fcode_allow using 'VL03_T' no.
    perform cua_fcode_allow using 'VL04_T' no.
    perform cua_fcode_allow using 'VL06_T' no.
    perform cua_fcode_allow using 'FT41_T' no.
    perform cua_fcode_allow using 'VL70_T' no.
    perform cua_fcode_allow using 'VL71_T' no.
    perform cua_fcode_allow using 'VL75_T' no.
    perform cua_fcode_allow using 'CRMA_T' no.
    perform cua_fcode_allow using 'CROA_T' no.
  endif.
end-enhancement-section.

* If not in transaction VLPOD suppress TAXI screen for POD
*.If not in SPE returns scenario suppress TAXI screen for RMA       "SPE_RET
  if t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.
    case t180-tcode.
      when 'VLPOD'.
        perform cua_taxitab_allow using 'SRMA_T' no.                "SPE_RET
      when 'VL02N' or 'VL03N' or 'VL01N' or 'VL01NO'.
        perform cua_taxitab_allow using 'UPOD_T' no.
ENHANCEMENT-POINT CUA_EXCLUDE_STATIC_02 SPOTS ES_SAPMV50A.
*       Additional tab strip only in case of SPE returns scenario
        loop at xlips transporting no fields
                      where spe_auth_number ne space.
          exit.
        endloop.
        if sy-subrc ne 0.
          perform cua_taxitab_allow using 'SRMA_T' no.
        endif.
      when 'VL31N' or 'VL32N' or 'VL33N'.
        perform cua_taxitab_allow using 'UPOD_T' no.
ENHANCEMENT-POINT CUA_EXCLUDE_STATIC_03 SPOTS ES_SAPMV50A.
*       Additional tab strip only in case of SPE returns scenario
        loop at xlips transporting no fields
                      where spe_auth_number ne space.
          exit.
        endloop.
        if sy-subrc ne 0.
          perform cua_taxitab_allow using 'SRMA_T' no.
        endif.
    endcase.
*   Suppress tab for template material maintaining if not allowed
    if v50agl-tppr_active eq space.
      perform cua_taxitab_allow using 'DGMD_T' no.
    endif.
  endif.

* TM ERP Integration II - UI Extension
  IF gr_tm_delivery IS NOT BOUND.
     perform cua_taxitab_allow using 'TMUB_T' no.
  ENDIF.

* Check whether user has the authority to change deliveries
  if t180-trtyp eq chara.
    authority-check object 'V_LIKP_VST'
         id 'VSTEL' field likp-vstel
         id 'ACTVT' field '02'.
    if sy-subrc ne 0.
      perform cua_fcode_allow using 'ANZA_T' no.
    endif.
    if likp-vbtyp ca vbtyp_lief.                            "v_n_579860
      perform check_tcode_authorization using 'VL02N'
                                        changing lf_subrc.
    else.
      perform check_tcode_authorization using 'VL32N'
                                        changing lf_subrc.
    endif.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'ANZA_T' no.
    endif.                                                  "^_n_579860
  endif.

* If the delivery is not changeable suppress toggle button
* - Delivery is replicated to WMS and no change management is active
* - Delivery was distributed and splitted in the decentral WMS
* - Delivery is unchecked
  if t180-trtyp eq chara and                                "AIP
     ( ( likp-vlstk eq 'B' and v50agl-dlv_change eq space ) or
       ( likp-vlstk eq 'E' and likp-verursys eq space ) or
       vbuk-bestk eq chara ).
    perform cua_fcode_allow using 'ANZA_T' no.
  endif.

* New dialog: deactivate goods issue if already done
*             deactivate change<-> display in VLPODA if
*             goods issue not yet done
  if    t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.
    if vbuk-wbstk = 'C'.
      perform cua_fcode_allow using 'WABU_T' no.
    endif.
    if vbuk-wbstk ne 'C' and t180-tcode eq 'VLPODA'.
      perform cua_fcode_allow using 'ANZA_T' no.
    endif.

  endif.

* Disable buttons for creating dates in inbound deliveries
  if t180-tcode(3) eq 'VL3'.
    perform cua_fcode_allow using 'TSEG_INSR' no.
    perform cua_fcode_allow using 'TSEG_DELE' no.
  endif.

enhancement-point sapmv50a_110 spots es_sapmv50a static.

enhancement-point sapmv50a_111 spots es_sapmv50a.
* Suppress fcodes with missing user authorization
  perform cua_fcode_tcode.                                  "50A

* correction deliveries: suppress display <=> change button
  if not likp-klief is initial.
    perform cua_fcode_allow using 'ANZA_T' no.
  endif.

* Disable not supported screens if delivery is displayed from archive
  if v50agl-display_from_archive ne space.                  "v_n_574894
    perform cua_fcode_allow using 'ANZA_T' no.
    perform cua_fcode_allow using 'VXSI_T' no.
    perform cua_fcode_allow using 'IFLU_T' no.
    perform cua_fcode_allow using 'FT41_T' no.
    perform cua_fcode_allow using 'IBST_T' no.
    perform cua_fcode_allow using 'IEHS_T' no.
    perform cua_fcode_allow using 'VL70_T' no.
    perform cua_fcode_allow using 'VL71_T' no.
    perform cua_fcode_allow using 'VL75_T' no.
    perform cua_fcode_allow using 'KKOM_T' no.
    perform cua_fcode_allow using 'KPRT_T' no.
    perform cua_fcode_allow using 'PPRT_T' no.
    perform cua_fcode_allow using 'PGGP_T' no.
    perform cua_fcode_allow using 'EXKO_T' no.
    perform cua_fcode_allow using 'IFDH_T' no.
    perform cua_fcode_allow using 'IFDA_T' no.
    perform cua_fcode_allow using 'HGAT_T' no.
    perform cua_taxitab_allow using 'VXSI_T' no.
  endif.                                                    "^_n_574894

ENHANCEMENT-POINT MV50AF0C_CUA_FCODE_STATIC_01 SPOTS ES_SAPMV50A.

endform.                               " CUA_EXCLUDE_STATIC