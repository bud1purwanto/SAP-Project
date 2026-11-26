*&---------------------------------------------------------------------*
*&  Include           ZSDI_SOTOSO_F01
*&---------------------------------------------------------------------*

INITIALIZATION.
  MOVE 'Program Information' TO INFO.
  MOVE 'Download Template' TO TEMPL.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR DATASET.
  PERFORM FILENAME.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'TEMPL'.
    DATA: OBJFILE TYPE REF TO CL_GUI_FRONTEND_SERVICES.
    DATA: PICKEDFOLDER TYPE STRING.
    DATA: INITIALFOLDER TYPE STRING.

    CREATE OBJECT OBJFILE.
    OBJFILE->GET_TEMP_DIRECTORY( CHANGING TEMP_DIR = INITIALFOLDER
                                   EXCEPTIONS CNTL_ERROR = 1
                                             ERROR_NO_GUI = 2
                                             NOT_SUPPORTED_BY_GUI = 3 ).
    OBJFILE->DIRECTORY_BROWSE( EXPORTING INITIAL_FOLDER = INITIALFOLDER
                               CHANGING SELECTED_FOLDER = PICKEDFOLDER
                               EXCEPTIONS CNTL_ERROR = 1
                                          ERROR_NO_GUI = 2
                                          NOT_SUPPORTED_BY_GUI = 3 ).

    IF PICKEDFOLDER EQ 'D:\' OR PICKEDFOLDER EQ 'C:\'.
      CONCATENATE PICKEDFOLDER 'template.xls' INTO FPATH.
    ELSE.
      CONCATENATE PICKEDFOLDER '\template.xls' INTO FPATH.
    ENDIF.
    IF FPATH IS NOT INITIAL.
      PERFORM DONLOT_TEMPLATE.
    ENDIF.
  ENDIF.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  PERFORM TRANS.

START-OF-SELECTION.
  PERFORM PROCESS.

*&---------------------------------------------------------------------*
*&      Form  PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PROCESS .
  CLEAR ITAB_DATA.
  REFRESH ITAB_DATA.
  PERFORM MASTER_ATNAM.
  IF R1 IS NOT INITIAL.
    IF BATCH IS INITIAL AND HU IS INITIAL .
      MESSAGE  'Please Fill Batch  or HU.' TYPE 'I'.
    ELSE.
      PERFORM GET_DATA.
      READ TABLE ITAB_DATA WITH KEY WN = 'W'.
      IF SY-SUBRC EQ 0.
        READ TABLE ITAB_DATA WITH KEY WN = 'N'.
        IF SY-SUBRC EQ 0.
          MESSAGE E016(PN) WITH 'Cannot Combine sotoso between SLOC WM and NON-WM'.
        ENDIF.
      ENDIF.
      PERFORM DISPLAY_ALV.
    ENDIF.
  ELSE.
    IF DATASET IS INITIAL .
      MESSAGE  'Please Fill File Name.' TYPE 'I'.
    ELSE.
      PERFORM READ_DATA.
      LOOP AT ITAB_DATA WHERE PSTAT NE 'P' AND EXIDV IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = ITAB_DATA-EXIDV
          IMPORTING
            OUTPUT = ITAB_DATA-EXIDV.
        CONCATENATE 'Can sotoso HU' ITAB_DATA-EXIDV 'with status not Pass' INTO TXT SEPARATED BY SPACE.
        MESSAGE E016(PN) WITH TXT.
      ENDLOOP.
      READ TABLE ITAB_DATA WITH KEY WN = 'W'.
      IF SY-SUBRC EQ 0.
        READ TABLE ITAB_DATA WITH KEY WN = 'N'.
        IF SY-SUBRC EQ 0.
          MESSAGE E016(PN) WITH 'Cannot Combine sotoso between SLOC WM and NON-WM'.
        ENDIF.
      ENDIF.

      IF ABSTA EQ 'C' AND ST NE 'X'.
        MESSAGE E016(PN) WITH MSG1.
      ENDIF.
      IF GBSTA EQ 'C' AND ST NE 'X'.
        MESSAGE E016(PN) WITH MSG2.
      ENDIF.

      IF ST NE 'X' AND ( ABSTA EQ 'C' OR GBSTA EQ 'C').
      ELSE.
        PERFORM PROC_DATA.
        PERFORM DOWNLOAD.
        FLAG = 'X'.
        PERFORM WRITE_LOG.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "PROCESS
*----------------------------------------------------------------------*
*  MODULE status_9000 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'PFSTAT'.
ENDMODULE.                    "status_9000 OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  READ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_DATA .
  DATA : ANSWER TYPE C,
         SEQMAX LIKE ZQM001-SEQ,
        POPUP TYPE C LENGTH 50,
        V_KALAB LIKE MSKA-KALAB,
        V_KAEIN LIKE MSKA-KAEIN,
        V_ERROR TYPE I,
        ATWRT1 LIKE CAWN-ATWRT,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        ATWRT2 LIKE CAWN-ATWRT,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        TEXT TYPE STRING,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        V_PASS.   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
  CLEAR TCUOBJ.
  CLEAR: CONFIG,TBATCH.
  REFRESH : CONFIG,TBATCH.
  MOVE DATASET  TO DATASET1.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = DATASET1
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB_DATA
    EXCEPTIONS
      CONVERSION_ERROR    = 1
      INVALID_TABLE_WIDTH = 2
      INVALID_TYPE        = 3
      NO_BATCH            = 4
      UNKNOWN_ERROR       = 5
      FILE_OPEN_ERROR     = 6
      FILE_READ_ERROR     = 7
      OTHERS              = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'File can not be opened'.
    STOP.
  ELSE.
    READ TABLE ITAB_DATA WITH KEY MOV_TYPE = '412'.
    IF SY-SUBRC EQ 0.
      MESSAGE I000(0K) WITH 'Do not use movement type 412'.
      STOP.
    ENDIF.
  ENDIF.
  LOOP AT ITAB_DATA.
    CLEAR : V_KALAB, V_KAEIN.
    SELECT SINGLE VENUM INTO (ITAB_DATA-VENUM)
      FROM  VEPO
      WHERE VEPO~CHARG = ITAB_DATA-BATCH.
    SELECT SINGLE VEKP~UEVEL VEKP~EXIDV INTO (ITAB_DATA-UEVEL, ITAB_DATA-EXIDV)
      FROM VEKP
      WHERE VEKP~VENUM = ITAB_DATA-VENUM.
    IF ITAB_DATA-UEVEL IS NOT INITIAL.
      SELECT SINGLE VEKP~UEVEL VEKP~EXIDV INTO (ITAB_DATA-UEVEL, ITAB_DATA-EXIDV)
      FROM VEKP
      WHERE VEKP~VENUM = ITAB_DATA-UEVEL.
    ENDIF.
    SELECT SINGLE LGORT INTO ITAB_DATA-LGORT
      FROM T320
      WHERE LGORT = ITAB_DATA-SLOC.
    IF SY-SUBRC EQ 0.
      ITAB_DATA-WN = 'W'.
    ELSE.
      ITAB_DATA-WN = 'N'.
    ENDIF.
    CLEAR SEQMAX.
    SELECT MAX( SEQ ) INTO SEQMAX
      FROM ZQM001
      WHERE EXIDV =  ITAB_DATA-EXIDV.
    SELECT SINGLE PSTAT INTO ITAB_DATA-PSTAT
      FROM ZQM001
      WHERE SEQ = SEQMAX
      AND EXIDV = ITAB_DATA-EXIDV.
    MODIFY ITAB_DATA.
    IF ITAB_DATA-ISSUE_SLOC NE ITAB_DATA-SLOC.
      CLEAR TXT.
      CONCATENATE 'Sloc asal'ITAB_DATA-SLOC 'dan Sloc tujuan'ITAB_DATA-ISSUE_SLOC 'Batch'ITAB_DATA-BATCH 'berbeda!' INTO TXT SEPARATED BY SPACE.
      MESSAGE TXT TYPE 'E'.
    ENDIF.
    "Added by Annisa Wibowo at 08.08.2022 for RTS-Rest and Unrest
    IF SY-TCODE = 'ZSD008A'.
      SELECT SINGLE KALAB KAEIN
      INTO (V_KALAB, V_KAEIN)
      FROM MSKA
      WHERE LGORT = ITAB_DATA-SLOC
        AND WERKS = ITAB_DATA-PLANT
        AND MATNR = ITAB_DATA-MATERIAL
        AND CHARG = ITAB_DATA-BATCH
        AND KAEIN NE 0.
      IF V_KAEIN = 0 OR V_KAEIN = ''.
        SELECT SINGLE CLABS CEINM
        INTO (V_KALAB, V_KAEIN)
        FROM MCHB
        WHERE LGORT = ITAB_DATA-SLOC
        AND WERKS = ITAB_DATA-PLANT
        AND MATNR = ITAB_DATA-MATERIAL
        AND CHARG = ITAB_DATA-BATCH
          AND CEINM NE 0.
      ENDIF.
      IF V_KAEIN = 0 OR V_KAEIN = ''.
        V_ERROR = 1.
        EXIT.
*        MESSAGE 'Data Tidak Ada' TYPE 'S' DISPLAY LIKE 'E'.
*        LEAVE LIST-PROCESSING.
      ENDIF.
    ELSE.
      SELECT SINGLE KALAB KAEIN
      INTO (V_KALAB, V_KAEIN)
      FROM MSKA
      WHERE LGORT = ITAB_DATA-SLOC
        AND WERKS = ITAB_DATA-PLANT
        AND MATNR = ITAB_DATA-MATERIAL
        AND CHARG = ITAB_DATA-BATCH
        AND KALAB NE 0.
      IF V_KAEIN = 0 OR V_KAEIN = ''.
        SELECT SINGLE CLABS CEINM
        INTO (V_KALAB, V_KAEIN)
        FROM MCHB
        WHERE LGORT = ITAB_DATA-SLOC
        AND WERKS = ITAB_DATA-PLANT
        AND MATNR = ITAB_DATA-MATERIAL
        AND CHARG = ITAB_DATA-BATCH
          AND CLABS NE 0.
      ENDIF.
      IF V_KALAB = 0 OR V_KALAB = ''.
        V_ERROR = 1.
        EXIT.
*        MESSAGE 'Data Tidak Ada' TYPE 'S' DISPLAY LIKE 'E'.
*        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
    "Ended by Annisa Wibowo at 08.08.2022 for RTS-Rest and Unrest
  ENDLOOP.

  IF V_ERROR = 1.
    MESSAGE 'Data Tidak Ada' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ELSE.

    CLEAR ITAB_DATA1.
    REFRESH ITAB_DATA1.
    ITAB_DATA1[] = ITAB_DATA[].
    SORT ITAB_DATA1 BY EXIDV.
    DELETE ADJACENT DUPLICATES FROM ITAB_DATA1 COMPARING EXIDV.
    LOOP AT ITAB_DATA1.
      SELECT VEPO~VENUM VEPO~UNVEL VEPO~CHARG SONUM INTO (ITAB_DATA2-VENUM,ITAB_DATA2-UNVEL,ITAB_DATA2-BATCH,ITAB_DATA2-SONUM)
        FROM VEPO
        JOIN VEKP ON VEKP~VENUM = VEPO~VENUM
        WHERE VEKP~EXIDV = ITAB_DATA1-EXIDV.
        ITAB_DATA2-EXIDV = ITAB_DATA1-EXIDV.
        APPEND ITAB_DATA2.
      ENDSELECT.
    ENDLOOP.
    LOOP AT ITAB_DATA2.
      INDEX = SY-TABIX.
      IF ITAB_DATA2-UNVEL IS NOT INITIAL.
        SELECT VEPO~VENUM VEPO~UNVEL VEPO~CHARG SONUM INTO (ITAB_DATA2-VENUM,ITAB_DATA2-UNVEL,ITAB_DATA2-BATCH, ITAB_DATA-SONUM)
           FROM VEPO
           WHERE VEPO~VENUM = ITAB_DATA2-UNVEL.
          ITAB_DATA2-EXIDV = ITAB_DATA2-EXIDV.
          ITAB_DATA2-OBATCH = ITAB_DATA2-BATCH.
          APPEND ITAB_DATA2.
        ENDSELECT.
        DELETE ITAB_DATA2 INDEX INDEX.
      ELSE.
        ITAB_DATA2-OBATCH = ITAB_DATA2-BATCH.
      ENDIF.
    ENDLOOP.
    LOOP AT ITAB_DATA1.
      CLEAR : TSO,STAT,V_VENUM,TSOITEM.
      LOOP AT ITAB_DATA2 WHERE EXIDV = ITAB_DATA1-EXIDV.
        READ TABLE ITAB_DATA WITH KEY BATCH = ITAB_DATA2-BATCH.
        IF SY-SUBRC NE 0.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = ITAB_DATA1-EXIDV
            IMPORTING
              OUTPUT = ITAB_DATA1-EXIDV.
          CONCATENATE 'Batch not complete for HU' ITAB_DATA1-EXIDV INTO TXT SEPARATED BY SPACE.
          MESSAGE E016(PN) WITH TXT.
        ENDIF.
      ENDLOOP.
      READ TABLE ITAB_DATA WITH KEY EXIDV = ITAB_DATA1-EXIDV.
      TSO = ITAB_DATA-SALES_ORDER.
      TSOITEM = ITAB_DATA-SALES_ORDER_ITEM.
      CLEAR : TXT.
*    BREAK-POINT.
      IF ITAB_DATA-EXIDV IS INITIAL.
      ELSE.
        LOOP AT ITAB_DATA WHERE EXIDV = ITAB_DATA1-EXIDV.
          IF ITAB_DATA-SALES_ORDER NE TSO OR ITAB_DATA-SALES_ORDER_ITEM NE TSOITEM.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                INPUT  = ITAB_DATA1-EXIDV
              IMPORTING
                OUTPUT = ITAB_DATA1-EXIDV.
            CONCATENATE 'Can not Upload HU' ITAB_DATA1-EXIDV 'in Diff SO or Item' INTO TXT SEPARATED BY SPACE.
            MESSAGE E016(PN) WITH TXT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LOOP AT ITAB_DATA.
      CLEAR :  TBATCH, CONFIG,TCUOBJ,ABSTA,GBSTA,MSG1,MSG2,AUART, ST.
      REFRESH : TBATCH, CONFIG.
      IF ITAB_DATA-MOV_TYPE NE '411'.
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
*      IF ITAB_DATA-MOV_TYPE EQ '412'." OR ITAB_DATA-MOV_TYPE EQ '411'.
        IF ITAB_DATA-MOV_TYPE EQ '413' AND ITAB_DATA-SPEC_STOCK EQ ' '." OR ITAB_DATA-MOV_TYPE EQ '411'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = ITAB_DATA-SO_STOCK
            IMPORTING
              OUTPUT = ITAB_DATA-SO_STOCK.
