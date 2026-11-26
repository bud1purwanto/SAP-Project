*&---------------------------------------------------------------------*
*&  Include           ZMMC_CONF_VAR_F01
*&---------------------------------------------------------------------*
INCLUDE Z_PROG_INFO.

START-OF-SELECTION.
AT SELECTION-SCREEN.
    CASE SY-UCOMM.
      WHEN 'INFO'.
        PERFORM F_PROG_INFO USING V_PROG.
      WHEN OTHERS.
        PERFORM GET_DATA.
        PERFORM UPLOADDATA.
        PERFORM DISPLAYREPORT.
    ENDCASE.

*START-OF-SELECTION.
*  CLEAR : ITAB, ITAB2.
*  REFRESH : ITAB, ITAB2.
*
*  CALL FUNCTION 'UPLOAD'
*    EXPORTING
*      FILETYPE = 'DAT'
*    TABLES
*      DATA_TAB = ITAB.
*
*  DELETE ADJACENT DUPLICATES FROM ITAB COMPARING MATNR WERKS LGORT.
*
*  LOOP AT ITAB.
*    CLEAR : I_MATNR, W_LENGHT.
*
*    W_LENGHT = STRLEN( ITAB-MATNR ).
*    W_INITAL = W_LENGHT - 1.
*    I_MATNR = ITAB-MATNR+W_INITAL(1).
*
*    IF I_MATNR = 'I'.
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0060'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RMMG1-MATNR'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=ENTR'.
*      PERFORM BDC_FIELD       USING 'RMMG1-MATNR'
*                                     ITAB-MATNR.  "'KACI'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0070'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'MSICHTAUSW-DYTXT(11)'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=ENTR'.
*      PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(02)'
*                                    'X'.
*      PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(11)'
*                                    'X'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0080'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RMMG1-LGORT'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=ENTR'.
*      PERFORM BDC_FIELD       USING 'RMMG1-WERKS'
*                                     ITAB-WERKS.  "'1000'.
*      PERFORM BDC_FIELD       USING 'RMMG1-LGORT'
*                                     ITAB-LGORT.  "'1001'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=PB21'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'MARA-SATNR'.
*      PERFORM BDC_FIELD       USING 'MARA-SATNR'
*                                     ITAB-SATNR. "'KACI'.
*      PERFORM BDC_FIELD       USING 'MARA-KZKFG'
*                                    'X'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RCTMS-MNAME(01)'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=BACK'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '/00'.
*      PERFORM BDC_FIELD       USING 'MARA-KZKFG'
*                                    'X'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=PB19'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'MARC-STDPD'.
*      PERFORM BDC_FIELD       USING 'MARC-STDPD'
*                                     ITAB-STDPD.  "'KACI'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RCTMS-MNAME(01)'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=BACK'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=BU'.
*      PERFORM BDC_TRANSACTION USING 'MM02'.
*
*    ELSEIF I_MATNR = 'O'.
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0060'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RMMG1-MATNR'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=ENTR'.
*      PERFORM BDC_FIELD       USING 'RMMG1-MATNR'
*                                     ITAB-MATNR.  "'KACI'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0070'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'MSICHTAUSW-DYTXT(11)'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=ENTR'.
*      PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(02)'
*                                    'X'.
*      PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(14)'
*                                    'X'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0080'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RMMG1-LGORT'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=ENTR'.
*      PERFORM BDC_FIELD       USING 'RMMG1-WERKS'
*                                     ITAB-WERKS.  "'1000'.
*      PERFORM BDC_FIELD       USING 'RMMG1-LGORT'
*                                     ITAB-LGORT.  "'1001'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=PB21'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'MARA-SATNR'.
*      PERFORM BDC_FIELD       USING 'MARA-SATNR'
*                                     ITAB-SATNR. "'KACI'.
*      PERFORM BDC_FIELD       USING 'MARA-KZKFG'
*                                    'X'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RCTMS-MNAME(01)'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=BACK'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '/00'.
*      PERFORM BDC_FIELD       USING 'MARA-KZKFG'
*                                    'X'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=PB19'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'MARC-STDPD'.
*      PERFORM BDC_FIELD       USING 'MARC-STDPD'
*                                     ITAB-STDPD.  "'KACI'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
*      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                    'RCTMS-MNAME(01)'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=BACK'.
*
*
*      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
*      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                    '=BU'.
*      PERFORM BDC_TRANSACTION USING 'MM02'.
*    ENDIF.
*  ENDLOOP.
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
      DATA_TAB            = ITAB
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

