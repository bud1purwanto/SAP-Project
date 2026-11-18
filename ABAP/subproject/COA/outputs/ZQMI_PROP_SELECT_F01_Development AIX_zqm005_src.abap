*&---------------------------------------------------------------------*
*&  Include           ZQMI_PROP_SELECT_F01
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

INITIALIZATION.
  MOVE 'Program Information' TO INFO.

AT SELECTION-SCREEN OUTPUT.
  PERFORM F_MODIFY_SCREEN.

START-OF-SELECTION.
  CONCATENATE PDATE-LOW+6(2)  '/' PDATE-LOW+4(2)  '/'  PDATE-LOW+0(4) INTO DATES.
  CONCATENATE PDATE-HIGH+6(2) '/' PDATE-HIGH+4(2) '/' PDATE-HIGH+0(4) INTO DATEF.

  PERFORM DATA_RETRIEVAL.

  IF RTYPE1 = 'X'.
    IF ITAB[] IS NOT INITIAL.
      PERFORM F_DISPLAY_DATA.
    ELSE.
      IF L_ERRNO <> -1.
        MESSAGE 'Tidak ada data!' TYPE 'I'.
      ENDIF.

    ENDIF.
  ELSEIF RTYPE2 = 'X'.
    IF ITAB[] IS NOT INITIAL.
      PERFORM CREATEDINAMYCIT.
    ELSE.
      IF L_ERRNO <> -1.
        MESSAGE 'Tidak ada data!' TYPE 'I'.
      ENDIF.
    ENDIF.
  ELSEIF RTYPE3 = 'X'.
    AUTHORITY-CHECK OBJECT 'ZOLAP'
             ID 'ACTVT' FIELD '01'
             ID 'ZTCODE' FIELD 'ZQM005'.
    IF SY-SUBRC <> 0.
      MESSAGE 'No Authorization to download data...!'  TYPE 'I'. "#EC NOTEXT
      EXIT.
    ELSE.
      DATA: CON_NAME LIKE DBCON-CON_NAME.
      SELECT SINGLE CON_NAME
        INTO CON_NAME
        FROM DBCON
       WHERE CON_NAME = 'TRIASDB05'.
      IF SY-SUBRC NE 0.
        MESSAGE 'Connection TRIASDB05 not found!'  TYPE 'I'. "#EC NOTEXT
        EXIT.
      ELSE.
        IF ITAB[] IS NOT INITIAL.
          PERFORM F_PUSH_TO_SQL_DB.
        ELSE.
          IF L_ERRNO <> -1.
            MESSAGE 'Tidak ada data!' TYPE 'I'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.

  IF RM = 'X'.
    PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'ITAB' :
    'ZZPRODLINE'  '' ''  '' ''  'Line'       '' ' ' '' '',
    'ENSTEHDAT'   '' ''  '' ''  'Inspection Lot Date'       '' ' ' '' '',
    'IL'          '' ''  '' ''  'Inspection Lot'            '' ' ' '' '',
    'MAT'         '' ''  '' ''  'Material Code'             '' ' ' '' '',
    'MAKTX'       '' ''  '' ''  'Material Desc.'                 '' ' ' '' '',
    'AUFNR'       '' ''  '' ''  'PO No.'                    '' ' ' '' '',
    'WERKS'       '' ''  '' ''  'Plant'                     '' ' ' '' '',
    'PNAME'       '' ''  '' ''  'Inspection Characteristic' '' ' ' '' '',
    'CMIN'        '' ''  '' ''  'Std Min'                   '' ' ' '' '',
    'CMAX'        '' ''  '' ''  'Std Max'                   '' ' ' '' '' ,
    'CVALUE'      '' ''  '' ''  'Mean Value'                '' ' ' '' ''.
  ELSEIF  R2 = 'X' .
    PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'ITAB' :
    'ZZPRODLINE'  '' ''  '' ''  'Line'       '' ' ' '' '',
    'ENSTEHDAT'   '' ''  '' ''  'Inspection Lot Date'       '' ' ' '' '',
    'IL'          '' ''  '' ''  'Inspection Lot'            '' ' ' '' '',
    'MAT'         '' ''  '' ''  'Material Code'             '' ' ' '' '',
    'ZZCODE'       '' ''  '' ''  'Film Type'                 '' ' ' '' '',
    'ZZNOROLLJR' '' ''  '' ''  'No JR'                     '' ' ' '' '',
    'BATCHJR'       '' ''  '' ''  'Batch JR'                     '' ' ' '' '',
    'ZZNOMORROLL' '' ''  '' ''  'No SR'                     '' ' ' '' '',
    'BATCH'       '' ''  '' ''  'Batch SR'                     '' ' ' '' '',
    "'PRUEFLOSREF'       '' ''  '' ''  'IL REF'                     '' ' ' '' '',
    'ZZWIDTH'     '' ''  '' ''  'Width'                     '' ' ' '' '',
    'ZZLENGTH'    '' ''  '' ''  'Length'                    '' ' ' '' '',
    'WERKS'       '' ''  '' ''  'Plant'                     '' ' ' '' '',
    'PNAME'       '' ''  '' ''  'Inspection Characteristic' '' ' ' '' '',
    'CMIN'        '' ''  '' ''  'Std Min'                   '' ' ' '' '',
    'CMAX'        '' ''  '' ''  'Std Max'                   '' ' ' '' '' ,
    'CVALUE'      '' ''  '' ''  'Mean Value'                '' ' ' '' ''.

  ELSEIF R1 = 'X'  OR R3 = 'X'.
    PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'ITAB' :
    'ZZPRODLINE'  '' ''  '' ''  'Line'       '' ' ' '' '',
    'ENSTEHDAT'   '' ''  '' ''  'Inspection Lot Date'       '' ' ' '' '',
    'IL'          '' ''  '' ''  'Inspection Lot'            '' ' ' '' '',
    'MAT'         '' ''  '' ''  'Material Code'             '' ' ' '' '',
    'ZZCODE'       '' ''  '' ''  'Film Type'                 '' ' ' '' '',
    'ZZNOMORROLL' '' ''  '' ''  'No JR'                     '' ' ' '' '',
    'BATCH'       '' ''  '' ''  'Batch'                     '' ' ' '' '',
    'ZZWIDTH'     '' ''  '' ''  'Width'                     '' ' ' '' '',
    'ZZLENGTH'    '' ''  '' ''  'Length'                    '' ' ' '' '',
    'WERKS'       '' ''  '' ''  'Plant'                     '' ' ' '' '',
    'PNAME'       '' ''  '' ''  'Inspection Characteristic' '' ' ' '' '',
    'CMIN'        '' ''  '' ''  'Std Min'                   '' ' ' '' '',
    'CMAX'        '' ''  '' ''  'Std Max'                   '' ' ' '' '' ,
    'CVALUE'      '' ''  '' ''  'Mean Value'                '' ' ' '' ''.
  ENDIF.

ENDFORM.                    "f_field_catalog


*&---------------------------------------------------------------------*
*&      Form  TOP-OF-PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOP-OF-PAGE.
*ALV HEADER DECLARATIONS
  DATA: T_HEADER TYPE SLIS_T_LISTHEADER,
        WA_HEADER TYPE SLIS_LISTHEADER,
        T_LINE LIKE WA_HEADER-INFO,
        LD_LINES TYPE I,
        LD_LINESC(10) TYPE C,
        VTYPE(10) TYPE C
        .


  CLEAR : DATES, DATEF.
  IF R1 = 'X'.
    VTYPE = 'Jumbo Roll'.
  ELSEIF  R2 = 'X'.
    VTYPE = 'Slit Roll'.
  ELSEIF  R3 = 'X'.
    VTYPE = 'Aging'.
  ELSEIF  RM = 'X'.
    VTYPE = 'Mixing'.
  ENDIF.

* TITLE
  WA_HEADER-TYP  = 'H'.
  WA_HEADER-INFO = 'AFTER PRODUCT REPORT '.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.

  WA_HEADER-TYP  = 'S'.
  CONCATENATE 'Material Type :' VTYPE INTO WA_HEADER-INFO SEPARATED BY SPACE.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.

  WA_HEADER-TYP  = 'S'.
  CONCATENATE 'Inspection Lot Date :' DATES 'to' DATEF INTO WA_HEADER-INFO  SEPARATED BY SPACE.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = T_HEADER.
