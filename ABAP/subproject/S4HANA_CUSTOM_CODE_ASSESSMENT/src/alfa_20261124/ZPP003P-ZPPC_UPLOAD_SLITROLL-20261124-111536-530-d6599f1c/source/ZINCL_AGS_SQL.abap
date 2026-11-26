*&---------------------------------------------------------------------*
*&  Include           ZINCL_AGS_SQL
*&---------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | 01.07.19 | Fathir      |            | Program Created          *
* 002 | 12.07.19 | Fathir      |            | Clear AGSCX_MSG          *
* 003 | 26.07.19 | Fathir      |            | Add SAP-AGS SQL Logging  *
*                                           | mechanism                *
* 004 | 19.08.19 | Gani        |            | Change AGS DRC mechanism *
*----------------------------------------------------------------------*

DATA: VLOG_PROGRAM(50) TYPE C VALUE SY-REPID,
      VLOG_DATE TYPE SY-DATUM,
      VLOG_TIME(8) TYPE C,
      VLOG_STATUS(1) TYPE C,
      VLOG_MSG(500) TYPE C,         "-- 0 = initial process, 1 = success, -1 = failed
      VLOG_TOTALRECORDS(10) TYPE C,
      VLOG_TCODE TYPE SY-TCODE,
      VLOG_AGSTABLE(50) TYPE C,
      VLOG_TERMINAL(50) TYPE C,
      VLOG_TEMP(100) TYPE C.

DATA: V_ISAGSDRC(1) TYPE C,         "-- ADDED FOR AGS BY FATHIR ON 26.07.2019 - Flag to decide the connection between AGS-LIVE or AGS-DRC
      V_ISDRCOK(1) TYPE C.          "-- ADDED FOR AGS BY FATHIR ON 26.07.2019 - Flag to determine is DRC mechanism is OK

DATA: AGSLEX_ROOT TYPE REF TO CX_ROOT.
DATA: AGSCX_MSG(500) TYPE C.

*--- CHANGED FOR AGS BY GANI ON 19.08.2019 - DRC mechanism for AGS
DATA: IT_AGSDRCLOG TYPE STANDARD TABLE OF ZTLOG_AGS,
      WA_AGSDRCLOG LIKE LINE OF IT_AGSDRCLOG,
      VDRC_TIME LIKE SY-UZEIT,
      VDRC_STAT LIKE ZTLOG_AGS-ZSTAT,
      VDRC_TERMINAL LIKE USR41-TERMINAL,
      R_BKTXT TYPE RANGE OF MKPF-BKTXT,
      R_CHARG TYPE RANGE OF MCH1-CHARG,
      R_AUFNR TYPE RANGE OF AUFK-AUFNR,
      R_MBLNR TYPE RANGE OF MSEG-MBLNR,
      R_ZDATA TYPE RANGE OF ZTLOG_AGS-ZDATA.

DATA: BEGIN OF WA_DATA,
         SIGN   TYPE C LENGTH 1,
         OPTION TYPE C LENGTH 2,
         LOW    TYPE C LENGTH 25,
         HIGH   TYPE C LENGTH 25,
      END OF WA_DATA.
*--- CHANGED FOR AGS BY GANI ON 19.08.2019 - DRC mechanism for AGS

CLEAR: VLOG_DATE,
       VLOG_TIME,
       VLOG_STATUS,
       VLOG_MSG,
       VLOG_TOTALRECORDS,
       VLOG_TCODE,
       VLOG_AGSTABLE,
       VLOG_TERMINAL,
       VLOG_TEMP,
       AGSCX_MSG,         "-- ADDED BY FATHIR ON 12.07.2019
       V_ISAGSDRC,        "-- ADDED FOR AGS BY FATHIR ON 26.07.2019 - Clear Flag AGS-DRC
       V_ISDRCOK.         "-- ADDED FOR AGS BY FATHIR ON 26.07.2019 - Clear Flag DRC-OK

*&---------------------------------------------------------------------*
*&      Form  CHECK_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM AGS_CHECK_SERVER.

  IF SY-HOST = 'TRIASWIN2008' OR SY-HOST = 'SAPTRPKR' OR SY-HOST = 'SAPTRPWARU'.
  ELSE.
    STOP.
  ENDIF.

ENDFORM.                   "CHECK_SERVER

