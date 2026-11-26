
*&---------------------------------------------------------------------*
*&  Include           ZQMC_UPLOAD_MIC_F01
*&---------------------------------------------------------------------*

INCLUDE Z_PROG_INFO.

START-OF-SELECTION.
AT SELECTION-SCREEN.
    CASE SY-UCOMM.
      WHEN 'INFO'.
        PERFORM F_PROG_INFO USING V_PROG.
      WHEN OTHERS.
        PERFORM GET_DATA.
          IF RB1 = 'X'.
             PERFORM UPLOADDATACREATE.
          ELSEIF RB2 = 'X'.
             PERFORM UPLOADDATAVERSION.
          ELSEIF RB3 = 'X'.
             PERFORM UPLOADDATACHANGE.
          ENDIF.
        PERFORM DISPLAYREPORT.
    ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  DATA: FILENAME1 TYPE STRING.

  MOVE FILENAME TO FILENAME1.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FILENAME1
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = IT_MIC
    EXCEPTIONS
      CONVERSION_ERROR    = 1
      INVALID_TABLE_WIDTH = 2
      INVALID_TYPE        = 3
      NO_BATCH            = 4
      UNKNOWN_ERROR       = 5
      FILE_OPEN_ERROR     = 6
      FILE_READ_ERROR     = 7
      OTHERS              = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'File cannot be opened'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " GET_DATA

FORM UPLOADDATACREATE.
DATA : "MSGS  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       LINE TYPE I,
       NOERR TYPE I,
       MESSAGE LIKE BAPIRET2-MESSAGE,
       MESSAGE_V1 LIKE  BAPIRET2-MESSAGE_V1,
       MESSAGE_V2 LIKE  BAPIRET2-MESSAGE_V2,
       MESSAGE_V3 LIKE  BAPIRET2-MESSAGE_V3,
       MESSAGE_V4 LIKE  BAPIRET2-MESSAGE_V4,
       ID LIKE  BAPIRET2-ID,
       NUMBER LIKE  BAPIRET2-NUMBER,
       WA_MSGS LIKE LINE OF MSGS,
       CTR TYPE I,
       SATNR LIKE MARA-SATNR,
       STDPD LIKE MARC-STDPD.

  CLEAR IT_REPORT. REFRESH IT_REPORT.
  CLEAR LINE.
  LOOP AT IT_MIC.
    CLEAR: BDCDATA, MESSTAB, MSGS, SATNR.
    REFRESH: BDCDATA, MESSTAB, MSGS.
    LINE =  LINE + 1.

    IF IT_MIC-QUANTITAET EQ 'X'.
      PERFORM BDC_ZQM_QS21_QT.
    ELSEIF IT_MIC-QUALITAET EQ 'X'.
      PERFORM BDC_ZQM_QS21_QL.
    ENDIF.

    CLEAR CTR.
    LOOP AT MSGS WHERE MSGTYP EQ 'E'.
      CTR = CTR + 1.
      EXIT.
    ENDLOOP.

    MOVE-CORRESPONDING IT_MIC TO IT_REPORT.
    CLEAR : WA_MSGS, CTR.
    CTR = LINES( MSGS ).
    READ TABLE MSGS INDEX CTR.
    WA_MSGS = MSGS.

    IT_REPORT-LINE = LINE.
    IF WA_MSGS-MSGTYP NE ''.
      CLEAR MESSAGE.
      CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3,
             MESSAGE_V4, ID, NUMBER.
      ID = WA_MSGS-MSGID.
      NUMBER =  WA_MSGS-MSGNR.
      MESSAGE_V1 = WA_MSGS-MSGV1.
      MESSAGE_V2 = WA_MSGS-MSGV2.
      MESSAGE_V3 = WA_MSGS-MSGV3.
      MESSAGE_V4 = WA_MSGS-MSGV4.

      CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
        EXPORTING
          ID         = ID
          NUMBER     = NUMBER
          LANGUAGE   = SY-LANGU
          TEXTFORMAT = 'HTM'
          MESSAGE_V1 = MESSAGE_V1
          MESSAGE_V2 = MESSAGE_V2
          MESSAGE_V3 = MESSAGE_V3
          MESSAGE_V4 = MESSAGE_V4
        IMPORTING
          MESSAGE    = MESSAGE.


          IF WA_MSGS-MSGTYP EQ 'S'.
            IT_REPORT-STAT = GCF_S1.
          ELSE.
            IT_REPORT-STAT = GCF_E1.
          ENDIF.
          IT_REPORT-MESSAGE = MESSAGE.
    ENDIF.
    APPEND IT_REPORT.
  ENDLOOP.
ENDFORM.

FORM UPLOADDATAVERSION.
DATA : "MSGS  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       LINE TYPE I,
       NOERR TYPE I,
       MESSAGE LIKE BAPIRET2-MESSAGE,
       MESSAGE_V1 LIKE  BAPIRET2-MESSAGE_V1,
       MESSAGE_V2 LIKE  BAPIRET2-MESSAGE_V2,
       MESSAGE_V3 LIKE  BAPIRET2-MESSAGE_V3,
       MESSAGE_V4 LIKE  BAPIRET2-MESSAGE_V4,
       ID LIKE  BAPIRET2-ID,
       NUMBER LIKE  BAPIRET2-NUMBER,
       WA_MSGS LIKE LINE OF MSGS,
       CTR TYPE I,
       SATNR LIKE MARA-SATNR,
       STDPD LIKE MARC-STDPD.

  CLEAR IT_REPORT. REFRESH IT_REPORT.
  CLEAR LINE.
  LOOP AT IT_MIC.
    CLEAR: BDCDATA, MESSTAB, MSGS, SATNR.
    REFRESH: BDCDATA, MESSTAB, MSGS.

    IF IT_MIC-QUANTITAET EQ 'X'.
      PERFORM BDC_ZQM_QS22_QT.
    ELSEIF IT_MIC-QUALITAET EQ 'X'.
      PERFORM BDC_ZQM_QS22_QL.
    ENDIF.

    CLEAR CTR.
    LOOP AT MSGS WHERE MSGTYP EQ 'E'.
      CTR = CTR + 1.
      EXIT.
    ENDLOOP.

    LINE =  LINE + 1.
    MOVE-CORRESPONDING IT_MIC TO IT_REPORT.
    CLEAR : WA_MSGS, CTR.
    CTR = LINES( MSGS ).
    READ TABLE MSGS INDEX CTR.
    WA_MSGS = MSGS.

    IF WA_MSGS-MSGTYP NE ''.
      CLEAR MESSAGE.
      CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3,
             MESSAGE_V4, ID, NUMBER.
      ID = WA_MSGS-MSGID.
      NUMBER =  WA_MSGS-MSGNR.
      MESSAGE_V1 = WA_MSGS-MSGV1.
      MESSAGE_V2 = WA_MSGS-MSGV2.
      MESSAGE_V3 = WA_MSGS-MSGV3.
      MESSAGE_V4 = WA_MSGS-MSGV4.

      CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
        EXPORTING
          ID         = ID
          NUMBER     = NUMBER
          LANGUAGE   = SY-LANGU
          TEXTFORMAT = 'HTM'
          MESSAGE_V1 = MESSAGE_V1
          MESSAGE_V2 = MESSAGE_V2
          MESSAGE_V3 = MESSAGE_V3
          MESSAGE_V4 = MESSAGE_V4
        IMPORTING
          MESSAGE    = MESSAGE.
          IF MESSAGE EQ ''.
            MESSAGE = 'Quantitative Data incorrect'.
          ENDIF.

          IT_REPORT-LINE = LINE.
          IF WA_MSGS-MSGTYP NE 'S'.
            IT_REPORT-STAT = GCF_E1.
          ELSE.
            IT_REPORT-STAT = GCF_S1.
          ENDIF.
          IT_REPORT-MESSAGE = MESSAGE.
    ENDIF.
    APPEND IT_REPORT.
  ENDLOOP.
ENDFORM.                    " UPLOADDATA

