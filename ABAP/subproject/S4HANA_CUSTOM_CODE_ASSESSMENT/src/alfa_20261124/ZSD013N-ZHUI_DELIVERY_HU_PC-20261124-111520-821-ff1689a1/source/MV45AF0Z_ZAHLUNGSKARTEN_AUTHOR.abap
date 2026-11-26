*---------------------------------------------------------------------*
*       FORM ZAHLUNGSKARTEN_AUTHORISIEREN                             *
*---------------------------------------------------------------------*
*       Perform authorization for sales order                         *
*---------------------------------------------------------------------*
*  -->  US_SICHERN      X Save sales order                            *
*---------------------------------------------------------------------*
FORM ZAHLUNGSKARTEN_AUTHORISIEREN USING US_SICHERN.

  DATA: DA_VBAP_TABIX LIKE SVBAP-TABIX.
  INCLUDE FPLTCCON.

* Tables to update the payment plan
  DATA: DA_XFPLT_AUTH LIKE XFPLT OCCURS 5 WITH HEADER LINE,
        DA_XFPLT_OLD  LIKE XFPLT OCCURS 5 WITH HEADER LINE.
  DATA: DA_CHANGE.
  DATA: DA_UPD_FPLA.
  DATA: DA_UPD_FPLT.
* Stuff before transmission
  DATA: DA_TVCAA LIKE TVCAA.
  DATA: DA_KTOPL LIKE TCCAA-KTOPL.
  DATA: DA_AUST1 LIKE FPLA-AUST1.
* Stuff for the transmission
  DATA: DA_CCAUT         LIKE CCAUT.
  DATA: DA_ORDER_AUTH      TYPE V21A_ORDER_AUTH,
        DA_ORDER_AUTH_PACK TYPE V21A_ORDER_AUTH_PACK.
* Stuff after transmission
  DATA: DA_CCAUT_R_TOTAL LIKE CCAUT_R OCCURS 5 WITH HEADER LINE.
  DATA: BEGIN OF DA_MESSAGE,
          MSGID LIKE SY-MSGID,
          MSGTY LIKE SY-MSGTY,
          MSGNO LIKE SY-MSGNO,
          MSGV1 LIKE SY-MSGV1,
          MSGV2 LIKE SY-MSGV2,
          MSGV3 LIKE SY-MSGV3,
          MSGV4 LIKE SY-MSGV4,
        END OF DA_MESSAGE.

  DATA: LC_FUNC_INFO     TYPE RS38L_FNAM VALUE 'CRS_SALES_GET_INFO',
        LC_FUNC_PAROLTP  TYPE RS38L_FNAM VALUE 'CRS_READ_CRMPAROLTP'.

  DATA: LV_PROXY         TYPE CHAR1,
        LV_PARVAL1       TYPE CHAR255,
        LV_RELEASE_CRM   TYPE CHAR3.

  DATA: LS_FPLT LIKE LINE OF XFPLT,
        LV_TABIX TYPE SY-TABIX,
        LV_SUBRC TYPE SY-SUBRC,
        LV_KALSM TYPE TVFK-KALSMCD,
        LS_KOMKCV TYPE KOMKCV,
        LS_KOMPCV TYPE KOMPCV,
        LS_MERCH TYPE TCCAA-MERCH.

  DATA: LR_BADI_SLS_CCARD_AUTH TYPE REF TO BADI_SLS_CCARD_AUTH.

  CONSTANTS: CO_POSNR_INITIAL LIKE VBPA-POSNR VALUE IS INITIAL.

* Are cards present ?
  CHECK NOT VBAK-RPLNR IS INITIAL.
  READ TABLE XFPLT
       WITH KEY FPLNR = VBAK-RPLNR
       BINARY SEARCH.
  CHECK SY-SUBRC = 0.
* Read misc. info
  READ TABLE XFPLA
       WITH KEY FPLNR = VBAK-RPLNR
       BINARY SEARCH.
  IF SY-SUBRC NE 0.
    MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ XFPLA'.
  ENDIF.
  READ TABLE XVBKD
       WITH KEY POSNR = CO_POSNR_INITIAL.
  IF SY-SUBRC NE 0.
    MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ XVBKD'.
  ENDIF.
* Don't authorize when the docuement is released
  CHECK CALL_ACTIVITY NE ACTIVITY_CREDIT_RELEASE.