ENDFORM.                    "TOP-OF-PAGE

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

  DATA : N TYPE I.

* CHECK FUNCTION CODE
  CASE R_UCOMM.
    WHEN 'PRINT1'.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME = 'ZQMFAFTERPRODUCT'
        IMPORTING
          FM_NAME  = FM_NAME.

      CALL FUNCTION FM_NAME
        EXPORTING
          IF_TAB = WA_ITAB
          PLOW   = PDATE-LOW
          PHIGH  = PDATE-HIGH
        TABLES
          ITAB   = ITAB.
  ENDCASE.

ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RETRIEVAL .

  DATA : ZCHAR TYPE TABLE OF CLBATCH WITH HEADER LINE.
  DATA : WACHAR TYPE CLBATCH.

  DATA : ITEMP TYPE TABLE OF ZQMSAP WITH HEADER LINE.
  DATA : ITEMP2 TYPE TABLE OF ZQMSAP WITH HEADER LINE.
  DATA : ITILREF TYPE TABLE OF ZQMSAP WITH HEADER LINE.
  DATA : ITILREFTEMP TYPE TABLE OF ZQMSAP WITH HEADER LINE.
  DATA : VATINN TYPE CAWNT-ATINN.

  DATA : N TYPE I,
         I TYPE I,
         VERWMERKM TYPE QAMV-VERWMERKM,
         MKVERSION TYPE QAMV-MKVERSION,
         VCODE1 TYPE QAMR-CODE1,
         VCANCEL TYPE I,
         VNCANCEL TYPE I,
         VKATAB1 TYPE QAMV-KATAB1.


  DATA: V_INSPECTED TYPE QAMR-ANZWERTG. "add by Afir 15-01-2021

  REFRESH ITAB.
  IF R1 = 'X'.
    "- JUMBO ROLL
    PERFORM F_GETDATA_JR.

  ELSEIF R2 = 'X'.
    "- SLIT ROLL
    PERFORM F_GETDATA_SR.

  ELSEIF R3 = 'X'.
    "- AGING
    PERFORM F_GETDATA_AGING.

  ELSEIF RM = 'X'.
    "- MIXING
    CLEAR L_ERRNO.
    IF PCHARG[] IS NOT INITIAL.
      L_ERRNO = -1.
      MESSAGE 'Batch tidak boleh diisi!' TYPE 'I'.
    ELSE.
      PERFORM F_GETDATA_MIXING.
    ENDIF.

  ENDIF.

  IF ITAB[] IS NOT INITIAL.

*  DATA FOR DISPLAY TYPE 2
    REFRESH : ITEMP, ITEMP2, ITEMPJR.
    ITEMP[]  = ITAB[].
    ITEMP2[] = ITAB[].
    ITEMPJR[] = ITAB[].
    SORT ITEMP ASCENDING BY MAT PNAME PVALUE.
    DELETE ADJACENT DUPLICATES FROM ITEMP COMPARING MAT PNAME.
    SORT ITEMP2 DESCENDING BY MAT PNAME PVALUE.
    DELETE ADJACENT DUPLICATES FROM ITEMP2 COMPARING MAT PNAME.

    IF R2 = 'X'.
      SORT ITEMPJR BY BATCH.
      DELETE ADJACENT DUPLICATES FROM ITEMPJR COMPARING BATCH.

      LOOP AT ITEMPJR.
        "CHECK CANCELLATION
        CLEAR : VCANCEL , VNCANCEL.

        SELECT COUNT( * )
        INTO VNCANCEL
        FROM MSEG
        WHERE MSEG~CHARG = ITEMPJR-BATCH
        AND MSEG~BWART = '101'.

        SELECT COUNT( * )
           INTO VCANCEL
           FROM MSEG
           WHERE MSEG~CHARG = ITEMPJR-BATCH
           AND MSEG~BWART = '102'.

        IF VCANCEL = VNCANCEL AND VNCANCEL <> 0.
          DELETE ITAB WHERE BATCH = ITEMPJR-BATCH.
          DELETE ITEMPJR.
          CONTINUE.
        ENDIF.

        PERFORM F_GET_BATCH_JR.
        REFRESH : ZCHARACTER, ZCHAR.

        CLEAR WA_JR.
        READ TABLE IT_JR INTO WA_JR.

        IF WA_JR-BATCHJR NE ''.

          CALL FUNCTION 'ZCHAR_ZQM005'
            EXPORTING
              I_VAL_MATNR  = WA_JR-MATJR
              I_VAL_CHARGE = WA_JR-BATCHJR
            TABLES
              T_VAL_TAB    = ZCHARACTER
            EXCEPTIONS
              NO_OBJECT    = 1
              NO_VALUES    = 2
              OTHERS       = 3.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.

        READ TABLE ZCHARACTER WITH KEY ATNAM = 'ZZNOMORROLL'.
        IF SY-SUBRC = 0.
          ITEMPJR-ZZNOROLLJR = ZCHARACTER-ATWRT.
          ITEMPJR-BATCHJR = WA_JR-BATCHJR.
        ENDIF.

        MODIFY ITEMPJR.
      ENDLOOP.
    ENDIF.
    PERFORM F_GETDATA_CHAR.

    LOOP AT ITAB.
      "- CEK INPS. LOT CANCELLED
      REFRESH : LT_USR_STAT, TSYSSTATUS.
      CALL FUNCTION 'BAPI_INSPLOT_GETSTATUS'
        EXPORTING
          NUMBER        = ITAB-IL
          LANGUAGE      = LS_LANGU
        TABLES
          SYSTEM_STATUS = TSYSSTATUS
          USER_STATUS   = LT_USR_STAT.

      READ TABLE TSYSSTATUS WITH  KEY SY_ST_TEXT = 'LTCA'.
      IF  SY-SUBRC = 0.
        DELETE ITAB WHERE IL = ITAB-IL.
        CONTINUE.
      ENDIF.

      CLEAR : VERWMERKM, MKVERSION.

      SELECT SINGLE QAMV~VERWMERKM
       INTO VERWMERKM
       FROM QAMV
       WHERE QAMV~PRUEFLOS = ITAB-IL
       AND QAMV~MERKNR  = ITAB-MERKNR.

      SELECT SINGLE QAMV~MKVERSION
      INTO MKVERSION
      FROM QAMV
      WHERE QAMV~PRUEFLOS = ITAB-IL
      AND QAMV~MERKNR  = ITAB-MERKNR.

      " GET STD MAX AND STD MIN
