*&---------------------------------------------------------------------*
*& Report  ZPPC_UPLOAD_SLITROLL
*&
*----------------------------------------------------------------------*
* Description      : Upload Process Order Slitroll
*
* Application Area - PP
* ABAPer           - Anthony Wijaya
* Date             -
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
* 002 | 18.11.19 | Fathir      |            | Insert Combine Order     *
*     |          |             |            | and Batch to AGS (TTE Only)
* 003 | 03.12.19 | Fathir      |            | Insert ZZALIAS batch     *
*     |          |             |            | characteristics          *
* 004 | 04.05.21 | Fathir      |            | Insert ZZTYBCOMBINATIONNO*
*     |          |             |            | batch characteristics    *
*----------------------------------------------------------------------*

REPORT  ZPPC_UPLOAD_SLITROLL.

TABLES: AUFK.

TYPE-POOLS: ICON.

INCLUDE ZBDCREX3.

DATA: ZORDER_NUMBER LIKE BAPI_ORDER_KEY-ORDER_NUMBER,
      ZORDERDATA    TYPE BAPI_PI_ORDER_CREATE OCCURS 0 WITH HEADER LINE,
      IT_RETURN     LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
      ZRETURN       LIKE BAPIRET2,
      IT_CHAR       LIKE BAPI1003_ALLOC_VALUES_CHAR OCCURS 0 WITH HEADER LINE,
      IT_NUM       	LIKE BAPI1003_ALLOC_VALUES_NUM OCCURS 0 WITH HEADER LINE,
      IT_CURR       LIKE BAPI1003_ALLOC_VALUES_CURR OCCURS 0 WITH HEADER LINE,
      ZBATCHATTRIBUTES  LIKE  BAPIBATCHATT.

DATA: BEGIN OF IT_ORDERDATA OCCURS 0,
        ORDER_NUMBER      TYPE AUFNR,
        ID                TYPE I,
        MATERIAL          TYPE CO_MATNR,
        ORDER_TYPE        TYPE AUFART,
        PLANT             TYPE WERKS_D,
        SALES_ORDER       TYPE C LENGTH 10,
        SALES_ORDER_ITEM  TYPE C LENGTH 6,
        ZVBELN1           TYPE AUFK-ZVBELN1,
        ZPOSNR1           TYPE C LENGTH 6,
        ZVBELN2           TYPE AUFK-ZVBELN2,
        ZPOSNR2           TYPE C LENGTH 6,
        ZVBELN3           TYPE AUFK-ZVBELN3,
        ZPOSNR3           TYPE C LENGTH 6,
        QUANTITY          TYPE C LENGTH 18,
        QUANTITY_UOM      TYPE C LENGTH 3,
        BASIC_END_DATE    TYPE C LENGTH 10,
        BASIC_END_TIME    TYPE C LENGTH 6,
        PROD_VERSION      TYPE VERID,
        STORAGE_LOCATION  TYPE LGORT_D,
        KODE_FILM         TYPE C LENGTH 3,
        TREATMENT         TYPE C LENGTH 4,
        CORE              TYPE C LENGTH 1,
        WIDTH             TYPE C LENGTH 5,
        LENGTH            TYPE C LENGTH 7,
        GRADE             TYPE C LENGTH 2,
        DERIVATIVEMS      TYPE C LENGTH 2,
        POSITIONMS        TYPE C LENGTH 2,
        DERIVATIVESS      TYPE C LENGTH 2,
        POSITIONSS        TYPE C LENGTH 2,
        PACKING           TYPE C LENGTH 2,
        LABEL             TYPE C LENGTH 4,
        PACKINGCODE      TYPE C LENGTH 30,
        EXTRALENGTH       TYPE C LENGTH 30,
        PRODLINE          TYPE C LENGTH 2,  "new company
        NOLOTTOYOBO       TYPE C LENGTH 15,
        NOROLLTOYOBO      TYPE C LENGTH 18,
        CONVERTION        TYPE C LENGTH 8,
        UNLOADING_POINT   TYPE C LENGTH 25,
        ZZALIAS            TYPE C LENGTH 40, "ADDED FOR AGS BY FATHIR ON 03.12.2019 - Alias of Film Type
        ZZCOMBNO          TYPE C LENGTH 30, "ADDED FOR AGS BY FATHIR ON 04.05.2021 - Combination No
      END OF IT_ORDERDATA.

DATA: BEGIN OF IT_DISPLAY OCCURS 0.
        INCLUDE STRUCTURE BAPIRET2.
DATA:   ZORDERNUMBER LIKE BAPI_ORDER_KEY-ORDER_NUMBER,
        ZID TYPE C LENGTH 10,
        VCOMBINE LIKE AFPO-AUFNR,
        VBATCH TYPE C LENGTH 10,
        ICON   TYPE C LENGTH 4,
        MATERIAL          TYPE CO_MATNR,
        ORDER_TYPE        TYPE AUFART,
        PLANT             TYPE WERKS_D,
        SALES_ORDER       TYPE C LENGTH 10,
        SALES_ORDER_ITEM  TYPE C LENGTH 6,
        QUANTITY          TYPE GAMNG,
        QUANTITY_UOM      TYPE C LENGTH 3,
      END OF IT_DISPLAY.

"-- ADDED FOR AGS BY FATHIR ON 03.12.2019 - Variable for AGS
DATA: BEGIN OF IT_AGSPLANRESULT OCCURS 0,
        AUFNR LIKE AUFK-AUFNR,              "Order number
        CHARG LIKE MCH1-CHARG,              "Batch
       END OF IT_AGSPLANRESULT.
DATA: IT_AGSPARAM LIKE STANDARD TABLE OF IT_AGSPLANRESULT.
"-- ADDED FOR AGS BY FATHIR ON 03.12.2019 - Variable for AGS

DATA : FNAME TYPE STRING,
*       FPATH type IBIPPARMS-PATH,
       MSG_ERROR TYPE C LENGTH 250,
       IT_ORDERDATA2 LIKE IT_ORDERDATA OCCURS 0 WITH HEADER LINE,
       IT_ORDERDATA3 LIKE IT_ORDERDATA OCCURS 0 WITH HEADER LINE,
       IT_DISPLAY2 LIKE IT_DISPLAY OCCURS 0 WITH HEADER LINE,
       IT_DISPLAY3 LIKE IT_DISPLAY OCCURS 0  WITH HEADER LINE,
       VDATE TYPE C LENGTH 10,
       NUM TYPE I,
       NUMC TYPE C LENGTH 2,
       NAMAF TYPE C LENGTH 50,
       NAMAF2 TYPE C LENGTH 2,
       VBATCH TYPE C LENGTH 10,
       VCLASS LIKE  KLAH-CLASS,
       VKLART LIKE  KLAH-KLART,
       VOBTAB LIKE  TCLT-OBTAB,
       VOBJEC LIKE  KSSK-OBJEK,
       VCOMBINE LIKE AFPO-AUFNR,
       VQTY TYPE GAMNG,
       VTEXT TYPE C LENGTH 100,
       VROWS TYPE C LENGTH 10,
       VTOTROWS TYPE C LENGTH 10,
       VVQTY TYPE C LENGTH 20,
       ZAUFNR1 LIKE AUFK-AUFNR,
       ZAUFNR2 LIKE AUFK-AUFNR,
       FLAGS TYPE C LENGTH 1,
       ZFLAGS TYPE C LENGTH 50,
       VAUFNR LIKE AUFK-AUFNR,
       VCHAR TYPE C LENGTH 10,
       CHARG TYPE CHARG_D,
       ZID TYPE C LENGTH 32,
       MATNR LIKE MARA-MATNR,
       WERKS TYPE WERKS_D,
       VMSG TYPE C LENGTH 50,
       VPLANT LIKE VBAP-WERKS,   "ADD NEW COMPANY
       V_VBELN  TYPE VBEP-VBELN, "ADD NEW COMPANY
       V_POSNR  TYPE VBEP-POSNR. "ADD NEW COMPANY

