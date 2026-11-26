*&---------------------------------------------------------------------*
*&  Include           MV45A_MSRF02
*&---------------------------------------------------------------------*
*&  subroutines for copying data from transaction MSR_CRD to CMR
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MSR_COPY
*&---------------------------------------------------------------------*
*       This form routine will be called at the end of form routine
*       UEBERSICHT_ANSTEUERN (include FV45PF0U) and will be implemented
*       within SAPMV45A. It imports the RRD data from memory and calls
*       the following form routines MSR_COPY_HEAD and MSR_COPY_ITEM
*       which will set up the CMR data.
*----------------------------------------------------------------------*
FORM msr_copy.

  LOCAL: gv_msr_crd_copy.

  DATA:
    ls_rrd_head         TYPE msr_s_rrd_head_cust,
    lt_rrd_item         TYPE msr_t_rrd_item_cust.

  gv_msr_crd_copy = charx.

  PERFORM msr_copy_data.

  synchronous = charx.

ENDFORM.                    "MSR_COPY

*&---------------------------------------------------------------------*
*&      Form  MSR_COPY_HEAD
*&---------------------------------------------------------------------*
*       The corresponding return header will be copied
*----------------------------------------------------------------------*
FORM msr_copy_head
  USING
    is_rrd_head         TYPE msr_s_rrd_head_cust.

  FIELD-SYMBOLS:
    <lr_sperre_beibehalten> TYPE char1.

  PERFORM beleg_kopieren_vorbereiten IN PROGRAM sapfv45c
                                     USING is_rrd_head-auara.

  CALL FUNCTION 'RV_DOCUMENT_COPY_NO_POPUP'
    EXPORTING
      fvak       = tvak
      fvbak      = vbak
      fvbpa      = vbpa
      i_vbeln    = is_rrd_head-refbeln
      i_no_items = charx
    IMPORTING
      fvbak      = cvbak
      fvbuk      = cvbuk
      fvcpa      = tvcpa
      fvbrk      = cvbrk
    TABLES
      fxvbap     = cvbap
      fxvbep     = cvbep
*     fyvbfa     =
      fxvbfa     = cvbfa
      fxvbkd     = cvbkd
      fxvbpa     = cvbpa
      fxvbuk     = xvbuk
      fxvbup     = cvbup
      fxvbuv     = xvbuv
      fxfpla     = cfpla
      fxfplt     = cfplt
      fxvbsn     = cvbsn
      fxvbrp     = cvbrp.

  gesperrt = charx.

* don't delete the block of the preceding document
  ASSIGN ('(SAPFV45C)sperre_beibehalten') TO <lr_sperre_beibehalten>.
  IF <lr_sperre_beibehalten> IS ASSIGNED.
    <lr_sperre_beibehalten> = charx.
  ENDIF.

* now copy the preceding document
  PERFORM vorlage_kopieren IN PROGRAM sapfv45c.

* reset the blocking indicator
  IF <lr_sperre_beibehalten> IS ASSIGNED.
    CLEAR <lr_sperre_beibehalten>.
  ENDIF.

ENDFORM.                    "MSR_COPY_HEAD

*&---------------------------------------------------------------------*
*&      Form  MSR_COPY_ITEM
*&---------------------------------------------------------------------*
*       The corresponding return item should be copied in 3 steps
*         1.) prepare the copying
*         2.) set up the c-tables
*         3.) set the deletion indicator for not relevant items
*         4.) set up the x-tables
*         5.) the RRD data will be set in the according item
*----------------------------------------------------------------------*
FORM msr_copy_item
  USING
    is_rrd_head         TYPE msr_s_rrd_head_cust
  CHANGING
    ct_rrd_item         TYPE msr_t_rrd_item_cust.

  TYPES:
    BEGIN OF lty_s_posnr_exchange,
      alt               TYPE posnr_va,
      neu               TYPE posnr_va,
    END OF lty_s_posnr_exchange,
    lty_t_posnr_exchange TYPE STANDARD TABLE OF lty_s_posnr_exchange.

  DATA:
    lv_copy             TYPE boolean,
    lo_badi             TYPE REF TO msr_sd_sales,
    lt_msr_sales_item   TYPE msr_t_sales_item.

  FIELD-SYMBOLS:
    <ls_rrd_item>       TYPE msr_s_rrd_item_cust,
    <ls_cvbap>          TYPE vbapvb,
    <lt_posnr_exchange> TYPE lty_t_posnr_exchange,
    <ls_posnr_exchange> TYPE lty_s_posnr_exchange,
    <lv_posnr_new>      TYPE posnr_va.

  GET BADI lo_badi.

  LOOP AT ct_rrd_item ASSIGNING <ls_rrd_item>.

