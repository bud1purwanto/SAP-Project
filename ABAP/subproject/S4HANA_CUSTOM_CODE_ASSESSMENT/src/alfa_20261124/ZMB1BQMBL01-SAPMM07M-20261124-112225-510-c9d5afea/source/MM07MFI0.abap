*---------------------------------------------------------------------*
*       FORM I-SEGMENTE_BUCHEN                                        *
*---------------------------------------------------------------------*
*       Die Tabelle ZIKPF wird abgearbeitet. Entsprechend der         *
*       Anzahl Einträge wird die Verbuchung aufgerufen. Dabei werden  *
*       jeweils nur die passenden YISEG's und YVM07M's übergeben.     *
*---------------------------------------------------------------------*
FORM i-segmente_buchen.
  data: l_dispatch(1),                                              "DUV
        lt_xiseg type iseg occurs 0 with header line.               "DUV

  tm07i-trtyp = h.
  tm07i-xhinz = x.
  tm07i-xzael = x.
  tm07i-xdiff = x.
  CLEAR  : ziseg.
  REFRESH: ziseg.
* Moving ZIKPF to ZIKPF_S because ZIKPF within
* MB_UPDATE_INVENTORY_DOCUMENT_V is smaller!
  CLEAR LT_ZIKPF. REFRESH LT_ZIKPF.
  LOOP at ZIKPF.
    MOVE-CORRESPONDING ZIKPF TO LT_ZIKPF.
    APPEND LT_ZIKPF.
  ENDLOOP.
  LOOP AT zikpf.
    CLEAR  : xiseg, xvm07i, xikpf, xcm07i, ycm07i.
    REFRESH: xiseg, xvm07i, xikpf, xcm07i, ycm07i.
    MOVE-CORRESPONDING zikpf TO xikpf.
    APPEND xikpf.
    CLEAR index_l.
    LOOP AT yiseg WHERE iblnr = xikpf-iblnr.
      index_l = index_l + 1.
      MOVE-CORRESPONDING yiseg TO xiseg.
      READ TABLE yvm07i WITH KEY zeilv = yiseg-zeili.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE a001 WITH 'YVM07I' yiseg-zeili.
      ENDIF.
      MOVE-CORRESPONDING yvm07i TO xvm07i.
      xiseg-zeili = xvm07i-zeilv = index_l.
*     check if dispatch is active                                   "DUV
      if not xiseg-xdispatch is initial.                            "DUV
        l_dispatch = x.                                             "DUV
      endif.                                                        "DUV
      APPEND xiseg.
      APPEND xvm07i.
      CLEAR ycm07i.
      MOVE-CORRESPONDING xiseg TO ycm07i.
      MOVE-CORRESPONDING xvm07i TO ycm07i.
      APPEND ycm07i.
    ENDLOOP.
    MOVE-CORRESPONDING xikpf TO ikpf.
    PERFORM i-segmente_chargen.

*   Dispatch of inventory difference: Create ML-document            "DUV
*   Only necessary for pos. posted with MI07/MI09/MI10              "DUV
    if not l_dispatch is initial.                                   "DUV
      CALL FUNCTION 'RH_FUNCTION_EXIST'                             "DUV
        EXPORTING                                                   "DUV
          name                  = 'CKMLDUVMAT_CREATE_RAW_DOCUMENT'  "DUV
        EXCEPTIONS                                                  "DUV
          FUNCTION_NOT_FOUND       = 1                              "DUV
          OTHERS                   = 2.                             "DUV
      IF sy-subrc = 0.                                              "DUV
        lt_xiseg[] = xiseg[].                                       "DUV
        CALL FUNCTION 'CKMLDUVMAT_CREATE_RAW_DOCUMENT'              "DUV
          TABLES                                                    "DUV
            it_iseg       = lt_xiseg                                "DUV
          EXCEPTIONS                                                "DUV
            ERROR         = 1                                       "DUV
            OTHERS        = 2.                                      "DUV
        IF sy-subrc <> 0.                                           "DUV
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO         "DUV
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.         "DUV
        ENDIF.                                                      "DUV
      ENDIF.                                                        "DUV
    ENDIF.                                                          "DUV
    CALL FUNCTION 'MB_UPDATE_INVENTORY_DOCUMENT_V' IN UPDATE TASK
         EXPORTING
              l_tm07i       = tm07i
         TABLES
              xcm07i        = xcm07i
              xikpf         = xikpf
              xiseg         = xiseg
              xvm07i        = xvm07i
              zikpf         = lt_zikpf
              ziseg         = ziseg
              XMARV   = XMARV
         EXCEPTIONS
              error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.

ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM I-SEGMENTE_ERGAENZEN                                     *
*---------------------------------------------------------------------*
*       Die Segmente des Inventurbelegs werden ergaenzt.              *
*---------------------------------------------------------------------*
FORM i-segmente_ergaenzen.

  DESCRIBE TABLE yiseg LINES index_l.
  CHECK NOT index_l IS INITIAL.
