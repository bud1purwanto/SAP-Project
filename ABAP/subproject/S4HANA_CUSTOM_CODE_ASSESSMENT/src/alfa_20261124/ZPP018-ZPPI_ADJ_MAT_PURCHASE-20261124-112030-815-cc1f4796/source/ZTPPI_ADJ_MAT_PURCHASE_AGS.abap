*&---------------------------------------------------------------------*
*& Report  ZTPPI_ADJ_MAT_PURCHASE_AGS
*&
*& Description      : Insert / Download result of Adjustment Material Purchase
*&
*& Program Structure: - Variable Definition
*&                    - Screen Definition
*&                    - Logical Runtime
*&                    - Function Definition
*&                    - Open SQL Function
*&
*& Application Area - PP
*& ABAPer           - Fathir Qisthi
*& Date             - July 29, 2019
*&---------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | 29.07.19 | Fathir      |            | Program Created          *
* 002 | 02.08.19 | Fathir      |            | Call function to check server
* 003 | 28.08.19 | Fathir      |            | Add SAP-AGS SQL Logging mechanism
*----------------------------------------------------------------------*

REPORT  ZTPPI_ADJ_MAT_PURCHASE_AGS.
INCLUDE ZINCL_AGS_SQL.

TABLES: MKPF, MCH1, AUFK.

TYPES: BEGIN OF T_AGSMKPF,
        MBLNR LIKE MKPF-MBLNR, "Material Document
        MJAHR LIKE MKPF-MJAHR, "Material Doc. Year
        BLDAT LIKE MKPF-BLDAT, "Document Date
        BUDAT LIKE MKPF-BUDAT, "Posting Date
        CPUDT LIKE MKPF-CPUDT, "Entry Date
        CPUTM LIKE MKPF-CPUTM, "time of entry
        AEDAT LIKE MKPF-AEDAT, "changed on
        USNAM LIKE MKPF-USNAM, "Username
        XBLNR LIKE MKPF-XBLNR, "Reference
        BKTXT LIKE MKPF-BKTXT, "Document Header Text
        XABLN LIKE MKPF-XABLN, "Goods Receipt/Issue Slip
      END OF T_AGSMKPF.

TYPES: BEGIN OF T_AGSMSEG,
        MBLNR LIKE MSEG-MBLNR, "Material Document
        MJAHR LIKE MSEG-MJAHR, "Material Doc. Year
        ZEILE LIKE MSEG-ZEILE, "Material Doc.Item
        BWART LIKE MSEG-BWART, "Movement Type
        MATNR LIKE MSEG-MATNR, "Material
        WERKS LIKE MSEG-WERKS, "Plant
        LGORT LIKE MSEG-LGORT, "Storage Location
        CHARG LIKE MSEG-CHARG, "Batch
        KDAUF LIKE MSEG-KDAUF, "Sales Order
        KDPOS LIKE MSEG-KDPOS, "Sales Order Item
        SHKZG LIKE MSEG-SHKZG, "Debit/Credit Ind.
        MENGE LIKE MSEG-MENGE, "Quantity
        SMBLN LIKE MSEG-SMBLN, "Material Document
        SMBLP LIKE MSEG-SMBLP, "Material Doc.Item
        SGTXT LIKE MSEG-SGTXT, "Text
        ABLAD LIKE MSEG-ABLAD, "Unloading Point
        AUFNR LIKE MSEG-AUFNR, "Order
        BUDAT_MKPF LIKE MSEG-BUDAT_MKPF, "Posting Date
        CPUDT_MKPF LIKE MSEG-CPUDT_MKPF, "Entry Date
        CPUTM_MKPF LIKE MSEG-CPUTM_MKPF, "Time of Entry
        USNAM_MKPF LIKE MSEG-USNAM_MKPF, "User name
        XBLNR_MKPF LIKE MSEG-XBLNR_MKPF, "Reference
        ISDZ LIKE AFRU-ISDZ, "Start time
        IEDZ LIKE AFRU-IEDZ, "Finish time
        WINDERINFO TYPE C LENGTH 40,  "Winder info
        BKTXT LIKE MKPF-BKTXT, "Number Roll (for testing purpose only)
      END OF T_AGSMSEG.

TYPES: BEGIN OF T_AGSMCH1,
        MATNR LIKE MCH1-MATNR, "Material
        CHARG LIKE MCH1-CHARG, "Batch
        LVORM LIKE MCH1-LVORM, "Batch Deletion Flag
        ERSDA LIKE MCH1-ERSDA, "Created On
        ERNAM LIKE MCH1-ERNAM, "Created by
        AENAM LIKE MCH1-AENAM, "Changed by
        LAEDA LIKE MCH1-LAEDA, "Last Change
        LICHA LIKE MCH1-LICHA, "Vendor Batch
        LWEDT LIKE MCH1-LWEDT, "Last goods receipt
      END OF T_AGSMCH1.

TYPES: BEGIN OF T_AGSMCHB,
        MATNR LIKE MCHB-MATNR, "Material
        WERKS LIKE MCHB-WERKS, "Plant
        LGORT LIKE MCHB-LGORT, "Storage Location
        CHARG LIKE MCHB-CHARG, "Batch
        LVORM LIKE MCHB-LVORM, "Deletion Flag Batch Stock
        ERSDA LIKE MCHB-ERSDA, "Created On
        ERNAM LIKE MCHB-ERNAM, "Created by
        LAEDA LIKE MCHB-LAEDA, "Last Change
        AENAM LIKE MCHB-AENAM, "Changed by
        CLABS LIKE MCHB-CLABS, "Unrestricted
        CUMLM LIKE MCHB-CUMLM, "Stock in transfer
        CINSM LIKE MCHB-CINSM, "In Quality Insp.
        CEINM LIKE MCHB-CEINM, "Restricted-Use Stock
        CSPEM LIKE MCHB-CSPEM, "Blocked
        CRETM LIKE MCHB-CRETM, "Returns
      END OF T_AGSMCHB.

TYPES: BEGIN OF T_AGSAUSP,
        CHARG LIKE MCH1-CHARG,
        ATNAM LIKE CABN-ATNAM,
        ATWRT LIKE CAWN-ATWRT,
        ATFLV LIKE CAWN-ATFLV,
      END OF T_AGSAUSP.