* fill G/L account during upload from CRM
  IF VBAK-VBKLA(2) = 'CR' AND
     NOT CALL_BAPI IS INITIAL.
    LOOP AT XFPLT INTO LS_FPLT WHERE CCACT IS INITIAL.
      LV_TABIX = SY-TABIX.
      CALL FUNCTION 'SD_PROCEDURE_DETERMINE_FPLT_OR'
           EXPORTING
                I_VBAK    = VBAK
                I_VBUK    = VBUK
           IMPORTING
                E_KALSMCD = LV_KALSM
           EXCEPTIONS
                NOT_FOUND = 4.
      CALL FUNCTION 'SD_FILL_KOMKCV_KOMPCV_FPLT_ORD'
           EXPORTING
                I_VBAK       = VBAK
                I_VBUK       = VBUK
                I_VBKDVB     = XVBKD
                I_FPLAVB     = XFPLA
                I_FPLTVB     = LS_FPLT
           IMPORTING
                E_KOMKCV     = LS_KOMKCV
                E_KOMPCV     = LS_KOMPCV
           EXCEPTIONS
                NOT_FILLABLE = 1
                OTHERS       = 2.
     CALL FUNCTION 'SD_CCARD_ACCOUNT_DETERMINATION'
          EXPORTING
               I_KOMKCV          = LS_KOMKCV
               I_KOMPCV          = LS_KOMPCV
               I_KALSM           = LV_KALSM
               I_XFPLT           = LS_FPLT
          IMPORTING
               E_SAKN1           = LS_FPLT-CCACT
               E_MERCH           = LS_MERCH
          EXCEPTIONS
               ACCOUNT_NOT_FOUND = 1
               OTHERS            = 2.
      IF NOT LS_FPLT-CCACT IS INITIAL.
        MODIFY XFPLT FROM LS_FPLT INDEX LV_TABIX TRANSPORTING CCACT.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Do not authorize when document is uploaded from CRM release >5.0
  IF NOT VBAK-RPLNR  IS INITIAL AND
     ( VBAK-VBKLA+2(1) =  'A' OR
       VBAK-VBKLA+2(1) =  'S' ).
*   Check if called from proxy
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        FUNCNAME           = LC_FUNC_INFO
      EXCEPTIONS
        FUNCTION_NOT_EXIST = 1
        OTHERS             = 2.
    IF SY-SUBRC = 0.
      CALL FUNCTION LC_FUNC_INFO                    "#EC EXISTS
         IMPORTING
            E_SEND_TOGETHER = LV_PROXY.
    ENDIF.
*   Check CRM release
    IF NOT LV_PROXY IS INITIAL.
      CALL FUNCTION LC_FUNC_PAROLTP                 "#EC EXISTS
        EXPORTING
          I_PARANAME = 'CRM_RELEASE'
        IMPORTING
          E_PARVAL1  = LV_PARVAL1.
      LV_RELEASE_CRM = LV_PARVAL1+0(3).
    ENDIF.
*   Exit if CRM upload
    IF NOT LV_PROXY      IS INITIAL AND
       LV_RELEASE_CRM(1) >= '5'.
      EXIT.
    ENDIF.
  ENDIF.
* Read check-group
  CALL FUNCTION 'SD_CCARD_TVCAA_SELECT'
       EXPORTING
            I_TVAK  = TVAK
       IMPORTING
            E_TVCAA = DA_TVCAA.
* Check AutorisationsStop
  CHECK XFPLA-AUST5 = ' '.
*  Re-run the availibility check          " we must do ATP before
  PERFORM CREDIT_REDO_AVAILABILITY.    " check order status
*  Re-run the delivery group correlation
  CREDIT_CHECK_CCARD_SIMUL_MODE = CHARX.  " like lgko runs in simul.mode
  PERFORM LIEFERGRUPPENDATUM_SETZEN(SAPFV45V) USING VERARB_IMMER.
  CREDIT_CHECK_CCARD_SIMUL_MODE = SPACE.

* Determine the current header status
  CALL FUNCTION 'RV_XVBUK_MAINTAIN'
       EXPORTING
            F_VBELN       = VBAK-VBELN
            F_VBTYP       = VBAK-VBTYP
            F_VBAK        = VBAK
       IMPORTING
            E_VBUK_CHANGE = DA_CHANGE
       TABLES
            FXVBUP        = XVBUP
            FXVBUK        = XVBUK
            FXVBUV        = XVBUV
            FYVBUK        = YVBUK.
  IF NOT DA_CHANGE IS INITIAL.
    UPD_VBUK = CHARU.
  ENDIF.
  PERFORM XVBUK_LESEN(SAPFV45K) USING VBAK-VBELN.
* We have to read payment plan header again, maybe we've lost it
  READ TABLE XFPLA
       WITH KEY FPLNR = VBAK-RPLNR
       BINARY SEARCH.
  IF SY-SUBRC NE 0.
    MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ XFPLA'.
  ENDIF.
* Check requirement
  DA_AUST1 = AUST1_NICHT_REL.
  IF NOT DA_TVCAA-AUTBE IS INITIAL.
    CALL FUNCTION 'SD_CCARD_AUTH_REQUIREMENT'
         EXPORTING
              I_CALL_ACTIVITY           = CALL_ACTIVITY
              I_AUTBE                   = DA_TVCAA-AUTBE
              I_VBAK                    = VBAK
              I_VBUK                    = VBUK
              I_VBKDVB                  = XVBKD
              I_FPLAVB                  = XFPLA
         EXCEPTIONS
              ERROR_MESSAGE             = 4
              REQUIREMENT_NOT_FULFILLED = 4
              OTHERS                    = 4.
* General error handling
    IF SY-SUBRC = 0.
      DA_AUST1 = AUST1_FULFILLED.
    ELSE.
      DA_AUST1 = AUST1_NOT_FULFILLED.
      CLEAR XFPLA-AUST2.
      CLEAR XFPLA-AUST3.
      CLEAR XFPLA-AUST5.
* Are we just checking or also saving
      IF CALL_ACTIVITY EQ ACTIVITY_CREDIT_AUTHPRE.
* Issue message directly
        MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2
                   SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ENDIF.
* Is the requirement okay ?
  IF DA_AUST1 CA AUST1_CA_GUELTIG.
