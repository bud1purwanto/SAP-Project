*&---------------------------------------------------------------------*
*&  Include           ZPPC_UP_BOM_F01
*&---------------------------------------------------------------------*


START-OF-SELECTION.
  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_RESOURCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UPLOAD_BOM .

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
      REFRESH : IT_IBOM, IT_HBOM.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME            = FNAME
          FILETYPE            = 'ASC'
          HAS_FIELD_SEPARATOR = 'X'
        TABLES
          DATA_TAB            = IT_HBOM.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.

        IT_IBOM[] = IT_HBOM[].

        SORT IT_HBOM BY MATNR WERKS STLAL.
        DELETE ADJACENT DUPLICATES FROM IT_HBOM COMPARING MATNR WERKS STLAL.

        LOOP AT IT_HBOM.

          CLEAR VMATNR.
          SELECT SINGLE MAST~MATNR
            INTO VMATNR
            FROM MAST
            WHERE MAST~MATNR = IT_HBOM-MATNR
            AND MAST~WERKS = IT_HBOM-WERKS
            AND MAST~STLAN = IT_HBOM-STLAN
            AND MAST~STLAL = IT_HBOM-STLAL.

          IF SY-SUBRC = 0 .
            IT_HBOM-ZDESC = 'Gagal, BOM sudah di-create sebelumnya'.
            IT_HBOM-ZSTAT = GCF_E1 .
          ELSE.

            REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.

            PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0100'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RC29N-DATUV'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM BDC_FIELD       USING 'RC29N-MATNR'
                                          IT_HBOM-MATNR.
            PERFORM BDC_FIELD       USING 'RC29N-WERKS'
                                          IT_HBOM-WERKS.
            PERFORM BDC_FIELD       USING 'RC29N-STLAN'
                                          IT_HBOM-STLAN.
            PERFORM BDC_FIELD       USING 'RC29N-STLAL'
                                          IT_HBOM-STLAL.


            CLEAR : DD, MM,YYYY, DATE.
            SPLIT IT_HBOM-DATUV  AT '.' INTO DD MM YYYY.
            CONCATENATE DD MM YYYY INTO DATE.
            PERFORM BDC_FIELD       USING 'RC29N-DATUV'
                                          DATE.

            PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0110'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RC29K-STLST'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM BDC_FIELD       USING 'RC29K-ZTEXT'
                                          IT_HBOM-ZTEXT.
            PERFORM BDC_FIELD       USING 'RC29K-BMENG'
                                          IT_HBOM-BMENG.
            PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0111'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RC29K-LABOR'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '/00'.

            REFRESH ITTEMP.
            ITTEMP[] = IT_IBOM[].
            LOOP AT ITTEMP WHERE MATNR = IT_HBOM-MATNR AND WERKS = IT_HBOM-WERKS AND STLAL = IT_HBOM-STLAL.
              ITTEMP-FLAG = 'X'.
              MODIFY ITTEMP.
            ENDLOOP.

            DELETE ITTEMP WHERE FLAG NE 'X'.

            CLEAR VLINE.
            DESCRIBE TABLE ITTEMP LINES VLINE.

            IF VLINE = 1.
              IF IT_HBOM-IDNRK = ''.
                PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0140'.
                PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                              '=FCBU'.
              ELSE.
                PERFORM F_UPLOAD_ITEM.
              ENDIF.
            ELSE.
              PERFORM F_UPLOAD_ITEM.
            ENDIF.
            CALL TRANSACTION 'CS01' USING IT_BDCDATA
                        MODE 'N'
                        UPDATE 'S'
                        MESSAGES INTO IT_BDCMSGCOLL.

            READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
            IF SY-SUBRC <> 0.
              COMMIT WORK AND WAIT.
              IT_HBOM-ZDESC = 'Sukses'.
              IT_HBOM-ZSTAT = GCF_S1 .
            ELSE.
              IT_HBOM-ZDESC = 'Gagal'.
              IT_HBOM-ZSTAT = GCF_E1 .
            ENDIF.

          ENDIF.

          MODIFY IT_HBOM.
        ENDLOOP.

        PERFORM F_DISPLAY_DATA.

      ENDIF.
    ELSE.
      MESSAGE 'Please upload only .txt file' TYPE 'I'.
      MOVE FPATH TO P_FILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_UPLOAD_RESOURCE



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
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HBOM' :
    'MATNR' '' ''  '' ''  'Material'      '' ' ' '' '',
    'WERKS' '' ''  '' ''  'Plant'     '' ' ' '' '',
    'STLAL' '' ''  '' ''  'Alternative'     '' ' ' '' '',
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
      T_OUTTAB                = IT_HBOM
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL


