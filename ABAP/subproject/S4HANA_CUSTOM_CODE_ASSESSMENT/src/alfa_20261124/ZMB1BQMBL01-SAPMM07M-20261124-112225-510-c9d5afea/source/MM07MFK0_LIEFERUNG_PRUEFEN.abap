*&---------------------------------------------------------------------*
*&  Include           MM07MFK0_LIEFERSCHEIN_PRUEFEN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LIEFERSCHEIN_PRUEFEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lieferung_pruefen USING vbeln TYPE vbeln
                             vbelp TYPE vbelp.

  IF cl_ops_switch_check=>mm_sfws_sit( ) IS INITIAL.
    RETURN.
  ENDIF.
  IF vbeln IS NOT INITIAL AND VBELP IS INITIAL.
    PERFORM no_input(sapfm07m) USING 'RM07M' 'VBELP'.
  ENDIF.
  DATA: ls_imseg      TYPE imseg,
        ls_lips       TYPE lips,
        ls_dfies      TYPE dfies,
        lt_deliveries TYPE leshp_delivery_t,
        ls_delivery   TYPE leshp_delivery_s,
        lt_del_items  TYPE leshp_delivery_item_t,
        ls_del_item   TYPE lipsvb,
        ls_data       TYPE leshp_data,
        ls_ekpo       TYPE ekpo,
        lv_bustr      TYPE bustr.

  TABLES maepv.

  IF fcausw-xlist IS INITIAL.

    ls_data-item = abap_true.

    CALL FUNCTION 'LE_DELIVERY_GET_BUFFERED'
      EXPORTING
        if_vbeln               = vbeln
        is_data                = ls_data
      CHANGING
        cx_deliveries          = lt_deliveries
      EXCEPTIONS
        no_item_selected       = 1
        selected_item_enqueued = 2
        no_key_specified       = 3
        OTHERS                 = 4.

    IF sy-subrc <> 0.
* Delivery does not exist
      MESSAGE e302(vl) WITH vbeln.
      EXIT.
    ENDIF.

    LOOP AT lt_deliveries INTO ls_delivery.

* No further processing for shipping notification
      IF ls_delivery-head-vbtyp = '7' AND t156-bustr <> '559'.  "1583699
        RETURN.
      ENDIF.

      READ TABLE ls_delivery-item INTO ls_del_item WITH KEY posnr = vbelp.

      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_del_item TO ls_lips.

* Wrong GR from receiving SIT into receiving plant (Instead of 109/169)
        IF ( t156-bustr = '101' OR t156-bustr = '161' OR
             t156-bustr = '107' OR t156-bustr = '167') AND
           ( xbapi = abap_true OR xmigo = abap_true ).
          SELECT SINGLE bustr FROM t156 INTO lv_bustr
                                        WHERE bwart = ls_lips-bwart.
          IF sy-subrc = 0.
            IF lv_bustr = '681' OR lv_bustr = '683' OR
               lv_bustr = '691' OR lv_bustr = '693' OR
               lv_bustr = '68A' OR lv_bustr = '68C' OR
               lv_bustr = '69A' OR lv_bustr = '69C'.
* Movement type & is not allowed
              MESSAGE e096(m7) WITH t156-bwart.
            ENDIF.
          ENDIF.
          RETURN.
* No further processing, for receiving SIT side no changes necessary
        ELSEIF NOT ( ( t156-bustr = '601' AND mseg-sobkz = 'T' ) OR
                       t156-bustr = '681' OR t156-bustr = '683' OR
                       t156-bustr = '68A' OR t156-bustr = '68C' OR
                       t156-bustr = '68E' OR t156-bustr = '68I' OR
                       t156-bustr = '685' OR t156-bustr = '687' OR
                       t156-bustr = '691' OR t156-bustr = '693' OR
                       t156-bustr = '695' OR t156-bustr = '69A' OR
                       t156-bustr = '69C' OR t156-bustr = '69E' OR
                       t156-bustr = '69I' OR t156-bustr = '417' OR
                       t156-bustr = '559' OR t156-bustr = '169' OR
                       t156-bustr = '335' ).
          RETURN.
