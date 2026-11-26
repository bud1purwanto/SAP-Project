*&---------------------------------------------------------------------*
*&      Form  TAXI_INITIALIZE_CARRIERSCREEN
*&---------------------------------------------------------------------*
*       Vervollständigung und Manipulation des Trägerdynpros. Wird aus
*       jedem Trägerdynpro im PBO gerufen.
*
*       Funktion:
*       - Falls ein Bildgruppenwechsel erkannt wird:
*            Reiterleiste beschriften
*       - Falls zusätzlich ein Panelwechsel erkannt wird:
*            Reiteraktivierung veranlassen
*       - Unabhängig vom Ortswechsel (=immer):
*            unbeschriftete Reiter ausblenden, bei Unvollständigkeits-
*            protokollabarbeitung alle bis auf den aktiven Reiter
*            ausblenden.
*----------------------------------------------------------------------*
FORM taxi_initialize_carrierscreen.

* Symbolvariable zur Aufnahme der Bezeichnung des zur aktuellen
* Bildgruppe gehörenden Tabstrip-Controls
  DATA: lv_display_text_for_archive TYPE boole.
  FIELD-SYMBOLS: <taxi_tabstrip> LIKE taxi_tabstrip.

* BAdI Data
  DATA: l_sd_cust_head_exit   TYPE REF TO if_ex_badi_sd_tab_cust_h,
        l_sd_cust_item_exit   TYPE REF TO if_ex_badi_sd_tab_cust_i,
      active_h TYPE xfeld,
      active_i TYPE xfeld,
      lf_caption         LIKE taxi_tabstrip_captions-tab01,
      lf_taxi_index_h(2)   TYPE n,
      lf_taxi_index_i(2)   TYPE n,
      lf_varname         TYPE fieldname,
      lf_fcode_in        TYPE fcode,
      lf_fcode_out       TYPE fcode.
  FIELD-SYMBOLS: <lf_taxi_caption> LIKE taxi_tabstrip_captions-tab01
.

* new BAdI screen header and item tabs
  DATA: lv_taxi_index_cus_scr_h(2)     TYPE n,
        lv_taxi_index_int_scr_h(2)     TYPE n,
        ls_screenbadi_cus_h            TYPE sales_cust_tab_page,
        ls_screenbadi_int_h            TYPE tds_head_scr_int,
        lv_taxi_index_cus_scr_i(2)     TYPE n,
        lv_taxi_index_int_scr_i(2)     TYPE n,
        ls_screenbadi_cus_i            TYPE sales_cust_tab_page,
        ls_screenbadi_int_i            TYPE tds_item_scr_int,
        lv_screenbadi_tabs             TYPE i,
        lv_screenbadi_tab_index        TYPE n, "which screen BAdI tab
        lv_screen_structure_name       TYPE fieldname.

  FIELD-SYMBOLS: <lv_caption>          TYPE taxi_tabstrip_captions-tab01.
*

* Bildgruppenattribute der aktuellen Bildgruppe in die Workarea
* bringen, Tabstrip-Control-Symbolvariable belegen
  READ TABLE taxi_screen_groups
     WITH KEY screen_group = taxi_screen_group.
  ASSIGN (taxi_screen_groups-tabstrip_name) TO <taxi_tabstrip>.

  lv_display_text_for_archive = abap_false.
  IF cl_ops_switch_check=>sd_sfws_sc3( ) EQ abap_true.
    lv_display_text_for_archive = abap_true.
  ENDIF.

* In case of archived orders: deactivate text-tabstrips
  IF data_read_from_archive = 'X' AND
     lv_display_text_for_archive EQ abap_false.
    taxi_inactive_fcodes = 'KTEX_SUB'.
    APPEND taxi_inactive_fcodes.
    taxi_inactive_fcodes = 'PTEX_SUB'.
    APPEND taxi_inactive_fcodes.
  ENDIF.
ENHANCEMENT-POINT ISM_SAPMV45A SPOTS ES_SAPMV45A.

* Payment Service Provider
  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
    IF vbak-sppaym EQ cv_sppaym01 AND
    t180-trtyp EQ charv.
      taxi_inactive_fcodes = 'KRPL'.
      APPEND taxi_inactive_fcodes.
    ENDIF.
  ENDIF.


* Reiterleiste neu beschriften, Reiterfunktionscode-
* Umsetzungstabelle füllen
  CALL FUNCTION 'TAXI_CREATE_CAPTIONS'
    EXPORTING
      program                 = 'SAPMV45A'
      screen_group            = taxi_screen_group
    IMPORTING
      tabstrip_captions       = taxi_tabstrip_captions
    TABLES
      inactive_fcodes         = taxi_inactive_fcodes
    EXCEPTIONS
      no_tabs_for_screengroup = 1
      no_caption_for_fcode    = 2
      OTHERS                  = 3.