*      IF ITAB_DATA-MOV_TYPE EQ '412'.
          SELECT SINGLE ABSTA GBSTA INTO (ABSTA,GBSTA)
            FROM VBUP
            WHERE VBELN = ITAB_DATA-SO_STOCK
            AND POSNR = ITAB_DATA-SOITEM_STOCK.
          SELECT SINGLE AUART INTO AUART
            FROM VBAK
            WHERE VBELN = ITAB_DATA-SO_STOCK
            AND AUART IN ('ZDRC','ZDRE','ZERE','ZERC').
          IF SY-SUBRC EQ 0.
            ST = 'X'.
          ENDIF.
          IF ABSTA EQ 'C' AND ST NE 'X'.
            CONCATENATE 'Can not sotoso, so'ITAB_DATA-SO_STOCK'rejected' INTO MSG1 SEPARATED BY SPACE.
            EXIT.
          ENDIF.
          IF GBSTA EQ 'C' AND ST NE 'X'.
            CONCATENATE 'Can not sotoso, so'ITAB_DATA-SO_STOCK 'completed' INTO MSG2 SEPARATED BY SPACE.
            EXIT.
          ENDIF.
*      ENDIF.
          SELECT SINGLE CUOBJ INTO TCUOBJ
            FROM VBAP
            WHERE VBAP~VBELN = ITAB_DATA-SO_STOCK
            AND VBAP~MATNR = ITAB_DATA-MATERIAL
            AND VBAP~POSNR = ITAB_DATA-SOITEM_STOCK.
          IF TCUOBJ IS INITIAL.
            MESSAGE E016(PN) WITH 'Configuration Object 'ITAB_DATA-SO_STOCK ITAB_DATA-SOITEM_STOCK' does not exist'.
          ENDIF.
        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = ITAB_DATA-SALES_ORDER
            IMPORTING
              OUTPUT = ITAB_DATA-SALES_ORDER.
          SELECT SINGLE ABSTA GBSTA INTO (ABSTA,GBSTA)
            FROM VBUP
            WHERE VBELN = ITAB_DATA-SALES_ORDER
            AND POSNR = ITAB_DATA-SALES_ORDER_ITEM.
          SELECT SINGLE AUART INTO AUART
           FROM VBAK
           WHERE VBELN = ITAB_DATA-SALES_ORDER
           AND AUART IN ('ZDRC','ZDRE','ZERE','ZERC').
          IF SY-SUBRC EQ 0.
            ST = 'X'.
          ENDIF.
          IF ABSTA EQ 'C' AND ST NE 'X'.
            CONCATENATE 'Can not sotoso, so'ITAB_DATA-SALES_ORDER'rejected' INTO MSG1 SEPARATED BY SPACE.
            EXIT.
          ENDIF.
          IF GBSTA EQ 'C' AND ST NE 'X'.
            CONCATENATE 'Can not sotoso, so'ITAB_DATA-SALES_ORDER 'completed' INTO MSG2 SEPARATED BY SPACE.
            EXIT.
          ENDIF.
          SELECT SINGLE CUOBJ INTO TCUOBJ
            FROM VBAP
            WHERE VBAP~VBELN = ITAB_DATA-SALES_ORDER
            AND VBAP~MATNR = ITAB_DATA-MATERIAL
            AND VBAP~POSNR = ITAB_DATA-SALES_ORDER_ITEM.
          IF TCUOBJ IS INITIAL.
            MESSAGE E016(PN) WITH 'Configuration Object 'ITAB_DATA-SALES_ORDER ITAB_DATA-SALES_ORDER_ITEM' does not exist'.
          ENDIF.
        ENDIF.
        CALL FUNCTION 'VC_I_GET_CONFIGURATION'
          EXPORTING
            INSTANCE      = TCUOBJ
          TABLES
            CONFIGURATION = CONFIG.

        CALL FUNCTION 'VB_INIT'
          EXPORTING
            INIT_RESET = 'X'.
        CALL FUNCTION 'VB_BATCH_GET_DETAIL' "
                EXPORTING
                  MATNR = ITAB_DATA-MATERIAL
                  CHARG = ITAB_DATA-BATCH
                 GET_CLASSIFICATION = 'X'
               TABLES
                 CHAR_OF_BATCH = TBATCH.
        CLEAR : STAT, TERR, ANSWER,POPUP.

        LOOP AT IT_ATNAM.
          "Cek Packing Code hanya untuk Plant Trias (1000 dan 2000) - Start Add by Fiqih 25.05.2026
          IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ITAB_DATA-PLANT NE '1000' AND ITAB_DATA-PLANT NE '2000'.
            CONTINUE.
          ENDIF.
          "End Add by Fiqih 25.05.2026

          READ TABLE CONFIG WITH KEY ATNAM = IT_ATNAM-ATNAM.
          IF SY-SUBRC EQ 0.
            READ TABLE TBATCH WITH KEY ATNAM = IT_ATNAM-ATNAM.
            IF SY-SUBRC EQ 0 AND ST NE 'X'.
              IF TBATCH-ATWTB NE CONFIG-ATWTB .
                " Modified by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
                IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
                  CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
                  " Get ZZPACKINGCODE Batch
                  SELECT SINGLE CAWN~ATWRT INTO ATWRT1 FROM CAWN
                    JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                    WHERE CAWNT~ATINN = TBATCH-ATINN AND CAWNT~ATWTB = TBATCH-ATWTB.

                  " Get ZZPACKINGCODE SO
                  SELECT SINGLE CAWN~ATWRT INTO ATWRT2 FROM CAWN
                    JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                    WHERE CAWNT~ATINN = CONFIG-ATINN AND CAWNT~ATWTB = CONFIG-ATWTB.

                  IF ATWRT1 IS NOT INITIAL AND ATWRT2 IS NOT INITIAL.
                    IF ATWRT1+0(1) EQ 'R' AND ATWRT2+0(1) NE 'R'.
                      IF ITAB_DATA-MOV_TYPE EQ '413' AND ITAB_DATA-SPEC_STOCK EQ ' '.
                        CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SO_STOCK '-' ITAB_DATA-SOITEM_STOCK ' adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                      ELSE.
                        CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                      ENDIF.
                      CALL FUNCTION 'POPUP_TO_CONFIRM'
                        EXPORTING
                          TITLEBAR              = 'Confirmation'
                          TEXT_QUESTION         = TEXT
                          TEXT_BUTTON_1         = 'Ya'
                          TEXT_BUTTON_2         = 'Tidak'
                          DEFAULT_BUTTON        = '2'
                          DISPLAY_CANCEL_BUTTON = ''
                        IMPORTING
                          ANSWER                = V_PASS.

                      IF V_PASS EQ '1'.
                        " Pass
                      ELSE.
                        " Exit, error
                        STAT = 'X'.
                        CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                        EXIT.
                      ENDIF.
                    ELSEIF ATWRT1+0(1) NE 'R' AND ATWRT2+0(1) EQ 'R'.
                      IF ITAB_DATA-MOV_TYPE EQ '413' AND ITAB_DATA-SPEC_STOCK EQ ' '.
                        CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SO_STOCK '-' ITAB_DATA-SOITEM_STOCK ' adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                      ELSE.
                        CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                      ENDIF.
                      CALL FUNCTION 'POPUP_TO_CONFIRM'
                        EXPORTING
                          TITLEBAR              = 'Confirmation'
                          TEXT_QUESTION         = TEXT
                          TEXT_BUTTON_1         = 'Ya'
                          TEXT_BUTTON_2         = 'Tidak'
                          DEFAULT_BUTTON        = '2'
                          DISPLAY_CANCEL_BUTTON = ''
                        IMPORTING
                          ANSWER                = V_PASS.

                      IF V_PASS EQ '1'.
                        " Pass
                      ELSE.
                        " Exit, error
                        STAT = 'X'.
                        CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                        EXIT.
                      ENDIF.
                    ENDIF.
                  ELSE.
                    STAT = 'X'.
                    CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                    EXIT.
                  ENDIF.
                ELSE.
                  STAT = 'X'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                  EXIT.
                ENDIF.
                " End modified by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
                " Remarked by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*                STAT = 'X'.
*                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*                EXIT.
                " End remarked by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
              ENDIF.
            ELSEIF SY-SUBRC NE 0 AND ST NE 'X'.
              CLEAR : ATWTB1,ATWTB2.
              ATWTB2 = ''."CONFIG-ATWTB.
              IF ATWTB2 NE CONFIG-ATWTB.
                " Modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
                IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
                  CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
                  " Get ZZPACKINGCODE SO
                  SELECT SINGLE CAWN~ATWRT INTO ATWRT2 FROM CAWN
                    JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                    WHERE CAWNT~ATINN = CONFIG-ATINN AND CAWNT~ATWTB = CONFIG-ATWTB.

                  " Pastikan ini ZZPACKINGCODE SO RTP, jika tidak maka skip
                  IF ATWRT2+0(1) EQ 'R'.
                    IF ITAB_DATA-MOV_TYPE EQ '413' AND ITAB_DATA-SPEC_STOCK EQ ' '.
                      CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SO_STOCK '-' ITAB_DATA-SOITEM_STOCK ' adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                    ELSE.
                      CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                    ENDIF.
                    CALL FUNCTION 'POPUP_TO_CONFIRM'
                      EXPORTING
                        TITLEBAR              = 'Confirmation'
                        TEXT_QUESTION         = TEXT
                        TEXT_BUTTON_1         = 'Ya'
                        TEXT_BUTTON_2         = 'Tidak'
                        DEFAULT_BUTTON        = '2'
                        DISPLAY_CANCEL_BUTTON = ''
                      IMPORTING
                        ANSWER                = V_PASS.

                    IF V_PASS EQ '1'.
                      " Pass
                    ELSE.
                      " Exit, error
                      STAT = 'X'.
                      CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                      EXIT.
                    ENDIF.
                  ENDIF.
                ELSE.
                  STAT = 'X'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                  EXIT.
                ENDIF.
                " End modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
                " Remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*                STAT = 'X'.
*                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*                EXIT.
                " End remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
              ENDIF.
            ENDIF.
          ELSE.
            CLEAR : ATWTB1,ATWTB2.
            ATWTB1 = ''."CONFIG-ATWTB.
            READ TABLE TBATCH WITH KEY ATNAM = IT_ATNAM-ATNAM.
            IF SY-SUBRC EQ 0 AND ST NE 'X'.
              IF TBATCH-ATWTB NE ATWTB1 .
                " Modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
                IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
                  CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
                  " Get ZZPACKINGCODE Batch
                  SELECT SINGLE CAWN~ATWRT INTO ATWRT1 FROM CAWN
                    JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                    WHERE CAWNT~ATINN = TBATCH-ATINN AND CAWNT~ATWTB = TBATCH-ATWTB.

                  " Pastikan ini ZZPACKINGCODE batch RTP, jika tidak maka skip
                  IF ATWRT1+0(1) EQ 'R'.
                    IF ITAB_DATA-MOV_TYPE EQ '413' AND ITAB_DATA-SPEC_STOCK EQ ' '.
                      CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SO_STOCK '-' ITAB_DATA-SOITEM_STOCK ' adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                    ELSE.
                      CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                    ENDIF.
                    CALL FUNCTION 'POPUP_TO_CONFIRM'
                      EXPORTING
                        TITLEBAR              = 'Confirmation'
                        TEXT_QUESTION         = TEXT
                        TEXT_BUTTON_1         = 'Ya'
                        TEXT_BUTTON_2         = 'Tidak'
                        DEFAULT_BUTTON        = '2'
                        DISPLAY_CANCEL_BUTTON = ''
                      IMPORTING
                        ANSWER                = V_PASS.

                    IF V_PASS EQ '1'.
                      " Pass
                    ELSE.
                      " Exit, error
                      STAT = 'X'.
                      CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                      EXIT.
                    ENDIF.
                  ENDIF.
                ELSE.
                  STAT = 'X'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                  EXIT.
                ENDIF.
                " End modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
                " Remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*                STAT = 'X'.
*                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*                EXIT.
                " End remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF STAT EQ 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF STAT EQ 'X'.
      MESSAGE E016(PN) WITH TERR.
    ENDIF.

  ENDIF.
ENDFORM.                    " READ_DATA
*&---------------------------------------------------------------------*
*&      Form  PROC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROC_DATA .
  CLEAR   T_ERRORS.
  REFRESH T_ERRORS.
  CLEAR IT_REPORT.
  REFRESH IT_REPORT.
  LOOP AT ITAB_DATA.

    CLEAR   ERRMSG.
    REFRESH ERRMSG.

    AT NEW MOV_TYPE.
      REFRESH ITAB.
      CLEAR ITAB.

      CLEAR : GMHEAD,
              GMCODE.
    ENDAT.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL            = ITAB_DATA-POST_DATE
      IMPORTING
        DATE_INTERNAL            = GMHEAD-PSTNG_DATE
      EXCEPTIONS
        DATE_EXTERNAL_IS_INVALID = 1
        OTHERS                   = 2.

    CONDENSE ITAB_DATA-QUANT NO-GAPS.
    GMHEAD-DOC_DATE   = SY-DATUM.
    GMHEAD-PR_UNAME   = SY-UNAME.
    GMCODE-GM_CODE    = '04'.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA-SO_STOCK
      IMPORTING
        OUTPUT = ITAB-VAL_SALES_ORD.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA-SALES_ORDER
      IMPORTING
        OUTPUT = ITAB-SALES_ORD.

    ITAB-MOVE_TYPE       =  ITAB_DATA-MOV_TYPE.
    ITAB-MVT_IND         = ' '.
    ITAB-SPEC_STOCK      =  ITAB_DATA-SPEC_STOCK.
    ITAB-PLANT           =  ITAB_DATA-PLANT.
    ITAB-MATERIAL        =  ITAB_DATA-MATERIAL.
    ITAB-ENTRY_QNT       =  ITAB_DATA-QUANT.
    ITAB-ENTRY_UOM       =  ITAB_DATA-UOM.
    ITAB-MOVE_STLOC      =  ITAB_DATA-ISSUE_SLOC.
    ITAB-STGE_LOC        =  ITAB_DATA-SLOC.
    ITAB-BATCH           =  ITAB_DATA-BATCH.
    ITAB-S_ORD_ITEM      =  ITAB_DATA-SALES_ORDER_ITEM.
    ITAB-VAL_S_ORD_ITEM  =  ITAB_DATA-SOITEM_STOCK.
    ITAB-MOVE_BATCH      =  ITAB_DATA-BATCH.
    APPEND ITAB.

    CASE ITAB_DATA-MOV_TYPE.
      WHEN  '411'.
        IT_REPORT-BUDAT  =  ITAB_DATA-POST_DATE.
        IT_REPORT-MATNR  =  ITAB_DATA-MATERIAL.
        IT_REPORT-CHARG  =  ITAB_DATA-BATCH.
        IT_REPORT-WERKS  =  ITAB_DATA-PLANT.
        IT_REPORT-LGORT  =  ITAB_DATA-SLOC.
        IT_REPORT-MENGE  =  ITAB_DATA-QUANT.
        IT_REPORT-MEINS  =  ITAB_DATA-UOM.
        IT_REPORT-SONU1  =  ITAB_DATA-SO_STOCK.
        IT_REPORT-SOIT1  =  ITAB_DATA-SOITEM_STOCK.
        APPEND IT_REPORT.
        CLEAR IT_REPORT.
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
      WHEN  '413'.
        IT_REPORT-BUDAT  =  ITAB_DATA-POST_DATE.
        IT_REPORT-MATNR  =  ITAB_DATA-MATERIAL.
        IT_REPORT-CHARG  =  ITAB_DATA-BATCH.
        IT_REPORT-WERKS  =  ITAB_DATA-PLANT.
        IT_REPORT-LGORT  =  ITAB_DATA-SLOC.
        IT_REPORT-MENGE  =  ITAB_DATA-QUANT.
        IT_REPORT-MEINS  =  ITAB_DATA-UOM.
        IF ITAB_DATA-SPEC_STOCK EQ ' '.
          IT_REPORT-SONU2  =  ITAB_DATA-SO_STOCK.
          IT_REPORT-SOIT2  =  ITAB_DATA-SOITEM_STOCK.
        ELSE.
          IT_REPORT-SONU1  =  ITAB_DATA-SO_STOCK.
          IT_REPORT-SOIT1  =  ITAB_DATA-SOITEM_STOCK.
          IT_REPORT-SONU1  =  ITAB_DATA-SALES_ORDER.
          IT_REPORT-SOIT1  =  ITAB_DATA-SALES_ORDER_ITEM.
        ENDIF.
        APPEND IT_REPORT.
        CLEAR IT_REPORT.