* Check the valuation stock for special stock
        ELSEIF ( ls_lips-sobkz = 'E' OR ls_lips-sobkz = 'Q' ) AND
               ls_lips-kzbws IS INITIAL.
* Combination special stock indicator & valuation & is not possible
          MESSAGE e240(m7) WITH ls_lips-sobkz ls_lips-kzbws.
        ENDIF.
        IF ls_lips-kzbws <> 'M' AND ls_delivery-head-vbtyp <> '7'.
*         Valuation control in material master and special stock
*         differs. Not necessary for inbound deliveries: note 1619279
          MESSAGE e242(m7).
        ENDIF.

* Lines deleted: Note 1530929
* GI out of issuing SIT - Sales Order scenario
        IF t156-bustr = '601' AND mseg-sobkz = 'T'.

          mseg-mat_kdauf = ls_lips-vbeln.
          mseg-mat_kdpos = ls_lips-posnr.

          mseg-kzbws = ls_lips-kzbws.

          APPEND ls_lips to x_lips.                         "1660570

* GI from issuing plant into issuing SIT
        ELSEIF t156-bustr = '681' OR t156-bustr = '691'.
          mseg-umsok = 'T'.

          mseg-kdauf = ls_lips-vbeln.
          mseg-kdpos = ls_lips-posnr.

          dm07m-umkzbws = ls_lips-kzbws.
          dm07m-setkzbws = x.

* GI from issuing plant into issuing SIT (Intracompany)
        ELSEIF t156-bustr = '68A' OR t156-bustr = '69A'.
          mseg-umsok = 'T'.

          mseg-kdauf = ls_lips-vbeln.
          mseg-kdpos = ls_lips-posnr.
          CLEAR: dm07m-umbar_po.
          msegk-pprctr = mseg-prctr.
          mseg-pprctr = mseg-prctr.
          mseg-bwtar = ls_lips-bwtar.
          mseg-charg = ls_lips-charg.

          dm07m-umkzbws = ls_lips-kzbws.
          dm07m-setkzbws = x.

          mseg-umwrk = mseg-werks.
* The batch and the valuation type have to be equal (Intracompany)
          mseg-umcha = mseg-charg.
          mseg-umbar = mseg-bwtar.
* GI from issuing plant into receiving SIT
        ELSEIF t156-bustr = '683' OR t156-bustr = '693'.        "1614311
          IF dm07m-gwebb IS INITIAL AND xebefu-gwebb IS NOT INITIAL.
            dm07m-gwebb = xebefu-gwebb.
          ENDIF.

* GI from issuing plant into receiving SIT
        ELSEIF t156-bustr = '68C' OR t156-bustr = '69C'.
* The batch and the valuation type have to be equal (Intracompany)
          IF mseg-umcha IS INITIAL.
            mseg-umcha = mseg-charg.
          ENDIF.
          IF mseg-umbar IS INITIAL.
            mseg-umbar = mseg-bwtar.
          ENDIF.
* GI from issuing SIT into receiving SIT/plant
        ELSEIF t156-bustr = '685' OR t156-bustr = '695'.

          mseg-sobkz = 'T'.

          msegk-mat_kdauf = ls_lips-vbeln.
          msegk-mat_kdpos = ls_lips-posnr.

          mseg-kzbws = ls_lips-kzbws.
*         removed 1638661                                     "1657162

* GI from issuing SIT into receiving SIT
        ELSEIF t156-bustr = '68E' OR t156-bustr = '69E'.
          mseg-sobkz = 'T'.

          msegk-mat_kdauf = ls_lips-vbeln.
          msegk-mat_kdpos = ls_lips-posnr.
          mseg-mat_kdauf = ls_lips-vbeln.
          mseg-mat_kdpos = ls_lips-posnr.

          mseg-kzbws = ls_lips-kzbws.
          mseg-umbar = fuss-umbar_po.
          IF mseg-umcha IS INITIAL.
            mseg-umcha = mseg-charg.
          ENDIF.
          IF mseg-umcha IS INITIAL AND mseg-umbar IS NOT INITIAL.
            mseg-umcha = mseg-umbar.
          ENDIF.
