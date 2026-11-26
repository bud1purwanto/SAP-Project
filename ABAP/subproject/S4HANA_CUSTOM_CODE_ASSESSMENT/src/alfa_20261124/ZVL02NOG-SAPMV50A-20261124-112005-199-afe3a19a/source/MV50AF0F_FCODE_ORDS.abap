*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_ORDS                                        *
*----------------------------------------------------------------------*
* Display the preceding sales order
*
FORM fcode_ords.

  DATA: lf_vgbel           TYPE vbeln_va,
        lf_destination     LIKE tblsysdest-rfcdest,
        lf_vgsys           LIKE lips-vgsys,
        lf_vbeln           TYPE likp-vbeln,
        lf_spe_le_scenario TYPE /spe/le_scenario,
        lf_msgtext         TYPE char80.

  FIELD-SYMBOLS: <fs_head> TYPE likpvb.

  CASE taxi_screen_group.
    WHEN c_taxi_scrgrp_item.
      lf_vbeln = gs_lips_main-vbeln.
      lf_vgbel = gs_lips_main-vgbel.
      lf_vgsys = gs_lips_main-vgsys.
    WHEN c_taxi_scrgrp_batch.
      lf_vbeln = gs_lips_chsp-vbeln.
      lf_vgbel = gs_lips_chsp-vgbel.
      lf_vgsys = gs_lips_chsp-vgsys.
  ENDCASE.

* SPM: Determine scenario of delivery
  IF lf_vbeln <> xlikp-vbeln.
    READ TABLE xlikp ASSIGNING <fs_head>
                     WITH KEY vbeln = lf_vbeln.
    IF sy-subrc = 0.
      lf_spe_le_scenario = <fs_head>-spe_le_scenario.
    ENDIF.
  ELSE.
    lf_spe_le_scenario = xlikp-spe_le_scenario.
  ENDIF.

  IF NOT lf_vgsys IS INITIAL.                               "AIP

    CALL FUNCTION 'LOG_SYSTEM_GET_RFC_DESTINATION'
      EXPORTING
        logical_system                = lf_vgsys
      IMPORTING
        rfc_destination               = lf_destination
      EXCEPTIONS
        no_rfc_destination_maintained = 1
        OTHERS                        = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
    IF NOT lf_destination IS INITIAL.
      IF lf_spe_le_scenario <> gc_le_scenario-crm.
        CALL FUNCTION 'SD_SALESDOCUMENT_DISPLAY'
          DESTINATION
          lf_destination
          EXPORTING
            i_vbeln               = lf_vgbel
          EXCEPTIONS
            communication_failure = 1  MESSAGE lf_msgtext
            system_failure        = 1  MESSAGE lf_msgtext
            no_authority          = 2
            OTHERS                = 3.
        IF sy-subrc = 1.
          MESSAGE e899(v1) WITH lf_msgtext(50) lf_msgtext+50(30).
        ELSEIF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ELSE.
*       SPM: Call CRM to display sales order
        PERFORM display_order_crm USING lf_vgbel
                                        lf_destination.
      ENDIF.
    ENDIF.

  ELSE.

    CALL FUNCTION 'RV_CALL_DISPLAY_TRANSACTION'
      EXPORTING
        vbeln = lf_vgbel.

  ENDIF.

ENDFORM.                    "fcode_ords