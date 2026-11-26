*&---------------------------------------------------------------------*
*&  Include           ZHUI_TRS_HU_DV_F01
*&---------------------------------------------------------------------*
*INCLUDE ZFIELDCATALOG.

START-OF-SELECTION.
  IF RM = 'X'.
    CALL SCREEN 100.
  ELSE.
    CALL SCREEN 110.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
FORM F_DATA_RETRIEVAL.
  DATA : ITSLOC TYPE TABLE OF TYSLOC WITH HEADER LINE.

  IF P1 = 'X'. "JIKA PLANT 1000

    "get data sloc
    CLEAR : WSLOC, ITSLOC, TSLOC.
    REFRESH : TSLOC, ITSLOC.

    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '1%'
      AND ZHU_MAPP~TYPES = '1' AND ZHU_MAPP~WERK1 = '1000'.  "ADD NEW COMPANY

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO TSLOC.
    ENDLOOP.

    SELECT DISTINCT VEKP~EXIDV AS EXIDV
    VEPO~LGORT AS  SLOCA
    INTO CORRESPONDING FIELDS OF TABLE ITDATA
    FROM VEKP
    JOIN VEPO
    ON VEKP~VENUM = VEPO~VENUM
    WHERE VEKP~UEVEL = '' AND VEPO~WERKS EQ '1000'. "ADD NEW COMPANY

  ELSEIF P2 = 'X'. "JIKA PLANT 2000

    "get data sloc
    CLEAR : WSLOC, ITSLOC, TSLOC.
    REFRESH : TSLOC, ITSLOC.

    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '2%'
      AND ZHU_MAPP~TYPES = '1'  AND ZHU_MAPP~WERK1 = '2000'.  "ADD NEW COMPANY

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.

      APPEND WSLOC TO TSLOC.
    ENDLOOP.

    SELECT DISTINCT VEKP~EXIDV AS EXIDV
      VEPO~LGORT AS  SLOCA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO
      ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~UEVEL = '' AND VEPO~WERKS EQ '2000'. "ADD NEW COMPANY
  ENDIF.

  IF ITDATA[] IS INITIAL.
    MESSAGE 'No Data Exist!' TYPE 'I'.
  ELSE.

    LOOP AT ITDATA.
      CLEAR : VENUM, OBJNR, UNVEL.

      SELECT SINGLE VEPO~UNVEL
        INTO UNVEL
        FROM VEPO JOIN VEKP
        ON VEPO~VENUM = VEKP~VENUM
        WHERE VEKP~EXIDV = ITDATA-EXIDV.

      IF UNVEL = ''.
        SELECT SINGLE VEPO~LGORT
          INTO ITDATA-SLOCA
          FROM VEPO
          JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
          WHERE VEKP~EXIDV = ITDATA-EXIDV.

        IF ITDATA-SLOCA = ''.
          DELETE ITDATA.
          CONTINUE.

        ELSE.
          "CHECK SLOC FROM ZHU_MAPP
          IF ITDATA-SLOCA NOT IN TSLOC.
            DELETE ITDATA.
            CONTINUE.
          ENDIF.
        ENDIF.

      ELSE.
        SELECT SINGLE VEPO~LGORT
          INTO ITDATA-SLOCA
          FROM VEPO
          WHERE VEPO~VENUM = UNVEL.

        IF ITDATA-SLOCA NOT IN TSLOC.
          DELETE ITDATA.
          CONTINUE.
        ENDIF.

      ENDIF.

      "get venum
      SELECT SINGLE VEKP~VENUM
        INTO VENUM
        FROM VEKP
        WHERE VEKP~EXIDV = ITDATA-EXIDV.

      "GET STATUS.
      CONCATENATE 'HU' VENUM INTO OBJNR.
      SELECT SINGLE TJ30T~TXT04
        INTO ITDATA-STATUS
        FROM TJ30T
        JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
        JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
        WHERE HUSSTAT~OBJNR = OBJNR
        AND HUSSTAT~STAT = TJ30T~ESTAT
        AND HUSSTAT~INACT = ''
        AND TJ30T~SPRAS = 'EN'.

      IF ITDATA-STATUS = ''.
        DELETE ITDATA.
        CONTINUE.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ITDATA-EXIDV
        IMPORTING
          OUTPUT = ITDATA-EXIDV.
      MODIFY ITDATA.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " DATA_RETRIEVAL

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITALV' :
    'EXIDV'   '' ''  '' ''  'HU Number'       '' ' ' '' '',
    'SLOCA'   '' ''  '' ''  'Sloc Asal'    '' ' ' '' '',
    'STATUS'   '' ''  '' ''  'User Status'   '' ' ' '' '',
    'SLOCT'  '' ''  '' ''  'Sloc Tujuan'      '' ' ' '' ''.
ENDFORM.                    " F_FIELD_CATALOG


*-------------------------------------------------------------------*
* FORM  TOP-OF-PAGE                                                 *
*-------------------------------------------------------------------*
* ALV REPORT HEADER                                                 *
*-------------------------------------------------------------------*
FORM TOP-OF-PAGE.
*ALV HEADER DECLARATIONS
  DATA: T_HEADER TYPE SLIS_T_LISTHEADER,
        WA_HEADER TYPE SLIS_LISTHEADER,
        T_LINE LIKE WA_HEADER-INFO,
        LD_LINES TYPE I,
        LD_LINESC(10) TYPE C.

* TITLE
  WA_HEADER-TYP  = 'H'.
  WA_HEADER-INFO = 'Transfer Handling Unit to Warehouse/FGS' .
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = T_HEADER.
ENDFORM. "TOP-OF-PAGE

*------------------------------------------------------------------*
*       FORM USER_COMMAND                                          *
*------------------------------------------------------------------*
*       --> R_UCOMM                                                *
*       --> RS_SELFIELD                                            *
*------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.

* CHECK FUNCTION CODE
  CASE R_UCOMM.
    WHEN 'TRANSFER'. "TRANSFER HANDLING UNIT
      CLEAR SY-UCOMM.
      CLEAR OKCODE.
      PERFORM F_TRANSFERHU.
  ENDCASE.
ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'PF1000'.
ENDFORM.                    " F_GUI_STATUS