*  Re-run the availibility check
    PERFORM CREDIT_REDO_AVAILABILITY.
*  Re-run the delivery group correlation
  CREDIT_CHECK_CCARD_SIMUL_MODE = CHARX." like lgko runs in simul.mode
  PERFORM LIEFERGRUPPENDATUM_SETZEN(SAPFV45V) USING VERARB_IMMER.
  CREDIT_CHECK_CCARD_SIMUL_MODE = SPACE.
* Get open values - all items, DA_VBAP_TABIX = 0
    PERFORM OFFENE_WERTE_ERMITTELN TABLES OPEN_VALUES
                                   USING CHARX DA_VBAP_TABIX.
* User exit in order to decide which items will be invoiced together
    PERFORM AUTHORIZATION_VALUE_SPLIT TABLES OPEN_VALUES .
* Get open delivery values
    CALL FUNCTION 'SD_CCARD_GET_OPEN_DELIVERIES'
         EXPORTING
              I_VBAK_VBELN = VBAK-VBELN
         TABLES
              I_S132       = OPEN_VALUES
              FXVBAP       = XVBAP
              FXVBFA       = XVBFA.
* Get open invoice values
    CALL FUNCTION 'SD_CCARD_GET_OPEN_BILLINGS'
         EXPORTING
              I_VBELN = VBAK-VBELN
         TABLES
              I_S132  = OPEN_VALUES
              FXVBUK  = XVBUK
              FXVBFA  = XVBFA.
* We have to read payment plan header again, when we've lost it
  READ TABLE XFPLA
       WITH KEY FPLNR = VBAK-RPLNR
       BINARY SEARCH.
  IF SY-SUBRC NE 0.
    MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ XFPLA'.
  ENDIF.
* Set Factor - Communication with Credit Management
    CALL FUNCTION 'SD_CCARD_SET_FACTOR'
         EXPORTING
              I_SOURCE  = '1'          "Sales Order
              I_VBAK    = VBAK
              I_XFPLA   = XFPLA
         TABLES
              T_XFPLT   = XFPLT
              T_BEZS132 = OPEN_VALUES.
* Create auth. lines and indicate which auth. will be replaced
    CALL FUNCTION 'SD_CCARD_PERFORM_AUTHORIZATION'
         EXPORTING
              I_VBUK         = VBUK
              I_VBAK         = VBAK
              I_XFPLA        = XFPLA
              I_XVBKD        = XVBKD
              I_TVCAA        = DA_TVCAA
         IMPORTING
              E_KTOPL        = DA_KTOPL
         TABLES
              T_XFPLT        = XFPLT
              T_BEZS132      = OPEN_VALUES
              T_XFPLT_UPDATE = DA_XFPLT_OLD
              T_XFPLT_NEW    = DA_XFPLT_AUTH.
* Check that there are no open invoices without payment plans
*   TABLES: VBRK.
*   DATA: DA_VBRK LIKE VBRK,
*         DA_OPEN_INVOICES.
*   CLEAR: DA_OPEN_INVOICES.
*   LOOP AT XVBFA
*        WHERE VBELV = VBAK-VBELN.
*     CHECK XVBFA-VBTYP_N CA VBTYP_FAKT.
*     SELECT SINGLE * FROM VBRK INTO DA_VBRK
*            WHERE VBELN = XVBFA-VBELN.
*     CHECK SY-SUBRC = 0.
*     CHECK VBRK-RPLNR IS INITIAL AND
*           VBRK-RFBSK CA ' ABFG'.
*     DA_OPEN_INVOICES = 'X'.
*     EXIT.
*   ENDLOOP.
*   IF DA_OPEN_INVOICES = 'X'.
*     MESSAGE I123(V/).
*     EXIT.
*   ENDIF.

* Are we just checking or also saving
    IF CALL_ACTIVITY EQ ACTIVITY_CREDIT_AUTHPRE.
      EXIT.
    ENDIF.

* Prepare for transmission
    CALL FUNCTION 'SD_CCARD_AUTH_FILL_COMM_OUT'
         EXPORTING
              I_VBAK            = VBAK
              I_XVBKD           = XVBKD
              I_XFPLA           = XFPLA
              I_KTOPL           = DA_KTOPL
         IMPORTING
              E_V21A_ORDER_AUTH = DA_ORDER_AUTH
         TABLES
              T_XFPLT_AUTH      = DA_XFPLT_AUTH
              T_XVBPA           = XVBPA
              T_XVBADR          = XVBADR
              T_XVBAP           = XVBAP
              T_XVBKD           = XVBKD
              T_XKOMV           = XKOMV.

*   Call BADI - filling additional fields
    TRY.
      GET BADI LR_BADI_SLS_CCARD_AUTH.
      IF LR_BADI_SLS_CCARD_AUTH IS BOUND.
        CALL BADI LR_BADI_SLS_CCARD_AUTH->ADD_FIELDS_TO_PCI
          EXPORTING
            IS_VBAK            = VBAK
            IS_XVBKD           = XVBKD
            IS_XFPLA           = XFPLA
            IS_KTOPL           = DA_KTOPL
            IT_XVBPA           = XVBPA[]
            IT_XVBADR          = XVBADR[]
            IT_XVBAP           = XVBAP[]
            IT_XVBKD           = XVBKD[]
            IT_XKOMV           = XKOMV[]
          CHANGING
            CT_ORDER_AUTH      = DA_ORDER_AUTH
            CT_XFPLT_AUTH      = DA_XFPLT_AUTH[].
      ENDIF.
    CATCH CX_BADI_NOT_IMPLEMENTED.
    ENDTRY.

