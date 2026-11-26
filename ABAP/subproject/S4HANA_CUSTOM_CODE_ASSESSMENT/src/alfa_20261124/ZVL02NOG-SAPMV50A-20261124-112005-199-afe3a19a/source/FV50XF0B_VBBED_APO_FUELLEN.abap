*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_VBBED_APO_FUELLEN                                 *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form VBBED_APO_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->text
*----------------------------------------------------------------------*
FORM VBBED_APO_FUELLEN .

  DATA: MY_EBELN TYPE EBELN,
        ME_EBELP TYPE EBELP,
        LF_TIMESTAMP TYPE TIMESTAMP.

  LOCAL: EKKO, EKPO, XLIKP, XLIPS.

  LOOP AT XVBBE.
*   First we have to get Delivery date/time from LIKP
    IF XLIKP-MANDT NE XVBBE-MANDT OR XLIKP-VBELN NE XVBBE-VBELN.
      READ TABLE XLIKP WITH KEY MANDT = XVBBE-MANDT
                                VBELN = XVBBE-VBELN.
      IF SY-SUBRC <> 0.
*       in this case the VBBE is the SD item data
*       get the delivery header for this SD item
        IF XLIPS-MANDT NE XVBBE-MANDT OR XLIPS-VGBEL NE XVBBE-VBELN OR
           XLIPS-VGPOS NE XVBBE-POSNR.
          READ TABLE XLIPS WITH KEY MANDT = XVBBE-MANDT
                                    VGBEL = XVBBE-VBELN
                                    VGPOS = XVBBE-POSNR.
          CHECK SY-SUBRC = 0.
        ENDIF.
        IF XLIKP-MANDT NE XLIPS-MANDT OR XLIKP-VBELN NE XLIPS-VBELN.
          READ TABLE XLIKP WITH KEY MANDT = XLIPS-MANDT
                                    VBELN = XLIPS-VBELN.
          CHECK SY-SUBRC = 0.
        ENDIF.

        XVBBE-KUNWE = XLIKP-KUNNR.
        MODIFY XVBBE TRANSPORTING KUNWE.
        CONTINUE.                         "all done in case of SD item
      ENDIF.
    ENDIF.

    XVBBE-LFDAT = XLIKP-LFDAT.
    XVBBE-LFUHR = XLIKP-LFUHR.
    XVBBE-KUNWE = XLIKP-KUNNR.

*   we need also the global timestamp for APO.
    CONVERT DATE XVBBE-LFDAT
            TIME XVBBE-LFUHR
       INTO TIME STAMP LF_TIMESTAMP
            TIME ZONE  SY-ZONLO.

    XVBBE-TIMESTAMP_GLOBAL = LF_TIMESTAMP.

*   Preceding document must be PO and sales document type is
*   outbound delivery or returns delivery. This condition all
*   standard delivery types NL,NLCC,NCR,NLR as well as customer
*   specific delivery types
    IF TVLK-LFART NE XLIKP-LFART.
      PERFORM TVLK_SELECT USING XLIKP-LFART
                                SPACE
                                SY-SUBRC.
    ENDIF.
    IF TVLK-AUFER EQ CHARB AND
       ( TVLK-VBTYP CA VBTYP_LIEF ).

      IF XLIPS-MANDT NE XVBBE-MANDT OR XLIPS-VBELN NE XVBBE-VBELN OR
         XLIPS-POSNR NE XVBBE-POSNR.
        READ TABLE XLIPS WITH KEY MANDT = XVBBE-MANDT
                               VBELN = XVBBE-VBELN
                               POSNR = XVBBE-POSNR.
        CHECK SY-SUBRC = 0.
      ENDIF.

      IF NOT XLIPS-VGBEL IS INITIAL AND
         NOT XLIPS-VGPOS IS INITIAL AND
             XLIPS-VGSYS IS INITIAL.

        IF EKPO-EBELN <> XLIPS-VGBEL OR
           EKPO-EBELP <> XLIPS-VGPOS.

          MY_EBELN = XLIPS-VGBEL.
          ME_EBELP = XLIPS-VGPOS.
          CALL FUNCTION 'ME_EKPO_SINGLE_READ'
            EXPORTING
              PI_EBELN         =  MY_EBELN
              PI_EBELP         =  ME_EBELP
            IMPORTING
              PO_EKPO          =  EKPO
            EXCEPTIONS
              NO_RECORDS_FOUND = 1
              OTHERS           = 2.
          CHECK SY-SUBRC = 0.

          CALL FUNCTION 'ME_EKKO_SINGLE_READ'
            EXPORTING
              PI_EBELN         = MY_EBELN
            IMPORTING
              PO_EKKO          = EKKO
            EXCEPTIONS
              NO_RECORDS_FOUND = 1
              OTHERS           = 2.
          CHECK SY-SUBRC = 0.

        ENDIF.

