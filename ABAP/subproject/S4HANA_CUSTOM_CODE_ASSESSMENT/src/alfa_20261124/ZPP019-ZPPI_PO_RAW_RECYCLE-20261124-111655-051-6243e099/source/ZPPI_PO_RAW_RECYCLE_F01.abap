*&---------------------------------------------------------------------*
*&  Include           ZPPI_PO_RAW_RECYCLE_F01
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM F_GET_DATA .

  TYPES : BEGIN OF IT_AUFNR,
            AUFNR TYPE RESB-AUFNR,
            STATUS TYPE BSVX-STTXT,
            LGORT TYPE RESB-LGORT,
         END OF IT_AUFNR.

  DATA : IT_AUFNR TYPE TABLE OF IT_AUFNR WITH HEADER LINE,
         WA_AUFNR LIKE LINE OF IT_AUFNR.
  DATA : V_AUART TYPE AUFK-AUART.

  REFRESH : ITDATA , ITORDER.

  IF P_BATCH[] IS INITIAL.
    IF P_PLANT[] IS INITIAL.
      IF P_NIK IS INITIAL.
        MESSAGE 'Isi Plant, Batch, dan NIK!' TYPE 'I'.
      ELSE.
        MESSAGE 'Isi Plant dan Batch!' TYPE 'I'.
      ENDIF.
    ELSE.
      IF P_NIK IS INITIAL.
        MESSAGE 'Isi Plant dan NIK!' TYPE 'I'.
      ELSE.
        MESSAGE 'Isi Batch!' TYPE 'I'.
      ENDIF.
    ENDIF.
  ELSE.

    IF P_PLANT[] IS INITIAL.
      IF P_NIK IS INITIAL.
        MESSAGE 'Isi Plant dan NIK!' TYPE 'I'.
      ELSE.
        MESSAGE 'Isi Plant!' TYPE 'I'.
      ENDIF.
    ELSE.
      IF P_NIK IS INITIAL.
        MESSAGE 'Isi NIK!' TYPE 'I'.
      ELSE.

        PERFORM F_CHECK_NIK CHANGING L_ERRNO.

        IF L_ERRNO = -1.

          MESSAGE MESSAGE TYPE 'I' DISPLAY LIKE 'W'.
        ELSE.
          "CONVERSI BATCH INPUT
          LOOP AT P_BATCH.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = P_BATCH-LOW
              IMPORTING
                OUTPUT = P_BATCH-LOW.
            MODIFY P_BATCH.
          ENDLOOP.

          "GET DATA MATERIAL
          SELECT  MCHB~MATNR AS MATNR
            MCHB~CHARG AS CHARG
            MARA~MTART AS MTART
            INTO CORRESPONDING FIELDS OF TABLE ITDATA
            FROM MCHB
            JOIN MARA ON MCHB~MATNR = MARA~MATNR
            WHERE MCHB~CHARG IN P_BATCH
            AND MCHB~WERKS IN P_PLANT
            AND MCHB~LGORT IN R_SLOC.

          SORT ITDATA BY CHARG.
          DELETE ADJACENT DUPLICATES FROM ITDATA COMPARING CHARG.

          IF ITDATA[] IS INITIAL.
            MESSAGE 'Tidak ada data yang ditemukan berdasarkan parameter yang anda input!' TYPE 'I'.
          ELSE.

            LOOP AT ITDATA.
              "SLOC GI
              SELECT SINGLE MCHB~LGORT AS SLOCGI
                 MCHB~CLABS AS CLABS
                 MCHB~CLABS AS CCLABS
                INTO (ITDATA-SLOCGI, ITDATA-CLABS, ITDATA-CCLABS)
                 FROM MCHB
                  WHERE MCHB~CHARG = ITDATA-CHARG
                  AND MCHB~CLABS <> 0.

              REFRESH IT_AUFNR.
              SELECT  RESB~AUFNR
                RESB~LGORT
                INTO CORRESPONDING FIELDS OF TABLE IT_AUFNR
                FROM RESB
                WHERE RESB~CHARG = ITDATA-CHARG.

              "Add Validasi Order Type Mat to Mat ZPP029 by Afir 30.04.2020
              LOOP AT IT_AUFNR.
                SELECT SINGLE AUART FROM AUFK INTO V_AUART WHERE AUFNR EQ IT_AUFNR-AUFNR.
                IF V_AUART EQ 'ZMM1'.
                  DELETE IT_AUFNR WHERE AUFNR EQ IT_AUFNR-AUFNR.
                ENDIF.
              ENDLOOP.

              DELETE IT_AUFNR WHERE AUFNR = ''.
              IF IT_AUFNR[] IS NOT INITIAL.
                "GET OBJECT NUMBER
                LOOP AT IT_AUFNR .
                  CLEAR : OBJNR.
                  SELECT SINGLE AUFK~OBJNR
                    INTO OBJNR
                    FROM AUFK
                    WHERE AUFK~AUFNR = IT_AUFNR-AUFNR.

                  CALL FUNCTION 'AIP9_STATUS_READ'
                    EXPORTING
                      I_OBJNR = OBJNR
                    IMPORTING
                      E_SYSST = IT_AUFNR-STATUS.

                  IF IT_AUFNR-STATUS CP '*TECO*'.
                    DELETE IT_AUFNR.
                    CONTINUE.
                  ELSE.
                    IF IT_AUFNR-STATUS CP '*GMPS*'.
                      "CHANGE STATUS ORDER
                      CLEAR : ITMATDOC, ITREFERENCE.
                      REFRESH : ITMATDOC, ITREFERENCE.
                      "GET DATA MATERIAL DOCUMENT
                      SELECT DISTINCT MBLNR AS MATDOC
                        MJAHR AS MJAHR
                        INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
                        FROM MSEG
                        WHERE AUFNR = IT_AUFNR-AUFNR
                        AND SMBLN = ''.

                      "GET DATA REFERENSI MATDOC.
                      SELECT DISTINCT SMBLN AS MATDOC
                      INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
                      FROM MSEG
                      WHERE AUFNR = IT_AUFNR-AUFNR
                        AND SMBLN NE ''.

                      "GET THE LAST MATDOC FOR PRO
                      LOOP AT ITREFERENCE.
                        DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC.
                      ENDLOOP.

                      IF ITMATDOC[] IS INITIAL .
                        IT_AUFNR-STATUS = 'Canceled'.
                      ELSE.
                        IT_AUFNR-STATUS = 'Posted'.
                      ENDIF.
                    ELSE.
                      IT_AUFNR-STATUS = 'Created'.
                    ENDIF.
                  ENDIF.
                  MODIFY IT_AUFNR.
                ENDLOOP.

                IF IT_AUFNR[] IS NOT INITIAL.
                  CLEAR VLINE.
                  DESCRIBE TABLE IT_AUFNR LINES VLINE.

                  IF VLINE = 1.
                    LOOP AT IT_AUFNR .
                      ITDATA-AUFNR = IT_AUFNR-AUFNR.
                      ITDATA-STATUS = IT_AUFNR-STATUS.
                      ITDATA-SLOCGI = IT_AUFNR-LGORT.
                    ENDLOOP.
                  ELSE.
                    READ TABLE IT_AUFNR WITH KEY STATUS = 'Posted'.

                    IF SY-SUBRC = 0.
                      DELETE IT_AUFNR WHERE STATUS NE 'Posted'.
                      LOOP AT IT_AUFNR .
                        ITDATA-AUFNR = IT_AUFNR-AUFNR.
                        ITDATA-STATUS = IT_AUFNR-STATUS.
                        ITDATA-SLOCGI = IT_AUFNR-LGORT.
                      ENDLOOP.
                    ELSE.
                      DELETE  IT_AUFNR FROM 2 TO VLINE.
                      LOOP AT IT_AUFNR .
                        ITDATA-AUFNR = IT_AUFNR-AUFNR.
                        ITDATA-STATUS = IT_AUFNR-STATUS.
                        ITDATA-SLOCGI = IT_AUFNR-LGORT.
                      ENDLOOP.
                    ENDIF.
                  ENDIF.

                  SELECT SINGLE AFKO~BMENGE
                      FROM AFKO
                      INTO ITDATA-CLABS
                      WHERE AFKO~AUFNR = ITDATA-AUFNR.
                ENDIF.

              ELSE.
                "GET QTY
                SELECT SINGLE MCHB~CLABS AS CLABS
                  MCHB~CLABS AS CCLABS
                   MCHB~LGORT AS SLOCGI
                  INTO (ITDATA-CLABS, ITDATA-CCLABS, ITDATA-SLOCGI )
                  FROM MCHB
                  WHERE MCHB~CHARG = ITDATA-CHARG
                  AND MCHB~CLABS NE ''.
              ENDIF.

              "GET TYPE FILM
              REFRESH ZCHAR.
              CALL FUNCTION 'VB_BATCH_GET_DETAIL'
                EXPORTING
                  MATNR              = ITDATA-MATNR
                  CHARG              = ITDATA-CHARG
                  WERKS              = MCHB-WERKS
                  GET_CLASSIFICATION = 'X'
                TABLES
                  CHAR_OF_BATCH      = ZCHAR.

              IF SY-SUBRC <> 0.
              ELSE.

                LOOP AT ZCHAR WHERE ATNAM = 'ZZCODE'.
                  ITDATA-ZZTYPE = ZCHAR-ATWTB.
                ENDLOOP.

                CLEAR V_LINE.
                LOOP AT ZCHAR WHERE ATNAM =  'ZZPRODLINE'.
                  V_LINE = ZCHAR-ATWTB.
                ENDLOOP.
              ENDIF.

              "GET VALUE OF CODE FILM
              CLEAR : ATINN, ATWRT.
              CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
                EXPORTING
                  INPUT  = 'ZZCODE'
                IMPORTING
                  OUTPUT = ATINN.

              SELECT SINGLE CAWN~ATWRT
                INTO ATWRT
                FROM CAWN
                JOIN CAWNT ON CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATWTB = ITDATA-ZZTYPE
                AND CAWN~ATINN = ATINN.

              "GET RAW MATERIAL
              SELECT SINGLE ZTMAP_MATRECYCLE~RAR_A_MATNR
                INTO ITDATA-RAR_A_MATNR
                FROM ZTMAP_MATRECYCLE
                WHERE ZTMAP_MATRECYCLE~FILMT = ATWRT AND ZTMAP_MATRECYCLE~WERKS IN P_PLANT. "add new company

              "GET VALUE OF LINE
              CLEAR : ATINN, ATWRT.
              CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
                EXPORTING
                  INPUT  = 'ZZPRODLINE'
                IMPORTING
                  OUTPUT = ATINN.

              SELECT SINGLE CAWN~ATWRT
                INTO ATWRT
                FROM CAWN
                JOIN CAWNT ON CAWN~ATZHL = CAWNT~ATZHL
                WHERE CAWNT~ATWTB = V_LINE
                AND CAWN~ATINN = ATINN.

              "GET MIN NO SLOC RR
              CLEAR ZZNUMBER.
              SELECT MIN( ZTMAP_SLOCRR~ZZNUMBER )
                 INTO ZZNUMBER
                 FROM ZTMAP_SLOCRR
                 WHERE ZTMAP_SLOCRR~ZLINE = ATWRT.

              "GET SLOC GR
              SELECT SINGLE ZTMAP_SLOCRR~ZRRLGORT
                INTO ITDATA-SLOCGR
                FROM ZTMAP_SLOCRR
                WHERE ZTMAP_SLOCRR~ZLINE = ATWRT
                AND ZTMAP_SLOCRR~ZZNUMBER = ZZNUMBER.

              "GET SLOC GR DESC.
              IF ITDATA-SLOCGR IS NOT INITIAL.
                SELECT SINGLE T001L~LGOBE
                  INTO ITDATA-DESC
                  FROM T001L
                  WHERE T001L~LGORT = ITDATA-SLOCGR.
              ENDIF.

              MODIFY ITDATA.
            ENDLOOP.
          ENDIF.
          REFRESH CONTROL 'TABCCTL' FROM SCREEN '0110'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_DATAORDER
