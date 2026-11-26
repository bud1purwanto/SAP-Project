*----------------------------------------------------------------------*
***INCLUDE ZHU_PACK_NB_F01 .
*----------------------------------------------------------------------*
DATA : VENUM TYPE VEPO-VENUM.
DATA : SLOC_UP TYPE LGORT_D.
DATA : SLOC_UPDATE TYPE LGORT_D.

** TYPES
TYPES:
  T_HU TYPE ZPACK_PCL,

  BEGIN OF T_UNPACK_TASK,
    VENUM  TYPE  VENUM,
    EXIDV  TYPE  EXIDV,
    UNPACK_EXID  TYPE EXIDV,
    VELIN  TYPE  VELIN,
    CHARG  TYPE  CHARG_D,
    SONUM  TYPE  LVS_SONUM,
    VEMNG  TYPE  VEMNG,
    LGORT  TYPE LGORT_D,
  END OF T_UNPACK_TASK.

** DATA
DATA ITAB_UNPACK_TASK TYPE TABLE OF T_UNPACK_TASK WITH HEADER LINE.
DATA:
  BEGIN OF ITAB_PRINTLIST OCCURS 0,
    SELEC TYPE FLAG,
    VENUM TYPE VENUM,
    EXIDV TYPE EXIDV,
    VHILM TYPE VHILM,
    HUTYP(3),
    SEQUENCE TYPE I,
    WA_HU TYPE ZPACK_PCL,
  END OF ITAB_PRINTLIST.

DATA:
  BEGIN OF ITAB_GRADE_CRITERIA OCCURS 0,
    GRADE    LIKE CUVTAB_VALC-VALC,
    CRITERIA LIKE CUVTAB_VALC-VALC,
  END OF ITAB_GRADE_CRITERIA.

DATA:
  BEGIN OF ITAB_SO OCCURS 0,
    MATNR TYPE MATNR,
    VBELN TYPE VBELN_VA,
    POSNR TYPE POSNR_VA,
    KALAB TYPE LABST,
    KAINS  TYPE MSKA-KAINS,
    KASPE TYPE SPEME,
    KAVLA TYPE MSKA-KAVLA,
    KAVIN TYPE MSKA-KAVIN,
    KAVSP TYPE MSKA-KAVSP,
    KAILL TYPE MSKA-KAILL,
    KAILQ TYPE MSKA-KAILQ,
    KAILS TYPE MSKA-KAILS,
    WERKS TYPE MSKA-WERKS,
    LGORT TYPE MSKA-LGORT,
    TOT   TYPE P DECIMALS 3,
  END OF ITAB_SO.


DATA EX               TYPE REF TO  CX_ROOT.
DATA MSG              TYPE REF TO  IF_MESSAGE.

DATA GS_COMPUTER_NAME TYPE STRING.
DATA GS_STATUS_PALLET TYPE STRING.
DATA GS_STATUS_BOX    TYPE STRING.
DATA GS_STATUS_PINS   TYPE STRING.
DATA GS_CHARGDC(18).

DATA ITAB_HU          TYPE T_HU.
DATA ITAB_PC          TYPE TABLE OF ZPACK_PC  WITH HEADER LINE.
DATA GWA_HU_PALLET    TYPE ZPACK_PCL. "-current handling unit (pallet)
DATA GWA_HU_BOX       TYPE ZPACK_PCL. "-current handling unit (box)
DATA GWA_HU           TYPE ZPACK_PCL. "-nearest handling unit
DATA GS_NEW_PALLET    TYPE EXIDV.
DATA GS_NEW_BOX       TYPE EXIDV.

DATA GWA_PC_PALLET    TYPE ZPACK_PC. "-current packing instruction (pallet)
DATA GWA_PC_BOX       TYPE ZPACK_PC. "-current packing instruction (box)
DATA GWA_PC           TYPE ZPACK_PC.  "-nearest packing instruction

DATA GS_EXIDV_PALLET  TYPE EXIDV. "-external hu number for current hu (pallet)
DATA GS_EXIDV_BOX     TYPE EXIDV. "-external hu number for current hu (box)
DATA GS_EXIDV         TYPE EXIDV. "-external hu number for nearest hu

DATA GWA_PCH          TYPE ZPACK_PCH. "-current packing instruction header

DATA GS_LAST_BATCH    TYPE CHARG_D.
DATA GS_LASTSO        TYPE VBELN_VA.
DATA GS_LASTSOITEM    TYPE POSNR_VA.
DATA GS_LASTPALLET    TYPE ZPOSNR_PL.
DATA GB_DO_PACKING    TYPE FLAG.
DATA GB_IS_NEW_BATCH  TYPE FLAG VALUE 'N'.
DATA GB_IS_FREESTOCK  TYPE FLAG.
DATA GS_SONUM         TYPE LVS_SONUM.
DATA GB_DISPLAY_ONLY  TYPE FLAG.

DATA GS_PLPCK(8).
DATA GS_BXPCK(8).
DATA GS_PLSEQ(4).
DATA GS_BXSEQ(2).

DATA GWA_LAST_CHARACTERISTICS TYPE ZPACK00.
DATA ZPACKSO TYPE ZPACK00.


* DATA FOR PRINTING
DATA GB_LABEL_PALLET  TYPE FLAG.
DATA GB_LABEL_BOX     TYPE FLAG.
DATA GB_REPORT_PALLET TYPE FLAG.

TYPES T_LOG TYPE TABLE OF ZZ01.

DATA: IT_HUPALLET TYPE ZPALLETR.
DATA: V_PALID LIKE MCH1-CHARG.
*&---------------------------------------------------------------------*
*&      Form  f_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FUS_LOG    text
*----------------------------------------------------------------------*
FORM F_LOG USING FUS_LOG TYPE T_LOG.
  INSERT ZZ01 FROM TABLE FUS_LOG.
ENDFORM.                    "f_log

*&---------------------------------------------------------------------*
*&      Form  f_read_batch_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_READ_BATCH_NEW .
  TABLES : MCHB.
  DATA S_SO     TYPE VBELN_VA.
  DATA S_SOITEM TYPE POSNR_VA.
  DATA S_MATNR  TYPE MATNR.
  DATA N_COUNT  TYPE I.
  DATA N_ERRNO  TYPE I.
  DATA N_KALAB  TYPE LABST.
  DATA N_KASPE  TYPE SPEME.
  DATA S_EXIDV  TYPE EXIDV.
  DATA S_GRADE(2).


  READ TABLE HU_COM
    WITH KEY EXID = ZPACK00-CHARGDC.

  IF SY-SUBRC EQ 0.
    BUT_UNPACK = ''.
    MESSAGE S001(00) WITH 'Sudah di-scan sebelumnya.'.

  ELSE.
    CLEAR:
      GS_NEW_BOX,VENUM,
      GS_NEW_PALLET.

    ZPACK00-CHARG = ZPACK00-CHARGDC(10).
    SELECT SINGLE VENUM INTO VENUM
      FROM VEPO WHERE CHARG = ZPACK00-CHARG.


    PERFORM    F_GET_EXIDV
      USING    VENUM
      CHANGING S_EXIDV N_ERRNO.

    IF S_EXIDV IS NOT INITIAL.
      MESSAGE I000(0K) WITH 'Sudah di-pack pada HU' S_EXIDV.

      GS_EXIDV = S_EXIDV.
      GB_DO_PACKING = V_NO.

    ELSE.
      SELECT  * FROM MCHB
          WHERE MATNR = GWA_PCH-MATNR
          AND   CHARG = ZPACK00-CHARGDC.
        IF MCHB-CSPEM NE 0.
          CLEAR : HU_COM. REFRESH : HU_COM.
          BUT_UNPACK = 'X'.
          MESSAGE E002(ZMM) WITH 'Blocked Stock'.
          RETURN.
        ELSE.
          BUT_UNPACK = ''.
        ENDIF.
      ENDSELECT.

      CLEAR GS_EXIDV.
      GB_DO_PACKING = V_YES.

    ENDIF.

    CTR1 = CTR2 = CTR3 = PAGEBEGIN = 0.


    IF GB_IS_FREESTOCK = V_YES.
      PERFORM F_PROCESS_FREESTOCK USING S_EXIDV.

    ELSE.
      IF GB_DO_PACKING = V_YES.
        PERFORM    F_READ_SONUM
          CHANGING S_SO S_SOITEM GS_SONUM S_MATNR N_KALAB N_KASPE N_ERRNO.
      ELSE.
        PERFORM    F_READ_SONUM_IN_PINS
          CHANGING S_SO S_SOITEM GS_SONUM S_MATNR N_KALAB N_KASPE N_ERRNO.

      ENDIF.

      PERFORM F_CHECK_BATCH USING S_MATNR CHANGING N_ERRNO.
      PERFORM F_GET_MATERIAL_MASTER USING ZPACK00-MATNR0
          CHANGING ZPACK00-MEINS0 MAKT-MAKTX MARA-MTART.

      CASE N_ERRNO.
        WHEN 0.
          PERFORM    F_PROCESS_SO
            USING    S_EXIDV S_SO S_SOITEM GS_SONUM S_MATNR
            CHANGING N_ERRNO.

        WHEN 1.
          PERFORM F_PROCESS_FREESTOCK USING S_EXIDV.

        WHEN 2.
          MESSAGE I000(0K) WITH 'Stok terblok di SO' S_SO '-' S_SOITEM.

        WHEN 3.
          MESSAGE I000(0K) WITH 'Stok kosong di SO' S_SO '-' S_SOITEM.

        WHEN 4.
          MESSAGE I001(00) WITH 'Batch tidak ditemukan'.
          RETURN.

        WHEN 5.
          MESSAGE I001(OK) WITH 'Sloc Tidak Sesuai'.
      ENDCASE.

    ENDIF.

  ENDIF.

ENDFORM.                    " f_read_batch_new


*&---------------------------------------------------------------------*
*&      Form  f_read_sonum
*&---------------------------------------------------------------------*
*       find so info for current batch number
*----------------------------------------------------------------------*
* OUTPUT:
*  fcs_so      selected so number
*  fcs_soitem  selected so item number
*  fcs_sonum   concatenation of so number and so item number
*  fcs_matnr   material in stock
*  fcn_kalab   unrestricted stock count
*  fcn_kaspe   blocked stock count
*  fcn_errno   0 - SO item found, unrestricted stock available
*              1 - Free stock
*              2 - SO item found, but only blocked stock available
*              3 - SO item found, no stock
*----------------------------------------------------------------------*
FORM F_READ_SONUM
  CHANGING
    FCS_SO FCS_SOITEM FCS_SONUM FCS_MATNR
    FCN_KALAB FCN_KASPE FCN_ERRNO.

  DATA WA_SO_WITH_BLOCK_STOCK LIKE LINE OF ITAB_SO.
  DATA WA_SO_WITH_UNRES_STOCK LIKE LINE OF ITAB_SO.
  DATA N_SO_COUNT TYPE I.
  DATA LINE TYPE I.
  DATA SLOC TYPE LGORT_D.

*- update for RTS
  IF SY-TCODE = 'ZHU5SOR'.
    SELECT MATNR VBELN POSNR KAEIN KAINS KASPE KAVLA KAVIN KAVSP KAILL KAILQ KAILS
           WERKS LGORT
      INTO TABLE ITAB_SO
      FROM MSKA
      WHERE CHARG = ZPACK00-CHARGDC(10).
  ELSE.
    SELECT MATNR VBELN POSNR KALAB KAINS KASPE KAVLA KAVIN KAVSP KAILL KAILQ KAILS
           WERKS LGORT
      INTO TABLE ITAB_SO
      FROM MSKA
      WHERE CHARG = ZPACK00-CHARGDC(10).
*       AND LGORT = HUPAST_T-STGE_LOC
*       AND WERKS = HUPAST_T-PLANT.
  ENDIF.

  DESCRIBE TABLE ITAB_SO LINES LINE.
  IF LINE NE 0.
    LOOP AT ITAB_SO WHERE KASPE NE 0.
      CLEAR : ITAB_SO,HU_COM. REFRESH : ITAB_SO,HU_COM.
      BUT_UNPACK = 'X'.
      MESSAGE W002(ZMM) WITH 'Blocked Stock'.
      RETURN.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      BUT_UNPACK = ''.
    ENDIF.
  ENDIF.

  LOOP AT ITAB_SO.
    ITAB_SO-TOT = ITAB_SO-KALAB + ITAB_SO-KAINS ."+ ITAB_SO-KAVLA
*                  + ITAB_SO-KAVIN + ITAB_SO-KAVSP + ITAB_SO-KAILL + ITAB_SO-KAILQ
*                  + ITAB_SO-KAILS.
    MODIFY ITAB_SO.
  ENDLOOP.
  DELETE ITAB_SO WHERE TOT = 0.
  DESCRIBE TABLE ITAB_SO LINES LINE.

  IF LINE = 0.
    FCN_ERRNO = 1.
    CLEAR:
      FCS_MATNR,
      FCS_SO,
      FCS_SOITEM,
      FCS_SONUM,
      FCN_KALAB,
      FCN_KASPE.

  ELSE.
    FCN_ERRNO = 3. "-- no stock available

    LOOP AT ITAB_SO.
      "- cek sloc sesuai
      SELECT SLOC_UP INTO SLOC
        FROM ZPACK_PCH
        JOIN ZPACK_PCL ON ZPACK_PCH~PINNR = ZPACK_PCL~PINNR
        WHERE ZPACK_PCH~VBELN = ITAB_SO-VBELN
        AND   ZPACK_PCH~POSNR = ITAB_SO-POSNR
        AND   ZPACK_PCL~SLOC_UP NE ''
        AND   ZPACK_PCL~FM = ''.
      ENDSELECT.


      IF  SLOC = '' .
        IF ITAB_SO-LGORT NE HUPAST_T-STGE_LOC.
          CLEAR : HU_COM,ITAB_SO . REFRESH : HU_COM,ITAB_SO.
          BUT_UNPACK = 'X'.
          MESSAGE W018(ZMM) WITH 'Sloc tidak sesuai'.
          FCN_ERRNO = 5.
          RETURN.
        ELSE.
          BUT_UNPACK = ''.
        ENDIF.

      ELSE.

        IF ITAB_SO-LGORT NE SLOC.
          CLEAR : HU_COM,ITAB_SO . REFRESH : HU_COM,ITAB_SO.
          BUT_UNPACK = 'X'.
          MESSAGE W018(ZMM) WITH 'Sloc tidak sesuai'.
          FCN_ERRNO = 5.
          RETURN.
        ELSE.
          BUT_UNPACK = ''.
        ENDIF.

      ENDIF.



      IF ITAB_SO-KALAB > 0.
        ADD 1 TO N_SO_COUNT.
        IF WA_SO_WITH_UNRES_STOCK IS INITIAL.
          WA_SO_WITH_UNRES_STOCK = ITAB_SO.
        ENDIF.

      ELSEIF ITAB_SO-KASPE > 0 AND WA_SO_WITH_BLOCK_STOCK  IS INITIAL.
        WA_SO_WITH_BLOCK_STOCK = ITAB_SO.
        FCN_ERRNO = 2.

      ENDIF.

    ENDLOOP.

    IF WA_SO_WITH_UNRES_STOCK IS NOT INITIAL.
      FCN_ERRNO = 0.
    ENDIF.

    CASE FCN_ERRNO.
      WHEN 0. "-- found so item with unrestricted stock
        IF N_SO_COUNT > 1.
          PERFORM F_SELECT_SO
            TABLES ITAB_SO
            CHANGING WA_SO_WITH_UNRES_STOCK FCN_ERRNO.
        ENDIF.

        IF FCN_ERRNO NE 0.
          FCN_ERRNO = 3.
          CLEAR:
            FCS_MATNR,
            FCS_SO,
            FCS_SOITEM,
            FCS_SONUM,
            FCN_KALAB,
            FCN_KASPE.
        ELSE.
          FCS_SO     = WA_SO_WITH_UNRES_STOCK-VBELN.
          FCS_SOITEM = WA_SO_WITH_UNRES_STOCK-POSNR.
          FCS_MATNR  = WA_SO_WITH_UNRES_STOCK-MATNR.
          FCN_KALAB  = WA_SO_WITH_UNRES_STOCK-KALAB.
          FCN_KASPE  = WA_SO_WITH_UNRES_STOCK-KASPE.
        ENDIF.

      WHEN 2. "-- found so item with blocked stock
        FCS_SO     = WA_SO_WITH_BLOCK_STOCK-VBELN.
        FCS_SOITEM = WA_SO_WITH_BLOCK_STOCK-POSNR.
        FCS_MATNR  = WA_SO_WITH_BLOCK_STOCK-MATNR.
        FCN_KALAB  = WA_SO_WITH_BLOCK_STOCK-KALAB.
        FCN_KASPE  = WA_SO_WITH_BLOCK_STOCK-KASPE.

      WHEN 3.
        CLEAR:
          FCS_MATNR,
          FCS_SO,
          FCS_SOITEM,
          FCS_SONUM,
          FCN_KALAB,
          FCN_KASPE.
    ENDCASE.

    CONCATENATE FCS_SO FCS_SOITEM INTO FCS_SONUM.
    ZPACK00-VBELN  = FCS_SO.
    ZPACK00-POSNR  = FCS_SOITEM.
    ZPACK00-MATNR0 = FCS_MATNR.

  ENDIF.

ENDFORM.                    " f_get_sonum


*&---------------------------------------------------------------------*
*&      Form  f_process_freestock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PROCESS_FREESTOCK USING FUS_EXIDV.
  IF GB_IS_FREESTOCK = V_NO.
    MESSAGE S001(00) WITH 'Produk ini untuk free-stock.'.

  ELSE.
    DATA N_ERRNO TYPE I.

    PERFORM F_GET_MATERIAL_FROM_PINS CHANGING ZPACK00-MATNR N_ERRNO.

    PERFORM F_GET_MATERIAL_MASTER USING ZPACK00-MATNR0
           CHANGING ZPACK00-MEINS0 MAKT-MAKTX MARA-MTART.

    IF N_ERRNO NE 0.
      MESSAGE E001(00) WITH 'Stock batch kosong / tidak ada.'.
    ELSE.

      IF ZPACK00-MATNR NE GWA_PCH-MATNR.
        MESSAGE E001(00) WITH
          'Material tidak sesuai dengan packing instruction.'.
      ELSE.
        PERFORM F_MATCH_PINS_CHARACTERISTIC CHANGING N_ERRNO.
        IF N_ERRNO EQ 0.
          GS_EXIDV = FUS_EXIDV.

          IF ITAB_GRADE_CRITERIA-CRITERIA = 'R'.
            MESSAGE 'Kriteria Grade RW/RS tidak boleh di packing' TYPE 'E'.
          ELSEIF ITAB_GRADE_CRITERIA-CRITERIA = 'S'.
            MESSAGE 'Kriteria Grade SCRAP tidap boleh di packing' TYPE 'E'.
          ENDIF.

          PERFORM F_PROCESS_COMMON.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.                    " f_process_freestock


*&---------------------------------------------------------------------*
*&      Form  f_process_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_SO  text
*      -->P_S_SOITEM  text
*      -->P_S_SONUM  text
*      -->P_S_MATNR  text
*      -->P_N_KALAB  text
*----------------------------------------------------------------------*
FORM F_PROCESS_SO  USING    FUS_EXIDV
                            FUS_SO
                            FUS_SOITEM
                            FUS_SONUM
                            FUS_MATNR
                   CHANGING FCN_ERRNO.

  DATA S_LASTSO             TYPE VBELN_VA.
  DATA B_SELECT_NEW_PALLET  TYPE FLAG.
  DATA B_IS_FULL            TYPE FLAG.
  DATA N_ERRNO              TYPE I.
  DATA S_PINNR              TYPE ZPINNR.
  DATA MSG TYPE STRING.
  DATA V_TEXT(10).
  DATA S_BTN_CLICKED(1).
  DATA AUART TYPE VBAK-AUART.


  ZPACK00-MATNR = FUS_MATNR.
  SELECT SINGLE MEINS INTO ZPACK00-MEINS0
  FROM MARA
  WHERE MATNR = ZPACK00-MATNR0.

  IF ( FUS_SO NE GS_LASTSO ) OR ( FUS_SOITEM NE GS_LASTSOITEM ).
    IF ( GS_LASTSO IS NOT INITIAL ) OR ( GS_LASTSOITEM IS NOT INITIAL )
    .

      IF GWA_HU_PALLET IS NOT INITIAL.
        PERFORM F_UNLOCK_NEW.
      ENDIF.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = 'SO Item Tidak Sama'
*         DIAGNOSE_OBJECT       = ' '
          TEXT_QUESTION         = 'Pindah ke SO Item baru?'
          TEXT_BUTTON_1         = 'Ya'
          ICON_BUTTON_1         = '@0V@'
          TEXT_BUTTON_2         = 'Tidak'
          ICON_BUTTON_2         = '@0W@'
          DISPLAY_CANCEL_BUTTON = ' '
        IMPORTING
          ANSWER                = S_BTN_CLICKED
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1
          OTHERS                = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        RETURN.

      ELSEIF S_BTN_CLICKED = 'A' OR S_BTN_CLICKED = '2'.
        FUS_SO = GS_LASTSO.
        FUS_SOITEM = GS_LASTSOITEM.
        ZPACK00-VBELN = GS_LASTSO.
        ZPACK00-POSNR = GS_LASTSOITEM.
        RETURN.
      ENDIF.

    ENDIF.

    GS_LASTSO     = FUS_SO.
    GS_LASTSOITEM = FUS_SOITEM.
    CLEAR GWA_LAST_CHARACTERISTICS.

*****    PERFORM f_reset_all.
    PERFORM    F_READ_CUSTOMER
      USING    FUS_SO
      CHANGING N_ERRNO.

    CLEAR N_ERRNO.
    PERFORM    F_READ_PINST
      USING    FUS_SO FUS_SOITEM
      CHANGING N_ERRNO.

    IF N_ERRNO NE 0.
      RETURN.
    ENDIF.

  ENDIF.

  CLEAR : MSG, WA_ERROR, TA_ERROR,AUART.
  SELECT SINGLE AUART INTO AUART
    FROM VBAK
    WHERE VBELN = FUS_SO.

  CONCATENATE FUS_SO 'item' FUS_SOITEM INTO MSG SEPARATED BY SPACE.
  IF GS_LAST_BATCH <> ZPACK00-CHARG.
    PERFORM    F_READ_CHARACTERISTICS
      CHANGING ZPACK00.

    IF GWA_LAST_CHARACTERISTICS IS INITIAL.
      GS_LAST_BATCH = ZPACK00-CHARG.
      GWA_LAST_CHARACTERISTICS-CHAR01 = ZPACK00-CHAR01.
      GWA_LAST_CHARACTERISTICS-CHAR02 = ZPACK00-CHAR02.
      GWA_LAST_CHARACTERISTICS-CHAR03 = ZPACK00-CHAR03.
      GWA_LAST_CHARACTERISTICS-CHAR04 = ZPACK00-CHAR04.
      GWA_LAST_CHARACTERISTICS-CHAR05 = ZPACK00-CHAR05.
      GWA_LAST_CHARACTERISTICS-CHAR06 = ZPACK00-CHAR06.
      GWA_LAST_CHARACTERISTICS-CHAR07 = ZPACK00-CHAR07.
      GWA_LAST_CHARACTERISTICS-CHAR08 = ZPACK00-CHAR08.
      GWA_LAST_CHARACTERISTICS-CHAR09 = ZPACK00-CHAR09.
      GWA_LAST_CHARACTERISTICS-CHAR10 = ZPACK00-CHAR10.
      GWA_LAST_CHARACTERISTICS-ZMENG  = ZPACK00-ZMENG.
      FCN_ERRNO = 0.
    ELSE.
      IF    ( GWA_LAST_CHARACTERISTICS-CHAR01 EQ ZPACK00-CHAR01 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR02 EQ ZPACK00-CHAR02 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR03 EQ ZPACK00-CHAR03 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR04 EQ ZPACK00-CHAR04 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR05 EQ ZPACK00-CHAR05 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR06 EQ ZPACK00-CHAR06 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR07 EQ ZPACK00-CHAR07 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR08 EQ ZPACK00-CHAR08 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR09 EQ ZPACK00-CHAR09 )
        AND ( GWA_LAST_CHARACTERISTICS-CHAR10 EQ ZPACK00-CHAR10 ).

        GS_LAST_BATCH = ZPACK00-CHARG.
        GWA_LAST_CHARACTERISTICS-CHAR01 = ZPACK00-CHAR01.
        GWA_LAST_CHARACTERISTICS-CHAR02 = ZPACK00-CHAR02.
        GWA_LAST_CHARACTERISTICS-CHAR03 = ZPACK00-CHAR03.
        GWA_LAST_CHARACTERISTICS-CHAR04 = ZPACK00-CHAR04.
        GWA_LAST_CHARACTERISTICS-CHAR05 = ZPACK00-CHAR05.
        GWA_LAST_CHARACTERISTICS-CHAR06 = ZPACK00-CHAR06.
        GWA_LAST_CHARACTERISTICS-CHAR07 = ZPACK00-CHAR07.
        GWA_LAST_CHARACTERISTICS-CHAR08 = ZPACK00-CHAR08.
        GWA_LAST_CHARACTERISTICS-CHAR09 = ZPACK00-CHAR09.
        GWA_LAST_CHARACTERISTICS-CHAR10 = ZPACK00-CHAR10.
        GWA_LAST_CHARACTERISTICS-ZMENG  = ZPACK00-ZMENG.
        FCN_ERRNO = 0.

      ELSE.
        IF AUART NE 'ZDRC' AND AUART NE 'ZDRE' AND AUART NE 'ZERC' AND AUART NE 'ZERE'
           AND AUART NE 'ZDKP' AND AUART NE 'ZDKR' AND AUART NE 'ZEKP' AND AUART NE 'ZEKR'. "-sotype
          IF ( GWA_LAST_CHARACTERISTICS-CHAR01 NE ZPACK00-CHAR01 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Tipe Film '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR02 NE ZPACK00-CHAR02 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Lebar Film '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR03 NE ZPACK00-CHAR03 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Panjang Film '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR04 NE ZPACK00-CHAR04 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Inside '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR05 NE ZPACK00-CHAR05 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Outside '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR06 NE ZPACK00-CHAR06 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Diameter Core '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR07 NE ZPACK00-CHAR07 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Kriteria Grade '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-ZMENG  NE ZPACK00-ZMENG ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Quantity '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR08 NE ZPACK00-CHAR08 ) .
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Type Label '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR09 NE ZPACK00-CHAR09 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Alias '.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
          IF ( GWA_LAST_CHARACTERISTICS-CHAR10 NE ZPACK00-CHAR10 ).
            FCN_ERRNO = 4.
            WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
            WA_ERROR-MSGV1 = 'Karakteristik Batch Type Packing'.
            WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
            WA_ERROR-MSGV3 = MSG.
            APPEND WA_ERROR TO TA_ERROR.
          ENDIF.
        ENDIF.  "-check sotype

        IF TA_ERROR[] IS NOT INITIAL.
          BUT_UNPACK = 'X'.
          CLEAR : HU_COM.
          REFRESH : HU_COM.
          CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
            TABLES
              I_MESSAGE_TAB = TA_ERROR.
          RETURN.
        ELSE.
          BUT_UNPACK = ''.
        ENDIF.

*       restore last characteristics
        ZPACK00-CHAR01 = GWA_LAST_CHARACTERISTICS-CHAR01.
        ZPACK00-CHAR02 = GWA_LAST_CHARACTERISTICS-CHAR02.
        ZPACK00-CHAR03 = GWA_LAST_CHARACTERISTICS-CHAR03.
        ZPACK00-CHAR04 = GWA_LAST_CHARACTERISTICS-CHAR04.
        ZPACK00-CHAR05 = GWA_LAST_CHARACTERISTICS-CHAR05.
        ZPACK00-CHAR06 = GWA_LAST_CHARACTERISTICS-CHAR06.
        ZPACK00-CHAR07 = GWA_LAST_CHARACTERISTICS-CHAR07.
        ZPACK00-CHAR08 = GWA_LAST_CHARACTERISTICS-CHAR08.
        ZPACK00-CHAR09 = GWA_LAST_CHARACTERISTICS-CHAR09.
        ZPACK00-CHAR09 = GWA_LAST_CHARACTERISTICS-CHAR09.
        ZPACK00-CHAR10 = GWA_LAST_CHARACTERISTICS-CHAR10.
        ZPACK00-ZMENG  = GWA_LAST_CHARACTERISTICS-ZMENG.
        RETURN.
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM F_CHARACTERISTICS_SO USING FUS_SO FUS_SOITEM CHANGING ZPACKSO.
  IF  AUART NE 'ZDRC' AND AUART NE 'ZDRE' AND AUART NE 'ZERC' AND AUART NE 'ZERE'
      AND AUART NE 'ZDKP' AND AUART NE 'ZDKR' AND AUART NE 'ZEKP' AND AUART NE 'ZEKR'."- sotype
    IF GWA_LAST_CHARACTERISTICS-CHAR01 NE ZPACKSO-CHAR01.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Type Film'.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR02 NE ZPACKSO-CHAR02.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Lebar Film '.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR03 NE ZPACKSO-CHAR03.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Panjang Film '.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR04 NE ZPACKSO-CHAR04.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Inside'.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR05 NE ZPACKSO-CHAR05.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Outside'.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR06 NE ZPACKSO-CHAR06.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Diameter Core'.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR07 NE ZPACKSO-CHAR07.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Kriteria Grade'.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-ZMENG  NE ZPACKSO-ZMENG.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Quantity'.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR08 NE ZPACKSO-CHAR08.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Type Label'.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR09 NE ZPACKSO-CHAR09.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Alias '.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
    IF GWA_LAST_CHARACTERISTICS-CHAR10 NE ZPACKSO-CHAR10.
      FCN_ERRNO = 4.
      WA_ERROR-MSGID = 'ZMM'.WA_ERROR-MSGTY = 'E' .WA_ERROR-MSGNO = '002'.
      WA_ERROR-MSGV1 = 'Karakteristik Batch Type Packing '.
      WA_ERROR-MSGV2 = 'tidak sama dengan SO'.
      WA_ERROR-MSGV3 = MSG.
      APPEND WA_ERROR TO TA_ERROR.
    ENDIF.
  ENDIF. "-> check sotype
  IF FCN_ERRNO = 4.
    BUT_UNPACK = 'X'.

    IF TA_ERROR[] IS NOT INITIAL.
      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          I_MESSAGE_TAB = TA_ERROR.
    ENDIF.