*&---------------------------------------------------------------------*
*&      Form  TRANSFERHU
*&---------------------------------------------------------------------*
FORM F_TRANSFERHU .
  DATA : VISERROR(1) TYPE C,
         VLINE TYPE I.

  " Added by William at 06.06.2026 (move pallet RTP)
  DATA: IT_ZPALLETR LIKE ZPALLETR OCCURS 0 WITH HEADER LINE.
  DATA: IT_MAP_PALLET LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE.
  DATA: IT_ERROR_PALLET LIKE ITAB OCCURS 0 WITH HEADER LINE.

  DATA: GMHEAD LIKE BAPI2017_GM_HEAD_01.
  DATA: GMCODE LIKE BAPI2017_GM_CODE.
  DATA  MATDOC TYPE BAPI2017_GM_HEAD_RET-MAT_DOC.
  DATA: IT_GOODSMVT_ITEM LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE.
  DATA: IT_RETURN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.

  DATA: IT_EXIDV TYPE HUM_EXIDV_T,
        IT_VEPO LIKE VEPOVB OCCURS 0,
        WA_VEPO LIKE VEPOVB OCCURS 0 WITH HEADER LINE.
  " End added by William at 06.06.2026 (move pallet RTP)

  CLEAR : DD, MM,YYYY, DATE.

  YYYY = SY-DATUM+0(4).
  MM = SY-DATUM+4(2).
  DD = SY-DATUM+6(2).
  CONCATENATE DD MM YYYY INTO DATE.

  CLEAR WADATA.
  READ TABLE ITALV INTO WADATA INDEX 1.

  IF WADATA-MATDOC <> ' '.
    MESSAGE 'Error, Transfer HU telah dilakukan sebelumnya!' TYPE 'I'.
  ELSE.

    "CALL BAPI
    LOOP AT ITALV.
      CLEAR : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.
      REFRESH : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = ITALV-EXIDV
        IMPORTING
          OUTPUT = ITALV-EXIDV.

      IT_MOVE_TO-LGORT = ITALV-SLOCT.
      APPEND IT_MOVE_TO.
      MOVE ITALV-EXIDV TO IT_EXTERNAL_ID-EXIDV.
      APPEND  IT_EXTERNAL_ID.

      CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
        EXPORTING
          IF_EVENT       = IF_EVENT
          IF_TCODE       = IF_TCODE
          IT_MOVE_TO     = IT_MOVE_TO[]
          IT_EXTERNAL_ID = IT_EXTERNAL_ID[]
        IMPORTING
          ES_MESSAGE     = ES_MESSAGE
          ET_MESSAGES    = ET_MESSAGES[].

      IF SY-SUBRC = 0.
        LOOP AT ET_MESSAGES.
          "JIKA ERROR
          IF ET_MESSAGES-MSGTY = 'E'.
            ITALV-MATDOC = ''.
          ELSE.
            ITALV-MATDOC = ET_MESSAGES-MSGV1.
          ENDIF.
        ENDLOOP.

        IF ITALV-MATDOC = ''.
          ITALV-KET = 'Error, Transfer HU Gagal'.
          ITALV-MATDOC = '-'.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.

          ITALV-MATDOC = ET_MESSAGES-MSGV1.
          ITALV-KET = 'Transfer HU Sukses'.
          "UPDATE DATA IN ZPACKPCL.
          CLEAR : WA_PSOURCE, T_PSOURCE,VENUM.
          REFRESH : T_PSOURCE.
          SELECT SINGLE VENUM INTO VENUM FROM VEKP WHERE VEKP~EXIDV = ITALV-EXIDV.

          SELECT SINGLE * INTO WA_PSOURCE FROM ZPACK_PCL WHERE VENUM = VENUM.
          WA_PSOURCE-FM = 'X'.
          UPDATE ZPACK_PCL FROM WA_PSOURCE.
          COMMIT WORK AND WAIT.

          "GET ALL DATA FROM ZPACKPCL (BOX)
          SELECT * INTO CORRESPONDING FIELDS OF TABLE T_PSOURCE
            FROM ZPACK_PCL
            WHERE HUSEQ_P = WA_PSOURCE-HUSEQ
            AND VENUM NE ''
            AND PINNR = WA_PSOURCE-PINNR .

          IF SY-SUBRC = 0.
            CLEAR WA_PSOURCE.
            LOOP AT T_PSOURCE INTO WA_PSOURCE.
              WA_PSOURCE-FM = 'X'.
              UPDATE ZPACK_PCL FROM WA_PSOURCE.
              COMMIT WORK AND WAIT.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ELSE.
        ITALV-MATDOC = '-'.
        ITALV-KET = 'Error, Transfer HU Gagal'.
      ENDIF.
      MODIFY ITALV.
    ENDLOOP.

    "CEK IF TRANSFER HU CONTAINS ERROR.
    CLEAR WADATA.
    READ TABLE ITALV WITH KEY MATDOC = '-'.

    IF SY-SUBRC = 0.
      LOOP AT ITALV.
        REFRESH : IT_BDCDATA ,IT_BDCMSGCOLL.
        IF ITALV-MATDOC NE '-' .

          "CANCEL TRANSFER HU
          PERFORM BDC_DYNPRO      USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ONLI'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'SP_MBLNR'.
          PERFORM BDC_FIELD       USING 'SP_PSTDA'
                                        DATE.
          PERFORM BDC_FIELD       USING 'SP_MBLNR'
                                        ITALV-MATDOC.
          PERFORM BDC_FIELD       USING 'SP_MJAHR'
                                        YYYY.

          CALL TRANSACTION 'HUCANC' USING IT_BDCDATA
                  MODE 'E'
                  UPDATE 'S'
                  MESSAGES INTO IT_BDCMSGCOLL.

          ITALV-KET    = 'HU OK, Not transferred'.
          ITALV-MATDOC = '-'.
        ELSE.
          IF ITALV-KET = 'Error, Transfer HU Gagal'.
            ITALV-KET = 'HU Locked, Not transferred'.
            ITALV-MATDOC = '-'.
          ENDIF.
        ENDIF.

        MODIFY ITALV.
      ENDLOOP.

      CLEAR VLINE.
      DESCRIBE TABLE ITALV LINES VLINE.
      IF VLINE = 1.
        MESSAGE 'HU Not Transferred.' TYPE 'I'.
      ELSE.
        MESSAGE 'All HU are Not Transferred.' TYPE 'I'.
      ENDIF.
    ELSE.
      "UPDATE DATA OF INTERNAL TABLE WHICH DISPLAY IN TABLE CONTROL
      LOOP AT ITALV.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = ITALV-EXIDV
          IMPORTING
            OUTPUT = ITALV-EXIDV.

        LOOP AT ITDATA WHERE EXIDV = ITALV-EXIDV.
          DELETE ITDATA.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    " Added by William at 06.06.2026 (move pallet RTP)
    " Rules: hanya bisa dilakukan kalau semua HU tidak error, sesuai mekanisme di atas
    " Kalau pallet gagal pindah tidak akan mengganggu perpindahan HU
    "CEK IF TRANSFER HU CONTAINS ERROR.
    CLEAR WADATA.
    READ TABLE ITALV WITH KEY MATDOC = '-'.

    IF SY-SUBRC NE 0.
      LOOP AT ITALV.
        CLEAR: IT_EXIDV, IT_VEPO, WA_VEPO.
        REFRESH: IT_EXIDV, IT_VEPO.

        APPEND ITALV-EXIDV TO IT_EXIDV.

        CALL FUNCTION 'HU_GET_HUS_DB'
          EXPORTING
            IT_HU_NUMBERS = IT_EXIDV
          IMPORTING
            ET_HU_ITEMS   = IT_VEPO.

        CLEAR: IT_ZPALLETR.
        REFRESH: IT_ZPALLETR.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ZPALLETR
          FROM ZPALLETR
          WHERE EXIDV = ITALV-EXIDV
          AND STATUS = 'P'.

        IF IT_ZPALLETR[] IS NOT INITIAL.
          " Get mapping Sloc pallet movement
          CLEAR: IT_MAP_PALLET.
          REFRESH: IT_MAP_PALLET.

          SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAP_PALLET
            FROM ZMAP_TYPE
            WHERE DELETION NE 'X'
            AND TCODE = SY-TCODE
            AND TYPE = 'PALLET'
            AND OPT = 'MOVE_STLOC'.