* Lesen der für diesen Benutzer zugelassenen Inventurtoleranz
  CLEAR: xtolmerke,
         xtoleranz,
         maxbt.
  SELECT SINGLE * FROM t043 WHERE usnam = sy-uname.
  IF NOT sy-subrc IS INITIAL.          "dummy-user
    SELECT SINGLE * FROM t043 WHERE usnam = '*'.
  ENDIF.
  IF sy-subrc IS INITIAL AND NOT t043-invpr IS INITIAL.
    SELECT SINGLE * FROM t043i WHERE bukrs = t001-bukrs
                                 AND invpr = t043-invpr.
    IF sy-subrc EQ 0.
      xtolmerke = x.
    ENDIF.
  ENDIF.
  SORT yiseg BY gjahr werks lgort sobkz zeili.
  DATA: BEGIN OF inv_old,
          gjahr LIKE ikpf-gjahr,
          werks LIKE ikpf-werks,
          lgort LIKE ikpf-lgort,
          sobkz LIKE ikpf-sobkz,
        END OF inv_old.
  DATA: BEGIN OF inv_new,
          gjahr LIKE ikpf-gjahr,
          werks LIKE ikpf-werks,
          lgort LIKE ikpf-lgort,
          sobkz LIKE ikpf-sobkz,
        END OF inv_new.
  DATA: iblnr LIKE ikpf-iblnr. CLEAR iblnr.
  CLEAR index_l.
  LOOP AT yiseg.
    IF NOT xtolmerke IS INITIAL.
      maxbt = maxbt + yiseg-dmbtr.
      IF yiseg-dmbtr > t043i-maxeb.
        xtoleranz = xtoleranz + 1.
      ENDIF.
    ENDIF.
    index_l = index_l + 1.
    MOVE-CORRESPONDING yiseg TO inv_new.
    READ TABLE yvm07i INDEX sy-tabix.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'YVM07I' sy-tabix.
    ENDIF.
    IF inv_new NE inv_old OR index_l > maxibuz.
      IF index_l > maxibuz.
        CLEAR index_l.
      ENDIF.
      CALL FUNCTION 'NUMBER_GET_NEXT'
           EXPORTING
                nr_range_nr = yvm07i-numkr
                object      = 'MATBELEG'
                toyear      = yiseg-gjahr
           IMPORTING
                number      = iblnr
                returncode  = vw.
      MOVE-CORRESPONDING yvm07i  TO zikpf.
      MOVE-CORRESPONDING yiseg   TO zikpf.
      MOVE-CORRESPONDING inv_new TO zikpf.
      zikpf-iblnr = iblnr.
      zikpf-budat = mkpf-budat.
      zikpf-bldat = mkpf-bldat.
      zikpf-usnam = sy-uname.
      zikpf-zstat = x.
      zikpf-dstat = x.
      APPEND zikpf.
    ENDIF.
    yiseg-iblnr = iblnr.
    MODIFY yiseg.
    yibuz-zeili = index_l.
    yibuz-zeile = yiseg-zeile.
    APPEND yibuz.
    MOVE-CORRESPONDING yiseg TO inv_old.
  ENDLOOP.
  IF NOT xtolmerke IS INITIAL.
    IF maxbt > t043i-maxbt.
      MESSAGE e777 WITH t043i-maxbt t001-waers.
    ENDIF.
    IF NOT xtoleranz IS INITIAL.
      DESCRIBE TABLE yiseg LINES index_i.
      IF xtoleranz = index_i.