*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_BOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHANGE_BOM .
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
      REFRESH : IT_IBOM, IT_HBOM.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME            = FNAME
          FILETYPE            = 'ASC'
          HAS_FIELD_SEPARATOR = 'X'
        TABLES
          DATA_TAB            = IT_HBOM.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.

        IT_IBOM[] = IT_HBOM[].

        SORT IT_HBOM BY MATNR WERKS STLAL.
        DELETE ADJACENT DUPLICATES FROM IT_HBOM COMPARING MATNR WERKS STLAL.

        LOOP AT IT_HBOM.
          REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.
          PERFORM F_CHECK_CHANGE.


          PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0100'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RC29N-STLAL'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM BDC_FIELD       USING 'RC29N-MATNR'
                                        IT_HBOM-MATNR.
          PERFORM BDC_FIELD       USING 'RC29N-WERKS'
                                        IT_HBOM-WERKS.
          PERFORM BDC_FIELD       USING 'RC29N-STLAN'
                                        IT_HBOM-STLAN.
          PERFORM BDC_FIELD       USING 'RC29N-STLAL'
                                        IT_HBOM-STLAL.


          CLEAR : DD, MM,YYYY, DATE.
          SPLIT IT_HBOM-DATUV  AT '.' INTO DD MM YYYY.
          CONCATENATE DD MM YYYY INTO DATE.
          PERFORM BDC_FIELD       USING 'RC29N-DATUV'
                                        DATE.


          PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0150'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RC29P-POSNR(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=SETP'.


          LOOP AT IT_IBOM WHERE MATNR = IT_HBOM-MATNR AND WERKS = IT_HBOM-WERKS AND STLAL = IT_HBOM-STLAL.


          ENDLOOP.

          PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0140'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RC29P-POSNR(02)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=FCBU'.


          OPT-DISMODE = 'E'. "A: show all dynpros "E: show dynpro on error only "N: do not display dynpro
          OPT-UPDMODE = 'A'. "S: synchronously "A: asynchronously "L: local
          OPT-DEFSIZE = 'X'.

          CALL TRANSACTION 'CS02' USING IT_BDCDATA
                OPTIONS FROM OPT
                MESSAGES INTO IT_BDCMSGCOLL.
          READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
          IF SY-SUBRC <> 0.
            COMMIT WORK AND WAIT.
            IT_HBOM-ZDESC = 'Change BOM Sukses'.
            IT_HBOM-ZSTAT = GCF_S1 .
          ELSE.
            IT_HBOM-ZDESC = 'Change BOM Gagal'.
            IT_HBOM-ZSTAT = GCF_E1 .
          ENDIF.
          MODIFY IT_HBOM.
        ENDLOOP.

        PERFORM F_DISPLAY_DATA.

      ENDIF.
    ELSE.
      MESSAGE 'Please upload only .txt file' TYPE 'I'.
      MOVE FPATH TO P_FILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHANGE_BOM


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CHANGE
*&---------------------------------------------------------------------*
*       CEK IF CHANGE, ADD, OR DELETE COMPONENT.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM F_CHECK_CHANGE .

  REFRESH T_STPO.

  CALL FUNCTION 'CSAP_MAT_BOM_READ'
    EXPORTING
      MATERIAL             = IT_HBOM-MATNR
      PLANT                = IT_HBOM-WERKS
      BOM_USAGE            = IT_HBOM-STLAN
      ALTERNATIVE          = IT_HBOM-STLAL
   TABLES
     T_STPO               = T_STPO.

  CLEAR V_COMP.
  DESCRIBE TABLE T_STPO LINES V_COMP.

  REFRESH ITTEMP.
  ITTEMP[] = IT_IBOM[].

  LOOP AT ITTEMP WHERE MATNR = IT_HBOM-MATNR AND WERKS = IT_HBOM-WERKS AND STLAL = IT_HBOM-STLAL.
    ITTEMP-FLAG = 'X'.
    MODIFY ITTEMP.
  ENDLOOP.

  DELETE ITTEMP WHERE FLAG NE 'X'.
  DESCRIBE TABLE ITTEMP LINES VLINE.



ENDFORM.                    " F_CHECK_CHANGE



