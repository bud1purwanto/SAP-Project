*&---------------------------------------------------------------------*
*&  Include           ZPPI_UPLOAD_MASTERRECIPE_F01
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  CALL SCREEN 200. "100.  "change New company

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_CREATE
*&---------------------------------------------------------------------*
*      Upload Create
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UPLOAD_CREATE_SR .

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
      REFRESH : IT_IMR, IT_HMR.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME            = FNAME
          FILETYPE            = 'ASC'
          HAS_FIELD_SEPARATOR = 'X'
        TABLES
          DATA_TAB            = IT_HMR.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.

        IT_IMR[] = IT_HMR[].


        SORT IT_HMR BY PLNNR MATNR WERKS PLNAL.
        DELETE ADJACENT DUPLICATES FROM IT_HMR COMPARING PLNNR MATNR WERKS PLNAL.

*        BREAK-POINT.
        LOOP AT IT_HMR.

          CLEAR VPLNNR.
          SELECT SINGLE PLNNR
            FROM PLKO
            INTO VPLNNR
            WHERE PLKO~PLNNR = IT_HMR-PLNNR
            AND PLKO~PLNAL = IT_HMR-PLNAL.

          IF SY-SUBRC = 0.
            IT_HMR-ZDESC = 'Gagal, Master Recipe sudah di-create sebelumnya'.
            IT_HMR-ZSTAT = GCF_E1 .
          ELSE.


            REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.

            PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4000'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RC271-PROFIDNETZ'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM BDC_FIELD       USING 'RC271-PLNNR'
                                          IT_HMR-PLNNR.
            PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                          IT_HMR-MATNR.
            PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                          IT_HMR-WERKS.
            PERFORM BDC_FIELD       USING 'RC271-PROFIDNETZ'
                                          'ZP01'.

            CLEAR : DATE.
            CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM+0(4) INTO DATE.


            PERFORM BDC_FIELD       USING 'RC271-STTAG'
                                          DATE.

            REFRESH ITTEMP.

            ITTEMP[] = IT_IMR[].
            LOOP AT ITTEMP WHERE PLNNR = IT_HMR-PLNNR AND MATNR =  IT_HMR-MATNR
                           AND    WERKS  = IT_HMR-WERKS  AND PLNAL = IT_HMR-PLNAL.

              ITTEMP-FLAG = 'X'.
              MODIFY ITTEMP.
            ENDLOOP.

            DELETE ITTEMP WHERE FLAG <> 'X'.
            CLEAR VLINE.
            DESCRIBE TABLE ITTEMP LINES VLINE.

            PERFORM BDC_DYNPRO      USING 'SAPLCPDA' '4210'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'PLKOD-STATU'.
            IF VLINE = 1.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=BU'.

              PERFORM BDC_FIELD       USING 'PLKOD-PLNAL'
                                           IT_HMR-PLNAL.
              PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                            '1'.
              PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                            '4'.
              PERFORM BDC_FIELD       USING 'PLKOD-BMSCH'
                                            '1.000'.
            ELSE.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=VOUE'.
              PERFORM BDC_FIELD       USING 'PLKOD-PLNAL'
                                            IT_HMR-PLNAL.
              PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                           '1'.
              PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                            '4'.
              PERFORM BDC_FIELD       USING 'PLKOD-BMSCH'
                                            '1.000'.

              PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'PLPOD-MEINH(02)'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=ENT1'.

              CLEAR COUNTER.
              LOOP AT IT_IMR WHERE  PLNNR = IT_HMR-PLNNR AND MATNR =  IT_HMR-MATNR
                             AND    WERKS  = IT_HMR-WERKS  AND PLNAL = IT_HMR-PLNAL.

                CLEAR : N.
                COUNTER = COUNTER + 1.

                MOVE COUNTER TO N.
                SHIFT N LEFT DELETING LEADING ''.

                IF COUNTER < 10.
                  CONCATENATE CPVZNR '(0' N ')' INTO VPVZNR.
                  CONCATENATE CPHFLG '(0' N ')' INTO VPHFLG.
                  CONCATENATE CPHSEQ '(0' N ')' INTO VPHSEQ.
                  CONCATENATE CARBPL '(0' N ')' INTO VARBPL.
                  CONCATENATE CSTEUS '(0' N ')' INTO VSTEUS.
                  CONCATENATE CBMSCH '(0' N ')' INTO VBMSCH.
                  CONCATENATE CMEINH '(0' N ')' INTO VMEINH.
                  CONCATENATE CVGW01 '(0' N ')' INTO VVGW01.
                  CONCATENATE CVGE01 '(0' N ')' INTO VVGE01.
                  CONCATENATE CVGW02 '(0' N ')' INTO VVGW02.
                  CONCATENATE CVGE02 '(0' N ')' INTO VVGE02.
                  CONCATENATE CVGW03 '(0' N ')' INTO VVGW03.
                  CONCATENATE CVGE03 '(0' N ')' INTO VVGE03.
                  CONCATENATE CVGW04 '(0' N ')' INTO VVGW04.
                  CONCATENATE CVGE04 '(0' N ')' INTO VVGE04.
                  CONCATENATE CVGW05 '(0' N ')' INTO VVGW05.
                  CONCATENATE CVGE05 '(0' N ')' INTO VVGE05.
                  CONCATENATE CVGW06 '(0' N ')' INTO VVGW06.
                  CONCATENATE CVGE06 '(0' N ')' INTO VVGE06.
                ELSE.
                  CONCATENATE CPVZNR '(' N ')' INTO VPVZNR.
                  CONCATENATE CPHFLG '(' N ')' INTO VPHFLG.
                  CONCATENATE CPHSEQ '(' N ')' INTO VPHSEQ.
                  CONCATENATE CARBPL '(' N ')' INTO VARBPL.
                  CONCATENATE CSTEUS '(' N ')' INTO VSTEUS.
                  CONCATENATE CBMSCH '(' N ')' INTO VBMSCH.
                  CONCATENATE CMEINH '(' N ')' INTO VMEINH.
                  CONCATENATE CVGW01 '(' N ')' INTO VVGW01.
                  CONCATENATE CVGE01 '(' N ')' INTO VVGE01.
                  CONCATENATE CVGW02 '(' N ')' INTO VVGW02.
                  CONCATENATE CVGE02 '(' N ')' INTO VVGE02.
                  CONCATENATE CVGW03 '(' N ')' INTO VVGW03.
                  CONCATENATE CVGE03 '(' N ')' INTO VVGE03.
                  CONCATENATE CVGW04 '(' N ')' INTO VVGW04.
                  CONCATENATE CVGE04 '(' N ')' INTO VVGE04.
                  CONCATENATE CVGW05 '(' N ')' INTO VVGW05.
                  CONCATENATE CVGE05 '(' N ')' INTO VVGE05.
                  CONCATENATE CVGW06 '(' N ')' INTO VVGW06.
                  CONCATENATE CVGE06 '(' N ')' INTO VVGE06.
                ENDIF.

                PERFORM BDC_FIELD       USING VPVZNR IT_IMR-PVZNR.
                PERFORM BDC_FIELD       USING VPHSEQ IT_IMR-PHSEQ.
                PERFORM BDC_FIELD       USING VARBPL IT_IMR-ARBPL.
                PERFORM BDC_FIELD       USING VSTEUS IT_IMR-STEUS.

                IF COUNTER = 2.
                  PERFORM BDC_FIELD       USING VBMSCH IT_IMR-BMSCH.
                  PERFORM BDC_FIELD       USING VMEINH IT_IMR-MEINH.
                  PERFORM BDC_FIELD       USING VPHFLG IT_IMR-PHFLG.
                  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
                  PERFORM BDC_FIELD       USING 'BDC_CURSOR' 'PLPOD-VORNR(03)'.
                  PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=BU'.


                  IF IT_HMR-PLNNR CP '*JR*' OR IT_HMR-PLNNR CP '*SR*'.

                    PERFORM BDC_FIELD       USING VVGW01 IT_IMR-VGW01.
                    PERFORM BDC_FIELD       USING VVGE01 IT_IMR-VGE01.
                    PERFORM BDC_FIELD       USING VVGW02 IT_IMR-VGW02.
                    PERFORM BDC_FIELD       USING VVGE02 IT_IMR-VGE02.

                    IF IT_HMR-PLNNR CP '*JR*'.
                      PERFORM BDC_FIELD       USING VVGW03 IT_IMR-VGW03.
                      PERFORM BDC_FIELD       USING VVGE03 IT_IMR-VGE03.
                      PERFORM BDC_FIELD       USING VVGW04 IT_IMR-VGW04.
                      PERFORM BDC_FIELD       USING VVGE04 IT_IMR-VGE04.
                      PERFORM BDC_FIELD       USING VVGW05 IT_IMR-VGW05.
                      PERFORM BDC_FIELD       USING VVGE05 IT_IMR-VGE05.
                      PERFORM BDC_FIELD       USING VVGW06 IT_IMR-VGW06.
                      PERFORM BDC_FIELD       USING VVGE06 IT_IMR-VGE06.
                    ENDIF.

                    IF IT_HMR-PLNNR CP '*SR*' AND IT_HMR-WERKS = 'TTE'.   "ADDED BY FATHIR ON 05.10.2020 - Add activity for SR Master Recipe TTE
                      PERFORM BDC_FIELD       USING VVGW03 IT_IMR-VGW03.
                      PERFORM BDC_FIELD       USING VVGE03 IT_IMR-VGE03.
                      PERFORM BDC_FIELD       USING VVGW04 IT_IMR-VGW04.
                      PERFORM BDC_FIELD       USING VVGE04 IT_IMR-VGE04.
                      PERFORM BDC_FIELD       USING VVGW05 IT_IMR-VGW05.
                      PERFORM BDC_FIELD       USING VVGE05 IT_IMR-VGE05.
                      PERFORM BDC_FIELD       USING VVGW06 IT_IMR-VGW06.
                      PERFORM BDC_FIELD       USING VVGE06 IT_IMR-VGE06.
                    ENDIF.

                  ELSEIF IT_HMR-PLNNR CP 'M*'.
                    PERFORM BDC_FIELD       USING VVGW01 IT_IMR-VGW01.
                    PERFORM BDC_FIELD       USING VVGE01 IT_IMR-VGE01.
                  ENDIF.

                ENDIF.

              ENDLOOP.

            ENDIF.

            CALL TRANSACTION 'C201' USING IT_BDCDATA
                          MODE 'E'
                          UPDATE 'S'
                          MESSAGES INTO IT_BDCMSGCOLL.

            READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
            IF SY-SUBRC <> 0.
              COMMIT WORK AND WAIT.
              IT_HMR-ZDESC = 'Sukses'.
              IT_HMR-ZSTAT = GCF_S1 .
            ELSE.
              IT_HMR-ZDESC = 'Gagal'.
              IT_HMR-ZSTAT = GCF_E1 .
            ENDIF.
          ENDIF.
          MODIFY IT_HMR.
        ENDLOOP.

        PERFORM F_DISPLAY_DATA.

        MOVE FPATH TO P_FILE.
      ENDIF.
    ELSE.
      MESSAGE 'Please upload only .txt file' TYPE 'I'.
      MOVE FPATH TO P_FILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_UPLOAD_CREATE


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
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DISPLAY_DATA .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DISPLAY_DATA2.
  PERFORM F_FIELD_CATALOG2.
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
FORM F_FIELD_CATALOG.
  REFRESH: T_FIELDCAT.

  IF RB3 = 'X'.
    PERFORM F_ALV_FIELDCATG_ICON USING 'IT_DELHMR' :
    'PLNNR' '' ''  '' ''  'Group'      '' ' ' '' '',
    'MATNR' '' ''  '' ''  'Material'      '' ' ' '' '',
    'WERKS' '' ''  '' ''  'Plant'     '' ' ' '' '',
    'PLNAL' '' ''  '' ''  'Recipe'     '' ' ' '' '',
    'ZDESC'   '' ''  '' ''  'Description'      '' ' ' '' '',
    'ZSTAT'   '' ''  '' ''  'Status'      '' ' ' '' ''.
  ELSE.
    PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HMR' :
    'PLNNR' '' ''  '' ''  'Group'      '' ' ' '' '',
    'MATNR' '' ''  '' ''  'Material'      '' ' ' '' '',
    'WERKS' '' ''  '' ''  'Plant'     '' ' ' '' '',
    'PLNAL' '' ''  '' ''  'Recipe'     '' ' ' '' '',
    'ZDESC'   '' ''  '' ''  'Description'      '' ' ' '' '',
    'ZSTAT'   '' ''  '' ''  'Status'      '' ' ' '' ''.
  ENDIF.