* Wenn das Flag TAXI_HEADER_INITIALIZED gesetzt ist, bedeutet dies,
* dass das Headersubscreendynpro seine Felddaten aus dem aktuellen
* Pool beziehen kann. Dies kann nur dann nicht erfüllt sein, wenn der
* Subscreen aus einem anderen Pool gerufen wird. Anders ausgedrückt,
* wird der Subscreen innerhalb eines Trägerdynpros dieses Pool
* gerufen, sind die Kopfdaten grundsätzlich initialisiert.
  taxi_header_initialized = 'X'.

* Unbeschriftete Reiter ausblenden
  CALL FUNCTION 'TAXI_INITIALIZE_CARRIERSCREEN'
    EXPORTING
      tabstrip_captions = taxi_tabstrip_captions
    EXCEPTIONS
      OTHERS            = 0.

*Screen extensions (BAdIs)
  CASE taxi_screen_group.
    WHEN 'K0'.
      CALL FUNCTION 'GET_HANDLE_SD_TAB_CUST_H'
        IMPORTING
          handle = l_sd_cust_head_exit
          active = active_h.
      IF active_h = 'X' .
        IF lf_taxi_index_h IS INITIAL.
          DO 32 TIMES VARYING lf_caption
                   FROM taxi_tabstrip_captions-tab01
                   NEXT taxi_tabstrip_captions-tab02.
            IF lf_caption EQ space.
              CLEAR lf_taxi_index_h.
              EXIT.
            ENDIF.
            lf_taxi_index_h = sy-index.
            CONCATENATE c_prefix_captions_field lf_taxi_index_h
                  INTO lf_fcode_in.

            CALL FUNCTION 'TAXI_CONVERT_FCODE'
              EXPORTING
                fcode_in        = lf_fcode_in
              IMPORTING
                fcode_out       = lf_fcode_out
              EXCEPTIONS
                fcode_not_found = 1
                OTHERS          = 2.
            IF sy-subrc NE 0.
              CLEAR lf_taxi_index_h.
              EXIT.
            ENDIF.

            IF lf_fcode_out CS 'CUST'.
              lf_taxi_index_h = sy-index.
              EXIT.
            ELSE.
              CLEAR lf_taxi_index_h.
            ENDIF.
          ENDDO.
        ENDIF.
        IF NOT lf_taxi_index_h IS INITIAL.
          CONCATENATE 'taxi_tabstrip_captions-tab' lf_taxi_index_h
                  INTO lf_varname.
          ASSIGN (lf_varname) TO <lf_taxi_caption>.
          <lf_taxi_caption> = gs_cust_tab-head_caption.
        ENDIF.
      ENDIF.
*     new BAdI screen - header
*     Header Internal BAdI screen tabs
      IF go_screenbadi_int_h IS BOUND.
*       If the classic screen extension BAdI is implemented, we can use the 'lf_taxi_index_h' index
        IF active_h = 'X'.
*         Store the tab counter
          lv_taxi_index_int_scr_h = lf_taxi_index_h.
        ENDIF.
        CLEAR lv_screenbadi_tab_index.
        DO.
          lv_taxi_index_int_scr_h = lv_taxi_index_int_scr_h + 1.
          ASSIGN COMPONENT lv_taxi_index_int_scr_h OF STRUCTURE taxi_tabstrip_captions TO <lv_caption>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          CONCATENATE c_prefix_captions_field lv_taxi_index_int_scr_h
                 INTO lf_fcode_in.
          CALL FUNCTION 'TAXI_CONVERT_FCODE'
            EXPORTING
              fcode_in        = lf_fcode_in
            IMPORTING
              fcode_out       = lf_fcode_out
            EXCEPTIONS
              fcode_not_found = 1
              OTHERS          = 2.
          IF sy-subrc NE 0.
            CLEAR lv_taxi_index_int_scr_h.
            EXIT.
          ENDIF.
          IF lf_fcode_out CS 'K_INT_BADI'.
            lv_screenbadi_tab_index = lv_screenbadi_tab_index + 1.
            READ TABLE gt_screenbadi_int_h
              INTO ls_screenbadi_int_h
              INDEX lv_screenbadi_tab_index.
            <lv_caption> = ls_screenbadi_int_h-caption.
