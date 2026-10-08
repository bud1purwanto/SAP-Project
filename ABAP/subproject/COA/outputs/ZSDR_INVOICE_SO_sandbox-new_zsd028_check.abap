*&---------------------------------------------------------------------*
*& Report  ZSDR_INVOICE_SO
*&---------------------------------------------------------------------*
*&  Project : IT-Inventory
*&  Created On: 22-10-2019
*&---------------------------------------------------------------------*

REPORT  ZSDR_INVOICE_SO.

TABLES: VBAK, VBAP, TLINE, KNA1, DBCON.

DATA: BEGIN OF IT_DATA OCCURS 0,
      VBELN LIKE VBAP-VBELN, "Sales Order
      POSNR LIKE VBAP-POSNR, "Sales Order Item
      KUNNR LIKE VBAK-KUNNR, "Customer Number
      NAME1 LIKE KNA1-NAME1, "Customer Name
      MATNR LIKE VBAP-MATNR, "Material
      ARKTX LIKE VBAP-ARKTX, "Material Description
      KWMENG LIKE VBAP-KWMENG, "Qty Sales
      VRKME LIKE VBAP-VRKME, "Qty Une
      NTGEW LIKE VBAP-NTGEW, "Qty
      GEWEI LIKE VBAP-GEWEI, "Qty Kg
      PINO LIKE TLINE-TDLINE, "PI No.
          BOX(1),
  END OF IT_DATA.

DATA: BEGIN OF IT_CUSTOMER OCCURS 0,
      KUNNR LIKE KNA1-KUNNR,
      NAME1 LIKE KNA1-NAME1,
  END OF IT_CUSTOMER.

DATA: BEGIN OF IT_TEXT OCCURS 0,
      PINO LIKE TLINE-TDLINE,
  END OF IT_TEXT.

DATA: VVBELN TYPE THEAD-TDNAME,
      PINO TYPE TLINE-TDLINE,
      V_MSG(100).

DATA: IT_LINE TYPE TLINE OCCURS 0 WITH HEADER LINE.

DATA: GV_SQL_CONNECTED TYPE C, " Added by William at 28.09.2026 (track secondary SQL connection)
      GV_OLAP_AUTHORIZED TYPE C,
      GV_TOTAL TYPE I, " Added by William at 28.09.2026 (track SQL transfer progress)
      GV_INSERTED TYPE I, " Added by William at 28.09.2026 (track SQL transfer progress)
      GV_PROGRESS_INTERVAL TYPE I, " Added by William at 28.09.2026 (track SQL transfer progress)
      GV_PERCENTAGE TYPE I. " Added by William at 28.09.2026 (track SQL transfer progress)


SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS :
                S_MATNR FOR VBAP-MATNR NO INTERVALS,
                S_WERKS FOR VBAP-WERKS NO INTERVALS OBLIGATORY, "Add new company
                S_MATKL FOR VBAP-MATKL NO INTERVALS,
                S_VBELN FOR VBAP-VBELN NO INTERVALS,
                S_POSNR FOR VBAP-POSNR NO INTERVALS,
                S_ERDAT FOR VBAP-ERDAT, " Modified by William at 28.09.2026 (allow SO creation date range)
                S_KUNNR FOR VBAK-KUNNR NO INTERVALS,
                S_PINO FOR TLINE-TDLINE NO INTERVALS.
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_SCREEN RADIOBUTTON GROUP DEST DEFAULT 'X' USER-COMMAND DST MODIF ID OUT. " Added by William at 28.09.2026 (add Output card authorization)
PARAMETERS P_OLAP RADIOBUTTON GROUP DEST MODIF ID OUT. " Added by William at 28.09.2026 (add Output card authorization)
SELECTION-SCREEN END OF BLOCK BLOCK2.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-003.
PARAMETERS P_CONN LIKE DBCON-CON_NAME MODIF ID CON. " Added by William at 28.09.2026 (SQL secondary connection input)
SELECTION-SCREEN END OF BLOCK BLOCK3.

DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      IT_LAYOUT   TYPE SLIS_LAYOUT_ALV OCCURS 0 WITH HEADER LINE,
      REPID       TYPE SY-REPID.

AT SELECTION-SCREEN OUTPUT.
  PERFORM CHECK_OLAP_AUTHORITY. " Added by William at 28.09.2026 (add restricted output card handling)
  PERFORM MODIFY_SQL_SCREEN.