*    MESSAGE I018(ZMM) WITH 'Karakteristik Batch' V_TEXT 'tidak sama dengan Karakteristik SO'
*            MSG.
    CLEAR : ZPACKSO,ZPACK00,GWA_LAST_CHARACTERISTICS.
*    PERFORM F_RESET_ALL.
    RETURN.
  ELSE.
    BUT_UNPACK = ''.
  ENDIF.

  GS_EXIDV = FUS_EXIDV.
  PERFORM F_PROCESS_COMMON.

ENDFORM.                    " f_process_so


*&---------------------------------------------------------------------*
*&      Form  f_select_new_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECT_PALLET CHANGING FCN_ERRNO.
  DATA ITAB_OPENPALLET TYPE TABLE OF T_HU WITH HEADER LINE.
  DATA ITAB_USEDPALLET TYPE TABLE OF T_HU WITH HEADER LINE.
  DATA N_PICKED TYPE I.
  DATA N_COUNT  TYPE I.
  DATA N_BOX_COUNT TYPE I.

  FCN_ERRNO = 1.
  N_PICKED = 0.
  GS_EXIDV = GS_EXIDV_PALLET.

* use current pallet if still not complete.
  IF GWA_HU IS NOT INITIAL.
    PERFORM F_INCOMPLETE_BOX_COUNT CHANGING N_BOX_COUNT.
    IF N_BOX_COUNT = 0.
      CLEAR GWA_HU_PALLET.
    ENDIF.
  ENDIF.

  CHECK ( GWA_HU_PALLET        IS INITIAL )
    OR  ( GWA_HU_PALLET-HUSTAT =  C_HUSTAT_COMPLETED )
    OR  ( GWA_HU_PALLET-HUSTAT =  C_HUSTAT_FORCED )
    OR  ( GWA_HU_PALLET-HUSTAT =  C_HUSTAT_CLOSED )
    OR  ( GWA_HU_PALLET-PINNR  NE GWA_PCH-PINNR ).

* baca pallet yang statusnya O=open (belum dipakai)
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ITAB_OPENPALLET
    FROM  ZPACK_PCL
    WHERE HUSTAT = C_HUSTAT_OPEN
      AND HUSEQ_P = '000000'
      AND PINNR  = GWA_PCH-PINNR.

  IF SY-SUBRC EQ 0.
    CLEAR : ITAB_USEDPALLET.
    ITAB_USEDPALLET-VENUM = '<new>'.
    APPEND ITAB_USEDPALLET.
  ELSE.
*   -- ensure that all 'Open' pallet don't have any venum
    LOOP AT ITAB_OPENPALLET.
      CLEAR:
      ITAB_OPENPALLET-VENUM,
      ITAB_OPENPALLET-PACKED.
      MODIFY ITAB_OPENPALLET.
    ENDLOOP.

  ENDIF.

* baca pallet yang statusnya I=inprogress (setengah isi)
  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ITAB_USEDPALLET
    FROM  ZPACK_PCL
    WHERE HUSTAT = C_HUSTAT_INPROGRESS
      AND HUSEQ_P = '000000'
      AND PINNR  = GWA_PCH-PINNR
      AND ( COMPUTER_NAME = '' OR COMPUTER_NAME = GS_COMPUTER_NAME )
      .

  DESCRIBE TABLE ITAB_USEDPALLET LINES N_COUNT.

  IF N_COUNT = 0.
    MESSAGE S001(00) WITH 'Tidak ada pallet yang dapat dipakai.'.
    FCN_ERRNO = 4.
    N_PICKED  = 0.

  ELSEIF N_COUNT = 1.
*   If there is only one pallet available then use it
    N_PICKED = 1.

  ELSE.
*   If there are many pallets available then let the user choose
    PERFORM F_PICK_HU
      TABLES ITAB_USEDPALLET
      USING 'PALET'
      CHANGING N_PICKED FCN_ERRNO.

  ENDIF.

  IF N_PICKED > 0.
    CLEAR:      GWA_HU_PALLET,
                GWA_HU_BOX,
                GWA_HU,
                GWA_PC_PALLET,
                GWA_PC_BOX,
                GWA_PC,
                GS_EXIDV_PALLET,
                GS_EXIDV_BOX,
                GS_EXIDV.

    PERFORM     F_USE_PALLET
      TABLES    ITAB_OPENPALLET  ITAB_USEDPALLET
      USING     N_PICKED
      CHANGING  FCN_ERRNO.

  ELSE.
    FCN_ERRNO = 4.

  ENDIF.

ENDFORM.                    " f_select_new_pallet


*&---------------------------------------------------------------------*
*&      Form  f_read_pinst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FUS_SO  text
*      -->P_FUS_SOITEM  text
*      <--P_S_PINNR  text
*----------------------------------------------------------------------*
FORM F_READ_PINST  USING    FUS_SO
                            FUS_SOITEM
                   CHANGING FCN_ERRNO.

  SELECT SINGLE * INTO GWA_PCH FROM ZPACK_PCH
    WHERE VBELN = FUS_SO AND POSNR = FUS_SOITEM.

  FCN_ERRNO = SY-SUBRC.

  IF FCN_ERRNO NE 0.
    MESSAGE I000(0K) WITH 'Packing instruction tidak ada!'.
    CLEAR GWA_PCH.

  ELSE.
    IF GWA_PCH-PINST = C_PINST_COMPLETED.
      MESSAGE I000(0K) WITH 'Packing instruction sudah terpenuhi'.

    ELSEIF ( GWA_PCH-PINST <> C_PINST_ACTIVE )
      AND  ( GWA_PCH-PINST <> C_PINST_INPROGRESS ).
      MESSAGE I000(0K) WITH 'Packing instruction tidak aktif!'.
      CLEAR GWA_PCH.

    ENDIF.

    SELECT SUM( ZMENG ) INTO ZPACK00-PLCNT FROM ZPACK_PC
      WHERE PINNR = GWA_PCH-PINNR AND INILVL = C_LEVEL_PALLET.

  ENDIF.

ENDFORM.                    "f_read_pinst

*&---------------------------------------------------------------------*
*&      Form  f_read_materials
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_READ_MATERIALS CHANGING FCN_ERRNO.
*   now read packing instruction details
  DATA D_QTY TYPE DZMENG.
  DATA N_COUNT TYPE I.

  REFRESH ITAB_PC.
  CLEAR ITAB_PC.

  IF GWA_HU_BOX IS INITIAL.
    SELECT * INTO TABLE ITAB_PC FROM ZPACK_PC
      WHERE PINNR = GWA_HU-PINNR
        AND ZINS01 = GWA_HU-ZINS01
        AND INILVL = C_LEVEL_ROLL.
  ELSE.
    SELECT * INTO TABLE ITAB_PC FROM ZPACK_PC
      WHERE PINNR = GWA_HU-PINNR
        AND ZINS01 = GWA_HU-ZINS01
        AND ZINS02 = GWA_HU-ZINS02
        AND INILVL = C_LEVEL_ROLL.

  ENDIF.

  IF ITAB_PC[] IS INITIAL.
    FCN_ERRNO = 4.
  ENDIF.

  N_COUNT = 0.
  LOOP AT ITAB_PC.
    DO ITAB_PC-ZMENG TIMES.
      ADD 1 TO N_COUNT.
      HU_COM-INS0  = GWA_HU-ZINS01.
      HU_COM-INS1  = GWA_HU-ZINS02.
      HU_COM-INS2  = N_COUNT.
      HU_COM-INST  = ITAB_PC-MATNR.
      HU_COM-ZMENG = ITAB_PC-ZMENG.
      HU_COM-TABIX = N_COUNT.
      CLEAR:
        HU_COM-EXID,
        HU_COM-STAT,
        HU_COM-SELE.

      APPEND HU_COM.
    ENDDO.

  ENDLOOP.
ENDFORM.                    "f_read_materials


*&---------------------------------------------------------------------*
*&      Form  f_set_material_exid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_SET_MATERIAL_EXID.
* baca produk yang sudah masuk ke hu ini, assign batch numbernya
  DATA : FEXIDV TYPE VEKP-EXIDV,
         N_ERRNO TYPE I,
         N_COUNT TYPE I,
         VENUM TYPE VEPO-UNVEL,
         UNVEL TYPE VEPO-UNVEL,
         LINE TYPE I.

  DATA : BEGIN OF TVEPO OCCURS 0 ,
         CHARG TYPE VEPO-CHARG,
         UNVEL TYPE VEPO-UNVEL,
         LGORT TYPE VEPO-LGORT,
         END OF TVEPO.


  IF GWA_HU-VENUM IS NOT INITIAL.
    CLEAR : FEXIDV, TVEPO,VENUM.
    REFRESH : TVEPO.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = GS_EXIDV_PALLET
      IMPORTING
        OUTPUT = FEXIDV.

    SELECT VEPO~CHARG AS CHARG
           VEPO~UNVEL AS UNVEL
           VEPO~LGORT AS LGORT
    INTO CORRESPONDING FIELDS OF TABLE TVEPO
    FROM VEKP
    JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    WHERE VEKP~EXIDV = FEXIDV.

*add SORT by ALF
    SORT TVEPO BY UNVEL ASCENDING.
*end of SORT

    "- cek batch yang diinput ada di box mana
    SELECT VENUM UNVEL INTO (VENUM,UNVEL)
      FROM VEPO WHERE CHARG = ZPACK00-CHARG.
      IF UNVEL = ''.
        SELECT SINGLE VENUM INTO UNVEL
          FROM VEPO WHERE UNVEL = VENUM.
        EXIT.
      ENDIF.
    ENDSELECT.

    IF UNVEL NE ''.
      READ TABLE TVEPO WITH KEY UNVEL = VENUM.
      VENUM = TVEPO-UNVEL.
    ELSE.
      DESCRIBE TABLE TVEPO LINES LINE.
      READ TABLE TVEPO INDEX LINE.
      VENUM = TVEPO-UNVEL .
    ENDIF.


    IF TVEPO-CHARG = ''.
      CLEAR : TVEPO. REFRESH : TVEPO.
      SELECT  VEPO~CHARG AS CHARG
              VEPO~LGORT AS LGORT
        INTO CORRESPONDING FIELDS OF TABLE TVEPO
        FROM VEPO
        WHERE VEPO~VENUM = VENUM
        AND   VEPO~VELIN = 1.
    ENDIF.

    N_COUNT = 0.
    LOOP AT TVEPO.
      ADD 1 TO N_COUNT.
      READ TABLE HU_COM INDEX N_COUNT .
      IF SY-SUBRC EQ 0.
        HU_COM-EXID = TVEPO-CHARG.

        IF GWA_HU-HUSTAT = C_HUSTAT_CLOSED.
          HU_COM-STAT = 'Cls'.
        ELSE.
          HU_COM-STAT = 'Pck'.
        ENDIF.
        MODIFY HU_COM INDEX N_COUNT.

      ELSE.
        EXIT.

      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " f_read_pinst


*&---------------------------------------------------------------------*
*&      Form  f_hu_create_new
*&---------------------------------------------------------------------*
*       copied from HU_CREATE_BY_BDC and a little modification in
*       the final part
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_CREATE_NEW
  CHANGING
    FCS_EXIDV
    FCWA_HU STRUCTURE ZPACK_PCL
    FCWA_PI STRUCTURE ZPACK_PC
    FCN_ERRNO.

  DATA : MSGS TYPE TABLE OF BDCMSGCOLL,
         WA   LIKE BDCMSGCOLL,
         NRIV TYPE  NRIV,
         LVL  LIKE INRI-NRRANGENR,
         FLD  LIKE HEADER51-PLANHU,
         RETURN TYPE VEKP-EXIDV,
         HUNO TYPE BAPIHUKEY-HU_EXID.

  CHECK FCS_EXIDV IS INITIAL.

  SELECT SINGLE MTART VHART INTO (MARA-MTART, MARA-VHART)
                      FROM MARA WHERE MATNR = FCWA_PI-MATNR.
  IF MARA-MTART NE 'ZPCK' AND MARA-MTART NE 'ZRTP'.
    MESSAGE I000(0K) WITH '* Not a Packaging Material.'.
    EXIT.
  ENDIF.

  SET PARAMETER ID 'WRK' FIELD HUPAST_T-PLANT.
  SET PARAMETER ID 'LAG' FIELD HUPAST_T-STGE_LOC.
  SET PARAMETER ID 'HANDLINGUNIT' FIELD SPACE.
  CALL FUNCTION 'HU_PACKING_REFRESH'.
  GET PARAMETER ID 'HU_ST_INIT' FIELD FLD.

  REFRESH BDCDATA.
  PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLV51G                                6020TAB'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.
  IF FLD NE SPACE.
*   Entering packg matr
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.


    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
*    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
    PERFORM BDC_FIELD   USING 'V51VE-VHILM(01)' FCWA_PI-MATNR.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=ENTR'.
  ELSE.
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6ALLG'.
*    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6030TAB'.
*   General Header Data
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
*    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6030TAB'.
    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'HEADER51-PLANHU'.
    PERFORM BDC_FIELD   USING 'HEADER51-PLANHU'         'C'.
    PERFORM BDC_FIELD   USING 'HUM_MM_KOPFDATEN-WERKS'  HUPAST_T-PLANT.
    PERFORM BDC_FIELD   USING 'HUM_MM_KOPFDATEN-LGORT'  HUPAST_T-STGE_LOC.


*   Entering packg matr
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.
*    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
    PERFORM BDC_FIELD   USING 'V51VE-VHILM(01)' FCWA_PI-MATNR.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=ENTR'.
  ENDIF.
* Save
  PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLV51G                                6020TAB'.
*  PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=SICH'.

*  GS_MODE = 'E'.
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'A'.
  OPT-DEFSIZE  = 'X'.
  OPT-NOBINPT  = 'X'.
  OPT-RACOMMIT = 'X'.
*  CALL TRANSACTION 'HU02' USING BDCDATA MODE GS_MODE UPDATE 'A'
*                                MESSAGES INTO MSGS.
  CALL TRANSACTION 'HU02' USING BDCDATA OPTIONS FROM OPT MESSAGES INTO MSGS.

  IF MARA-VHART = '0003'.
    LVL = '01'.
  ELSE.
    LVL = '02'.
  ENDIF.

  READ TABLE MSGS INDEX 1 INTO WA.

  IF WA-TCODE = 'HU02' AND WA-MSGID = 'HUDIALOG' AND
     WA-MSGNR = '008'.


    GET PARAMETER ID 'HANDLINGUNIT' FIELD HUKEY.
    IF HUKEY IS INITIAL.
      MESSAGE I000(0K) WITH 'HU tidak dapat dibuat'.
      FCN_ERRNO = 4.
      RETURN.
    ELSE.
      CLEAR : RETURN.
      WHILE RETURN = ''.
        SELECT SINGLE EXIDV INTO RETURN
          FROM VEKP
          WHERE EXIDV = HUKEY.
      ENDWHILE.
    ENDIF.


*   Entering Packing Instruction in the HU Header
    REFRESH RETRN.
*   CHECK NOT hukey IS INITIAL.
    CLEAR HUHDR.

    PERFORM PROCESS_DELAYING.

*- update by ALF for Returnable pallet
*    PERFORM INSERT_PALID.  " insert HU to table ZPALLETR
*- end of update by ALF for Returnable pallet

    HUHDR-CONTENT = FCWA_PI+3(37).
    CALL FUNCTION 'BAPI_HU_CHANGE_HEADER'
      EXPORTING
        HUKEY     = HUKEY
        HUCHANGED = HUHDR
      TABLES
        RETURN    = RETRN.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = V_YES.


    FCS_EXIDV = HUKEY.

    PERFORM PROCESS_DELAYING.
    PERFORM F_GET_VENUM USING FCS_EXIDV CHANGING FCWA_HU-VENUM FCN_ERRNO.

    IF FCN_ERRNO EQ 0.
      MESSAGE S000(0K) WITH '* HU' HUKEY 'dibuat.'.
    ELSE.
      MESSAGE I000(0K) WITH '* HU tidak dapat dibuat.'.
    ENDIF.

  ELSE.
    FCN_ERRNO = 4.
    MESSAGE I000(0K) WITH '* HU tidak dapat dibuat.'.
  ENDIF.

ENDFORM.                    " f_hu_create_new


*&---------------------------------------------------------------------*
*&      Form  f_use_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_OPENPALLET  text
*      -->P_ITAB_USEDPALLET  text
*      -->P_N_PICKED  text
*----------------------------------------------------------------------*
FORM F_USE_PALLET
  TABLES   FT_OPENPALLET STRUCTURE ITAB_HU
           FT_USEDPALLET STRUCTURE ITAB_HU
  USING    FUN_PICKED
  CHANGING FCN_ERRNO.


  READ TABLE FT_USEDPALLET INDEX FUN_PICKED.

* use new pallet
  IF FT_USEDPALLET-VENUM = '<new>'.
    READ TABLE FT_OPENPALLET INDEX 1.
    MOVE-CORRESPONDING FT_OPENPALLET TO GWA_HU_PALLET.
    IF GWA_HU_PALLET-PRSTAT IS INITIAL.
      GWA_HU_PALLET-PRSTAT = C_PRSTAT_NOTPRINTED.
    ENDIF.

    PERFORM F_GET_PALLET_DETAIL.

*   create handling unit if the pallet do not have a hu number
    IF GWA_HU_PALLET-HUSTAT = C_HUSTAT_OPEN. "-- IS INITIAL.
      CLEAR GS_EXIDV_PALLET.

*- modify by ALF for returnable pallet
      PERFORM CEK_SO_PALID CHANGING FCN_ERRNO.

*     create handling unit   """"""""""""""
      IF FCN_ERRNO NE 4.
        PERFORM     F_HU_CREATE_NEW
          CHANGING  GS_EXIDV_PALLET
                    GWA_HU_PALLET
                    GWA_PC_PALLET
                    FCN_ERRNO.
      ENDIF.

      IF FCN_ERRNO EQ 0.
        PERFORM INSERT_PALID.  " insert HU to table ZPALLETR
*- end of modify by ALF for returnable pallet

*        gwa_hu_pallet-pinnr = gwa_pch-pinnr.
        PERFORM F_REC_HU_USAGE CHANGING GWA_HU_PALLET.
        UPDATE ZPACK_PCL       FROM GWA_HU_PALLET.


        DATA:
        LD_SUBRC(2),
        LD_PACKED(18),
        LD_DESCR TYPE TEXT255.

        MOVE SY-SUBRC TO LD_SUBRC.
        WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

        CONCATENATE '(' LD_SUBRC ') F_USE_PALLET, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
        CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.


        GS_NEW_PALLET = GS_EXIDV_PALLET.
        GWA_HU = GWA_HU_PALLET.

      ENDIF.

    ELSE.
      PERFORM     F_GET_EXIDV
        USING     GWA_HU_PALLET-VENUM
        CHANGING  GS_EXIDV_PALLET FCN_ERRNO.

      GWA_HU = GWA_HU_PALLET.
    ENDIF.

* use used pallet
  ELSE.
    READ TABLE FT_USEDPALLET INDEX FUN_PICKED.
    MOVE-CORRESPONDING FT_USEDPALLET TO GWA_HU_PALLET.
    IF GWA_HU_PALLET-PRSTAT IS INITIAL.
      GWA_HU_PALLET-PRSTAT = C_PRSTAT_NOTPRINTED.
    ENDIF.

    PERFORM     F_GET_PALLET_DETAIL.
    PERFORM     F_GET_EXIDV
      USING     GWA_HU_PALLET-VENUM
      CHANGING  GS_EXIDV_PALLET FCN_ERRNO.

    GWA_HU = GWA_HU_PALLET.
  ENDIF.

ENDFORM.                    " f_use_pallet


*&---------------------------------------------------------------------*
*&      Form  f_select_new_box
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_PINNR  text
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_SELECT_BOX CHANGING FCN_ERRNO.
  DATA ITAB_OPENBOX TYPE TABLE OF T_HU WITH HEADER LINE.
  DATA ITAB_USEDBOX TYPE TABLE OF T_HU WITH HEADER LINE.
  DATA N_SUSPENDED_COUNT TYPE I.
  DATA N_BOXED_COUNT TYPE I.
  DATA N_COUNT TYPE I.
  DATA N_PICKED TYPE I.

  N_PICKED = 0.
*  gs_exidv = gs_exidv_box.
  IF GWA_HU_BOX IS NOT INITIAL.
    GS_EXIDV = GS_EXIDV_BOX.
    GWA_HU   = GWA_HU_BOX.
    FCN_ERRNO = 1.
  ELSE.
    FCN_ERRNO = 0.
  ENDIF.

* use current pallet if still not complete.
  CHECK ( GWA_HU_BOX IS INITIAL )
     OR ( GWA_HU_BOX-HUSTAT = C_HUSTAT_COMPLETED )
     OR ( GWA_HU_BOX-HUSTAT = C_HUSTAT_FORCED )
     OR ( GWA_HU_BOX-HUSTAT = C_HUSTAT_CLOSED )
     OR ( GWA_HU_BOX-PINNR NE GWA_HU_PALLET-PINNR )
     OR ( GWA_HU_BOX-HUSEQ(4) NE GWA_HU_PALLET-HUSEQ(4) ).

  PERFORM     F_COUNT_PALLET_TYPE
    CHANGING  N_SUSPENDED_COUNT
              N_BOXED_COUNT.

  IF N_BOXED_COUNT > 0.
*   get all open boxes into itab_openbox
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE ITAB_OPENBOX
      FROM ZPACK_PCL
      WHERE PINNR = GWA_HU_PALLET-PINNR
        AND HUSEQ_P = GWA_HU_PALLET-HUSEQ
        AND HUSTAT = C_HUSTAT_OPEN.

    IF SY-SUBRC EQ 0.
      ITAB_USEDBOX-VENUM = '<new>'.
      APPEND ITAB_USEDBOX.

    ELSE.
*     -- ensure that all 'Open' pallet don't have any venum
      LOOP AT ITAB_OPENBOX.
        CLEAR:
        ITAB_OPENBOX-VENUM,
        ITAB_OPENBOX-PACKED.
        MODIFY ITAB_OPENBOX.
      ENDLOOP.

    ENDIF.

*   get all used boxes into itab_usedbox
    SELECT *
      APPENDING CORRESPONDING FIELDS OF TABLE ITAB_USEDBOX
      FROM ZPACK_PCL
      WHERE PINNR = GWA_HU_PALLET-PINNR
        AND HUSEQ_P = GWA_HU_PALLET-HUSEQ
        AND HUSTAT = C_HUSTAT_INPROGRESS.

    DESCRIBE TABLE ITAB_USEDBOX LINES N_COUNT.

    IF N_COUNT = 0.
      MESSAGE S001(00) WITH 'Tidak ada box yang dapat dipakai.'.
      FCN_ERRNO = 4.
      N_PICKED = 0.

    ELSEIF N_COUNT = 1.
*     If there is only one box available then set it up directly
      N_PICKED = 1.

    ELSE.
      PERFORM F_PICK_HU
        TABLES ITAB_USEDBOX
        USING 'BOX'
        CHANGING N_PICKED FCN_ERRNO.

    ENDIF.

    IF N_PICKED > 0.
      PERFORM F_USE_BOX
        TABLES ITAB_OPENBOX ITAB_USEDBOX
        USING N_PICKED CHANGING FCN_ERRNO.

    ELSE.
      CLEAR GWA_HU_BOX.
      CLEAR GS_EXIDV_BOX.

    ENDIF.

  ENDIF.

ENDFORM.                    " f_select_new_box


*&---------------------------------------------------------------------*
*&      Form  f_count_pallet_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM F_COUNT_PALLET_TYPE
  CHANGING FCN_SUSPENDED_COUNT
    FCN_BOXED_COUNT.


  SELECT COUNT( * )
    INTO FCN_SUSPENDED_COUNT
    FROM ZPACK_PC
    WHERE PINNR = GWA_HU_PALLET-PINNR
      AND ZINS01 = GWA_HU_PALLET-ZINS01
      AND ZINS02 <> '00'
      AND INILVL = C_LEVEL_ROLL.

  SELECT COUNT( * )
    INTO FCN_BOXED_COUNT
    FROM ZPACK_PC
    WHERE PINNR = GWA_HU_PALLET-PINNR
      AND ZINS01 = GWA_HU_PALLET-ZINS01
      AND ZINS02 <> '00'
      AND INILVL = C_LEVEL_BOX.

ENDFORM.                    " f_count_pallet_type


*&---------------------------------------------------------------------*
*&      Form  f_use_box
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_OPENBOX  text
*      -->P_ITAB_USEDBOX  text
*      -->P_N_PICKED  text
*----------------------------------------------------------------------*
FORM F_USE_BOX
  TABLES   FT_OPENBOX STRUCTURE ITAB_HU
           FT_USEDBOX STRUCTURE ITAB_HU
  USING    FUN_PICKED
  CHANGING FCN_ERRNO.


  READ TABLE FT_USEDBOX INDEX FUN_PICKED.

* use new pallet
  IF FT_USEDBOX-VENUM = '<new>'.
    READ TABLE   FT_OPENBOX   INDEX 1.
    MOVE-CORRESPONDING        FT_OPENBOX TO GWA_HU_BOX.
    IF GWA_HU_BOX-PRSTAT IS INITIAL.
      GWA_HU_BOX-PRSTAT = C_PRSTAT_NOTPRINTED.
    ENDIF.

    PERFORM F_REC_HU_USAGE    CHANGING GWA_HU_BOX.
    PERFORM F_GET_BOX_DETAIL.

*   if no handling unit then create one and pack it to the pallet
    IF GWA_HU_BOX-HUSTAT = C_HUSTAT_OPEN. "-- venum IS INITIAL.
      CLEAR GS_EXIDV_BOX.

      PERFORM     F_HU_CREATE_NEW
        CHANGING  GS_EXIDV_BOX
                  GWA_HU_BOX
                  GWA_PC_BOX
                  FCN_ERRNO.

      IF FCN_ERRNO EQ 0.
        UPDATE ZPACK_PCL FROM GWA_HU_BOX.

        DATA:
        LD_SUBRC(2),
        LD_PACKED(18),
        LD_DESCR TYPE TEXT255.

        MOVE SY-SUBRC TO LD_SUBRC.
        WRITE GWA_HU_BOX-PACKED TO LD_PACKED.

        CONCATENATE '(' LD_SUBRC ') F_USE_BOX, VENUM=' GWA_HU_BOX-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
        CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_BOX-HUSTAT INTO LD_DESCR.


        GWA_HU = GWA_HU_BOX.
        GS_NEW_BOX = GS_EXIDV_BOX.

*       pack the box with the pallet
        PERFORM F_PACK_BOX_TO_PALLET CHANGING FCN_ERRNO.

*       update pallet status when updated
        IF FCN_ERRNO EQ 0.
*          ADD 1 TO gwa_hu_pallet-packed.
          SELECT COUNT( * ) INTO GWA_HU_PALLET-PACKED FROM ZPACK_PCL
            WHERE PINNR   = GWA_HU_PALLET-PINNR
              AND HUSEQ_P = GWA_HU_PALLET-HUSEQ
              AND VENUM NE SPACE.

          GWA_HU_PALLET-HUSTAT = C_HUSTAT_INPROGRESS.
          PERFORM F_REC_HU_USAGE  CHANGING GWA_HU_PALLET.
          UPDATE ZPACK_PCL FROM GWA_HU_BOX.


          MOVE SY-SUBRC TO LD_SUBRC.
          WRITE GWA_HU_BOX-PACKED TO LD_PACKED.

          CONCATENATE '(' LD_SUBRC ') F_USE_BOX, VENUM=' GWA_HU_BOX-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
          CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_BOX-HUSTAT INTO LD_DESCR.

          UPDATE ZPACK_PCL FROM GWA_HU_PALLET.

          MOVE SY-SUBRC TO LD_SUBRC.
          WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

          CONCATENATE '(' LD_SUBRC ') F_USE_BOX, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
          CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.

        ELSE.
          PERFORM F_DELETE_NEW_BOX CHANGING FCN_ERRNO.
        ENDIF.

      ENDIF.

    ELSE.
      PERFORM F_GET_EXIDV
        USING GWA_HU_BOX-VENUM
        CHANGING GS_EXIDV_BOX FCN_ERRNO.

    ENDIF.

* use used pallet
  ELSE.
    READ TABLE FT_USEDBOX INDEX FUN_PICKED.
    MOVE-CORRESPONDING FT_USEDBOX TO GWA_HU_BOX.
    IF GWA_HU_BOX-PRSTAT IS INITIAL.
      GWA_HU_BOX-PRSTAT = C_PRSTAT_NOTPRINTED.
    ENDIF.

    PERFORM F_REC_HU_USAGE CHANGING GWA_HU_BOX.

    PERFORM F_GET_BOX_DETAIL.
    PERFORM F_GET_EXIDV
      USING GWA_HU_BOX-VENUM
      CHANGING GS_EXIDV_BOX FCN_ERRNO.

  ENDIF.

  IF FCN_ERRNO EQ 0.
    GWA_HU = GWA_HU_BOX.
    GS_EXIDV = GS_EXIDV_BOX.

  ENDIF.

ENDFORM.                    " f_use_box


*&---------------------------------------------------------------------*
*&      Form  f_get_pallet_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_PALLET_DETAIL.

  SELECT SINGLE * INTO GWA_PC_PALLET
    FROM ZPACK_PC
    WHERE PINNR = GWA_HU_PALLET-PINNR
      AND ZINS01 = GWA_HU_PALLET-ZINS01
      AND INILVL = C_LEVEL_PALLET.

  IF SY-SUBRC NE 0.
    MESSAGE I000(0K) WITH 'Packing instruction tidak konsisten.'.
  ENDIF.

ENDFORM.                    "f_get_pallet_detail


*&---------------------------------------------------------------------*
*&      Form  f_get_box_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_BOX_DETAIL.
  SELECT SINGLE * INTO GWA_PC_BOX
    FROM ZPACK_PC
    WHERE PINNR = GWA_HU_BOX-PINNR
      AND ZINS01 = GWA_HU_BOX-ZINS01
      AND ZINS02 = GWA_HU_BOX-ZINS02.
*      AND inilvl = c_level_box.

  IF SY-SUBRC NE 0.
    MESSAGE I000(0K) WITH 'Packing instruction tidak konsisten.'.
  ENDIF.

ENDFORM.                    "f_get_box_detail

*&---------------------------------------------------------------------*
*&      Form  f_autopack
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_AUTOPACK .
  DATA : WA LIKE HU_COM,
         V1 TYPE P DECIMALS 2,
         V2 TYPE I,
         N_PROCESSED_MATERIAL TYPE I,
         N_REC_COUNT TYPE I,
         N_BOX_COUNT TYPE I,
         N_ERRNO TYPE I.

  CLEAR : ITMPROPOSAL,SLOC_UPDATE.
  REFRESH : ITMPROPOSAL, RETRN.

