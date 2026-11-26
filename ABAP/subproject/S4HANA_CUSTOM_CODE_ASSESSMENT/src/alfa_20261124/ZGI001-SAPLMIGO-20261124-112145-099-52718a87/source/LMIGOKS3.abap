
*----------------------------------------------------------------------*
*   INCLUDE LMIGOKS3                                                   *
*   kernal serial_numbers implementation                               *
*----------------------------------------------------------------------*


************************************************************************
* serialnumbers_read                                                   *
************************************************************************
* read serialnumbers of material document item                         *
************************************************************************

METHOD serialnumbers_read.

* local variables
  DATA:
    ls_rserob   TYPE rserob,
    lt_sernos   TYPE TABLE OF rserob,
    ls_sernos   TYPE rserob,
    ls_goserial TYPE ty_s_goserial,
    ls_goitem   TYPE goitem.

* EhP604 Serial Numbers
  DATA:
    ls_st156s   TYPE st156s,
    ls_sernr    TYPE e1rmsno,
    lt_r_sernr  TYPE TABLE OF ersernr,
    lt_sernr    TYPE TABLE OF e1rmsno,
    lt_tsmesg   TYPE tsmesg,
    lv_msgv1    TYPE sychar50.

  FIELD-SYMBOLS:
    <lf_tsmesg> TYPE smesg.

  ls_goitem = is_goitem.

* reset returning table
  CLEAR et_goserial.

* Reference: Material document
  IF s_control-refdoc = 'R02' OR
     s_control-refdoc = 'R03'.
    ls_rserob-taser = 'SER03'.
    ls_rserob-mblnr = ls_goitem-mblnr.
    ls_rserob-mjahr = ls_goitem-mjahr.
    IF ls_goitem-maa_urzei IS INITIAL.                      "MAA2
      ls_rserob-zeile = ls_goitem-zeile.
    ENDIF.                                                  "MAA2

* Reference: Order
  ELSEIF s_control-refdoc = 'R08'.
    ls_rserob-taser   = 'SER05'.
    ls_rserob-ppaufnr = ls_goitem-pps_aufnr.
    ls_rserob-ppposnr = ls_goitem-pps_posnr.

*  Reference: Purchase Order                              "EhP604
  ELSEIF s_control-refdoc = 'R01' AND cl_mmpur_switch_check=>get_serial01_switch_state( ) = abap_true.
    ls_rserob-taser = 'SER08'.
    ls_rserob-ebeln = ls_goitem-ebeln.
    ls_rserob-ebelp = ls_goitem-ebelp.

* Reference: Delivery
  ELSE.
    ls_rserob-taser   = 'SER01'.
*   Inbound delivery / Shipping notification                "491680
    IF  is_goitem-vbeln IS INITIAL.                         "491680
      ls_rserob-lief_nr = ls_goitem-vlief_avis.             "491680
      ls_rserob-posnr   = ls_goitem-vbelp_avis.             "491680
*   Outbound delivery                                       "491680
    ELSE.                                                   "491680
      ls_rserob-lief_nr = ls_goitem-vbeln.                  "491680
      ls_rserob-posnr   = ls_goitem-posnr.                  "491680
    ENDIF.                                                  "491680
*   via Handling Unit                                       "731711
    IF NOT godynpro-shipping_unit IS INITIAL.               "731711
      ls_rserob-taser   = 'SER06'.                          "731711
      ls_rserob-venum   = is_vepwe-venum.                   "731711
      ls_rserob-vepos   = is_vepwe-vepos.                   "731711
    ENDIF.                                                  "731711
  ENDIF.

* get serial numbers and uiis
  CALL FUNCTION 'GET_SERNOS_OF_DOCUMENT'
    EXPORTING
      key_data            = ls_rserob
    TABLES
      sernos              = lt_sernos
    EXCEPTIONS
      key_parameter_error = 1
      no_supported_access = 2
      no_data_found       = 3
      OTHERS              = 4.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.

* delete serial numbers which do not belog to maa_urzei      "MAA2
  IF NOT ls_goitem-maa_urzei IS INITIAL.                    "MAA2
    DATA : lv_flag_error       TYPE  abap_bool,             "MAA2
           lt_message_log      TYPE  bapirettab.            "MAA2

    CALL METHOD go_mmim_maa_2->maa_get_serial               "MAA2
              EXPORTING                                     "MAA2
                is_goitem       = ls_goitem                 "MAA2
              CHANGING                                      "MAA2
                lt_sernos       = lt_sernos                 "MAA2
                ct_message_log  = lt_message_log            "MAA2
                cv_flag_error   = lv_flag_error.            "MAA2
  ENDIF.                                                    "MAA2

* add selected data to returning table
  LOOP AT lt_sernos INTO ls_sernos.
    ls_goserial-serialno = ls_sernos-sernr.
    ls_goserial-uii      = ls_sernos-uii.                  "EHP603 IUID
    APPEND ls_goserial TO et_goserial.
  ENDLOOP.

ENHANCEMENT-POINT EHP604_SERNR_READ_02 SPOTS ES_SAPLMIGO.

ENHANCEMENT-POINT EHP604_SERNR_READ_03 SPOTS ES_SAPLMIGO.

