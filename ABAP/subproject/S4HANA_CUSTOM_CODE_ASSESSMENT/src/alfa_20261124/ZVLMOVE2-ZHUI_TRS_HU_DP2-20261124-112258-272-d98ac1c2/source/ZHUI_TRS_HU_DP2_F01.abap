*&---------------------------------------------------------------------*
*&  Include           ZHUI_TRS_HU_DP2_F01
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  CALL SCREEN 100.


*&---------------------------------------------------------------------*
*&      Form  EXECUTE1
*&---------------------------------------------------------------------*

FORM EXECUTE1 .
  IF RW = 'X'.
    CLEAR : JPB, JTGI,  JTK, JTS, JTW, KPB, KTGI, KTGN, KTJ, KTS, KTW.
    CLEAR : ZHUK, ZHUJ.
    CALL SCREEN 200. "WARU AREA

  ELSEIF RK = 'X'.
    CLEAR : JPB, JTGI, JTK, JTS, JTW, WPB, WTGI, WTGN, WTJ, WTK, WTS.
    CLEAR : ZHUW, ZHUJ.
    CALL SCREEN 300. "KRIAN AREA

  ELSEIF RJ = 'X'.
    CLEAR : WPB, WTGI, WTGN, WTJ, WTK, WTS, KPB, KTGI, KTGN, KTJ, KTS, KTW.
    CLEAR : ZHUW, ZHUK.
    CALL SCREEN 400. "JAKARTA AREA
  ENDIF.

ENDFORM.                    " EXECUTE1

*&---------------------------------------------------------------------*
*&      Form  GET_SLOC
*&---------------------------------------------------------------------*
*       Get Correct SLoc Asal and SLoc Tujuan for each Area
*----------------------------------------------------------------------*
FORM F_GET_SLOC .
  "GET DATA SLOC
  CLEAR : ITSLOC, RSLOCA, RSLOCT, WSLOC.
  REFRESH : ITSLOC, RSLOCA, RSLOCT.

  IF RW = 'X'. "WARU AREA
    " GET DATA SLOC ASAL FOR WARU AREA
    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '1%'
      AND ZHU_MAPP~WERK1 = '1000'
      AND ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCA.
    ENDLOOP.

    " GET DATA SLOC TUJUAN FOR WARU AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.
    IF WTGI = 'X'.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '1%'
      AND ZHU_MAPP~TYPES = TYPE.
    ELSE.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '1%'
      AND ZHU_MAPP~WERK2 = '1000'
      AND ZHU_MAPP~TYPES = TYPE.
    ENDIF.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCT.
    ENDLOOP.

  ELSEIF RK = 'X'.  "KRIAN AREA
    " GET DATA SLOC ASAL FOR KRIAN AREA
    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '2%'
      AND ZHU_MAPP~WERK1 = '2000'
      AND ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCA.
    ENDLOOP.

    " GET DATA SLOC TUJUAN FOR KRIAN AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.

    IF KTGI = 'X'.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '2%'
      AND ZHU_MAPP~TYPES = TYPE.
    ELSE.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '2%'
      AND ZHU_MAPP~WERK2 = '2000'
      AND ZHU_MAPP~TYPES = TYPE.
    ENDIF.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCT.
    ENDLOOP.

  ELSEIF RJ = 'X'. "JAKARTA AREA

    " GET DATA SLOC ASAL FOR JAKARTA AREA
    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '3%'
      AND ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCA.
    ENDLOOP.

    " GET DATA SLOC TUJUAN FOR JAKARTA AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.
    SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCT.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " GET_SLOC


*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*

FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.

  IF ( WTJ = 'X' OR  WTK = 'X' OR KTJ = 'X' OR KTW = 'X' OR JTK = 'X'  OR JTW = 'X' ).
    PERFORM F_ALV_FIELDCATG_ICON USING 'ITDATA' :
    'HUNO'   '' ''  '' ''  'HU Number'       '' ' ' '' '',
    'SLOCA'   '' ''  '' ''  'Sloc Asal'    '' ' ' '' '',
    'PLANTA'   '' ''  '' ''  'Plant Asal'   '' ' ' '' '',
    'SLOCT'  '' ''  '' ''  'Sloc Tujuan'      '' ' ' '' '',
    'PLANTT'  '' ''  '' ''  'Plant Tujuan'      '' ' ' '' '',
    'MATDOC'  '' ''  '' ''  'ODO No.'      '' ' ' '' '',
    'KET'  '' ''  '' ''  'Keterangan'      '' ' ' '' ''.
  ELSE.
    PERFORM F_ALV_FIELDCATG_ICON USING 'ITDATA' :
    'HUNO'   '' ''  '' ''  'HU Number'       '' ' ' '' '',
    'SLOCA'   '' ''  '' ''  'Sloc Asal'    '' ' ' '' '',
    'PLANTA'   '' ''  '' ''  'Plant Asal'   '' ' ' '' '',
    'SLOCT'  '' ''  '' ''  'Sloc Tujuan'      '' ' ' '' '',
    'PLANTT'  '' ''  '' ''  'Plant Tujuan'      '' ' ' '' '',
    'MATDOC'  '' ''  '' ''  'Material Doc.'      '' ' ' '' '',
    'KET'  '' ''  '' ''  'Keterangan'      '' ' ' '' ''.

  ENDIF.
ENDFORM.                    " F_FIELD_CATALOG

*------------------------------------------------------------------*
*       FORM USER_COMMAND                                          *
*------------------------------------------------------------------*

FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.

ENDFORM.                    "USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  SET_CELL_COLOURS
*&---------------------------------------------------------------------*
*       SET CELL COLOURS FOR ALV GRID
*----------------------------------------------------------------------*
FORM SET_CELL_COLOURS .
  DATA: WA_CELLCOLOR TYPE LVC_S_SCOL.
  DATA: LD_INDEX TYPE SY-TABIX.

  LOOP AT ITDATA.
    REFRESH ITDATA-CELLCOLOR.
    MODIFY ITDATA.
  ENDLOOP.

  LOOP AT ITDATA WHERE KET NP '*HU OK*'.
    IF ITDATA-MATDOC = '-'.
      LD_INDEX = SY-TABIX.

      WA_CELLCOLOR-FNAME = 'HUNO'.
      WA_CELLCOLOR-COLOR-COL = 6.
      WA_CELLCOLOR-COLOR-INT = '1'.
      WA_CELLCOLOR-COLOR-INV = '1'.
      APPEND WA_CELLCOLOR TO ITDATA-CELLCOLOR.
      MODIFY ITDATA INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'SLOCA'.
      WA_CELLCOLOR-COLOR-COL = 6.
      WA_CELLCOLOR-COLOR-INT = '1'.
      WA_CELLCOLOR-COLOR-INV = '1'.
      APPEND WA_CELLCOLOR TO ITDATA-CELLCOLOR.
      MODIFY ITDATA INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'PLANTA'.
      WA_CELLCOLOR-COLOR-COL = 6.
      WA_CELLCOLOR-COLOR-INT = '1'.
      WA_CELLCOLOR-COLOR-INV = '1'.
      APPEND WA_CELLCOLOR TO ITDATA-CELLCOLOR.
      MODIFY ITDATA INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'SLOCT'.
      WA_CELLCOLOR-COLOR-COL = 6.
      WA_CELLCOLOR-COLOR-INT = '1'.
      WA_CELLCOLOR-COLOR-INV = '1'.
      APPEND WA_CELLCOLOR TO ITDATA-CELLCOLOR.
      MODIFY ITDATA INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'PLANTT'.
      WA_CELLCOLOR-COLOR-COL = 6.
      WA_CELLCOLOR-COLOR-INT = '1'.
      WA_CELLCOLOR-COLOR-INV = '1'.
      APPEND WA_CELLCOLOR TO ITDATA-CELLCOLOR.
      MODIFY ITDATA INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'MATDOC'.
      WA_CELLCOLOR-COLOR-COL = 6.
      WA_CELLCOLOR-COLOR-INT = '1'.
      WA_CELLCOLOR-COLOR-INV = '1'.
      APPEND WA_CELLCOLOR TO ITDATA-CELLCOLOR.
      MODIFY ITDATA INDEX LD_INDEX TRANSPORTING CELLCOLOR.

      WA_CELLCOLOR-FNAME = 'KET'.
      WA_CELLCOLOR-COLOR-COL = 6.
      WA_CELLCOLOR-COLOR-INT = '1'.
      WA_CELLCOLOR-COLOR-INV = '1'.
      APPEND WA_CELLCOLOR TO ITDATA-CELLCOLOR.
      MODIFY ITDATA INDEX LD_INDEX TRANSPORTING CELLCOLOR.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SET_CELL_COLOURS

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

  DATA : THEADER(50) TYPE C,
         TTITLE(50) TYPE C.

  "SET HEADER REPORT
  CLEAR : THEADER, TTITLE.
  IF WTGN = 'X'.
    THEADER = 'Transfer Handling Unit for Waru Area'.
    TTITLE  = 'Transfer to Gudang Non WM'.
  ELSEIF WTGI = 'X'.
    THEADER = 'Transfer Handling Unit for Waru Area'.
    TTITLE  = 'Transfer for GI Sales'.
  ELSEIF WPB = 'X'.
    THEADER = 'Transfer Handling Unit for Waru Area'.
    TTITLE  = 'Penerimaan Barang'.
  ELSEIF WTJ = 'X'.
    THEADER = 'Transfer Handling Unit for Waru Area'.
    TTITLE  = 'Transfer Waru to Jakarta'.
  ELSEIF WTK = 'X'.
    THEADER = 'Transfer Handling Unit for Waru Area'.
    TTITLE  = 'Transfer Waru to Krian'.
  ELSEIF WTS = 'X'.
    THEADER = 'Transfer Handling Unit for Waru Area'.
    TTITLE  = 'Transfer antar Storage Location'.
  ELSEIF KTGN = 'X'.
    THEADER = 'Transfer Handling Unit for Krian Area'.
    TTITLE  = 'Transfer to Gudang Non WM'.
  ELSEIF KTGI = 'X'.
    THEADER = 'Transfer Handling Unit for Krian Area'.
    TTITLE  = 'Transfer for GI Sales'.
  ELSEIF KPB = 'X'.
    THEADER = 'Transfer Handling Unit for Krian Area'.
    TTITLE  = 'Penerimaan Barang'.
  ELSEIF KTJ = 'X'.
    THEADER = 'Transfer Handling Unit for Krian Area'.
    TTITLE  = 'Transfer Krian to Jakarta'.
  ELSEIF KTW = 'X'.
    THEADER = 'Transfer Handling Unit for Krian Area'.
    TTITLE  = 'Transfer Krian to Waru'.
  ELSEIF KTS = 'X'.
    THEADER = 'Transfer Handling Unit for Krian Area'.
    TTITLE  = 'Transfer antar Storage Location'.
  ELSEIF JTGI = 'X'.
    THEADER = 'Transfer Handling Unit for Jakarta Area'.
    TTITLE  = 'Transfer for GI Sales'.
  ELSEIF JPB = 'X'.
    THEADER = 'Transfer Handling Unit for Jakarta Area'.
    TTITLE  = 'Penerimaan Barang'.
  ELSEIF JTK = 'X'.
    THEADER = 'Transfer Handling Unit for Jakarta Area'.
    TTITLE  = 'Transfer Jakarta to Krian'.
  ELSEIF JTW = 'X'.
    THEADER = 'Transfer Handling Unit for Jakarta Area'.
    TTITLE  = 'Transfer Jakarta to Waru'.
  ELSEIF JTS = 'X'.
    THEADER = 'Transfer Handling Unit for Jakarta Area'.
    TTITLE  = 'Transfer antar Storage Location'.
  ENDIF.