ENDFORM.                    " F_FIELD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG2.
  REFRESH: T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HMR' :
    'MATNR' '' ''  '' ''  'Material'      '' ' ' '' '',
    'WERKS' '' ''  '' ''  'Plant'     '' ' ' '' '',
    'PLNAL' '' ''  '' ''  'Recipe'     '' ' ' '' '',
    'ZDESC'   '' ''  '' ''  'Description'      '' ' ' '' '',
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

  IF RB3 = 'X'.
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
        T_OUTTAB                = IT_DELHMR
      EXCEPTIONS
        PROGRAM_ERROR           = 1
        OTHERS                  = 2.
  ELSE.
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
        T_OUTTAB                = IT_HMR
      EXCEPTIONS
        PROGRAM_ERROR           = 1
        OTHERS                  = 2.
  ENDIF.


ENDFORM.                    " F_LIST_DETAIL


*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_CREATE_CR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UPLOAD_CREATE_CR .
  DATA : IITEM TYPE I,
         VITEM TYPE VORNR.

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
      REFRESH :IT_IMR, IT_HMR.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME            = FNAME
          FILETYPE            = 'ASC'
          HAS_FIELD_SEPARATOR = 'X'
        TABLES
          DATA_TAB            = IT_HMR.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.

        IT_IMR[] = IT_HMR[].


        SORT IT_HMR BY PLNNR MATNR WERKS PLNAL.
        DELETE ADJACENT DUPLICATES FROM IT_HMR COMPARING PLNNR MATNR WERKS PLNAL.

        LOOP AT IT_HMR.
          CLEAR VPLNNR.
          SELECT SINGLE PLNNR
            FROM PLKO
            INTO VPLNNR
            WHERE PLKO~PLNNR = IT_HMR-PLNNR
            AND PLKO~PLNAL = IT_HMR-PLNAL.

          IF SY-SUBRC = 0.
            IT_HMR-ZDESC = 'Gagal, Master Recipe sudah di-create sebelumnya'.
            IT_HMR-ZSTAT = GCF_E1 .
          ELSE.
            REFRESH ITTEMP.

            ITTEMP[] = IT_IMR[].
            LOOP AT ITTEMP WHERE PLNNR = IT_HMR-PLNNR AND MATNR =  IT_HMR-MATNR
                           AND    WERKS  = IT_HMR-WERKS  AND PLNAL = IT_HMR-PLNAL.

              ITTEMP-FLAG = 'X'.
              MODIFY ITTEMP.
            ENDLOOP.

            DELETE ITTEMP WHERE FLAG <> 'X'.
            CLEAR VLINE.
            DESCRIBE TABLE ITTEMP LINES VLINE.

            REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.

            PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4000'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RC271-PROFIDNETZ'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                          IT_HMR-MATNR.
            PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                          IT_HMR-WERKS.
            PERFORM BDC_FIELD       USING 'RC271-PROFIDNETZ'
                                          'ZP01'.

            PERFORM BDC_DYNPRO      USING 'SAPLCPDA' '4210'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'PLKOD-STATU'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=VOUE'.
            PERFORM BDC_FIELD       USING 'PLKOD-PLNAL'
                                           IT_HMR-PLNAL.
            PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                          '1'.
            PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                          '4'.
            CLEAR : IITEM, COUNTER.
            LOOP AT IT_IMR WHERE  PLNNR = IT_HMR-PLNNR AND MATNR =  IT_HMR-MATNR
                           AND    WERKS  = IT_HMR-WERKS  AND PLNAL = IT_HMR-PLNAL.

              CLEAR : N.
              COUNTER = COUNTER + 1.

              MOVE COUNTER TO N.
              SHIFT N LEFT DELETING LEADING ''.

              IF COUNTER < 10.
                CONCATENATE CPVZNR '(0' N ')' INTO VPVZNR.
                CONCATENATE CPHFLG '(0' N ')' INTO VPHFLG.
                CONCATENATE CPHSEQ '(0' N ')' INTO VPHSEQ.
                CONCATENATE CARBPL '(0' N ')' INTO VARBPL.
                CONCATENATE CSTEUS '(0' N ')' INTO VSTEUS.
                CONCATENATE CLTXA1 '(0' N ')' INTO VLTXA1.
                CONCATENATE CBMSCH '(0' N ')' INTO VBMSCH.
                CONCATENATE CMEINH '(0' N ')' INTO VMEINH.
                CONCATENATE CVGW01 '(0' N ')' INTO VVGW01.
                CONCATENATE CVGE01 '(0' N ')' INTO VVGE01.
                CONCATENATE CVGW02 '(0' N ')' INTO VVGW02.
                CONCATENATE CVGE02 '(0' N ')' INTO VVGE02.
                CONCATENATE CVGW03 '(0' N ')' INTO VVGW03.
                CONCATENATE CVGE03 '(0' N ')' INTO VVGE03.
                CONCATENATE CVGW04 '(0' N ')' INTO VVGW04.
                CONCATENATE CVGE04 '(0' N ')' INTO VVGE04.
                CONCATENATE CVGW05 '(0' N ')' INTO VVGW05.
                CONCATENATE CVGE05 '(0' N ')' INTO VVGE05.
                CONCATENATE CVGW06 '(0' N ')' INTO VVGW06.
                CONCATENATE CVGE06 '(0' N ')' INTO VVGE06.
              ELSE.
                CONCATENATE CPVZNR '(' N ')' INTO VPVZNR.
                CONCATENATE CPHFLG '(' N ')' INTO VPHFLG.
                CONCATENATE CPHSEQ '(' N ')' INTO VPHSEQ.
                CONCATENATE CARBPL '(' N ')' INTO VARBPL.
                CONCATENATE CSTEUS '(' N ')' INTO VSTEUS.
                CONCATENATE CLTXA1 '(' N ')' INTO VLTXA1.
                CONCATENATE CBMSCH '(' N ')' INTO VBMSCH.
                CONCATENATE CMEINH '(' N ')' INTO VMEINH.
                CONCATENATE CVGW01 '(' N ')' INTO VVGW01.
                CONCATENATE CVGE01 '(' N ')' INTO VVGE01.
                CONCATENATE CVGW02 '(' N ')' INTO VVGW02.
                CONCATENATE CVGE02 '(' N ')' INTO VVGE02.
                CONCATENATE CVGW03 '(' N ')' INTO VVGW03.
                CONCATENATE CVGE03 '(' N ')' INTO VVGE03.
                CONCATENATE CVGW04 '(' N ')' INTO VVGW04.
                CONCATENATE CVGE04 '(' N ')' INTO VVGE04.
                CONCATENATE CVGW05 '(' N ')' INTO VVGW05.
                CONCATENATE CVGE05 '(' N ')' INTO VVGE05.
                CONCATENATE CVGW06 '(' N ')' INTO VVGW06.
                CONCATENATE CVGE06 '(' N ')' INTO VVGE06.
              ENDIF.

              "-ITEM
              IF ( SY-TABIX MOD 2 = 0 ).
                IITEM = IITEM + 10.
                CLEAR VITEM.
                MOVE IITEM TO VITEM.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    INPUT  = VITEM
                  IMPORTING
                    OUTPUT = VITEM.

              ENDIF.

              PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'PLPOD-MEINH(02)'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=ENT1'.

              IF COUNTER = 1 OR COUNTER = 3 OR COUNTER = 5.
                PERFORM BDC_FIELD       USING VARBPL IT_IMR-ARBPL.
                PERFORM BDC_FIELD       USING VSTEUS IT_IMR-STEUS.
                PERFORM BDC_FIELD       USING VPHSEQ IT_IMR-PHSEQ.
              ELSE.
                PERFORM BDC_FIELD       USING VPHFLG IT_IMR-PHFLG.
                PERFORM BDC_FIELD       USING VPVZNR IT_IMR-PVZNR.
                PERFORM BDC_FIELD       USING VPHSEQ IT_IMR-PHSEQ.
                PERFORM BDC_FIELD       USING VARBPL IT_IMR-ARBPL.
                PERFORM BDC_FIELD       USING VLTXA1 IT_IMR-LTXA1.

                IF VLINE = 6.
                  IF COUNTER = 2.
                    PERFORM BDC_FIELD       USING VSTEUS IT_IMR-STEUS.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
                    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                  'PLPOD-ARBPL(03)'.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=ENT1'.


                    PERFORM BDC_FIELD       USING VVGW01 IT_IMR-VGW01.
                    PERFORM BDC_FIELD       USING VVGE01 IT_IMR-VGE01.
                    PERFORM BDC_FIELD       USING VVGW02 IT_IMR-VGW02.
                    PERFORM BDC_FIELD       USING VVGE02 IT_IMR-VGE02.

                    PERFORM BDC_FIELD       USING VVGW03 IT_IMR-VGW03.
                    PERFORM BDC_FIELD       USING VVGE03 IT_IMR-VGE03.
                    PERFORM BDC_FIELD       USING VVGW04 IT_IMR-VGW04.
                    PERFORM BDC_FIELD       USING VVGE04 IT_IMR-VGE04.
                    PERFORM BDC_FIELD       USING VVGW05 IT_IMR-VGW05.
                    PERFORM BDC_FIELD       USING VVGE05 IT_IMR-VGE05.

                  ELSE.
                    PERFORM BDC_FIELD       USING VSTEUS 'ZP01'.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
                    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                  VSTEUS.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=PICK'.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4410'.
                    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                  'PLPOD-VORNR'.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=VOAG'.
                    PERFORM BDC_FIELD       USING 'PLPOD-STEUS'
                                'ZP01'.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4420'.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '/00'.
                    PERFORM BDC_FIELD       USING 'PLPOD-EKORG'
                                                  IT_IMR-EKORG.
                    PERFORM BDC_FIELD       USING 'PLPOD-MATKL'
                                                  IT_IMR-MATKL.
                    PERFORM BDC_FIELD       USING 'PLPOD-EKGRP'
                                                  IT_IMR-EKGRP.
                    PERFORM BDC_FIELD       USING 'PLPOD-LIFNR'
                                                  IT_IMR-LIFNR.
                    PERFORM BDC_FIELD       USING 'PLPOD-PLIFZ'
                                                  IT_IMR-PLIFZ.
                    PERFORM BDC_FIELD       USING 'PLPOD-PEINH'
                                                  IT_IMR-PEINH.
                    PERFORM BDC_FIELD       USING 'PLPOD-SAKTO'
                                                  IT_IMR-SAKTO.
                    PERFORM BDC_FIELD       USING 'PLPOD-PREIS'
                                                  IT_IMR-PREIS.
                    PERFORM BDC_FIELD       USING 'PLPOD-WAERS'
                                                  IT_IMR-WAERS.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4420'.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=BACK'.
                    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
                    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                  VSTEUS.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=ENT1'.
                    PERFORM BDC_FIELD       USING VSTEUS IT_IMR-STEUS.
                  ENDIF.

                ELSE.
                  IF COUNTER = 2 OR COUNTER = 4.
                    " Add by Stefan - Paper Core Enhancement - 02.04.20
                    IF COUNTER = 2.
                      PERFORM BDC_FIELD       USING VSTEUS IT_IMR-STEUS.
                      PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
                      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                    'PLPOD-ARBPL(03)'.
                      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                    '=ENT1'.
                      PERFORM BDC_FIELD       USING VVGW01 IT_IMR-VGW01.
                      PERFORM BDC_FIELD       USING VVGE01 IT_IMR-VGE01.
                      PERFORM BDC_FIELD       USING VVGW02 IT_IMR-VGW02.
                      PERFORM BDC_FIELD       USING VVGE02 IT_IMR-VGE02.
                      PERFORM BDC_FIELD       USING VVGW03 IT_IMR-VGW03.
                      PERFORM BDC_FIELD       USING VVGE03 IT_IMR-VGE03.
                      PERFORM BDC_FIELD       USING VVGW04 IT_IMR-VGW04.
                      PERFORM BDC_FIELD       USING VVGE04 IT_IMR-VGE04.
                      PERFORM BDC_FIELD       USING VVGW05 IT_IMR-VGW05.
                      PERFORM BDC_FIELD       USING VVGE05 IT_IMR-VGE05.
                    ENDIF.

                    PERFORM BDC_FIELD       USING VSTEUS 'ZP01'.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
                    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                  VSTEUS.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=PICK'.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4410'.
                    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                  'PLPOD-VORNR'.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=VOAG'.
                    PERFORM BDC_FIELD       USING 'PLPOD-STEUS'
                                'ZP01'.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4420'.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '/00'.
                    PERFORM BDC_FIELD       USING 'PLPOD-EKORG'
                                                  IT_IMR-EKORG.
                    PERFORM BDC_FIELD       USING 'PLPOD-MATKL'
                                                  IT_IMR-MATKL.
                    PERFORM BDC_FIELD       USING 'PLPOD-EKGRP'
                                                  IT_IMR-EKGRP.
                    PERFORM BDC_FIELD       USING 'PLPOD-LIFNR'
                                                  IT_IMR-LIFNR.
                    PERFORM BDC_FIELD       USING 'PLPOD-PLIFZ'
                                                  IT_IMR-PLIFZ.
                    PERFORM BDC_FIELD       USING 'PLPOD-PEINH'
                                                  IT_IMR-PEINH.
                    PERFORM BDC_FIELD       USING 'PLPOD-SAKTO'
                                                  IT_IMR-SAKTO.
                    PERFORM BDC_FIELD       USING 'PLPOD-PREIS'
                                                  IT_IMR-PREIS.
                    PERFORM BDC_FIELD       USING 'PLPOD-WAERS'
                                                  IT_IMR-WAERS.

                    PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4420'.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=BACK'.
                    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
                    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                                  VSTEUS.
                    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                                  '=ENT1'.
                    PERFORM BDC_FIELD       USING VSTEUS IT_IMR-STEUS.
                  ENDIF.
                ENDIF.

                IF COUNTER = 4 OR COUNTER = 6.
                ENDIF.
                IF VLINE = 2 OR VLINE = 4.

                ELSE.
                  IF COUNTER = 2.
                  ENDIF.

                ENDIF.
              ENDIF.
            ENDLOOP.

            PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'PLPOD-VORNR(01)'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=BU'.

