*&---------------------------------------------------------------------*
*&  Include           ZPPI_CHANGE_BOM_PO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GETZ_DATA .
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETZ_DATA USING P_UCOMM.
  DATA : COUNT_MATNR TYPE I,
         NUM2 TYPE I,
         AUFNR TYPE AUFK-AUFNR.

  CLEAR : T_CANCEL,TA_ORI,WA_ORI.

  IF P_UCOMM = 'X'.
    PERFORM F_FILTER_DATA_2.
  ELSE.
    PERFORM F_FILTER_DATA_1.
  ENDIF.

  SORT TA_ITEM BY AUFNR CHARG_JR .
  TA_ITEM_JR[] = TA_ITEM[].
  CLEAR : TA_ITEM. REFRESH : TA_ITEM.


** cari raw material bom dari jumbo roll buat planning
  SELECT STAS~STLTY  STAS~STLAL
         STPO~IDNRK STPO~STLNR STPO~LGORT STPO~MENGE STPO~MEINS
         STAS~STLKN
    INTO TABLE TA_BOM
  FROM STAS
  JOIN STPO ON STAS~STLTY = STPO~STLTY
  AND  STAS~STLNR = STPO~STLNR
  AND  STAS~STLKN = STPO~STLKN
  FOR ALL ENTRIES IN TA_ITEM_JR
  WHERE STAS~STLTY = TA_ITEM_JR-STLTY
  AND   STAS~STLNR = TA_ITEM_JR-STLNR
  AND   STAS~STLAL = TA_ITEM_JR-STLAL.


  DELETE TA_BOM WHERE MENGE < 0.
  SORT TA_BOM BY STLTY STLAL STLNR IDNRK MENGE. "STLNR IDNRK.
  DELETE ADJACENT DUPLICATES FROM TA_BOM COMPARING STLTY STLAL STLNR IDNRK MENGE.


  LOOP AT TA_ITEM_JR INTO WA_ITEM_JR.
    LOOP AT TA_BOM INTO WA_BOM WHERE STLNR = WA_ITEM_JR-STLNR
                               AND   STLTY = WA_ITEM_JR-STLTY
                               AND   STLAL = WA_ITEM_JR-STLAL.
      CLEAR  BMENG.
      SELECT SINGLE BMENG INTO BMENG
        FROM STKO
        WHERE STLNR = WA_ITEM_JR-STLNR
        AND   STLTY = WA_ITEM_JR-STLTY
        AND   STLAL = WA_ITEM_JR-STLAL.

**    qty / satuan
*      BASE_QTY =  WA_BOM-MENGE / BMENG.


      MOVE-CORRESPONDING WA_ITEM_JR TO WA_ITEM_GI.
      WA_ITEM_GI-STLKN   = WA_BOM-STLKN.
      WA_ITEM_GI-IDNRK_P = WA_BOM-IDNRK.
      WA_ITEM_GI-STLNR_P = WA_BOM-STLNR.
      WA_ITEM_GI-LGORT_P = WA_BOM-LGORT.
      WA_ITEM_GI-MENGE_P = WA_ITEM_JR-MENGE_GR * ( WA_BOM-MENGE / BMENG ). " BASE_QTY.
      WA_ITEM_GI-MEINS_P = WA_BOM-MEINS.

      PERFORM GET_MAKTX USING WA_ITEM_GI-IDNRK_P CHANGING WA_ITEM_GI-MAKTX_P ERRNO.

*      SELECT SINGLE CHARG INTO WA_ITEM_GI-CHARG_P
*        FROM MCHB
*        WHERE MATNR = WA_BOM-IDNRK
*        AND   WERKS = WA_ITEM_JR-WERKS
*        AND   LGORT = WA_BOM-LGORT.

      APPEND WA_ITEM_GI TO TA_ITEM_GI.
    ENDLOOP.
  ENDLOOP.


***  raw mat
  CLEAR : TA_ITEM_JR. REFRESH : TA_ITEM_JR.
  TA_ITEM_JR[] = TA_ITEM_GI[].
  SORT TA_ITEM_JR BY AUFNR CHARG_JR IDNRK_P.
  DELETE ADJACENT DUPLICATES FROM TA_ITEM_JR COMPARING AUFNR CHARG_JR.

  SORT TA_ITEM_JR BY NOSEQ AUFNR CHARG_JR ASCENDING  NOSEQ.

  LOOP AT TA_ITEM_JR INTO WA_ITEM_JR.
    NUM_MAT = NUM = 0.
    SUBTOT_A = 0.
    CLEAR : NEW_RAWMAT,TZEILE,TMATNR . REFRESH : NEW_RAWMAT,TZEILE,TMATNR.

    LOOP AT TA_ITEM_GI INTO WA_ITEM_GI WHERE AUFNR = WA_ITEM_JR-AUFNR
                                       AND   CHARG_JR = WA_ITEM_JR-CHARG_JR.
      CLEAR : MBLNR,MJAHR,ZEILE,MENGE,COUNT_MATNR,
      T_CANCEL-LGORT,T_CANCEL-MATNR,T_CANCEL-WERKS,T_CANCEL-MEINS,T_CANCEL-XABLN.

      "- 18 jan 2013
      PERFORM GET_BWART_ALL USING WA_ITEM_JR-AUFNR  CHANGING BWART1 BWART2.

      SELECT MSEG~MBLNR MSEG~MJAHR MSEG~ZEILE MSEG~MENGE MSEG~CHARG
             MSEG~MATNR MSEG~WERKS MSEG~LGORT MSEG~MEINS MKPF~XABLN
        INTO (MBLNR,MJAHR,ZEILE,MENGE,WA_ITEM_GI-CHARG_A,T_CANCEL-MATNR,
              T_CANCEL-WERKS,T_CANCEL-LGORT,T_CANCEL-MEINS,T_CANCEL-XABLN)
        FROM MSEG
        JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
        WHERE BWART = BWART1 " '261'
        AND   MATNR = WA_ITEM_GI-IDNRK_P
        AND   AUFNR = WA_ITEM_GI-AUFNR
        AND   BKTXT = WA_ITEM_JR-BKTXT_JR
        AND   XABLN NE 'Balancing'  " 4-3-2012 (bagus) TRDK906283
        ORDER BY MSEG~MBLNR ASCENDING.
*        %_HINTS ORACLE 'INDEX("MSEG" "MSEG~BOM")'.
      ENDSELECT.

      NUM = NUM + 1.

      "- material yang sama pas gi disesuaikan qty ga ada parameternya, jadi begini deh
      T_FILTER[] = TA_ITEM_GI[].
      DELETE T_FILTER   WHERE BKTXT_JR   NE WA_ITEM_GI-BKTXT_JR.
      DELETE T_FILTER   WHERE AUFNR    NE WA_ITEM_GI-AUFNR
                        AND   CHARG_JR NE WA_ITEM_GI-CHARG_JR.
      DELETE T_FILTER   WHERE   IDNRK_P  NE WA_ITEM_GI-IDNRK_P.
      DESCRIBE TABLE T_FILTER LINES LINE.
      READ TABLE T_FILTER INDEX 1.
      IF LINE > 1 .
        NUM_MAT = NUM_MAT  + 1.
        IF NUM_MAT = 1.
          SELECT AUFM~ZEILE AUFM~MENGE AUFM~CHARG
            INTO TABLE T_MATERIAL
            FROM AUFM
            JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
            WHERE BWART = BWART1 " '261'
            AND   MATNR = WA_ITEM_GI-IDNRK_P
            AND   AUFM~MBLNR = MBLNR.
*            %_HINTS ORACLE 'INDEX("AUFM" "AUFM~Z05")'.
        ENDIF.

        READ TABLE T_MATERIAL INDEX 1.
        IF SY-SUBRC = 0.
          ZEILE               = T_MATERIAL-ZEILE.
          MENGE               = T_MATERIAL-MENGE.
          WA_ITEM_GI-CHARG_A  = T_MATERIAL-CHARG.
          DELETE T_MATERIAL WHERE ZEILE = ZEILE.
          DESCRIBE TABLE T_MATERIAL LINES LINE.
          IF LINE = 0.
            CLEAR : NUM_MAT.
          ENDIF.
        ELSE.
          ZEILE = MENGE = NUM_MAT = 0.
          CLEAR : T_MATERIAL,MBLNR,LINE.
        ENDIF.
      ELSE.
        CLEAR : T_MATERIAL.
        NUM_MAT  = 0.
      ENDIF.


* kuning = belom gi
* merah = udah di gi tp qty 0
* ijo   = udah di gi
      IF MBLNR = ''.
        WA_ITEM_GI-ICON    = '@09@' .
*        WA_ITEM_GI-MENGE_A =  WA_ITEM_GI-MENGE_P.
        WA_ITEM_GI-MENGE_A = 0 .
*        WA_ITEM_GI-LGORT_A = ''.
      ELSE.

        SELECT SINGLE ZEILE INTO ZEILE
          FROM MSEG
          WHERE BWART = BWART2 " '262'
          AND   SMBLN = MBLNR
          AND   SMBLP = ZEILE
          AND   SJAHR = MJAHR.
*          %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.
        IF SY-SUBRC = 0.
          WA_ITEM_GI-ICON = '@09@' .
          WA_ITEM_GI-MENGE_A = 0 .
        ELSE.
          IF MENGE = 0 .
            WA_ITEM_GI-ICON =  '@0A@'.
          ELSE.
            WA_ITEM_GI-ICON = '@08@' .
          ENDIF.
          T_CANCEL-AUFNR   = WA_ITEM_JR-AUFNR.
          T_CANCEL-CHARG   = WA_ITEM_JR-CHARG_JR.
          T_CANCEL-MBLNR   = MBLNR.
          T_CANCEL-MJAHR   = MJAHR.
          T_CANCEL-ZEILE   = ZEILE.
          T_CANCEL-MENGE   = MENGE.
          T_CANCEL-CHARG_A = WA_ITEM_GI-CHARG_A.
          T_CANCEL-ZZLINE  = WA_ITEM_JR-ZZLINE.
          T_CANCEL-ZZCODE  = WA_ITEM_JR-ZZCODE.
          T_CANCEL-BKTXT   = WA_ITEM_JR-BKTXT_JR.
          APPEND T_CANCEL.
          WA_ITEM_GI-MENGE_A = MENGE .
        ENDIF.
      ENDIF.


