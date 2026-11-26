*&---------------------------------------------------------------------*
*&  Include           ZPPC_UP_CREATE_PROD_VER_F01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PROD_VER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CREATE_PROD_VER .
* begin add by pst_hisar option for call transaction
  DATA : OPT LIKE CTU_PARAMS.
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.
*  end add by pst_hisar
  IF FPATH IS INITIAL.
    MESSAGE 'Please input a file' TYPE 'I'.
  ELSE.
    CLEAR FNAME.
    MOVE FPATH TO FNAME.
    MOVE FPATH TO P_FILE.

    "CHECK EKSTENSION OF FILE.
    SHIFT P_FILE RIGHT CIRCULAR BY 3 PLACES.
    MOVE P_FILE(3) TO EKS.

    IF EKS = 'TXT' OR  EKS = 'txt'.
      REFRESH  : IT_HPVER , IT_IPVER.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME            = FNAME
          FILETYPE            = 'ASC'
          HAS_FIELD_SEPARATOR = 'X'
        TABLES
          DATA_TAB            = IT_HPVER.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.

        IT_IPVER[] = IT_HPVER[].

        SORT IT_HPVER BY  WERKS MATNR.
        DELETE ADJACENT DUPLICATES FROM IT_HPVER COMPARING WERKS MATNR.

        LOOP AT IT_HPVER.
*          begin add by pst_hisar for delete current production version
          IF CH EQ 'X'.
            PERFORM F_DEL_CURRENP_PROD_VER  USING IT_HPVER-WERKS IT_HPVER-MATNR.
          ENDIF.
          REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.
*          end add by pst_hisar
          PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ENTE'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'MKAL-PLNNR'.
          PERFORM BDC_FIELD       USING 'MKAL-WERKS'
                                        IT_HPVER-WERKS.
          PERFORM BDC_FIELD       USING 'MKAL-MATNR'
                                        IT_HPVER-MATNR.
          PERFORM BDC_FIELD       USING 'MKAL-PLNNR'
                                        ''.

          CLEAR : COUNTER.
          LOOP AT IT_IPVER WHERE WERKS = IT_HPVER-WERKS AND MATNR = IT_HPVER-MATNR.

            CLEAR N.

            COUNTER = COUNTER + 1.
            MOVE COUNTER TO N.
            SHIFT N LEFT DELETING LEADING ''.
            IF N GT 9.
              PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=P+'.
              COUNTER = 2.
              MOVE COUNTER TO N.
              SHIFT N LEFT DELETING LEADING ''.
            ENDIF.

            IF COUNTER < 10.
              CONCATENATE CPLNTY '(0' N ')' INTO VPLNTY.
              CONCATENATE CMATNR '(0' N ')' INTO VMATNR.
              CONCATENATE CVERID '(0' N ')' INTO VVERID.
              CONCATENATE CTEXT1 '(0' N ')' INTO VTEXT1.
              CONCATENATE CADATU '(0' N ')' INTO VADATU.
              CONCATENATE CBDATU '(0' N ')' INTO VBDATU.
              CONCATENATE CSTLAL '(0' N ')' INTO VSTLAL.
              CONCATENATE CSTLAN '(0' N ')' INTO VSTLAN.
              CONCATENATE CPLNNR '(0' N ')' INTO VPLNNR.
              CONCATENATE CALNAL '(0' N ')' INTO VALNAL.
              CONCATENATE CMARK '(0' N ')' INTO VMARK.
            ELSE.
              CONCATENATE CPLNTY '(' N ')' INTO VPLNTY.
              CONCATENATE CMATNR '(' N ')' INTO VMATNR.
              CONCATENATE CVERID '(' N ')' INTO VVERID.
              CONCATENATE CTEXT1 '(' N ')' INTO VTEXT1.
              CONCATENATE CADATU '(' N ')' INTO VADATU.
              CONCATENATE CBDATU '(' N ')' INTO VBDATU.
              CONCATENATE CSTLAL '(' N ')' INTO VSTLAL.
              CONCATENATE CSTLAN '(' N ')' INTO VSTLAN.
              CONCATENATE CPLNNR '(' N ')' INTO VPLNNR.
              CONCATENATE CALNAL '(' N ')' INTO VALNAL.
            ENDIF.


            PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=ENTE'.
            PERFORM BDC_FIELD       USING 'MKAL-MATNR'
                                          IT_IPVER-MATNR.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'MKAL_EXPAND-BDATU(01)'.
            PERFORM BDC_FIELD       USING VMATNR
                                          IT_IPVER-MATNR.
            PERFORM BDC_FIELD       USING VVERID
                                          IT_IPVER-VERID.
            PERFORM BDC_FIELD       USING VTEXT1
                                          IT_IPVER-TEXT1.

            CLEAR : DD, MM,YYYY, DATE.
            SPLIT IT_IPVER-ADATU  AT '.' INTO DD MM YYYY.
            CONCATENATE DD MM YYYY INTO DATE.
            PERFORM BDC_FIELD       USING VADATU
                                          DATE.

            CLEAR : DD, MM,YYYY, DATE.
            SPLIT IT_IPVER-BDATU  AT '.' INTO DD MM YYYY.
            CONCATENATE DD MM YYYY INTO DATE.
            PERFORM BDC_FIELD       USING VBDATU
                                          DATE.

            PERFORM BDC_FIELD       USING VSTLAL
                                          IT_IPVER-STLAL.
            PERFORM BDC_FIELD       USING VSTLAN
                                          IT_IPVER-STLAN.
            PERFORM BDC_FIELD       USING VPLNNR
                                          IT_IPVER-PLNNR.
            PERFORM BDC_FIELD       USING VALNAL
                                          IT_IPVER-ALNAL.
            PERFORM BDC_FIELD       USING VPLNTY
                                          IT_IPVER-PLNTY.

            PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=PRFG'.
            PERFORM BDC_FIELD       USING VMARK
                                          'X'.


            PERFORM BDC_DYNPRO      USING 'SAPMSSY0' '0120'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=BACK'.
          ENDLOOP.

          PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=SAVE'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'MKAL-WERKS'.

          PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/EBACK'.

          CALL TRANSACTION 'C223' USING IT_BDCDATA
                      OPTIONS FROM OPT
                      MESSAGES INTO IT_BDCMSGCOLL.

          READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
          IF SY-SUBRC <> 0.
            COMMIT WORK AND WAIT.
            IT_HPVER-ZDESC = 'Sukses'.
            IT_HPVER-ZSTAT = GCF_S1 .
          ELSE.
            IT_HPVER-ZDESC = 'Gagal'.
            IT_HPVER-ZSTAT = GCF_E1 .
          ENDIF.

          MODIFY IT_HPVER.
        ENDLOOP.
        PERFORM F_DISPLAY_DATA.

      ENDIF.
    ELSE.
      MESSAGE 'Please upload only .txt file' TYPE 'I'.
      MOVE FPATH TO P_FILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CREATE_PROD_VER