*      WHEN  '412'.
*        IT_REPORT-BUDAT  =  ITAB_DATA-POST_DATE.
*        IT_REPORT-MATNR  =  ITAB_DATA-MATERIAL.
*        IT_REPORT-CHARG  =  ITAB_DATA-BATCH.
*        IT_REPORT-WERKS  =  ITAB_DATA-PLANT.
*        IT_REPORT-LGORT  =  ITAB_DATA-SLOC.
*        IT_REPORT-MENGE  =  ITAB_DATA-QUANT.
*        IT_REPORT-MEINS  =  ITAB_DATA-UOM.
*        IT_REPORT-SONU2  =  ITAB_DATA-SO_STOCK.
*        IT_REPORT-SOIT2  =  ITAB_DATA-SOITEM_STOCK.
*        APPEND IT_REPORT.
*        CLEAR IT_REPORT.
*      WHEN  '413'.
*        IT_REPORT-BUDAT  =  ITAB_DATA-POST_DATE.
*        IT_REPORT-MATNR  =  ITAB_DATA-MATERIAL.
*        IT_REPORT-CHARG  =  ITAB_DATA-BATCH.
*        IT_REPORT-WERKS  =  ITAB_DATA-PLANT.
*        IT_REPORT-LGORT  =  ITAB_DATA-SLOC.
*        IT_REPORT-MENGE  =  ITAB_DATA-QUANT.
*        IT_REPORT-MEINS  =  ITAB_DATA-UOM.
*        IT_REPORT-SONU1  =  ITAB_DATA-SO_STOCK.
*        IT_REPORT-SOIT1  =  ITAB_DATA-SOITEM_STOCK.
*        IT_REPORT-SONU1  =  ITAB_DATA-SALES_ORDER.
*        IT_REPORT-SOIT1  =  ITAB_DATA-SALES_ORDER_ITEM.
*        APPEND IT_REPORT.
*        CLEAR IT_REPORT.
    ENDCASE.

    AT END OF MOV_TYPE.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = GMHEAD
          GOODSMVT_CODE    = GMCODE
          TESTRUN          = ' '
        IMPORTING
          GOODSMVT_HEADRET = MTHEAD
        TABLES
          GOODSMVT_ITEM    = ITAB
          RETURN           = ERRMSG.

      PERFORM GET_ERROR.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " PROC_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ERROR .
  CLEAR ERRFLAG.
  LOOP AT ERRMSG.
    IF ERRMSG-TYPE EQ 'E'.
      ERRFLAG = 'X'.
    ENDIF.

    SY-MSGNO = ERRMSG-NUMBER.
    SY-MSGV1 = ERRMSG-MESSAGE_V1.
    SY-MSGV2 = ERRMSG-MESSAGE_V2.
    SY-MSGV3 = ERRMSG-MESSAGE_V3.
    SY-MSGV4 = ERRMSG-MESSAGE_V4.

    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        ID         = ERRMSG-ID
        NUMBER     = SY-MSGNO
        MESSAGE_V1 = SY-MSGV1
        MESSAGE_V2 = SY-MSGV2
        MESSAGE_V3 = SY-MSGV3
        MESSAGE_V4 = SY-MSGV4
        LANGUAGE   = SY-LANGU
        TEXTFORMAT = 'HTM'
      IMPORTING
        MESSAGE    = V_MSG.

    T_ERRORS-TYPE = ERRMSG-TYPE.
    T_ERRORS-MSG = V_MSG.
    T_ERRORS-VBELN = ERRMSG-MESSAGE_V1.

    CONDENSE T_ERRORS-MSG.
    APPEND T_ERRORS.
    CLEAR  T_ERRORS.
  ENDLOOP.
  IF ERRFLAG IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    IF SY-SUBRC NE 0.
      MESSAGE E899 WITH 'Error in updating'.
    ELSE.
      CONCATENATE 'Document' MTHEAD-MAT_DOC 'has been created'
                  INTO T_ERRORS-MSG SEPARATED BY SPACE.
      APPEND T_ERRORS.
      CLEAR  T_ERRORS.
*      BREAK-POINT.
      ITAB_LOG1[] = ITAB_LOG[].
      LOOP AT T_ERRORS WHERE TYPE EQ 'S'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = T_ERRORS-VBELN
          IMPORTING
            OUTPUT = T_ERRORS-VBELN.

        SELECT SINGLE LGNUM INTO T_ERRORS-LGNUM
          FROM LIKP
          WHERE LIKP~VBELN = T_ERRORS-VBELN.
        IF T_ERRORS-LGNUM IS INITIAL.
          SELECT VBELN POSNR MATNR LFIMG  INTO CORRESPONDING FIELDS OF TABLE IT_LIPS
            FROM LIPS
            WHERE VBELN = T_ERRORS-VBELN.
          PERFORM UPDATE.
        ENDIF.
        MODIFY T_ERRORS.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_ERROR
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD .
  TABLES RLGRAP.

  DATA:  DEF_PATH LIKE RLGRAP-FILENAME.
  DATA: TMP_FILENAME LIKE RLGRAP-FILENAME.
  DATA V_FILENAME TYPE STRING.

  DATA : BEGIN OF IT_FIELDNAMES OCCURS 0,
           FIELD(30),
         END OF IT_FIELDNAMES.

  REFRESH IT_FIELDNAMES.
  CLEAR IT_FIELDNAMES.
  IT_FIELDNAMES-FIELD = 'Posting Date'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'Material Number'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'Batch'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'Plant'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'SLoc'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'Quantity'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'UoM'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'SO Asal'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'Item'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'SO Tujuan'.
  APPEND IT_FIELDNAMES.

  IT_FIELDNAMES-FIELD = 'Item'.
  APPEND IT_FIELDNAMES.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = RLGRAP-FILENAME
      DEF_PATH         = DEF_PATH
    IMPORTING
      FILENAME         = TMP_FILENAME
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.

  IF SY-SUBRC = 0.
    RLGRAP-FILENAME = TMP_FILENAME.
  ELSE.
    EXIT.
  ENDIF.

  V_FILENAME = RLGRAP-FILENAME.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME              = V_FILENAME
      FILETYPE              = 'ASC'
      WRITE_FIELD_SEPARATOR = 'X'
      CONFIRM_OVERWRITE     = 'X'
      SHOW_TRANSFER_STATUS  = 'X'
    TABLES
      DATA_TAB              = IT_REPORT
      FIELDNAMES            = IT_FIELDNAMES.

  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'Download error'.
    STOP.
  ENDIF.