* Transmission
    LOOP AT DA_ORDER_AUTH INTO DA_ORDER_AUTH_PACK.
* Call
      READ TABLE DA_XFPLT_AUTH INDEX 1.
      IF DA_XFPLT_AUTH-VCARD EQ 'X'.
* fulfill ccaut strurcture for SET, payment-number should get another
* number (currently billing plan number)
        DATA : DA_SET_CCAUT LIKE CCAUT.
        DATA : DA_SET_XFPLT LIKE XFPLT OCCURS 5 WITH HEADER LINE.
        LOOP AT XFPLT WHERE FPLNR = DA_XFPLT_AUTH-FPLNR.
          READ TABLE XFPLT INDEX SY-TABIX.
          MOVE XFPLT TO DA_SET_XFPLT.
          APPEND DA_SET_XFPLT.
        ENDLOOP.
        SORT DA_SET_XFPLT BY MANDT FPLNR FPLTR DESCENDING.
        READ TABLE DA_SET_XFPLT INDEX 1.
        DESCRIBE TABLE DA_SET_XFPLT LINES SY-TFILL.
        IF SY-TFILL > 1.
          DA_SET_CCAUT-PAYMENT_NUMBER = DA_SET_XFPLT-FPLTR + 1.  " next
          DA_SET_CCAUT-SPLITALLOWED = 1.
        ELSE.
          DA_SET_CCAUT-PAYMENT_NUMBER = 900001.   " should be the first
          CLEAR DA_SET_CCAUT-SPLITALLOWED.
        ENDIF.
        MODIFY DA_ORDER_AUTH_PACK-CCAUT
          FROM DA_SET_CCAUT INDEX SY-TABIX
          TRANSPORTING PAYMENT_NUMBER SPLITALLOWED.

        DATA: DA_CCAUT_R         LIKE CCAUT_R.
        REFRESH DA_ORDER_AUTH_PACK-CCAUT.
        LOOP AT DA_ORDER_AUTH_PACK-CCAUT_R INTO DA_CCAUT_R.
          MOVE-CORRESPONDING DA_CCAUT_R TO DA_CCAUT.
          APPEND DA_CCAUT_R TO DA_ORDER_AUTH_PACK-CCAUT_R.
        ENDLOOP.
*        DA_ORDER_AUTH_PACK-CCAUT_R[] = DA_ORDER_AUTH_PACK-CCAUT[].
*        da_order_auth_pack-fnaut_setinit
*        da_order_auth_pack-fnaut_setinfo
*        da_order_auth_pack-rfcaut
      ELSE.
        CALL FUNCTION 'SD_CCARD_AUTH_CALL_RFC'
             EXPORTING
                  I_FNAUT       = DA_ORDER_AUTH_PACK-FNAUT
                  I_RFCAUT      = DA_ORDER_AUTH_PACK-RFCAUT
             TABLES
                  T_CCAUT       = DA_ORDER_AUTH_PACK-CCAUT
                  T_CCAUT_R     = DA_ORDER_AUTH_PACK-CCAUT_R
                  T_CCAUT_H     = DA_ORDER_AUTH_PACK-CCAUT_H
                  T_CCAUT_I     = DA_ORDER_AUTH_PACK-CCAUT_I
             EXCEPTIONS
                  ERROR_IN_CALL = 1
                  OTHERS        = 2.
      ENDIF.
* Set call status for function
      IF SY-SUBRC = 0.
        APPEND LINES OF DA_ORDER_AUTH_PACK-CCAUT_R TO DA_CCAUT_R_TOTAL.
        DA_ORDER_AUTH_PACK-CCALL = CCALL_CALLED.
      ELSE.
        MOVE-CORRESPONDING SYST TO DA_MESSAGE.
        MESSAGE I018(V/).
        MESSAGE ID DA_MESSAGE-MSGID TYPE 'I' NUMBER DA_MESSAGE-MSGNO
                   WITH DA_MESSAGE-MSGV1 DA_MESSAGE-MSGV2
                        DA_MESSAGE-MSGV3 DA_MESSAGE-MSGV4.
        DA_ORDER_AUTH_PACK-CCALL = CCALL_NOT_CALL.
      ENDIF.
      MODIFY DA_ORDER_AUTH FROM DA_ORDER_AUTH_PACK.
    ENDLOOP.