* any empty hu?
  READ TABLE HU_COM WITH KEY EXID = SPACE.
  IF SY-SUBRC NE 0.
    MESSAGE I000(0K) WITH 'HU sudah terpenuhi.'.
    RETURN.
  ENDIF.

  N_PROCESSED_MATERIAL = SY-TABIX.
  HU_COM-EXID = ZPACK00-CHARGDC.
  MODIFY HU_COM INDEX N_PROCESSED_MATERIAL.

* pack with nearest hu and update nearest hu status
  PERFORM F_HU_PACK_MATERIAL CHANGING N_ERRNO SLOC_UPDATE.

  IF N_ERRNO NE 0.
    HU_COM-EXID = ''.
    MODIFY HU_COM INDEX N_PROCESSED_MATERIAL.
    MESSAGE I000(0K) WITH 'Tidak dapat melakukan packing ke HU.'.

    PERFORM F_DELETE_NEW_BOX CHANGING N_ERRNO.
    PERFORM F_DELETE_NEW_PALLET CHANGING N_ERRNO.
    RETURN.

  ENDIF.

  WA = HU_COM.


* update quantity and status of handling unit (venum)
  SELECT COUNT( * ) INTO GWA_HU-PACKED FROM VEPO
    WHERE VENUM = GWA_HU-VENUM.

  PERFORM F_COMPLETE_HU CHANGING N_ERRNO.
  IF N_ERRNO NE 0.
    ROLLBACK WORK.
    RETURN.
  ENDIF.

  MESSAGE S000(0K) WITH '* Batch' WA-EXID 'dipack ke HU' GS_EXIDV.

* Auto Scroll
  IF N_PROCESSED_MATERIAL > MAXLOOP.
    V1 = N_PROCESSED_MATERIAL / MAXLOOP.
    V2 = TRUNC( V1 ).
    PAGEBEGIN = V2 * MAXLOOP.
  ENDIF.

* Update Status in screen to "Pck" (Packed)
  READ TABLE HU_COM INDEX N_PROCESSED_MATERIAL.

  IF GWA_HU_PALLET-HUSTAT = C_HUSTAT_CLOSED.
    HU_COM-STAT = 'Cls'.
  ELSE.
    PERFORM F_GET_DOMAIN_TEXT
      USING     'ZPCKST'     C_PCKST_PACKED
      CHANGING  HU_COM-STAT  N_ERRNO.
  ENDIF.

  MODIFY HU_COM INDEX N_PROCESSED_MATERIAL.

  CLEAR:
    GS_NEW_BOX,
    GS_NEW_PALLET.

  COMMIT WORK AND WAIT.
ENDFORM.                    " f_autopack


*&---------------------------------------------------------------------*
*&      Form  f_delete_new_box
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FCN_ERRNO  text
*----------------------------------------------------------------------*
FORM F_DELETE_NEW_BOX CHANGING FCN_ERRNO.
  IF GS_NEW_BOX IS NOT INITIAL.
    IF GWA_HU = GWA_HU_BOX.
      CLEAR GWA_HU.
      CLEAR GS_EXIDV.
    ENDIF.

    IF GWA_HU_PALLET-PACKED = 0.
      PERFORM F_HU_DELETE_NEW CHANGING GWA_HU_BOX GS_EXIDV_BOX FCN_ERRNO.
    ENDIF.

    CLEAR GS_NEW_BOX.
  ENDIF.

ENDFORM.                    "f_delete_new_box


*&---------------------------------------------------------------------*
*&      Form  f_delete_new_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FCN_ERRNO  text
*----------------------------------------------------------------------*
FORM F_DELETE_NEW_PALLET CHANGING FCN_ERRNO.
  IF GS_NEW_PALLET IS NOT INITIAL.
    IF GWA_HU = GWA_HU_PALLET.
      CLEAR GWA_HU.
      CLEAR GS_EXIDV.
    ENDIF.

    IF GWA_HU_PALLET-PACKED = 0.
      PERFORM F_HU_DELETE_NEW CHANGING GWA_HU_PALLET GS_EXIDV_PALLET FCN_ERRNO.
    ENDIF.

    CLEAR GS_NEW_PALLET.
  ENDIF.

ENDFORM.                    "f_delete_new_pallet

*&---------------------------------------------------------------------*
*&      Form  f_get_domain_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FUS_DOMAIN text
*      -->FUS_VALUE  text
*      -->FCS_TEXT   text
*      -->FC_ERRNO   text
*----------------------------------------------------------------------*
FORM F_GET_DOMAIN_TEXT
  USING    FUS_DOMAIN  FUS_VALUE
  CHANGING FCS_TEXT    FCN_ERRNO.

  DATA S_NAME  LIKE  DD07V-DOMNAME.
  DATA S_VALUE LIKE  DD07V-DOMVALUE_L.
  DATA S_TEXT  LIKE  DD07V-DDTEXT.

  S_NAME  = FUS_DOMAIN.
  S_VALUE = FUS_VALUE.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
    EXPORTING
      I_DOMNAME  = S_NAME
      I_DOMVALUE = S_VALUE
    IMPORTING
      E_DDTEXT   = S_TEXT
    EXCEPTIONS
      NOT_EXIST  = 1
      OTHERS     = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    FCN_ERRNO = SY-SUBRC.
    CLEAR FCS_TEXT.

  ELSE.
    FCN_ERRNO = 0.
    FCS_TEXT  = S_TEXT.

  ENDIF.

ENDFORM.                    "f_get_domain_text


*&---------------------------------------------------------------------*
*&      Form  f_get_exidv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_gwa_hu_VENUM  text
*      <--P_GS_EXIDV_BOX  text
*----------------------------------------------------------------------*
FORM F_GET_EXIDV  USING    FUS_VENUM
                  CHANGING FCS_EXIDV FCN_ERRNO.

  SELECT SINGLE EXIDV INTO FCS_EXIDV
    FROM VEKP WHERE VENUM = FUS_VENUM.

  IF SY-SUBRC NE 0.
    FCN_ERRNO = 4.
    CLEAR FCS_EXIDV.

  ELSE.
    FCN_ERRNO = 0.

  ENDIF.
ENDFORM.                    " f_get_exidv


*&---------------------------------------------------------------------*
*&      Form  f_get_venum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FCS_EXIDV  text
*      <--P_FCWA_HU_VENUM  text
*----------------------------------------------------------------------*
FORM F_GET_VENUM  USING    FUS_EXIDV
                  CHANGING FCS_VENUM
                           FCN_ERRNO.

  SELECT SINGLE VENUM INTO FCS_VENUM
    FROM VEKP WHERE EXIDV = FUS_EXIDV.

  FCN_ERRNO = SY-SUBRC.
  IF FCN_ERRNO NE 0.
    CLEAR FCS_VENUM.
    FCN_ERRNO = 4.
  ENDIF.
ENDFORM.                    " f_get_venum


*&---------------------------------------------------------------------*
*&      Form  f_pack_box_to_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PACK_BOX_TO_PALLET CHANGING FCN_ERRNO .
  REFRESH ITMPROPOSAL.
  CLEAR ITMPROPOSAL.

  FCN_ERRNO = 0.
  HUKEY = GS_EXIDV_PALLET.

  PERFORM F_GET_SHEET CHANGING SHEET.

  ITMPROPOSAL-HU_ITEM_TYPE      = '3'.
*  itmproposal-material          = gwa_pc_box-matnr.
  ITMPROPOSAL-PACK_QTY          = '1'.
  IF SHEET = 'X'.
    ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'PAK'.
    ITMPROPOSAL-BASE_UNIT_QTY     = 'PAK'.
  ELSE.
    ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'BOX'.
    ITMPROPOSAL-BASE_UNIT_QTY     = 'BOX'.
  ENDIF.
  ITMPROPOSAL-LOWER_LEVEL_EXID  = GS_EXIDV_BOX.
*  itmproposal-plant             = hupast_t-plant.
*  itmproposal-stge_loc          = hupast_t-stge_loc.
*  itmproposal-spec_stock        = 'E'.
*  itmproposal-sp_stck_no        = gs_sonum.

  APPEND ITMPROPOSAL.

  CALL FUNCTION 'BAPI_HU_PACK'
    EXPORTING
      HUKEY        = HUKEY
      ITEMPROPOSAL = ITMPROPOSAL
    IMPORTING
      HUITEM       = HUITM
      HUHEADER     = HUHDR
    TABLES
      RETURN       = RETRN.

  IF NOT RETRN[] IS INITIAL.
    READ TABLE RETRN INDEX 1.
    MESSAGE I000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
    FCN_ERRNO = 4.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = V_YES.

    PERFORM F_TEST_HU_PACKING CHANGING FCN_ERRNO.
    IF FCN_ERRNO EQ 0.
      MESSAGE S000(0K) WITH '* HU' HUKEY 'Packed.'.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_pack_box_to_pallet


*&---------------------------------------------------------------------*
*&      Form  f_test_hu_packing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FCN_ERRNO  text
*----------------------------------------------------------------------*
FORM F_TEST_HU_PACKING CHANGING FCN_ERRNO.
  DATA:
    HDR    LIKE HUHDR OCCURS 2 WITH HEADER LINE,
    ITM    LIKE HUITM OCCURS 2 WITH HEADER LINE,
    HUNUMB LIKE BAPIHUNUMBER OCCURS 2 WITH HEADER LINE,
    HI     LIKE BAPIHUINTERNAL  OCCURS 1 WITH HEADER LINE,
    UNPACK TYPE BAPIHUITMUNPACK OCCURS 1 WITH HEADER LINE,
    MSTEXT(100).

  REFRESH : HUNUMB, HDR, ITM, HI, RETRN.
  HUNUMB-HU_EXID = GS_EXIDV_PALLET.
  APPEND HUNUMB.

  CALL FUNCTION 'BAPI_HU_GETLIST'
    EXPORTING
      NOTEXT       = ' '
      ONLYKEYS     = ' '
    TABLES
      HUNUMBERS    = HUNUMB
      HUHEADER     = HDR
      HUITEM       = ITM
      HIGHESTLEVEL = HI
      RETURN       = RETRN.

  FCN_ERRNO = SY-SUBRC.
  IF ( FCN_ERRNO = 0 ) AND ( NOT RETRN[] IS INITIAL ).
    READ TABLE RETRN WITH KEY TYPE = 'E'.
    IF SY-SUBRC EQ 0.
      FCN_ERRNO = 4.

    ELSE.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          ID   = RETRN-ID
          LANG = SY-LANGU
          NO   = RETRN-NUMBER
          V1   = RETRN-MESSAGE_V1
          V2   = RETRN-MESSAGE_V2
          V3   = RETRN-MESSAGE_V3
          V4   = RETRN-MESSAGE_V4
        IMPORTING
          MSG  = MSTEXT.

      MESSAGE S000(0K) WITH MSTEXT.
    ENDIF.
  ENDIF.

  IF FCN_ERRNO EQ 0.
    READ TABLE ITM WITH KEY LOWER_LEVEL_EXID = GS_EXIDV_BOX.
    IF SY-SUBRC NE 0.
      FCN_ERRNO = 4.
      MESSAGE I000(0K) WITH 'Box gagal di pack ke pallet.'.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_test_hu_packing


*&---------------------------------------------------------------------*
*&      Form  f_pack_material_to_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_PACK_MATERIAL CHANGING FCN_ERRNO FCSLOC_UPDATE.
  DATA : SLOC TYPE LGORT_D,
         FM,
         WERKS TYPE WERKS_D.

  FCN_ERRNO = 0.
  HUKEY = GS_EXIDV.
  PERFORM F_GET_SLOC_FM CHANGING FM SLOC.
  IF SLOC = ''.
    SLOC  = HUPAST_T-STGE_LOC.
    WERKS = HUPAST_T-PLANT.
  ELSE.
    SELECT SINGLE WERK2 INTO WERKS
      FROM ZHU_MAPP
      WHERE LGOR1 = SLOC
      AND WERK1 = HUPAST_T-PLANT. "ADD NEW COMPANY
    SLOC_UPDATE = SLOC.
  ENDIF.


  PERFORM F_GET_SHEET CHANGING SHEET.


  ITMPROPOSAL-HU_ITEM_TYPE      = '1'.
  ITMPROPOSAL-MATERIAL          = HU_COM-INST.
  ITMPROPOSAL-PACK_QTY          = '1'.
  IF SHEET = 'X'.
    ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'PAK'.
    ITMPROPOSAL-BASE_UNIT_QTY     = 'PAK'.
  ELSE.
    ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'ROL'.
    ITMPROPOSAL-BASE_UNIT_QTY     = 'ROL'.
  ENDIF.
  ITMPROPOSAL-BATCH             = HU_COM-EXID.
  ITMPROPOSAL-PLANT             = WERKS. "HUPAST_T-PLANT.
  ITMPROPOSAL-STGE_LOC          = SLOC. "HUPAST_T-STGE_LOC.
  ITMPROPOSAL-SP_STCK_NO        = GS_SONUM.

  IF GB_IS_FREESTOCK = V_YES.
    ITMPROPOSAL-SPEC_STOCK        = ' '.
  ELSE.
    ITMPROPOSAL-SPEC_STOCK        = 'E'.
  ENDIF.

  APPEND ITMPROPOSAL.


  CALL FUNCTION 'BAPI_HU_PACK'
    EXPORTING
      HUKEY        = HUKEY
      ITEMPROPOSAL = ITMPROPOSAL
    IMPORTING
      HUITEM       = HUITM
      HUHEADER     = HUHDR
    TABLES
      RETURN       = RETRN.

  IF NOT RETRN[] IS INITIAL.
    READ TABLE RETRN INDEX 1.
    MESSAGE I000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
    FCN_ERRNO = 4.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = V_YES.
    MESSAGE S000(0K) WITH '* HU' HUKEY 'Packed.'.

  ENDIF.

ENDFORM.                    " f_pack_material_to_hu


*&---------------------------------------------------------------------*
*&      Form  f_incomplete_box_count
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_INCOMPLETE_BOX_COUNT CHANGING FCN_BOX_COUNT.

  DATA : TPCL LIKE ZPACK_PCL OCCURS 0 WITH HEADER LINE.
  DATA : NOT_COMPLETE,
         LINE TYPE I,
         BOX_INS TYPE I.
  CLEAR : TPCL,NOT_COMPLETE . REFRESH : TPCL.

  SELECT * FROM ZPACK_PCL INTO TABLE TPCL
     WHERE PINNR = GWA_HU_PALLET-PINNR
*     AND HUSEQ_P NE '000000'.
     AND  HUSEQ_P = GWA_HU_PALLET-HUSEQ.
  DESCRIBE TABLE TPCL LINES LINE.

  IF LINE = 0.
    SELECT COUNT( * ) INTO FCN_BOX_COUNT FROM ZPACK_PCL
      WHERE PINNR = GWA_HU_PALLET-PINNR
        AND HUSEQ = GWA_HU_PALLET-HUSEQ
        AND HUSTAT IN (C_HUSTAT_OPEN, C_HUSTAT_INPROGRESS).
    RETURN.
  ENDIF.

  LOOP AT TPCL.
    IF TPCL-VENUM = ''.
      NOT_COMPLETE = V_YES.
      EXIT.
    ENDIF.

    SELECT COUNT( * ) INTO FCN_BOX_COUNT FROM VEPO
       WHERE VENUM = TPCL-VENUM.

    SELECT SINGLE ZMENG INTO BOX_INS FROM ZPACK_PC
      WHERE PINNR = TPCL-PINNR
      AND   ZINS01 = TPCL-ZINS01
      AND   INILVL = '3'.

*    IF TPCL-PACKED NE FCN_BOX_COUNT.
    IF BOX_INS NE FCN_BOX_COUNT.
      NOT_COMPLETE = V_YES.
    ENDIF.
  ENDLOOP.

  IF NOT_COMPLETE = V_NO.
    FCN_BOX_COUNT = 0.
  ENDIF.
ENDFORM.                    " f_incomplete_box_count

*&---------------------------------------------------------------------*
*&      Form  f_hu_unpack_material
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FUWA_UNPACK_TASK  text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK_TASK
  USING FUWA_UNPACK_TASK TYPE T_UNPACK_TASK
  CHANGING FCN_ERRNO.

  DATA ITAB_RETURN   TYPE TABLE OF BAPIRET2 WITH HEADER LINE.
  DATA WA_UNPACK     TYPE BAPIHUITMUNPACK.
  DATA WA_ITEM       TYPE VEPO.
  DATA S_HUKEY       TYPE EXIDV.

  SELECT SINGLE * INTO WA_ITEM
    FROM VEPO
    WHERE VENUM = FUWA_UNPACK_TASK-VENUM
      AND VELIN = FUWA_UNPACK_TASK-VELIN
      AND CHARG = FUWA_UNPACK_TASK-CHARG.
*      AND sonum = fuwa_unpack_task-sonum.

  CHECK SY-SUBRC EQ 0.
  S_HUKEY = FUWA_UNPACK_TASK-EXIDV.

  WA_UNPACK-HU_ITEM_TYPE       = WA_ITEM-VELIN.
  WA_UNPACK-MATERIAL           = WA_ITEM-MATNR.
  WA_UNPACK-PACK_QTY           = FUWA_UNPACK_TASK-VEMNG.
  CLEAR WA_UNPACK-HU_ITEM_NUMBER. "--wa_item-vepos.

  PERFORM F_GET_SHEET CHANGING SHEET.

*   velin=1:Material unpack
  IF WA_ITEM-VELIN = '1'.
    WA_UNPACK-BATCH              = WA_ITEM-CHARG.
    IF SHEET = 'X'.
      WA_UNPACK-BASE_UNIT_QTY_ISO  = 'PAK'.
      WA_UNPACK-BASE_UNIT_QTY      = 'PAK'.
    ELSE.
      WA_UNPACK-BASE_UNIT_QTY_ISO  = 'ROL'.          "--wa_item-vemeh.
      WA_UNPACK-BASE_UNIT_QTY      = 'ROL'.          "--wa_item-altme.
    ENDIF.
    WA_UNPACK-UNPACK_EXID        = S_HUKEY.
    WA_UNPACK-PLANT              = WA_ITEM-WERKS.
    WA_UNPACK-STGE_LOC           = WA_ITEM-LGORT.
    WA_UNPACK-STOCK_CAT          = WA_ITEM-BESTQ.
    WA_UNPACK-SPEC_STOCK         = WA_ITEM-SOBKZ.
    WA_UNPACK-SP_STCK_NO         = WA_ITEM-SONUM.


*   velin=3:HU unpack (must be a box)
  ELSEIF WA_ITEM-VELIN = '3'.
    WA_UNPACK-BASE_UNIT_QTY_ISO  = 'BOX'.          "--wa_item-vemeh.
    WA_UNPACK-BASE_UNIT_QTY      = 'BOX'.          "--wa_item-altme.
    WA_UNPACK-UNPACK_EXID        = FUWA_UNPACK_TASK-UNPACK_EXID.

  ENDIF.

  REFRESH ITAB_RETURN.

  CALL FUNCTION 'BAPI_HU_UNPACK'
    EXPORTING
      HUKEY      = S_HUKEY
      ITEMUNPACK = WA_UNPACK
    TABLES
      RETURN     = ITAB_RETURN.

  IF ITAB_RETURN[] IS NOT INITIAL.
    FCN_ERRNO = 4.
    READ TABLE ITAB_RETURN INDEX 1.
    MESSAGE I000(0K) WITH ITAB_RETURN-MESSAGE.
  ENDIF.


ENDFORM.                    "f_hu_unpack_material

*&---------------------------------------------------------------------*
*&      Form  f_can_unpack
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_HDR  text
*      -->P_ITM  text
*      -->P_HUNUMB  text
*      -->P_HI  text
*      <--P_B_CAN_UNPACK  text
*----------------------------------------------------------------------*
FORM F_CAN_UNPACK
  CHANGING
    FCB_CAN_UNPACK.

  DATA:
    HDR    LIKE HUHDR OCCURS 2 WITH HEADER LINE,
    ITM    LIKE HUITM OCCURS 2 WITH HEADER LINE,
    HUNUMB LIKE BAPIHUNUMBER OCCURS 2 WITH HEADER LINE,
    HI     LIKE BAPIHUINTERNAL  OCCURS 1 WITH HEADER LINE,
    UNPACK TYPE BAPIHUITMUNPACK OCCURS 1 WITH HEADER LINE,
    TABIX  LIKE SY-TABIX,
    RETCODE(02),
    QMCODE(02),
    MSTEXT(100).


  FCB_CAN_UNPACK = V_YES.

* Read Packing Document
  REFRESH : HUNUMB, HDR, ITM, HI, RETRN.
  HUNUMB-HU_EXID = GS_EXIDV_PALLET.
  APPEND HUNUMB.

  CALL FUNCTION 'BAPI_HU_GETLIST'
    EXPORTING
      NOTEXT       = ' '
      ONLYKEYS     = ' '
    TABLES
      HUNUMBERS    = HUNUMB
      HUHEADER     = HDR
      HUITEM       = ITM
      HIGHESTLEVEL = HI
      RETURN       = RETRN.

  IF NOT RETRN[] IS INITIAL.
    READ TABLE RETRN INDEX 1.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        ID   = RETRN-ID
        LANG = SY-LANGU
        NO   = RETRN-NUMBER
        V1   = RETRN-MESSAGE_V1
        V2   = RETRN-MESSAGE_V2
        V3   = RETRN-MESSAGE_V3
        V4   = RETRN-MESSAGE_V4
      IMPORTING
        MSG  = MSTEXT.

    MESSAGE S000(0K) WITH MSTEXT.

    IF RETRN-TYPE = 'E'.
      FCB_CAN_UNPACK = V_NO.
      CLEAR HUKEY.
      RETURN.

    ENDIF.

  ENDIF.

* Unpack Process
  CLEAR HUKEY.

  READ TABLE HI INDEX 1.
  READ TABLE HDR WITH KEY HU_ID = HI-HU_ID.

  IF SY-SUBRC = 0.
    HUKEY = HDR-HU_EXID.
*   No unpack for QM in Process
    SELECT * FROM ZQM001 WHERE EXIDV = HUKEY
    ORDER BY ZQM001~AEDAT ZQM001~AETIME ASCENDING.
    ENDSELECT.

    IF SY-SUBRC = 0.
      CASE ZQM001-PSTAT.
        WHEN 'P'.
          MESSAGE I000(0K) WITH '* HU in QA Pass'.
          QMCODE = 'X'.

        WHEN 'H'.
          MESSAGE I000(0K) WITH '* HU in QA Hold'.
*          QMCODE = ''.
*          FCB_CAN_UNPACK = V_NO.
*          RETURN.
          QMCODE = 'X'.
        WHEN ' '.
          MESSAGE I000(0K) WITH '* HU in QA Initial'.

      ENDCASE.

    ENDIF.

  ENDIF.

  IF QMCODE = 'X'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'HU in Used by QM Area'
        TEXT_QUESTION         = 'Do you want Un-Pack HU Document ? '
        TEXT_BUTTON_1         = 'Yes'
        TEXT_BUTTON_2         = 'No'
        DEFAULT_BUTTON        = 'A'
        DISPLAY_CANCEL_BUTTON = 'X'
      IMPORTING
        ANSWER                = ANS.

    IF ANS NE '1'.
      FCB_CAN_UNPACK = V_NO.
      RETURN.
    ENDIF.

  ENDIF.

  IF ITM[] IS INITIAL.
    FCB_CAN_UNPACK = V_NO.
  ELSE.
    READ TABLE ITM WITH KEY HU_ITEM_TYPE = 1.
    IF ( ITM-STGE_LOC NE HUPAST_T-STGE_LOC AND OK_CODE = 'UNPACK' ).
      FCB_CAN_UNPACK = V_NO.
      MESSAGE I000(0K) WITH 'HU tidak di storage location' HUPAST_T-STGE_LOC.
    ENDIF.
    FCB_CAN_UNPACK = V_YES.


  ENDIF.

ENDFORM.                    " f_can_unpack


*&---------------------------------------------------------------------*
*&      Form  F_HU_CLOSE_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FCN_ERRNO  text
*----------------------------------------------------------------------*
FORM F_HU_CLOSE_NEW CHANGING FCN_ERRNO.
  DATA : MSGS TYPE TABLE OF BDCMSGCOLL,
         WA   LIKE BDCMSGCOLL,
         FM TYPE ZPACK_PCL-FM,
         SLOC TYPE ZPACK_PCL-SLOC_UP,
         LGOR2 TYPE LGORT_D,
         LGOR1 TYPE LGORT_D,
         WERK2 TYPE WERKS_D,
         CLFLAG.

  DATA : TPCL LIKE ZPACK_PCL OCCURS 0 WITH HEADER LINE.

  IF GS_EXIDV_PALLET = SPACE.
    MESSAGE I000(0K) WITH '* No Handling Unit.'.
    EXIT.
  ENDIF.


  SET PARAMETER ID 'WRK' FIELD HUPAST_T-PLANT.
  SET PARAMETER ID 'LAG' FIELD HUPAST_T-HU_STGE_LOC.

  LGOR1 = HUPAST_T-HU_STGE_LOC.
  PERFORM F_GET_SLOC_FM CHANGING FM SLOC.
  IF SLOC NE ''.
    SELECT SINGLE LGOR2 WERK2 INTO (LGOR2,WERK2)
    FROM ZHU_MAPP
    WHERE TYPES = '11'
    AND   LGOR1 = SLOC
    AND   WERK1 = HUPAST_T-PLANT.  "ADD NEW COMPANY
    LGOR1 = LGOR2.
    SET PARAMETER ID 'WRK' FIELD WERK2.
    SET PARAMETER ID 'LAG' FIELD LGOR2.

  ENDIF.

  REFRESH BDCDATA.
  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'      '2000'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLLE_MOV                              2013TAB_SUB'.
  PERFORM BDC_FIELD   USING 'BDC_CURSOR   '       'LEMOVHUS-HUWBEVENT'.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-HUWBEVENT'  '0006'.   "Movm 311
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLLE_MOV                              2010HU_FRAME'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLLE_MOV                              2017SUB_BUT'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=TCVG'. "TCVG'.
*
  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'      '2000'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLLE_MOV                              2013TAB_SUB'.
  PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'LEMOVHUS-EXIDV'.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-LGORT'  LGOR1. "HUPAST_T-HU_STGE_LOC.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-HUWBEVENT'  '0006'.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-EXIDV'       GS_EXIDV_PALLET.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLLE_MOV                              2010HU_FRAME'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLLE_MOV                              2017SUB_BUT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=TCHC'.

  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'      '2000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=TCWB'.
  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'      '2001'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '/ETCBA'.
*
  GS_MODE = 'E'.
  CALL TRANSACTION 'VLMOVE' USING BDCDATA MODE GS_MODE UPDATE 'S'
                                  MESSAGES INTO MSGS.

  READ TABLE MSGS INDEX 1 INTO WA.
  IF SY-SUBRC EQ 0.
    MESSAGE I000(0K) WITH WA-MSGID WA-MSGNR WA-MSGV1 WA-MSGV2.
  ENDIF.

  DATA S_SLOC TYPE LGORT_D.

  PERFORM F_CHECK_HU_SLOC USING GWA_HU-VENUM CHANGING S_SLOC.


  IF SLOC = ''.
    IF S_SLOC NE HUPAST_T-HU_STGE_LOC.
      FCN_ERRNO = 4.
    ENDIF.
  ENDIF.


  IF FCN_ERRNO = 4.
    MESSAGE I000(0K) WITH 'HU tidak dapat di close'.

  ELSE.
    LOOP AT HU_COM.  "-- WHERE ins0 = zpack00-zins01.
      HU_COM-STAT = 'Cls'.
      MODIFY HU_COM INDEX SY-TABIX.
    ENDLOOP.

    GWA_HU_PALLET-HUSTAT = C_HUSTAT_CLOSED.
    GWA_HU_PALLET-SLOC_UP = V_NO.
    UPDATE ZPACK_PCL FROM GWA_HU_PALLET.

    SELECT * FROM ZPACK_PCL INTO TABLE TPCL
      WHERE ( PINNR = GWA_HU_PALLET-PINNR
      AND    HUSEQ = GWA_HU_PALLET-HUSEQ )
      OR ( PINNR = GWA_HU_PALLET-PINNR AND
      HUSEQ_P = GWA_HU_PALLET-HUSEQ ).

    LOOP AT TPCL.
      TPCL-FM = V_YES.
      SLOC_UP = V_NO.
      MODIFY TPCL.
    ENDLOOP.

    UPDATE ZPACK_PCL  FROM TABLE TPCL.

*- update or automatic QA PASS
    PERFORM F_UPDATE_PASS.

    DATA:
    LD_SUBRC(2),
    LD_PACKED(18),
    LD_DESCR TYPE TEXT255.

    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_HU_CLOSE_NEW, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
    CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.

    IF GWA_HU_BOX IS INITIAL.
      GWA_HU = GWA_HU_PALLET.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_hu_close_new


*&---------------------------------------------------------------------*
*&      Form  f_load_hu
*&---------------------------------------------------------------------*
*       Load HU and its related packing instruction
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOAD_HU
  USING    FUS_EXIDV
  CHANGING FCN_ERRNO.

  DATA:
    WA_HU           LIKE GWA_HU,
    WA_HU_BOX       LIKE GWA_HU_BOX,
    WA_HU_PALLET    LIKE GWA_HU_PALLET,
    WA_PCH          LIKE GWA_PCH,
    WA_PC           LIKE GWA_PC,
    WA_PC_BOX       LIKE GWA_PC_BOX,
    WA_PC_PALLET    LIKE GWA_PC_PALLET,
    S_EXIDV         LIKE GS_EXIDV,
    S_EXIDV_BOX     LIKE GS_EXIDV_BOX,
    S_EXIDV_PALLET  LIKE GS_EXIDV_PALLET.


  FCN_ERRNO = 0.

  TRY.
      S_EXIDV = FUS_EXIDV.

*   read the handling unit for packed item (using hu internal number)
      SELECT SINGLE * INTO WA_HU
        FROM ZPACK_PCL
        WHERE VENUM = VENUM.

*   load packing instruction header for this handling unit
      SELECT SINGLE * INTO WA_PCH
        FROM ZPACK_PCH
        WHERE PINNR = WA_HU-PINNR.

