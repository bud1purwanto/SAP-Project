*----------------------------------------------------------------------*
*   INCLUDE MV50ABUFF                                                  *
*----------------------------------------------------------------------*

FORM   lock_and_fill_buffer.

* Header ---------------------------------------------------------------
  DATA:      lf_vgtyp           TYPE vbtyp.
  DATA:      lf_ordernumber(10) TYPE c.
  DATA:      lf_user            TYPE symsgv.                "n_557750
  CONSTANTS: lc_sto_tra_order   TYPE vbtyp VALUE charv.

  STATICS:   ls_order_view      TYPE order_view VALUE IS INITIAL.
  DATA:      ls_key_to_lock     TYPE shp_vl10_package.
  DATA:      ls_ekko            TYPE ekko.

  DATA:      lt_ekpo_key        TYPE ekpo_key  OCCURS 0
                                               WITH HEADER LINE.
  DATA:      lt_sales_key       TYPE sales_key OCCURS 0
                                               WITH HEADER LINE.
  DATA:      lt_key_to_lock     TYPE shp_vl10_package_t.
  DATA:      lt_key_unlockable  TYPE shp_vl10_package_t.
  DATA:      l_posar            LIKE lips-posar.            "n_620726

  FIELD-SYMBOLS: <ls_xlips>     TYPE lipsvb.
  FIELD-SYMBOLS: <ls_key>       TYPE shp_vl10_package.

* Body -----------------------------------------------------------------
* Init -----------------------------------------------------------------
  REFRESH lt_ekpo_key.
  REFRESH lt_sales_key.
  REFRESH lt_key_to_lock.
  REFRESH lt_key_unlockable.
  l_posar = 'B'.                                            "n_620726

* Fill the internal tables for buffering and locking -------------------
  LOOP AT xlips ASSIGNING <ls_xlips>.
* No predecessor?
    CHECK <ls_xlips>-vgsys IS INITIAL.                " AIP
    IF ( <ls_xlips>-vgbel IS INITIAL AND <ls_xlips>-vgtyp IS INITIAL )
    OR   <ls_xlips>-vgpos IS INITIAL.
      CONTINUE.
    ENDIF.
    IF <ls_xlips>-vgbel IS INITIAL.
      CONTINUE.
    ENDIF.
* Predecessor is stock_transfer_order?
* Stock transfer order and customer order are not mixed in one delivery
    IF <ls_xlips>-vgtyp EQ charv AND likp-verursys IS INITIAL.
      lf_vgtyp = lc_sto_tra_order.
    ELSE.
      CLEAR lf_vgtyp.
    ENDIF.
* Fill input for buffering
    IF lf_vgtyp = lc_sto_tra_order.
      IF l_posar = 'B' AND <ls_xlips>-posar <> 'B'.         "v_n_620726
        CLEAR l_posar.
      ENDIF.                                                "^_n_620726
      lt_ekpo_key-ebeln  = <ls_xlips>-vgbel.
      lt_ekpo_key-ebelp  = <ls_xlips>-vgpos.
      COLLECT lt_ekpo_key.
    ELSE.
      lt_sales_key-vbeln = <ls_xlips>-vgbel.
      COLLECT lt_sales_key.
    ENDIF.
* Fill input for locking
*   if not ( v50agl-kommirueckmeldung = 'X'                   "n_1012854
*            and v50agl-synchron = ' ' ) .
      IF nicht_sperren <> chary.
        CHECK t180-trtyp <> chara.
        ls_key_to_lock-vbtyp = <ls_xlips>-vgtyp.
        ls_key_to_lock-vbeln = <ls_xlips>-vgbel.
        APPEND ls_key_to_lock TO lt_key_to_lock.
      ENDIF.
*   endif.                                                    "n_1012854
  ENDLOOP.

* Lock -----------------------------------------------------------------
  IF NOT lt_key_to_lock[] IS INITIAL.
* Prepare lock input
    SORT lt_key_to_lock.
    DELETE ADJACENT DUPLICATES FROM lt_key_to_lock.