START-OF-SELECTION.
  PERFORM CHECK_OLAP_AUTHORITY. " Added by William at 28.09.2026 (add authorization enforcement before execution)
  IF P_SCREEN EQ 'X'.
    PERFORM GET_DATA.
    PERFORM DISPLAY_DATA.
  ELSE.
    PERFORM DOWNLOAD_SQL.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*& Membaca item Sales Order yang memenuhi filter dan melengkapi nomor PI.
*& Data yang sama dipakai untuk tampilan ALV atau dikirim ke SQL.
*----------------------------------------------------------------------*
FORM GET_DATA.

  SELECT
    A~VBELN
    A~POSNR
    B~KUNNR
    A~MATNR
    A~ARKTX
    A~KWMENG
    A~VRKME
    A~NTGEW
    A~GEWEI
    C~NAME1
    FROM VBAP AS A INNER JOIN VBAK AS B ON A~VBELN EQ B~VBELN
                   INNER JOIN KNA1 AS C ON C~KUNNR EQ B~KUNNR
                   INNER JOIN MARA AS D ON A~MATNR EQ D~MATNR
    INTO CORRESPONDING FIELDS OF TABLE IT_DATA
    WHERE A~VBELN IN S_VBELN
    AND   A~WERKS IN S_WERKS
    AND   A~MATNR IN S_MATNR
    AND   A~MATKL IN S_MATKL
    AND   A~VBELN IN S_VBELN
    AND   A~POSNR IN S_POSNR
    AND   A~ERDAT IN S_ERDAT
    AND   B~KUNNR IN S_KUNNR
    AND   A~ABGRU EQ '  '
    AND   B~VBTYP = 'C'
    AND   D~MTART = 'ZFGS'.

  IF IT_DATA[] IS INITIAL.
    IF P_SCREEN EQ 'X'.
      MESSAGE 'Data Tidak Ditemukan!' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

* Isi PI dari teks header Sales Order sebelum filter PI diterapkan.
  LOOP AT IT_DATA.
    CLEAR : VVBELN.
    VVBELN = IT_DATA-VBELN.

    PERFORM READTEXT USING 'Z101' 'VBBK' VVBELN.
    IF SY-SUBRC EQ 0.
      READ TABLE IT_LINE INDEX 1.
      IT_DATA-PINO = IT_LINE-TDLINE.
    ENDIF.
    MODIFY IT_DATA.
  ENDLOOP.

  IF S_PINO IS INITIAL.
  ELSE.
    DELETE IT_DATA WHERE PINO NOT IN S_PINO.
  ENDIF.

ENDFORM.                    "GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*& Menampilkan IT_DATA pada ALV untuk pilihan Screen.
*----------------------------------------------------------------------*
FORM DISPLAY_DATA.

  IF IT_DATA IS INITIAL.
    MESSAGE 'Data Tidak Ada!' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  REPID = SY-REPID.
  LS_FIELDCAT-NO_ZERO  = 'X'.

  LS_FIELDCAT-FIELDNAME = 'VBELN'.  LS_FIELDCAT-SELTEXT_M = 'Sales Order'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'POSNR'.  LS_FIELDCAT-SELTEXT_M = 'Sales Order Item'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'KUNNR'.  LS_FIELDCAT-SELTEXT_L = 'Customer Number'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'NAME1'.  LS_FIELDCAT-SELTEXT_M = 'Customer Name'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'PINO'.  LS_FIELDCAT-SELTEXT_M = 'Performa Invoice'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'MATNR'.  LS_FIELDCAT-SELTEXT_M = 'Material'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'ARKTX'.  LS_FIELDCAT-SELTEXT_M = 'Material Description'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'KWMENG'.  LS_FIELDCAT-SELTEXT_M = 'Qty Sales'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'VRKME'.  LS_FIELDCAT-SELTEXT_M = 'Qty UnE'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'NTGEW'.  LS_FIELDCAT-SELTEXT_M = 'Qty'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'GEWEI'.  LS_FIELDCAT-SELTEXT_M = 'Qty Kg'.  APPEND LS_FIELDCAT TO IT_FIELDCAT. CLEAR LS_FIELDCAT.


  IT_LAYOUT-BOX_FIELDNAME = 'BOX'.
  IT_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  APPEND IT_LAYOUT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IT_FIELDCAT        = IT_FIELDCAT " field catalog
      I_CALLBACK_PROGRAM = REPID
      IS_LAYOUT          = IT_LAYOUT
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = IT_DATA " internal table
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

  CLEAR: IT_DATA.
  REFRESH: IT_DATA.

