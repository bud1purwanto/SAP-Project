*&---------------------------------------------------------------------*
*&      Form  fcode_matsearch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fcode_matsearch.

  DATA: ls_search_param TYPE wsd_ms_initial_params_sty,
        ls_matlist      TYPE wsd_ms_return_sty,
        lt_matlist      TYPE wsd_ms_return_tty.

    DATA: ls_vbap         TYPE vbap,
        ls_knvv         TYPE knvv   .

  DATA: lv_subrc TYPE sy-subrc,
        lf_error TYPE flag.
  DATA: lv_space TYPE c VALUE space.
  data: ls_mara type mara.

  ls_search_param-app_name = cl_wsd_constants=>co_appl_sales_order.
  ls_search_param-kunnr = vbak-kunnr.

* Determine own plant
  IF rv45a-dwerk IS NOT INITIAL.
    ls_search_param-werks = rv45a-dwerk.
  ELSE.
* Read plant from user parameter
      CALL FUNCTION 'WSD_READ_PLANT_PARAM'
        IMPORTING
          e_werks = ls_search_param-werks.

    IF ls_search_param-werks IS NOT INITIAL.
* check if plant is assigned to sales organization.
      CALL FUNCTION 'TVKWZ_SINGLE_READ'
        EXPORTING
          tvkwz_vkorg = vbak-vkorg
          tvkwz_vtweg = vbak-vtweg
          tvkwz_werks = ls_search_param-werks
        EXCEPTIONS
          not_found   = 1
          OTHERS      = 2.
      IF sy-subrc <> 0.
        CLEAR ls_search_param-werks.
      ENDIF.
    ENDIF.
    IF ls_search_param-werks IS INITIAL.
*     popup to select plant
      CALL FUNCTION 'WSD_SELECT_OWN_PLANT'
        EXPORTING
          i_vkorg = vbak-vkorg
          i_vtweg = vbak-vtweg
        IMPORTING
          e_werks = ls_search_param-werks.
    ENDIF.
  ENDIF.
  IF ls_search_param-werks IS INITIAL.
    MESSAGE i096(wsd_message).
    RETURN.
  ENDIF.

  CLEAR ls_search_param-ekorg.
  ls_search_param-vkorg = vbak-vkorg.
  ls_search_param-vtweg = vbak-vtweg.
  ls_search_param-spart = vbak-spart.
  ls_search_param-auart = vbak-auart.
  CLEAR ls_search_param-free_text.
  ls_search_param-effective_date = sy-datum.

  AUTHORITY-CHECK OBJECT 'M_MATE_NEU' ID 'DUMMY' FIELD '__________'.
  IF sy-subrc = 0.
    CLEAR ls_search_param-restrict_mat_creation.
  ELSE.
    ls_search_param-restrict_mat_creation = 'X'.
  ENDIF.

    CALL FUNCTION 'WSD_MATERIAL_SEARCH'
      DESTINATION 'NONE'
      EXPORTING
        is_params             = ls_search_param
      IMPORTING
        et_return             = lt_matlist
      EXCEPTIONS
        system_failure        = 1
        communication_failure = 2
        OTHERS                = 3.

  CHECK sy-subrc = 0.
  IF lt_matlist IS NOT INITIAL.
    CALL FUNCTION 'MARC_ARRAY_READ'
      EXPORTING
        kzrfb                = 'X'
      EXCEPTIONS
        enqueue_mode_changed = 0
        lock_on_marc         = 0
        lock_system_error    = 0
        OTHERS               = 0.
  ENDIF.

* make sure to suppress error and warning messages
  KOPIEREN = 'X'.

  LOOP AT lt_matlist INTO ls_matlist.
    CHECK NOT ls_matlist-matnr IS INITIAL.
    svbap-tabix = 0.
    PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).
    vbap-matnr = ls_matlist-matnr.
    vbap-werks = ls_matlist-werks.
    vbap-vrkme = ls_matlist-vrkme.
    lf_error = charx.

*    perform vbap-matnr_pruefen(sapfv45p) using space
*                                      changing lv_subrc.
    CALL FUNCTION 'SD_CALL_PERFORM'
      EXPORTING
        iv_form       = 'VBAP-MATNR_PRUEFEN'
        iv_program    = 'SAPFV45P'
      CHANGING
        cv_using1     = lf_error
        cv_using2     = lv_subrc
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc <> 0.
      IF sy-msgno IS NOT INITIAL.
        message_collect msgg_check_item 'E'.
        CONTINUE.
      ENDIF.
    ENDIF.

*    perform vbap-werks_pruefen(sapfv45p) using vbap-posnr
*                                               vbap-werks
*                                               space
*                                               space
*                                               space
*                                      changing lv_subrc
*                                               vbap-lgort.
    CALL FUNCTION 'SD_CALL_PERFORM'
      EXPORTING
        iv_form       = 'VBAP-WERKS_PRUEFEN'
        iv_program    = 'SAPFV45P'
      CHANGING
        cv_using1     = vbap-posnr
        cv_using2     = vbap-werks
        cv_using3     = lv_space
        cv_using4     = lv_space
        cv_using5     = lf_error
        cv_using6     = lv_subrc
        cv_using7     = vbap-lgort
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc <> 0.
      IF sy-msgno IS NOT INITIAL.
        message_collect msgg_check_item 'E'.
        CONTINUE.
      ENDIF.
    ENDIF.

    PERFORM vbap_fuellen(sapfv45p).
    clear ls_mara.
    CALL FUNCTION 'MARA_SINGLE_READ'
      EXPORTING
        matnr                   = vbap-MATNR
      IMPORTING
        WMARA                   = ls_mara
      EXCEPTIONS
        OTHERS                  = 0.
* In case of retail generic materials => Matrix has to be called
    IF ls_mara-attyp = '01'.
      clear kopieren.
    ENDIF.
    rv45a-KWMENG = ls_matlist-kwmeng.
    cvbap-orfmng = ls_matlist-kwmeng.
    PERFORM vbap_bearbeiten(sapfv45p).
    kopieren = 'X'.
*   create schedule lines
    IF tvap-eterl NE space AND
       ls_matlist-kwmeng > 0.
      svbep-tabix = 0.
      PERFORM vbep_bearbeiten_vorbereiten(sapfv45e).
      vbep-wmeng = ls_matlist-kwmeng.
      PERFORM vbep_fuellen(sapfv45e).
      PERFORM vbep-wmeng_pruefen(sapfv45e) USING space
                          CHANGING sy-subrc sy-msgid sy-msgty sy-msgno
                                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      PERFORM vbep_bearbeiten(sapfv45e).
    ENDIF.
    PERFORM vbap_bearbeiten_ende(sapfv45p).
  ENDLOOP.

  clear KOPIEREN.

ENDFORM.                    "FCODE_MATSEARCH