*          IF IT_MAP_PALLET[] IS INITIAL.
*            " Mapping not maintained, skip
*            CONTINUE.
*          ENDIF.

          LOOP AT IT_ZPALLETR.
            CLEAR: GMHEAD, GMCODE, MATDOC, IT_GOODSMVT_ITEM, IT_RETURN.
            REFRESH: IT_GOODSMVT_ITEM, IT_RETURN.

            " Set data header
            GMHEAD-DOC_DATE   = SY-DATUM.
            GMHEAD-PSTNG_DATE = SY-DATUM.
            GMHEAD-PR_UNAME   = SY-UNAME.
            GMCODE-GM_CODE    = '04'.   "04 - MB1B - Transfer Posting

            " Mvt Pallet
            IT_GOODSMVT_ITEM-MOVE_TYPE  = '311'.

            " Plant
            CLEAR: WA_VEPO.
            LOOP AT IT_VEPO INTO WA_VEPO WHERE CHARG IS NOT INITIAL.
              IT_GOODSMVT_ITEM-PLANT = WA_VEPO-WERKS.
              IT_GOODSMVT_ITEM-MOVE_PLANT = WA_VEPO-WERKS.
            ENDLOOP.

            " Material
            SELECT SINGLE MATNR INTO IT_GOODSMVT_ITEM-MATERIAL
              FROM MCH1
              WHERE CHARG = IT_ZPALLETR-PALID.

            " UoM
            SELECT SINGLE MEINS INTO IT_GOODSMVT_ITEM-ENTRY_UOM FROM MARA WHERE MATNR = IT_GOODSMVT_ITEM-MATERIAL.

            " Sloc Asal/STGE_LOC
            SELECT SINGLE LGORT INTO IT_GOODSMVT_ITEM-STGE_LOC
              FROM MCHB
              WHERE CHARG = IT_ZPALLETR-PALID
              AND CLABS > 0.

            IF SY-SUBRC NE 0.
              CLEAR IT_ERROR_PALLET.
              MOVE-CORRESPONDING ITALV TO IT_ERROR_PALLET.
              IT_ERROR_PALLET-MATDOC = '-'.
              CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal: Pallet tidak ditemukan!' INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
              APPEND IT_ERROR_PALLET.
              CLEAR IT_ERROR_PALLET.
              CONTINUE.
            ENDIF.

            " Sloc Tujuan/MOVE_STLOC
            READ TABLE IT_MAP_PALLET WITH KEY TCODE = SY-TCODE
                                              TEXT1 = ITALV-SLOCT.
            IF SY-SUBRC NE 0.
              CLEAR IT_ERROR_PALLET.
              MOVE-CORRESPONDING ITALV TO IT_ERROR_PALLET.
              IT_ERROR_PALLET-MATDOC = '-'.
              CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal: Sloc tujuan pallet tidak ditemukan!' INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
              APPEND IT_ERROR_PALLET.
              CLEAR IT_ERROR_PALLET.
              CONTINUE.
            ELSE.
              IT_GOODSMVT_ITEM-MOVE_STLOC      = IT_MAP_PALLET-TEXT2.  "sloc target.
            ENDIF.

            IT_GOODSMVT_ITEM-MVT_IND         = ' '.
            IT_GOODSMVT_ITEM-ENTRY_QNT       = '1'.  "itab_data-quant.
            IT_GOODSMVT_ITEM-BATCH           = IT_ZPALLETR-PALID.

            APPEND IT_GOODSMVT_ITEM.
            CLEAR IT_GOODSMVT_ITEM.

            CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
              EXPORTING
                GOODSMVT_HEADER  = GMHEAD
                GOODSMVT_CODE    = GMCODE
              IMPORTING
                MATERIALDOCUMENT = MATDOC
              TABLES
                GOODSMVT_ITEM    = IT_GOODSMVT_ITEM
                RETURN           = IT_RETURN.

            READ TABLE IT_RETURN WITH KEY TYPE = 'E'.
            IF SY-SUBRC NE 0.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
            ELSE.
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

              CLEAR: IT_ERROR_PALLET.
              MOVE-CORRESPONDING ITALV TO IT_ERROR_PALLET.
              IT_ERROR_PALLET-MATDOC = '-'.
              READ TABLE IT_RETURN WITH KEY TYPE = 'E'.
              CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal:' IT_RETURN-MESSAGE INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
              APPEND IT_ERROR_PALLET.
              CLEAR IT_ERROR_PALLET.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

      " Add error data to ITALV
      IF IT_ERROR_PALLET[] IS NOT INITIAL.
        MOVE-CORRESPONDING IT_ERROR_PALLET TO ITALV.
        APPEND IT_ERROR_PALLET.
      ENDIF.
      CLEAR: IT_ERROR_PALLET.
      REFRESH: IT_ERROR_PALLET.
    ENDIF.
    " End added by William at 06.06.2026 (move pallet RTP)

    "UPDATE DATA IN TABLE CONTROL
    REFRESH CONTROL 'TCHU' FROM SCREEN '0100'.

    PERFORM F_DISPLAY_DATA2.

  ENDIF.
ENDFORM.                    " TRANSFERHU

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG2
*&---------------------------------------------------------------------*
FORM F_FIELD_CATALOG2 .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITALV' :
    'EXIDV'   '' ''  '' ''  'HU Number'     '' ' ' '' '',
    'SLOCA'   '' ''  '' ''  'Sloc Asal'     '' ' ' '' '',
    'STATUS'  '' ''  '' ''  'User Status'   '' ' ' '' '',
    'SLOCT'   '' ''  '' ''  'Sloc Tujuan'   '' ' ' '' '',
    'MATDOC'  '' ''  '' ''  'Material Doc.' '' ' ' '' '',
    'KET'     '' ''  '' ''  'Keterangan'    '' ' ' '' ''.
ENDFORM.                    " F_FIELD_CATALOG2

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG3
*&---------------------------------------------------------------------*
FORM F_FIELD_CATALOG3 .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB1' :
    'EXIDV'   '' ''  '' ''  'HU Number'       '' ' ' '' '',
    'SLOCA'   '' ''  '' ''  'Sloc Asal'    '' ' ' '' '',
    'STATUS'   '' ''  '' ''  'User Status'   '' ' ' '' '',
    'SLOCT'  '' ''  '' ''  'Sloc Tujuan'      '' ' ' '' '',
    'MATDOC'  '' ''  '' ''  'Material Doc.'      '' ' ' '' '',
    'KET'  '' ''  '' ''  'Keterangan'      '' ' ' '' ''.
ENDFORM.                    " F_FIELD_CATALOG3

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
FORM F_SELECT_ALL .
  LOOP AT ITDATA.
    ITDATA-MARK = 'X'.
    MODIFY ITDATA.
  ENDLOOP.
ENDFORM.                    " SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL
*&---------------------------------------------------------------------*
FORM  F_DESELECT_ALL .
  LOOP AT ITDATA.
    ITDATA-MARK = ''.
    MODIFY ITDATA.
  ENDLOOP.
ENDFORM.                    " DESELECT_ALL


