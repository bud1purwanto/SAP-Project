*----------------------------------------------------------------------*
*   INCLUDE LMIGOHC2                                                   *
*   Header carrier implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_header IMPLEMENTATION.

************************************************************************
* Constructor: Not much to do.
************************************************************************
  METHOD constructor.
    DATA: lt_receiving TYPE lif_migo_frame=>ty_t_message_ids.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    lif_migo_frame~class_id = 'MIGO_HEADER'.
    APPEND 'HEADER_OPEN' TO lt_receiving.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_receiving  = lt_receiving.
    CREATE OBJECT poref_settings EXPORTING i_action = 'MIGO_HEADER'.
  ENDMETHOD.                    "constructor

************************************************************************
* PBO: Superclass PBO, get data from model, tabstrip settings
************************************************************************
  METHOD pbo.
    DATA:
      ls_badi   TYPE migo_badi_init,            "BAdI-Registration
      l_cprog   TYPE sycprog,                   "external program
      l_dynnr   TYPE sydynnr,                   "external screen
      l_heading TYPE migo_badi_heading,         "external tabstrip name
      l_tabix   TYPE sytabix.                   "BAdI implementation no.

    CALL METHOD super->pbo.
    CALL METHOD lcl_migo_globals=>kernel->header_get
      IMPORTING
        e_gohead = gohead.
    CALL METHOD subscreen_select.
    CALL METHOD screen_modify_local.
*   BAdI: Subscreens for external components
    IF NOT lcl_migo_globals=>if_badi is initial.                 "552774
      LOOP AT lcl_migo_globals=>t_badi INTO ls_badi.
        l_tabix = sy-tabix.
        CLEAR l_dynnr.
        CALL METHOD lcl_migo_globals=>if_badi->pbo_header
          EXPORTING
            i_class_id = ls_badi-class_id
          CHANGING
            e_cprog    = l_cprog
            e_dynnr    = l_dynnr
            e_heading  = l_heading.
        IF l_dynnr IS INITIAL.
*         No one interested: Dummy screen.
          l_cprog   = sy-repid.
          l_dynnr   = '2099'.
          l_heading = 'Unknown'.
        ENDIF.
        CASE l_tabix.
          WHEN 1.
            g_ext1_cprog       = l_cprog.
            g_ext1_head_dynnr  = l_dynnr.
            ts_gohead_ext_1    = l_heading.
          WHEN 2.
            g_ext2_cprog       = l_cprog.
            g_ext2_head_dynnr  = l_dynnr.
            ts_gohead_ext_2    = l_heading.
          WHEN 3.
            g_ext3_cprog       = l_cprog.
            g_ext3_head_dynnr  = l_dynnr.
            ts_gohead_ext_3    = l_heading.
          WHEN 4.
            g_ext4_cprog       = l_cprog.
            g_ext4_head_dynnr  = l_dynnr.
            ts_gohead_ext_4    = l_heading.
          WHEN 5.
            g_ext5_cprog       = l_cprog.
            g_ext5_head_dynnr  = l_dynnr.
            ts_gohead_ext_5    = l_heading.
        ENDCASE.
      ENDLOOP.
    ENDIF.                                                       "552774
*   set active tabstrip
    ts_gohead-activetab = poref_settings->get( 'ACTIVE_TAB' ).
  ENDMETHOD.                    "pbo

************************************************************************
* PAI: Data back to model
************************************************************************
  METHOD pai.

    CALL METHOD super->pai.

    CALL METHOD lcl_migo_globals=>kernel->header_modify
      EXPORTING
        i_gohead = gohead.

*   BAdI: PAI_HEADER
    IF NOT lcl_migo_globals=>if_badi is initial.                 "552774
      CALL METHOD lcl_migo_globals=>if_badi->pai_header
        EXPORTING
          i_okcode       = okcode
          is_gohead      = gohead.
    ENDIF.                                                       "552774
    CALL METHOD poref_settings->set( i_element = 'ACTIVE_TAB'
      i_active = ts_gohead-activetab ).
  ENDMETHOD.                    "pai

************************************************************************
* Screen modification for the header tabstrips
************************************************************************
  METHOD screen_modify_local.
    LOOP AT SCREEN.
*   Screen-input not allowed for tabstrip
      IF screen-input = c_mod_off.
        screen-input = c_mod_on.
      ENDIF.
      CASE screen-group2.
        WHEN 'TH1'.
*       Tabstrip TS_GOHEAD_CREATEDBY: only in display/change mode
          IF lcl_migo_globals=>kernel->s_action-create = abap_true.
            screen-invisible = c_mod_on.
            screen-active    = c_mod_off.
          ENDIF.
        WHEN 'TH2'.
*       Tabstrip TS_GOHEAD_VENDOR: only makes sense when with
*       resp. to goods receipt for PO. Therefore we check VGART
*       analog LMIGODC2
          IF lcl_migo_globals=>kernel->s_control-vgart <> 'WE' AND
             lcl_migo_globals=>kernel->s_control-vgart <> 'WO'.
            screen-invisible = c_mod_on.
            screen-active    = c_mod_off.
          ENDIF.
        WHEN 'TH4'.
*       Tabstrip TS_GOHEAD_IMPORT (foreign trade)
          IF gohead-exnum IS INITIAL.
            screen-invisible = c_mod_on.
            screen-active    = c_mod_off.
          ENDIF.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.                    "screen_modify_local

************************************************************************
* Subsceen_select: Find right subscreens according to VGART of         *
*                  reference document                                  *
************************************************************************
  METHOD subscreen_select.
*  Set new subscreen numbers for header general when VGART has changed.
    CASE lcl_migo_globals=>kernel->s_control-vgart.
      WHEN 'WE'.
        g_sub_general = '0110'.
      WHEN 'WF' OR 'WR' OR 'WS'.
        g_sub_general = '0111'.
      WHEN 'WA'.
        g_sub_general = '0112'.
      WHEN OTHERS.
        g_sub_general = '0110'.
    ENDCASE.
*  Set subscreen number for vendor or supplying plant
    IF gohead-reswk IS INITIAL.
      g_sub_vendor = '0115'.
    ELSE.
      g_sub_vendor = '0116'.
    ENDIF.

  ENDMETHOD.                    "subscreen_select


************************************************************************
* Callback methods
***********************************************************************
  METHOD lif_migo_frame~okcode_handler.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

  METHOD lif_migo_frame~message_handler.
    CASE i_message_id.
      WHEN 'HEADER_OPEN'.
        CHECK is_message-data1 <> space.
        CALL METHOD poref_settings->set( i_element = 'ACTIVE_TAB'
          i_active = is_message-data1 ).
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~message_handler

ENDCLASS.                    "lcl_migo_header IMPLEMENTATION