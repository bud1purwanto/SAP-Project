*&---------------------------------------------------------------------*
*& Report  ZPPR_NEW_LIST_JR
*&---------------------------------------------------------------------*
* Description      : Report New Listing Jumbo Roll
*
* Application Area - PP
* ABAPer           - Jeffri Pranata
* Date             - 23 Oktober, 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | 23.10.12 | Jeffri      |            | Program created          *
*----------------------------------------------------------------------*

REPORT  ZTPPR_NEW_LIST_JR.
INCLUDE ZINCL_ERP_SQL.
*INCLUDE ZABAPALV.
*INCLUDE ZPPR_NEW_LIST_JR_TOP.
*INCLUDE ZSAMBA_TEXT.

DATA: VDATE(10) TYPE C,
      VTIME(8) TYPE C,
      VDATETIME(20) TYPE C,
      VSTATUS(1) TYPE C,
      VMSG(500) TYPE C,
      VPROGRAM(50) TYPE C VALUE SY-REPID,
      VID(50) TYPE C,
      VTOTALREC(10) TYPE C,
      LV TYPE I.

TABLES : MCHB,MARA,MCH1.

DATA : BEGIN OF IT_JR OCCURS 0,
        LWEDT LIKE MCH1-LWEDT,
        MATNR LIKE MCHB-MATNR,
        WERKS LIKE MCHB-WERKS,
        CHARG LIKE MCHB-CHARG,
        ZNOROL LIKE API_VALI-ATWRT,
        ZPRDLN LIKE API_VALI-ATWRT,
        LGORT LIKE MCHB-LGORT,
        UMUR TYPE P,
        ZTYPE LIKE API_VALI-ATWRT,
        ZTHICK LIKE API_VALI-ATWRT,
        ZWIDTH LIKE API_VALI-ATWRT,
        ZLENGTH LIKE API_VALI-ATWRT,
        ZGRADEJR LIKE API_VALI-ATWRT,
        ZCONVROL LIKE API_VALI-ATWRT,
        ZZCONVROL TYPE P DECIMALS 3,
        ZINSD LIKE API_VALI-ATWRT,
        ZOTSD LIKE API_VALI-ATWRT,
        ZPRUFLOS LIKE QALS-PRUEFLOS,
        HOLD TYPE C LENGTH 4,
        KETWIN TYPE C LENGTH 40,
        LABINF TYPE C LENGTH 50,
        CLABS LIKE MCHB-CLABS,
        CUMLM LIKE MCHB-CUMLM,
        CINSM LIKE MCHB-CINSM,
        CEINM LIKE MCHB-CEINM,
        CSPEM LIKE MCHB-CSPEM,
        CRETM LIKE MCHB-CRETM,
        VCODE LIKE QAVE-VCODE,
        CLENGTH TYPE P DECIMALS 0,
        CPUTM LIKE MKPF-CPUTM,
        "-Add By Krisna, New Characteristic Batch JR for SUBCOUNT
        ZPOCUSTOMER(30),
        ZCUSTOMER(30),
        ZNOLOTSUBCONT(30),
        ZNOLOTSUBCONT2(30),
        ZNOLOTSUBCONT3(30),
        ZSKU(30),
        "-End Add By Krisna, New Characteristic Batch JR for SUBCOUNT
       END OF IT_JR.

DATA : ZVAL LIKE STANDARD TABLE OF API_VALI WITH HEADER LINE,
       ZMSEG LIKE STANDARD TABLE OF MSEG WITH HEADER LINE.

DATA : DTMLO1 TYPE TIMESTAMP,
       DTMLO2 TYPE TIMESTAMP,
       PTMLO1 TYPE P,
       PTMLO2 TYPE P,
       VSEC TYPE P,
       DUZEIT LIKE SY-UZEIT,
       DDATE LIKE SY-DATLO,
       DTZONE LIKE TTZDATA-TZONE,
       DSEQ TYPE I,
       CTEXT TYPE C,
       LV_NAME1 TYPE KNA1-NAME1.

SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_MATNR FOR MCHB-MATNR NO-DISPLAY.
SELECT-OPTIONS: S_WERKS FOR MCHB-WERKS NO-DISPLAY.
SELECT-OPTIONS: S_LGORT FOR MCHB-LGORT NO-DISPLAY.
SELECT-OPTIONS: S_BUDAT FOR MCH1-LWEDT NO-DISPLAY.
SELECT-OPTIONS: S_MATKL FOR MARA-MATKL DEFAULT '400001' TO '400099' NO-DISPLAY.
SELECT-OPTIONS: S_CHARG FOR MCHB-CHARG OBLIGATORY.
PARAMETERS : R_ZERO AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK SEL.