*&---------------------------------------------------------------------*
*&      Form  GETDATATRANSFER
*&---------------------------------------------------------------------*
FORM F_GETDATATRANSFER .
  DATA  : MSG TYPE C LENGTH 30,
          N TYPE I.

  DATA : ITSLOC TYPE TABLE OF TYSLOC WITH HEADER LINE.
  ITALV[] = ITDATA[].
  DELETE ITALV WHERE MARK NE 'X'.

  "check apakah user memilih item atau tidak
  IF ITALV[] IS INITIAL.
    MESSAGE 'Please Select any HU'  TYPE 'I'.
  ELSE.
    "CHECK APAKAH SEMUA SLOC TUJUAN DIISI.
    CLEAR N.
    LOOP AT ITALV WHERE SLOCT = ''.
      N = N + 1.
    ENDLOOP.

    IF N <> 0.
      MESSAGE 'Please Input SLoc Tujuan for all of selected HU'  TYPE 'I'.
    ELSE.
      CLEAR N.
      LOOP AT ITALV WHERE STATUS <> 'QAOK'.
        N = N + 1.
      ENDLOOP.

      IF N >= 1.
        CLEAR OKCODE.
        MESSAGE 'Please Input HU which status = QAOK!'  TYPE 'I'.
      ELSE.

        IF P1 = 'X'.
          "get data sloc
          CLEAR : WSLOC, ITSLOC, TSLOC.
          REFRESH : TSLOC, ITSLOC.

          SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
            INTO CORRESPONDING FIELDS OF TABLE ITSLOC
            FROM ZHU_MAPP
            WHERE ZHU_MAPP~LGOR2 LIKE '1%'
            AND ZHU_MAPP~TYPES = '1' AND ZHU_MAPP~WERK2 = '1000'.  "ADD NEW COMPANY

          LOOP AT ITSLOC.
            WSLOC-SIGN   = 'I'.
            WSLOC-OPTION = 'EQ'.
            WSLOC-LOW    = ITSLOC-SLOC.

            APPEND WSLOC TO TSLOC.
          ENDLOOP.
          CLEAR N.
          LOOP AT ITALV.
            "CHECK IF SLOC TUJUAN CORRECT
            IF ITALV-SLOCT IN TSLOC.
            ELSE.
              N = N + 1.
            ENDIF.
          ENDLOOP.
        ELSEIF P2 = 'X'.
          "get data sloc
          CLEAR : WSLOC, ITSLOC, TSLOC.
          REFRESH : TSLOC, ITSLOC.

          SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
            INTO CORRESPONDING FIELDS OF TABLE ITSLOC
            FROM ZHU_MAPP
            WHERE ZHU_MAPP~LGOR2 LIKE '2%'
            AND ZHU_MAPP~TYPES = '1' AND ZHU_MAPP~WERK2 = '2000'.  "ADD NEW COMPANY

          LOOP AT ITSLOC.
            WSLOC-SIGN   = 'I'.
            WSLOC-OPTION = 'EQ'.
            WSLOC-LOW    = ITSLOC-SLOC.
            APPEND WSLOC TO TSLOC.
          ENDLOOP.

          CLEAR L_ERRNO.
          LOOP AT ITALV.
            CLEAR N.
            "CHECK IF SLOC TUJUAN CORRECT
            IF ITALV-SLOCT IN TSLOC.
              PERFORM F_CHECK_ERROR CHANGING N L_ERRNO.
            ELSE.
              N = N + 1.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF N >= 1.
          CLEAR OKCODE.
          MESSAGE 'Please check SLoc Tujuan'  TYPE 'I'.
        ELSE.
          IF L_ERRNO <> -1.
            PERFORM F_DISPLAYDATA.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GETDATATRANSFER


*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*

FORM F_UPLOAD_DATA .
  DATA : VENUM TYPE VEPO-VENUM,
         STAT(1) TYPE C VALUE 'F',
         INDICATOR(1) TYPE C,
         LEN TYPE I,
         VPLANT LIKE VEPO-WERKS. "ADD NEW COMPANY

  DATA : ITSLOC TYPE TABLE OF TYSLOC WITH HEADER LINE.
  DATA: V_EXIDV LIKE VEKP-EXIDV, V_MSG(100).

  DATA: IT_EXIDV TYPE HUM_EXIDV_T,    "ADD NEW COMPANY
        IT_VEPO LIKE VEPOVB OCCURS 0, "ADD NEW COMPANY
        WA_VEPO LIKE VEPOVB OCCURS 0 WITH HEADER LINE.  "ADD NEW COMPANY

  " Added by William at 19.02.2026 (move pallet RTP)
  DATA: IT_ZPALLETR LIKE ZPALLETR OCCURS 0 WITH HEADER LINE.
  DATA: IT_MAP_PALLET LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE.
  DATA: IT_ERROR_PALLET LIKE ITAB OCCURS 0 WITH HEADER LINE.

  DATA: GMHEAD LIKE BAPI2017_GM_HEAD_01.
  DATA: GMCODE LIKE BAPI2017_GM_CODE.
  DATA  MATDOC TYPE BAPI2017_GM_HEAD_RET-MAT_DOC.
  DATA: IT_GOODSMVT_ITEM LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE.
  DATA: IT_RETURN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.
  " End added by William at 19.02.2026 (move pallet RTP)

  CLEAR : DD, MM,YYYY, DATE.
  REFRESH : ITAB1, ITAB.
  YYYY = SY-DATUM+0(4).
  MM = SY-DATUM+4(2).
  DD = SY-DATUM+6(2).
  CONCATENATE DD MM YYYY INTO DATE.

  IF FPATH IS INITIAL.
    MESSAGE 'Please input a file' TYPE 'I'.
  ELSE.
    MOVE FPATH TO FNAME.
    MOVE FPATH TO P_FILE.

    "CHECK EKSTENSION OF FILE.
    SHIFT P_FILE RIGHT CIRCULAR BY 3 PLACES.
    MOVE P_FILE(3) TO EKS.

    IF EKS = 'TXT' OR  EKS = 'txt'.

      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME            = FNAME
          FILETYPE            = 'ASC'
          HAS_FIELD_SEPARATOR = 'X'
        TABLES
          DATA_TAB            = ITAB.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