*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_NORMAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHANGE_NORMAL .

  PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0100'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC29N-STLAL'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC29N-MATNR'
                                IT_HBOM-MATNR.
  PERFORM BDC_FIELD       USING 'RC29N-WERKS'
                                IT_HBOM-WERKS.
  PERFORM BDC_FIELD       USING 'RC29N-STLAN'
                                IT_HBOM-STLAN.
  PERFORM BDC_FIELD       USING 'RC29N-STLAL'
                                IT_HBOM-STLAL.

  CLEAR : DD, MM,YYYY, DATE.
  SPLIT IT_HBOM-DATUV  AT '.' INTO DD MM YYYY.
  CONCATENATE DD MM YYYY INTO DATE.
  PERFORM BDC_FIELD       USING 'RC29N-DATUV'
                                DATE.


  LOOP AT IT_IBOM WHERE MATNR = IT_HBOM-MATNR AND WERKS = IT_HBOM-WERKS AND STLAL = IT_HBOM-STLAL.
    SHIFT POSNR LEFT DELETING LEADING ''.

    MOVE COUNTER TO N.
    SHIFT N LEFT DELETING LEADING ''.

    IF COUNTER < 10.
      CONCATENATE CIDNRK '(0' N ')' INTO VIDNRK.
      CONCATENATE CMENGE '(0' N ')' INTO VMENGE.
      CONCATENATE CMEINS '(0' N ')' INTO VMEINS.
    ELSE.
      CONCATENATE CIDNRK '(' N ')' INTO VIDNRK.
      CONCATENATE CMENGE '(' N ')' INTO VMENGE.
      CONCATENATE CMEINS '(' N ')' INTO VMEINS.
    ENDIF.


    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0150'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC29P-MENGE(02)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RC29P-MENGE(02)'
                                  '28.790'.

    PERFORM BDC_FIELD       USING VIDNRK
                                  IT_IBOM-IDNRK.
    PERFORM BDC_FIELD       USING VMENGE
                                  IT_IBOM-MENGE.
    PERFORM BDC_FIELD       USING VMEINS
                                  IT_IBOM-MEINS.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0130'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC29P-REKRS'.
    PERFORM BDC_FIELD       USING 'RC29P-POSNR'
                                  POSNR.
    PERFORM BDC_FIELD       USING 'RC29P-IDNRK'
                                  IT_IBOM-IDNRK.
    PERFORM BDC_FIELD       USING 'RC29P-MENGE'
                                  IT_IBOM-MENGE.
    PERFORM BDC_FIELD       USING 'RC29P-MEINS'
                                  IT_IBOM-MEINS.
    PERFORM BDC_FIELD       USING 'RC29P-REKRS'
                                  IT_IBOM-REKRS.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0131'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC29P-LGORT'.
    PERFORM BDC_FIELD       USING 'RC29P-LGORT'
                                  IT_IBOM-LGORT.
  ENDLOOP.

  CLEAR : DD, MM,YYYY, DATE.
  SPLIT IT_HBOM-DATUV  AT '.' INTO DD MM YYYY.
  CONCATENATE DD MM YYYY INTO DATE.
  PERFORM BDC_FIELD       USING 'RC29N-DATUV'
                                DATE."'01.01.2012'.


  PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0150'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC29P-MEINS(02)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=KALL'.

  LOOP AT IT_IBOM WHERE MATNR = IT_HBOM-MATNR AND WERKS = IT_HBOM-WERKS AND STLAL = IT_HBOM-STLAL.
    CLEAR : N, POSNR.
    IPOSNR = IPOSNR + 10.
    COUNTER = COUNTER + 1.
    MOVE IPOSNR TO POSNR.

    SHIFT POSNR LEFT DELETING LEADING ''.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = POSNR
      IMPORTING
        OUTPUT = POSNR.


    MOVE COUNTER TO N.
    SHIFT N LEFT DELETING LEADING ''.

    IF COUNTER < 10.
      CONCATENATE CIDNRK '(0' N ')' INTO VIDNRK.
      CONCATENATE CMENGE '(0' N ')' INTO VMENGE.
      CONCATENATE CMEINS '(0' N ')' INTO VMEINS.
    ELSE.
      CONCATENATE CIDNRK '(' N ')' INTO VIDNRK.
      CONCATENATE CMENGE '(' N ')' INTO VMENGE.
      CONCATENATE CMEINS '(' N ')' INTO VMEINS.
    ENDIF.

    PERFORM BDC_FIELD       USING VIDNRK
                                  IT_IBOM-IDNRK.
    PERFORM BDC_FIELD       USING VMENGE
                                  IT_IBOM-MENGE.
    PERFORM BDC_FIELD       USING VMEINS
                                  IT_IBOM-MEINS.
    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0130'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC29P-REKRS'.
    PERFORM BDC_FIELD       USING 'RC29P-POSNR'
                                  POSNR.
    PERFORM BDC_FIELD       USING 'RC29P-IDNRK'
                                  IT_IBOM-IDNRK.
    PERFORM BDC_FIELD       USING 'RC29P-MENGE'
                                  IT_IBOM-MENGE.
    PERFORM BDC_FIELD       USING 'RC29P-MEINS'
                                  IT_IBOM-MEINS.
    PERFORM BDC_FIELD       USING 'RC29P-REKRS'
                                  IT_IBOM-REKRS.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0131'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC29P-LGORT'.
    PERFORM BDC_FIELD       USING 'RC29P-LGORT'
                                  IT_IBOM-LGORT.

  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0150'.

  PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '2110'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC29K-STLST'.
  PERFORM BDC_FIELD       USING 'RC29K-ZTEXT'
                                IT_HBOM-ZTEXT.
  PERFORM BDC_FIELD       USING 'RC29K-BMENG'
                                IT_HBOM-BMENG.

  PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '2110'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=FCPU'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC29K-EXSTL'.

  PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0150'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC29P-POSNR(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=FCBU'.

