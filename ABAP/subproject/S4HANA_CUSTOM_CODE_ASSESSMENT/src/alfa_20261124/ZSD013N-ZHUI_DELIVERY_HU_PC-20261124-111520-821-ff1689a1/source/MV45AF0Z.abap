***********************************************************************
*  Unterroutinen RV-Auftragsabwicklung alphabetisch sortiert:         *
*  ----------------------------------------------------------         *
*  Buchstabe Z:                                                       *
*                                                                     *
***********************************************************************

  INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_AUTHOR .
*eject

*---------------------------------------------------------------------*
*       FORM ZAHLUNGSKARTEN_BEARBEITEN_VORB                           *
*---------------------------------------------------------------------*
FORM ZAHLUNGSKARTEN_BEARBEITEN_VORB.
  CHECK NOT TVAK-RPART IS INITIAL.
*
  CLEAR: CCDATA.
  clear xfplt.
*
  IF NOT VBAK-RPLNR IS INITIAL.
    READ TABLE XFPLT WITH KEY FPLNR = VBAK-RPLNR
                              UELNR = '         '
                              UELTR = 0         BINARY SEARCH.
    CHECK SY-SUBRC = 0.
      MOVE XFPLT-CCINS TO CCDATA-CCINS.
      MOVE XFPLT-CCNUM TO CCDATA-CCNUM.
      MOVE XFPLT-DATBI TO CCDATA-DATBI.
      MOVE XFPLT-CCNAME TO CCDATA-CCNAME.
      MOVE XFPLT-CVVAL TO CCARD_CVV-CVVAL.
      MOVE XFPLT-CVVST TO CCARD_CVV-CVVST.
      if call_activity eq gc_activity_lord.
        ccdata-ccard_guid = xfplt-ccard_guid.
      endif.
   ELSE.
     IF NOT CCARD_CVV-CVVAL IS INITIAL.
      CLEAR CCARD_CVV.
     ENDIF.
  ENDIF.
  MOVE CCDATA TO *CCDATA.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM CC_DATUM_PRUEFEN                                         *
*---------------------------------------------------------------------*
*        Pruefen auf sy-datum und tvcaa-ccpga (Datumshorizont)
*---------------------------------------------------------------------*
FORM ZAHLUNGSKARTEN_DATUM_PRUEFEN.

  DATA:
        DIFF_TAGE TYPE I,
        I_TVCAA LIKE TVCAA.

* Prüfhorizont Lesen
  CALL FUNCTION 'SD_CCARD_TVCAA_SELECT'
       EXPORTING
            I_TVAK    = TVAK
       IMPORTING
            E_TVCAA   = I_TVCAA
       EXCEPTIONS
            NOT_FOUND = 1.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO.
  ENDIF.
  DIFF_TAGE = CCDATA-DATBI - SY-DATUM.

  CHECK NOT ( CCDATA-CCINS IS INITIAL AND
              CCDATA-CCNUM IS INITIAL AND
              CCDATA-DATBI IS INITIAL ).
  IF CCDATA-DATBI LT SY-DATUM.
    SET CURSOR FIELD 'CCDATA-DATBI'.
    MESSAGE W114(V/).
  ELSEIF DIFF_TAGE LT I_TVCAA-TGDAT.
    SET CURSOR FIELD 'CCDATA-DATBI'.
    MESSAGE W115(V/) WITH DIFF_TAGE I_TVCAA-TGDAT.
  ENDIF.

ENDFORM.

  INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_BEARBE .
  INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_LESEN  .

  INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_PRUEFE .

  INCLUDE MV45AF0Z_CCARD_KONTENFIND_VORB .
  INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_DATUMI .
  INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_DATUMO .

*&---------------------------------------------------------------------*
*&      Form  ZAHLUNGSKARTEN_MANUAL
*&---------------------------------------------------------------------*
*       Berechtigungsprüfung für manuelle Autorisierung
*----------------------------------------------------------------------*
*      <--P_DA_SUBRC  Return Code
*----------------------------------------------------------------------*
FORM ZAHLUNGSKARTEN_MANUAL CHANGING P_DA_SUBRC LIKE SY-SUBRC.

* Authority-Check
  CALL FUNCTION 'SD_CCARD_SALES_AUTHORITY_CHECK'
       EXPORTING
            I_AUART      = VBAK-AUART
            I_ACTVT      = 'C3'                " Manuelle Autorisierung
       EXCEPTIONS
            NO_AUTHORITY = 4.
  P_DA_SUBRC =  SY-SUBRC.
ENDFORM.                    " ZAHLUNGSKARTEN_MANUAL