DATA: GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
       G_EXIT_CAUSED_BY_CALLER,
       GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
       GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
       G_REPID LIKE SY-REPID,
       Y_PRINT TYPE SLIS_PRINT_ALV.

DATA:
      GT_EVENTS TYPE SLIS_T_EVENT,
      GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
      G_STATUS_SET TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
      G_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
      G_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
      G_TOP_OF_LIST TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST',
      G_END_OF_LIST TYPE SLIS_FORMNAME VALUE 'END_OF_LIST'.

DATA : GS_VARIANT LIKE DISVARIANT, G_SAVE.

INITIALIZATION.
  "Validasi TTA
  IF SY-TCODE EQ 'ZAPP003P'.
    SET TITLEBAR 'TTA'.
  ENDIF.

  G_REPID = SY-REPID. "call report id
  Y_PRINT-NO_PRINT_SELINFOS = 'X'.
  Y_PRINT-NO_PRINT_LISTINFOS = 'X'.
  PERFORM LAYOUT_INIT USING GS_LAYOUT. "call ALV layout for report by gs_layout
*  PERFORM EVENTTAB_BUILD USING GT_EVENTS[]. "NEW COMPANY
  GS_VARIANT-REPORT = G_REPID.
  G_SAVE = 'A'.

  SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.

  PARAMETERS: FPATH LIKE RLGRAP-FILENAME MEMORY ID PID LOWER CASE OBLIGATORY,
              X_FLD LIKE /SAPDMC/LSFSCREEN-X_FLDNAMES DEFAULT 'X'.

  SELECTION-SCREEN END OF BLOCK 1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FPATH.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_PATH         = 'C:\'
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = FPATH
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

START-OF-SELECTION.

  MOVE FPATH TO FNAME.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = IT_ORDERDATA
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
    STOP.
  ENDIF.



  IF X_FLD IS NOT INITIAL.
    DELETE IT_ORDERDATA INDEX 1.
  ENDIF.


  IT_ORDERDATA2[] = IT_ORDERDATA[].
  IT_ORDERDATA3[] = IT_ORDERDATA[].
  SORT IT_ORDERDATA ASCENDING BY ORDER_NUMBER.
  DELETE ADJACENT DUPLICATES FROM IT_ORDERDATA COMPARING ORDER_NUMBER.
  SORT IT_ORDERDATA2 ASCENDING BY ID.
  DELETE ADJACENT DUPLICATES FROM IT_ORDERDATA2 COMPARING ID.
  SORT IT_ORDERDATA3 ASCENDING BY ORDER_NUMBER POSITIONMS POSITIONSS.

  "Validasi TTA
  IF SY-TCODE EQ 'ZAPP003P'.
    PERFORM VALIDASI_TTA.
  ENDIF.

  DESCRIBE TABLE IT_ORDERDATA2 LINES VTOTROWS.

  LOOP AT IT_ORDERDATA2.

    CLEAR VTEXT.
    ADD 1 TO VROWS.
    CONCATENATE 'Retrieving record no. '  VROWS '/' VTOTROWS
              INTO VTEXT.

*Informasi data progress
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = 100
        TEXT       = VTEXT.

    LOOP AT IT_ORDERDATA WHERE ID = IT_ORDERDATA2-ID.

      PERFORM OPEN_GROUP.

      PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'CAUFVD-AUFNR'.
      IF IT_ORDERDATA-SALES_ORDER IS INITIAL.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=ENTK'.
        PERFORM BDC_FIELD       USING 'CAUFVD-MATNR'
                                      IT_ORDERDATA-MATERIAL."'SRPAKI'.
        PERFORM BDC_FIELD       USING 'CAUFVD-WERKS'
                                      IT_ORDERDATA-PLANT."'2000'.
        PERFORM BDC_FIELD       USING 'AFPOD-PWERK'
                                      IT_ORDERDATA-PLANT."'2000'.
        PERFORM BDC_FIELD       USING 'AUFPAR-PI_AUFART'
                                      IT_ORDERDATA-ORDER_TYPE."'ZPE2'.
        PERFORM BDC_FIELD       USING 'CAUFVD-AUFNR'
                                      IT_ORDERDATA-ORDER_NUMBER."'E20000004061'.
      ELSE.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=VOWE'.
        PERFORM BDC_FIELD       USING 'CAUFVD-MATNR'
                                      IT_ORDERDATA-MATERIAL."'SRPAKI'.
        PERFORM BDC_FIELD       USING 'CAUFVD-WERKS'
                                      IT_ORDERDATA-PLANT."'2000'.
        PERFORM BDC_FIELD       USING 'AFPOD-PWERK'
                                      IT_ORDERDATA-PLANT."'2000'.
        PERFORM BDC_FIELD       USING 'AUFPAR-PI_AUFART'
                                      IT_ORDERDATA-ORDER_TYPE."'ZPE2'.
        PERFORM BDC_FIELD       USING 'CAUFVD-AUFNR'
                                      IT_ORDERDATA-ORDER_NUMBER."'E20000004061'.

        PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5135'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=ENT1'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'AFPOD-KDPOS'.
        PERFORM BDC_FIELD       USING 'AFPOD-KDAUF'
                                      IT_ORDERDATA-SALES_ORDER."'274'.
        PERFORM BDC_FIELD       USING 'AFPOD-KDPOS'
                                      IT_ORDERDATA-SALES_ORDER_ITEM."'10'.

        "ADD NEW COMPANY
        CLEAR: VPLANT,V_VBELN,V_POSNR.
        PERFORM CONV_ALPHA_INPUT.
        SELECT SINGLE WERKS INTO VPLANT FROM VBAP
          WHERE VBELN = V_VBELN
          AND POSNR = V_POSNR.

        IF IT_ORDERDATA-PLANT NE VPLANT.                    " '2000'.
          PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0500'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=OPT1'.
        ENDIF.

      ENDIF.

      CLEAR: VQTY, VVQTY, ZFLAGS.
      LOOP AT IT_ORDERDATA3 WHERE ORDER_NUMBER = IT_ORDERDATA-ORDER_NUMBER.
        VQTY = VQTY + IT_ORDERDATA3-QUANTITY.
      ENDLOOP.
      MOVE VQTY TO VVQTY.
      CONDENSE VVQTY.

      CONCATENATE IT_ORDERDATA-BASIC_END_DATE+6(2) IT_ORDERDATA-BASIC_END_DATE+4(2) IT_ORDERDATA-BASIC_END_DATE+0(4) INTO VDATE SEPARATED BY '.'.
      PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=KOWE'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'CAUFVD-GSTRP'.
      PERFORM BDC_FIELD       USING 'CAUFVD-GAMNG'
                                    VVQTY."'1'.
      PERFORM BDC_FIELD       USING 'CAUFVD-GMEIN'
                                    'ROL'.
      PERFORM BDC_FIELD       USING 'CAUFVD-BMENGE'
                                    VVQTY."'1'.
      PERFORM BDC_FIELD       USING 'CAUFVD-GLTRP'
                                    VDATE."'07.11.2012'.
      PERFORM BDC_FIELD       USING 'CAUFVD-GLUZP'
                                    IT_ORDERDATA-BASIC_END_TIME."'24:00:00'.
      PERFORM BDC_FIELD       USING 'CAUFVD-GSTRP'
                                    VDATE."'07.11.2012'.
      PERFORM BDC_FIELD       USING 'CAUFVD-GSUZP'
                                    IT_ORDERDATA-BASIC_END_TIME."'00:00:00'.


      PERFORM BDC_DYNPRO      USING 'SAPLCOSD' '5132'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'MDFQ-VERID(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=AUSW'.

      PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=SLAP'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'AFPOD-LGORT'.
      PERFORM BDC_FIELD       USING 'AFPOD-UEBTK'
                                    'X'.
      PERFORM BDC_FIELD       USING 'AFPOD-LGORT'
                                    IT_ORDERDATA-STORAGE_LOCATION."'2306'.

      PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=STAK'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'CAUFVD-PLNNR'.
      PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5131'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=ENT1'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RC62F-PROD_VERS'.
