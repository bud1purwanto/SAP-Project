*&---------------------------------------------------------------------*
*& Report  ZTPPR_LOG_ERROR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZTPPR_LOG_ERROR.
INCLUDE ZINCL_ERP_SQL.

TABLES: ZERROR_LOG.

DATA : IT_DATA TYPE ZERROR_LOG OCCURS 0 WITH HEADER LINE.

DATA: FNAME TYPE STRING.

SELECT-OPTIONS: S_AUFNR FOR ZERROR_LOG-AUFNR OBLIGATORY.
*      S_DATE FOR ZERROR_LOG-CPUDT," DEFAULT SY-DATUM,
*      S_TIME FOR ZERROR_LOG-CPUTM." DEFAULT SY-UZEIT.

START-OF-SELECTION.
  PERFORM CHECK_SERVER.
  PERFORM GETDATA.
  INSERT_LOG_SQL IT_DATA AUFNR 'ZTPP_LOG'.

  IF IT_DATA[] IS INITIAL.
    VARSTATUS = '0'. VARMSG = ''.
    PERFORM UPDATE_LOG_SQL.
  ELSE.
    PERFORM INSERT_SQL.
    PERFORM UPDATE_LOG_SQL.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  GETDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GETDATA.
  REFRESH IT_DATA.
  SELECT * FROM ZERROR_LOG INTO TABLE IT_DATA.
*    WHERE ZERROR_LOG~AUFNR IN S_AUFNR.
*    ZERROR_LOG~CPUDT IN S_DATE AND
*    ZERROR_LOG~CPUTM IN S_TIME.

  IT_DATA-BUDAT = '19000101'.
  MODIFY IT_DATA TRANSPORTING BUDAT WHERE BUDAT = 00000000.
  IT_DATA-BLDAT = '19000101'.
  MODIFY IT_DATA TRANSPORTING BLDAT WHERE BLDAT = 00000000.
  IT_DATA-CPUDT = '19000101'.
  MODIFY IT_DATA TRANSPORTING CPUDT WHERE CPUDT = 00000000.
  IT_DATA-TGL = '19000101'.
  MODIFY IT_DATA TRANSPORTING TGL WHERE TGL = 00000000.
ENDFORM.                    "GETDATA


*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_SQL.

  LOOP AT IT_DATA.
    EXEC SQL.
      INSERT INTO TMP.RPT_ZPP_RE_LOG
      ([Order],
        Material,
        MovementType,
        MatRawRecycle,
        PostingDate,
        DocumentDate,
        Enteredon,
        Enteredat,
        UserName,
        Plant,
        StorLocation,
        Quantity,
        BaseUnit,
        Recipient,
        CodeLine,
        FilmType,
        TglKupas,
        MaterialDoc,
        MatDocYear,
        LastUpdated)
      VALUES
      (:IT_DATA-AUFNR,
        :IT_DATA-MATNR,
        :IT_DATA-BWART,
        :IT_DATA-MATRR,
        :IT_DATA-BUDAT,
        :IT_DATA-BLDAT,
        :IT_DATA-CPUDT,
        :IT_DATA-CPUTM,
        :IT_DATA-USNAM,
        :IT_DATA-WERKS,
        :IT_DATA-LGORT,
        :IT_DATA-MENGE,
        :IT_DATA-MEINS,
        :IT_DATA-WEMPF,
        :IT_DATA-LINE,
        :IT_DATA-FILM,
        :IT_DATA-TGL,
        :IT_DATA-MATDOC,
        :IT_DATA-MATYEAR,
        :VARDATETIME)
    ENDEXEC.
  ENDLOOP.

  IF SY-SUBRC = 0.
    EXEC SQL.
      COMMIT WORK
    ENDEXEC.
    VARSTATUS = '1'. VARMSG = ''.
  ELSE.
    VARSTATUS = '0'. VARMSG = ''.
  ENDIF.

ENDFORM.                    "INSERT_SQL