*      SELECT SINGLE QPMK~TOLERANZUN QPMK~TOLERANZOB QPMK~STELLEN
*        INTO (ITAB-ZMIN, ITAB-ZMAX, ITAB-STELLEN)
      SELECT SINGLE QPMK~TOLERANZUN QPMK~TOLERANZOB QPMK~STELLEN
        INTO (ITAB-ZMIN, ITAB-ZMAX, ITAB-STELLEN)
        FROM QPMK
        WHERE QPMK~MKMNR = VERWMERKM
        AND   QPMK~VERSION = MKVERSION
        AND QPMK~WERKS = ITAB-WERKS.

      IF RM = 'X'.
        "- Get Line
        SELECT SINGLE ZTMAP_SLOC_JR_GR~ZLINE
          INTO ITAB-ZZPRODLINE
          FROM ZTMAP_SLOC_JR_GR
          JOIN MSEG ON ZTMAP_SLOC_JR_GR~ZSLOCGIJR = MSEG~LGORT
          WHERE MSEG~MATNR = ITAB-MAT
          AND MSEG~WERKS = ITAB-WERKS
          AND MSEG~BWART = '261'.

      ELSE.
        "GET CHAR PER MAT AND BATCH
        CLEAR WA_ITAB.
        LOOP AT ITCHAR INTO WA_ITAB WHERE MAT = ITAB-MAT AND BATCH = ITAB-BATCH.
        ENDLOOP.

        ITAB-ZZNOMORROLL = WA_ITAB-ZZNOMORROLL.
        ITAB-ZZCODE = WA_ITAB-ZZCODE.

        "- LENGTH
        CLEAR : V_CUOBJ_BM, V_MAFID, V_UDATE, V_VALUE_NEW, F_VALUE,
                V_UTIME, V_OBJECTID, V_TABKEY, V_CHANGENR.

        SELECT SINGLE MCH1~CUOBJ_BM
          INTO V_CUOBJ_BM
          FROM MCH1
          WHERE MCH1~MATNR = ITAB-MAT
          AND MCH1~CHARG = ITAB-BATCH.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = V_CUOBJ_BM
          IMPORTING
            OUTPUT = V_CUOBJ_BM.

        CLEAR VATINN.
        CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
          EXPORTING
            INPUT  = 'ZZLENGTH'
          IMPORTING
            OUTPUT = VATINN.

        CONCATENATE V_CUOBJ_BM VATINN  '001' 'O' INTO V_TABKEY.
        CONCATENATE V_CUOBJ_BM 'O' INTO V_OBJECTID.

        "- GET ORIGINAL DATE AND TIME
        SELECT MIN( CDHDR~UDATE )
          INTO V_UDATE
          FROM CDHDR
          WHERE CDHDR~OBJECTCLAS = 'CLASSIFY'
          AND CDHDR~OBJECTID = V_OBJECTID.

        SELECT MIN( CDHDR~UTIME )
           INTO V_UTIME
           FROM CDHDR
           WHERE CDHDR~OBJECTCLAS = 'CLASSIFY'
           AND CDHDR~OBJECTID = V_OBJECTID
          AND CDHDR~UDATE = V_UDATE.

        SELECT SINGLE CDHDR~CHANGENR
          INTO V_CHANGENR
          FROM CDHDR
          WHERE  CDHDR~OBJECTCLAS = 'CLASSIFY'
          AND CDHDR~OBJECTID = V_OBJECTID
          AND CDHDR~UDATE = V_UDATE
          AND CDHDR~UTIME = V_UTIME
          %_HINTS ORACLE 'INDEX"CDHDR~001"'.

        IF SY-SUBRC <> 0.
          ITAB-ZZLENGTH = WA_ITAB-ZZLENGTH.
        ELSE.
          SELECT SINGLE CDPOS~VALUE_NEW
            INTO V_VALUE_NEW
            FROM CDPOS
            WHERE CDPOS~OBJECTCLAS = 'CLASSIFY'
            AND CDPOS~OBJECTID = V_OBJECTID
            AND CDPOS~TABKEY = V_TABKEY
            AND CDPOS~CHANGENR = V_CHANGENR
            AND CDPOS~FNAME = 'ATFLV'.

          IF SY-SUBRC = 0.
            MOVE V_VALUE_NEW TO F_VALUE .
            MOVE F_VALUE  TO ITAB-ZZLENGTH.
          ELSE.
            ITAB-ZZLENGTH = WA_ITAB-ZZLENGTH.
          ENDIF.

        ENDIF.

        "- WIDTH
        CLEAR : V_MAFID,VATINN, V_UDATE, V_VALUE_NEW, F_VALUE,
                V_UTIME, V_OBJECTID, V_TABKEY, V_CHANGENR.

        CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
          EXPORTING
            INPUT  = 'ZZWIDTH'
          IMPORTING
            OUTPUT = VATINN.

        CONCATENATE V_CUOBJ_BM VATINN '001' 'O' INTO V_TABKEY.
        CONCATENATE V_CUOBJ_BM 'O' INTO V_OBJECTID.

        "- GET ORIGINAL DATE AND TIME
        SELECT MIN( CDHDR~UDATE )
          INTO V_UDATE
          FROM CDHDR
          WHERE CDHDR~OBJECTCLAS = 'CLASSIFY'
          AND CDHDR~OBJECTID = V_OBJECTID.

        SELECT MIN( CDHDR~UTIME )
           INTO V_UTIME
           FROM CDHDR
           WHERE CDHDR~OBJECTCLAS = 'CLASSIFY'
           AND CDHDR~OBJECTID = V_OBJECTID
          AND CDHDR~UDATE = V_UDATE.

        SELECT SINGLE CDHDR~CHANGENR
          INTO V_CHANGENR
          FROM CDHDR
          WHERE  CDHDR~OBJECTCLAS = 'CLASSIFY'
          AND CDHDR~OBJECTID = V_OBJECTID
          AND CDHDR~UDATE = V_UDATE
          AND CDHDR~UTIME = V_UTIME
         %_HINTS ORACLE 'INDEX"CDHDR~001"'.

        IF SY-SUBRC <> 0.
          ITAB-ZZWIDTH = WA_ITAB-ZZWIDTH.
        ELSE.

          SELECT SINGLE CDPOS~VALUE_NEW
            INTO V_VALUE_NEW
            FROM CDPOS
            WHERE CDPOS~OBJECTCLAS = 'CLASSIFY'
            AND CDPOS~OBJECTID = V_OBJECTID
            AND CDPOS~TABKEY = V_TABKEY
            AND CDPOS~CHANGENR = V_CHANGENR
            AND CDPOS~FNAME = 'ATFLV'.

          IF SY-SUBRC = 0.
            MOVE V_VALUE_NEW TO F_VALUE .
            MOVE F_VALUE  TO ITAB-ZZWIDTH.
          ELSE.
            ITAB-ZZWIDTH = WA_ITAB-ZZWIDTH.
          ENDIF.
        ENDIF.

        ITAB-ZZPRODLINE = WA_ITAB-ZZPRODLINE.

        IF R2 = 'X'.
          CLEAR WA_ITAB.
          READ TABLE ITEMPJR INTO WA_ITAB WITH KEY BATCH = ITAB-BATCH.
          IF SY-SUBRC = 0.
            ITAB-ZZNOROLLJR = WA_ITAB-ZZNOROLLJR.
            ITAB-BATCHJR = WA_ITAB-BATCHJR.
          ENDIF.

        ELSE.
          ITAB-ZZNOMORROLL = WA_ITAB-ZZNOMORROLL.
        ENDIF.

      ENDIF.

*      MOVE ITAB-PVALUE TO ITAB-CVALUE.

*      CEK KUALITATIF OR QUANTITATIF
      CLEAR VKATAB1.
      SELECT SINGLE QAMV~KATAB1
        FROM QAMV
        INTO VKATAB1
        WHERE QAMV~PRUEFLOS = ITAB-IL
        AND QAMV~MERKNR = ITAB-MERKNR
        AND QAMV~KATAB1 = 'X'.

      IF SY-SUBRC = 0.
        SELECT SINGLE QASE~CODE1
              INTO ITAB-CVALUE
              FROM QASE
              JOIN QAMV ON QASE~PRUEFLOS = QAMV~PRUEFLOS
              AND QASE~VORGLFNR = QAMV~VORGLFNR
              AND QASE~MERKNR = QAMV~MERKNR
              WHERE QAMV~PRUEFLOS = ITAB-IL
              AND QAMV~MERKNR = ITAB-MERKNR.

        IF SY-SUBRC <> 0.
          SELECT SINGLE QAMR~CODE1
            INTO ITAB-CVALUE
            FROM QAMR
            WHERE  QAMR~PRUEFLOS = ITAB-IL
          AND QAMR~VORGLFNR = ITAB-VORGLFNR
          AND QAMR~MERKNR   = ITAB-MERKNR.
        ELSE.
          ITAB-CVALUE = ''.
        ENDIF.

      ENDIF.

      IF VKATAB1 EQ 'X'. "Start add by Afir 15-01-2021
        ITAB-CMIN = ''.
        ITAB-CMAX = ''.
      ELSE.
        WRITE ITAB-ZMIN TO ITAB-CMIN DECIMALS ITAB-STELLEN EXPONENT 0.
        WRITE ITAB-ZMAX TO ITAB-CMAX DECIMALS ITAB-STELLEN EXPONENT 0.
      ENDIF.

      IF ITAB-CVALUE = ''.
        CLEAR V_INSPECTED.
        SELECT SINGLE A~ANZWERTG INTO V_INSPECTED FROM QAMR AS A JOIN QALS AS B ON A~PRUEFLOS EQ B~PRUEFLOS
          WHERE A~PRUEFLOS EQ ITAB-IL AND A~MERKNR EQ ITAB-MERKNR.

        IF V_INSPECTED EQ 0.
          ITAB-CVALUE = ''.
        ELSE.
          WRITE ITAB-PVALUE TO ITAB-CVALUE DECIMALS ITAB-STELLEN EXPONENT 0.
        ENDIF.
      ENDIF. " End add by Afir 15-01-2021