ENDFORM.                    "DISPLAY_DATA

*&---------------------------------------------------------------------*
*& Form CHECK_OLAP_AUTHORITY
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (restrict OLAP output by ZOLAP ACTVT 01)
*& Memeriksa otorisasi ZOLAP; tanpa izin, pilihan dikembalikan ke Screen.
*&---------------------------------------------------------------------*
FORM CHECK_OLAP_AUTHORITY.
* Added by William at 28.09.2026 (add authorization check before showing or running OLAP)
  AUTHORITY-CHECK OBJECT 'ZOLAP'
    ID 'ACTVT' FIELD '01'.

  IF SY-SUBRC EQ 0.
    GV_OLAP_AUTHORIZED = 'X'.
  ELSE.
    CLEAR GV_OLAP_AUTHORIZED.
    P_SCREEN = 'X'.
    CLEAR P_OLAP.
  ENDIF.
ENDFORM.                    "CHECK_OLAP_AUTHORITY

*&---------------------------------------------------------------------*
*& Form MODIFY_SQL_SCREEN
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (hide Output and OLAP Connection cards when unauthorized)
*& Mengatur visibilitas card output dan input koneksi sesuai pilihan.
*&---------------------------------------------------------------------*
* Added by William at 28.09.2026 (control visibility of SQL output cards)
FORM MODIFY_SQL_SCREEN.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'OUT'.
      IF GV_OLAP_AUTHORIZED EQ 'X'.
        SCREEN-ACTIVE = '1'.
        SCREEN-INPUT = '1'.
      ELSE.
        SCREEN-ACTIVE = '0'.
        SCREEN-INPUT = '0'.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF SCREEN-GROUP1 = 'CON'.
      IF GV_OLAP_AUTHORIZED EQ 'X' AND P_OLAP EQ 'X'.
        SCREEN-ACTIVE = '1'.
        SCREEN-INPUT = '1'.
      ELSE.
        SCREEN-ACTIVE = '0'.
        SCREEN-INPUT = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "MODIFY_SQL_SCREEN

*&---------------------------------------------------------------------*
*& Form CHECK_SQL_CONNECTION
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (validate SQL secondary connection)
*& Memastikan nama koneksi yang dipilih terdaftar pada DBCON.
*&---------------------------------------------------------------------*
FORM CHECK_SQL_CONNECTION.
  IF P_CONN IS INITIAL.
    MESSAGE 'Enter an SQL connection name' TYPE 'E'.
  ENDIF.

  SELECT SINGLE CON_NAME
    INTO P_CONN
    FROM DBCON
    WHERE CON_NAME = P_CONN.
  IF SY-SUBRC NE 0.
    MESSAGE 'SQL connection name was not found in DBCON' TYPE 'E'.
  ENDIF.
ENDFORM.                    "CHECK_SQL_CONNECTION

*&---------------------------------------------------------------------*
*& Form DOWNLOAD_SQL
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (SQL download using staging XSD028)
*& Memeriksa koneksi sebelum mengambil data, mengisi staging XSD028,
*& lalu menjalankan dbo.SP_Merge_ZSD028.
*&---------------------------------------------------------------------*
FORM DOWNLOAD_SQL.
  DATA: LO_SQL_NATIVE_ERROR TYPE REF TO CX_SY_NATIVE_SQL_ERROR,
        LO_SQL_ERROR TYPE REF TO CX_ROOT,
        LV_SQL_PHASE TYPE STRING,
        LV_TECHNICAL_ERROR TYPE STRING,
        LV_SQL_ERROR TYPE STRING.

* Semua tahap koneksi dan transfer berada dalam TRY agar error teknis
* SAP maupun database ditampilkan bersama fase prosesnya.
  TRY.
      LV_SQL_PHASE = 'Validate SQL Connection'.
      PERFORM CHECK_SQL_CONNECTION.
      LV_SQL_PHASE = 'Connect SQL'.
      PERFORM CONNECT_SQL.