*---------------------------------------------------------------------*
*       FORM authorization_value_split1                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  us_auart                                                      *
*  -->  us_fkart                                                      *
*  -->  us_pstyv                                                      *
*---------------------------------------------------------------------*
  FORM AUTHORIZATION_VALUE_SPLIT1 TABLES OPEN_VALUES STRUCTURE BEZS132
                                  USING US_AUART TYPE AUART
                                        US_FKART TYPE FKART
                                        US_PSTYV TYPE PSTYV
                               CHANGING CH_SUBRC TYPE SY-SUBRC.

    DATA: BEGIN OF DA_VBSK.
            INCLUDE STRUCTURE  VBSK.
    DATA: END   OF DA_VBSK.

    DATA: BEGIN OF DA_XKOMFKGN OCCURS 2.
            INCLUDE STRUCTURE KOMFKGN.
    DATA: END OF DA_XKOMFKGN.

    DATA: BEGIN OF DA_XKOMFKKO OCCURS 2.
            INCLUDE STRUCTURE KOMV.
    DATA: END OF DA_XKOMFKKO.

    DATA: BEGIN OF DA_XKOMFK OCCURS 2.
            INCLUDE STRUCTURE KOMFK.
    DATA: END OF DA_XKOMFK.

    DATA: BEGIN OF DA_XKOMV OCCURS 50.
            INCLUDE STRUCTURE KOMV.
    DATA: END   OF DA_XKOMV.

    DATA: BEGIN OF DA_XTHEAD OCCURS 50.
            INCLUDE STRUCTURE THEAD.
    DATA:  TXPFL  LIKE TTXERN-TXPFL.
    DATA:  TDTEXT LIKE TTXIT-TDTEXT.
    DATA:  LFDTX  LIKE TTXERN-LFDTX.
    DATA:  UPDKZ.
    DATA: END OF DA_XTHEAD.

    DATA: BEGIN OF DA_XVBFS OCCURS 20.
            INCLUDE STRUCTURE VBFS.
    DATA: END OF DA_XVBFS.

    DATA: BEGIN OF DA_XVBPA OCCURS 5.
            INCLUDE STRUCTURE VBPAVB.
    DATA: END OF DA_XVBPA.

    DATA: BEGIN OF DA_XVBRK OCCURS 10.
            INCLUDE STRUCTURE VBRKVB.
    DATA: END OF DA_XVBRK.
    DATA: BEGIN OF DA_XVBRP OCCURS 100.
            INCLUDE STRUCTURE VBRPVB.
    DATA: END OF DA_XVBRP.

    DATA: BEGIN OF DA_XVBSS OCCURS 10.
            INCLUDE STRUCTURE VBSS.
    DATA: END OF DA_XVBSS.
    DATA DA_KUNRG LIKE VBPA-KUNNR.
    DATA DA_KUNWE LIKE VBPA-KUNNR.
    DATA DA_KUNRE LIKE VBPA-KUNNR.

    CLEAR CH_SUBRC.

    SORT OPEN_VALUES BY VBELN POSNR ETENR.

    READ TABLE XVBPA WITH KEY MANDT = VBAK-MANDT
                              VBELN = VBAK-VBELN
                              POSNR = POSNR_LOW    BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LOOP AT XVBPA FROM SY-TABIX.
        IF XVBPA-MANDT NE VBAK-MANDT
        OR XVBPA-VBELN NE VBAK-VBELN
        OR XVBPA-POSNR NE POSNR_LOW.
          EXIT.
        ENDIF.
        IF XVBPA-PARVW EQ 'WE'.
          MOVE XVBPA-KUNNR          TO DA_KUNWE.
        ELSEIF XVBPA-PARVW EQ 'RG'.
          MOVE XVBPA-KUNNR          TO DA_KUNRG.
        ELSEIF XVBPA-PARVW EQ 'RE'.
          MOVE XVBPA-KUNNR          TO DA_KUNRE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT XVBAP WHERE UPDKZ NE CHARD.
      READ TABLE OPEN_VALUES WITH KEY VBELN = XVBAP-VBELN
                                      POSNR = XVBAP-POSNR
                                      BINARY SEARCH.
      CHECK SY-SUBRC = 0.
      READ TABLE XVBKD WITH KEY VBELN = XVBAP-VBELN
                                POSNR = XVBAP-POSNR.
      IF SY-SUBRC NE 0.
        READ TABLE XVBKD WITH KEY VBELN = XVBAP-VBELN
                                  POSNR = POSNR_LOW.
      ENDIF.
      MOVE-CORRESPONDING VBAK  TO DA_XKOMFKGN.
      MOVE US_AUART            TO DA_XKOMFKGN-AUART.
      MOVE-CORRESPONDING XVBAP TO DA_XKOMFKGN.
      MOVE US_PSTYV            TO DA_XKOMFKGN-PSTYV.
      MOVE-CORRESPONDING XVBKD TO DA_XKOMFKGN.
      MOVE VBAK-KUNNR          TO DA_XKOMFKGN-KUNAG.
      MOVE DA_KUNRG            TO DA_XKOMFKGN-KUNRG.
      MOVE DA_KUNWE            TO DA_XKOMFKGN-KUNWE.
      MOVE DA_KUNRE            TO DA_XKOMFKGN-KUNRE.
      MOVE VBAK-VBELN          TO DA_XKOMFKGN-VGBEL.
      MOVE XVBAP-POSNR         TO DA_XKOMFKGN-VGPOS.
      MOVE US_FKART            TO DA_XKOMFKGN-FKARA.
      READ TABLE XVBPA WITH KEY MANDT = VBAK-MANDT
                                VBELN = VBAK-VBELN
                                POSNR = XVBAP-POSNR  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LOOP AT XVBPA FROM SY-TABIX.
          IF XVBPA-MANDT NE VBAK-MANDT
          OR XVBPA-VBELN NE VBAK-VBELN
          OR XVBPA-POSNR NE XVBAP-POSNR.
            EXIT.
          ENDIF.
          IF XVBPA-PARVW EQ 'WE'.
            MOVE XVBPA-KUNNR          TO DA_XKOMFKGN-KUNWE.
          ELSEIF XVBPA-PARVW EQ 'RG'.
            MOVE XVBPA-KUNNR          TO DA_XKOMFKGN-KUNRG.
          ELSEIF XVBPA-PARVW EQ 'RE'.
            MOVE XVBPA-KUNNR          TO DA_XKOMFKGN-KUNRE.
          ENDIF.
        ENDLOOP.
      ENDIF.
      APPEND DA_XKOMFKGN.

      READ TABLE XKOMV WITH KEY KNUMV = VBAK-KNUMV
                                KPOSN = XVBAP-POSNR
                            BINARY SEARCH.
      LOOP AT XKOMV FROM SY-TABIX.
        IF XKOMV-KNUMV NE VBAK-KNUMV OR
           XKOMV-KPOSN NE XVBAP-POSNR.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING XKOMV TO DA_XKOMFKKO.
        APPEND DA_XKOMFKKO.
      ENDLOOP.
    ENDLOOP.

    CALL FUNCTION 'GN_INVOICE_CREATE'
         EXPORTING
              VBSK_I            = DA_VBSK
              WITH_POSTING      = SPACE
              I_WITHOUT_REFRESH = CHARX
              ID_NO_DIALOG      = CHARX
         TABLES
              XKOMFK            = DA_XKOMFK
              XKOMFKGN          = DA_XKOMFKGN
              XKOMFKKO          = DA_XKOMFKKO
              XKOMV             = DA_XKOMV
              XTHEAD            = DA_XTHEAD
              XVBFS             = DA_XVBFS
              XVBPA             = DA_XVBPA
              XVBRK             = DA_XVBRK
              XVBRP             = DA_XVBRP
              XVBSS             = DA_XVBSS.

    LOOP AT DA_XVBFS WHERE MSGTY CA 'AE'.
