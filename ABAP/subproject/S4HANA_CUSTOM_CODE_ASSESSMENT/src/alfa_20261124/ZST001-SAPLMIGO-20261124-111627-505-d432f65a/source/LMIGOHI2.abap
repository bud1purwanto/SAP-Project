*----------------------------------------------------------------------*
*   INCLUDE LMIGOHI2                                                   *
*----------------------------------------------------------------------*
*   Header tabstrip import implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_header_import IMPLEMENTATION.

*----------------------------------------------------------------------*
* METHOD CONSTRUCTOR
*----------------------------------------------------------------------*
  METHOD constructor.
    DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    APPEND 'MIGO_OK_IMPORT_HEAD' TO lt_okcodes.
    lif_migo_frame~class_id = 'MIGO_HEADER_IMPORT'.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD PBO
*----------------------------------------------------------------------*
  METHOD pbo.
    DATA: l_complete TYPE abap_bool.
* Avoid unnecessary processing after each enter
    CHECK NOT gohead-exnum IS INITIAL.
    CALL METHOD super->pbo.
* Check if import data is complete and set red or green light
    CALL FUNCTION 'EXPIMP_DATA_COMPLETENESS_CHECK'
         EXPORTING
              i_exnum              = gohead-exnum
*             I_EXPOS              = '000000'
              i_ft_basis           = '1WE'
         IMPORTING
              e_header_complete    = l_complete
*             E_LINE_ITEM_COMPLETE =
         EXCEPTIONS
*             NO_EXPORT_DATA       = 1
              OTHERS               = 2
              .
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
*      rl50e-stat_k = icon_red_light.
    ENDIF.
    CASE l_complete.
      WHEN abap_true.
        rl50e-stat_k = icon_green_light.
      WHEN abap_false.
        rl50e-stat_k = icon_red_light.
    ENDCASE.

  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD PAI
*----------------------------------------------------------------------*
  METHOD pai.
    CALL METHOD super->pai.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD PBO_POPUP
*----------------------------------------------------------------------*
  METHOD pbo_popup.
    DATA: l_trtyp           TYPE t180-trtyp,
          l_partner_number  TYPE kna1-kunnr,
          l_partner_name    TYPE kna1-name1,
          l_partner_country TYPE kna1-land1.

    CHECK sy-ucomm = 'MIGO_OK_IMPORT_HEAD'.
    SET PF-STATUS 'IMPORT_HEADER'.
    SET TITLEBAR  'IMPORT_HEADER'.
    IF lcl_migo_globals=>kernel->s_action-create = abap_true AND
      NOT lcl_migo_globals=>kernel->s_action-cancel = abap_true.
      l_trtyp = h.
    ELSE.
      l_trtyp = a.
    ENDIF.

    IF gohead-reswk IS INITIAL.
      IF NOT gohead-llief IS INITIAL.
        l_partner_number  = gohead-llief.
        l_partner_name    = gohead-supvendname.
      ELSE.
        l_partner_number  = gohead-lifnr.
        l_partner_name    = gohead-vendorname.
      ENDIF.
    ELSE.
      l_partner_number    = gohead-reswk.
      l_partner_name      = gohead-vendorname.
      l_partner_country   = gohead-land1.
    ENDIF.


    CALL FUNCTION 'FTRADE_HEADER_DATA_MNT_TS_PBO'
         EXPORTING
              i_ftrade_number           = gohead-exnum
              i_home_country            = gohead-land1
              i_partner_country         = l_partner_country
              i_partner_name            = l_partner_name
              i_partner_number          = l_partner_number
*             I_EXPORTER_NUMBER         = ' '
*             I_EXPORTER_PLANT          = ' '
              i_ft_basis                = '1WE'
*             I_STAT_COMPLETE_MANDATORY = ' '
              i_transaction_type        = l_trtyp
*             I_FUNCTION_CODE           = sy-ucomm
*             I_FUNCTION_CODE_DEFAULT   = 'OK_GO'
*        TABLES
*             I_T_XVBRP                 =
              .
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD PAI_EXIT
*----------------------------------------------------------------------*
  METHOD pai_exit.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD PAI_POPUP
*----------------------------------------------------------------------*
  METHOD pai_popup.
    IF sy-ucomm = 'OK_WEIT'.
      CALL FUNCTION 'FTRADE_HEADER_DATA_MNT_TS_PAI'
           EXPORTING
                i_ftrade_number        = gohead-exnum
                i_function_code        = sy-ucomm
           IMPORTING
*               E_FTRADE_DATA_COMPLETE =
                e_ftrade_number_new    = gohead-exnum
*               E_DATALOSS             =
                e_function_code        = sy-ucomm
*               E_SYSTEM_UCOMM         =
                .
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ENDMETHOD.

*----------------------------------------------------------------------*
* Interface
*----------------------------------------------------------------------*
  METHOD lif_migo_frame~okcode_handler.
    CASE i_okcode.
      WHEN 'MIGO_OK_IMPORT_HEAD'.
        CALL SCREEN 4000 STARTING AT 5 1
                         ENDING   AT 90 18.
    ENDCASE.
  ENDMETHOD.

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.


ENDCLASS.