*perform bdc_field       using 'RC62F-VER_SEL'
*                              'X'.
      PERFORM BDC_FIELD       USING 'RC62F-PROD_VERS'
                                    IT_ORDERDATA-PROD_VERSION."'0001'.


      PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=+COI'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'CAUFVD-PLNNR'.
      PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=BU'."'=KOMG'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'ZFILM-ZWIDTH'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZWIDTH'
                                    IT_ORDERDATA-WIDTH."'100'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZLENGTH'
                                    IT_ORDERDATA-LENGTH.    "'12000'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZVBELN1'
                                    IT_ORDERDATA-ZVBELN1."'258'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZPOSNR1'
                                    IT_ORDERDATA-ZPOSNR1."'10'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZVBELN2'
                                    IT_ORDERDATA-ZVBELN2."'259'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZPOSNR2'
                                    IT_ORDERDATA-ZPOSNR2."'10'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZVBELN3'
                                    IT_ORDERDATA-ZVBELN3."'260'.
      PERFORM BDC_FIELD       USING 'ZFILM-ZPOSNR3'
                                    IT_ORDERDATA-ZPOSNR3."'20'.

      PERFORM BDC_TRANSACTION USING 'COR1'.

      PERFORM CLOSE_GROUP.

      CLEAR: VAUFNR, FLAGS.
      SELECT SINGLE AUFK~AUFNR INTO (VAUFNR)
        FROM AUFK
        WHERE AUFK~AUFNR = IT_ORDERDATA-ORDER_NUMBER.

      IF VAUFNR IS INITIAL.

        LOOP AT MESSTAB WHERE MSGTYP = 'E' OR MSGTYP = 'I'.
          SELECT SINGLE T100~TEXT INTO (IT_DISPLAY2-MESSAGE)
            FROM T100
            WHERE T100~SPRSL = 'EN'
            AND T100~ARBGB = MESSTAB-MSGID
            AND T100~MSGNR = MESSTAB-MSGNR.
          IT_DISPLAY2-ZORDERNUMBER      = IT_ORDERDATA-ORDER_NUMBER.
          IT_DISPLAY2-ZID               = IT_ORDERDATA-ID.
          IT_DISPLAY2-ICON              = ICON_RED_LIGHT.
          IT_DISPLAY2-MATERIAL          = IT_ORDERDATA-MATERIAL.
          IT_DISPLAY2-ORDER_TYPE        = IT_ORDERDATA-ORDER_TYPE.
          IT_DISPLAY2-PLANT             = IT_ORDERDATA-PLANT.
          IT_DISPLAY2-SALES_ORDER       = IT_ORDERDATA-SALES_ORDER.
          IT_DISPLAY2-SALES_ORDER_ITEM  = IT_ORDERDATA-SALES_ORDER_ITEM.
          IT_DISPLAY2-QUANTITY          = VVQTY.
          IT_DISPLAY2-QUANTITY_UOM      = IT_ORDERDATA-QUANTITY_UOM.
          APPEND IT_DISPLAY2.
          FLAGS = 'X'.
        ENDLOOP.

      ELSE.

        LOOP AT MESSTAB WHERE MSGTYP = 'E'.
          SELECT SINGLE T100~TEXT INTO (IT_DISPLAY2-MESSAGE)
            FROM T100
            WHERE T100~SPRSL = 'EN'
            AND T100~ARBGB = MESSTAB-MSGID
            AND T100~MSGNR = MESSTAB-MSGNR.
          IT_DISPLAY2-ZORDERNUMBER      = IT_ORDERDATA-ORDER_NUMBER.
          IT_DISPLAY2-ZID               = IT_ORDERDATA-ID.
          IT_DISPLAY2-ICON              = ICON_RED_LIGHT.
          IT_DISPLAY2-MATERIAL          = IT_ORDERDATA-MATERIAL.
          IT_DISPLAY2-ORDER_TYPE        = IT_ORDERDATA-ORDER_TYPE.
          IT_DISPLAY2-PLANT             = IT_ORDERDATA-PLANT.
          IT_DISPLAY2-SALES_ORDER       = IT_ORDERDATA-SALES_ORDER.
          IT_DISPLAY2-SALES_ORDER_ITEM  = IT_ORDERDATA-SALES_ORDER_ITEM.
          IT_DISPLAY2-QUANTITY          = VVQTY.
          IT_DISPLAY2-QUANTITY_UOM      = IT_ORDERDATA-QUANTITY_UOM.
          APPEND IT_DISPLAY2.
          FLAGS = 'X'.
        ENDLOOP.

      ENDIF.


      IF FLAGS = 'X'.
        APPEND LINES OF IT_DISPLAY TO IT_DISPLAY2.
        PERFORM DISPLAY.
        LEAVE PROGRAM.
      ELSE.
        IT_DISPLAY-ZORDERNUMBER = VAUFNR.
        IT_DISPLAY-MESSAGE      = 'Process Order Created'.
        IT_DISPLAY-ICON         = ICON_GREEN_LIGHT.
        APPEND IT_DISPLAY.
      ENDIF.

    ENDLOOP.
    CLEAR: ZAUFNR1, ZAUFNR2.
    SORT IT_DISPLAY ASCENDING BY ZORDERNUMBER.
    READ TABLE IT_DISPLAY INDEX 1.
    ZAUFNR1 = IT_DISPLAY-ZORDERNUMBER.

    SORT IT_DISPLAY DESCENDING BY ZORDERNUMBER.
    READ TABLE IT_DISPLAY INDEX 1.
    ZAUFNR2 = IT_DISPLAY-ZORDERNUMBER.

    WAIT UP TO 1 SECONDS.
    PERFORM OPEN_GROUP.

    PERFORM BDC_DYNPRO      USING 'SAPLMILL_OC' '0010'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'MILL_OC_PRESELECT-WERKS'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=AUSF'.