*    SORT DA_CCAUT_R_TOTAL BY FPLTR.
* Set call status for every line
    DATA: BEGIN OF DA_XFPLT_AUTH_EXT OCCURS 5.
            INCLUDE STRUCTURE FPLTVB.
    DATA: AUTWV_EXT LIKE CCAUT-AUTWV.
    DATA: END OF DA_XFPLT_AUTH_EXT.

    LOOP AT DA_XFPLT_AUTH.
      MOVE-CORRESPONDING DA_XFPLT_AUTH TO DA_XFPLT_AUTH_EXT.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
           EXPORTING
                CURRENCY        = VBAK-WAERK
                AMOUNT_INTERNAL = DA_XFPLT_AUTH_EXT-AUTWV
           IMPORTING
                AMOUNT_EXTERNAL = DA_XFPLT_AUTH_EXT-AUTWV_EXT.
      IF VBAK-VBTYP CA VBTYP_RETOUR.
        DA_XFPLT_AUTH_EXT-AUTWV_EXT = - DA_XFPLT_AUTH_EXT-AUTWV_EXT.
      ENDIF.
      APPEND DA_XFPLT_AUTH_EXT.
    ENDLOOP.

    LOOP AT DA_XFPLT_AUTH_EXT.
      LOOP AT DA_ORDER_AUTH INTO DA_ORDER_AUTH_PACK.
        LOOP AT DA_ORDER_AUTH_PACK-CCAUT INTO DA_CCAUT
             WHERE FPLTR = DA_XFPLT_AUTH_EXT-FPLTR AND
                   AUTWV = DA_XFPLT_AUTH_EXT-AUTWV_EXT.
          DA_XFPLT_AUTH_EXT-CCALL = DA_ORDER_AUTH_PACK-CCALL.
          DA_XFPLT_AUTH_EXT-FNAUT_SETINIT
                                    = DA_ORDER_AUTH_PACK-FNAUT_SETINIT.
          DA_XFPLT_AUTH_EXT-FNAUT_SETINFO
                                    = DA_ORDER_AUTH_PACK-FNAUT_SETINFO.
          DA_XFPLT_AUTH_EXT-RFCAUT = DA_ORDER_AUTH_PACK-RFCAUT.
          DA_XFPLT_AUTH_EXT-CCNUM = DA_CCAUT-CCNUM.
          MODIFY DA_XFPLT_AUTH_EXT TRANSPORTING CCALL
                                            FNAUT_SETINIT
                                            FNAUT_SETINFO
                                            RFCAUT
                                            CCNUM.
          EXIT.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
* Authorisieren und Ergebnis übernehmen
    DATA: DA_XFPLT_AUTH_NEW LIKE XFPLT OCCURS 2 WITH HEADER LINE.
    DATA: DA_TABIX LIKE SY-TABIX.
*    SORT DA_CCAUT_R_TOTAL BY AUTWR.

    LOOP AT DA_XFPLT_AUTH_EXT.
      MOVE-CORRESPONDING DA_XFPLT_AUTH_EXT TO DA_XFPLT_AUTH_NEW.
      IF DA_XFPLT_AUTH_EXT-CCPRE NE 'X'.
        LOOP AT DA_CCAUT_R_TOTAL.
          IF DA_CCAUT_R_TOTAL-AUTWR = DA_XFPLT_AUTH_EXT-AUTWV_EXT
           AND DA_CCAUT_R_TOTAL-FPLTR = DA_XFPLT_AUTH_EXT-FPLTR.




*           WHERE AUTWR = DA_XFPLT_AUTH_EXT-AUTWV_EXT.
*        IF SY-SUBRC = 0.               " matched
*      READ TABLE DA_CCAUT_R_TOTAL
*           WITH KEY FPLTR = DA_XFPLT_AUTH-FPLTR
*           BINARY SEARCH.
*      IF SY-SUBRC = 0.
*        DA_TABIX = SY-TABIX.
*        CALL FUNCTION 'SD_CCARD_AUTH_GET_COMM_IN'
*             EXPORTING
*                  I_VBAK    = VBAK
*                  I_XFPLT   = DA_XFPLT_AUTH
*                  I_CCAUT_R = DA_CCAUT_R_TOTAL
*             IMPORTING
*                  E_XFPLT   = DA_XFPLT_AUTH.
            MOVE-CORRESPONDING DA_CCAUT_R_TOTAL TO DA_XFPLT_AUTH_NEW.
            CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
                 EXPORTING
                      CURRENCY             = VBAK-WAERK
                      AMOUNT_EXTERNAL      = DA_CCAUT_R_TOTAL-AUTWR
                      MAX_NUMBER_OF_DIGITS = 23
                 IMPORTING
                      AMOUNT_INTERNAL      = DA_XFPLT_AUTH_NEW-AUTWR.
            IF VBAK-VBTYP CA VBTYP_RETOUR.
              DA_XFPLT_AUTH_NEW-AUTWR = - DA_XFPLT_AUTH_NEW-AUTWR.
            ENDIF.
            DA_XFPLT_AUTH_NEW-CCALL = CCALL_ANSWERED.
            DELETE DA_XFPLT_AUTH_EXT.  " we don't need it any more
            DELETE DA_CCAUT_R_TOTAL.
            APPEND DA_XFPLT_AUTH_NEW.  " copy to new int. table
            EXIT.
          ENDIF.                       " IF matched
        ENDLOOP.                       " LOOP DA_CCAUT_R_TOTAL
      ENDIF.                           " DA_XFPLT_AUTH_EXT-CCPRE NE 'X'
    ENDLOOP.