*            BREAK-POINT.

            CALL TRANSACTION 'C201' USING IT_BDCDATA
                          MODE 'E'
                          UPDATE 'S'
                          MESSAGES INTO IT_BDCMSGCOLL.

            READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
            IF SY-SUBRC <> 0.
              COMMIT WORK AND WAIT.
              IT_HMR-ZDESC = 'Sukses'.
              IT_HMR-ZSTAT = GCF_S1 .
            ELSE.
              IT_HMR-ZDESC = 'Gagal'.
              IT_HMR-ZSTAT = GCF_E1 .
            ENDIF.
          ENDIF.

          MODIFY IT_HMR.

        ENDLOOP.

      ENDIF.

      PERFORM F_DISPLAY_DATA.
      MOVE FPATH TO P_FILE.

*    ENDIF.
    ELSE.
      MESSAGE 'Please upload only .txt file' TYPE 'I'.
      MOVE FPATH TO P_FILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_UPLOAD_CREATE_CR

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_RB1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CHANGE_RB1.

  CLEAR: IT_DETAIL2, IT_BDCMSGCOLL, IT_HMR.
  REFRESH: IT_DETAIL2, IT_BDCMSGCOLL, IT_HMR.

  IT_DETAIL2[] = IT_DETAIL[].
  DELETE ADJACENT DUPLICATES FROM IT_DETAIL COMPARING PLNAL MATNR.

  LOOP AT IT_DETAIL.
    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4000'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC27M-WERKS'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ALDE'.
    PERFORM BDC_FIELD       USING 'RC271-PLNAL'
                                   IT_DETAIL-PLNAL.
    PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                   IT_DETAIL-MATNR.
    PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                   IT_DETAIL-WERKS.


    PERFORM BDC_DYNPRO      USING 'SAPLCPDA' '4210'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLKOD-KTEXT'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=VOUE'.
    PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                  '1'.
    PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                  '4'.
    N = 0.
    LOOP AT IT_DETAIL2.
      VCURSOR = 'RC27X-FLG_SEL('.
      CONCATENATE VCURSOR IT_DETAIL2-VORNR ')' INTO VCURSOR.
      VPHFLG = 'PLPOD-PHFLG('.
      CONCATENATE VPHFLG IT_DETAIL2-VORNR ')' INTO VPHFLG.
      VPVZNR = 'PLPOD-PVZNR('.
      CONCATENATE VPVZNR IT_DETAIL2-VORNR ')' INTO VPVZNR.
      VPHSEQ = 'PLPOD-PHSEQ('.
      CONCATENATE VPHSEQ IT_DETAIL2-VORNR ')' INTO VPHSEQ.
      VARBPL = 'PLPOD-ARBPL('.
      CONCATENATE VARBPL IT_DETAIL2-VORNR ')' INTO VARBPL.
      VSTEUS = 'PLPOD-STEUS('.
      CONCATENATE VSTEUS IT_DETAIL2-VORNR ')' INTO VSTEUS.
      VLTXA1 = 'PLPOD-LTXA1('.
      CONCATENATE VLTXA1 IT_DETAIL2-VORNR ')' INTO VLTXA1.

      PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    VCURSOR.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=ARBD'.
      PERFORM BDC_FIELD       USING VCURSOR
                                    'X'.
      IF N = 0.
        N = N + 1.
        VCURSOR2 = VCURSOR.
      ELSEIF N > 0.
        PERFORM BDC_FIELD       USING VCURSOR2
                                      ' '.
        VCURSOR2 = VCURSOR.
      ENDIF.

      IF IT_DETAIL2-NEWOP = 'X'.

        PERFORM BDC_FIELD       USING VPVZNR
                                      IT_DETAIL2-PVZNR.
        PERFORM BDC_FIELD       USING VPHFLG
                                      IT_DETAIL2-PHFLG.
        PERFORM BDC_FIELD       USING VARBPL
                                      IT_DETAIL2-ARBPL.
        PERFORM BDC_FIELD       USING VPHSEQ
                                      IT_DETAIL2-PHSEQ.

      ELSEIF IT_DETAIL2-NEWOP = ' ' AND IT_DETAIL2-PVZNR IS NOT INITIAL.

        PERFORM BDC_FIELD       USING VPHSEQ
                                      IT_DETAIL2-PHSEQ.

      ELSEIF IT_DETAIL2-NEWOP = ' ' AND IT_DETAIL2-PVZNR IS INITIAL.

        PERFORM BDC_FIELD       USING VARBPL
                                      IT_DETAIL2-ARBPL.

      ENDIF.

      PERFORM BDC_FIELD       USING VSTEUS
                                    IT_DETAIL2-STEUS.
      PERFORM BDC_FIELD       USING VLTXA1
                                    IT_DETAIL2-LTXA1.


      PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4410'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'PLPOD-VORNR'.
      IF IT_DETAIL2-PVZNR IS NOT INITIAL.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=VOAG'.
      ELSE.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=BACK'.
      ENDIF.
      PERFORM BDC_FIELD       USING 'PLPOD-STEUS'
                                    IT_DETAIL2-STEUS.
      PERFORM BDC_FIELD       USING 'PLPOD-LTXA1'
                                    IT_DETAIL2-LTXA1.
      PERFORM BDC_FIELD       USING 'PLPOD-BMSCH'
                                    IT_DETAIL2-BMSCH.
      PERFORM BDC_FIELD       USING 'PLPOD-MEINH'
                                    IT_DETAIL2-MEINH.
      IF IT_DETAIL2-PVZNR IS NOT INITIAL.

        IF IT_DETAIL2-MATNR+0(2) = 'JR'.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW01'
                                        IT_DETAIL2-VGW01.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE01'
                                        IT_DETAIL2-VGE01.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW02'
                                        IT_DETAIL2-VGW02.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE02'
                                        IT_DETAIL2-VGE02.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW03'
                                        IT_DETAIL2-VGW03.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE03'
                                        IT_DETAIL2-VGE03.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW04'
                                        IT_DETAIL2-VGW04.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE04'
                                        IT_DETAIL2-VGE04.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW05'
                                        IT_DETAIL2-VGW05.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE05'
                                        IT_DETAIL2-VGE05.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW06'
                                        IT_DETAIL2-VGW06.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE06'
                                        IT_DETAIL2-VGE06.
        ELSEIF IT_DETAIL2-MATNR+0(2) = 'SR'.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW01'
                                        IT_DETAIL2-VGW01.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE01'
                                        IT_DETAIL2-VGE01.
          PERFORM BDC_FIELD       USING 'PLPOD-VGW02'
                                        IT_DETAIL2-VGW02.
          PERFORM BDC_FIELD       USING 'PLPOD-VGE02'
                                        IT_DETAIL2-VGE02.

          IF IT_DETAIL2-WERKS = 'TTE'.    "ADDED BY FATHIR ON 05.10.2020 - add activity for SR Master Recipe TTE
            PERFORM BDC_FIELD       USING 'PLPOD-VGW03'
                                          IT_DETAIL2-VGW03.
            PERFORM BDC_FIELD       USING 'PLPOD-VGE03'
                                          IT_DETAIL2-VGE03.
            PERFORM BDC_FIELD       USING 'PLPOD-VGW04'
                                          IT_DETAIL2-VGW04.
            PERFORM BDC_FIELD       USING 'PLPOD-VGE04'
                                          IT_DETAIL2-VGE04.
            PERFORM BDC_FIELD       USING 'PLPOD-VGW05'
                                          IT_DETAIL2-VGW05.
            PERFORM BDC_FIELD       USING 'PLPOD-VGE05'
                                          IT_DETAIL2-VGE05.
            PERFORM BDC_FIELD       USING 'PLPOD-VGW06'
                                          IT_DETAIL2-VGW06.
            PERFORM BDC_FIELD       USING 'PLPOD-VGE06'
                                          IT_DETAIL2-VGE06.
          ENDIF.

        ENDIF.

        PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4420'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'PLPOD-LOART'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=BACK'.
        PERFORM BDC_FIELD       USING 'PLPOD-EKORG'
                                      IT_DETAIL2-EKORG.
        PERFORM BDC_FIELD       USING 'PLPOD-MATKL'
                                      IT_DETAIL2-MATKL.
        PERFORM BDC_FIELD       USING 'PLPOD-EKGRP'
                                      IT_DETAIL2-EKGRP.
        PERFORM BDC_FIELD       USING 'PLPOD-LIFNR'
                                      IT_DETAIL2-LIFNR.
        PERFORM BDC_FIELD       USING 'PLPOD-PEINH'
                                      IT_DETAIL2-PEINH.
        PERFORM BDC_FIELD       USING 'PLPOD-SAKTO'
                                      IT_DETAIL2-SAKTO.
        PERFORM BDC_FIELD       USING 'PLPOD-PREIS'
                                      IT_DETAIL2-PREIS.
        PERFORM BDC_FIELD       USING 'PLPOD-WAERS'
                                      IT_DETAIL2-WAERS.
      ENDIF.

    ENDLOOP.

    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLPOD-VORNR(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BU'.

    CLEAR IT_BDCMSGCOLL. REFRESH IT_BDCMSGCOLL.
    CALL TRANSACTION 'C202' USING IT_BDCDATA
                              MODE 'N'
                              UPDATE 'S'
                              MESSAGES INTO IT_BDCMSGCOLL.

    CLEAR IT_BDCDATA. REFRESH IT_BDCDATA.

    READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC <> 0.
      READ TABLE IT_BDCMSGCOLL INDEX 1.
      CONCATENATE 'Recipe was saved with group' IT_BDCMSGCOLL-MSGV1 'and Material' IT_BDCMSGCOLL-MSGV2
      INTO IT_HMR-ZDESC SEPARATED BY SPACE.
      IT_HMR-ZSTAT = GCF_S1.
      IT_HMR-MATNR = IT_DETAIL-MATNR.
      IT_HMR-WERKS = IT_DETAIL-WERKS.
      IT_HMR-PLNAL = IT_DETAIL-PLNAL.
    ELSE.
      SELECT SINGLE T100~TEXT INTO (IT_HMR-ZDESC)
       FROM T100 WHERE SPRSL = IT_BDCMSGCOLL-MSGSPRA
                        AND   ARBGB = IT_BDCMSGCOLL-MSGID
                        AND   MSGNR = IT_BDCMSGCOLL-MSGNR.
      IT_HMR-ZDESC = 'Failed'.
      IT_HMR-ZSTAT = GCF_E1.
      IT_HMR-MATNR = IT_DETAIL-MATNR.
      IT_HMR-WERKS = IT_DETAIL-WERKS.
      IT_HMR-PLNAL = IT_DETAIL-PLNAL.
    ENDIF.
    APPEND IT_HMR.

  ENDLOOP.

  PERFORM F_DISPLAY_DATA2.

ENDFORM.                    "F_CHANGE_RB1

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_RB2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CHANGE_RB2.
*  BREAK-POINT.
  CLEAR: IT_DETAIL2, IT_BDCMSGCOLL, IT_HMR.
  REFRESH: IT_DETAIL2, IT_BDCMSGCOLL, IT_HMR.

  IT_DETAIL2[] = IT_DETAIL[].
  DELETE ADJACENT DUPLICATES FROM IT_DETAIL COMPARING PLNAL MATNR.

  LOOP AT IT_DETAIL.
    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4000'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC27M-WERKS'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ALDE'.
    PERFORM BDC_FIELD       USING 'RC271-PLNNR'
                                  '   '.
    PERFORM BDC_FIELD       USING 'RC271-PLNAL'
                                   IT_DETAIL-PLNAL.
    PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                   IT_DETAIL-MATNR.
    PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                   IT_DETAIL-WERKS.


    PERFORM BDC_DYNPRO      USING 'SAPLCPDA' '4210'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLKOD-KTEXT'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=VOUE'.
    PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                  '1'.
    PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                  '4'.
    N = 0.
    LOOP AT IT_DETAIL2 WHERE MATNR = IT_DETAIL-MATNR.
      VCURSOR = 'RC27X-FLG_SEL('.
      CONCATENATE VCURSOR IT_DETAIL2-VORNR ')' INTO VCURSOR.
      VPHFLG = 'PLPOD-PHFLG('.
      CONCATENATE VPHFLG IT_DETAIL2-VORNR ')' INTO VPHFLG.
      VPVZNR = 'PLPOD-PVZNR('.
      CONCATENATE VPVZNR IT_DETAIL2-VORNR ')' INTO VPVZNR.
      VPHSEQ = 'PLPOD-PHSEQ('.
      CONCATENATE VPHSEQ IT_DETAIL2-VORNR ')' INTO VPHSEQ.
      VARBPL = 'PLPOD-ARBPL('.
      CONCATENATE VARBPL IT_DETAIL2-VORNR ')' INTO VARBPL.
      VSTEUS = 'PLPOD-STEUS('.
      CONCATENATE VSTEUS IT_DETAIL2-VORNR ')' INTO VSTEUS.
      VLTXA1 = 'PLPOD-LTXA1('.
      CONCATENATE VLTXA1 IT_DETAIL2-VORNR ')' INTO VLTXA1.

      PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    VCURSOR.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=ARBD'.
      PERFORM BDC_FIELD       USING VCURSOR
                                    'X'.
      IF N = 0.
        N = N + 1.
        VCURSOR2 = VCURSOR.
      ELSEIF N > 0.
        PERFORM BDC_FIELD       USING VCURSOR2
                                      ' '.
        VCURSOR2 = VCURSOR.
      ENDIF.

      IF IT_DETAIL2-NEWOP = 'X'.

        PERFORM BDC_FIELD       USING VPVZNR
                                      IT_DETAIL2-PVZNR.
        PERFORM BDC_FIELD       USING VPHFLG
                                      IT_DETAIL2-PHFLG.
        PERFORM BDC_FIELD       USING VARBPL
                                      IT_DETAIL2-ARBPL.
        PERFORM BDC_FIELD       USING VPHSEQ
                                      IT_DETAIL2-PHSEQ.

      ELSEIF IT_DETAIL2-NEWOP = ' ' AND IT_DETAIL2-PVZNR IS NOT INITIAL.

        PERFORM BDC_FIELD       USING VPHSEQ
                                      IT_DETAIL2-PHSEQ.

      ELSEIF IT_DETAIL2-NEWOP = ' ' AND IT_DETAIL2-PVZNR IS INITIAL.

        PERFORM BDC_FIELD       USING VARBPL
                                      IT_DETAIL2-ARBPL.

      ENDIF.

      IF IT_DETAIL2-STEUS EQ 'ZP05' OR IT_DETAIL2-STEUS EQ 'ZP06'.
        PERFORM BDC_FIELD       USING VSTEUS
                                      'ZP01'.
      ELSE.
        PERFORM BDC_FIELD       USING VSTEUS
                                      IT_DETAIL2-STEUS.
      ENDIF.
      PERFORM BDC_FIELD       USING VLTXA1
                                    IT_DETAIL2-LTXA1.
      PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4410'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'PLPOD-VORNR'.
      IF IT_DETAIL2-PVZNR IS NOT INITIAL.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=VOAG'.
      ELSE.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=BACK'.
      ENDIF.

      IF IT_DETAIL2-STEUS EQ 'ZP05' OR IT_DETAIL2-STEUS EQ 'ZP06'.
        PERFORM BDC_FIELD       USING 'PLPOD-STEUS'
                                       'ZP01'.
      ELSE.
        PERFORM BDC_FIELD       USING 'PLPOD-STEUS'
                                       IT_DETAIL2-STEUS.
      ENDIF.
      PERFORM BDC_FIELD       USING 'PLPOD-LTXA1'
                                    IT_DETAIL2-LTXA1.
      PERFORM BDC_FIELD       USING 'PLPOD-BMSCH'
                                    IT_DETAIL2-BMSCH.
      PERFORM BDC_FIELD       USING 'PLPOD-MEINH'
                                    IT_DETAIL2-MEINH.
      IF IT_DETAIL2-PVZNR IS NOT INITIAL.

        PERFORM BDC_FIELD       USING 'PLPOD-VGW01'
                                      IT_DETAIL2-VGW01.
        PERFORM BDC_FIELD       USING 'PLPOD-VGE01'
                                      IT_DETAIL2-VGE01.
        PERFORM BDC_FIELD       USING 'PLPOD-VGW02'
                                      IT_DETAIL2-VGW02.
        PERFORM BDC_FIELD       USING 'PLPOD-VGE02'
                                      IT_DETAIL2-VGE02.
        PERFORM BDC_FIELD       USING 'PLPOD-VGW03'
                                      IT_DETAIL2-VGW03.
        PERFORM BDC_FIELD       USING 'PLPOD-VGE03'
                                      IT_DETAIL2-VGE03.
        PERFORM BDC_FIELD       USING 'PLPOD-VGW04'
                                      IT_DETAIL2-VGW04.
        PERFORM BDC_FIELD       USING 'PLPOD-VGE04'
                                      IT_DETAIL2-VGE04.
        PERFORM BDC_FIELD       USING 'PLPOD-VGW05'
                                      IT_DETAIL2-VGW05.
        PERFORM BDC_FIELD       USING 'PLPOD-VGE05'
                                      IT_DETAIL2-VGE05.

        IF IT_DETAIL2-STEUS EQ 'ZP05' OR IT_DETAIL2-STEUS EQ 'ZP06'.
          PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4420'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'PLPOD-LOART'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ARBD'.
          PERFORM BDC_FIELD       USING 'PLPOD-EKORG'
                                        IT_DETAIL2-EKORG.
          PERFORM BDC_FIELD       USING 'PLPOD-MATKL'
                                        IT_DETAIL2-MATKL.
          PERFORM BDC_FIELD       USING 'PLPOD-EKGRP'
                                        IT_DETAIL2-EKGRP.
          PERFORM BDC_FIELD       USING 'PLPOD-LIFNR'
                                        IT_DETAIL2-LIFNR.
          PERFORM BDC_FIELD       USING 'PLPOD-PEINH'
                                        IT_DETAIL2-PEINH.
          PERFORM BDC_FIELD       USING 'PLPOD-SAKTO'
                                        IT_DETAIL2-SAKTO.
          PERFORM BDC_FIELD       USING 'PLPOD-PREIS'
                                        IT_DETAIL2-PREIS.
          PERFORM BDC_FIELD       USING 'PLPOD-WAERS'
                                        IT_DETAIL2-WAERS.

          PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4410'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'PLPOD-STEUS'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=BACK'.
          PERFORM BDC_FIELD       USING 'PLPOD-STEUS'
                                      IT_DETAIL2-STEUS.
        ELSE.

          PERFORM BDC_DYNPRO      USING 'SAPLCPDO' '4420'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'PLPOD-LOART'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=BACK'.
          PERFORM BDC_FIELD       USING 'PLPOD-EKORG'
                                        IT_DETAIL2-EKORG.
          PERFORM BDC_FIELD       USING 'PLPOD-MATKL'
                                        IT_DETAIL2-MATKL.
          PERFORM BDC_FIELD       USING 'PLPOD-EKGRP'
                                        IT_DETAIL2-EKGRP.
          PERFORM BDC_FIELD       USING 'PLPOD-LIFNR'
                                        IT_DETAIL2-LIFNR.
          PERFORM BDC_FIELD       USING 'PLPOD-PEINH'
                                        IT_DETAIL2-PEINH.
          PERFORM BDC_FIELD       USING 'PLPOD-SAKTO'
                                        IT_DETAIL2-SAKTO.
          PERFORM BDC_FIELD       USING 'PLPOD-PREIS'
                                        IT_DETAIL2-PREIS.
          PERFORM BDC_FIELD       USING 'PLPOD-WAERS'
                                        IT_DETAIL2-WAERS.
        ENDIF.

      ENDIF.

    ENDLOOP.

    PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '4400'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLPOD-VORNR(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BU'.

    CLEAR IT_BDCMSGCOLL. REFRESH IT_BDCMSGCOLL.
    CALL TRANSACTION 'C202' USING IT_BDCDATA
                              MODE 'N'
                              UPDATE 'S'
                              MESSAGES INTO IT_BDCMSGCOLL.

    CLEAR IT_BDCDATA. REFRESH IT_BDCDATA.

    READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC <> 0.
      READ TABLE IT_BDCMSGCOLL INDEX 1.
      CONCATENATE 'Recipe was saved with group' IT_BDCMSGCOLL-MSGV1 'and Material' IT_BDCMSGCOLL-MSGV2
      INTO IT_HMR-ZDESC SEPARATED BY SPACE.
      IT_HMR-ZSTAT = GCF_S1.
      IT_HMR-MATNR = IT_DETAIL-MATNR.
      IT_HMR-WERKS = IT_DETAIL-WERKS.
      IT_HMR-PLNAL = IT_DETAIL-PLNAL.
    ELSE.
      IT_HMR-ZDESC = 'Failed'.
      IT_HMR-ZSTAT = GCF_E1.
      IT_HMR-MATNR = IT_DETAIL-MATNR.
      IT_HMR-WERKS = IT_DETAIL-WERKS.
      IT_HMR-PLNAL = IT_DETAIL-PLNAL.
    ENDIF.
    APPEND IT_HMR.

  ENDLOOP.

  PERFORM F_DISPLAY_DATA2.

ENDFORM.                    "F_CHANGE_RB2


*&---------------------------------------------------------------------*
*&      Form  F_DELETE_MR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DELETE_MR .
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
      REFRESH : IT_DELHMR.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME            = FNAME
          FILETYPE            = 'ASC'
          HAS_FIELD_SEPARATOR = 'X'
        TABLES
          DATA_TAB            = IT_DELHMR.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
        LOOP AT IT_DELHMR.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = IT_DELHMR-PLNAL
            IMPORTING
              OUTPUT = IT_DELHMR-PLNAL.


          CLEAR VPLNNR.
          SELECT SINGLE PLNNR
            FROM PLKO
            INTO VPLNNR
            WHERE PLKO~PLNNR = IT_DELHMR-PLNNR
            AND PLKO~PLNAL = IT_DELHMR-PLNAL.

          IF SY-SUBRC <> 0.
            IT_DELHMR-ZDESC = 'Gagal, Master Recipe tidak ada di database'.
            IT_DELHMR-ZSTAT = GCF_E1 .
          ELSE.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                INPUT  = IT_DELHMR-PLNAL
              IMPORTING
                OUTPUT = IT_DELHMR-PLNAL.

            REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.

            PERFORM BDC_DYNPRO      USING 'RPIREDE2' '1000'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'CHECK'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=ONLI'.
            PERFORM BDC_FIELD       USING 'MATNR-LOW'
                                          IT_DELHMR-MATNR.
            PERFORM BDC_FIELD       USING 'WERKM'
                                          IT_DELHMR-MAT_WERKS.
            PERFORM BDC_FIELD       USING 'PLNTY-LOW'
                                          IT_DELHMR-PLNTY.
            PERFORM BDC_FIELD       USING 'PLNNR-LOW'
                                          IT_DELHMR-PLNNR.
            PERFORM BDC_FIELD       USING 'PLNAL-LOW'
                                          IT_DELHMR-PLNAL.
            PERFORM BDC_FIELD       USING 'WERKS-LOW'
                                          IT_DELHMR-WERKS.
            PERFORM BDC_FIELD       USING 'STATU-LOW'
                                          IT_DELHMR-STATU.
            PERFORM BDC_FIELD       USING 'VERW-LOW'
                                          IT_DELHMR-VERWE.
            PERFORM BDC_FIELD       USING 'STT'
                                          ''.
            PERFORM BDC_FIELD       USING 'RESET'
                                          IT_DELHMR-FLG_RESET.
            PERFORM BDC_FIELD       USING 'CHECK'
                                          IT_DELHMR-FLG_CHECK.
            PERFORM BDC_FIELD       USING 'PROT'
                                          IT_DELHMR-FLG_PROT.
            PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0100'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=YES'.

            PERFORM BDC_DYNPRO      USING 'SAPLCPRE' '1010'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'ITAB_LINES'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=BACK'.
            PERFORM BDC_DYNPRO      USING 'SAPMSSY0' '0120'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=BACK'.
            PERFORM BDC_DYNPRO      USING 'RPIREDE2' '1000'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '/EE'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'MATNR-LOW'.

            OPT-DISMODE = 'E'. "A: show all dynpros "E: show dynpro on error only "N: do not display dynpro
            OPT-UPDMODE = 'A'. "S: synchronously "A: asynchronously "L: local
            OPT-DEFSIZE = 'X'.
            OPT-RACOMMIT = 'X'.

            CALL TRANSACTION 'C298' USING IT_BDCDATA
                        OPTIONS FROM OPT
                        MESSAGES INTO IT_BDCMSGCOLL.

            READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
            IF SY-SUBRC <> 0.
              COMMIT WORK AND WAIT.
              IT_DELHMR-ZDESC = 'Sukses'.
              IT_DELHMR-ZSTAT = GCF_S1 .
            ELSE.
              IT_DELHMR-ZDESC = 'Gagal'.
              IT_DELHMR-ZSTAT = GCF_E1 .
            ENDIF.
          ENDIF.
          MODIFY IT_DELHMR.
        ENDLOOP.
      ENDIF.

      PERFORM F_DISPLAY_DATA.
      MOVE FPATH TO P_FILE.
    ELSE.
      MESSAGE 'Please upload only .txt file' TYPE 'I'.
      MOVE FPATH TO P_FILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DELETE_MR