* Lock
    CALL FUNCTION 'SHP_SD_ORDER_ENQUEUE'
      CHANGING
        ct_key_try    = lt_key_to_lock
        ct_key_failed = lt_key_unlockable
      EXCEPTIONS
        OTHERS        = 1.
* Lock not ok
    IF NOT lt_key_unlockable[] IS INITIAL.
      LOOP AT lt_key_unlockable ASSIGNING <ls_key>.
        WRITE <ls_key>-vbeln TO lf_ordernumber NO-ZERO.
        WRITE sy-msgv1       TO lf_user.
        IF lf_vgtyp = lc_sto_tra_order.
          MESSAGE e247 WITH lf_ordernumber lf_user.
        ELSE.
          MESSAGE e045 WITH lf_ordernumber lf_user.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

* Refresh buffer and fill, if necessary --------------------------------
  IF  lt_ekpo_key[]  IS INITIAL
  AND lt_sales_key[] IS INITIAL.
    EXIT.
  ENDIF.

  IF lf_vgtyp = lc_sto_tra_order.
* Refresh and prefetch stock transfer order items
    CALL FUNCTION 'ME_EKPO_ARRAY_READ'
         EXPORTING
*             PI_BYPASSING_BUFFER =
              pi_refresh_buffer   = charx
         TABLES
              pti_ekpo_key        = lt_ekpo_key
*             PTO_EKPO            =
         EXCEPTIONS
              no_records_found    = 1
              error_message       = 2
              OTHERS              = 3
         .

*   SPE INB RG 17.05.2004 HOLD Status in item level
    BREAK-POINT ID /spe/inb_hold.
*   Dont check the existenc of the PO/SA for the hold delivery.
    IF NOT ( xvbuk-hdall IS INITIAL ) OR
       NOT ( xvbuk-hdals IS INITIAL ).  "N: 926859
      EXIT.
    ENDIF.

    IF sy-subrc <> 0.
      READ TABLE lt_ekpo_key INDEX 1.
      IF t180-trtyp EQ chara.
        MESSAGE i650 WITH lt_ekpo_key-ebeln lt_ekpo_key-ebelp .
      ELSE.
        MESSAGE a650 WITH lt_ekpo_key-ebeln lt_ekpo_key-ebelp .
      ENDIF.
    ENDIF.

    IF likp-vbtyp CA vbtyp_mmli.
      CALL FUNCTION 'ME_EKKO_SINGLE_READ'
        EXPORTING
          pi_ebeln         = lt_ekpo_key-ebeln                 "n_890195
        IMPORTING
          po_ekko          = ls_ekko
        EXCEPTIONS
          no_records_found = 1
          OTHERS           = 2.
    ENDIF.

ENHANCEMENT-SECTION     MV50ABUFF_01 SPOTS ES_SAPMV50A.
    IF likp-vbtyp NA vbtyp_mmli OR
       ls_ekko-bstyp NE 'L'.
      IF l_posar <> 'B'.                                    "n_620726
* Refresh stock transfer orders schedules
        CALL FUNCTION 'ME_EKET_ARRAY_READ_ITEM'
          EXPORTING
            pi_refresh_buffer        = charx
          TABLES
            pti_eket_keytab          = lt_ekpo_key
          EXCEPTIONS
            err_no_records_requested = 1
            err_no_records_found     = 2
            error_message            = 3
            OTHERS                   = 4.
        IF sy-subrc <> 0.
          MESSAGE x572 .
*       Unerwartete Ausnahme
        ENDIF.

* Prefetech stock transfer order schedules
        CALL FUNCTION 'ME_EKET_ARRAY_READ_ITEM'
          TABLES
            pti_eket_keytab          = lt_ekpo_key
          EXCEPTIONS
            err_no_records_requested = 1
            err_no_records_found     = 2
            error_message            = 3
            OTHERS                   = 4.
        IF sy-subrc > 1.
          READ TABLE lt_ekpo_key INDEX 1.
          IF t180-trtyp EQ chara.
            MESSAGE i650 WITH lt_ekpo_key-ebeln lt_ekpo_key-ebelp .
          ELSE.
            MESSAGE a650 WITH lt_ekpo_key-ebeln lt_ekpo_key-ebelp .
          ENDIF.
        ENDIF.
      ENDIF.                                                "n_620726
    ENDIF.
