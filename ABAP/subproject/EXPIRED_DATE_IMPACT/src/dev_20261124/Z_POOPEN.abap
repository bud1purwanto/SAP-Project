*&---------------------------------------------------------------------*
*& Report  Z_POOPEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_POOPEN.

*&---------------------------------------------------------------------*
*& Report  Z_COBA_HU
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE ZABAPALV.
INCLUDE Z_PROG_INFO.

TABLES : T300, T300T, T001W, T001L, TJ30T, TVAK, TVAKT, MARA, VEKP, MCHA, VBAK, VBAP, LEIN.

DATA : SAP_CON LIKE DBCON-CON_NAME VALUE 'TRIASDB',
       DBTYPE TYPE DBCON_DBMS.

TYPES :
 BEGIN OF IT_HU,
  BOX(1),
  WERKS LIKE VEPO-WERKS,
  LGORT LIKE VEPO-LGORT,
  LGNUM LIKE LEIN-LGNUM,
  LGPLA LIKE LEIN-LGPLA,
  EXIDV LIKE VEKP-EXIDV,
  ZEXIDV LIKE VEKP-EXIDV,
  ZZEXIDV LIKE VEKP-EXIDV,
  VENUM LIKE VEPO-VENUM,
  UEVEL LIKE VEKP-UEVEL,
  UNVEL LIKE VEPO-UNVEL,
  MATNR LIKE VEPO-MATNR,
  CHARG LIKE VEPO-CHARG,
  MAGRV LIKE VEKP-MAGRV,
  SOBKZ LIKE VEPO-SOBKZ,
  ZZNOMORROLL(30),
  ZZTYPE(30),
  ZZTHICKNESS(30),
  ZZWIDTH(30),
  ZZLENGTH(30),
*  ZZGRADE(20),
  VEMNG LIKE VEPO-VEMNG,
  ZQTYROL TYPE P,
  ZZTREATMENT(30),
  ZZALIAS(30),
  ZZCORE(30),
  ZZPACKING(30),
  ZZCODE(20),
  ZZCRITERIA(30),
  ZZEXPIREDLIVE TYPE SY-DATUM,
  BESTQ LIKE VEPO-BESTQ,
  TXT04 LIKE TJ30T-TXT04,
  ERDAT LIKE VEKP-ERDAT,
  WDATU LIKE VEPO-WDATU,
*  ZZEXPR LIKE SY-DATUM,
  ERSDA LIKE MCH1-ERSDA,
  BSTKD LIKE VBKD-BSTKD,
  BEZEI LIKE TVAKT-BEZEI,
  NAME1 LIKE KNA1-NAME1,
  SONUM LIKE VEPO-SONUM,
  VBELN LIKE VBAK-VBELN,
  POSNR LIKE VBAP-POSNR,
  AUART LIKE VBAK-AUART,
  PSTYV LIKE VBAP-PSTYV,
  ZVBELN LIKE LIKP-VBELN,
  ZPOSNR LIKE LIPS-POSNR,
  VDATU LIKE VBAK-VDATU,
  KUNNR LIKE KNA1-KUNNR,
  ZFBDT LIKE BSID-ZFBDT,
  ZBD1T LIKE BSID-ZBD1T,
  ZZBLOCK(10),
  ZNAME1 LIKE KNA1-NAME1,
  ZERDAT LIKE VEKP-ERDAT,
  ERUHR LIKE VEKP-ERUHR,
  ZPINUM(20),
  DELUS(50),
  LINE_COLOR(4),
END OF IT_HU.

TYPES :
 BEGIN OF IT_VEKP,
   EXIDV LIKE VEKP-EXIDV,
   MAGRV LIKE VEKP-MAGRV,
   VENUM LIKE VEPO-VENUM,
   UNVEL LIKE VEPO-UNVEL,
   CHARG LIKE VEPO-CHARG,
END OF IT_VEKP.

TYPES :
  BEGIN OF IT_CHARG,
   MATNR LIKE MCHA-MATNR,
   WERKS LIKE MCHA-WERKS,
   CHARG LIKE MCHA-CHARG,
  END OF IT_CHARG.