*&---------------------------------------------------------------------*
*&      Form  AGS_CONNECT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM AGS_CONNECT_SQL.

  TRY.
      EXEC SQL.
        CONNECT TO 'AGS' AS 'DBAGS'
      ENDEXEC.

      EXEC SQL.
        SET CONNECTION 'DBAGS'
      ENDEXEC.

      "-- ADDED FOR AGS BY FATHIR ON 25.10.2019 - Fill AGS-DRC Flag
      IF SY-SUBRC NE 0.
        V_ISAGSDRC = 'X'.
      ENDIF.
      "-- ADDED FOR AGS BY FATHIR ON 25.10.2019 - Fill AGS-DRC Flag
    CATCH CX_ROOT INTO AGSLEX_ROOT.
      V_ISAGSDRC = 'X'.                         "-- ADDED FOR AGS BY FATHIR ON 26.07.2019 - Fill AGS-DRC Flag
  ENDTRY.

  "-- ADDED FOR AGS BY FATHIR ON 26.07.2019 - Connect to AGS-DRC SQL connection profile
  IF V_ISAGSDRC EQ 'X'.
    CLEAR AGSCX_MSG.

    TRY.
        EXEC SQL.
          CONNECT TO 'AGS_DRC' AS 'DBAGS'
        ENDEXEC.

        EXEC SQL.
          SET CONNECTION 'DBAGS'
        ENDEXEC.

        "-- ADDED FOR AGS BY FATHIR ON 25.10.2019 - Fill AGS-DRC Flag
        IF SY-SUBRC NE 0.
          AGSCX_MSG = 'Failed to connect to DRC server'.
        ENDIF.
        "-- ADDED FOR AGS BY FATHIR ON 25.10.2019 - Fill AGS-DRC Flag
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS INITIAL.
      V_ISDRCOK = 'X'.
    ENDIF.
  ENDIF.
  "-- ADDED FOR AGS BY FATHIR ON 26.07.2019 - Connect to AGS-DRC SQL connection profile

ENDFORM.                    "AGS_CONNECT_SQL

*&---------------------------------------------------------------------*
*&      Form  AGS_INSERT_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PIN_STATUS        text
*      -->PIN_MSG           text
*      -->PIN_TOTALRECORDS  text
*----------------------------------------------------------------------*
FORM AGS_INSERT_LOG USING PIN_STATUS PIN_MSG PIN_TOTALRECORDS.

  TRY.
      EXEC SQL.
        INSERT INTO DBO.XLOG_SYNC_SAP
        ( [Program], [Date], [Time], [Status], [Message], [TotalRecords] )
        VALUES
        ( :VLOG_PROGRAM, :VLOG_DATE, :VLOG_TIME, :PIN_STATUS, :PIN_MSG, :PIN_TOTALRECORDS )
      ENDEXEC.

    CATCH CX_ROOT INTO AGSLEX_ROOT.
      AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
      MESSAGE AGSCX_MSG TYPE 'S'.
  ENDTRY.


ENDFORM.                    "AGS_INSERT_LOG

*&---------------------------------------------------------------------*
*&      Form  AGS_UPDATE_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PIN_STATUS text
*----------------------------------------------------------------------*
FORM AGS_UPDATE_LOG USING PIN_STATUS TYPE C
                          PIN_ID TYPE C.

  CLEAR: VLOG_TIME.
  WRITE SY-UZEIT TO VLOG_TIME.

  TRY.
      EXEC SQL.
        UPDATE DBO.XLOG_SYNC_SAP
          SET
              [Status] = :PIN_STATUS,
              [Time]  = :VLOG_TIME
          WHERE
              [Status] = ''
              AND [Message] = :PIN_ID ;
      ENDEXEC.

    CATCH CX_ROOT INTO AGSLEX_ROOT.
      AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
      MESSAGE AGSCX_MSG TYPE 'S'.
  ENDTRY.

ENDFORM.                    "AGS_UPDATE_LOG

*&---------------------------------------------------------------------*
*&      Form  AGS_COMMIT_ROLLBACK
*&---------------------------------------------------------------------*
*       Commit / Rollback SAP-AGS transaction
*----------------------------------------------------------------------*
FORM AGS_COMMIT_ROLLBACK.
  "-- Check if AGSCX_MSG is empty
  "-- to decide it will be rollback or commit the SQL transaction
  IF AGSCX_MSG IS NOT INITIAL.
    TRY.
        EXEC SQL.
          ROLLBACK WORK.
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    "-- ADDED FOR AGS BY FATHIR ON 22.10.2019 - Change message while acquiring Deadlock in AGS SQL
    IF AGSCX_MSG CP '*MSSDEADL*'.
      AGSCX_MSG = 'Please check your AGS log.'.
      MESSAGE AGSCX_MSG TYPE 'S'.
    ENDIF.
    "-- ADDED FOR AGS BY FATHIR ON 22.10.2019 - Change message while acquiring Deadlock in AGS SQL
  ELSE.
    TRY.
        EXEC SQL.
          COMMIT WORK.
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.
  ENDIF.