*   load packing instruction details for this handling unit
      SELECT SINGLE * INTO WA_PC
        FROM ZPACK_PC
        WHERE PINNR  = WA_HU-PINNR
          AND ZINS01 = WA_HU-ZINS01
          AND ZINS02 = WA_HU-ZINS02.

      IF WA_HU-ZINS02  = '00'.      "-- suspended pallet (no box)
        WA_HU_PALLET   = WA_HU.      "-- material hu is a pallet
        WA_PC_PALLET   = WA_PC.
        "- material packing instruction is for pallet
        S_EXIDV_PALLET = FUS_EXIDV.
        "-- ext hu number is pallet ext hu number

        CLEAR WA_HU_BOX.
        CLEAR WA_PC_BOX.
        CLEAR S_EXIDV_BOX.

      ELSE.                          "-- boxed (using box)
        WA_HU_BOX   = WA_HU.         "-- material hu is a box
        WA_PC_BOX   = WA_PC.
        "-- material packing instruction is for box
        S_EXIDV_BOX = S_EXIDV.
        "-- ext hu number is box ext hu number

*     read pallet info
        SELECT SINGLE * INTO WA_HU_PALLET
        FROM ZPACK_PCL
        WHERE PINNR = WA_HU_BOX-PINNR
          AND HUSEQ = WA_HU_BOX-HUSEQ_P.

        SELECT SINGLE * INTO WA_PC_PALLET
          FROM ZPACK_PC
          WHERE PINNR  = WA_HU_PALLET-PINNR
            AND ZINS01 = WA_HU_PALLET-ZINS01
            AND ZINS02 = WA_HU_PALLET-ZINS02.

        PERFORM    F_GET_EXIDV
          USING    WA_HU_PALLET-VENUM
          CHANGING S_EXIDV_PALLET FCN_ERRNO.

      ENDIF.

      GWA_HU            = WA_HU          .
      GWA_HU_BOX        = WA_HU_BOX      .
      GWA_HU_PALLET     = WA_HU_PALLET   .
      GWA_PCH           = WA_PCH         .
      GWA_PC            = WA_PC          .
      GWA_PC_BOX        = WA_PC_BOX      .
      GWA_PC_PALLET     = WA_PC_PALLET   .
      GS_EXIDV          = S_EXIDV        .
      GS_EXIDV_BOX      = S_EXIDV_BOX    .
      GS_EXIDV_PALLET   = S_EXIDV_PALLET .

      SELECT SUM( ZMENG ) INTO ZPACK00-PLCNT FROM ZPACK_PC
        WHERE PINNR = GWA_PCH-PINNR AND INILVL = C_LEVEL_PALLET.

    CATCH CX_ROOT INTO EX.
      FCN_ERRNO = 4.
      MSG = EX.

      DATA TX TYPE STRING.
      TX = MSG->GET_TEXT( ).
      MESSAGE E000(0K) WITH TX.

  ENDTRY.

ENDFORM.                    " f_load_hu


*&---------------------------------------------------------------------*
*&      Form  f_read_customer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_READ_CUSTOMER USING FUS_SO CHANGING FCN_ERRNO.
  SELECT SINGLE VBELN AUART VBAK~KUNNR KNA1~KUNNR NAME1
    INTO (VBAK-VBELN, VBAK-AUART, VBAK-KUNNR, KNA1-KUNNR, KNA1-NAME1)
    FROM VBAK INNER JOIN KNA1 ON VBAK~KUNNR = KNA1~KUNNR
    WHERE VBELN = FUS_SO
      AND KNA1~SPRAS = SY-LANGU.

  FCN_ERRNO = SY-SUBRC.
  IF FCN_ERRNO NE 0.
    MESSAGE I000(0K) WITH 'Customer tidak ditemukan'.
  ELSE.
    V_SO = FUS_SO.
    PERFORM F_GET_DESTINATION USING V_SO.
  ENDIF.

ENDFORM.                    " f_read_customer


*&---------------------------------------------------------------------*
*&      Form  f_unlock_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UNLOCK_NEW .
  DATA S_LOOBJ TYPE ZTLOCK-LOOBJ.

  CONCATENATE
    'PCL'
    GWA_HU_PALLET-PINNR
    GWA_HU_PALLET-HUSEQ
    INTO S_LOOBJ.

  IF GWA_HU_PALLET IS NOT INITIAL.

    CALL FUNCTION 'DEQUEUE_EZPACK_PCL'
      EXPORTING
        MANDT = SY-MANDT
        LOOBJ = S_LOOBJ.

    PERFORM F_REC_HU_USAGE CHANGING GWA_HU_PALLET.
    PERFORM F_REC_HU_USAGE CHANGING GWA_HU_BOX.
*
*   clear pallet and box 'computer_name'
    GWA_HU_PALLET-COMPUTER_NAME = ''.
    GWA_HU_BOX-COMPUTER_NAME    = ''.

    UPDATE  ZPACK_PCL
      FROM  GWA_HU_PALLET.

    DATA:
    LD_SUBRC(2),
    LD_PACKED(18),
    LD_DESCR TYPE TEXT255.

    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_UNLOCK_NEW, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
    CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT ', CLEAR COMPUTER_NAME' INTO LD_DESCR.



    UPDATE  ZPACK_PCL SET COMPUTER_NAME = ''
      WHERE PINNR   = GWA_HU_PALLET-PINNR
        AND HUSEQ_P = GWA_HU_PALLET-HUSEQ.


    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_UNLOCK_NEW, (to children) CLEAR COMPUTER_NAME' INTO LD_DESCR.


  ENDIF.

ENDFORM.                    " f_unlock_new

*&---------------------------------------------------------------------*
*&      Form  f_lock_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_LOCK_NEW  CHANGING FCN_ERRNO.
  DATA S_LOOBJ TYPE ZTLOCK-LOOBJ.


  CONCATENATE
    'PCL'
    GWA_HU_PALLET-PINNR
    GWA_HU_PALLET-HUSEQ
    INTO S_LOOBJ.

  CALL FUNCTION 'ENQUEUE_EZPACK_PCL'
    EXPORTING
      MANDT          = SY-MANDT
      LOOBJ          = S_LOOBJ
      _WAIT          = 'X'
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  FCN_ERRNO = SY-SUBRC.

  IF ( FCN_ERRNO = 0 )
    OR ( FCN_ERRNO = 1 AND GWA_HU_PALLET-COMPUTER_NAME = GS_COMPUTER_NAME ).

    PERFORM F_REC_HU_USAGE CHANGING GWA_HU_PALLET.
    UPDATE  ZPACK_PCL FROM GWA_HU_PALLET.

    DATA:
    LD_SUBRC(2),
    LD_PACKED(18),
    LD_DESCR TYPE TEXT255.

    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_LOCK_NEW, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
    CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.


  ELSEIF FCN_ERRNO = 1.
    MESSAGE I000(0K)
      WITH
        'Pallet is locked by'
        GWA_HU_PALLET-PACKING_STATION
        'on computer'
        GWA_HU_PALLET-COMPUTER_NAME.

    PERFORM F_RESET_ALL.
    FCN_ERRNO = 4.

  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    FCN_ERRNO = 4.
  ENDIF.

ENDFORM.                    " f_lock_new


*&---------------------------------------------------------------------*
*&      Form  f_pick_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_USEDPALLET  text
*      <--P_N_PICKED  text
*----------------------------------------------------------------------*
FORM F_PICK_HU  TABLES   FT_USEDHU STRUCTURE ITAB_HU
                    USING FUS_TYPE
                    CHANGING FCN_PICKED FCN_ERRNO.

  DATA LT_RETVAL TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA NCOUNT TYPE I.
  DATA:
    BEGIN OF ITAB_SELECTION OCCURS 0,
      NO     TYPE NUMC2,
      HUTYPE TYPE TEXT5,
      EXIDV  TYPE EXIDV,
      VHILM  TYPE VHILM,
      ZINS01 TYPE NUMC2,
      ZINS02 TYPE NUMC2,
      WERKS  TYPE MSEG-WERKS,
      LGORT  TYPE MSEG-LGORT,
    END OF ITAB_SELECTION.

  DATA:
    BEGIN OF ITAB_EXIDV OCCURS 0,
      VENUM  TYPE VENUM,
      EXIDV  TYPE EXIDV,
      VHILM  TYPE VHILM,
    END OF ITAB_EXIDV.

  DATA  : UNVEL TYPE VEPO-UNVEL,
          NUM TYPE I.

* convert itab to human readable selection
  SELECT VENUM EXIDV VHILM
    INTO TABLE ITAB_EXIDV
    FROM VEKP
    FOR ALL ENTRIES IN FT_USEDHU
    WHERE VENUM = FT_USEDHU-VENUM.


  DATA N_INDEX TYPE I.

  N_INDEX = 0.
  LOOP AT FT_USEDHU.
    IF FT_USEDHU-VENUM = '<new>'.
      ITAB_EXIDV-VHILM = '<new>'.

    ELSE.
      READ TABLE ITAB_EXIDV WITH KEY VENUM = FT_USEDHU-VENUM.
      IF SY-SUBRC NE 0.
        CLEAR ITAB_EXIDV.
      ENDIF.
      SELECT SINGLE UNVEL WERKS LGORT INTO (UNVEL,ITAB_SELECTION-WERKS,ITAB_SELECTION-LGORT)
        FROM VEPO
        WHERE VENUM = ITAB_EXIDV-VENUM.

      IF UNVEL NE ''.
        SELECT SINGLE WERKS LGORT INTO (ITAB_SELECTION-WERKS,ITAB_SELECTION-LGORT)
          FROM VEPO
          WHERE VENUM = UNVEL.
      ENDIF.
    ENDIF.

    ADD 1 TO N_INDEX.
    ITAB_SELECTION-NO = N_INDEX.
    ITAB_SELECTION-HUTYPE = FUS_TYPE.
    ITAB_SELECTION-EXIDV  = ITAB_EXIDV-EXIDV.
    ITAB_SELECTION-VHILM  = ITAB_EXIDV-VHILM.
    ITAB_SELECTION-ZINS01 = FT_USEDHU-ZINS01.
    ITAB_SELECTION-ZINS02 = FT_USEDHU-ZINS02.

    APPEND ITAB_SELECTION.
  ENDLOOP.

  FCN_PICKED = 0.
  FCN_ERRNO = 0.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'NO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = ITAB_SELECTION
      RETURN_TAB      = LT_RETVAL
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    FCN_ERRNO = 4.

  ELSE.

    DESCRIBE TABLE LT_RETVAL LINES NCOUNT.
    NUM = LT_RETVAL-FIELDVAL.
    IF SY-TCODE = 'ZHU5SO' AND NUM > 1 .
      READ TABLE ITAB_SELECTION INDEX NUM.
      IF ITAB_SELECTION-LGORT NE HUPAST_T-STGE_LOC.
        MESSAGE  I002(ZMM) WITH 'Sloc tidak sesuai'.
        FCN_ERRNO = 4.
*        RETURN.
      ENDIF.
    ENDIF.

    IF NCOUNT > 0.
      DATA S_EXIDV TYPE N LENGTH 20.

      READ TABLE LT_RETVAL INDEX 1.
      MOVE LT_RETVAL-FIELDVAL TO N_INDEX.
*      READ TABLE itab_selection INDEX n_index.
      FCN_PICKED = N_INDEX.

    ELSE.
      FCN_ERRNO = 4.

    ENDIF.

  ENDIF.

ENDFORM.                    " f_pick_hu


*&---------------------------------------------------------------------*
*&      Form  f_reset_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_RESET_ALL .
  CLEAR:
    GWA_HU_PALLET,
    GWA_HU_BOX,
    GWA_HU,
    GWA_PC_PALLET,
    GWA_PC_BOX,
    GWA_PC,
    GS_EXIDV_PALLET,
    GS_EXIDV_BOX,
    GS_EXIDV,
    GS_CHARGDC,
    GS_LASTSO,
    GS_LASTSOITEM,
    GS_LAST_BATCH,
    GWA_LAST_CHARACTERISTICS,
    KNA1,
    HU_COM,
    ZPACK00.

  IF GB_IS_FREESTOCK = V_YES.
    SELECT SINGLE * INTO GWA_PCH FROM ZPACK_PCH
      WHERE PINNR = GWA_PCH-PINNR.
  ELSE.
    CLEAR GWA_PCH.
  ENDIF.

  REFRESH HU_COM.
ENDFORM.                    " f_reset_all


*&---------------------------------------------------------------------*
*&      Form  f_hu_delete_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FU_HUKEY  text
*----------------------------------------------------------------------*
FORM F_HU_DELETE_NEW CHANGING FCWA_HU STRUCTURE ZPACK_PCL FCS_EXIDV FCN_ERRNO.
  DATA: LB_CAN_UNPACK TYPE FLAG,
        TA_HU TYPE ZPACK_PCL OCCURS 1 WITH HEADER LINE.

  IF FCS_EXIDV = ''.
    RETURN.
  ENDIF.

  REFRESH RETRN.
  COMMIT WORK AND WAIT.
  FCN_ERRNO = 0.

  " Added by William at 23.02.2026 (unpallet RTP)
  CLEAR: V_WERK1_UNPALLET, V_LGOR1_UNPALLET.
  PERFORM F_GET_SLOC_HU USING FCS_EXIDV CHANGING V_LGOR1_UNPALLET V_WERK1_UNPALLET.
  " End added by William at 23.02.2026 (unpallet RTP)

  CALL FUNCTION 'BAPI_HU_DELETE'
    EXPORTING
      HUKEY        = FCS_EXIDV
*     withlowerhus = V_YES
      IFPACKED     = V_YES
    TABLES
      RETURN       = RETRN.

  READ TABLE RETRN WITH KEY TYPE = 'E'.

  IF SY-SUBRC EQ 0.
    MESSAGE I000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
    FCN_ERRNO = 4.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = V_YES.

    DATA N_COUNT TYPE I.
    SELECT COUNT(*) INTO N_COUNT FROM VEKP
      WHERE EXIDV = FCS_EXIDV
        AND STATUS NE '0060'.


    IF N_COUNT = 0.
      FCWA_HU-HUSTAT = C_HUSTAT_OPEN.
      FCWA_HU-PRSTAT = C_PRSTAT_NOTPRINTED.
      CLEAR: FCWA_HU-VENUM, FCWA_HU-PACKED.

      CLEAR  : TA_HU. REFRESH : TA_HU.
      MOVE-CORRESPONDING FCWA_HU TO TA_HU.
      APPEND TA_HU.

      UPDATE ZPACK_PCL FROM TABLE TA_HU.
      COMMIT WORK.

      DATA:
      LD_SUBRC(2),
      LD_PACKED(18),
      LD_DESCR TYPE TEXT255.

      MOVE SY-SUBRC TO LD_SUBRC.
      WRITE FCWA_HU-PACKED TO LD_PACKED.

      CONCATENATE '(' LD_SUBRC ') F_HU_DELETE_NEW, VENUM=' FCWA_HU-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
      CONCATENATE LD_DESCR ', HUSTAT=' FCWA_HU-HUSTAT INTO LD_DESCR.


      CLEAR FCWA_HU.
      CLEAR FCS_EXIDV.

      PERFORM UNPACK_PALID.

    ELSE.
      MESSAGE I000(0K) WITH 'HU tidak dapat di hapus.'
        'Mungkin sedang digunakan orang lain.'.
      FCN_ERRNO = 4.

    ENDIF.
  ENDIF.

ENDFORM.                    " f_hu_delete_new


*&---------------------------------------------------------------------*
*&      Form  f_select_free_pinnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECT_FREE_PINNR .
  DATA LT_RETVAL TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA NCOUNT TYPE I.

  DATA:
    BEGIN OF ITAB_SELECTION OCCURS 0,
      PINNR  TYPE ZPINNR,
      DESCR  TYPE TEXT50,
      CRNAM  TYPE CRNAM,
      CRDAT  TYPE CRDAT,
      CRTIM  TYPE ERZET,
      AENAM  TYPE AENAM,
      AEDAT  TYPE AEDAT,
      AETIM  TYPE AEZEIT,
      WERKS TYPE WERKS,
      LGORT TYPE LGORT,
    END OF ITAB_SELECTION.
  DATA ITAB_PCH TYPE TABLE OF ZPACK_PCH WITH HEADER LINE.

  SELECT * INTO TABLE ITAB_PCH
    FROM ZPACK_PCH
    WHERE VBELN = ''
      AND POSNR = '000000'
      AND PINST NE C_PINST_INACTIVE
      AND LOEVR = SPACE
      AND ( WERKS = HUPAST_T-PLANT OR WERKS = SPACE OR WERKS IS NULL )
      AND ( LGORT = HUPAST_T-STGE_LOC OR LGORT = SPACE OR LGORT IS NULL ).

  LOOP AT ITAB_PCH.
    MOVE-CORRESPONDING ITAB_PCH TO ITAB_SELECTION.
    APPEND ITAB_SELECTION.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'PINNR'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = ITAB_SELECTION
      RETURN_TAB      = LT_RETVAL
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
    DESCRIBE TABLE LT_RETVAL LINES NCOUNT.

    IF NCOUNT > 0.
      DATA S_PINNR TYPE N LENGTH 12.

      READ TABLE LT_RETVAL INDEX 1.
      MOVE LT_RETVAL-FIELDVAL TO S_PINNR.

      READ TABLE ITAB_PCH WITH KEY PINNR = S_PINNR.
      GWA_PCH = ITAB_PCH.

    ENDIF.

  ENDIF.
ENDFORM.                    " f_select_free_pinnr


*&---------------------------------------------------------------------*
*&      Form  f_check_pinnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_PINNR .

  SELECT SINGLE * INTO GWA_PCH
    FROM ZPACK_PCH
    WHERE VBELN = ''
      AND POSNR = '000000'
      AND PINNR = GWA_PCH-PINNR
      AND PINST IN (C_PINST_ACTIVE, C_PINST_INPROGRESS, C_PINST_COMPLETED)
      AND LOEVR = SPACE
      AND ( WERKS = HUPAST_T-PLANT OR WERKS = SPACE OR WERKS IS NULL )
      AND ( LGORT = HUPAST_T-STGE_LOC OR LGORT = SPACE OR LGORT IS NULL ).

  IF SY-SUBRC NE 0.
    MESSAGE W000(0K)
      WITH 'Packing Instruction' GWA_PCH-PINNR 'tidak ditemukan'.
    CLEAR : GWA_PCH-PINNR.
  ELSE.

    SELECT SUM( ZMENG ) INTO ZPACK00-PLCNT FROM ZPACK_PC
      WHERE PINNR = GWA_PCH-PINNR AND INILVL = C_LEVEL_PALLET.

    PERFORM F_READ_GRADE_CRITERIA.
  ENDIF.

ENDFORM.                    " f_check_pinnr


*&---------------------------------------------------------------------*
*&      Form  f_process_both
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PROCESS_COMMON .
  DATA N_ERRNO TYPE I.

  GB_DISPLAY_ONLY = V_NO.

  IF GB_DO_PACKING = V_NO.      "-- already packed
    PERFORM     F_LOAD_HU
      USING     GS_EXIDV
      CHANGING  N_ERRNO.

    IF N_ERRNO NE 0.
      MESSAGE I000(0K) WITH 'Cant load HU.'.
      RETURN.

    ELSE.
      PERFORM F_LOCK_NEW CHANGING N_ERRNO.
      IF N_ERRNO NE 0.
        GB_DISPLAY_ONLY = V_YES.
        CLEAR N_ERRNO.
      ENDIF.
    ENDIF.

  ELSE.                                      "-- select an available hu
*   select new pallet if necessary (check is inside)
*     n_errno = 0 if new pallet selected
*     n_errno = 1 if still using current pallet
*     n_errno = 4 if no pallet available or can not create hu

    PERFORM F_SELECT_PALLET  CHANGING N_ERRNO.

    IF N_ERRNO = 4.
      RETURN. "-- no pallet available
    ELSE.
      IF N_ERRNO EQ 0.                         "-- lock new pallet
        PERFORM F_LOCK_NEW CHANGING N_ERRNO.
      ENDIF.

*If a pallet is selected (either using the previous pallet or a new one)
      IF N_ERRNO NE 4.
*      select new box if necessary (check inside) output is equal to new
*      pallet
        GWA_HU = GWA_HU_PALLET.
        GS_EXIDV = GS_EXIDV_PALLET.

        PERFORM F_SELECT_BOX CHANGING N_ERRNO.
      ENDIF.

      IF N_ERRNO EQ 4.
        PERFORM F_UNLOCK_NEW.
        PERFORM F_DELETE_NEW_PALLET CHANGING N_ERRNO.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.


* read materials if no errors and no new box from above
  IF N_ERRNO EQ 0.
    REFRESH HU_COM.
    IF GWA_HU-PINNR IS NOT INITIAL.
      PERFORM F_READ_MATERIALS CHANGING N_ERRNO.
      IF N_ERRNO NE 0.
        MESSAGE I000(0K) WITH 'Jumlah 0 pada packing instruction' ITAB_PC-PINNR.
        PERFORM F_DELETE_NEW_BOX CHANGING N_ERRNO.
        PERFORM F_DELETE_NEW_PALLET CHANGING N_ERRNO.
        RETURN.
      ENDIF.

      PERFORM F_SET_MATERIAL_EXID.
    ENDIF.

  ENDIF.

  IF GB_DO_PACKING = V_YES.
    DATA N_REC_COUNT TYPE I.

*   get record count and compare with current line
    PERFORM F_AUTOPACK.
    PERFORM F_LOCK_NEW CHANGING N_ERRNO.
  ENDIF.

ENDFORM.                    " f_process_both


*&---------------------------------------------------------------------*
*&      Form  f_get_material_from_pins
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPACK00_MATNR  text
*----------------------------------------------------------------------*
FORM F_GET_MATERIAL_FROM_PINS CHANGING FCS_MATNR FCN_ERRNO.

  SELECT SINGLE MATNR INTO FCS_MATNR
    FROM MCHB
    WHERE CHARG = ZPACK00-CHARGDC
      AND WERKS = HUPAST_T-PLANT
      AND LGORT = HUPAST_T-STGE_LOC.
  ZPACK00-MATNR0 = FCS_MATNR.
  FCN_ERRNO = SY-SUBRC.
ENDFORM.                    " f_get_material_from_pins


*&---------------------------------------------------------------------*
*&      Form  f_hu_print_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_PRINT_NEW .
  DATA : PROC,
         WA LIKE HU_COM.

  PROC = '1'.

  SET PARAMETER ID 'NAC' FIELD ''.
  SET PARAMETER ID 'VL'  FIELD ''.
  SET PARAMETER ID 'TNR' FIELD ''.
  SET PARAMETER ID 'ANR' FIELD ''.
  SET PARAMETER ID 'AUN' FIELD ''.
  SET PARAMETER ID 'BES' FIELD ''.

  IF GB_LABEL_BOX = V_YES.
    REFRESH BDCDATA.
    PERFORM BDC_DYNPRO      USING 'SD70AV6A'      '1000'.
    PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z001'.
    PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '8'.
    PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
    PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
    PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  GS_EXIDV_BOX.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.

    GS_MODE = 'E'.
    CALL TRANSACTION 'VL74' USING BDCDATA MODE GS_MODE UPDATE 'S'.


*   update print status
    GWA_HU_BOX-PRSTAT = C_PRSTAT_LABEL.
    GWA_HU-PRSTAT = C_PRSTAT_LABEL.
    UPDATE ZPACK_PCL FROM GWA_HU_BOX.

    DATA:
    LD_SUBRC(2),
    LD_PACKED(18),
    LD_DESCR TYPE TEXT255.

    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU_BOX-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_HU_PRINT_NEW, VENUM=' GWA_HU_BOX-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
    CONCATENATE LD_DESCR ', PRSTAT=' GWA_HU_BOX-PRSTAT INTO LD_DESCR.

    CALL FUNCTION 'ZFM_LOG_PK'
      EXPORTING
        PINNR = GWA_HU_BOX-PINNR
        HUSEQ = GWA_HU_BOX-HUSEQ
        REPID = SY-REPID
        AREA  = 'PACKING'
        DESCR = LD_DESCR.

  ENDIF.

  IF GB_LABEL_PALLET = V_YES.
    IF GB_LABEL_BOX = V_YES.
      MESSAGE S000(0K) WITH 'Waiting.....'.
      DO 5 TIMES.
        CALL FUNCTION 'RZL_SLEEP'
          EXPORTING
            SECONDS = 5.
      ENDDO.
    ENDIF.

    MESSAGE S000(0K) WITH ''.
    REFRESH BDCDATA.
    PERFORM BDC_DYNPRO      USING 'SD70AV6A'      '1000'.
    PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z002'.
    PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '8'.
    PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
    PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
    PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  GS_EXIDV_PALLET.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.

    GS_MODE = 'E'.
    CALL TRANSACTION 'VL74' USING BDCDATA MODE GS_MODE UPDATE 'S'.

  ENDIF.

  IF GB_REPORT_PALLET = V_YES.
    IF GB_LABEL_PALLET = V_YES OR GB_LABEL_BOX = V_YES.
      MESSAGE S000(0K) WITH 'Waiting.....'.
      DO 5 TIMES.
        CALL FUNCTION 'RZL_SLEEP'
          EXPORTING
            SECONDS = 5.
      ENDDO.
    ENDIF.

    REFRESH BDCDATA.
    PERFORM BDC_DYNPRO      USING 'SD70AV6A'      '1000'.
    PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z003'.
    PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '1'.
    PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
    PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
    PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  GS_EXIDV_PALLET.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.
    CALL TRANSACTION 'VL74' USING BDCDATA MODE 'E' UPDATE 'S'.

  ENDIF.

  IF ( GB_LABEL_PALLET = V_YES ) AND ( GB_REPORT_PALLET = V_YES ).
    GWA_HU_PALLET-PRSTAT = C_PRSTAT_LABELANDREPORT.
    UPDATE ZPACK_PCL FROM GWA_HU_BOX.

  ELSEIF ( GB_LABEL_PALLET = V_YES ).
    GWA_HU_PALLET-PRSTAT = C_PRSTAT_LABEL.
    UPDATE ZPACK_PCL FROM GWA_HU_BOX.

  ELSEIF ( GB_REPORT_PALLET = V_YES ).
    GWA_HU_PALLET-PRSTAT = C_PRSTAT_LABEL.
    UPDATE ZPACK_PCL FROM GWA_HU_BOX.

  ENDIF.

  MOVE SY-SUBRC TO LD_SUBRC.
  WRITE GWA_HU_BOX-PACKED TO LD_PACKED.

  CONCATENATE '(' LD_SUBRC ') F_HU_PRINT_NEW, VENUM=' GWA_HU_BOX-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
  CONCATENATE LD_DESCR ', PRSTAT=' GWA_HU_BOX-PRSTAT INTO LD_DESCR.


  IF GWA_HU_BOX IS NOT INITIAL.
    GWA_HU = GWA_HU_PALLET.
  ENDIF.

ENDFORM.                    " f_hu_print_new


**&---------------------------------------------------------------------*
**&      Form  f_hu_print_mass
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM F_HU_PRINT_MASS.
  DATA N_ERRNO TYPE I.
  DATA ITAB_HULIST TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.

  LOOP AT ITAB_PRINTLIST.
    CHECK ITAB_PRINTLIST-SELEC = V_YES.

    PERFORM F_HU_PRINT_WA_NEW
      CHANGING
        ITAB_PRINTLIST-WA_HU
        ITAB_PRINTLIST-EXIDV
        N_ERRNO.

    IF N_ERRNO EQ 0.
      PERFORM F_REC_HU_USAGE CHANGING ITAB_PRINTLIST-WA_HU.

      IF    ITAB_PRINTLIST-WA_HU-PINNR EQ GWA_HU_PALLET-PINNR
        AND ITAB_PRINTLIST-WA_HU-HUSEQ EQ GWA_HU_PALLET-HUSEQ.
        GWA_HU_PALLET-PRSTAT = ITAB_PRINTLIST-WA_HU-PRSTAT.
        IF GWA_HU_BOX IS INITIAL.
          GWA_HU = GWA_HU_PALLET.
        ENDIF.

      ELSEIF ITAB_PRINTLIST-WA_HU-PINNR EQ GWA_HU_BOX-PINNR
        AND  ITAB_PRINTLIST-WA_HU-HUSEQ EQ GWA_HU_BOX-HUSEQ.
        GWA_HU_BOX-PRSTAT = ITAB_PRINTLIST-WA_HU-PRSTAT.
        GWA_HU = GWA_HU_BOX.
      ELSE.
        CLEAR ITAB_PRINTLIST-WA_HU-COMPUTER_NAME.
      ENDIF.

      MODIFY ITAB_PRINTLIST INDEX SY-TABIX.
      APPEND ITAB_PRINTLIST-WA_HU TO ITAB_HULIST.
    ENDIF.
  ENDLOOP.

  UPDATE ZPACK_PCL FROM TABLE ITAB_HULIST.

  DATA:
  LD_SUBRC(2),
  LD_DESCR TYPE TEXT255,
  LT_LOG TYPE TABLE OF ZPACK_PCL_LOG WITH HEADER LINE.

  MOVE SY-SUBRC TO LD_SUBRC.
  REFRESH LT_LOG.

  LOOP AT ITAB_HULIST.
    MOVE-CORRESPONDING ITAB_HULIST TO LT_LOG.
    CONCATENATE '(' LD_SUBRC ') F_HU_PRINT_MASS, VENUM=' ITAB_HULIST-VENUM ', HUSTAT=' ITAB_HULIST-HUSTAT INTO LT_LOG-DESCR.
    CONCATENATE LT_LOG-DESCR ', PRSTAT=' ITAB_HULIST-PRSTAT INTO LT_LOG-DESCR.
    APPEND LT_LOG.
  ENDLOOP.


  COMMIT WORK AND WAIT.
ENDFORM.                    "f_hu_print_mass