*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0327   text
*      -->P_IT_RHEADER_KAPART  text
*----------------------------------------------------------------------*
FORM BDC_FIELD  USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    " BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0337   text
*      -->P_0338   text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO  USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    " BDC_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DISPLAY_DATA .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HPVER' :
    'WERKS' '' ''  '' ''  'Plant'      '' ' ' '' '',
    'MATNR' '' ''  '' ''  'Material'      '' ' ' '' '',
    'VERID' '' ''  '' ''  'Prod. Version'     '' ' ' '' '',
    'ZDESC'   '' ''  '' ''  'Deskripsi'      '' ' ' '' '',
    'ZSTAT'   '' ''  '' ''  'Status'      '' ' ' '' ''.

ENDFORM.                    " F_FIELD_CATALOG


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " F_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_USER_COMMAND = ''
      IS_LAYOUT               = WA_LAYOUT
      IT_FIELDCAT             = T_FIELDCAT[]
      IT_EVENTS               = T_EVENTS[]
      IT_EVENT_EXIT           = T_EVENT_EXIT[]
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
      IS_VARIANT              = WA_VARIANTE
      IS_PRINT                = T_PRINT
      IT_SORT                 = T_SORT[]
      IT_EXCLUDING            = T_EXCLUDING[]
      I_BYPASSING_BUFFER      = 'X'
    TABLES
      T_OUTTAB                = IT_HPVER
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL
*&---------------------------------------------------------------------*
*&      Form  F_DEL_CURRENP_PROD_VER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_HPVER_WERKS  text
*      -->P_IT_HPVER_MATNR  text
*----------------------------------------------------------------------*
FORM F_DEL_CURRENP_PROD_VER  USING    P_IT_HPVER_WERKS
                                      P_IT_HPVER_MATNR.
  DATA : OPT LIKE CTU_PARAMS.
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.
  REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.
  PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'MKAL-MATNR'.
  PERFORM BDC_FIELD       USING 'MKAL-WERKS'
                                P_IT_HPVER_WERKS.
  PERFORM BDC_FIELD       USING 'MKAL-MATNR'
                                P_IT_HPVER_MATNR.
  PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=MAAL'.
  PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=DELE'.
  PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=YES'.
  PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SAVE'.
  PERFORM BDC_DYNPRO      USING 'SAPLCMFV' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/EBACK'.
  CALL TRANSACTION 'C223' USING IT_BDCDATA
                      OPTIONS FROM OPT
                      MESSAGES INTO IT_BDCMSGCOLL.

ENDFORM.                    " F_DEL_CURRENP_PROD_VER