* 1.) prepare the copying
    PERFORM beleg_kopieren_vorbereiten IN PROGRAM sapfv45c
                                       USING vbak-auart.

* 2.) set up the c-tables
    cvbfa[] = xvbfa[].
    cvbup[] = xvbup[].

    CALL FUNCTION 'RV_DOCUMENT_COPY_NO_POPUP'
      EXPORTING
        fvak       = tvak
        fvbak      = vbak
        fvbpa      = vbpa
        i_vbeln    = is_rrd_head-refbeln
        i_no_items = ' '
      IMPORTING
        fvbak      = cvbak
        fvbuk      = cvbuk
        fvcpa      = tvcpa
        fvbrk      = cvbrk
      TABLES
        fxvbap     = cvbap
        fxvbep     = cvbep
*       fyvbfa     =
        fxvbfa     = cvbfa
        fxvbkd     = cvbkd
        fxvbpa     = cvbpa
        fxvbuk     = xvbuk
        fxvbup     = cvbup
        fxvbuv     = xvbuv
        fxfpla     = cfpla
        fxfplt     = cfplt
        fxvbsn     = cvbsn
        fxvbrp     = cvbrp.

* 3.) set the deletion indicator for not relevant items
*     and check wether there are is an item to copy
    CLEAR lv_copy.
    LOOP AT cvbap ASSIGNING <ls_cvbap>.
      IF <ls_cvbap>-posnr NE <ls_rrd_item>-posnr.
        <ls_cvbap>-updkz = 'D'.
      ELSE.
        lv_copy = charx.
      ENDIF.
    ENDLOOP.

* 4.) set up the x-tables
    IF lv_copy IS INITIAL.
      DELETE ct_rrd_item.
      CONTINUE.
    ELSE.
      gv_msr_copy_split_id = <ls_rrd_item>-split_id.
      PERFORM vorlage_kopieren IN PROGRAM sapfv45c.
      CLEAR gv_msr_copy_split_id.
    ENDIF.

* 5.) the RRD data will be set in the according item
* first get the according vbap entry
    ASSIGN ('(SAPFV45C)POSNR_UMSETZUNG[]') TO <lt_posnr_exchange>.
    READ TABLE <lt_posnr_exchange> ASSIGNING <ls_posnr_exchange> INDEX 1.
    IF sy-subrc IS NOT INITIAL.
      DELETE ct_rrd_item.
      CONTINUE.
    ENDIF.
    ASSIGN <ls_posnr_exchange>-neu TO <lv_posnr_new>.
    IF <lv_posnr_new> IS NOT ASSIGNED.
      DELETE ct_rrd_item.
      CONTINUE.
    ENDIF.
    PERFORM xvbap_lesen_allgemein IN PROGRAM sapfv45p
                                  USING <lv_posnr_new>
                                        space
                                  CHANGING svbap-tabix.
    IF svbap-tabix = 0.
      DELETE ct_rrd_item.
      CONTINUE.
    ENDIF.

    PERFORM vbap_bearbeiten_vorbereiten IN PROGRAM sapfv45p.
    IF vbap-zieme NE <ls_rrd_item>-vrkme.
      vbap-zieme = <ls_rrd_item>-vrkme.
      PERFORM vbap-zieme_pruefen IN PROGRAM sapfv45p
                                 USING charx
                                 CHANGING sy-subrc sy-msgid sy-msgty
                                          sy-msgno sy-msgv1 sy-msgv2
                                          sy-msgv3 sy-msgv4.
      PERFORM message_vbfs_aufbauen IN PROGRAM sapfv45l
                                    USING 'V1' '395' 'I'
                                          space space space space.
    ENDIF.