TYPES :
BEGIN OF IT_AUART,
  AUART LIKE VBAK-AUART,
  BEZEI LIKE TVAKT-BEZEI,
END OF IT_AUART.


TYPES :
  BEGIN OF IT_VBELN,
   VBELN LIKE VBAK-VBELN,
  END OF IT_VBELN.

TYPES :
BEGIN OF IT_LGNUM,
   LGNUM LIKE T300-LGNUM,
   LNUMT LIKE T300T-LNUMT,
END OF IT_LGNUM.

TYPES :
BEGIN OF IT_MSEG,
  MBLNR LIKE MSEG-MBLNR,
  BUDAT LIKE MKPF-BUDAT,
  LGORT LIKE MSEG-LGORT,
END OF IT_MSEG.

"- Table for Credit Block
TYPES :
BEGIN OF IT_BSID,
  KUNNR LIKE BSID-KUNNR,
  ZFBDT LIKE BSID-ZFBDT,
  ZBD1T LIKE BSID-ZBD1T,
  WRBTR LIKE BSID-WRBTR,
  SHKZG LIKE BSID-SHKZG,
  DUEDT TYPE SY-DATUM,
END OF IT_BSID.


DATA : IT_HU TYPE STANDARD TABLE OF IT_HU WITH HEADER LINE,
       IT_VEKP TYPE STANDARD TABLE OF IT_VEKP WITH HEADER LINE,
       IT_VEKP_TEMP TYPE STANDARD TABLE OF IT_VEKP WITH HEADER LINE,
       IT_LINE TYPE STANDARD TABLE OF TLINE WITH HEADER LINE,
       IT_XVBPA TYPE STANDARD TABLE OF VBPAVB WITH HEADER LINE,
       IT_XVBADR TYPE STANDARD TABLE OF SADRVB WITH HEADER LINE,
       IT_ENTRIES TYPE STANDARD TABLE OF VTENTRIES WITH HEADER LINE,
       IT_TEMP TYPE STANDARD TABLE OF VTENTRIES WITH HEADER LINE,
       WA_TEMP TYPE STANDARD TABLE OF VTENTRIES WITH HEADER LINE,
       IT_CHARG TYPE STANDARD TABLE OF IT_CHARG WITH HEADER LINE,
       IT_MSEG TYPE STANDARD TABLE OF IT_MSEG WITH HEADER LINE,
       IT_MKPF TYPE STANDARD TABLE OF IT_MSEG WITH HEADER LINE,
       IT_AUART TYPE STANDARD TABLE OF IT_AUART WITH HEADER LINE,
       IT_VBELN TYPE STANDARD TABLE OF IT_VBELN WITH HEADER LINE,
       IT_LGNUM TYPE STANDARD TABLE OF IT_LGNUM WITH HEADER LINE,
       IT_BSID TYPE STANDARD TABLE OF IT_BSID WITH HEADER LINE,
       IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.

FIELD-SYMBOLS  : <FS_HU> LIKE LINE OF IT_HU,
                <FS_VEKP> LIKE LINE OF IT_VEKP,
                <FS_VEKP_TEMP> LIKE LINE OF IT_VEKP,
                <FS_LINE> LIKE LINE OF IT_LINE,
                <FS_XVBPA> LIKE LINE OF IT_XVBPA ,
                <FS_XVBADR> LIKE LINE OF IT_XVBADR,
                <FS_ENTRIES> LIKE LINE OF IT_ENTRIES,
                <FS_TEMP> LIKE LINE OF IT_TEMP,
                <FS_WA_TEMP> LIKE LINE OF IT_TEMP,
                <FS_CHARG> LIKE LINE OF IT_CHARG,
                <FS_MSEG> LIKE LINE OF IT_MSEG,
                <FS_MKPF> LIKE LINE OF IT_MKPF,
                <FS_AUART> LIKE LINE OF IT_AUART,
                <FS_VBELN> LIKE LINE OF IT_VBELN,
                <FS_LGNUM> LIKE LINE OF IT_LGNUM,
                <FS_BSID> LIKE LINE OF IT_BSID,
                <FS_CHAR> LIKE LINE OF IT_CHAR.