* Now the part which don't matched to auth line or pre-auth.
    LOOP AT DA_XFPLT_AUTH_EXT.
      MOVE-CORRESPONDING DA_XFPLT_AUTH_EXT TO DA_XFPLT_AUTH_NEW.
      LOOP AT DA_CCAUT_R_TOTAL
           WHERE FPLTR = DA_XFPLT_AUTH_EXT-FPLTR.
        IF SY-SUBRC = 0.               " matched
          MOVE-CORRESPONDING DA_CCAUT_R_TOTAL TO DA_XFPLT_AUTH_NEW.
          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
               EXPORTING
                    CURRENCY             = VBAK-WAERK
                    AMOUNT_EXTERNAL      = DA_CCAUT_R_TOTAL-AUTWR
                    MAX_NUMBER_OF_DIGITS = 23
               IMPORTING
                    AMOUNT_INTERNAL      = DA_XFPLT_AUTH_NEW-AUTWR.
          IF VBAK-VBTYP CA VBTYP_RETOUR.
            IF DA_XFPLT_AUTH_NEW-CCPRE NE 'X'.
              DA_XFPLT_AUTH_NEW-AUTWR = - DA_XFPLT_AUTH_NEW-AUTWR.
            ENDIF.
          ENDIF.
          IF NOT DA_CCAUT_R_TOTAL-REACT IS INITIAL.
            DA_XFPLT_AUTH_NEW-CCALL = CCALL_ANSWERED.
          ELSE.
            CLEAR DA_XFPLT_AUTH_NEW-AUTWR.
          ENDIF.
          DELETE DA_CCAUT_R_TOTAL.     " we don't need it any more
          APPEND DA_XFPLT_AUTH_NEW.    " copy to new int. table
          DELETE DA_XFPLT_AUTH_EXT.
          EXIT.
        ENDIF.                         " It should be matched for all
      ENDLOOP.
    ENDLOOP.

* If RFC call is not sucessful
    LOOP AT DA_XFPLT_AUTH_EXT.
      MOVE-CORRESPONDING DA_XFPLT_AUTH_EXT TO DA_XFPLT_AUTH_NEW.
      APPEND DA_XFPLT_AUTH_NEW.    " copy to new int. table
    ENDLOOP.

* Fakturastatus der neuen Autorisierung setzen
    LOOP AT DA_XFPLT_AUTH_NEW.
*      MOVE-CORRESPONDING DA_XFPLT_AUTH_EXT TO DA_XFPLT_AUTH_NEW.
      IF DA_XFPLT_AUTH_NEW-CCALL = CCALL_ANSWERED AND
         DA_XFPLT_AUTH_NEW-REACT CA REACT_CA_GUELTIG.
        DA_XFPLT_AUTH_NEW-FKSAF = FKSAF_NICHT_BEARB.
      ELSE.
        DA_XFPLT_AUTH_NEW-FKSAF = FKSAF_NICHT_REL.
      ENDIF.
      MODIFY DA_XFPLT_AUTH_NEW.
* Neue XFPLT kopieren
      CLEAR: DA_XFPLT_AUTH_NEW-FPLTR,
             DA_XFPLT_AUTH_NEW-UPDKZ,
             DA_XFPLT_AUTH_NEW-CCARD_GUID.
      CALL FUNCTION 'BILLING_SCHEDULE_MAINTAIN'
           EXPORTING
                I_FPLT     = DA_XFPLT_AUTH_NEW
                I_FPLNR    = VBAK-RPLNR
           IMPORTING
                E_UPD_FPLA = UPD_FPLA
                E_UPD_FPLT = UPD_FPLT
           TABLES
                FPLA_OLD   = YFPLA
                FPLA_NEW   = XFPLA
                FPLT_OLD   = YFPLT
                FPLT_NEW   = XFPLT.
    ENDLOOP.
* update pre-auth, if we have got new auth.
    LOOP AT DA_XFPLT_AUTH_NEW.
      CHECK DA_XFPLT_AUTH_NEW-FKSAF = FKSAF_NICHT_BEARB.
      LOOP AT XFPLT WHERE UELTR = DA_XFPLT_AUTH_NEW-UELTR
                   AND UPDKZ EQ ' '
                   AND CCPRE = 'X'.
* if there is pre-auth, take over as used
        READ TABLE DA_XFPLT_OLD WITH KEY FPLNR = XFPLT-FPLNR
                                         FPLTR = XFPLT-FPLTR.
        IF SY-SUBRC NE 0.                " take over as used
          DA_XFPLT_OLD = XFPLT.
          DA_XFPLT_OLD-CCOLD = 'X'.
          APPEND DA_XFPLT_OLD.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
* Alte XFPLT kopieren
    LOOP AT DA_XFPLT_OLD.
* Ursprunglichen Authorizierung updaten
*      IF NOT DA_XFPLT_AUTH-UELTR_A IS INITIAL.
*        READ TABLE DA_XFPLT_OLD
*                 WITH KEY FPLTR = DA_XFPLT_AUTH-UELTR_A
*                 BINARY SEARCH.
*        IF SY-SUBRC NE 0.
*          MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ DA_XFPLA_OLD'.
*        ENDIF.
*        IF DA_XFPLT_AUTH-FKSAF = FKSAF_NICHT_BEARB.
      IF DA_XFPLT_OLD-CCOLD = 'X'.
        DA_XFPLT_OLD-FKSAF = FKSAF_NICHT_REL.
*        ELSE.
*          CLEAR: DA_XFPLT_OLD-CCOLD,
*                 DA_XFPLT_OLD-CCVAL.
*          DA_XFPLT_OLD-FKSAF = FKSAF_NICHT_BEARB.
*        ENDIF.
        MODIFY DA_XFPLT_OLD INDEX SY-TABIX.
      ENDIF.