* KWMENG: update target quantity
* vbap-zmeng_pruefen has to run after having set the quantity units
    IF vbap-zmeng NE <ls_rrd_item>-kwmeng.
      vbap-zmeng = <ls_rrd_item>-kwmeng.
      PERFORM vbap-zmeng_pruefen IN PROGRAM sapfv45p.
    ENDIF.
* RFMNG: will not be considered
* MEINS: will not be considered
* REJECTION_REASON: update Multi-step-returns : Rejection reason
    vbap-abgru = <ls_rrd_item>-abgru.
* RET_REASON: update Multi-step-returns : Returns reason
    vbap-msr_ret_reason = <ls_rrd_item>-ret_reason.
* REFUND_CODE: update Multi-step returns : Returns refund code
    vbap-msr_refund_code = <ls_rrd_item>-refund_code.
* INSPECTION_CODE: will not be considered
* SPLIT_ID: will not be considered

* remember posnr for tracking issues during saving
    <ls_rrd_item>-posnr = <lv_posnr_new>.

    gs_msr_sales_item-inspection_code = <ls_rrd_item>-inspection_code.

    PERFORM msr_check_item USING space space.
    PERFORM vbap_bearbeiten IN PROGRAM sapfv45p.
    PERFORM vbap_bearbeiten_ende IN PROGRAM sapfv45p.

  ENDLOOP.

  IF gr_msr_sales IS NOT INITIAL.
    gr_msr_sales->change_head_billing_block(
      EXPORTING
        is_vbak                 = vbak
        it_xvbap                = xvbap[]
        iv_trtyp                = t180-trtyp
      CHANGING
        cv_header_billing_block = vbak-faksk ).
  ENDIF.

ENDFORM.                    "MSR_COPY_ITEM


*&---------------------------------------------------------------------*
*&      Form  msr_copy_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM msr_copy_data.

  DATA: ls_rrd_head TYPE msr_s_rrd_head_cust,
        ls_rrd_item TYPE msr_s_rrd_item_cust,
        lt_rrd_item TYPE msr_t_rrd_item_cust.
  DATA: lv_no_items TYPE flag.
  DATA  lv_call_activity(4).

  FIELD-SYMBOLS:
        <ls_cvbap> TYPE vbapvb,
        <ls_posnr_umsetzung> TYPE data,
        <lt_posnr_umsetzung> TYPE STANDARD TABLE,
        <lv_posnr> TYPE posnr.

  IMPORT rrd_head = ls_rrd_head
         rrd_item = lt_rrd_item
         FROM MEMORY ID 'RRD_COPY_MEMORY'.

  IF gr_msr_sales IS NOT BOUND OR
     ls_rrd_head IS INITIAL.
    CLEAR ls_rrd_head.
    CLEAR lt_rrd_item[].
    EXPORT rrd_head = ls_rrd_head
           rrd_item = lt_rrd_item
           TO MEMORY ID 'RRD_COPY_MEMORY'.
    RETURN.
  ENDIF.

  IF vbak-auart IS INITIAL.
    vbak-auart = ls_rrd_head-auara.
  ENDIF.

  SORT lt_rrd_item BY posnr intpos.
  IF lt_rrd_item IS INITIAL.
    lv_no_items = charx.
  ENDIF.

  DO.

    IF lv_no_items IS INITIAL.
      CLEAR ls_rrd_item.
      READ TABLE lt_rrd_item INTO ls_rrd_item INDEX 1.
      IF sy-subrc = 0.
        DELETE lt_rrd_item INDEX 1.
      ENDIF.
    ENDIF.

    PERFORM beleg_kopieren_vorbereiten IN PROGRAM sapfv45c
                                       USING vbak-auart.

    cvbfa[] = xvbfa[].
    cvbup[] = xvbup[].

    CALL FUNCTION 'RV_DOCUMENT_COPY_NO_POPUP'
      EXPORTING
        fvak       = tvak
        fvbak      = vbak
        fvbpa      = vbpa
        i_vbeln    = ls_rrd_head-refbeln
        i_no_items = lv_no_items
      IMPORTING
        fvbak      = cvbak
        fvbuk      = cvbuk
        fvcpa      = tvcpa
        fvbrk      = cvbrk
      TABLES
        fxvbap     = cvbap
        fxvbep     = cvbep