DATA : ATFLV1 TYPE P LENGTH 5 DECIMALS 1,
       ATFLV2 TYPE P LENGTH 5 DECIMALS 0.

DATA : V_KULAB LIKE MSKU-KULAB,
       V_LBLAB LIKE MSLB-LBLAB.

DATA : V_EXIDV LIKE VEKP-EXIDV.
DATA : V_EXIDV2 LIKE VEKP-EXIDV.

DATA : V_ZZEXIDV LIKE VEKP-EXIDV.
DATA : V_ZZEXIDV2 LIKE VEKP-EXIDV.

DATA : V_VENUM LIKE VEKP-VENUM.
DATA : V_UNVEL LIKE VEPO-UNVEL.
DATA : V_VBELV LIKE THEAD-TDNAME.
DATA : V_OBJNR LIKE HUSSTAT-OBJNR.
DATA : V_BLOCK TYPE I.
DATA : V_STATUS LIKE VEKP-STATUS.
DATA : V_VTLINENO LIKE VTENTRIES-VTLINENO.
DATA : V_VTVALUE  LIKE VTENTRIES-VTVALUE.
DATA : FLAG(1).
DATA : V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZBAP_READY_REPORT'.

DATA : TVALUES LIKE USVALUES OCCURS 0 WITH HEADER LINE.
DATA : VON TYPE XUVAL.
DATA : V_TEXT1(60),
       NUMBER1 TYPE P,
       NUMBER2 TYPE P.

DATA : V_PERCENT TYPE P,
       LINE TYPE P.
"--------------------------------ADDITIONAL VARIABLE---------------
DATA : BEGIN OF IT_HUPARENTS,
        EXIDV LIKE VEKP-EXIDV, "EXTERNAL HU NO
        MAGRV LIKE VEKP-MAGRV, "MATERIAL GROUP PACK MATS
        VENUM LIKE VEPO-VENUM, "INTERNAL HU NO
        UEVEL LIKE VEKP-UEVEL, "HIGH LEVEL
       END OF IT_HUPARENTS.

"--------------------------------SELECTION SCREEN------------------
SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : S_LGNUM FOR T300-LGNUM,
                 S_WERKS FOR T001W-WERKS OBLIGATORY,
                 S_LGORT FOR T001L-LGORT OBLIGATORY,
                 S_LGPLA FOR LEIN-LGPLA,
                 S_MATNR FOR MARA-MATNR OBLIGATORY,
                 S_EXIDV FOR VEKP-EXIDV,
                 S_CHARG FOR MCHA-CHARG.
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS : S_VBELN FOR VBAK-VBELN,
                 S_POSNR FOR VBAP-POSNR,
                 S_AUART FOR TVAK-AUART.
SELECTION-SCREEN END OF BLOCK BLOCK2.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-003.
PARAMETERS: P1 RADIOBUTTON GROUP GRP1,
            P2 RADIOBUTTON GROUP GRP1 DEFAULT 'X'.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.
SELECTION-SCREEN END OF BLOCK BLOCK3.

"--------------------------------START OF SELECTION------------------

START-OF-SELECTION.
  IF P2 = 'X'.
    PERFORM GET_DATA.
    PERFORM DISPLAY_DATA.
  ELSEIF P1 = 'X'.
    PERFORM GET_DATA.
    PERFORM CONNECT_SQL.
    PERFORM EXP_SQL.
  ENDIF.

"--------------------------------AT SELECTION SCREEN------------------
AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

  IF SY-UCOMM = 'ONLI'.
*    PERFORM CHECK_WERKS .
    PERFORM CHECK_LGORT .
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'P1'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  --- xxxxxx------

INITIALIZATION.
  MOVE 'Program Information' TO INFO.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_CHARG-LOW.
  PERFORM GET_F4 USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_CHARG-HIGH.
  PERFORM GET_F4 USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_AUART-LOW.
  PERFORM GET_AUART_F4 USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_AUART-HIGH.
  PERFORM GET_AUART_F4 USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VBELN-LOW.
  PERFORM GET_VBELN_F4 USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VBELN-HIGH.
  PERFORM GET_VBELN_F4 USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LGNUM-LOW.
  PERFORM GET_LGNUM_F4 USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LGNUM-HIGH.
  PERFORM GET_LGNUM_F4 USING 'HIGH'.