**    raw mat sama dengan planning
      WA_ITEM_GI-CHARGID = WA_ITEM_JR-CHARG_JR.
      WA_ITEM_GI-AUFNRID = WA_ITEM_JR-AUFNR.
      WA_ITEM_GI-BKTXTID = WA_ITEM_JR-BKTXT_JR.
      WA_ITEM_GI-NOSEQID = WA_ITEM_JR-NOSEQ.
      IF WA_ITEM_GI-CHARG_A = ''.
        WA_ITEM_GI-CHARG_A = WA_ITEM_GI-CHARG_P.
      ENDIF.
*      IF WA_ITEM_GI-LGORT_A = ''.
*        WA_ITEM_GI-LGORT_A =  T_CANCEL-LGORT.
*      ELSE.
*        WA_ITEM_GI-LGORT_A = WA_ITEM_GI-LGORT_P.
*      ENDIF.
      IF T_CANCEL-LGORT = ''.
        WA_ITEM_GI-LGORT_A = WA_ITEM_GI-LGORT_P.
      ELSE.
        WA_ITEM_GI-LGORT_A =  T_CANCEL-LGORT.
      ENDIF.
      WA_ITEM_GI-MATNR_A = WA_ITEM_GI-IDNRK_P.
      WA_ITEM_GI-MAKTX_A = WA_ITEM_GI-MAKTX_P.




      IF NUM > 1.
        CLEAR : WA_ITEM_GI-AUFNR, WA_ITEM_GI-MATNR, WA_ITEM_GI-CHARG_JR,
                WA_ITEM_GI-BLDAT, WA_ITEM_GI-ZLINE, WA_ITEM_GI-PERNR, WA_ITEM_GI-CPUTM,
                WA_ITEM_GI-ZZTYPE, WA_ITEM_GI-ZZTHICKNESS, WA_ITEM_GI-ZZWIDTH,
                WA_ITEM_GI-ZZLENGTH, WA_ITEM_GI-ZZNOMORROLL,WA_ITEM_GI-NOSEQ. "WA_ITEM_GI-MENGE_GR,
        .

      ELSEIF NUM = 1.
*
      ENDIF.

****  cek item duplicate
      READ TABLE TA_ITEM INTO WA_ITEM WITH KEY AUFNRID  = WA_ITEM_JR-AUFNR
                                                CHARGID = WA_ITEM_JR-CHARG_JR
                                                MATNR_A = WA_ITEM_GI-IDNRK_P
                                                ZEILE   = ZEILE
                                                MBLNR   = MBLNR.
      IF SY-SUBRC = 0.
        WA_ITEM_GI-MENGE_A = 0.
      ENDIF.


      MOVE-CORRESPONDING WA_ITEM_GI TO WA_ITEM.
      WA_ITEM-MBLNR = MBLNR.
      WA_ITEM-ZEILE = ZEILE.
      APPEND WA_ITEM TO TA_ITEM.
      SUBTOT_A = SUBTOT_A + WA_ITEM_GI-MENGE_A.

      TZEILE-SIGN   = 'I'.
      TZEILE-OPTION = 'EQ'.
      TZEILE-LOW    = ZEILE.
      APPEND TZEILE.


      TMATNR-SIGN   = 'I'.
      TMATNR-OPTION = 'EQ'.
      TMATNR-LOW    = WA_ITEM_GI-IDNRK_P.
      APPEND TMATNR.
*      ENDDO.
    ENDLOOP.


*** added 26 nop  12
    READ TABLE TA_ITEM INTO WA_ITEM WITH KEY AUFNRID = WA_ITEM_GI-AUFNRID
                                             CHARGID = WA_ITEM_GI-CHARGID.
    IF SY-SUBRC = 0.
      "- 18 jan 2013
      PERFORM GET_BWART_ALL USING WA_ITEM_GI-AUFNRID  CHANGING BWART1 BWART2.

      SORT TZEILE BY LOW ASCENDING.
      DELETE ADJACENT DUPLICATES FROM TZEILE COMPARING LOW.
      SELECT CHARG MENGE LGORT MATNR MEINS ZEILE MBLNR
        INTO (WA_ITEM-CHARG_A,WA_ITEM-MENGE_A,WA_ITEM-LGORT_A,WA_ITEM-MATNR_A,
              WA_ITEM-MEINS,WA_ITEM-ZEILE,WA_ITEM-MBLNR)
        FROM AUFM
        WHERE MBLNR = WA_ITEM-MBLNR
        AND   BWART = BWART1 " '261'
        AND   ZEILE NOT IN TZEILE.
        IF SY-SUBRC = 0.
          SUBTOT_A = SUBTOT_A + WA_ITEM-MENGE_A.
          PERFORM GET_MAKTX USING WA_ITEM-MATNR_A CHANGING WA_ITEM-MAKTX_A ERRNO.
          WA_ITEM-AUFNRID = WA_ITEM_GI-AUFNRID.
          WA_ITEM-CHARGID = WA_ITEM_GI-CHARGID.
          WA_ITEM-BKTXTID = WA_ITEM_GI-BKTXTID.
          WA_ITEM-NOSEQID = WA_ITEM_GI-NOSEQID.

          CLEAR : WA_ITEM-AUFNR, WA_ITEM-MATNR, WA_ITEM-CHARG_JR,
                  WA_ITEM-BLDAT, WA_ITEM-ZLINE, WA_ITEM-PERNR, WA_ITEM-CPUTM,
                  WA_ITEM-ZZTYPE, WA_ITEM-ZZTHICKNESS, WA_ITEM-ZZWIDTH,
                  WA_ITEM-ZZLENGTH, WA_ITEM-ZZNOMORROLL,
                  WA_ITEM-NOSEQ,WA_ITEM-IDNRK_P,WA_ITEM-MAKTX_P,WA_ITEM-CHARG_P,
                  WA_ITEM-MENGE_P,WA_ITEM-LGORT_P."WA_ITEM-MENGE_GR,
          WA_ITEM-STLKN = '999'.
          APPEND WA_ITEM TO TA_ITEM.
        ENDIF.
      ENDSELECT.

      IF SY-SUBRC NE 0.
        PERFORM F_NEW_RAWMAT USING WA_ITEM_GI-AUFNRID  WA_ITEM_GI-BKTXT_JR.
      ENDIF.
    ENDIF.
***  add 26 nop12



    CLEAR : WA_ITEM.
    WA_ITEM-COLOR = 'C311'.
    WA_ITEM-MAKTX_A = 'TOTAL'.
    IF WA_ITEM-MENGE_A NE 0.
      WA_ITEM-PERSEN_A = 100.
    ENDIF.
    WA_ITEM-MENGE_A = SUBTOT_A.
    WA_ITEM-CHARGID = WA_ITEM_JR-CHARG_JR.
    WA_ITEM-AUFNRID = WA_ITEM_JR-AUFNR.
    WA_ITEM-BKTXTID = WA_ITEM_JR-BKTXT_JR.
    WA_ITEM-NOSEQID = WA_ITEM_JR-NOSEQ.
    APPEND WA_ITEM TO TA_ITEM.
  ENDLOOP.


  ITAB[] = TA_ITEM[].
  LOOP AT ITAB.
    ITAB-FLAG = 'O'.
    ITAB-CHARG_JRD = ITAB-CHARG_JR.
    ITAB-CHARG_PD  = ITAB-CHARG_P.
    ITAB-CHARG_AD  = ITAB-CHARG_A.
**  Warna Warni :D
    IF ITAB-MENGE_A = 0 AND ITAB-MAKTX_A NE 'TOTAL'.
      FS_CELL-FIELDNAME = 'MENGE_A' .
      FS_CELL-COLOR-COL = 6.
      FS_CELL-NOKEYCOL = 'X'.
      APPEND FS_CELL TO ITAB-CELL.
    ENDIF.

    READ TABLE  TA_ITEM INTO WA_ITEM WITH KEY AUFNRID = ITAB-AUFNRID
                             CHARGID = ITAB-CHARGID
                             MAKTX_A = 'TOTAL'.

    SUBTOT_A = WA_ITEM-MENGE_A.
    IF SUBTOT_A NE 0.
      ITAB-PERSEN_A = ( ITAB-MENGE_A / SUBTOT_A ) * 100.
      "-> indikator gi
*      IF ITAB-AUFNR NE '' AND ITAB-CHARG_JR NE '' AND ITAB-NOSEQ NE ''.
*        ITAB-IGI = 'X'.
*      ENDIF.
*    ELSEIF SUBTOT_A = 0.
*      "-> indikator gi
*      IF ITAB-AUFNR NE '' AND ITAB-CHARG_JR NE '' AND ITAB-NOSEQ NE ''.
*        ITAB-IGI = 'X'.
*      ENDIF.
    ENDIF.
    MODIFY ITAB .
  ENDLOOP.

  T_CEKLIST[] = ITAB[].
  SORT T_CEKLIST BY AUFNRID CHARGID.
  DELETE ADJACENT DUPLICATES FROM T_CEKLIST COMPARING AUFNRID CHARGID.
  LOOP AT T_CEKLIST INTO W_CEKLIST.
    QTY_JR = 0.
    LOOP AT ITAB WHERE AUFNRID = W_CEKLIST-AUFNRID
                 AND   CHARGID = W_CEKLIST-CHARGID.

      PERFORM F_GET_MATGROUP  USING ITAB-MATNR_A CHANGING MATKL CEK.
      IF ( MATKL+0(1) = '2' OR MATKL+0(4) = '4001' ).
        QTY_JR = QTY_JR + ITAB-MENGE_A.
      ENDIF.
    ENDLOOP.

    "-> indikator gi
    IF QTY_JR NE 0 AND SY-SUBRC = 0.
      LOOP AT ITAB WHERE AUFNR    = W_CEKLIST-AUFNRID
                   AND   CHARG_JR = W_CEKLIST-CHARGID.
        ITAB-IGI = 'X'.
        MODIFY ITAB.
      ENDLOOP.
    ENDIF.


  ENDLOOP.

  CLEAR : OK_CODE,T_CEKLIST,W_CEKLIST,CODE,LOCATION,QTY_JR.
  REFRESH : T_CEKLIST.
  TA_ORI[] = ITAB[].

  DELETE T_CANCEL WHERE XABLN EQ ''.
  LOOP AT T_CANCEL.
    PERFORM F_GET_MATGROUP USING T_CANCEL-MATNR CHANGING MATKL CEK.
    IF MATKL NE '' AND CEK = 'X'.
      DELETE T_CANCEL.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GETZ_DATA