*- cek double HU
        SORT ITAB BY EXIDV ASCENDING.
        LOOP AT ITAB.
          IF V_EXIDV = ITAB-EXIDV.
            CONCATENATE 'HU nomor' V_EXIDV 'ganda, silahkan dikoreksi.' INTO V_MSG SEPARATED BY SPACE.
            MESSAGE V_MSG TYPE 'I'.
            RETURN.
          ENDIF.
          V_EXIDV = ITAB-EXIDV.

          "Add New Company
          "CEK PLANT Trias
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = ITAB-EXIDV
            IMPORTING
              OUTPUT = ITAB-EXIDV.

          CLEAR: IT_EXIDV, IT_VEPO.
          REFRESH: IT_EXIDV, IT_VEPO.

          APPEND ITAB-EXIDV TO IT_EXIDV.

          CALL FUNCTION 'HU_GET_HUS_DB'
            EXPORTING
              IT_HU_NUMBERS = IT_EXIDV
            IMPORTING
              ET_HU_ITEMS   = IT_VEPO.

          LOOP AT IT_VEPO INTO WA_VEPO WHERE CHARG IS NOT INITIAL.
          ENDLOOP.

          IF WA_VEPO-WERKS NE '1000' AND WA_VEPO-WERKS NE '2000'.
            CONCATENATE 'HU nomor' V_EXIDV ', bukan HU Trias.' INTO V_MSG SEPARATED BY SPACE.
            MESSAGE V_MSG TYPE 'I'.
            RETURN.
          ENDIF.
          "End New Company
        ENDLOOP.

        LOOP AT ITAB.
          CLEAR : UNVEL,VPLANT.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = ITAB-EXIDV
            IMPORTING
              OUTPUT = ITAB-EXIDV.

          "CEK LOW LEVEL
          SELECT SINGLE VEPO~UNVEL
            INTO UNVEL
            FROM VEPO JOIN VEKP
            ON VEPO~VENUM = VEKP~VENUM
            WHERE VEKP~EXIDV = ITAB-EXIDV.

          IF UNVEL = ''.
            SELECT SINGLE VEPO~LGORT VEPO~WERKS
              INTO (ITAB-SLOCA, VPLANT)  "ADD NEW COMPANY
              FROM VEPO
              JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
              WHERE VEKP~EXIDV = ITAB-EXIDV.
          ELSE.
            SELECT SINGLE VEPO~LGORT VEPO~WERKS
             INTO (ITAB-SLOCA, VPLANT)  "ADD NEW COMPANY
             FROM VEPO
             WHERE VEPO~VENUM = UNVEL.
          ENDIF.

          IF ITAB-SLOCA = ''.
            ITAB-KET = 'Error, SLoc Asal kosong'.
            ITAB-MATDOC = '-'.
          ELSE.
            INDICATOR = ITAB-SLOCA+0(1).
            CLEAR : STAT.

            IF INDICATOR = '1'.

              CLEAR : WSLOC, ITSLOC, TSLOC.
              REFRESH : TSLOC, ITSLOC.

              SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
                INTO CORRESPONDING FIELDS OF TABLE ITSLOC
                FROM ZHU_MAPP
                WHERE ZHU_MAPP~LGOR2 LIKE '1%' AND ZHU_MAPP~WERK2 EQ VPLANT  "ADD NEW COMPANY
                AND ZHU_MAPP~TYPES = '1'.

              LOOP AT ITSLOC.
                WSLOC-SIGN   = 'I'.
                WSLOC-OPTION = 'EQ'.
                WSLOC-LOW    = ITSLOC-SLOC.
                APPEND WSLOC TO TSLOC.
              ENDLOOP.

              IF ITAB-SLOCT IN TSLOC.
                STAT = 'T'.
                IF ITAB-SLOCA = ITAB-SLOCT.
                  STAT = 'C'.
                ENDIF.

              ELSE.
                IF ITAB-SLOCA = ITAB-SLOCT.
                  STAT = 'C'.
                ELSE.
                  STAT = 'F'.
                ENDIF.

              ENDIF.
*- add by ALF case on plant JKT
            ELSEIF INDICATOR = '3'.
              CLEAR : WSLOC, ITSLOC, TSLOC.
              REFRESH : TSLOC, ITSLOC.

              SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
                INTO CORRESPONDING FIELDS OF TABLE ITSLOC
                FROM ZHU_MAPP
                WHERE ZHU_MAPP~LGOR2 LIKE '3%' AND ZHU_MAPP~WERK2 EQ VPLANT  "ADD NEW COMPANY
                AND ZHU_MAPP~TYPES = '1'.

              IF SY-SUBRC NE 0.
                STAT = 'F'.
              ELSE.
                LOOP AT ITSLOC.
                  WSLOC-SIGN   = 'I'.
                  WSLOC-OPTION = 'EQ'.
                  WSLOC-LOW    = ITSLOC-SLOC.
                  APPEND WSLOC TO TSLOC.
                ENDLOOP.

                IF ITAB-SLOCT IN TSLOC.
                  STAT = 'T'.
                  IF ITAB-SLOCA = ITAB-SLOCT.
                    STAT = 'C'.
                  ENDIF.

                ELSE.
                  IF ITAB-SLOCA = ITAB-SLOCT.
                    STAT = 'C'.
                  ELSE.
                    STAT = 'F'.
                  ENDIF.

                ENDIF.
              ENDIF.
*- end of add by ALF case on plant JKT
            ELSE.
              CLEAR : WSLOC, ITSLOC, TSLOC.
              REFRESH : TSLOC, ITSLOC.

              SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
                INTO CORRESPONDING FIELDS OF TABLE ITSLOC
                FROM ZHU_MAPP
                WHERE ZHU_MAPP~LGOR2 LIKE '2%' AND ZHU_MAPP~WERK2 EQ VPLANT  "ADD NEW COMPANY
                AND ZHU_MAPP~TYPES = '1'.

              LOOP AT ITSLOC.
                WSLOC-SIGN   = 'I'.
                WSLOC-OPTION = 'EQ'.
                WSLOC-LOW    = ITSLOC-SLOC.

                APPEND WSLOC TO TSLOC.
              ENDLOOP.

              IF ITAB-SLOCT IN  TSLOC.
                STAT = 'T'.
                IF ITAB-SLOCA = ITAB-SLOCT.
                  STAT = 'C'.
                ENDIF.
              ELSE.
                IF ITAB-SLOCA = ITAB-SLOCT.
                  STAT = 'C'.
                ELSE.
                  STAT = 'F'.
                ENDIF.
              ENDIF.
            ENDIF.

            "CEK APAKAH SLOC TUJUAN SALAH
            IF STAT = 'F'.
              ITAB-KET = 'Error, SLoc tujuan tidak sesuai'.
              ITAB-MATDOC = '-'.
            ELSEIF STAT = 'C'.
              ITAB-KET = 'Error, SLoc awal dan Sloc tujuan sama'.
              ITAB-MATDOC = '-'.
            ELSEIF STAT = 'T'.
              "CHECK STATUS HU
              CLEAR : STAT, OBJNR, VENUM.

              "get venum
              SELECT SINGLE VEKP~VENUM
                INTO VENUM
                FROM VEKP
                WHERE VEKP~EXIDV = ITAB-EXIDV.

              "GET STATUS.
              CONCATENATE 'HU' VENUM INTO OBJNR.

              SELECT SINGLE TJ30T~TXT04
                INTO ITAB-STATUS
                FROM TJ30T
                JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
                JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
                WHERE HUSSTAT~OBJNR = OBJNR
                AND HUSSTAT~STAT = TJ30T~ESTAT
                AND HUSSTAT~INACT = ''
                AND TJ30T~SPRAS = 'EN'.

              IF ITAB-STATUS = 'QAOK'.
                STAT = 'T'.
              ELSE.
                STAT = 'F'.
                ITAB-KET = 'Error, Status HU tidak QAOK'.
                ITAB-MATDOC = '-'.
              ENDIF.
            ENDIF.
          ENDIF.

          "GET STATUS.
          CLEAR VENUM.
          SELECT SINGLE VENUM
            INTO VENUM
            FROM VEKP
            WHERE VEKP~EXIDV = ITAB-EXIDV.

          CONCATENATE 'HU' VENUM INTO OBJNR.
          SELECT SINGLE TJ30T~TXT04
            INTO ITAB-STATUS
            FROM TJ30T
            JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
            JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
            WHERE HUSSTAT~OBJNR = OBJNR
            AND HUSSTAT~STAT = TJ30T~ESTAT
            AND HUSSTAT~INACT = ''
            AND TJ30T~SPRAS = 'EN'.

          MODIFY ITAB.
        ENDLOOP.
      ENDIF.

*-- process hu goods movement
      READ TABLE ITAB WITH KEY MATDOC = '-'.
      IF SY-SUBRC EQ 0.
        LOOP AT ITAB WHERE MATDOC NE '-'.
          ITAB-KET = 'HU OK, Not transferred'.
          ITAB-MATDOC = '-'.
          MODIFY ITAB.
        ENDLOOP.
      ELSE.
        LOOP AT ITAB.
