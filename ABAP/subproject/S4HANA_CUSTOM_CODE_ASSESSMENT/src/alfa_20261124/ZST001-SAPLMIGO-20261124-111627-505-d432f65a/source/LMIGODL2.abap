*----------------------------------------------------------------------*
*   INCLUDE LMIGODL2                                                   *
*   Dynpro locator
*----------------------------------------------------------------------*
CLASS lcl_migo_dynprolocator IMPLEMENTATION.


************************************************************************
* Constructor: Register at framework
************************************************************************
METHOD constructor.
  DATA: lt_receiving TYPE lif_migo_frame~ty_t_message_ids,
        lt_sending   TYPE lif_migo_frame~ty_t_message_ids.
  lif_migo_frame~class_id = 'MIGO_DYNPROLOCATOR'.
  APPEND 'SET_CURSOR_POSITION'        TO lt_receiving.
  APPEND 'ITEMDETAIL_CURRENTLINE'     TO lt_receiving.
  APPEND 'MIGO_DETAIL_TOGGLER_STATUS' TO lt_receiving.
  APPEND 'HEADER_OPEN'                TO lt_sending.
  APPEND 'ITEMDETAIL_OPEN'            TO lt_sending.
  APPEND 'ITEMDETAIL_LINE_SET'        TO lt_sending.
  APPEND 'TABLEVIEW_LINE_SET'         TO lt_sending.
  APPEND 'GA_OPEN'                    TO lt_sending.
ENHANCEMENT-POINT LMIGODL2_05 SPOTS ES_SAPLMIGO.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_receiving  = lt_receiving
      it_sending    = lt_sending.

ENDMETHOD.

************************************************************************
* Handler method
************************************************************************
METHOD lif_migo_frame~message_handler.
  DATA: l_glc       TYPE migo_global_counter,
        l_fieldname TYPE migo_fieldname.
  CASE i_message_id.
    WHEN 'SET_CURSOR_POSITION'.
      l_glc       = is_message-data1.
      l_fieldname = is_message-data2.
      CALL METHOD set_cursor_position
        EXPORTING
          i_glc       = l_glc
          i_fieldname = l_fieldname.
    WHEN 'ITEMDETAIL_CURRENTLINE'.
      p_itemdetail_line = is_message-data1.
    WHEN 'MIGO_DETAIL_TOGGLER_STATUS'.
      IF is_message-data1 = 'VISIBILITY'.
        p_itemdetail_visible = is_message-data2.
      ENDIF.
  ENDCASE.
ENDMETHOD.

METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.


************************************************************************
* Set cursor to a specified field using the field-dynpro-relation
* stored in the fieldselection class
************************************************************************
METHOD set_cursor_position.
  DATA: lt_dynnr    TYPE lcl_migo_screenmodification=>ty_t_dynnr,
        ls_column   TYPE lcl_migo_screenmodification=>ty_s_column,
        l_dynnr     TYPE sydynnr,
        l_status    TYPE migo_fs_status,
        l_line      TYPE sytabix,
        l_fieldname TYPE migo_fieldname.
* Ask the screenmodification on which dynpros the requested
* field may be found. Additional demand: Field is ready for input.
  CALL METHOD lcl_migo_screenmodification=>field_locate
    EXPORTING
      i_field          = i_fieldname
      i_global_counter = i_glc
    IMPORTING
      et_dynnr         = lt_dynnr.
* No rule without exception.
* In R/3: Only exceptions, no rules.
* Fields in the header data are on different screens, depending on
* transaction type. This inforamtion is not known to the
* fieldselection and has to be considered in the application (here).
ENHANCEMENT-SECTION     LCL_MIGO_DYNPROLOCATOR_01 SPOTS ES_SAPLMIGO.
  CASE i_fieldname.
    WHEN 'GOHEAD-BKTXT' OR
         'GOHEAD-BLDAT' OR
         'GOHEAD-BUDAT' OR
         'GOHEAD-LFSNR' OR
         'GOHEAD-XABLN'.
      CLEAR lt_dynnr.
      APPEND g_sub_general TO lt_dynnr.
  ENDCASE.