*     Differenzbetrag ist zu hoch
        MESSAGE e776 .
      ELSE.
*     Differenzbetrag einiger Positionen ist zu hoch
        MESSAGE e778 .
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM I-SEGMENT_GENERIEREN                                     *
*---------------------------------------------------------------------*
*       Die Segmente des Inventurbelegs werden generiert.             *
*       Nur, wenn über MB11 Inventurbeleg direkt mitgebucht wird.     *
*       D. h. in T159L ist VGART für Inventurbeleg gesetzt.           *
*---------------------------------------------------------------------*
FORM i-segment_generieren.

  CHECK inventur IS INITIAL.
  CHECK NOT xvm07m-vgart IS INITIAL AND NOT xvm07m-xinvb IS INITIAL.
  CHECK NOT xmseg-xauto = l.
  IF NOT mbval IS INITIAL.
    MESSAGE e324.
  ENDIF.
  CLEAR t003m.
  IF NOT xvm07m-vgart = t003m-vgart.
    SELECT SINGLE * FROM t003m WHERE vgart = xvm07m-vgart.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH '003M' xvm07m-vgart.
    ENDIF.
    CALL FUNCTION 'NUMBER_GET_INFO'
         EXPORTING
              nr_range_nr        = t003m-numkr
              object             = 'MATBELEG'
              toyear             = mkpf-mjahr
         EXCEPTIONS
              interval_not_found = 1.
    IF sy-subrc = 1.
      MESSAGE e562 WITH t003m-vgart mkpf-mjahr.
    ENDIF.
  ENDIF.
  CLEAR: yiseg,
         yvm07i.
  index_l   = index_l + 1.
  index_inv = index_inv + 1.
  yiseg-zeili  = index_inv.
  yvm07i-monat = zvm07m-monat.
  yvm07i-numkr = t003m-numkr.
  MOVE-CORRESPONDING xmseg  TO yiseg.
  MOVE-CORRESPONDING xvm07m TO yvm07i.
  yvm07i-zeilv = index_inv.
  DATA kzcha. CLEAR kzcha.
  IF NOT xmseg-charg IS INITIAL.
    kzcha = x.
  ENDIF.
  PERFORM bestandsfelder_pruefen USING xvm07m-xiupd
                                       xmseg-sobkz
                                       kzcha
                                       xmseg-xruem
                                       xmseg-xruej.
  MOVE-CORRESPONDING t150f TO yvm07i.