*           If this tab was selected, keep screen attributes
            IF lf_fcode_out EQ taxi_fcode.
              gs_screenbadi_int_h = ls_screenbadi_int_h.
            ENDIF.
          ENDIF.
        ENDDO.
      ENDIF.
*     Header Customer BAdI screen tabs
      IF go_screenbadi_cus_h IS BOUND.
*       If the internal screen-badi is implemented, we can use the 'lv_taxi_index_int_scr_h' index
        IF go_screenbadi_int_h IS BOUND.
          lv_taxi_index_cus_scr_h = lv_taxi_index_int_scr_h.
*       If the classic screen extension BAdI is implemented, we can use the 'lf_taxi_index_h' index
        ELSEIF active_h = 'X'.
          lv_taxi_index_cus_scr_h = lf_taxi_index_h.
        ENDIF.
        CLEAR lv_screenbadi_tab_index.
        DO.
          lv_taxi_index_cus_scr_h = lv_taxi_index_cus_scr_h + 1.
          ASSIGN COMPONENT lv_taxi_index_cus_scr_h OF STRUCTURE taxi_tabstrip_captions TO <lv_caption>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          CONCATENATE c_prefix_captions_field lv_taxi_index_cus_scr_h
                 INTO lf_fcode_in.
          CALL FUNCTION 'TAXI_CONVERT_FCODE'
            EXPORTING
              fcode_in        = lf_fcode_in
            IMPORTING
              fcode_out       = lf_fcode_out
            EXCEPTIONS
              fcode_not_found = 1
              OTHERS          = 2.
          IF sy-subrc NE 0.
            CLEAR lv_taxi_index_cus_scr_h.
            EXIT.
          ENDIF.
          IF lf_fcode_out CS 'K_CUS_BADI'.
            lv_screenbadi_tab_index = lv_screenbadi_tab_index + 1.
            READ TABLE gt_screenbadi_cus_h
              INTO ls_screenbadi_cus_h
              INDEX lv_screenbadi_tab_index.
            <lv_caption> = ls_screenbadi_cus_h-head_caption.
*           If this tab was selected, keep screen attributes
            IF lf_fcode_out EQ taxi_fcode.
              gs_screenbadi_cus_h = ls_screenbadi_cus_h.
            ENDIF.
          ENDIF.
        ENDDO.
      ENDIF.
**
    WHEN 'P0'.
      CALL FUNCTION 'GET_HANDLE_SD_TAB_CUST_I'
        IMPORTING
          handle = l_sd_cust_item_exit
          active = active_i.
      IF active_i = 'X' .
        IF lf_taxi_index_i IS INITIAL.
          DO 32 TIMES VARYING lf_caption
                   FROM taxi_tabstrip_captions-tab01
                   NEXT taxi_tabstrip_captions-tab02.
            IF lf_caption EQ space.
              CLEAR lf_taxi_index_i.
              EXIT.
            ENDIF.
            lf_taxi_index_i = sy-index.
            CONCATENATE c_prefix_captions_field lf_taxi_index_i
                  INTO lf_fcode_in.

            CALL FUNCTION 'TAXI_CONVERT_FCODE'
              EXPORTING
                fcode_in        = lf_fcode_in
              IMPORTING
                fcode_out       = lf_fcode_out
              EXCEPTIONS
                fcode_not_found = 1
                OTHERS          = 2.
            IF sy-subrc NE 0.
              CLEAR lf_taxi_index_i.
              EXIT.
            ENDIF.

            IF lf_fcode_out CS 'CUST'.
              lf_taxi_index_i = sy-index.
              EXIT.
            ELSE.
              CLEAR lf_taxi_index_i.
            ENDIF.
          ENDDO.
        ENDIF.
        IF NOT lf_taxi_index_i IS INITIAL.
          CONCATENATE 'taxi_tabstrip_captions-tab' lf_taxi_index_i
                  INTO lf_varname.
          ASSIGN (lf_varname) TO <lf_taxi_caption>.
          <lf_taxi_caption> = gs_cust_tab-item_caption.
        ENDIF.
      ENDIF.
*     New Item Internal BAdI screen tabs
      IF go_screenbadi_int_i IS BOUND.
*       If the classic screen extension BAdI is implemented, we can use the 'lf_taxi_index_i' index
        IF active_i = 'X'.