ENDFORM.                    " DOWNLOAD
*&---------------------------------------------------------------------*
*&      Form  FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILENAME .
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_PATH         = 'D:\'
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = DATASET
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.
ENDFORM.                    " FILENAME
*&---------------------------------------------------------------------*
*&      Form  TRANS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TRANS .
  IF R1 IS NOT INITIAL.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'DATASET'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'BATCH-LOW'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'BATCH-HIGH'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'HU-LOW'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'HU-HIGH'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'R3'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'R4'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'R5'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " TRANS
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  DATA: MAXSEQ TYPE I.
  CLEAR: ITAB_DATA.
  REFRESH ITAB_DATA.
  IF BATCH-LOW IS NOT INITIAL.
    IF R3 IS NOT INITIAL OR R5 IS NOT INITIAL.
      "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
      IF SY-TCODE = 'ZSD008A'.
        SELECT MSKA~CHARG MSKA~WERKS MSKA~LGORT MSKA~MATNR MSKA~SOBKZ  INTO
        (ITAB_DATA-BATCH, ITAB_DATA-PLANT,ITAB_DATA-SLOC,ITAB_DATA-MATERIAL,ITAB_DATA-SPEC_STOCK)
        FROM MSKA
        WHERE MSKA~CHARG IN BATCH
        AND MSKA~KAEIN NE 0.  "Restricted
          APPEND ITAB_DATA.
        ENDSELECT.
      ELSE.
        SELECT MSKA~CHARG MSKA~WERKS MSKA~LGORT MSKA~MATNR MSKA~SOBKZ  INTO
        (ITAB_DATA-BATCH, ITAB_DATA-PLANT,ITAB_DATA-SLOC,ITAB_DATA-MATERIAL,ITAB_DATA-SPEC_STOCK)
        FROM MSKA
        WHERE MSKA~CHARG IN BATCH
        AND MSKA~KALAB NE 0.  "Unrest
          APPEND ITAB_DATA.
        ENDSELECT.
      ENDIF.
      "Ended by Annisa Wibowo at 08.07.2022 for Tcode ZSD008A Restricted
    ENDIF.
    IF R4 IS NOT INITIAL.
      "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
      IF SY-TCODE = 'ZSD008A'.
        SELECT MCHB~CHARG MCHB~WERKS MCHB~LGORT MCHB~MATNR INTO
        (ITAB_DATA-BATCH, ITAB_DATA-PLANT,ITAB_DATA-SLOC,ITAB_DATA-MATERIAL)
        FROM MCHB
        WHERE MCHB~CHARG IN BATCH
        AND MCHB~CEINM NE 0. "Restricted
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
*        ITAB_DATA-SPEC_STOCK = 'E'.
          ITAB_DATA-SPEC_STOCK = ''.
          APPEND ITAB_DATA.
        ENDSELECT.
      ELSE.
        SELECT MCHB~CHARG MCHB~WERKS MCHB~LGORT MCHB~MATNR INTO
        (ITAB_DATA-BATCH, ITAB_DATA-PLANT,ITAB_DATA-SLOC,ITAB_DATA-MATERIAL)
        FROM MCHB
        WHERE MCHB~CHARG IN BATCH
        AND MCHB~CLABS NE 0.  "Unrest
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
*        ITAB_DATA-SPEC_STOCK = 'E'.
          ITAB_DATA-SPEC_STOCK = ''.
          APPEND ITAB_DATA.
        ENDSELECT.
      ENDIF.
      "Ended by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
    ENDIF.
  ELSEIF HU-LOW IS NOT INITIAL.
    SELECT VEKP~EXIDV VEKP~VENUM VEKP~UEVEL VEPO~UNVEL INTO (ITAB_DATA1-EXIDV, ITAB_DATA1-VENUM, ITAB_DATA1-UEVEL, ITAB_DATA1-UNVEL)
      FROM VEKP
      JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
      WHERE VEKP~EXIDV IN HU.
      APPEND ITAB_DATA1.
    ENDSELECT.
    SORT ITAB_DATA1 BY EXIDV UNVEL.
    DELETE ADJACENT DUPLICATES FROM ITAB_DATA1 COMPARING EXIDV VENUM UNVEL.
    CLEAR INDEX.
    LOOP AT ITAB_DATA1.
      INDEX =  SY-TABIX.
      IF  ITAB_DATA1-UNVEL IS NOT INITIAL.
        SELECT VEPO~CHARG VEPO~WERKS VEPO~LGORT VEPO~MATNR VEPO~VENUM  INTO
           (ITAB_DATA-BATCH, ITAB_DATA-PLANT,ITAB_DATA-SLOC,ITAB_DATA-MATERIAL,ITAB_DATA-VENUM)
           FROM VEPO
           WHERE VEPO~VENUM EQ ITAB_DATA1-UNVEL
           AND VEPO~VEMNG NE 0.
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
*          ITAB_DATA-SPEC_STOCK = 'E'.
          IF R4 IS INITIAL.
            ITAB_DATA-SPEC_STOCK = 'E'.
          ENDIF.
          APPEND ITAB_DATA.
        ENDSELECT.
      ELSE.
        SELECT VEPO~CHARG VEPO~WERKS VEPO~LGORT VEPO~MATNR VEPO~VENUM  INTO
            (ITAB_DATA-BATCH, ITAB_DATA-PLANT,ITAB_DATA-SLOC,ITAB_DATA-MATERIAL,ITAB_DATA-VENUM)
            FROM VEPO
            WHERE VEPO~VENUM EQ ITAB_DATA1-VENUM
            AND VEPO~VEMNG NE 0.
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
*          ITAB_DATA-SPEC_STOCK = 'E'.
          IF R4 IS INITIAL.
            ITAB_DATA-SPEC_STOCK = 'E'.
          ENDIF.
          APPEND ITAB_DATA.
        ENDSELECT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  LOOP AT ITAB_DATA.
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = SY-DATUM
      IMPORTING
        DATE_EXTERNAL = ITAB_DATA-POST_DATE
      EXCEPTIONS
        OTHERS        = 2.
    IF R3 IS NOT INITIAL.
      ITAB_DATA-MOV_TYPE = '413'.
      "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
      IF SY-TCODE = 'ZSD008A'.
        SELECT SINGLE VBELN POSNR INTO (ITAB_DATA-SO_STOCK, ITAB_DATA-SOITEM_STOCK)
        FROM MSKA
        WHERE MSKA~CHARG = ITAB_DATA-BATCH
        AND MSKA~WERKS = ITAB_DATA-PLANT
        AND MSKA~LGORT = ITAB_DATA-SLOC
        AND MSKA~MATNR = ITAB_DATA-MATERIAL
        AND MSKA~KAEIN NE 0.  "Restricted
      ELSE.
        SELECT SINGLE VBELN POSNR INTO (ITAB_DATA-SO_STOCK, ITAB_DATA-SOITEM_STOCK)
          FROM MSKA
          WHERE MSKA~CHARG = ITAB_DATA-BATCH
          AND MSKA~WERKS = ITAB_DATA-PLANT
          AND MSKA~LGORT = ITAB_DATA-SLOC
          AND MSKA~MATNR = ITAB_DATA-MATERIAL
          AND MSKA~KALAB NE 0."Unrest
      ENDIF. "Added New
      "Ended by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
    ELSEIF R4 IS NOT INITIAL.
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
*      ITAB_DATA-MOV_TYPE = '412'.
      ITAB_DATA-MOV_TYPE = '413'.
    ELSEIF R5 IS NOT INITIAL.
      ITAB_DATA-MOV_TYPE = '411'.
      "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
      IF SY-TCODE = 'ZSD008A'.
        SELECT SINGLE VBELN POSNR INTO (ITAB_DATA-SO_STOCK, ITAB_DATA-SOITEM_STOCK)
        FROM MSKA
        WHERE MSKA~CHARG = ITAB_DATA-BATCH
        AND MSKA~WERKS = ITAB_DATA-PLANT
        AND MSKA~LGORT = ITAB_DATA-SLOC
        AND MSKA~MATNR = ITAB_DATA-MATERIAL
        AND MSKA~KAEIN NE 0.  "Restricted
      ELSE.
        SELECT SINGLE VBELN POSNR INTO (ITAB_DATA-SO_STOCK, ITAB_DATA-SOITEM_STOCK)
        FROM MSKA
        WHERE MSKA~CHARG = ITAB_DATA-BATCH
        AND MSKA~WERKS = ITAB_DATA-PLANT
        AND MSKA~LGORT = ITAB_DATA-SLOC
        AND MSKA~MATNR = ITAB_DATA-MATERIAL
        AND MSKA~KALAB NE 0.  "Unrest
      ENDIF. "Added New
      "Ended by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted

    ENDIF.
    SELECT SINGLE MEINS INTO (ITAB_DATA-UOM)
      FROM MARA
      WHERE MARA~MATNR = ITAB_DATA-MATERIAL.
    "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
    IF SY-TCODE = 'ZSD008A'.
      IF ITAB_DATA-SO_STOCK IS NOT INITIAL.
        SELECT SINGLE KAEIN INTO (ITAB_DATA-KAEIN)
        FROM MSKA
        WHERE MSKA~CHARG = ITAB_DATA-BATCH
         AND MSKA~WERKS = ITAB_DATA-PLANT
        AND MSKA~LGORT = ITAB_DATA-SLOC
        AND MSKA~MATNR = ITAB_DATA-MATERIAL
        AND MSKA~VBELN = ITAB_DATA-SO_STOCK
        AND MSKA~KAEIN NE 0.
      ELSEIF ITAB_DATA-KAEIN IS  INITIAL.
        SELECT SINGLE MCHB~CEINM INTO (ITAB_DATA-KAEIN)
        FROM MCHB
        WHERE MCHB~CHARG = ITAB_DATA-BATCH
        AND MCHB~CEINM NE 0
        AND MCHB~WERKS = ITAB_DATA-PLANT
        AND MCHB~LGORT = ITAB_DATA-SLOC
        AND MCHB~MATNR = ITAB_DATA-MATERIAL.
      ENDIF.
    ELSE.
      IF ITAB_DATA-SO_STOCK IS NOT INITIAL.
        SELECT SINGLE KALAB INTO (ITAB_DATA-KALAB)
          FROM MSKA
          WHERE MSKA~CHARG = ITAB_DATA-BATCH
           AND MSKA~WERKS = ITAB_DATA-PLANT
          AND MSKA~LGORT = ITAB_DATA-SLOC
          AND MSKA~MATNR = ITAB_DATA-MATERIAL
          AND MSKA~VBELN = ITAB_DATA-SO_STOCK
          AND MSKA~KALAB NE 0.
      ELSEIF ITAB_DATA-KALAB IS  INITIAL.
        SELECT SINGLE MCHB~CLABS INTO (ITAB_DATA-KALAB)
          FROM MCHB
          WHERE MCHB~CHARG = ITAB_DATA-BATCH
          AND MCHB~CLABS NE 0
          AND MCHB~WERKS = ITAB_DATA-PLANT
          AND MCHB~LGORT = ITAB_DATA-SLOC
          AND MCHB~MATNR = ITAB_DATA-MATERIAL.
      ENDIF.
    ENDIF. "Added New
    "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
    SELECT SINGLE SONUM INTO (ITAB_DATA-SONUM)
        FROM  VEPO
        WHERE VEPO~CHARG = ITAB_DATA-BATCH.
    IF ITAB_DATA-VENUM IS INITIAL.
      SELECT SINGLE VENUM INTO (ITAB_DATA-VENUM)
        FROM  VEPO
        WHERE VEPO~CHARG = ITAB_DATA-BATCH.
    ENDIF.
    IF ITAB_DATA-EXIDV IS INITIAL.
      SELECT SINGLE VEKP~UEVEL VEKP~EXIDV INTO (ITAB_DATA-UEVEL, ITAB_DATA-EXIDV)
        FROM VEKP
        WHERE VEKP~VENUM = ITAB_DATA-VENUM.
      IF ITAB_DATA-UEVEL IS NOT INITIAL.
        SELECT SINGLE VEKP~UEVEL VEKP~EXIDV INTO (ITAB_DATA-UEVEL, ITAB_DATA-EXIDV)
        FROM VEKP
        WHERE VEKP~VENUM = ITAB_DATA-UEVEL.
      ENDIF.
    ENDIF.
    ITAB_DATA-ISSUE_SLOC = ITAB_DATA-SLOC.
    "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
    IF SY-TCODE = 'ZSD008A'.
      ITAB_DATA-QUANT = ITAB_DATA-KAEIN.
    ELSE.
      ITAB_DATA-QUANT = ITAB_DATA-KALAB.
    ENDIF. "Added New
    "Ended by Annisa Wibowo at 07.07.2022 for Tcode ZSD008A Restricted
    ITAB_DATA-OBATCH = ITAB_DATA-BATCH.
    CONDENSE ITAB_DATA-QUANT.
    SELECT SINGLE LGORT INTO ITAB_DATA-LGORT
      FROM T320
      WHERE LGORT = ITAB_DATA-SLOC.
    IF SY-SUBRC EQ 0.
      ITAB_DATA-WN = 'W'.
    ELSE.
      ITAB_DATA-WN = 'N'.
    ENDIF.
    CLEAR: MAXSEQ.
    SELECT MAX( SEQ ) INTO MAXSEQ
      FROM ZQM001
      WHERE EXIDV = ITAB_DATA-EXIDV.
    SELECT SINGLE PSTAT INTO ITAB_DATA-PSTAT
      FROM ZQM001
      WHERE SEQ = MAXSEQ
      AND EXIDV = ITAB_DATA-EXIDV.
    SHIFT ITAB_DATA-EXIDV LEFT DELETING LEADING '0'.
    SHIFT ITAB_DATA-SOITEM_STOCK LEFT DELETING LEADING '0'.
    SHIFT ITAB_DATA-SO_STOCK LEFT DELETING LEADING '0'.

    MODIFY ITAB_DATA.
  ENDLOOP.
  IF R3 IS NOT INITIAL OR R5 IS NOT INITIAL.
    DELETE ITAB_DATA WHERE SO_STOCK IS INITIAL.
    DELETE ITAB_DATA WHERE QUANT IS INITIAL.
  ELSEIF R4 IS NOT INITIAL.
    DELETE ITAB_DATA WHERE SO_STOCK IS NOT INITIAL.
    DELETE ITAB_DATA WHERE QUANT EQ 0.
  ENDIF.
  CLEAR ITAB_DATA1.
  REFRESH ITAB_DATA1.

  ITAB_DATA1[] = ITAB_DATA[].
  SORT ITAB_DATA1 BY EXIDV.
  DELETE ADJACENT DUPLICATES FROM ITAB_DATA1 COMPARING EXIDV.
  LOOP AT ITAB_DATA1.
    CLEAR INDEX.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA1-EXIDV
      IMPORTING
        OUTPUT = ITAB_DATA1-EXIDV.

    SELECT VEPO~VENUM VEPO~UNVEL VEPO~CHARG SONUM INTO (ITAB_DATA2-VENUM,ITAB_DATA2-UNVEL,ITAB_DATA2-BATCH,ITAB_DATA2-SONUM)
      FROM VEPO
      JOIN VEKP ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV = ITAB_DATA1-EXIDV.
      ITAB_DATA2-EXIDV = ITAB_DATA1-EXIDV.
      SHIFT ITAB_DATA2-EXIDV LEFT DELETING LEADING '0'.
      APPEND ITAB_DATA2.
    ENDSELECT.
  ENDLOOP.
  LOOP AT ITAB_DATA2.
    INDEX = SY-TABIX.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA2-EXIDV
      IMPORTING
        OUTPUT = ITAB_DATA2-EXIDV.
    IF ITAB_DATA2-UNVEL IS NOT INITIAL.
      SELECT VEPO~VENUM VEPO~UNVEL VEPO~CHARG SONUM INTO (ITAB_DATA2-VENUM,ITAB_DATA2-UNVEL,ITAB_DATA2-BATCH, ITAB_DATA-SONUM)
         FROM VEPO
         WHERE VEPO~VENUM = ITAB_DATA2-UNVEL.
        ITAB_DATA2-EXIDV = ITAB_DATA2-EXIDV.
        ITAB_DATA2-OBATCH = ITAB_DATA2-BATCH.
        SHIFT ITAB_DATA2-EXIDV LEFT DELETING LEADING '0'.
        APPEND ITAB_DATA2.
      ENDSELECT.
      DELETE ITAB_DATA2 INDEX INDEX.
    ELSE.
      ITAB_DATA2-OBATCH = ITAB_DATA2-BATCH.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV .
  PERFORM F_FIELD_CATALOG.
  PERFORM BUILD_LAYOUT.
  PERFORM BUILD_EVENTS.
  PERFORM BUILD_PRINT_PARAMS.
  PERFORM DISPLAY_ALV_REPORT.
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.
  "Added by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
  IF SY-TCODE = 'ZSD008A'.
    PERFORM F_ALV_FIELDCATG_SO USING 'ITAB_DATA' :
    'POST_DATE'       '' ''  '' ''  'Date' ''  ' ' '' ' ' ,
    'MOV_TYPE'       '' ''  '' ''  'M Type'  '' ' ' '' ' ',
    'PLANT'       '' ''  '' ''  'Plant'  '' ' ' ''  ' ' ,
    'SLOC'       '' ''  '' ''  'Storage Location' ''  ' ' '' ' '  ,
    'SPEC_STOCK'       '' ''  '' ''  'Special Stock'  '' ' ' '' ' ' ,
    'SO_STOCK'       '' ''  '' ''  'SO' ''  ' ' '' ' ' ,
    'SOITEM_STOCK'       '' ''  '' ''  'Item'  '' ' '  '' ' ',
    'ISSUE_SLOC'       '' ''  '' ''  'I Sloc' ''   ''  '' ' ',
    'MATERIAL'       '' ''  '' ''  'Material'   ' ' '' '' ' ' ,
    'KAEIN'       '' ''  '' ''  'Quantity' ''   ''  '' ' ',
    'UOM'       '' ''  '' ''  'UoM'  '' ' '  '' ' ' ,
    'OBATCH'       '' ''  '' ''  'Batch'  ''  '' '' ' ' ,
    'EXIDV'       '' ''  '' ''  'HU'  ''  '' '' ' ' .
  ELSE.
    PERFORM F_ALV_FIELDCATG_SO USING 'ITAB_DATA' :
      'POST_DATE'       '' ''  '' ''  'Date' ''  ' ' '' ' ' ,
      'MOV_TYPE'       '' ''  '' ''  'M Type'  '' ' ' '' ' ',
      'PLANT'       '' ''  '' ''  'Plant'  '' ' ' ''  ' ' ,
      'SLOC'       '' ''  '' ''  'Storage Location' ''  ' ' '' ' '  ,
      'SPEC_STOCK'       '' ''  '' ''  'Special Stock'  '' ' ' '' ' ' ,
      'SO_STOCK'       '' ''  '' ''  'SO' ''  ' ' '' ' ' ,
      'SOITEM_STOCK'       '' ''  '' ''  'Item'  '' ' '  '' ' ',
      'ISSUE_SLOC'       '' ''  '' ''  'I Sloc' ''   ''  '' ' ',
      'MATERIAL'       '' ''  '' ''  'Material'   ' ' '' '' ' ' ,
      'KALAB'       '' ''  '' ''  'Quantity' ''   ''  '' ' ',
      'UOM'       '' ''  '' ''  'UoM'  '' ' '  '' ' ' ,
      'OBATCH'       '' ''  '' ''  'Batch'  ''  '' '' ' ' ,
      'EXIDV'       '' ''  '' ''  'HU'  ''  '' '' ' ' .
  ENDIF.  "Added New
  "Ended by Annisa Wibowo at 07.08.2022 for Tcode ZSD008A Restricted
ENDFORM.                    " F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_LAYOUT .
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-TOTALS_TEXT       = 'TOTALS'(201).
  WA_LAYOUT-COLTAB_FIELDNAME = 'CELLCOLOR'.
ENDFORM.                    " BUILD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  BUILD_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_EVENTS .
  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = T_EVENTS[].

  READ TABLE T_EVENTS WITH KEY NAME =  SLIS_EV_END_OF_PAGE
                           INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE 'END_OF_PAGE' TO LS_EVENT-FORM.
    APPEND LS_EVENT TO T_EVENTS.
  ENDIF.

  READ TABLE T_EVENTS WITH KEY NAME =  SLIS_EV_END_OF_LIST
                         INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE 'END_OF_LIST' TO LS_EVENT-FORM.
    APPEND LS_EVENT TO T_EVENTS.
  ENDIF.
ENDFORM.                    " BUILD_EVENTS
*&---------------------------------------------------------------------*
*&      Form  BUILD_PRINT_PARAMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_PRINT_PARAMS .
  T_PRINT-RESERVE_LINES = '3'.   "LINES RESERVED FOR FOOTER
  T_PRINT-NO_COVERPAGE = 'X'.