END-ENHANCEMENT-SECTION.


* For item lines, get line number in model
  CALL METHOD lcl_migo_globals=>kernel->line_mapping
    EXPORTING  i_global_counter = i_glc
    IMPORTING  e_line           = l_line
    EXCEPTIONS not_found        = 1.
* If the field is potentially in the table control, find out
* whether it is ready for input there.
ENHANCEMENT-SECTION     LMIGODL2_01 SPOTS ES_SAPLMIGO.
  READ TABLE lt_dynnr WITH KEY table_line = '0200'
             TRANSPORTING NO FIELDS.
END-ENHANCEMENT-SECTION.
  IF sy-subrc = 0.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING   i_field  = i_fieldname
      RECEIVING   r_status = l_status.
    IF l_status >= lcl_migo_screenmodification=>c_visible AND
       ( p_itemdetail_visible = abap_false OR
         l_line <> p_itemdetail_line ).
*     Last (?) check: The column must not be removed by the
*     administrator function. This information is not
*     accessible in the fieldselection table as it is a
*     technical information from the table control.
*     If the column has been disabled by MIGO, the
*     GET-method would return STATUS = 0.
ENHANCEMENT-SECTION     LMIGODL2_02 SPOTS ES_SAPLMIGO.
      READ TABLE tv_goitem-cols INTO ls_column
                 WITH KEY screen-name = i_fieldname.
END-ENHANCEMENT-SECTION.
      IF ls_column-invisible <> x.
      def_sms 'TABLEVIEW_LINE_SET' l_line space.
ENHANCEMENT-SECTION     LMIGODL2_03 SPOTS ES_SAPLMIGO.
      CALL METHOD lcl_migo_cursor=>cursor_set
        EXPORTING i_dynnr = '0200'
                  i_stepl = 1
                  i_field = i_fieldname.
END-ENHANCEMENT-SECTION.
      EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
* If we are here, the cursor could not be placed into the table control.
* So we open the corresponding detail viewer and place it there.
ENHANCEMENT-SECTION     LMIGODL2_04 SPOTS ES_SAPLMIGO.
  LOOP AT lt_dynnr INTO l_dynnr WHERE table_line <> '0200'.
    EXIT.
  ENDLOOP.
END-ENHANCEMENT-SECTION.
  CHECK NOT l_dynnr IS INITIAL.

* Open header if header field
  IF l_dynnr >= '0100' AND l_dynnr < '0200'.               "#EC PORTABLE
    def_sms 'HEADER_OPEN' space space.
  ENDIF.
* Open item if requested.
  IF l_line <> 0.
    def_sms 'ITEMDETAIL_OPEN'     space  space.
    def_sms 'ITEMDETAIL_LINE_SET' l_line space.
  ENDIF.
* Special business knowledge the fieldselection does not know:
* Fields on the COBL-screen are dynpro 0345.
* We have to switch manually to the corresponding tabstrip because
* if the field is not on the initial COBL-screen but can only be
* accessed via the "MORE"-button, then the cursor will not be set
* and the screen will not be visible.
  l_fieldname = i_fieldname.
  IF l_dynnr = 'COBL'.
    l_dynnr = '0345'.
    def_sms 'ITEMDETAIL_OPEN' 'OK_GOITEM_ACCOUNT' space.
  ELSEIF l_dynnr = 'VBDO'.                           " documentary batch
*   similar for documentary bach: subscreen is not handled by MM-IM
    l_dynnr = '0338'.
    def_sms 'ITEMDETAIL_OPEN' 'OK_GOITEM_BATCH' space.
  ENDIF.
* Set cursor
  CALL METHOD lcl_migo_cursor=>cursor_set
    EXPORTING i_dynnr = l_dynnr
              i_field = l_fieldname.

ENDMETHOD.














ENDCLASS.