* TITLE
  WA_HEADER-TYP  = 'H'.
  WA_HEADER-INFO = THEADER.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.

  WA_HEADER-TYP  = 'S'.
  WA_HEADER-INFO = TTITLE.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = T_HEADER.

ENDFORM. "TOP-OF-PAGE


*&---------------------------------------------------------------------*
*&      Form  GETLAYOUT
*&---------------------------------------------------------------------*
*       Build ALV Grid
*----------------------------------------------------------------------*
FORM F_GETLAYOUT .

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM SET_CELL_COLOURS.
  PERFORM F_LIST_DETAIL.

ENDFORM.                    " GETLAYOUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       Module User command for screen 500
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.
  CASE OKCODE.
    WHEN 'BACK'.
      CLEAR : OKCODE, ITDATA.
      REFRESH ITDATA.
      CLEAR TSLOC.
      LEAVE TO SCREEN 0.
    WHEN 'GO'.
      IF TSLOC IS INITIAL.
        MESSAGE 'Please input target SLoc' TYPE 'I'.
      ELSE.
        SORT ITDATA DESCENDING BY KET.
        READ TABLE ITDATA INDEX 1.

        IF ITDATA-KET <> ''.
          MESSAGE 'Transfer HU sudah dilakukan sebelumnya' TYPE 'I'.
        ELSE.
          CLEAR OKCODE.
          PERFORM PENERIMAAN_BARANG. "PENERIMAAN BARANG OR TRANSFER ANTAR SLOC.
        ENDIF.
      ENDIF.

    WHEN 'EXIT'.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Form  GET_TYPE_SLOC
*&---------------------------------------------------------------------*
*       Get Type SLoc for each Type Transfer HU
*----------------------------------------------------------------------*
FORM F_GET_TYPE_SLOC .
  "GET TYPE SLOC
  CLEAR : TYPE.
  IF ( WTGN = 'X' OR KTGN = 'X' ).
    TYPE = '2'.
  ELSEIF ( WTK = 'X' OR KTW = 'X' ).
    TYPE = '3'.
  ELSEIF ( WTJ = 'X' OR KTJ = 'X' ).
    TYPE = '4'.
  ELSEIF ( WPB = 'X' OR KPB = 'X' OR  JPB = 'X').
    TYPE = '5'.
  ELSEIF ( WTS = 'X' OR KTS = 'X' OR JTS = 'X').
    TYPE = '6'.
  ELSEIF ( JTW = 'X' ).
    TYPE = '7'.
  ELSEIF ( JTK = 'X' ).
    TYPE = '10'.
  ELSEIF ( WTGI = 'X' OR KTGI = 'X' OR JTGI  = 'X').
    TYPE = '9'.
  ENDIF.
ENDFORM.                    " GET_TYPE_SLOC


*&---------------------------------------------------------------------*
*&   Form  TRANSFER_SLOC
*&---------------------------------------------------------------------*
*   Transfer SLoc- Used for Penerimaan Barang & Transfer Antar SLoc
*----------------------------------------------------------------------*
FORM F_TRANSFER_SLOC .
  CLEAR : TSLOC, TYPE, ITDATA.
  REFRESH ITDATA.
  CALL SCREEN 500.