ENDFORM.                    " BUILD_PRINT_PARAMS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_REPORT .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_TOP_OF_PAGE   = 'TOP-OF-PAGE'
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
*     IT_EVENTS                = T_EVENTS
      IS_PRINT                 = T_PRINT
      I_SAVE                   = 'X'
    TABLES
      T_OUTTAB                 = ITAB_DATA
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA : ERRORTXT TYPE C LENGTH 100.
  DATA : LS_REF1 TYPE REF TO CL_GUI_ALV_GRID.
  SY-LSIND = 0.
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LS_REF1.

  CALL METHOD LS_REF1->CHECK_CHANGED_DATA .

  CASE R_UCOMM .
    WHEN 'EXEC'.
      LOOP AT ITAB_DATA1.
        CLEAR : V_VENUM,TXT.
        LOOP AT ITAB_DATA2 WHERE EXIDV = ITAB_DATA1-EXIDV.
          READ TABLE ITAB_DATA WITH KEY BATCH = ITAB_DATA2-BATCH.
          IF SY-SUBRC NE 0.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                INPUT  = ITAB_DATA1-EXIDV
              IMPORTING
                OUTPUT = ITAB_DATA1-EXIDV.
            CONCATENATE 'Batch not complete for HU' ITAB_DATA1-EXIDV INTO TXT SEPARATED BY SPACE.
            MESSAGE E016(PN) WITH TXT.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      LOOP AT ITAB_DATA WHERE PSTAT NE 'P' AND EXIDV IS NOT INITIAL.
        CONCATENATE 'Can sotoso HU' ITAB_DATA-EXIDV 'with status not Pass' INTO ERRORTXT SEPARATED BY SPACE.
        MESSAGE E016(PN) WITH ERRORTXT.
      ENDLOOP.
      CLEAR : TSO,STAT.
      TSO = ITAB_DATA-SO_STOCK.
      LOOP AT ITAB_DATA WHERE SO_STOCK NE TSO.
        STAT = 'A'.
      ENDLOOP.
      IF R3 IS NOT INITIAL.
        IF STAT NE 'A'.
          PERFORM POPSTS.
        ELSE.
          MESSAGE E016(PN) WITH 'Can not Upload Diff SO'.
        ENDIF.
      ELSEIF R4 IS NOT INITIAL.
        IF STAT NE 'A'.
          PERFORM POPFTS.
        ELSE.
          MESSAGE E016(PN) WITH 'Can not Upload Diff HU'.
        ENDIF.
      ELSEIF R5 IS NOT INITIAL.
        IF STAT NE 'A'.
          PERFORM PROC_DATA3.
        ELSE.
          MESSAGE E016(PN) WITH 'Can not Upload Diff HU'.
        ENDIF.
      ENDIF.
*      BREAK-POINT.
      IF ST NE 'X' AND ( ABSTA EQ 'C' OR GBSTA EQ 'C' ).
      ELSE.
        PERFORM F_FIELD_CATALOG_END.
        PERFORM DISPLAY_ALV_REPORT_END.
      ENDIF.
    WHEN 'TEST'.
      INDEX = 1.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CALL METHOD LS_REF1->REFRESH_TABLE_DISPLAY .
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  L_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM L_USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : LS_REF1 TYPE REF TO CL_GUI_ALV_GRID.
  SY-LSIND = 0.
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LS_REF1.

  CALL METHOD LS_REF1->CHECK_CHANGED_DATA .

  CASE R_UCOMM .
    WHEN 'REFE'.
      PERFORM F_FIELD_CATALOG_LOG.
      PERFORM DISPLAY_ALV_REPORT_LOG.
    WHEN 'TEST'.
      INDEX = 1.
      CALL TRANSACTION 'ZSD008'.
      LEAVE PROGRAM.
  ENDCASE.
  CALL METHOD LS_REF1->REFRESH_TABLE_DISPLAY .

ENDFORM.                    "USER_COMMAND

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
        LD_LINESC(10) TYPE C,
        TXT TYPE C LENGTH 25.
  IF R3 IS NOT INITIAL.
    TXT = 'Transfer SO to SO'.
  ELSEIF R4 IS NOT INITIAL.
    TXT = 'Transfer Free to SO'.
  ELSEIF R5 IS NOT INITIAL.
    TXT = 'Transfer SO to Free'.
  ENDIF.

* TITLE
  WA_HEADER-TYP  = 'H'.
  WA_HEADER-INFO = TXT.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = T_HEADER.
ENDFORM. "TOP-OF-PAGE


**&---------------------------------------------------------------------
**&      Form  F_GUI_STATUS
**&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'PFSTAT'.
ENDFORM.                    " F_ALV_STATUS
*&---------------------------------------------------------------------*
*&      Form  L_GUI_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EXTAB   text
*----------------------------------------------------------------------*
FORM L_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'PF_LOG'.
ENDFORM.                    "L_GUI_STATUS
*&---------------------------------------------------------------------*
*&      Form  POPSTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPSTS .
  DATA : ANSWER TYPE C,
        POPUP TYPE C LENGTH 50,
        ATWRT1 LIKE CAWN-ATWRT,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        ATWRT2 LIKE CAWN-ATWRT,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        TEXT TYPE STRING,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        V_PASS.   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
  CLEAR: IT_SOPOP.
  REFRESH : IT_SOPOP.
  IT_SOPOP-TABNAME = 'MKPF'.
  IT_SOPOP-FIELDNAME = 'BUDAT'.
  IT_SOPOP-FIELDTEXT  = 'Posting Date'.
  IT_SOPOP-FIELD_OBL = 'X'.
*  IT_SOPOP-VALUE = ITAB_DATA-POST_DATE.
  CONCATENATE ITAB_DATA-POST_DATE+6(4) ITAB_DATA-POST_DATE+3(2) ITAB_DATA-POST_DATE+0(2) INTO IT_SOPOP-VALUE.
  APPEND IT_SOPOP.

  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MSEG'.
  IT_SOPOP-FIELDNAME = 'KDAUF'.
  IT_SOPOP-FIELDTEXT  = 'SO Number'.
  IT_SOPOP-FIELD_OBL = 'X'.
  APPEND IT_SOPOP.
  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MSEG'.
  IT_SOPOP-FIELDNAME = 'KDPOS'.
  IT_SOPOP-FIELDTEXT  = 'SO Item'.
  IT_SOPOP-FIELD_OBL = 'X'.
  APPEND IT_SOPOP.

  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MCHB'.
  IT_SOPOP-FIELDNAME = 'WERKS'.
  IT_SOPOP-FIELDTEXT  = 'Plant'.
  IT_SOPOP-VALUE = ITAB_DATA-PLANT.
  IT_SOPOP-FIELD_ATTR = '05'.
  APPEND IT_SOPOP.
  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MCHB'.
  IT_SOPOP-FIELDNAME = 'LGORT'.
  IT_SOPOP-FIELDTEXT  = 'Storage Location'.
  IT_SOPOP-VALUE = ITAB_DATA-SLOC.
  IT_SOPOP-FIELD_ATTR = '05'.
  APPEND IT_SOPOP.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = 'SO to SO '
    IMPORTING
      RETURNCODE      = RETURNCODE
    TABLES
      FIELDS          = IT_SOPOP
    EXCEPTIONS
      ERROR_IN_FIELDS = 1.
  IF RETURNCODE EQ 'A'.
    LEAVE SCREEN.
  ELSE.
    LOOP AT ITAB_DATA.
      READ TABLE IT_SOPOP WITH KEY FIELDNAME = 'KDAUF'.
      IF SY-SUBRC EQ 0.
        ITAB_DATA-SALES_ORDER = IT_SOPOP-VALUE.
      ENDIF.
      READ TABLE IT_SOPOP WITH KEY FIELDNAME = 'KDPOS'.
      IF SY-SUBRC EQ 0.
        ITAB_DATA-SALES_ORDER_ITEM = IT_SOPOP-VALUE.
      ENDIF.
      READ TABLE IT_SOPOP WITH KEY FIELDNAME = 'BUDAT'.
      IF SY-SUBRC EQ 0.
*        ITAB_DATA-POST_DATE = IT_SOPOP-VALUE.
        CONCATENATE IT_SOPOP-VALUE+6(2) IT_SOPOP-VALUE+4(2) IT_SOPOP-VALUE+0(4) INTO ITAB_DATA-POST_DATE SEPARATED BY '.'.
      ENDIF.
      MODIFY ITAB_DATA.
    ENDLOOP.
  ENDIF.
  CLEAR TCUOBJ.
  CLEAR: CONFIG,TBATCH,ST.
  REFRESH : CONFIG,TBATCH.
  READ TABLE ITAB_DATA INDEX 1.
  SELECT SINGLE CUOBJ INTO TCUOBJ
    FROM VBAP
    WHERE VBAP~VBELN = ITAB_DATA-SALES_ORDER
    AND VBAP~MATNR = ITAB_DATA-MATERIAL
    AND VBAP~POSNR = ITAB_DATA-SALES_ORDER_ITEM.
  SELECT SINGLE AUART INTO AUART
      FROM VBAK
      WHERE VBELN = ITAB_DATA-SALES_ORDER
      AND AUART IN ('ZDRC','ZDRE','ZERE','ZERC').
  IF SY-SUBRC EQ 0.
    ST = 'X'.
  ENDIF.
  IF TCUOBJ IS INITIAL.
    MESSAGE E016(PN) WITH 'Configuration Object 'ITAB_DATA-SALES_ORDER ITAB_DATA-SALES_ORDER_ITEM ' does not exist'.
  ENDIF.
  "Add by J. Budi at 14 May 2025 for Subcontracting Laminate
  PERFORM SUBCONTRACTING USING ITAB_DATA-SALES_ORDER.
  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE      = TCUOBJ
    TABLES
      CONFIGURATION = CONFIG.

  LOOP AT ITAB_DATA.
    CLEAR TBATCH.
    REFRESH TBATCH.
    CALL FUNCTION 'VB_BATCH_GET_DETAIL' "
            EXPORTING
              MATNR = ITAB_DATA-MATERIAL
              CHARG = ITAB_DATA-BATCH
             GET_CLASSIFICATION = 'X'
           TABLES
             CHAR_OF_BATCH = TBATCH.
    CLEAR : STAT, TERR,ANSWER,POPUP.
*    BREAK-POINT.
    LOOP AT IT_ATNAM.
      "Cek Packing Code hanya untuk Plant Trias (1000 dan 2000) - Start Add by Fiqih 25.05.2026
      IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ITAB_DATA-PLANT NE '1000' AND ITAB_DATA-PLANT NE '2000'.
        CONTINUE.
      ENDIF.
      "End Add by Fiqih 25.05.2026
      READ TABLE CONFIG WITH KEY ATNAM = IT_ATNAM-ATNAM.
      IF SY-SUBRC EQ 0.
        READ TABLE TBATCH WITH KEY ATNAM = IT_ATNAM-ATNAM.
        IF SY-SUBRC EQ 0 AND ST NE 'X'.
          IF TBATCH-ATWTB NE CONFIG-ATWTB .
            " Modified by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
              CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
              " Get ZZPACKINGCODE Batch
              SELECT SINGLE CAWN~ATWRT INTO ATWRT1 FROM CAWN
                JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATINN = TBATCH-ATINN AND CAWNT~ATWTB = TBATCH-ATWTB.

              " Get ZZPACKINGCODE SO
              SELECT SINGLE CAWN~ATWRT INTO ATWRT2 FROM CAWN
                JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATINN = CONFIG-ATINN AND CAWNT~ATWTB = CONFIG-ATWTB.

              IF ATWRT1 IS NOT INITIAL AND ATWRT2 IS NOT INITIAL.
                IF ATWRT1+0(1) EQ 'R' AND ATWRT2+0(1) NE 'R'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM ' adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                  CALL FUNCTION 'POPUP_TO_CONFIRM'
                    EXPORTING
                      TITLEBAR              = 'Confirmation'
                      TEXT_QUESTION         = TEXT
                      TEXT_BUTTON_1         = 'Ya'
                      TEXT_BUTTON_2         = 'Tidak'
                      DEFAULT_BUTTON        = '2'
                      DISPLAY_CANCEL_BUTTON = ''
                    IMPORTING
                      ANSWER                = V_PASS.

                  IF V_PASS EQ '1'.
                    " Pass
                  ELSE.
                    " Exit, error
                    STAT = 'X'.
                    CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                    EXIT.
                  ENDIF.
                ELSEIF ATWRT1+0(1) NE 'R' AND ATWRT2+0(1) EQ 'R'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM ' adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                  CALL FUNCTION 'POPUP_TO_CONFIRM'
                    EXPORTING
                      TITLEBAR              = 'Confirmation'
                      TEXT_QUESTION         = TEXT
                      TEXT_BUTTON_1         = 'Ya'
                      TEXT_BUTTON_2         = 'Tidak'
                      DEFAULT_BUTTON        = '2'
                      DISPLAY_CANCEL_BUTTON = ''
                    IMPORTING
                      ANSWER                = V_PASS.

                  IF V_PASS EQ '1'.
                    " Pass
                  ELSE.
                    " Exit, error
                    STAT = 'X'.
                    CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                    EXIT.
                  ENDIF.
                ENDIF.
              ELSE.
                STAT = 'X'.
                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                EXIT.
              ENDIF.
            ELSE.
              STAT = 'X'.
              CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
              EXIT.
            ENDIF.
            " End modified by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            " Remarked by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*            STAT = 'X'.
*            CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*            EXIT.
            " End remarked by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          ENDIF.
        ELSEIF SY-SUBRC NE 0 AND ST NE 'X'.
          CLEAR : ATWTB1,ATWTB2.
          ATWTB2 = ''."TBATCH-ATWTB.
          IF ATWTB2 NE CONFIG-ATWTB.
            " Modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
              CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
              " Get ZZPACKINGCODE SO
              SELECT SINGLE CAWN~ATWRT INTO ATWRT2 FROM CAWN
                JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATINN = CONFIG-ATINN AND CAWNT~ATWTB = CONFIG-ATWTB.

              " Pastikan ini ZZPACKINGCODE SO RTP, jika tidak maka skip
              IF ATWRT2+0(1) EQ 'R'.
                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                CALL FUNCTION 'POPUP_TO_CONFIRM'
                  EXPORTING
                    TITLEBAR              = 'Confirmation'
                    TEXT_QUESTION         = TEXT
                    TEXT_BUTTON_1         = 'Ya'
                    TEXT_BUTTON_2         = 'Tidak'
                    DEFAULT_BUTTON        = '2'
                    DISPLAY_CANCEL_BUTTON = ''
                  IMPORTING
                    ANSWER                = V_PASS.

                IF V_PASS EQ '1'.
                  " Pass
                ELSE.
                  " Exit, error
                  STAT = 'X'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                  EXIT.
                ENDIF.
              ENDIF.
            ELSE.
              STAT = 'X'.
              CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
              EXIT.
            ENDIF.
            " End modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            " Remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*            STAT = 'X'.