FORM UPLOADDATACHANGE.
DATA : "MSGS  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       LINE TYPE I,
       NOERR TYPE I,
       MESSAGE LIKE BAPIRET2-MESSAGE,
       MESSAGE_V1 LIKE  BAPIRET2-MESSAGE_V1,
       MESSAGE_V2 LIKE  BAPIRET2-MESSAGE_V2,
       MESSAGE_V3 LIKE  BAPIRET2-MESSAGE_V3,
       MESSAGE_V4 LIKE  BAPIRET2-MESSAGE_V4,
       ID LIKE  BAPIRET2-ID,
       NUMBER LIKE  BAPIRET2-NUMBER,
       WA_MSGS LIKE LINE OF MSGS,
       CTR TYPE I,
       SATNR LIKE MARA-SATNR,
       STDPD LIKE MARC-STDPD.

  CLEAR IT_REPORT. REFRESH IT_REPORT.
  CLEAR LINE.
  LOOP AT IT_MIC.
    CLEAR: BDCDATA, MESSTAB, MSGS, SATNR.
    REFRESH: BDCDATA, MESSTAB, MSGS.

    IF IT_MIC-QUANTITAET EQ 'X'.
      PERFORM BDC_ZQM_QS23_QT.
    ELSEIF IT_MIC-QUALITAET EQ 'X'.
      PERFORM BDC_ZQM_QS23_QL.
    ENDIF.

    CLEAR CTR.
    LOOP AT MSGS WHERE MSGTYP EQ 'E'.
      CTR = CTR + 1.
      EXIT.
    ENDLOOP.

    LINE =  LINE + 1.
    MOVE-CORRESPONDING IT_MIC TO IT_REPORT.
    CLEAR : WA_MSGS, CTR.
    CTR = LINES( MSGS ).
    READ TABLE MSGS INDEX CTR.
    WA_MSGS = MSGS.

    IF WA_MSGS-MSGTYP NE ''.
      CLEAR MESSAGE.
      CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3,
             MESSAGE_V4, ID, NUMBER.
      ID = WA_MSGS-MSGID.
      NUMBER =  WA_MSGS-MSGNR.
      MESSAGE_V1 = WA_MSGS-MSGV1.
      MESSAGE_V2 = WA_MSGS-MSGV2.
      MESSAGE_V3 = WA_MSGS-MSGV3.
      MESSAGE_V4 = WA_MSGS-MSGV4.

      CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
        EXPORTING
          ID         = ID
          NUMBER     = NUMBER
          LANGUAGE   = SY-LANGU
          TEXTFORMAT = 'HTM'
          MESSAGE_V1 = MESSAGE_V1
          MESSAGE_V2 = MESSAGE_V2
          MESSAGE_V3 = MESSAGE_V3
          MESSAGE_V4 = MESSAGE_V4
        IMPORTING
          MESSAGE    = MESSAGE.

          IT_REPORT-LINE = LINE.
          IF WA_MSGS-MSGTYP EQ 'E'.
            IT_REPORT-STAT = GCF_E1.
          ELSE.
            IT_REPORT-STAT = GCF_S1.
          ENDIF.
          IT_REPORT-MESSAGE = MESSAGE.
    ENDIF.
    APPEND IT_REPORT.
  ENDLOOP.
ENDFORM.

FORM DISPLAYREPORT.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAYREPORT

FORM BDC_ZQM_QS21_QT.
perform bdc_dynpro      using 'SAPMQSDA' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-GUELTIGAB'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'QPMK-WERKS'
                                IT_MIC-WERKS. "'2000'.
  perform bdc_field       using 'QPMK-MKMNR'
                                IT_MIC-MKMNR. "'PCCAELMD'.
  perform bdc_field       using 'QPMK-GUELTIGAB'
                                IT_MIC-GUELTIGAM. "'09.11.2012'.

  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-SORTFELD'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=MART'.
  perform bdc_field       using 'RMQSD-QUANTITAET'
                                IT_MIC-QUANTITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Elongation MD'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'Elongation MD'.
*  perform bdc_field       using 'QPMK-MERKGEW'
*                                IT_MIC-MERKGEW. "'MN'.

  perform bdc_dynpro      using 'SAPLQSS0' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-ESTUKZ3'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-TOLERUNTEN'
                                IT_MIC-TOLERUNTEN. "'X'.
  perform bdc_field       using 'RQMST-TOLEROBEN'
                                IT_MIC-TOLEROBEN. "'X'.
  perform bdc_field       using 'RQMST-SOLLPRUEF'
                                IT_MIC-SOLLPRUEF. "'X'.
  perform bdc_field       using 'RQMST-STICHPR'
                                IT_MIC-STICHPR. "'X'.
  perform bdc_field       using 'RQMST-ADDPRO'
                                IT_MIC-ADDPRO. "'X'.
  perform bdc_field       using 'RQMST-QSPCMK'
                                IT_MIC-QSPCMK. "'X'.
  perform bdc_field       using 'RQMST-ZERSTPRF'
                                IT_MIC-ZERSTPRF. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ5'
                                IT_MIC-ESTUKZ5. "''.
  perform bdc_field       using 'RQMST-RZWANG4'
                                IT_MIC-RZWANG4. "'X'.
  perform bdc_field       using 'RQMST-RZWANG1'
                                IT_MIC-RZWANG1. "''.
  perform bdc_field       using 'RQMST-ESTUKZ3'
                                IT_MIC-ESTUKZ3. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ1'
                                IT_MIC-ESTUKZ1. "''.
  perform bdc_field       using 'RQMST-ESTUKZ2'
                                IT_MIC-ESTUKZ2. "''.
  perform bdc_field       using 'RQMST-FEHLREC'
                                IT_MIC-FEHLREC. "''.
  perform bdc_field       using 'RQMST-RZWANG2'
                                IT_MIC-RZWANG2. "''.
  perform bdc_field       using 'RQMST-RZWANG3'
                                IT_MIC-RZWANG3. "''.


  perform bdc_dynpro      using 'SAPLQSS0' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-LZEITKZ'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-PUMFKZ1'
                                IT_MIC-PUMFKZ1. "'X'.
  perform bdc_field       using 'RQMST-DOKUKZ1'
                                IT_MIC-DOKUKZ1. "'X'.
  perform bdc_field       using 'RQMST-PUMFKZ4'
                                IT_MIC-PUMFKZ4. "''.
  perform bdc_field       using 'RQMST-PUMFKZ2'
                                IT_MIC-PUMFKZ2. "''.
  perform bdc_field       using 'RQMST-PUMFKZ3'
                                IT_MIC-PUMFKZ3. "''.
  perform bdc_field       using 'RQMST-DOKUKZ2'
                                IT_MIC-DOKUKZ2. "''.
  perform bdc_field       using 'RQMST-DOKUKZ3'
                                IT_MIC-DOKUKZ3. "''.
  perform bdc_field       using 'RQMST-LZEITKZ'
                                IT_MIC-LZEITKZ. "'X'.
  perform bdc_field       using 'RQMST-AUSSLOS'
                                IT_MIC-AUSSLOS." 'X'.
  perform bdc_field       using 'RQMST-AENDBELEG'
                                IT_MIC-AENDBELEG. "'X'.
  perform bdc_field       using 'RQMST-PMMZWANG'
                                IT_MIC-PMMZWANG. "'X'.
  perform bdc_field       using 'RQMST-MESSWERTE'
                                IT_MIC-MESSWERTE. "'X'.
  perform bdc_field       using 'RQMST-FORMELMK'
                                IT_MIC-FORMELMK. "''.
  perform bdc_field       using 'RQMST-DRUCK1'
                                IT_MIC-DRUCK1. "''.
  perform bdc_field       using 'RQMST-KEINEFORMEL'
                                IT_MIC-NOFORMULA. "KEINEFORMEL. "'X'.
  perform bdc_field       using 'RQMST-DRUCK3'
                                IT_MIC-DRUCK3. "''.
  perform bdc_field       using 'RQMST-DRUCK2'
                                IT_MIC-DRUCK2. "'X'.

  IF IT_MIC-TOLERUNTEN EQ 'X' OR IT_MIC-TOLEROBEN EQ 'X'.
    perform bdc_dynpro      using 'SAPMQSDA' '0110'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'QPMK-TOLERANZSL'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=WEIT'.

    perform bdc_dynpro      using 'SAPMQSDA' '0108'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'QFLTP-TOLERANZOB'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=WEIT'.
    perform bdc_field       using 'QPMK-STELLEN'
                                  IT_MIC-Decimalplaces. "'STELLEN. "'2'.
    perform bdc_field       using 'RMQSD-MASSEINHSW'
                                  IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
    perform bdc_field       using 'QFLTP-SOLLWERT'
                                  IT_MIC-TargetValue. "SOLLWERT. "'120'.
    IF IT_MIC-TOLERUNTEN EQ 'X'.
      perform bdc_field       using 'QFLTP-TOLERANZUN'
                                    IT_MIC-LowerSpecLimit. "TOLERANZUN. "'100'.
    ENDIF.
    IF IT_MIC-TOLEROBEN EQ 'X'.
      perform bdc_field       using 'QFLTP-TOLERANZOB'
                                    IT_MIC-UpperSpecLimit. "TOLERANZOB. "'120'.
    ENDIF.
  ENDIF.

  IF IT_MIC-TOLERUNTEN EQ '' AND IT_MIC-TOLEROBEN EQ '' AND IT_MIC-SOLLPRUEF EQ 'X'.
    perform bdc_dynpro      using 'SAPMQSDA' '0108'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'QPMK-STELLEN'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=WEIT'.
    perform bdc_field       using 'QPMK-STELLEN'
                                  IT_MIC-Decimalplaces. "'STELLEN. "'2'.
    perform bdc_field       using 'RMQSD-MASSEINHSW'
                                  IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
    perform bdc_field       using 'QFLTP-SOLLWERT'
                                  IT_MIC-TargetValue. "SOLLWERT. "'120'.
  ELSEIF IT_MIC-TOLERUNTEN EQ '' AND IT_MIC-TOLEROBEN EQ '' AND IT_MIC-SOLLPRUEF EQ ''.
    perform bdc_dynpro      using 'SAPMQSDA' '0108'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'QPMK-STELLEN'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=WEIT'.
    perform bdc_field       using 'QPMK-STELLEN'
                                  IT_MIC-Decimalplaces. "'STELLEN. "'2'.
    perform bdc_field       using 'RMQSD-MASSEINHSW'
                                  IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
    perform bdc_field       using 'QFLTP-SOLLWERT'
                                  IT_MIC-TargetValue. "SOLLWERT. "'120'.
  ENDIF.


  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMQSD-VSTEUERKZ'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'RMQSD-QUANTITAET'
                                IT_MIC-QUANTITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Elongation MD'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'ELONGATION MD'.