*                ELSEIF STAT = 'T'. "JIKA STATUS HU QAOK
          CLEAR : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.
          REFRESH : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.

          MOVE ITAB-SLOCT TO IT_MOVE_TO-LGORT.
          MOVE ITAB-EXIDV TO IT_EXTERNAL_ID-EXIDV.
          APPEND IT_MOVE_TO.
          APPEND IT_EXTERNAL_ID.

          "CAL BAPI HU_CREATE_GOODS_MOVEMENT FOR TRANSFERRING HU
          CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
            EXPORTING
              IF_EVENT       = IF_EVENT
              IF_TCODE       = IF_TCODE
              IT_MOVE_TO     = IT_MOVE_TO[]
              IT_EXTERNAL_ID = IT_EXTERNAL_ID[]
            IMPORTING
              ES_MESSAGE     = ES_MESSAGE
              ET_MESSAGES    = ET_MESSAGES[].

          IF SY-SUBRC = 0.
            LOOP AT ET_MESSAGES.
              ITAB-MATDOC = ET_MESSAGES-MSGV1.
            ENDLOOP.

            IF ITAB-MATDOC = ''.
              ITAB-MATDOC = '-'.
              ITAB-KET    = 'Error, Transfer HU Gagal'.
            ELSE.

              "- bagus
              READ TABLE ET_MESSAGES WITH KEY MSGID = 'M7' MSGTY = 'E' MSGNO = '120'.
              IF SY-SUBRC NE 0.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    WAIT = 'X'.

                ITAB-KET    = 'Transfer HU Sukses'.
              ELSE.
                ITAB-KET    = 'No Authorization to process data'.
              ENDIF. " :)

              "UPDATE DATA IN ZPACKPCL.
              CLEAR : WA_PSOURCE, T_PSOURCE,VENUM.
              REFRESH : T_PSOURCE.
              SELECT SINGLE VENUM INTO VENUM FROM VEKP WHERE VEKP~EXIDV = ITALV-EXIDV.

              SELECT SINGLE * INTO WA_PSOURCE FROM ZPACK_PCL WHERE VENUM = VENUM.
              WA_PSOURCE-FM = 'X'.
              UPDATE ZPACK_PCL FROM WA_PSOURCE.
              COMMIT WORK AND WAIT.

              "GET ALL DATA FROM ZPACKPCL (BOX)
              SELECT * INTO CORRESPONDING FIELDS OF TABLE T_PSOURCE
                FROM ZPACK_PCL
                WHERE HUSEQ_P = WA_PSOURCE-HUSEQ
                AND VENUM NE ''
                AND PINNR = WA_PSOURCE-PINNR .

              IF SY-SUBRC = 0.
                CLEAR WA_PSOURCE.
                LOOP AT T_PSOURCE INTO WA_PSOURCE.
                  WA_PSOURCE-FM = 'X'.
                  UPDATE ZPACK_PCL FROM WA_PSOURCE.
                  COMMIT WORK AND WAIT.
                ENDLOOP.
              ENDIF.

              " Added by William at 19.02.2026 (move pallet RTP)
              CLEAR: IT_ZPALLETR.
              REFRESH: IT_ZPALLETR.
              SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ZPALLETR
                FROM ZPALLETR
                WHERE EXIDV = ITAB-EXIDV
                AND STATUS = 'P'.

              IF IT_ZPALLETR[] IS NOT INITIAL.
                " Get mapping Sloc pallet movement
                CLEAR: IT_MAP_PALLET.
                REFRESH: IT_MAP_PALLET.

                SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAP_PALLET
                  FROM ZMAP_TYPE
                  WHERE DELETION NE 'X'
                  AND TCODE = SY-TCODE
                  AND TYPE = 'PALLET'
                  AND OPT = 'MOVE_STLOC'.

*                IF IT_MAP_PALLET[] IS INITIAL.
*                  " Mapping not maintained, skip
*                  CONTINUE.
*                ENDIF.

                LOOP AT IT_ZPALLETR.
                  CLEAR: GMHEAD, GMCODE, MATDOC, IT_GOODSMVT_ITEM, IT_RETURN.
                  REFRESH: IT_GOODSMVT_ITEM, IT_RETURN.

                  " Set data header
                  GMHEAD-DOC_DATE   = SY-DATUM.
                  GMHEAD-PSTNG_DATE = SY-DATUM.
                  GMHEAD-PR_UNAME   = SY-UNAME.
                  GMCODE-GM_CODE    = '04'.   "04 - MB1B - Transfer Posting

                  " Mvt Pallet
                  IT_GOODSMVT_ITEM-MOVE_TYPE  = '311'.

                  " Plant
                  CLEAR: WA_VEPO.
                  LOOP AT IT_VEPO INTO WA_VEPO WHERE CHARG IS NOT INITIAL.
                    IT_GOODSMVT_ITEM-PLANT = WA_VEPO-WERKS.
                    IT_GOODSMVT_ITEM-MOVE_PLANT = WA_VEPO-WERKS.
                  ENDLOOP.

                  " Material
                  SELECT SINGLE MATNR INTO IT_GOODSMVT_ITEM-MATERIAL
                    FROM MCH1
                    WHERE CHARG = IT_ZPALLETR-PALID.

                  " UoM
                  SELECT SINGLE MEINS INTO IT_GOODSMVT_ITEM-ENTRY_UOM FROM MARA WHERE MATNR = IT_GOODSMVT_ITEM-MATERIAL.

                  " Sloc Asal/STGE_LOC
                  SELECT SINGLE LGORT INTO IT_GOODSMVT_ITEM-STGE_LOC
                    FROM MCHB
                    WHERE CHARG = IT_ZPALLETR-PALID
                    AND CLABS > 0.

                  IF SY-SUBRC NE 0.
                    CLEAR IT_ERROR_PALLET.
                    MOVE-CORRESPONDING ITAB TO IT_ERROR_PALLET.
                    IT_ERROR_PALLET-MATDOC = '-'.
                    CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal: Pallet tidak ditemukan!' INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
                    APPEND IT_ERROR_PALLET.
                    CLEAR IT_ERROR_PALLET.
                    CONTINUE.
                  ENDIF.

                  " Sloc Tujuan/MOVE_STLOC
                  READ TABLE IT_MAP_PALLET WITH KEY TCODE = SY-TCODE
                                                    TEXT1 = ITAB-SLOCT.
                  IF SY-SUBRC NE 0.
                    CLEAR IT_ERROR_PALLET.
                    MOVE-CORRESPONDING ITAB TO IT_ERROR_PALLET.
                    IT_ERROR_PALLET-MATDOC = '-'.
                    CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal: Sloc tujuan pallet tidak ditemukan!' INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
                    APPEND IT_ERROR_PALLET.
                    CLEAR IT_ERROR_PALLET.
                    CONTINUE.
                  ELSE.
                    IT_GOODSMVT_ITEM-MOVE_STLOC      = IT_MAP_PALLET-TEXT2.  "sloc target.
                  ENDIF.

                  IT_GOODSMVT_ITEM-MVT_IND         = ' '.
                  IT_GOODSMVT_ITEM-ENTRY_QNT       = '1'.  "itab_data-quant.
                  IT_GOODSMVT_ITEM-BATCH           = IT_ZPALLETR-PALID.

                  APPEND IT_GOODSMVT_ITEM.
                  CLEAR IT_GOODSMVT_ITEM.

                  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                    EXPORTING
                      GOODSMVT_HEADER  = GMHEAD
                      GOODSMVT_CODE    = GMCODE
                    IMPORTING
                      MATERIALDOCUMENT = MATDOC
                    TABLES
                      GOODSMVT_ITEM    = IT_GOODSMVT_ITEM
                      RETURN           = IT_RETURN.

                  READ TABLE IT_RETURN WITH KEY TYPE = 'E'.
                  IF SY-SUBRC NE 0.
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
                  ELSE.
                    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

                    CLEAR: IT_ERROR_PALLET.
                    MOVE-CORRESPONDING ITAB TO IT_ERROR_PALLET.
                    IT_ERROR_PALLET-MATDOC = '-'.
                    READ TABLE IT_RETURN WITH KEY TYPE = 'E'.
                    CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal:' IT_RETURN-MESSAGE INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
                    APPEND IT_ERROR_PALLET.
                    CLEAR IT_ERROR_PALLET.
                  ENDIF.
                ENDLOOP.
              ENDIF.
              " End added by William at 19.02.2026 (move pallet RTP)
            ENDIF.
          ELSE.
            ITAB-MATDOC = '-'.
            ITAB-KET    = 'Error, Transfer HU Gagal'.
          ENDIF.
          MODIFY ITAB.
        ENDLOOP.
      ENDIF.