*&---------------------------------------------------------------------*
*&      Form  UPLOADDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOADDATA .
DATA : MSGS  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
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
       CTR TYPE I, COMPLETE(100),
       SATNR LIKE MARA-SATNR,
       STDPD LIKE MARC-STDPD.

**material yang bisa diupload hanya yang berawalan I atau O
  CLEAR IT_REPORT. REFRESH IT_REPORT.
  IF ITAB[] IS NOT INITIAL.
*    DELETE ADJACENT DUPLICATES FROM ITAB COMPARING MATNR WERKS LGORT.
    CLEAR : LINE.
    LOOP AT ITAB.
      CLEAR: BDCDATA, MESSTAB, MSGS, SATNR, COMPLETE.
      REFRESH: BDCDATA, MESSTAB, MSGS.
      CLEAR : I_MATNR, W_LENGHT, NOERR, SATNR, STDPD.
      LINE = LINE + 1.
      W_LENGHT = STRLEN( ITAB-MATNR ).
      W_INITAL = W_LENGHT - 1.
      I_MATNR = ITAB-MATNR+W_INITAL(1).

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT              = ITAB-MATNR
       IMPORTING
         OUTPUT             = ITAB-MATNR
       EXCEPTIONS
         LENGTH_ERROR       = 1
         OTHERS             = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      SELECT SINGLE SATNR
        INTO SATNR
        FROM MARA
        WHERE MATNR = ITAB-MATNR.
      SELECT SINGLE STDPD
        INTO STDPD
        FROM MARC
        WHERE MATNR = ITAB-MATNR AND
              WERKS = ITAB-WERKS.

      IF ITAB-MATNR+0(2) EQ 'SR' AND ( I_MATNR EQ 'I' OR I_MATNR EQ 'A').
            PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0060'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RMMG1-MATNR'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=ENTR'.
            PERFORM BDC_FIELD       USING 'RMMG1-MATNR'
                                           ITAB-MATNR.  "'KACI'.

            PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0070'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'MSICHTAUSW-DYTXT(11)'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=ENTR'.

            PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(02)'
                                            'X'.

            PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(11)'
                                            'X'.
            PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0080'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'RMMG1-LGORT'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=ENTR'.
            PERFORM BDC_FIELD       USING 'RMMG1-WERKS'
                                             ITAB-WERKS.  "'1000'.
            PERFORM BDC_FIELD       USING 'RMMG1-LGORT'
                                             ITAB-LGORT.  "'1001'.

            PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=PB21'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'MARA-SATNR'.
              IF SATNR EQ ''.
                PERFORM BDC_FIELD       USING 'MARA-SATNR'
                                               ITAB-SATNR. "'KACI'.
                PERFORM BDC_FIELD       USING 'MARA-KZKFG'
                                              'X'.
              ENDIF.
*            ENDIF.

            PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RCTMS-MNAME(01)'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=BACK'.


            PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '/00'.
*            PERFORM BDC_FIELD       USING 'MARA-KZKFG'
*                                          'X'.

              PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=PB19'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'MARC-STDPD'.
            IF STDPD EQ ''.
              PERFORM BDC_FIELD       USING 'MARC-STDPD'
                                             ITAB-STDPD.  "'KACI'.
            ENDIF.

            PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'RCTMS-MNAME(01)'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=BACK'.


            PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=BU'.
            CALL TRANSACTION 'MM02' USING BDCDATA
                                    MODE CTUMODE
                                    UPDATE 'S'
                                    MESSAGES INTO MSGS.
      ELSEIF I_MATNR = 'O'.
              PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0060'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'RMMG1-MATNR'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=ENTR'.
              PERFORM BDC_FIELD       USING 'RMMG1-MATNR'
                                             ITAB-MATNR.  "'KACI'.


              PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0070'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'MSICHTAUSW-DYTXT(11)'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=ENTR'.


              PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(02)'
                                            'X'.
              PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(14)'
                                            'X'.


              PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0080'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'RMMG1-LGORT'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=ENTR'.
              PERFORM BDC_FIELD       USING 'RMMG1-WERKS'
                                             ITAB-WERKS.  "'1000'.
              PERFORM BDC_FIELD       USING 'RMMG1-LGORT'
                                             ITAB-LGORT.  "'1001'.


                PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
                PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                              '=PB21'.
                PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                              'MARA-SATNR'.
              IF SATNR EQ ''.
                PERFORM BDC_FIELD       USING 'MARA-SATNR'
                                               ITAB-SATNR. "'KACI'.
                PERFORM BDC_FIELD       USING 'MARA-KZKFG'
                                              'X'.
              ENDIF.

              PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'RCTMS-MNAME(01)'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=BACK'.

              PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4004'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '/00'.