*&---------------------------------------------------------------------*
*&      Form  f_hu_print_wa_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FUWA_HU    text
*      -->FUS_EXIDV  text
*----------------------------------------------------------------------*
FORM F_HU_PRINT_WA_NEW
  CHANGING
    FCWA_HU STRUCTURE ZPACK_PCL
    FCS_EXIDV
    FCN_ERRNO.

  DATA : PROC,
         WA LIKE HU_COM,
         B_IS_PALLET TYPE FLAG.

  PROC = '1'.

  TRY.
      SET PARAMETER ID 'NAC' FIELD ''.
      SET PARAMETER ID 'VL'  FIELD ''.
      SET PARAMETER ID 'TNR' FIELD ''.
      SET PARAMETER ID 'ANR' FIELD ''.
      SET PARAMETER ID 'AUN' FIELD ''.
      SET PARAMETER ID 'BES' FIELD ''.

      IF FCWA_HU-HUSEQ+4(2) = '00'.
        B_IS_PALLET = V_YES.
      ELSE.
        B_IS_PALLET = V_NO.
      ENDIF.

      IF B_IS_PALLET = V_NO. "--it is a box
        REFRESH BDCDATA.
        PERFORM BDC_DYNPRO      USING 'SD70AV6A'      '1000'.
        PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z001'.
        PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '8'.
        PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
        PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
        PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  FCS_EXIDV.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.
        CALL TRANSACTION 'VL74' USING BDCDATA MODE 'E' UPDATE 'S'.

        FCWA_HU-PRSTAT = C_PRSTAT_LABEL.

        MESSAGE S000(0K) WITH 'Waiting.....'.
        DO 5 TIMES.
          CALL FUNCTION 'RZL_SLEEP'
            EXPORTING
              SECONDS = 5.
        ENDDO.

      ELSE. "-- it is a pallet
        MESSAGE S000(0K) WITH ''.
        REFRESH BDCDATA.
        PERFORM BDC_DYNPRO      USING 'SD70AV6A'      '1000'.
        PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z002'.
        PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '8'.
        PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
        PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
        PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  FCS_EXIDV.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.
        CALL TRANSACTION 'VL74' USING BDCDATA MODE 'E' UPDATE 'S'.

        MESSAGE S000(0K) WITH 'Waiting.....'.
        DO 5 TIMES.
          CALL FUNCTION 'RZL_SLEEP'
            EXPORTING
              SECONDS = 5.
        ENDDO.

        REFRESH BDCDATA.
        PERFORM BDC_DYNPRO      USING 'SD70AV6A'      '1000'.
        PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z003'.
        PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '1'.
        PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
        PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
        PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  FCS_EXIDV.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
        PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.
        CALL TRANSACTION 'VL74' USING BDCDATA MODE 'E' UPDATE 'S'.

        FCWA_HU-PRSTAT = C_PRSTAT_LABELANDREPORT.

        MESSAGE S000(0K) WITH 'Waiting.....'.
        DO 5 TIMES.
          CALL FUNCTION 'RZL_SLEEP'
            EXPORTING
              SECONDS = 5.
        ENDDO.

      ENDIF.

      FCN_ERRNO = 0.

    CATCH CX_ROOT INTO EX.
      FCN_ERRNO = 4.

  ENDTRY.

ENDFORM.                    " f_hu_print_new


*&---------------------------------------------------------------------*
*&      Form  f_check_batch_model
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_BATCH_MODEL .
  DATA  LS_PREFIX(18).
  DATA : L_V_LENGTH TYPE I.
  DATA : B_CHANGE TYPE FLAG,
         N_ERRNO.

* Check Batch Number
*  LS_PREFIX = ZPACK00-CHARGDC.
  L_V_LENGTH = STRLEN( ZPACK00-CHARGDC ).
  CASE L_V_LENGTH.
    WHEN 12.
      CALL FUNCTION 'CONVERSION_EXIT_BAS36_INPUT'
        EXPORTING
          INPUT  = ZPACK00-CHARGDC
        IMPORTING
          OUTPUT = LS_PREFIX.
      ZPACK00-CHARGDC = LS_PREFIX+0(10).
    WHEN 10.

*      CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
*        EXPORTING
*          INPUT   = LS_PREFIX
*        IMPORTING
*          OUTPUT  = ZPACK00-CHARGDC.

  ENDCASE.


*  IF LS_PREFIX = '000000'.
*    IF GB_IS_NEW_BATCH = V_YES.
*      PERFORM F_CONFIRM_SWITCH_BATCH CHANGING B_CHANGE.
*      IF B_CHANGE = V_NO.
*        MESSAGE E000(0K) WITH 'Masukkan nomor batch'.
*        RETURN.
*      ENDIF.
*    ENDIF.
*
*    GB_IS_NEW_BATCH = V_NO.

*  ELSEIF ZPACK00-CHARGDC <> '000000000000000000'.
  IF ZPACK00-CHARGDC <> '0000000000'.
    IF GB_IS_NEW_BATCH = V_NO.
      PERFORM F_CONFIRM_SWITCH_BATCH CHANGING B_CHANGE.
      IF B_CHANGE = V_NO.
        MESSAGE E000(0K) WITH 'Masukkan nomor batch'.
        RETURN.
      ENDIF.
    ENDIF.

    GB_IS_NEW_BATCH = V_YES.

    ZPACK00-CHARGDC = ZPACK00-CHARGDC+0(10).   "update by ALF at 23-10-2020
    GS_CHARGDC = ZPACK00-CHARGDC.

  ELSE.
    GB_IS_NEW_BATCH = 'N'.
  ENDIF.

ENDFORM.                    " f_check_batch_model


*&---------------------------------------------------------------------*
*&      Form  f_incomplete_pallet_count
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_PALLET_COUNT  text
*----------------------------------------------------------------------*
FORM F_INCOMPLETE_PALLET_COUNT  CHANGING FCN_PALLET_COUNT.
  SELECT COUNT( * ) INTO FCN_PALLET_COUNT FROM ZPACK_PCL
    WHERE PINNR = GWA_HU_PALLET-PINNR
      AND HUSEQ_P = '000000'
      AND HUSTAT IN (C_HUSTAT_OPEN, C_HUSTAT_INPROGRESS).

ENDFORM.                    " f_incomplete_pallet_count


*&---------------------------------------------------------------------*
*&      Form  f_rec_hu_usage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GWA_HU_BOX  text
*----------------------------------------------------------------------*
FORM F_REC_HU_USAGE   CHANGING FCWA_HU STRUCTURE ZPACK_PCL.
  FCWA_HU-PACKING_STATION = HUM_PROFILE_S-PACKING_STATION.
  FCWA_HU-COMPUTER_NAME   = GS_COMPUTER_NAME.
*  fcwa_hu-pinnr           = gwa_pch-pinnr.
  FCWA_HU-AENAM           = SY-UNAME.
  FCWA_HU-AEDAT           = SY-DATUM.
  FCWA_HU-AETIM           = SY-UZEIT.

ENDFORM.                    " f_rec_hu_usage


*&---------------------------------------------------------------------*
*&      Form  f_set_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SET_DISPLAY .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'NEW'.
      IF GB_IS_NEW_BATCH = V_YES.
        IF SCREEN-GROUP2 = 'BOX' AND GWA_HU_BOX IS INITIAL.
          SCREEN-INPUT     = 0.
          SCREEN-INVISIBLE = 1.
        ELSE.
          IF SCREEN-GROUP4 = 'ON'.
            IF SCREEN-NAME = 'COMPLETE'.
              IF GWA_HU-HUSTAT = C_HUSTAT_INPROGRESS. " and not gwa_hu_pallet is initial.
                SCREEN-INPUT   = 1.
              ELSE.
                SCREEN-INPUT   = 0.
              ENDIF.
            ELSE.
              SCREEN-INPUT = 1.
            ENDIF.
          ELSE.
            SCREEN-INPUT   = 0.
          ENDIF.
          SCREEN-INVISIBLE = 0.
        ENDIF.

      ELSE.
        SCREEN-INPUT     = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.

    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " f_set_display


*&---------------------------------------------------------------------*
*&      Form  f_init_screen_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_INIT_SCREEN_200 .
  DATA ITAB_EXCLUDE TYPE TABLE OF SY-UCOMM.
  DATA S_PLPCK(3).
  DATA S_BXPCK(3).
  DATA S_PLREQ(3).
  DATA S_BXREQ(3).
  DATA N_COUNT TYPE I.

  REFRESH ITAB_EXCLUDE.

*  tctr01-lines = gwa_pc-zmeng.

  IF GB_DISPLAY_ONLY = V_YES.
    GB_IS_NEW_BATCH = 'N'.
  ENDIF.

  CASE GB_IS_NEW_BATCH.
    WHEN V_NO.
      APPEND 'COMPLETE' TO ITAB_EXCLUDE.

      CLEAR:
         ZPACK00-PLPCK,
         ZPACK00-BXPCK,
         ZPACK00-PLSEQ,
         ZPACK00-BXSEQ,
         ZPACK00-BXSTAT,
         ZPACK00-PLSTAT,
         ZPACK00-PINST,
         ZPACK00-PINNR,
         ZPACK00-DESCR,
         ZPACK00-BXEXID,
         ZPACK00-PLEXID,
         ZPACK00-BXPRST,
         ZPACK00-PLPRST.

    WHEN V_YES.
      DESCRIBE TABLE HU_COM LINES N_COUNT.

      WRITE GWA_HU_PALLET-PACKED TO S_PLPCK DECIMALS 0.
      WRITE GWA_HU_BOX-PACKED    TO S_BXPCK DECIMALS 0.

      IF GWA_HU_BOX IS INITIAL.
        S_BXREQ = '0'.
        WRITE N_COUNT              TO S_PLREQ.
      ELSE.
        WRITE GWA_PC_BOX-ZMENG     TO S_PLREQ DECIMALS 0.
        WRITE N_COUNT              TO S_BXREQ.
      ENDIF.

      CONCATENATE S_PLPCK '/' S_PLREQ INTO ZPACK00-PLPCK.
      CONCATENATE S_BXPCK '/' S_BXREQ INTO ZPACK00-BXPCK.

      ZPACK00-PINNR = GWA_PCH-PINNR.
      ZPACK00-PLSEQ = GWA_HU_PALLET-HUSEQ(4).
      ZPACK00-BXSEQ = GWA_HU_BOX-HUSEQ+4(2).

      ZPACK00-PLSTAT = GWA_HU_PALLET-HUSTAT.
      ZPACK00-BXSTAT = GWA_HU_BOX-HUSTAT.
      ZPACK00-PINST  = GWA_PCH-PINST.
      ZPACK00-DESCR  = GWA_PCH-DESCR.
      WRITE GS_EXIDV_BOX TO ZPACK00-BXEXID RIGHT-JUSTIFIED.
      ZPACK00-PLEXID = GS_EXIDV_PALLET.
      ZPACK00-BXPRST = GWA_HU_BOX-PRSTAT.
      ZPACK00-PLPRST = GWA_HU_PALLET-PRSTAT.

      IF ZPACK00-BXPRST IS INITIAL.
        ZPACK00-BXPRST = C_PRSTAT_NOTPRINTED.
      ENDIF.

      IF ZPACK00-PLPRST IS INITIAL.
        ZPACK00-PLPRST = C_PRSTAT_NOTPRINTED.
      ENDIF.

      APPEND:
        'CREATE'   TO ITAB_EXCLUDE,
        'PACK'     TO ITAB_EXCLUDE,
        'DISPLAY'  TO ITAB_EXCLUDE,
        'DELHU'    TO ITAB_EXCLUDE,
        'HULIST'   TO ITAB_EXCLUDE,
        'REFRESH'  TO ITAB_EXCLUDE.

      IF GWA_HU_PALLET IS INITIAL OR GWA_HU_PALLET-HUSTAT EQ C_HUSTAT_CLOSED.
        IF GWA_HU_PALLET IS INITIAL.
          APPEND 'PRINT' TO ITAB_EXCLUDE.
        ENDIF.

      ENDIF.

      CASE GWA_HU_PALLET-HUSTAT.
        WHEN C_HUSTAT_COMPLETED OR C_HUSTAT_FORCED OR V_YES.
          APPEND 'COMPLETE' TO ITAB_EXCLUDE.

        WHEN OTHERS.
          APPEND 'CLOSE' TO ITAB_EXCLUDE.

      ENDCASE.

      DATA N_ITEM_COUNT TYPE I.
      DESCRIBE TABLE HU_COM LINES N_ITEM_COUNT.

      IF ZPACK00-PLEXID = ''.
        APPEND 'UNPACK' TO ITAB_EXCLUDE.
        APPEND 'UNPALLET' TO ITAB_EXCLUDE.
      ENDIF.

    WHEN OTHERS.
      APPEND:
        'CREATE'   TO ITAB_EXCLUDE,
        'PACK'     TO ITAB_EXCLUDE,
        'CLOSE'    TO ITAB_EXCLUDE,
        'UNPACK'   TO ITAB_EXCLUDE,
        'UNPALLET' TO ITAB_EXCLUDE,
        'DISPLAY'  TO ITAB_EXCLUDE,
        'PRINT'    TO ITAB_EXCLUDE,
        'DELHU'    TO ITAB_EXCLUDE,
        'HULIST'   TO ITAB_EXCLUDE,
        'REFRESH'  TO ITAB_EXCLUDE,
        'COMPLETE' TO ITAB_EXCLUDE.


  ENDCASE.

  SET TITLEBAR '200'.
  SET PF-STATUS '200' EXCLUDING ITAB_EXCLUDE.

  IF ZPACK00-CHARGDC IS INITIAL.
    SET CURSOR FIELD ZPACK00-CHARGDC.
  ENDIF.

  PERFORM F_SET_DISPLAY.

ENDFORM.                    " f_init_screen_200



*&---------------------------------------------------------------------*
*&      Form  f_force_to_complete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FORCE_TO_COMPLETE .
  DATA N_COUNT TYPE I.
  DATA N_ERRNO TYPE I.
  DATA SLOC_UPDATE TYPE LGORT_D.
  DATA UNVEL TYPE VEPO-UNVEL.


  READ TABLE HU_COM INDEX 1.
  SELECT SINGLE LGORT UNVEL INTO (SLOC_UPDATE,UNVEL)
    FROM VEPO
    WHERE CHARG = HU_COM-EXID.
  IF UNVEL NE ''.
    SELECT SINGLE LGORT INTO SLOC_UPDATE
      FROM VEPO
      WHERE CHARG = UNVEL.
  ELSE.
    SELECT SINGLE LGORT INTO SLOC_UPDATE
      FROM VEPO
      WHERE CHARG = HU_COM-EXID.
    ZPACK00-CHARG = ZPACK00-CHARGDC = HU_COM-EXID.
  ENDIF.



  GWA_HU-SLOC_UP = SLOC_UPDATE.
  GWA_HU-HUSTAT  = C_HUSTAT_FORCED.
  UPDATE ZPACK_PCL FROM GWA_HU.


  DATA:
  LD_SUBRC(2),
  LD_PACKED(18),
  LD_DESCR TYPE TEXT255.

  MOVE SY-SUBRC TO LD_SUBRC.
  WRITE GWA_HU-PACKED TO LD_PACKED.

  CONCATENATE '(' LD_SUBRC ') F_FORCE_TO_COMPLETE, VENUM=' GWA_HU-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
  CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU-HUSTAT INTO LD_DESCR.


  IF GWA_HU_BOX IS INITIAL.
    GWA_HU_PALLET = GWA_HU.

  ELSE.
    GWA_HU_BOX = GWA_HU.
    GWA_HU_PALLET-HUSTAT = SLOC_UPDATE.
    GWA_HU_PALLET-HUSTAT = C_HUSTAT_FORCED.
    UPDATE ZPACK_PCL FROM GWA_HU_PALLET.


    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_FORCE_TO_COMPLETE, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
    CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.

    CALL FUNCTION 'ZFM_LOG_PK'
      EXPORTING
        PINNR = GWA_HU_PALLET-PINNR
        HUSEQ = GWA_HU_PALLET-HUSEQ
        REPID = SY-REPID
        AREA  = 'PACKING'
        DESCR = LD_DESCR.


  ENDIF.

  PERFORM F_HU_CLOSE_NEW CHANGING N_ERRNO.

  PERFORM F_INCOMPLETE_PALLET_COUNT CHANGING N_COUNT.
  IF N_COUNT = 0.
    GWA_PCH-PINST = C_PINST_COMPLETED.
    UPDATE ZPACK_PCH FROM GWA_PCH.
  ENDIF.

  COMMIT WORK AND WAIT.
ENDFORM.                    " f_force_to_complete


*&---------------------------------------------------------------------*
*&      Form  f_hu_complete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_COMPLETE_HU CHANGING FCN_ERRNO.
  DATA N_BOX_COUNT TYPE I.
  DATA N_REC_COUNT TYPE I.

  DESCRIBE TABLE HU_COM LINES N_REC_COUNT.
  IF N_REC_COUNT = GWA_HU-PACKED.
    SELECT SINGLE SLOC_UP INTO GWA_HU-SLOC_UP
      FROM ZPACK_PCL
      WHERE VENUM = GWA_HU_PALLET-VENUM.

    GWA_HU-HUSTAT = C_HUSTAT_COMPLETED.
    GWA_HU-FM     = V_YES.
  ELSE.
    SELECT SINGLE SLOC_UP INTO GWA_HU-SLOC_UP
      FROM ZPACK_PCL
      WHERE VENUM = GWA_HU_PALLET-VENUM %_HINTS ORACLE 'INDEX("ZPACK_PCL" "ZPACK_PCL~Z01")'.
    GWA_HU-HUSTAT = C_HUSTAT_INPROGRESS.
  ENDIF.

  UPDATE ZPACK_PCL FROM GWA_HU.

  DATA:
  LD_SUBRC(2),
  LD_PACKED(18),
  LD_DESCR TYPE TEXT255.

  MOVE SY-SUBRC TO LD_SUBRC.
  WRITE GWA_HU-PACKED TO LD_PACKED.

  CONCATENATE '(' LD_SUBRC ') F_COMPLETE_HU, VENUM=' GWA_HU-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
  CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU-HUSTAT INTO LD_DESCR.


* update current work areas
  IF ( GWA_HU_BOX IS INITIAL ).
    GWA_HU_PALLET = GWA_HU.

  ELSE.
    GWA_HU_BOX = GWA_HU.


*   if the box is completed, check if this also complete the pallet/
    IF GWA_HU_BOX-HUSTAT = C_HUSTAT_COMPLETED.
      PERFORM F_INCOMPLETE_BOX_COUNT CHANGING N_BOX_COUNT.

      IF N_BOX_COUNT = 0.
        GWA_HU_PALLET-HUSTAT = C_HUSTAT_COMPLETED.
        GWA_HU_PALLET-FM     = V_YES.
        GWA_HU_PALLET-SLOC_UP = SLOC_UPDATE.
      ELSE.
        GWA_HU_PALLET-SLOC_UP = SLOC_UPDATE.
        GWA_HU_PALLET-HUSTAT = C_HUSTAT_INPROGRESS.
      ENDIF.
    ELSE.
      GWA_HU_PALLET-HUSTAT = C_HUSTAT_INPROGRESS.
    ENDIF.

    UPDATE ZPACK_PCL FROM GWA_HU_PALLET.

    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_COMPLETE_HU, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
    CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.


  ENDIF.

  IF GWA_HU_PALLET-HUSTAT = C_HUSTAT_COMPLETED.
    IF FCN_ERRNO EQ 0.
      PERFORM F_COMPLETE_PALLET.
    ENDIF.
    PERFORM F_HU_CLOSE_NEW CHANGING FCN_ERRNO.

  ELSE.
    IF GWA_PCH-PINST = C_PINST_ACTIVE.
      GWA_PCH-PINST = C_PINST_INPROGRESS.
      UPDATE ZPACK_PCH FROM GWA_PCH.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_hu_complete


*&---------------------------------------------------------------------*
*&      Form  f_complete_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_COMPLETE_PALLET .
  DATA N_PALLET_COUNT TYPE I.

  PERFORM F_INCOMPLETE_PALLET_COUNT CHANGING N_PALLET_COUNT.

  IF N_PALLET_COUNT = 0.
    GWA_PCH-PINST    = C_PINST_COMPLETED.
    MESSAGE I000(0K) WITH 'Packing Instruction telah terpenuhi.'.

*- update or automatic QA PASS
    PERFORM F_UPDATE_PASS.

  ELSE.
    MESSAGE I000(0K) WITH 'Pallet' GS_EXIDV_PALLET
      'selesai. Siap memroses pallet berikutnya'.

  ENDIF.
ENDFORM.                    " f_complete_pallet


*&---------------------------------------------------------------------*
*&      Form  f_unpack_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK_SELECTION CHANGING FCN_UNPACKED_COUNT.
  LOOP AT ITAB_UNPACK_TASK WHERE CHARG NE ''.
*    ADD 1 TO fcn_unpacked_count.
    ADD ITAB_UNPACK_TASK-VEMNG TO FCN_UNPACKED_COUNT.
  ENDLOOP.

ENDFORM.                    " f_unpack_selection


*&---------------------------------------------------------------------*
*&      Form  f_add_unpack_task
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADD_UNPACK_MATERIAL_TASK USING FUS_CHARG.
  CLEAR ITAB_UNPACK_TASK.
  ITAB_UNPACK_TASK-VENUM = GWA_HU-VENUM.
  ITAB_UNPACK_TASK-EXIDV = GS_EXIDV.
  ITAB_UNPACK_TASK-CHARG = FUS_CHARG.
  ITAB_UNPACK_TASK-SONUM = GS_SONUM.
  ITAB_UNPACK_TASK-VELIN = '1'.
  ITAB_UNPACK_TASK-VEMNG = 1.
  COLLECT ITAB_UNPACK_TASK.
ENDFORM.                    " f_add_unpack_task


*&---------------------------------------------------------------------*
*&      Form  f_unpack_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK_HU.
  IF GWA_HU_BOX IS NOT INITIAL.
*   If the materials is in a box then add it to unpack list.
    PERFORM  F_ADD_UNPACK_HU_TASK.
  ENDIF.

ENDFORM.                    " f_unpack_hu


*&---------------------------------------------------------------------*
*&      Form  f_add_unpack_hu_task
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADD_UNPACK_HU_TASK .
  CLEAR ITAB_UNPACK_TASK.
  ITAB_UNPACK_TASK-VENUM = GWA_HU_PALLET-VENUM.
  ITAB_UNPACK_TASK-EXIDV = GS_EXIDV_PALLET.
  ITAB_UNPACK_TASK-UNPACK_EXID = GS_EXIDV_BOX.
  ITAB_UNPACK_TASK-SONUM = GS_SONUM.
  ITAB_UNPACK_TASK-VELIN = '3'.
  ITAB_UNPACK_TASK-VEMNG = 1.
  COLLECT ITAB_UNPACK_TASK.

ENDFORM.                    " f_add_unpack_hu_task


*&---------------------------------------------------------------------*
*&      Form  f_next_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_NEXT_PROCESSING .
*- update for RTS
  IF SY-TCODE = 'ZHU5FSR' OR SY-TCODE = 'ZHU5SOR'.
    IF OK_CODE = 'UNPACK' OR OK_CODE = 'UNPALLET'.
      PERFORM CEK_RESTRICTED_STOCK.
    ENDIF.
  ENDIF.
*- end of update for RTS

  CASE OK_CODE.
    WHEN 'PACK'.
      PERFORM HU_PACKING.
      LOOP AT HU_COM WHERE SELE = 'X'.
        HU_COM-SELE = ' '.
        MODIFY HU_COM INDEX SY-TABIX.
      ENDLOOP.
      CLEAR VSELEK.
      READ TABLE HU_COM WITH KEY EXID = HUKEY.

    WHEN 'UNPACK'.
      IF BUT_UNPACK = 'X'.
        MESSAGE I002(ZMM) WITH 'Error Karakteristik'
                       'Scan Ulang Batch Terakhir'.

      ELSE.
        PERFORM F_HU_UNPACK.
      ENDIF.
    WHEN 'UNPALLET'.
      IF BUT_UNPACK = 'X'.
        MESSAGE I002(ZMM) WITH 'Error Karakteristik'
                       'Scan Ulang Batch Terakhir'.
      ELSE.
        PERFORM F_UNPACK_PALLET.
      ENDIF.
  ENDCASE.

  CLEAR OK_CODE.
ENDFORM.                    " f_next_processing


*&---------------------------------------------------------------------*
*&      Form  f_hu_unpack
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK .
  DATA B_CAN_UNPACK TYPE FLAG.
  DATA EX TYPE REF TO CX_ROOT.
  DATA N_UNPACKED_COUNT TYPE I.
  DATA B_CONFIRM TYPE FLAG.
  DATA N_COUNT TYPE I.
  DATA B_UNPACK_HU TYPE FLAG.
  DATA N_ERRNO TYPE I.
  DATA INT_HU TYPE VEKP-VENUM.
  DATA B_PINNR TYPE ZPACK_PCL-PINNR.

*  PINNR = GWA_HU_PALLET-PINNR.
  TRY.
      IF ( GWA_HU_PALLET-HUSTAT = C_HUSTAT_CLOSED OR GWA_HU_PALLET-HUSTAT = C_HUSTAT_COMPLETED
            OR GWA_HU_PALLET-HUSTAT = C_HUSTAT_FORCED ).
*        PERFORM F_MOVE_SLOC_BAPI CHANGING N_ERRNO.
*        IF N_ERRNO NE 0.
*          ROLLBACK WORK.
*          CALL FUNCTION 'HU_PACKING_REFRESH'.
*          CALL FUNCTION 'SERIAL_INTTAB_REFRESH'.
*          MESSAGE 'Problem occured!' TYPE 'I'.
*        ENDIF.
      ENDIF.

      PERFORM F_CAN_UNPACK CHANGING B_CAN_UNPACK.

      IF B_CAN_UNPACK = V_YES.
        IF ITAB_UNPACK_TASK[] IS INITIAL.
          B_UNPACK_HU = V_YES.
          PERFORM F_HU_UNPACK_SELECT_ALL CHANGING N_UNPACKED_COUNT.
        ELSE.
          PERFORM F_HU_UNPACK_SELECTION CHANGING N_UNPACKED_COUNT.
*         are all packed items will be unpacked?
          IF N_UNPACKED_COUNT = GWA_HU-PACKED.
            B_UNPACK_HU = V_YES.
          ELSE.
            B_UNPACK_HU = V_NO.
          ENDIF.
        ENDIF.

        "- 13 feb 2013 (cek otorisasi unpack)
        READ TABLE ITAB_UNPACK_TASK WITH KEY CHARG = ''.
        IF SY-SUBRC = 0.
          MESSAGE 'Pilih pada baris yang ada nomor batch..!' TYPE 'I'.
          RETURN.
        ENDIF.
        LOOP AT ITAB_UNPACK_TASK.
          PERFORM CHECK_AUTH_BATCH USING ITAB_UNPACK_TASK-CHARG SY-TCODE CHANGING N_ERRNO.
          IF N_ERRNO NE 0.
            ROLLBACK WORK.
            RETURN.
          ENDIF.
        ENDLOOP.
        "- 13 feb 2013

        IF B_UNPACK_HU = V_YES.
          PERFORM F_CONFIRM_UNPACK_HU CHANGING B_CONFIRM.
          IF B_CONFIRM = V_YES.
            PERFORM F_HU_UNPACK_HU.
          ELSE.
            RETURN.
          ENDIF.
        ENDIF.

        IF N_UNPACKED_COUNT > 0.
          IF B_UNPACK_HU = V_YES .
            IF ( GWA_HU_PALLET-HUSTAT = C_HUSTAT_CLOSED OR GWA_HU_PALLET-HUSTAT = C_HUSTAT_COMPLETED
            OR GWA_HU_PALLET-HUSTAT = C_HUSTAT_FORCED ).
              PERFORM F_MOVE_SLOC_BAPI CHANGING N_ERRNO.
              IF N_ERRNO NE 0.
                ROLLBACK WORK.
                CALL FUNCTION 'HU_PACKING_REFRESH'.
                CALL FUNCTION 'SERIAL_INTTAB_REFRESH'.
                MESSAGE 'Problem occured!' TYPE 'I'.
              ENDIF.
            ENDIF.

            SELECT SINGLE VENUM INTO INT_HU
              FROM VEKP
              WHERE EXIDV = GS_EXIDV.
            B_PINNR = GWA_PCH-PINNR.
            PERFORM F_HU_DELETE_NEW CHANGING GWA_HU GS_EXIDV N_ERRNO.
            IF N_ERRNO NE 0.
              ROLLBACK WORK.
              RETURN.
            ENDIF.

          ELSE.
            IF ( GWA_HU_PALLET-HUSTAT = C_HUSTAT_CLOSED OR GWA_HU_PALLET-HUSTAT = C_HUSTAT_COMPLETED
             OR GWA_HU_PALLET-HUSTAT = C_HUSTAT_FORCED ).
              PERFORM F_MOVE_SLOC_BAPI CHANGING N_ERRNO.
              IF N_ERRNO NE 0.
                ROLLBACK WORK.
                CALL FUNCTION 'HU_PACKING_REFRESH'.
                CALL FUNCTION 'SERIAL_INTTAB_REFRESH'.
                MESSAGE 'Problem occured!' TYPE 'I'.
              ENDIF.
            ENDIF.

            LOOP AT ITAB_UNPACK_TASK.
              PERFORM    F_HU_UNPACK_TASK
                USING    ITAB_UNPACK_TASK
                CHANGING N_ERRNO.

              IF N_ERRNO NE 0.
                ROLLBACK WORK.
                RETURN.
              ENDIF.
            ENDLOOP.
          ENDIF.

          PERFORM F_HU_UNPACK_UPDATE_ITEMS CHANGING N_UNPACKED_COUNT.
*if there are anything unpacked then check and update the HU status
          IF N_UNPACKED_COUNT > 0 .
            DATA N_PALLET_COUNT TYPE I.

            PERFORM F_HU_UNPACK_UPDATE_HU
              USING N_UNPACKED_COUNT
              CHANGING N_ERRNO.

            SELECT COUNT( * ) INTO N_PALLET_COUNT FROM ZPACK_PCL
              WHERE PINNR = GWA_PCH-PINNR
                AND HUSTAT NE C_HUSTAT_OPEN
                AND HUSEQ_P = '000000'.

            IF N_PALLET_COUNT = 0.
              GWA_PCH-PINST = C_PINST_ACTIVE.
              UPDATE ZPACK_PCH FROM GWA_PCH.
            ENDIF.
          ENDIF.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = V_YES.

          MESSAGE I000(0K) WITH 'Unpack berhasil.'.

          DATA : TPCL LIKE ZPACK_PCL OCCURS 0 WITH HEADER LINE.
          SELECT * FROM ZPACK_PCL INTO TABLE TPCL
            WHERE ( PINNR = GWA_HU_PALLET-PINNR
            AND   HUSEQ = GWA_HU_PALLET-HUSEQ ) OR
            ( PINNR = GWA_HU_PALLET-PINNR
            AND HUSEQ_P = GWA_HU_PALLET-HUSEQ ).


          CASE OK_CODE.
              DATA : HUSTAT TYPE ZPACK_PCL-HUSTAT,
                     FM TYPE ZPACK_PCL-FM,
                     ZMENG TYPE ZPACK_PC-ZMENG.

            WHEN  'UNPALLET' .
              LOOP AT TPCL.
                TPCL-HUSTAT = C_HUSTAT_OPEN.
                TPCL-VENUM = TPCL-FM = TPCL-SLOC_UP = V_NO.
                MODIFY TPCL.
              ENDLOOP.

              UPDATE ZPACK_PCL  FROM TABLE TPCL.

            WHEN 'UNPACK'.

