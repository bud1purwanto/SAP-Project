*&---------------------------------------------------------------------*
*&  Include           ZINCL_ERP_SQL
*&---------------------------------------------------------------------*

DATA: VARDATE TYPE SY-DATUM,
      VARTIME(8) TYPE C,
      VARDATETIME(20) TYPE C,
      VARSTATUS(1) TYPE C,
      VARMSG(500) TYPE C,
      VARPROGRAM(50) TYPE C VALUE SY-REPID,
      VARID(500) TYPE C,
      VARTOTALREC(10) TYPE C,
      VARLIST TYPE MSXXLIST OCCURS 0 WITH HEADER LINE,
      VARTERMINAL(50) TYPE C,
      VARTEMP TYPE STRING.
DATA : LEX_ROOT TYPE REF TO CX_ROOT.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SERVER.
  IF SY-HOST = 'TRIASWIN2008' OR SY-HOST = 'SAPTRPKR' OR SY-HOST = 'SAPTRPWARU'.
  ELSE.
    STOP.
  ENDIF.


ENDFORM.                    "CHECK_SERVER

DEFINE INSERT_LOG_SQL.
  "&1 Internal Table Name
  "&2 Field Internal Table
  "&3 Hard Tcode

  CLEAR : VARDATE,VARTIME,VARDATETIME,VARSTATUS,VARMSG.
  VARDATE = SY-DATUM.
*  VARDATETIME = VARDATE.
  WRITE SY-UZEIT TO VARTIME.
  CONCATENATE  VARDATE VARTIME INTO VARDATETIME SEPARATED BY SPACE.
*  CONCATENATE  VARDATE INTO VARDATETIME SEPARATED BY SPACE.
*  IF VARID IS INITIAL.
*    CONCATENATE SY-DATUM SY-UZEIT SY-TCODE INTO VARID.
*  ENDIF.

  CALL FUNCTION 'GUI_GET_DESKTOP_INFO'
  EXPORTING
    TYPE = '1'
  CHANGING
    RETURN = VARTERMINAL.

  IF VARTERMINAL IS INITIAL.
    VARTERMINAL = 'BACKGROUND JOB'.
  ENDIF.

  CONCATENATE SY-DATUM SY-UZEIT SY-TCODE &3 VARTERMINAL INTO VARMSG SEPARATED BY '|'.
  CLEAR VARTEMP.
  LOOP AT &1.
    IF &1-&2 NE VARTEMP.
      CONCATENATE VARMSG &1-&2 INTO VARMSG SEPARATED BY '|'.
      VARTEMP = &1-&2.
    ENDIF.
  ENDLOOP.

  VARID = VARMSG.
  DESCRIBE TABLE &1 LINES VARTOTALREC.
  CONDENSE VARTOTALREC.
  VARSTATUS = ''. VARMSG = VARID.
  PERFORM CONNECT_SQL.
  PERFORM INSERT_LOG USING VARSTATUS VARMSG.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  INSERT_LOG_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VARSTATUS    text
*      -->VARMSG       text
*----------------------------------------------------------------------*
FORM INSERT_LOG USING VARSTATUS VARMSG.
  TRY.
      EXEC SQL.
        INSERT INTO RPT.LOG_REPORT
        ( Program, Tanggal, Waktu, Status, Message, Total_Record )
        VALUES( :VARPROGRAM, :VARDATE, :VARTIME, :VARSTATUS, :VARMSG, :VARTOTALREC )
      ENDEXEC.
      EXEC SQL.
        COMMIT WORK
      ENDEXEC.
    CATCH CX_ROOT INTO LEX_ROOT.
      MESSAGE LEX_ROOT TYPE 'S'.
  ENDTRY.
ENDFORM.                    "INSERT_LOG_SQL

*&---------------------------------------------------------------------*
*&      Form  CONNECT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONNECT_SQL.
  EXEC SQL.
    CONNECT TO 'ERP' AS 'DBTRIAL'
  ENDEXEC.

  EXEC SQL.
    SET CONNECTION 'DBTRIAL'
  ENDEXEC.
ENDFORM.                    "CONNECT_SQL

*&---------------------------------------------------------------------*
*&      Form  UPDATE_LOG_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VARSTATUS    text
*      -->VARMSG       text
*      -->VARID        text
*----------------------------------------------------------------------*
FORM UPDATE_LOG_SQL.
  CLEAR VARTIME.
  WRITE SY-UZEIT TO VARTIME.
  TRY.
      EXEC SQL.
        UPDATE RPT.LOG_REPORT
          SET Status = :VARSTATUS, Tanggal = :VARDATE
          WHERE Status = '' AND Message = :VARID ;
      ENDEXEC.
      EXEC SQL.
        COMMIT WORK
      ENDEXEC.
    CATCH CX_ROOT INTO LEX_ROOT.
      MESSAGE LEX_ROOT TYPE 'S'.
*      PERFORM INSERT_ERRORLOG USING VARID LEX_ROOT.
  ENDTRY.
ENDFORM.                    "UPDATE_LOG_SQL

DEFINE CONVERT_DATE.
  "&1 : Internal Table
  "&2 : Field Name

  &1-&2 = '19000101'.
  MODIFY &1 TRANSPORTING &2 WHERE &2 = 00000000.
END-OF-DEFINITION.


*&---------------------------------------------------------------------*
*&      Form  INSERT_ERRORLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_ERRORLOG USING VARID LEX_ROOT.

  EXEC SQL.
    INSERT INTO RPT.LOG_ERROR
    ( Message, Error_Log )
    VALUES( :VARID, :LEX_ROOT )
  ENDEXEC.
  EXEC SQL.
    COMMIT WORK
  ENDEXEC.
ENDFORM.                    "INSERT_ERRORLOG