*            CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*            EXIT.
            " End remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR : ATWTB1,ATWTB2.
        ATWTB1 = ''."CONFIG-ATWTB.
        READ TABLE TBATCH WITH KEY ATNAM = IT_ATNAM-ATNAM.
        IF SY-SUBRC EQ 0 AND ST NE 'X'.
          IF TBATCH-ATWTB NE ATWTB1 .
            " Modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
              CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
              " Get ZZPACKINGCODE Batch
              SELECT SINGLE CAWN~ATWRT INTO ATWRT1 FROM CAWN
                JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATINN = TBATCH-ATINN AND CAWNT~ATWTB = TBATCH-ATWTB.

              " Pastikan ini ZZPACKINGCODE batch RTP, jika tidak maka skip
              IF ATWRT1+0(1) EQ 'R'.
                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                CALL FUNCTION 'POPUP_TO_CONFIRM'
                  EXPORTING
                    TITLEBAR              = 'Confirmation'
                    TEXT_QUESTION         = TEXT
                    TEXT_BUTTON_1         = 'Ya'
                    TEXT_BUTTON_2         = 'Tidak'
                    DEFAULT_BUTTON        = '2'
                    DISPLAY_CANCEL_BUTTON = ''
                  IMPORTING
                    ANSWER                = V_PASS.

                IF V_PASS EQ '1'.
                  " Pass
                ELSE.
                  " Exit, error
                  STAT = 'X'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                  EXIT.
                ENDIF.
              ENDIF.
            ELSE.
              STAT = 'X'.
              CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
              EXIT.
            ENDIF.
            " End modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            " Remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*            STAT = 'X'.
*            CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*            EXIT.
            " End remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF STAT EQ 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.
  CLEAR : ABSTA,GBSTA,MSG1,MSG2,AUART.
  READ TABLE ITAB_DATA INDEX 1.
  SELECT SINGLE ABSTA GBSTA INTO (ABSTA,GBSTA)
    FROM VBUP
    WHERE VBELN = ITAB_DATA-SALES_ORDER
    AND POSNR = ITAB_DATA-SALES_ORDER_ITEM.
*  SELECT SINGLE AUART INTO AUART
*        FROM VBAK
*        WHERE VBELN = ITAB_DATA-SALES_ORDER
*        AND AUART IN ('ZDRC','ZDRE','ZERE','ZERC').
*  IF SY-SUBRC EQ 0.
*    ST = 'X'.
*  ENDIF.
  CONCATENATE 'Can not  sotoso, so'ITAB_DATA-SALES_ORDER 'rejected' INTO MSG1 SEPARATED BY SPACE.
  CONCATENATE 'Can not  sotoso, so'ITAB_DATA-SALES_ORDER 'completed' INTO MSG2 SEPARATED BY SPACE.
  IF ABSTA EQ 'C' AND ST NE 'X'.
    MESSAGE MSG1 TYPE 'I'.
  ENDIF.
  IF GBSTA EQ 'C' AND ST NE 'X'.
    MESSAGE MSG2 TYPE 'I'.
  ENDIF.
  IF ABSTA  EQ 'C'  AND ST NE 'X' .
  ELSEIF GBSTA EQ 'C'  AND ST NE 'X'.
  ELSE.
    IF STAT NE 'X'.
      PERFORM PROC_DATA1.
    ELSE.
      MESSAGE E016(PN) WITH TERR.
    ENDIF.
  ENDIF.
ENDFORM.                    " POPSTS
*&---------------------------------------------------------------------*
*&      Form  POPFTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPFTS .
  DATA : ANSWER TYPE C,
        POPUP TYPE C LENGTH 50,
        ATWRT1 LIKE CAWN-ATWRT,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        ATWRT2 LIKE CAWN-ATWRT,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        TEXT TYPE STRING,   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
        V_PASS.   " Added by William at 20.05.2026 (for ZZPACKINGCODE)
  CLEAR: IT_SOPOP.
  REFRESH : IT_SOPOP.
  IT_SOPOP-TABNAME = 'MKPF'.
  IT_SOPOP-FIELDNAME = 'BUDAT'.
  IT_SOPOP-FIELDTEXT  = 'Posting Date'.
  IT_SOPOP-FIELD_OBL = 'X'.
*  IT_SOPOP-VALUE = ITAB_DATA-POST_DATE.
  CONCATENATE ITAB_DATA-POST_DATE+6(4) ITAB_DATA-POST_DATE+3(2) ITAB_DATA-POST_DATE+0(2) INTO IT_SOPOP-VALUE.
  APPEND IT_SOPOP.

  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MSEG'.
  IT_SOPOP-FIELDNAME = 'MAT_KDAUF'.
  IT_SOPOP-FIELDTEXT  = 'SO Number'.
  IT_SOPOP-FIELD_OBL = 'X'.
  APPEND IT_SOPOP.
  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MSEG'.
  IT_SOPOP-FIELDNAME = 'MAT_KDPOS'.
  IT_SOPOP-FIELDTEXT  = 'SO Item'.
  IT_SOPOP-FIELD_OBL = 'X'.
  APPEND IT_SOPOP.
  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MCHB'.
  IT_SOPOP-FIELDNAME = 'WERKS'.
  IT_SOPOP-FIELDTEXT  = 'Plant'.
  IT_SOPOP-VALUE = ITAB_DATA-PLANT.
  IT_SOPOP-FIELD_ATTR = '05'.
  APPEND IT_SOPOP.
  CLEAR: IT_SOPOP.
  IT_SOPOP-TABNAME = 'MCHB'.
  IT_SOPOP-FIELDNAME = 'LGORT'.
  IT_SOPOP-FIELDTEXT  = 'Storage Location'.
  IT_SOPOP-VALUE = ITAB_DATA-SLOC.
  IT_SOPOP-FIELD_ATTR = '05'.
  APPEND IT_SOPOP.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = 'Free to SO '
    IMPORTING
      RETURNCODE      = RETURNCODE
    TABLES
      FIELDS          = IT_SOPOP
    EXCEPTIONS
      ERROR_IN_FIELDS = 1.
  IF RETURNCODE EQ 'A'.
    LEAVE SCREEN.
  ELSE.
    LOOP AT ITAB_DATA.
      READ TABLE IT_SOPOP WITH KEY FIELDNAME = 'MAT_KDAUF'.
      IF SY-SUBRC EQ 0.
        ITAB_DATA-SO_STOCK = IT_SOPOP-VALUE.
      ENDIF.
      READ TABLE IT_SOPOP WITH KEY FIELDNAME = 'MAT_KDPOS'.
      IF SY-SUBRC EQ 0.
        ITAB_DATA-SOITEM_STOCK = IT_SOPOP-VALUE.
      ENDIF.
      READ TABLE IT_SOPOP WITH KEY FIELDNAME = 'BUDAT'.
      IF SY-SUBRC EQ 0.
*        ITAB_DATA-POST_DATE = IT_SOPOP-VALUE.
        CONCATENATE IT_SOPOP-VALUE+6(2) IT_SOPOP-VALUE+4(2) IT_SOPOP-VALUE+0(4) INTO ITAB_DATA-POST_DATE SEPARATED BY '.'.
      ENDIF.
      MODIFY ITAB_DATA.
    ENDLOOP.
  ENDIF.
  CLEAR TCUOBJ.
  CLEAR: CONFIG,TBATCH,ST.
  REFRESH : CONFIG,TBATCH.
  READ TABLE ITAB_DATA INDEX 1.
  SELECT SINGLE CUOBJ INTO TCUOBJ
    FROM VBAP
    WHERE VBAP~VBELN = ITAB_DATA-SO_STOCK
    AND VBAP~MATNR = ITAB_DATA-MATERIAL
    AND VBAP~POSNR = ITAB_DATA-SOITEM_STOCK.
  SELECT SINGLE AUART INTO AUART
    FROM VBAK
    WHERE VBELN = ITAB_DATA-SO_STOCK
    AND AUART IN ('ZDRC','ZDRE','ZERE','ZERC').
  IF SY-SUBRC EQ 0.
    ST = 'X'.
  ENDIF.
  IF TCUOBJ IS INITIAL.
    MESSAGE E016(PN) WITH 'Configuration Object 'ITAB_DATA-SO_STOCK ITAB_DATA-SOITEM_STOCK ' does not exist'.
  ENDIF.
  "Add by J. Budi at 14 May 2025 for Subcontracting Laminate
  PERFORM SUBCONTRACTING USING ITAB_DATA-SO_STOCK.
  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE      = TCUOBJ
    TABLES
      CONFIGURATION = CONFIG.

  LOOP AT ITAB_DATA.
    CLEAR TBATCH.
    REFRESH TBATCH.
    CALL FUNCTION 'VB_INIT'
      EXPORTING
        INIT_RESET = 'X'.
    CALL FUNCTION 'VB_BATCH_GET_DETAIL' "
            EXPORTING
              MATNR = ITAB_DATA-MATERIAL
              CHARG = ITAB_DATA-BATCH
             GET_CLASSIFICATION = 'X'
           TABLES
             CHAR_OF_BATCH = TBATCH.
    CLEAR : STAT, TERR,ANSWER,POPUP.

    LOOP AT IT_ATNAM.
      "Cek Packing Code hanya untuk Plant Trias (1000 dan 2000) - Start Add by Fiqih 25.05.2026
      IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ITAB_DATA-PLANT NE '1000' AND ITAB_DATA-PLANT NE '2000'.
        CONTINUE.
      ENDIF.
      "End Add by Fiqih 25.05.2026

*--- update bug by ALF
      READ TABLE CONFIG WITH KEY ATNAM = IT_ATNAM-ATNAM.
      IF SY-SUBRC EQ 0.
        READ TABLE TBATCH WITH KEY ATNAM = IT_ATNAM-ATNAM.
        IF SY-SUBRC EQ 0 AND ST NE 'X'.
          IF TBATCH-ATWTB NE CONFIG-ATWTB .
            " Modified by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
              CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
              " Get ZZPACKINGCODE Batch
              SELECT SINGLE CAWN~ATWRT INTO ATWRT1 FROM CAWN
                JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATINN = TBATCH-ATINN AND CAWNT~ATWTB = TBATCH-ATWTB.

              " Get ZZPACKINGCODE SO
              SELECT SINGLE CAWN~ATWRT INTO ATWRT2 FROM CAWN
                JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATINN = CONFIG-ATINN AND CAWNT~ATWTB = CONFIG-ATWTB.

              IF ATWRT1 IS NOT INITIAL AND ATWRT2 IS NOT INITIAL.
                IF ATWRT1+0(1) EQ 'R' AND ATWRT2+0(1) NE 'R'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SO_STOCK '-' ITAB_DATA-SOITEM_STOCK ' adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                  CALL FUNCTION 'POPUP_TO_CONFIRM'
                    EXPORTING
                      TITLEBAR              = 'Confirmation'
                      TEXT_QUESTION         = TEXT
                      TEXT_BUTTON_1         = 'Ya'
                      TEXT_BUTTON_2         = 'Tidak'
                      DEFAULT_BUTTON        = '2'
                      DISPLAY_CANCEL_BUTTON = ''
                    IMPORTING
                      ANSWER                = V_PASS.

                  IF V_PASS EQ '1'.
                    " Pass
                  ELSE.
                    " Exit, error
                    STAT = 'X'.
                    CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                    EXIT.
                  ENDIF.
                ELSEIF ATWRT1+0(1) NE 'R' AND ATWRT2+0(1) EQ 'R'.
                  CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SO_STOCK '-' ITAB_DATA-SOITEM_STOCK ' adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
                  CALL FUNCTION 'POPUP_TO_CONFIRM'
                    EXPORTING
                      TITLEBAR              = 'Confirmation'
                      TEXT_QUESTION         = TEXT
                      TEXT_BUTTON_1         = 'Ya'
                      TEXT_BUTTON_2         = 'Tidak'
                      DEFAULT_BUTTON        = '2'
                      DISPLAY_CANCEL_BUTTON = ''
                    IMPORTING
                      ANSWER                = V_PASS.

                  IF V_PASS EQ '1'.
                    " Pass
                  ELSE.
                    " Exit, error
                    STAT = 'X'.
                    CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                    EXIT.
                  ENDIF.
                ENDIF.
              ELSE.
                STAT = 'X'.
                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                EXIT.
              ENDIF.
            ELSE.
              STAT = 'X'.
              CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
              EXIT.
            ENDIF.
            " End modified by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
            " Remarked by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*            STAT = 'X'.
*            CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*            EXIT.
            " End remarked by William at 20.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          ENDIF.
        ELSEIF SY-SUBRC NE 0 AND ST NE 'X'.
          CLEAR : ATWTB1,ATWTB2.
          ATWTB2 = ''."TBATCH-ATWTB.
*          IF ATWTB2 = CONFIG-ATWTB.
          " Modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
            CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
            " Get ZZPACKINGCODE SO
            SELECT SINGLE CAWN~ATWRT INTO ATWRT2 FROM CAWN
              JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
              WHERE CAWNT~ATINN = CONFIG-ATINN AND CAWNT~ATWTB = CONFIG-ATWTB.

            " Pastikan ini ZZPACKINGCODE SO RTP, jika tidak maka skip
            IF ATWRT2+0(1) EQ 'R'.
              CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah non-RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  TITLEBAR              = 'Confirmation'
                  TEXT_QUESTION         = TEXT
                  TEXT_BUTTON_1         = 'Ya'
                  TEXT_BUTTON_2         = 'Tidak'
                  DEFAULT_BUTTON        = '2'
                  DISPLAY_CANCEL_BUTTON = ''
                IMPORTING
                  ANSWER                = V_PASS.

              IF V_PASS EQ '1'.
                " Pass
              ELSE.
                " Exit, error
                STAT = 'X'.
                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                EXIT.
              ENDIF.
            ENDIF.
          ELSE.
            STAT = 'X'.
            CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
            EXIT.
          ENDIF.
          " End modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          " Remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*          STAT = 'X'.
*          CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*          EXIT.
          " End remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*          ENDIF.
        ENDIF.
      ELSE.
        CLEAR : ATWTB1,ATWTB2.
        ATWTB1 = ''."CONFIG-ATWTB.
        READ TABLE TBATCH WITH KEY ATNAM = IT_ATNAM-ATNAM.
        IF SY-SUBRC EQ 0.
          " Modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          IF IT_ATNAM-ATNAM = 'ZZPACKINGCODE' AND ( ITAB_DATA-PLANT = '1000' OR ITAB_DATA-PLANT = '2000' ).
            CLEAR: ATWRT1, ATWRT2, TEXT, V_PASS.
            " Get ZZPACKINGCODE Batch
            SELECT SINGLE CAWN~ATWRT INTO ATWRT1 FROM CAWN
              JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
              WHERE CAWNT~ATINN = TBATCH-ATINN AND CAWNT~ATWTB = TBATCH-ATWTB.

            " Pastikan ini ZZPACKINGCODE batch RTP, jika tidak maka skip
            IF ATWRT1+0(1) EQ 'R'.
              CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'adalah RTP dan ' IT_ATNAM-ATBEZ 'SO ' ITAB_DATA-SALES_ORDER '-' ITAB_DATA-SALES_ORDER_ITEM 'adalah non-RTP. Lanjutkan?' INTO TEXT SEPARATED BY SPACE.
              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  TITLEBAR              = 'Confirmation'
                  TEXT_QUESTION         = TEXT
                  TEXT_BUTTON_1         = 'Ya'
                  TEXT_BUTTON_2         = 'Tidak'
                  DEFAULT_BUTTON        = '2'
                  DISPLAY_CANCEL_BUTTON = ''
                IMPORTING
                  ANSWER                = V_PASS.

              IF V_PASS EQ '1'.
                " Pass
              ELSE.
                " Exit, error
                STAT = 'X'.
                CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
                EXIT.
              ENDIF.
            ENDIF.
          ELSE.
            STAT = 'X'.
            CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
            EXIT.
          ENDIF.
          " End modified by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
          " Remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