"--------------------------------FUNCTION F01------------------
FORM GET_DATA.
  "- HU
  IF S_EXIDV[] IS NOT INITIAL.
    SELECT
    VEKP~EXIDV
    VEKP~MAGRV
    VEPO~VENUM
    VEPO~UNVEL
    INTO CORRESPONDING FIELDS OF TABLE IT_VEKP_TEMP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV.
    SELECT
    VEKP~EXIDV
    VEKP~VENUM
    VEKP~MAGRV
    VEKP~ERUHR
    VEKP~UEVEL
    VEPO~UNVEL
    VEPO~WERKS
    VEPO~LGORT
    VEPO~MATNR
    VEPO~CHARG
    VEPO~SONUM
    VEPO~VEMNG
    VEPO~WDATU
    VEPO~BESTQ
    VEPO~SOBKZ
    VEPO~VBELN AS ZVBELN
    VEPO~POSNR AS ZPOSNR
    INTO CORRESPONDING FIELDS OF TABLE IT_HU
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV
      AND VEPO~WERKS IN S_WERKS
      AND VEPO~LGORT IN S_LGORT
      AND VEPO~MATNR IN S_MATNR
      AND VEPO~CHARG IN S_CHARG.
  ELSE.
    SELECT
    VEKP~EXIDV
    VEKP~VENUM
    VEKP~MAGRV
    VEKP~ERUHR
    VEKP~UEVEL
    VEPO~UNVEL
    VEPO~WERKS
    VEPO~LGORT
    VEPO~MATNR
    VEPO~CHARG
    VEPO~SONUM
    VEPO~VEMNG
    VEPO~WDATU
    VEPO~BESTQ
    VEPO~SOBKZ
    VEPO~VBELN AS ZVBELN
    VEPO~POSNR AS ZPOSNR
    INTO CORRESPONDING FIELDS OF TABLE IT_HU
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE VEPO~WERKS IN S_WERKS
      AND VEPO~LGORT IN S_LGORT
      AND VEPO~MATNR IN S_MATNR
      AND VEPO~CHARG IN S_CHARG.
  ENDIF.
ENDFORM.
FORM DISPLAY_DATA .
  IF IT_HU[] IS INITIAL.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.

ENDFORM.

FORM F_FIELD_CATALOG .
*      VEKP~VENUM
*      VEKP~MAGRV
*      VEKP~UEVEL
*      VEPO~UNVEL
*      VEPO~SONUM
*      VEPO~VBELN AS ZVBELN
*      VEPO~POSNR AS ZPOSNR
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU' :
       'WERKS'   ''  ''  ''  5   'Plant'    ''   ''  ''  '',
       'LGORT'   ''  ''  ''  5   'Sloc'  ''   ''  ''  '',
*       'LGNUM'   ''  ''  ''  8   'Warehouse Number'  ''   ''  ''  '',
*       'LGPLA'   ''  ''  ''  12   'Storage Bin'  ''   ''  ''  '',
*       'ZZEXIDV'   ''  ''  ''  11   'HU Container'  ''   ''  ''  '',
       'EXIDV'   ''  ''  ''  11   'HU Pallet'  ''   ''  ''  '',
*       'ZEXIDV'   ''  ''  '' 11   'HU Box'  ''   ''  ''  '' ,
       'MATNR'   ''  ''  ''  11    'Material Number'    ''   ''  ''  ''.
  PERFORM F_ALV_FIELDCATG_ICON2 USING 'IT_HU' :
      'CHARG'   ''  ''  ''  12   'Batch'  ''   ''  ''  ''.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU' :