*     message Innn "error in invoice simulation, no split of
*                   authorization value possible"

      CH_SUBRC = 4.
      EXIT.
    ENDLOOP.

    LOOP AT DA_XVBRP.
      READ TABLE OPEN_VALUES WITH KEY VBELN = DA_XVBRP-VGBEL
                                      POSNR = DA_XVBRP-VGPOS
                                      BINARY SEARCH.
      IF SY-SUBRC = 0.
        LOOP AT OPEN_VALUES FROM SY-TABIX.
          IF OPEN_VALUES-VBELN NE DA_XVBRP-VGBEL
          OR OPEN_VALUES-POSNR NE DA_XVBRP-VGPOS.
            EXIT.
          ENDIF.
          MOVE DA_XVBRP-VBELN TO OPEN_VALUES-ZUKRI.
          MODIFY OPEN_VALUES.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
*
  ENDFORM.



*   second example, for example shipping point
  FORM AUTHORIZATION_VALUE_SPLIT2 TABLES OPEN_VALUES STRUCTURE BEZS132.

    SORT OPEN_VALUES BY VBELN POSNR ETENR.

    LOOP AT XVBAP WHERE UPDKZ NE CHARD.
      READ TABLE OPEN_VALUES WITH KEY VBELN = XVBAP-VBELN
                                      POSNR = XVBAP-POSNR
                                      BINARY SEARCH.
      IF SY-SUBRC = 0.
        LOOP AT OPEN_VALUES FROM SY-TABIX.
          IF OPEN_VALUES-VBELN NE XVBAP-VBELN
          OR OPEN_VALUES-POSNR NE XVBAP-POSNR.
            EXIT.
          ENDIF.
*         insert of user fields
*         shipping point is only an example, you do not have to use it
          MOVE XVBAP-VSTEL TO OPEN_VALUES-ZUKRI.
*         MOVE xvbap-werks TO OPEN_VALUES-ZUKRI+4.
*         end of insert user fields
          MODIFY OPEN_VALUES.
        ENDLOOP.
      ENDIF.
    ENDLOOP.



  ENDFORM.