INITIALIZATION.
*  TXT1 = 'Material'.
*  TXT2 = 'Plant'.
*  TXT3 = 'Storage Location'.
*  TXT4 = 'Last Good Receipt Date'.
*  TXT5 = 'Material Group'.
*  TXT6 = 'Batch'.

START-OF-SELECTION.
  PERFORM CHECK_SERVER.
  PERFORM GT_DATA.
  INSERT_LOG_SQL IT_JR CHARG 'ZTPP009A'.
  IF IT_JR[] IS INITIAL.
    VSTATUS = '0'. VMSG = ''.
    PERFORM UPDATE_LOG_SQL.
  ELSE.
    PERFORM INSERT_SQL.
    PERFORM UPDATE_LOG_SQL.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&  Include           ZPPR_NEW_LIST_JR_F01
*&---------------------------------------------------------------------*
FORM GT_DATA.
  IF R_ZERO IS NOT INITIAL.
    SELECT MCHB~MATNR WERKS MCHB~CHARG LWEDT CLABS CUMLM CINSM CEINM CSPEM CRETM LGORT
      INTO CORRESPONDING FIELDS OF TABLE IT_JR
    FROM MCHB
      JOIN MCH1 ON MCH1~MATNR = MCHB~MATNR AND
                   MCH1~CHARG = MCHB~CHARG
      JOIN MARA ON MARA~MATNR = MCHB~MATNR
    WHERE MCHB~MATNR IN S_MATNR AND
          WERKS IN S_WERKS AND
          LGORT IN S_LGORT AND
          LWEDT IN S_BUDAT AND
          MATKL IN S_MATKL AND
          MCHB~CHARG IN S_CHARG AND
          ( CLABS GT 0 OR CUMLM GT 0 OR CINSM GT 0 OR CEINM GT 0 OR CSPEM GT 0 OR CRETM GT 0 ).
  ELSE.
    SELECT MCHB~MATNR WERKS MCHB~CHARG LWEDT CLABS CUMLM CINSM CEINM CSPEM CRETM LGORT
      INTO CORRESPONDING FIELDS OF TABLE IT_JR
    FROM MCHB
      JOIN MCH1 ON MCH1~MATNR = MCHB~MATNR AND
                   MCH1~CHARG = MCHB~CHARG
      JOIN MARA ON MARA~MATNR = MCHB~MATNR
    WHERE MCHB~MATNR IN S_MATNR AND
          WERKS IN S_WERKS AND
          LGORT IN S_LGORT AND
          LWEDT IN S_BUDAT AND
          MATKL IN S_MATKL AND
          MCHB~CHARG IN S_CHARG.
  ENDIF.

  LOOP AT IT_JR.
    REFRESH ZVAL.
    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
      EXPORTING
        I_VAL_MATNR    = IT_JR-MATNR
        I_VAL_WERKS    = IT_JR-WERKS
        I_VAL_CHARGE   = IT_JR-CHARG
      TABLES
        T_VAL_TAB      = ZVAL
      EXCEPTIONS
        NO_CLASS       = 1
        INTERNAL_ERROR = 2
        NO_VALUES      = 3
        NO_CHARS       = 4
        OTHERS         = 5.
    IF SY-SUBRC = 0.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC = 0.
        IT_JR-ZTYPE = ZVAL-ATWRT.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZTHICKNESS'.
      IF SY-SUBRC = 0.
        IT_JR-ZTHICK = ZVAL-ATWRT.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZWIDTH'.
      IF SY-SUBRC = 0.
        IT_JR-ZWIDTH = ZVAL-ATWRT.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZLENGTH'.
      IF SY-SUBRC = 0.
        IT_JR-ZLENGTH = ZVAL-ATWRT.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZGRADEJR'.
      IF SY-SUBRC = 0.
        IT_JR-ZGRADEJR = ZVAL-ATWRT.
        PERFORM GT_CHR_VAL USING 'ZZGRADEJR' IT_JR-ZGRADEJR CHANGING IT_JR-ZGRADEJR.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      IF SY-SUBRC = 0.
        IT_JR-ZCONVROL = ZVAL-ATWRT.
        REPLACE ALL OCCURRENCES OF 'Kg/Rol' IN IT_JR-ZCONVROL WITH ''.
        REPLACE ALL OCCURRENCES OF ',' IN IT_JR-ZCONVROL WITH ''.
        MOVE IT_JR-ZCONVROL TO IT_JR-ZZCONVROL.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZNOMORROLL'.
      IF SY-SUBRC = 0.
        IT_JR-ZNOROL = ZVAL-ATWRT.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZPRODLINE'.
      IF SY-SUBRC = 0.
        IT_JR-ZPRDLN = ZVAL-ATWRT.
        PERFORM GT_CHR_VAL USING 'ZZPRODLINE' IT_JR-ZPRDLN CHANGING IT_JR-ZPRDLN.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZINSIDE'.
      IF SY-SUBRC = 0.
        IT_JR-ZINSD = ZVAL-ATWRT.
        PERFORM GT_CHR_VAL USING 'ZZINSIDE' IT_JR-ZINSD CHANGING IT_JR-ZINSD.
      ENDIF.
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZOUTSIDE'.
      IF SY-SUBRC = 0.
        IT_JR-ZOTSD = ZVAL-ATWRT.
        PERFORM GT_CHR_VAL USING 'ZZOUTSIDE' IT_JR-ZOTSD CHANGING IT_JR-ZOTSD.
      ENDIF.

      "Add by Krisna new Characteristic Batch for SUBCOUNT 3/4/2025
      "- No. PO Subcount
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZPOCUSTOMER'.
      IF SY-SUBRC = 0.
        IT_JR-ZPOCUSTOMER = ZVAL-ATWRT.
      ENDIF.

      "- No. Customer
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZCUSTOMER'.
      IF SY-SUBRC = 0.
        SELECT SINGLE NAME1 INTO LV_NAME1
          FROM KNA1
          WHERE KUNNR = ZVAL-ATWRT.

        IT_JR-ZCUSTOMER = LV_NAME1.
      ENDIF.

      "- No. Lot Subcount 1
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZNOLOTSUBCONT'.
      IF SY-SUBRC = 0.
        IT_JR-ZNOLOTSUBCONT = ZVAL-ATWRT.
      ENDIF.

      "- No. Lot Subcount 2
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZNOLOTSUBCONT2'.
      IF SY-SUBRC = 0.
        IT_JR-ZNOLOTSUBCONT2 = ZVAL-ATWRT.
      ENDIF.

      "- No. Lot Subcount 3
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZNOLOTSUBCONT3'.
      IF SY-SUBRC = 0.
        IT_JR-ZNOLOTSUBCONT3 = ZVAL-ATWRT.
      ENDIF.

      "- SKU
      READ TABLE ZVAL WITH KEY ATNAM = 'ZZSKU'.
      IF SY-SUBRC = 0.
        IT_JR-ZSKU = ZVAL-ATWRT.
      ENDIF.
      "End Add by Krisna new Characteristic Batch for SUBCOUNT 3/4/2025
    ENDIF.

    SELECT SINGLE QALS~PRUEFLOS VCODE
      INTO (IT_JR-ZPRUFLOS, IT_JR-VCODE)
    FROM QAVE
      JOIN QALS ON QALS~PRUEFLOS = QAVE~PRUEFLOS AND
                   QALS~WERK = QAVE~VWERKS
    WHERE CHARG = IT_JR-CHARG AND
          WERK = IT_JR-WERKS AND
          HERKUNFT = '04'.

    IF IT_JR-VCODE IS NOT INITIAL.
      CASE IT_JR-VCODE(1).
        WHEN 'H'.
          IT_JR-HOLD = 'Hold'.
        WHEN 'P'.
          IT_JR-HOLD = 'Pass'.
        WHEN OTHERS.
          IT_JR-HOLD = ''.
      ENDCASE.
    ENDIF.

    PERFORM GT_WINDER USING 'VERM' 'CHARGE' IT_JR-CHARG IT_JR-MATNR CHANGING IT_JR-KETWIN.
    PERFORM GT_LAB_INF USING 'QAVE' 'QPRUEFLOS' IT_JR-ZPRUFLOS CHANGING IT_JR-LABINF.

    CLEAR : DDATE, DTMLO1, DTMLO2, PTMLO1, PTMLO2, DUZEIT, VSEC, ZMSEG. REFRESH : ZMSEG.

    SELECT MBLNR SMBLN CPUTM_MKPF SGTXT
      INTO CORRESPONDING FIELDS OF TABLE ZMSEG
    FROM MSEG
      WHERE MATNR = IT_JR-MATNR AND
            CHARG = IT_JR-CHARG AND
            BUDAT_MKPF = IT_JR-LWEDT AND
            BWART IN ('101','102').

    LOOP AT ZMSEG WHERE SMBLN IS NOT INITIAL.
      DELETE ZMSEG WHERE MBLNR = ZMSEG-SMBLN.
    ENDLOOP.
    DELETE ZMSEG WHERE BWART = '102'.

    READ TABLE ZMSEG INDEX 1.
    IF SY-SUBRC = 0.
      MOVE ZMSEG-CPUTM_MKPF TO DUZEIT.
      MOVE IT_JR-LWEDT TO DDATE.
      MOVE SY-TZONE TO DTZONE.
      IT_JR-CPUTM = DUZEIT.