*      'ZZNOMORROLL'   ''  ''  ''  15   'Roll Number'   ''   ''  ''  '',
*      'ZZTYPE'   ''  ''  ''  5   'Tipe'  ''   ''  ''  '',
*      'ZZTHICKNESS'   ''  ''  ''  10   'Thickness (micron)'   ''  ''  ''  '',
*      'ZZWIDTH'   ''  ''  ''  10   'Width (mm)'   ''  ''  ''  '',
*      'ZZLENGTH'   ''  ''  ''  12   'Length (M)' ''   ''  ''  '',
*      'ZZCRITERIA'   ''  ''  ''  8   'Criteria Grade'    ''   ''  ''  '',
      'VEMNG'   ''  ''  ''  12   'Weight (KG)'  ''   ''  ''  '',
*      'ZQTYROL'   ''  ''  ''  8   'Qty Roll'  ''   ''  ''  '',
*      'ZZTREATMENT'   ''  ''  ''  15   'Treatment'  ''   ''  ''  '',
*      'ZZCORE'   ''  ''  ''  6   'Core'   ''   ''  ''  '',
*      'ZZPACKING'   ''  ''  ''  18   'Sistem Packing'   ''   ''  ''  '',
      'BESTQ'   ''  ''  ''  16   'Stock Category'   ''   ''  ''  '',
      'SOBKZ'   ''  ''  ''  16   'Special Stock'   ''   ''  ''  '',
*      'TXT04'   ''  ''  '' 10   'QA Status '       ''   ''  ''  '',
      'WDATU'   ''  ''  ''  10   'GR HU Date'  ''   ''  ''  '',
*      'ZZEXPIREDLIVE'   ''  ''  ''  10   'Expired Date'  ''   ''  ''  '',
*      'ERSDA'   ''  ''  ''  10   'Production Date'   ''  ''  ''  '',
*      'BSTKD'   ''  ''  ''  6   'PO Number'   ''  ''  ''  '',
*      'ZPINUM'   ''  ''  ''  6   'PI Number'   ''  ''  ''  '',
*      'BEZEI'   ''  ''  ''  12   'SO Type Description' ''   ''  ''  '',
*      'NAME1'   ''  ''  ''  25   'Customer Name'  ''   ''  ''  '',
*      'VBELN'   ''  ''  ''  12   'SO Number'  ''   ''  ''  '',
*      'POSNR'   ''  ''  ''  7   'SO Item'  ''   ''  ''  '',
*      'VDATU'   ''  ''  ''  10   'Requested Delivery Date'  ''   ''  ''  '',
*      'DELUS'   ''  ''  ''  50   'Requested Delivery Status'  ''   ''  ''  '',
*      'ZZBLOCK'   ''  ''  ''  10   'Credit Blocked' ''   ''  ''  '',
*      'ZNAME1'   ''  ''  ''  20   'Sales Employee'    ''   ''  ''  '',
*      'ERDAT'   ''  ''  ''  12   'HU Created Date'  ''   ''  ''  '',
      'ERUHR'   ''  ''  ''  12   'HU Created On'  ''   ''  ''  ''.
*      'ZZALIAS'  ''  ''  ''  12   'Alias'  ''   ''  ''  ''.


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
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-INFO_FIELDNAME = 'LINE_COLOR'.
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
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
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
      T_OUTTAB                 = IT_HU
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDR_HU'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  SY-LSIND = 0.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  GET_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0017   text
*----------------------------------------------------------------------*
FORM GET_F4  USING    VALUE(P_0017).

  DATA : V_CHARG TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_CHARG.
  REFRESH : IT_CHARG.
  "-GET DATA CHARG
  SELECT
    MCHA~CHARG
    MCHA~MATNR
    MCHA~WERKS
    INTO CORRESPONDING FIELDS OF TABLE IT_CHARG
    FROM MCHA
    INNER JOIN MARA ON MCHA~MATNR = MARA~MATNR
    INNER JOIN VEPO ON MCHA~CHARG = VEPO~CHARG
    INNER JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
      WHERE VEKP~STATUS NE '0050'
        AND VEKP~STATUS NE '0060'
        AND VEKP~STATUS NE '0001'
        AND MARA~MTART EQ 'ZFGS'.

  SORT IT_CHARG ASCENDING BY CHARG.
  DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING CHARG.

  CASE P_0017.
    WHEN 'LOW'.
      V_CHARG = 'S_CHARG-LOW'.
    WHEN 'HIGH'.
      V_CHARG = 'S_CHARG-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'CHARG'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_CHARG
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_CHARG.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.