*&---------------------------------------------------------------------*
*       Get Data Order
*----------------------------------------------------------------------*
FORM F_GET_DATAORDER .
  DATA : VSTAT(6) TYPE C.
  IF P_PERIOD[] IS INITIAL.
    MESSAGE 'Isi Periode!' TYPE 'I'.
  ELSE.
    REFRESH ITORDER.
    SELECT RESB~MATNR AS MATNR
      RESB~AUFNR AS AUFNR
      RESB~CHARG AS CHARG
      AFKO~BMENGE AS BMENGE
      AUFK~OBJNR AS OBJNR
      AUFK~WERKS AS WERKS
      UP TO 100 ROWS
      FROM RESB
      JOIN AFKO ON RESB~AUFNR = AFKO~AUFNR
      JOIN AFPO ON AFKO~AUFNR = AFPO~AUFNR
      JOIN AUFK ON AFPO~AUFNR = AUFK~AUFNR
      INTO CORRESPONDING FIELDS OF TABLE ITORDER
      WHERE RESB~AUFNR IN P_AUFNR
      AND AFKO~GLTRP IN P_PERIOD
      AND RESB~MATNR IN P_MATNR
      AND RESB~CHARG NE ''
      AND AUFK~AUART IN ('ZRR2','ZRR1').

    IF ITORDER[] IS INITIAL.
      MESSAGE 'Data tidak ditemukan!' TYPE 'I'.
    ENDIF.

    REFRESH P_STATUS.
    IF CHC = 'X'.
      CLEAR W_STATUS.
      W_STATUS-SIGN   = 'I'.
      W_STATUS-OPTION = 'EQ'.
      W_STATUS-LOW    = 'CANCELLED'.
      APPEND W_STATUS TO P_STATUS.
    ENDIF.

    IF CHP = 'X'.
      CLEAR W_STATUS.
      W_STATUS-SIGN   = 'I'.
      W_STATUS-OPTION = 'EQ'.
      W_STATUS-LOW    = 'POSTED'.
      APPEND W_STATUS TO P_STATUS.
    ENDIF.

    IF CHR = 'X'.
      CLEAR W_STATUS.
      W_STATUS-SIGN   = 'I'.
      W_STATUS-OPTION = 'EQ'.
      W_STATUS-LOW    = 'RELEASED'.
      APPEND W_STATUS TO P_STATUS.
    ENDIF.

    IF CHT = 'X'.
      CLEAR W_STATUS.
      W_STATUS-SIGN   = 'I'.
      W_STATUS-OPTION = 'EQ'.
      W_STATUS-LOW    = 'TECO'.
      APPEND W_STATUS TO P_STATUS.
    ENDIF.

    LOOP AT ITORDER.
      "GET RAW RECYCLE
      SELECT SINGLE RESB~MATNR
       INTO ITORDER-RAWM
       FROM RESB
       WHERE RESB~AUFNR = ITORDER-AUFNR
       AND RESB~MATNR NE ITORDER-MATNR.

      "GET SLOC GI
      SELECT SINGLE RESB~LGORT
        INTO ITORDER-LGORTGI
        FROM RESB
        WHERE RESB~AUFNR = ITORDER-AUFNR
        AND RESB~MATNR = ITORDER-MATNR
        AND RESB~CHARG = ITORDER-CHARG.

      "GET SLOC GR
      SELECT SINGLE RESB~LGORT
       INTO ITORDER-LGORTGR
       FROM RESB
       WHERE RESB~AUFNR = ITORDER-AUFNR
       AND RESB~MATNR = ITORDER-RAWM.

      "GET STATUS ORDER
      CALL FUNCTION 'AIP9_STATUS_READ'
        EXPORTING
          I_OBJNR = ITORDER-OBJNR
          I_SPRAS = SY-LANGU
        IMPORTING
          E_SYSST = ITORDER-STAT.

      IF ITORDER-STAT NP '*TECO*'.
        IF ITORDER-STAT NP '*GMPS*'.
          ITORDER-STAT = 'RELEASED'.
        ELSEIF ITORDER-STAT CP '*GMPS*'.
          CLEAR : ITMATDOC, ITREFERENCE.
          REFRESH : ITMATDOC, ITREFERENCE.
          "GET DATA MATERIAL DOCUMENT
          SELECT DISTINCT MBLNR AS MATDOC
            MJAHR AS MJAHR
            INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
            FROM MSEG
            WHERE AUFNR = ITORDER-AUFNR
            AND SMBLN = ''.

          "GET DATA REFERENSI MATDOC.
          SELECT DISTINCT SMBLN AS MATDOC
          INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
          FROM MSEG
          WHERE AUFNR = ITORDER-AUFNR
            AND SMBLN NE ''.

          "GET THE LAST MATDOC FOR PRO
          LOOP AT ITREFERENCE.
            DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC .
          ENDLOOP.

          IF ITMATDOC[] IS INITIAL .
            ITORDER-STAT = 'CANCELLED'.
          ELSE.
            ITORDER-STAT = 'POSTED'.
          ENDIF.
        ENDIF.

      ELSEIF ITORDER-STAT CP '*TECO*'.
        IF ITORDER-STAT NP '*GMPS*'.
          ITORDER-STAT = 'TECO'.
        ELSEIF ITORDER-STAT CP '*GMPS*'.
          CLEAR : ITMATDOC, ITREFERENCE.
          REFRESH : ITMATDOC, ITREFERENCE.
          "GET DATA MATERIAL DOCUMENT
          SELECT DISTINCT MBLNR AS MATDOC
            MJAHR AS MJAHR
            INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
            FROM MSEG
            WHERE AUFNR = ITORDER-AUFNR
            AND SMBLN = ''.

          "GET DATA REFERENSI MATDOC.
          SELECT DISTINCT SMBLN AS MATDOC
          INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
          FROM MSEG
          WHERE AUFNR = ITORDER-AUFNR
            AND SMBLN NE ''.

          "GET THE LAST MATDOC FOR PRO
          LOOP AT ITREFERENCE.
            DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC.
          ENDLOOP.

          IF ITMATDOC[] IS INITIAL .
            ITORDER-STAT = 'CANCELLED TECO'.
          ELSE.
            ITORDER-STAT = 'POSTED TECO'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF P_STATUS[] IS NOT INITIAL.
        LOOP AT P_STATUS.
          IF P_STATUS-LOW = 'TECO'.
            IF ITORDER-STAT CP '*TECO*'.
              ITORDER-FLAG = 'X'.
            ENDIF.
          ELSEIF P_STATUS-LOW = 'CANCELLED'.
            IF ITORDER-STAT = 'CANCELLED'.
              ITORDER-FLAG = 'X'.
            ENDIF.
          ELSEIF P_STATUS-LOW = 'POSTED'.
            IF ITORDER-STAT = 'POSTED'.
              ITORDER-FLAG = 'X'.
            ENDIF.
          ELSEIF P_STATUS-LOW = 'RELEASED'.
            IF ITORDER-STAT CP '*RELEASED*'.
              ITORDER-FLAG = 'X'.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

      "GET TYPE FILM
      REFRESH ZCHAR.
      CALL FUNCTION 'VB_BATCH_GET_DETAIL'
        EXPORTING
          MATNR              = ITORDER-MATNR
          CHARG              = ITORDER-CHARG
          WERKS              = ITORDER-WERKS
          GET_CLASSIFICATION = 'X'
        TABLES
          CHAR_OF_BATCH      = ZCHAR.

      IF SY-SUBRC <> 0.
      ELSE.

        LOOP AT ZCHAR WHERE ATNAM = 'ZZCODE'.
          ITORDER-ZZTYPE = ZCHAR-ATWTB.
        ENDLOOP.
      ENDIF.

      "HEADER TEXT
      CLEAR V_MBLNR.
      SELECT MAX( MSEG~MBLNR )
        INTO V_MBLNR
        FROM MSEG
        JOIN MKPF ON MKPF~MBLNR = MSEG~MBLNR
        WHERE MSEG~AUFNR = ITORDER-AUFNR
        AND MKPF~XBLNR  NE ''
        AND MSEG~BWART IN ('531', '532').

      SELECT SINGLE MKPF~XBLNR
        INTO ITORDER-BKTXT
        FROM MKPF
        JOIN MSEG ON   MSEG~MBLNR = MKPF~MBLNR
        WHERE MSEG~AUFNR = ITORDER-AUFNR
        AND MSEG~MBLNR = V_MBLNR
        AND MKPF~XBLNR NE ''.

      MODIFY ITORDER.
    ENDLOOP.

    IF P_STATUS[] IS NOT INITIAL.
      DELETE ITORDER WHERE FLAG = ''.
      IF ITORDER[] IS INITIAL.
        MESSAGE 'Tidak ada data.' TYPE 'I'.
      ENDIF.
    ENDIF.
  ENDIF.

  REFRESH CONTROL 'TCORDER' FROM SCREEN '0120'.