END-ENHANCEMENT-SECTION.
  ELSE.
* Refresh customer orders
    CALL FUNCTION 'SD_BUFFER_TABLES_REFRESH'.
* Specify what you want
    IF ls_order_view IS INITIAL.
      ls_order_view-header   = charx.
      ls_order_view-item     = charx.
      ls_order_view-sdschedule = charx.
      ls_order_view-status_h = charx.
      ls_order_view-status_i = charx.
*     LS_ORDER_VIEW-FLOW     = CHARX.
    ENDIF.
* Prefetch customer orders
    CALL FUNCTION 'SD_SALES_DOCUMENT_PREFETCH'
         EXPORTING
              i_sales_view  = ls_order_view
              i_memory_read = chara
*             I_PRINT_MODE  = ' '
         TABLES
              i_vbak_keytab = lt_sales_key
*             FXVBAK        =
*             FXVBAP        =
*             FXVBEP        =
*             FXVBKD        =
*             FXVBPA        =
*             FXSADR        =
*             FXVBUK        =
*             FXVBUP        =
*             FXKOMV        =
*             FXKONH        =
*             FXKONP        =
*             FXKONM        =
*             FXKONW        =
*             FXVEDA        =
*             FXTHEAD       =
*             FXTLINE       =
*             FXVBFA        =
*             FCUREF        =
*             FCUCFG        =
*             FCUINS        =
*             FCUPRT        =
*             FCUVAL        =
*             FCUBLB        =
*             FCUVK         =
*             FXFPLA        =
*             FXFPLT        =
*             FXVBUV        =
              .
  ENDIF.
ENDFORM.                    "LOCK_AND_FILL_BUFFER

*---------------------------------------------------------------------*
*       FORM VBAK_SELECT_BUFFER                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(VS_MANDT)                                               *
*  -->  VALUE(VS_VBELN)                                               *
*---------------------------------------------------------------------*
FORM vbak_select_buffer  USING value(vs_mandt) LIKE sy-mandt
                         value(vs_vbeln)       LIKE vbak-vbeln.

  CALL FUNCTION 'SD_VBAK_SINGLE_READ'
       EXPORTING
            i_vbeln            = vs_vbeln
*           I_BYPASSING_BUFFER = ' '
*           I_REFRESH_BUFFER   =
       IMPORTING
            e_vbak             = vbak
       EXCEPTIONS
            record_not_found   = 1
            error_message      = 2
            OTHERS             = 3
            .

  IF sy-subrc > 0 .
    PERFORM auftrag_entsperren USING vs_vbeln.
    IF t180-trtyp EQ chara.
      IF v50agl-display_from_archive EQ space.              "v_n_574894
        MESSAGE s303(vl) WITH vs_vbeln.
      ENDIF.                                                "^_n_574894
    ELSE.
      PERFORM message_handling(sapmv50a) USING posnr_low
                                               '303'
                                               'E'
                                               'VL'
                                               vs_vbeln
                                               space
                                               space
                                               space.
    ENDIF.
  ELSE.
    cvbak = vbak.
    rv50a-vtweg = vbak-vtweg.
    rv50a-spart = vbak-spart.
  ENDIF.

ENDFORM.                    "VBAK_SELECT_BUFFER

*---------------------------------------------------------------------*
*       FORM VBUK_SELECT_BUFFER                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(VS_MANDT)                                               *
*  -->  VALUE(VS_VBELN)                                               *
*---------------------------------------------------------------------*
FORM vbuk_select_buffer USING value(vs_mandt) LIKE sy-mandt
                        value(vs_vbeln)       LIKE vbuk-vbeln.

  DATA: BEGIN OF vbukkey,
                 mandt LIKE vbuk-mandt,
                 vbeln LIKE vbuk-vbeln,
        END OF vbukkey.
  vbukkey-mandt = vs_mandt.
  vbukkey-vbeln = vs_vbeln.
  READ TABLE xvbuk WITH KEY vbukkey BINARY SEARCH.
  IF sy-subrc = 0.
    vbuk = xvbuk.
  ELSE.
    CALL FUNCTION 'SD_VBUK_SINGLE_READ'
         EXPORTING
              i_vbeln            = vs_vbeln