*       FLS rSTO scenario should send 'real' from and to plants
        IF EKPO-FLS_RSTO IS NOT INITIAL.
          XVBBE-EWERKS  = EKKO-RESWK.
        ELSE.
          XVBBE-EWERKS  = EKPO-WERKS.
          XVBBE-ELGORT  = EKPO-LGORT.
          XVBBE-EBERID  = EKPO-BERID.
        ENDIF.
      ENDIF.

    ENDIF.                             "ENDIF Stock transfer delivery

    MODIFY XVBBE TRANSPORTING LFDAT
                              LFUHR
                              KUNWE
                              TIMESTAMP_GLOBAL
                              EWERKS
                              ELGORT
                              EBERID.

  ENDLOOP.

* Do the same for YVBBE as well - we have to get mapping from customer
* to plant also for deleted items. Otherwise in APO the location could
* be changed to the ship-to party (ORDKEY-LOCID)
  LOOP AT yvbbe.
    IF ylikp-mandt NE yvbbe-mandt OR
       ylikp-vbeln NE yvbbe-vbeln.
      READ TABLE ylikp
        WITH KEY mandt = yvbbe-mandt
                 vbeln = yvbbe-vbeln.
      CHECK sy-subrc IS INITIAL.
    ENDIF.

    IF tvlk-lfart NE ylikp-lfart.
      PERFORM tvlk_select USING ylikp-lfart
                                space
                                sy-subrc.
    ENDIF.
    CHECK: tvlk-aufer EQ charb      AND
           tvlk-vbtyp CA vbtyp_lief.

    IF ylips-mandt NE yvbbe-mandt OR
       ylips-vbeln NE yvbbe-vbeln OR
       ylips-posnr NE yvbbe-posnr.
      READ TABLE ylips
        WITH KEY mandt = yvbbe-mandt
                 vbeln = yvbbe-vbeln
                 posnr = yvbbe-posnr.
      CHECK sy-subrc IS INITIAL.
    ENDIF.

    CHECK: NOT ylips-vgbel IS INITIAL AND
           NOT ylips-vgpos IS INITIAL AND
               ylips-vgsys IS INITIAL.

    IF ekpo-ebeln NE ylips-vgbel OR
       ekpo-ebelp NE ylips-vgpos.

      my_ebeln = ylips-vgbel.
      me_ebelp = ylips-vgpos.
      CALL FUNCTION 'ME_EKPO_SINGLE_READ'
        EXPORTING
          pi_ebeln         =  my_ebeln
          pi_ebelp         =  me_ebelp
        IMPORTING
          po_ekpo          =  ekpo
        EXCEPTIONS
          no_records_found = 1
          OTHERS           = 2.
      CHECK sy-subrc IS INITIAL.

      CALL FUNCTION 'ME_EKKO_SINGLE_READ'
        EXPORTING
          pi_ebeln         = my_ebeln
        IMPORTING
          po_ekko          = ekko
        EXCEPTIONS
          no_records_found = 1
          OTHERS           = 2.
      CHECK sy-subrc IS INITIAL.
    ENDIF.

*   FLS rSTO scenario should send 'real' from and to plants
    IF EKPO-FLS_RSTO IS NOT INITIAL.
      yvbbe-ewerks  = ekko-reswk.
    ELSE.
      yvbbe-ewerks  = ekpo-werks.
      yvbbe-elgort  = ekpo-lgort.
      yvbbe-eberid  = ekpo-berid.
    ENDIF.

    MODIFY yvbbe TRANSPORTING ewerks
                              elgort
                              eberid.

  ENDLOOP.

ENDFORM.                    "VBBED_APO_FUELLEN