ENDFORM.                    " GET_F4

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON2 USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-NO_ZERO       = ''.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon

*&---------------------------------------------------------------------*
*&      Form  EXP_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXP_SQL.
  DATA : COUNT TYPE P.

  TRY .
      EXEC SQL.
        DELETE  FROM XZSD012N
      ENDEXEC.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.
    CATCH CX_SY_NATIVE_SQL_ERROR.
      MESSAGE 'Error in procedure execution delete' TYPE 'I'.
      RETURN.
  ENDTRY.

  TRY.
*      COUNT = 0.
      LOOP AT IT_HU ASSIGNING <FS_HU>.
*        COUNT = COUNT + 1.
        EXEC SQL.
          INSERT INTO XZSD012N(ZCOLUMN0,ZCOLUMN1,ZCOLUMN2,ZCOLUMN3,ZCOLUMN4,ZCOLUMN5,ZCOLUMN6,ZCOLUMN7,ZCOLUMN8,ZCOLUMN9,ZCOLUMN10,ZCOLUMN11,ZCOLUMN12
                              ,ZCOLUMN13,ZCOLUMN14,ZCOLUMN15,ZCOLUMN16,ZCOLUMN17,ZCOLUMN18,ZCOLUMN19,ZCOLUMN20,ZCOLUMN21,ZCOLUMN22,ZCOLUMN23,ZCOLUMN24
                              ,ZCOLUMN25,ZCOLUMN26,ZCOLUMN27,ZCOLUMN28,ZCOLUMN29,ZCOLUMN30,ZCOLUMN31,ZCOLUMN32,ZCOLUMN33,ZCOLUMN34,ZCOLUMN35,ZCOLUMN36
                              ,ZCOLUMN37,ZCOLUMN38)
          VALUES(:<FS_HU>-WERKS,:<FS_HU>-LGORT,:<FS_HU>-LGNUM,:<FS_HU>-LGPLA,:<FS_HU>-ZZEXIDV,:<FS_HU>-EXIDV,:<FS_HU>-ZEXIDV,:<FS_HU>-MATNR,:<FS_HU>-CHARG,:<FS_HU>-ZZNOMORROLL,
                 :<FS_HU>-ZZTYPE,:<FS_HU>-ZZTHICKNESS,:<FS_HU>-ZZWIDTH,:<FS_HU>-ZZLENGTH,:<FS_HU>-ZZCRITERIA,:<FS_HU>-VEMNG,:<FS_HU>-ZQTYROL,:<FS_HU>-ZZTREATMENT,:<FS_HU>-ZZCORE,:<FS_HU>-ZZPACKING,
                 :<FS_HU>-BESTQ,:<FS_HU>-SOBKZ,:<FS_HU>-TXT04,:<FS_HU>-ERDAT,:<FS_HU>-WDATU,:<FS_HU>-ZZEXPIREDLIVE,:<FS_HU>-ERSDA,:<FS_HU>-BSTKD,:<FS_HU>-ZPINUM,:<FS_HU>-BEZEI,
                 :<FS_HU>-NAME1,:<FS_HU>-VBELN,:<FS_HU>-POSNR,:<FS_HU>-VDATU,:<FS_HU>-ZZBLOCK,:<FS_HU>-ZNAME1,:<FS_HU>-ERDAT,:<FS_HU>-ERUHR,:<FS_HU>-DELUS)
        ENDEXEC.

*        IF COUNT = '100'.
*          EXEC SQL.
*            COMMIT WORK
*          ENDEXEC.
*
*          COUNT = 0.
*        ENDIF.
      ENDLOOP.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.

    CATCH CX_SY_NATIVE_SQL_ERROR.
      MESSAGE 'Error in procedure execution insert' TYPE 'I'.
      RETURN.
  ENDTRY.

  IF SY-SUBRC  = 0.
    MESSAGE 'Penyimpanan Data ke SQL sukses!!!' TYPE 'I'.
  ENDIF.

ENDFORM.                    "EXP_SQL

