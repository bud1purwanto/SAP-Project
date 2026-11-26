*----------------------------------------------------------------------*
*   INCLUDE LMIGOAR2                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_arch IMPLEMENTATION.

  METHOD constructor.
    DATA: lt_receiving   TYPE lif_migo_frame=>ty_t_message_ids.
    lif_migo_frame~class_id = 'MIGO_ARCH'.
    APPEND 'KERNEL_RESET'       TO lt_receiving.
    APPEND 'NEW_DOCUMENT'       TO lt_receiving.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer  = me
        it_receiving   = lt_receiving.
  ENDMETHOD.

*-----------------------------------------------------------------------
* Message handler
* This method is calles when messages occur for which lcl_migo_arch is
* registered
*-----------------------------------------------------------------------
  METHOD lif_migo_frame~message_handler.
*     Generic Object Services (GOS) is setting a "commit work" in
*     "cl_gos_manager->set_id_of_published_object" -> maybe it is better
*     not to use GOS when MIGO is called externally. But as you post in
*     46C with MIGO_DIALOG, the rollarea changes => commit should be no
*     problem => note 0429075:
*    CHECK lcl_migo_globals=>external_call_active = abap_false. "0429075

    FIELD-SYMBOLS: <ls_key> TYPE lcl_migo_kernel=>ty_s_refdockey.
    CASE i_message_id.
      WHEN 'KERNEL_RESET'.
        CALL METHOD object_publish_general.
      WHEN 'NEW_DOCUMENT'.
        IF is_message-data1 = 'R02'.
          ASSIGN is_message-dref->* TO <ls_key>.
          CALL METHOD object_publish_distinct
               EXPORTING
                i_matdoc_number = <ls_key>-mat_doc
                i_matdoc_year = <ls_key>-doc_year.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

*-----------------------------------------------------------------------
* okcode handler
*-----------------------------------------------------------------------
  METHOD lif_migo_frame~okcode_handler.
  ENDMETHOD.

*----------------------------------------------------------------------*
*  METHOD object_publish_general.                                      *
*----------------------------------------------------------------------*
* The generic object services need the key of a bor object, but        *
* this key is not known when starting migo. So just the object type    *
* can be published when starting migo.                                 *
*----------------------------------------------------------------------*
  METHOD object_publish_general.

    DATA: ls_object TYPE borident.

    CHECK lcl_migo_globals=>cntl_error = abap_false.             "204565

    IF NOT go_matdoc IS INITIAL.
      CALL METHOD go_matdoc->unpublish.
    ENDIF.

    ls_object-objtype = 'BUS2017'.

*   If MIGO is creating a material document, attachments should only
*   be saved if MIGO commits. But in display mode, the COMMIT
*   must be done by GOS because MIGO does not.
*   This is not critical. If MIGO is in display mode, no things
*   have been done which are update relevant.
*   And applications which place something into the UPDATE-task
*   or do PERFORM ON COMMIT and afterwards call MIGO to display
*   a material document cannot be helped anyway :-)
    CREATE OBJECT go_matdoc
      EXPORTING
        is_object = ls_object
        ip_no_instance = x
        ip_no_commit   =                                         "381390
                   lcl_migo_globals=>kernel->s_action-create     "381390
      EXCEPTIONS
        others = 1.

*   Usually, explicit FLUSHs are not necessary unless you need
*   data from the frontend and should be avoided whenever possible.
*   Without this flush here, the object services will create
*   two (2) of its control objects (visible only in the new GUI design).
*   However, as this is an explicit flush, it needs to implement the
*   exceptions to detect GUI errors (the implicit FLUSH is covered
*   by the SET HANDLER in LCL_MIGO_GLOBALS).
    CALL METHOD cl_gui_cfw=>flush                                "204565
      EXCEPTIONS                                                 "204565
        cntl_system_error = 1                                    "204565
        cntl_error        = 2                                    "204565
        OTHERS            = 3.                                   "204565
    IF sy-subrc <> 0.                                            "204565
      CALL METHOD lcl_migo_globals=>cntl_error_handler.          "204565
    ENDIF.                                                       "204565

  ENDMETHOD.

*----------------------------------------------------------------------*
*  METHOD object_publish_disitinct                                     *
*----------------------------------------------------------------------*
* As soon as we know the complete key of our object, it can be         *
* published to the generic object services                             *
*----------------------------------------------------------------------*
  METHOD object_publish_distinct.

    DATA: ls_object TYPE borident.

    CHECK lcl_migo_globals=>cntl_error = abap_false.             "204565

    ls_object-objtype      = 'BUS2017'.
    ls_object-objkey       = i_matdoc_number.
    ls_object-objkey+10(4) = i_matdoc_year.
    CALL METHOD go_matdoc->set_id_of_published_object
                  EXPORTING
                    is_object = ls_object.



  ENDMETHOD.

ENDCLASS.