*              ITAB_UNPACK_TASK
              LOOP AT TPCL.
                CLEAR : ZMENG.
                SELECT SINGLE ZMENG INTO ZMENG
                  FROM ZPACK_PC
                  WHERE PINNR  = TPCL-PINNR
                  AND   ZINS01 = TPCL-ZINS01
                  AND   ZINS02 = TPCL-ZINS02
                  AND   MEINS  = TPCL-MEINS.

                IF TPCL-HUSEQ_P = '000000'.
                  IF TPCL-PACKED NE 0.
                    TPCL-HUSTAT = C_HUSTAT_INPROGRESS.
                  ELSE.
                    TPCL-HUSTAT = C_HUSTAT_OPEN.
                    TPCL-VENUM  = V_NO.
                  ENDIF.
                ELSE.
                  IF ZMENG = TPCL-PACKED.
                    TPCL-HUSTAT = C_HUSTAT_OPEN.
                  ENDIF.
                ENDIF.
                TPCL-FM = V_NO.
                TPCL-SLOC_UP = SLOC_UP.
                MODIFY TPCL.
              ENDLOOP.
              IF SY-SUBRC = 0.
                UPDATE ZPACK_PCL  FROM TABLE TPCL.
              ELSE.
                IF GWA_HU_BOX IS NOT INITIAL.
                  UPDATE ZPACK_PCL CLIENT SPECIFIED
                                   SET HUSTAT = C_HUSTAT_OPEN
                                   VENUM   = V_NO
                                   PACKED  = '0'
                                   PACKING_STATION = V_NO
                                   WHERE PINNR   = B_PINNR
                                   AND   VENUM   = INT_HU.
                ELSE.
                  UPDATE ZPACK_PCL CLIENT SPECIFIED
                                   SET HUSTAT = C_HUSTAT_OPEN
                                   VENUM   = V_NO
                                   PACKED  = '0'
                                   PACKING_STATION = V_NO
                                   FM = V_NO
                                   SLOC_UP = V_NO
                                   WHERE PINNR   = B_PINNR
                                   AND   VENUM   = INT_HU.
                ENDIF.
                COMMIT WORK AND WAIT.

              ENDIF.

          ENDCASE.
          COMMIT WORK.
        ENDIF.
      ENDIF.

    CATCH CX_ROOT INTO EX.
      DATA MSG TYPE REF TO IF_MESSAGE.
      DATA S_MSG(100).

      ROLLBACK WORK.
      MSG = EX.
      S_MSG = EX->GET_TEXT( ).
      MESSAGE E000(0K) WITH 'Unpack error.' S_MSG.

  ENDTRY.

ENDFORM.                    " f_hu_unpack


*&---------------------------------------------------------------------*
*&      Form  f_hu_unpack_update_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK_UPDATE_ITEMS CHANGING FCN_UNPACKED_COUNT.
  DATA N_COUNT       TYPE I.
  DATA N_WRITEPOS    TYPE I.
  DATA N_READPOS     TYPE I.
  DATA WA_COM        LIKE HU_COM.
  DATA ITAB_UNPACKED TYPE TABLE OF COMM1 WITH HEADER LINE.

  DESCRIBE TABLE HU_COM LINES N_COUNT.

  N_WRITEPOS = 0.
  FCN_UNPACKED_COUNT = 0.
  REFRESH ITAB_UNPACKED.

* Shift up to fill empty rows
  DO N_COUNT TIMES.
    ADD 1 TO N_READPOS.
    READ TABLE HU_COM INDEX N_READPOS INTO WA_COM.

    IF WA_COM-SELE = V_YES.
      ADD 1 TO FCN_UNPACKED_COUNT.

*     store hu_com record for clearing related zdigitctl-venum (later)
      APPEND WA_COM TO ITAB_UNPACKED.
    ELSE.
      ADD 1 TO N_WRITEPOS.
      IF N_READPOS NE N_WRITEPOS.
        READ TABLE HU_COM INDEX N_WRITEPOS.
        HU_COM-STAT = WA_COM-STAT.
        HU_COM-SELE = ''.
        HU_COM-EXID = WA_COM-EXID.
        MODIFY HU_COM INDEX N_WRITEPOS.
      ENDIF.
    ENDIF.

  ENDDO.

*- change status from cls to pck by ALF at 06-02-2014
  IF FCN_UNPACKED_COUNT > 0.
    HU_COM-STAT = 'PCK'.
    MODIFY HU_COM TRANSPORTING STAT WHERE EXID NE ''.
  ENDIF.

* Empty last lines
  DO FCN_UNPACKED_COUNT TIMES.
    ADD 1 TO N_WRITEPOS.
    READ TABLE HU_COM INDEX N_WRITEPOS.
    CLEAR:
      HU_COM-STAT,
      HU_COM-SELE,
      HU_COM-EXID.
    MODIFY HU_COM INDEX N_WRITEPOS.
  ENDDO.

  DATA:

  BEGIN OF LT_DC OCCURS 0,
    CHARG TYPE CHARG_D,
    DERIVATIVEMS TYPE N LENGTH 2,
    POSITIONMS TYPE N LENGTH 2,
    DERIVATIVESS TYPE N LENGTH 2,
    POSITIONSS TYPE N LENGTH 2,
    SUBRC(2),
  END OF LT_DC,
  BEGIN OF LT_DCID OCCURS 0,
    DCID TYPE N LENGTH 12,
    CHARG TYPE CHARG_D,
    DERIVATIVEMS TYPE N LENGTH 2,
    POSITIONMS TYPE N LENGTH 2,
    DERIVATIVESS TYPE N LENGTH 2,
    POSITIONSS TYPE N LENGTH 2,
  END OF LT_DCID.

  LOOP AT ITAB_UNPACKED.

    MOVE SY-SUBRC TO LT_DC-SUBRC.
    MOVE ITAB_UNPACKED-EXID(10) TO LT_DC-CHARG.
    MOVE ITAB_UNPACKED-EXID+10(2) TO LT_DC-DERIVATIVEMS.
    MOVE ITAB_UNPACKED-EXID+12(2) TO LT_DC-POSITIONMS.
    MOVE ITAB_UNPACKED-EXID+14(2) TO LT_DC-DERIVATIVESS.
    MOVE ITAB_UNPACKED-EXID+16(2) TO LT_DC-POSITIONSS.
    APPEND LT_DC.
  ENDLOOP.

ENDFORM.                    " f_hu_unpack_update_screen


*&---------------------------------------------------------------------*
*&      Form  f_hu_unpack_update_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK_UPDATE_HU USING FUN_UNPACKED_COUNT CHANGING FCN_ERRNO.

  SELECT COUNT( * ) INTO GWA_HU-PACKED FROM VEPO
    WHERE VENUM = GWA_HU-VENUM.

* Update HU status
  IF GWA_HU-PACKED = 0.
    PERFORM F_HU_RELEASE CHANGING GWA_HU GS_EXIDV FCN_ERRNO.
  ELSE.
    PERFORM F_REC_HU_USAGE CHANGING GWA_HU.
    GWA_HU-HUSTAT = C_HUSTAT_INPROGRESS.
    GWA_HU-PACKED = GWA_HU-PACKED - FUN_UNPACKED_COUNT. " uhuy
    UPDATE ZPACK_PCL FROM GWA_HU.


    DATA:
    LD_SUBRC(2),
    LD_PACKED(18),
    LD_DESCR TYPE TEXT255.

    MOVE SY-SUBRC TO LD_SUBRC.
    WRITE GWA_HU-PACKED TO LD_PACKED.

    CONCATENATE '(' LD_SUBRC ') F_HU_UNPACK_UPDATE_HU, VENUM=' GWA_HU-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
    CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU-HUSTAT INTO LD_DESCR.

  ENDIF.


  IF GWA_HU_BOX IS INITIAL.
    PERFORM F_HU_UNPACK_UPDATE_PIN.
    GWA_HU_PALLET = GWA_HU.
    GS_EXIDV_PALLET = GS_EXIDV.

  ELSE.
    IF GWA_HU IS NOT INITIAL.
      GWA_HU_BOX = GWA_HU.
    ENDIF.
    GS_EXIDV_BOX = GS_EXIDV.

    SELECT COUNT( * ) INTO GWA_HU_PALLET-PACKED FROM ZPACK_PCL
      WHERE PINNR = GWA_HU_PALLET-PINNR
        AND HUSEQ_P = GWA_HU_PALLET-HUSEQ
        AND VENUM NE SPACE.

*   If the status of the box is cleared (box hu removed), then
*   decrease packed count from the pallet
    IF GWA_HU_BOX IS INITIAL.
*      SELECT COUNT( * ) INTO GWA_HU_PALLET-PACKED FROM ZPACK_PCL
*        WHERE PINNR = GWA_HU_PALLET-PINNR
*          AND HUSEQ_P = GWA_HU_PALLET-HUSEQ
*          AND VENUM NE SPACE.



      IF GWA_HU_PALLET-PACKED = 0.
        PERFORM F_HU_RELEASE
          CHANGING GWA_HU_PALLET GS_EXIDV_PALLET FCN_ERRNO.
      ELSE.
        PERFORM F_REC_HU_USAGE CHANGING GWA_HU_PALLET.
        GWA_HU_PALLET-HUSTAT = C_HUSTAT_INPROGRESS.
        UPDATE ZPACK_PCL FROM GWA_HU_PALLET.

        MOVE SY-SUBRC TO LD_SUBRC.
        WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

        CONCATENATE '(' LD_SUBRC ') F_HU_UNPACK_UPDATE_HU, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
        CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.

      ENDIF.

      PERFORM F_HU_UNPACK_UPDATE_PIN.

    ELSE.
      GWA_HU_PALLET-HUSTAT = C_HUSTAT_INPROGRESS.
      PERFORM F_REC_HU_USAGE CHANGING GWA_HU_PALLET.
      UPDATE ZPACK_PCL FROM GWA_HU_PALLET.


      MOVE SY-SUBRC TO LD_SUBRC.
      WRITE GWA_HU_PALLET-PACKED TO LD_PACKED.

      CONCATENATE '(' LD_SUBRC ') F_HU_UNPACK_UPDATE_HU, VENUM=' GWA_HU_PALLET-VENUM ', PACKED=' LD_PACKED INTO LD_DESCR.
      CONCATENATE LD_DESCR ', HUSTAT=' GWA_HU_PALLET-HUSTAT INTO LD_DESCR.


    ENDIF.

  ENDIF.

ENDFORM.                    " f_hu_unpack_update_hu


*&---------------------------------------------------------------------*
*&      Form  f_hu_release
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GWA_HU  text
*      <--P_GS_EXIDV  text
*----------------------------------------------------------------------*
FORM F_HU_RELEASE
  CHANGING FCWA_HU TYPE ZPACK_PCL
           FCS_EXIDV FCN_ERRNO.

  PERFORM F_REC_HU_USAGE CHANGING FCWA_HU.
  PERFORM F_HU_DELETE_NEW CHANGING FCWA_HU FCS_EXIDV FCN_ERRNO.
ENDFORM.                    " f_hu_release


*&---------------------------------------------------------------------*
*&      Form  f_hu_unpack_update_pin
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK_UPDATE_PIN .
  DATA N_PALLET_COUNT TYPE I.
  DATA N_REQUIRED_PALLET TYPE I.


*   All pallet is OPEN then packing instruction status should be
*   set to Active.

  SELECT COUNT( * ) INTO N_PALLET_COUNT FROM ZPACK_PCL
    WHERE PINNR = GWA_HU_PALLET-PINNR
      AND HUSEQ_P = '000000'
      AND HUSTAT = C_HUSTAT_OPEN.

  SELECT SUM( ZMENG ) INTO N_REQUIRED_PALLET
    FROM ZPACK_PC
    WHERE PINNR = GWA_HU_PALLET-PINNR
      AND INILVL = C_LEVEL_PALLET.

*   gwa_pc_pallet-zmeng.
  IF N_PALLET_COUNT = N_REQUIRED_PALLET.
    GWA_PCH-PINST = C_PINST_ACTIVE.
    UPDATE ZPACK_PCH FROM GWA_PCH.

    PERFORM F_UNLOCK_NEW.
    PERFORM F_RESET_ALL.
  ENDIF.


ENDFORM.                    " f_hu_unpack_update_pin


*&---------------------------------------------------------------------*
*&      Form  f_confirm_unpack_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_B_CONFIRM  text
*----------------------------------------------------------------------*
FORM F_CONFIRM_UNPACK_HU  CHANGING FCB_CONFIRM.
  DATA S_CHOICE(1).


  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Unpack HU Confirmation'
      TEXT_QUESTION         = 'Unpack HU?'
      TEXT_BUTTON_1         = 'Ya'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = 'Tidak'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '2'
      DISPLAY_CANCEL_BUTTON = V_NO
    IMPORTING
      ANSWER                = S_CHOICE.

*  fcb_confirm = s_choice.
  IF S_CHOICE = '1'.
    FCB_CONFIRM = V_YES.
  ELSE.
    CLEAR FCB_CONFIRM.
  ENDIF.

ENDFORM.                    " f_confirm_unpack_hu


*&---------------------------------------------------------------------*
*&      Form  f_hu_unpack_select_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_HU_UNPACK_SELECT_ALL CHANGING FCN_UNPACKED_COUNT.
  REFRESH ITAB_UNPACK_TASK.

  FCN_UNPACKED_COUNT = 0.

* unpack all the materials.
  LOOP AT HU_COM.
    IF HU_COM-EXID IS NOT INITIAL.
      ADD 1 TO FCN_UNPACKED_COUNT.
      HU_COM-SELE = V_YES.
      MODIFY HU_COM INDEX SY-TABIX.
      PERFORM F_ADD_UNPACK_MATERIAL_TASK USING HU_COM-EXID.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " f_select_all

*&---------------------------------------------------------------------*
*&      Form  f_hu_print_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_PRINTLIST  text
*----------------------------------------------------------------------*
FORM F_HU_PRINT_SELECTION USING FUB_SHOWALL.
  DATA:
    BEGIN OF ITAB_EXIDV OCCURS 0,
      VENUM TYPE VENUM,
      EXIDV TYPE EXIDV,
      VHILM TYPE VHILM,
    END OF ITAB_EXIDV,

*    itab_selection TYPE TABLE OF mcmarked_values WITH HEADER LINE,
    ITAB_HU TYPE TABLE OF ZPACK_PCL WITH HEADER LINE,
    S_PRSTAT(15),
    S_TEXT(40),
    N_ERRNO TYPE I,
    EX TYPE REF TO CX_ROOT.

  REFRESH ITAB_PRINTLIST.

  IF FUB_SHOWALL = V_YES.
    SELECT *
      INTO TABLE ITAB_HU
      FROM ZPACK_PCL
      WHERE PINNR = GWA_PCH-PINNR
        AND HUSTAT IN
          (C_HUSTAT_COMPLETED, C_HUSTAT_FORCED, C_HUSTAT_CLOSED)
        AND ( COMPUTER_NAME EQ SPACE OR COMPUTER_NAME
          EQ GS_COMPUTER_NAME ).
  ELSE.
    SELECT *
      INTO TABLE ITAB_HU
      FROM ZPACK_PCL
      WHERE PINNR = GWA_PCH-PINNR
        AND HUSTAT IN
          (C_HUSTAT_COMPLETED, C_HUSTAT_FORCED, C_HUSTAT_CLOSED)
        AND ( COMPUTER_NAME EQ SPACE OR COMPUTER_NAME
          EQ GS_COMPUTER_NAME )
        AND PRSTAT EQ C_PRSTAT_NOTPRINTED.
  ENDIF.

  SELECT VENUM EXIDV VHILM
    INTO TABLE ITAB_EXIDV
    FROM VEKP
    FOR ALL ENTRIES IN ITAB_HU
    WHERE VENUM = ITAB_HU-VENUM.

  SORT ITAB_HU BY HUSEQ.
  REFRESH ITAB_PRINTLIST.

  LOOP AT ITAB_HU.
    MOVE ITAB_HU TO ITAB_PRINTLIST-WA_HU.
    READ TABLE ITAB_EXIDV WITH KEY VENUM = ITAB_HU-VENUM.
    ITAB_PRINTLIST-VENUM = ITAB_EXIDV-VENUM.
    ITAB_PRINTLIST-EXIDV = ITAB_EXIDV-EXIDV.
    ITAB_PRINTLIST-VHILM = ITAB_EXIDV-VHILM.

    IF ITAB_PRINTLIST-WA_HU-PRSTAT = ''.
      ITAB_PRINTLIST-WA_HU-PRSTAT = C_PRSTAT_NOTPRINTED.
    ENDIF.

    IF ITAB_PRINTLIST-WA_HU-HUSEQ+4(2) = '00'.
      ITAB_PRINTLIST-HUTYP = 'PLT'.
      ITAB_PRINTLIST-SEQUENCE = ITAB_PRINTLIST-WA_HU-HUSEQ(4).
    ELSE.
      ITAB_PRINTLIST-HUTYP = 'BOX'.
      ITAB_PRINTLIST-SEQUENCE = ITAB_PRINTLIST-WA_HU-HUSEQ+4(2).
    ENDIF.

    APPEND ITAB_PRINTLIST.

  ENDLOOP.

ENDFORM.                    " f_hu_print_selection


*&---------------------------------------------------------------------*
*&      Form  f_confirm_switch_batch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_B_CHANGE  text
*----------------------------------------------------------------------*
FORM F_CONFIRM_SWITCH_BATCH  CHANGING FCB_CHANGE.
  DATA S_QUESTION(50).
  DATA S_CHOICE(1).

  IF GB_IS_NEW_BATCH = V_YES.
    S_QUESTION = 'Ganti ke model batch lama?'.
  ELSE.
    S_QUESTION = 'Ganti ke model batch baru?'.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Ganti model batch'
      TEXT_QUESTION         = S_QUESTION
      TEXT_BUTTON_1         = 'Ya'
      ICON_BUTTON_1         = '@0V@'
      TEXT_BUTTON_2         = 'Tidak'
      ICON_BUTTON_2         = '@0W'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = V_NO
    IMPORTING
      ANSWER                = S_CHOICE
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    FCB_CHANGE = V_NO.
  ELSE.
    IF S_CHOICE = '1'.
      FCB_CHANGE = V_YES.
    ELSE.
      FCB_CHANGE = V_NO.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_confirm_switch_batch


*&---------------------------------------------------------------------*
*&      Form  f_match_pins_characteristic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_MATCH_PINS_CHARACTERISTIC  CHANGING FCN_ERRNO.
  DATA: ITAB_VALUES TYPE TABLE OF API_VALI WITH HEADER LINE,
        ITAB_CREATED TYPE TABLE OF API_VALI WITH HEADER LINE,
        V_CHARG LIKE MCHA-CHARG,
        V_MATNR LIKE MCHA-MATNR,
        V_VENUM LIKE VEPO-VENUM,
        V_WIDTH LIKE AUSP-ATFLV,
        V_WIDTH_I LIKE AUSP-ATFLV,
        V_LENGTH LIKE AUSP-ATFLV,
        V_LENGTH_I LIKE AUSP-ATFLV.

  IF GS_EXIDV IS INITIAL.
    SELECT SINGLE VENUM INTO V_VENUM FROM ZPACK_PCL WHERE PINNR = GWA_PCH-PINNR.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE CHARG INTO V_CHARG FROM VEPO WHERE VENUM = V_VENUM.
      IF SY-SUBRC EQ 0.
        SELECT SINGLE MATNR INTO V_MATNR FROM MCHA WHERE CHARG = V_CHARG.
        IF SY-SUBRC EQ 0.
          CALL FUNCTION 'QC01_BATCH_VALUES_READ'
            EXPORTING
              I_VAL_MATNR    = V_MATNR
              I_VAL_CHARGE   = V_CHARG
              I_DATE         = SY-DATUM
            TABLES
              T_VAL_TAB      = ITAB_CREATED
            EXCEPTIONS
              NO_CLASS       = 1
              INTERNAL_ERROR = 2
              NO_VALUES      = 3
              NO_CHARS       = 4
              OTHERS         = 5.

          IF SY-SUBRC EQ 0.
            READ TABLE ITAB_CREATED WITH KEY ATNAM = 'ZZWIDTH'.
            IF SY-SUBRC EQ 0.
              V_WIDTH = ITAB_CREATED-ATFLV.
            ENDIF.

            READ TABLE ITAB_CREATED WITH KEY ATNAM = 'ZZLENGTH'.
            IF SY-SUBRC EQ 0.
              V_LENGTH = ITAB_CREATED-ATFLV.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = ZPACK00-MATNR
      I_VAL_CHARGE   = ZPACK00-CHARG
      I_DATE         = SY-DATUM
    TABLES
      T_VAL_TAB      = ITAB_VALUES
    EXCEPTIONS
      NO_CLASS       = 1
      INTERNAL_ERROR = 2
      NO_VALUES      = 3
      NO_CHARS       = 4
      OTHERS         = 5.
  FCN_ERRNO = SY-SUBRC.
  IF FCN_ERRNO <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
    DATA : S_TYPE TYPE STRING,
           S_WIDTH TYPE STRING,
           S_LENGTH TYPE STRING,
           S_INSIDE TYPE STRING,
           S_OUTSIDE TYPE STRING,
           S_CORE TYPE STRING,
           S_CRITERIA,
           S_VALUE TYPE P DECIMALS 0,
           S_MESSAGE(100).

    IF GS_EXIDV IS INITIAL.
      IF V_WIDTH NE 0.
        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZWIDTH'.
        IF SY-SUBRC EQ 0.
          V_WIDTH_I = ITAB_VALUES-ATFLV.
        ENDIF.
        IF V_WIDTH NE V_WIDTH_I.
          CLEAR : HU_COM, S_MESSAGE, S_VALUE. REFRESH : HU_COM.
          BUT_UNPACK = 'X'.
          S_VALUE    = V_WIDTH.
          S_MESSAGE  = 'Width tidak sesuai, width batch sebelumnya:' && S_VALUE.
          MESSAGE E001(00) WITH S_MESSAGE.
        ENDIF.
      ENDIF.

      IF V_LENGTH NE 0.
        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLENGTH'.
        IF SY-SUBRC EQ 0.
          V_LENGTH_I = ITAB_VALUES-ATFLV.
        ENDIF.
        IF V_LENGTH NE V_LENGTH_I.
          CLEAR : HU_COM, S_MESSAGE, S_VALUE. REFRESH : HU_COM.
          BUT_UNPACK = 'X'.
          S_VALUE    = V_LENGTH.
          S_MESSAGE  = 'Length tidak sesuai, length batch sebelumnya:' && S_VALUE.
          MESSAGE E001(00) WITH S_MESSAGE.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCORE'.
    IF SY-SUBRC EQ 0.
      S_CORE = ITAB_VALUES-ATWRT.
    ENDIF.

    IF GWA_PCH-ZZCORE3 = V_YES AND S_CORE NE '3'.
      FCN_ERRNO = 4.
    ENDIF.
    IF GWA_PCH-ZZCORE6 = V_YES AND S_CORE NE '6'.
      FCN_ERRNO = 4.
    ENDIF.
    IF GWA_PCH-ZZSHEET = V_YES AND S_CORE NE '0'.
      FCN_ERRNO = 4.
    ENDIF.


    IF FCN_ERRNO = 4.
      CLEAR : HU_COM. REFRESH : HU_COM.
      BUT_UNPACK = 'X'.
      MESSAGE E001(00) WITH 'Core tidak sesuai'.
    ELSE.
      BUT_UNPACK = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCRITERIA'.
    IF SY-SUBRC EQ 0.
      S_CRITERIA = ITAB_VALUES-ATWRT.
    ENDIF.
    IF ( GWA_PCH-ZZCRITERIABF = V_YES AND S_CRITERIA NE 'B' ).
      FCN_ERRNO = 4.
    ENDIF.

    IF    GWA_PCH-ZZCRITERIA1 = V_YES AND S_CRITERIA NE '1' .
      FCN_ERRNO = 4.
    ENDIF.

    IF ( GWA_PCH-ZZCRITERIA2 = V_YES AND S_CRITERIA NE '2' ).
      FCN_ERRNO = 4.
    ENDIF.

    IF ( GWA_PCH-ZZCRITERIAR = V_YES AND S_CRITERIA NE 'R' ).
      FCN_ERRNO = 4.
    ENDIF.


    IF FCN_ERRNO = 4.
      CLEAR : HU_COM. REFRESH : HU_COM.
      BUT_UNPACK = 'X'.
      MESSAGE E001(00) WITH 'Kriteria tidak sesuai'.
    ELSE.
      BUT_UNPACK = ''.
    ENDIF.

  ENDIF.

  READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTYPE'.
  IF SY-SUBRC EQ 0.
    S_TYPE = ITAB_VALUES-ATWRT.
  ENDIF.
  READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZWIDTH'.
  IF SY-SUBRC EQ 0.
    S_WIDTH = ITAB_VALUES-ATWRT.
  ENDIF.
  READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC EQ 0.
    S_LENGTH = ITAB_VALUES-ATWRT.
  ENDIF.
  READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZINSIDE'.
  IF SY-SUBRC EQ 0.
    S_INSIDE = ITAB_VALUES-ATWTB.
  ENDIF.
  READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZOUTSIDE'.
  IF SY-SUBRC EQ 0.
    S_OUTSIDE = ITAB_VALUES-ATWTB.
  ENDIF.


  " display informasi karakteristik
  ZPACK00-CHAR01 = S_TYPE.
  ZPACK00-CHAR02 = S_WIDTH.
  ZPACK00-CHAR03 = S_LENGTH.
  ZPACK00-CHAR04 = S_INSIDE.
  ZPACK00-CHAR05 = S_OUTSIDE.
  ZPACK00-CHAR06 = S_CORE.
  ZPACK00-CHAR07 = S_CRITERIA.
  SELECT SINGLE MEINS INTO ZPACK00-MEINS0
    FROM MARA
    WHERE MATNR = ZPACK00-MATNR0.
ENDFORM.                    " f_match_pins_characteristic



*&---------------------------------------------------------------------*
*&      Form  f_read_grade_criteria
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_READ_GRADE_CRITERIA .
  SELECT C1~VALC C2~VALC
    INTO TABLE ITAB_GRADE_CRITERIA
    FROM CUVTAB_VALC AS C1
      INNER JOIN CUVTAB_VALC AS C2
      ON C1~VTINT = C2~VTINT
        AND C1~SLNID = C2~SLNID
      INNER JOIN CABN AS B1        " ZZGRADE
      ON C1~ATINN = B1~ATINN
      INNER JOIN CABN AS B2        " ZZCRITERIA
      ON C2~ATINN = B2~ATINN
    WHERE B1~ATNAM = 'ZZGRADE'                              " 1150
      AND B2~ATNAM = 'ZZCRITERIA'                           " 1151
  .

ENDFORM.                    " read_grade_criteria


*&---------------------------------------------------------------------*
*&      Form  f_read_characteristics
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_READ_CHARACTERISTICS CHANGING P_TAB STRUCTURE ZPACK00.
  DATA ITAB_VALUES TYPE TABLE OF API_VALI WITH HEADER LINE.
  DATA : VAR1 TYPE STRING,
         VAR2 TYPE STRING.

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = ZPACK00-MATNR
      I_VAL_CHARGE   = ZPACK00-CHARG
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
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
    IF SY-SUBRC EQ 0.
      IF ITAB_VALUES-ATWRT IS NOT INITIAL.
        SPLIT ITAB_VALUES-ATWRT AT 'K' INTO VAR1 VAR2.
        REPLACE ALL OCCURRENCES OF ',' IN VAR1 WITH ''.
        P_TAB-ZMENG = VAR1.
      ENDIF.
    ENDIF.

*   if exist use alias as type
*    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZALIAS'.
*    IF SY-SUBRC EQ 0.
*      IF ITAB_VALUES-ATWRT IS NOT INITIAL.
*        P_TAB-CHAR11 = ITAB_VALUES-ATWRT.
*      ENDIF.
*    ENDIF.

*    IF P_TAB-CHAR01 IS INITIAL.
*     otherwise use ZZTYPE - ZZTHICKNESS
    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC EQ 0.
*        DATA S_CHAR(40).
*        S_CHAR = ITAB_VALUES-ATWRT.
*        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTHICKNESS'.
*        IF SY-SUBRC EQ 0.
*          CONCATENATE S_CHAR '-' ITAB_VALUES-ATWRT
*            INTO S_CHAR SEPARATED BY SPACE.
*        ENDIF.
      P_TAB-CHAR01 = ITAB_VALUES-ATWRT. "S_CHAR.
    ELSE.
      P_TAB-CHAR01 = ''.
    ENDIF.
*    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR02 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR02 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR03 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR03  = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZINSIDE'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR04 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR04  = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZOUTSIDE'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR05 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR05 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCORE'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR06 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR06 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCRITERIA'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR07 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR07 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR08 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR08 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZALIAS'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR09 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR09 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZPACKING'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR10 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR10 = ''.
    ENDIF.

  ENDIF.

ENDFORM.                    "f_read_characteristics


*&---------------------------------------------------------------------*
*&      Form  f_check_hu_sloc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_HU_VENUM  text
*      <--P_S_SLOC  text
*----------------------------------------------------------------------*
FORM F_CHECK_HU_SLOC  USING    FUS_VENUM
                      CHANGING FCS_SLOC.

  CLEAR FCS_SLOC.
  SELECT SINGLE LGORT INTO FCS_SLOC FROM VEPO
    WHERE VENUM = FUS_VENUM.

ENDFORM.                    " f_check_hu_sloc


*&---------------------------------------------------------------------*
*&      Form  f_select_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_SO  text
*      <--P_WA_SO_WITH_UNRES_STOCK  text
*      <--P_FCN_ERRNO  text
*----------------------------------------------------------------------*
FORM F_SELECT_SO  TABLES   FT_SO STRUCTURE ITAB_SO
                  CHANGING FCWA_SO STRUCTURE ITAB_SO
                           FCN_ERRNO.

  DELETE FT_SO WHERE KALAB EQ 0.

  DATA LT_RETVAL TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA NCOUNT TYPE I.
  DATA:
    BEGIN OF ITAB_SELECTION OCCURS 0,
      NO    TYPE NUMC2,
      MATNR TYPE MATNR,
      VBELN TYPE VBELN_VA,
      POSNR TYPE POSNR_VA,
      KALAB TYPE LABST,
      KASPE TYPE SPEME,
      WERKS TYPE WERKS,
      LGORT TYPE LGORT,
    END OF ITAB_SELECTION.