*             I_BYPASSING_BUFFER = ' '
*             I_REFRESH_BUFFER   =
         IMPORTING
*             E_VBUKVB           =
              e_vbuk             = vbuk
         EXCEPTIONS
              record_not_found   = 1
              error_message      = 2
              OTHERS             = 3
              .

    IF sy-subrc = 0.
      cvbuk = vbuk.
    ENDIF.
  ENDIF.

ENDFORM.                    "VBUK_SELECT_BUFFER

*---------------------------------------------------------------------*
*       FORM VBUP_SELECT_BUFFER                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(VS_MANDT)                                               *
*  -->  VALUE(VS_VBELN)                                               *
*---------------------------------------------------------------------*
FORM vbup_select_buffer  USING value(vs_mandt) LIKE sy-mandt
                         value(vs_vbeln)       LIKE vbup-vbeln.

  DATA lt_vbup TYPE vbup OCCURS 0 WITH HEADER LINE.

  REFRESH lt_vbup.

  CALL FUNCTION 'SD_VBUP_READ_WITH_VBELN'
       EXPORTING
            i_vbeln            = vs_vbeln
*           I_BYPASSING_BUFFER = ' '
*           I_REFRESH_BUFFER   =
      TABLES
*           ET_VBUPVB          =
            et_vbup            = lt_vbup
      EXCEPTIONS                                            "50A
            record_not_found   = 0
            OTHERS             = 0
            .

  APPEND LINES OF lt_vbup TO cvbup.
  SORT cvbup BY mandt vbeln posnr.

ENDFORM.                    "VBUP_SELECT_BUFFER

*---------------------------------------------------------------------*
*       FORM VBFA_SELECT_BUFFER                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(VS_MANDT)                                               *
*  -->  VALUE(VS_VBELV)                                               *
*---------------------------------------------------------------------*
FORM vbfa_select_buffer USING value(vs_mandt) LIKE sy-mandt
                              value(vs_vbelv) LIKE vbfa-vbelv.

  DATA: lt_vbfa TYPE vbfa OCCURS 0 WITH HEADER LINE.

  REFRESH lt_vbfa.

  CALL FUNCTION 'SD_VBFA_READ_WITH_VBELV'
       EXPORTING
            i_vbelv            = vs_vbelv
*           I_BYPASSING_BUFFER = ' '
*           I_REFRESH_BUFFER   =
       TABLES
*           ET_VBFAVB          =
            et_vbfa            = lt_vbfa
       EXCEPTIONS                                           "50A
            record_not_found   = 0
            OTHERS             = 0
            .

  APPEND LINES OF lt_vbfa TO  cvbfa.
  SORT cvbfa BY mandt vbelv posnv vbeln posnn vbtyp_n.

ENDFORM.                    "VBFA_SELECT_BUFFER

*---------------------------------------------------------------------*
*       FORM VBAP_SELECT_SINGLE_BUFFER                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(VS_MANDT)                                               *
*  -->  VALUE(VS_VBELN)                                               *
*  -->  VALUE(VS_ABPOS)                                               *
*---------------------------------------------------------------------*
FORM vbap_select_single_buffer  USING value(vs_mandt) LIKE sy-mandt
                                value(vs_vbeln)       LIKE vbap-vbeln
                                value(vs_abpos)       LIKE vbap-posnr.

  DATA: help_vbap LIKE vbapvb.
  DATA: lt_txvbap LIKE vbapvb OCCURS 0 WITH HEADER LINE.
  DATA: lt_tuvbap LIKE vbapu  OCCURS 0 WITH HEADER LINE.


  CLEAR:    lt_txvbap, lt_tuvbap.
  REFRESH:  lt_txvbap, lt_tuvbap.


  CLEAR cvbap.

  CALL FUNCTION 'SD_VBAP_SINGLE_READ'
       EXPORTING
            i_vbeln            = vs_vbeln
            i_posnr            = vs_abpos