ENDFORM.                    "AGS_COMMIT_ROLLBACK

*&---------------------------------------------------------------------*
*&      Form  AGS_DISCONNECT
*&---------------------------------------------------------------------*
*       ADDED FOR AGS BY FATHIR ON 09.10.2019
*       Disconnect the connection
*----------------------------------------------------------------------*
FORM AGS_DISCONNECT.
  TRY.
      EXEC SQL.
        DISCONNECT 'DBAGS'
      ENDEXEC.
    CATCH CX_ROOT INTO AGSLEX_ROOT.
      AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
      MESSAGE AGSCX_MSG TYPE 'S'.
  ENDTRY.
ENDFORM.                    "AGS_DISCONNECT

DEFINE AGS_CONVERT_DATE.
  "&1 : Internal Table
  "&2 : Field Name

  &1-&2 = '19000101'.
  MODIFY &1 TRANSPORTING &2 WHERE &2 = 00000000.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  F_INSERTAGSDRC
*&---------------------------------------------------------------------*
*       Insert DRC/Log status of AGS data
*       ADDED BY GANI ON 19.08.2019
*----------------------------------------------------------------------*
*      -->S_BKTXT    text
*      -->S_CHARG    text
*      -->S_AUFNR    text
*      -->S_MBLNR    text
*----------------------------------------------------------------------*
FORM F_INSERTAGSDRC USING S_BKTXT LIKE R_BKTXT
                        S_CHARG LIKE R_CHARG
                        S_AUFNR LIKE R_AUFNR
                        S_MBLNR LIKE R_MBLNR.

  CLEAR: VDRC_TIME, VDRC_STAT, VDRC_TERMINAL.
  CLEAR: IT_AGSDRCLOG, WA_AGSDRCLOG.
  REFRESH: IT_AGSDRCLOG.

  "-- Get Terminal value
  CALL FUNCTION 'TERMINAL_ID_GET'
    EXPORTING
      USERNAME = SY-UNAME
    IMPORTING
      TERMINAL = VDRC_TERMINAL.

  "-- Set initial status & time
  VDRC_STAT = 'INPROGRESS'.
  VDRC_TIME = SY-UZEIT.

  IF SY-SUBRC <> 0.
    VDRC_TERMINAL = 'SAP CLIENT'.
    MESSAGE 'Failed to get terminal ID' TYPE 'S'.
  ENDIF.

  "-- BKTXT - Roll Number
  IF S_BKTXT[] IS NOT INITIAL.
    LOOP AT S_BKTXT INTO WA_DATA.
      CLEAR WA_AGSDRCLOG.
      WA_AGSDRCLOG-MANDT = SY-MANDT.
      WA_AGSDRCLOG-TERMINAL = VDRC_TERMINAL.
      WA_AGSDRCLOG-ZTCODE = SY-TCODE.
      WA_AGSDRCLOG-ZDATA = WA_DATA-LOW.
      WA_AGSDRCLOG-ZTYPE = 'BKTXT'.
      WA_AGSDRCLOG-ZSTAT = VDRC_STAT.
      WA_AGSDRCLOG-UNAME = SY-UNAME.
      WA_AGSDRCLOG-ZDATE = SY-DATUM.
      WA_AGSDRCLOG-ZTIME = VDRC_TIME.
      APPEND WA_AGSDRCLOG TO IT_AGSDRCLOG.
      CLEAR WA_DATA.
    ENDLOOP.
  ENDIF.

  "-- CHARG - Batch
  IF S_CHARG[] IS NOT INITIAL.
    LOOP AT S_CHARG INTO WA_DATA.
      CLEAR WA_AGSDRCLOG.
      WA_AGSDRCLOG-MANDT = SY-MANDT.
      WA_AGSDRCLOG-TERMINAL = VDRC_TERMINAL.
      WA_AGSDRCLOG-ZTCODE = SY-TCODE.
      WA_AGSDRCLOG-ZDATA = WA_DATA-LOW.
      WA_AGSDRCLOG-ZTYPE = 'CHARG'.
      WA_AGSDRCLOG-ZSTAT = VDRC_STAT.
      WA_AGSDRCLOG-UNAME = SY-UNAME.
      WA_AGSDRCLOG-ZDATE = SY-DATUM.
      WA_AGSDRCLOG-ZTIME = VDRC_TIME.
      APPEND WA_AGSDRCLOG TO IT_AGSDRCLOG.
      CLEAR WA_DATA.
    ENDLOOP.
  ENDIF.

  "-- AUFNR - Order Number
  IF S_AUFNR[] IS NOT INITIAL.
    LOOP AT S_AUFNR INTO WA_DATA.
      CLEAR WA_AGSDRCLOG.
      WA_AGSDRCLOG-MANDT = SY-MANDT.
      WA_AGSDRCLOG-TERMINAL = VDRC_TERMINAL.
      WA_AGSDRCLOG-ZTCODE = SY-TCODE.
      WA_AGSDRCLOG-ZDATA = WA_DATA-LOW.
      WA_AGSDRCLOG-ZTYPE = 'AUFNR'.
      WA_AGSDRCLOG-ZSTAT = VDRC_STAT.
      WA_AGSDRCLOG-UNAME = SY-UNAME.
      WA_AGSDRCLOG-ZDATE = SY-DATUM.
      WA_AGSDRCLOG-ZTIME = VDRC_TIME.
      APPEND WA_AGSDRCLOG TO IT_AGSDRCLOG.
      CLEAR WA_DATA.
    ENDLOOP.
  ENDIF.

  "-- MBLNR - Matdoc
  IF S_MBLNR[] IS NOT INITIAL.
    LOOP AT S_MBLNR INTO WA_DATA.
      CLEAR WA_AGSDRCLOG.
      WA_AGSDRCLOG-MANDT = SY-MANDT.
      WA_AGSDRCLOG-TERMINAL = VDRC_TERMINAL.
      WA_AGSDRCLOG-ZTCODE = SY-TCODE.
      WA_AGSDRCLOG-ZDATA = WA_DATA-LOW.
      WA_AGSDRCLOG-ZTYPE = 'MBLNR'.
      WA_AGSDRCLOG-ZSTAT = VDRC_STAT.
      WA_AGSDRCLOG-UNAME = SY-UNAME.
      WA_AGSDRCLOG-ZDATE = SY-DATUM.
      WA_AGSDRCLOG-ZTIME = VDRC_TIME.
      APPEND WA_AGSDRCLOG TO IT_AGSDRCLOG.
      CLEAR WA_DATA.
    ENDLOOP.
  ENDIF.

  IF IT_AGSDRCLOG[] IS NOT INITIAL.
    INSERT ZTLOG_AGS FROM TABLE IT_AGSDRCLOG ACCEPTING DUPLICATE KEYS.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.
    ELSE.
      MESSAGE 'Failed to insert AGS Log' TYPE 'S'.
    ENDIF.
  ENDIF.