ENDFORM.                    " GET_DATAORDER

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
    WHEN 'INSR'.                      "insert row
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                        P_TABLE_NAME.
      CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME.
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.

    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.


  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_INSERT_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_LINES_NAME       LIKE FELD-NAME.
  DATA L_SELLINE          LIKE SY-STEPL.
  DATA L_LASTLINE         TYPE I.
  DATA L_LINE             TYPE I.
  DATA L_TABLE_NAME       LIKE FELD-NAME.
  FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
  ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE L_SELLINE.
  IF SY-SUBRC <> 0.                   " append line to table
    L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
    IF L_SELLINE > <LINES>.
      <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
    ELSE.
      <TC>-TOP_LINE = 1.
    ENDIF.
  ELSE.                               " insert line into table
    L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
    L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE L_LINE.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_DELETE_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME
                       P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    IF <MARK_FIELD> = 'X'.
      DELETE <TABLE> INDEX SYST-TABIX.
      IF SY-SUBRC = 0.
        <TC>-LINES = <TC>-LINES - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                      P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TC_NEW_TOP_LINE     TYPE I.
  DATA L_TC_NAME             LIKE FELD-NAME.
  DATA L_TC_LINES_NAME       LIKE FELD-NAME.
  DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
  IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        ENTRY_ACT      = <TC>-TOP_LINE
        ENTRY_FROM     = 1
        ENTRY_TO       = <TC>-LINES
        LAST_PAGE_FULL = 'X'
        LOOPS          = <LINES>
        OK_CODE        = P_OK
        OVERLAPPING    = 'X'
      IMPORTING
        ENTRY_NEW      = L_TC_NEW_TOP_LINE
      EXCEPTIONS
        OTHERS         = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD L_TC_FIELD_NAME
             AREA  L_TC_NAME.

  IF SYST-SUBRC = 0.
    IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  CREATE_PRO
*&---------------------------------------------------------------------*

FORM F_CREATE_PRO .
  DATA :  CLABS   TYPE LAENG,
          DD      TYPE C LENGTH 2,
          MM      TYPE C LENGTH 2,
          YYYY    TYPE C LENGTH 4,
          DATE    TYPE C LENGTH 8,
          TAMOUNT TYPE MCHB-CLABS,
          QTY TYPE I.

  CLEAR : DD, MM,YYYY, DATE, ITDATA2, ITTEMP, ITMATERIAL.
  REFRESH : ITMATERIAL, ITTEMP.
  ITTEMP[] = ITDATA[].

  YYYY = SY-DATUM+0(4).
  MM = SY-DATUM+4(2).
  DD = SY-DATUM+6(2).
  CONCATENATE DD MM YYYY INTO DATE.

  DELETE ITTEMP WHERE MARK NE 'X'.
  " CEK APAKAH ADA MATERIAL YANG DI-TICK
  CLEAR VLINE.
  DESCRIBE TABLE ITTEMP LINES VLINE.
  IF VLINE = 0.
    MESSAGE 'Anda Belum Memilih Material!' TYPE 'I'.
  ELSE.
    "cek data apakah sudah memiliki PRo
    ITMATERIAL[] =  ITTEMP[].
    DELETE ITMATERIAL WHERE AUFNR = ''.
    CLEAR VLINE.
    DESCRIBE TABLE ITMATERIAL LINES VLINE.

    IF VLINE <> 0 .
      MESSAGE 'Process Order Sudah Ada, Periksa Kembali Line Yang Anda Pilih!' TYPE 'I'.
    ELSE.

      READ TABLE ITTEMP WITH KEY RAR_A_MATNR = ''.
      IF SY-SUBRC = ''.
        MESSAGE 'Raw Recycle tidak ditemukan, periksa kembali batch inputan Anda!' TYPE 'I'.
      ELSE.

        "GET LIST OF MATERIAL AND BATCH
        CLEAR ITMATERIAL.
        REFRESH ITMATERIAL.
        ITMATERIAL[] = ITTEMP[].

        "CHECK QUNTITY NE 0
        CLEAR WADATA.
        READ TABLE ITTEMP INTO WADATA WITH KEY CLABS = 0 .
        IF SY-SUBRC = 0.
          MESSAGE 'Quantity Batch = 0 Periksa Kembali Line Yang Anda Pilih! ' TYPE 'I'.
        ELSE.
          "CHECK SLOC GR
          CLEAR WADATA.
          READ TABLE ITTEMP INTO WADATA WITH KEY SLOCGR = ''.
          IF SY-SUBRC = 0.
            MESSAGE 'Isi Sloc GR Untuk Semua Data Yang Anda Pilih!' TYPE 'I'.
          ELSE.

            CLEAR WADATA.
            READ TABLE ITTEMP INTO WADATA WITH KEY SLOCGI = ''.
            IF SY-SUBRC = 0.
              MESSAGE 'Isi Sloc GI Untuk Semua Data Yang Anda Pilih!' TYPE 'I'.
            ELSE.
              "cek quantity
              CLEAR :  IS_ERROR,WADATA.
              LOOP AT ITTEMP INTO WADATA.
                IF WADATA-CLABS > WADATA-CCLABS.
                  IS_ERROR = 'X'.
                ENDIF.
              ENDLOOP.

              IF IS_ERROR = 'X'.
                CLEAR MESSAGE.
                CONCATENATE 'Quantity Process Order' WADATA-AUFNR 'lebih besar dari quantity stock!' INTO MESSAGE SEPARATED BY SPACE.
                MESSAGE MESSAGE TYPE 'I'.
              ELSE.

                SORT ITTEMP BY MATNR RAR_A_MATNR.
                DELETE ADJACENT DUPLICATES FROM ITTEMP COMPARING MATNR RAR_A_MATNR.

                LOOP AT ITTEMP.
                  IF ITTEMP-SLOCGI NOT IN R_SLOC.
                    CLEAR MESSAGE.
                    CONCATENATE 'Periksa kembali SLoc GI' ITTEMP-AUFNR '!' INTO MESSAGE SEPARATED BY SPACE.
                    MESSAGE MESSAGE TYPE 'I'.
                  ELSE.

                    "GET TOTAL AMOUNT OF EACH MATERIAL-RAW RECYCLE
                    CLEAR : TAMOUNT, QTY, TORDER,ORDERO, IT_BDCDATA ,IT_BDCMSGCOLL, TAMOUNT, QTY .
                    REFRESH : IT_BDCDATA ,IT_BDCMSGCOLL .
                    LOOP AT ITMATERIAL WHERE MATNR = ITTEMP-MATNR AND RAR_A_MATNR = ITTEMP-RAR_A_MATNR.
                      TAMOUNT = TAMOUNT + ITMATERIAL-CLABS.
                      QTY     = QTY + 1.
                    ENDLOOP.

                    "FILL DATA TORDER
                    TORDER-MATERIAL = ITTEMP-MATNR.
                    TORDER-PLANT    = P_PLANT-LOW.

                    CASE P_PLANT-LOW.
                      WHEN '1000'.
                        TORDER-ORDER_TYPE = 'ZRR1'.
                      WHEN '2000'.
                        TORDER-ORDER_TYPE = 'ZRR2'.
                      WHEN 'TTA2'.
                        TORDER-ORDER_TYPE = 'ZRR2'. " ADD NEW COMPANY
                      WHEN 'TTE'.
                        TORDER-ORDER_TYPE = 'ZRR2'. " ADD NEW COMPANY
                    ENDCASE.

                    TORDER-BASIC_START_DATE = P_DATE.
                    TORDER-BASIC_END_DATE = P_DATE.
                    TORDER-QUANTITY = TAMOUNT.
                    TORDER-PROD_VERSION = '0003'.

                    "CALL BAPI CREATE PROCORD
                    CALL FUNCTION 'BAPI_PROCORD_CREATE'
                      EXPORTING
                        ORDERDATA    = TORDER
                      IMPORTING
                        RETURN       = IT_RET
                        ORDER_NUMBER = ORDERO.

                    LS_SUBRC = 0.
                    LOOP AT IT_RET.
                      IF IT_RET-TYPE EQ 'E'.
                        WRITE:/ IT_RET-MESSAGE.
                      ENDIF.

                      IF IT_RET-TYPE EQ 'E' AND LS_SUBRC EQ 0.
                        LS_SUBRC = 1.
                      ENDIF.
                    ENDLOOP.

                    "JIKA BAPI ME-RETURN ERROR MESSAGE
                    IF LS_SUBRC <> 0.
                      MESSAGE 'Create Process Order Gagal!' TYPE 'I'.
                      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                    ELSE.
                      IF ORDERO = ''.
                        MESSAGE 'Create Process Order Gagal!' TYPE 'I'.
                        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                      ELSE.
                        COMMIT WORK AND WAIT.
                        PERFORM  PROCESS_DELAYING .

                        "PERFORM BDC COR2
                        PERFORM BDC_DYNPRO      USING 'SAPLCOKO'      '5110'.
                        PERFORM BDC_FIELD       USING 'BDC_CURSOR'    'CAUFVD-AUFNR'.
                        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '/00'.
                        PERFORM BDC_FIELD       USING 'CAUFVD-AUFNR'  ORDERO .

                        PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
                        PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=KOMG'.
                        PERFORM BDC_FIELD       USING 'BDC_CURSOR' 'CAUFVD-GAMNG'.
                        CLEAR VCLABS.
                        MOVE  QTY TO VCLABS.
                        PERFORM BDC_FIELD       USING 'CAUFVD-GAMNG'  VCLABS.

                        "QTY STOCK
                        CLEAR VCLABS.
                        MOVE TAMOUNT TO VCLABS.
                        PERFORM BDC_FIELD       USING 'CAUFVD-BMENGE' VCLABS.
                        PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '0133'.
                        PERFORM BDC_FIELD       USING 'BDC_CURSOR' 'CAUFVD-BMENGE'.
                        "QTY BATCH
                        PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=ENT1'.
                        CLEAR VCLABS.
                        MOVE  QTY TO VCLABS.
                        PERFORM BDC_FIELD       USING 'CAUFVD-GAMNG'  VCLABS.

                        "QTY STOCK
                        CLEAR VCLABS.
                        MOVE TAMOUNT TO VCLABS.
                        PERFORM BDC_FIELD       USING 'CAUFVD-BMENGE' VCLABS.

                        PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
                        PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=OMLA'.
                        CLEAR VCLABS.
                        MOVE  QTY TO VCLABS.
                        PERFORM BDC_FIELD       USING 'CAUFVD-GAMNG'  VCLABS.

                        "QTY STOCK
                        CLEAR VCLABS.
                        MOVE TAMOUNT TO VCLABS.
                        PERFORM BDC_FIELD       USING 'CAUFVD-BMENGE' VCLABS.
                        PERFORM BDC_DYNPRO      USING 'SAPLCOMK'      '5120'.
                        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '/00'.

                        CLEAR : COUNTER.
                        LOOP AT ITMATERIAL WHERE MATNR = ITTEMP-MATNR AND RAR_A_MATNR = ITTEMP-RAR_A_MATNR..
                          CLEAR : N, VMATNR,VMENGE,VPOSTP,VLGORT,VCHARG,VVORNR.
                          COUNTER  = COUNTER + 1.

                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                            EXPORTING
                              INPUT  = ITMATERIAL-CHARG
                            IMPORTING
                              OUTPUT = ITMATERIAL-CHARG.

                          N = COUNTER .
                          SHIFT N LEFT DELETING LEADING ''.
                          IF COUNTER < 10.
                            CONCATENATE CMATNR '(0' N ')' INTO VMATNR.
                            CONCATENATE CMENGE '(0' N ')' INTO VMENGE.
                            CONCATENATE CPOSTP '(0' N ')' INTO VPOSTP.
                            CONCATENATE CLGORT '(0' N ')' INTO VLGORT.
                            CONCATENATE CCHARG '(0' N ')' INTO VCHARG.
                            CONCATENATE CVORNR '(0' N ')' INTO VVORNR.
                            CONCATENATE CEINHEIT '(0' N ')' INTO VEINHEIT.
                          ELSE.
                            CONCATENATE CMATNR '(' N ')' INTO VMATNR.
                            CONCATENATE CMENGE '(' N ')' INTO VMENGE.
                            CONCATENATE CPOSTP '(' N ')' INTO VPOSTP.
                            CONCATENATE CLGORT '(' N ')' INTO VLGORT.
                            CONCATENATE CCHARG '(' N ')' INTO VCHARG.
                            CONCATENATE CVORNR '(' N ')' INTO VVORNR.
                            CONCATENATE CEINHEIT '(' N ')' INTO VEINHEIT.
                          ENDIF.

                          PERFORM BDC_FIELD       USING VMATNR ITMATERIAL-MATNR.
                          CLEAR VCLABS.
                          MOVE ITMATERIAL-CLABS TO VCLABS.
                          PERFORM BDC_FIELD       USING VMENGE VCLABS.
                          PERFORM BDC_FIELD       USING VEINHEIT 'KG'.

                          "CEK ITEM DARI ITTEMP.
                          PERFORM BDC_FIELD       USING VPOSTP 'L'.
                          PERFORM BDC_FIELD       USING VLGORT ITMATERIAL-SLOCGI.
                          PERFORM BDC_FIELD       USING VCHARG ITMATERIAL-CHARG.
                          PERFORM BDC_FIELD       USING VVORNR '0010'.
                        ENDLOOP.

                        COUNTER = COUNTER + 1.
                        CLEAR N.
                        N = COUNTER .
                        SHIFT N LEFT DELETING LEADING ''.
                        IF COUNTER < 10.
                          CONCATENATE CMATNR '(0' N ')' INTO VMATNR.
                          CONCATENATE CMENGE '(0' N ')' INTO VMENGE.
                          CONCATENATE CPOSTP '(0' N ')' INTO VPOSTP.
                          CONCATENATE CLGORT '(0' N ')' INTO VLGORT.
                          CONCATENATE CCHARG '(0' N ')' INTO VCHARG.
                          CONCATENATE CVORNR '(0' N ')' INTO VVORNR.
                        ELSE.
                          CONCATENATE CMATNR '(' N ')' INTO VMATNR.
                          CONCATENATE CMENGE '(' N ')' INTO VMENGE.
                          CONCATENATE CPOSTP '(' N ')' INTO VPOSTP.
                          CONCATENATE CLGORT '(' N ')' INTO VLGORT.
                          CONCATENATE CCHARG '(' N ')' INTO VCHARG.
                          CONCATENATE CVORNR '(' N ')' INTO VVORNR.
                        ENDIF.

                        CLEAR : CLABS, VCLABS.
                        CLABS = TAMOUNT * ( -1 ).
                        MOVE CLABS TO VCLABS.
                        PERFORM BDC_FIELD       USING VMATNR ITTEMP-RAR_A_MATNR.
                        PERFORM BDC_FIELD       USING VMENGE VCLABS.
                        PERFORM BDC_FIELD       USING VEINHEIT 'KG'.
                        PERFORM BDC_FIELD       USING VPOSTP 'L'.
                        PERFORM BDC_FIELD       USING VLGORT ITTEMP-SLOCGR.
                        PERFORM BDC_FIELD       USING VVORNR '0010'.

                        CLEAR VLINE.
                        VLINE = QTY + 1.

                        DO VLINE TIMES.
                          PERFORM BDC_DYNPRO      USING 'SAPLCOMD'   '5100'.
                          PERFORM BDC_FIELD       USING 'BDC_OKCODE' '/00'.
                        ENDDO.

                        PERFORM BDC_DYNPRO      USING 'SAPLCOMK'   '5120'.
                        PERFORM BDC_FIELD       USING 'BDC_CURSOR' 'RESBD-POSNR(01)'.
                        PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=FREI'.
                        PERFORM BDC_DYNPRO      USING 'SAPLCOMK'   '5120'.
                        PERFORM BDC_FIELD       USING 'BDC_CURSOR' 'RESBD-POSNR(01)'.
                        PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=BU'.

                        CALL TRANSACTION 'COR2' USING IT_BDCDATA
                          MODE 'E'
                          UPDATE 'S'
                          MESSAGES INTO IT_BDCMSGCOLL.

                        IF LS_SUBRC NE 0.
                          MESSAGE 'Create Process Order Gagal!' TYPE 'I'.
                          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                        ELSE.