ENDFORM.                    " TRANSFER_SLOC


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
*&      Form  TRANSFERHU
*&---------------------------------------------------------------------*
*       Transfer HU
*----------------------------------------------------------------------*
FORM F_TRANSFERHU .

  IF RW = 'X'.
    CLEAR : JPB, JTGI, JTK, JTS, JTW, KPB, KTGI, KTGN, KTJ, KTS, KTW.
    CLEAR : ZHUK, ZHUJ.

  ELSEIF RK = 'X'.
    CLEAR : JPB, JTGI, JTK, JTS, JTW, WPB, WTGI, WTGN, WTJ, WTK, WTS.
    CLEAR : ZHUW, ZHUJ.

  ELSEIF RJ = 'X'.
    CLEAR : WPB, WTGI, WTGN, WTJ, WTK, WTS, KPB, KTGI, KTGN, KTJ, KTS, KTW.
    CLEAR : ZHUW, ZHUK.
  ENDIF.

  PERFORM GET_HUPLANT. "add New Company

  " Jika Transfer to Gudang Non WM
  IF ( WTGN = 'X' OR KTGN = 'X').
    IF WTGN = 'X'.
      IF ZHUW[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_TO_GUDANG_NONWM.
      ENDIF.

    ELSEIF KTGN = 'X' .
      IF ZHUK[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_TO_GUDANG_NONWM.
      ENDIF.
    ENDIF.

    "Jika Transfer Antar Area
  ELSEIF ( WTJ = 'X' OR  WTK = 'X' OR KTJ = 'X' OR KTW = 'X' OR JTK = 'X'  OR JTW = 'X').
    IF ( WTJ = 'X' OR  WTK = 'X' ).
      IF ZHUW[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_ANTAR_AREA.
      ENDIF.

    ELSEIF ( KTJ = 'X' OR KTW = 'X' ) .
      IF ZHUK[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_ANTAR_AREA.
      ENDIF.

    ELSEIF ( JTK = 'X'  OR JTW = 'X' ).
      IF ZHUJ[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_ANTAR_AREA.
      ENDIF.
    ENDIF.

    "Jika Transfer for GI Sales
  ELSEIF ( WTGI = 'X' OR KTGI = 'X' OR JTGI = 'X' ).
    IF WTGI = 'X'.
      IF ZHUW[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM   F_TRANSFER_FOR_GI_SALES.
      ENDIF.

    ELSEIF KTGI = 'X' .
      IF ZHUK[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM   F_TRANSFER_FOR_GI_SALES.
      ENDIF.

    ELSEIF JTGI = 'X' .
      IF ZHUJ[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM   F_TRANSFER_FOR_GI_SALES.
      ENDIF.
    ENDIF.

    "Jika Penerimaan Barang atau Transfer Antar Sloc.
  ELSEIF ( KPB = 'X' OR KTS = 'X' OR JPB = 'X' OR JTS = 'X' OR WPB = 'X' OR WTS = 'X' ).

    IF ( WPB = 'X' OR WTS = 'X' ).
      IF ZHUW[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_SLOC.
      ENDIF.

    ELSEIF ( KPB = 'X' OR KTS = 'X' ).
      IF ZHUK[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_SLOC.
      ENDIF.

    ELSEIF ( JPB = 'X' OR JTS = 'X' ).
      IF ZHUJ[] IS INITIAL.
        MESSAGE 'Please input HU Number!' TYPE 'I'.
      ELSE.
        PERFORM F_TRANSFER_SLOC.
      ENDIF.

    ENDIF.

  ENDIF.
ENDFORM.                    " TRANSFERHU


*&---------------------------------------------------------------------*
*&      Form  TRANSFER_TO_GUDANG_NONWM
*&---------------------------------------------------------------------*
*       TRANSFER TO GUDANG NON WM
*----------------------------------------------------------------------*
FORM F_TRANSFER_TO_GUDANG_NONWM .
  CLEAR : ITDATA ,WADATA.
  REFRESH : ITDATA.

  "CHECK PLANT
  IF ( WTGN = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
      VEPO~WERKS AS PLANTA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV IN ZHUW
      AND  VEKP~UEVEL = ''.

  ELSEIF ( KTGN = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
        VEPO~WERKS AS PLANTA
        INTO CORRESPONDING FIELDS OF TABLE ITDATA
        FROM VEKP
        JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
        WHERE VEKP~EXIDV IN ZHUK
        AND  VEKP~UEVEL = ''.
  ENDIF.

  LOOP AT ITDATA.

    "GET DATA SLOC FROM TABLE ZHU_MAPP
    PERFORM F_GET_TYPE_SLOC.
    PERFORM F_GET_SLOC.

    "CHECK PLANT
    IF ( WTGN = 'X').
      IF ITDATA-PLANTA <> '1000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Waru'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        ENDIF.
      ENDIF.
    ELSEIF ( KTGN = 'X' ).
      IF ITDATA-PLANTA <> '2000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Krian'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        ENDIF.
      ENDIF.
    ENDIF.

    IF ITDATA-KET = ''.
      "GET SLOC ASAL
      CLEAR : UNVEL.
      SELECT SINGLE VEPO~UNVEL
          INTO UNVEL
          FROM VEPO JOIN VEKP
          ON VEPO~VENUM = VEKP~VENUM
          WHERE VEKP~EXIDV = ITDATA-HUNO.

      IF UNVEL = ''.
        SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.
          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( WTGN = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF ( KTGN = 'X' ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.

            ENDIF.

            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.

      ELSE. " Jika masih ada high level HU

        SELECT SINGLE VEPO~LGORT VEPO~WERKS
            INTO (ITDATA-SLOCA,ITDATA-PLANTA)
            FROM VEPO
            WHERE VEPO~VENUM = UNVEL.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.

          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( WTGN = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF (  KTGN = 'X'   ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ENDIF.

            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ITDATA-KET = ''.
        "GET SLOC DAN PLANT TUJUAN
        SELECT SINGLE ZHU_MAPP~WERK2 ZHU_MAPP~LGOR2
            INTO (ITDATA-PLANTT, ITDATA-SLOCT)
            FROM ZHU_MAPP
            WHERE ZHU_MAPP~TYPES = TYPE
            AND ZHU_MAPP~WERK1 = ITDATA-PLANTA
            AND ZHU_MAPP~LGOR1 = ITDATA-SLOCA.

        "CHECK SLOC TUJUAN
        IF ITDATA-SLOCT = ''.
          ITDATA-KET = 'Error, SLoc Tujuan Kosong'.
          ITDATA-MATDOC = '-'.
        ELSE.
          IF  ITDATA-SLOCT NOT IN RSLOCT.
            ITDATA-KET = 'Error, SLoc Tujuan Salah'.
            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.

        CLEAR VENUM.
        "GET INTERNAL HU
        SELECT SINGLE VEKP~VENUM
           INTO VENUM
           FROM VEKP
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        "GET STATUS HU
        CLEAR : STATUS.
        CONCATENATE 'HU' VENUM INTO OBJNR.
        SELECT SINGLE TJ30T~TXT04
           INTO STATUS
           FROM TJ30T
           JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
           JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
           WHERE HUSSTAT~OBJNR = OBJNR
           AND HUSSTAT~STAT = TJ30T~ESTAT
           AND HUSSTAT~INACT = ''
           AND TJ30T~SPRAS = 'EN'.

        IF STATUS = ''.
          ITDATA-KET = 'Error, Status HU kosong'.
          ITDATA-MATDOC = '-'.
        ELSEIF STATUS <> 'QAOK'.
          ITDATA-KET = 'Error, Status HU tidak QAOK'.
          ITDATA-MATDOC = '-'.
        ENDIF.

        IF ITDATA-KET = ''.

          "GET MAX DATE AND TIME STATUS HU
          CLEAR : VAEDAT , VAETIME.
          SELECT MAX( ZQM001~AEDAT )
            INTO VAEDAT
            FROM ZQM001
            WHERE ZQM001~EXIDV = ITDATA-HUNO.

          SELECT MAX( ZQM001~AETIME )
            INTO VAETIME
            FROM ZQM001
            WHERE ZQM001~EXIDV = ITDATA-HUNO
            AND ZQM001~AEDAT = VAEDAT.

          "GET STATUS PASS/HOLD.
          CLEAR PSTAT.
          SELECT SINGLE ZQM001~PSTAT
            INTO PSTAT
            FROM ZQM001
            WHERE ZQM001~EXIDV = ITDATA-HUNO
            AND ZQM001~AEDAT = VAEDAT
            AND ZQM001~AETIME = VAETIME.

          IF PSTAT NE 'P'.
            ITDATA-KET = 'Status HU is not Pass'.
            ITDATA-MATDOC = '-'.
          ENDIF.

          "MOVE HU
          IF ITDATA-KET = ''.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = ITDATA-HUNO
              IMPORTING
                OUTPUT = ITDATA-HUNO.

            CLEAR : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.
            REFRESH : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.

            IT_MOVE_TO-LGORT = ITDATA-SLOCT.
            APPEND IT_MOVE_TO.
            MOVE ITDATA-HUNO TO IT_EXTERNAL_ID-EXIDV.
            APPEND  IT_EXTERNAL_ID.

            CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
              EXPORTING
                IF_EVENT       = '0006'
                IF_TCODE       = 'VLMOVE'
                IT_MOVE_TO     = IT_MOVE_TO[]
                IT_EXTERNAL_ID = IT_EXTERNAL_ID[]
              IMPORTING
                ES_MESSAGE     = ES_MESSAGE
                ET_MESSAGES    = ET_MESSAGES[].

            IF SY-SUBRC = 0.

              READ TABLE ES_MESSAGE WITH KEY MSGTY = 'E'.
*
              IF SY-SUBRC = 0.
                ITDATA-KET = 'Error, Transfer HU Gagal'.
                ITDATA-MATDOC = '-'.
              ELSE.
                LOOP AT ET_MESSAGES.
                  "JIKA ERROR
                  IF ET_MESSAGES-MSGTY = 'E'.
                    ITDATA-MATDOC = ''.
                  ELSE.
                    ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                  ENDIF.
                ENDLOOP.

                IF ITDATA-MATDOC = ''.
                  ITDATA-KET = 'Error, Transfer HU Gagal'.
                  ITDATA-MATDOC = '-'.
                ELSE.
                  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                    EXPORTING
                      WAIT = 'X'.

                  "UPDATE DATA IN ZPACKPCL.
                  CLEAR : WA_PSOURCE, T_PSOURCE,VENUM.
                  REFRESH : T_PSOURCE.
                  SELECT SINGLE VENUM INTO VENUM FROM VEKP WHERE VEKP~EXIDV = ITDATA-HUNO.

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

                  ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                  ITDATA-KET = 'Transfer HU Sukses'.
                ENDIF.

              ENDIF.

            ELSE.
              ITDATA-MATDOC = '-'.
              ITDATA-KET = 'Error, Transfer HU Gagal'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY ITDATA.
  ENDLOOP.


  "CHECK LOCKING.
  CLEAR WADATA.
  READ TABLE ITDATA INTO WADATA WITH KEY MATDOC = '-'.

  IF SY-SUBRC = 0.
    LOOP AT ITDATA.
      REFRESH : IT_BDCDATA, IT_BDCMSGCOLL.
      "CANCEL TRANSFER HU
      IF ITDATA-MATDOC NE '-'.
        PERFORM BDC_DYNPRO      USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=ONLI'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'SP_MBLNR'.
        PERFORM BDC_FIELD       USING 'SP_PSTDA'
                                      DATE.
        PERFORM BDC_FIELD       USING 'SP_MBLNR'
                                      ITDATA-MATDOC.
        PERFORM BDC_FIELD       USING 'SP_MJAHR'
                                      YYYY.

        CALL TRANSACTION 'HUCANC' USING IT_BDCDATA
                MODE 'E'
                UPDATE 'S'
                MESSAGES INTO IT_BDCMSGCOLL.

        ITDATA-KET = 'HU OK, Not transferred'.
        ITDATA-MATDOC = '-'.
      ELSE.
        IF ITDATA-KET = 'Error, Transfer HU Gagal'..
          ITDATA-KET = 'HU Locked, Not Transferred'.
          ITDATA-MATDOC = '-'.
        ENDIF.
      ENDIF.
      MODIFY ITDATA.
    ENDLOOP.

    CLEAR VLINE.
    DESCRIBE TABLE ITDATA LINES VLINE.
    IF VLINE = 1.
      MESSAGE 'HU Not Transferred.' TYPE 'I'.
    ELSE.
      MESSAGE 'All HU are Not Transferred.' TYPE 'I'.
    ENDIF.
  ENDIF.

  "PERFORM ALV GRID
  IF ITDATA[] IS INITIAL.
    MESSAGE 'No Data Exist!' TYPE 'I'.
  ELSE.
    PERFORM F_GETLAYOUT.
  ENDIF.
ENDFORM.                    " TRANSFER_TO_GUDANG_NONWM


*&---------------------------------------------------------------------*
*&      Form  TRANSFER_FOR_GI_SALES
*&---------------------------------------------------------------------*
*       Transfer for GI Sales.
*----------------------------------------------------------------------*
FORM F_TRANSFER_FOR_GI_SALES .
  CLEAR : ITDATA ,WADATA.
  REFRESH : ITDATA.

  "CHECK PLANT
  IF ( WTGI = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
      VEPO~WERKS AS PLANTA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV IN ZHUW
      AND  VEKP~UEVEL = ''.

  ELSEIF ( KTGI = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
        VEPO~WERKS AS PLANTA
        INTO CORRESPONDING FIELDS OF TABLE ITDATA
        FROM VEKP
        JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
        WHERE VEKP~EXIDV IN ZHUK
        AND  VEKP~UEVEL = ''.

  ELSEIF ( JTGI = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
      VEPO~WERKS AS PLANTA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV IN ZHUJ
      AND  VEKP~UEVEL = ''.
  ENDIF.

  LOOP AT ITDATA.

    PERFORM F_GET_TYPE_SLOC.
    PERFORM F_GET_SLOC.

    "CHECK PLANT
    IF ( WTGI = 'X' ).
      IF ITDATA-PLANTA <> '1000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Waru'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        ENDIF.
      ENDIF.
    ELSEIF ( KTGI = 'X' ).
      IF ITDATA-PLANTA <> '2000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Krian'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ITDATA-KET = ''.
      "GET SLOC ASAL
      CLEAR : UNVEL.
      SELECT SINGLE VEPO~UNVEL
          INTO UNVEL
          FROM VEPO JOIN VEKP
          ON VEPO~VENUM = VEKP~VENUM
          WHERE VEKP~EXIDV = ITDATA-HUNO.

      IF UNVEL = ''.
        SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.

          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( WTGI = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF ( KTGI = 'X' ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( JTGI = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.

            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.

      ELSE. "Jika masih ada high level HU
        SELECT SINGLE VEPO~LGORT VEPO~WERKS
            INTO (ITDATA-SLOCA,ITDATA-PLANTA)
            FROM VEPO
            WHERE VEPO~VENUM = UNVEL.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.

          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( WTGI = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF ( KTGI = 'X' ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( JTGI = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.
            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ITDATA-KET = ''.
        "GET SLOC DAN PLANT TUJUAN
        SELECT SINGLE ZHU_MAPP~WERK2 ZHU_MAPP~LGOR2
              INTO (ITDATA-PLANTT, ITDATA-SLOCT)
              FROM ZHU_MAPP
              WHERE ZHU_MAPP~TYPES = TYPE
              AND ZHU_MAPP~WERK1 = ITDATA-PLANTA
              AND ZHU_MAPP~LGOR1 = ITDATA-SLOCA.

        "CHECK SLOC TUJUAN
        IF ITDATA-SLOCT = ''.
          ITDATA-KET = 'Error, SLoc Tujuan Kosong'.
          ITDATA-MATDOC = '-'.
        ELSE.
          IF  ITDATA-SLOCT NOT IN RSLOCT.
            ITDATA-KET = 'Error, SLoc Tujuan Salah'.
            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.


        IF ITDATA-SLOCA = ITDATA-SLOCT.
          ITDATA-KET = 'Error, SLoc Asal sama dengan SLoc tujuan'.
          ITDATA-MATDOC = '-'.
        ENDIF.

        IF  ITDATA-KET = ''..
          "GET INTERNAL HU
          CLEAR VENUM.
          SELECT SINGLE VEKP~VENUM
             INTO VENUM
             FROM VEKP
             WHERE VEKP~EXIDV = ITDATA-HUNO.

          "GET STATUS HU
          CLEAR : STATUS.
          CONCATENATE 'HU' VENUM INTO OBJNR.
          SELECT SINGLE TJ30T~TXT04
             INTO STATUS
             FROM TJ30T
             JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
             JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
             WHERE HUSSTAT~OBJNR = OBJNR
             AND HUSSTAT~STAT = TJ30T~ESTAT
             AND HUSSTAT~INACT = ''
             AND TJ30T~SPRAS = 'EN'.

          IF STATUS = ''.
            ITDATA-KET = 'Error, Status HU kosong'.
            ITDATA-MATDOC = '-'.
          ELSEIF STATUS <> 'QAOK'.
            ITDATA-KET = 'Error, Status HU tidak QAOK'.
            ITDATA-MATDOC = '-'.
          ENDIF.

          IF ITDATA-KET = ''.

            "GET MAX DATE AND TIME STATUS HU
            CLEAR : VAEDAT , VAETIME.
            SELECT MAX( ZQM001~AEDAT )
              INTO VAEDAT
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO.

            SELECT MAX( ZQM001~AETIME )
              INTO VAETIME
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO
              AND ZQM001~AEDAT = VAEDAT.

            "GET STATUS PASS/HOLD.
            CLEAR PSTAT.
            SELECT SINGLE ZQM001~PSTAT
              INTO PSTAT
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO
              AND ZQM001~AEDAT = VAEDAT
              AND ZQM001~AETIME = VAETIME.

            IF PSTAT NE 'P'.
              ITDATA-KET = 'Status HU is not Pass'.
              ITDATA-MATDOC = '-'.
            ENDIF.

            "MOVE HU
            IF ITDATA-KET = ''.
              "convert HU
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT  = ITDATA-HUNO
                IMPORTING
                  OUTPUT = ITDATA-HUNO.

              REFRESH : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.

              IT_MOVE_TO-LGORT = ITDATA-SLOCT.
              IT_MOVE_TO-WERKS = ITDATA-PLANTT.
              APPEND IT_MOVE_TO.
              MOVE ITDATA-HUNO TO IT_EXTERNAL_ID-EXIDV.
              APPEND  IT_EXTERNAL_ID.

              IF WTGI = 'X'.
                IF_EVENT = '0007'.
              ELSE.
                IF_EVENT = '0006'.
              ENDIF.

              CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
                EXPORTING
                  IF_EVENT       = IF_EVENT
                  IF_TCODE       = 'VLMOVE'
                  IT_MOVE_TO     = IT_MOVE_TO[]
                  IT_EXTERNAL_ID = IT_EXTERNAL_ID[]
                IMPORTING
                  ES_MESSAGE     = ES_MESSAGE
                  ET_MESSAGES    = ET_MESSAGES[].

              IF SY-SUBRC = 0.

                READ TABLE ES_MESSAGE WITH KEY MSGTY = 'E'.
*
                IF SY-SUBRC = 0.
                  ITDATA-KET = 'Error, Transfer HU Gagal'.
                  ITDATA-MATDOC = '-'.
                ELSE.

                  LOOP AT ET_MESSAGES.
                    "JIKA ERROR
                    IF ET_MESSAGES-MSGTY = 'E'.
                      ITDATA-MATDOC = ''.
                    ELSE.
                      ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                    ENDIF.
                  ENDLOOP.

                  IF ITDATA-MATDOC = ''.
                    ITDATA-KET = 'Error, Transfer HU Gagal'.
                    ITDATA-MATDOC = '-'.
                  ELSE.
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                      EXPORTING
                        WAIT = 'X'.

                    "UPDATE DATA IN ZPACKPCL.
                    CLEAR : WA_PSOURCE, T_PSOURCE,VENUM.
                    REFRESH : T_PSOURCE.
                    SELECT SINGLE VENUM INTO VENUM FROM VEKP WHERE VEKP~EXIDV = ITDATA-HUNO.

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


                    ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                    ITDATA-KET = 'Transfer HU Sukses'.
                  ENDIF.
                ENDIF.
              ELSE.
                ITDATA-MATDOC = '-'.
                ITDATA-KET = 'Error, Transfer HU Gagal'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY ITDATA.
  ENDLOOP.

  "CHECK LOCKING.
  CLEAR WADATA.
  READ TABLE ITDATA INTO WADATA WITH KEY MATDOC = '-'.

  IF SY-SUBRC = 0.
    LOOP AT ITDATA.
      REFRESH : IT_BDCDATA, IT_BDCMSGCOLL.
      "CANCEL TRANSFER HU
      IF ITDATA-MATDOC NE '-'.
        PERFORM BDC_DYNPRO      USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=ONLI'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'SP_MBLNR'.
        PERFORM BDC_FIELD       USING 'SP_PSTDA'
                                      DATE.
        PERFORM BDC_FIELD       USING 'SP_MBLNR'
                                      ITDATA-MATDOC.
        PERFORM BDC_FIELD       USING 'SP_MJAHR'
                                      YYYY.

        CALL TRANSACTION 'HUCANC' USING IT_BDCDATA
                MODE 'E'
                UPDATE 'S'
                MESSAGES INTO IT_BDCMSGCOLL.

        ITDATA-KET = 'HU OK, Not transferred'.
        ITDATA-MATDOC = '-'.
      ELSE.
        IF ITDATA-KET = 'Error, Transfer HU Gagal'..
          ITDATA-KET = 'HU Locked, Not Transferred'.
          ITDATA-MATDOC = '-'.
        ENDIF.
      ENDIF.
      MODIFY ITDATA.
    ENDLOOP.

    CLEAR VLINE.
    DESCRIBE TABLE ITDATA LINES VLINE.
    IF VLINE = 1.
      MESSAGE 'HU Not Transferred.' TYPE 'I'.
    ELSE.
      MESSAGE 'All HU are Not Transferred.' TYPE 'I'.
    ENDIF.
  ENDIF.

  IF ITDATA[] IS INITIAL.
    MESSAGE 'No Data Exist!' TYPE 'I'.
  ELSE.
    PERFORM F_GETLAYOUT.
  ENDIF.

ENDFORM.                    " TRANSFER_FOR_GI_SALES


*&---------------------------------------------------------------------*
*&      Form  PENERIMAAN_BARANG
*&---------------------------------------------------------------------*
*       Penerimaan Barang atau Transfer Antar Sloc.
*----------------------------------------------------------------------*
FORM PENERIMAAN_BARANG .
  " Added by William at 19.02.2026 (move pallet RTP)
  DATA: IT_ZPALLETR LIKE ZPALLETR OCCURS 0 WITH HEADER LINE.
  DATA: IT_MAP_PALLET LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE.
  DATA: IT_ERROR_PALLET LIKE ITDATA OCCURS 0 WITH HEADER LINE.

  DATA: GMHEAD LIKE BAPI2017_GM_HEAD_01.
  DATA: GMCODE LIKE BAPI2017_GM_CODE.
  DATA  MATDOC TYPE BAPI2017_GM_HEAD_RET-MAT_DOC.
  DATA: IT_GOODSMVT_ITEM LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE.
  DATA: IT_RETURN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.
  " End added by William at 19.02.2026 (move pallet RTP)

  CLEAR : ITDATA ,WADATA.
  REFRESH : ITDATA.

  "CHECK PLANT
  IF ( WPB = 'X'  OR WTS = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
      VEPO~WERKS AS PLANTA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV IN ZHUW
      AND  VEKP~UEVEL = ''.

  ELSEIF ( KPB = 'X' OR KTS = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
        VEPO~WERKS AS PLANTA
        INTO CORRESPONDING FIELDS OF TABLE ITDATA
        FROM VEKP
        JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
        WHERE VEKP~EXIDV IN ZHUK
        AND  VEKP~UEVEL = ''.

  ELSEIF ( JPB = 'X' OR JTS = 'X'  ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
      VEPO~WERKS AS PLANTA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV IN ZHUJ
      AND  VEKP~UEVEL = ''.
  ENDIF.

  LOOP AT ITDATA.

    PERFORM F_GET_TYPE_SLOC.
    PERFORM F_GET_SLOC.

    "CHECK PLANT
    CLEAR V_CANC_ODO.
    IF ( WPB = 'X'  OR WTS = 'X' ).
      IF ITDATA-PLANTA <> '1000'.
        IF ITDATA-PLANTA NE ''.
          SELECT SINGLE VEPO~LGORT
               INTO ITDATA-SLOCA
               FROM VEPO
               JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
               WHERE VEKP~EXIDV = ITDATA-HUNO.

          IF ITDATA-SLOCA CP '1*'.
            V_CANC_ODO = 'X'.
          ELSE.
            ITDATA-KET = 'Plant Asal tidak berada di Area Waru'.
            ITDATA-MATDOC = '-'.

            SELECT SINGLE VEPO~LGORT
             INTO ITDATA-SLOCA
             FROM VEPO
             JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
             WHERE VEKP~EXIDV = ITDATA-HUNO.
          ENDIF.

        ENDIF.
      ENDIF.
    ELSEIF ( KPB = 'X' OR KTS = 'X' ).
      IF ITDATA-PLANTA <> '2000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Krian'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        ENDIF.
      ENDIF.
    ENDIF.

    IF ITDATA-KET = ''.
      "GET SLOC ASAL
      CLEAR : UNVEL.
      SELECT SINGLE VEPO~UNVEL
          INTO UNVEL
          FROM VEPO JOIN VEKP
          ON VEPO~VENUM = VEKP~VENUM
          WHERE VEKP~EXIDV = ITDATA-HUNO.

      IF UNVEL = ''.
        SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.

          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( WPB = 'X'  OR WTS = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF ( KPB = 'X'  OR KTS = 'X'  ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( JPB = 'X' OR JTS = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.
            ITDATA-MATDOC = '-'.

          ENDIF.
        ENDIF.

      ELSE.   "jika High Level HU ada
        SELECT SINGLE VEPO~LGORT VEPO~WERKS
            INTO (ITDATA-SLOCA,ITDATA-PLANTA)
            FROM VEPO
            WHERE VEPO~VENUM = UNVEL.

        IF ( WPB = 'X'  OR WTS = 'X' ).
          IF ITDATA-PLANTA <> '1000'.
            IF ITDATA-PLANTA NE ''.
              IF ITDATA-SLOCA CP '1*'.
                V_CANC_ODO = 'X'.
              ELSE.
                ITDATA-KET = 'Plant Asal tidak berada di Area Waru'.
                ITDATA-MATDOC = '-'.

                SELECT SINGLE VEPO~LGORT
                 INTO ITDATA-SLOCA
                 FROM VEPO
                 JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
                 WHERE VEKP~EXIDV = ITDATA-HUNO.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.
          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( WPB = 'X'  OR WTS = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF ( KPB = 'X'  OR KTS = 'X'  ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( JPB = 'X' OR JTS = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.

            ITDATA-MATDOC = '-'.
          ENDIF.

        ENDIF.
      ENDIF.

      IF ITDATA-KET = ''.
        "GET SLOC DAN PLANT TUJUAN
        ITDATA-SLOCT = TSLOC.   "get sloc from texbox
        IF ITDATA-SLOCT NE '' .
          SELECT SINGLE ZHU_MAPP~WERK2
            INTO (ITDATA-PLANTT)
            FROM ZHU_MAPP
            WHERE ZHU_MAPP~TYPES = TYPE
            AND ZHU_MAPP~WERK1 = ITDATA-PLANTA
            AND ZHU_MAPP~LGOR1 = ITDATA-SLOCA.

          IF V_CANC_ODO = 'X'.
            ITDATA-PLANTT = '1000'.
          ENDIF.
        ELSE.
          ITDATA-PLANTT = ''.
        ENDIF.

        IF ITDATA-SLOCT NOT IN RSLOCT.
          ITDATA-KET = 'Error, SLoc Tujuan salah'.
          ITDATA-MATDOC = '-'.
        ENDIF.

        IF ITDATA-KET  = ''.

          IF ITDATA-SLOCA = ITDATA-SLOCT.
            ITDATA-KET = 'Error, SLoc Asal sama dengan SLoc tujuan'.
            ITDATA-MATDOC = '-'.
          ENDIF.

          IF ITDATA-KET = ''.

            "GET INTERNAL HU
            SELECT SINGLE VEKP~VENUM
               INTO VENUM
               FROM VEKP
               WHERE VEKP~EXIDV = ITDATA-HUNO.

            "GET STATUS HU
            CLEAR : STATUS.
            CONCATENATE 'HU' VENUM INTO OBJNR.
            SELECT SINGLE TJ30T~TXT04
               INTO STATUS
               FROM TJ30T
               JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
               JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
               WHERE HUSSTAT~OBJNR = OBJNR
               AND HUSSTAT~STAT = TJ30T~ESTAT
               AND HUSSTAT~INACT = ''
               AND TJ30T~SPRAS = 'EN'.

            IF STATUS = ''.
              ITDATA-KET = 'Error, Status HU kosong'.
              ITDATA-MATDOC = '-'.
            ELSEIF STATUS <> 'QAOK'.
              ITDATA-KET = 'Error, Status HU tidak QAOK'.
              ITDATA-MATDOC = '-'.
            ENDIF.

            "MOVE HU
            IF ITDATA-KET = ''.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT  = ITDATA-HUNO
                IMPORTING
                  OUTPUT = ITDATA-HUNO.

              CLEAR : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.
              REFRESH : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.

              IT_MOVE_TO-LGORT = TSLOC.
              IF V_CANC_ODO = 'X'.
                IT_MOVE_TO-WERKS = ITDATA-PLANTT.
              ENDIF.
              APPEND IT_MOVE_TO.

              MOVE ITDATA-HUNO TO IT_EXTERNAL_ID-EXIDV.
              APPEND  IT_EXTERNAL_ID.

              CLEAR IF_EVENT.
              IF V_CANC_ODO = 'X'.
                IF_EVENT = '0007'.
              ELSE.
                IF_EVENT = '0006'.
              ENDIF.

              CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
                EXPORTING
                  IF_EVENT       = IF_EVENT
                  IF_TCODE       = 'VLMOVE'
                  IT_MOVE_TO     = IT_MOVE_TO[]
                  IT_EXTERNAL_ID = IT_EXTERNAL_ID[]
                IMPORTING
                  ES_MESSAGE     = ES_MESSAGE
                  ET_MESSAGES    = ET_MESSAGES[].

              IF SY-SUBRC = 0.
                LOOP AT ET_MESSAGES.
                  "JIKA ERROR
                  IF ET_MESSAGES-MSGTY = 'E'.
                    ITDATA-MATDOC = ''.
                  ELSE.
                    ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                  ENDIF.

                ENDLOOP.

                IF ITDATA-MATDOC = ''.
                  ITDATA-KET = 'Error, Transfer HU Gagal'.
                  ITDATA-MATDOC = '-'.
                ELSE.
                  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                    EXPORTING
                      WAIT = 'X'.

                  ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                  ITDATA-KET = 'Transfer HU Sukses'.

                  " Added by William at 19.02.2026 (move pallet RTP)
                  IF WPB = 'X' OR KPB = 'X' OR JPB = 'X'.
                    CLEAR: IT_ZPALLETR.
                    REFRESH: IT_ZPALLETR.
                    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ZPALLETR
                      FROM ZPALLETR
                      WHERE EXIDV = ITDATA-HUNO
                      AND STATUS = 'P'.

                    IF IT_ZPALLETR[] IS NOT INITIAL.
                      CLEAR: IT_ERROR_PALLET.
                      REFRESH: IT_ERROR_PALLET.

                      " Get mapping Sloc pallet movement
                      CLEAR: IT_MAP_PALLET.
                      REFRESH: IT_MAP_PALLET.

                      SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAP_PALLET
                        FROM ZMAP_TYPE
                        WHERE DELETION NE 'X'
                        AND TCODE = SY-TCODE
                        AND TYPE = 'PALLET'
                        AND OPT = 'MOVE_STLOC'.

*                      IF IT_MAP_PALLET[] IS INITIAL.
*                        " Mapping not maintained, skip
*                        CONTINUE.
*                      ENDIF.

                      LOOP AT IT_ZPALLETR.
                        CLEAR: GMHEAD, GMCODE, MATDOC, IT_GOODSMVT_ITEM, IT_RETURN.
                        REFRESH: IT_GOODSMVT_ITEM, IT_RETURN.

                        " Set data header
                        GMHEAD-DOC_DATE   = SY-DATUM.
                        GMHEAD-PSTNG_DATE = SY-DATUM.
                        GMHEAD-PR_UNAME   = SY-UNAME.
                        GMCODE-GM_CODE    = '04'.   "04 - MB1B - Transfer Posting

                        " Mvt Pallet
                        IT_GOODSMVT_ITEM-MOVE_TYPE  = '301'.

                        " Material
                        SELECT SINGLE MATNR INTO IT_GOODSMVT_ITEM-MATERIAL
                          FROM MCH1
                          WHERE CHARG = IT_ZPALLETR-PALID.

                        " UoM
                        SELECT SINGLE MEINS INTO IT_GOODSMVT_ITEM-ENTRY_UOM FROM MARA WHERE MATNR = IT_GOODSMVT_ITEM-MATERIAL.

                        " Plant Asal/PLANT dan Sloc Asal/STGE_LOC
                        SELECT SINGLE WERKS LGORT INTO (IT_GOODSMVT_ITEM-PLANT, IT_GOODSMVT_ITEM-STGE_LOC)
                          FROM MCHB
                          WHERE CHARG = IT_ZPALLETR-PALID
                          AND CLABS > 0.

                        IF SY-SUBRC NE 0.
                          CLEAR IT_ERROR_PALLET.
                          MOVE-CORRESPONDING ITDATA TO IT_ERROR_PALLET.
                          IT_ERROR_PALLET-MATDOC = '-'.
                          CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal: Pallet tidak ditemukan!' INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
                          APPEND IT_ERROR_PALLET.
                          CLEAR IT_ERROR_PALLET.
                          CONTINUE.
                        ENDIF.

                        " Sloc Tujuan/MOVE_STLOC
                        READ TABLE IT_MAP_PALLET WITH KEY TCODE = SY-TCODE
                                                          TEXT1 = ITDATA-SLOCT.
                        IF SY-SUBRC NE 0.
                          CLEAR IT_ERROR_PALLET.
                          MOVE-CORRESPONDING ITDATA TO IT_ERROR_PALLET.
                          IT_ERROR_PALLET-MATDOC = '-'.
                          CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal: SLoc tujuan pallet tidak ditemukan!' INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
                          APPEND IT_ERROR_PALLET.
                          CLEAR IT_ERROR_PALLET.
                          CONTINUE.
                        ENDIF.

                        IT_GOODSMVT_ITEM-MVT_IND         = ' '.
                        IT_GOODSMVT_ITEM-ENTRY_QNT       = '1'.  "itab_data-quant.
                        IT_GOODSMVT_ITEM-MOVE_PLANT      = ITDATA-PLANTT.  "plant target.
                        IT_GOODSMVT_ITEM-MOVE_STLOC      = IT_MAP_PALLET-TEXT2.  "sloc target.
*                        IT_GOODSMVT_ITEM-PLANT           = ITDATA-PLANTA.   "plant asal.
*                        IT_GOODSMVT_ITEM-STGE_LOC        = ITDATA-SLOCA.   "sloc asal.
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
                          MOVE-CORRESPONDING ITDATA TO IT_ERROR_PALLET.
                          IT_ERROR_PALLET-MATDOC = '-'.
                          READ TABLE IT_RETURN WITH KEY TYPE = 'E'.
                          CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal:' IT_RETURN-MESSAGE INTO IT_ERROR_PALLET-KET SEPARATED BY SPACE.
                          APPEND IT_ERROR_PALLET.
                          CLEAR: IT_ERROR_PALLET.
                        ENDIF.
                      ENDLOOP.
                    ENDIF.
                  ENDIF.
                  " End added by William at 19.02.2026 (move pallet RTP)
                ENDIF.

              ELSE.
                ITDATA-MATDOC = '-'.
                ITDATA-KET = 'Error, Transfer HU Gagal'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY ITDATA.
  ENDLOOP.

  "CHECK LOCKING.
  CLEAR WADATA.
  READ TABLE ITDATA INTO WADATA WITH KEY MATDOC = '-'.

  IF SY-SUBRC = 0.
    LOOP AT ITDATA.
      REFRESH : IT_BDCDATA, IT_BDCMSGCOLL.
      "CANCEL TRANSFER HU
      IF ITDATA-MATDOC NE '-'.
        PERFORM BDC_DYNPRO      USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=ONLI'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'SP_MBLNR'.
        PERFORM BDC_FIELD       USING 'SP_PSTDA'
                                      DATE.
        PERFORM BDC_FIELD       USING 'SP_MBLNR'
                                      ITDATA-MATDOC.
        PERFORM BDC_FIELD       USING 'SP_MJAHR'
                                      YYYY.

        CALL TRANSACTION 'HUCANC' USING IT_BDCDATA
                MODE 'E'
                UPDATE 'S'
                MESSAGES INTO IT_BDCMSGCOLL.

        ITDATA-KET = 'HU OK, Not transferred'.
        ITDATA-MATDOC = '-'.
      ELSE.
        IF ITDATA-KET = 'Error, Transfer HU Gagal'..
          ITDATA-KET = 'HU Locked, Not Transferred'.
          ITDATA-MATDOC = '-'.
        ENDIF.
      ENDIF.
      MODIFY ITDATA.
    ENDLOOP.

    CLEAR VLINE.
    DESCRIBE TABLE ITDATA LINES VLINE.
    IF VLINE = 1.
      MESSAGE 'HU Not Transferred.' TYPE 'I'.
    ELSE.
      MESSAGE 'All HU are Not Transferred.' TYPE 'I'.
    ENDIF.
  ENDIF.

  " Added by William at 19.02.2026 (move pallet RTP)
  " Add error data to ITAB
  IF IT_ERROR_PALLET[] IS NOT INITIAL.
    APPEND LINES OF IT_ERROR_PALLET TO ITDATA.
  ENDIF.
  CLEAR: IT_ERROR_PALLET.
  REFRESH: IT_ERROR_PALLET.
  " End added by William at 19.02.2026 (move pallet RTP)

  "PERFORM ALV GRID
  IF ITDATA[] IS INITIAL.
    MESSAGE 'No Data Exist!' TYPE 'I'.
  ELSE.
    PERFORM F_GETLAYOUT.
  ENDIF.
ENDFORM.                    " PENERIMAAN_BARANG

*&---------------------------------------------------------------------*
*&      Form  TRANSFER_ANTAR_AREA
*&---------------------------------------------------------------------*
*       Transfer HU antar Area
*----------------------------------------------------------------------*
FORM F_TRANSFER_ANTAR_AREA .
  DATA : X TYPE I. "COUNTER FOR UMLGO
  CLEAR : ITDATA ,WADATA.
  REFRESH : ITDATA.

  "CHECK PLANT
  IF (  WTJ = 'X' OR  WTK = 'X'  ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
      VEPO~WERKS AS PLANTA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV IN ZHUW
      AND  VEKP~UEVEL = ''.

  ELSEIF ( KTJ = 'X' OR KTW = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
        VEPO~WERKS AS PLANTA
        INTO CORRESPONDING FIELDS OF TABLE ITDATA
        FROM VEKP
        JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
        WHERE VEKP~EXIDV IN ZHUK
        AND  VEKP~UEVEL = ''.

  ELSEIF ( JTK = 'X'  OR JTW = 'X' ).
    SELECT DISTINCT VEKP~EXIDV AS HUNO
      VEPO~WERKS AS PLANTA
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VEKP
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV IN ZHUJ
      AND  VEKP~UEVEL = ''.
  ENDIF.

  LOOP AT ITDATA.

    TYPE = '2'.
    PERFORM F_GET_SLOC.

    "CHECK PLANT
    CLEAR V_CANC_ODO.
    IF ( WTJ = 'X' OR  WTK = 'X' ).
      IF ITDATA-PLANTA <> '1000'.
        IF ITDATA-PLANTA NE ''.

          SELECT SINGLE VEPO~LGORT
               INTO ITDATA-SLOCA
               FROM VEPO
               JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
               WHERE VEKP~EXIDV = ITDATA-HUNO.

          IF ITDATA-SLOCA CP '1*'.
            V_CANC_ODO = 'X'.
          ELSE.
            ITDATA-KET = 'Plant Asal tidak berada di Area Waru'.
            ITDATA-MATDOC = '-'.

            SELECT SINGLE VEPO~LGORT
             INTO ITDATA-SLOCA
             FROM VEPO
             JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
             WHERE VEKP~EXIDV = ITDATA-HUNO.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF (  KTJ = 'X' OR  KTW = 'X' ).
      IF ITDATA-PLANTA <> '2000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Krian'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ITDATA-KET = ''.
      "GET SLOC ASAL
      CLEAR : UNVEL.
      SELECT SINGLE VEPO~UNVEL
          INTO UNVEL
          FROM VEPO JOIN VEKP
          ON VEPO~VENUM = VEKP~VENUM
          WHERE VEKP~EXIDV = ITDATA-HUNO.

      IF UNVEL = ''.
        SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.

          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF (  WTJ = 'X' OR  WTK = 'X').
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.

            ELSEIF ( KTJ = 'X' OR KTW = 'X' ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( JTK = 'X'  OR JTW = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.

            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.

      ELSE. "jika hu high level ada

        SELECT SINGLE VEPO~LGORT VEPO~WERKS
            INTO (ITDATA-SLOCA,ITDATA-PLANTA)
            FROM VEPO
            WHERE VEPO~VENUM = UNVEL.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.
          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( WTJ = 'X' OR  WTK = 'X'  ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.

            ELSEIF ( KTJ = 'X'  OR KTW = 'X' ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( JTK = 'X'  OR JTW = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.
            ITDATA-MATDOC = '-'.
          ENDIF.

        ENDIF.
      ENDIF.

      IF ITDATA-KET = ''.

        SELECT SINGLE ZHU_MAPP~WERK2 ZHU_MAPP~LGOR2
          INTO (ITDATA-PLANTT, ITDATA-SLOCT)
          FROM ZHU_MAPP
          WHERE ZHU_MAPP~TYPES = TYPE
          AND ZHU_MAPP~WERK1 = ITDATA-PLANTA
          AND ZHU_MAPP~LGOR1 = ITDATA-SLOCA.

        IF ITDATA-SLOCT = ''.
          ITDATA-KET = 'Error, SLoc Tujuan Kosong'.
          ITDATA-MATDOC = '-'.
        ELSE.
          IF  ITDATA-SLOCT NOT IN RSLOCT.
            ITDATA-KET = 'Error, SLoc Tujuan Salah'.
            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.

        IF ITDATA-SLOCA = ITDATA-SLOCT.
          ITDATA-KET = 'Error, SLoc Asal sama dengan SLoc tujuan'.
          ITDATA-MATDOC = '-'.
        ENDIF.

        IF ITDATA-KET = ''.

          "GET INTERNAL HU
          CLEAR VENUM.
          SELECT SINGLE VEKP~VENUM
             INTO VENUM
             FROM VEKP
             WHERE VEKP~EXIDV = ITDATA-HUNO.

          "GET STATUS HU
          CLEAR : STATUS.
          CONCATENATE 'HU' VENUM INTO OBJNR.
          SELECT SINGLE TJ30T~TXT04
             INTO STATUS
             FROM TJ30T
             JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
             JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
             WHERE HUSSTAT~OBJNR = OBJNR
             AND HUSSTAT~STAT = TJ30T~ESTAT
             AND HUSSTAT~INACT = ''
             AND TJ30T~SPRAS = 'EN'.


          IF STATUS = ''.
            ITDATA-KET = 'Error, Status HU kosong'.
            ITDATA-MATDOC = '-'.
          ELSEIF STATUS <> 'QAOK'.
            ITDATA-KET = 'Error, Status HU tidak QAOK'.
            ITDATA-MATDOC = '-'.
          ENDIF.

          IF ITDATA-KET = ''.
            "GET MAX DATE AND TIME STATUS HU
            CLEAR : VAEDAT , VAETIME.
            SELECT MAX( ZQM001~AEDAT )
              INTO VAEDAT
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO.

            SELECT MAX( ZQM001~AETIME )
              INTO VAETIME
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO
              AND ZQM001~AEDAT = VAEDAT.

            "GET STATUS PASS/HOLD.
            CLEAR PSTAT.
            SELECT SINGLE ZQM001~PSTAT
              INTO PSTAT
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO
              AND ZQM001~AEDAT = VAEDAT
              AND ZQM001~AETIME = VAETIME.

            IF SY-SUBRC = 0.
              IF PSTAT NE 'P'.
                ITDATA-KET = 'Status HU is not Pass'.
                ITDATA-MATDOC = '-'.
              ENDIF.
            ELSE.
              IF PSTAT NE 'P'.
                ITDATA-KET = 'Status HU is not Pass'.
                ITDATA-MATDOC = '-'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY ITDATA.
  ENDLOOP.

  "CEK APAKAH ADA TRANSFER HU YANG ERROR.
  CLEAR : WADATA, VSTAT.
  READ TABLE ITDATA INTO WADATA WITH KEY MATDOC = '-'.

  IF SY-SUBRC = 0.
    VSTAT = 'F'.
  ELSE.
    VSTAT = 'T'.
  ENDIF.

  IF VSTAT = 'F'.
    MESSAGE 'All HU are not transfered.' TYPE 'I'.

    LOOP AT ITDATA WHERE MATDOC = ''.
      ITDATA-KET = 'HU OK, Not Transferred'.
      MODIFY ITDATA.
    ENDLOOP.

  ELSE.
    LOOP AT ITDATA.
      "transfer hu to gudang wm.
      IF ITDATA-KET = ''.

        CLEAR : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.
        REFRESH : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.

        IT_MOVE_TO-LGORT = ITDATA-SLOCT.
        APPEND IT_MOVE_TO.
        MOVE ITDATA-HUNO TO IT_EXTERNAL_ID-EXIDV.
        APPEND  IT_EXTERNAL_ID.

        CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
          EXPORTING
            IF_EVENT       = '0006'
            IF_TCODE       = 'VLMOVE'
            IT_MOVE_TO     = IT_MOVE_TO[]
            IT_EXTERNAL_ID = IT_EXTERNAL_ID[]
          IMPORTING
            ES_MESSAGE     = ES_MESSAGE
            ET_MESSAGES    = ET_MESSAGES[].

        IF SY-SUBRC = 0.
          LOOP AT ET_MESSAGES.
            "JIKA ERROR
            IF ET_MESSAGES-MSGTY = 'E'.
              ITDATA-MATDOC = ''.
            ELSE.
              ITDATA-MATDOC = ET_MESSAGES-MSGV1.
            ENDIF.
          ENDLOOP.

          IF ITDATA-MATDOC = ''.
            ITDATA-KET = 'Error, Transfer HU Gagal'.
            ITDATA-MATDOC = '-'.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.

            "UPDATE DATA IN ZPACKPCL.
            CLEAR : WA_PSOURCE, T_PSOURCE,VENUM.
            REFRESH : T_PSOURCE.
            SELECT SINGLE VENUM INTO VENUM FROM VEKP WHERE VEKP~EXIDV = ITDATA-HUNO.

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

            ITDATA-MATDOC = ET_MESSAGES-MSGV1.
            ITDATA-KET = 'Transfer HU Sukses'.
          ENDIF.

        ELSE.
          ITDATA-MATDOC = '-'.
          ITDATA-KET = 'Error, Transfer HU Gagal'.
        ENDIF.

      ENDIF.

      MODIFY ITDATA.

    ENDLOOP.

    CLEAR WADATA.
    READ TABLE ITDATA WITH KEY MATDOC = '-'.

    IF SY-SUBRC = 0.
      "CHECK LOCKING
      LOOP AT ITDATA.
        REFRESH  : IT_BDCDATA, IT_BDCMSGCOLL.

        "CANCEL TRANSFER HU
        IF ITDATA-MATDOC NE '-'.
          PERFORM BDC_DYNPRO      USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ONLI'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'SP_MBLNR'.
          PERFORM BDC_FIELD       USING 'SP_PSTDA'
                                        DATE.
          PERFORM BDC_FIELD       USING 'SP_MBLNR'
                                        ITDATA-MATDOC.
          PERFORM BDC_FIELD       USING 'SP_MJAHR'
                                        YYYY.

          CALL TRANSACTION 'HUCANC' USING IT_BDCDATA
                  MODE 'E'
                  UPDATE 'S'
                  MESSAGES INTO IT_BDCMSGCOLL.

          ITDATA-KET = 'HU OK, Not Transferred'.
          ITDATA-MATDOC = '-'.
        ELSE.

          IF ITDATA-KET = 'Error, Transfer HU Gagal'..
            ITDATA-KET = 'HU Locked, Not Transferred'.
            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.
        MODIFY ITDATA.
      ENDLOOP.

      CLEAR VLINE.
      DESCRIBE TABLE ITDATA LINES VLINE.
      IF VLINE = 1.
        MESSAGE 'HU Not Transferred.' TYPE 'I'.
      ELSE.
        MESSAGE 'All HU are Not Transferred.' TYPE 'I'.
      ENDIF.

    ELSE.
      "Transfer ke area lain
      IF ( WTJ = 'X' OR  WTK = 'X' OR KTJ = 'X' OR KTW = 'X' OR JTK = 'X'  OR JTW = 'X') .
        CLEAR IT_BDCDATA.
        REFRESH IT_BDCDATA.

        LOOP AT ITDATA.
          IF ITDATA-MATDOC = '-'.
            ITDATA-KET = 'Transfer HU ke gudang non WM gagal'.
          ELSE.
            PERFORM F_GET_TYPE_SLOC.
            PERFORM F_GET_SLOC.

            CLEAR : PLANA, SLOCA.
            PLANA = ITDATA-PLANTT.
            SLOCA  = ITDATA-SLOCT.
            CLEAR : ITDATA-PLANTT, ITDATA-SLOCT.

            "CHECK SLOC FROM ZHU_MAPP
            CLEAR INDICATOR.
            IF SLOCA NOT IN RSLOCA.
              INDICATOR = SLOCA+0(1).
              IF (  WTJ = 'X' OR  WTK = 'X' ).
                IF INDICATOR = '1'.
                  ITDATA-KET = 'Error, Sloc Asal salah'.
                ELSE.
                  ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
                ENDIF.
              ELSEIF (  KTJ = 'X'  OR KTW = 'X' ).
                IF INDICATOR = '2'.
                  ITDATA-KET = 'Error, Sloc Asal salah'.
                ELSE.
                  ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
                ENDIF.
              ELSEIF (  JTK = 'X'  OR JTW = 'X' ).
                IF INDICATOR = '3'.
                  ITDATA-KET = 'Error, Sloc Asal salah'.
                ELSE.
                  ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
                ENDIF.
              ENDIF.
              ITDATA-MATDOC = '-'.
            ENDIF.

            "GET PLANT TUJUAN DAN SLOC TUJUAN
            SELECT SINGLE ZHU_MAPP~WERK2 ZHU_MAPP~LGOR2
                INTO (ITDATA-PLANTT, ITDATA-SLOCT)
                FROM ZHU_MAPP
                WHERE ZHU_MAPP~TYPES = TYPE
                AND ZHU_MAPP~WERK1 = PLANA
                AND ZHU_MAPP~LGOR1 = SLOCA.

            IF ITDATA-SLOCT = ''.
              ITDATA-KET = 'Error, SLoc Tujuan Kosong'.
              ITDATA-MATDOC = '-'.
            ELSE.
              IF  ITDATA-SLOCT NOT IN RSLOCT.
                ITDATA-KET = 'Error, SLoc Tujuan Salah'.
                ITDATA-MATDOC = '-'.
              ENDIF.
            ENDIF.


            IF WTK = 'X' OR WTJ = 'X' OR KTW = 'X' OR JTW = 'X'.

              PERFORM BDC_DYNPRO      USING 'SAPLLE_MOV' '2000'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=TCVG'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'LEMOVHUS-HUWBEVENT'.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-HUWBEVENT'
                                            '0007'.
              PERFORM BDC_DYNPRO      USING 'SAPLLE_MOV' '2000'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=TCHC'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'LEMOVHUS-EXIDV'.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-EXIDV'
                                             ITDATA-HUNO.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-WERKS'
                                            ITDATA-PLANTT.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-LGORT'
                                            ITDATA-SLOCT.

            ELSE.

              PERFORM BDC_DYNPRO      USING 'SAPLLE_MOV' '2000'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=TCVG'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'LEMOVHUS-HUWBEVENT'.
              SET PARAMETER ID 'WRK' FIELD ITDATA-PLANTT.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-HUWBEVENT'
                                            '0006'.
              PERFORM BDC_DYNPRO      USING 'SAPLLE_MOV' '2000'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=TCHC'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'LEMOVHUS-EXIDV'.
              SET PARAMETER ID 'WRK' FIELD ITDATA-PLANTT.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-HUWBEVENT'
                                '0006'.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-EXIDV'
                                             ITDATA-HUNO.
              PERFORM BDC_FIELD       USING 'LEMOVHUS-LGORT'
                                            ITDATA-SLOCT.

            ENDIF.
          ENDIF.
          MODIFY ITDATA.
        ENDLOOP.

        SET PARAMETER ID 'MBN' FIELD SPACE.
        SET PARAMETER ID 'MJA' FIELD SPACE.

        PERFORM BDC_DYNPRO      USING 'SAPLLE_MOV' '2000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE' '=TCCR'.

        "CALL TRANSACTION VLMOVE.
        CALL TRANSACTION 'VLMOVE' USING IT_BDCDATA
             MODE 'E'
             UPDATE 'S'
             MESSAGES INTO IT_BDCMSGCOLL.

        IF SY-SUBRC = 0.

          LOOP AT ITDATA.
            "CHECK APAKAH HU SUDAH DITRANSFER
            CLEAR : VENUM, MATNR.
            REFRESH TODO.
            "get batch HU.
            CLEAR BATCH.
            SELECT SINGLE VEPO~CHARG
               INTO BATCH
               FROM VEPO
               JOIN VEKP ON  VEPO~VENUM = VEKP~VENUM
               WHERE VEKP~EXIDV = ITDATA-HUNO.

            "GET INTERNAL HU
            IF BATCH = ''.
              SELECT SINGLE VEPO~UNVEL
               INTO VENUM
               FROM VEPO
               JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
               WHERE VEKP~EXIDV = ITDATA-HUNO
                AND VEPO~UNVEL <> ''.

              IF SY-SUBRC = 0.
                SELECT SINGLE VEPO~MATNR INTO MATNR FROM VEPO WHERE VENUM = VENUM.
              ENDIF.

            ELSE.
              SELECT SINGLE VEKP~VENUM
                         INTO VENUM
                         FROM VEKP
                         WHERE VEKP~EXIDV = ITDATA-HUNO.

              IF SY-SUBRC = 0.
                SELECT SINGLE VEPO~MATNR INTO MATNR FROM VEPO WHERE VENUM = VENUM.
              ENDIF.
            ENDIF.

            IF MATNR = ''.
              SELECT DISTINCT LIPS~CHARG
                INTO CORRESPONDING FIELDS OF TABLE TODO
                FROM LIPS
                JOIN VEPO ON LIPS~CHARG = VEPO~CHARG
                WHERE VEPO~VENUM = VENUM
                AND LIPS~PSTYV = 'HSTP'.

            ELSE.
              SELECT DISTINCT LIPS~CHARG
                INTO CORRESPONDING FIELDS OF TABLE TODO
                FROM LIPS
                JOIN VEPO ON LIPS~CHARG = VEPO~CHARG
                WHERE VEPO~VENUM = VENUM
                AND LIPS~PSTYV = 'HSTP'
                AND LIPS~MATNR = MATNR.

            ENDIF.

            LOOP AT TODO.
              SELECT MAX( LIPS~VBELN )
                INTO TODO-VBELN
                FROM LIPS
                WHERE LIPS~CHARG = TODO-CHARG
                AND  LIPS~PSTYV = 'HSTP'.
              MODIFY TODO.
            ENDLOOP.

            IF TODO[] IS INITIAL.
              ITDATA-MATDOC = '-'.
              ITDATA-KET =  'Error, Transfer HU Gagal'.
            ELSE.
              DELETE ADJACENT DUPLICATES FROM TODO COMPARING VBELN.

              LOOP AT TODO.
                MOVE TODO-VBELN TO ITDATA-MATDOC.
                ITDATA-KET = 'Transfer HU Sukses'.
              ENDLOOP.
            ENDIF.
            MODIFY ITDATA.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  "PERFORM ALV GRID
  IF ITDATA[] IS INITIAL.
    MESSAGE 'No Data Exist!' TYPE 'I'.
  ELSE.
    PERFORM F_GETLAYOUT.
  ENDIF.

ENDFORM.                    " TRANSFER_ANTAR_AREA
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
  T_SORT-FIELDNAME = 'HUNO'.
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
  T_SORT-FIELDNAME = 'PLANTA'.
  T_SORT-UP = 'X'.
  T_SORT-SUBTOT = ''.
  APPEND T_SORT.

  N = N + 1.
  T_SORT-SPOS = N.
  T_SORT-FIELDNAME = 'SLOCT'.
  T_SORT-UP = 'X'.
  T_SORT-SUBTOT = ''.
  APPEND T_SORT.

  N = N + 1.
  T_SORT-SPOS = N.
  T_SORT-FIELDNAME = 'PLANTT'.
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
      T_OUTTAB                = ITDATA
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  GET_HUPLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_HUPLANT.
  RANGES: ZHU FOR VEKP-EXIDV.

  DATA : BEGIN OF LMSG OCCURS 0,
          MSGID  LIKE SY-MSGID,
          MSGTY  LIKE SY-MSGTY,
          MSGNO  LIKE SY-MSGNO,
          MSGV1  LIKE SY-MSGV1,
          MSGV2  LIKE SY-MSGV2,
          MSGV3  LIKE SY-MSGV3,
          MSGV4  LIKE SY-MSGV4,
          LINENO TYPE MESG-ZEILE,
        END OF LMSG.

  DATA: IT_VEPO LIKE VEPOVB OCCURS 0,
        IT_EXIDV TYPE HUM_EXIDV_T,
        WA_VEPO LIKE VEPOVB OCCURS 0 WITH HEADER LINE,
        LMSG2 LIKE LMSG OCCURS 0,
        VMESSAGE(50),
        VNO TYPE I VALUE 1.

  CLEAR: IT_VEPO,IT_EXIDV,ZHU[], LMSG, LMSG2.
  REFRESH: IT_VEPO,IT_EXIDV,ZHU[], LMSG, LMSG2.

  IF ZHUW[] IS NOT INITIAL.
    ZHU[] = ZHUW[].
  ELSEIF ZHUK[] IS NOT INITIAL.
    ZHU[] = ZHUK[].
  ELSEIF ZHUJ[] IS NOT INITIAL.
    ZHU[] = ZHUJ[].
  ENDIF.

  LOOP AT ZHU.
    CLEAR: IT_EXIDV, IT_VEPO.
    REFRESH: IT_EXIDV, IT_VEPO.

    APPEND ZHU-LOW TO IT_EXIDV.

    CALL FUNCTION 'HU_GET_HUS_DB'
      EXPORTING
        IT_HU_NUMBERS = IT_EXIDV
      IMPORTING
*       ET_HU_HEADER  =
        ET_HU_ITEMS   = IT_VEPO.

    LOOP AT IT_VEPO INTO WA_VEPO WHERE CHARG IS NOT INITIAL.
    ENDLOOP.

    IF WA_VEPO-WERKS EQ '1000' OR WA_VEPO-WERKS EQ '2000' .
      SHIFT ZHU-LOW LEFT DELETING LEADING '0'.
      LMSG-MSGV1 = ZHU-LOW.
      LMSG-MSGID = '00'.
      LMSG-MSGTY = 'S'.
      LMSG-MSGNO = '1'.
      LMSG-LINENO = VNO.
      APPEND LMSG.
    ELSE.
      SHIFT ZHU-LOW LEFT DELETING LEADING '0'.
      CONCATENATE ZHU-LOW 'Bukan Plant 1000 atau 2000' INTO LMSG-MSGV1 SEPARATED BY SPACE.
      LMSG-MSGID = '00'.
      LMSG-MSGTY = 'E'.
      LMSG-MSGNO = '1'.
      LMSG-LINENO = VNO.
      APPEND LMSG.
    ENDIF.
    VNO = VNO + 1.
  ENDLOOP.

  LMSG2[] = LMSG[].
  DELETE LMSG2 WHERE MSGTY EQ 'S'.

  IF LMSG2[] IS NOT INITIAL.
    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        I_MESSAGE_TAB = LMSG.

    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.                    "GET_HUPLANT