*&---------------------------------------------------------------------*
*&      Form  ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV .
  DATA : LINE TYPE I .
  DESCRIBE TABLE ITAB LINES LINE.

  IF LINE  = 0.
    MESSAGE I002 WITH 'Data tidak ditemukan. cek header text / batch'.
    RETURN.
  ENDIF.


  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " ALV
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .

  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG USING 'ITAB' :
   'IGI'    '' ''  '' '10' 'Indicator GI'   '' ' ' '' ,
   'NOSEQ'    '' ''  '' '11' 'No Sequence JR'   '' ' ' '' ,   "change New Company
   'ZZNOMORROLL'   '' ''  '' '14' 'Nomor JR'   '' ' '  '' ,   "change New Company
   'AUFNR'    '' ''  '' '13' 'No PO'   '' ' ' '' ,
   'BLDAT'   '' ''  '' '10' 'GR Date'   '' ' ' ''  ,
   'CPUTM'    '' ''  '' '10' 'GR Time'   '' ' ' ''  ,
   'PERNR'   '' ''  '' '10' 'NIK'   '' ' ' ''   ,
   'ZLINE'    '' ''  '' '5' 'Group'   '' ' ' ''   ,
   'ZZTYPE'    '' ''  '' '12' 'Type Film'   '' ' ' ''  ,
   'ZZTHICKNESS'    '' ''  '' '12' 'Thickness'   '' ' '  '' ,
   'ZZWIDTH'    '' ''  '' '12' 'Lebar'   '' ' ' ''   ,
   'ZZLENGTH'    '' ''  '' '11' 'Panjang'   '' ' '  ''  ,
   'CHARG_JRD'    '' ''  '' '10' 'Batch GR'   '' ' '  '' ,
   'MENGE_GR'  '' ''  '' '12' 'Qty GR (Kg)'   '' ' ' ''  ,
**----------------- planning -----------------------------------
   'IDNRK_P'   '' ''  '' '15' 'Material PO'   '' ' ' ''  ,
   'MAKTX_P'    '' ''  '' '48' 'Description'   '' ' ' ''  ,
   'CHARG_PD'      '' ''  '' '10' 'Batch GI'   '' ' ' ''  ,
   'MENGE_P'   '' ''  '' '12' 'Qty GI'   '' ' '  '' ,
   'MEINS_P'   '' ''  '' '3' 'UoM GI'   '' ' '  '' ,
   'LGORT_P'    '' ''  '' '7' 'Sloc GI'   '' ' ' ''  ,
**---------------- actual -------------------------------------
*   'ICON'    '' ''  '' '4' 'Status'   '' ' ' ''  , "-> ref1
   'MATNR_A'    '' ''  '' '15' 'Material PO'    ' ' '' '' ,
   'MAKTX_A'    '' ''  '' '48' 'Description'    ' ' '' '' ,
   'CHARG_AD'    '' ''  '' '15' 'Batch GI Revisi'   '' ' ' ''  ,
   'PERSEN_A'  '' ''  '' '8' '%'   '' ' ' ''  ,
   'MENGE_A' '' ''  '' '17' 'Qty GI Revisi'   '' ' ' ''  ,
   'LGORT_A'     '' ''  '' '14' 'Sloc GI Revisi'   '' ' ' ''  .

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
  WA_LAYOUT-INFO_FIELDNAME = 'COLOR'.
  WA_LAYOUT-F2CODE = '&ETA'.
  WA_LAYOUT-NO_COLHEAD =  V_YES.
  WA_LAYOUT-COLTAB_FIELDNAME = 'CELL'.
*  IF RB1 = V_YES. "-> ref1
  WA_LAYOUT-BOX_FIELDNAME = 'CHECKBOX'.
*  ENDIF. "-> ref1
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

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    IMPORTING
      ET_EVENTS = IT_EVT.

  READ TABLE IT_EVT INTO WA_EVT
       WITH KEY NAME = SLIS_EV_AFTER_LINE_OUTPUT .
  WA_EVT-FORM = SLIS_EV_AFTER_LINE_OUTPUT .
  MODIFY IT_EVT FROM WA_EVT INDEX SY-TABIX .

  READ TABLE IT_EVT INTO WA_EVT
       WITH KEY NAME = SLIS_EV_TOP_OF_PAGE .
  WA_EVT-FORM = SLIS_EV_TOP_OF_PAGE .
  MODIFY IT_EVT FROM WA_EVT INDEX SY-TABIX .

  LOOP AT T_FIELDCAT WHERE FIELDNAME = 'PERSEN_A' OR
                           FIELDNAME = 'MENGE_A' OR
                           FIELDNAME = 'CHARG_JRD' OR
                           FIELDNAME = 'CHARG_PD' OR
                           FIELDNAME = 'CHARG_AD'.
    T_FIELDCAT-NO_ZERO = V_NO.
    MODIFY T_FIELDCAT.
  ENDLOOP.


  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = IT_EVT[]
*     IT_EVENT_EXIT            = T_EVENT_EXIT[]
*     I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
*     IS_VARIANT               = WA_VARIANTE
*     IS_PRINT                 = T_PRINT
*     IT_SORT                  = T_SORT[]
*     IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = ITAB[]
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE .

  SKIP.

*  IF RB1 = V_YES. "-> ref1
  "- header1
  ULINE AT 164(387).
  WRITE : /163 SY-VLINE .
  FORMAT COLOR COL_GROUP INTENSIFIED ON.
  WRITE : 164 '                                             PLANNING                                           '   .
  WRITE : 264 SY-VLINE  .
  FORMAT COLOR COL_NEGATIVE INTENSIFIED ON.
  WRITE : 265 '                                                   ACTUAL                                                  '.
  WRITE : 387 SY-VLINE.

  "-header2
  WRITE : / '|' .
  ULINE AT 1(387).
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE : /1 '|',
           2 'Indikator GI',
           14 SY-VLINE,
           15 'No Sequence JR',
           26 SY-VLINE,         "change New Company
           27 '  Nomor JR',     "change New Company
           41 SY-VLINE,
           42 '     No Po     ',
           55 SY-VLINE,
           56 '  GR Date ',
           66 SY-VLINE,
           67 '  GR Time ',
           77 SY-VLINE,
           78 '   NIK    ',
           88 SY-VLINE,
           89 'Group',
           94 SY-VLINE,
           95 'Type Film',
           105 SY-VLINE,
           106 'Thickness',
           116 SY-VLINE,
           117 ' Lebar   ',
           127 SY-VLINE,
           128 '  Panjang ',
           139 SY-VLINE,
           140 'Batch GR',
           150 SY-VLINE,
           151 ' Qty GR (Kg) '.


  WRITE : 163 SY-VLINE .
  FORMAT COLOR COL_GROUP INTENSIFIED ON.
  WRITE : 164 '  Material PO  ',
          179 SY-VLINE,
          180 '             Description',
          228 SY-VLINE,
          229 'Batch GI',
          239 SY-VLINE,
          240 ' Qty GI ',
          252 SY-VLINE,
          253 'UoM',
          256 SY-VLINE,
          257 'Sloc GI'.

  WRITE : 264 SY-VLINE  .
  FORMAT COLOR COL_NEGATIVE INTENSIFIED ON.
  WRITE : 265 '  Material PO' ,
          280 SY-VLINE,
          281 '              Description',
          329 SY-VLINE,
          330 ' Batch GI Revisi',
          345 SY-VLINE,
          346 '   %',
          354 SY-VLINE,
          355 ' Qty GI Revisi',
          372 SY-VLINE,
          373 'Sloc GI Revisi',
          387 SY-VLINE.

**  ref1 ******************************
**  ELSEIF RB2 = V_YES.
**
****  header1
**    ULINE AT 137(343).
**    WRITE : /137 SY-VLINE .
**    FORMAT COLOR COL_GROUP INTENSIFIED ON.
**    WRITE : 140 '                                        PLANNING                                           '   .
**    WRITE : 234 SY-VLINE  .
**    FORMAT COLOR COL_NEGATIVE INTENSIFIED ON.
**    WRITE : 235 '                                                 ACTUAL                                                  '.
**    WRITE : 345 SY-VLINE.
**
**    "-header2
**    WRITE : / '|' .
**    ULINE AT 1(348).
**    FORMAT COLOR COL_HEADING INTENSIFIED ON.
**    WRITE : /1 '|',
**             2 '     No Po     ',
**             15 SY-VLINE,
**             16 '  GR Date ',
**             26 SY-VLINE,
**             27 '  GR Time ',
**             37 SY-VLINE,
**             38 '   NIK    ',
**             48 SY-VLINE,
**             49 'Group',
**             54 SY-VLINE,  "
**             55 ' Type Film ',
**             65 SY-VLINE,
**             66 ' Thickness',
**             76 SY-VLINE,
**             77 '  Lebar   ',
**             87 SY-VLINE,
**             88 '  Panjang ',
**             99 SY-VLINE,
**             101 ' Batch GR ',
**             110 SY-VLINE,
**             111 '  Nomor JR  ',
**             124 SY-VLINE,
**             130 'Qty GR (Kg) '.
**
**
**    WRITE : 137 SY-VLINE .
**    FORMAT COLOR COL_GROUP INTENSIFIED ON.
**    WRITE : 138 '  Material PO  ',
**            153 SY-VLINE,
**            154 '             Description',
**            202 SY-VLINE,
**            203 '   Batch  ',
**            213 SY-VLINE,
**            214 ' Qty PO(Kg) ',
**            226 SY-VLINE,
**            229 'Sloc '.
**
**    WRITE : 234 SY-VLINE  .
**    FORMAT COLOR COL_NEGATIVE INTENSIFIED ON.
**    WRITE : 235 'Status',
**            239 SY-VLINE,
**            240 '  Material GI' ,
**            255 SY-VLINE,
**            256 '              Description',
**            304 SY-VLINE,
**            305 ' Batch GI',
**            315 SY-VLINE,
**            316 '   %',
**            324 SY-VLINE,
**            325 ' Qty GI(Kg)',
**            337 SY-VLINE,
**            338 'Sloc GI',
**            345 SY-VLINE.
**
**  ENDIF.
ENDFORM.                    "top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EXTAB   text
*----------------------------------------------------------------------*
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB .
  CLEAR : FT_EXTAB.
  REFRESH : FT_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING FT_EXTAB.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_UCOMM     text