*              PERFORM BDC_FIELD       USING 'MARA-KZKFG'
*                                            'X'.

                PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
                PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                              '=PB19'.
                PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                              'MARC-STDPD'.
              IF STDPD EQ ''.
                PERFORM BDC_FIELD       USING 'MARC-STDPD'
                                               ITAB-STDPD.  "'KACI'.
              ENDIF.

              PERFORM BDC_DYNPRO      USING 'SAPLCEI0' '0109'.
              PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                            'RCTMS-MNAME(01)'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=BACK'.


              PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
              PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                            '=BU'.
              CALL TRANSACTION 'MM02' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
      ELSE.
        COMPLETE = 'Material is invalid'.
      ENDIF.

      IF MSGS[] IS NOT INITIAL.
        CLEAR : WA_MSGS, CTR.
        CTR = LINES( MSGS ).
        READ TABLE MSGS INDEX CTR.
        WA_MSGS = MSGS.
          IF WA_MSGS-MSGTYP NE ''.
                    CLEAR MESSAGE.
                    CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3, MESSAGE_V4, ID, NUMBER.
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

                  NOERR = NOERR + 1.
                  IT_REPORT-LINE = LINE.
                  IF WA_MSGS-MSGTYP EQ 'E'.
                    IT_REPORT-STAT = GCF_E1.
                  ELSE.
                    IT_REPORT-STAT = GCF_S1.
                  ENDIF.

            IT_REPORT-MESSAGE = MESSAGE.
            IT_REPORT-NOERR = NOERR.
            IT_REPORT-MATNR = ITAB-MATNR.
            IT_REPORT-WERKS = ITAB-WERKS.
            IT_REPORT-LGORT = ITAB-LGORT.
            IT_REPORT-SATNR = ITAB-SATNR.
            IT_REPORT-STDPD = ITAB-STDPD.
            APPEND IT_REPORT.
        ENDIF.
      ELSE.
            CLEAR MESSAGE.
            IF COMPLETE NE ''.
              MESSAGE = COMPLETE.
            ELSE.
              CONCATENATE 'Material ' ITAB-MATNR 'Changed.' INTO MESSAGE SEPARATED BY SPACE.
            ENDIF.
            IT_REPORT-LINE = LINE.
            IF COMPLETE EQ ''.
              IT_REPORT-STAT = GCF_S1.
            ELSE.
              IT_REPORT-STAT = GCF_E1.
            ENDIF.
            IT_REPORT-MESSAGE = MESSAGE.
            IT_REPORT-NOERR = NOERR.
            IT_REPORT-MATNR = ITAB-MATNR.
            IT_REPORT-WERKS = ITAB-WERKS.
            IT_REPORT-LGORT = ITAB-LGORT.
            IT_REPORT-SATNR = ITAB-SATNR.
            IT_REPORT-STDPD = ITAB-STDPD.
            APPEND IT_REPORT.
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE 'No data Uploaded' TYPE 'E'.
  ENDIF.
ENDFORM.                    " UPLOADDATA

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
*&      Form  DISPLAYREPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAYREPORT .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAYREPORT

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
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
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
        'MESSAGE' '' ''  '' ''  'Message'      '' ' ' '' '',
        'MATNR' '' ''  '' ''  'Material Number'      '' ' ' '' '',
        'WERKS' '' ''  '' ''  'Plant'      '' ' ' '' '',
        'LGORT' '' ''  '' ''  'Storage Location'      '' ' ' '' '',
        'SATNR' '' ''  '' ''  'Cross-Plant Configurable Material'      '' ' ' '' '',
        'STDPD' '' ''  '' ''  'Configurable material'      '' ' ' '' ''.
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

FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
*  DATA: LT_HUS TYPE HUM_VENUM_T.
*
*  SY-LSIND = 0.
*  CASE FU_UCOMM.
*    WHEN '&IC1'.
*      READ TABLE ITAB INDEX FU_SELFIELD-TABINDEX ASSIGNING <FS_ITEM1>.
*      CASE FU_SELFIELD-SEL_TAB_FIELD.
*        WHEN 'ITAB-EQUNR'.
*          SET PARAMETER ID 'EQN' FIELD <FS_ITEM1>-EQUNR.
*          CALL TRANSACTION 'IE03' AND SKIP FIRST SCREEN.
*      ENDCASE.
*  ENDCASE.

ENDFORM.