*                                                      '=COM1'.
    PERFORM BDC_FIELD       USING 'MILL_OC_PRESELECT-WERKS'
                                  IT_ORDERDATA2-PLANT.
    PERFORM BDC_FIELD       USING 'MILL_OC_PRESELECT-SELID'
                                  IT_ORDERDATA2-ORDER_TYPE.
    PERFORM BDC_FIELD       USING 'MILL_OC_PRESELECT-AUFNR1'
                                  ZAUFNR1.
    PERFORM BDC_FIELD       USING 'MILL_OC_PRESELECT-AUFNR2'
                                  ZAUFNR2.

*              LOOP AT IT_DISPLAY WHERE ZID = IT_ORDERDATA2-ID."
*
*                        perform bdc_dynpro      using 'SAPLALDB' '3000'.
*                        perform bdc_field       using 'BDC_OKCODE'
*                                                      '=LINS'.
*                        perform bdc_field       using 'BDC_CURSOR'
*                                                      'RSCSEL_255-SLOW_I(01)'.
*                        perform bdc_field       using 'RSCSEL_255-SLOW_I(01)'
*                                                       IT_DISPLAY-ZORDERNUMBER.
*               ENDLOOP."

*                        perform bdc_dynpro      using 'SAPLALDB' '3000'."
*                        perform bdc_field       using 'BDC_OKCODE'
*                                                      '=ACPT'.
*                        perform bdc_field       using 'BDC_CURSOR'
*                                                      'RSCSEL_255-SLOW_I(01)'."
*
*                        perform bdc_dynpro      using 'SAPLMILL_OC' '0010'."
*                        perform bdc_field       using 'BDC_CURSOR'
*                                                      'MILL_OC_PRESELECT-WERKS'.
*                        perform bdc_field       using 'BDC_OKCODE'
*                                                      '=AUSF'."

*                        perform bdc_dynpro      using 'SAPLMILL_OC' '0100'.
*                        perform bdc_field       using 'BDC_CURSOR'
*                                                      'MILL_OC_ORDER_COMB_STRUC-VORLAGEAUFTR(' "&
*                                                     &'01)'.
*                        perform bdc_field       using 'BDC_OKCODE'
*                                                      '=AUSF'.
*                  NUM = 0.
*              LOOP AT IT_DISPLAY WHERE ZID = IT_ORDERDATA2-ID.
*                  NUM = NUM + 1.
*                  MOVE NUM TO NUMC.
*
*                        NAMAF = 'MILL_OC_ORDER_COMB_STRUC-MARK(0'.
*                        CONCATENATE NAMAF NUMC INTO NAMAF.
*                        CONCATENATE NAMAF ')'  INTO NAMAF.
*
*                        perform bdc_field       using NAMAF
*                                                      'X'.
*                        CLEAR NAMAF.
*              ENDLOOP.
*                        perform bdc_field       using 'MILL_OC_ORDER_COMB_STRUC-VORLAGEAUFTR(01)'
*                                                      'X'.
    PERFORM BDC_DYNPRO      USING 'SAPLMILL_OC' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'MILL_OC_ORDER_COMB_STRUC-DELBZ(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SELE'.

    PERFORM BDC_DYNPRO      USING 'SAPLMILL_OC' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'MILL_OC_ORDER_COMB_STRUC-VORLAGEAUFTR(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=AUSF'.
    PERFORM BDC_FIELD       USING 'MILL_OC_ORDER_COMB_STRUC-VORLAGEAUFTR(01)'
                                  'X'.

    PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=KOWE'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'CAUFVD-GAMNG'.

*                        perform bdc_dynpro      using 'SAPLCOKO' '0133'.
*                        perform bdc_field       using 'BDC_OKCODE'
*                                                      '=ENT1'.
*                        perform bdc_field       using 'CAUFVD-BMENGE'
*                                                      VVQTY."'100'.

*                        perform bdc_dynpro      using 'SAPLCOKO' '5115'.
*                        perform bdc_field       using 'BDC_OKCODE'
*                                                      '=KOWE'.

    PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BACK'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'AFPOD-ABLAD'.
    PERFORM BDC_FIELD       USING 'AFPOD-ABLAD'
                                   IT_ORDERDATA2-UNLOADING_POINT.

    PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0300'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=YES'.
    PERFORM BDC_TRANSACTION USING 'MILL_OC'.

    PERFORM CLOSE_GROUP.