*  perform bdc_transaction using 'QS21'.
  CALL TRANSACTION 'QS21' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
ENDFORM.

FORM BDC_ZQM_QS21_QL.

perform bdc_dynpro      using 'SAPMQSDA' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-MKMNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'QPMK-WERKS'
                                IT_MIC-WERKS. "'2000'.
  perform bdc_field       using 'QPMK-MKMNR'
                                IT_MIC-MKMNR. "'PEZABTAL'.
  perform bdc_field       using 'QPMK-GUELTIGAB'
                                IT_MIC-GUELTIGAM. "'09.11.2012'.


  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-SORTFELD'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=MART'.
  perform bdc_field       using 'RMQSD-QUALITAET'
                                IT_MIC-QUALITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Bonding strength with Scott Test'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'Bonding strength with Scott Test'.


  perform bdc_dynpro      using 'SAPLQSS0' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-RZWANG4'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-PRUEFKAT'
                                IT_MIC-PRUEFKAT. "'X'.
  perform bdc_field       using 'RQMST-STICHPR'
                                IT_MIC-STICHPR. "'X'.
  perform bdc_field       using 'RQMST-ADDPRO'
                                IT_MIC-ADDPRO. "'X'.
  perform bdc_field       using 'RQMST-QSPCMK'
                                IT_MIC-QSPCMK. "'X'.
  perform bdc_field       using 'RQMST-ZERSTPRF'
                                IT_MIC-ZERSTPRF. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ5'
                                IT_MIC-ESTUKZ5. "''.
  perform bdc_field       using 'RQMST-RZWANG4'
                                IT_MIC-RZWANG4. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ3'
                                IT_MIC-ESTUKZ3. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ1'
                                IT_MIC-ESTUKZ1. "''.
  perform bdc_field       using 'RQMST-ESTUKZ2'
                                IT_MIC-ESTUKZ2. "''.
  perform bdc_field       using 'RQMST-RZWANG3'
                                IT_MIC-RZWANG3. "''.
  perform bdc_field       using 'RQMST-RZWANG2'
                                IT_MIC-RZWANG2. "''.
  perform bdc_field       using 'RQMST-RZWANG1'
                                IT_MIC-RZWANG1. "''.


  perform bdc_dynpro      using 'SAPLQSS0' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-DRUCK2'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-DOKUKZ1'
                                IT_MIC-DOKUKZ1. "'X'.
  perform bdc_field       using 'RQMST-DOKUKZ2'
                                IT_MIC-DOKUKZ2. "''.
  perform bdc_field       using 'RQMST-DOKUKZ3'
                                IT_MIC-DOKUKZ3. "''.
  perform bdc_field       using 'RQMST-PUMFKZ1'
                                IT_MIC-PUMFKZ1. "''.
  perform bdc_field       using 'RQMST-PUMFKZ2'
                                IT_MIC-PUMFKZ2. "''.
  perform bdc_field       using 'RQMST-PUMFKZ3'
                                IT_MIC-PUMFKZ3. "''.
  perform bdc_field       using 'RQMST-PUMFKZ4'
                                IT_MIC-PUMFKZ4. "'X'.
  perform bdc_field       using 'RQMST-LZEITKZ'
                                IT_MIC-LZEITKZ."'X'.
  perform bdc_field       using 'RQMST-AUSSLOS'
                                IT_MIC-AUSSLOS. "'X'.
  perform bdc_field       using 'RQMST-AENDBELEG'
                                IT_MIC-AENDBELEG. "'X'.
  perform bdc_field       using 'RQMST-PMMZWANG'
                                IT_MIC-PMMZWANG. "'X'.
  perform bdc_field       using 'RQMST-DRUCK1'
                                IT_MIC-DRUCK1. "''.
  perform bdc_field       using 'RQMST-DRUCK2'
                                IT_MIC-DRUCK2. "'X'.
  perform bdc_field       using 'RQMST-DRUCK3'
                                IT_MIC-DRUCK3. "''.


*  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
*  perform bdc_field       using 'BDC_CURSOR'
*                                'QPMK-SORTFELD'.
*  perform bdc_field       using 'BDC_OKCODE'
*                                '=QD'.

  "QUANTITATIVE DATA EXIST OR NOT? "add by Irma on 21-11-2012
***  DATA  : DATE(8),
***          DATE1(8).
***  CLEAR : DATE,DATE1.
***  DATE = IT_MIC-GUELTIGAM.
***  CONCATENATE DATE+4(4) DATE+2(2) DATE+0(2)
***  INTO DATE1.
***  IT_MIC-ZCDATE = DATE1.
***
***  SELECT SINGLE QPMK~SOLLWNI QPMK~TOLOBNI QPMK~TOLUNNI
***    INTO (IT_MIC-ZQTTGT, IT_MIC-ZQTUP, IT_MIC-ZQTLW)
***    FROM QPMK
***    WHERE QPMK~ZAEHLER EQ IT_MIC-WERKS
***    AND QPMK~MKMNR EQ IT_MIC-MKMNR
***    AND QPMK~GUELTIGAB LT IT_MIC-ZCDATE.
***
**************************************add by irma
***    IF IT_MIC-TOLERUNTEN EQ 'X' OR IT_MIC-TOLEROBEN EQ 'X'.
***    perform bdc_dynpro      using 'SAPMQSDA' '0110'.
***    perform bdc_field       using 'BDC_CURSOR'
***                                  'QPMK-TOLERANZSL'.
***    perform bdc_field       using 'BDC_OKCODE'
***                                  '=WEIT'.
***
***        IF IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X'.
***        ELSE.
***             IF IT_MIC-Decimalplaces NE ''.
***               perform bdc_dynpro      using 'SAPMQSDA' '0108'.
***               perform bdc_field       using 'BDC_CURSOR'
***                                    'QFLTP-TOLERANZOB'.
***               perform bdc_field       using 'BDC_OKCODE'
***                                    '=WEIT'.
***               IF IT_MIC-Decimalplaces NE ''.
***                 perform bdc_field       using 'QPMK-STELLEN'
***                                         IT_MIC-Decimalplaces. "'STELLEN. "'2'.
***               ENDIF.
***               IF IT_MIC-MeasurementUnit NE ''.
***                 perform bdc_field       using 'RMQSD-MASSEINHSW'
***                                        IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
***               ENDIF.
***               IF IT_MIC-TargetValue NE ''.
***                 perform bdc_field       using 'QFLTP-SOLLWERT'
***                                      IT_MIC-TargetValue. "SOLLWERT. "'120'.
***               ENDIF.
***               IF IT_MIC-LowerSpecLimit NE ''.
***                 perform bdc_field       using 'QFLTP-TOLERANZUN'
***                                      IT_MIC-LowerSpecLimit. "TOLERANZUN. "'100'.
***               ENDIF.
***               IF IT_MIC-UpperSpecLimit NE ''.
***                 perform bdc_field       using 'QFLTP-TOLERANZOB'
***                                      IT_MIC-UpperSpecLimit. "TOLERANZOB. "'120'.
***               ENDIF.
***             ENDIF.
***        ENDIF.
***    ENDIF.
***
***
***    IF IT_MIC-TOLERUNTEN EQ '' AND IT_MIC-TOLEROBEN EQ '' AND IT_MIC-SOLLPRUEF EQ 'X'.
***         IF IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X'.
***         ELSE.
***           IF IT_MIC-Decimalplaces NE ''.
***             perform bdc_dynpro      using 'SAPMQSDA' '0108'.
***             perform bdc_field       using 'BDC_CURSOR'
***                                    'QPMK-STELLEN'.
***             perform bdc_field       using 'BDC_OKCODE'
***                                    '=WEIT'.
***             IF IT_MIC-Decimalplaces NE ''.
***               perform bdc_field       using 'QPMK-STELLEN'
***                                       IT_MIC-Decimalplaces. "'STELLEN. "'2'.
***             ENDIF.
***             IF IT_MIC-MeasurementUnit NE ''.
***               perform bdc_field       using 'RMQSD-MASSEINHSW'
***                                      IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
***             ENDIF.
***             IF IT_MIC-TargetValue NE ''.
***               perform bdc_field       using 'QFLTP-SOLLWERT'
***                                      IT_MIC-TargetValue. "SOLLWERT. "'120'.
***             ENDIF.
***           ENDIF.
***        ENDIF.
***    ENDIF.

