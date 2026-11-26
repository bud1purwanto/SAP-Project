*---------------------------------------------------------------------*
*       MODULE FELDAUSWAHL OUTPUT                                     *
*---------------------------------------------------------------------*
*       Aufruf der Feldauswahl                                        *
*---------------------------------------------------------------------*
module feldauswahl output.

  data: mpool like sy-repid,
        dyngr like sy-dyngr,
        loop(3) value 'LOO',           " MODIF 2 für Step-Loop-Ident.
        da_display_status like sy-subrc.
  data: lv_first type xfeld,
        lv_sd_sfws_ui3_o2c_active type xfeld.

  data: l_sd_sales_basic_exit type ref to if_ex_badi_sd_sales_basic,
        l_badi_sd_sales_basic type ref to badi_sd_sales_basic,
        active type xfeld.
  data:
      lv_new_item      type xfeld,
      lv_table_loop    type xfeld,
      lv_modify_screen type xfeld.
"$$
"$$
"$$
  mpool = sy-repid.
  dyngr = sy-dyngr.

* Read switch information
  lv_sd_sfws_ui3_o2c_active = cl_sd_switch_check=>sd_sfws_ui3_o2c( ).

ENHANCEMENT-POINT FELDAUSWAHL_12 SPOTS ES_SAPMV45A.

ENHANCEMENT-POINT FELDAUSWAHL_10 SPOTS ES_SAPMV45A.
*-Modifikation des Dynpros zu SY-DYNGR -------------------------------*
  loop at screen.
"$$
"$$
"$$
ENHANCEMENT-POINT FELDAUSWAHL_13 SPOTS ES_SAPMV45A.
* CMDS - Collaborative Management of Delivery Schedules
* if CMDS is active for item, some fields must not be open for
* manual input anymore
    if ( t185v-panel eq fcode_lieferabruf or
         t185v-panel eq fcode_lieferabruf_einteilung or
         t185v-panel eq fcode_eingang_lab or
         t185v-panel eq fcode_freigabe_lab or
         t185v-panel eq fcode_feinabruf or
         t185v-panel eq fcode_feinabruf_einteilung or
         t185v-panel eq fcode_eingang_fab or
         t185v-panel eq fcode_freigabe_fab or
         t185v-panel eq fcode_planabruf or
         t185v-panel eq fcode_planabruf_einteilung or
         t185v-panel eq fcode_detail1_einteilung or
         t185v-panel eq 'EID2' or
         screen-name(4) eq 'VBLB' or
         screen-name(4) eq 'VBEP' ) and
         screen-input ne 0 and not
         item_cmds_active is initial and not
         screen-name eq 'RV45A-VBEP_SELKZ'.
      check call_bapi is initial.
      screen-input = 0.
      modify screen.
    endif.

* Handle Predefined Price Elements
    if not lv_sd_sfws_ui3_o2c_active is initial and
       screen-name(10) eq 'TDS_VA_PPE'.
      if sy-stepl = 0.
        lv_first = 'X'.
      else.
        clear lv_first.
      endif.
* Get instance of PPE processing
* (here in sales order only one context !)
      if not gr_ppe_process is bound.
        gr_ppe_process = cl_va_ppe_process=>get_instance(
            i_context = 'V'
            i_kappl   = 'V' ).
      endif.
      if gr_ppe_process is bound.
        call method gr_ppe_process->screen_settings
          exporting
            iv_fieldname        = screen-name
            iv_heading          = lv_first
            is_va_ppe           = tds_va_ppe
            iv_trtyp            = t180-aktyp
            iv_empty            = rv45a-zeile_leer
          importing
            ev_screen_input     = screen-input
            ev_screen_invisible = screen-invisible
            ev_screen_active    = screen-active.
        if lv_first is initial.
          modify screen.
        else.
* Switch columns
          perform tctrl_spaltenauswahl.
        endif.
      endif.
      continue.
    endif.

*-STEP-LOOP wird erst bei Abarbeitung der Loop-Zeilen modifiziert ----*
    if screen-group2 eq loop.
      check sy-stepl ne 0.