*      MOVE ITAB-ZMIN TO ITAB-CMIN.
*      MOVE ITAB-ZMAX TO ITAB-CMAX.
*      MOVE ITAB-PVALUE TO ITAB-CVALUE.

      " result 0 tetap ditampilkan 29 Jan 2012
*      IF ITAB-PVALUE = 0.
*        IF ITAB-CVALUE NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
*          DELETE ITAB.
*          CONTINUE.
*        ENDIF.
*
*      ENDIF. "29 Jan 2012

      MODIFY ITAB.
    ENDLOOP.

    IF PLINE[] IS NOT INITIAL.
      LOOP AT PLINE.
        TRANSLATE PLINE-LOW TO UPPER CASE.
        TRANSLATE PLINE-HIGH TO UPPER CASE.
        MODIFY PLINE.
      ENDLOOP.

      DELETE ITAB WHERE ZZPRODLINE NOT IN PLINE.
    ENDIF.

    "assign nilai itab ke internal tabel itab2(untuk keperluan type2)
    REFRESH ITAB2.
    SORT ITAB BY MAT BATCH IL MERKNR.
    ITAB2[] = ITAB[].
    SORT ITAB2 BY MAT PNAME.
  ENDIF.


ENDFORM.                    " DATA_RETRIEVAL

*&---------------------------------------------------------------------*
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EXTAB   text
*----------------------------------------------------------------------*
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'PFSTAT'.
ENDFORM.                    "F_GUI_STATUS


*&---------------------------------------------------------------------*
*&      Form  CREATEDINAMICIT
*&---------------------------------------------------------------------*
*       DINAMIC TABLE DISPLAY (TYPE 2 IN DATA DISPLAY)
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATEDINAMYCIT .
  DATA : ITEMP TYPE TABLE OF ZQMSAP WITH HEADER LINE.
  DATA : ITEMP2 TYPE TABLE OF ZQMSAP WITH HEADER LINE,
         N TYPE I, "COUNTER FOR PROPERTIES OF MATERIAL.
         VTEMP TYPE C,
         VFIELDTEMP(50) TYPE C.

  "JIKA MIXING
  IF RM = 'X'.
    REFRESH ITEMP.
    "DATA FOR PROPERTIES.
    ITEMP[] = ITAB2[].
    SORT ITEMP BY MAT PNAME.
    DELETE ADJACENT DUPLICATES FROM ITEMP COMPARING MAT PNAME.

    " DATA FOR MATERIAL
    ITAB3[] = ITAB2[].
    SORT ITAB3 BY MAT.
    DELETE ADJACENT DUPLICATES FROM ITAB3 COMPARING MAT.

    "CREATE FIELDNAME
    SORT ITAB2 BY MAT PNAME.
    ITEMP2[] = ITAB2[].

    DELETE ADJACENT DUPLICATES FROM ITEMP2 COMPARING MAT PNAME.

    LOOP AT ITEMP2.
      LOOP AT ITAB2 WHERE MAT = ITEMP2-MAT AND PNAME = ITEMP2-PNAME.
        CONCATENATE 'Z' ITAB2-MAT ITAB2-AUFNR INTO ITAB2-ZFIELDNAME.

        MODIFY ITAB2.
      ENDLOOP.

    ENDLOOP.

    REFRESH ITEMP2.
    ITEMP2[] = ITAB2[].

****  "CALCULATE DATA FOR BATCH
    SORT ITAB2 BY ZFIELDNAME.
    DELETE ADJACENT DUPLICATES FROM ITAB2 COMPARING ZFIELDNAME.

    READ TABLE ITAB2 INTO WA_ITAB WITH KEY ZFIELDNAME = 'MATERIAL'.
    IF SY-SUBRC NE 0.
      WA_ITAB-ZFIELDNAME = 'MATERIAL'.
      APPEND WA_ITAB TO ITAB2.

      WA_ITAB-ZFIELDNAME = 'MDATERIAL'.
      APPEND WA_ITAB TO ITAB2.
    ENDIF.

    READ TABLE ITAB2 INTO WA_ITAB WITH KEY ZFIELDNAME = 'PPROPERTIES'.
    IF SY-SUBRC NE 0.
      WA_ITAB-ZFIELDNAME = 'PROPERTIES'.
      APPEND WA_ITAB TO ITAB2.

      WA_ITAB-ZFIELDNAME = 'TMAX'.
      APPEND WA_ITAB TO ITAB2.

      WA_ITAB-ZFIELDNAME = 'TMIN'.
      APPEND WA_ITAB TO ITAB2.
    ENDIF.

    CLEAR : WA_ITAB, LA_COMP.
    SORT ITAB2 BY ZFIELDNAME.

    LOOP AT ITAB2.
      CLEAR : LS_TABIX.
      LS_TABIX = SY-TABIX.

      IF ( LS_TABIX = 1 OR LS_TABIX = 2 OR LS_TABIX = 3 OR LS_TABIX = 4 OR LS_TABIX = 5 ).
*   Element Description
        LO_ELEMENT ?= CL_ABAP_ELEMDESCR=>DESCRIBE_BY_NAME( 'CHAR20' ).
*   Field name
        MOVE ITAB2-ZFIELDNAME TO LA_COMP-NAME.
*
*   Field type character
        LA_COMP-TYPE = CL_ABAP_ELEMDESCR=>GET_C(
                          P_LENGTH   = LO_ELEMENT->LENGTH ).
*
*   Filling the component table
        APPEND LA_COMP TO LT_TOT_COMP.
        CLEAR: LA_COMP.

      ELSE.

*   Element Description
        LO_ELEMENT ?= CL_ABAP_ELEMDESCR=>DESCRIBE_BY_NAME( 'ZQMIC' ).
*
*   Field name
        MOVE ITAB2-ZFIELDNAME TO LA_COMP-NAME.

*   Field type quantity with decimals
        LA_COMP-TYPE = CL_ABAP_ELEMDESCR=>GET_C(
                                  P_LENGTH   = LO_ELEMENT->LENGTH ).
*   Filling the component table
        APPEND LA_COMP TO LT_TOT_COMP.
        CLEAR: LA_COMP.

      ENDIF.
    ENDLOOP.

    SORT LT_TOT_COMP BY NAME.

* 3. Create a New Type
    LO_NEW_TYPE = CL_ABAP_STRUCTDESCR=>CREATE( LT_TOT_COMP ).

* 4. New Table type
    LO_NEW_TAB = CL_ABAP_TABLEDESCR=>CREATE(
                    P_LINE_TYPE  = LO_NEW_TYPE
                    P_TABLE_KIND = CL_ABAP_TABLEDESCR=>TABLEKIND_STD
                    P_UNIQUE     = ABAP_FALSE ).

* 5. data to handle the new table type
    CREATE DATA LO_DATA TYPE HANDLE LO_NEW_TAB.