*                                IT_CHAR-CHARACT     = 'ZZCODE'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-KODE_FILM.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZTREATMENT'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-TREATMENT.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZCORE'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-CORE.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZWIDTH'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-WIDTH.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZGRADE'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-GRADE.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZDERIVATIVEMS'.
*                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-DERIVATIVEMS.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZDERIVATIVESS'.
*                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-DERIVATIVESS.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZPACKING'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-PACKING.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZLABEL'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-LABEL.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZPACKINGCODE'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-PACKINGCODE.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZEXLENGTH'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-EXTRALENGTH.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZPRODLINE'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-PRODLINE.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZNOLOTTOYOBO'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-NOLOTTOYOBO.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZNOROLLTOYOBO'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-NOROLLTOYOBO.
*                                APPEND IT_CHAR.
*
*                                IT_CHAR-CHARACT     = 'ZZPOSITIONMS'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-POSITIONMS.
*                                APPEND IT_CHAR.
**
*                                IT_CHAR-CHARACT     = 'ZZPOSITIONSS'.
**                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA2-POSITIONSS.
*                                APPEND IT_CHAR.
*
*                                CLEAR VCOMBINE.
*                                SELECT SINGLE AFPO~AUFNR INTO (VCOMBINE)
*                                  FROM AFPO
*                                  WHERE AFPO~MILL_OC_AUFNR_U = IT_ORDERDATA2-ORDER_NUMBER.
*
**              LOOP AT IT_DISPLAY.
*                LOOP AT IT_ORDERDATA3 WHERE ID = IT_ORDERDATA2-ID." AND ORDER_NUMBER = IT_DISPLAY-ZORDERNUMBER.
*
*
*                       ZBATCHATTRIBUTES-VENDRBATCH = IT_ORDERDATA3-ORDER_NUMBER.
*                       CALL FUNCTION 'BAPI_BATCH_CREATE'
*                           EXPORTING
*                             MATERIAL             = IT_ORDERDATA3-MATERIAL
*                             PLANT                = IT_ORDERDATA3-PLANT
*                             BATCHATTRIBUTES      = ZBATCHATTRIBUTES
*                           IMPORTING
*                             BATCH                = VBATCH
*                           TABLES
*                             RETURN               = IT_RETURN.
*
*                       CALL FUNCTION 'DEQUEUE_ALL'.
*
*                       IF IT_RETURN-TYPE EQ 'E'.
*                             IT_DISPLAY2-VCOMBINE      = VCOMBINE.
*                             IT_DISPLAY2-ZORDERNUMBER  = IT_ORDERDATA3-ORDER_NUMBER.
*                             IT_DISPLAY2-VBATCH        = VBATCH.
*                             IT_DISPLAY2-MESSAGE       = IT_RETURN-MESSAGE.
*                             APPEND IT_DISPLAY2.
*                       ELSE.
*
*                        CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
*                              EXPORTING
*                                I_MATNR      = IT_ORDERDATA3-MATERIAL
*                                I_WERKS      = IT_ORDERDATA3-PLANT
*                                I_CHARG      = VBATCH
*                                I_MARA_LEVEL = 'X'
*                              IMPORTING
*                                E_CLASS      = VCLASS
*                                E_KLART      = VKLART
*                                E_OBTAB      = VOBTAB
*                                E_OBJEC      = VOBJEC.
*
*                        CALL FUNCTION 'DEQUEUE_ALL'.
*                        WAIT UP TO 1 SECONDS.
*
*                          IF VCLASS = 'ZZSRSHEET'.
*                                IT_CHAR-CHARACT     = 'ZZLENGTHSHT'.
*                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA3-LENGTH.
*                                APPEND IT_CHAR.
*                          ELSE.
*                                IT_CHAR-CHARACT     = 'ZZLENGTH'.
*                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA3-LENGTH.
*                                APPEND IT_CHAR.
*                          ENDIF.
*
*                          LOOP AT IT_CHAR.
*                              IF IT_CHAR-CHARACT     = 'ZZCODE'.
*                                IT_CHAR-VALUE_CHAR  = IT_ORDERDATA3-KODE_FILM.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZTREATMENT'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-TREATMENT.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZCORE'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-CORE.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZWIDTH'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-WIDTH.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZGRADE'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-GRADE.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZPACKING'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-PACKING.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZLABEL'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-LABEL.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZPACKINGCODE'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-PACKINGCODE.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZEXLENGTH'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-EXTRALENGTH.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZPRODLINE'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-PRODLINE.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZNOLOTTOYOBO'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA2-NOLOTTOYOBO.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZNOROLLTOYOBO'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA2-NOROLLTOYOBO.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZPOSITIONMS'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-POSITIONMS.
*                              ELSEIF IT_CHAR-CHARACT = 'ZZPOSITIONSS'.
*                                IT_CHAR-VALUE_CHAR   = IT_ORDERDATA3-POSITIONSS.
*                              ENDIF.
*                              MODIFY IT_CHAR.
*                          ENDLOOP.
*
*                          CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*                              EXPORTING
*                                OBJECTKEY          = VOBJEC
*                                OBJECTTABLE        = VOBTAB
*                                CLASSNUM           = VCLASS
*                                CLASSTYPE          = VKLART
*                              TABLES
*                                ALLOCVALUESNUMNEW  = IT_NUM
*                                ALLOCVALUESCHARNEW = IT_CHAR
*                                ALLOCVALUESCURRNEW = IT_CURR
*                                RETURN             = IT_RETURN.
*
*                            CALL FUNCTION 'DEQUEUE_ALL'.
*                             READ TABLE IT_RETURN INDEX 1.
*                             IT_DISPLAY2-VCOMBINE          = VCOMBINE.
*                             IT_DISPLAY2-ZORDERNUMBER      = IT_ORDERDATA3-ORDER_NUMBER.
*                             IT_DISPLAY2-VBATCH            = VBATCH.
*                             IT_DISPLAY2-MESSAGE           = IT_RETURN-MESSAGE.
*                             IT_DISPLAY2-MATERIAL          = IT_ORDERDATA3-MATERIAL.
*                             IT_DISPLAY2-ORDER_TYPE        = IT_ORDERDATA3-ORDER_TYPE.
*                             IT_DISPLAY2-PLANT             = IT_ORDERDATA3-PLANT.
*                             IT_DISPLAY2-SALES_ORDER       = IT_ORDERDATA3-SALES_ORDER.
*                             IT_DISPLAY2-SALES_ORDER_ITEM  = IT_ORDERDATA3-SALES_ORDER_ITEM.
*                             IT_DISPLAY2-QUANTITY          = IT_ORDERDATA3-QUANTITY.
*                             IT_DISPLAY2-QUANTITY_UOM      = IT_ORDERDATA3-QUANTITY_UOM.
*                           IF IT_RETURN-TYPE EQ 'S'.
*                             IT_DISPLAY2-ICON              = ICON_GREEN_LIGHT.
*                           ELSE.
*                             IT_DISPLAY2-ICON              = ICON_RED_LIGHT.
*                           ENDIF.
*                             APPEND IT_DISPLAY2.
*
*
*                             CLEAR IT_RETURN. REFRESH IT_RETURN.
*
*
*                          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                               EXPORTING
*                                 WAIT          = 'X'.
*                        ENDIF.
*                 ENDLOOP.
**               ENDLOOP.

    CLEAR VCOMBINE.
    SELECT SINGLE AFPO~AUFNR INTO (VCOMBINE)
      FROM AFPO
      WHERE AFPO~MILL_OC_AUFNR_U = IT_ORDERDATA2-ORDER_NUMBER.

    IF VCOMBINE IS INITIAL. "VALIDATION (COMBINE ORDER ERROR = LEAVE PROGRAM)

      CONCATENATE ZAUFNR1 ZAUFNR2 'Combine order FAILED' INTO IT_DISPLAY-MESSAGE.
      APPEND LINES OF IT_DISPLAY TO IT_DISPLAY2.
      PERFORM DISPLAY.
      LEAVE PROGRAM.

    ELSEIF VCOMBINE IS NOT INITIAL.

      LOOP AT IT_ORDERDATA3 WHERE ID = IT_ORDERDATA2-ID.

        CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
          EXPORTING
            I_MATNR      = IT_ORDERDATA3-MATERIAL
            I_WERKS      = IT_ORDERDATA3-PLANT
            I_MARA_LEVEL = 'X'
          IMPORTING
            E_CLASS      = VCLASS
            E_KLART      = VKLART
            E_OBTAB      = VOBTAB
            E_OBJEC      = VOBJEC.

        CLEAR: VCHAR.
        IF VCLASS = 'ZZSRSHEET'.
          VCHAR     = 'ZZLENGTHSHT'.
        ELSE.
          VCHAR     = 'ZZLENGTH'.
        ENDIF.


        CONCATENATE IT_ORDERDATA3-MATERIAL IT_ORDERDATA3-PLANT INTO VMSG SEPARATED BY '-'.
        SET PARAMETER ID 'ZBAP1' FIELD VMSG.

        PERFORM OPEN_GROUP.

        PERFORM BDC_DYNPRO      USING 'SAPMM03S' '0105'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'RM03S-CHARG'.
        PERFORM BDC_FIELD       USING 'RM03S-MATNR'
                                      IT_ORDERDATA3-MATERIAL."'SRPAKI'.
        PERFORM BDC_FIELD       USING 'RM03S-CHARG'
                                      ''.
        PERFORM BDC_FIELD       USING 'RM03S-WERKS'
                                      IT_ORDERDATA3-PLANT."'2000'.
        PERFORM BDC_FIELD       USING 'RM03S-LGORT'
                                      ''.
        PERFORM BDC_DYNPRO      USING 'SAPMM03S' '0200'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'MCHA-LICHA'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=CLAS'.
        PERFORM BDC_FIELD       USING 'RM03S-FZUST'
                                      'X'.
        PERFORM BDC_FIELD       USING 'MCHA-LICHA'
                                      IT_ORDERDATA3-ORDER_NUMBER."'P123456789'.
        PERFORM BDC_FIELD       USING 'RM03S-CHKLJ'
                                      'X'.
        PERFORM BDC_FIELD       USING 'RM03S-SPRAS'
                                      'EN'.

        PERFORM BDC_DYNPRO      USING 'SAPLCTMS' '0109'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'RCTMS-MWERT(10)'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'
                                      'ZZCODE'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(02)'
                                      'ZZTREATMENT'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(03)'
                                      'ZZCORE'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(04)'
                                      'ZZWIDTH'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(05)'
                                      'ZZGRADE'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(06)'
                                      'ZZDERIVATIVEMS'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(07)'
                                      'ZZDERIVATIVESS'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(08)'
                                      'ZZPACKING'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(09)'
                                      'ZZLABEL'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(10)'
                                      'ZZPACKINGCODE'.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                      IT_ORDERDATA3-KODE_FILM.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'
                                      IT_ORDERDATA3-TREATMENT.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(03)'
                                      IT_ORDERDATA3-CORE.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(04)'
                                      IT_ORDERDATA3-WIDTH.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(05)'
                                      IT_ORDERDATA3-GRADE.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(06)'
                                      IT_ORDERDATA3-DERIVATIVEMS.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(07)'
                                      IT_ORDERDATA3-DERIVATIVESS.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(08)'
                                      IT_ORDERDATA3-PACKING.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(09)'
                                      IT_ORDERDATA3-LABEL.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(10)'
                                      IT_ORDERDATA3-PACKINGCODE.

        PERFORM BDC_DYNPRO      USING 'SAPLCTMS' '0109'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'RCTMS-MWERT(06)'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=BACK'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'
                                      'ZZEXLENGTH'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(02)'
                                      'ZZPRODLINE'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(03)'
                                      'ZZNOLOTTOYOBO'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(04)'
                                      'ZZNOROLLTOYOBO'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(05)'
                                      'ZZPOSITIONMS'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(06)'
                                      'ZZPOSITIONSS'.
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(07)'
                                       VCHAR.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                      IT_ORDERDATA3-EXTRALENGTH.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'
                                      IT_ORDERDATA3-PRODLINE.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(03)'
                                      IT_ORDERDATA3-NOLOTTOYOBO.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(04)'
                                      IT_ORDERDATA3-NOROLLTOYOBO.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(05)'
                                      IT_ORDERDATA3-POSITIONMS.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(06)'
                                      IT_ORDERDATA3-POSITIONSS.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(07)'
                                      IT_ORDERDATA3-LENGTH.

        "-- ADDED FOR AGS BY FATHIR ON 03.12.2019 - Create ZZALIAS characteristic
        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(08)'
                                      'ZZALIAS'.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(08)'
                                      IT_ORDERDATA3-ZZALIAS.
        "-- ADDED FOR AGS BY FATHIR ON 03.12.2019 - Create ZZALIAS characteristic

        PERFORM BDC_FIELD       USING 'RCTMS-MNAME(09)' "ADDED FOR AGS BY FATHIR ON 04.05.2021 - Start of - Combination No
                                      'ZZTYBCOMBINATIONNO'.
        PERFORM BDC_FIELD       USING 'RCTMS-MWERT(09)'
                                      IT_ORDERDATA3-ZZCOMBNO. "ADDED FOR AGS BY FATHIR ON 04.05.2021 - End of - Combination No

