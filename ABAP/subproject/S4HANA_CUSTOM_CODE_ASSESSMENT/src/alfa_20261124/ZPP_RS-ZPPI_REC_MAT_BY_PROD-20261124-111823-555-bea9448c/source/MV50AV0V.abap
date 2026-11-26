***INCLUDE MV50AV0V .
************************************************************************
*                                                                      *
* POV Module zur Ablaufsteuerung - Kundenauftragsabwicklung            *
*     Module alphabetisch geordnet; hier beginnend mit "V"             *
*                                                                      *
*       MODULE LIPS-LGORT_VALUES.                                      *
*       MODULE LIPS-BWTAR_VALUES.                                      *
*       MODULE LIPS-PSTYV_VALUES.                                      *
*       MODULE LIPS-WERKS_VALUES.                                      *
*       MODULE LIPS-CHARG_VALUES.
*       MODULE LIKP-VBELN_VALUES.
************************************************************************

  DATA: help_f(10) TYPE c, help_tabix LIKE sy-tabix.
  DATA: BEGIN OF help_lips.
          INCLUDE STRUCTURE lips.
  DATA: END OF help_lips.

*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld LIPS-BWTAR                               *
*       Aufruf auch aus Step-Loop                                     *
*---------------------------------------------------------------------*
  MODULE lips-bwtar_values.

    GET CURSOR FIELD help_f LINE help_tabix.
    IF help_tabix > 0.
      READ TABLE slips INDEX help_tabix.
      IF sy-subrc = 0.
        READ TABLE xlips INDEX slips-tabix.
        help_lips = xlips.
      ELSE.                                                 "YGE
        help_lips = lips.                                   "YGE
      ENDIF.
    ELSE.
      help_lips = lips.
    ENDIF.
    if not help_lips-werks is initial.
      perform t001w_select using help_lips-werks
                                 space
                                 sy-subrc.
    endif.

    CALL FUNCTION 'RV_HELP'
         EXPORTING
              key      = help_lips-matnr
              key2     = t001w-bwkey
              key3     = help_lips-bwtex
              number   = '014'
              trtyp    = t180-trtyp
              field_in = help_lips-bwtar
         IMPORTING
              field    = lips-bwtar.

  ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE LIPS-LGORT_VALUES.                                     *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld LIPS-LGORT                               *
*---------------------------------------------------------------------*
  MODULE lips-lgort_values.

    PERFORM lips-lgort_values.

  ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE LIPS-CHARG_VALUES.                                     *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld LIPS-CHARG                               *
* note 53993
*---------------------------------------------------------------------*
  MODULE lips-charg_values.

    PERFORM lips-charg_values.

  ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE LIPS-PSTYV_VALUES.                                     *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld LIPS-PSTYV                               *
*---------------------------------------------------------------------*
  MODULE lips-pstyv_values.

    PERFORM lips-pstyp_values USING lips-pstyv.

  ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE LIPS-WERKS_VALUES.                                     *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld LIPS-WERKS                               *
*---------------------------------------------------------------------*
  MODULE lips-werks_values.

    GET CURSOR FIELD help_f LINE help_tabix.
    IF help_tabix > 0.
      READ TABLE slips INDEX help_tabix.
      IF sy-subrc = 0.
        READ TABLE xlips INDEX slips-tabix.
        help_lips = xlips.
      ENDIF.
    ELSE.
      help_lips = lips.
    ENDIF.

    CALL FUNCTION 'RV_HELP'
         EXPORTING
              key            = help_lips-matnr
              key2           = likp-vstel
              key3           = likp-vkorg
              key4           = help_lips-vtweg
              number         = 'L10'
              trtyp          = t180-trtyp
              field_in       = help_lips-werks
              description_in = t001w-name1
         IMPORTING
              field          = lips-werks
              description    = t001w-name1.

  ENDMODULE.


*---------------------------------------------------------------------*
*       MODULE LIPS-VRKME_VALUES.                                     *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld LIPS-VRKME                               *
*---------------------------------------------------------------------*
  MODULE lips-vrkme_values.

    GET CURSOR FIELD help_f LINE help_tabix.
    IF help_tabix > 0.
      READ TABLE slips INDEX help_tabix.
      IF sy-subrc = 0.
        READ TABLE xlips INDEX slips-tabix.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'RV_HELP'
         EXPORTING
              key            = xlips-matnr
              key2           = xlips-meins
              key3           = '                '
              number         = '001'
              trtyp          = t180-trtyp
              field_in       = xlips-vrkme
*           DESCRIPTION_IN = TVAPT-VTEXT
         IMPORTING
              field          = lips-vrkme.