*      -->FU_SELFIELD  text
*----------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
    WHEN '&CHECKLIST'.
***************  ref1 ***********************************************************
*      IF T_CEKLIST IS NOT INITIAL.
*        MESSAGE I000.
*        RETURN.
*      ELSE.
*        READ TABLE ITAB WITH KEY CHECKBOX = V_YES.
*        IF SY-SUBRC NE 0.
*          MESSAGE I001.
*          RETURN.
*        ENDIF.
*      ENDIF.
*
*      TA_ITEM[] = TA_ITEM_JR[] = ITAB[].
*      DELETE TA_ITEM WHERE CHECKBOX NE V_YES.
*      SORT TA_ITEM BY AUFNRID CHARGID.
*      DELETE ADJACENT DUPLICATES FROM TA_ITEM COMPARING AUFNRID CHARGID.
*
*      CODE = 'P'. "=> di buat p biar cari sloc aja
*      LOOP AT TA_ITEM INTO WA_ITEM.
*        LOOP AT TA_ITEM_JR INTO WA_ITEM_JR WHERE  AUFNRID = WA_ITEM-AUFNRID
*                                         AND    CHARGID = WA_ITEM-CHARGID.
***    cari sloc kalo
*          IF WA_ITEM_JR-LGORT_A = V_NO.
*            PERFORM CEK_RAWMAT USING WA_ITEM_JR-MATNR_A WA_ITEM_JR-WERKS ''  ''
*                               CHANGING WA_ITEM_JR-LGORT_A MENGE  CHARG  ERRNO.
*          ENDIF.
*
*
*          MOVE-CORRESPONDING WA_ITEM_JR TO W_CEKLIST.
*          APPEND W_CEKLIST TO T_CEKLIST.
*        ENDLOOP.
*      ENDLOOP.
*
**     filter data cancelan sesuai data yang dipilih
*      LOOP AT T_CANCEL.
*        READ TABLE TA_ITEM INTO WA_ITEM WITH KEY AUFNRID = T_CANCEL-AUFNR
*                                                     CHARGID = T_CANCEL-CHARG.
*        IF SY-SUBRC NE 0.
*          DELETE T_CANCEL WHERE AUFNR = T_CANCEL-AUFNR
*                          AND   CHARG = T_CANCEL-CHARG.
*        ENDIF.
*      ENDLOOP.
*
*      DELETE T_CEKLIST WHERE MAKTX_A = 'TOTAL'.
*      CLEAR : CODE,WERKS,ERRNO,BKTXTID,MENGE,CHARG,ERRNO,ZZCODE,ZZLINE,COUNT_CLICK,
*              TA_EXCEL,WA_EXCEL,T_CANCEL.
*      CALL SCREEN 100.
*******   ref1***********************************************************************
    WHEN '&EXPORT'.
      PERFORM F_FILTER.
      PERFORM F_EXPORT.
      ITAB[] = TA_ORI[].

    WHEN '&IMPORT'.
      PERFORM F_IMPORT2.
    WHEN '&SAVE'.
      IF CODE NE 'I'.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR              = 'Konfirmasi'
            TEXT_QUESTION         = 'Tidak ada data yang diupload. Mau GI dengan data di layar ?'
            TEXT_BUTTON_1         = 'Ya'
            TEXT_BUTTON_2         = 'Tidak'
            DEFAULT_BUTTON        = '1'
            DISPLAY_CANCEL_BUTTON = ''
          IMPORTING
            ANSWER                = P_ANSWER.
        IF P_ANSWER = '1'.
          PERFORM F_FILTER.
        ELSE.
          RETURN.
        ENDIF.
      ENDIF.

      PERFORM F_SAVE.
    WHEN '&REFRESH' .
      PERFORM RESET_ALL USING FU_UCOMM.
    WHEN '&UP' OR '&BACK'.
      PERFORM RESET_ALL USING FU_UCOMM.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  RESET_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_UCOMM  text
*----------------------------------------------------------------------*
FORM RESET_ALL  USING    P_UCOMM.
  CLEAR : ITAB,TA_ITEM,WA_ITEM,TA_ITEM_JR,WA_ITEM_JR,TA_ITEM_GI,WA_ITEM_GI,TA_BOM,WA_BOM,
          T_CEKLIST,W_CEKLIST,TA_EXCEL,WA_EXCEL,CODE,ZZCODE,ZZLINE,COUNT_CLICK,
          ZZLENGTH,ZZWIDTH,ZZCOATING_WEIGHT,T_CANCEL,LOCATION,QTY_JR.
  REFRESH : ITAB,TA_ITEM,TA_ITEM_JR,TA_ITEM_GI,TA_BOM,T_CEKLIST,TA_EXCEL,T_CANCEL, TA_ORI.

  IF P_UCOMM = '&REFRESH'.
    PERFORM GETZ_DATA USING ''.
    PERFORM ALV.
  ENDIF.
  LEAVE SCREEN.
ENDFORM.                    " RESET_ALL
*&---------------------------------------------------------------------*
*&      Form  GET_MAKTX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MATNR  text
*      <--P_MAKTX  text
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
FORM GET_MAKTX  USING    P_MATNR
                CHANGING P_MAKTX
                         P_ERRNO.
  CLEAR : P_MAKTX, P_ERRNO.
  SELECT SINGLE MAKTX INTO P_MAKTX
    FROM MAKT
    WHERE SPRAS = 'EN'
    AND   MATNR = P_MATNR.
  P_ERRNO = SY-SUBRC.
ENDFORM.                    " GET_MAKTX
*&---------------------------------------------------------------------*
*&      Form  F_FILTER_DATA_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FILTER_DATA_2 .
  CLEAR : T_CANCEL.
  LOOP AT T_CEKLIST INTO W_CEKLIST.
    SELECT SINGLE
          AUFK~AUFNR
          AUFK~WERKS
          AFPO~MATNR
          AUFK~ZLINE
          AFKO~STLTY
          AFKO~STLST
          AFKO~STLNR
          AFKO~STLAL
   INTO (WA_ITEM_JR-AUFNR,WA_ITEM_JR-WERKS,WA_ITEM_JR-MATNR,WA_ITEM_JR-ZLINE,
          WA_ITEM_JR-STLTY,WA_ITEM_JR-STLST,WA_ITEM_JR-STLNR,WA_ITEM_JR-STLAL)
   FROM AUFK
   JOIN AFPO ON AUFK~AUFNR = AFPO~AUFNR
   JOIN AFKO ON AUFK~AUFNR = AFKO~AUFNR
   WHERE AUFK~AUFNR = W_CEKLIST-AUFNRID
   AND   AUFK~AUART IN ('ZP01','ZP02','ZP03','ZP04','ZP05','ZP06','ZP07','ZP08','ZP09','ZP10','ZP12','ZTR1','ZTR2',
                        'ZTR3','ZTR4','ZTR5','ZTR6','ZTR7',     "ADDED EXLAM 11.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
                        " Added by William at 24.07.2022 (OPP7 CPP1)
                        'ZP13','ZP14','ZP15','ZP16','ZP17','ZP18',
                        'ZTR8','ZTR9','ZTRA','ZTRB','ZTRC',
                        " End added by William at 24.07.2022 (OPP7 CPP1)
                        "Added by Ryan at 05.01.2025 (Laminator #2 #3)
                        'ZTRD')
                        "END added by Ryan at 05.01.2025 (Laminator #2 #3)
   AND   AFPO~MATNR = W_CEKLIST-MATNR.

    CLEAR : MBLNR,MJAHR,ZEILE.

* gr date , gr time, qty gr yang ga di cancel
    SELECT  MKPF~BKTXT MKPF~BLDAT MKPF~CPUTM AUFM~MENGE AUFM~CHARG AUFM~MBLNR AUFM~MJAHR AUFM~ZEILE
            AUFM~MEINS
      INTO (WA_ITEM_JR-BKTXT_JR, WA_ITEM_JR-BLDAT, WA_ITEM_JR-CPUTM, WA_ITEM_JR-MENGE_GR, WA_ITEM_JR-CHARG_JR,
            MBLNR, MJAHR, ZEILE,WA_ITEM_JR-MEINS)
      FROM MKPF
      JOIN AUFM ON MKPF~MBLNR = AUFM~MBLNR
      WHERE AUFM~AUFNR = W_CEKLIST-AUFNRID
      AND   AUFM~CHARG = W_CEKLIST-CHARGID
      AND   AUFM~BWART = '101'.
*      %_HINTS ORACLE 'INDEX("AUFM" "AUFM~Z07")'.


      IF MBLNR NE V_NO.
        SELECT SINGLE MBLNR INTO MBLNR
           FROM AUFM
           WHERE MBLNR = MBLNR
           AND   MJAHR = MJAHR
           AND   ZEILE = ZEILE
           AND   BWART = '102'.
*         %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.

        IF SY-SUBRC = 0.
*          EXIT.
          CLEAR : WA_ITEM_JR-BKTXT_JR, WA_ITEM_JR-BLDAT, WA_ITEM_JR-CPUTM, WA_ITEM_JR-MENGE_GR, WA_ITEM_JR-CHARG_JR,
           MBLNR, MJAHR, ZEILE.
        ENDIF.
      ENDIF.

      CHECK WA_ITEM_JR-BLDAT NE '00000000' AND   WA_ITEM_JR-BKTXT_JR NE '' .

*    nik
      SELECT  AFRU~VORNR AFRU~IEDD AFRU~IEDZ INTO (WA_ITEM_JR-VORNR,IEDD,IEDZ)
        FROM AFRU
        WHERE AFRU~AUFNR = WA_ITEM_JR-AUFNR
      ORDER BY VORNR ASCENDING.
      ENDSELECT.

      SELECT SINGLE AFRU~PERNR INTO WA_ITEM_JR-PERNR
        FROM AFRU
        WHERE AFRU~AUFNR = WA_ITEM_JR-AUFNR
        AND   AFRU~VORNR = WA_ITEM_JR-VORNR
        AND   AFRU~PERNR NE ''.

      SELECT SINGLE ZZGROUP INTO WA_ITEM_JR-ZLINE
        FROM ZGROUP
        WHERE ZZTANGGAL =  IEDD
        AND  ( ZZJAM_MASUK < IEDZ AND  ZZJAM_KELUAR > IEDZ ).