*                 REFRESH DATA IN TABLE CONTROL.
                          COMMIT WORK AND WAIT.
                          LOOP AT ITMATERIAL WHERE MATNR = ITTEMP-MATNR AND RAR_A_MATNR = ITTEMP-RAR_A_MATNR.
                            LOOP AT ITDATA WHERE MATNR = ITMATERIAL-MATNR AND RAR_A_MATNR = ITTEMP-RAR_A_MATNR AND  CHARG = ITMATERIAL-CHARG.
                              "-GET OBJECT NUMBER OF ORDER
                              ITDATA-AUFNR = ORDERO.
                              CLEAR OBJNR.
                              SELECT SINGLE AUFK~OBJNR
                                INTO OBJNR
                                FROM AUFK
                                WHERE AUFK~AUFNR = ITDATA-AUFNR.

*                      -GET STATUS ORDER
                              CALL FUNCTION 'AIP9_STATUS_READ'
                                EXPORTING
                                  I_OBJNR = OBJNR
                                IMPORTING
                                  E_SYSST = ITDATA-STATUS.

                              IF SY-SUBRC <> 0.
                                MESSAGE 'Status Process Order Tidak Ditemukan' TYPE  'I'.
                              ENDIF.

                              IF ITDATA-STATUS NP '*GMPS*'.
                                ITDATA-STATUS = 'Created'.
                              ENDIF.

                              "MODIFY QUANTITY
                              SELECT SINGLE AFKO~BMENGE
                                FROM AFKO
                                INTO ITDATA-CLABS
                                WHERE AFKO~AUFNR = ITDATA-AUFNR.

                              MODIFY ITDATA.
                            ENDLOOP.
                          ENDLOOP.
                          CLEAR MESSAGE.
                          CONCATENATE 'Create Process Order' ORDERO 'Berhasil!' INTO MESSAGE SEPARATED BY SPACE.
                          MESSAGE MESSAGE TYPE 'I'.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
*           ADD BY JARWO
                IF ITDATA[] IS NOT INITIAL.
                  PERFORM SUBMIT_TO_PROGRAM TABLES ITDATA[].
                  PERFORM SUBMIT_BATCH TABLES ITDATA[].
                ENDIF.
*           Add By Jarwo
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        REFRESH CONTROL 'TABCCTL' FROM SCREEN '0110'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CREATE_PRO


*&---------------------------------------------------------------------*
*&      Form  TECO
*&---------------------------------------------------------------------*