ENDFORM.                    "F_INSERTAGSDRC


*&---------------------------------------------------------------------*
*&      Form  F_UPDATEAGSDRC
*&---------------------------------------------------------------------*
*       Update DRC/Log status of AGS data
*       ADDED BY GANI ON 19.08.2019
*----------------------------------------------------------------------*
*      -->P_STATUS   text
*      -->R_ZDATA    text
*----------------------------------------------------------------------*
FORM F_UPDATEAGSDRC USING P_STATUS TYPE C
                       R_ZDATA LIKE R_ZDATA.

  UPDATE ZTLOG_AGS
  SET    ZSTAT = P_STATUS
  WHERE  ZDATA IN R_ZDATA
     AND ZTIME = VDRC_TIME        "-- ADDED FOR AGS BY FATHIR ON 22.10.2019 - Add TIME condition for updating AGS DRC Log
     AND ZDATE = SY-DATUM         "-- ADDED FOR AGS BY FATHIR ON 22.10.2019 - Add DATE condition for updating AGS DRC Log
     AND ZSTAT = 'INPROGRESS'.

  IF P_STATUS EQ 'FAILED'.
    MESSAGE 'Please check your AGS log.' TYPE 'S'.
  ELSEIF P_STATUS EQ 'COMPLETE' OR P_STATUS EQ 'COMPLETEDRC'.
    MESSAGE 'AGS logging complete.' TYPE 'S'.
  ENDIF.

ENDFORM.                    "F_UPDATEAGSDRC