*    Characteristic batch jumbo roll
      CLEAR : ITAB_VALUES.
      REFRESH : ITAB_VALUES.
      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR    = WA_ITEM_JR-MATNR
          I_VAL_CHARGE   = WA_ITEM_JR-CHARG_JR
          I_DATE         = SY-DATUM
        TABLES
          T_VAL_TAB      = ITAB_VALUES
        EXCEPTIONS
          NO_CLASS       = 1
          INTERNAL_ERROR = 2
          NO_VALUES      = 3
          NO_CHARS       = 4
          OTHERS         = 5.
      IF SY-SUBRC <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

      ELSE.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTYPE'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZTYPE = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTHICKNESS'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZTHICKNESS = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZWIDTH'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZWIDTH = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLENGTH'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZLENGTH = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZNOMORROLL'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZNOMORROLL = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCODE'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZCODE = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZPRODLINE'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZLINE = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCOATING_WEIGHT'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-ZZCOATING_WEIGHT = ITAB_VALUES-ATWRT.
        ENDIF.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZSEQUENCENBR'.
        IF SY-SUBRC EQ 0.
          WA_ITEM_JR-NOSEQ = ITAB_VALUES-ATWRT.
        ENDIF.

      ENDIF.

      MOVE-CORRESPONDING WA_ITEM_JR TO WA_ITEM.
      APPEND WA_ITEM TO TA_ITEM.
    ENDSELECT.  "- END SELECT ORDER

  ENDLOOP.

  SORT TA_ITEM BY AUFNR CHARG_JR.
  DELETE ADJACENT DUPLICATES FROM TA_ITEM COMPARING AUFNR CHARG_JR.
ENDFORM.                    " F_FILTER_DATA_1
*&---------------------------------------------------------------------*
*&      Form  F_FILTER_DATA_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FILTER_DATA_1 .
* gr date , gr time, qty gr yang ga di cancel
  SELECT  MKPF~BKTXT MKPF~BLDAT MKPF~CPUTM AUFM~MENGE AUFM~CHARG AUFM~MBLNR AUFM~MJAHR AUFM~ZEILE AUFM~AUFNR
          AUFM~MATNR AUFK~WERKS AUFK~ZLINE AUFM~MEINS
    INTO (WA_ITEM_JR-BKTXT_JR, WA_ITEM_JR-BLDAT, WA_ITEM_JR-CPUTM, WA_ITEM_JR-MENGE_GR, WA_ITEM_JR-CHARG_JR,
          MBLNR, MJAHR, ZEILE , WA_ITEM_JR-AUFNR,WA_ITEM_JR-MATNR,WA_ITEM_JR-WERKS,WA_ITEM_JR-ZLINE,
          WA_ITEM_JR-MEINS)
    FROM MKPF
    JOIN AUFM ON MKPF~MBLNR = AUFM~MBLNR
    JOIN AUFK ON AUFM~AUFNR = AUFK~AUFNR
    WHERE  AUFM~CHARG IN S_CHARG
    AND    AUFM~BWART = '101'
    AND    AUFM~MATNR IN S_MATNR
    AND    MKPF~BLDAT IN S_BLDAT
    AND    AUFK~AUFNR IN S_AUFNR
    AND    AUFK~ZLINE IN S_ZLINE
    AND    AUFK~AUART IN ('ZP01','ZP02','ZP03','ZP04','ZP05','ZP06','ZP07','ZP08','ZP09','ZP10','ZP12','ZTR1','ZTR2',
                          'ZTR3','ZTR4','ZTR5','ZTR6','ZTR7',     "ADDED EXLAM 11.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
                          " Added by William at 24.07.2022 (OPP7 CPP1)
                          'ZP13','ZP14','ZP15','ZP16','ZP17','ZP18',
                          'ZTR8','ZTR9','ZTRA','ZTRB','ZTRC',
                          " End added by William at 24.07.2022 (OPP7 CPP1)
                          "Added by Ryan at 05.01.2025 (Laminator #2 #3)
                          'ZTRD').
                          "END added by Ryan at 05.01.2025 (Laminator #2 #3)
*    %_HINTS ORACLE 'INDEX("AUFM" "AUFM~Z07")'.


    IF MBLNR NE V_NO.
      SELECT SINGLE MBLNR INTO MBLNR
         FROM MSEG
         WHERE SMBLN = MBLNR
         AND   SJAHR = MJAHR
         AND   SMBLP = ZEILE
         AND   BWART = '102'.
*       %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.

      IF SY-SUBRC = 0.
*          EXIT.
        CLEAR : WA_ITEM_JR-BKTXT_JR, WA_ITEM_JR-BLDAT, WA_ITEM_JR-CPUTM, WA_ITEM_JR-MENGE_GR, WA_ITEM_JR-CHARG_JR,
         MBLNR, MJAHR, ZEILE.
      ENDIF.
    ENDIF.

    CLEAR : MBLNR,MJAHR,ZEILE.
    CHECK WA_ITEM_JR-BLDAT NE '00000000' AND   WA_ITEM_JR-BKTXT_JR NE '' .

    APPEND WA_ITEM_JR TO TA_ITEM_JR.
    CLEAR : WA_ITEM_JR.
  ENDSELECT.  "- END SELECT ORDER


  DELETE TA_ITEM_JR WHERE BLDAT = '00000000'.
  SORT TA_ITEM_JR BY AUFNR CHARG_JR.
  DELETE ADJACENT DUPLICATES FROM TA_ITEM_JR COMPARING AUFNR CHARG_JR.

  LOOP AT TA_ITEM_JR INTO WA_ITEM_JR.
* no po, batch , material, line
    SELECT SINGLE
*           AUFK~AUFNR AS AUFNR
*           AUFK~WERKS AS WERKS
**           AFPO~MATNR AS MATNR
*           AUFK~ZLINE AS ZLINE
           AFKO~STLTY AS STLTY "bom category
           AFKO~STLST AS STLST " bom status
           AFKO~STLNR AS STLNR " bom
           AFKO~STLAL AS STLAL " alternative
    INTO  (WA_ITEM_JR-STLTY,
          WA_ITEM_JR-STLST,WA_ITEM_JR-STLNR,WA_ITEM_JR-STLAL)
     FROM AFKO
     WHERE AFKO~AUFNR = WA_ITEM_JR-AUFNR.
*    FROM AUFK
*    JOIN AFPO ON AUFK~AUFNR = AFPO~AUFNR
*    JOIN AFKO ON AUFK~AUFNR = AFKO~AUFNR
*    WHERE AUFK~AUFNR EQ WA_ITEM_JR-AUFNR
*    AND   AUFK~AUFNR IN S_AUFNR
*    AND   AUFK~ZLINE IN S_ZLINE
*    AND   AUFK~AUART IN ('ZP01','ZP02','ZP03','ZP04','ZP05','ZP06','ZP07','ZP08','ZP09','ZP10','ZTR1','ZTR2').

*    nik
    SELECT  AFRU~VORNR AFRU~IEDD AFRU~IEDZ INTO (WA_ITEM_JR-VORNR,IEDD,IEDZ)
      FROM AFRU
      WHERE AFRU~AUFNR = WA_ITEM_JR-AUFNR
    ORDER BY VORNR ASCENDING.
    ENDSELECT.

    SELECT SINGLE AFRU~PERNR INTO WA_ITEM_JR-PERNR
      FROM AFRU
      WHERE AFRU~AUFNR = WA_ITEM_JR-AUFNR
      AND   AFRU~VORNR = WA_ITEM_JR-VORNR
      AND   AFRU~PERNR NE ''.

    SELECT SINGLE ZZGROUP INTO WA_ITEM_JR-ZLINE
      FROM ZGROUP
      WHERE ZZTANGGAL =  IEDD
      AND  ( ZZJAM_MASUK < IEDZ AND  ZZJAM_KELUAR > IEDZ ).

*    Characteristic batch jumbo roll
    CHECK WA_ITEM_JR-MATNR NE '' AND WA_ITEM_JR-CHARG_JR NE ''.
    CLEAR : ITAB_VALUES.
    REFRESH : ITAB_VALUES.
    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
      EXPORTING
        I_VAL_MATNR    = WA_ITEM_JR-MATNR
        I_VAL_CHARGE   = WA_ITEM_JR-CHARG_JR
        I_VAL_WERKS    = WA_ITEM_JR-WERKS
        I_DATE         = SY-DATUM
      TABLES
        T_VAL_TAB      = ITAB_VALUES
      EXCEPTIONS
        NO_CLASS       = 1
        INTERNAL_ERROR = 2
        NO_VALUES      = 3
        NO_CHARS       = 4
        OTHERS         = 5.

    CHECK SY-SUBRC = 0.
    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZTYPE = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTHICKNESS'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZTHICKNESS = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZWIDTH = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZLENGTH = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZNOMORROLL'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZNOMORROLL = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCODE'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZCODE = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZPRODLINE'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZLINE = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCOATING_WEIGHT'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-ZZCOATING_WEIGHT = ITAB_VALUES-ATWRT.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZSEQUENCENBR'.
    IF SY-SUBRC EQ 0.
      WA_ITEM_JR-NOSEQ = ITAB_VALUES-ATWRT.
    ENDIF.

    MOVE-CORRESPONDING WA_ITEM_JR TO WA_ITEM.
    APPEND WA_ITEM TO  TA_ITEM.
  ENDLOOP.

ENDFORM.                    " F_FILTER_DATA_1
*&---------------------------------------------------------------------*
*&      Form  F_CHOOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ANSWER  text
*----------------------------------------------------------------------*
FORM F_CHOOSE  CHANGING P_ANSWER.
  DATA: CHOICES LIKE SPOPLI OCCURS 3 WITH HEADER LINE.

  CHOICES-VAROPTION = 'TXT / Notepad'(ASC).              APPEND CHOICES.
  CHOICES-VAROPTION = 'SpreadSheet'(DAT).                APPEND CHOICES.

  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
    EXPORTING
      CURSORLINE = 1
      TITEL      = 'Tipe File'
      TEXTLINE1  = ''
    IMPORTING
      ANSWER     = P_ANSWER
    TABLES
      T_SPOPLI   = CHOICES.

  CASE P_ANSWER.
    WHEN 'A'.
      EXIT.
  ENDCASE.