*      ENDIF.
*      MODIFY DA_XFPLT_AUTH.
      CLEAR: DA_XFPLT_OLD-UPDKZ.
      CALL FUNCTION 'BILLING_SCHEDULE_MAINTAIN'
           EXPORTING
                I_FPLT     = DA_XFPLT_OLD
                I_FPLNR    = VBAK-RPLNR
           IMPORTING
                E_UPD_FPLA = DA_UPD_FPLA
                E_UPD_FPLT = DA_UPD_FPLT
           TABLES
                FPLA_OLD   = YFPLA
                FPLA_NEW   = XFPLA
                FPLT_OLD   = YFPLT
                FPLT_NEW   = XFPLT.

*     do not overwrite former value of UPD_FPLA/UPD_FPLT if the old
*     authorization has not been changed
      IF NOT DA_UPD_FPLA IS INITIAL.
        UPD_FPLA = DA_UPD_FPLA.
      ENDIF.
      IF NOT DA_UPD_FPLT IS INITIAL.
        UPD_FPLT = DA_UPD_FPLT.
      ENDIF.

    ENDLOOP.
  ENDIF.
* Are we just checking or also saving
  IF CALL_ACTIVITY EQ ACTIVITY_CREDIT_AUTHPRE.
    EXIT.
  ENDIF.
* XFPLA Statusübernahme
  XFPLA-AUST1 = DA_AUST1.
  DATA MANUAL_AUTH VALUE 'X'.
  DESCRIBE TABLE DA_XFPLT_AUTH_NEW LINES SY-TABIX.
  IF SY-TABIX NE 0.
    CLEAR XFPLA-AUST2.
    CLEAR XFPLA-AUST3.
    CLEAR XFPLA-AUST5.
    CLEAR MANUAL_AUTH.      " if sy-tabix no zero, autom. auth. is done
    LOOP AT DA_XFPLT_AUTH_NEW.
* Call Status
      XFPLA-AUST2 = CCALL_ANSWERED.
      IF XFPLA-AUST2 GT DA_XFPLT_AUTH_NEW-CCALL AND
         DA_XFPLT_AUTH_NEW-CCALL NE CCALL_NICHT_REL.
        XFPLA-AUST2 = DA_XFPLT_AUTH_NEW-CCALL.
      ENDIF.
* Reaction
      IF XFPLA-AUST3 LT DA_XFPLT_AUTH_NEW-REACT.
        XFPLA-AUST3 = DA_XFPLT_AUTH_NEW-REACT.
      ENDIF.
* Stop-Flag setzten
      IF DA_XFPLT_AUTH_NEW-REACT = REACT_STOP.
        XFPLA-AUST5 = 'X'.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF VBAK-RPLNR NE XFPLA-FPLNR.        " just the wrong entry
    READ TABLE XFPLA                   " we must read it again
         WITH KEY FPLNR = VBAK-RPLNR
         BINARY SEARCH.
    IF SY-SUBRC NE 0.
      MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ XFPLA'.
    ENDIF.
  ENDIF.
  DATA: DA_FPLA LIKE FPLA.
*   DA_FPLA = XFPLA.
  MOVE-CORRESPONDING XFPLA TO DA_FPLA.
  CALL FUNCTION 'BILLING_SCHEDULE_MAINTAIN'
       EXPORTING
            I_FPLA     = DA_FPLA
            I_UPD_FPLT = UPD_FPLT      " keep update flag for fplt
            I_FPLNR    = VBAK-RPLNR
       IMPORTING
            E_UPD_FPLA = UPD_FPLA
            E_UPD_FPLT = UPD_FPLT
       TABLES
            FPLA_OLD   = YFPLA
            FPLA_NEW   = XFPLA
            FPLT_OLD   = YFPLT
            FPLT_NEW   = XFPLT.

* Now we check answer from clearing house and call a popup
* User has to decide whether the order should be saved or not.
  IF MANUAL_AUTH IS INITIAL.           " So we have autom. autho.
IF DA_FPLA-AUST1 NA ' B'.              "B or spacefor case authorisation
      PERFORM CCARD_LAST_DIALOG USING
                                TEXT-289 " something was wrong
                                US_SICHERN.
    ELSE.
  IF DA_FPLA-AUST2 NA ' C'.            " C for answer from clearinghouse
        PERFORM CCARD_LAST_DIALOG USING
                                  TEXT-287 " we don't get answer
                                  US_SICHERN.
      ELSE.
        IF DA_FPLA-AUST3 EQ 'C'.       " C for card not O.K.
          PERFORM CCARD_LAST_DIALOG USING
                                    TEXT-281
                                    US_SICHERN.
        ELSEIF DA_FPLA-AUST3 EQ 'B'.   " B for no connection
          PERFORM CCARD_LAST_DIALOG USING
                                    TEXT-288
                                    US_SICHERN.
        ELSEIF DA_FPLA-AUST3 NA ' A'.  " other except A
          PERFORM CCARD_LAST_DIALOG USING
                                    TEXT-289  " something was wrong
                                    US_SICHERN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM CREDIT_REDO_AVAILABILITY