TYPES: BEGIN OF T_AGSAUFK,
        AUFNR LIKE AUFK-AUFNR, "Order
        AUART LIKE AUFK-AUART, "OrderType
        ERNAM LIKE AUFK-ERNAM, "Enteredby
        ERDAT LIKE AUFK-ERDAT, "Createdon
        AENAM LIKE AUFK-AENAM, "LastChangedby
        AEDAT LIKE AUFK-AEDAT, "ChangeDateforOrderMaster
        KTEXT LIKE AUFK-KTEXT, "Description
        LTEXT LIKE AUFK-LTEXT, "LongTextExists
        WERKS LIKE AUFK-WERKS, "Plant
        OBJNR LIKE AUFK-OBJNR, "ObjectNumber
        KDAUF LIKE AUFK-KDAUF, "SalesOrder
        KDPOS LIKE AUFK-KDPOS, "SalesOrderItem
        ZCODE LIKE AUFK-ZCODE, "FilmCode
        ZLENGTH LIKE AUFK-ZLENGTH, "Length
        ZWIDTH LIKE AUFK-ZWIDTH, "Width
        ZTREAT LIKE AUFK-ZTREAT, "Treatment
        ZCUSTM LIKE AUFK-ZCUSTM, "Customer
        ZMONTH LIKE AUFK-ZMONTH, "MonthYearofProduction
        ZVBELN1 LIKE AUFK-ZVBELN1, "SOforOverProduction1
        ZPOSNR1 LIKE AUFK-ZPOSNR1, "ItemforOverProduction1
        ZVBELN2 LIKE AUFK-ZVBELN2, "SOforOverProduction2
        ZPOSNR2 LIKE AUFK-ZPOSNR2, "ItemforOverProduction2
        ZVBELN3 LIKE AUFK-ZVBELN3, "SOfor2ndGrade
        ZPOSNR3 LIKE AUFK-ZPOSNR3, "Itemfor2ndGrade
      END OF T_AGSAUFK.

TYPES: BEGIN OF T_AGSAFKO ,
        AUFNR LIKE AFKO-AUFNR, "Order
        GLTRP LIKE AFKO-GLTRP, "BasicFinishDate
        GSTRP LIKE AFKO-GSTRP, "BasicStartDate
        FTRMS LIKE AFKO-FTRMS, "ScheduledReleaseDate
        GLTRS LIKE AFKO-GLTRS, "ScheduledFinish
        GSTRS LIKE AFKO-GSTRS, "ScheduledStart
        GASMG LIKE AFKO-GASMG, "TotalScrapQuantityintheOrder
        GAMNG LIKE AFKO-GAMNG, "TotalOrderQuantity
        GMEIN LIKE AFKO-GMEIN, "BaseUnitofMeasure
        PLNBEZ LIKE AFKO-PLNBEZ, "Material
        SBMNG LIKE AFKO-SBMNG, "BaseQuantity
        SBMEH LIKE AFKO-SBMEH, "BaseUnitofMeasure
        SLSVN LIKE AFKO-SLSVN, "FromLotSize
        SLSBS LIKE AFKO-SLSBS, "ToLotSize
        RUECK LIKE AFKO-RUECK, "Confirmation
        LKNOT LIKE AFKO-LKNOT, "LeftNode
        RKNOT LIKE AFKO-RKNOT, "RightNode
        GLUZP LIKE AFKO-GLUZP, "BasicFinishTime
      END OF T_AGSAFKO.

TYPES: BEGIN OF T_AGSAFPO,
        AUFNR LIKE AFPO-AUFNR, "Order
        POSNR LIKE AFPO-POSNR, "ItemNumber
        PLNUM LIKE AFPO-PLNUM, "PlannedOrder
        STRMP LIKE AFPO-STRMP, "StartDateofthePlannedOrder
        PSMNG LIKE AFPO-PSMNG, "OrderItemQuantity
        WEMNG LIKE AFPO-WEMNG, "QuantityofGoodsReceived
        AMEIN LIKE AFPO-AMEIN, "OrderUnitofMeas
        MEINS LIKE AFPO-MEINS, "BaseUnitofMeasure
        MATNR LIKE AFPO-MATNR, "MaterialNumber
        LTRMI LIKE AFPO-LTRMI, "ActualdeliveryFinishDate
        WEPOS LIKE AFPO-WEPOS, "GoodsReceipt
        LGORT LIKE AFPO-LGORT, "StorageLocation
        ELIKZ LIKE AFPO-ELIKZ, "DeliveryCompleted
        VERID LIKE AFPO-VERID, "ProductionVersion
        DWERK LIKE AFPO-DWERK, "Plant
        DAUAT LIKE AFPO-DAUAT, "OrderType
        DGLTP LIKE AFPO-DGLTP, "BasicFinishDate
        DGLTS LIKE AFPO-DGLTS, "ScheduledFinish
        DFREI LIKE AFPO-DFREI, "ReleasedIndicator
        ABLAD LIKE AFPO-ABLAD, "UnloadingPoint
        MILL_OC_AUFNR_U LIKE AFPO-MILL_OC_AUFNR_U, "NumberofOriginalOrder
        MILL_OC_SORT LIKE AFPO-MILL_OC_SORT, "Sequence
      END OF T_AGSAFPO.

DATA: IT_AGSAFKO TYPE T_AGSAFKO OCCURS 0 WITH HEADER LINE,
      IT_AGSAFPO TYPE T_AGSAFPO OCCURS 0 WITH HEADER LINE,
      IT_AGSAUFK TYPE T_AGSAUFK OCCURS 0 WITH HEADER LINE,
      IT_AGSAUSP TYPE T_AGSAUSP OCCURS 0 WITH HEADER LINE,
      IT_AGSMCH1 TYPE T_AGSMCH1 OCCURS 0 WITH HEADER LINE,
      IT_AGSMCHB TYPE T_AGSMCHB OCCURS 0 WITH HEADER LINE,
      IT_AGSMKPF TYPE T_AGSMKPF OCCURS 0 WITH HEADER LINE,
      IT_AGSMSEG TYPE T_AGSMSEG OCCURS 0 WITH HEADER LINE.

DATA: WA_AGSAFKO LIKE LINE OF IT_AGSAFKO,
      WA_AGSAFPO LIKE LINE OF IT_AGSAFPO,
      WA_AGSAUFK LIKE LINE OF IT_AGSAUFK,
      WA_AGSAUSP LIKE LINE OF IT_AGSAUSP,
      WA_AGSMCH1 LIKE LINE OF IT_AGSMCH1,
      WA_AGSMCHB LIKE LINE OF IT_AGSMCHB,
      WA_AGSMKPF LIKE LINE OF IT_AGSMKPF,
      WA_AGSMSEG LIKE LINE OF IT_AGSMSEG.

DATA: V_LOGMSG_AFKO(500) TYPE C,
      V_LOGMSG_AFPO(500) TYPE C,
      V_LOGMSG_AUFK(500) TYPE C,
      V_LOGMSG_AUSP(500) TYPE C,
      V_LOGMSG_MCH1(500) TYPE C,
      V_LOGMSG_MCHB(500) TYPE C,
      V_LOGMSG_MKPF(500) TYPE C,
      V_LOGMSG_MSEG(500) TYPE C.

"-- Local variable for FM call
DATA: IT_AGSCHAR LIKE STANDARD TABLE OF API_VALI WITH HEADER LINE.

*--------------------------------------------------------------------*
*     END OF - Variable Definition                                   *
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
*     Screen Definition                                              *
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_CHARG FOR MCH1-CHARG, "Batch
                S_AUFNR FOR AUFK-AUFNR, "Order
                S_MBLNR FOR MKPF-MBLNR. "Matdoc