FORM F_TECO .
*  CLEAR : ITDATA2, ITMATERIAL, ITTEMP, IT_RET, TORDERKEY.
  REFRESH : ITDATA2, ITMATERIAL, ITTEMP, IT_RET, TORDERKEY.

  ITTEMP[] = ITDATA[].
  DELETE ITTEMP WHERE MARK NE 'X'.

  IF ITTEMP[] IS INITIAL. "1
    MESSAGE 'Please select any Material!' TYPE 'I'.
  ELSE.
    ITMATERIAL[] = ITTEMP[].
    CLEAR WADATA.
    READ TABLE ITMATERIAL INTO WADATA WITH KEY AUFNR = ''.
    IF SY-SUBRC = 0.
      MESSAGE 'Process Order Tidak Ada, Periksa Kembali Line Yang Anda Pilih!' TYPE 'I'.
    ELSE.

      SORT ITTEMP BY AUFNR.
      DELETE ADJACENT DUPLICATES FROM ITTEMP COMPARING AUFNR.

      LOOP AT ITTEMP.

        IF ITTEMP-SLOCGI NOT IN R_SLOC.
          CLEAR MESSAGE.
          CONCATENATE 'Periksa kembali SLoc GI' ITTEMP-AUFNR '!' INTO MESSAGE SEPARATED BY SPACE.
          MESSAGE MESSAGE TYPE 'I'.
        ELSE.
          "CEK LOCKING ORDER.
          CLEAR : LOCKLIST, LOCKOBJECT, WLOCKLIST.
          REFRESH : LOCKLIST.
          CALL FUNCTION 'ENQUEUE_READ'
            EXPORTING
              GCLIENT = SY-MANDT
              GNAME   = 'AUFK'
            TABLES
              ENQ     = LOCKLIST.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.

          CONCATENATE SY-MANDT ITTEMP-AUFNR INTO LOCKOBJECT.
          READ TABLE LOCKLIST WITH KEY GARG = LOCKOBJECT INTO WLOCKLIST.

          CLEAR MESSAGE.
          IF SY-SUBRC = 0.
            CONCATENATE 'Process Order' ITTEMP-AUFNR 'di Locked oleh User' WLOCKLIST-GUNAME INTO MESSAGE SEPARATED BY SPACE.
            MESSAGE MESSAGE TYPE 'I'.
          ELSE.

            CLEAR : MSG, ANSWER, VCLABS.
            MOVE ITTEMP-CLABS TO VCLABS.
            CONCATENATE : 'Anda akan melakukan TECO Process Order:' ITTEMP-AUFNR
            'Quantity:' VCLABS  'Batch:' ITTEMP-CHARG
            'dan SLoc Raw Recycle:' ITTEMP-SLOCGR INTO MSG SEPARATED BY SPACE.

            CALL FUNCTION 'POPUP_TO_CONFIRM'
              EXPORTING
                TITLEBAR              = 'Confirmation'
                TEXT_QUESTION         = MSG
                TEXT_BUTTON_1         = 'Ya'
                TEXT_BUTTON_2         = 'Tidak'
                DEFAULT_BUTTON        = '1'
                DISPLAY_CANCEL_BUTTON = ''
              IMPORTING
                ANSWER                = ANSWER.

            IF ANSWER = 2.
            ELSEIF ANSWER  = ''.
            ELSE.

              REFRESH TORDERKEY.

              TORDERKEY-ORDER_NUMBER = ITTEMP-AUFNR.
              APPEND TORDERKEY.

              CLEAR : LS_SUBRC.
              CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
                IMPORTING
                  RETURN = IT_RET
                TABLES
                  ORDERS = TORDERKEY.

              READ TABLE IT_RET WITH KEY  TYPE = 'E'.
              IF SY-SUBRC <> 0.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    WAIT = 'X'.

                CLEAR : MESSAGE.
                CONCATENATE 'TECO Process Order' ITTEMP-AUFNR 'Berhasil!' INTO MESSAGE SEPARATED BY SPACE.
                MESSAGE MESSAGE TYPE 'I'.
              ELSE.
                CLEAR : MESSAGE.
                CONCATENATE 'TECO Process Order' ITTEMP-AUFNR 'Gagal!' INTO MESSAGE SEPARATED BY SPACE.
                MESSAGE MESSAGE TYPE 'I'.
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
              ENDIF.

              LOOP AT ITMATERIAL WHERE AUFNR = ITTEMP-AUFNR.
                LOOP AT ITDATA WHERE MATNR = ITMATERIAL-MATNR AND AUFNR = ITMATERIAL-AUFNR.

                  CLEAR OBJNR.
                  SELECT SINGLE AUFK~OBJNR
                    INTO OBJNR
                    FROM AUFK
                    WHERE AUFK~AUFNR = ITDATA-AUFNR.

                  CALL FUNCTION 'AIP9_STATUS_READ'
                    EXPORTING
                      I_OBJNR = OBJNR
                    IMPORTING
                      E_SYSST = ITDATA-STATUS.

                  IF ITDATA-STATUS CP '*TECO*'.
                    ITDATA-STATUS = 'TECO'.
                    ITDATA-AUFNR = ''.
                    ITDATA-STATUS = ''.
                  ENDIF.

                  SELECT SINGLE MCHB~CLABS AS CLABS
                    INTO ITDATA-CLABS
                    FROM MCHB
                    WHERE MCHB~CHARG = ITDATA-CHARG
                    AND MCHB~WERKS IN  P_PLANT
                    AND MCHB~LGORT = ITDATA-SLOCGI.
                  MODIFY ITDATA.
                ENDLOOP.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
*     ADD BY JARWO
      IF ITTEMP IS NOT INITIAL.
        PERFORM SUBMIT_TO_PROGRAM TABLES ITTEMP[].
      ENDIF.
*     Add By Jarwo
    ENDIF.
    REFRESH CONTROL 'TABCCTL' FROM SCREEN '0110'.
  ENDIF.

ENDFORM.                    " TECO


*&---------------------------------------------------------------------*
*&      Form  F_POSTING
*&---------------------------------------------------------------------*
FORM F_POSTINGGIGR .
  DATA : SLOC TYPE RESB-LGORT,
         QTY TYPE RESB-BDMNG.


  CLEAR   : ITMATERIAL, ITTEMP, IT_RET.
  REFRESH : ITMATERIAL, ITTEMP, IT_RET.

  ITTEMP[] = ITDATA[].
*  get material yang ditick.
  DELETE ITTEMP WHERE MARK NE 'X'.

  " CEK APAKAH ADA MATERIAL YANG DI-TICK
  CLEAR VLINE.
  DESCRIBE TABLE ITTEMP LINES VLINE.

  IF VLINE = 0.  "1
    MESSAGE 'Anda Belum Memilih Material' TYPE 'I'.
  ELSE.

    ITMATERIAL[] = ITTEMP[].
    CLEAR WADATA.
    READ TABLE ITMATERIAL INTO WADATA WITH KEY AUFNR = ''.
    IF SY-SUBRC = 0.
      MESSAGE 'Process Order Tidak Ada, Periksa Kembali Line Yang Anda Pilih!' TYPE 'I'.
    ELSE.
      CLEAR WADATA.
      READ TABLE ITMATERIAL INTO WADATA WITH KEY SLOCGR = ''.
      IF SY-SUBRC = 0.
        MESSAGE 'Isi Sloc GR Untuk Semua Data Yang Anda Pilih!' TYPE 'I'.
      ELSE .

        CLEAR WADATA.
        READ TABLE ITMATERIAL INTO WADATA WITH KEY SLOCGI = ''.
        IF SY-SUBRC = 0.
          MESSAGE 'Isi Sloc GI Untuk Semua Data Yang Anda Pilih!' TYPE 'I'.
        ELSE .

          SORT ITTEMP BY AUFNR.
          DELETE ADJACENT DUPLICATES FROM ITTEMP COMPARING AUFNR.

          LOOP AT ITTEMP.

            IF ITTEMP-SLOCGI NOT IN R_SLOC.
              CLEAR MESSAGE.
              CONCATENATE 'Periksa kembali SLoc GI' ITTEMP-AUFNR '!' INTO MESSAGE SEPARATED BY SPACE.
              MESSAGE MESSAGE TYPE 'I'.
            ELSE.

              "CEK LOCKING ORDER.
              CLEAR : LOCKLIST, LOCKOBJECT, WLOCKLIST.
              REFRESH : LOCKLIST.
              CALL FUNCTION 'ENQUEUE_READ'
                EXPORTING
                  GCLIENT = SY-MANDT
                  GNAME   = 'AUFK'
                TABLES
                  ENQ     = LOCKLIST.
              IF SY-SUBRC <> 0.