* convert itab to human readable selection
  DATA N_INDEX TYPE I.

  N_INDEX = 0.
  LOOP AT FT_SO.
    MOVE-CORRESPONDING FT_SO TO ITAB_SELECTION.

    ADD 1 TO N_INDEX.
    ITAB_SELECTION-NO = N_INDEX.
    APPEND ITAB_SELECTION.
  ENDLOOP.

  FCN_ERRNO = 0.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'NO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = ITAB_SELECTION
      RETURN_TAB      = LT_RETVAL
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    FCN_ERRNO = 4.

  ELSE.
    DESCRIBE TABLE LT_RETVAL LINES NCOUNT.

    IF NCOUNT > 0.
      DATA S_EXIDV TYPE N LENGTH 20.

      READ TABLE LT_RETVAL INDEX 1.
      MOVE LT_RETVAL-FIELDVAL TO N_INDEX.
      READ TABLE FT_SO INDEX N_INDEX.
      FCWA_SO = FT_SO.

    ELSE.
      CLEAR FCWA_SO.
      FCN_ERRNO = 4.

    ENDIF.

  ENDIF.


ENDFORM.                    " f_select_so


*&---------------------------------------------------------------------*
*&      Form  f_read_sonum_in_pins
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_S_SO  text
*      <--P_S_SOITEM  text
*      <--P_GS_SONUM  text
*      <--P_S_MATNR  text
*      <--P_N_KALAB  text
*      <--P_N_KASPE  text
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_READ_SONUM_IN_PINS  CHANGING FCS_SO
                                    FCS_SOITEM
                                    FCS_SONUM
                                    FCS_MATNR
                                    FCN_KALAB
                                    FCN_KASPE
                                    FCN_ERRNO.

  DATA S_PINNR TYPE ZPINNR.

  SELECT SINGLE PINNR INTO S_PINNR FROM ZPACK_PCL
    WHERE VENUM = VENUM.

  IF SY-SUBRC NE 0.

    FCN_ERRNO = 4.

  ELSE.
    SELECT SINGLE VBELN POSNR MATNR INTO (FCS_SO, FCS_SOITEM, FCS_MATNR)
      FROM ZPACK_PCH WHERE PINNR = S_PINNR.

    IF SY-SUBRC NE 0.
      MESSAGE I000(0K) WITH 'Cant find packing instruction.'.
      FCN_ERRNO = 4.

    ELSE.
      CONCATENATE FCS_SO FCS_SOITEM INTO FCS_SONUM.
      ZPACK00-VBELN  = FCS_SO.
      ZPACK00-POSNR  = FCS_SOITEM.
      ZPACK00-MATNR0 = FCS_MATNR.

    ENDIF.
  ENDIF.

  CLEAR: FCN_KASPE, FCN_KALAB.
ENDFORM.                    " f_read_sonum_in_pins


*&---------------------------------------------------------------------*
*&      Form  f_unpack_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UNPACK_PALLET .
  DATA ANS.
  DATA RET       TYPE TABLE OF BAPIRET2 WITH HEADER LINE.
  DATA ITAB_PCL  TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
  DATA S_HUSEQ_LAST TYPE ZPOSNR_PL.
  DATA N_COUNT TYPE I.
  DATA S_DESCR TYPE TEXT255.
  DATA N_ERRNO TYPE I.

  TYPES :
    BEGIN OF ST_FORMSG,
      MSGID  LIKE SY-MSGID,
      MSGTY  LIKE SY-MSGTY,
      MSGNO  LIKE SY-MSGNO,
      MSGV1  LIKE SY-MSGV1,
      MSGV2  LIKE SY-MSGV2,
      MSGV3  LIKE SY-MSGV3,
      MSGV4  LIKE SY-MSGV4,
      LINENO TYPE MESG-ZEILE,
    END OF ST_FORMSG.

  DATA : TA_ERROR TYPE TABLE OF ST_FORMSG,
         WA_ERROR TYPE ST_FORMSG.



  IF GS_EXIDV_PALLET IS NOT INITIAL.
    IF GWA_HU_PALLET-HUSTAT IS INITIAL.
      RETURN.
    ENDIF.

*    IF GWA_HU_PALLET-HUSTAT = C_HUSTAT_CLOSED.
*      MESSAGE I000(0K) WITH 'Pallet sudah di close. Tidak dapat di unpack.'.
*      RETURN.
*    ENDIF.

    DATA: LB_CAN_UNPACK TYPE FLAG.
    PERFORM F_CAN_UNPACK CHANGING LB_CAN_UNPACK.
    IF LB_CAN_UNPACK = V_NO.
      MESSAGE I000(0K) WITH 'Pallet tidak dapat di unpack.'.
      RETURN.

    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Unpack dan hapus pallet?'
        TEXT_QUESTION         = 'Unpack dan hapus pallet?'
        TEXT_BUTTON_1         = 'Ya'
        ICON_BUTTON_1         = '@0V@'
        TEXT_BUTTON_2         = 'Tidak'
        ICON_BUTTON_2         = '@0W@'
        DEFAULT_BUTTON        = '1'
        DISPLAY_CANCEL_BUTTON = ' '
      IMPORTING
        ANSWER                = ANS.

    IF ANS = '2'.
      RETURN.
    ENDIF.

    "- 13 feb 2013 (cek otorisasi unpack)
    LOOP AT  HU_COM.
      PERFORM CHECK_AUTH_BATCH USING HU_COM-EXID SY-TCODE CHANGING N_ERRNO.
      IF N_ERRNO NE 0.
        ROLLBACK WORK.
        RETURN.
      ENDIF.
    ENDLOOP.
    "- 13 feb 2013

    " Added by William at 23.02.2026 (unpallet RTP)
    CLEAR: V_WERK1_UNPALLET, V_LGOR1_UNPALLET.
    PERFORM F_GET_SLOC_HU USING GS_EXIDV_PALLET CHANGING V_LGOR1_UNPALLET V_WERK1_UNPALLET.
    " End added by William at 23.02.2026 (unpallet RTP)

    CALL FUNCTION 'BAPI_HU_DELETE'
      EXPORTING
        HUKEY        = GS_EXIDV_PALLET
        WITHLOWERHUS = 'X'
      TABLES
        RETURN       = RET.

    READ TABLE RET WITH KEY TYPE = 'E'.
    IF SY-SUBRC EQ 0.
**-- 14 jan 13 (minta detil message)
      LOOP AT RET WHERE TYPE NE 'S'.
        WA_ERROR-MSGID    = RET-ID.
        WA_ERROR-MSGTY    = RET-TYPE .
        WA_ERROR-MSGNO    = RET-NUMBER.
        WA_ERROR-MSGV1    = RET-MESSAGE_V1.
        WA_ERROR-MSGV2    = RET-MESSAGE_V2.
        WA_ERROR-MSGV3    = RET-MESSAGE_V3.
        WA_ERROR-MSGV4    = RET-MESSAGE_V4.
        WA_ERROR-LINENO = SY-TABIX.
        APPEND WA_ERROR TO TA_ERROR.
      ENDLOOP.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          I_MESSAGE_TAB = TA_ERROR.
*-  14 jan 13
*    IF ret[] IS NOT INITIAL.
      MESSAGE I000(0K) WITH 'Cant unpack'.
      RETURN.
    ENDIF.

    CONCATENATE GWA_HU_PALLET-HUSEQ(4) '99' INTO S_HUSEQ_LAST.
*    s_huseq_last = gwa_hu_pallet-huseq.
*    s_huseq_last+4(2) = '99'.

    SELECT * INTO TABLE ITAB_PCL FROM ZPACK_PCL
      WHERE PINNR = GWA_HU_PALLET-PINNR
        AND HUSEQ >= GWA_HU_PALLET-HUSEQ
        AND HUSEQ <= S_HUSEQ_LAST
        AND VENUM <> SPACE
        AND VENUM <> ''.

    DESCRIBE TABLE ITAB_PCL LINES N_COUNT.


    IF N_COUNT > 100 OR SY-SUBRC NE 0.
      WRITE N_COUNT TO S_DESCR.
      CONCATENATE '(1)_F_UNPACK_PALLET, Too many HU to process=' S_DESCR INTO S_DESCR.
      CONCATENATE S_DESCR ', VENUM=' GWA_HU_PALLET-VENUM ', EXIDV=' GS_EXIDV_PALLET INTO S_DESCR.

    ENDIF.


    LOOP AT ITAB_PCL.
      CLEAR:
        ITAB_PCL-PACKED,
        ITAB_PCL-VENUM.

      ITAB_PCL-HUSTAT = C_HUSTAT_OPEN.
      ITAB_PCL-PRSTAT = C_PRSTAT_NOTPRINTED.
      ITAB_PCL-FM     = V_NO.
      ITAB_PCL-SLOC_UP = V_NO.
      IF ITAB_PCL-HUSEQ = '000100'.
        ITAB_PCL-HUSEQ_P = '000000'.
      ENDIF.
      PERFORM F_REC_HU_USAGE CHANGING ITAB_PCL.
      MODIFY ITAB_PCL.
    ENDLOOP.


    READ TABLE ITAB_PCL WITH KEY HUSEQ_P = '000000' INTO GWA_HU_PALLET.
    IF GWA_HU_BOX IS INITIAL.
      GWA_HU = GWA_HU_PALLET.
    ENDIF.

    DATA LD_SUBRC(2).

    UPDATE ZPACK_PCL  FROM TABLE ITAB_PCL.
    UPDATE ZPACK_PCH CLIENT SPECIFIED
           SET PINST = 'A'
           WHERE PINNR = ZPACK00-PINNR.
    COMMIT WORK .


    DATA:
    LT_LOG TYPE TABLE OF ZPACK_PCL_LOG WITH HEADER LINE.

    MOVE SY-SUBRC TO LD_SUBRC.
    REFRESH LT_LOG.

    LOOP AT ITAB_PCL.
      MOVE-CORRESPONDING ITAB_PCL TO LT_LOG.
      CONCATENATE '(' LD_SUBRC ') F_UNPACK_PALLET, VENUM=' ITAB_PCL-VENUM ', HUSTAT=' ITAB_PCL-HUSTAT INTO LT_LOG-DESCR.
      CONCATENATE LT_LOG-DESCR ', PRSTAT=' ITAB_PCL-PRSTAT INTO LT_LOG-DESCR.
      APPEND LT_LOG.
    ENDLOOP.


    MOVE SY-SUBRC TO LD_SUBRC.

    PERFORM F_HU_UNPACK_UPDATE_PIN.
    PERFORM F_RESET_ALL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT   = V_YES
      IMPORTING
        RETURN = RET.

    MESSAGE I000(0K) WITH 'Pallet berhasil di unpack.'.

    PERFORM UNPACK_PALID.

  ENDIF.
ENDFORM.                    " f_unpack_pallet
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_BATCH  USING  FUS_MATNR CHANGING P_N_ERRNO.
  DATA : V_CHARG TYPE MCHA-CHARG.
  CLEAR : V_CHARG.

  SELECT SINGLE CHARG INTO V_CHARG
    FROM MCHA
    WHERE CHARG = ZPACK00-CHARG
    AND   MATNR = FUS_MATNR
    AND   WERKS = HUPAST_T-PLANT.

  IF SY-SUBRC NE 0.
    P_N_ERRNO = 4.
  ENDIF.


ENDFORM.                    " F_CHECK_BATCH
*&---------------------------------------------------------------------*
*&      Form  LOCK_FS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LOCK_FS .
  DATA : MSG TYPE STRING,
         PC TYPE STRING,
         USER TYPE SY-UNAME,
         DATE TYPE STRING,
         TIME TYPE STRING,
         MESSAGE TYPE SM04DIC-POPUPMSG,
         ANS,
         FLAG,
         KEY1 TYPE STRING,
         VAR1 TYPE STRING,
         VAR2 TYPE STRING,
         TLOCK TYPE SEQG3 OCCURS 0 WITH HEADER LINE,
         TINFO TYPE  UINFO2 OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'POC_GET_COMPUTER_NAME'
    IMPORTING
      EX_COMPUTER_NAME = GS_COMPUTER_NAME
    EXCEPTIONS
      GUI_ERROR        = 1
      OTHERS           = 2.

  CONCATENATE 'FS' GWA_PCH-PINNR HUPAST_T-PLANT '-' GS_COMPUTER_NAME INTO VLOCK.
  CONCATENATE SY-MANDT 'FS' GWA_PCH-PINNR HUPAST_T-PLANT INTO KEY1.

*   tampilin semua yang kelock
  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GUNAME = ''
    TABLES
      ENQ    = TLOCK.


  LOOP AT TLOCK  WHERE GNAME  = 'ZTLOCK'
                 AND  GOBJ   = 'EZGR'
                 AND  GTCODE =  SY-TCODE.

    SPLIT TLOCK-GTARG AT '-' INTO VAR1 VAR2. "(paking instructin / terminal lock)

    IF ( VAR1 = KEY1 ) .  "-> Kalo packing instruction ada yang di lock

      IF ( VAR2 NE GS_COMPUTER_NAME ) AND ( SY-UNAME NE TLOCK-GUNAME ).  "-> kalo terminal login beda sama terminal yang ngelock
        "-> cek terminalnya  masih aktif
        CALL FUNCTION 'TH_LONG_USR_INFO'
          EXPORTING
            USER      = TLOCK-GUNAME " USER YANG LOCK
          TABLES
            USER_INFO = TINFO.

*- update for RTS
        LOOP AT TINFO WHERE TCODE = 'ZHU5FS' OR  TCODE = 'ZHU5FSR'.
          TRANSLATE TINFO-TERMINAL TO UPPER CASE.
          MODIFY TINFO.
        ENDLOOP.
        IF SY-TCODE = 'ZHU5FSR'.
          READ TABLE TINFO WITH KEY CLIENT   = SY-MANDT
                                    USER     = TLOCK-GUNAME
                                    TCODE    = 'ZHU5FSR'
                                    TERMINAL = VAR2.
        ELSE.
          READ TABLE TINFO WITH KEY CLIENT   = SY-MANDT
                                    USER     = TLOCK-GUNAME
                                    TCODE    = 'ZHU5FS'
                                    TERMINAL = VAR2.
        ENDIF.
        IF SY-SUBRC = 0. "-> MASIH aktif
          MESSAGE I018(ZMM) WITH 'Packing inst sedang digunakan oleh'
               TLOCK-GUNAME 'terminal' VAR2.
          LEAVE SCREEN.
        ELSE. " ga aktif terminalnya / nyangkut
          PERFORM DELETE_LOCK_FS  USING VLOCK .
          FLAG = 1.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF FLAG = 0.
    CALL FUNCTION 'ENQUEUE_EZGR'
      EXPORTING
        MODE_ZTLOCK    = 'E'
        MANDT          = SY-MANDT
        LOOBJ          = VLOCK
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

  ENDIF.


*      IF SY-SUBRC NE 0. "-> ga ada user yang buka / nyangkut
*        PERFORM DELETE_LOCK_FS  USING VLOCK CHANGING FLAG.
*        IF FLAG = 1.
*          MESSAGE I002(ZMM) WITH  'nomer nyangkut dan Gagal di unlock' 'Coba beberapa saat lagi'.
*          RETURN.
*        ENDIF.
*
*      ELSE. "-> ada yang ngelock
*
*        "-> cek lagi terminal yang sama apa ga?
*        "    kalo ga sama baru ga boleh kalo sama lanjuttt
*        IF TINFO-TERMINAL NE GS_COMPUTER_NAME.
*
*          CONCATENATE 'Packing Instruction' GWA_PCH-PINNR
*          'sedang di lock oleh' USER_LOCK 'menggunakan pc' TINFO-TERMINAL
*           INTO MSG SEPARATED BY SPACE.
*
*          CALL FUNCTION 'POPUP_TO_CONFIRM'
*            EXPORTING
*              TEXT_QUESTION = MSG
*              TEXT_BUTTON_1 = 'Lanjut'
*              TEXT_BUTTON_2 = 'Tidak'
*            IMPORTING
*              ANSWER        = ANS.
*        ENDIF.
*
*      ENDIF.
*
*
*
*    ENDIF.
*  ENDIF.

*  SELECT SINGLE * FROM ZTLOCK
*     WHERE ZTLOCK~LOOBJ = GWA_PCH-PINNR.
*  IF SY-SUBRC EQ 0.
*    SPLIT ZTLOCK-NOTE AT '-' INTO USER PC TIME DATE.
*    CONCATENATE 'Kemungkin Packing Instruction' ZTLOCK-LOOBJ
*    'sedang digunakan atau nyangkut pada waktu' DATE TIME 'oleh' USER 'menggunakan pc'
*    PC INTO MSG SEPARATED BY SPACE.
*    CALL FUNCTION 'POPUP_TO_CONFIRM'
*      EXPORTING
*        TEXT_QUESTION = MSG
*        TEXT_BUTTON_1 = 'Lanjut'
*        TEXT_BUTTON_2 = 'Gak'
*      IMPORTING
*        ANSWER        = ANS.

*    IF ANS = 1.
*      PERFORM DELETE_LOCK_FS.
*
*      CONCATENATE 'User' SY-UNAME 'PC' GS_COMPUTER_NAME
*      'Menggunakan Packing Instruction' ZTLOCK-LOOBJ 'Untuk Free Stock' INTO MESSAGE SEPARATED BY SPACE.
*      CALL FUNCTION 'TH_POPUP'
*        EXPORTING
*          CLIENT      = SY-MANDT
*          USER        = USER
*          MESSAGE     = MESSAGE
*          MESSAGE_LEN = '12'.
*      ERROR = ''.
*    ELSE.
*      ERROR = V_YES .
*    ENDIF.
*
*  ELSE.


*    CONCATENATE SY-UNAME GS_COMPUTER_NAME SY-UZEIT SY-DATUM INTO ZTLOCK-NOTE SEPARATED BY '-'.
*    ZTLOCK-LOOBJ   = GWA_PCH-PINNR.
*    INSERT ZTLOCK.
*    COMMIT WORK.
*  ENDIF.
ENDFORM.                    " LOCK_FS
*&---------------------------------------------------------------------*
*&      Form  DELETE_LOCK_FS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_LOCK_FS USING P_VLOCK  .
  CALL FUNCTION 'DEQUEUE_EZGR'
    EXPORTING
      MODE_ZTLOCK    = 'E'
      MANDT          = SY-MANDT
      LOOBJ          = P_VLOCK
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

ENDFORM.                    " DELETE_LOCK_FS
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_SLOC_BAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_MOVE_SLOC_BAPI  CHANGING P_N_ERRNO.
  DATA : LT_MOVE_TO TYPE HUM_DATA_MOVE_TO_T,
         LT_EXIDV   TYPE HUM_EXIDV_T WITH HEADER LINE,
         LS_MOVE_TO TYPE HUM_DATA_MOVE_TO,
         LV_POSTED TYPE SYSUBRC,
         LS_MESS TYPE HUITEM_MESSAGES ,
         LT_MESS TYPE HUITEM_MESSAGES_T WITH HEADER LINE,
         LS_EMKPF TYPE EMKPF ,
         LGOR2 TYPE ZHU_MAPP-LGOR2.

  PERFORM F_GET_SLOC CHANGING V_LGORT V_WERKS.

  SELECT SINGLE LGOR2 INTO LGOR2
    FROM ZHU_MAPP
    WHERE TYPES = '11'
    AND   WERK1 = V_WERKS
    AND   LGOR1 = V_LGORT.

  CHECK SY-SUBRC = 0.
  LT_EXIDV-EXIDV = GS_EXIDV_PALLET.
  APPEND LT_EXIDV.
  LS_MOVE_TO-LGORT = LGOR2.
  APPEND LS_MOVE_TO TO LT_MOVE_TO.
  SLOC_UP = LGOR2.

  CALL FUNCTION 'HU_PACKING_REFRESH'.
  PERFORM REFRESH_CHANGE_STOCK(SAPLV51E).

  CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
    EXPORTING
      IF_EVENT       = '0006'
      IF_TCODE       = 'VLMOVE'
      IT_EXTERNAL_ID = LT_EXIDV[]
      IT_MOVE_TO     = LT_MOVE_TO[]
    IMPORTING
      EF_POSTED      = LV_POSTED
      ES_MESSAGE     = LS_MESS
      ET_MESSAGES    = LT_MESS[]
      ES_EMKPF       = LS_EMKPF.

  IF LV_POSTED NE 1.
    P_N_ERRNO = 1 .
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = V_YES.
  ENDIF.
ENDFORM.                    " VLMOVE
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BATCH_SLOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_BATCH_SLOC CHANGING P_N_ERRNO.

*- update for RTS
  CHECK SY-TCODE = 'ZHU5FS' OR SY-TCODE = 'ZHU5FSR'.

  DATA : QTY TYPE P DECIMALS 3,
         QTY_ALL TYPE P DECIMALS 3,
         FM,
         JUM TYPE P DECIMALS 3,
         SOBKZ TYPE VEPO-SOBKZ,
         SLOC TYPE ZPACK_PCL-SLOC_UP,
         CSPEM TYPE MCHB-CSPEM.


  CLEAR : MCHB,P_N_ERRNO,FM,SLOC.

  "cek sloc udah di pindah di zvlmove
  PERFORM F_GET_SLOC_FM CHANGING FM SLOC.

  SELECT  * FROM MCHB
    WHERE MATNR = GWA_PCH-MATNR
*    AND   WERKS = HUPAST_T-PLANT
*    AND   LGORT = HUPAST_T-STGE_LOC
    AND   CHARG = ZPACK00-CHARGDC.

    CLEAR : QTY.
*    QTY = MCHB-CLABS + MCHB-CINSM + MCHB-CEINM  + MCHB-CVMLA
*          + MCHB-CVMIN + MCHB-CVMEI + MCHB-CVMSP + MCHB-CVMRE.
*    JUM = MCHB-CLABS + MCHB-CINSM + MCHB-CSPEM.
*    IF  JUM NE 0.
*        AUTHORITY-CHECK OBJECT 'Z_UNPACK' ID 'Z_UNPACK' FIELD MCHB-LGORT .
*        IF SY-SUBRC NE 0.
*          MESSAGE W000(0K) WITH 'No Authorization to process data' .
*          P_N_ERRNO = '9'.
*          RETURN.
*        ENDIF.
*    ENDIF.

    IF SY-TCODE = 'ZHU5FSR'.
      QTY = MCHB-CEINM + MCHB-CINSM .
    ELSE.
      QTY = MCHB-CLABS + MCHB-CINSM .
    ENDIF.

    QTY_ALL = QTY_ALL + QTY.
*    IF MCHB-CSPEM > 0 .
*      P_N_ERRNO = 2.
*    ENDIF.
    CSPEM = CSPEM + MCHB-CSPEM.

    IF SLOC = ''.
      IF FM = ''.
        IF QTY NE 0.
          IF HUPAST_T-STGE_LOC NE MCHB-LGORT.
            P_N_ERRNO = 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF FM = ''.
        IF QTY NE 0.
          IF SLOC NE MCHB-LGORT.
            P_N_ERRNO = 1 .
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*- update for RTS
    IF SY-TCODE = 'ZHU5FSR'.
      IF SY-TCODE = 'ZHU5FSR' AND MCHB-LGORT = HUPAST_T-STGE_LOC.
        IF MCHB-CLABS NE 0.
          ZPACK00-ZMENG = MCHB-CEINM.
        ELSEIF MCHB-CINSM NE 0.
          ZPACK00-ZMENG = MCHB-CINSM.
        ELSEIF MCHB-CSPEM NE 0.
          ZPACK00-ZMENG = MCHB-CSPEM.
        ENDIF.
      ENDIF.
    ELSE.
      IF SY-TCODE = 'ZHU5FS' AND MCHB-LGORT = HUPAST_T-STGE_LOC.
        IF MCHB-CLABS NE 0.
          ZPACK00-ZMENG = MCHB-CLABS.
        ELSEIF MCHB-CINSM NE 0.
          ZPACK00-ZMENG = MCHB-CINSM.
*      ELSEIF MCHB-CEINM NE 0.
*        ZPACK00-ZMENG = MCHB-CEINM.
        ELSEIF MCHB-CSPEM NE 0.
          ZPACK00-ZMENG = MCHB-CSPEM.
*      ELSEIF MCHB-CVMLA NE 0.
*        ZPACK00-ZMENG = MCHB-CVMLA.
*      ELSEIF MCHB-CVMIN NE 0.
*        ZPACK00-ZMENG = MCHB-CVMIN.
*      ELSEIF MCHB-CVMEI NE 0.
*        ZPACK00-ZMENG = MCHB-CVMEI.
*      ELSEIF MCHB-CVMSP NE 0.
*        ZPACK00-ZMENG = MCHB-CVMSP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDSELECT.

*-- Cek packing udah pindah ke so ?
  SELECT SINGLE SOBKZ INTO SOBKZ
    FROM VEPO
    WHERE CHARG = ZPACK00-CHARGDC
    AND   MATNR = GWA_PCH-MATNR.

* - Qty total all
  IF ( QTY_ALL = 0 AND CSPEM = 0 AND SOBKZ NE 'E' ).
    P_N_ERRNO = 3.
  ENDIF.

  CASE P_N_ERRNO .
    WHEN 1.
      MESSAGE 'Sloc tidak sesuai' TYPE 'I'.
    WHEN 2.
*      IF SY-UCOMM = 'ENTR'.
*         MESSAGE W002(ZMM) WITH 'Blocked Stock'.
*      ENDIF.
    WHEN 3.
      MESSAGE W002(ZMM) WITH 'Tidak ada roll yang dapat dipacking'.
  ENDCASE.

  CHECK P_N_ERRNO = 0.
  SELECT SUM( ZMENG ) INTO ZPACK00-PLCNT FROM ZPACK_PC
  WHERE PINNR = GWA_PCH-PINNR AND INILVL = C_LEVEL_PALLET.

  IF FM = V_YES.
    P_N_ERRNO = 0.
  ENDIF.

ENDFORM.                    " F_CHECK_BATCH_SLOC
*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_LGORT  text
*      <--P_V_WERKS  text
*----------------------------------------------------------------------*
FORM F_GET_SLOC  CHANGING P_V_LGORT
                          P_V_WERKS.

  DATA : V_UNVEL TYPE VEPO-UNVEL,
         EXIDV TYPE VEKP-EXIDV.

  EXIDV = ZPACK00-PLEXID.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = EXIDV
    IMPORTING
      OUTPUT = EXIDV.

  SELECT VEPO~LGORT VEPO~UNVEL VEPO~WERKS INTO (P_V_LGORT, V_UNVEL , P_V_WERKS )
    FROM VEKP
    JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    WHERE VEKP~EXIDV = EXIDV.

    IF V_UNVEL NE ''.
      SELECT SINGLE VEPO~LGORT VEPO~WERKS INTO (P_V_LGORT,P_V_WERKS)
        FROM VEPO
        WHERE VEPO~VENUM = V_UNVEL.
    ELSE.
      EXIT.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " F_GET_SLOC
*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOC_FM
*&---------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      <--P_FM  text
*      <--P_SLOC  text
*----------------------------------------------------------------------*
FORM F_GET_SLOC_FM  CHANGING P_FM
                             P_SLOC.

  DATA : VENUM TYPE VEPO-VENUM,
         HUSEQ TYPE ZPACK_PCL-HUSEQ,
         HUSEQ_P TYPE ZPACK_PCL-HUSEQ_P,
         HUSTAT TYPE ZPACK_PCL-HUSTAT,
         FM TYPE ZPACK_PCL-FM.


  SELECT VENUM INTO VENUM
    FROM VEPO
    WHERE CHARG = ZPACK00-CHARGDC.
  ENDSELECT.

  IF VENUM = ''.
    SELECT SINGLE HUSTAT FM SLOC_UP  INTO (HUSTAT,P_FM,P_SLOC)
      FROM ZPACK_PCL
      WHERE VENUM = GWA_HU-VENUM
      AND   PINNR = GWA_HU-PINNR
      AND   HUSTAT IN (C_HUSTAT_OPEN,C_HUSTAT_INPROGRESS).

    IF HUSTAT = C_HUSTAT_OPEN OR HUSTAT = C_HUSTAT_INPROGRESS.
      RETURN.
    ELSE.
      SELECT VENUM INTO VENUM
        FROM ZPACK_PCL
        WHERE HUSTAT IN (C_HUSTAT_OPEN ,C_HUSTAT_INPROGRESS)
        AND   PINNR = GWA_HU-PINNR
        AND   HUSEQ_P = '0000'.
      ENDSELECT.

*      VENUM = GWA_HU-VENUM.
    ENDIF.
  ENDIF.

  SELECT SINGLE FM  INTO P_FM
    FROM ZPACK_PCL
    WHERE PINNR = GWA_PCH-PINNR
    AND   FM = V_YES
    AND   VENUM = VENUM.


  SELECT SINGLE SLOC_UP INTO P_SLOC "SLOC_UP
    FROM ZPACK_PCL
    WHERE PINNR = GWA_PCH-PINNR
    AND  SLOC_UP NE V_NO
    AND   VENUM = VENUM.

  IF P_SLOC = V_NO.
    SELECT SINGLE HUSEQ HUSEQ_P INTO (HUSEQ,HUSEQ_P)
      FROM ZPACK_PCL
      WHERE PINNR = GWA_PCH-PINNR
      AND VENUM = VENUM.

    IF HUSEQ_P = '00000'.
      HUSEQ_P = HUSEQ.
    ENDIF.
    SELECT SINGLE SLOC_UP INTO P_SLOC
      FROM ZPACK_PCL
      WHERE PINNR = GWA_PCH-PINNR
      AND   HUSEQ_P = HUSEQ_P
      AND   SLOC_UP NE V_NO.
  ENDIF.


ENDFORM.                    " F_GET_SLOC_FM

*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOC_HU
*&---------------------------------------------------------------------*
*       Added by William at 23.02.2026 (unpallet RTP)
*----------------------------------------------------------------------*
*      <--P_V_LGORT  text
*      <--P_V_WERKS  text
*----------------------------------------------------------------------*
FORM F_GET_SLOC_HU USING P_EXIDV  CHANGING P_V_LGORT
                                           P_V_WERKS.

  DATA : V_UNVEL TYPE VEPO-UNVEL,
         EXIDV TYPE VEKP-EXIDV.

  EXIDV = P_EXIDV.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = EXIDV
    IMPORTING
      OUTPUT = EXIDV.

  SELECT VEPO~LGORT VEPO~UNVEL VEPO~WERKS INTO (P_V_LGORT, V_UNVEL , P_V_WERKS )
    FROM VEKP
    JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    WHERE VEKP~EXIDV = EXIDV.

    IF V_UNVEL NE ''.
      SELECT SINGLE VEPO~LGORT VEPO~WERKS INTO (P_V_LGORT,P_V_WERKS)
        FROM VEPO
        WHERE VEPO~VENUM = V_UNVEL.
    ELSE.
      EXIT.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " F_GET_SLOC_HU

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_MASTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MATNR  text
*      <--P_MEINS  text
*      <--P_MAKTX  text
*      <--P_MTART  text
*----------------------------------------------------------------------*
FORM F_GET_MATERIAL_MASTER  USING    P_MATNR
                            CHANGING P_MEINS
                                     P_MAKTX
                                     P_MTART.

  SELECT SINGLE MEINS MAKTX MTART
    INTO (P_MEINS, P_MAKTX, P_MTART)
    FROM MARA INNER JOIN MAKT
      ON MARA~MATNR = MAKT~MATNR
    WHERE MARA~MATNR = P_MATNR
      AND MAKT~SPRAS = SY-LANGU.