SELECTION-SCREEN END OF BLOCK BLOCK1.
*--------------------------------------------------------------------*
*     END OF - Screen Definition                                     *
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
*     Logical Runtime                                                *
*--------------------------------------------------------------------*
START-OF-SELECTION.

  WAIT UP TO 3 SECONDS.

  PERFORM AGS_CHECK_SERVER.         "-- ADDED FOR AGS BY FATHIR 02.08.2019 - Check used server

  "-- ADDED FOR AGS BY FATHIR ON 17.10.2019 - Delete duplicate parameter
  DELETE ADJACENT DUPLICATES FROM S_CHARG COMPARING LOW.
  DELETE ADJACENT DUPLICATES FROM S_AUFNR COMPARING LOW.
  DELETE ADJACENT DUPLICATES FROM S_MBLNR COMPARING LOW.
  "-- ADDED FOR AGS BY FATHIR ON 17.10.2019 - Delete duplicate parameter

  IF S_CHARG[] IS NOT INITIAL
     AND S_AUFNR[] IS NOT INITIAL
     AND S_MBLNR[] IS NOT INITIAL.

    "-- ADDED FOR AGS BY FATHIR ON 28.08.2019 - Insert SAP-AGS Log
    PERFORM F_INSAGSLOG.
    "-- ADDED FOR AGS BY FATHIR ON 28.08.2019 - Insert SAP-AGS Log

    PERFORM F_GETMATDOC_GIGR_BYMD.
    PERFORM F_ALIGNMATDOCDATA.
    PERFORM F_GETBATCH.
    PERFORM F_GETBATCHSTOCK.
    PERFORM F_GETBATCHCHAR.
    PERFORM F_GETORDER.
    PERFORM F_SETOUTSOURCEMSG.
    PERFORM F_REPLACEDATE.

*    WRITE: 'Debug here!'.

    PERFORM AGS_INSERT_LOG_SQL
      USING 'ZPP018'
            IT_AGSMCH1[]
            IT_AGSMCHB[]
            IT_AGSAUSP[]
            IT_AGSMKPF[]
            IT_AGSMSEG[]
            IT_AGSAUFK[]
            IT_AGSAFKO[]
            IT_AGSAFPO[].

    "-- ADDED BY FATHIR ON 12.07.2019
    "-- Perform commit / rollback SAP-AGS transaction
    "-- based on SQL status
    PERFORM AGS_COMMIT_ROLLBACK.

    IF AGSCX_MSG IS NOT INITIAL.                               "-- Reach the line END-OF-SELECTION soon after the AGSCX_MSG is not empty
      PERFORM F_UPDATEAGSDRC USING 'FAILED' R_ZDATA[].         "-- ADDED FOR AGS BY FATHIR ON 28.08.2019 - Set AGS log as FAILED.
      STOP.
    ENDIF.
    "-- ADDED BY FATHIR ON 12.07.2019

    IF IT_AGSMCH1[] IS INITIAL
       OR IT_AGSMCHB[] IS INITIAL
       OR IT_AGSMKPF[] IS INITIAL
       OR IT_AGSMSEG[] IS INITIAL
       OR IT_AGSAUFK[] IS INITIAL
       OR IT_AGSAFKO[] IS INITIAL
       OR IT_AGSAFPO[] IS INITIAL
       OR IT_AGSAUSP[] IS INITIAL.

      PERFORM F_UPDATEAGSDRC USING 'FAILED' R_ZDATA[].         "-- ADDED FOR AGS BY FATHIR ON 28.08.2019 - Set AGS log as FAILED.

      VLOG_STATUS = '0'.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MCH1.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MCHB.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MKPF.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MSEG.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AUFK.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AFKO.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AFPO.
      PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AUSP.

    ELSE.

      PERFORM F_INSERT_MCH1.
      PERFORM F_INSERT_MCHB.
      PERFORM F_INSERT_AUSP.
      PERFORM F_INSERT_MKPF.
      PERFORM F_INSERT_MSEG.
      PERFORM F_INSERT_AUFK.
      PERFORM F_INSERT_AFKO.
      PERFORM F_INSERT_AFPO.

      IF AGSCX_MSG IS NOT INITIAL.
        PERFORM F_UPDATEAGSDRC USING 'FAILED' R_ZDATA[].         "-- ADDED FOR AGS BY FATHIR ON 17.10.2019 - Set AGS log as FAILED.
      ELSE.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MCH1.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MCHB.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MKPF.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_MSEG.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AUFK.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AFKO.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AFPO.
        PERFORM AGS_UPDATE_LOG USING VLOG_STATUS V_LOGMSG_AUSP.

        "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - Set AGS log as COMPLETE / COMPLETEDRC.
        IF V_ISDRCOK = 'X' AND AGSCX_MSG IS INITIAL.
          PERFORM F_UPDATEAGSDRC USING 'COMPLETEDRC' R_ZDATA[].
        ELSEIF V_ISDRCOK = '' AND AGSCX_MSG IS INITIAL.
          PERFORM F_UPDATEAGSDRC USING 'COMPLETE' R_ZDATA[].
        ENDIF.
        "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - Set AGS log as COMPLETE / COMPLETEDRC.

      ENDIF.

    ENDIF.

    "-- Perform commit / rollback SAP-AGS transaction
    "-- based on SQL status
    PERFORM AGS_COMMIT_ROLLBACK.

    "-- ADDED FOR AGS BY FATHIR ON 09.10.2019 -- Disconnect from SQL Connection
    PERFORM AGS_DISCONNECT.

  ENDIF.

END-OF-SELECTION.
*--------------------------------------------------------------------*
*     END OF - Logical Runtime
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
*     Function Definition
*--------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INSAGSLOG
*&---------------------------------------------------------------------*
*       ADDED FOR AGS BY FATHIR ON 28.08.2019 - Call program to insert SAP-AGS SQL log
*       Insert ZTLOG_AGS
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_INSAGSLOG.
  RANGES: S_BKTXT FOR MKPF-BKTXT.
  CLEAR: R_ZDATA.

  APPEND LINES OF S_AUFNR TO R_ZDATA.
  APPEND LINES OF S_MBLNR TO R_ZDATA.
  APPEND LINES OF S_CHARG TO R_ZDATA.

  PERFORM F_INSERTAGSDRC USING S_BKTXT[] S_CHARG[] S_AUFNR[] S_MBLNR[].

ENDFORM.                    "F_INSAGSLOG