FORM GET_AUART_F4  USING    VALUE(P_0072).
  DATA : V_AUART TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_AUART.
  REFRESH : IT_AUART.

  "-GET DATA AUART
  SELECT
    VBAK~AUART
    TVAKT~BEZEI

    INTO CORRESPONDING FIELDS OF TABLE IT_AUART
    FROM VBAK
    INNER JOIN TVAKT ON VBAK~AUART = TVAKT~AUART
    WHERE VBAK~AUART LIKE 'Z%'
      AND TVAKT~SPRAS EQ 'E'.

  SORT IT_AUART ASCENDING BY AUART.
  DELETE ADJACENT DUPLICATES FROM IT_AUART COMPARING AUART.


  CASE P_0072.
    WHEN 'LOW'.
      V_AUART = 'S_AUART-LOW'.
    WHEN 'HIGH'.
      V_AUART = 'S_AUART-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'AUART'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_AUART
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_AUART.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.



ENDFORM.                    " GET_AUART_F4


*&---------------------------------------------------------------------*
*&      Form  GET_VBELN_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0092   text
*----------------------------------------------------------------------*
FORM GET_VBELN_F4  USING    VALUE(P_0092).
  DATA : V_VBELN TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_VBELN.
  REFRESH : IT_VBELN.

  "-GET DATA VBELN
  SELECT
    VBAK~VBELN

    INTO CORRESPONDING FIELDS OF TABLE IT_VBELN
    FROM VBAK
    WHERE VBAK~VBTYP EQ 'C'.

  SORT IT_VBELN ASCENDING BY VBELN.
  DELETE ADJACENT DUPLICATES FROM IT_VBELN COMPARING VBELN.


  CASE P_0092.
    WHEN 'LOW'.
      V_VBELN = 'S_VBELN-LOW'.
    WHEN 'HIGH'.
      V_VBELN = 'S_VBELN-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'VBELN'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_VBELN
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_VBELN.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.

ENDFORM.                    " GET_VBELN_F4


*&---------------------------------------------------------------------*
*&      Form  GET_LGNUM_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0112   text
*----------------------------------------------------------------------*
FORM GET_LGNUM_F4  USING    VALUE(P_0112).
  DATA : V_LGNUM TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_LGNUM.
  REFRESH : IT_LGNUM.

  "-GET DATA VBELN
  SELECT
    T300~LGNUM
    T300T~LNUMT

    INTO CORRESPONDING FIELDS OF TABLE IT_LGNUM
    FROM T300
    INNER JOIN T300T ON T300~LGNUM = T300T~LGNUM
    WHERE T300~LGNUM IN ('J01' , 'K01' , 'W01')
      AND T300T~SPRAS EQ 'E'.

  SORT IT_LGNUM ASCENDING BY LGNUM.
  DELETE ADJACENT DUPLICATES FROM IT_LGNUM COMPARING LGNUM.

  CASE P_0112.
    WHEN 'LOW'.
      V_LGNUM = 'S_LGNUM-LOW'.
    WHEN 'HIGH'.
      V_LGNUM = 'S_LGNUM-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'LGNUM'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_LGNUM
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_LGNUM.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.