ENDFORM.                    " F_GET_MATERIAL_MASTER
*&---------------------------------------------------------------------*
*&      Form  F_CHARACTERISTICS_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZCHARSO  text
*----------------------------------------------------------------------*
FORM F_CHARACTERISTICS_SO USING P_VBELN P_VBELP
           CHANGING P_TAB STRUCTURE ZPACKSO.

  DATA ITAB_VALUES TYPE TABLE OF CONF_OUT WITH HEADER LINE.
  DATA : VAR1 TYPE STRING,
         VAR2 TYPE STRING,
         CUOBJ TYPE INOB-CUOBJ.

  SELECT SINGLE CUOBJ INTO CUOBJ
    FROM VBAP
    WHERE VBELN = P_VBELN
    AND   POSNR = P_VBELP.

  CHECK CUOBJ NE ''.
  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE       = CUOBJ
    TABLES
      CONFIGURATION  = ITAB_VALUES
    EXCEPTIONS
      NO_CLASS       = 1
      INTERNAL_ERROR = 2
      NO_VALUES      = 3
      NO_CHARS       = 4
      OTHERS         = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
    IF SY-SUBRC EQ 0.
      IF ITAB_VALUES-ATWRT IS NOT INITIAL.
        SPLIT ITAB_VALUES-ATWRT AT 'K' INTO VAR1 VAR2.
        REPLACE ALL OCCURRENCES OF ',' IN VAR1 WITH ''.
        P_TAB-ZMENG = VAR1.
      ENDIF.
    ENDIF.

*   if exist use alias as type
*    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZALIAS'.
*    IF SY-SUBRC EQ 0.
*      IF ITAB_VALUES-ATWRT IS NOT INITIAL.
*        P_TAB-CHAR01 = ITAB_VALUES-ATWRT.
*      ENDIF.
*    ENDIF.

*    IF P_TAB-CHAR01 IS INITIAL.
*     otherwise use ZZTYPE - ZZTHICKNESS
    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC EQ 0.
*        DATA S_CHAR(40).
*        S_CHAR = ITAB_VALUES-ATWRT.
*        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZTHICKNESS'.
*        IF SY-SUBRC EQ 0.
*          CONCATENATE S_CHAR '-' ITAB_VALUES-ATWRT
*            INTO S_CHAR SEPARATED BY SPACE.
*        ENDIF.
      P_TAB-CHAR01 = ITAB_VALUES-ATWRT. " S_CHAR.
*      ENDIF.
    ELSE.
      P_TAB-CHAR01 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR02 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR02  = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR03 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR03  = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZINSIDE'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR04 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR04 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZOUTSIDE'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR05 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR05 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCORE'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR06 = ITAB_VALUES-ATWRT.
    ELSE.
      P_TAB-CHAR06 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCRITERIA'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR07 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR07 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCORE'.
    IF ITAB_VALUES-ATWTB = 'SHEET' .
      UPDATE ZPACK_PCH SET ZZSHEET = 'X'
           WHERE  VBELN = P_VBELN
           AND   POSNR = P_VBELP.
      COMMIT WORK.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR08 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR08 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZALIAS'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR09 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR09 = ''.
    ENDIF.

    READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZPACKING'.
    IF SY-SUBRC EQ 0.
      P_TAB-CHAR10 = ITAB_VALUES-ATWTB.
    ELSE.
      P_TAB-CHAR10 = ''.
    ENDIF.

  ENDIF.


ENDFORM.                    " F_CHARACTERISTICS_SO
*&---------------------------------------------------------------------*
*&      Form  F_GET_SHEET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SHEET  text
*----------------------------------------------------------------------*
FORM F_GET_SHEET  CHANGING P_SHEET.
  SELECT SINGLE ZZSHEET INTO P_SHEET
    FROM ZPACK_PCH
    WHERE PINNR = GWA_PCH-PINNR
    AND   VBELN = GWA_PCH-VBELN
    AND   POSNR = GWA_PCH-POSNR.
ENDFORM.                    " F_GET_SHEET
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTH_SLOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
FORM CHECK_AUTH_SLOC  CHANGING P_ERRNO.
  DATA : LGORT TYPE LGORT_D,
          UNVEL TYPE VEPO-UNVEL,
          EXIDV TYPE VEKP-EXIDV.
  CHECK RB2 EQ 'X'.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_EXIDV
    IMPORTING
      OUTPUT = EXIDV.

  SELECT SINGLE  VEPO~LGORT VEPO~UNVEL INTO (LGORT,UNVEL)
    FROM VEKP
    JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    WHERE VEKP~EXIDV = EXIDV.

  IF UNVEL NE ''.
    SELECT SINGLE VEPO~LGORT INTO LGORT
      FROM VEPO
      WHERE VENUM = UNVEL.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'Z_UNPACK' ID 'Z_UNPACK' FIELD LGORT .
  IF SY-SUBRC NE 0.
    MESSAGE W000(0K) WITH 'No Authorization to process data' .
    CLEAR : GS_EXIDV.
    P_ERRNO = '9'.
    RETURN.
  ENDIF.
ENDFORM.                    " CHECK_AUTH_SLOC


*&---------------------------------------------------------------------*
*&      Form  cek_so_palid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_SO_PALID CHANGING FCN_ERRNO.
  DATA: ZSVAL LIKE STANDARD TABLE OF SVAL WITH HEADER LINE,
        V_ANSWER TYPE C,
        V_EXIDV LIKE VEKP-EXIDV,
        V_MSG(125),
        V_NUM10 TYPE N LENGTH 10,
        V_NUM05 TYPE N LENGTH 5,
        V_CHAR6(6).

*- is SO with plastic pallet
  DATA: V_CUOBJ LIKE VEPO-CUOBJ,
        V_ATINN LIKE AUSP-ATINN,
        V_KODE LIKE AUSP-ATWRT.

  DATA: V_MCHB TYPE MCHB.

*- select palid
  DATA: BEGIN OF IT_PALID OCCURS 0,
        PALID LIKE MCH1-CHARG,
        MATNR LIKE MARA-MATNR,
        MAKTX LIKE MAKT-MAKTX,
        END OF IT_PALID.
  DATA: BEGIN OF IT_PALID2 OCCURS 0,
        BOX(2),
        PALID(10)     TYPE C,
        SEPARATOR1(3) TYPE C,
        MATNR(20)     TYPE C,
        SEPARATOR2(3) TYPE C,
        MAKTX(40)     TYPE C,
        END OF IT_PALID2.

  DATA : V_SELE LIKE SY-TABIX.
*- end of select palid

  CLEAR: V_PALID.

  SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = 'ZZPACKINGCODE'. "0000000864
  SELECT SINGLE CUOBJ INTO V_CUOBJ FROM VBAP WHERE VBELN = GS_LASTSO AND POSNR = GS_LASTSOITEM.
  SELECT SINGLE C~ATWRT INTO V_KODE
       FROM ( IBIN AS A JOIN IBINVALUES AS B ON A~IN_RECNO EQ B~IN_RECNO )
       JOIN IBSYMBOL AS C ON C~SYMBOL_ID EQ B~SYMBOL_ID
      WHERE A~INSTANCE EQ V_CUOBJ AND C~ATINN EQ V_ATINN.


  IF V_KODE+0(1) NE 'R'.
    " Modified by William at 21.01.2026 (validasi baru)
    IF SY-TCODE = 'ZHU5SO' OR SY-TCODE = 'ZHU5SOX'.
      EXIT.  "from plastic pallet
    ENDIF.
    " End modified by William at 21.01.2026 (validasi baru)
  ENDIF.

*  IF SY-SUBRC NE 0.
*    MESSAGE 'Kode pallet didalam SO tidak ditemukan...!' TYPE 'I'.
*    FCN_ERRNO = 4.
*    EXIT.
*  ELSEIF V_KODE+0(1) NE 'R'.
*    FCN_ERRNO = 4.
*    EXIT.  "from plastic pallet
*  ELSE.
*  ENDIF.

  " Added by William at 21.01.2026 (validasi baru)
  DATA: V_USE_RTP.

  " Validasi: apakah mau pakai RTP atau tidak?
  CLEAR: V_USE_RTP.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Confirmation'
      TEXT_QUESTION         = 'Apakah roll ini akan di-packing menggunakan RTP?'
      TEXT_BUTTON_1         = 'Ya'
      TEXT_BUTTON_2         = 'Tidak'
      DEFAULT_BUTTON        = '2'
      DISPLAY_CANCEL_BUTTON = 'X'
    IMPORTING
      ANSWER                = V_USE_RTP.

  IF V_USE_RTP EQ '1'.
    " Don't exit
  ELSEIF V_USE_RTP EQ '2'.
    " Exit, but HU still created
    EXIT.
  ELSE.
    " Exit, cancel process
    V_MSG = 'Batal memproses Pallet ID...!'.
    MESSAGE V_MSG TYPE 'I'.
    FCN_ERRNO = 4.
    EXIT.
  ENDIF.
  " End added by William at 21.01.2026 (validasi baru)

  CLEAR: ZSVAL.
  ZSVAL-TABNAME   = 'MCHB'.
  ZSVAL-FIELDNAME = 'CHARG'.  "V_PALID.
  ZSVAL-FIELDTEXT = 'Pallet ID'.
  APPEND ZSVAL.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK  = ' '
      POPUP_TITLE     = 'Masukkan nomor Pallet'
      START_COLUMN    = '5'
      START_ROW       = '5'
    IMPORTING
      RETURNCODE      = V_ANSWER
    TABLES
      FIELDS          = ZSVAL
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.

  IF SY-SUBRC <> 0.
    MESSAGE 'Gagal periksa, silahkan ulangi lagi.' TYPE 'I'.
    FCN_ERRNO = 4.
    EXIT.
  ENDIF.

  CONDENSE ZSVAL-VALUE.

  IF V_ANSWER = 'A' .
    FCN_ERRNO = 4.
    EXIT.
  " Modified by William at 21.01.2026 (perbaikan baca pallet ID)
*  ELSEIF ZSVAL-VALUE+6(1) EQ ''.
*    MESSAGE 'ID Pallet Tidak Boleh Kosong kurang 3 digit' TYPE 'I'.
*    FCN_ERRNO = 4.
*    EXIT.
  ELSE.
    DATA: V_INPLNG TYPE I.
    V_INPLNG = STRLEN( ZSVAL-VALUE ).
    IF V_INPLNG < 3.
      MESSAGE 'ID Pallet Tidak Boleh Kosong kurang 3 digit' TYPE 'I'.
      FCN_ERRNO = 4.
      EXIT.
    ENDIF.
  " End modified by William at 21.01.2026 (perbaikan baca pallet ID)

    CONCATENATE '%' ZSVAL-VALUE INTO ZSVAL-VALUE.

    " Modified by William at 21.01.2026 (perbaikan get pallet ID)
    SELECT MCH1~CHARG MARA~MATNR MAKT~MAKTX INTO TABLE IT_PALID "Change for New Company
        FROM MCH1 JOIN MCHB ON MCH1~MATNR = MCHB~MATNR AND MCH1~CHARG = MCHB~CHARG
          JOIN MARA ON MCH1~MATNR = MARA~MATNR
          JOIN MAKT ON MARA~MATNR = MAKT~MATNR
        WHERE MCH1~CHARG LIKE ZSVAL-VALUE
          AND MCHB~WERKS = HUPAST_T-PLANT
          AND MARA~MATKL IN ('900001','900003')
          AND MARA~MATNR = GWA_PC_PALLET-MATNR
          AND MARA~MTART = 'ZRTP'.
    " End modified by William at 21.01.2026 (perbaikan get pallet ID)

    IF SY-SUBRC EQ 0.
      LOOP AT IT_PALID.  "delete PALID in Use
        SELECT SINGLE PALID INTO V_PALID FROM ZPALLETR WHERE PALID = IT_PALID-PALID AND STATUS IN ('P','E').
        IF SY-SUBRC = 0.
          DELETE IT_PALID WHERE PALID = IT_PALID-PALID.
        ENDIF.
      ENDLOOP.
      READ TABLE IT_PALID INDEX 1.
      IF SY-SUBRC NE 0.
        V_MSG = 'Pallet ID sedang digunakan...!'.
        MESSAGE V_MSG TYPE 'I'.
        FCN_ERRNO = 4.
        EXIT.
      ENDIF.
    ELSE.
      CONCATENATE 'Pallet ID ' V_PALID 'untuk material packing' GWA_PC_PALLET-MATNR 'tidak ditemukan..!' INTO V_MSG SEPARATED BY SPACE.
      MESSAGE V_MSG TYPE 'I'.
      FCN_ERRNO = 4.
      EXIT.
    ENDIF.

*- add by ALF for new PALID code
    " Modified by William at 21.01.2026 (perbaikan baca pallet ID)
*    LOOP AT IT_PALID.
*      IT_PALID2-PALID = IT_PALID-PALID.
*      APPEND IT_PALID2.
*      V_PALID = IT_PALID-PALID.
*    ENDLOOP.
*
*    READ TABLE IT_PALID2 INDEX 2.
*    IF SY-SUBRC NE 0.
*      EXIT.
*    ENDIF.

    CLEAR: IT_PALID2.
    REFRESH: IT_PALID2.
    LOOP AT IT_PALID.
      IT_PALID2-PALID = IT_PALID-PALID.
      IT_PALID2-SEPARATOR1 = ' - '.
      IT_PALID2-MATNR = IT_PALID-MATNR.
      IT_PALID2-SEPARATOR2 = ' - '.
      IT_PALID2-MAKTX = IT_PALID-MAKTX.
      APPEND IT_PALID2.
      V_PALID = IT_PALID-PALID.
    ENDLOOP.

    IF IT_PALID2[] IS INITIAL.
      EXIT.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM IT_PALID2 COMPARING ALL FIELDS.

    CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
      EXPORTING
        STARTPOS_COL = 10
*        ENDPOS_COL   = 30
        ENDPOS_COL   = 85
        STARTPOS_ROW = 5
        ENDPOS_ROW   = 12
        TITLETEXT    = 'Pilih pallet ID'
      IMPORTING
        CHOISE       = V_SELE
      TABLES
        VALUETAB     = IT_PALID2
      EXCEPTIONS
        BREAK_OFF    = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
    " End modified by William at 21.01.2026 (perbaikan baca pallet ID)

    CLEAR: IT_PALID2, V_PALID.
    READ TABLE IT_PALID2 INDEX V_SELE.
    V_PALID = IT_PALID2-PALID.

    IF SY-SUBRC NE 0.
      V_MSG = 'Batal memasukkan Pallet ID...!'.
      MESSAGE V_MSG TYPE 'I'.
      FCN_ERRNO = 4.
      EXIT.
    ENDIF.
*- end of add by ALF for new PALID code


*    V_PALID = ZSVAL-VALUE.
*- update for RTS
    IF SY-TCODE = 'ZHU5FSR'.
      SELECT SINGLE * INTO V_MCHB FROM MCHB WHERE CHARG = V_PALID AND WERKS = HUPAST_T-PLANT AND CEINM > 0.
    ELSE.
      SELECT SINGLE * INTO V_MCHB FROM MCHB WHERE CHARG = V_PALID AND WERKS = HUPAST_T-PLANT AND CLABS > 0.
    ENDIF.

    IF SY-SUBRC NE 0.
      CONCATENATE 'Pallet ID ' V_PALID 'tidak ditemukan..!' INTO V_MSG SEPARATED BY SPACE.
      MESSAGE V_MSG TYPE 'I'.
      FCN_ERRNO = 4.
      EXIT.
    ELSEIF V_MCHB-LGORT = '1212'.
      MESSAGE 'Pallet sedang ada di customer...!'  TYPE 'I'.
      FCN_ERRNO = 4.
      EXIT.
    ELSE.  "cek sudah terikat HU
      SELECT SINGLE * INTO IT_HUPALLET FROM ZPALLETR WHERE PALID = V_PALID AND STATUS = 'P' AND WERKS1 = HUPAST_T-PLANT.
      IF SY-SUBRC = 0.
        CONCATENATE 'Pallet ID ' V_PALID 'sudah di packing di HU' IT_HUPALLET-EXIDV INTO V_MSG SEPARATED BY SPACE.
        MESSAGE V_MSG TYPE 'I'.
        FCN_ERRNO = 4.
        EXIT.
      ENDIF.

*- cek werks
      IF V_MCHB-WERKS NE HUPAST_T-PLANT.
        CONCATENATE 'Pallet ID ' V_PALID 'tidak ada di plant' HUPAST_T-PLANT INTO V_MSG SEPARATED BY SPACE.
        MESSAGE V_MSG TYPE 'I'.
        FCN_ERRNO = 4.
        EXIT.
      ENDIF.

      " Added by William at 21.01.2026 (validasi baru)
*- cek lgort (sloc)
      IF V_MCHB-LGORT NE HUPAST_T-STGE_LOC.
        CONCATENATE 'Pallet ID ' V_PALID 'tidak ada di sloc' HUPAST_T-STGE_LOC INTO V_MSG SEPARATED BY SPACE.
        MESSAGE V_MSG TYPE 'I'.
        FCN_ERRNO = 4.
        EXIT.
      ENDIF.
      " End added by William at 21.01.2026 (validasi baru)
    ENDIF.
  ENDIF.
ENDFORM.                    "cek_so_palid


*&---------------------------------------------------------------------*
*&      Form  insert_palid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_PALID.  " insert HU to table ZPALLETR
  IF V_PALID = ''.
    EXIT.
  ENDIF.

  CLEAR: IT_HUPALLET.
  SELECT MAX( DOCNO ) INTO IT_HUPALLET-DOCNO FROM ZPALLETR.
  IF SY-SUBRC NE 0.
    MESSAGE 'Gagal update data pallet plastik, silahkan hubungi Admin' TYPE 'O'.
    EXIT.
  ENDIF.
  IT_HUPALLET-DOCNO = IT_HUPALLET-DOCNO + 1.
  IT_HUPALLET-PALID = V_PALID.
  IT_HUPALLET-EXIDV = GS_EXIDV_PALLET.
  IT_HUPALLET-STATUS = 'P'.
  IT_HUPALLET-WERKS1 = HUPAST_T-PLANT.
  MODIFY ZPALLETR FROM IT_HUPALLET.
  COMMIT WORK.
ENDFORM.                    "insert_palid

*&---------------------------------------------------------------------*
*&      Form  unpack_palid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UNPACK_PALID.
  " Added by William at 23.02.2026 (update pallet status for ZHU5FS - Unpack Pallet RTP)
  DATA: LT_STATUS LIKE ZMAP_TYPE-TEXT2.
  DATA: IT_ZPALLETR LIKE ZPALLETR OCCURS 0 WITH HEADER LINE.
  DATA: WA_HUPALLET LIKE LINE OF IT_ZPALLETR.
  DATA: IT_ERROR_PALLET TYPE ESP1_MESSAGE_TAB_TYPE.
  DATA: WA_ERROR_PALLET LIKE LINE OF IT_ERROR_PALLET.

  DATA: GMHEAD LIKE BAPI2017_GM_HEAD_01.
  DATA: GMCODE LIKE BAPI2017_GM_CODE.
  DATA  MATDOC TYPE BAPI2017_GM_HEAD_RET-MAT_DOC.
  DATA: IT_GOODSMVT_ITEM LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE.
  DATA: IT_RETURN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.
  " End added by William at 23.02.2026 (update pallet status for ZHU5FS - Unpack Pallet RTP)

  CLEAR: IT_HUPALLET.

  " Added by William at 23.02.2026 (update pallet status for ZHU5FS - Unpack Pallet RTP)
  CASE OK_CODE.
    WHEN 'UNPALLET' OR 'UNPACK'.
      IF SY-TCODE = 'ZHU5SO' OR SY-TCODE = 'ZHU5FS'.
        CLEAR: IT_ERROR_PALLET.
        REFRESH: IT_ERROR_PALLET.
        " Get destination pallet
        CLEAR: V_WERK2_UNPALLET, V_LGOR2_UNPALLET.
        SELECT SINGLE WERK2 LGOR2 INTO (V_WERK2_UNPALLET, V_LGOR2_UNPALLET)
          FROM ZHU_MAPP
          WHERE TYPES = '11'
          AND   WERK1 = V_WERK1_UNPALLET
          AND   LGOR1 = V_LGOR1_UNPALLET.

        IF SY-SUBRC EQ 0.
          CLEAR: IT_ZPALLETR.
          REFRESH: IT_ZPALLETR.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ZPALLETR
            FROM ZPALLETR
            WHERE EXIDV = HUKEY
            AND STATUS = 'P'.

          IF SY-SUBRC EQ 0.
            " Move Pallet
            LOOP AT IT_ZPALLETR.
              CLEAR: GMHEAD, GMCODE, MATDOC, IT_GOODSMVT_ITEM, IT_RETURN.
              REFRESH: IT_GOODSMVT_ITEM, IT_RETURN.

              " Set data header
              GMHEAD-DOC_DATE   = SY-DATUM.
              GMHEAD-PSTNG_DATE = SY-DATUM.
              GMHEAD-PR_UNAME   = SY-UNAME.
              GMCODE-GM_CODE    = '04'.   "04 - MB1B - Transfer Posting

              " Mvt Pallet
              IT_GOODSMVT_ITEM-MOVE_TYPE  = '311'.

              " Material
              SELECT SINGLE MATNR INTO IT_GOODSMVT_ITEM-MATERIAL
                FROM MCH1
                WHERE CHARG = IT_ZPALLETR-PALID.

              " UoM
              SELECT SINGLE MEINS INTO IT_GOODSMVT_ITEM-ENTRY_UOM FROM MARA WHERE MATNR = IT_GOODSMVT_ITEM-MATERIAL.

              " Plant Asal/PLANT dan Sloc Asal/STGE_LOC
              SELECT SINGLE WERKS LGORT INTO (IT_GOODSMVT_ITEM-PLANT, IT_GOODSMVT_ITEM-STGE_LOC)
                FROM MCHB
                WHERE CHARG = IT_ZPALLETR-PALID
                AND CLABS > 0.

              " Plant Tujuan/MOVE_PLANT dan Sloc Tujuan/MOVE_STLOC
              IT_GOODSMVT_ITEM-MOVE_PLANT      = V_WERK2_UNPALLET.  "plant target.
              IT_GOODSMVT_ITEM-MOVE_STLOC      = V_LGOR2_UNPALLET.  "sloc target.

              " Data lain
              IT_GOODSMVT_ITEM-MVT_IND         = ' '.
              IT_GOODSMVT_ITEM-ENTRY_QNT       = '1'.  "itab_data-quant.
              IT_GOODSMVT_ITEM-BATCH           = IT_ZPALLETR-PALID.

              APPEND IT_GOODSMVT_ITEM.
              CLEAR IT_GOODSMVT_ITEM.

              " Execute good movement pallet
              CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                EXPORTING
                  GOODSMVT_HEADER  = GMHEAD
                  GOODSMVT_CODE    = GMCODE
                IMPORTING
                  MATERIALDOCUMENT = MATDOC
                TABLES
                  GOODSMVT_ITEM    = IT_GOODSMVT_ITEM
                  RETURN           = IT_RETURN.

              READ TABLE IT_RETURN WITH KEY TYPE = 'E'.
              IF SY-SUBRC NE 0.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

                " Update status pallet
                " 1. Copy data pallet
                CLEAR: WA_HUPALLET.
                MOVE-CORRESPONDING IT_ZPALLETR TO WA_HUPALLET.
                WA_HUPALLET-WERKS3 = V_WERK2_UNPALLET.
                WA_HUPALLET-LGORT3 = V_LGOR2_UNPALLET.
                WA_HUPALLET-ERDAT3 = SY-DATUM.

                " 2. Check mapping status
                SELECT SINGLE TEXT2 INTO LT_STATUS
                  FROM ZMAP_TYPE
                  WHERE DELETION NE 'X'
                  AND TCODE = SY-TCODE
                  AND TYPE = 'PALLET'
                  AND OPT = 'STATUS'
                  AND TEXT1 = V_LGOR2_UNPALLET.

                IF SY-SUBRC EQ 0.
                  WA_HUPALLET-STATUS = LT_STATUS.
                ELSE.
                  WA_HUPALLET-STATUS = 'L'.
                ENDIF.

                " 3. Update data pallet
                UPDATE ZPALLETR FROM WA_HUPALLET.
                COMMIT WORK.
              ELSE.
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

                CLEAR: WA_ERROR_PALLET.
                READ TABLE IT_RETURN WITH KEY TYPE = 'E'.
                CONCATENATE 'Error, transfer pallet' IT_ZPALLETR-PALID 'gagal:' INTO WA_ERROR_PALLET-MSGV1 SEPARATED BY SPACE.
                WA_ERROR_PALLET-MSGV2 = IT_RETURN-MESSAGE.

                WA_ERROR_PALLET-MSGTY = 'E'.   " Error
                WA_ERROR_PALLET-MSGID = '00'.
                WA_ERROR_PALLET-MSGNO = '001'.

                APPEND WA_ERROR_PALLET TO IT_ERROR_PALLET.
                CLEAR: WA_ERROR_PALLET.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
*      ELSEIF SY-TCODE = 'ZHU5SO'.
*        SELECT SINGLE * INTO IT_HUPALLET FROM ZPALLETR WHERE EXIDV = HUKEY AND STATUS = 'P'.
*        IF SY-SUBRC = 0.
*          IT_HUPALLET-STATUS = 'L'.
*          IT_HUPALLET-WERKS3 = V_WERK2_UNPALLET.
*          IT_HUPALLET-LGORT3 = V_LGOR2_UNPALLET.
*          IT_HUPALLET-ERDAT3 = SY-DATUM.
*          UPDATE ZPALLETR FROM IT_HUPALLET.
*          COMMIT WORK.
*        ENDIF.
      ENDIF.
    WHEN OTHERS.
      SELECT SINGLE * INTO IT_HUPALLET FROM ZPALLETR WHERE EXIDV = HUKEY AND STATUS = 'P'.
      IF SY-SUBRC = 0.
        IT_HUPALLET-STATUS = 'L'.
        IT_HUPALLET-WERKS3 = V_WERK2_UNPALLET.
        IT_HUPALLET-LGORT3 = V_LGOR2_UNPALLET.
        IT_HUPALLET-ERDAT3 = SY-DATUM.
        UPDATE ZPALLETR FROM IT_HUPALLET.
        COMMIT WORK.
      ENDIF.
  ENDCASE.

  IF IT_ERROR_PALLET[] IS NOT INITIAL.
    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        I_MESSAGE_TAB = IT_ERROR_PALLET.
  ENDIF.
  " End added by William at 23.02.2026 (update pallet status for ZHU5FS - Unpack Pallet RTP)

  " Remarked by William at 23.02.2026 (update pallet status for ZHU5FS - Unpack Pallet RTP)
*  CLEAR: IT_HUPALLET.
*  SELECT SINGLE * INTO IT_HUPALLET FROM ZPALLETR WHERE EXIDV = HUKEY AND STATUS = 'P'.
*  IF SY-SUBRC = 0.
*    IT_HUPALLET-STATUS = 'L'.
*    UPDATE ZPALLETR FROM IT_HUPALLET.
*    COMMIT WORK.
*  ENDIF.
  " End remarked by William at 23.02.2026 (update pallet status for ZHU5FS - Unpack Pallet RTP)
ENDFORM.                    "unpack_palid


*&---------------------------------------------------------------------*
*&      Form  GET_HUPLANT
*&---------------------------------------------------------------------*
*       text New company
*----------------------------------------------------------------------*
FORM GET_HUPLANT USING VEXIDV.
  DATA: IT_VEPO LIKE VEPOVB OCCURS 0,
        IT_EXIDV TYPE HUM_EXIDV_T,
        WA_VEPO LIKE VEPOVB OCCURS 0 WITH HEADER LINE.

  CLEAR: IT_EXIDV, IT_VEPO, WA_VEPO.
  REFRESH: IT_EXIDV, IT_VEPO, WA_VEPO.

  APPEND VEXIDV TO IT_EXIDV.

  CALL FUNCTION 'HU_GET_HUS_DB'
    EXPORTING
      IT_HU_NUMBERS = IT_EXIDV
    IMPORTING
*     ET_HU_HEADER  =
      ET_HU_ITEMS   = IT_VEPO.

  LOOP AT IT_VEPO INTO WA_VEPO WHERE CHARG IS NOT INITIAL.
  ENDLOOP.

  IF WA_VEPO-WERKS EQ '1000' OR WA_VEPO-WERKS EQ '2000'.
  ELSE.
    MESSAGE 'HU Bukan Milik Plant TRIAS' TYPE 'I'.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDFORM.                    "GET_HUPLANT


*&---------------------------------------------------------------------*
*&      Form  f_udate_pass
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_UPDATE_PASS.
  DATA: WA_ZQM001 LIKE ZQM001.
  SELECT SINGLE EXIDV INTO WA_ZQM001-EXIDV
    FROM ZQM001
    WHERE EXIDV = GS_EXIDV_PALLET.

  IF SY-SUBRC EQ 0.
    EXIT.
  ENDIF.

  WA_ZQM001-EXIDV  = GS_EXIDV_PALLET.
  WA_ZQM001-PSTAT  = 'P'.
  WA_ZQM001-AEDAT  = SY-DATUM.
  WA_ZQM001-AETIME = SY-UZEIT.
  WA_ZQM001-NIK = '9999'.
  CONCATENATE SY-UNAME 'by T-code:' SY-TCODE INTO WA_ZQM001-NOTE SEPARATED BY SPACE.

  CLEAR : WA_ZQM001-SEQ.
  SELECT MAX( SEQ )
  INTO WA_ZQM001-SEQ
  FROM ZQM001.

  IF SY-SUBRC <> 0.
    WA_ZQM001-SEQ = 1.
  ELSE.
    WA_ZQM001-SEQ = WA_ZQM001-SEQ + 1.
  ENDIF.

  INSERT INTO ZQM001 VALUES WA_ZQM001.
  COMMIT WORK AND WAIT.
ENDFORM.                    "f_udate_pass