*          STAT = 'X'.
*          CONCATENATE IT_ATNAM-ATBEZ 'batch ' ITAB_DATA-BATCH 'Diff' INTO TERR SEPARATED BY SPACE.
*          EXIT.
          " End remarked by William at 21.05.2026 (exception for ZZPACKINGCODE / Kode Pack)
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF STAT EQ 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.
  CLEAR : ABSTA,GBSTA,MSG1,MSG2.
  READ TABLE ITAB_DATA INDEX 1.
  SELECT SINGLE ABSTA GBSTA INTO (ABSTA,GBSTA)
    FROM VBUP
    WHERE VBELN = ITAB_DATA-SO_STOCK
    AND POSNR = ITAB_DATA-SOITEM_STOCK.

*  SELECT SINGLE AUART INTO AUART
*      FROM VBAK
*      WHERE VBELN = ITAB_DATA-SO_STOCK
*      AND AUART IN ('ZDRC','ZDRE','ZERE','ZERC').
*  IF SY-SUBRC EQ 0.
*    ST = 'X'.
*  ENDIF.
  CONCATENATE 'Can not  sotoso, so'ITAB_DATA-SO_STOCK 'rejected' INTO MSG1 SEPARATED BY SPACE.
  CONCATENATE 'Can not  sotoso, so'ITAB_DATA-SO_STOCK 'completed' INTO MSG2 SEPARATED BY SPACE.
  IF ABSTA EQ 'C' AND ST NE 'X'.
    MESSAGE MSG1 TYPE 'I'.
  ENDIF.
  IF GBSTA EQ 'C' AND ST NE 'X'.
    MESSAGE MSG2 TYPE 'I'.
  ENDIF.
  IF ABSTA  EQ 'C'  AND ST NE 'X' .
  ELSEIF GBSTA EQ 'C'  AND ST NE 'X'.
  ELSE.
    IF STAT NE 'X'.
      PERFORM PROC_DATA2.
    ELSE.
      MESSAGE E016(PN) WITH TERR.
    ENDIF.
  ENDIF.
ENDFORM.                    " POPFTS
*&---------------------------------------------------------------------*
*&      Form  PROC_DATA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROC_DATA1 .
  CLEAR   T_ERRORS.
  REFRESH T_ERRORS.
  CLEAR IT_REPORT.
  REFRESH IT_REPORT.
  LOOP AT ITAB_DATA.

    CLEAR   ERRMSG.
    REFRESH ERRMSG.

    AT NEW MOV_TYPE.
      REFRESH ITAB.
      CLEAR ITAB.

      CLEAR : GMHEAD,
              GMCODE.
    ENDAT.
*
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL            = ITAB_DATA-POST_DATE
      IMPORTING
        DATE_INTERNAL            = GMHEAD-PSTNG_DATE
      EXCEPTIONS
        DATE_EXTERNAL_IS_INVALID = 1
        OTHERS                   = 2.
    CONDENSE ITAB_DATA-QUANT NO-GAPS.

    GMHEAD-DOC_DATE   = SY-DATUM.
    GMHEAD-PR_UNAME   = SY-UNAME.
    GMCODE-GM_CODE    = '04'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA-SO_STOCK
      IMPORTING
        OUTPUT = ITAB-VAL_SALES_ORD.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA-SALES_ORDER
      IMPORTING
        OUTPUT = ITAB-SALES_ORD.

    ITAB-MOVE_TYPE       =  ITAB_DATA-MOV_TYPE.
    ITAB-MVT_IND         = ' '.
    ITAB-SPEC_STOCK      =  ITAB_DATA-SPEC_STOCK.
    ITAB-PLANT           =  ITAB_DATA-PLANT.
    ITAB-MATERIAL        =  ITAB_DATA-MATERIAL.
    ITAB-ENTRY_QNT       =  ITAB_DATA-QUANT.
    ITAB-ENTRY_UOM       =  ITAB_DATA-UOM.
    ITAB-MOVE_STLOC      =  ITAB_DATA-ISSUE_SLOC.
    ITAB-STGE_LOC        =  ITAB_DATA-SLOC.
    ITAB-BATCH           =  ITAB_DATA-BATCH.
    ITAB-S_ORD_ITEM      =  ITAB_DATA-SALES_ORDER_ITEM.
    ITAB-VAL_S_ORD_ITEM  =  ITAB_DATA-SOITEM_STOCK.
    ITAB-MOVE_BATCH      =  ITAB_DATA-BATCH.
    APPEND ITAB.

    CASE ITAB_DATA-MOV_TYPE.
      WHEN  '413'.
        IT_REPORT-BUDAT  =  ITAB_DATA-POST_DATE.
        IT_REPORT-MATNR  =  ITAB_DATA-MATERIAL.
        IT_REPORT-CHARG  =  ITAB_DATA-BATCH.
        IT_REPORT-WERKS  =  ITAB_DATA-PLANT.
        IT_REPORT-LGORT  =  ITAB_DATA-SLOC.
        IT_REPORT-MENGE  =  ITAB_DATA-QUANT.
        IT_REPORT-MEINS  =  ITAB_DATA-UOM.
        IT_REPORT-SONU1  =  ITAB_DATA-SO_STOCK.
        IT_REPORT-SOIT1  =  ITAB_DATA-SALES_ORDER_ITEM.
        IT_REPORT-SONU1  =  ITAB_DATA-SALES_ORDER.
        IT_REPORT-SOIT1  =  ITAB_DATA-SALES_ORDER_ITEM.
        APPEND IT_REPORT.
        CLEAR IT_REPORT.
    ENDCASE.
    ITAB_LOG-POST_DATE  =  ITAB_DATA-POST_DATE.
    ITAB_LOG-MOV_TYPE = ITAB_DATA-MOV_TYPE.
    ITAB_LOG-EXIDV = ITAB_DATA-EXIDV.
    ITAB_LOG-SPEC_STOCK = ITAB_DATA-SPEC_STOCK.
    ITAB_LOG-MATERIAL  =  ITAB_DATA-MATERIAL.
    ITAB_LOG-BATCH  =  ITAB_DATA-BATCH.
    ITAB_LOG-PLANT  =  ITAB_DATA-PLANT.
    ITAB_LOG-SLOC  =  ITAB_DATA-SLOC.
    ITAB_LOG-QUANT  =  ITAB_DATA-QUANT.
    ITAB_LOG-UOM  =  ITAB_DATA-UOM.
    ITAB_LOG-SO_STOCK  =  ITAB_DATA-SALES_ORDER.
    ITAB_LOG-SOITEM_STOCK  =  ITAB_DATA-SALES_ORDER_ITEM.
    ITAB_LOG-SALES_ORDER  =  ITAB_DATA-SO_STOCK.
    ITAB_LOG-SALES_ORDER_ITEM  =  ITAB_DATA-SOITEM_STOCK.
    APPEND ITAB_LOG.
    CLEAR ITAB_LOG.

    AT END OF MOV_TYPE.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = GMHEAD
          GOODSMVT_CODE    = GMCODE
          TESTRUN          = ' '
        IMPORTING
          GOODSMVT_HEADRET = MTHEAD
        TABLES
          GOODSMVT_ITEM    = ITAB
          RETURN           = ERRMSG.
      FLAG = 'X'.
      PERFORM GET_ERROR.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " PROC_DATA1
*&---------------------------------------------------------------------*
*&      Form  PROC_DATA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROC_DATA2 .
  CLEAR   T_ERRORS.
  REFRESH T_ERRORS.
  CLEAR IT_REPORT.
  REFRESH IT_REPORT.
  LOOP AT ITAB_DATA.

    CLEAR   ERRMSG.
    REFRESH ERRMSG.

    AT NEW MOV_TYPE.
      REFRESH ITAB.
      CLEAR ITAB.

      CLEAR : GMHEAD,
              GMCODE.
    ENDAT.
*
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL            = ITAB_DATA-POST_DATE
      IMPORTING
        DATE_INTERNAL            = GMHEAD-PSTNG_DATE
      EXCEPTIONS
        DATE_EXTERNAL_IS_INVALID = 1
        OTHERS                   = 2.
    CONDENSE ITAB_DATA-QUANT NO-GAPS.

    GMHEAD-DOC_DATE   = SY-DATUM.
    GMHEAD-PR_UNAME   = SY-UNAME.
    GMCODE-GM_CODE    = '04'.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA-SO_STOCK
      IMPORTING
        OUTPUT = ITAB-VAL_SALES_ORD.

    ITAB-MOVE_TYPE       =  ITAB_DATA-MOV_TYPE.
    ITAB-MVT_IND         = ' '.
    ITAB-SPEC_STOCK      =  ITAB_DATA-SPEC_STOCK.
    ITAB-PLANT           =  ITAB_DATA-PLANT.
    ITAB-MATERIAL        =  ITAB_DATA-MATERIAL.
    ITAB-ENTRY_QNT       =  ITAB_DATA-QUANT.
    ITAB-ENTRY_UOM       =  ITAB_DATA-UOM.
    ITAB-MOVE_STLOC      =  ITAB_DATA-ISSUE_SLOC.
    ITAB-STGE_LOC        =  ITAB_DATA-SLOC.
    ITAB-BATCH           =  ITAB_DATA-BATCH.
    ITAB-VAL_S_ORD_ITEM  =  ITAB_DATA-SOITEM_STOCK.
    ITAB-MOVE_BATCH      =  ITAB_DATA-BATCH.
    APPEND ITAB.

    CASE ITAB_DATA-MOV_TYPE.
*Perubahan tanggal 06.02.2013 untuk perubahan movement type
*      WHEN  '412'.
      WHEN  '413'.
        IT_REPORT-BUDAT  =  ITAB_DATA-POST_DATE.
        IT_REPORT-MATNR  =  ITAB_DATA-MATERIAL.
        IT_REPORT-CHARG  =  ITAB_DATA-BATCH.
        IT_REPORT-WERKS  =  ITAB_DATA-PLANT.
        IT_REPORT-LGORT  =  ITAB_DATA-SLOC.
        IT_REPORT-MENGE  =  ITAB_DATA-QUANT.
        IT_REPORT-MEINS  =  ITAB_DATA-UOM.
        IT_REPORT-SONU2  =  ITAB_DATA-SO_STOCK.
        IT_REPORT-SOIT2  =  ITAB_DATA-SOITEM_STOCK.
        APPEND IT_REPORT.
        CLEAR IT_REPORT.
    ENDCASE.
    ITAB_LOG-POST_DATE  =  ITAB_DATA-POST_DATE.
    ITAB_LOG-MOV_TYPE = ITAB_DATA-MOV_TYPE.
    ITAB_LOG-EXIDV = ITAB_DATA-EXIDV.
    ITAB_LOG-SPEC_STOCK = ITAB_DATA-SPEC_STOCK.
    ITAB_LOG-MATERIAL  =  ITAB_DATA-MATERIAL.
    ITAB_LOG-BATCH  =  ITAB_DATA-BATCH.
    ITAB_LOG-PLANT  =  ITAB_DATA-PLANT.
    ITAB_LOG-SLOC  =  ITAB_DATA-SLOC.
    ITAB_LOG-QUANT  =  ITAB_DATA-QUANT.
    ITAB_LOG-UOM  =  ITAB_DATA-UOM.
    ITAB_LOG-SO_STOCK  =  ITAB_DATA-SO_STOCK.
    ITAB_LOG-SOITEM_STOCK  = ITAB_DATA-SOITEM_STOCK.
    ITAB_LOG-SALES_ORDER  =  ''.
    ITAB_LOG-SALES_ORDER_ITEM  = ''.
    APPEND ITAB_LOG.
    CLEAR ITAB_LOG.

    AT END OF MOV_TYPE.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = GMHEAD
          GOODSMVT_CODE    = GMCODE
          TESTRUN          = ' '
        IMPORTING
          GOODSMVT_HEADRET = MTHEAD
        TABLES
          GOODSMVT_ITEM    = ITAB
          RETURN           = ERRMSG.
      FLAG = 'X'.
      PERFORM GET_ERROR.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " PROC_DATA2
*&---------------------------------------------------------------------*
*&      Form  PROC_DATA3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROC_DATA3 .
  CLEAR   T_ERRORS.
  REFRESH T_ERRORS.
  CLEAR IT_REPORT.
  REFRESH IT_REPORT.
  CLEAR: IT_SOPOP.
  REFRESH : IT_SOPOP.

  IT_SOPOP-TABNAME = 'MKPF'.
  IT_SOPOP-FIELDNAME = 'BUDAT'.
  IT_SOPOP-FIELDTEXT  = 'Posting Date'.
  IT_SOPOP-FIELD_OBL = 'X'.
*  IT_SOPOP-VALUE = ITAB_DATA-POST_DATE.
  CONCATENATE ITAB_DATA-POST_DATE+6(4) ITAB_DATA-POST_DATE+3(2) ITAB_DATA-POST_DATE+0(2) INTO IT_SOPOP-VALUE.
  APPEND IT_SOPOP.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = 'Free to SO '
    IMPORTING
      RETURNCODE      = RETURNCODE
    TABLES
      FIELDS          = IT_SOPOP
    EXCEPTIONS
      ERROR_IN_FIELDS = 1.
  IF RETURNCODE EQ 'A'.
    LEAVE SCREEN.
  ELSE.
    LOOP AT ITAB_DATA.
      READ TABLE IT_SOPOP WITH KEY FIELDNAME = 'BUDAT'.
      IF SY-SUBRC EQ 0.
*        ITAB_DATA-POST_DATE = IT_SOPOP-VALUE.
        CONCATENATE IT_SOPOP-VALUE+6(2) IT_SOPOP-VALUE+4(2) IT_SOPOP-VALUE+0(4) INTO ITAB_DATA-POST_DATE SEPARATED BY '.'.
      ENDIF.
      MODIFY ITAB_DATA.
    ENDLOOP.
  ENDIF.
  LOOP AT ITAB_DATA.
    CLEAR   ERRMSG.
    REFRESH ERRMSG.

    AT NEW MOV_TYPE.
      REFRESH ITAB.
      CLEAR ITAB.

      CLEAR : GMHEAD,
              GMCODE.
    ENDAT.