*&---------------------------------------------------------------------*
*&      Form  F_GETMATDOC_GIGR_BYMD
*&---------------------------------------------------------------------*
*       Retrieve Matdoc 101, 102, 261, 262, 901, 902
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_GETMATDOC_GIGR_BYMD.

  IF S_MBLNR[] IS NOT INITIAL.
    SELECT
        MKPF~MBLNR
        MKPF~MJAHR
        MKPF~BLDAT
        MKPF~BUDAT
        MKPF~CPUDT
        MKPF~CPUTM
        MKPF~AEDAT
        MKPF~USNAM
        MKPF~XBLNR
        MKPF~BKTXT
        MKPF~XABLN
      INTO CORRESPONDING FIELDS OF TABLE IT_AGSMKPF
      FROM MKPF
      WHERE MKPF~MBLNR IN S_MBLNR.
  ENDIF.

  IF IT_AGSMKPF[] IS NOT INITIAL.
    SELECT
        MSEG~MBLNR
        MSEG~MJAHR
        MSEG~ZEILE
        MSEG~BWART
        MSEG~MATNR
        MSEG~WERKS
        MSEG~LGORT
        MSEG~CHARG
        MSEG~KDAUF
        MSEG~KDPOS
        MSEG~SHKZG
        MSEG~MENGE
        MSEG~SMBLN
        MSEG~SMBLP
        MSEG~SGTXT
        MSEG~ABLAD
        MSEG~AUFNR
        MSEG~BUDAT_MKPF
        MSEG~CPUDT_MKPF
        MSEG~CPUTM_MKPF
        MSEG~USNAM_MKPF
        MSEG~XBLNR_MKPF
      APPENDING CORRESPONDING FIELDS OF TABLE IT_AGSMSEG
      FROM MSEG
      FOR ALL ENTRIES IN IT_AGSMKPF
      WHERE MSEG~MBLNR = IT_AGSMKPF-MBLNR
            AND MSEG~CHARG <> ''
            AND MSEG~BWART IN ('101', '102', '261', '262', '901', '902').

    SORT IT_AGSMSEG BY BKTXT MBLNR MJAHR ZEILE ASCENDING.
  ENDIF.

  "-- Get Start Time and Finish Time for every Matdoc
  "-- Then, get KETERANGAN WINDER for every Batch
  "-- Then, add found Batch into S_CHARG
  IF IT_AGSMSEG[] IS NOT INITIAL.

    LOOP AT IT_AGSMSEG.

      "-- Copy BKTXT field from MKPF to MSEG
      CLEAR IT_AGSMKPF.
      READ TABLE IT_AGSMKPF INTO IT_AGSMKPF WITH KEY MBLNR = IT_AGSMSEG-MBLNR.
      IT_AGSMSEG-BKTXT = IT_AGSMKPF-BKTXT.

      "-- Get Start Time and Finish Time
      SELECT
          AFRU~ISDZ
          AFRU~IEDZ
        INTO (IT_AGSMSEG-ISDZ, IT_AGSMSEG-IEDZ)
        FROM AFRU
        WHERE LTXA1 = IT_AGSMSEG-MBLNR.
      ENDSELECT.

      MODIFY IT_AGSMSEG TRANSPORTING BKTXT WHERE MBLNR = IT_AGSMSEG-MBLNR.      "-- Insert BKTXT field from MKPF to MSEG
      MODIFY IT_AGSMSEG TRANSPORTING ISDZ IEDZ WHERE MBLNR = IT_AGSMSEG-MBLNR.  "-- Insert Start Time and Finish Time

      "-- Get KETERANGAN WINDER
      PERFORM F_GETWINDERINFO USING 'VERM' 'CHARGE' IT_AGSMSEG-CHARG IT_AGSMSEG-MATNR CHANGING IT_AGSMSEG-WINDERINFO.
      MODIFY IT_AGSMSEG TRANSPORTING WINDERINFO WHERE CHARG = IT_AGSMSEG-CHARG AND BWART = '101'.     "ADDED FOR AGS BY FATHIR ON 22.07.2019 - Insert Winder info to 101 Mvt only

      "-- Add Batch of Roll Input into S_CHARG
      S_CHARG-SIGN = 'I'.
      S_CHARG-OPTION = 'EQ'.
      S_CHARG-LOW = IT_AGSMSEG-CHARG.
      APPEND S_CHARG TO S_CHARG.

    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM S_CHARG COMPARING LOW.

  ENDIF.
ENDFORM.                    " F_GETMATDOC_GIGR_BYMD

*&---------------------------------------------------------------------*
*&      Form  F_ALIGNMATDOCDATA
*&---------------------------------------------------------------------*
*       Align data of Matdoc in MKPF with Matdoc in MSEG
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_ALIGNMATDOCDATA.

  RANGES: R_MATDOC FOR MSEG-MBLNR.

  IF IT_AGSMKPF[] IS NOT INITIAL
     AND IT_AGSMSEG[] IS NOT INITIAL.

    CLEAR: WA_AGSMSEG.
    LOOP AT IT_AGSMSEG INTO WA_AGSMSEG.
      R_MATDOC-SIGN = 'I'.
      R_MATDOC-OPTION = 'EQ'.
      R_MATDOC-LOW = WA_AGSMSEG-MBLNR.
      APPEND R_MATDOC.
    ENDLOOP.

    DELETE IT_AGSMKPF WHERE MBLNR NOT IN R_MATDOC.

  ENDIF.

ENDFORM.                    "F_ALIGNMATDOCDATA

*&---------------------------------------------------------------------*
*&      Form  F_GETBATCH
*&---------------------------------------------------------------------*
*       Retrieve Batch data based on Inserted Batch
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_GETBATCH .

  IF S_CHARG[] IS NOT INITIAL.
    SELECT
        MATNR
        CHARG
        LVORM
        ERSDA
        ERNAM
        AENAM
        LAEDA
        LICHA
        LWEDT
      INTO CORRESPONDING FIELDS OF TABLE IT_AGSMCH1
      FROM MCH1
      WHERE MCH1~CHARG IN S_CHARG.
  ENDIF.

ENDFORM.                    " F_GETBATCH

*&---------------------------------------------------------------------*
*&      Form  F_GETBATCHSTOCK
*&---------------------------------------------------------------------*
*       Retrieve Batch Stock data based on Inserted Batch
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_GETBATCHSTOCK .

  IF S_CHARG[] IS NOT INITIAL.

    SELECT
      MATNR
      WERKS
      LGORT
      CHARG
      LVORM
      ERSDA
      ERNAM
      LAEDA
      AENAM
      CLABS
      CUMLM
      CINSM
      CEINM
      CSPEM
      CRETM
    INTO CORRESPONDING FIELDS OF TABLE IT_AGSMCHB
    FROM MCHB
*    FOR ALL ENTRIES IN IT_AGSMSEG            "CHANGED FOR AGS BY FATHIR ON 18.09.2019 - Get stock for all found batch
    WHERE MCHB~CHARG IN S_CHARG.
*      AND MCHB~LGORT = IT_AGSMSEG-LGORT.     "CHANGED FOR AGS BY FATHIR ON 18.09.2019 - Get stock for all found batch

    "-- Replace stock value of Batch GR with stock value in MSEG
    "-- then, place the new stock value of Batch GR in "Unrestricted"
    LOOP AT IT_AGSMCHB INTO WA_AGSMCHB.
      CLEAR: WA_AGSMSEG.

      READ TABLE IT_AGSMSEG WITH KEY CHARG = WA_AGSMCHB-CHARG BWART = '101' INTO WA_AGSMSEG.
      IF SY-SUBRC EQ 0.
        WA_AGSMCHB-CLABS = WA_AGSMSEG-MENGE.
        WA_AGSMCHB-CUMLM = 0.
        WA_AGSMCHB-CINSM = 0.
        WA_AGSMCHB-CEINM = 0.
        WA_AGSMCHB-CSPEM = 0.
        WA_AGSMCHB-CRETM = 0.

        MODIFY IT_AGSMCHB
        FROM WA_AGSMCHB
        TRANSPORTING  CLABS
                      CUMLM
                      CINSM
                      CEINM
                      CSPEM
                      CRETM
        WHERE CHARG = WA_AGSMSEG-CHARG.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_GETBATCHSTOCK