*      "CEK IF TRANSFER HU CONTAINS ERROR.
*      CLEAR WA_DATA.
*      READ TABLE ITAB WITH KEY MATDOC = '-'.
*      IF SY-SUBRC = 0.
*        LOOP AT ITAB.
*          REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.
*          "CANCEL TRANSFER HU
*          IF ITAB-MATDOC NE '-'.
*            PERFORM BDC_DYNPRO      USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
*            PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=ONLI'.
*            PERFORM BDC_FIELD       USING 'BDC_CURSOR' 'SP_MBLNR'.
*            PERFORM BDC_FIELD       USING 'SP_PSTDA' DATE.
*            PERFORM BDC_FIELD       USING 'SP_MBLNR' ITAB-MATDOC.
*            PERFORM BDC_FIELD       USING 'SP_MJAHR' YYYY.
*
*            CALL TRANSACTION 'HUCANC' USING IT_BDCDATA
*                    MODE 'E'
*                    UPDATE 'S'
*                    MESSAGES INTO IT_BDCMSGCOLL.
*
*            ITAB-KET = 'HU OK, Not transferred'.
*            ITAB-MATDOC = '-'.
*          ELSE.
*            IF ITAB-KET = 'Error, Transfer HU Gagal'.
*              ITAB-KET = 'HU Locked, Not transferred'.
*              ITAB-MATDOC = '-'.
*            ENDIF.
*          ENDIF.
*          MODIFY ITAB.
*        ENDLOOP.
*
*        CLEAR VLINE.
*        DESCRIBE TABLE ITAB LINES VLINE.
*        IF VLINE = 1.
*          MESSAGE 'HU Not Transferred.' TYPE 'I'.
*        ELSE.
*          MESSAGE 'All HU are Not Transferred.' TYPE 'I'.
*        ENDIF.
*      ELSE.
*      ENDIF.

      " Added by William at 19.02.2026 (move pallet RTP)
      " Add error data to ITAB
      IF IT_ERROR_PALLET[] IS NOT INITIAL.
        APPEND LINES OF IT_ERROR_PALLET TO ITAB.
      ENDIF.
      CLEAR: IT_ERROR_PALLET.
      REFRESH: IT_ERROR_PALLET.
      " End added by William at 19.02.2026 (move pallet RTP)

      LOOP AT ITAB.
        MOVE-CORRESPONDING ITAB TO ITAB1.
        APPEND ITAB1.
      ENDLOOP.
      PERFORM F_DISPLAY_DATA3.
    ELSE.
      MESSAGE 'Please upload only .txt file' TYPE 'I'.
      MOVE FPATH TO P_FILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  CLEARDATA
*&---------------------------------------------------------------------*
FORM F_CLEARDATA .
  REFRESH ITDATA.
  CLEAR ITDATA.

  REFRESH CONTROL 'TCHU' FROM SCREEN '0100'.

ENDFORM.                    " CLEARDATA


*&---------------------------------------------------------------------*
*&      Form  SORT_ASC
*&---------------------------------------------------------------------*
FORM F_SORT_ASC .

  SORT ITDATA ASCENDING BY EXIDV.

ENDFORM.                    " SORT_ASC

*&---------------------------------------------------------------------*
*&      Form  SORT_DSC
*&---------------------------------------------------------------------*
FORM F_SORT_DSC .
  SORT ITDATA DESCENDING BY EXIDV.
ENDFORM.                    " SORT_DSC


*&---------------------------------------------------------------------*
*&      Form  FIND_HU
*&---------------------------------------------------------------------*
FORM F_FIND_HU .
  LOOP AT ITDATA.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITDATA-EXIDV
      IMPORTING
        OUTPUT = ITDATA-EXIDV.
    MODIFY ITDATA.
  ENDLOOP.

  DATA : TAB TYPE STANDARD TABLE OF SVAL WITH HEADER LINE.

  TAB-TABNAME = 'VEKP'.
  TAB-FIELDNAME = 'EXIDV'.
  APPEND TAB.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = 'Find HU Number'
      START_COLUMN    = '5'
      START_ROW       = '5'
    TABLES
      FIELDS          = TAB
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    MESSAGE 'No Data Found' TYPE 'I'.
  ELSE.
    READ TABLE ITDATA INTO WADATA WITH KEY EXIDV = TAB-VALUE.
    IF SY-SUBRC = 0.
      TCHU-TOP_LINE = SY-TABIX.

      LOOP AT ITDATA.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = ITDATA-EXIDV
          IMPORTING
            OUTPUT = ITDATA-EXIDV.
        MODIFY ITDATA.
      ENDLOOP.
    ELSE.
      MESSAGE 'No Data Found' TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.                    " FIND_HU


*&---------------------------------------------------------------------*
*&      Form  SET_CELL_COLOURS
*&---------------------------------------------------------------------*
FORM F_SET_CELL_COLOURS .
  DATA: WA_CELLCOLOR TYPE LVC_S_SCOL.
  DATA: LD_INDEX TYPE SY-TABIX.

  LOOP AT ITALV.
    REFRESH ITALV-CELLCOLOR.
    MODIFY ITALV.
  ENDLOOP.

  LOOP AT ITALV WHERE KET NP '*HU OK*'.
    IF ITALV-MATDOC = '-'.
      LD_INDEX = SY-TABIX.
      WA_CELLCOLOR-FNAME = 'EXIDV'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITALV-CELLCOLOR.
      MODIFY ITALV INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'SLOCA'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITALV-CELLCOLOR.
      MODIFY ITALV INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'STATUS'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITALV-CELLCOLOR.
      MODIFY ITALV INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'SLOCT'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITALV-CELLCOLOR.
      MODIFY ITALV INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'MATDOC'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITALV-CELLCOLOR.
      MODIFY ITALV INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'KET'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITALV-CELLCOLOR.
      MODIFY ITALV INDEX LD_INDEX TRANSPORTING CELLCOLOR.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " SET_CELL_COLOURS


*&---------------------------------------------------------------------*
*&      Form  SET_CELL_COLOURS_U
*&---------------------------------------------------------------------*
*       Colour Text for Upload Data Report
*----------------------------------------------------------------------*