* Implement suitable error handling here
              ENDIF.

              CONCATENATE SY-MANDT ITTEMP-AUFNR INTO LOCKOBJECT.
              READ TABLE LOCKLIST WITH KEY GARG = LOCKOBJECT INTO WLOCKLIST.

              IF SY-SUBRC = 0.
                CLEAR MESSAGE.
                CONCATENATE 'Order' ITTEMP-AUFNR 'Di Locked Oleh User' WLOCKLIST-GUNAME INTO MESSAGE SEPARATED BY SPACE.
                MESSAGE MESSAGE TYPE 'I'.
              ELSE.
                CLEAR : MSG, ANSWER, VCLABS.
                MOVE ITTEMP-CLABS TO VCLABS.
                CONCATENATE 'Anda akan melakukan posting GI/GR dengan Process Order:' ITTEMP-AUFNR
                'Quantity:' VCLABS 'Batch:' ITTEMP-CHARG
                'dan SLoc Raw Recycle:' ITTEMP-SLOCGR INTO MSG SEPARATED BY SPACE.

                CALL FUNCTION 'POPUP_TO_CONFIRM'
                  EXPORTING
                    TITLEBAR              = 'Confirmation'
                    TEXT_QUESTION         = MSG
                    TEXT_BUTTON_1         = 'Ya'
                    TEXT_BUTTON_2         = 'Tidak'
                    DEFAULT_BUTTON        = '1'
                    DISPLAY_CANCEL_BUTTON = ''
                  IMPORTING
                    ANSWER                = ANSWER.

                IF ANSWER = 2.
                ELSEIF ANSWER  = ''.
                ELSE.
                  CLEAR : ITMATDOC, ITREFERENCE.
                  REFRESH : ITMATDOC, ITREFERENCE.

                  "GET DATA MATERIAL DOCUMENT
                  SELECT DISTINCT MBLNR AS MATDOC
                    MJAHR AS MJAHR
                    INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
                    FROM MSEG
                    WHERE AUFNR = ITTEMP-AUFNR
                    AND SMBLN = ''.

                  "GET DATA REFERENSI MATDOC.
                  SELECT DISTINCT SMBLN AS MATDOC
                  INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
                  FROM MSEG
                  WHERE AUFNR = ITTEMP-AUFNR
                    AND SMBLN NE ''.

                  "GET THE LAST MATDOC FOR PRO
                  LOOP AT ITREFERENCE.
                    DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC .
                  ENDLOOP.

                  IF ITMATDOC[] IS NOT INITIAL .
                    CLEAR MESSAGE.
                    CONCATENATE 'Process Order' ITTEMP-AUFNR 'sudah diposting GI/GR!' INTO MESSAGE SEPARATED BY SPACE.
                    MESSAGE MESSAGE TYPE 'I'.
                  ELSE.

                    CLEAR : GMHEADER, GMITEM.
                    REFRESH : GMITEM.

                    "FILL  HEADER DATA
                    GMHEADER-PSTNG_DATE = SY-DATUM.
                    GMHEADER-DOC_DATE = SY-DATUM.
                    GMHEADER-REF_DOC_NO = P_NIK.

                    "FILL ITEM DATA
                    LOOP AT ITMATERIAL WHERE AUFNR = ITTEMP-AUFNR.

                      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                        EXPORTING
                          INPUT  = ITMATERIAL-CHARG
                        IMPORTING
                          OUTPUT = ITMATERIAL-CHARG.

                      "get quantity
                      CLEAR : QTY.
                      SELECT SINGLE  BDMNG
                        INTO QTY
                        FROM RESB
                        WHERE AUFNR =  ITMATERIAL-AUFNR
                        AND MATNR   = ITMATERIAL-MATNR
                        AND CHARG   = ITMATERIAL-CHARG.

                      GMITEM-PLANT      = P_PLANT-LOW.
                      GMITEM-BATCH      = ITMATERIAL-CHARG.
                      GMITEM-STGE_LOC   = ITMATERIAL-SLOCGI.
                      GMITEM-WITHDRAWN  = 'X'.
                      GMITEM-MOVE_TYPE  = '261'.
                      GMITEM-ENTRY_UOM  = 'KG'.
                      GMITEM-ORDERID    = ITTEMP-AUFNR.
                      GMITEM-MATERIAL   = ITTEMP-MATNR.
                      GMITEM-ENTRY_QNT  = QTY.
                      APPEND GMITEM.
                    ENDLOOP.

                    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                      EXPORTING
                        GOODSMVT_HEADER  = GMHEADER
                        GOODSMVT_CODE    = '03'
                      IMPORTING
                        MATERIALDOCUMENT = MATDOC
                      TABLES
                        GOODSMVT_ITEM    = GMITEM
                        RETURN           = IT_RET.

                    READ TABLE IT_RET WITH KEY TYPE = 'E'.

                    IF SY-SUBRC = 0.
                      CLEAR MESSAGE.
                      CONCATENATE 'Posting GI/GR' ITTEMP-AUFNR 'Gagal!' INTO MESSAGE SEPARATED BY SPACE.
                      MESSAGE MESSAGE TYPE 'I'.
                      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                    ELSE.
                      IF MATDOC = ''.
                        CLEAR MESSAGE.
                        CONCATENATE 'Posting GI/GR' ITTEMP-AUFNR 'Gagal!' INTO MESSAGE SEPARATED BY SPACE.
                        MESSAGE MESSAGE TYPE 'I'.
                        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                      ELSE.
                        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                          EXPORTING
                            WAIT = 'X'.

                        CLEAR : GMITEM, GMHEADER.
                        REFRESH : GMITEM.
                        GMHEADER-PSTNG_DATE = SY-DATUM.
                        GMHEADER-DOC_DATE = SY-DATUM.
                        GMHEADER-REF_DOC_NO = P_NIK.

                        "FILL ITEM DATA
                        CLEAR : QTY.
                        SELECT SINGLE  BDMNG
                          INTO QTY
                          FROM RESB
                          WHERE AUFNR =  ITTEMP-AUFNR
                          AND MATNR = ITTEMP-RAR_A_MATNR.

                        GMITEM-PLANT = P_PLANT-LOW.
                        GMITEM-STGE_LOC = ITTEMP-SLOCGR.
                        GMITEM-WITHDRAWN = 'X'.
                        GMITEM-ENTRY_UOM = 'KG'.
                        GMITEM-MOVE_TYPE = '531'.
                        GMITEM-ORDERID = ITTEMP-AUFNR.
                        GMITEM-MATERIAL = ITTEMP-RAR_A_MATNR.
                        GMITEM-ENTRY_QNT = QTY.
                        APPEND GMITEM.

                        CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                          EXPORTING
                            GOODSMVT_HEADER  = GMHEADER
                            GOODSMVT_CODE    = '03'
                          IMPORTING
                            MATERIALDOCUMENT = MATDOC
                          TABLES
                            GOODSMVT_ITEM    = GMITEM
                            RETURN           = IT_RET.

                        CLEAR : LS_SUBRC.
                        LOOP AT IT_RET.
                          IF IT_RET-TYPE EQ 'E'.
                            WRITE:/ IT_RET-MESSAGE.
                          ENDIF.

                          IF IT_RET-TYPE EQ 'E' AND LS_SUBRC EQ 0.
                            LS_SUBRC = 1.
                          ENDIF.
                        ENDLOOP.

                        IF LS_SUBRC EQ 0.
                          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                            EXPORTING
                              WAIT = 'X'.

                          CLEAR MESSAGE.
                          CONCATENATE 'Posting GI/GR untuk Process Order' ITTEMP-AUFNR 'sukses!' INTO MESSAGE SEPARATED BY SPACE.
                          MESSAGE MESSAGE TYPE 'I'.
                        ELSE.
                          CLEAR MESSAGE.
                          MESSAGE 'Can not Post PO!' TYPE 'I'.
                          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

                "Refresh data in table control
                LOOP AT ITMATERIAL WHERE AUFNR = ITTEMP-AUFNR.
                  LOOP AT ITDATA WHERE MATNR = ITMATERIAL-MATNR AND CHARG = ITMATERIAL-CHARG AND AUFNR = ITMATERIAL-AUFNR.

                    "CHANGE STATUS ORDER
                    CLEAR : ITMATDOC, ITREFERENCE.
                    REFRESH : ITMATDOC, ITREFERENCE.
                    "GET DATA MATERIAL DOCUMENT
                    SELECT DISTINCT MBLNR AS MATDOC
                      MJAHR AS MJAHR
                      INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
                      FROM MSEG
                      WHERE AUFNR = ITTEMP-AUFNR
                      AND SMBLN = ''.

                    "GET DATA REFERENSI MATDOC.
                    SELECT DISTINCT SMBLN AS MATDOC
                    INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
                    FROM MSEG
                    WHERE AUFNR = ITTEMP-AUFNR
                      AND SMBLN NE ''.

                    "GET THE LAST MATDOC FOR PRO
                    LOOP AT ITREFERENCE.
                      DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC.
                    ENDLOOP.

                    IF ITMATDOC[] IS NOT INITIAL .
                      ITDATA-STATUS = 'Posted'.
                    ENDIF.

                    "MODIFY QUANTITY
                    SELECT SINGLE AFKO~BMENGE
                      FROM AFKO
                      INTO ITDATA-CLABS
                      WHERE AFKO~AUFNR = ITDATA-AUFNR.

                    MODIFY ITDATA.
                  ENDLOOP.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDLOOP.
*         ADD BY JARWO
          IF ITTEMP[] IS NOT INITIAL.
            PERFORM SUBMIT_TO_PROGRAM TABLES ITTEMP[].
            PERFORM SUBMIT_BATCH TABLES ITTEMP[].
          ENDIF.
*         Add By Jarwo
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.


  REFRESH CONTROL 'TABCCTL' FROM SCREEN '0110'.
ENDFORM.                    " F_POSTING