*                perform bdc_dynpro      using 'SAPLCTMS' '0109'.
*                perform bdc_field       using 'BDC_OKCODE'
*                                              '/EEOT'.
*                perform bdc_field       using 'BDC_CURSOR'
*                                              'RCTMS-MNAME(01)'.
        PERFORM BDC_DYNPRO      USING 'SAPMM03S' '0200'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'RM03S-CHARG'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=BU'.
        PERFORM BDC_FIELD       USING 'RM03S-FZUST'
                                      'X'.
*                perform bdc_field       using 'MCHA-LICHA'
*                                              'P123456789'.
        PERFORM BDC_FIELD       USING 'RM03S-CHKLJ'
                                      'X'.
        PERFORM BDC_TRANSACTION USING 'MSC1'.

        PERFORM CLOSE_GROUP.

        LOOP AT MESSTAB WHERE MSGTYP = 'E'.
          SELECT SINGLE T100~TEXT INTO (IT_DISPLAY2-MESSAGE)
            FROM T100
            WHERE T100~SPRSL = 'EN'
            AND T100~ARBGB = MESSTAB-MSGID
            AND T100~MSGNR = MESSTAB-MSGNR.
          IT_DISPLAY2-ZORDERNUMBER      = IT_ORDERDATA3-ORDER_NUMBER.
          IT_DISPLAY2-ICON              = ICON_RED_LIGHT.
          IT_DISPLAY2-MATERIAL          = IT_ORDERDATA3-MATERIAL.
          IT_DISPLAY2-ORDER_TYPE        = IT_ORDERDATA3-ORDER_TYPE.
          IT_DISPLAY2-PLANT             = IT_ORDERDATA3-PLANT.
          IT_DISPLAY2-SALES_ORDER       = IT_ORDERDATA3-SALES_ORDER.
          IT_DISPLAY2-SALES_ORDER_ITEM  = IT_ORDERDATA3-SALES_ORDER_ITEM.
          IT_DISPLAY2-QUANTITY          = IT_ORDERDATA3-QUANTITY.
          IT_DISPLAY2-QUANTITY_UOM      = IT_ORDERDATA-QUANTITY_UOM.
          APPEND IT_DISPLAY2.
          FLAGS = 'X'.
        ENDLOOP.


        IF FLAGS IS INITIAL.
          GET PARAMETER ID 'ZBAP2' FIELD ZID.
          SPLIT ZID AT '-' INTO CHARG MATNR WERKS.
          IT_DISPLAY2-VCOMBINE          = VCOMBINE.
          IT_DISPLAY2-ZORDERNUMBER      = IT_ORDERDATA3-ORDER_NUMBER.
          IT_DISPLAY2-VBATCH            = CHARG.
          IT_DISPLAY2-MESSAGE           = 'Saving changes to assignments'.
          IT_DISPLAY2-MATERIAL          = IT_ORDERDATA3-MATERIAL.
          IT_DISPLAY2-ORDER_TYPE        = IT_ORDERDATA3-ORDER_TYPE.
          IT_DISPLAY2-PLANT             = IT_ORDERDATA3-PLANT.
          IT_DISPLAY2-SALES_ORDER       = IT_ORDERDATA3-SALES_ORDER.
          IT_DISPLAY2-SALES_ORDER_ITEM  = IT_ORDERDATA3-SALES_ORDER_ITEM.
          IT_DISPLAY2-QUANTITY          = IT_ORDERDATA3-QUANTITY.
          IT_DISPLAY2-QUANTITY_UOM      = IT_ORDERDATA3-QUANTITY_UOM.
          IT_DISPLAY2-ICON              = ICON_GREEN_LIGHT.
          APPEND IT_DISPLAY2.

        ENDIF.
      ENDLOOP.

    ENDIF.
    CLEAR IT_DISPLAY. REFRESH IT_DISPLAY.
  ENDLOOP.

  "-- ADDED FOR AGS BY FATHIR ON 25.11.2019 - Insert SR Plan Result to AGS SQL
  REFRESH IT_AGSPLANRESULT.
  IF WERKS = 'TTE'.
    CLEAR IT_DISPLAY2.
    LOOP AT IT_DISPLAY2 WHERE ICON = ICON_GREEN_LIGHT.
      IF IT_DISPLAY2-VCOMBINE IS NOT INITIAL
         AND IT_DISPLAY2-VBATCH IS NOT INITIAL.

        CLEAR IT_AGSPLANRESULT.
        IT_AGSPLANRESULT-AUFNR = IT_DISPLAY2-VCOMBINE.
        IT_AGSPLANRESULT-CHARG = IT_DISPLAY2-VBATCH.
        APPEND IT_AGSPLANRESULT.

      ENDIF.
    ENDLOOP.

    PERFORM F_INSERTAGS_SQL TABLES IT_AGSPLANRESULT.
  ENDIF.
  "-- ADDED FOR AGS BY FATHIR ON 25.11.2019 - Insert SR Plan Result to AGS SQL

  CALL FUNCTION 'DEQUEUE_ALL'.
  PERFORM DISPLAY.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY.