* 6. New internal table in the fieldsymbols
    ASSIGN LO_DATA->* TO <F_TAB>.

    CREATE DATA NEW_LINE LIKE LINE OF <F_TAB>.
    ASSIGN NEW_LINE->* TO <LO_LINE>.

    "ASSIGN DATA TO TABLE <F_TAB>
    SORT ITEMP2 BY MAT PNAME.
    LOOP AT ITEMP.
      ASSIGN COMPONENT 'MATERIAL' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      <F_FIELD> = ITEMP-MAT.

      ASSIGN COMPONENT 'MDATERIAL' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      <F_FIELD> = ITEMP-MAKTX.

      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      <F_FIELD> = ITEMP-PNAME.

      ASSIGN COMPONENT 'TMAX' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      CONDENSE ITEMP-CMAX.      MOVE ITEMP-CMAX TO <F_FIELD>.
      ASSIGN COMPONENT 'TMIN' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      CONDENSE ITEMP-CMIN.      MOVE ITEMP-CMIN TO <F_FIELD>.

      LOOP AT ITEMP2 WHERE MAT = ITEMP-MAT AND PNAME = ITEMP-PNAME.
        ASSIGN COMPONENT ITEMP2-ZFIELDNAME OF STRUCTURE <LO_LINE> TO <F_FIELD>.
        CONDENSE ITEMP2-CVALUE. MOVE ITEMP2-CVALUE TO <F_FIELD>.
      ENDLOOP.

      INSERT <LO_LINE> INTO TABLE <F_TAB>.
    ENDLOOP.


  ELSE. "JIKA SELAIN MIXING

    REFRESH ITEMP.
    CLEAR ITEMP.
    "DATA FOR PROPERTIES.
    ITEMP[] = ITAB2[].
    SORT ITEMP BY MAT PNAME.
    DELETE ADJACENT DUPLICATES FROM ITEMP COMPARING MAT PNAME.

    " DATA FOR MATERIAL
    ITAB3[] = ITAB2[].
    SORT ITAB3 BY MAT.
    DELETE ADJACENT DUPLICATES FROM ITAB3 COMPARING MAT.

    "CREATE FIELDNAME
    SORT ITAB2 BY MAT PNAME.
    ITEMP2[] = ITAB2[].

    DELETE ADJACENT DUPLICATES FROM ITEMP2 COMPARING MAT PNAME.

    LOOP AT ITEMP2.
      LOOP AT ITAB2 WHERE MAT = ITEMP2-MAT AND PNAME = ITEMP2-PNAME.
        CONCATENATE 'Z' ITAB2-MAT ITAB2-BATCH INTO ITAB2-ZFIELDNAME.
        MODIFY ITAB2.
      ENDLOOP.

    ENDLOOP.

    REFRESH ITEMP2.
    ITEMP2[] = ITAB2[].

****  "CALCULATE DATA FOR BATCH
    SORT ITAB2 BY ZFIELDNAME. "MAT.
    DELETE ADJACENT DUPLICATES FROM ITAB2 COMPARING ZFIELDNAME.

    READ TABLE ITAB2 INTO WA_ITAB WITH KEY ZFIELDNAME = 'MATERIAL'.
    IF SY-SUBRC NE 0.
      WA_ITAB-ZFIELDNAME = 'MATERIAL'.
      APPEND WA_ITAB TO ITAB2.
    ENDIF.

    READ TABLE ITAB2 INTO WA_ITAB WITH KEY ZFIELDNAME = 'PPROPERTIES'.
    IF SY-SUBRC NE 0.
      WA_ITAB-ZFIELDNAME = 'PROPERTIES'.
      APPEND WA_ITAB TO ITAB2.

      WA_ITAB-ZFIELDNAME = 'TMAX'.
      APPEND WA_ITAB TO ITAB2.

      WA_ITAB-ZFIELDNAME = 'TMIN'.
      APPEND WA_ITAB TO ITAB2.
    ENDIF.

    CLEAR : WA_ITAB, LA_COMP.
    SORT ITAB2 BY ZFIELDNAME.

    LOOP AT ITAB2. "INTO WA_ITAB.
      CLEAR : LS_TABIX.
      LS_TABIX = SY-TABIX.

      IF LS_TABIX = 1 OR LS_TABIX = 2 OR LS_TABIX = 3 OR LS_TABIX = 4 .
*   Element Description
        LO_ELEMENT ?= CL_ABAP_ELEMDESCR=>DESCRIBE_BY_NAME( 'CHAR20' ).
*   Field name
        MOVE ITAB2-ZFIELDNAME TO LA_COMP-NAME.
*
*   Field type character
        LA_COMP-TYPE = CL_ABAP_ELEMDESCR=>GET_C(
                          P_LENGTH   = LO_ELEMENT->LENGTH ).
*
*   Filling the component table
        APPEND LA_COMP TO LT_TOT_COMP.
        CLEAR: LA_COMP.

      ELSE.

*   Element Description
        LO_ELEMENT ?= CL_ABAP_ELEMDESCR=>DESCRIBE_BY_NAME( 'ZQMIC' ).
*
*   Field name
        MOVE ITAB2-ZFIELDNAME TO LA_COMP-NAME.
*    *   Field type character
        LA_COMP-TYPE = CL_ABAP_ELEMDESCR=>GET_C(
                          P_LENGTH   = LO_ELEMENT->LENGTH ).
*
*   Filling the component table
        APPEND LA_COMP TO LT_TOT_COMP.
        CLEAR: LA_COMP.

      ENDIF.
    ENDLOOP.

    SORT LT_TOT_COMP BY NAME.

* 3. Create a New Type
    LO_NEW_TYPE = CL_ABAP_STRUCTDESCR=>CREATE( LT_TOT_COMP ).

* 4. New Table type
    LO_NEW_TAB = CL_ABAP_TABLEDESCR=>CREATE(
                    P_LINE_TYPE  = LO_NEW_TYPE
                    P_TABLE_KIND = CL_ABAP_TABLEDESCR=>TABLEKIND_STD
                    P_UNIQUE     = ABAP_FALSE ).

* 5. data to handle the new table type
    CREATE DATA LO_DATA TYPE HANDLE LO_NEW_TAB.

* 6. New internal table in the fieldsymbols
    ASSIGN LO_DATA->* TO <F_TAB>.

    CREATE DATA NEW_LINE LIKE LINE OF <F_TAB>.
    ASSIGN NEW_LINE->* TO <LO_LINE>.

    "ASSIGN DATA TO TABLE <F_TAB>
    SORT ITEMP2 BY MAT PNAME." MERKNR.
    SORT ITEMP BY MAT MERKNR.
    LOOP AT ITEMP.
      ASSIGN COMPONENT 'MATERIAL' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      <F_FIELD> = ITEMP-ZZCODE.

      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      <F_FIELD> = ITEMP-PNAME.

      ASSIGN COMPONENT 'TMAX' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      CONDENSE ITEMP-CMAX.      MOVE ITEMP-CMAX TO <F_FIELD>.

      ASSIGN COMPONENT 'TMIN' OF STRUCTURE <LO_LINE> TO <F_FIELD>.
      CONDENSE ITEMP-CMIN.      MOVE ITEMP-CMIN TO <F_FIELD>.

      LOOP AT ITEMP2 WHERE MAT = ITEMP-MAT AND PNAME = ITEMP-PNAME.
        ASSIGN COMPONENT ITEMP2-ZFIELDNAME OF STRUCTURE <LO_LINE> TO <F_FIELD>.
        CONDENSE ITEMP2-CVALUE. MOVE ITEMP2-CVALUE TO <F_FIELD>.
      ENDLOOP.

      INSERT <LO_LINE> INTO TABLE <F_TAB>.
      CLEAR <LO_LINE>.
    ENDLOOP.
  ENDIF.

*...............Displaying using SALV model...................*
  DATA: LO_REPORT TYPE REF TO LCL_REPORT.

  CREATE OBJECT LO_REPORT.
  LO_REPORT->GENERATE_OUTPUT( ).

*...............End Displaying using SALV model...............*

ENDFORM.                    " CREATEDINAMICIT


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
      T_OUTTAB                = ITAB
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL


*&---------------------------------------------------------------------*
*&      Form  F_GET_BATCH_JR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_BATCH_JR .

  REFRESH IT_JR.

  SELECT DISTINCT AUFM~CHARG AS BATCHSR
    AUFM~AUFNR AS ORDERSR
    AFPO~AUFNR AS ORDERRF
    INTO CORRESPONDING FIELDS OF TABLE IT_JR
    FROM AUFM
    JOIN AFPO ON AUFM~AUFNR = AFPO~MILL_OC_AUFNR_U
     WHERE AUFM~CHARG = ITEMPJR-BATCH
    AND AUFM~BWART = '101'.

  SORT IT_JR BY BATCHSR ORDERSR.
  DELETE ADJACENT DUPLICATES FROM IT_JR COMPARING BATCHSR ORDERSR.

  CLEAR IS_TRUE.
  LOOP AT IT_JR.

    SELECT SINGLE MSEG~CHARG AS BATCHJR
      MSEG~MATNR AS MATJR
      MARA~MATKL AS MATKL
      INTO (IT_JR-BATCHJR, IT_JR-MATJR, IT_JR-MATKL)
      FROM MSEG
      JOIN MARA ON MSEG~MATNR = MARA~MATNR
      WHERE MSEG~AUFNR = IT_JR-ORDERRF
      AND MSEG~BWART = '261'.

    IF IT_JR-MATKL BETWEEN '400001' AND '400100'.
      IS_TRUE = 'X'.
    ENDIF.

    MODIFY IT_JR.
  ENDLOOP.

  WHILE IS_TRUE NE 'X'.
    REFRESH IT_TEMPJR.
    IT_TEMPJR[] = IT_JR[].
    REFRESH IT_JR.

*--  update by ALF at 22-09-2014
    LOOP AT IT_TEMPJR WHERE BATCHJR NE ''.
    ENDLOOP.

    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.
*-

    SELECT DISTINCT AUFM~CHARG AS BATCHSR
    AUFM~AUFNR AS ORDERSR
    AFPO~AUFNR AS ORDERRF
    INTO CORRESPONDING FIELDS OF TABLE IT_JR
    FROM AUFM
    JOIN AFPO ON AUFM~AUFNR = AFPO~MILL_OC_AUFNR_U
      FOR ALL ENTRIES IN IT_TEMPJR
     WHERE AUFM~CHARG = IT_TEMPJR-BATCHJR
    AND AUFM~BWART = '101'.

    SORT IT_JR BY BATCHSR ORDERSR.
    DELETE ADJACENT DUPLICATES FROM IT_JR COMPARING BATCHSR ORDERSR.

    LOOP AT IT_JR.

      SELECT SINGLE AUFM~CHARG AS BATCHJR
        AUFM~MATNR AS MATJR
        MARA~MATKL AS MATKL
        INTO (IT_JR-BATCHJR, IT_JR-MATJR, IT_JR-MATKL)
        FROM AUFM
        JOIN MARA ON AUFM~MATNR = MARA~MATNR
        WHERE AUFM~AUFNR = IT_JR-ORDERRF
        AND AUFM~BWART = '261'.

*--  update by ALF at 01-09-2014
      IF SY-SUBRC NE 0.
        IS_TRUE = 'X'.
      ENDIF.

      IF IT_JR-MATKL BETWEEN '400001' AND '400100'.
        IS_TRUE = 'X'.
      ENDIF.

      MODIFY IT_JR.
    ENDLOOP.
  ENDWHILE.

ENDFORM.                    " F_GET_BATCH_JRTABLES


*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_JR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GETDATA_JR .

  SELECT
    QALS~PRUEFLOS   AS IL
    QALS~ENSTEHDAT  AS ENSTEHDAT
    QALS~MATNR      AS MAT
    QALS~CHARG      AS BATCH
    QALS~WERK       AS WERKS
    QAMV~MERKNR     AS MERKNR
    QAMV~KURZTEXT   AS PNAME
    QAMV~VORGLFNR   AS VORGLFNR
    QAMR~MITTELWERT AS PVALUE
    MAKT~MAKTX      AS MAKTX
    FROM QALS
    JOIN MAKT ON QALS~MATNR = MAKT~MATNR
    JOIN QAMV ON QALS~PRUEFLOS = QAMV~PRUEFLOS
    JOIN QAMR ON QAMV~PRUEFLOS = QAMR~PRUEFLOS
    AND QAMV~MERKNR = QAMR~MERKNR
    INTO CORRESPONDING FIELDS OF TABLE ITAB
    WHERE QALS~MATNR   IN PMATNR
    AND QALS~ART = 'Z02'
    AND QALS~MATNR     LIKE 'JR%'
    AND QALS~ENSTEHDAT IN PDATE
     AND QALS~WERK     IN PPLANT
    AND QALS~CHARG     IN PCHARG
    AND QALS~MATNR     IN PMATNR
    AND QALS~STAT14 = 'X'
    AND MAKT~SPRAS = 'E' .

ENDFORM.                    " F_GETDATA_JR


*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_SR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GETDATA_SR .
  SELECT
    QALS~PRUEFLOS   AS IL
    QALS~ENSTEHDAT  AS ENSTEHDAT
    QALS~MATNR      AS MAT
    QALS~CHARG      AS BATCH
    QALS~WERK       AS WERKS
    QAMV~KURZTEXT   AS PNAME
    QAMV~VORGLFNR AS VORGLFNR
    QAMV~MERKNR AS MERKNR
    QAMR~MITTELWERT AS PVALUE
    QAMR~MAXWERT AS ZMAX
    QAMR~MINWERT AS ZMIN
    MAKT~MAKTX      AS MAKTX
    FROM QALS
    JOIN QAMV ON QALS~PRUEFLOS = QAMV~PRUEFLOS
    JOIN ZQM_LOG_GS ON QALS~PRUEFLOS = ZQM_LOG_GS~PRUEFLOS
     AND QALS~CHARG = ZQM_LOG_GS~CHARGAS
    JOIN QAMR ON QAMV~PRUEFLOS = QAMR~PRUEFLOS
    AND QAMV~MERKNR = QAMR~MERKNR
    JOIN MAKT ON QALS~MATNR = MAKT~MATNR
    INTO CORRESPONDING FIELDS OF TABLE ITAB
    WHERE QALS~MATNR   IN PMATNR
    AND QALS~MATNR     LIKE 'SR%'
    AND QALS~ART = 'Z04'
    AND QALS~ENSTEHDAT IN PDATE
    AND QALS~WERK     IN PPLANT
    AND QALS~CHARG     IN PCHARG
    AND QALS~STAT14 = 'X'
    AND MAKT~SPRAS = 'E'
      AND ZQM_LOG_GS~PREF NE ''
      .
ENDFORM.                    " F_GETDATA_SR


*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_AGING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GETDATA_AGING .
  SELECT
    QALS~PRUEFLOS   AS IL
    QALS~ENSTEHDAT  AS ENSTEHDAT
    QALS~MATNR      AS MAT
    QALS~CHARG      AS BATCH
    QALS~WERK       AS WERKS
    QAMV~KURZTEXT   AS PNAME
    QAMV~VORGLFNR AS VORGLFNR
    QAMV~MERKNR AS MERKNR
    QAMR~MITTELWERT AS PVALUE
    MAKT~MAKTX      AS MAKTX
    FROM QALS
    JOIN MAKT ON QALS~MATNR = MAKT~MATNR
    JOIN QAMV ON QALS~PRUEFLOS = QAMV~PRUEFLOS
    JOIN QAMR ON QAMV~PRUEFLOS = QAMR~PRUEFLOS
    AND QAMV~MERKNR = QAMR~MERKNR
    INTO CORRESPONDING FIELDS OF TABLE ITAB
    WHERE QALS~MATNR   IN PMATNR
    AND QALS~ART = 'Z03'
    AND QALS~MATNR     LIKE 'JR%'
    AND QALS~ENSTEHDAT IN PDATE
    AND QALS~WERK     IN PPLANT
    AND QALS~CHARG     IN PCHARG
    AND QALS~STAT14 = 'X'
      AND MAKT~SPRAS = 'E'
      .
ENDFORM.                    " F_GETDATA_AGING