* Data baru dibaca setelah koneksi SQL berhasil. Filter PI sudah selesai
* sebelum staging dikosongkan dan baris hasil mulai dimasukkan.
      LV_SQL_PHASE = 'Read Report Data'.
      PERFORM GET_DATA.
      IF IT_DATA[] IS INITIAL.
        PERFORM DISCONNECT_SQL.
        MESSAGE 'No data found; SQL transfer was skipped' TYPE 'I'.
        RETURN.
      ENDIF.

      LV_SQL_PHASE = 'Clear SQL Staging'.
      PERFORM CLEAR_SQL_STAGING.
      LV_SQL_PHASE = 'Insert SQL Staging'.
      PERFORM INSERT_SQL_STAGING.
      LV_SQL_PHASE = 'Commit SQL Staging'.
      PERFORM COMMIT_SQL.
      LV_SQL_PHASE = 'Execute Merge Procedure'.
      PERFORM EXECUTE_SQL_MERGE.
      LV_SQL_PHASE = 'Clear SQL Staging After Merge'.
      PERFORM CLEAR_SQL_STAGING.
      LV_SQL_PHASE = 'Disconnect SQL'.
      PERFORM DISCONNECT_SQL.
    CATCH CX_SY_NATIVE_SQL_ERROR INTO LO_SQL_NATIVE_ERROR.
* SQLMSG berisi error asli database; GET_TEXT menjadi fallback bila kosong.
      PERFORM CLEANUP_SQL_ON_ERROR.
      LV_TECHNICAL_ERROR = LO_SQL_NATIVE_ERROR->SQLMSG.
      IF LV_TECHNICAL_ERROR IS INITIAL.
        LV_TECHNICAL_ERROR = LO_SQL_NATIVE_ERROR->GET_TEXT( ).
      ENDIF.
      CONCATENATE 'SQL Error - ' LV_SQL_PHASE ': ' LV_TECHNICAL_ERROR
        INTO LV_SQL_ERROR.
      MESSAGE LV_SQL_ERROR TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    CATCH CX_ROOT INTO LO_SQL_ERROR.
* Error Open SQL dan error ABAP lain tetap menampilkan fase dan teks teknis.
      PERFORM CLEANUP_SQL_ON_ERROR.
      LV_TECHNICAL_ERROR = LO_SQL_ERROR->GET_TEXT( ).
      CONCATENATE 'SAP Error - ' LV_SQL_PHASE ': ' LV_TECHNICAL_ERROR
        INTO LV_SQL_ERROR.
      MESSAGE LV_SQL_ERROR TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
  ENDTRY.

  MESSAGE 'ZSD028 data successfully transferred to SQL' TYPE 'S'.
ENDFORM.                    "DOWNLOAD_SQL

*&---------------------------------------------------------------------*
*& Form CLEANUP_SQL_ON_ERROR
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (rollback staging and disconnect on errors)
*& Membatalkan transaksi staging yang belum commit dan menutup koneksi.
*& Error cleanup diabaikan agar pesan teknis utama tetap terlihat.
*&---------------------------------------------------------------------*
FORM CLEANUP_SQL_ON_ERROR.
  TRY.
      IF GV_SQL_CONNECTED EQ 'X'.
        EXEC SQL.
          ROLLBACK WORK
        ENDEXEC.
      ENDIF.
    CATCH CX_ROOT.
  ENDTRY.

  TRY.
      PERFORM DISCONNECT_SQL.
    CATCH CX_ROOT.
  ENDTRY.
ENDFORM.                    "CLEANUP_SQL_ON_ERROR

*&---------------------------------------------------------------------*
*& Form CONNECT_SQL
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (open SQL secondary connection)
*& Membuka koneksi secondary database sesuai parameter P_CONN.
*&---------------------------------------------------------------------*
FORM CONNECT_SQL.
  CLEAR GV_SQL_CONNECTED.

  EXEC SQL.
    CONNECT TO :P_CONN
  ENDEXEC.
  GV_SQL_CONNECTED = 'X'.
ENDFORM.                    "CONNECT_SQL

*&---------------------------------------------------------------------*
*& Form CLEAR_SQL_STAGING
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (clear SQL staging table XSD028)
*& Membersihkan staging XSD028 sebelum insert dan setelah merge berhasil.
*&---------------------------------------------------------------------*
FORM CLEAR_SQL_STAGING.
  EXEC SQL.
    DELETE FROM XSD028
  ENDEXEC.
ENDFORM.                    "CLEAR_SQL_STAGING