* GI from issuing SIT into receiving plant
        ELSEIF t156-bustr = '68I' OR t156-bustr = '69I'.

          mseg-sobkz = 'T'.

          msegk-mat_kdauf = ls_lips-vbeln.
          msegk-mat_kdpos = ls_lips-posnr.
          mseg-mat_kdauf = ls_lips-vbeln.
          mseg-mat_kdpos = ls_lips-posnr.

          mseg-kzbws = ls_lips-kzbws.

          CALL FUNCTION 'ME_EKPO_SINGLE_READ'
            EXPORTING
              pi_ebeln                  = mseg-ebeln
              pi_ebelp                  = mseg-ebelp
            IMPORTING
              PO_EKPO                   = ls_ekpo
            EXCEPTIONS
              NO_RECORDS_FOUND          = 1
              OTHERS                    = 2.

          IF sy-subrc = 0.
* Storage location mus tbe entered in the PO
            IF ls_ekpo-lgort IS INITIAL.
* Enter storage location in the PO
              MESSAGE e471(m7) WITH ls_ekpo-ebeln ls_ekpo-ebelp.
              RETURN.
            ENDIF.
            mseg-umlgo = ls_ekpo-lgort.
          ENDIF.

          IF mseg-umcha IS INITIAL.
            mseg-umcha = mseg-charg.
          ENDIF.
          IF mseg-umbar IS INITIAL.
            mseg-umbar = mseg-bwtar.
          ENDIF.
* GI from issuing plant into issuing SIT - Sales Order scenario
        ELSEIF t156-bustr = '687'.

          mseg-umsok = 'T'.

          mseg-kdauf = ls_lips-vbeln.
          mseg-kdpos = ls_lips-posnr.

          dm07m-umkzbws = ls_lips-kzbws.
          dm07m-setkzbws = x.
          CLEAR mseg-kzvbr.                                     "1610260

* Transfer posting from issuing SIT
        ELSEIF t156-bustr = '417'.

          mseg-kdauf = ls_lips-vbeln.
          mseg-kdpos = ls_lips-posnr.

          dm07m-umkzbws = ls_lips-kzbws.
          dm07m-setkzbws = x.

* Scrapping from issuing SIT
        ELSEIF t156-bustr = '335'.
          IF mseg-sobkz IS INITIAL.
            PERFORM no_input(sapfm07m) USING 'RM07M' 'SOBKZ'.
          ELSEIF mseg-sobkz <> 'T'.
            PERFORM WRONG_INPUT(SAPFM07M) USING 'RM07M' 'SOBKZ' mseg-sobkz E.
          ENDIF.
          mseg-mat_kdauf = ls_lips-vbeln.
          mseg-mat_kdpos = ls_lips-posnr.

          mseg-kzbws = ls_lips-kzbws.

        ELSEIF t156-bustr = '559'.
          CASE ls_lips-sobkz.
            WHEN e.
              mseg-sobkz = ls_lips-sobkz.
              mseg-kzbws = ls_lips-kzbws.
              mseg-mat_kdauf = ls_lips-kdauf.
              mseg-mat_kdpos = ls_lips-kdpos.
            WHEN q.
              mseg-sobkz = ls_lips-sobkz.
              mseg-kzbws = ls_lips-kzbws.
              IF ls_lips-ps_psp_pnr IS NOT INITIAL.             "1583699
                mseg-mat_pspnr = ls_lips-ps_psp_pnr.
              ELSE.
                mseg-mat_pspnr = ls_lips-pspnr.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.

        ENDIF.
      ELSEIF ls_del_item-sitkz IS INITIAL.
        PERFORM WRONG_INPUT(SAPFM07M) USING 'RM07M' 'VBELP' VBELP E.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " LIEFERSCHEIN_PRUEFEN