*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_GRGI
*&---------------------------------------------------------------------*
FORM F_CANCEL_GRGI .
  REFRESH : ITDATA2, ITMATERIAL, ITTEMP, IT_RET, GMITEM.
  CLEAR : ITDATA2, ITMATERIAL, ITTEMP, IT_RET, GMITEM, GMHEADER.

  ITTEMP[] = ITDATA[].

  DELETE ITTEMP WHERE MARK NE 'X'.
  ITMATERIAL[] = ITTEMP[].

  DELETE ITTEMP WHERE MARK NE 'X'.
  IF ITTEMP[] IS INITIAL.
    CLEAR MESSAGE.
    MESSAGE 'Anda Belum Memilih Material!' TYPE 'I'.
  ELSE. "1
    ITMATERIAL[] = ITTEMP[].
    CLEAR WADATA.
    READ TABLE ITMATERIAL INTO WADATA WITH KEY AUFNR = ''.
    IF SY-SUBRC = 0.
      CLEAR MESSAGE.
      MESSAGE 'Process Order Tidak Ada, Periksa Kembali Line Yang Anda Pilih!' TYPE 'I'.
    ELSE.

      SORT ITTEMP BY AUFNR.
      DELETE ADJACENT DUPLICATES FROM ITTEMP COMPARING AUFNR.

      LOOP AT ITTEMP.
        "CEK LOCKING ORDER.
        CLEAR : LOCKLIST, LOCKOBJECT, WLOCKLIST.
        REFRESH : LOCKLIST.
        CALL FUNCTION 'ENQUEUE_READ'
          EXPORTING
            GCLIENT = SY-MANDT
            GNAME   = 'AUFK'
          TABLES
            ENQ     = LOCKLIST.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.

        CONCATENATE SY-MANDT ITTEMP-AUFNR INTO LOCKOBJECT.
        READ TABLE LOCKLIST WITH KEY GARG = LOCKOBJECT INTO WLOCKLIST.

        CLEAR MESSAGE.
        IF SY-SUBRC = 0.
          CLEAR MESSAGE.
          CONCATENATE 'Order' ITTEMP-AUFNR 'Di Locked Oleh User' WLOCKLIST-GUNAME INTO MESSAGE SEPARATED BY SPACE.
          MESSAGE MESSAGE TYPE 'I'.
        ELSE.

          "SEND CONFIRMATION MESSAGE
          CLEAR : MSG, ANSWER, VCLABS.
          MOVE ITTEMP-CLABS TO VCLABS.
          CONCATENATE 'Anda akan melakukan Cancel GI/GR dengan Process Order:' ITTEMP-AUFNR
          'Quantity:' VCLABS 'Batch:' ITTEMP-CHARG
          'dan SLoc Raw Recycle:' ITTEMP-SLOCGR INTO MSG SEPARATED BY SPACE.

          CALL FUNCTION 'POPUP_TO_CONFIRM'
            EXPORTING
              TITLEBAR              = 'Confirmation'
              TEXT_QUESTION         = MSG
              TEXT_BUTTON_1         = 'Ya'
              TEXT_BUTTON_2         = 'Tidak'
              DEFAULT_BUTTON        = '1'
              DISPLAY_CANCEL_BUTTON = ''
            IMPORTING
              ANSWER                = ANSWER.

          IF ANSWER = 1.
            CLEAR : ITMATDOC, ITREFERENCE.
            REFRESH : ITMATDOC, ITREFERENCE.
            "GET DATA MATERIAL DOCUMENT
            SELECT DISTINCT MBLNR AS MATDOC
              MJAHR AS MJAHR
              BWART AS BWART
              INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
              FROM MSEG
              WHERE AUFNR = ITTEMP-AUFNR
              AND SMBLN = ''.

            IF ITMATDOC[] IS INITIAL .
              CLEAR MESSAGE.
              CONCATENATE 'Process Order' ITTEMP-AUFNR 'Belum Diposting GI/GR!' INTO MESSAGE SEPARATED BY SPACE.
              MESSAGE MESSAGE TYPE 'I'.
            ELSE.

              "GET DATA REFERENSI MATDOC.
              SELECT DISTINCT SMBLN AS MATDOC
              INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
              FROM MSEG
              WHERE AUFNR = ITTEMP-AUFNR
                AND SMBLN NE ''.

              "GET THE LAST MATDOC FOR PRO
              LOOP AT ITREFERENCE.
                DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC.
              ENDLOOP.

              IF ITMATDOC[] IS INITIAL .
                CLEAR MESSAGE.
                CONCATENATE 'Process Order' ITTEMP-AUFNR 'sudah dicancel GI/GR!' INTO MESSAGE SEPARATED BY SPACE.
                MESSAGE MESSAGE TYPE 'I'.
              ELSE.
                "CEK STOCK MT GR
                CLEAR VBMENGE.
                SELECT SINGLE MARD~LABST
                  INTO VBMENGE
                  FROM MARD
                  WHERE MARD~MATNR = ITTEMP-RAR_A_MATNR
                  AND MARD~LGORT = ITTEMP-SLOCGR
                  AND MARD~WERKS IN P_PLANT. "add New Company

                IF SY-SUBRC <> 0.
                  MESSAGE 'Stock Raw Recycle Tidak Cukup untuk di-Cancel' TYPE 'I'.
                ELSE.
                  IF VBMENGE < ITTEMP-CLABS.
                    MESSAGE 'Stock Raw Recycle Tidak Cukup untuk di-Cancel' TYPE 'I'.
                  ELSE.

                    SORT ITMATDOC DESCENDING BY MATDOC BWART.
                    LOOP AT ITMATDOC.
                      "CALL BAPI GOODMOVEMENTS CREATE
                      CLEAR : THEADER, IT_RET.
                      REFRESH : THEADER, IT_RET.
                      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
                        EXPORTING
                          MATERIALDOCUMENT    = ITMATDOC-MATDOC
                          MATDOCUMENTYEAR     = ITMATDOC-MJAHR
                          GOODSMVT_PSTNG_DATE = SY-DATUM
                        IMPORTING
                          GOODSMVT_HEADRET    = THEADER
                        TABLES
                          RETURN              = IT_RET.

                      CLEAR : LS_SUBRC.
                      LOOP AT IT_RET.
                        IF IT_RET-TYPE EQ 'E'.
                          WRITE:/ IT_RET-MESSAGE.
                        ENDIF.

                        IF IT_RET-TYPE EQ 'E' AND LS_SUBRC EQ 0.
                          LS_SUBRC = 1.
                        ENDIF.
                      ENDLOOP.

                      IF LS_SUBRC EQ 0.
                        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                          EXPORTING
                            WAIT = 'X'.

                        PERFORM F_SAVE_NIK_CANCEL.
                      ELSE.
                        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                      ENDIF.

                    ENDLOOP.

                    IF LS_SUBRC EQ 0.
                      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                        EXPORTING
                          WAIT = 'X'.

                      CLEAR MESSAGE.
                      CONCATENATE 'Process Order ' ITTEMP-AUFNR 'Berhasil di Cancel!' INTO MESSAGE SEPARATED BY SPACE.
                      MESSAGE MESSAGE TYPE 'I'.
                    ELSE.
                      CLEAR MESSAGE.
                      CONCATENATE 'Process Order' ITTEMP-AUFNR 'Gagal Di Cancel' INTO MESSAGE SEPARATED BY SPACE.
                      MESSAGE MESSAGE TYPE 'I'.
                      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          LOOP AT ITMATERIAL WHERE AUFNR = ITTEMP-AUFNR.
            LOOP AT ITDATA WHERE MATNR = ITMATERIAL-MATNR AND CHARG = ITMATERIAL-CHARG AND AUFNR = ITMATERIAL-AUFNR.

              "CHANGE STATUS ORDER
              CLEAR : ITMATDOC, ITREFERENCE.
              REFRESH : ITMATDOC, ITREFERENCE.
              "GET DATA MATERIAL DOCUMENT
              SELECT DISTINCT MBLNR AS MATDOC
                MJAHR AS MJAHR
                INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
                FROM MSEG
                WHERE AUFNR = ITTEMP-AUFNR
                AND SMBLN = ''.

              "GET DATA REFERENSI MATDOC.
              SELECT DISTINCT SMBLN AS MATDOC
              INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
              FROM MSEG
              WHERE AUFNR = ITTEMP-AUFNR
                AND SMBLN NE ''.

              "GET THE LAST MATDOC FOR PRO
              LOOP AT ITREFERENCE.
                DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC .
              ENDLOOP.

              IF ITMATDOC[] IS INITIAL .
                ITDATA-STATUS = 'Canceled'.
              ENDIF.

              "MODIFY QUANTITY
              SELECT SINGLE AFKO~BMENGE
                           FROM AFKO
                           INTO ITDATA-CLABS
                           WHERE AFKO~AUFNR = ITDATA-AUFNR.

              MODIFY ITDATA.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
*      ADD BY JARWO
      IF ITTEMP[] IS NOT INITIAL.
        PERFORM SUBMIT_TO_PROGRAM TABLES ITTEMP[].
      ENDIF.
*         Add By Jarwo
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CANCEL



*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       BDC Dynpro
*----------------------------------------------------------------------*
FORM BDC_DYNPRO  USING    PROG SCR.

  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.

ENDFORM.                    " BDC_DYNPRO

*  &---------------------------------------------------------------------*
*  &      Form  BDC_FIELD
*  &---------------------------------------------------------------------*
*         BDC FIELD
*  ----------------------------------------------------------------------*

FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  CLEAR_DATA
*&---------------------------------------------------------------------*
FORM CLEAR_DATA .
  CLEAR : ITDATA, ITORDER, P_PLANT,P_BATCH, P_MATNR, P_AUFNR ,P_PERIOD,P_NIK  .
  REFRESH : ITDATA,ITORDER, P_PLANT,P_BATCH, P_MATNR, P_AUFNR ,P_PERIOD.
ENDFORM.                    " CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SALL
*&---------------------------------------------------------------------*
FORM F_SALL .
  LOOP AT ITDATA.
    ITDATA-MARK = 'X'.
    MODIFY ITDATA.
  ENDLOOP.

  REFRESH CONTROL 'TABCCTL' FROM SCREEN '0110'.
ENDFORM.                    " F_SALL


*&---------------------------------------------------------------------*
*&      Form  F_DALL
*&---------------------------------------------------------------------*
FORM F_DALL .
  LOOP AT ITDATA.
    ITDATA-MARK = ''.
    MODIFY ITDATA.
  ENDLOOP.

  REFRESH CONTROL 'TABCCTL' FROM SCREEN '0110'.
ENDFORM.                    " F_DALL

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DELAYING
*&---------------------------------------------------------------------*
FORM PROCESS_DELAYING .
  DATA : X1 TYPE P DECIMALS 4.                              "#EC NEEDED
  DO 80000 TIMES.
    X1 = SQRT( SY-INDEX ) / SQRT( SY-INDEX ).
  ENDDO.
  WAIT UP TO 3 SECONDS. "ADD DELAY TIME
ENDFORM.                    " PROCESS_DELAYING


*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SLOC  text
*----------------------------------------------------------------------*
FORM F_GET_SLOC  USING    P_SLOC.

  CLEAR WSLOC.
  WSLOC-SIGN   = 'I'.
  WSLOC-OPTION = 'EQ'.
  WSLOC-LOW    = P_SLOC.
  APPEND WSLOC TO RSLOC.
ENDFORM.                    " F_GET_SLOC


*&---------------------------------------------------------------------*
*&      Form  F_RTECO
*&---------------------------------------------------------------------*
FORM F_RTECO .
  REFRESH : TEMPORDER, TEMPORDER2.

  DATA : VSTAT    LIKE BSVX-STTXT.

  TEMPORDER[] = ITORDER[].

  IF TEMPORDER[] IS INITIAL.
    MESSAGE 'Tidak ada data yang akan diproses.' TYPE 'I'.
  ELSE.

    DELETE TEMPORDER WHERE MARK NE 'X'.

    IF TEMPORDER[] IS INITIAL.
      MESSAGE 'Pilih data terlebih dahulu.' TYPE 'I'.
    ELSE.

      SORT TEMPORDER BY AUFNR.
      DELETE ADJACENT DUPLICATES FROM TEMPORDER COMPARING AUFNR.

      CLEAR IS_ERROR.
      LOOP AT TEMPORDER WHERE STAT NP '*TECO*'.
        IS_ERROR = 'X'.
      ENDLOOP.

      IF IS_ERROR = 'X'.
        MESSAGE 'Periksa kembali data yang anda input, status Process Order belum TECO' TYPE 'I'.
      ELSE.

        LOOP AT TEMPORDER.
          REFRESH : IT_BDCDATA , IT_BDCMSGCOLL.

          PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5110'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'CAUFVD-AUFNR'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM BDC_FIELD       USING 'CAUFVD-AUFNR'
                                        TEMPORDER-AUFNR.
          PERFORM BDC_FIELD       USING 'R62CLORD-FLG_COMPL'
                                        'X'.
          PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=TABR'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'CAUFVD-GAMNG'.
          PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=BU'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'CAUFVD-GAMNG'.


          CALL TRANSACTION 'COR2' USING IT_BDCDATA
                        MODE 'E'
                        UPDATE 'S'
                        MESSAGES INTO IT_BDCMSGCOLL.


          READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.
          IF SY-SUBRC <> 0.

            CLEAR MESSAGE.
            CONCATENATE 'Process Order' TEMPORDER-AUFNR 'berhasil di-revoke.' INTO MESSAGE SEPARATED BY SPACE.
            MESSAGE MESSAGE TYPE 'I'.
            COMMIT WORK AND WAIT.

            LOOP AT ITORDER WHERE AUFNR = TEMPORDER-AUFNR.
              "GET STATUS ORDER
              CALL FUNCTION 'AIP9_STATUS_READ'
                EXPORTING
                  I_OBJNR = ITORDER-OBJNR
                  I_SPRAS = SY-LANGU
                IMPORTING
                  E_SYSST = ITORDER-STAT.

              IF ITORDER-STAT NP '*TECO*'.
                IF ITORDER-STAT NP '*GMPS*'.
                  ITORDER-STAT = 'RELEASED'.
                ELSEIF ITORDER-STAT CP '*GMPS*'.
                  CLEAR : ITMATDOC, ITREFERENCE.
                  REFRESH : ITMATDOC, ITREFERENCE.
                  "GET DATA MATERIAL DOCUMENT
                  SELECT DISTINCT MBLNR AS MATDOC
                    MJAHR AS MJAHR
                    INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
                    FROM MSEG
                    WHERE AUFNR = ITORDER-AUFNR
                    AND SMBLN = ''.

                  "GET DATA REFERENSI MATDOC.
                  SELECT DISTINCT SMBLN AS MATDOC
                  INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
                  FROM MSEG
                  WHERE AUFNR = ITORDER-AUFNR
                    AND SMBLN NE ''.

                  "GET THE LAST MATDOC FOR PRO
                  LOOP AT ITREFERENCE.
                    DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC.
                  ENDLOOP.

                  IF ITMATDOC[] IS INITIAL .
                    ITORDER-STAT = 'CANCELLED'.
                  ELSE.
                    ITORDER-STAT = 'POSTED'.
                  ENDIF.
                ENDIF.

              ELSEIF ITORDER-STAT CP '*TECO*'.
                IF ITORDER-STAT NP '*GMPS*'.
                  ITORDER-STAT = 'TECO'.
                ELSEIF ITORDER-STAT CP '*GMPS*'.
                  CLEAR : ITMATDOC, ITREFERENCE.
                  REFRESH : ITMATDOC, ITREFERENCE.
                  "GET DATA MATERIAL DOCUMENT
                  SELECT DISTINCT MBLNR AS MATDOC
                    MJAHR AS MJAHR
                    INTO CORRESPONDING FIELDS OF TABLE ITMATDOC
                    FROM MSEG
                    WHERE AUFNR = ITORDER-AUFNR
                    AND SMBLN = ''.

                  "GET DATA REFERENSI MATDOC.
                  SELECT DISTINCT SMBLN AS MATDOC
                  INTO CORRESPONDING FIELDS OF TABLE ITREFERENCE
                  FROM MSEG
                  WHERE AUFNR = ITORDER-AUFNR
                    AND SMBLN NE ''.

                  "GET THE LAST MATDOC FOR PRO
                  LOOP AT ITREFERENCE.
                    DELETE ITMATDOC WHERE MATDOC = ITREFERENCE-MATDOC.
                  ENDLOOP.

                  IF ITMATDOC[] IS INITIAL .
                    ITORDER-STAT = 'CANCELLED TECO'.
                  ELSE.
                    ITORDER-STAT = 'POSTED TECO'.
                  ENDIF.
                ENDIF.
              ENDIF.
              MODIFY ITORDER.
            ENDLOOP.

          ELSE.
            CLEAR MESSAGE.
            CONCATENATE 'Process Order' TEMPORDER-AUFNR 'gagal di-revoke.' INTO MESSAGE SEPARATED BY SPACE.
            MESSAGE MESSAGE TYPE 'I'.
          ENDIF.
          MODIFY TEMPORDER.
        ENDLOOP.