ENDFORM.                    " F_CHOOSE
*&---------------------------------------------------------------------*
*&      Form  F_IMPORT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_IMPORT2 .
  DATA: FNAME TYPE STRING,
        FPATH TYPE IBIPPARMS-PATH,
        MATNR_GR TYPE MSEG-MATNR,
        MENGE_GR TYPE MSEG-MENGE,
        CHARGID  TYPE MSEG-CHARG,
        IDX TYPE P,
        L_V_LENGTH TYPE I,
        TIPE TYPE STRING.

  CLEAR : CODE, LOCATION,QTY_JR.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = FPATH.
  CHECK FPATH NE ''.

  MOVE FPATH TO FNAME.
  TRANSLATE FNAME TO UPPER CASE.
  L_V_LENGTH = STRLEN( FNAME ).
  L_V_LENGTH = L_V_LENGTH - 4.
  TIPE = FNAME+L_V_LENGTH(4).
  IF TIPE NE '.TXT'.
    MESSAGE W002 WITH 'Format File Harus .TXT'.
    CLEAR : OK_CODE.
    RETURN.
  ENDIF.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = TA_EXCEL.
  IF SY-SUBRC NE 0.
    CLEAR : OK_CODE.
    MESSAGE I004.
    RETURN.
  ELSE.
    IF TA_EXCEL IS INITIAL.
      MESSAGE W002 WITH 'Isi File Tidak boleh Kosong'.
      RETURN.
    ENDIF.
    CODE = 'I'.
    LOCATION = FNAME.
    MESSAGE S002 WITH 'Import File' LOCATION 'Sukses'.
  ENDIF.


  DELETE TA_EXCEL WHERE AUFNRID = ''.
  SORT TA_EXCEL BY AUFNRID CHARGID.
  DESCRIBE TABLE TA_EXCEL LINES LINE.
  IDX = 0.
  LOOP AT TA_EXCEL INTO WA_EXCEL.
    IDX = IDX + 1.
    V_PERCENT  = ( SY-TABIX / LINE ) * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = V_PERCENT
        TEXT       = 'Cek Data Upload'.

    IF WA_EXCEL-MEINS = ''.
      MESSAGE W002 WITH 'Unit Satuan tidak boleh kosong' WA_EXCEL-AUFNRID WA_EXCEL-CHARGID.
      RETURN.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = WA_EXCEL-MEINS
      IMPORTING
        OUTPUT = WA_EXCEL-MEINS.
    IF SY-SUBRC NE 0.
      MESSAGE W002 WITH 'Unit satuan tidak wajar' WA_EXCEL-AUFNRID WA_EXCEL-CHARGID.
    ENDIF.

    IF WA_EXCEL-AUFNRID = ''.
      MESSAGE W002 WITH 'Order tidak boleh kosong' WA_EXCEL-AUFNRID WA_EXCEL-CHARGID.
      RETURN.
    ENDIF.

    IF WA_EXCEL-CHARGID = ''.
      MESSAGE W002 WITH 'Batch Jumbo Roll tidak boleh kosong' WA_EXCEL-AUFNRID WA_EXCEL-CHARGID.
      RETURN.
    ENDIF.

    TRANSLATE  WA_EXCEL-MATNR_A TO UPPER CASE.
    TRANSLATE  WA_EXCEL-MAKTX_A TO UPPER CASE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_EXCEL-CHARGID
      IMPORTING
        OUTPUT = WA_EXCEL-CHARGID.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_EXCEL-CHARG_A
      IMPORTING
        OUTPUT = WA_EXCEL-CHARG_A.

    REPLACE ALL OCCURRENCES OF ',' IN WA_EXCEL-MENGE_GR WITH '.'.
    REPLACE ALL OCCURRENCES OF ',' IN WA_EXCEL-MENGE_A WITH '.'.


    PERFORM F_GET_MATGROUP USING WA_EXCEL-MATNR_A CHANGING MATKL CEK.
    IF MATKL = ''.
      MESSAGE W018 WITH WA_EXCEL-AUFNRID WA_EXCEL-CHARGID WA_EXCEL-MATNR_A 'Tidak ada material group'.
      RETURN.
    ENDIF.

    IF CEK = 'X'.
      WA_EXCEL-MATNR_A = 'DELETEHAPUS'.
    ENDIF.

    MODIFY TA_EXCEL FROM WA_EXCEL INDEX IDX.
  ENDLOOP.

  DELETE TA_EXCEL WHERE MATNR_A = 'DELETEHAPUS'.

  TA_ITEM[] = ITAB[].
  SORT TA_ITEM BY AUFNRID CHARGID.
  DELETE ADJACENT DUPLICATES FROM TA_ITEM COMPARING AUFNRID CHARGID.

  CLEAR : T_CEKLIST, W_CEKLIST.
  REFRESH : T_CEKLIST.
  DESCRIBE TABLE TA_ITEM LINES LINE.
  LOOP AT TA_ITEM INTO WA_ITEM.

    V_PERCENT  = ( SY-TABIX / LINE ) * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = V_PERCENT
        TEXT       = 'Upload File'.

    LOOP AT TA_EXCEL INTO WA_EXCEL WHERE AUFNRID = WA_ITEM-AUFNRID
                                   AND   CHARGID = WA_ITEM-CHARGID.

      MOVE-CORRESPONDING WA_EXCEL TO W_CEKLIST.

      READ TABLE ITAB  WITH KEY AUFNRID = WA_ITEM-AUFNRID
                                CHARGID = WA_ITEM-CHARGID.
      IF SY-SUBRC = 0.
        MATNR_GR         = ITAB-MATNR.
        BKTXTID          = ITAB-BKTXTID.
        WERKS            = ITAB-WERKS.
        ZZLINE           = ITAB-ZZLINE.
        ZZCODE           = ITAB-ZZCODE.
        ZZLENGTH         = ITAB-ZZLENGTH.
        ZZWIDTH          = ITAB-ZZWIDTH.
        ZZCOATING_WEIGHT = ITAB-ZZCOATING_WEIGHT.
      ENDIF.

      W_CEKLIST-WERKS            = WERKS.
      W_CEKLIST-BKTXT_JR         = W_CEKLIST-BKTXTID = BKTXTID.
      W_CEKLIST-ZZLINE           = ZZLINE.
      W_CEKLIST-ZZCODE           = ZZCODE.
      W_CEKLIST-ZZLENGTH         = ZZLENGTH.
      W_CEKLIST-ZZWIDTH          = ZZWIDTH.
      W_CEKLIST-ZZCOATING_WEIGHT = ZZCOATING_WEIGHT.
      W_CEKLIST-MATNR            = MATNR_GR.

      PERFORM GET_MAKTX USING W_CEKLIST-MATNR_A CHANGING W_CEKLIST-MAKTX_A ERRNO.
      APPEND W_CEKLIST TO T_CEKLIST.
    ENDLOOP.

    IF SY-SUBRC = 0.  "-> sesuai dengan order & batch di excel
      "-> tampilin yang material group kepala 3
      LOOP AT ITAB WHERE AUFNRID = WA_ITEM-AUFNRID
                   AND   CHARGID = WA_ITEM-CHARGID.
        CLEAR : MATKL.
        SELECT SINGLE MATKL INTO MATKL
          FROM MARA
          WHERE MATNR = ITAB-MATNR_A.
        IF MATKL+0(1) = '3'.
          MOVE-CORRESPONDING ITAB TO W_CEKLIST.
          APPEND W_CEKLIST TO T_CEKLIST.
        ELSEIF MATKL+0(1) = '4'.
          CASE MATKL.
            WHEN '400001' OR '400002' OR '400003' OR '400004' OR '400005' OR '400006'
            OR '400007' OR '40008' OR '400009' OR '400010' OR '400011' OR '400012'
            OR '400013' OR '400015' OR '400016' OR '400017' OR '400018'.  " Added by William at 24.07.2022 (OPP7 CPP1)
              MOVE-CORRESPONDING ITAB TO W_CEKLIST.
              APPEND W_CEKLIST TO T_CEKLIST.
          ENDCASE.
        ENDIF.

      ENDLOOP.
    ENDIF.


  ENDLOOP.

  IF T_CEKLIST IS INITIAL.
    CLEAR : LOCATION,CODE.
    MESSAGE W002 WITH 'Jumbo roll yang diupload tidak ada' 'yang sesuai dengan list di report'.
    RETURN.
  ENDIF.
  TA_ITEM[] = T_CEKLIST[].
  SORT TA_ITEM BY AUFNRID CHARGID.
  DELETE ADJACENT DUPLICATES FROM TA_ITEM COMPARING AUFNRID CHARGID.
  DESCRIBE TABLE TA_ITEM LINES QTY_JR.

*     filter data cancelan sesuai data yang dipilih
  LOOP AT T_CANCEL.
    READ TABLE T_CEKLIST  INTO W_CEKLIST WITH KEY AUFNRID = T_CANCEL-AUFNR
                                                  CHARGID = T_CANCEL-CHARG.
    IF SY-SUBRC NE 0.
      DELETE T_CANCEL WHERE AUFNR = T_CANCEL-AUFNR
                      AND   CHARG = T_CANCEL-CHARG.
    ENDIF.
  ENDLOOP.

  CLEAR : OK_CODE.
ENDFORM.                    " F_IMPORT2
*&---------------------------------------------------------------------*
*&      Form  F_FILTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FILTER .
  CLEAR : T_CEKLIST.
  IF T_CEKLIST IS NOT INITIAL.
    MESSAGE I000.
    RETURN.
  ELSE.
    READ TABLE ITAB WITH KEY CHECKBOX = V_YES.
    IF SY-SUBRC NE 0.
      MESSAGE I001.
      RETURN.
    ENDIF.
  ENDIF.

  TA_ITEM[] = TA_ITEM_JR[] = ITAB[].
  DELETE TA_ITEM WHERE CHECKBOX NE V_YES.
  SORT TA_ITEM BY AUFNRID CHARGID.
  DELETE ADJACENT DUPLICATES FROM TA_ITEM COMPARING AUFNRID CHARGID.

  CODE = 'P'. "=> di buat p biar cari sloc aja
  LOOP AT TA_ITEM INTO WA_ITEM.
    LOOP AT TA_ITEM_JR INTO WA_ITEM_JR WHERE  AUFNRID = WA_ITEM-AUFNRID
                                     AND    CHARGID = WA_ITEM-CHARGID.
