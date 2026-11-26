*----------------------------------------------------------------------*
*   INCLUDE MV45AF0S_SD_WORD_PROCESSING_PU                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SD_WORD_PROCESSING_PUT
*&---------------------------------------------------------------------*
  FORM sd_word_processing_put.

    DATA: da_display.
    DATA: lv_no_changes TYPE xfeld.

* Änderungsmodus
    da_display = t180-trtyp.

* Payment Service Provider
    IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
      IF t180-trtyp EQ charv AND
       vbak-sppaym EQ cv_sppaym01 AND
       gr_paysp IS BOUND.
        IF tvcom-tdobject EQ tdobject_vbbp.
          CALL METHOD gr_paysp->get_change_mode_group
            EXPORTING
            iv_group_id     =
              cl_sls_paysp_integration=>cv_group_id_text
            iv_trtyp      = t180-trtyp
            is_vbak       = vbak
            is_vbap       = vbap
            is_vbkd       = vbkd
            is_tvak       = tvak
            is_tvap       = tvap
            IMPORTING
              ev_no_changes  = lv_no_changes.
        ELSE.
          CALL METHOD gr_paysp->get_change_mode_group
            EXPORTING
            iv_group_id     =
              cl_sls_paysp_integration=>cv_group_id_text
            iv_trtyp      = t180-trtyp
            is_vbak       = vbak
            is_vbkd       = vbkd
            is_tvak       = tvak
            IMPORTING
             ev_no_changes  = lv_no_changes.
        ENDIF.
        IF lv_no_changes EQ abap_true.
          da_display = chara.
        ENDIF.
      ENDIF.
    ENDIF.

    TRANSLATE da_display USING 'AXH V '.

    IF sy-ucomm(3) = 'TP_'.
* word processing fcodes have been executed by V70T
* clear in order to not execute double
      CLEAR sy-ucomm.
    ENDIF.

* Texte anzeigen
    CALL FUNCTION 'SD_WORD_PROCESSING_PUT'
      EXPORTING
        fi_application_data  = tvcom
        fi_display_flag      = da_display
        fi_group             = tvcom-txtgn
        fi_object            = tvcom-tdobject
*       FI_APPL_OBJECT_IDENT = ' '
*       FI_APPL_OBJECT_DESCR = ' '
        fi_default_fcode     = 'ENT1'
        fi_subscreen_number  = '2100'
*       FIT_EXCL_FCODE       =
        fit_xvbpa            = xvbpa[]
      CHANGING
        fct_xvbuv            = xvbuv[]
        fct_xthead           = xthead[]
      EXCEPTIONS
        OTHERS               = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE chari NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDFORM.                             " SD_WORD_PROCESSING_PUT