*---------------------------------------------------------------------*
*       Re-run the availibility check if:                             *
*       - The sales order was blocked and                             *
*       - The subsequent functions took away the availability         *
*---------------------------------------------------------------------*
FORM CREDIT_REDO_AVAILABILITY.         "CCARD

  DATA: DA_VBUK LIKE VBUK,
        DA_SUBRC LIKE SY-SUBRC.
  LOCAL: VBUK_KEIN_KREDITCHECK,
         VBUK_KREDIT_VFP.

  IF T180-TRTYP NE CHARH.
* Check the subsequent functions for the old state of the SO
    SORT YVBUK BY VBELN.
    READ TABLE YVBUK
          WITH KEY VBELN = VBAK-VBELN BINARY SEARCH.
    IF SY-SUBRC = 0.
      DA_VBUK = YVBUK.
    ELSE.
      PERFORM XVBUK_LESEN(SAPFV45K) USING VBAK-VBELN.
      DA_VBUK = XVBUK.
    ENDIF.
    PERFORM SUBSEQ_ALLOWED_AVAIL USING *VBAK
                                       DA_VBUK
                              CHANGING DA_SUBRC.
  ENDIF.
* Check the subsequent functions for the current state of the SO
  IF DA_SUBRC = 0.
    PERFORM XVBUK_LESEN(SAPFV45K) USING VBAK-VBELN.
    DA_VBUK = XVBUK.
    PERFORM SUBSEQ_ALLOWED_AVAIL USING VBAK
                                       DA_VBUK
                              CHANGING DA_SUBRC.
  ENDIF.
  IF DA_SUBRC NE 0.
    VBUK_KEIN_KREDITCHECK = CHARY.
    VBUK_KREDIT_VFP       = CHARX.
    CREDIT_CHECK_CCARD_SIMUL_MODE = CHARX.    " bvfp runs in simul. mode
    PERFORM FCODE_BVFP(SAPMV45A).
    CREDIT_CHECK_CCARD_SIMUL_MODE = SPACE.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SUBSEQ_ALLOWED_AVAIL
*&---------------------------------------------------------------------*
*       Check subsequent functions for availibility
*----------------------------------------------------------------------*
*      <--P_DA_SUBRC  0 Okay                                           *
*                   <>0 Not okay                                       *
*----------------------------------------------------------------------*
FORM SUBSEQ_ALLOWED_AVAIL USING US_VBAK STRUCTURE VBAK       "CCARD
                                US_VBUK STRUCTURE VBUK
                       CHANGING CH_SUBRC LIKE SY-SUBRC.

  CLEAR CH_SUBRC.

* fofun_beda_verfuegbar
  CALL FUNCTION 'SD_ORDER_SUBSEQUENT_ALLOWED'
       EXPORTING
            BVBAK                   = US_VBAK
            BVBUK                   = US_VBUK
            FOFUN                   = FOFUN_BEDA_VERFUEGBAR
       EXCEPTIONS
            WARNING                 = 0
            ERROR_BUT_DO_NOT_DELETE = 0
            ERROR                   = 1.
  IF SY-SUBRC NE 0.
    CH_SUBRC = SY-SUBRC.
    EXIT.
  ENDIF.

* Loop über die führenden Einteilungen
  LOOP AT XVBEP WHERE WMENG GT 0
                  AND UPDKZ NE UPDKZ_DELETE.

    SVBEP-TABIX = SY-TABIX.
* Übergabestrukturen füllen
    PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING XVBEP-POSNR
                                               SVBAP-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    VBUP = XVBUP.
    PERFORM VBEP_BEARBEITEN_VORBEREITEN(SAPFV45E).

* fofun_banf
    IF NOT TVEP-BSART IS INITIAL.
* Prüfen, ob Banf-Bearbeitung erlaubt
      CALL FUNCTION 'SD_ORDER_SUBSEQUENT_ALLOWED'
           EXPORTING
                BVBAK                   = US_VBAK
                BVBUK                   = US_VBUK
                BTVEP                   = TVEP
                BTVAP                   = TVAP
                BVBAP                   = VBAP
                BVBEP                   = VBEP
                BVBUP                   = VBUP
                FOFUN                   = FOFUN_BANF
           EXCEPTIONS
                WARNING                 = 0
                ERROR_BUT_DO_NOT_DELETE = 0
                ERROR                   = 1.
      IF SY-SUBRC NE 0.
        CH_SUBRC = SY-SUBRC.
        EXIT.                      " exit from loop
      ENDIF.
    ELSE.                               " also nicht BANF
      PERFORM T459K_LESEN.
      IF NOT T459K-MNTGA IS INITIAL.
* fofun_montagesperre
        CALL FUNCTION 'SD_ORDER_SUBSEQUENT_ALLOWED'
           EXPORTING
                BVBAK                   = US_VBAK
                BVBUK                   = US_VBUK
                BTVEP                   = TVEP
                BTVAP                   = TVAP
                BVBAP                   = VBAP
                BVBEP                   = VBEP
                BVBUP                   = VBUP
                FOFUN                   = FOFUN_MONTAGESPERRE
           EXCEPTIONS
                WARNING                 = 0
                ERROR_BUT_DO_NOT_DELETE = 0
                ERROR                   = 1.
        IF SY-SUBRC NE 0.
          CH_SUBRC = SY-SUBRC.
          EXIT.                      " exit from loop
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF CH_SUBRC NE 0.
    EXIT.                        " exit from FORM
  ENDIF.

ENDFORM.                               " SUBSEQ_ALLOWED_AVAIL