*&---------------------------------------------------------------------*
*&      Form  F_GETBATCHCHAR
*&---------------------------------------------------------------------*
*       Retrieve all Batch Characteristics based on Inserted Batch
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_GETBATCHCHAR .

  LOOP AT IT_AGSMCHB.
    IF IT_AGSMCHB-CHARG IS NOT INITIAL
       AND IT_AGSMCHB-MATNR IS NOT INITIAL.

      CLEAR IT_AGSCHAR.
      REFRESH IT_AGSCHAR.
      "-- Retrieve Batch Characteristics based on Material and Inserted Batch
      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR    = IT_AGSMCHB-MATNR
          I_VAL_CHARGE   = IT_AGSMCHB-CHARG
        TABLES
          T_VAL_TAB      = IT_AGSCHAR
        EXCEPTIONS
          NO_CLASS       = 1
          INTERNAL_ERROR = 2
          NO_VALUES      = 3
          NO_CHARS       = 4
          OTHERS         = 5.

      IF SY-SUBRC EQ 0.
        LOOP AT IT_AGSCHAR.
          CLEAR WA_AGSAUSP.
          WA_AGSAUSP-CHARG = IT_AGSMCHB-CHARG.
          WA_AGSAUSP-ATNAM = IT_AGSCHAR-ATNAM.
          WA_AGSAUSP-ATWRT = IT_AGSCHAR-ATWRT.
          WA_AGSAUSP-ATFLV = IT_AGSCHAR-ATFLV.
          APPEND WA_AGSAUSP TO IT_AGSAUSP.
        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDLOOP.

  SORT IT_AGSAUSP BY CHARG ATNAM ASCENDING.

ENDFORM.                    " F_GETBATCHCHAR

*&---------------------------------------------------------------------*
*&      Form  F_GETORDER
*&---------------------------------------------------------------------*
*       Retrieve JR Order data
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_GETORDER .

  IF S_AUFNR[] IS NOT INITIAL.

    "-- Get Order master data
    SELECT
        AUFK~AUFNR
        AUFK~AUART
        AUFK~ERNAM
        AUFK~ERDAT
        AUFK~AENAM
        AUFK~AEDAT
        AUFK~KTEXT
        AUFK~LTEXT
        AUFK~WERKS
        AUFK~OBJNR
        AUFK~KDAUF
        AUFK~KDPOS
        AUFK~ZCODE
        AUFK~ZLENGTH
        AUFK~ZWIDTH
        AUFK~ZTREAT
        AUFK~ZCUSTM
        AUFK~ZMONTH
        AUFK~ZVBELN1
        AUFK~ZPOSNR1
        AUFK~ZVBELN2
        AUFK~ZPOSNR2
        AUFK~ZVBELN3
        AUFK~ZPOSNR3
      INTO CORRESPONDING FIELDS OF TABLE IT_AGSAUFK
      FROM AUFK
      WHERE AUFK~AUFNR IN S_AUFNR.

    "-- Get Order Header Data PP Orders
    SELECT
      AFKO~AUFNR
      AFKO~GLTRP
      AFKO~GSTRP
      AFKO~FTRMS
      AFKO~GLTRS
      AFKO~GSTRS
      AFKO~GASMG
      AFKO~GAMNG
      AFKO~GMEIN
      AFKO~PLNBEZ
      AFKO~SBMNG
      AFKO~SBMEH
      AFKO~SLSVN
      AFKO~SLSBS
      AFKO~RUECK
      AFKO~LKNOT
      AFKO~RKNOT
      AFKO~GLUZP
    INTO CORRESPONDING FIELDS OF TABLE IT_AGSAFKO
    FROM AFKO
    WHERE AFKO~AUFNR IN S_AUFNR.

    "-- Get Order item
    SELECT
      AFPO~AUFNR
      AFPO~POSNR
      AFPO~PLNUM
      AFPO~STRMP
      AFPO~PSMNG
      AFPO~WEMNG
      AFPO~AMEIN
      AFPO~MEINS
      AFPO~MATNR
      AFPO~LTRMI
      AFPO~WEPOS
      AFPO~LGORT
      AFPO~ELIKZ
      AFPO~VERID
      AFPO~DWERK
      AFPO~DAUAT
      AFPO~DGLTP
      AFPO~DGLTS
      AFPO~DFREI
      AFPO~ABLAD
      AFPO~MILL_OC_AUFNR_U
      AFPO~MILL_OC_SORT
    INTO CORRESPONDING FIELDS OF TABLE IT_AGSAFPO
    FROM AFPO
    WHERE AFPO~AUFNR IN S_AUFNR.

  ENDIF.

ENDFORM.                    " F_GETORDER

*&---------------------------------------------------------------------*
*&      Form  F_REPLACEDATE
*&---------------------------------------------------------------------*
*       Replace EMPTY date fields on any
*       declared date fields inside this function
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_REPLACEDATE .

  "-- Change blank date to 19000101
  "-- MCH1
  AGS_CONVERT_DATE IT_AGSMCH1 ERSDA.
  AGS_CONVERT_DATE IT_AGSMCH1 LAEDA.
  AGS_CONVERT_DATE IT_AGSMCH1 LWEDT.

  "-- MCHB
  AGS_CONVERT_DATE IT_AGSMCHB ERSDA.
  AGS_CONVERT_DATE IT_AGSMCHB LAEDA.

  "-- MKPF
  AGS_CONVERT_DATE IT_AGSMKPF BLDAT.
  AGS_CONVERT_DATE IT_AGSMKPF BUDAT.
  AGS_CONVERT_DATE IT_AGSMKPF CPUDT.

  "-- MSEG
  AGS_CONVERT_DATE IT_AGSMSEG BUDAT_MKPF.
  AGS_CONVERT_DATE IT_AGSMSEG CPUDT_MKPF.

  "-- AUFK
  AGS_CONVERT_DATE IT_AGSAUFK ERDAT.
  AGS_CONVERT_DATE IT_AGSAUFK AEDAT.

  "-- AFKO
  AGS_CONVERT_DATE IT_AGSAFKO GLTRP.
  AGS_CONVERT_DATE IT_AGSAFKO GSTRP.
  AGS_CONVERT_DATE IT_AGSAFKO FTRMS.
  AGS_CONVERT_DATE IT_AGSAFKO GLTRS.
  AGS_CONVERT_DATE IT_AGSAFKO GSTRS.

  "-- AFPO
  AGS_CONVERT_DATE IT_AGSAFPO STRMP.
  AGS_CONVERT_DATE IT_AGSAFPO LTRMI.
  AGS_CONVERT_DATE IT_AGSAFPO DGLTP.
  AGS_CONVERT_DATE IT_AGSAFPO DGLTS.

ENDFORM.                    " F_REPLACEDATE