* Dispatch of inventory differences: 711-718 (Read Customizing)     "DUV
  CLEAR: tm07i-duv_active, tm07i-duv_default, tm07i-duv_binding.    "DUV
  CALL FUNCTION 'RH_FUNCTION_EXIST'                                 "DUV
    EXPORTING                                                       "DUV
      name                     = 'CKMLDUVMAT_READ_CUSTOMIZING'      "DUV
    EXCEPTIONS                                                      "DUV
      FUNCTION_NOT_FOUND       = 1                                  "DUV
      OTHERS                   = 2.                                 "DUV
  IF sy-subrc = 0.                                                  "DUV
    CALL FUNCTION 'CKMLDUVMAT_READ_CUSTOMIZING'                     "DUV
      EXPORTING                                                     "DUV
        i_werks = yiseg-werks                                       "DUV
        i_lgort = yiseg-lgort                                       "DUV
        i_sobkz = yiseg-sobkz
        "DUV
      IMPORTING                                                     "DUV
        e_acti  = tm07i-duv_active                                  "DUV
        e_defa  = tm07i-duv_default                                 "DUV
        e_verb  = tm07i-duv_binding                                 "DUV
      EXCEPTIONS                                                    "DUV
        NOT_CUSTOMIZED           = 1                                "DUV
        PLANT_INITIAL            = 2                                "DUV
        STORAGE_LOCATION_INITIAL = 3.                               "DUV
  ENDIF.                                                            "DUV
  IF tm07i-duv_active = x and tm07i-duv_default = 1.                "DUV
    yiseg-xdispatch = x.                                            "DUV
  ENDIF.                                                            "DUV
  yiseg-usnam = sy-uname.
  yiseg-usnaz = sy-uname.
  yiseg-usnad = sy-uname.
  yiseg-aedat = sy-datum.
  yiseg-zldat = mkpf-budat.
  yiseg-budat = mkpf-budat.
  yiseg-xzael = x.
  yiseg-xdiff = x.
  yiseg-bstar = t150f-bstar.
  APPEND yiseg.
  APPEND yvm07i.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Module  IMPORT  INPUT
*&---------------------------------------------------------------------*
*       Importdaten beim Wareneingang
*----------------------------------------------------------------------*
MODULE import INPUT.

  DATA: complete, dataloss, imp_lifnr LIKE mseg-emlif.
*  if not t156n-xstor eq 2.                                 note 851758
    PERFORM import.
    SET PF-STATUS pfsta.
*  endif.                                                   note 851758

ENDMODULE.                             " IMPORT  INPUT


*&---------------------------------------------------------------------*
*&      Form  IMPORT
*&---------------------------------------------------------------------*
*       Importdaten beim Wareneingang
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM import.
* everything has been done in MIGO => nothing to do here
  CHECK xmigo IS INITIAL.
  IF vm07m-pstyp = '3' AND "subcontracting case    begin of note 851758
     aktyp = 'H'.                                         "note 1492658
    IF mkpf-exnum IS INITIAL.
      CALL FUNCTION 'IMPORT_GOODS_RECEIPT_GENERAL'
           EXPORTING
                i_mode                  = t158-trtyp
                i_company_data          = t001
                i_plant_data            = t001w
                i_no_process            = xmbwl
           IMPORTING
                e_import_vendor         = imp_lifnr
                e_purchase_order_header = ekko
           CHANGING
                goods_receipt_header    = mkpf
                goods_receipt_line_item = omseg.
    ENDIF.
    CALL FUNCTION 'IMPORT_GOODS_RECEIPT_LINE_ITEM'
         EXPORTING
              i_mode                    = t158-trtyp
*              i_company_code_data       = t001
              i_plant_data              = t001w
              i_import_vendor           = imp_lifnr
              i_purchase_order_header   = ekko
              i_goods_receipt_header    = mkpf
              i_goods_receipt_line_item = omseg
              i_no_process              = xmbwl.
  ELSE. "                                            end of note 851758
    IF mkpf-exnum IS INITIAL.
      CALL FUNCTION 'IMPORT_GOODS_RECEIPT_GENERAL'
           EXPORTING
                i_mode                  = t158-trtyp
                i_company_data          = t001
                i_plant_data            = t001w
                i_no_process            = xmbwl
           IMPORTING
                e_import_vendor         = imp_lifnr
                e_purchase_order_header = ekko
           CHANGING
                goods_receipt_header    = mkpf
                goods_receipt_line_item = mseg.
    ENDIF.
    CALL FUNCTION 'IMPORT_GOODS_RECEIPT_LINE_ITEM'
         EXPORTING
              i_mode                    = t158-trtyp
*              i_company_code_data       = t001
              i_plant_data              = t001w
              i_import_vendor           = imp_lifnr
              i_purchase_order_header   = ekko
              i_goods_receipt_header    = mkpf
              i_goods_receipt_line_item = mseg
              i_no_process              = xmbwl.
  ENDIF.                                                         "851758

ENDFORM.                               " IMPORT