**    cari sloc kalo
      IF WA_ITEM_JR-LGORT_A = V_NO.
        PERFORM CEK_RAWMAT USING WA_ITEM_JR-MATNR_A WA_ITEM_JR-WERKS ''  ''
                           CHANGING WA_ITEM_JR-LGORT_A MENGE  CHARG  ERRNO.
      ENDIF.

      MOVE-CORRESPONDING WA_ITEM_JR TO W_CEKLIST.
      PERFORM F_GET_MATGROUP USING WA_ITEM_JR-MATNR_A CHANGING  W_CEKLIST-MATKL CEK.
      APPEND W_CEKLIST TO T_CEKLIST.
    ENDLOOP.
  ENDLOOP.

*     filter data cancelan sesuai data yang dipilih
  LOOP AT T_CANCEL.
    READ TABLE T_CEKLIST  INTO W_CEKLIST WITH KEY AUFNRID = T_CANCEL-AUFNR
                                                  CHARGID = T_CANCEL-CHARG.
    IF SY-SUBRC NE 0.
      DELETE T_CANCEL WHERE AUFNR = T_CANCEL-AUFNR
                      AND   CHARG = T_CANCEL-CHARG.
    ENDIF.
  ENDLOOP.

  DELETE T_CEKLIST WHERE MAKTX_A = 'TOTAL'.
  CLEAR : CODE,WERKS,ERRNO,BKTXTID,MENGE,CHARG,ERRNO,ZZCODE,ZZLINE,COUNT_CLICK,
          TA_EXCEL,WA_EXCEL,T_CANCEL.
ENDFORM.                    " F_FILTER
*&---------------------------------------------------------------------*
*&      Form  F_GET_531
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZZLINE  text
*      -->P_WERKS  text
*      -->P_ZZCODE  text
*      <--P_Z531  text
*----------------------------------------------------------------------*
FORM F_GET_531  USING    P_MODE
                         P_ZZLINE
                         P_WERKS
                         P_ZZCODE
                         P_AUFNR
                         P_BKTXT
                CHANGING P_TAB TYPE ST_531   .
  DATA : VMBLNR TYPE AUFM-MBLNR.
  DATA : ZZNUMBER TYPE ZTMAP_SLOCRR-ZZNUMBER .

  DATA : Z261 TYPE MSEG-MENGE,
         Z262 TYPE MSEG-MENGE,
         "ADDED BY FATHIR 29.01.2019 - RE-EXEC GOOD ISSUE BUG
         Z261TEMP TYPE MSEG-MENGE,        "TEMP QTY BEFORE CANCEL
         Z261C TYPE MSEG-MENGE.           "QTY BEFORE CANCEL

  DATA : MBLNR102 TYPE AUFM-MBLNR.        "MATDOC CANCEL GR
  DATA : BEGIN OF IT_SMBLN OCCURS 0,      "MATDOC BEFORE CANCEL
          SMBLN TYPE MSEG-SMBLN,
         END OF IT_SMBLN.

  CLEAR : Z261TEMP, Z261C, MBLNR102.
  "ADDED BY FATHIR 29.01.2019 - RE-EXEC GOOD ISSUE BUG

  "-18 JAN 2013
  PERFORM GET_BWART_ALL USING P_AUFNR  CHANGING BWART1 BWART2.

  IF P_MODE = '1'.

    SELECT MENGE INTO P_TAB-QTY1
      FROM AUFM
      JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
      WHERE AUFM~AUFNR = P_AUFNR
      AND   AUFM~BWART = '101'
      AND   MKPF~BKTXT = P_BKTXT
      ORDER BY AUFM~MBLNR ASCENDING.
    ENDSELECT.

    SELECT SUM( MENGE ) INTO Z261
      FROM AUFM
      JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
      WHERE AUFM~AUFNR = P_AUFNR
      AND   AUFM~BWART = BWART1 " '261'
      AND   MKPF~BKTXT = P_BKTXT
      AND   MKPF~XABLN = ''.
*      ORDER BY AUFM~MBLNR ASCENDING.

    SELECT SUM( MENGE ) INTO Z262
     FROM AUFM
     JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
     WHERE AUFM~AUFNR = P_AUFNR
     AND   AUFM~BWART = BWART2 " '262'
     AND   MKPF~BKTXT = P_BKTXT
     AND   MKPF~XABLN = ''.

    "ADDED BY FATHIR 29.01.2019 - RE-EXEC GOOD ISSUE BUG
    SELECT AUFM~MBLNR INTO MBLNR102                   "CHECK IF ANY CANCEL GR
      FROM AUFM
      JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
      WHERE AUFM~AUFNR = P_AUFNR
      AND AUFM~BWART = '102'
      AND MKPF~BKTXT = P_BKTXT.
    ENDSELECT.

    IF SY-SUBRC = 0.  "IF THERE IS CANCELED GR
      SELECT MSEG~SMBLN                             "GET SMBLN FOR CANCELED 261
       FROM MSEG
       JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
       INTO CORRESPONDING FIELDS OF TABLE IT_SMBLN
       WHERE MSEG~AUFNR = P_AUFNR
       AND   MSEG~BWART = BWART2 " '262'
       AND   MKPF~BKTXT = P_BKTXT
       AND   MKPF~XABLN = ''.

      SELECT AUFM~MENGE INTO Z261TEMP               "SUM INPUT MATERIAL QTY OF CANCELED 261
       FROM AUFM
       FOR ALL ENTRIES IN IT_SMBLN
       WHERE AUFM~MBLNR = IT_SMBLN-SMBLN.

        Z261C = Z261C + Z261TEMP.
      ENDSELECT.

      Z261 = Z261 + Z261C.                          "ADD CURRENT 261 WITH CANCELED 261
    ENDIF.
    "ADDED BY FATHIR 29.01.2019 - RE-EXEC GOOD ISSUE BUG

    P_TAB-QTY2 = Z261 - Z262.

    SELECT ZZNUMBER ZWPLGORT INTO (ZZNUMBER, P_TAB-LGORT )
      FROM ZTMAP_SLOCRR
      WHERE ZLINE = P_ZZLINE
      ORDER BY ZTMAP_SLOCRR~ZZNUMBER DESCENDING.
    ENDSELECT.

    SELECT SINGLE RAR_A_MATNR INTO P_TAB-MATNR
      FROM ZTMAP_MATRECYCLE
      WHERE WERKS = P_WERKS
      AND   FILMT = P_ZZCODE.

    SELECT SINGLE CHARG INTO P_TAB-CHARG
      FROM MCHB
      WHERE MATNR = P_TAB-MATNR
      AND   WERKS = P_WERKS
      AND   LGORT = P_TAB-LGORT.

    P_TAB-WERKS = P_WERKS.
    P_TAB-AUFNR = P_AUFNR.

  ELSEIF P_MODE = '2'.

    SELECT ZZNUMBER ZWPLGORT INTO (ZZNUMBER,P_TAB-LGORT)
      FROM ZTMAP_SLOCRR
      WHERE ZLINE = P_ZZLINE
      ORDER BY ZTMAP_SLOCRR~ZZNUMBER DESCENDING.
    ENDSELECT.

    SELECT SINGLE RAR_A_MATNR INTO P_TAB-MATNR
      FROM ZTMAP_MATRECYCLE
      WHERE WERKS = P_WERKS
      AND   FILMT = P_ZZCODE.

    SELECT SINGLE CHARG INTO P_TAB-CHARG
      FROM MCHB
      WHERE MATNR = P_TAB-MATNR
      AND   WERKS = P_WERKS
      AND   LGORT = P_TAB-LGORT.

    P_TAB-WERKS = P_WERKS.
    P_TAB-AUFNR = P_AUFNR.

  ELSEIF P_MODE = '3'.
*-- Added for Exlam by Fathir on 01.04.2019 - New mode for calculating difference between 261 and 262 Qty
*-------------------------------------------- Excluding Mixing Material from calculation
    SELECT MENGE INTO P_TAB-QTY1
    FROM AUFM
    JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
    WHERE AUFM~AUFNR = P_AUFNR
    AND   AUFM~BWART = '101'
    AND   MKPF~BKTXT = P_BKTXT
    ORDER BY AUFM~MBLNR ASCENDING.
    ENDSELECT.

    SELECT SUM( MENGE ) INTO Z261
      FROM AUFM
      JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
      JOIN MARA ON AUFM~MATNR = MARA~MATNR
      WHERE AUFM~AUFNR = P_AUFNR
      AND   AUFM~BWART = BWART1 " '261'
      AND   MKPF~BKTXT = P_BKTXT
      AND   MKPF~XABLN = ''
      AND   MARA~MATKL NOT BETWEEN 400101 AND 400108.

    SELECT SUM( MENGE ) INTO Z262
     FROM AUFM
     JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
     JOIN MARA ON AUFM~MATNR = MARA~MATNR
     WHERE AUFM~AUFNR = P_AUFNR
     AND   AUFM~BWART = BWART2 " '262'
     AND   MKPF~BKTXT = P_BKTXT
     AND   MKPF~XABLN = ''
     AND   MARA~MATKL NOT BETWEEN 400101 AND 400108.

    SELECT AUFM~MBLNR INTO MBLNR102                   "CHECK IF ANY CANCEL GR
      FROM AUFM
      JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
      WHERE AUFM~AUFNR = P_AUFNR
      AND AUFM~BWART = '102'
      AND MKPF~BKTXT = P_BKTXT.
    ENDSELECT.

    IF SY-SUBRC = 0.  "IF THERE IS CANCELED GR
      SELECT MSEG~SMBLN                             "GET SMBLN FOR CANCELED 261
       FROM MSEG
       JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
       INTO CORRESPONDING FIELDS OF TABLE IT_SMBLN
       WHERE MSEG~AUFNR = P_AUFNR
       AND   MSEG~BWART = BWART2 " '262'
       AND   MKPF~BKTXT = P_BKTXT
       AND   MKPF~XABLN = ''.

      SELECT AUFM~MENGE INTO Z261TEMP               "SUM INPUT MATERIAL QTY OF CANCELED 261
       FROM AUFM
       JOIN MARA ON AUFM~MATNR = MARA~MATNR
       FOR ALL ENTRIES IN IT_SMBLN
       WHERE AUFM~MBLNR = IT_SMBLN-SMBLN
       AND   MARA~MATKL NOT BETWEEN 400101 AND 400108..

        Z261C = Z261C + Z261TEMP.
      ENDSELECT.

      Z261 = Z261 + Z261C.                          "ADD CURRENT 261 WITH CANCELED 261
    ENDIF.

    P_TAB-QTY2 = Z261 - Z262.

    SELECT ZZNUMBER ZWPLGORT INTO (ZZNUMBER, P_TAB-LGORT )
      FROM ZTMAP_SLOCRR
      WHERE ZLINE = P_ZZLINE
      ORDER BY ZTMAP_SLOCRR~ZZNUMBER DESCENDING.
    ENDSELECT.

    SELECT SINGLE RAR_A_MATNR INTO P_TAB-MATNR
      FROM ZTMAP_MATRECYCLE
      WHERE WERKS = P_WERKS
      AND   FILMT = P_ZZCODE.

    SELECT SINGLE CHARG INTO P_TAB-CHARG
      FROM MCHB
      WHERE MATNR = P_TAB-MATNR
      AND   WERKS = P_WERKS
      AND   LGORT = P_TAB-LGORT.

    P_TAB-WERKS = P_WERKS.
    P_TAB-AUFNR = P_AUFNR.