*********************************** end
  perform bdc_dynpro      using 'SAPMQSDA' '0106'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMZ-AUSWMGWRK1'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
  perform bdc_field       using 'QPMZ-AUSWMENGE1'
                                IT_MIC-AUSWMENGE1. "'1-QL-HU'.
  perform bdc_field       using 'QPMZ-AUSWMGWRK1'
                                IT_MIC-AUSWMGWRK1. "'2000'.

  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMQSD-VSTEUERKZ'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'RMQSD-QUALITAET'
                                IT_MIC-QUALITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Bonding strength with Scott Test'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'BONDING STRENGTH WITH SCOTT TEST'.
*  perform bdc_transaction using 'QS21'.

  CALL TRANSACTION 'QS21' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
ENDFORM.

FORM BDC_ZQM_QS22_QT.
  "QUANTITATIVE DATA EXIST OR NOT?
  DATA  : DATE(10),
          DATE1(10).
  CLEAR : DATE,DATE1.
  DATE = IT_MIC-GUELTIGAM.
  CONCATENATE DATE+6(4) DATE+3(2) DATE+0(2)
  INTO DATE1.
  IT_MIC-ZCDATE = DATE1.

  "check quantitative data
*  CLEAR : IT_MIC-UPPER,IT_MIC-LOWER,IT_MIC-TARGET.
  IT_MIC-UPPER = IT_MIC-UPPERSPECLIMIT.
  IT_MIC-LOWER = IT_MIC-LOWERSPECLIMIT.
  IT_MIC-TARGET = IT_MIC-TARGETVALUE.

  IF IT_MIC-LOWERSPECLIMIT NE '' AND IT_MIC-UPPERSPECLIMIT NE '' AND IT_MIC-TARGETVALUE NE ''. "UPPER LOWER TARGET
      IF ( IT_MIC-LOWER > IT_MIC-UPPER ) OR ( IT_MIC-TARGET < IT_MIC-LOWER ) OR ( IT_MIC-TARGET > IT_MIC-UPPER ) .
        MSGS-MSGTYP = 'E'.
        APPEND MSGS.
        EXIT.
      ENDIF.
  ELSEIF IT_MIC-LOWERSPECLIMIT NE '' AND IT_MIC-UPPERSPECLIMIT NE ''.
        IF IT_MIC-LOWER > IT_MIC-UPPER.
        MSGS-MSGTYP = 'E'.
        APPEND MSGS.
        EXIT.
      ENDIF.
  ELSEIF IT_MIC-LOWERSPECLIMIT NE '' AND IT_MIC-TARGETVALUE NE ''. "LOWER TARGET
      IF IT_MIC-TARGET < IT_MIC-LOWER.
        MSGS-MSGTYP = 'E'.
        APPEND MSGS.
        EXIT.
      ENDIF.
  ELSEIF IT_MIC-UPPERSPECLIMIT NE '' AND IT_MIC-TARGETVALUE NE ''.  "UPPER TARGET
      IF IT_MIC-TARGET > IT_MIC-UPPER.
        MSGS-MSGTYP = 'E'.
        APPEND MSGS.
        EXIT.
      ENDIF.
  ENDIF.
  "end of check

  SELECT SINGLE QPMK~SOLLWNI QPMK~TOLOBNI QPMK~TOLUNNI QPMK~MASSEINHSW QPMK~VERSION
    INTO (IT_MIC-ZQTTGT, IT_MIC-ZQTUP, IT_MIC-ZQTLW, IT_MIC-MASSEINHSW, IT_MIC-ZVERSION)
    FROM QPMK
    WHERE QPMK~ZAEHLER EQ IT_MIC-WERKS
    AND QPMK~MKMNR EQ IT_MIC-MKMNR
    AND QPMK~GUELTIGAB LT IT_MIC-ZCDATE.

  perform bdc_dynpro      using 'SAPMQSDA' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-GUELTIGAB'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'QPMK-WERKS'
                                IT_MIC-WERKS. "'2000'.
  perform bdc_field       using 'QPMK-MKMNR'
                                IT_MIC-MKMNR. "'PCCAELMD'.
  perform bdc_field       using 'QPMK-GUELTIGAB'
                                IT_MIC-GUELTIGAM. "'09.11.2012'.

  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-SORTFELD'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=MART'.
  perform bdc_field       using 'RMQSD-QUANTITAET'
                                IT_MIC-QUANTITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Elongation MD'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'Elongation MD'.
  perform bdc_field       using 'QPMK-DUMMY40'
                                IT_MIC-DUMMY40.