*&---------------------------------------------------------------------*
*&      Form  F_GETWINDERINFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PIN_TDID         Text ID in Function Module
*      -->PIN_TDOBJECT     Object of Text in Function Module
*      -->PIN_CHARG        Batch
*      -->PIN_PLNBEZ       Material
*      <--POUT_WINDERINFO  OUTPUT - KETERANGAN WINDER
*----------------------------------------------------------------------*
FORM F_GETWINDERINFO
  USING PIN_TDID LIKE THEAD-TDID
        PIN_TDOBJECT LIKE THEAD-TDOBJECT
        PIN_CHARG LIKE MCH1-CHARG
        PIN_PLNBEZ LIKE AFKO-PLNBEZ
  CHANGING POUT_WINDERINFO TYPE C.

  DATA: Z_CHARG TYPE STRING,
        Z_TDNAME LIKE THEAD-TDNAME,
        Z_LENGTH TYPE I.
  DATA: IT_TLINE LIKE TABLE OF TLINE WITH HEADER LINE.

  CLEAR: Z_CHARG, Z_TDNAME, Z_LENGTH, IT_TLINE.
  REFRESH: IT_TLINE.

  "-- Set default winderinfo as empty string
  POUT_WINDERINFO = ''.

  "-- START OF - Set TDNAME for FM Call
  MOVE PIN_CHARG TO Z_CHARG.
  CONDENSE Z_CHARG.
  Z_LENGTH = 22 - STRLEN( PIN_PLNBEZ ).
  SHIFT Z_CHARG BY Z_LENGTH PLACES RIGHT.
  CONCATENATE PIN_PLNBEZ Z_CHARG INTO Z_TDNAME.
  "-- END OF - Set TDNAME for FM Call

  IF Z_TDNAME IS NOT INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        ID                      = PIN_TDID
        LANGUAGE                = 'E'
        NAME                    = Z_TDNAME
        OBJECT                  = PIN_TDOBJECT
      TABLES
        LINES                   = IT_TLINE
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.

    "-- Get KETERANGAN WINDER text
    READ TABLE IT_TLINE INDEX 1.
    IF SY-SUBRC = 0.
      POUT_WINDERINFO = IT_TLINE-TDLINE.
    ENDIF.

  ENDIF.


ENDFORM.                    "F_GETWINDERINFO

*&---------------------------------------------------------------------*
*&      Form  F_SETOUTSOURCEMSG
*&---------------------------------------------------------------------*
*       Fill IT_AGSMSEG-SGTXT with "O" and
*       IT_AGSMSEG-ABLAD with roll length from Batch Characteristics
*
*       Called in START-OF-SELECTION
*----------------------------------------------------------------------*
FORM F_SETOUTSOURCEMSG.

  IF IT_AGSMSEG[] IS NOT INITIAL
     AND IT_AGSAUSP[] IS NOT INITIAL.

    LOOP AT IT_AGSMSEG INTO WA_AGSMSEG.

      CLEAR WA_AGSAUSP.
      READ TABLE IT_AGSAUSP INTO WA_AGSAUSP WITH KEY CHARG = WA_AGSMSEG-CHARG ATNAM = 'ZZLENGTH'.

      WA_AGSMSEG-SGTXT = 'O'.
      WRITE WA_AGSAUSP-ATWRT TO WA_AGSMSEG-ABLAD.

      REPLACE ALL OCCURRENCES OF ',' IN WA_AGSMSEG-ABLAD WITH ''.
      CONDENSE WA_AGSMSEG-ABLAD.

      MODIFY IT_AGSMSEG FROM WA_AGSMSEG TRANSPORTING SGTXT ABLAD WHERE CHARG = WA_AGSMSEG-CHARG.

    ENDLOOP.

  ENDIF.