*         Store the tab counter
          lv_taxi_index_int_scr_i = lf_taxi_index_i.
        ENDIF.
        CLEAR lv_screenbadi_tab_index.
        DO.
          lv_taxi_index_int_scr_i = lv_taxi_index_int_scr_i + 1.
          ASSIGN COMPONENT lv_taxi_index_int_scr_i OF STRUCTURE taxi_tabstrip_captions TO <lv_caption>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          CONCATENATE c_prefix_captions_field lv_taxi_index_int_scr_i
                 INTO lf_fcode_in.
          CALL FUNCTION 'TAXI_CONVERT_FCODE'
            EXPORTING
              fcode_in        = lf_fcode_in
            IMPORTING
              fcode_out       = lf_fcode_out
            EXCEPTIONS
              fcode_not_found = 1
              OTHERS          = 2.
          IF sy-subrc NE 0.
            CLEAR lv_taxi_index_int_scr_i.
            EXIT.
          ENDIF.
          IF lf_fcode_out CS 'P_INT_BADI'.
            lv_screenbadi_tab_index = lv_screenbadi_tab_index + 1.
            READ TABLE gt_screenbadi_int_i
              INTO ls_screenbadi_int_i
              INDEX lv_screenbadi_tab_index.
            <lv_caption> = ls_screenbadi_int_i-caption.
*           If this tab was selected, keep screen attributes
            IF lf_fcode_out EQ taxi_fcode.
              gs_screenbadi_int_i = ls_screenbadi_int_i.
            ENDIF.
          ENDIF.
        ENDDO.
      ENDIF.
*     Item Customer BAdI screen tabs
      IF go_screenbadi_cus_i IS BOUND.
*       If the internal screen-badi is implemented, we can use the 'lv_taxi_index_int_scr_i' index
        IF go_screenbadi_int_h IS BOUND.
          lv_taxi_index_cus_scr_i = lv_taxi_index_int_scr_i.
*       If the classic screen extension BAdI is implemented, we can use the 'lf_taxi_index_i' index
        ELSEIF active_h = 'X'.
          lv_taxi_index_cus_scr_i = lf_taxi_index_i.
        ENDIF.
        CLEAR lv_screenbadi_tab_index.
        DO.
          lv_taxi_index_cus_scr_i = lv_taxi_index_cus_scr_i + 1.
          ASSIGN COMPONENT lv_taxi_index_cus_scr_i OF STRUCTURE taxi_tabstrip_captions TO <lv_caption>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          CONCATENATE c_prefix_captions_field lv_taxi_index_cus_scr_i
                 INTO lf_fcode_in.
          CALL FUNCTION 'TAXI_CONVERT_FCODE'
            EXPORTING
              fcode_in        = lf_fcode_in
            IMPORTING
              fcode_out       = lf_fcode_out
            EXCEPTIONS
              fcode_not_found = 1
              OTHERS          = 2.
          IF sy-subrc NE 0.
            CLEAR lv_taxi_index_cus_scr_i.
            EXIT.
          ENDIF.
          IF lf_fcode_out CS 'P_CUS_BADI'.
            lv_screenbadi_tab_index = lv_screenbadi_tab_index + 1.
            READ TABLE gt_screenbadi_cus_i
              INTO ls_screenbadi_cus_i
              INDEX lv_screenbadi_tab_index.
            <lv_caption> = ls_screenbadi_cus_i-item_caption.
*           If this tab was selected, keep screen attributes
            IF lf_fcode_out EQ taxi_fcode.
              gs_screenbadi_cus_i = ls_screenbadi_cus_i.
            ENDIF.
          ENDIF.
        ENDDO.
      ENDIF.
**
  ENDCASE.

* Fand durch den Dialogschritt ein Ortswechsel statt ?
  IF taxi_panel NE *taxi_panel
        OR taxi_screen_group NE *taxi_screen_group.
    IF taxi_fcode = 'BAFE' AND
       fehler = space.
      taxi_fcode = taxi_panel.
      CLEAR <taxi_tabstrip>-%_scrollposition.
    ENDIF.
*    Wenn ja, den zum FCode passenden Reiter in den Vordergrund bringen
    PERFORM taxi_activate_tab
            TABLES   taxi_screen_groups
            USING    taxi_fcode
                     taxi_screen_group
            CHANGING <taxi_tabstrip>.
  ENDIF.

* Während der Abarbeitung des Unvollständigkeitsprotokolls alle Reiter
* bis auf den im Vordergrund befindlichen ausblenden
  IF NOT fehler IS INITIAL.
    CALL FUNCTION 'TAXI_INCOMPLOG_HIDE_TABS'
      EXPORTING
        tabstrip = <taxi_tabstrip>
      EXCEPTIONS
        OTHERS   = 0.
  ENDIF.

* Initialisieren Flag zum Verlassen des Dynpros ohne Verarbeitung
  CLEAR leave_without_check.

ENDFORM.                               " TAXI_INITIALIZE_CARRIERSCREEN