*-Spezielle Feldauswahl für leere Loop-Zeilen ------------------------*
ENHANCEMENT-POINT MV45AO0F_FELDAUSWAHL_15 SPOTS ES_SAPMV45A.
      if rv45a-zeile_leer ne space and
         screen-group3 ne space.
        perform feldauswahl_leere_zeilen.
      endif.
      if not rv45a-zeile_leer is initial.
        perform field_control_empty_line.
      endif.
      check rv45a-zeile_leer is initial.
    else.
      check sy-stepl eq 0.
    endif.
*- Betriebswirtschaftlich nicht sinnvoll zu modifiziernde Regeln -----*
    if screen-group3 ne space.
      perform feldauswahl_sonderregeln.
    endif.
    perform feldauswahl_status using screen-name
                               changing da_display_status.
ENHANCEMENT-POINT FELDAUSWAHL_01 SPOTS ES_SAPMV45A.
ENHANCEMENT-POINT FELDAUSWAHL_02 SPOTS ES_SAPMV45A.

* change of revenue recognition fields only allowed as long as
* no revenue recognized

    perform fieldmodification_rev_reg.

    if gs_ops_switch_check-ops_sfws_sc_advret1 eq charx.
      perform feldauswahl_msr changing screen.
    endif.


* Call SD Sales BAdI
    call function 'GET_HANDLE_SD_SALES_BASIC'
      importing
        er_badi = l_badi_sd_sales_basic
        active = active.

    if active = charx.
      if not l_badi_sd_sales_basic is initial.
        try.
            call badi l_badi_sd_sales_basic->maintain_screen
              exporting
                ft180    = t180
                fvbak    = vbak
                fvbap    = vbap
                fxvbup   = xvbup[]
                fxvbuk   = xvbuk[]
                fxvbap   = xvbap[]
                fxvbpa   = xvbpa[]
              changing
                f_screen = screen.
          catch cx_badi.
        endtry.
      endif.
    endif.

    call customer-function '004'
         exporting
              i_screen_name      = screen-name
              i_vbap             = vbap
              i_vbup             = xvbup
              i_screen_group4    = screen-group4
              i_t180_aktyp       = t180-aktyp
         changing
              c_screen_active    = screen-active
              c_screen_invisible = screen-invisible
              c_screen_input     = screen-input.

* end   Revenue Recognition Project


ENHANCEMENT-POINT MV45AO0F_FELDAUSWAHL_17 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT MV45AO0F_FELDAUSWAHL_16 SPOTS ES_SAPMV45A.
* Userexit
    perform userexit_field_modification.

    modify screen.

* Spaltenauswahl für Tabstrips aus Tablecontrol ableiten
    perform tctrl_spaltenauswahl.

ENHANCEMENT-POINT FELDAUSWAHL_11 SPOTS ES_SAPMV45A.
  endloop.
  clear rv45a-zeile_leer.

ENHANCEMENT-POINT FELDAUSWAHL_16 SPOTS ES_SAPMV45A .

endmodule.                    "FELDAUSWAHL OUTPUT

*---------------------------------------------------------------------*
*       MODULE FELDAUSWAHL_ESD OUTPUT                                 *
*---------------------------------------------------------------------*
*       Aufruf der Feldauswahl                                        *
*---------------------------------------------------------------------*
module feldauswahl_esd output.            "necessary because of IS2ERP
* DI 3.0 Projekt ESD HOS 181100
* Bezeichnung der Zusatzdaten soll kunden- und sprachabhängig erfolgen
  data: daten1(15),
        daten2(15),
        daten3(15),
        daten4(15),
        daten5(15).
* Bezeichnungen initialisieren

  daten1 = 'DATEN 1'.
  daten2 = 'DATEN 2'.
  daten3 = 'DATEN 3'.
  daten4 = 'DATEN 4'.
  daten5 = 'DATEN 5'.

ENHANCEMENT-POINT MV45O0F_FELDAUSWAHL_01 SPOTS ES_SAPMV45A.

endmodule.                 " FELDAUSWAHL_ESD  OUTPUT