*      JEFF 03-01-2013
      IF ZMSEG-SGTXT IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ',' IN ZMSEG-SGTXT WITH ''.
        CLEAR : DSEQ, CTEXT.
        WHILE CTEXT NE '-'.
          CLEAR CTEXT.
          DSEQ = DSEQ + 1.
          CTEXT = ZMSEG-SGTXT+DSEQ.
        ENDWHILE.

        IF DSEQ NE 0.
          MOVE ZMSEG-SGTXT(DSEQ) TO IT_JR-CLENGTH.
        ENDIF.
      ENDIF.
*      END JEFF 03-01-2013

      CONVERT DATE DDATE TIME DUZEIT INTO TIME STAMP DTMLO1 TIME ZONE 'UTC   '.
      CONVERT DATE SY-DATUM TIME SY-UZEIT INTO TIME STAMP DTMLO2 TIME ZONE 'UTC   '.

      MOVE DTMLO1 TO PTMLO1.
      MOVE DTMLO2 TO PTMLO2.
      VSEC = CL_ABAP_TSTMP=>SUBTRACT( TSTMP2 = PTMLO2 TSTMP1 = PTMLO1 ).
      IT_JR-UMUR = ABS( VSEC DIV 3600 ).
    ENDIF.
    MODIFY IT_JR.
  ENDLOOP.

  IT_JR-LWEDT = '19000101'.
  MODIFY IT_JR TRANSPORTING LWEDT WHERE LWEDT = 00000000.