*  IF ( IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X' ) AND IT_MIC-MASSEINHSW IS INITIAL.
  IF IT_MIC-ZVERSION NE '' AND IT_MIC-MASSEINHSW IS INITIAL.
           perform bdc_dynpro      using 'SAPMQSDA' '0108'.
           perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-STELLEN'.
           perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
           perform bdc_field       using 'RMQSD-MASSEINHSW'
                                IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.

   ENDIF.

  perform bdc_dynpro      using 'SAPLQSS0' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-ESTUKZ3'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-TOLERUNTEN'
                                IT_MIC-TOLERUNTEN. "'X'.
  perform bdc_field       using 'RQMST-TOLEROBEN'
                                IT_MIC-TOLEROBEN. "'X'.
  perform bdc_field       using 'RQMST-SOLLPRUEF'
                                IT_MIC-SOLLPRUEF. "'X'.
  perform bdc_field       using 'RQMST-STICHPR'
                                IT_MIC-STICHPR. "'X'.
  perform bdc_field       using 'RQMST-ADDPRO'
                                IT_MIC-ADDPRO. "'X'.
  perform bdc_field       using 'RQMST-QSPCMK'
                                IT_MIC-QSPCMK. "'X'.
  perform bdc_field       using 'RQMST-ZERSTPRF'
                                IT_MIC-ZERSTPRF. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ5'
                                IT_MIC-ESTUKZ5. "''.
  perform bdc_field       using 'RQMST-RZWANG4'
                                IT_MIC-RZWANG4. "'X'.
  perform bdc_field       using 'RQMST-RZWANG1'
                                IT_MIC-RZWANG1. "''.
  perform bdc_field       using 'RQMST-ESTUKZ3'
                                IT_MIC-ESTUKZ3. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ1'
                                IT_MIC-ESTUKZ1. "''.
  perform bdc_field       using 'RQMST-ESTUKZ2'
                                IT_MIC-ESTUKZ2. "''.
  perform bdc_field       using 'RQMST-FEHLREC'
                                IT_MIC-FEHLREC. "''.
  perform bdc_field       using 'RQMST-RZWANG2'
                                IT_MIC-RZWANG2. "''.
  perform bdc_field       using 'RQMST-RZWANG3'
                                IT_MIC-RZWANG3. "''.

  perform bdc_dynpro      using 'SAPLQSS0' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-LZEITKZ'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-PUMFKZ1'
                                IT_MIC-PUMFKZ1. "'X'.
  perform bdc_field       using 'RQMST-DOKUKZ1'
                                IT_MIC-DOKUKZ1. "'X'.
  perform bdc_field       using 'RQMST-PUMFKZ4'
                                IT_MIC-PUMFKZ4. "''.
  perform bdc_field       using 'RQMST-PUMFKZ2'
                                IT_MIC-PUMFKZ2. "''.
  perform bdc_field       using 'RQMST-PUMFKZ3'
                                IT_MIC-PUMFKZ3. "''.
  perform bdc_field       using 'RQMST-DOKUKZ2'
                                IT_MIC-DOKUKZ2. "''.
  perform bdc_field       using 'RQMST-DOKUKZ3'
                                IT_MIC-DOKUKZ3. "''.
  perform bdc_field       using 'RQMST-LZEITKZ'
                                IT_MIC-LZEITKZ. "'X'.
  perform bdc_field       using 'RQMST-AUSSLOS'
                                IT_MIC-AUSSLOS." 'X'.
  perform bdc_field       using 'RQMST-AENDBELEG'
                                IT_MIC-AENDBELEG. "'X'.
  perform bdc_field       using 'RQMST-PMMZWANG'
                                IT_MIC-PMMZWANG. "'X'.
  perform bdc_field       using 'RQMST-MESSWERTE'
                                IT_MIC-MESSWERTE. "'X'.
  perform bdc_field       using 'RQMST-FORMELMK'
                                IT_MIC-FORMELMK. "''.
  perform bdc_field       using 'RQMST-DRUCK1'
                                IT_MIC-DRUCK1. "''.
  perform bdc_field       using 'RQMST-KEINEFORMEL'
                                IT_MIC-NOFORMULA. "KEINEFORMEL. "'X'.
  perform bdc_field       using 'RQMST-DRUCK3'
                                IT_MIC-DRUCK3. "''.
  perform bdc_field       using 'RQMST-DRUCK2'
                                IT_MIC-DRUCK2. "'X'.


  IF IT_MIC-TOLERUNTEN EQ 'X' AND IT_MIC-TOLEROBEN EQ 'X' AND IT_MIC-SOLLPRUEF EQ 'X'. "JIKA LOWER,UPPER,TARGET VALUE DI PILIH
       IF ( IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X').
      ELSE.
          perform bdc_dynpro      using 'SAPMQSDA' '0110'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'QPMK-TOLERANZSL'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=WEIT'.
          IF IT_MIC-MASSEINHSW EQ ''.
           perform bdc_dynpro      using 'SAPMQSDA' '0108'.
           perform bdc_field       using 'BDC_CURSOR'
                                'QFLTP-TOLERANZOB'.
           perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
           perform bdc_field       using 'QPMK-STELLEN'
                                IT_MIC-Decimalplaces. "'STELLEN. "'2'.
           perform bdc_field       using 'RMQSD-MASSEINHSW'
                                IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
           perform bdc_field       using 'QFLTP-SOLLWERT'
                                IT_MIC-TargetValue. "SOLLWERT. "'120'.
           perform bdc_field       using 'QFLTP-TOLERANZUN'
                                IT_MIC-LowerSpecLimit. "TOLERANZUN. "'100'.
           perform bdc_field       using 'QFLTP-TOLERANZOB'
                                IT_MIC-UpperSpecLimit. "TOLERANZOB. "'120'.
           ENDIF.
      ENDIF.
  ENDIF.

  IF IT_MIC-TOLERUNTEN EQ 'X' AND IT_MIC-TOLEROBEN EQ 'X' AND IT_MIC-SOLLPRUEF EQ ''. "JIKA LOWER,UPPER DI PILIH
       IF ( IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X').
      ELSE.
          perform bdc_dynpro      using 'SAPMQSDA' '0110'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'QPMK-TOLERANZSL'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=WEIT'.
          IF IT_MIC-MASSEINHSW EQ ''.
           perform bdc_dynpro      using 'SAPMQSDA' '0108'.
           perform bdc_field       using 'BDC_CURSOR'
                                'QFLTP-TOLERANZOB'.
           perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
           perform bdc_field       using 'QPMK-STELLEN'
                                IT_MIC-Decimalplaces. "'STELLEN. "'2'.
           perform bdc_field       using 'RMQSD-MASSEINHSW'
                                IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
           perform bdc_field       using 'QFLTP-TOLERANZUN'
                                IT_MIC-LowerSpecLimit. "TOLERANZUN. "'100'.
           perform bdc_field       using 'QFLTP-TOLERANZOB'
                                IT_MIC-UpperSpecLimit. "TOLERANZOB. "'120'.
           ENDIF.
      ENDIF.
  ENDIF.

  IF IT_MIC-TOLERUNTEN EQ 'X' AND IT_MIC-TOLEROBEN EQ '' AND IT_MIC-SOLLPRUEF EQ ''. "JIKA HANYA LOWER YANG DIPIILH
       IF ( IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X').
      ELSE.
          perform bdc_dynpro      using 'SAPMQSDA' '0110'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'QPMK-TOLERANZSL'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=WEIT'.
          IF IT_MIC-MASSEINHSW EQ ''.
           perform bdc_dynpro      using 'SAPMQSDA' '0108'.
           perform bdc_field       using 'BDC_CURSOR'
                                'QFLTP-TOLERANZUN'.
           perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
           perform bdc_field       using 'QPMK-STELLEN'
                                IT_MIC-Decimalplaces. "'STELLEN. "'2'.
           perform bdc_field       using 'RMQSD-MASSEINHSW'
                                IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
           perform bdc_field       using 'QFLTP-TOLERANZUN'
                                IT_MIC-LowerSpecLimit. "TOLERANZUN. "'100'.
           ENDIF.
      ENDIF.
  ENDIF.

  IF IT_MIC-TOLERUNTEN EQ '' AND IT_MIC-TOLEROBEN EQ 'X' AND IT_MIC-SOLLPRUEF EQ ''. "JIKA HANYA UPPER YANG DIPIILH
       IF ( IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X').
      ELSE.
          perform bdc_dynpro      using 'SAPMQSDA' '0110'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'QPMK-TOLERANZSL'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=WEIT'.
          IF IT_MIC-MASSEINHSW EQ ''.
           perform bdc_dynpro      using 'SAPMQSDA' '0108'.
           perform bdc_field       using 'BDC_CURSOR'
                                'QFLTP-TOLERANZOB'.
           perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
           perform bdc_field       using 'QPMK-STELLEN'
                                IT_MIC-Decimalplaces. "'STELLEN. "'2'.
           perform bdc_field       using 'RMQSD-MASSEINHSW'
                                IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
           perform bdc_field       using 'QFLTP-TOLERANZOB'
                                IT_MIC-UpperSpecLimit. "TOLERANZOB. "'120'.
           ENDIF.
      ENDIF.
  ENDIF.

  IF IT_MIC-TOLERUNTEN EQ '' AND IT_MIC-TOLEROBEN EQ '' AND IT_MIC-SOLLPRUEF EQ 'X'. "JIKA HANYA TARGET VALUE YANG DIPILIH
       IF IT_MIC-ZQTTGT EQ 'X' OR IT_MIC-ZQTUP EQ 'X' OR IT_MIC-ZQTLW EQ 'X'.
       ELSE.
         perform bdc_dynpro      using 'SAPMQSDA' '0108'.
         perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-STELLEN'.
         perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
         perform bdc_field       using 'QPMK-STELLEN'
                                IT_MIC-Decimalplaces. "'STELLEN. "'2'.
         perform bdc_field       using 'RMQSD-MASSEINHSW'
                                IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
         perform bdc_field       using 'QFLTP-SOLLWERT'
                                IT_MIC-TargetValue. "SOLLWERT. "'120'.
      ENDIF.
  ENDIF.

    IF IT_MIC-TOLERUNTEN EQ '' AND IT_MIC-TOLEROBEN EQ '' AND IT_MIC-SOLLPRUEF EQ ''. "JIKA TIDAK ADA YANG DIPILIH
       IF IT_MIC-MASSEINHSW IS NOT  INITIAL.
       ELSE.
         perform bdc_dynpro      using 'SAPMQSDA' '0108'.
         perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-STELLEN'.
         perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
         perform bdc_field       using 'QPMK-STELLEN'
                                IT_MIC-Decimalplaces. "'STELLEN. "'2'.
         perform bdc_field       using 'RMQSD-MASSEINHSW'
                                IT_MIC-MeasurementUnit. "MASSEINHSW. "'%'.
      ENDIF.
  ENDIF.

  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMQSD-VSTEUERKZ'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'RMQSD-QUANTITAET'
                                IT_MIC-QUANTITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Elongation MD'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'ELONGATION MD'.
*  perform bdc_transaction using 'QS21'.
  CALL TRANSACTION 'QS22' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
ENDFORM.                    " BDC_ZQM_QS21_QT

FORM BDC_ZQM_QS22_QL .
  DATA  : DATE(10),
          DATE1(10).
  CLEAR : DATE,DATE1.
  DATE = IT_MIC-GUELTIGAM.
  CONCATENATE DATE+6(4) DATE+3(2) DATE+0(2)
  INTO DATE1.
  IT_MIC-ZCDATE = DATE1.

  SELECT SINGLE QPMZ~AUSWMENGE1
    INTO (IT_MIC-QUAL)
    FROM QPMZ
    WHERE QPMZ~ZAEHLER EQ IT_MIC-WERKS
    AND QPMZ~MKMNR EQ IT_MIC-MKMNR.
*    AND QPMZ~GUELTIGAB LT IT_MIC-ZCDATE.

   SELECT SINGLE QPMZ~AUSWMENGE1
    INTO (IT_MIC-QUAL2)
    FROM QPMZ
    WHERE QPMZ~ZAEHLER EQ IT_MIC-WERKS
    AND QPMZ~MKMNR EQ IT_MIC-MKMNR
    AND QPMZ~GUELTIGAB LT IT_MIC-ZCDATE.

  perform bdc_dynpro      using 'SAPMQSDA' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-MKMNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'QPMK-WERKS'
                                IT_MIC-WERKS. "'2000'.
  perform bdc_field       using 'QPMK-MKMNR'
                                IT_MIC-MKMNR. "'PEZABTAL'.
  perform bdc_field       using 'QPMK-GUELTIGAB'
                                IT_MIC-GUELTIGAM. "'09.11.2012'.


  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-SORTFELD'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=MART'.
  perform bdc_field       using 'RMQSD-QUALITAET'
                                IT_MIC-QUALITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Bonding strength with Scott Test'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'Bonding strength with Scott Test'.
  perform bdc_field       using 'QPMK-DUMMY40'
                                IT_MIC-DUMMY40.

  IF IT_MIC-QUAL NE ''.
  ELSE.
  perform bdc_dynpro      using 'SAPMQSDA' '0106'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMZ-AUSWMGWRK1'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
  perform bdc_field       using 'QPMZ-AUSWMENGE1'
                                IT_MIC-AUSWMENGE1. "'1-QL-HU'.
  perform bdc_field       using 'QPMZ-AUSWMGWRK1'
                                IT_MIC-AUSWMGWRK1. "'2000'.
  ENDIF.

  perform bdc_dynpro      using 'SAPLQSS0' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-RZWANG4'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-PRUEFKAT'
                                IT_MIC-PRUEFKAT. "'X'.
  perform bdc_field       using 'RQMST-STICHPR'
                                IT_MIC-STICHPR. "'X'.
  perform bdc_field       using 'RQMST-ADDPRO'
                                IT_MIC-ADDPRO. "'X'.
  perform bdc_field       using 'RQMST-QSPCMK'
                                IT_MIC-QSPCMK. "'X'.
  perform bdc_field       using 'RQMST-ZERSTPRF'
                                IT_MIC-ZERSTPRF. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ5'
                                IT_MIC-ESTUKZ5. "''.
  perform bdc_field       using 'RQMST-RZWANG4'
                                IT_MIC-RZWANG4. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ3'
                                IT_MIC-ESTUKZ3. "'X'.
  perform bdc_field       using 'RQMST-ESTUKZ1'
                                IT_MIC-ESTUKZ1. "''.
  perform bdc_field       using 'RQMST-ESTUKZ2'
                                IT_MIC-ESTUKZ2. "''.
  perform bdc_field       using 'RQMST-RZWANG3'
                                IT_MIC-RZWANG3. "''.
  perform bdc_field       using 'RQMST-RZWANG2'
                                IT_MIC-RZWANG2. "''.
  perform bdc_field       using 'RQMST-RZWANG1'
                                IT_MIC-RZWANG1. "''.


  perform bdc_dynpro      using 'SAPLQSS0' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RQMST-DRUCK2'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'RQMST-DOKUKZ1'
                                IT_MIC-DOKUKZ1. "'X'.
  perform bdc_field       using 'RQMST-DOKUKZ2'
                                IT_MIC-DOKUKZ2. "''.
  perform bdc_field       using 'RQMST-DOKUKZ3'
                                IT_MIC-DOKUKZ3. "''.
  perform bdc_field       using 'RQMST-PUMFKZ1'
                                IT_MIC-PUMFKZ1. "''.
  perform bdc_field       using 'RQMST-PUMFKZ2'
                                IT_MIC-PUMFKZ2. "''.
  perform bdc_field       using 'RQMST-PUMFKZ3'
                                IT_MIC-PUMFKZ3. "''.
  perform bdc_field       using 'RQMST-PUMFKZ4'
                                IT_MIC-PUMFKZ4. "'X'.
  perform bdc_field       using 'RQMST-LZEITKZ'
                                IT_MIC-LZEITKZ."'X'.
  perform bdc_field       using 'RQMST-AUSSLOS'
                                IT_MIC-AUSSLOS. "'X'.
  perform bdc_field       using 'RQMST-AENDBELEG'
                                IT_MIC-AENDBELEG. "'X'.
  perform bdc_field       using 'RQMST-PMMZWANG'
                                IT_MIC-PMMZWANG. "'X'.
  perform bdc_field       using 'RQMST-DRUCK1'
                                IT_MIC-DRUCK1. "''.
  perform bdc_field       using 'RQMST-DRUCK2'
                                IT_MIC-DRUCK2. "'X'.
  perform bdc_field       using 'RQMST-DRUCK3'
                                IT_MIC-DRUCK3. "''.



  IF IT_MIC-QUAL2 NE ''.
  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-SORTFELD'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=KT'.
  perform bdc_dynpro      using 'SAPMQSDA' '0106'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMZ-AUSWMGWRK1'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.

  perform bdc_field       using 'QPMZ-AUSWMENGE1'
                                IT_MIC-AUSWMENGE1. "'1-QL-HU'.
  perform bdc_field       using 'QPMZ-AUSWMGWRK1'
                                IT_MIC-AUSWMGWRK1. "'2000'.
  ELSE.
  perform bdc_dynpro      using 'SAPMQSDA' '0106'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMZ-AUSWMGWRK1'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.

  perform bdc_field       using 'QPMZ-AUSWMENGE1'
                                IT_MIC-AUSWMENGE1. "'1-QL-HU'.
  perform bdc_field       using 'QPMZ-AUSWMGWRK1'
                                IT_MIC-AUSWMGWRK1. "'2000'.
  ENDIF.

  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMQSD-VSTEUERKZ'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'RMQSD-QUALITAET'
                                IT_MIC-QUALITAET. "'X'.
  perform bdc_field       using 'QPMK-LOEKZ'
                                IT_MIC-LOEKZ. "'2'.
  perform bdc_field       using 'QPMK-KONSISTENT'
                                IT_MIC-KONSISTENT. "'1'.
  perform bdc_field       using 'VSKT-KURZTEXT'
                                IT_MIC-KURZTEXT. "'Bonding strength with Scott Test'.
  perform bdc_field       using 'QPMK-SORTFELD'
                                IT_MIC-SORTFELD. "'BONDING STRENGTH WITH SCOTT TEST'.
*  perform bdc_transaction using 'QS21'.

  CALL TRANSACTION 'QS22' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
ENDFORM.                    " BDC_ZQM_QS21_QL

FORM BDC_ZQM_QS23_QL.
SELECT COUNT( * ) INTO IT_MIC-ZVER
  FROM QPMK
  WHERE QPMK~ZAEHLER EQ IT_MIC-WERKS
  AND QPMK~MKMNR EQ IT_MIC-MKMNR.

  DATA  : DATE(8),
          DATE1(8).
  CLEAR : DATE,DATE1.
  DATE = IT_MIC-GUELTIGAM.
  CONCATENATE DATE+4(4) DATE+2(2) DATE+0(2)
  INTO DATE1.
  IT_MIC-ZCDATE = DATE1.

  SELECT SINGLE QPMZ~AUSWMENGE1
    INTO (IT_MIC-QUAL)
    FROM QPMZ
    WHERE QPMZ~ZAEHLER EQ IT_MIC-WERKS
    AND QPMZ~MKMNR EQ IT_MIC-MKMNR
    AND QPMZ~VERSION EQ IT_MIC-GUELTIGAM.


IF IT_MIC-ZVER > 1.
perform bdc_dynpro      using 'SAPMQSDA' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'QPMK-MKMNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'QPMK-WERKS'
                              IT_MIC-WERKS.     "'2000'.
perform bdc_field       using 'QPMK-MKMNR'
                              IT_MIC-MKMNR.     "'PEZABTAL'.


perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '02/01'.
perform bdc_field       using 'BDC_OKCODE'
                              '=NSEL'.


perform bdc_dynpro      using 'SAPLSDH4' '0200'.
perform bdc_field       using 'BDC_OKCODE'
                              '=GOON'.
perform bdc_field       using 'BDC_CURSOR'
                              'G_SELFLD_TAB-LOW(03)'.
perform bdc_field       using 'G_SELFLD_TAB-LOW(03)'
                              IT_MIC-GUELTIGAM.       "'2'.


perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '04/03'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
ELSE.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-MKMNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'QPMK-WERKS'
                                IT_MIC-WERKS. "'2000'.
  perform bdc_field       using 'QPMK-MKMNR'
                                IT_MIC-MKMNR. "'PEZABTAL'.
ENDIF.

perform bdc_dynpro      using 'SAPMQSDA' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'QPMK-SORTFELD'.
perform bdc_field       using 'BDC_OKCODE'
                              '=MART'.
perform bdc_field       using 'RMQSD-QUALITAET'
                              IT_MIC-QUALITAET.     "'X'.
perform bdc_field       using 'QPMK-LOEKZ'
                              IT_MIC-LOEKZ.         "'2'.
perform bdc_field       using 'QPMK-KONSISTENT'
                              IT_MIC-KONSISTENT.    "'1'.
perform bdc_field       using 'VSKT-KURZTEXT'
                              IT_MIC-KURZTEXT.      "'Bonding strength with Scott Test 23'.
perform bdc_field       using 'QPMK-SORTFELD'
                              IT_MIC-SORTFELD.       "'BONDING STRENGTH WITH SCOTT TEST 23'.
perform bdc_field       using 'QPMK-DUMMY40'
                                IT_MIC-DUMMY40.

  IF IT_MIC-QUAL NE ''.
  ELSE.
  perform bdc_dynpro      using 'SAPMQSDA' '0106'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMZ-AUSWMGWRK1'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.
  perform bdc_field       using 'QPMZ-AUSWMENGE1'
                                IT_MIC-AUSWMENGE1. "'1-QL-HU'.
  perform bdc_field       using 'QPMZ-AUSWMGWRK1'
                                IT_MIC-AUSWMGWRK1. "'2000'.
  ENDIF.

perform bdc_dynpro      using 'SAPLQSS0' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RQMST-TEXT1'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENT1'.
perform bdc_field       using 'RQMST-PRUEFKAT'
                              IT_MIC-PRUEFKAT.        "'X'.
perform bdc_field       using 'RQMST-STICHPR'
                              IT_MIC-STICHPR.         "'X'.
perform bdc_field       using 'RQMST-ADDPRO'
                              IT_MIC-ADDPRO.          "'X'.
perform bdc_field       using 'RQMST-QSPCMK'
                              IT_MIC-QSPCMK.          "'X'.
perform bdc_field       using 'RQMST-ZERSTPRF'
                              IT_MIC-ZERSTPRF.        "'X'.
perform bdc_field       using 'RQMST-ESTUKZ5'
                              IT_MIC-ESTUKZ5.         "''.
perform bdc_field       using 'RQMST-RZWANG4'
                              IT_MIC-RZWANG4.         "'X'.
perform bdc_field       using 'RQMST-ESTUKZ3'
                              IT_MIC-ESTUKZ3.         "'X'.
perform bdc_field       using 'RQMST-ESTUKZ1'
                              IT_MIC-ESTUKZ1.         "''.
perform bdc_field       using 'RQMST-ESTUKZ2'
                              IT_MIC-ESTUKZ2.         "''.
perform bdc_field       using 'RQMST-RZWANG3'
                              IT_MIC-RZWANG3.         "''.
perform bdc_field       using 'RQMST-RZWANG2'
                              IT_MIC-RZWANG2.         "''.
perform bdc_field       using 'RQMST-RZWANG1'
                              IT_MIC-RZWANG1.         "''.


perform bdc_dynpro      using 'SAPLQSS0' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'RQMST-TEXT1'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENT1'.
perform bdc_field       using 'RQMST-DOKUKZ1'
                              IT_MIC-DOKUKZ1.     "'X'.
perform bdc_field       using 'RQMST-DOKUKZ2'
                              IT_MIC-DOKUKZ2.     "''.
perform bdc_field       using 'RQMST-DOKUKZ3'
                              IT_MIC-DOKUKZ3.     "''.
perform bdc_field       using 'RQMST-PUMFKZ1'
                              IT_MIC-PUMFKZ1.     "''.
perform bdc_field       using 'RQMST-PUMFKZ2'
                              IT_MIC-PUMFKZ2.     "''.
perform bdc_field       using 'RQMST-PUMFKZ3'
                              IT_MIC-PUMFKZ3.     "''.
perform bdc_field       using 'RQMST-PUMFKZ4'
                              IT_MIC-PUMFKZ4.     "'X'.
perform bdc_field       using 'RQMST-LZEITKZ'
                              IT_MIC-LZEITKZ.     "'X'.
perform bdc_field       using 'RQMST-AUSSLOS'
                              IT_MIC-AUSSLOS.     "'X'.
perform bdc_field       using 'RQMST-AENDBELEG'
                              IT_MIC-AENDBELEG.   "'X'.
perform bdc_field       using 'RQMST-PMMZWANG'
                              IT_MIC-PMMZWANG.    "'X'.
perform bdc_field       using 'RQMST-DRUCK1'
                              IT_MIC-DRUCK1.      "''.
perform bdc_field       using 'RQMST-DRUCK2'
                              IT_MIC-DRUCK2.      "'X'.
perform bdc_field       using 'RQMST-DRUCK3'
                              IT_MIC-DRUCK3.      "''.


IF IT_MIC-QUAL NE ''.
  perform bdc_dynpro      using 'SAPMQSDA' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-SORTFELD'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=KT'.
  perform bdc_dynpro      using 'SAPMQSDA' '0106'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMZ-AUSWMGWRK1'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.

  perform bdc_field       using 'QPMZ-AUSWMENGE1'
                                IT_MIC-AUSWMENGE1. "'1-QL-HU'.
  perform bdc_field       using 'QPMZ-AUSWMGWRK1'
                                IT_MIC-AUSWMGWRK1. "'2000'.
  ELSE.
  perform bdc_dynpro      using 'SAPMQSDA' '0106'.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMZ-AUSWMGWRK1'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=WEIT'.

  perform bdc_field       using 'QPMZ-AUSWMENGE1'
                                IT_MIC-AUSWMENGE1. "'1-QL-HU'.
  perform bdc_field       using 'QPMZ-AUSWMGWRK1'
                                IT_MIC-AUSWMGWRK1. "'2000'.
  ENDIF.


perform bdc_dynpro      using 'SAPMQSDA' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'RMQSD-ATNAM'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.

  CALL TRANSACTION 'QS23' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
ENDFORM.

FORM BDC_ZQM_QS23_QT.
SELECT COUNT( * ) INTO IT_MIC-ZVER
  FROM QPMK
  WHERE QPMK~ZAEHLER EQ IT_MIC-WERKS
  AND QPMK~MKMNR EQ IT_MIC-MKMNR.

perform bdc_dynpro      using 'SAPMQSDA' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'QPMK-MKMNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'QPMK-WERKS'
                              IT_MIC-WERKS.       "'2000'.
perform bdc_field       using 'QPMK-MKMNR'
                              IT_MIC-MKMNR.    "'CAFOELMD'.

IF IT_MIC-ZVER > 1.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '02/01'.
perform bdc_field       using 'BDC_OKCODE'
                              '=NSEL'.

perform bdc_dynpro      using 'SAPLSDH4' '0200'.
perform bdc_field       using 'BDC_OKCODE'
                              '=GOON'.
perform bdc_field       using 'BDC_CURSOR'
                              'G_SELFLD_TAB-LOW(03)'.
perform bdc_field       using 'G_SELFLD_TAB-LOW(03)'
                              IT_MIC-GUELTIGAM.       "'3'. "version


perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '04/03'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
ELSE.
  perform bdc_field       using 'BDC_CURSOR'
                                'QPMK-MKMNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'QPMK-WERKS'
                                IT_MIC-WERKS. "'2000'.
  perform bdc_field       using 'QPMK-MKMNR'
                                IT_MIC-MKMNR. "'PEZABTAL'.
ENDIF.

perform bdc_dynpro      using 'SAPMQSDA' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'QPMK-SORTFELD'.
perform bdc_field       using 'BDC_OKCODE'
                              '=MART'.
perform bdc_field       using 'RMQSD-QUANTITAET'
                              IT_MIC-QUANTITAET.        "'X'.
perform bdc_field       using 'QPMK-LOEKZ'
                              IT_MIC-LOEKZ.             "'2'.
perform bdc_field       using 'QPMK-KONSISTENT'
                              IT_MIC-KONSISTENT.        "'1'.
perform bdc_field       using 'VSKT-KURZTEXT'
                              IT_MIC-KURZTEXT.          "'Elongation MD 23'.
perform bdc_field       using 'QPMK-SORTFELD'
                              IT_MIC-SORTFELD.         "'ELONGATION MD STD 90-140 24'.
perform bdc_field       using 'QPMK-DUMMY40'
                                IT_MIC-DUMMY40.
*perform bdc_field       using 'QPMK-MERKGEW'
*                              IT_MIC-MERKGEW.           "'MN'.


perform bdc_dynpro      using 'SAPLQSS0' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RQMST-TEXT1'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENT1'.
perform bdc_field       using 'RQMST-TOLERUNTEN'
                              IT_MIC-TOLERUNTEN.  "'X'.
perform bdc_field       using 'RQMST-TOLEROBEN'
                              IT_MIC-TOLEROBEN.   "'X'.
perform bdc_field       using 'RQMST-SOLLPRUEF'
                              IT_MIC-SOLLPRUEF.   "'X'.
perform bdc_field       using 'RQMST-STICHPR'
                              IT_MIC-STICHPR.     "'X'.
perform bdc_field       using 'RQMST-ADDPRO'
                              IT_MIC-ADDPRO.      "'X'.
perform bdc_field       using 'RQMST-QSPCMK'
                              IT_MIC-QSPCMK.      "'X'.
perform bdc_field       using 'RQMST-ZERSTPRF'
                              IT_MIC-ZERSTPRF.    "'X'.
perform bdc_field       using 'RQMST-ESTUKZ5'
                              IT_MIC-ESTUKZ5.     "''.
perform bdc_field       using 'RQMST-RZWANG4'
                              IT_MIC-RZWANG4.     "'X'.
perform bdc_field       using 'RQMST-RZWANG1'
                              IT_MIC-RZWANG1.     "''.
perform bdc_field       using 'RQMST-ESTUKZ3'
                              IT_MIC-ESTUKZ3.     "'X'.
perform bdc_field       using 'RQMST-ESTUKZ1'
                              IT_MIC-ESTUKZ1.     "''.
perform bdc_field       using 'RQMST-ESTUKZ2'
                              IT_MIC-ESTUKZ2.     "''.
perform bdc_field       using 'RQMST-FEHLREC'
                              IT_MIC-FEHLREC.     "''.
perform bdc_field       using 'RQMST-RZWANG2'
                              IT_MIC-RZWANG2.     "''.
perform bdc_field       using 'RQMST-RZWANG3'
                              IT_MIC-RZWANG3.     "''.


perform bdc_dynpro      using 'SAPLQSS0' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'RQMST-DRUCK2'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENT1'.
perform bdc_field       using 'RQMST-PUMFKZ1'
                              IT_MIC-PUMFKZ1.       "''.
perform bdc_field       using 'RQMST-DOKUKZ1'
                              IT_MIC-DOKUKZ1.       "'X'.
perform bdc_field       using 'RQMST-PUMFKZ4'
                              IT_MIC-PUMFKZ4.       "'X'.
perform bdc_field       using 'RQMST-PUMFKZ2'
                              IT_MIC-PUMFKZ2.        "''.
perform bdc_field       using 'RQMST-PUMFKZ3'
                              IT_MIC-PUMFKZ3.     "''.
perform bdc_field       using 'RQMST-DOKUKZ2'
                              IT_MIC-DOKUKZ2.     "''.
perform bdc_field       using 'RQMST-DOKUKZ3'
                              IT_MIC-DOKUKZ3.     "''.
perform bdc_field       using 'RQMST-LZEITKZ'
                              IT_MIC-LZEITKZ.     "''.
perform bdc_field       using 'RQMST-AUSSLOS'
                              IT_MIC-AUSSLOS.     "''.
perform bdc_field       using 'RQMST-AENDBELEG'
                              IT_MIC-AENDBELEG.     "''.
perform bdc_field       using 'RQMST-PMMZWANG'
                              IT_MIC-PMMZWANG.      "''.
perform bdc_field       using 'RQMST-MESSWERTE'
                              IT_MIC-MESSWERTE.     "'X'.
perform bdc_field       using 'RQMST-FORMELMK'
                              IT_MIC-FORMELMK.      "''.
perform bdc_field       using 'RQMST-DRUCK1'
                              IT_MIC-DRUCK1.      "''.
perform bdc_field       using 'RQMST-KEINEFORMEL'
                              IT_MIC-NOFORMULA.   "'X'.
perform bdc_field       using 'RQMST-DRUCK3'
                              IT_MIC-DRUCK3.        "''.
perform bdc_field       using 'RQMST-DRUCK2'
                              IT_MIC-DRUCK2.      "'X'.


perform bdc_dynpro      using 'SAPMQSDA' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'RMQSD-ATNAM'.
perform bdc_field       using 'BDC_OKCODE'
                              '=QD'.


perform bdc_dynpro      using 'SAPMQSDA' '0108'.
perform bdc_field       using 'BDC_CURSOR'
                              'QPMK-STELLEN'.
perform bdc_field       using 'BDC_OKCODE'
                              '=WEIT'.
perform bdc_field       using 'QPMK-STELLEN'
                              IT_MIC-Decimalplaces.        "'3'.
perform bdc_field       using 'RMQSD-MASSEINHSW'
                              IT_MIC-MeasurementUnit.     "'%'.
perform bdc_field       using 'QFLTP-SOLLWERT'
                              IT_MIC-TargetValue.       "121.000'.
perform bdc_field       using 'QFLTP-TOLERANZUN'
                              IT_MIC-LowerSpecLimit.    "'          92.000'.
perform bdc_field       using 'QFLTP-TOLERANZOB'
                              IT_MIC-UpperSpecLimit. .    "'         142.000'.


perform bdc_dynpro      using 'SAPMQSDA' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'RMQSD-ATNAM'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.

  CALL TRANSACTION 'QS23' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
ENDFORM.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR: T_FIELDCAT. REFRESH T_FIELDCAT.
    PERFORM F_ALV_FIELDCATG_ICON USING 'IT_REPORT' :
        'LINE' '' ''  '' ''  'Line'      '' ' ' '' '',
        'STAT' '' ''  '' ''  'Status'      '' ' ' '' '',
        'WERKS' '' ''  '' ''  'Plant'      '' ' ' '' '',
        'MKMNR' '' ''  '' ''  'MIC'      '' ' ' '' '',
        'MESSAGE' '' ''  '' ''  'ERROR Log'      '' ' ' '' ''.
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
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_USER_COMMAND = 'F_USER_COMMAND'
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
      T_OUTTAB                = IT_REPORT
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON USING FU_TYPES
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
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
*  T_FIELDCAT-NO_ZERO       = 'X'.
  T_FIELDCAT-FIX_COLUMN    = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " F_ALV_FIELDCATG_ICON