*&---------------------------------------------------------------------*
*& Form INSERT_SQL_STAGING
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (insert report data into XSD028 with progress)
*& Memasukkan hasil akhir IT_DATA ke XSD028 dan menampilkan progres.
*&---------------------------------------------------------------------*
FORM INSERT_SQL_STAGING.
  DATA: LV_INSERTED_TEXT TYPE C LENGTH 12,
        LV_TOTAL_TEXT TYPE C LENGTH 12,
        LV_PROGRESS_TEXT TYPE C LENGTH 80.

  DESCRIBE TABLE IT_DATA LINES GV_TOTAL.
  CLEAR: GV_INSERTED, GV_PERCENTAGE.
  GV_PROGRESS_INTERVAL = GV_TOTAL DIV 100.
  IF GV_PROGRESS_INTERVAL LT 1.
    GV_PROGRESS_INTERVAL = 1.
  ENDIF.

* Native SQL insert memakai field yang sama dengan kolom ALV dan SQL spec.
  LOOP AT IT_DATA.
    EXEC SQL.
      INSERT INTO XSD028
        ([SALES ORDER], [SALES ORDER ITEM], [CUSTOMER NUMBER],
         [CUSTOMER NAME], [PERFORMA INVOICE], [MATERIAL],
         [MATERIAL DESCRIPTION], [QTY SALES], [QTY UNE], [QTY], [QTY KG])
      VALUES
        (:IT_DATA-VBELN, :IT_DATA-POSNR, :IT_DATA-KUNNR,
         :IT_DATA-NAME1, :IT_DATA-PINO, :IT_DATA-MATNR,
         :IT_DATA-ARKTX, :IT_DATA-KWMENG, :IT_DATA-VRKME,
         :IT_DATA-NTGEW, :IT_DATA-GEWEI)
    ENDEXEC.

    GV_INSERTED = GV_INSERTED + 1.
    IF GV_INSERTED MOD GV_PROGRESS_INTERVAL EQ 0
       OR GV_INSERTED EQ GV_TOTAL.
      GV_PERCENTAGE = GV_INSERTED * 100 / GV_TOTAL.
      WRITE GV_INSERTED TO LV_INSERTED_TEXT.
      WRITE GV_TOTAL TO LV_TOTAL_TEXT.
      CONCATENATE 'Inserting SQL rows:' LV_INSERTED_TEXT 'of'
                  LV_TOTAL_TEXT INTO LV_PROGRESS_TEXT
                  SEPARATED BY SPACE.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          PERCENTAGE = GV_PERCENTAGE
          TEXT       = LV_PROGRESS_TEXT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "INSERT_SQL_STAGING

*&---------------------------------------------------------------------*
*& Form EXECUTE_SQL_MERGE
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (execute SQL merge procedure after XSD028 staging)
*& Menjalankan prosedur merge setelah staging XSD028 terisi.
*& dbo.SP_Merge_ZSD028 harus tersedia pada database tujuan.
*&---------------------------------------------------------------------*
FORM EXECUTE_SQL_MERGE.
  EXEC SQL.
    EXEC DBO.SP_MERGE_ZSD028
  ENDEXEC.
ENDFORM.                    "EXECUTE_SQL_MERGE

*&---------------------------------------------------------------------*
*& Form COMMIT_SQL
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (commit SQL staging rows before merge)
*& Menetapkan seluruh baris staging sebelum prosedur merge dijalankan.
*&---------------------------------------------------------------------*
FORM COMMIT_SQL.
  EXEC SQL.
    COMMIT WORK
  ENDEXEC.
ENDFORM.                    "COMMIT_SQL

*&---------------------------------------------------------------------*
*& Form DISCONNECT_SQL
*&---------------------------------------------------------------------*
*& Added by William at 28.09.2026 (close SQL secondary connection)
*& Menutup koneksi secondary database setelah proses SQL selesai.
*&---------------------------------------------------------------------*
FORM DISCONNECT_SQL.
  CHECK GV_SQL_CONNECTED EQ 'X'.

  EXEC SQL.
    DISCONNECT :P_CONN
  ENDEXEC.
  CLEAR GV_SQL_CONNECTED.
ENDFORM.                    "DISCONNECT_SQL

*&---------------------------------------------------------------------*
*&      Form  READTEXT
*&---------------------------------------------------------------------*
*& Membaca teks header Sales Order, termasuk PI pada baris pertama.
*& USING ID = text ID, OBJECT = text object, NAME = Sales Order text name.
*----------------------------------------------------------------------*
FORM READTEXT USING ID OBJECT NAME.
  CLEAR : IT_LINE.
  REFRESH : IT_LINE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID                      = ID
      LANGUAGE                = SY-LANGU
      NAME                    = VVBELN
      OBJECT                  = OBJECT
    TABLES
      LINES                   = IT_LINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
ENDFORM.                    "READTEXT