*tambahan untuk ALV
  PERFORM BUILD_FIELDCATALOG.
*perform comment_build using gt_list_top_of_page[]. "NEW COMPANY

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = G_REPID
      IS_LAYOUT          = GS_LAYOUT
      IT_FIELDCAT        = GT_FIELDCAT[]
      IS_PRINT           = Y_PRINT
      I_SAVE             = G_SAVE
      IS_VARIANT         = GS_VARIANT
      IT_EVENTS          = GT_EVENTS[]
    TABLES
      T_OUTTAB           = IT_DISPLAY2
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

  IF SY-SUBRC <> 0.
*  message 'Sorry, Report cannot be generated' type i.
  ENDIF.
ENDFORM.                    "DISPLAY

*&---------------------------------------------------------------------*
*&      Form  build_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCATALOG.
  DATA: XFIELDCAT TYPE SLIS_FIELDCAT_ALV,
        N TYPE I.

  REFRESH GT_FIELDCAT.
  N = 0.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'VCOMBINE'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Combine Order'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  XFIELDCAT-FIX_COLUMN = 'X'.
  XFIELDCAT-EMPHASIZE = 'C110'.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'ZORDERNUMBER'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Order Number'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  XFIELDCAT-FIX_COLUMN = 'X'.
  XFIELDCAT-EMPHASIZE = 'C110'.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'VBATCH'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Batch Number'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.


  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'MATERIAL'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Material'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'ORDER_TYPE'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Order Type'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'PLANT'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Plant'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'SALES_ORDER'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'SO Number'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'SALES_ORDER_ITEM'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'SO Item'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'QUANTITY'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Quantity'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'QUANTITY_UOM'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'UoM'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'MESSAGE'.
  XFIELDCAT-SELTEXT_M = 'Message'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'ICON'.
  XFIELDCAT-SELTEXT_M = 'Indicator'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

ENDFORM. "build_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM LAYOUT_INIT USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
  RS_LAYOUT-DETAIL_POPUP = 'X'.
  RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  RS_LAYOUT-ZEBRA             = 'X'.
ENDFORM.            "Layout_init

*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EVENTS  text
*----------------------------------------------------------------------*
FORM EVENTTAB_BUILD USING RT_EVENTS TYPE SLIS_T_EVENT.
  DATA : LS_EVENT TYPE SLIS_ALV_EVENT.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = RT_EVENTS.

  READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                            INTO LS_EVENT.

  IF SY-SUBRC = 0.
    MOVE G_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO RT_EVENTS.
  ENDIF.
ENDFORM.              "eventtab_build

*&---------------------------------------------------------------------*
*&      Form  comment_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.

  CLEAR LS_LINE.
  REFRESH LT_TOP_OF_PAGE.
  LS_LINE-TYP = 'H'.
  LS_LINE-INFO = 'PT.Trias Sentosa, Tbk.'.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.
  CLEAR LS_LINE.
  LS_LINE-TYP = 'A'.
  LS_LINE-INFO = 'Report Upload Process Order Slitroll'.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.
ENDFORM.                    "comment_build

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      I_LOGO             = ' '
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
ENDFORM.                    "top_of_page

*&---------------------------------------------------------------------*
*&      Form  CONV_ALPHA_OUTPUT
*&---------------------------------------------------------------------*
*       text New Company
*----------------------------------------------------------------------*
FORM CONV_ALPHA_INPUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = IT_ORDERDATA-SALES_ORDER
    IMPORTING
      OUTPUT = V_VBELN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = IT_ORDERDATA-SALES_ORDER_ITEM
    IMPORTING
      OUTPUT = V_POSNR.
ENDFORM.                    "CONV_ALPHA_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_INSERTAGS_SQL
*&---------------------------------------------------------------------*
*       Insert planned SR data to AGS SQL database
*
*       ADDED FOR AGS BY FATHIR ON 25.11.2019
*----------------------------------------------------------------------*
*      -->PIN_CHARG  text
*      -->PIN_AUFNR  text
*----------------------------------------------------------------------*
FORM F_INSERTAGS_SQL
  TABLES PIN_PLANRESULT LIKE IT_AGSPARAM.

  RANGES: R_CHARG FOR MCHB-CHARG,
          R_AUFNR FOR AUFK-AUFNR.
  REFRESH: R_CHARG,
           R_AUFNR.
  CLEAR: R_CHARG,
         R_AUFNR.

  IF PIN_PLANRESULT[] IS NOT INITIAL.

    LOOP AT PIN_PLANRESULT.

      CLEAR R_CHARG.
      R_CHARG-SIGN = 'I'.
      R_CHARG-OPTION = 'EQ'.
      R_CHARG-LOW = PIN_PLANRESULT-CHARG.
      APPEND R_CHARG.

      CLEAR R_AUFNR.
      R_AUFNR-SIGN = 'I'.
      R_AUFNR-OPTION = 'EQ'.
      R_AUFNR-LOW = PIN_PLANRESULT-AUFNR.
      APPEND R_AUFNR.

    ENDLOOP.

    SUBMIT ZTPPI_PLANNINGDATA_AGS
      WITH S_CHARG IN R_CHARG
      WITH S_AUFNR IN R_AUFNR
      AND RETURN.

  ENDIF.

ENDFORM.                    "F_INSERTAGS_SQL