*           DESCRIPTION    = TVAPT-VTEXT.

  ENDMODULE.




*---------------------------------------------------------------------*
*       MODULE LIKP-VBELN_VALUES                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
  MODULE likp-vbeln_values.
    CHECK xlikp-vbeln IS INITIAL.                           "45A

    CALL FUNCTION 'RV_HELP_VBELN'
         EXPORTING
              trtyp     = t185f-trtyp
              vbeln_in  = likp-vbeln
              lfart     = tvlk-lfart
              numke     = tvlk-numke
         IMPORTING
              vbeln_out = likp-vbeln.
  ENDMODULE.



*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld LIKP-ABLAD                               *
*---------------------------------------------------------------------*
  MODULE likp-ablad_values.

    CALL FUNCTION 'RV_HELP'
         EXPORTING
              key      = likp-kunnr
              number   = '018'
              trtyp    = t180-trtyp
              field_in = likp-ablad
         IMPORTING
              field    = likp-ablad.

  ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE VBELN_NO_HELP                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
  MODULE vbeln_no_help.
    MESSAGE s088.
  ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  LFART_LO_VALUES  INPUT
*&---------------------------------------------------------------------*
*       Value help for the delivery type of deliveries without
*       reference to an order
*----------------------------------------------------------------------*
  MODULE lfart_lo_values INPUT.

    PERFORM lfart_values USING space
                         CHANGING likp-lfart.
  ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  LFART_LF_VALUES  INPUT
*&---------------------------------------------------------------------*
*       Value help for the delivery type of deliveries with
*       reference to a sales order
*----------------------------------------------------------------------*
  MODULE lfart_lf_values INPUT.

    PERFORM lfart_values USING charx
                         CHANGING likp-lfart.

  ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SO_ITEM_VALUES_LOW  INPUT
*&---------------------------------------------------------------------*
*       Value help for the items of the sales order to be delivered
*       with transaction VL01N
*----------------------------------------------------------------------*
  MODULE so_item_values_low INPUT.

    PERFORM sales_order_item_values CHANGING lv50c-abpos.

  ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SO_ITEM_VALUES_HIGH  INPUT
*&---------------------------------------------------------------------*
*       Value help for the items of the sales order to be delivered
*       with transaction VL01N
*----------------------------------------------------------------------*
  MODULE so_item_values_high INPUT.

    PERFORM sales_order_item_values CHANGING lv50c-bipos.

  ENDMODULE.

*##ngr-anf
*&---------------------------------------------------------------------*
*&      Module  LIPS-MEINH_VALUES  INPUT
*&---------------------------------------------------------------------*
*       Wertehilfe für Mengeneinheiten eines Materials                 *
*----------------------------------------------------------------------*
  MODULE lips-meinh_values INPUT.

    GET CURSOR FIELD help_f LINE help_tabix.
    IF help_tabix > 0.
      READ TABLE slips INDEX help_tabix.
      IF sy-subrc = 0.
        READ TABLE xlips INDEX slips-tabix.
        help_lips = xlips.
      ENDIF.
    ELSE.
      help_lips = lips.
    ENDIF.

    CALL FUNCTION 'GET_MATERIAL_UNITS'
         EXPORTING
              i_matnr = help_lips-matnr
         IMPORTING
              e_meinh = help_lips-vrkme.

    IF NOT help_lips-vrkme IS INITIAL.
      rv50a-meins_gw = help_lips-vrkme.
    ENDIF.

  ENDMODULE.                           " LIPS-MEINH_VALUES  INPUT
*##ngr-end

*&---------------------------------------------------------------------*
*&      Module  LIKP-TRMTYP_VALUES  INPUT
*&---------------------------------------------------------------------*
*       Search help for the field means of transport
*----------------------------------------------------------------------*
  MODULE likp-trmtyp_values INPUT.

    PERFORM likp-trmtyp_values TABLES   xlips
                               CHANGING likp-trmtyp.

  ENDMODULE.                           " LIKP-TRMTYP_VALUES  INPUT
*&---------------------------------------------------------------------*
*&      Module  LIKP-AULWE_VALUES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LIKP-AULWE_VALUES INPUT.
  data: f_aulwe like likp-aulwe.
ENHANCEMENT-SECTION     MV50AV0V_01 SPOTS ES_SAPMV50A.
  perform f_aulwe_anzeigen_core changing f_aulwe.        "1275015
END-ENHANCEMENT-SECTION.
  likp-aulwe = f_aulwe.
ENDMODULE.                 " LIKP-AULWE_VALUES  INPUT