FORM F_SET_CELL_COLOURS_U .
*  BREAK-POINT.
  DATA: WA_CELLCOLOR TYPE LVC_S_SCOL.
  DATA: LD_INDEX TYPE SY-TABIX.

  LOOP AT ITAB1.
    REFRESH ITAB1-CELLCOLOR.
    MODIFY ITAB1.
  ENDLOOP.

  LOOP AT ITAB1 WHERE KET NP '*HU OK*'.
    IF ITAB1-MATDOC = '-'.
      LD_INDEX = SY-TABIX.
*   Set colour of EBELN field to various colors based on sy-tabix value
      WA_CELLCOLOR-FNAME = 'EXIDV'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITAB1-CELLCOLOR.
      MODIFY ITAB1 INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'SLOCA'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITAB1-CELLCOLOR.
      MODIFY ITAB1 INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'STATUS'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITAB1-CELLCOLOR.
      MODIFY ITAB1 INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'SLOCT'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITAB1-CELLCOLOR.
      MODIFY ITAB1 INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'MATDOC'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITAB1-CELLCOLOR.
      MODIFY ITAB1 INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'KET'.
      WA_CELLCOLOR-COLOR-COL = 6.  "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '1'.  "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO ITAB1-CELLCOLOR.
      MODIFY ITAB1 INDEX LD_INDEX TRANSPORTING CELLCOLOR.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SET_CELL_COLOURS_U


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAYDATA
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM F_DISPLAYDATA .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " F_DISPLAYDATA


*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                   " BDC_DYNPRO


*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
FORM BDC_FIELD  USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.

ENDFORM.                    " BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
FORM F_LAYOUT .
  DATA: N TYPE I. " Added by William at 20.02.2026 (sort data for display)

  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-COLTAB_FIELDNAME = 'CELLCOLOR'.

  " Added by William at 20.02.2026 (sort data for display)
  N = N + 1.
  T_SORT-SPOS = N.
  T_SORT-FIELDNAME = 'EXIDV'.
  T_SORT-UP = 'X'.
  T_SORT-SUBTOT = ''.
  APPEND T_SORT.

  N = N + 1.
  T_SORT-SPOS = N.
  T_SORT-FIELDNAME = 'SLOCA'.
  T_SORT-UP = 'X'.
  T_SORT-SUBTOT = ''.
  APPEND T_SORT.

  N = N + 1.
  T_SORT-SPOS = N.
  T_SORT-FIELDNAME = 'STATUS'.
  T_SORT-UP = 'X'.
  T_SORT-SUBTOT = ''.
  APPEND T_SORT.

  N = N + 1.
  T_SORT-SPOS = N.
  T_SORT-FIELDNAME = 'SLOCT'.
  T_SORT-UP = 'X'.
  T_SORT-SUBTOT = ''.
  APPEND T_SORT.
  " End added by William at 20.02.2026 (sort data for display)
ENDFORM.                    " F_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_TOP_OF_PAGE   = 'TOP-OF-PAGE'
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = ITALV
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL3 .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_TOP_OF_PAGE  = 'TOP-OF-PAGE'
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
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
      T_OUTTAB                = ITALV
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA2
*&---------------------------------------------------------------------*
FORM F_DISPLAY_DATA2 .
  PERFORM F_FIELD_CATALOG2.
  PERFORM F_LAYOUT.
  PERFORM F_SET_CELL_COLOURS.
  PERFORM F_LIST_DETAIL3.
ENDFORM.                    " F_DISPLAY_DATA2


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA3
*&---------------------------------------------------------------------*
FORM F_DISPLAY_DATA3 .
  PERFORM F_FIELD_CATALOG3.
  PERFORM F_LAYOUT.
  PERFORM F_SET_CELL_COLOURS_U.
  PERFORM F_LIST_DETAIL2.
ENDFORM.                    " F_DISPLAY_DATA3


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL2
*&---------------------------------------------------------------------*
FORM F_LIST_DETAIL2 .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_TOP_OF_PAGE  = 'TOP-OF-PAGE'
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
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
      T_OUTTAB                = ITAB1
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL2


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_ERROR  CHANGING N L_ERRNO.
  "GET MATERIAL HU.
  CLEAR : N,  VMATNR, UNVEL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ITALV-EXIDV
    IMPORTING
      OUTPUT = ITALV-EXIDV.


  SELECT SINGLE VEPO~UNVEL
      INTO UNVEL
      FROM VEPO JOIN VEKP
      ON VEPO~VENUM = VEKP~VENUM
      WHERE VEKP~EXIDV = ITALV-EXIDV.

  IF UNVEL = ''.
    SELECT SINGLE VEPO~MATNR VEPO~WERKS
       INTO (VMATNR , ITALV-WERKS)
       FROM VEPO
       JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
       WHERE VEKP~EXIDV = ITALV-EXIDV.

  ELSE. " Jika masih ada high level HU

    SELECT SINGLE VEPO~MATNR VEPO~WERKS
        INTO (VMATNR, ITALV-WERKS)
        FROM VEPO
        WHERE VEPO~VENUM = UNVEL.

  ENDIF.

  REFRESH ITSLOCT.

  SELECT DISTINCT MARD~LGORT AS SLOC
            INTO CORRESPONDING FIELDS OF TABLE ITSLOCT
            FROM MARD
            WHERE MARD~MATNR = VMATNR
            AND MARD~WERKS = ITALV-WERKS.

  REFRESH TSLOC.
  LOOP AT ITSLOCT.
    CLEAR WSLOC.
    WSLOC-SIGN   = 'I'.
    WSLOC-OPTION = 'EQ'.
    WSLOC-LOW    = ITSLOCT-SLOC.
    APPEND WSLOC TO TSLOC.
  ENDLOOP.

*  BREAK-POINT.
  IF ITALV-SLOCT NOT IN TSLOC.
    N = N + 1.
    L_ERRNO = -1.
    CLEAR MESSAGE.
    CONCATENATE 'Error, SLoc' ITALV-SLOCT 'belum di-maintain' INTO MESSAGE SEPARATED BY SPACE.
    MESSAGE MESSAGE TYPE 'I'.
    ITALV-KET = MESSAGE.
  ELSE.
    CLEAR VLGNUM.
    CASE ITALV-WERKS.
      WHEN '1000'.
        SELECT SINGLE MLGT~LGNUM
          INTO VLGNUM
          FROM MLGT
          WHERE MLGT~MATNR = VMATNR
          AND MLGT~LGNUM = 'W01'.
      WHEN '2000'.
        SELECT SINGLE MLGT~LGNUM
          INTO VLGNUM
          FROM MLGT
          WHERE MLGT~MATNR = VMATNR
          AND MLGT~LGNUM = 'K01'.
    ENDCASE.

    IF SY-SUBRC <> 0.
      N = N + 1.
      L_ERRNO = -1.
      CASE ITALV-WERKS.
        WHEN '1000'.
          MESSAGE 'Error, Warehouse W01 belum di-maintain' TYPE 'I'.
          ITALV-KET = 'Error, Warehouse W01 belum di-maintain'.
        WHEN '2000'.
          MESSAGE 'Error, Warehouse K01 belum di-maintain' TYPE 'I'.
          ITALV-KET = 'Error, Warehouse K01 belum di-maintain'.
      ENDCASE.

    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_ERROR