ENDFORM.                    "GT_DATA

*&---------------------------------------------------------------------*
*&      Form  GT_WINDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZID        text
*      -->ZOBJ       text
*      -->ZCHARG     text
*      -->ZPLNBEZ    text
*      -->ZDESC      text
*----------------------------------------------------------------------*
FORM GT_WINDER USING ZID ZOBJ ZCHARG ZPLNBEZ CHANGING ZDESC.
  DATA :ZZCHARG TYPE STRING,
        DNAME TYPE THEAD-TDNAME,
        DLENG TYPE I.
  DATA : ZLINE LIKE STANDARD TABLE OF TLINE WITH HEADER LINE.

  MOVE ZCHARG TO ZZCHARG.
  CONDENSE ZZCHARG.
  DLENG = 22 - STRLEN( ZPLNBEZ ).
  SHIFT ZZCHARG BY DLENG PLACES RIGHT.
  CONCATENATE ZPLNBEZ ZZCHARG INTO DNAME.

  IF DNAME IS NOT INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        ID              = ZID
        LANGUAGE        = 'E'
*       INLINE_COUNT    = 1
        NAME            = DNAME
        OBJECT          = ZOBJ
      TABLES
        LINES           = ZLINE
      EXCEPTIONS
        ID              = 1
        LANGUAGE        = 2
        NAME            = 3
        NOT_FOUND       = 4
        OBJECT          = 5
        REFERENCE_CHECK = 6
        OTHERS          = 99.

    READ TABLE ZLINE INDEX 1.
    IF SY-SUBRC = 0.
      ZDESC = ZLINE-TDLINE.
    ELSE.
      ZDESC = ''.
    ENDIF.
  ELSE.
    ZDESC = ''.
  ENDIF.
ENDFORM.                    "GT_WINDER