enhancement-point ehp604_sernr_read_04 spots es_saplmigo.

ENDMETHOD.                    "serialnumbers_read


************************************************************************
* serialnumbers_fill                                                   *
************************************************************************
* fill serialnumbers in internal local table for post                  *
************************************************************************

METHOD serialnumbers_fill.

* local pointers
  FIELD-SYMBOLS:
    <ls_goserial_kernel> TYPE ty_s_goserial_kernel.

* loval variables
  DATA:
    ls_goserial_post TYPE ty_s_goserial_post,
    ls_goserial      TYPE ty_s_goserial.

  READ TABLE pt_goserial_kernel
                    ASSIGNING <ls_goserial_kernel> WITH TABLE KEY
                     global_counter = i_global_counter.
  IF sy-subrc = 0.
    LOOP AT <ls_goserial_kernel>-t_goserial INTO ls_goserial.
      ls_goserial_post-serialno = ls_goserial-serialno.
      ls_goserial_post-uii      = ls_goserial-uii.         "EHP603 IUID
*      ls_goserial_post-matdoc_itm = i_global_counter+2(4).   "558991
      ls_goserial_post-matdoc_itm = i_counter.              "734758
ENHANCEMENT-POINT EHP604_SERIALNUMBERS_FILL_01 SPOTS ES_SAPLMIGO.
      APPEND ls_goserial_post TO pt_goserial_post.
    ENDLOOP.
  ENDIF.

ENDMETHOD.                    "serialnumbers_fill


************************************************************************
* serialnumbers_post                                                   *
************************************************************************
* post serialnumbers                                                   *
************************************************************************

METHOD serialnumbers_post.

* local variables
  DATA:
    l_ser_tab TYPE TABLE OF iseri.

* Transfer information to local memory of serial number management
  IF s_action-cancel = abap_false AND
     NOT pt_goserial_post IS INITIAL.
    l_ser_tab[] = pt_goserial_post[].
    CALL FUNCTION 'DOCUMENT_SERIALNOS_IMPORT'
      TABLES
        ser_tab = l_ser_tab.
  ENDIF.

* initialization of serialnumber tables
  CALL FUNCTION 'SERIALPROFILE_CHECK'
    EXPORTING
      operation    = 'SNCL'
    EXCEPTIONS
      error_message.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.

ENDMETHOD.                    "serialnumbers_post


************************************************************************
* serailnumbers_select_all                                             *
************************************************************************

METHOD serialnumbers_select_all.

* local pointers
  FIELD-SYMBOLS:
    <ls_goserial>        TYPE ty_s_goserial,
    <ls_goserial_kernel> TYPE ty_s_goserial_kernel.

* local variables
  DATA:
    l_global_counter TYPE ty_s_goserial_kernel-global_counter.

  CALL METHOD line_mapping
    EXPORTING
      i_line           = i_line
    IMPORTING
      e_global_counter = l_global_counter.

  READ TABLE pt_goserial_kernel ASSIGNING <ls_goserial_kernel>
        WITH TABLE KEY global_counter = l_global_counter.
  LOOP AT <ls_goserial_kernel>-t_goserial ASSIGNING <ls_goserial>
                                          WHERE selected IS INITIAL.
    <ls_goserial>-selected = x.
  ENDLOOP.

ENDMETHOD.                    "serialnumbers_select_all


************************************************************************
* serailnumbers_deselect_all                                           *
************************************************************************

METHOD serialnumbers_deselect_all.

* local pointers
  FIELD-SYMBOLS:
    <ls_goserial>        TYPE ty_s_goserial,
    <ls_goserial_kernel> TYPE ty_s_goserial_kernel.

* local variables
  DATA:
    l_global_counter TYPE ty_s_goserial_kernel-global_counter.

  CALL METHOD line_mapping
    EXPORTING
      i_line           = i_line
    IMPORTING
      e_global_counter = l_global_counter.

  READ TABLE pt_goserial_kernel ASSIGNING <ls_goserial_kernel>
                     WITH TABLE KEY global_counter = l_global_counter.
  LOOP AT <ls_goserial_kernel>-t_goserial ASSIGNING <ls_goserial>
                                   WHERE selected = x.
    CLEAR <ls_goserial>-selected.
  ENDLOOP.

ENDMETHOD.                    "serialnumbers_deselect_all


************************************************************************
* serailnumbers_delete_sel                                             *
************************************************************************

METHOD serialnumbers_delete_sel.

* local pointers
  FIELD-SYMBOLS:
    <ls_goserial_kernel> TYPE ty_s_goserial_kernel.

* local variables
  DATA:
    l_global_counter TYPE ty_s_goserial_kernel-global_counter,
    ls_goserial      TYPE ty_s_goserial.

  CALL METHOD line_mapping
    EXPORTING
      i_line           = i_line
    IMPORTING
      e_global_counter = l_global_counter.

  READ TABLE pt_goserial_kernel ASSIGNING <ls_goserial_kernel>
                      WITH TABLE KEY global_counter = l_global_counter.

  DELETE <ls_goserial_kernel>-t_goserial WHERE selected = x.

ENDMETHOD.                    "serialnumbers_delete_sel