ENDFORM.                    " F_CHANGE_NORMAL


*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHANGE_ADD .

ENDFORM.                    " F_CHANGE_ADD


*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHANGE_DELETE .

ENDFORM.                    " F_CHANGE_DELETE

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UPLOAD_ITEM .
  CLEAR :IPOSNR, COUNTER.
  LOOP AT IT_IBOM WHERE MATNR = IT_HBOM-MATNR AND WERKS = IT_HBOM-WERKS AND STLAL = IT_HBOM-STLAL.
    CLEAR : N, POSNR.
    IPOSNR = IPOSNR + 10.
    COUNTER = COUNTER + 1.
    MOVE IPOSNR TO POSNR.

    SHIFT POSNR LEFT DELETING LEADING ''.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = POSNR
      IMPORTING
        OUTPUT = POSNR.


    MOVE COUNTER TO N.
    SHIFT N LEFT DELETING LEADING ''.

    IF COUNTER < 10.
      CONCATENATE CIDNRK '(0' N ')' INTO VIDNRK.
      CONCATENATE CMENGE '(0' N ')' INTO VMENGE.
      CONCATENATE CMEINS '(0' N ')' INTO VMEINS.
      CONCATENATE CPOSTP '(0' N ')' INTO VPOSTP.
    ELSE.
      CONCATENATE CIDNRK '(' N ')' INTO VIDNRK.
      CONCATENATE CMENGE '(' N ')' INTO VMENGE.
      CONCATENATE CMEINS '(' N ')' INTO VMEINS.
      CONCATENATE CPOSTP '(' N ')' INTO VPOSTP.
    ENDIF.


    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0140'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.

    IF COUNTER = 1.
      PERFORM BDC_FIELD       USING 'RC29P-IDNRK(01)'
                                  IT_IBOM-IDNRK.
      PERFORM BDC_FIELD       USING 'RC29P-MENGE(01)'
                                  IT_IBOM-MENGE.
      PERFORM BDC_FIELD       USING 'RC29P-MEINS(01)'
                                    IT_IBOM-MEINS.
      PERFORM BDC_FIELD       USING 'RC29P-POSTP(01)'
                                    'L'.
    ELSE.
      PERFORM BDC_FIELD       USING 'RC29P-IDNRK(02)'
                                  IT_IBOM-IDNRK.
      PERFORM BDC_FIELD       USING 'RC29P-MENGE(02)'
                                  IT_IBOM-MENGE.
      PERFORM BDC_FIELD       USING 'RC29P-MEINS(02)'
                                    IT_IBOM-MEINS.
      PERFORM BDC_FIELD       USING 'RC29P-POSTP(02)'
                                    'L'.

    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0130'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC29P-REKRS'.
    PERFORM BDC_FIELD       USING 'RC29P-IDNRK'
                                  IT_IBOM-IDNRK.
    PERFORM BDC_FIELD       USING 'RC29P-MENGE'
                                  IT_IBOM-MENGE.
    PERFORM BDC_FIELD       USING 'RC29P-MEINS'
                                  IT_IBOM-MEINS.
    PERFORM BDC_FIELD       USING 'RC29P-REKRS'
                                  IT_IBOM-REKRS.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0131'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC29P-LGORT'.
    PERFORM BDC_FIELD       USING 'RC29P-LGORT'
                                  IT_IBOM-LGORT.
*
    IF COUNTER = VLINE.
      PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0140'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RC29P-POSNR(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=FCBU'.
    ELSE.
      PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0140'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RC29P-POSNR(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=FCNP'.
    ENDIF.


  ENDLOOP.
ENDFORM.                    " F_UPLOAD_ITEM