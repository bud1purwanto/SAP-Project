* Report  ZMMR_STOCK_BY_CHAR
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Report Stock Overview with Characteristic
*
* Application Area - MM
* ABAPer           - Bagus Aditya Putra
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*----------------------------------------------------------------------*

INCLUDE ZBAP_STOCK_BY_CHAR1_TOP.

INCLUDE ZBAP_STOCK_BY_CHAR1_F01.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT1-LOW.
  PERFORM GT_LST_CHAR USING 'ZZCODE' CHANGING S_ATWRT1-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT5-LOW.
  PERFORM GT_LST_CHAR USING 'ZZTREATMENT' CHANGING S_ATWRT5-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT6-LOW.
  PERFORM GT_LST_CHAR USING 'ZZCORE' CHANGING S_ATWRT6-LOW.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT8.
*  PERFORM GT_LST_CHAR USING 'I/O' CHANGING S_ATWRT8.


INITIALIZATION.
  TXT1 = 'Material'.
  TXT2 = 'Plant'.
  TXT3 = 'Storage Location'.
  TXT4 = 'Batch'.
  TXT5 = 'SO Number'.
  TXT6 = 'SO Item'.
  TXT7 = 'Sales Doc Type'.

  TXT8 = 'Material Type'.
  TXT9 = 'Type Film'.
  TXT10 = 'Thickness/Tebal'.
  TXT11 = 'Width/Lebar'.
  TXT12 = 'Length/Panjang'.
  TXT13 = 'Treatment'.
  TXT14 = 'Core'.
  TXT15 = 'Toyobo Combination No'. "ADDED FOR AGS BY FATHIR ON 04.05.2021 - Combination No
  TXT20 = 'Customer Subcontracting'.
*TXT15 = 'Inhouse/Outsource'.

  TXT16 = 'Special stock indicator'.
  TXT17 = 'Screen'.
  TXT18 = 'OLAP'.
  TXT21 = 'WMS'. " Added by Budi at 28.10.2026 (Execution Type WMS - generate by AI)
  TXT19 = 'DBCO Name'.
  MOVE 'Program Information' TO INFO. "DOCUMENTATION

  "DOCUMENTATION*************************

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.
*  *************************************

  IF SY-UCOMM = 'ONLI'.
    PERFORM CHECK_WERKS .
    PERFORM CHECK_LGORT .
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  " Modified by William at 13.08.2026 (Show QA Reason filters only with display options - generate by AI)
  IF P_HHU IS INITIAL.
    CLEAR P_HHUF.
  ENDIF.
  IF P_HBATCH IS INITIAL.
    CLEAR P_HBAF.
  ENDIF.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'HUF' AND P_HHU IS INITIAL.
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
    ELSEIF SCREEN-GROUP1 = 'BAF' AND P_HBATCH IS INITIAL.
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      " Modified by Budi at 28.10.2026 (Execution Type WMS - generate by AI)
      IF SCREEN-NAME = 'LRB2' OR SCREEN-NAME = 'LRB3'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF LRB1 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'CON'.
        SCREEN-INPUT = 0.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  " Modified by Budi at 28.10.2026 (Show DBCO Name for WMS - generate by AI)
  ELSEIF LRB2 = 'X' OR LRB3 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'CON'.
        SCREEN-INPUT = 1.
        SCREEN-ACTIVE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.



START-OF-SELECTION.
  " ADD VALIDASI ROLE NEW COMPANY
  LOOP AT S_WERKS.
    AUTHORITY-CHECK OBJECT 'Z_WERKS'
    ID 'ZWERKS' FIELD S_WERKS-LOW.
    IF SY-SUBRC NE 0.
      MESSAGE 'No Authorization' TYPE 'E'.
    ENDIF.
  ENDLOOP.
  " END VALIDASI ROLE NEW COMPANY

  PERFORM GT_DATA.
  IF LRB1 IS INITIAL.
    IF S_CONN IS INITIAL.
      MESSAGE 'Masukan DBCO Connection name...!' TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
*    SAP_CON = S_CONN.
    " Modified by Budi at 28.10.2026 (Execution Type WMS - generate by AI)
    IF LRB3 = 'X'.
      PERFORM INSERT_SQL_WMS.
    ELSE.
    PERFORM CONNECT_SQL.
    PERFORM INSERT_SQL.
    ENDIF.
  ELSEIF LRB2 IS INITIAL.
    IF P_ACTWGT = 'X'.
      PERFORM GET_ACTUAL_WEIGHT.
    ENDIF.

    PERFORM SET_ALV.
  ENDIF.