*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_MIXING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GETDATA_MIXING .
  SELECT QALS~PRUEFLOS   AS IL
    QALS~ENSTEHDAT  AS ENSTEHDAT
    QALS~MATNR      AS MAT
    QALS~CHARG      AS BATCH
    QALS~WERK       AS WERKS
    QALS~AUFNR      AS AUFNR
    QALS~SELMATNR AS MAKTX
    QAMV~KURZTEXT   AS PNAME
    QAMV~MERKNR AS MERKNR
    QAMR~MITTELWERT AS PVALUE
    QAMV~VORGLFNR AS VORGLFNR
    FROM QALS
    JOIN QAMV ON QALS~PRUEFLOS = QAMV~PRUEFLOS
    JOIN QAMR ON QAMV~PRUEFLOS = QAMR~PRUEFLOS
    AND QAMV~MERKNR = QAMR~MERKNR
    INTO CORRESPONDING FIELDS OF TABLE ITAB
    WHERE QALS~MATNR   IN PMATNR
    AND QALS~ART = 'Z01'
    AND QALS~ENSTEHDAT IN PDATE
     AND QALS~WERK     IN PPLANT
    AND QALS~STAT14 = 'X'
    .
ENDFORM.                    " F_GETDATA_MIXING


*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GETDATA_CHAR .
  REFRESH ITCHAR.
  ITCHAR[] = ITAB[].

  SORT ITCHAR BY MAT BATCH.
  DELETE ADJACENT DUPLICATES FROM ITCHAR COMPARING MAT BATCH.

  LOOP AT ITCHAR.
    CALL FUNCTION 'ZCHAR_ZQM005'
      EXPORTING
        I_VAL_MATNR  = ITCHAR-MAT
        I_VAL_CHARGE = ITCHAR-BATCH
      TABLES
        T_VAL_TAB    = ZCHARACTER
      EXCEPTIONS
        NO_OBJECT    = 1
        NO_VALUES    = 2
        OTHERS       = 3.

    READ TABLE ZCHARACTER WITH KEY ATNAM = 'ZZNOMORROLL'.
    IF SY-SUBRC = 0.
      ITCHAR-ZZNOMORROLL =  ZCHARACTER-ATWRT.
    ENDIF.

    READ TABLE ZCHARACTER WITH KEY ATNAM = 'ZZCODE'.
    IF SY-SUBRC = 0.
      ITCHAR-ZZCODE =  ZCHARACTER-ATWTB.
    ENDIF.

    READ TABLE ZCHARACTER WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC = 0.
      MOVE ZCHARACTER-ATFLV TO  ITCHAR-ZZLENGTH.
    ENDIF.

    READ TABLE ZCHARACTER WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC = 0.
      MOVE ZCHARACTER-ATFLV TO  ITCHAR-ZZWIDTH.
    ENDIF.

    READ TABLE ZCHARACTER WITH KEY ATNAM = 'ZZPRODLINE'.
    IF SY-SUBRC = 0.
      ITCHAR-ZZPRODLINE =  ZCHARACTER-ATWRT.
    ENDIF.

    MODIFY ITCHAR.
  ENDLOOP.
ENDFORM.                    " F_GETDATA_CHAR


*&---------------------------------------------------------------------*
*&      Form  F_GET_CONDITION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_CONDITION .
  LOOP AT IT_JR WHERE MATKL BETWEEN '400001' AND '400100'.
    IS_TRUE = 'X'.
    EXIT.
  ENDLOOP.
ENDFORM.                    " F_GET_CONDITION


*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Sembunyikan tombol RTYPE3 jika tidak ada otorisasi
*       Persis meniru logika ZPPR_SLITTING_REKAP_DAILY
*----------------------------------------------------------------------*
FORM F_MODIFY_SCREEN .
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'RTYPE3'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN


*&---------------------------------------------------------------------*
*&      Form  F_PUSH_TO_SQL_DB
*&---------------------------------------------------------------------*
*       Menghubungkan SAP ke Database MS SQL Server via DBCO (TRIASDB05)
*       Target: Staging dbo.XQM005_SR lalu Trigger EXEC SP_Merge_ZQM005_SR
*----------------------------------------------------------------------*
FORM F_PUSH_TO_SQL_DB .
  CONSTANTS: C_DBCON TYPE DBCON-CON_NAME VALUE 'TRIASDB05',
             C_TABLE TYPE STRING VALUE 'dbo.XQM005_SR'.

  DATA: LO_CON        TYPE REF TO CL_SQL_CONNECTION,
        LO_STMT       TYPE REF TO CL_SQL_STATEMENT,
        LX_SQL        TYPE REF TO CX_SQL_EXCEPTION,
        LV_SQL        TYPE STRING,
        LV_INS_HEADER TYPE STRING,
        LV_VAL_BLOCK  TYPE STRING,
        LV_MODE(10)   TYPE C,
        LV_DATE_L(10) TYPE C,
        LV_DATE_H(10) TYPE C,
        LV_TOTAL_ROWS TYPE I,
        LV_DELETED    TYPE I,
        LV_INSERTED   TYPE I,
        LV_BATCH_CNT  TYPE I,
        LV_ERR_TEXT   TYPE STRING,
        LV_WIDTH_STR(20)  TYPE C,
        LV_LENGTH_STR(20) TYPE C,
        LV_ROW_DATE(10)   TYPE C,
        LV_WIDTH_VAL  TYPE STRING,
        LV_LENGTH_VAL TYPE STRING,
        LV_MAT        TYPE STRING,
        LV_WERKS      TYPE STRING,
        LV_LINE       TYPE STRING,
        LV_CODE       TYPE STRING,
        LV_NOJR       TYPE STRING,
        LV_BATCHJR    TYPE STRING,
        LV_NOSR       TYPE STRING,
        LV_BATCHSR    TYPE STRING,
        LV_PNAME      TYPE STRING,
        LV_CMIN       TYPE STRING,
        LV_CMAX       TYPE STRING,
        LV_CVALUE     TYPE STRING,
        LV_SINGLE_VAL TYPE STRING.

  LV_TOTAL_ROWS = LINES( ITAB ).

  " 1. Tentukan Mode Transaksi
  IF RM = 'X'.
    LV_MODE = 'MIXING'.
  ELSEIF R2 = 'X'.
    LV_MODE = 'SR'.
  ELSEIF R1 = 'X'.
    LV_MODE = 'JR'.
  ELSE.
    LV_MODE = 'AGING'.
  ENDIF.

  " 2. Format Rentang Tanggal
  CONCATENATE PDATE-LOW+0(4) '-' PDATE-LOW+4(2) '-' PDATE-LOW+6(2) INTO LV_DATE_L.
  IF PDATE-HIGH IS NOT INITIAL.
    CONCATENATE PDATE-HIGH+0(4) '-' PDATE-HIGH+4(2) '-' PDATE-HIGH+6(2) INTO LV_DATE_H.
  ELSE.
    LV_DATE_H = LV_DATE_L.
  ENDIF.

  TRY.
      " 3. Buka Koneksi ke Database Eksternal via DBCO (TRIASDB05)
      LO_CON = CL_SQL_CONNECTION=>GET_CONNECTION( C_DBCON ).
      LO_STMT = LO_CON->CREATE_STATEMENT( ).

      " 4. Bersihkan Tabel Staging Sebelum Batch Ingestion
      CONCATENATE 'DELETE FROM' C_TABLE INTO LV_SQL SEPARATED BY SPACE.
      LV_DELETED = LO_STMT->EXECUTE_UPDATE( LV_SQL ).

      " 5. Siapkan Header Query INSERT INTO
      CONCATENATE 'INSERT INTO' C_TABLE
                  '([Inspection Date], [Inspection Lot], [Plant], [Line], [Material],'
                  ' [Film Type], [No JR], [Batch JR], [No SR], [Batch SR],'
                  ' [Width], [Length], [Inspection Characteristic], [Std Min], [Std Max], [Mean Value])'
                  'VALUES'
             INTO LV_INS_HEADER SEPARATED BY SPACE.

      " 6. Lakukan Batched Multi-Row INSERT (Per paket 100 baris untuk performa tinggi)
      CLEAR: LV_SQL, LV_VAL_BLOCK, LV_BATCH_CNT, LV_INSERTED.

      LOOP AT ITAB.
        CLEAR: LV_WIDTH_STR, LV_LENGTH_STR, LV_ROW_DATE,
               LV_WIDTH_VAL, LV_LENGTH_VAL, LV_MAT, LV_WERKS, LV_LINE,
               LV_CODE, LV_NOJR, LV_BATCHJR, LV_NOSR, LV_BATCHSR,
               LV_PNAME, LV_CMIN, LV_CMAX, LV_CVALUE, LV_SINGLE_VAL.

        " Escape karakter petik satu (') pada teks agar kueri SQL valid
        LV_MAT = ITAB-MAT.
        REPLACE ALL OCCURRENCES OF '''' IN LV_MAT WITH ''''''.
        CONDENSE LV_MAT.

        LV_WERKS = ITAB-WERKS.
        CONDENSE LV_WERKS.

        LV_LINE = ITAB-ZZPRODLINE.
        REPLACE ALL OCCURRENCES OF '''' IN LV_LINE WITH ''''''.
        CONDENSE LV_LINE.

        LV_CODE = ITAB-ZZCODE.
        REPLACE ALL OCCURRENCES OF '''' IN LV_CODE WITH ''''''.
        CONDENSE LV_CODE.

        LV_NOJR = ITAB-ZZNOROLLJR.
        REPLACE ALL OCCURRENCES OF '''' IN LV_NOJR WITH ''''''.
        CONDENSE LV_NOJR.

        LV_BATCHJR = ITAB-BATCHJR.
        REPLACE ALL OCCURRENCES OF '''' IN LV_BATCHJR WITH ''''''.
        CONDENSE LV_BATCHJR.

        LV_NOSR = ITAB-ZZNOMORROLL.
        REPLACE ALL OCCURRENCES OF '''' IN LV_NOSR WITH ''''''.
        CONDENSE LV_NOSR.

        LV_BATCHSR = ITAB-BATCH.
        REPLACE ALL OCCURRENCES OF '''' IN LV_BATCHSR WITH ''''''.
        CONDENSE LV_BATCHSR.

        LV_PNAME = ITAB-PNAME.
        REPLACE ALL OCCURRENCES OF '''' IN LV_PNAME WITH ''''''.
        CONDENSE LV_PNAME.

        LV_CMIN = ITAB-CMIN.
        REPLACE ALL OCCURRENCES OF '''' IN LV_CMIN WITH ''''''.
        CONDENSE LV_CMIN.

        LV_CMAX = ITAB-CMAX.
        REPLACE ALL OCCURRENCES OF '''' IN LV_CMAX WITH ''''''.
        CONDENSE LV_CMAX.

        LV_CVALUE = ITAB-CVALUE.
        REPLACE ALL OCCURRENCES OF '''' IN LV_CVALUE WITH ''''''.
        CONDENSE LV_CVALUE.

        " Format Width & Length (Tipe C)
        IF ITAB-ZZWIDTH <> 0.
          WRITE ITAB-ZZWIDTH TO LV_WIDTH_STR NO-GROUPING EXPONENT 0 DECIMALS 2.
          CONDENSE LV_WIDTH_STR.
          CONCATENATE '''' LV_WIDTH_STR '''' INTO LV_WIDTH_VAL.
        ELSE.
          LV_WIDTH_VAL = 'NULL'.
        ENDIF.

        IF ITAB-ZZLENGTH <> 0.
          WRITE ITAB-ZZLENGTH TO LV_LENGTH_STR NO-GROUPING EXPONENT 0 DECIMALS 2.
          CONDENSE LV_LENGTH_STR.
          CONCATENATE '''' LV_LENGTH_STR '''' INTO LV_LENGTH_VAL.
        ELSE.
          LV_LENGTH_VAL = 'NULL'.
        ENDIF.

        " Format Tanggal ISO-8601 YYYY-MM-DD
        CONCATENATE ITAB-ENSTEHDAT+0(4) '-' ITAB-ENSTEHDAT+4(2) '-' ITAB-ENSTEHDAT+6(2) INTO LV_ROW_DATE.

        " Bangun Baris Values (...) sesuai 16 kolom skema Tim OLAP
        CONCATENATE '(''' LV_ROW_DATE ''',''' ITAB-IL ''',''' LV_WERKS ''',''' LV_LINE ''',''' LV_MAT ''','
                    '''' LV_CODE ''',''' LV_NOJR ''',''' LV_BATCHJR ''',''' LV_NOSR ''',''' LV_BATCHSR ''','
                    LV_WIDTH_VAL ',' LV_LENGTH_VAL ',N''' LV_PNAME ''',''' LV_CMIN ''',''' LV_CMAX ''',''' LV_CVALUE ''')'
               INTO LV_SINGLE_VAL.

        IF LV_VAL_BLOCK IS INITIAL.
          LV_VAL_BLOCK = LV_SINGLE_VAL.
        ELSE.
          CONCATENATE LV_VAL_BLOCK ',' LV_SINGLE_VAL INTO LV_VAL_BLOCK.
        ENDIF.

        LV_BATCH_CNT = LV_BATCH_CNT + 1.
        LV_INSERTED  = LV_INSERTED + 1.

        " Eksekusi batch per 100 baris
        IF LV_BATCH_CNT >= 100.
          CONCATENATE LV_INS_HEADER LV_VAL_BLOCK INTO LV_SQL SEPARATED BY SPACE.
          LO_STMT->EXECUTE_UPDATE( LV_SQL ).
          CLEAR: LV_VAL_BLOCK, LV_BATCH_CNT.
        ENDIF.
      ENDLOOP.

      " Eksekusi sisa baris terakhir
      IF LV_VAL_BLOCK IS NOT INITIAL.
        CONCATENATE LV_INS_HEADER LV_VAL_BLOCK INTO LV_SQL SEPARATED BY SPACE.
        LO_STMT->EXECUTE_UPDATE( LV_SQL ).
      ENDIF.

      " 7. Eksekusi Stored Procedure Merge ke Z Table jika tersedia di database
      LV_SQL = 'IF OBJECT_ID(''[dbo].[SP_Merge_ZQM005_SR]'', ''P'') IS NOT NULL EXEC [dbo].[SP_Merge_ZQM005_SR];'.
      LO_STMT->EXECUTE_UPDATE( LV_SQL ).

      " 8. Commit transaksi SQL
      LO_CON->COMMIT( ).
      LO_CON->CLOSE( ).

      " Cetak Log Hasil Eksekusi
      IF SY-BATCH = 'X'.
        WRITE: / '========================================================================',
               / 'STATUS: PUSH DATA ZQM005 KE DATABASE SQL SERVER (TRIASDB05) BERHASIL!',
               / 'Koneksi DBCO        :', C_DBCON,
               / 'Tabel Staging SQL   :', C_TABLE,
               / 'Mode Pengujian      :', LV_MODE,
               / 'Periode Tanggal     :', LV_DATE_L, 's/d', LV_DATE_H,
               / 'Baris Masuk Staging :', LV_INSERTED,
               / 'Merge Procedure     : [dbo].[SP_Merge_ZQM005_SR] (Executed)',
               / 'Waktu Selesai       :', SY-DATUM, SY-UZEIT,
               / '========================================================================'.
      ELSE.
        DATA: LV_MSG TYPE STRING.
        LV_MSG = |Sukses push { LV_INSERTED } baris ke { C_TABLE } & execute SP_Merge_ZQM005_SR|.
        MESSAGE LV_MSG TYPE 'S'.
      ENDIF.

    CATCH CX_SQL_EXCEPTION INTO LX_SQL.
      IF LO_CON IS BOUND.
        LO_CON->ROLLBACK( ).
        LO_CON->CLOSE( ).
      ENDIF.
      LV_ERR_TEXT = LX_SQL->GET_TEXT( ).
      IF SY-BATCH = 'X'.
        WRITE: / '========================================================================',
               / 'ERROR: GAGAL MENGHUBUNGKAN ATAU INSERT KE SQL SERVER!',
               / 'Pesan Error SQL :', LV_ERR_TEXT,
               / '========================================================================'.
      ELSE.
        MESSAGE LV_ERR_TEXT TYPE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.                    " F_PUSH_TO_SQL_DB