ENDFORM.                    "F_SETOUTSOURCEMSG

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_MCH1
*&---------------------------------------------------------------------*
*       Insert MCH1 for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_MCH1.
  LOOP AT IT_AGSMCH1.
    TRY.
        EXEC SQL.
          INSERT INTO DBO.Y_MK3CH1
          (
            Material,
            Batch,
            BatchDeletionFlag,
            CreatedOn,
            CreatedBy,
            ChangedOn,
            ChangedBy,
            VendorBatch,
            LastGoodsRec
          )
          VALUES
          (
            :IT_AGSMCH1-MATNR,
            :IT_AGSMCH1-CHARG,
            :IT_AGSMCH1-LVORM,
            :IT_AGSMCH1-ERSDA,
            :IT_AGSMCH1-ERNAM,
            :IT_AGSMCH1-LAEDA,
            :IT_AGSMCH1-AENAM,
            :IT_AGSMCH1-LICHA,
            :IT_AGSMCH1-LWEDT
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_MCH1

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_MCHB
*&---------------------------------------------------------------------*
*       Insert MCHB for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_MCHB.

  LOOP AT IT_AGSMCHB.
    TRY.
        EXEC SQL.
          INSERT INTO DBO.Y_MK3CHB
          (
            Material,
            Plant,
            StorLocation,
            Batch,
            Stockdelflag,
            CreatedOn,
            Createdby,
            ChangedOn,
            Changedby,
            Unrestricted,
            Stockintfr,
            InQualInsp,
            RestrictedUse,
            Blocked,
            Returns
          )
          VALUES
          (
            :IT_AGSMCHB-MATNR,
            :IT_AGSMCHB-WERKS,
            :IT_AGSMCHB-LGORT,
            :IT_AGSMCHB-CHARG,
            :IT_AGSMCHB-LVORM,
            :IT_AGSMCHB-ERSDA,
            :IT_AGSMCHB-ERNAM,
            :IT_AGSMCHB-LAEDA,
            :IT_AGSMCHB-AENAM,
            :IT_AGSMCHB-CLABS,
            :IT_AGSMCHB-CUMLM,
            :IT_AGSMCHB-CINSM,
            :IT_AGSMCHB-CEINM,
            :IT_AGSMCHB-CSPEM,
            :IT_AGSMCHB-CRETM
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_MCHB

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_AUSP
*&---------------------------------------------------------------------*
*       Insert AUSP for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_AUSP.

  LOOP AT IT_AGSAUSP.
    TRY.
        EXEC SQL.
          INSERT INTO DBO.Y_AA1USP
          (
            Object,
            InternalChar,
            CharValue,
            Valuefrom
          )
          VALUES
          (
            :IT_AGSAUSP-CHARG,
            :IT_AGSAUSP-ATNAM,
            :IT_AGSAUSP-ATWRT,
            :IT_AGSAUSP-ATFLV
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_AUSP

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_MKPF
*&---------------------------------------------------------------------*
*       Insert MKPF for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_MKPF.

  LOOP AT IT_AGSMKPF.
    TRY.
        EXEC SQL.
          INSERT INTO DBO.Y_MK3KPF
          (
            MaterialDoc,
            MatDocYear,
            DocumentDate,
            PostingDate,
            EnteredOn,
            EnteredAt,
            ChangedOn,
            Username,
            Reference,
            DocHeaderText,
            GRGISlipNo
          )
          VALUES
          (
            :IT_AGSMKPF-MBLNR,
            :IT_AGSMKPF-MJAHR,
            :IT_AGSMKPF-BLDAT,
            :IT_AGSMKPF-BUDAT,
            :IT_AGSMKPF-CPUDT,
            :IT_AGSMKPF-CPUTM,
            :IT_AGSMKPF-AEDAT,
            :IT_AGSMKPF-USNAM,
            :IT_AGSMKPF-XBLNR,
            :IT_AGSMKPF-BKTXT,
            :IT_AGSMKPF-XABLN
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_MKPF

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_MSEG
*&---------------------------------------------------------------------*
*       Insert MSEG for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_MSEG.

  LOOP AT IT_AGSMSEG.
    TRY .
        EXEC SQL.
          INSERT INTO DBO.Y_MK3SEG
          (
            MaterialDoc1,
            MatDocYear,
            MatDocItem1,
            MovementType,
            Material,
            Plant,
            StorLocation,
            Batch,
            SalesOrder,
            SalesOrdItem,
            DebitCredit,
            Quantity,
            MaterialDoc2,
            MatDocItem2,
            Text,
            UnloadingPoint,
            Order,
            PostingDate,
            Enteredon,
            Enteredat,
            Username,
            Reference,
            StartTime,
            FinishTime,
            WinderInfo
          )
          VALUES
          (
            :IT_AGSMSEG-MBLNR,
            :IT_AGSMSEG-MJAHR,
            :IT_AGSMSEG-ZEILE,
            :IT_AGSMSEG-BWART,
            :IT_AGSMSEG-MATNR,
            :IT_AGSMSEG-WERKS,
            :IT_AGSMSEG-LGORT,
            :IT_AGSMSEG-CHARG,
            :IT_AGSMSEG-KDAUF,
            :IT_AGSMSEG-KDPOS,
            :IT_AGSMSEG-SHKZG,
            :IT_AGSMSEG-MENGE,
            :IT_AGSMSEG-SMBLN,
            :IT_AGSMSEG-SMBLP,
            :IT_AGSMSEG-SGTXT,
            :IT_AGSMSEG-ABLAD,
            :IT_AGSMSEG-AUFNR,
            :IT_AGSMSEG-BUDAT_MKPF,
            :IT_AGSMSEG-CPUDT_MKPF,
            :IT_AGSMSEG-CPUTM_MKPF,
            :IT_AGSMSEG-USNAM_MKPF,
            :IT_AGSMSEG-XBLNR_MKPF,
            :IT_AGSMSEG-ISDZ,
            :IT_AGSMSEG-IEDZ,
            :IT_AGSMSEG-WINDERINFO
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_MSEG

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_AUFK
*&---------------------------------------------------------------------*
*       Insert AUFK for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_AUFK.

  LOOP AT IT_AGSAUFK.
    TRY .
        EXEC SQL.
          INSERT INTO DBO.Y_AA1UFK
          (
            Order,
            OrderType,
            Enteredby,
            Createdon,
            Changedby,
            Changedon,
            Description,
            Longtxtexists,
            Plant,
            ObjectNumber,
            SalesOrder,
            SalesOrdItem,
            FilmCode,
            Length,
            Width,
            Treatment,
            Customer,
            MonthYearofProduction,
            SOforOverProduction1,
            SOItemforOverProduction1,
            SOforOverProduction2,
            SOItemforOverProduction2,
            SOforSecondGrade,
            SOItemforSecondGrade
          )
          VALUES
          (
            :IT_AGSAUFK-AUFNR,
            :IT_AGSAUFK-AUART,
            :IT_AGSAUFK-ERNAM,
            :IT_AGSAUFK-ERDAT,
            :IT_AGSAUFK-AENAM,
            :IT_AGSAUFK-AEDAT,
            :IT_AGSAUFK-KTEXT,
            :IT_AGSAUFK-LTEXT,
            :IT_AGSAUFK-WERKS,
            :IT_AGSAUFK-OBJNR,
            :IT_AGSAUFK-KDAUF,
            :IT_AGSAUFK-KDPOS,
            :IT_AGSAUFK-ZCODE,
            :IT_AGSAUFK-ZLENGTH,
            :IT_AGSAUFK-ZWIDTH,
            :IT_AGSAUFK-ZTREAT,
            :IT_AGSAUFK-ZCUSTM,
            :IT_AGSAUFK-ZMONTH,
            :IT_AGSAUFK-ZVBELN1,
            :IT_AGSAUFK-ZPOSNR1,
            :IT_AGSAUFK-ZVBELN2,
            :IT_AGSAUFK-ZPOSNR2,
            :IT_AGSAUFK-ZVBELN3,
            :IT_AGSAUFK-ZPOSNR3
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_AUFK

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_AFKO
*&---------------------------------------------------------------------*
*       Insert AFKO for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_AFKO.

  LOOP AT IT_AGSAFKO.
    TRY.
        EXEC SQL.
          INSERT INTO DBO.Y_AA1FKO
          (
            Order,
            BasicFinishDate,
            BasicStartDate,
            Release,
            Schedfinish,
            Schedstart,
            Scrap,
            Targetquantity,
            BaseUnit1,
            Material,
            Basequantity,
            BaseUnit2,
            FromLotSize,
            ToLotSize,
            Confirmation,
            LeftNode,
            RightNode,
            BasicFinishTime
          )
          VALUES
          (
            :IT_AGSAFKO-AUFNR,
            :IT_AGSAFKO-GLTRP,
            :IT_AGSAFKO-GSTRP,
            :IT_AGSAFKO-FTRMS,
            :IT_AGSAFKO-GLTRS,
            :IT_AGSAFKO-GSTRS,
            :IT_AGSAFKO-GASMG,
            :IT_AGSAFKO-GAMNG,
            :IT_AGSAFKO-GMEIN,
            :IT_AGSAFKO-PLNBEZ,
            :IT_AGSAFKO-SBMNG,
            :IT_AGSAFKO-SBMEH,
            :IT_AGSAFKO-SLSVN,
            :IT_AGSAFKO-SLSBS,
            :IT_AGSAFKO-RUECK,
            :IT_AGSAFKO-LKNOT,
            :IT_AGSAFKO-RKNOT,
            :IT_AGSAFKO-GLUZP
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_AFKO

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_AFPO
*&---------------------------------------------------------------------*
*       Insert AFPO for AGS
*
*       Called in ...
*----------------------------------------------------------------------*
FORM F_INSERT_AFPO.

  LOOP AT IT_AGSAFPO.
    TRY.
        EXEC SQL.
          INSERT INTO DBO.Y_AA1FPO
          (
            Order,
            ItemNumber,
            PlannedOrder,
            ItemQuantity,
            GRQuantity,
            OrderUn,
            BaseUnit,
            MaterialNumber,
            Actdelivdate,
            GoodsReceipt,
            StorLocation,
            DelivCompl,
            ProdVersion,
            Plant,
            OrderType,
            Basicfindate,
            Schedfinish,
            Releaseind,
            UnloadingPoint,
            Originalorder,
            Sequence
          )
          VALUES
          (
            :IT_AGSAFPO-AUFNR,
            :IT_AGSAFPO-POSNR,
            :IT_AGSAFPO-PLNUM,
            :IT_AGSAFPO-PSMNG,
            :IT_AGSAFPO-WEMNG,
            :IT_AGSAFPO-AMEIN,
            :IT_AGSAFPO-MEINS,
            :IT_AGSAFPO-MATNR,
            :IT_AGSAFPO-LTRMI,
            :IT_AGSAFPO-WEPOS,
            :IT_AGSAFPO-LGORT,
            :IT_AGSAFPO-ELIKZ,
            :IT_AGSAFPO-VERID,
            :IT_AGSAFPO-DWERK,
            :IT_AGSAFPO-DAUAT,
            :IT_AGSAFPO-DGLTP,
            :IT_AGSAFPO-DGLTS,
            :IT_AGSAFPO-DFREI,
            :IT_AGSAFPO-ABLAD,
            :IT_AGSAFPO-MILL_OC_AUFNR_U,
            :IT_AGSAFPO-MILL_OC_SORT
          )
        ENDEXEC.
      CATCH CX_ROOT INTO AGSLEX_ROOT.
        VLOG_STATUS = '0'.
        AGSCX_MSG = AGSLEX_ROOT->GET_TEXT( ).
        MESSAGE AGSCX_MSG TYPE 'S'.
    ENDTRY.

    IF AGSCX_MSG IS NOT INITIAL.      "-- CHANGED FOR AGS BY FATHIR ON 17.10.2019 - use AGSCX_MSG as a flag of SQL Error
      EXIT.
    ENDIF.

  ENDLOOP.

  IF AGSCX_MSG IS INITIAL.
    VLOG_STATUS = '1'.
  ENDIF.

ENDFORM.                    "F_INSERT_AFPO


*&---------------------------------------------------------------------*
*&      Form  AGS_INSERT_LOG_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PIN_TCODE  text
*      -->VALUE      text
*      -->(PIN_MCH1) text
*      -->VALUE      text
*      -->(PIN_MCHB) text
*      -->VALUE      text
*      -->(PIN_AUSP) text
*      -->VALUE      text
*      -->(PIN_MKPF) text
*      -->VALUE      text
*      -->(PIN_MSEG) text
*      -->VALUE      text
*      -->(PIN_AUFK) text
*      -->VALUE      text
*      -->(PIN_AFKO) text
*      -->VALUE      text
*      -->(PIN_AFPO) text
*----------------------------------------------------------------------*
FORM AGS_INSERT_LOG_SQL
  USING PIN_TCODE TYPE C
        VALUE(PIN_MCH1) TYPE STANDARD TABLE
        VALUE(PIN_MCHB) TYPE STANDARD TABLE
        VALUE(PIN_AUSP) TYPE STANDARD TABLE
        VALUE(PIN_MKPF) TYPE STANDARD TABLE
        VALUE(PIN_MSEG) TYPE STANDARD TABLE
        VALUE(PIN_AUFK) TYPE STANDARD TABLE
        VALUE(PIN_AFKO) TYPE STANDARD TABLE
        VALUE(PIN_AFPO) TYPE STANDARD TABLE .

  CLEAR: VLOG_DATE,
         VLOG_TIME,
         VLOG_STATUS,
         VLOG_MSG,
         VLOG_TOTALRECORDS,
         VLOG_TCODE,
         VLOG_AGSTABLE,
         VLOG_TERMINAL,
         VLOG_TEMP.

  VLOG_DATE = SY-DATUM.               "-- set date
  WRITE SY-UZEIT TO VLOG_TIME.        "-- set time
  VLOG_TCODE = SY-TCODE.              "-- set tcode
  VLOG_STATUS = ''.                   "-- set initial log status

  "-- set computer name
  CALL FUNCTION 'GUI_GET_DESKTOP_INFO'
    EXPORTING
      TYPE   = '1'
    CHANGING
      RETURN = VLOG_TERMINAL.

  IF VLOG_TERMINAL IS INITIAL.
    VLOG_TERMINAL = 'BACKGROUND JOB'.
  ENDIF.

  PERFORM AGS_CONNECT_SQL.            "-- OPEN SQL CONNECTION
  IF AGSCX_MSG IS NOT INITIAL.        "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.

  "-- process log for MCH1
  "-- set table name for log
  VLOG_AGSTABLE = 'MCH1'.

  DESCRIBE TABLE PIN_MCH1 LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_MCH1 SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_MCH1 WITH ''. "-- remove time separator
  CONDENSE V_LOGMSG_MCH1.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_MCH1 VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for MCH1

  "-- process log for MCHB
  "-- set table name for log
  VLOG_AGSTABLE = 'MCHB'.

  DESCRIBE TABLE PIN_MCHB LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_MCHB SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_MCHB WITH ''. "-- remove time separator
  CONDENSE V_LOGMSG_MCHB.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_MCHB VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for MCHB

  "-- process log for AUSP
  "-- set table name for log
  VLOG_AGSTABLE = 'AUSP'.

  DESCRIBE TABLE PIN_AUSP LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_AUSP SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_AUSP WITH ''. "-- remove time separator
  CONDENSE V_LOGMSG_AUSP.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_AUSP VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for AUSP

  "-- process log for MKPF
  "-- set table name for log
  VLOG_AGSTABLE = 'MKPF'.

  DESCRIBE TABLE PIN_MKPF LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_MKPF SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_MKPF WITH ''. "-- remove time separator
  CONDENSE V_LOGMSG_MKPF.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_MKPF VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for MKPF

  "-- process log for MSEG
  "-- set table name for log
  VLOG_AGSTABLE = 'MSEG'.

  DESCRIBE TABLE PIN_MSEG LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_MSEG SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_MSEG WITH ''. "-- remove time separator
  CONDENSE V_LOGMSG_MSEG.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_MSEG VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for MSEG

  "-- process log for AUFK
  "-- set table name for log
  VLOG_AGSTABLE = 'AUFK'.

  DESCRIBE TABLE PIN_AUFK LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_AUFK SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_AUFK WITH ''. "-- remove time separator
  CONDENSE V_LOGMSG_AUFK.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_AUFK VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for AUFK

  "-- process log for AFKO
  "-- set table name for log
  VLOG_AGSTABLE = 'AFKO'.

  DESCRIBE TABLE PIN_AFKO LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_AFKO SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_AFKO WITH ''. "-- remove time separator

  LOOP AT PIN_AFKO INTO WA_AGSAFKO.
    CONCATENATE V_LOGMSG_AFKO WA_AGSAFKO-AUFNR INTO V_LOGMSG_AFKO SEPARATED BY '|'.
  ENDLOOP.
  CONDENSE V_LOGMSG_AFKO.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_AFKO VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for AFKO

  "-- process log for AFPO
  "-- set table name for log
  VLOG_AGSTABLE = 'AFPO'.

  DESCRIBE TABLE PIN_AFPO LINES VLOG_TOTALRECORDS.
  CONDENSE VLOG_TOTALRECORDS.

  "-- set message
  CONCATENATE VLOG_DATE VLOG_TIME VLOG_TCODE PIN_TCODE VLOG_AGSTABLE VLOG_TERMINAL INTO V_LOGMSG_AFPO SEPARATED BY '|'.
  REPLACE ALL OCCURRENCES OF SUBSTRING ':' IN V_LOGMSG_AFPO WITH ''. "-- remove time separator
  CONDENSE V_LOGMSG_AFPO.

  PERFORM AGS_INSERT_LOG USING VLOG_STATUS V_LOGMSG_AFPO VLOG_TOTALRECORDS.
  IF AGSCX_MSG IS NOT INITIAL.      "-- ADDED BY FATHIR ON 12.07.2019
    EXIT.
  ENDIF.
  "-- END OF - process log for AFPO

ENDFORM.                    "AGS_INSERT_LOG_SQL