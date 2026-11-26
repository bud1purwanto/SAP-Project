*----------------------------------------------------------------------*
*   INCLUDE LMIGODE1                                                   *
*   Default values for the kernel operations
*----------------------------------------------------------------------*

CLASS lcl_migo_defaults DEFINITION
                        INHERITING FROM lcl_migo_screenobject.

  PUBLIC SECTION.
    TYPES : lty_t_fields TYPE TABLE OF migo_fieldname.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION,
      pbo_loop,
      pai_loop,
      exit_command,
      pbo_transfer,
      pbo_transfer_loop,
      pai_transfer,
      pai_transfer_loop,
      pai_new_line_check,
      transfer_defaults_popup
        IMPORTING i_bwart TYPE bwart OPTIONAL
                  i_sobkz TYPE sobkz OPTIONAL,
      update_flag_set,
      copy_rule_get
        IMPORTING i_bwart TYPE bwart
                  i_sobkz TYPE sobkz
        EXPORTING et_copy_fields TYPE lty_t_fields.

ENHANCEMENT-POINT LMIGODE1_01 SPOTS ES_SAPLMIGO STATIC.

  PRIVATE SECTION.
    TYPES: BEGIN OF pty_esdus_transfer,
             matnr TYPE migo_xmatnr,
             werks TYPE migo_xplant,
             lgort TYPE migo_xsloc,
             charg TYPE migo_xbatch,
             bwtar TYPE migo_xbwtar,
             ummat TYPE migo_xmatnr,
             umwrk TYPE migo_xplant,
             umlgo TYPE migo_xsloc,
             umcha TYPE migo_xbatch,
             umbar TYPE migo_xbwtar,
             special_stock_l TYPE migo_sobkz_l,
             special_stock_r TYPE migo_sobkz_r,
           END OF pty_esdus_transfer.
    DATA:
      oref_settings       TYPE REF TO cl_mmim_userdefaults,
      oref_settings_trans TYPE REF TO cl_mmim_userdefaults,
      pt_tv               TYPE STANDARD TABLE OF godefault_tv,
      pt_tv_old TYPE STANDARD TABLE OF godefault_tv,
      pt_tv_trans         TYPE SORTED TABLE OF godefault_tra_tv
                          WITH NON-UNIQUE KEY bwart sobkz,
      pt_tv_trans_work    TYPE STANDARD TABLE OF godefault_tra_tv,
      pt_tv_trans_deleted TYPE STANDARD TABLE OF godefault_tra_tv,
      pt_dfies            TYPE TABLE OF dfies.

    METHODS:
      data_send_to_kernel,
      defaults_popup,
      godefault_fill,
      defaults_update,
      defaults_update_wever                                 "315434
        IMPORTING i_wever TYPE wever,
      defaults_update_bwart_sobkz
        IMPORTING i_mvt TYPE bwart
                  i_sobkz TYPE sobkz,
      screen_modify_local,
      preset,
      copy_rule_translate
        IMPORTING i_rule TYPE godefault_tra_tv
        EXPORTING et_copy_fields TYPE lty_t_fields,
      transfer_tv_fill,
      trans_lines_create,
      trans_lines_delete,
      screen_mod_transfer.
ENDCLASS.                    "lcl_migo_defaults  DEFINITIO