*-- Added for Exlam by Fathir on 01.04.2019 - New mode for calculating difference between 261 and 262 Qty

  ENDIF.
ENDFORM.                    " F_GET_531
*&---------------------------------------------------------------------*
*&      Form  F_GET_MATGROUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MATNR  text
*      <--P_MATKL  text
*      <--P_CEK  text
*----------------------------------------------------------------------*
FORM F_GET_MATGROUP  USING    P_MATNR
                     CHANGING P_MATKL
                              P_CEK.
  CLEAR : MATKL,P_MATKL,P_CEK.
  SELECT SINGLE MATKL INTO P_MATKL
    FROM MARA
    WHERE MATNR = P_MATNR.

  CHECK MATKL NE ''.
  IF MATKL+0(1) = '3'.
    P_CEK = 'X'.
  ELSEIF MATKL+0(1) = '4'.
    CASE MATKL.
      WHEN '400001' OR '400002' OR '400003' OR '400004' OR '400005' OR '400006'
      OR '400007' OR '40008' OR '400009' OR '400010' OR '400011' OR '400012'
      OR '400013' OR '400015' OR '400016' OR '400017' OR '400018'.  " Added by William at 24.07.2022 (OPP7 CPP1)
        P_CEK = 'X'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GET_MATGROUP
*&---------------------------------------------------------------------*
*&      Form  F_NEW_RAWMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_NEW_RAWMAT USING P_AUFNR
                        P_BKTXT.
  CLEAR : NEW_RAWMAT,C_RAWMAT,T_RAWMAT.
  REFRESH : NEW_RAWMAT,C_RAWMAT,T_RAWMAT.


  "- 18 jan 2013
  PERFORM GET_BWART_ALL USING P_AUFNR CHANGING BWART1 BWART2.

** cari rawmat tambahan
  SELECT  AUFM~CHARG AUFM~AUFNR AUFM~MENGE AUFM~LGORT
          AUFM~MATNR AUFM~MBLNR AUFM~MJAHR AUFM~ZEILE
          AUFM~WERKS AUFM~MEINS MKPF~XABLN
    INTO TABLE NEW_RAWMAT
    FROM AUFM
    JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
    WHERE AUFNR = P_AUFNR
    AND   BWART EQ BWART1 "'261'
    AND   BKTXT = P_BKTXT
    AND   XABLN NE 'Balancing'                              "TRDK906283
    AND   MATNR NOT IN TMATNR.
*         %_HINTS ORACLE 'INDEX("AUFM" "AUFM~Z05")'.

**    cek material yang duplikat ambil yang matdoc terakhir

  C_RAWMAT[] = T_RAWMAT[] = NEW_RAWMAT[].
  SORT T_RAWMAT BY MATNR ZEILE.
  DELETE ADJACENT DUPLICATES FROM T_RAWMAT COMPARING MATNR ZEILE.

  LOOP AT T_RAWMAT.
    NEW_RAWMAT[] = C_RAWMAT[].
    DELETE NEW_RAWMAT WHERE MATNR NE T_RAWMAT-MATNR.
    DELETE NEW_RAWMAT WHERE ZEILE NE T_RAWMAT-ZEILE.
    DESCRIBE TABLE NEW_RAWMAT LINES LINE.
    SORT NEW_RAWMAT BY MBLNR ASCENDING.
    READ TABLE NEW_RAWMAT INDEX LINE.
    T_RAWMAT-MENGE = NEW_RAWMAT-MENGE.
    T_RAWMAT-MBLNR = NEW_RAWMAT-MBLNR.
    T_RAWMAT-ZEILE = NEW_RAWMAT-ZEILE.
    T_RAWMAT-MJAHR = NEW_RAWMAT-MJAHR.
    MODIFY T_RAWMAT.
  ENDLOOP.

  NEW_RAWMAT[] = T_RAWMAT[].

  DESCRIBE TABLE NEW_RAWMAT LINES LINE.
  IF LINE > 0.
    LOOP AT NEW_RAWMAT.

      SELECT SINGLE ZEILE INTO ZEILE
        FROM MSEG
        WHERE SMBLN = NEW_RAWMAT-MBLNR
        AND   SMBLP = NEW_RAWMAT-ZEILE
        AND   SJAHR = NEW_RAWMAT-MJAHR
        AND   BWART = BWART2. "'262'.
*          %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.

      CHECK SY-SUBRC NE 0.
*        IF SY-SUBRC = 0.
*          WA_ITEM_GI-ICON = '@09@' .
*          WA_ITEM_GI-MENGE_A = 0 .
*        ELSE.
      IF NEW_RAWMAT-MENGE = 0 .
        WA_ITEM_GI-ICON = '@0A@'.
        WA_ITEM_GI-MENGE_A  = 0.
      ELSE.
        T_CANCEL-MBLNR   = NEW_RAWMAT-MBLNR.
        T_CANCEL-MJAHR   = NEW_RAWMAT-MJAHR.
        T_CANCEL-MATNR   = NEW_RAWMAT-MATNR.
        T_CANCEL-AUFNR   = WA_ITEM_JR-AUFNR.
        T_CANCEL-CHARG   = WA_ITEM_JR-CHARG_JR.
        T_CANCEL-ZEILE   = NEW_RAWMAT-ZEILE.
        T_CANCEL-MENGE   = NEW_RAWMAT-MENGE.
        T_CANCEL-BKTXT   = WA_ITEM_JR-BKTXT_JR.
        T_CANCEL-LGORT   = NEW_RAWMAT-LGORT.
        T_CANCEL-WERKS   = NEW_RAWMAT-WERKS.
        T_CANCEL-CHARG_A = NEW_RAWMAT-CHARG.
        T_CANCEL-ZZLINE  = WA_ITEM_JR-ZZLINE.
        T_CANCEL-ZZCODE  = WA_ITEM_JR-ZZCODE.
        T_CANCEL-MEINS   = NEW_RAWMAT-MEINS.
        T_CANCEL-XABLN   = NEW_RAWMAT-XABLN.
        APPEND T_CANCEL.

        WA_ITEM_GI-MENGE_A = NEW_RAWMAT-MENGE.
        SUBTOT_A = SUBTOT_A + NEW_RAWMAT-MENGE.
        WA_ITEM_GI-ICON = '@08@'.
      ENDIF.
*        ENDIF.

      WA_ITEM_GI-CHARGID = WA_ITEM_JR-CHARG_JR.
      WA_ITEM_GI-AUFNRID = WA_ITEM_JR-AUFNR.
      WA_ITEM_GI-BKTXTID = WA_ITEM_JR-BKTXT_JR.
      WA_ITEM_GI-NOSEQID = WA_ITEM_JR-NOSEQ.
      WA_ITEM_GI-CHARG_A = NEW_RAWMAT-CHARG.
      WA_ITEM_GI-LGORT_A = NEW_RAWMAT-LGORT.
      WA_ITEM_GI-MATNR_A = NEW_RAWMAT-MATNR.

      PERFORM GET_MAKTX USING NEW_RAWMAT-MATNR CHANGING WA_ITEM_GI-MAKTX_A ERRNO.

      CLEAR : WA_ITEM_GI-IDNRK_P, WA_ITEM_GI-MAKTX_P, WA_ITEM_GI-CHARG_P,
              WA_ITEM_GI-MENGE_P, WA_ITEM_GI-LGORT_P.
      MOVE-CORRESPONDING WA_ITEM_GI TO WA_ITEM.
      WA_ITEM-STLKN = '999'.
      APPEND WA_ITEM TO TA_ITEM.


    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_NEW_RAWMAT

*&---------------------------------------------------------------------*
*&      Form  GET_BWART_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ITEM_JR_AUFNR  text
*      <--P_BWART1  text
*      <--P_BWART2  text
*----------------------------------------------------------------------*
FORM GET_BWART_ALL  USING    P_AUFNR
                    CHANGING P_BWART1
                             P_BWART2.

  DATA : AUART TYPE AUFK-AUART.

  SELECT SINGLE AUART INTO AUART
    FROM AUFK
    WHERE AUFNR = P_AUFNR.

  IF ( AUART = 'ZTR1' OR AUART = 'ZTR2' OR AUART = 'ZTR3' OR AUART = 'ZTR4' OR AUART = 'ZTR5'
     OR AUART = 'ZTR6' OR AUART = 'ZTR7'     "ADDED FOR EXLAM 30.01.2019 - ADD ORDER TYPE ZTR7
     OR AUART = 'ZTR8' OR AUART = 'ZTR9' OR AUART = 'ZTRA' OR AUART = 'ZTRB' OR AUART = 'ZTRC' " Added by William at 24.07.2022 (OPP7 CPP1)
     "Added by Ryan at 05.01.2025 (Laminator #2 #3)
     OR AUART = 'ZTRD').
     "END added by Ryan at 05.01.2025 (Laminator #2 #3)
    P_BWART1 = '901'.
    P_BWART2 = '902'.
  ELSE.
    P_BWART1 = '261'.
    P_BWART2 = '262'.
  ENDIF.
ENDFORM.                    " GET_BWART_ALL