*       fyvbfa     =
        fxvbfa     = cvbfa
        fxvbkd     = cvbkd
        fxvbpa     = cvbpa
        fxvbuk     = xvbuk
        fxvbup     = cvbup
        fxvbuv     = xvbuv
        fxfpla     = cfpla
        fxfplt     = cfplt
        fxvbsn     = cvbsn
        fxvbrp     = cvbrp.

    IF lv_no_items IS INITIAL.
      LOOP AT cvbap ASSIGNING <ls_cvbap> WHERE posnr NE ls_rrd_item-posnr.
        <ls_cvbap>-updkz = 'D'.
      ENDLOOP.
    ENDIF.

    gesperrt = charx.

    gv_msr_copy_split_id = ls_rrd_item-split_id.
    PERFORM vorlage_kopieren IN PROGRAM sapfv45c.
    CLEAR gv_msr_copy_split_id.

    IF lv_no_items IS INITIAL.
      UNASSIGN <lv_posnr>.
      ASSIGN ('(SAPFV45C)POSNR_UMSETZUNG[]') TO <lt_posnr_umsetzung>.
      IF sy-subrc = 0.
        READ TABLE <lt_posnr_umsetzung> ASSIGNING <ls_posnr_umsetzung> INDEX 1.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'NEU' OF STRUCTURE <ls_posnr_umsetzung> TO <lv_posnr>.
        ENDIF.
      ENDIF.
      IF <lv_posnr> IS ASSIGNED.
        ls_rrd_item-posnr = <lv_posnr>.
*       prepare item processing
        PERFORM xvbap_lesen_allgemein IN PROGRAM sapfv45p
                                      USING <lv_posnr>
                                            space
                                   CHANGING svbap-tabix.
        IF svbap-tabix > 0.
          IF gr_msr_sales IS NOT INITIAL.
            gr_msr_sales->set_rrd_item( is_rrd_item = ls_rrd_item ).
          ENDIF.
          PERFORM vbap_bearbeiten_vorbereiten IN PROGRAM sapfv45p.
*         set item data and msr-specific data
          IF vbap-zmeng NE ls_rrd_item-kwmeng.
            vbap-zmeng = ls_rrd_item-kwmeng.
            PERFORM vbap-zmeng_pruefen IN PROGRAM sapfv45p.
          ENDIF.

          IF vbap-zieme NE ls_rrd_item-vrkme.
            vbap-zieme = ls_rrd_item-vrkme.
            PERFORM vbap-zieme_pruefen.
          ENDIF.
          vbap-abgru = ls_rrd_item-abgru.
          vbap-msr_ret_reason = ls_rrd_item-ret_reason.
          vbap-msr_refund_code = ls_rrd_item-refund_code.
          gs_msr_sales_item-inspection_code = ls_rrd_item-inspection_code.

          lv_call_activity = call_activity.
          call_activity = gc_activity_lord.

          PERFORM msr_check_item USING space space.
          PERFORM vbap_bearbeiten IN PROGRAM sapfv45p.

          call_activity = lv_call_activity.

          PERFORM vbap_bearbeiten_ende IN PROGRAM sapfv45p.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lt_rrd_item IS INITIAL.
      EXIT.
    ENDIF.

  ENDDO.

  IF gr_msr_sales IS NOT INITIAL.
    gr_msr_sales->change_head_billing_block(
      EXPORTING
        is_vbak                 = vbak
        it_xvbap                = xvbap[]
        iv_trtyp                = t180-trtyp
      CHANGING
        cv_header_billing_block = vbak-faksk ).
  ENDIF.

  CLEAR ls_rrd_head.
  REFRESH lt_rrd_item.
  EXPORT rrd_head = ls_rrd_head
         rrd_item = lt_rrd_item
         TO MEMORY ID 'RRD_COPY_MEMORY'.

ENDFORM.                    "msr_copy_data