*           I_BYPASSING_BUFFER = ' '
*           I_REFRESH_BUFFER   =
       IMPORTING
            e_vbap             = vbap
       EXCEPTIONS                                           "50A
            record_not_found   = 1
            OTHERS             = 2
            .
  CHECK sy-subrc EQ 0.

* keep in mind: as SD is not able or willing to fill the dynamic part
* of cvbap in FG V45i, we have do this in vbap_c_aufbauen !!
  PERFORM vbap_c_aufbauen.

* im Falle der product selection werden die abhängigen Positionen
* ebenfalls gelesen
  IF vbap-prosa = chara.
    help_vbap = cvbap.

    CALL FUNCTION 'SD_VBAP_SELECT_STRUCTURE'
         EXPORTING
              i_document_number = vs_vbeln
              i_item_number     = vs_abpos
         TABLES
              txvbap            = lt_txvbap
              tuvbap            = lt_tuvbap
*    EXCEPTIONS
*         ITEM_NOT_FOUND    = 1
*         OTHERS            = 2
              .

* same as above: fill the dynamic part of cvbap (lt_txvbap) here
    IF cvbak-vbeln NE vs_vbeln.
      READ TABLE cvbak INTO cvbak
                       WITH KEY vbeln = vs_vbeln.
    ENDIF.

    CALL FUNCTION 'SHP_FILL_DYN_PART_XVBAP'
      TABLES
        ct_vbap        = lt_txvbap
      CHANGING
        is_vbak        = cvbak
      EXCEPTIONS
        internal_error = 1
        wrong_call     = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT lt_txvbap.
      IF lt_txvbap-uepos <> vs_abpos.
        CONTINUE.
      ENDIF.

      READ TABLE xvbap WITH KEY lt_txvbap(19).
      IF sy-subrc NE 0.
        CLEAR xvbap.
        MOVE-CORRESPONDING lt_txvbap TO xvbap.
        APPEND xvbap.
      ENDIF.

      READ TABLE cvbap WITH KEY lt_txvbap(19).
      IF sy-subrc NE 0.
        cvbap = xvbap.
        APPEND cvbap.
      ENDIF.

    ENDLOOP.

    cvbap = help_vbap.
  ENDIF.

* IF vbap-prosa EQ chara.
* help_vbap = cvbap.
*   SELECT *
*          INTO vbap
*          FROM vbap
*               WHERE vbeln  = :vs_vbeln
*               AND   uepos  = :vs_abpos.
*     READ TABLE xvbap WITH KEY vbap(19).
*     IF sy-subrc NE 0.
*       CLEAR xvbap.
*       MOVE-CORRESPONDING vbap TO xvbap.
*       APPEND xvbap.
*     ENDIF.
*     READ TABLE cvbap WITH KEY vbap(19).
*     IF sy-subrc NE 0.
*       cvbap = xvbap.
*       APPEND cvbap.
*     ENDIF.
*   ENDSELECT.
*   cvbap = help_vbap.
* ENDIF.

  SORT cvbap BY vbeln posnr.

ENDFORM.                    "VBAP_SELECT_SINGLE_BUFFER

*---------------------------------------------------------------------*
*       FORM VBUP_SELECT_BUFFER                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(VS_MANDT)                                               *
*  -->  VALUE(VS_VBELN)                                               *
*---------------------------------------------------------------------*
FORM vbep_select_buffer  USING value(vs_mandt) LIKE sy-mandt
                               value(vs_vbeln) LIKE vbep-vbeln.

  DATA lt_vbep TYPE vbep OCCURS 0 WITH HEADER LINE.

  REFRESH lt_vbep.

  CALL FUNCTION 'SD_VBEP_READ_WITH_VBELN'
       EXPORTING
            i_vbeln            = vs_vbeln
*           I_BYPASSING_BUFFER = ' '
*           I_REFRESH_BUFFER   =
      TABLES
            et_vbep            = lt_vbep
      EXCEPTIONS
            record_not_found   = 0
            OTHERS             = 0
            .

  LOOP AT lt_vbep.
    MOVE-CORRESPONDING lt_vbep TO cvbep.
    APPEND cvbep.
  ENDLOOP.
  SORT cvbep BY mandt vbeln posnr etenr.

ENDFORM.                    "vbep_select_buffer