*&---------------------------------------------------------------------*
*&      Form  VALIDASI_TTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALIDASI_TTA.
  DATA: BEGIN OF IT_DUPLICATE OCCURS 0,
        MESS           TYPE CHAR255,
        AUFNR          TYPE AUFNR,
        CHARG          TYPE CHARG_D,
        ATWRT          TYPE ATWRT,
        LICHA          TYPE LICHN,
        END OF IT_DUPLICATE.

  DATA: V_ZZNOROLLTOYOBO TYPE ATINN,
        V_CHARG          TYPE CHARG_D,
        V_ATWRT          TYPE ATWRT,
        V_LICHA          TYPE LICHN,
        V_ANSWER,
        V_MESS TYPE C LENGTH 150.

  DATA: GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
        GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
        LS_SELFIELD TYPE SLIS_SELFIELD,
        IT_EXCLUDING TYPE SLIS_T_EXTAB WITH HEADER LINE,
        IT_CHECK LIKE IT_ORDERDATA OCCURS 0 WITH HEADER LINE,
        IT_DUPLICATE2 LIKE IT_DUPLICATE OCCURS 0 WITH HEADER LINE.

  CLEAR: IT_DUPLICATE, IT_DUPLICATE2, IT_CHECK, V_ANSWER, V_MESS, V_CHARG, V_ATWRT.
  REFRESH: IT_DUPLICATE, IT_DUPLICATE2, IT_CHECK.

  SELECT SINGLE ATINN INTO V_ZZNOROLLTOYOBO FROM CABN WHERE ATNAM EQ 'ZZNOROLLTOYOBO'.

  LOOP AT IT_ORDERDATA.
    CLEAR: V_CHARG, V_ATWRT, V_LICHA.

    SELECT SINGLE CHARG ATWRT LICHA
     INTO (V_CHARG, V_ATWRT, V_LICHA)
     FROM MCH1
     JOIN AUSP ON AUSP~OBJEK EQ MCH1~CUOBJ_BM
    WHERE AUSP~ATWRT = IT_ORDERDATA-NOROLLTOYOBO
      AND MCH1~FVDT1 = '00000000'
      AND AUSP~KLART = '023'
      AND AUSP~MAFID = 'O'
      AND AUSP~ATINN = V_ZZNOROLLTOYOBO.

    IF V_CHARG IS NOT INITIAL.
      IT_DUPLICATE-AUFNR = IT_ORDERDATA-ORDER_NUMBER.
      IT_DUPLICATE-CHARG = V_CHARG.
      IT_DUPLICATE-ATWRT = V_ATWRT.
      IT_DUPLICATE-LICHA = V_LICHA.
      APPEND IT_DUPLICATE.
      CLEAR IT_DUPLICATE.
    ENDIF.
  ENDLOOP.


  LOOP AT IT_DUPLICATE.
    CONCATENATE 'No Roll Toyobo' IT_DUPLICATE-ATWRT 'telah digunakan pada Order:' IT_DUPLICATE-LICHA 'dan Batch:' IT_DUPLICATE-CHARG INTO IT_DUPLICATE-MESS SEPARATED BY SPACE.

    MODIFY IT_DUPLICATE.
    CLEAR IT_DUPLICATE.
  ENDLOOP.

  IT_CHECK[] = IT_ORDERDATA[].

  LOOP AT IT_ORDERDATA.
    LOOP AT IT_CHECK WHERE NOROLLTOYOBO EQ IT_ORDERDATA-NOROLLTOYOBO AND ORDER_NUMBER NE IT_ORDERDATA-ORDER_NUMBER.
      CONCATENATE 'No Roll Toyobo' IT_ORDERDATA-NOROLLTOYOBO 'telah digunakan pada Order:' IT_CHECK-ORDER_NUMBER INTO IT_DUPLICATE2-MESS SEPARATED BY SPACE.

      IT_DUPLICATE2-AUFNR = IT_ORDERDATA-ORDER_NUMBER.
      IT_DUPLICATE2-ATWRT = IT_ORDERDATA-NOROLLTOYOBO.

      APPEND IT_DUPLICATE2.
      CLEAR IT_DUPLICATE2.

      IF IT_CHECK-ORDER_NUMBER NE IT_ORDERDATA-ORDER_NUMBER.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  APPEND LINES OF IT_DUPLICATE2 TO IT_DUPLICATE.

  IF IT_DUPLICATE[] IS NOT INITIAL.
    IT_DUPLICATE-MESS = ''.
    APPEND IT_DUPLICATE.
    CLEAR IT_DUPLICATE.

    IT_DUPLICATE-MESS = 'Tetap dilanjutkan...?'.
    APPEND IT_DUPLICATE.
    CLEAR IT_DUPLICATE.

    CLEAR: GS_FIELDCAT, GT_FIELDCAT, LS_SELFIELD, IT_EXCLUDING.
    REFRESH: GT_FIELDCAT, IT_EXCLUDING.

    GS_FIELDCAT-FIELDNAME = 'MESS'.
    GS_FIELDCAT-SELTEXT_M = 'Message'.
    GS_FIELDCAT-OUTPUTLEN = 98.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    APPEND '&OUP'  TO IT_EXCLUDING.
    APPEND '&ODN'  TO IT_EXCLUDING.
    APPEND '&OL0'  TO IT_EXCLUDING.
    APPEND '&ILT'  TO IT_EXCLUDING.
    APPEND '%SC'   TO IT_EXCLUDING.
    APPEND '%SC+'  TO IT_EXCLUDING.
    APPEND '&ETA'  TO IT_EXCLUDING.

    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        I_TITLE                 = 'Warning...!'
        I_SELECTION             = 'X'
        I_ALLOW_NO_SELECTION    = 'X'
        I_ZEBRA                 = ''
        I_SCREEN_START_COLUMN   = 30
        I_SCREEN_START_LINE     = 5
        I_SCREEN_END_COLUMN     = 130
        I_SCREEN_END_LINE       = 11
        IT_FIELDCAT             = GT_FIELDCAT
        I_TABNAME               = 'A'
        IT_EXCLUDING            = IT_EXCLUDING[]
        I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      IMPORTING
        ES_SELFIELD             = LS_SELFIELD
      TABLES
        T_OUTTAB                = IT_DUPLICATE
      EXCEPTIONS
        PROGRAM_ERROR           = 1
        OTHERS                  = 2.

    IF SY-XCODE EQ '&AC1'.
      LOOP AT IT_ORDERDATA.
        READ TABLE IT_DUPLICATE WITH KEY AUFNR = IT_ORDERDATA-ORDER_NUMBER.
        IF SY-SUBRC EQ 0.
          IT_DISPLAY2-MESSAGE       = IT_DUPLICATE-MESS.
        ELSE.
          IT_DISPLAY2-MESSAGE       = 'Action cancelled by user'.
        ENDIF.

        IT_DISPLAY2-ZORDERNUMBER  = IT_ORDERDATA-ORDER_NUMBER.
        IT_DISPLAY2-MATERIAL      = IT_ORDERDATA-MATERIAL.
        IT_DISPLAY2-ORDER_TYPE    = IT_ORDERDATA-ORDER_TYPE.
        IT_DISPLAY2-PLANT         = IT_ORDERDATA-PLANT.
        IT_DISPLAY2-QUANTITY      = IT_ORDERDATA-QUANTITY.
        IT_DISPLAY2-QUANTITY_UOM  = IT_ORDERDATA-QUANTITY_UOM.
        IT_DISPLAY2-ICON          = ICON_RED_LIGHT.

        APPEND IT_DISPLAY2.
      ENDLOOP.

      PERFORM DISPLAY.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
ENDFORM.                    "VALIDASI_TTA