ENDFORM.                    " GET_LGNUM_F4
*&---------------------------------------------------------------------*
*&      Form  CHECK_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_WERKS .
  CLEAR : VON, TVALUES. REFRESH  : TVALUES.
  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
      USER_NAME           = SY-UNAME
      SEL_OBJECT          = 'Z_WERKS'
    TABLES
      VALUES              = TVALUES
    EXCEPTIONS
      USER_NAME_NOT_EXIST = 1
      NOT_AUTHORIZED      = 2
      INTERNAL_ERROR      = 3.

  READ TABLE TVALUES INDEX 1.
  VON = TVALUES-VON.

  CHECK VON NE '*'.


  READ TABLE S_WERKS WITH KEY LOW = '*'.
  IF SY-SUBRC = 0.
    CLEAR : S_WERKS. REFRESH : S_WERKS.
    MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
    S_WERKS-SIGN   = 'I'.
    S_WERKS-OPTION = 'EQ'.
    S_WERKS-LOW    = VON.
    APPEND S_WERKS.
    RETURN.
  ELSE.

    READ TABLE S_WERKS WITH KEY HIGH = '*'.
    IF SY-SUBRC = 0.
      CLEAR : S_WERKS. REFRESH : S_WERKS.
      MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
      S_WERKS-SIGN   = 'I'.
      S_WERKS-OPTION = 'EQ'.
      S_WERKS-LOW    = VON.
      APPEND S_WERKS.
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT S_WERKS.
    IF S_WERKS-LOW NE ''.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD S_WERKS-LOW.
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        CLEAR : S_WERKS. REFRESH : S_WERKS.
        RETURN.
      ENDIF.
    ENDIF.
    IF S_WERKS-HIGH NE ''.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD S_WERKS-HIGH.
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        CLEAR : S_WERKS. REFRESH : S_WERKS.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " CHECK_WERKS
*&---------------------------------------------------------------------*
*&      Form  CHECK_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_LGORT .
  CLEAR : VON, TVALUES. REFRESH  : TVALUES.
  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
      USER_NAME           = SY-UNAME
      SEL_OBJECT          = 'Z_LGORT'
    TABLES
      VALUES              = TVALUES
    EXCEPTIONS
      USER_NAME_NOT_EXIST = 1
      NOT_AUTHORIZED      = 2
      INTERNAL_ERROR      = 3.

  READ TABLE TVALUES WITH KEY VON = '*'.
  IF SY-SUBRC = 0.
    RETURN.
  ENDIF.


  READ TABLE S_LGORT WITH KEY LOW = '*'.
  IF SY-SUBRC = 0.
    CLEAR : S_LGORT. REFRESH : S_LGORT.
    MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
    LOOP AT TVALUES.
      S_LGORT-SIGN   = 'I'.
      S_LGORT-OPTION = 'EQ'.
      S_LGORT-LOW    = TVALUES-VON.
      APPEND S_LGORT.
    ENDLOOP.
    RETURN.
  ELSE.

    READ TABLE S_LGORT WITH KEY HIGH = '*'.
    IF SY-SUBRC = 0.
      CLEAR : S_LGORT. REFRESH : S_LGORT.
      MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
      LOOP AT TVALUES.
        S_LGORT-SIGN   = 'I'.
        S_LGORT-OPTION = 'EQ'.
        S_LGORT-LOW    = TVALUES-VON.
        APPEND S_LGORT.
      ENDLOOP.
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT S_LGORT.
    IF S_LGORT-LOW NE ''.
      AUTHORITY-CHECK OBJECT 'Z_LGORT' ID 'ZLGORT' FIELD S_LGORT-LOW.
      IF SY-SUBRC NE 0.
        MESSAGE E000(0K) WITH 'No Authorization to process data' S_LGORT-LOW.
        CLEAR : S_LGORT-LOW.
        MODIFY S_LGORT.
      ENDIF.
    ENDIF.
    IF S_LGORT-HIGH NE ''.
      AUTHORITY-CHECK OBJECT 'Z_LGORT' ID 'ZLGORT' FIELD S_LGORT-HIGH.
      IF SY-SUBRC NE 0.
        MESSAGE E000(0K) WITH 'No Authorization to process data' S_LGORT-LOW.
        CLEAR : S_LGORT-HIGH.
        MODIFY S_LGORT.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHECK_LGORT

FORM CONNECT_SQL .
  SELECT SINGLE DBMS
         FROM DBCON
         INTO DBTYPE
         WHERE CON_NAME = SAP_CON.

  IF DBTYPE = 'MSS'.
    TRY .
      EXEC SQL.
        SET CONNECTION :SAP_CON
      ENDEXEC.

      EXEC SQL.
        CONNECT TO :SAP_CON
      ENDEXEC.

      IF SY-SUBRC <> 0.
        MESSAGE 'Not Connected..!!' TYPE 'I'.
      ELSE.
        MESSAGE 'Database SQL Connected' TYPE 'I'.
      ENDIF.
    ENDTRY.
  ENDIF.
ENDFORM.                    " CONNECT_SQL