*        ADD BY JARWO
        IF TEMPORDER[] IS NOT INITIAL.
          LOOP AT TEMPORDER.
            MOVE-CORRESPONDING TEMPORDER TO ITDATA.
            APPEND ITDATA.
          ENDLOOP.

          PERFORM SUBMIT_TO_PROGRAM TABLES ITDATA[].
        ENDIF.
*           Add By Jarwo

        REFRESH CONTROL 'TCORDER'FROM SCREEN '0120'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RTECO


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAYDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DISPLAYDATA .

  IF ITORDER[] IS INITIAL.
    MESSAGE 'Tidak ada data.' TYPE 'I' DISPLAY LIKE 'W'.
  ELSE.
    PERFORM F_FIELD_CATALOG.
    PERFORM F_LAYOUT.
    PERFORM F_LIST_DETAIL.
  ENDIF.


ENDFORM.                    " F_DISPLAYDATA


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
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITORDER' :
    'MATNR'   '' ''  '' ''  'Material Kupas'       '' ' ' '' '',
    'CHARG'   '' ''  '' ''  'Batch GI'    '' ' ' '' '',
    'ZZTYPE'   '' ''  '' ''  'Tipe Film'   '' ' ' '' '',
    'AUFNR'  '' ''  '' ''  'Process Order'      '' ' ' '' '',
    'BMENGE'  '' ''  '' ''  'Quantity'      '' ' ' '' '',
    'LGORTGI'  '' ''  '' ''  'SLoc GI'      '' ' ' '' '',
    'LGORTGR'  '' ''  '' ''  'SLoc GR'      '' ' ' '' '',
    'RAWM'  '' ''  '' ''  'Raw Recycle'      '' ' ' '' '',
    'STAT'  '' ''  '' ''  'Status'      '' ' ' '' '',
    'BKTXT'  '' ''  '' ''  'NIK'      '' ' ' '' ''.

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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = ''
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
      T_OUTTAB                 = ITORDER
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  DATA ITAB_EXCLUDE TYPE TABLE OF SY-UCOMM.

  APPEND '&XXL' TO ITAB_EXCLUDE.


  SET PF-STATUS 'PF1000' EXCLUDING ITAB_EXCLUDE.
ENDFORM.                    " F_GUI_STATUS



*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_NIK CHANGING P_L_ERRNO.
  DATA : VPERNR TYPE PA0001-PERNR.
  CLEAR : VPERNR, P_L_ERRNO.

  "cek nik
  SELECT SINGLE PA0001~PERNR
    FROM PA0001
    INTO VPERNR
    WHERE PA0001~PERNR = P_NIK.

  IF SY-SUBRC <> 0.
    P_L_ERRNO = -1.
    CLEAR MESSAGE.
    MESSAGE =  'NIK Salah!' .
  ENDIF.

ENDFORM.                    " F_CHECK_NIK


*&---------------------------------------------------------------------*
*&      Form  F_SAVE_NIK_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SAVE_NIK_CANCEL .
  REFRESH : IT_BDCDATA , IT_BDCMSGCOLL.

  PERFORM BDC_DYNPRO      USING 'SAPMM07M' '0460'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RM07M-MBLNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=KK'.
  PERFORM BDC_FIELD       USING 'RM07M-MBLNR'
                                THEADER-MAT_DOC.
  PERFORM BDC_FIELD       USING 'RM07M-MJAHR'
                                THEADER-DOC_YEAR.

  PERFORM BDC_DYNPRO      USING 'SAPMM07M' '0490'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RM07M-MTSNR'. "'MKPF-XBLNR'. "change New company
  "'MKPF-BKTXT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.


  PERFORM BDC_FIELD       USING 'RM07M-MTSNR' "'MKPF-XBLNR' "change New company
                                P_NIK.

  CALL TRANSACTION 'MB02' USING IT_BDCDATA
                        MODE 'E'
                        UPDATE 'S'
                        MESSAGES INTO IT_BDCMSGCOLL.

  READ TABLE IT_BDCMSGCOLL WITH KEY MSGTYP = 'E'.

  IF SY-SUBRC <> 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.                    " F_SAVE_NIK_CANCEL


*&---------------------------------------------------------------------*
*&      Form  F_INITIAL_SLOC_GI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_INITIAL_SLOC_GI .
  REFRESH R_SLOC.
  CLEAR W_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1P01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1P02'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1P03'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2P01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2P02'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2P03'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1A01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1Z01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1Z02'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2A01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z02'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z03'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2L01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2R01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2T02'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2S01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2T01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2E02'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2E01'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1802'.
  APPEND W_SLOC TO R_SLOC.


  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2802'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '3802'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2A02'.
  APPEND W_SLOC TO R_SLOC.

  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z0A'.
  APPEND W_SLOC TO R_SLOC.

  "Add Sloc GI METZ 7 & 8
  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z0B'.
  APPEND W_SLOC TO R_SLOC.

  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z0C'.
  APPEND W_SLOC TO R_SLOC.


  CLEAR W_SLOC.             "Add by Afir Sloc METZ 9,10,11
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z0D'.
  APPEND W_SLOC TO R_SLOC.

  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z0E'.
  APPEND W_SLOC TO R_SLOC.

  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2Z0F'.
  APPEND W_SLOC TO R_SLOC. "End Add by Afir Sloc METZ 9,10,11

  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2X01'.
  APPEND W_SLOC TO R_SLOC.      "ADDED EXLAM 11.01.2019 - ADD SLOC JR EXLAM NA 2X01

  " Added by William at 24.07.2022 (OPP7 CPP1)
  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2C01'.
  APPEND W_SLOC TO R_SLOC.

  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '2P04'.
  APPEND W_SLOC TO R_SLOC.
  " End added by William at 24.07.2022 (OPP7 CPP1)

  "Added by Dila at 11.02.2024 (Laminator #2 #3)
  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1L0A'.
  APPEND W_SLOC TO R_SLOC.

  CLEAR W_SLOC.
  W_SLOC-SIGN   = 'I'.
  W_SLOC-OPTION = 'EQ'.
  W_SLOC-LOW    = '1L0B'.
  APPEND W_SLOC TO R_SLOC.
  " End added by Dila at 11.02.2024 (Laminator #2 #3)

ENDFORM.                    " F_INITIAL_SLOC_GI

*&---------------------------------------------------------------------*
*&      Form  SUBMIT_TO_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUBMIT_TO_PROGRAM TABLES P_AUFNR LIKE ITDATA[].
  RANGES:  R_AUFNR FOR RESB-AUFNR.
  CLEAR: R_AUFNR. REFRESH: R_AUFNR.

  IF P_AUFNR[] IS NOT INITIAL.
    LOOP AT P_AUFNR.
      R_AUFNR-SIGN = 'I'.
      R_AUFNR-OPTION = 'EQ'.
      R_AUFNR-LOW = P_AUFNR-AUFNR.
      APPEND R_AUFNR.
      CLEAR R_AUFNR.
    ENDLOOP.

    SUBMIT ZTPPR_PRO_RAW_RECYCLE WITH S_AUFNR IN R_AUFNR AND RETURN.
  ENDIF.

ENDFORM.                    "TO_PROGRAM

*&---------------------------------------------------------------------*
*&      Form  SUBMIT_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BATCH    text
*----------------------------------------------------------------------*
FORM SUBMIT_BATCH TABLES P_BATCH LIKE ITDATA[].
  RANGES: R_BATCH FOR MCHB-CHARG.
  CLEAR: R_BATCH. REFRESH R_BATCH.

  IF P_BATCH[] IS NOT INITIAL.
    LOOP AT P_BATCH.
      R_BATCH-SIGN = 'I'.
      R_BATCH-OPTION = 'EQ'.
      R_BATCH-LOW = P_BATCH-CHARG.
      APPEND R_BATCH.
      CLEAR R_BATCH.
    ENDLOOP.

    SUBMIT ZTPPR_NEW_LIST_JR WITH S_CHARG IN R_BATCH AND RETURN.
  ENDIF.
ENDFORM.                    "SUBMIT_BATCH