*&---------------------------------------------------------------------*
*&      Form  GT_LAB_INF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZID        text
*      -->ZOBJ       text
*      -->ZPRUFLOS   text
*      -->ZDESC      text
*----------------------------------------------------------------------*
FORM GT_LAB_INF USING ZID ZOBJ ZPRUFLOS CHANGING ZDESC.
  DATA :DNAME TYPE THEAD-TDNAME.
  DATA : ZLINE LIKE STANDARD TABLE OF TLINE WITH HEADER LINE.

  CONCATENATE SY-MANDT ZPRUFLOS 'L' INTO DNAME.

  IF DNAME IS NOT INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        ID              = ZID
        LANGUAGE        = 'E'
*       INLINE_COUNT    = 1
        NAME            = DNAME
        OBJECT          = ZOBJ
      TABLES
        LINES           = ZLINE
      EXCEPTIONS
        ID              = 1
        LANGUAGE        = 2
        NAME            = 3
        NOT_FOUND       = 4
        OBJECT          = 5
        REFERENCE_CHECK = 6
        OTHERS          = 99.

    READ TABLE ZLINE INDEX 1.
    IF SY-SUBRC = 0.
      ZDESC = ZLINE-TDLINE.
    ELSE.
      ZDESC = ''.
    ENDIF.
  ELSE.
    ZDESC = ''.
  ENDIF.
ENDFORM.                    "GT_LAB_INF

*&---------------------------------------------------------------------*
*&      Form  GT_CHR_VAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZCHAR      text
*      -->ZATWTB     text
*      -->ZATWRT     text
*----------------------------------------------------------------------*
FORM GT_CHR_VAL USING ZCHAR ZATWTB CHANGING ZATWRT.
  DATA : VATINN LIKE CAWN-ATINN.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = ZCHAR
    IMPORTING
      OUTPUT = VATINN.

  SELECT SINGLE ATWTB INTO ZATWRT
    FROM CAWN
  JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND
                 CAWN~ATZHL = CAWNT~ATZHL
   WHERE ATWRT = ZATWTB AND
         CAWNT~SPRAS = 'E' AND
         CAWNT~ATINN = ZCHAR.
ENDFORM.                    "GT_CHR_VAL

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_SQL.

  LOOP AT IT_JR.
    EXEC SQL.
      INSERT INTO TMP.RPT_ZPP009A
      (LastGR,
       Material,
       Plant,
       Batch,
       NoRoll,
       Line,
       StorLoc,
       Umur,
       FilmType,
       Thickness,
       Width,
       Length1,
       Grade,
       Weight,
       TreatmentInside,
       TreatmentOutside,
       InspLot,
       Hold,
       KeteranganWinder,
       LabInfo,
       Unrestr,
       StockInTfr,
       QualInsp,
       Restricted,
       Blocked,
       [Returns],
       UDcode,
       Length2,
       LastGRTime,
       [PO Subcount],
       [Customer],
       [NoLotSubcont1],
       [NoLotSubcont2],
       [NoLotSubcont3],
       [SKU],
       LastUpdated
       )
     VALUES
     (:IT_JR-LWEDT,
      :IT_JR-MATNR,
      :IT_JR-WERKS,
      :IT_JR-CHARG,
      :IT_JR-ZNOROL,
      :IT_JR-ZPRDLN,
      :IT_JR-LGORT,
      :IT_JR-UMUR,
      :IT_JR-ZTYPE,
      :IT_JR-ZTHICK,
      :IT_JR-ZWIDTH,
      :IT_JR-ZLENGTH,
      :IT_JR-ZGRADEJR,
      :IT_JR-ZCONVROL,
      :IT_JR-ZINSD,
      :IT_JR-ZOTSD,
      :IT_JR-ZPRUFLOS,
      :IT_JR-HOLD,
      :IT_JR-KETWIN,
      :IT_JR-LABINF,
      :IT_JR-CLABS,
      :IT_JR-CUMLM,
      :IT_JR-CINSM ,
      :IT_JR-CEINM,
      :IT_JR-CSPEM,
      :IT_JR-CRETM,
      :IT_JR-VCODE,
      :IT_JR-CLENGTH,
      :IT_JR-CPUTM,
      :IT_JR-ZPOCUSTOMER,
      :IT_JR-ZCUSTOMER,
      :IT_JR-ZNOLOTSUBCONT,
      :IT_JR-ZNOLOTSUBCONT2,
      :IT_JR-ZNOLOTSUBCONT3,
      :IT_JR-ZSKU,
      :VARDATETIME
      )
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