*
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL            = ITAB_DATA-POST_DATE
      IMPORTING
        DATE_INTERNAL            = GMHEAD-PSTNG_DATE
      EXCEPTIONS
        DATE_EXTERNAL_IS_INVALID = 1
        OTHERS                   = 2.
    CONDENSE ITAB_DATA-QUANT NO-GAPS.

    GMHEAD-DOC_DATE   = SY-DATUM.
    GMHEAD-PR_UNAME   = SY-UNAME.
    GMCODE-GM_CODE    = '04'.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITAB_DATA-SO_STOCK
      IMPORTING
        OUTPUT = ITAB-VAL_SALES_ORD.

    ITAB-MOVE_TYPE       =  ITAB_DATA-MOV_TYPE.
    ITAB-MVT_IND         = ' '.
    ITAB-SPEC_STOCK      =  ITAB_DATA-SPEC_STOCK.
    ITAB-PLANT           =  ITAB_DATA-PLANT.
    ITAB-MATERIAL        =  ITAB_DATA-MATERIAL.
    ITAB-ENTRY_QNT       =  ITAB_DATA-QUANT.
    ITAB-ENTRY_UOM       =  ITAB_DATA-UOM.
    ITAB-MOVE_STLOC      =  ITAB_DATA-ISSUE_SLOC.
    ITAB-STGE_LOC        =  ITAB_DATA-SLOC.
    ITAB-BATCH           =  ITAB_DATA-BATCH.
    ITAB-VAL_S_ORD_ITEM  =  ITAB_DATA-SOITEM_STOCK.
    ITAB-MOVE_BATCH      =  ITAB_DATA-BATCH.
    APPEND ITAB.

    CASE ITAB_DATA-MOV_TYPE.
      WHEN  '411'.
        IT_REPORT-BUDAT  =  ITAB_DATA-POST_DATE.
        IT_REPORT-MATNR  =  ITAB_DATA-MATERIAL.
        IT_REPORT-CHARG  =  ITAB_DATA-BATCH.
        IT_REPORT-WERKS  =  ITAB_DATA-PLANT.
        IT_REPORT-LGORT  =  ITAB_DATA-SLOC.
        IT_REPORT-MENGE  =  ITAB_DATA-QUANT.
        IT_REPORT-MEINS  =  ITAB_DATA-UOM.
        IT_REPORT-SONU1  =  ITAB_DATA-SO_STOCK.
        IT_REPORT-SOIT1  =  ITAB_DATA-SOITEM_STOCK.
        APPEND IT_REPORT.
        CLEAR IT_REPORT.
    ENDCASE.
    ITAB_LOG-POST_DATE  =  ITAB_DATA-POST_DATE.
    ITAB_LOG-MOV_TYPE = ITAB_DATA-MOV_TYPE.
    ITAB_LOG-EXIDV = ITAB_DATA-EXIDV.
    ITAB_LOG-SPEC_STOCK = ITAB_DATA-SPEC_STOCK.
    ITAB_LOG-MATERIAL  =  ITAB_DATA-MATERIAL.
    ITAB_LOG-BATCH  =  ITAB_DATA-BATCH.
    ITAB_LOG-PLANT  =  ITAB_DATA-PLANT.
    ITAB_LOG-SLOC  =  ITAB_DATA-SLOC.
    ITAB_LOG-QUANT  =  ITAB_DATA-QUANT.
    ITAB_LOG-UOM  =  ITAB_DATA-UOM.
    ITAB_LOG-SO_STOCK  =  ''.
    ITAB_LOG-SOITEM_STOCK  =  ''.
    ITAB_LOG-SALES_ORDER  =  ITAB_DATA-SO_STOCK.
    ITAB_LOG-SALES_ORDER_ITEM  = ITAB_DATA-SOITEM_STOCK.
    APPEND ITAB_LOG.
    CLEAR ITAB_LOG.

    AT END OF MOV_TYPE.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = GMHEAD
          GOODSMVT_CODE    = GMCODE
          TESTRUN          = ' '
        IMPORTING
          GOODSMVT_HEADRET = MTHEAD
        TABLES
          GOODSMVT_ITEM    = ITAB
          RETURN           = ERRMSG.
      FLAG = 'X'.
      PERFORM GET_ERROR.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " PROC_DATA3
*&---------------------------------------------------------------------*
*&      Form  WRITE_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_LOG .
  IF FLAG IS NOT INITIAL.
    LOOP AT T_ERRORS.
      IF T_ERRORS-TYPE = 'E'.
        WRITE : /2 T_ERRORS-MSG COLOR COL_NEGATIVE.
      ELSE.
        WRITE : /2 T_ERRORS-MSG COLOR COL_POSITIVE.
      ENDIF.
    ENDLOOP.
    CLEAR FLAG.
  ENDIF.
ENDFORM.                    " WRITE_LOG
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_END
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_END .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_SO USING T_ERRORS :
    'MSG'       '' ''  '' ''  'Log' ''  ' ' ''  '' .
ENDFORM.                    " F_FIELD_CATALOG_END
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT_END
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_REPORT_END .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_TOP_OF_PAGE   = 'TOP-OF-PAGE'
      I_CALLBACK_USER_COMMAND  = 'L_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IS_PRINT                 = T_PRINT
      I_SAVE                   = 'X'
    TABLES
      T_OUTTAB                 = T_ERRORS
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT_END






*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_LOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_SO USING 'ITAB_LOG1' :
    'POST_DATE'       '' ''  '' ''  'Date' ''  ' ' '' ' ' ,
    'MOV_TYPE'       '' ''  '' ''  'M Type'  '' ' ' '' ' ',
    'PLANT'       '' ''  '' ''  'Plant'  '' ' ' ''  ' ' ,
    'SLOC'       '' ''  '' ''  'Storage Location' ''  ' ' '' ' '  ,
    'SPEC_STOCK'       '' ''  '' ''  'Special Stock'  '' ' ' '' ' ' ,
    'SO_STOCK'       '' ''  '' ''  'SO' ''  ' ' '' ' ' ,
    'SOITEM_STOCK'       '' ''  '' ''  'Item'  '' ' '  '' ' ',
    'SLOC'       '' ''  '' ''  'I Sloc' ''   ''  '' ' ',
    'MATERIAL'       '' ''  '' ''  'Material'   ' ' '' '' ' ' ,
    'QUANT'       '' ''  '' ''  'Quantity' ''   ''  '' ' ',
    'UOM'       '' ''  '' ''  'UoM'  '' ' '  '' ' ' ,
    'BATCH'       '' ''  '' ''  'Batch'  ''  '' '' ' ' ,
    'EXIDV'       '' ''  '' ''  'HU'  ''  '' '' ' ' ,
    'SALES_ORDER'       '' ''  '' ''  'SO Asal ' ''  ' '  '' ' ' ,
    'SALES_ORDER_ITEM'       '' ''  '' ''  'SO Item Asal'   ' ' '' '' ' ' .
ENDFORM.                    " F_FIELD_CATALOG_LOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_REPORT_LOG .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_TOP_OF_PAGE   = 'TOP-OF-PAGE'
      I_CALLBACK_USER_COMMAND  = 'L_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IS_PRINT                 = T_PRINT
      I_SAVE                   = 'X'
    TABLES
      T_OUTTAB                 = ITAB_LOG1
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT_LOG
*&---------------------------------------------------------------------*
*&      Form  DONLOT_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DONLOT_TEMPLATE .
  CLEAR: ITAB1.
  REFRESH : ITAB1.
  ITAB1-A = 'Date'.
  ITAB1-B = 'M Type'.
  ITAB1-C = 'Plant'.
  ITAB1-D = 'Sloc'.
  ITAB1-E = 'S Stk'.
  ITAB1-F = 'SO'.
  ITAB1-G = 'Item'.
  ITAB1-H = 'SO'.
  ITAB1-I = 'Item'.
  ITAB1-J = 'I Sloc'.
  ITAB1-K = 'Material'.
  ITAB1-L = 'Quant'.
  ITAB1-M = 'UoM'.
  ITAB1-N = 'Batch'.
  APPEND  ITAB1.



  CREATE OBJECT APPLICATION 'excel.application'.
  SET PROPERTY OF APPLICATION 'visible' = 1.
  CALL METHOD OF
      APPLICATION
      'Workbooks' = WORKBOOK.
  CALL METHOD OF
      WORKBOOK
      'Add'.

* Create first Excel Sheet
  CALL METHOD OF
      APPLICATION
      'Worksheets' = SHEET
    EXPORTING
      #1           = 1.
  CALL METHOD OF
      SHEET
      'Activate'.
  SET PROPERTY OF SHEET 'Name' = 'Sheet1'.

  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 1.
  SET PROPERTY OF CELLS 'Value' = ITAB1-A.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 2.
  SET PROPERTY OF CELLS 'Value' = ITAB1-B.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 3.
  SET PROPERTY OF CELLS 'Value' = ITAB1-C.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 4.
  SET PROPERTY OF CELLS 'Value' = ITAB1-D.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 5.
  SET PROPERTY OF CELLS 'Value' = ITAB1-E.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 6.
  SET PROPERTY OF CELLS 'Value' = ITAB1-F.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 7.
  SET PROPERTY OF CELLS 'Value' = ITAB1-G.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 8.
  SET PROPERTY OF CELLS 'Value' = ITAB1-H.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 9.
  SET PROPERTY OF CELLS 'Value' = ITAB1-I.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 10.
  SET PROPERTY OF CELLS 'Value' = ITAB1-J.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 11.
  SET PROPERTY OF CELLS 'Value' = ITAB1-K.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 12.
  SET PROPERTY OF CELLS 'Value' = ITAB1-L.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 13.
  SET PROPERTY OF CELLS 'Value' = ITAB1-M.
  CALL METHOD OF
      SHEET
      'Cells' = CELLS
    EXPORTING
      #1      = 14.
  SET PROPERTY OF CELLS 'Value' = ITAB1-N.

* Save excel speadsheet to particular filename
  CALL METHOD OF
      SHEET
      'SaveAs'

    EXPORTING
      #1       = FPATH" 'd:template.xls'     "filename
      #2       = 1.                          "fileFormat

ENDFORM.                    " DONLOT_TEMPLATE
*&---------------------------------------------------------------------*
*&      Form  MASTER_ATNAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MASTER_ATNAM .
  DATA : ATINN LIKE CABNT-ATINN.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZTYPE'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZCORE'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZCRITERIA'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZLENGTH'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZTREATMENT'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZLABEL'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZPACKING'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZALIAS'.
  APPEND IT_ATNAM.
  CLEAR IT_ATNAM.
  IT_ATNAM-ATNAM = 'ZZWIDTH'.
  APPEND IT_ATNAM.

  " Added by William at 24.03.2026 (validasi Kode Pack)
  IT_ATNAM-ATNAM = 'ZZPACKINGCODE'.
  APPEND IT_ATNAM.
  " End added by William at 24.03.2026 (validasi Kode Pack)

  LOOP AT IT_ATNAM.
    CLEAR ATINN.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = IT_ATNAM
      IMPORTING
        OUTPUT = ATINN.
    SELECT SINGLE ATBEZ INTO IT_ATNAM-ATBEZ
      FROM CABNT
      WHERE ATINN = ATINN.
    MODIFY IT_ATNAM.
  ENDLOOP.
ENDFORM.                    " MASTER_ATNAM
*&---------------------------------------------------------------------*
*&      Form  UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE .
  DATA : N    TYPE N,
         LN   TYPE I,
         TEMP TYPE I,
         VAL  TYPE I,
         V_FIELD(040),
         V_NAME LIKE THEAD-TDNAME,
         CMENGE(15).
  DATA : OPT LIKE CTU_PARAMS.

  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.

  CLEAR : IT_BDCDATA.
  REFRESH : IT_BDCDATA.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '4004'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIKP-VBELN'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'LIKP-VBELN'
                                T_ERRORS-VBELN."'160000300'.
*                                'LIPSD-PIKMG(01)'.
  N = 0.
  VAL = 0.
  CLEAR : LN, TEMP.
  DESCRIBE TABLE IT_LIPS LINES LN.
  LOOP AT IT_LIPS.
    CLEAR CMENGE.
    CMENGE = IT_LIPS-LFIMG.
    CONDENSE CMENGE.
    N = N + 1.
    VAL = VAL + 1.
    IF N > 8.
      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=NPAG_T'.
      TEMP = ( LN - 8 ).
      LN   = TEMP.
      IF TEMP >= 8.
        N = 1.
        VAL = 1.
      ELSE.
        N = ( 8 - TEMP ) + 1.
        VAL = N.
      ENDIF.
    ENDIF.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '/00'.
    CLEAR : V_FIELD.
    CONCATENATE 'LIPSD-PIKMG(0' N ')' INTO V_FIELD.
    PERFORM BDC_FIELD      USING V_FIELD
                           CMENGE.
  ENDLOOP.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SICH_T'.

  CALL TRANSACTION 'VL02N' USING IT_BDCDATA
                                 OPTIONS FROM OPT
                                 MESSAGES INTO IT_BDCMSGCOLL.
  COMMIT WORK AND WAIT.
ENDFORM.                    " UPDATE
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROG       text
*      -->SCR        text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  SUBCONTRACTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUBCONTRACTING USING SO.
  DATA: IT_AUART LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE,
        IT_CHAR  LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE,
        ATINN LIKE CABNT-ATINN.

  REFRESH: IT_AUART, IT_CHAR.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_AUART
    FROM ZMAP_TYPE
   WHERE PROG   EQ SY-CPROG
     AND TYPE   EQ 'SO TYPE'
     AND OPT    EQ 'SUBCONTRACTING'.

  IF IT_AUART[] IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_AUART
    FROM ZMAP_TYPE
   WHERE TCODE   EQ SY-TCODE
     AND TYPE   EQ 'SO TYPE'
     AND OPT    EQ 'SUBCONTRACTING'.
  ENDIF.

  IF IT_AUART[] IS INITIAL.
    EXIT.
  ENDIF.

  IF AUART IS INITIAL.
    SELECT SINGLE AUART INTO AUART FROM VBAK WHERE VBELN = SO.
  ENDIF.

  READ TABLE IT_AUART WITH KEY VALUE = AUART.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_CHAR
    FROM ZMAP_TYPE
   WHERE PROG   EQ SY-CPROG
     AND TYPE   EQ 'CHARACTERISTIC'
     AND OPT    EQ 'SUBCONTRACTING'.

  IF IT_CHAR[] IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_CHAR
      FROM ZMAP_TYPE
     WHERE TCODE  EQ SY-TCODE
       AND TYPE   EQ 'CHARACTERISTIC'
       AND OPT    EQ 'SUBCONTRACTING'.
  ENDIF.

  LOOP AT IT_CHAR.
    CLEAR IT_ATNAM.
    IT_ATNAM-ATNAM = IT_CHAR-VALUE.
    APPEND IT_ATNAM.
  ENDLOOP.

  LOOP AT IT_ATNAM WHERE ATBEZ IS INITIAL.
    CLEAR ATINN.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = IT_ATNAM
      IMPORTING
        OUTPUT = ATINN.
    SELECT SINGLE ATBEZ INTO IT_ATNAM-ATBEZ
      FROM CABNT
      WHERE ATINN = ATINN.
    MODIFY IT_ATNAM.
  ENDLOOP.

ENDFORM.                    "SUBCONTRACTING