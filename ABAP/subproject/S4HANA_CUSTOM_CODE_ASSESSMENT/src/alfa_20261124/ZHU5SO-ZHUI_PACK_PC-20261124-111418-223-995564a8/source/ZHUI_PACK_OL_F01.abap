*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACK_OL_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  get_packing_instructions
*&---------------------------------------------------------------------*
FORM GET_PACKING_INSTRUCTIONS .
  DATA : TMP  LIKE HU_TMP OCCURS 2 WITH HEADER LINE,
         FLAG.

  SELECT * FROM ZPACK WHERE VBELN = ZPACK00-VBELN
                        AND POSNR = ZPACK00-POSNR.

    IF ZPACK-ZMENG IS INITIAL.
      REFRESH HU_TMP.
      CLEAR HU_TMP.

      D_FATALERR = 'X'.
      EXIT.
    ENDIF.

    HU_TMP-POSNR = ZPACK-POSNR.
    HU_TMP-INS0  = ZPACK-ZINS01.
    HU_TMP-INS1  = ZPACK-ZINS02.
    HU_TMP-INS2  = ZPACK-ZINS03.
    HU_TMP-INST  = ZPACK-MATNR.
    HU_TMP-ZMENG = ZPACK-ZMENG.
    HU_TMP-STAT  = SPACE.

    APPEND HU_TMP.
  ENDSELECT.

  IF D_FATALERR IS NOT INITIAL.
    MESSAGE I000(0K) WITH
      '* Incomplete Packing Instruction for SONUM =' GSONUM.

    RETURN.
  ENDIF.

  CHECK NOT HU_TMP[] IS INITIAL.
  SORT HU_TMP.
  TMP[]  = HU_TMP[].

* Generate Packing Instructions
  LOOP AT HU_TMP WHERE INS1 = 0 AND INS2 = 0.
*   Check for 3rd level
    CLEAR FLAG.
    LOOP AT TMP WHERE POSNR = HU_TMP-POSNR
                  AND INS0  = HU_TMP-INS0
                  AND INS1  NE 0
                  AND INS2  = 0.
      FLAG = 'X'.
    ENDLOOP.

    IF FLAG = 'X'.
      PERFORM INSERT_FOR_3LEVEL.
    ELSE.
*     Check for 2nd level
      LOOP AT TMP WHERE POSNR = HU_TMP-POSNR
                    AND INS0  = HU_TMP-INS0
                    AND INS1  NE 0
                    AND INS2  NE 0.
        FLAG = 'X'.
      ENDLOOP.

      IF FLAG = 'X'.
        PERFORM INSERT_FOR_2LEVEL.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Insert from insertion table
  IF NOT HU_NEU[] IS INITIAL.
    INSERT LINES OF HU_NEU INTO TABLE HU_COM.
  ENDIF.

  LOOP AT HU_COM.
*   Put leading zero for sorting purpose
    VINS0 = HU_COM-INS0.
    VINS1 = HU_COM-INS1.
    VINS2 = HU_COM-INS2.
    HU_COM-INS0 = VINS0.
    HU_COM-INS1 = VINS1.
    HU_COM-INS2 = VINS2.
    IF HU_COM-INS1 = 0.
      CLEAR HU_COM-INS1.
    ENDIF.
    IF HU_COM-INS2 = 0.
      CLEAR HU_COM-INS2.
    ENDIF.
    MODIFY HU_COM INDEX SY-TABIX.
  ENDLOOP.
  SORT HU_COM.

ENDFORM.                    " get_packing_instructions

*&---------------------------------------------------------------------*
*&      Form  read_characteristics
*&---------------------------------------------------------------------*
FORM READ_CHARACTERISTICS
  CHANGING P_TAB STRUCTURE ZPACK00.
  TABLES : CABN, AUSP.
  DATA : BEGIN OF KY OCCURS 2,
           NAME LIKE BAPI_CHAR-NAME_CHAR,
         END OF KY.
  DATA : VCHAR LIKE AUSP-ATWRT,
         VNUM  TYPE I,
         VDEC  TYPE P DECIMALS 2,
         I_CLASS LIKE KLAH-CLASS,
         TCHAR   LIKE BAPI_CHAR OCCURS 2 WITH HEADER LINE,
         TVAL    LIKE BAPI_CHAR_VALUES OCCURS 2 WITH HEADER LINE,
         OBJEK   LIKE MCH1-CUOBJ_BM,
         TABIX   LIKE SY-TABIX,
         VATINN  LIKE CABN-ATINN.

  KY-NAME = 'ZZALIAS'.     APPEND KY.
  KY-NAME = 'ZZWIDTH'.     APPEND KY.
  KY-NAME = 'ZZLENGTH'.    APPEND KY.
  KY-NAME = 'ZZINSIDE'.    APPEND KY.
  KY-NAME = 'ZZOUTSIDE'.   APPEND KY.
  KY-NAME = 'ZZCORE'.      APPEND KY.
  KY-NAME = 'ZZCRITERIA'.  APPEND KY.

  SELECT SINGLE CUOBJ_BM FROM MCH1 INTO OBJEK
              WHERE MATNR = P_TAB-MATNR0         "mska-matnr
                AND CHARG = P_TAB-CHARG(10).

  CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
    EXPORTING
      I_MATNR                = P_TAB-MATNR0
      I_CHARG                = P_TAB-CHARG(10)
      I_MARA_LEVEL           = 'X'
    IMPORTING
      E_CLASS                = I_CLASS
    EXCEPTIONS
      NO_CLASS               = 1
      INTERNAL_ERROR_CLASSIF = 2
      NO_CHANGE_SERVICE      = 3
      OTHERS                 = 4.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    CLEAR P_TAB.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_CLASS_GET_CHARACTERISTICS'
    EXPORTING
      CLASSNUM        = I_CLASS
      CLASSTYPE       = '023'
    TABLES
      CHARACTERISTICS = TCHAR
      CHAR_VALUES     = TVAL.

  LOOP AT KY.
    TABIX = SY-TABIX.
    CLEAR VCHAR.
    READ TABLE TCHAR WITH KEY NAME_CHAR = KY-NAME.

*   Read attin nr.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = KY-NAME
      IMPORTING
        OUTPUT = VATINN.

    SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATINN = VATINN
                                                    AND ADZHL = 0.
    IF SY-SUBRC = 0.
*     Read charateristic value
      SELECT SINGLE * FROM AUSP WHERE OBJEK = OBJEK
                                  AND ATINN = CABN-ATINN
                                  AND KLART = '023'.
      IF  SY-SUBRC = 0.
        IF AUSP-ATWRT NE SPACE.
          VCHAR = AUSP-ATWRT.
        ELSE.
          IF TCHAR-DATA_TYPE = 'NUM' AND TCHAR-NUMBER_DECIMALS > 0.
            VDEC = AUSP-ATFLV.
            WRITE VDEC TO VCHAR.
          ELSE.
            VNUM  = AUSP-ATFLV.
            WRITE VNUM TO VCHAR.
          ENDIF.
          CONDENSE VCHAR.
        ENDIF.
      ENDIF.
    ENDIF.

*   Get Description value if any
    READ TABLE TVAL WITH KEY NAME_CHAR  = KY-NAME
                             CHAR_VALUE = VCHAR.
    IF SY-SUBRC = 0 AND TVAL-DESCR_CVAL NE SPACE.
      VCHAR = TVAL-DESCR_CVAL.
    ENDIF.

    CASE TABIX.
      WHEN 1.
        P_TAB-CHAR01 = VCHAR.
        IF P_TAB-CHAR01 IS INITIAL.
          SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZTYPE'.
          CHECK SY-SUBRC = 0.
          SELECT SINGLE * FROM AUSP WHERE OBJEK = OBJEK
                                      AND ATINN = CABN-ATINN
                                      AND KLART = '023'.
          CHECK SY-SUBRC = 0.
          VCHAR = AUSP-ATWRT.
          READ TABLE TVAL WITH KEY NAME_CHAR  = KY-NAME
                                   CHAR_VALUE = VCHAR.
          IF SY-SUBRC = 0 AND TVAL-DESCR_CVAL NE SPACE.
            VCHAR = TVAL-DESCR_CVAL.
          ENDIF.
          P_TAB-CHAR01 = VCHAR.

          SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZTHICKNESS'.
          CHECK SY-SUBRC = 0.
          SELECT SINGLE * FROM AUSP WHERE OBJEK = OBJEK
                                      AND ATINN = CABN-ATINN
                                      AND KLART = '023'.
          CHECK SY-SUBRC = 0.
          VDEC  = AUSP-ATFLV.
          VCHAR = VDEC.
          CONDENSE VCHAR.
          READ TABLE TVAL WITH KEY NAME_CHAR  = KY-NAME
                                   CHAR_VALUE = VCHAR.
          IF SY-SUBRC = 0 AND TVAL-DESCR_CVAL NE SPACE.
            VCHAR = TVAL-DESCR_CVAL.
          ENDIF.
          IF VCHAR NE SPACE.
            CONCATENATE P_TAB-CHAR01 '-' VCHAR INTO P_TAB-CHAR01
                                                 SEPARATED BY SPACE.
          ENDIF.
        ENDIF.
      WHEN 2.
        P_TAB-CHAR02 = VCHAR.
      WHEN 3.
        P_TAB-CHAR03 = VCHAR.
      WHEN 4.
        P_TAB-CHAR04 = VCHAR.
      WHEN 5.
        P_TAB-CHAR05 = VCHAR.
      WHEN 6.
        P_TAB-CHAR06 = VCHAR.
      WHEN 7.
        P_TAB-CHAR07 = VCHAR.
*       IF ausp-atwrt(1) = 'R' OR ausp-atwrt(1) = 'S'.
*        IF ausp-atwrt(1) NE '1' AND vbak-auart(3) NE 'ZDM'.
*          MESSAGE e000(0k) WITH '* Only 1st Grade Can be Packed !'.
*        ENDIF.
      WHEN 8.
        P_TAB-CHAR08 = VCHAR.
      WHEN 9.
        P_TAB-CHAR09 = VCHAR.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " read_characteristics

*&---------------------------------------------------------------------*
*&      Form  insert_for_2level
*&---------------------------------------------------------------------*
FORM INSERT_FOR_2LEVEL .
  DATA : TMP1 LIKE HU_TMP OCCURS 2 WITH HEADER LINE.

  TMP1[] = HU_TMP[].

* 1st Level
  DO HU_TMP-ZMENG TIMES.
    CTR1 = CTR1 + 1.
    HU_COM-POSNR = HU_TMP-POSNR.
    HU_COM-INS0  = CTR1.
    HU_COM-INS1  = HU_TMP-INS1.
    HU_COM-INS2  = HU_TMP-INS2.
    HU_COM-INST  = HU_TMP-INST.
    HU_COM-STAT  = SPACE.

    IF HU_COM-INS1 = 0.
      CLEAR HU_COM-INS1.
    ENDIF.
    IF HU_COM-INS2 = 0.
      CLEAR HU_COM-INS2.
    ENDIF.
    APPEND HU_COM.

    LOOP AT TMP1 WHERE POSNR = HU_TMP-POSNR
                   AND INS0  = HU_TMP-INS0
*                  AND ins1  NE 0
                   AND INS2  NE 0.
*     2nd Generation
      DO TMP1-ZMENG TIMES.
        CTR2 = CTR2 + 1.
        HU_COM-POSNR = HU_TMP-POSNR.
        HU_COM-INS0  = CTR1.
        HU_COM-INS1  = CTR2.
        HU_COM-INS2  = CTR3.
        HU_COM-INST  = TMP1-INST.

        HU_COM-STAT  = SPACE.
        IF HU_COM-INS1 = 0.
          CLEAR HU_COM-INS1.
        ENDIF.
        IF HU_COM-INS2 = 0.
          CLEAR HU_COM-INS2.
        ENDIF.
        APPEND HU_COM.
      ENDDO.
      CTR3 = 0.
    ENDLOOP.
    CTR2 = 0.
  ENDDO.

ENDFORM.                    " insert_for_2level

*&---------------------------------------------------------------------*
*&      Form  insert_for_3level
*&---------------------------------------------------------------------*
FORM INSERT_FOR_3LEVEL .
  DATA : TMP1 LIKE HU_TMP OCCURS 2 WITH HEADER LINE,
         TMP2 LIKE HU_TMP OCCURS 2 WITH HEADER LINE.

  TMP1[] = TMP2[] = HU_TMP[].

* 1st Level
  DO HU_TMP-ZMENG TIMES.
    CTR1 = CTR1 + 1.
    HU_COM-POSNR = HU_TMP-POSNR.
    HU_COM-INS0  = CTR1.
    HU_COM-INS1  = HU_TMP-INS1.
    HU_COM-INS2  = HU_TMP-INS2.
    HU_COM-INST  = HU_TMP-INST.

    HU_COM-STAT  = SPACE.
    IF HU_COM-INS1 = 0.
      CLEAR HU_COM-INS1.
    ENDIF.
    IF HU_COM-INS2 = 0.
      CLEAR HU_COM-INS2.
    ENDIF.
    CONDENSE : HU_COM-INS0, HU_COM-INS1, HU_COM-INS2.
    APPEND HU_COM.
    CLEAR HU_COM.

    LOOP AT TMP1 WHERE POSNR = HU_TMP-POSNR
                   AND INS0  = HU_TMP-INS0
                   AND INS1  NE 0
                   AND INS2  = 0.
*     2nd Generation
      DO TMP1-ZMENG TIMES.
        CTR2 = CTR2 + 1.
        HU_COM-POSNR = HU_TMP-POSNR.
        HU_COM-INS0  = CTR1.
        HU_COM-INS1  = CTR2.
*       hu_com-ins2  = ctr3.
        WRITE TMP1-INST TO HU_COM-INST.
        HU_COM-STAT  = SPACE.
        IF HU_COM-INS1 = 0.
          CLEAR HU_COM-INS1.
        ENDIF.
        IF HU_COM-INS2 = 0.
          CLEAR HU_COM-INS2.
        ENDIF.
        CONDENSE : HU_COM-INS0, HU_COM-INS1, HU_COM-INS2.
        APPEND HU_COM.
        CLEAR HU_COM.

        LOOP AT TMP2 WHERE POSNR = HU_TMP-POSNR
                       AND INS0  = HU_TMP-INS0
                       AND INS1  NE 0
                       AND INS2  NE 0.
          DO TMP2-ZMENG TIMES.
*           3rd Level
            CTR3 = CTR3 + 1.
            HU_COM-POSNR = HU_TMP-POSNR.
            HU_COM-INS0  = CTR1.
            HU_COM-INS1  = CTR2.
            HU_COM-INS2  = CTR3.
            HU_COM-INST  = TMP2-INST.
            HU_COM-STAT  = SPACE.
            IF HU_COM-INS1 = 0.
              CLEAR HU_COM-INS1.
            ENDIF.
            IF HU_COM-INS2 = 0.
              CLEAR HU_COM-INS2.
            ENDIF.
            CONDENSE : HU_COM-INS0, HU_COM-INS1, HU_COM-INS2.
            APPEND HU_COM.
            CLEAR HU_COM.
          ENDDO.
        ENDLOOP.
        CTR3 = 0.
      ENDDO.
*     ctr3 = 0.
    ENDLOOP.
    CTR2 = 0.
  ENDDO.

ENDFORM.                    " insert_for_3level


*&---------------------------------------------------------------------*
*&      Form  modify_screen
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN .

  LOOP AT SCREEN.
    SCREEN-INPUT = 1.
    SCREEN-COLOR = 4.
    IF ( SCREEN-NAME = 'ZPACK00-ZINS01' OR SCREEN-NAME = 'ZPACK00-ZINS02' OR
         SCREEN-NAME = 'ZPACK00-ZINS03' OR SCREEN-NAME = 'ZPACK00-MATNR'  OR
         SCREEN-NAME = 'ZPACK00-STAT' ).
      SCREEN-INPUT = 0.
    ENDIF.

    IF ( SCREEN-NAME = 'ZPACK00-EXIDV' OR SCREEN-NAME = 'ZPACK00-STAT' ).
      SCREEN-INPUT = 0.
    ENDIF.

*    IF ZPACK00-STAT = 'Cls'.
*      SCREEN-INTENSIFIED = 1.
*      IF GB_IS_NEW_BATCH = V_YES AND ZPACK00-PLSTAT NE C_HUSTAT_CLOSED
*        AND SCREEN-NAME = 'VSELEK'.
*        SCREEN-INPUT = 1.
*      ELSE.
*        SCREEN-INPUT = 0.
*      ENDIF.
*    ENDIF.

    IF ZPACK00-STAT = 'Pck' OR ZPACK00-STAT = 'Prt'.
      SCREEN-INTENSIFIED = 1.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.


ENDFORM.                    " modify_screen

***&---------------------------------------------------------------------*
***&      Form  hu_create
***&---------------------------------------------------------------------*
**FORM hu_create .
**
**  CHECK zpack00-exidv IS INITIAL.
**  CLEAR hdrproposal.
**  REFRESH retrn.
**  hdrproposal-hu_status_init = 'C'.
**  hdrproposal-pack_mat       = zpack00-matnr.
*** hdrproposal-ext_id_hu_2    =
**
**  CALL FUNCTION 'BAPI_HU_CREATE'
**    EXPORTING
**      headerproposal = hdrproposal
**    IMPORTING
**      huheader       = huhdr
**      hukey          = hukey
**    TABLES
**      return         = retrn.
**
**  IF hukey IS INITIAL.
**    READ TABLE retrn INDEX 1.
**    MESSAGE s000(0k) WITH retrn-message(50) retrn-message+50.
**    EXIT.
**  ENDIF.
**  read_idx = pagebegin + sy-stepl.
**  READ TABLE hu_com INDEX read_idx.
**  CHECK sy-subrc = 0.
**  hu_com-exid = hukey.
**  hu_com-stat = 'X'.
**  MODIFY hu_com INDEX read_idx.
**  CLEAR hu_hu.
**  MOVE-CORRESPONDING hu_com TO hu_hu.
**  hu_hu-exid = hukey.
**  APPEND hu_hu.
**  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
**  MESSAGE s000(0k) WITH '* Handling Unit Created.'.
**
**ENDFORM.                    " hu_create
*
*&---------------------------------------------------------------------*
*&      Form  hu_create_by_bdc
*&---------------------------------------------------------------------*
FORM HU_CREATE_BY_BDC .
  DATA : MSGS TYPE TABLE OF BDCMSGCOLL,
         WA   LIKE BDCMSGCOLL,
         NRIV TYPE  NRIV,
         LVL  LIKE INRI-NRRANGENR,
         FLD  LIKE HEADER51-PLANHU,
         RETURN TYPE BAPIHUKEY-HU_EXID.

  CHECK ZPACK00-EXIDV IS INITIAL.
  SELECT SINGLE MTART VHART INTO (MARA-MTART, MARA-VHART)
                      FROM MARA WHERE MATNR = ZPACK00-MATNR.
  IF MARA-MTART NE 'ZPCK' AND MARA-MTART NE 'ZRTP'.
    MESSAGE I000(0K) WITH '* Not a Packaging Material.'.
    EXIT.
  ENDIF.
  SET PARAMETER ID 'WRK' FIELD HUPAST_T-PLANT.
  SET PARAMETER ID 'LAG' FIELD HUPAST_T-STGE_LOC.
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
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.

    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
*    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
    PERFORM BDC_FIELD   USING 'V51VE-VHILM(01)' ZPACK00-MATNR.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=ENTR'.
  ELSE.
**   General Header Data
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6030TAB'.
    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'HEADER51-PLANHU'.
    PERFORM BDC_FIELD   USING 'HEADER51-PLANHU'         'C'.
    PERFORM BDC_FIELD   USING 'HUM_MM_KOPFDATEN-WERKS'  HUPAST_T-PLANT.
    PERFORM BDC_FIELD   USING 'HUM_MM_KOPFDATEN-LGORT'  HUPAST_T-STGE_LOC.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6ALLG'.
*   Entering packg matr
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.
*    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
    PERFORM BDC_FIELD   USING 'V51VE-VHILM(01)' ZPACK00-MATNR.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=ENTR'.
  ENDIF.
* Save
  PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
  'SAPLV51G                                6020TAB'.
*  PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=SICH'.
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'A'.
  OPT-DEFSIZE  = 'X'.
  OPT-NOBINPT  = 'X'.
  OPT-RACOMMIT = 'X'.
  CALL TRANSACTION 'HU02' USING BDCDATA OPTIONS FROM OPT MESSAGES INTO MSGS.

*  CALL TRANSACTION 'HU02' USING BDCDATA MODE 'E' UPDATE 'A'
*                                MESSAGES INTO MSGS.

  PERFORM PROCESS_DELAYING.

  IF MARA-VHART = '0003'.
    LVL = '01'.
  ELSE.
    LVL = '02'.
  ENDIF.
  READ TABLE MSGS INDEX 1 INTO WA.
  IF WA-TCODE = 'HU02' AND WA-MSGID = 'HUDIALOG' AND
     WA-MSGNR = '008'.
*   Get last number created
    CALL FUNCTION 'NUMBER_RANGE_GET_BUFFERED'
      EXPORTING
        NR_RANGE_NR        = LVL
        OBJECT             = 'HU_VEKP'
      IMPORTING
        E_NRIV             = NRIV
      EXCEPTIONS
        INTERVAL_NOT_FOUND = 1
        OBJECT_NOT_FOUND   = 2
        OTHERS             = 3.
    IF SY-SUBRC = 0.
      HUKEY = NRIV-NRLEVEL.
    ELSE.
      CLEAR HUKEY.
    ENDIF.
    READ_IDX = PAGEBEGIN + SY-STEPL.
    READ TABLE HU_COM INDEX READ_IDX.
    CHECK SY-SUBRC = 0.
    HU_COM-EXID = HUKEY.
    HU_COM-STAT = 'X'.
    MODIFY HU_COM INDEX READ_IDX.
    CLEAR HU_HU.
    MOVE-CORRESPONDING HU_COM TO HU_HU.
    HU_HU-EXID = HUKEY.
    APPEND HU_HU.
    MESSAGE S000(0K) WITH '* Handling Unit Created.'.
*   Entering Packing Instruction in the HU Header
    REFRESH RETRN.
*   CHECK NOT hukey IS INITIAL.
    PERFORM PROCESS_DELAYING.
    CLEAR HUHDR.
    HUHDR-CONTENT = HU_COM+6(9).

    CLEAR : RETURN.
    WHILE RETURN = ''.
      SELECT SINGLE EXIDV INTO RETURN
        FROM VEKP
        WHERE EXIDV = HUKEY.
    ENDWHILE.

    CALL FUNCTION 'BAPI_HU_CHANGE_HEADER'
      EXPORTING
        HUKEY     = HUKEY
        HUCHANGED = HUHDR
      TABLES
        RETURN    = RETRN.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  ELSE.
    MESSAGE I000(0K) WITH '* Creation Problem, Please Check/Create Again.'.
  ENDIF.

ENDFORM.                    " hu_create_by_bdc

*&---------------------------------------------------------------------*
*&      Form  hu_packing
*&---------------------------------------------------------------------*
FORM HU_PACKING .
  DATA : REC TYPE I,
         ERR.
  DATA LD_EXID TYPE EXIDV.

  LOOP AT HU_COM WHERE SELE = 'X'.
    CHECK HU_COM-EXID IS NOT INITIAL.
    CLEAR HU_PACK.
    HU_PACK-POSNR = HU_COM-POSNR.
    HU_PACK-INS0  = HU_COM-INS0.
    HU_PACK-INS1  = HU_COM-INS1.
    HU_PACK-INS2  = HU_COM-INS2.
    HU_PACK-INST  = HU_COM-INST.
    HU_PACK-EXID  = HU_COM-EXID.
    COLLECT HU_PACK.
  ENDLOOP.

  CHECK NOT HU_PACK[] IS INITIAL.
  DESCRIBE TABLE HU_PACK LINES REC.
  IF REC = 1.
    MESSAGE I000(0K) WITH '* Select Pallet and Box or Material'.
    REFRESH HU_PACK.
    EXIT.
  ENDIF.
  SORT HU_PACK.

  READ TABLE HU_PACK INDEX 1.

  IF HU_PACK-EXID+10(1) NE '6' AND HU_PACK-EXID+10(1) NE '1'.
    MESSAGE I000(0K) WITH '* Select Also a Line with HU Number.'.
    REFRESH HU_PACK.
    EXIT.

  ELSEIF HU_PACK-INS1 IS NOT INITIAL. "-- IT IS A BOX, CHECK PALLET
    READ TABLE HU_COM
      WITH KEY
        POSNR = HU_PACK-POSNR
        INS0 = HU_PACK-INS0
        INS1 = SPACE
        INS2 = SPACE
        EXID = SPACE.

    IF SY-SUBRC EQ 0.
      MESSAGE I000(0K) WITH '* No HU for pallet' HU_PACK-INS0.
      REFRESH HU_PACK.
      EXIT.

    ENDIF.

  ENDIF.

* Checking Batch Packed
  CLEAR ERR.
  LOOP AT HU_PACK.
    CHECK STRLEN( HU_PACK-EXID ) = 10.

    PERFORM F_GETEXIDBYBATCH
      USING HU_PACK-EXID
      CHANGING LD_EXID.

    IF LD_EXID IS NOT INITIAL.
      ERR = 'X'.
    ENDIF.

  ENDLOOP.

  IF ERR = 'X'.
    REFRESH HU_PACK.
  ENDIF.

  CHECK ERR IS INITIAL.
  CLEAR : ITMPROPOSAL, FLG.
  REFRESH : ITMPROPOSAL, RETRN.

* Entering packing items
  LOOP AT HU_PACK.
    CLEAR ITMPROPOSAL.
    IF SY-TABIX = 1.
      HUKEY = HU_PACK-EXID.
      CONTINUE.
    ENDIF.
    IF HU_PACK-INST = ZPACK00-MATNR1.
*     Comparing Characteristics Value
      IF NOT GCHAR IS INITIAL AND VBAK-AUART(3) NE 'ZDM'.
        IF CHR1ST-CHAR01 NE ZPACK00-CHAR01 OR CHR1ST-CHAR02 NE ZPACK00-CHAR02 OR
           CHR1ST-CHAR03 NE ZPACK00-CHAR03 OR CHR1ST-CHAR04 NE ZPACK00-CHAR04 OR
           CHR1ST-CHAR05 NE ZPACK00-CHAR05 OR CHR1ST-CHAR06 NE ZPACK00-CHAR06 OR
           CHR1ST-CHAR07 NE ZPACK00-CHAR07.
          MESSAGE S000(0K) WITH '* Can not be Packed for Different Characteristics.'.
          CLEAR FLG.
          ERR = 'X'.
          EXIT.
        ENDIF.
      ENDIF.

      PERFORM F_GET_SHEET CHANGING SHEET.

      ITMPROPOSAL-HU_ITEM_TYPE      = '1'.
      IF VBAK-AUART(3) = 'ZDM'.
        ITMPROPOSAL-MATERIAL        = ZPACK00-MATNR0.
      ELSE.
        ITMPROPOSAL-MATERIAL        = HU_PACK-INST.
      ENDIF.
*  Hardcode pack qty with '1 ROL'.
      ITMPROPOSAL-PACK_QTY          = '1'.
      IF SHEET = 'X'.
        ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'PAK'.
        ITMPROPOSAL-BASE_UNIT_QTY     = 'PAK'.
      ELSE.
        ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'ROL'.
        ITMPROPOSAL-BASE_UNIT_QTY     = 'ROL'.
      ENDIF.
*      itmproposal-pack_qty          = zpack00-zmeng.
*      itmproposal-base_unit_qty_iso = zpack00-meins.
*      itmproposal-base_unit_qty     = zpack00-meins.
      ITMPROPOSAL-BATCH             = HU_PACK-EXID.
      ITMPROPOSAL-PLANT             = HUPAST_T-PLANT.
      ITMPROPOSAL-STGE_LOC          = HUPAST_T-STGE_LOC.
      ITMPROPOSAL-SPEC_STOCK        = 'E'.
      ITMPROPOSAL-SP_STCK_NO        = GSONUM.
    ELSE.
      ITMPROPOSAL-HU_ITEM_TYPE      = '3'.
      ITMPROPOSAL-LOWER_LEVEL_EXID  = HU_PACK-EXID.
      ITMPROPOSAL-SP_STCK_NO        = GSONUM.
    ENDIF.
*   APPEND itmproposal.
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
      MESSAGE S000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
      ERR = 'X'.
      EXIT.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    IF C_USEMIRROR IS NOT INITIAL.
      CLEAR IT_EXIDV.
      IT_EXIDV-EXIDV = HUHDR-HU_EXID.
      IT_EXIDV-CHARG = HU_PACK-EXID.
      INSERT TABLE IT_EXIDV.
    ENDIF.

*   CALL FUNCTION 'RZL_SLEEP'.
    PERFORM PROCESS_DELAYING.
    MESSAGE S000(0K) WITH '* HU' HUKEY 'Packed.'.
*   Keep First Packed Characteristics
    IF GCHAR IS INITIAL.
      CHR1ST-MATNR0 = ZPACK00-MATNR0.
      CHR1ST-MATNR1 = ZPACK00-MATNR1.
      CHR1ST-CHARG  = ZPACK00-CHARGDC.
      PERFORM READ_CHARACTERISTICS CHANGING CHR1ST.
      GCHAR = 'X'.
    ENDIF.
  ENDLOOP.
  IF ERR = 'X'.
    REFRESH HU_PACK.
  ENDIF.
  CHECK ERR IS INITIAL.
* Delete HU itab
  LOOP AT HU_PACK.
    READ TABLE HU_HU WITH KEY EXID = HU_PACK-EXID.
    IF SY-SUBRC = 0.
      DELETE HU_HU INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.
* Update Status
  LOOP AT HU_PACK.
    READ TABLE HU_COM
      WITH KEY
        POSNR = HU_PACK-POSNR
        INS0 = HU_PACK-INS0
        INS1 = HU_PACK-INS1
        INS2 = HU_PACK-INS2
        INST = HU_PACK-INST
        EXID = HU_PACK-EXID.
    CHECK SY-SUBRC = 0.
    HU_COM-STAT = 'Pck'.
    MODIFY HU_COM INDEX SY-TABIX.
  ENDLOOP.
  REFRESH HU_PACK.

ENDFORM.                    " hu_packing

*&---------------------------------------------------------------------*
*&      Form  hu_close
*&---------------------------------------------------------------------*
FORM HU_CLOSE.
  DATA : MSGS TYPE TABLE OF BDCMSGCOLL,
         WA   LIKE BDCMSGCOLL,
         CLFLAG.

  IF ZPACK00-ZINS02 NE 0 OR ZPACK00-ZINS03 NE 0.
    MESSAGE I000(0K) WITH '* Only Pallet Can be Closed.'.
    EXIT.
  ENDIF.

  IF ZPACK00-EXIDV = SPACE.
    MESSAGE I000(0K) WITH '* No Handling Unit.'.
    EXIT.
  ENDIF.

  CLEAR CLFLAG.
  PERFORM CLOSE_STATUS USING ZPACK00-EXIDV CHANGING CLFLAG.
  IF CLFLAG = 'X'.
    MESSAGE I000(0K) WITH '* HU Already Closed.'.
    EXIT.
  ENDIF.

  SET PARAMETER ID 'WRK' FIELD HUPAST_T-PLANT.
  SET PARAMETER ID 'LAG' FIELD HUPAST_T-HU_STGE_LOC.

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
  PERFORM BDC_FIELD   USING 'LEMOVHUS-LGORT'  HUPAST_T-HU_STGE_LOC.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-HUWBEVENT'  '0006'.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-EXIDV'       ZPACK00-EXIDV.
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

  CALL TRANSACTION 'VLMOVE' USING BDCDATA MODE 'E' UPDATE 'A'
                                  MESSAGES INTO MSGS.
  READ TABLE MSGS INDEX 1 INTO WA.
  IF SY-SUBRC = 0.
    MESSAGE S000(0K) WITH WA-MSGID WA-MSGNR WA-MSGV1 WA-MSGV2.
  ENDIF.
* Check whether VLMOVE succesfuly or not
  CLEAR CLFLAG.
  PERFORM CLOSE_STATUS USING ZPACK00-EXIDV CHANGING CLFLAG.
  IF CLFLAG = 'X'.
    LOOP AT HU_COM WHERE INS0 = ZPACK00-ZINS01.
      HU_COM-STAT = 'Cls'.
      MODIFY HU_COM INDEX SY-TABIX.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " hu_close

*&---------------------------------------------------------------------*
*&      Form  hu_unpacking
*&---------------------------------------------------------------------*
FORM HU_UNPACKING .
  DATA : HDR    LIKE HUHDR OCCURS 2 WITH HEADER LINE,
         ITM    LIKE HUITM OCCURS 2 WITH HEADER LINE,
         HUNUMB LIKE BAPIHUNUMBER OCCURS 2 WITH HEADER LINE,
         HI     LIKE BAPIHUINTERNAL  OCCURS 1 WITH HEADER LINE,
         UNPACK TYPE BAPIHUITMUNPACK OCCURS 1 WITH HEADER LINE,
         TABIX  LIKE SY-TABIX,
         RETCODE(02),
         QMCODE(02),
         MSTEXT(100).

  DATA: BEGIN OF IT_VEPO OCCURS 10,
          VENUM  LIKE  VEPO-VENUM,
          MATNR  LIKE  VEPO-MATNR,
          CHARG  LIKE  VEPO-CHARG,
          WERKS  LIKE  VEPO-WERKS,
          LGORT  LIKE  VEPO-LGORT,
        END OF IT_VEPO.

  SELECT SINGLE MTART VHART INTO (MARA-MTART, MARA-VHART)
                      FROM MARA WHERE MATNR = ZPACK00-MATNR.
  IF MARA-MTART NE 'ZPCK' AND MARA-MTART NE 'ZRTP'.
    MESSAGE I000(0K) WITH '* Select a Line with Packaging Material Only.'.
    EXIT.
  ENDIF.
  IF ZPACK00-EXIDV IS INITIAL.
    MESSAGE I000(0K) WITH ZPACK00-MATNR ' without Handling Unit.'.
    EXIT.
  ENDIF.

* Read Packing Document
  REFRESH : HUNUMB, HDR, ITM, HI, RETRN.
  HUNUMB-HU_EXID = ZPACK00-EXIDV.
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
      EXIT.
    ENDIF.
  ENDIF.

* Unpack Process
  DESCRIBE TABLE HDR LINES TABIX.
  CLEAR : HUKEY.
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
          QMCODE = 'X'.
*          EXIT.
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
      EXIT.
    ENDIF.
  ENDIF.

  IF TABIX > 1.      "Unpack Pallet and Box
    REFRESH RETRN.
*    LOOP AT hdr WHERE hu_exid NE hukey.
    LOOP AT HDR WHERE HU_EXID = ZPACK00-EXIDV.
      READ TABLE ITM WITH KEY LOWER_LEVEL_EXID = HDR-HU_EXID.
      IF SY-SUBRC = 0.
* Unpack just the boxes selected
        SELECT VEPO~VENUM VEPO~MATNR VEPO~CHARG VEPO~WERKS VEPO~LGORT INTO TABLE IT_VEPO FROM VEPO
        INNER JOIN VEKP ON VEKP~VENUM = VEPO~VENUM
        WHERE VEKP~EXIDV = HDR-HU_EXID.

        HUKEY = HDR-HU_EXID.

        LOOP AT IT_VEPO.
          READ TABLE ITM WITH KEY MATERIAL = IT_VEPO-MATNR
                                  BATCH    = IT_VEPO-CHARG
                                  PLANT    = IT_VEPO-WERKS
                                  STGE_LOC = IT_VEPO-LGORT.
          IF SY-SUBRC = 0.
            MOVE-CORRESPONDING ITM TO UNPACK.
            UNPACK-UNPACK_EXID = ITM-LOWER_LEVEL_EXID.

            CALL FUNCTION 'BAPI_HU_UNPACK'
              EXPORTING
                HUKEY      = HUKEY
                ITEMUNPACK = UNPACK
              TABLES
                RETURN     = RETRN.

*            append unpack.
*            clear unpack.
          ENDIF.
        ENDLOOP.
*        MOVE-CORRESPONDING itm TO unpack.
*        unpack-u.npack_exid = itm-lower_level_exid.
*        CALL FUNCTION 'BAPI_HU_UNPACK'
*          EXPORTING
*            hukey      = hukey
*            itemunpack = unpack
*          TABLES
*            return     = retrn.

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
            RETCODE = 02.
            EXIT.
*
*          ELSE.
*            DELETE TABLE IT_EXIDV
*              WITH TABLE KEY CHARG = hdr-hu_exid.

          ENDIF.

        ENDIF.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*       CALL FUNCTION 'RZL_SLEEP'.
        PERFORM PROCESS_DELAYING.
        MESSAGE S000(0K) WITH '* HU' HDR-HU_EXID 'Un-Packed.'.

*        hukey = hdr-hu_exid.
*        CALL FUNCTION 'BAPI_HU_DELETE'
*          EXPORTING
*            hukey  = hukey
*          TABLES
*            return = retrn.
*        IF NOT retrn[] IS INITIAL.
*          READ TABLE retrn INDEX 1.
*          MESSAGE s000(0k) WITH retrn-message(50) retrn-message+50.
*          IF retrn-type = 'E'.
*            EXIT.
*          ENDIF.
*        ENDIF.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

*      IF dlastvbeln IS NOT INITIAL.
*        PERFORM f_refresh.
*      ENDIF.

      ENDIF.
    ENDLOOP.

    CHECK RETCODE = 00.
*   Insert to HU itab
    CLEAR HU_HU.
    READ TABLE HU_COM WITH KEY EXID = HUKEY.
    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING HU_COM TO HU_HU.
      CLEAR HU_HU-STAT.
*      clear hu_hu-exid.
      COLLECT HU_HU.

    ENDIF.
*   Remove status flag for Pallet
    READ TABLE HU_COM WITH KEY EXID = HUKEY.
    CHECK SY-SUBRC = 0.
    HU_COM-STAT = 'X'.
*    clear hu_com-exid.
    MODIFY HU_COM INDEX SY-TABIX.
****
  ELSE.             "Unpack for Pallet/Box with Material
****
    SORT ITM BY OBJ_ITEM_NUMBER.
    LOOP AT ITM.
      REFRESH RETRN.
      MOVE-CORRESPONDING ITM TO UNPACK.
      UNPACK-UNPACK_EXID = ITM-LOWER_LEVEL_EXID.

      CALL FUNCTION 'BAPI_HU_UNPACK'
        EXPORTING
          HUKEY      = HUKEY
          ITEMUNPACK = UNPACK
        TABLES
          RETURN     = RETRN.

      IF NOT RETRN[] IS INITIAL.
        READ TABLE RETRN INDEX 1.
        MESSAGE S000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
        IF RETRN-TYPE = 'E'.
          RETCODE = 02.
          EXIT.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*     CALL FUNCTION 'RZL_SLEEP'.
      PERFORM PROCESS_DELAYING.
      MESSAGE S000(0K) WITH '* HU' HUKEY 'Un-Packed.'.
    ENDLOOP.

    CHECK RETCODE = 00.
*   Insert to HU itab
    CLEAR HU_HU.
    READ TABLE HU_COM WITH KEY EXID = HUKEY.
    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING HU_COM TO HU_HU.
      CLEAR HU_HU-STAT.
      COLLECT HU_HU.
    ENDIF.
*   Remove status flag.
    READ TABLE HU_COM WITH KEY EXID = HDR-HU_EXID.
    CHECK SY-SUBRC = 0.
    HU_COM-STAT = 'X'.
    MODIFY HU_COM INDEX SY-TABIX.
    SELECT SINGLE INHALT INTO VEKP-INHALT FROM VEKP WHERE EXIDV = HUKEY.
    LOOP AT ITM.
      IF ITM-HU_ITEM_TYPE = '1' AND VBAK-AUART(3) = 'ZDM'.
        ITM-MATERIAL = ZPACK00-MATNR1.
      ENDIF.
      READ TABLE HU_COM WITH KEY INS0 = VEKP-INHALT(3)
                                 INST = ITM-MATERIAL
                                 EXID = ITM-BATCH.
      IF SY-SUBRC = 0.
        HU_COM-EXID = ''.
        HU_COM-STAT = ' '.
        MODIFY HU_COM INDEX SY-TABIX.
      ENDIF.
    ENDLOOP.

  ENDIF.
  CLEAR : *ZPACK00, GCHAR.
* Remove Selection
  LOOP AT HU_COM WHERE SELE = 'X'.
    HU_COM-SELE = ' '.
    MODIFY HU_COM INDEX SY-TABIX.
  ENDLOOP.
  CLEAR VSELEK.

  PERFORM F_RELOADMIRROR.

ENDFORM.                    " hu_unpacking

*&---------------------------------------------------------------------*
*&      Form  hu_display
*&---------------------------------------------------------------------*
FORM HU_DISPLAY .

  IF ZPACK00-EXIDV IS INITIAL.
    MESSAGE I000(0K) WITH '* No Handling Unit Created.'.
    EXIT.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ZPACK00-EXIDV
      IMPORTING
        OUTPUT = ZPACK00-EXIDV.

    SELECT SINGLE * FROM VEKP WHERE EXIDV = ZPACK00-EXIDV.
    IF SY-SUBRC NE 0.
      MESSAGE I000(0K) WITH '* Handling Unit Does Not Exist.'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ZPACK00-EXIDV
        IMPORTING
          OUTPUT = ZPACK00-EXIDV.

      EXIT.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'COHU_HU_REFRESH'.
  CALL FUNCTION 'COHU_HU_DISPLAY'
    EXPORTING
      I_EXIDV = ZPACK00-EXIDV.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = ZPACK00-EXIDV
    IMPORTING
      OUTPUT = ZPACK00-EXIDV.

ENDFORM.                    " hu_display

***&---------------------------------------------------------------------*
***&      Form  hu_printing
***&---------------------------------------------------------------------*
**FORM hu_printing .
**  TABLES : b020, nach.
**  DATA : dynot TYPE bapioutpdevext,
**         proc  TYPE bapishpoutput-processing VALUE 1,
**         sortm TYPE bapishpoutput-sort VALUE 1,
**         hukey TYPE bapihukey OCCURS 1 WITH HEADER LINE,
**         ot    TYPE bapioutptype OCCURS 1 WITH HEADER LINE.
**
**
**  SELECT SINGLE * FROM vekp WHERE exidv = zpack00-exidv.
**  IF sy-subrc NE 0.
**    MESSAGE i000(0k) WITH '* Handling Unit Does Not Exist.'.
**    EXIT.
**  ENDIF.
**  hukey = vekp-exidv.
**  APPEND hukey.
**
**  proc = 1.
*** Printing Box Label
**  IF vekp-vhart = '0003'.
**    ot-output_type  = 'Z001'.
**    APPEND ot.
**    CALL FUNCTION 'HU_PACKING_REFRESH'.
**    CALL FUNCTION 'BAPI_HU_PROCESS_MSG_DIRECT'
**     EXPORTING
**       dynamicoutputdevice       = dynot
**       processing                = proc
**       sortmessage               = sortm
**      TABLES
**        hukey                     = hukey
**        outputtype                = ot
***       MESSAGEPROTOCOL           =
**        return                    = retrn.
**
**    IF NOT retrn[] IS INITIAL.
**      READ TABLE retrn INDEX 1.
**      MESSAGE s000(0k) WITH retrn-message(50) retrn-message+50.
**    ENDIF.
**
**  ELSE.
***   Printing Pallet Label
**    ot-output_type  = 'Z002'.
**    APPEND ot.
**    CALL FUNCTION 'BAPI_HU_PROCESS_MSG_DIRECT'
**      EXPORTING
**        dynamicoutputdevice       = dynot
**        processing                = proc
**        sortmessage               = sortm
**      TABLES
**        hukey                     = hukey
**        outputtype                = ot
***       MESSAGEPROTOCOL           =
**        return                    = retrn.
**
**    IF NOT retrn[] IS INITIAL.
**      READ TABLE retrn INDEX 1.
**      MESSAGE s000(0k) WITH retrn-message(50) retrn-message+50.
**    ENDIF.
***   CALL FUNCTION 'RZL_SLEEP'.
**    PERFORM process_delaying.
**    REFRESH ot.
**    ot-output_type  = 'Z003'.
**    APPEND ot.
**
**    SELECT SINGLE * FROM nast WHERE kappl = 'V6'
**                                AND objky = vekp-venum
**                                AND kschl = 'Z003'
**                                AND spras = sy-langu.
**    IF sy-subrc = 0.
**      proc = 2.
**    ENDIF.
***   Select output type from B020 and Nach
**    SELECT SINGLE * FROM b020 WHERE kappl = 'V6'
**                                AND kschl = 'Z003'
**                                AND vhart = vekp-vhart.
**    IF sy-subrc = 0.
**      SELECT SINGLE * FROM nach WHERE knumh = b020-knumh.
**      IF sy-subrc = 0.
**        dynot-output_device = nach-ldest.
**      ELSE.
***       Get from user default
**        SELECT SINGLE * FROM usr01 WHERE bname = sy-uname.
**        IF sy-subrc = 0.
**          IF  usr01-spld NE space.
**            dynot-output_device  = usr01-spld.
**          ELSE.
**            dynot-output_device  = 'LOCL'.
**          ENDIF.
**        ENDIF.
**      ENDIF.
**    ENDIF.
**  ENDIF.
**
**ENDFORM.                    " hu_printing

*&---------------------------------------------------------------------*
*&      Form  hu_printing_by_bdc
*&---------------------------------------------------------------------*
FORM HU_PRINTING_BY_BDC .
  DATA : PROC,
         WA LIKE HU_COM.


  SELECT SINGLE * FROM VEKP WHERE EXIDV = ZPACK00-EXIDV.
  IF SY-SUBRC NE 0.
    MESSAGE I000(0K) WITH '* Handling Unit Does Not Exist.'.
    EXIT.
  ENDIF.
  PROC = '1'.

  SET PARAMETER ID 'NAC' FIELD ''.
  SET PARAMETER ID 'VL'  FIELD ''.
  SET PARAMETER ID 'TNR' FIELD ''.
  SET PARAMETER ID 'ANR' FIELD ''.
  SET PARAMETER ID 'AUN' FIELD ''.
  SET PARAMETER ID 'BES' FIELD ''.
  REFRESH BDCDATA.
  PERFORM BDC_DYNPRO      USING 'SD70AV6A'        '1000'.
  IF VEKP-VHART = '0003'.
    PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z001'.
    PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '8'.
    PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
    PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
    PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  VEKP-EXIDV.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.
    CALL TRANSACTION 'VL74' USING BDCDATA MODE 'E' UPDATE 'A'.
  ELSE.
    PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z002'.
    PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '8'.
    PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
    PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
    PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  VEKP-EXIDV.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.
    CALL TRANSACTION 'VL74' USING BDCDATA MODE 'E' UPDATE 'A'.
    MESSAGE S000(0K) WITH 'Waiting.....'.
    DO 5 TIMES.
      CALL FUNCTION 'RZL_SLEEP'
        EXPORTING
          SECONDS = 5.
    ENDDO.
    MESSAGE S000(0K) WITH ''.
    REFRESH BDCDATA.
    PERFORM BDC_DYNPRO      USING 'SD70AV6A'      '1000'.
    PERFORM BDC_FIELD       USING 'RG_KSCHL-LOW'  'Z003'.
    PERFORM BDC_FIELD       USING 'RG_NACHA-LOW'  '1'.
    PERFORM BDC_FIELD       USING 'PM_NSORT'      '01'.
    PERFORM BDC_FIELD       USING 'PM_VERMO'      PROC.
    PERFORM BDC_FIELD       USING 'RG_EXIDV-LOW'  VEKP-EXIDV.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=ONLI'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&ALL'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=PROC'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0'      '0120'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'    '=&F03'.
    CALL TRANSACTION 'VL74' USING BDCDATA MODE 'E' UPDATE 'A'.
  ENDIF.

  READ TABLE HU_COM WITH KEY EXID = ZPACK00-EXIDV.
  IF SY-SUBRC = 0.
    HU_COM-SELE = ' '.
    MODIFY HU_COM INDEX SY-TABIX.
  ENDIF.
  CLEAR VSELEK.
ENDFORM.                    " hu_printing_by_bdc

*&---------------------------------------------------------------------*
*&      Form  hu_deletion
*&---------------------------------------------------------------------*
FORM HU_DELETION.

  READ TABLE HU_COM WITH KEY POSNR = ZPACK00-POSNR
                             INS0  = ZPACK00-ZINS01
                             INS1  = ZPACK00-ZINS02
                             INS2  = ZPACK00-ZINS03
                             EXID  = ZPACK00-EXIDV
                             STAT  = ZPACK00-STAT.
  CHECK SY-SUBRC = 0.
  READ_IDX = SY-TABIX.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ZPACK00-EXIDV
    IMPORTING
      OUTPUT = HUKEY.
  SELECT SINGLE * FROM VEKP WHERE EXIDV = HUKEY.
  IF SY-SUBRC NE 0.
    MESSAGE I000(0K) WITH '* Handling Unit Does Not Exist.'.
    EXIT.
  ENDIF.
  REFRESH RETRN.
  CALL FUNCTION 'BAPI_HU_DELETE'
    EXPORTING
      HUKEY  = HUKEY
    TABLES
      RETURN = RETRN.
  IF NOT RETRN[] IS INITIAL.
    READ TABLE RETRN INDEX 1.
    MESSAGE S000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
    IF RETRN-TYPE = 'E'.
      EXIT.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  CLEAR : HU_COM-EXID, HU_COM-STAT.
  MODIFY HU_COM INDEX READ_IDX.
  READ TABLE HU_HU WITH KEY EXID = HUKEY.
  IF SY-SUBRC = 0.
    DELETE HU_HU INDEX SY-TABIX.
  ENDIF.
  MESSAGE S000(0K) WITH '* Handling Unit Deleted.'.

ENDFORM.                    " hu_deletion

**&---------------------------------------------------------------------*
**&      Form  delete_packing_instruction
**&---------------------------------------------------------------------*
*FORM DELETE_PACKING_INSTRUCTION .
*  DATA TABIX LIKE SY-TABIX.
*  READ TABLE HU_COM WITH KEY POSNR = ZPACK00-POSNR
*                             INS0  = ZPACK00-ZINS01
*                             INS1  = ZPACK00-ZINS02
*                             INS2  = ZPACK00-ZINS03
*                             EXID  = ZPACK00-EXIDV
*                             STAT  = ZPACK00-STAT.
*  CHECK SY-SUBRC = 0.
*  TABIX    = HU_COM-TABIX.
*  READ_IDX = SY-TABIX.
*  IF HU_COM-TABIX NE 0.
*    READ TABLE HU_NEU WITH KEY TABIX = TABIX.
*    DELETE HU_NEU INDEX SY-TABIX.
*  ENDIF.
*  DELETE HU_COM INDEX READ_IDX.
*ENDFORM.                    " delete_packing_instruction
*
*
**&---------------------------------------------------------------------*
**&      Form  get_pack_exist
**&---------------------------------------------------------------------*
*FORM GET_PACK_EXIST.
*  TYPES : BEGIN OF SONUM,
*          INS0  LIKE HU_COM-INS0,
*          INS1  LIKE HU_COM-INS1,
*          EXIDV LIKE VEKP-EXIDV,
*          VHILM LIKE VEKP-VHILM,
*          VENUM LIKE VEPO-VENUM,
*          VELIN LIKE VEPO-VELIN,
*          UNVEL LIKE VEPO-UNVEL,
*          MATNR LIKE VEPO-MATNR,
*          CHARG LIKE VEPO-CHARG,
*        END OF SONUM,
*        BEGIN OF T_VEKP,
*          EXIDV  LIKE VEKP-EXIDV,
*          INHALT LIKE VEKP-INHALT,
*          VHILM  LIKE VEKP-VHILM,
*          VENUM  LIKE VEKP-VENUM,
*        END OF T_VEKP.
*
*  DATA: BEGIN OF IT_VEPO OCCURS 0,
*          VENUM  LIKE  VEPO-VENUM,
*          MATNR  LIKE  VEPO-MATNR,
*          CHARG  LIKE  VEPO-CHARG,
*        END OF IT_VEPO.
*
*  DATA: BEGIN OF IT_SONUM OCCURS 1,
**venum velin unvel matnr charg
*          VENUM  LIKE  VEPO-VENUM,
*          VELIN  LIKE  VEPO-VELIN,
*          UNVEL  LIKE  VEPO-UNVEL,
*          MATNR  LIKE  VEPO-MATNR,
*          CHARG  LIKE  VEPO-CHARG,
*        END OF IT_SONUM.
*
*  DATA : T_SONUM  TYPE SORTED TABLE OF SONUM WITH UNIQUE KEY TABLE_LINE WITH HEADER LINE,
*         T_SO2SO  TYPE SONUM OCCURS 2 WITH HEADER LINE,
*         T_EXIDV  TYPE SONUM OCCURS 2 WITH HEADER LINE,
*         IT_VEKP  TYPE HASHED TABLE OF T_VEKP WITH UNIQUE KEY VENUM WITH HEADER LINE.
*
*  DATA : INDEK  LIKE SY-TABIX,
*         VSTAT,
*         VCLOSE LIKE HU_COM OCCURS 2 WITH HEADER LINE,
*         CLFLAG,
*         VTABIX LIKE SY-TABIX.
*
*
** Fill-in HU number created for Pallet and Boxes
*  IF NOT HU_HU[] IS INITIAL.
*    LOOP AT HU_COM WHERE EXID = SPACE.
*      INDEK = SY-TABIX.
*      IF HU_COM-INS2 = 0.
*        READ TABLE HU_HU WITH KEY INS0 = HU_COM-INS0
*                                  INS1 = HU_COM-INS1
*                                  INS2 = HU_COM-INS2
*                                  INST = HU_COM-INST.
*        IF SY-SUBRC = 0.
*          HU_COM-EXID = HU_HU-EXID.
*          HU_COM-STAT = 'X'.
*          MODIFY HU_COM INDEX INDEK.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*  SELECT VENUM VELIN UNVEL MATNR CHARG
*    INTO CORRESPONDING FIELDS OF TABLE T_SONUM
*    FROM VEPO
*    WHERE SONUM = GSONUM.
*
************** Oscar - cari venum = unvel untuk nyari pallet yang gak ada sonumnya
*  SELECT VENUM VELIN UNVEL MATNR CHARG
*    INTO TABLE IT_SONUM
*    FROM VEPO FOR ALL ENTRIES IN T_SONUM
*    WHERE VENUM = T_SONUM-UNVEL.
*
*  LOOP AT T_SONUM WHERE UNVEL NE SPACE.
*    READ TABLE IT_SONUM WITH KEY VENUM = T_SONUM-UNVEL.
*    IF SY-SUBRC = 0.
*      MOVE-CORRESPONDING IT_SONUM TO T_SONUM.
*      COLLECT T_SONUM.
*      CLEAR T_SONUM.
*    ENDIF.
*  ENDLOOP.
********************************************
*  IF T_SONUM[] IS INITIAL.
*    READ TABLE HU_COM WITH KEY EXID = ZPACK00-CHARGDC.
*    CHECK SY-SUBRC NE 0.
*
**   ---
*    IF D_MATERIALTYPEOK IS NOT INITIAL.
*      READ TABLE HU_COM
*        WITH KEY
*          INST = ZPACK00-MATNR1
*          EXID = SPACE.
*
*      IF SY-SUBRC EQ 0.
*        HU_COM-EXID = ZPACK00-CHARGDC.
*        CLEAR HU_COM-STAT.
*        MODIFY HU_COM INDEX SY-TABIX.
*      ENDIF.
*    ENDIF.
*
*  ENDIF.
*
*  CHECK NOT T_SONUM[] IS INITIAL.
*
** Completing t_sonum with record from Transfer SO to SO after HU Closed
** for displaying purpose
*  T_SO2SO[] = T_SONUM[].
*  DELETE T_SO2SO WHERE VELIN NE '3' AND UNVEL NE SPACE.
*
*  IF T_SO2SO[] IS INITIAL.
*    REFRESH IT_VEPO.
*
*  ELSE.
*    SELECT VENUM MATNR CHARG INTO TABLE IT_VEPO FROM VEPO
*    FOR ALL ENTRIES IN T_SO2SO WHERE VENUM = T_SO2SO-UNVEL
*    %_HINTS ORACLE 'INDEX(VEPO"Z02")'.
*
*  ENDIF.
*
*
*  LOOP AT IT_VEPO.
*    CLEAR T_SONUM.
*    T_SONUM-VELIN = '1'.
*    T_SONUM-VENUM = IT_VEPO-VENUM.
*    T_SONUM-MATNR = IT_VEPO-MATNR.
*    T_SONUM-CHARG = IT_VEPO-CHARG.
*    COLLECT T_SONUM.
*  ENDLOOP.
*
** Generate packing document itab (t_exidv)
**  SELECT DISTINCT exidv inhalt vhilm venum
*  SELECT EXIDV INHALT VHILM VENUM
*    INTO TABLE IT_VEKP
*    FROM VEKP
*    FOR ALL ENTRIES IN T_SONUM
*    WHERE VEKP~VENUM = T_SONUM-VENUM.
*
*  LOOP AT T_SONUM.
**   for material
*    IF T_SONUM-VELIN = '1'.
*      READ TABLE IT_VEKP WITH TABLE KEY VENUM = T_SONUM-VENUM.
*
*      IF IT_VEKP-INHALT(3) IS NOT INITIAL.
*        CLEAR T_EXIDV.
*        T_EXIDV-INS0  = IT_VEKP-INHALT(3).
*        T_EXIDV-INS1  = IT_VEKP-INHALT+3(3).
*        T_EXIDV-EXIDV = IT_VEKP-EXIDV.
**       New Dummy
*        IF VBAK-AUART(3) = 'ZDM'.
*          T_EXIDV-VHILM = ZPACK00-MATNR1.
*        ELSE.
*          T_EXIDV-VHILM = T_SONUM-MATNR.
*        ENDIF.
*        T_EXIDV-VENUM = T_SONUM-VENUM.
*        T_EXIDV-CHARG = T_SONUM-CHARG.
*        COLLECT T_EXIDV.
*
*        CLEAR T_EXIDV.
*        T_EXIDV-INS0  = IT_VEKP-INHALT(3).
*        T_EXIDV-INS1  = IT_VEKP-INHALT+3(3).
*        T_EXIDV-EXIDV = IT_VEKP-EXIDV.
*        T_EXIDV-VHILM = IT_VEKP-VHILM.
*        T_EXIDV-VENUM = IT_VEKP-VENUM.
*        COLLECT T_EXIDV.
*
*      ENDIF.
*
*    ENDIF.
**   for handling unit
*    IF T_SONUM-VELIN = '3'.
*      READ TABLE IT_VEKP WITH TABLE KEY VENUM = T_SONUM-VENUM.
*
*      IF IT_VEKP-INHALT(3) IS NOT INITIAL.
*        CLEAR T_EXIDV.
*        T_EXIDV-INS0  = IT_VEKP-INHALT(3).
*        T_EXIDV-INS1  = IT_VEKP-INHALT+3(3).
*        T_EXIDV-EXIDV = IT_VEKP-EXIDV.
*        T_EXIDV-VHILM = IT_VEKP-VHILM.
*        T_EXIDV-VENUM = IT_VEKP-VENUM.
*        COLLECT T_EXIDV.
*      ENDIF.
*
**      SELECT SINGLE exidv inhalt vhilm venum
**             INTO (vekp-exidv,vekp-inhalt,vekp-vhilm,vekp-venum)
**             FROM vekp WHERE venum = t_sonum-unvel.
*      READ TABLE IT_VEKP WITH TABLE KEY VENUM = T_SONUM-UNVEL.
*
*      IF IT_VEKP-INHALT(3) IS NOT INITIAL.
*        CLEAR T_EXIDV.
*        T_EXIDV-INS0  = IT_VEKP-INHALT(3).
*        T_EXIDV-INS1  = IT_VEKP-INHALT+3(3).
*        T_EXIDV-EXIDV = IT_VEKP-EXIDV.
*        T_EXIDV-VHILM = IT_VEKP-VHILM.
*        T_EXIDV-VENUM = IT_VEKP-VENUM.
*        COLLECT T_EXIDV.
*
*      ENDIF.
*
*    ENDIF.
*
*  ENDLOOP.
*
**  DELETE t_exidv WHERE ins0 = space.
*  SORT T_EXIDV.
*
** Combining instruction with HU packing items (t_exidv)
*  LOOP AT HU_COM WHERE EXID = SPACE.
*
*    READ_IDX = SY-TABIX.
**   For pallet only, fill-in HU number
*    IF HU_COM-INS2 = 0.
*      READ TABLE HU_HU WITH KEY INS0 = HU_COM-INS0
*                                INS1 = HU_COM-INS1
*                                INS2 = HU_COM-INS2
*                                INST = HU_COM-INST.
*      IF SY-SUBRC = 0.
*        HU_COM-EXID = HU_HU-EXID.
*        MODIFY HU_COM INDEX READ_IDX.
*      ENDIF.
*    ENDIF.
*    CLEAR VSTAT.
*
*    LOOP AT T_EXIDV WHERE VHILM = HU_COM-INST
*                      AND  INS0 = HU_COM-INS0.
*      VTABIX = SY-TABIX.
*      IF HU_COM-INS1 NE SPACE AND HU_COM-INS2 NE SPACE.
*        CHECK T_EXIDV-INS1 = HU_COM-INS1.
*      ENDIF.
*
*      IF T_EXIDV-CHARG NE SPACE.
***       Check whether printed already for Box
**        SELECT SINGLE kappl
**          INTO nast-kappl
**          FROM nast WHERE kappl = 'V6'
**           AND objky = t_exidv-venum "vepo-venum
**           AND kschl = 'Z001'
**           AND vstat NE 0
**           AND spras = sy-langu.
**
**        IF sy-subrc = 0.
**          hu_com-stat = 'Prt'.
**          vstat       = 'X'.
**        ELSE.
**          IF vstat = 'X'.
**            hu_com-stat = 'Prt'.
**          ELSE.
**            hu_com-stat = 'Pck'.
**          ENDIF.
**        ENDIF.
*
*        HU_COM-STAT = 'Pck'.
*        HU_COM-EXID = T_EXIDV-CHARG.
*
**       Keep First Batch Characteristics Values
*        IF GCHAR IS INITIAL.
*          CHR1ST-MATNR0 = ZPACK00-MATNR0.
*          CHR1ST-MATNR1 = T_EXIDV-VHILM.
*          CHR1ST-CHARG  = T_EXIDV-CHARG.
*          PERFORM READ_CHARACTERISTICS CHANGING CHR1ST.
*          GCHAR = 'X'.
*        ENDIF.
*
**       Change sy-tabix to v_tabix by Johan.
*        DELETE T_EXIDV INDEX VTABIX.
**       DELETE t_exidv INDEX sy-tabix.
*        MODIFY HU_COM INDEX READ_IDX.
*        EXIT.
*      ENDIF.
*
*      IF T_EXIDV-EXIDV NE SPACE.
***       Check whether printed already for Pallet
**        SELECT SINGLE kappl INTO nast-kappl
**                            FROM nast WHERE kappl = 'V6'
**                             AND objky = t_exidv-venum "vekp-venum
**                             AND kschl = 'Z002'
**                             AND vstat NE 0
**                             AND spras = sy-langu.
**        IF sy-subrc = 0.
**          hu_com-stat = 'Prt'.
**          vstat       = 'X'.
**        ELSE.
**          IF vstat = 'X'.
**            hu_com-stat = 'Prt'.
**          ELSE.
**            hu_com-stat = 'Pck'.
**          ENDIF.
**        ENDIF.
*
*        HU_COM-STAT = 'Pck'.
*        HU_COM-EXID = T_EXIDV-EXIDV.
*
**       Change sy-tabix to v_tabix by Johan.
*        DELETE T_EXIDV INDEX VTABIX.
**       DELETE t_exidv INDEX sy-tabix.
*        MODIFY HU_COM INDEX READ_IDX.
*        EXIT.
*      ENDIF.
*
*    ENDLOOP.
*  ENDLOOP.
*
** Remove HU Number and Batch Number for HU Closed
*  IF VBAK-AUART(3) = 'ZDM'.
**   Update Status for HU Closed (Dummy)
**    SELECT MATNR MTART INTO TABLE IT_MTART
**      FROM MARA
**      FOR ALL ENTRIES IN HU_COM
**      WHERE MARA~MTART NE 'ZPCK'
**        AND MARA~MTART NE 'ZRTP'
**        AND MARA~MATNR = HU_COM-INST.
**
**    SELECT CHARG
**      INTO IT_CHARG
**      FROM MSKA
**      WHERE VBELN = ZPACK00-VBELN
**        AND POSNR = ZPACK00-POSNR
**        AND CHARG = HU_COM-EXID
**        AND KALAB NE 0
**        AND ( ( MSKA-LGORT <> '1302' )
**          OR ( MSKA-LGORT <> '1802' )
**          OR ( MSKA-LGORT <> '2302' )
**          OR ( MSKA-LGORT <> '2802' ) ).
*
*    LOOP AT HU_COM.
*      SELECT SINGLE MTART VHART INTO (MARA-MTART, MARA-VHART)
*                          FROM MARA WHERE MATNR = HU_COM-INST.
*
*      IF MARA-MTART NE 'ZPCK' AND MARA-MTART NE 'ZRTP'.
*        SELECT SINGLE LGORT
*          INTO MSKA-LGORT
*          FROM MSKA
*          WHERE VBELN = ZPACK00-VBELN
*            AND POSNR = ZPACK00-POSNR
*            AND CHARG = HU_COM-EXID
*            AND KALAB NE 0.
*
*        IF ( ( MSKA-LGORT <> '1302' )
*          OR ( MSKA-LGORT <> '1802' )
*          OR ( MSKA-LGORT <> '2302' )
*          OR ( MSKA-LGORT <> '2802' ) ).
*
**        IF SY-SUBRC EQ 0.
*          CLEAR VCLOSE.
*          MOVE-CORRESPONDING HU_COM TO VCLOSE.
*          APPEND VCLOSE.
*
*        ENDIF.
*
*      ENDIF.
*
*    ENDLOOP.
*
*
*    IF NOT VCLOSE[] IS INITIAL.
*      LOOP AT VCLOSE.
*        LOOP AT HU_COM WHERE INS0 = VCLOSE-INS0.
*          CLEAR : HU_COM-EXID, HU_COM-STAT, HU_COM-SELE.
*          MODIFY HU_COM INDEX SY-TABIX.
*        ENDLOOP.
*      ENDLOOP.
*    ENDIF.
*
*  ELSE.
**   Update Status for HU Closed (Standard)
*    REFRESH VCLOSE.
*    VCLOSE[] = HU_COM[].
*    LOOP AT VCLOSE.
*      CHECK STRLEN( VCLOSE-EXID ) = 20.
*      CLEAR CLFLAG.
*      PERFORM CLOSE_STATUS USING VCLOSE-EXID CHANGING CLFLAG.
*      IF CLFLAG = 'X'.
*        LOOP AT HU_COM WHERE INS0 = VCLOSE-INS0.
*          HU_COM-STAT = 'Cls'.
*          MODIFY HU_COM INDEX SY-TABIX.
*        ENDLOOP.
*      ENDIF.
*    ENDLOOP.
*
**    PERFORM F_GETCLOSEDBATCH.
**
**    VCLOSE[] = HU_COM[].
**    LOOP AT VCLOSE.
**      READ TABLE IT_CHARG WITH TABLE KEY CHARG = VCLOSE-EXID.
**
**      IF SY-SUBRC EQ 0.  "-- IF FOUND THEN IT IS ALREADY CLOSED
**        LOOP AT HU_COM WHERE INS0 = VCLOSE-INS0 AND STAT NE 'Cls'.
**          HU_COM-STAT = 'Cls'.
**          MODIFY HU_COM INDEX SY-TABIX.
**        ENDLOOP.
**
**      ENDIF.
**
**    ENDLOOP.
*
*  ENDIF.
*
*ENDFORM.                    " get_pack_exist

*&---------------------------------------------------------------------*
*&      Form  auto_packing
*&---------------------------------------------------------------------*
FORM AUTO_PACKING.
  DATA : WA LIKE HU_COM,
         FLG,
         V1 TYPE P DECIMALS 2,
         V2 TYPE I.
  DATA LD_EXID TYPE EXIDV.

  CLEAR : ITMPROPOSAL.
  REFRESH : ITMPROPOSAL, RETRN.

* Check batch number in hu_com
  IF VBAK-AUART(3) = 'ZDM'.
    READ TABLE HU_COM WITH KEY "-not needed-->  inst = zpack00-matnr1
                               EXID = ZPACK00-CHARGDC.
  ELSE.
    READ TABLE HU_COM WITH KEY "-not needed-->  inst = zpack00-matnr0
                               EXID = ZPACK00-CHARGDC.
  ENDIF.

  IF SY-SUBRC EQ 0.
    IF HU_COM-STAT NE ' '.
      PAGEBEGIN = SY-TABIX - 3.
      MESSAGE I000(0K) WITH '* Batch already entered.'.
      RETURN.

    ENDIF.

  ELSE.
    MESSAGE I000(0K) WITH '* Batch / Material Number is Different'
                          'OR No Packing Instruction Available.'.
    RETURN.

  ENDIF.

* --NOTE: Since HU for SO Item of this batch is already loaded to hu_com
*         and hu_com is already checked in the above codes, then no need to
*         call the form F_GETEXIDBYBATCH anymore.
*
*  PERFORM F_GETEXIDBYBATCH
*    USING zpack00-chargdc
*    CHANGING LD_EXID.
*
*  IF LD_EXID IS NOT INITIAL.
*    RETURN.
*  ENDIF.

  WA = HU_COM.

* Get Upper Level HU of Material
  LOOP AT HU_COM WHERE INS0 = WA-INS0.

    IF WA-INS1 NE SPACE AND WA-INS2 NE SPACE.
      CHECK HU_COM-INS1 = WA-INS1 AND HU_COM-INS2 = SPACE AND
            HU_COM-EXID NE SPACE.  "  AND
*           ( hu_com-stat NE 'Prt' AND hu_com-stat NE 'Cls' ).
    ENDIF.
    IF WA-INS1 NE SPACE AND WA-INS2 = SPACE.
      CHECK HU_COM-INS1 = SPACE AND HU_COM-EXID NE SPACE.   " AND
*           ( hu_com-stat NE 'Prt' AND hu_com-stat NE 'Cls' ).
    ENDIF.

*   Comparing Characteristics Value
    IF NOT GCHAR IS INITIAL.
      IF CHR1ST-CHAR01 NE ZPACK00-CHAR01 OR CHR1ST-CHAR02 NE ZPACK00-CHAR02 OR
         CHR1ST-CHAR03 NE ZPACK00-CHAR03 OR CHR1ST-CHAR04 NE ZPACK00-CHAR04 OR
         CHR1ST-CHAR05 NE ZPACK00-CHAR05 OR CHR1ST-CHAR06 NE ZPACK00-CHAR06 OR
         CHR1ST-CHAR07 NE ZPACK00-CHAR07.
        MESSAGE S000(0K) WITH '* Can not be Packed for Different Characteristics.'.
        CLEAR FLG.
        EXIT.
      ENDIF.
    ENDIF.

    PERFORM F_GET_SHEET CHANGING SHEET.

*   BAPI Preparation
    HUKEY = HU_COM-EXID.
    ITMPROPOSAL-HU_ITEM_TYPE      = '1'.
    IF VBAK-AUART(3) = 'ZDM'.
      ITMPROPOSAL-MATERIAL        = ZPACK00-MATNR0.
    ELSE.
      ITMPROPOSAL-MATERIAL        = WA-INST.
    ENDIF.
*  HardCore pack qty with '1 ROL'.
    ITMPROPOSAL-PACK_QTY          = '1'.
    IF SHEET = 'X'.
      ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'PAK'.
      ITMPROPOSAL-BASE_UNIT_QTY     = 'PAK'.
    ELSE.
      ITMPROPOSAL-BASE_UNIT_QTY_ISO = 'ROL'.
      ITMPROPOSAL-BASE_UNIT_QTY     = 'ROL'.
    ENDIF.
*    itmproposal-pack_qty          = zpack00-zmeng.
*    itmproposal-base_unit_qty_iso = zpack00-meins.
*    itmproposal-base_unit_qty     = zpack00-meins.
    ITMPROPOSAL-BATCH             = WA-EXID.
    ITMPROPOSAL-PLANT             = HUPAST_T-PLANT.
    ITMPROPOSAL-STGE_LOC          = HUPAST_T-STGE_LOC.
    ITMPROPOSAL-SPEC_STOCK        = 'E'.
    ITMPROPOSAL-SP_STCK_NO        = GSONUM.
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
      MESSAGE S000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
      EXIT.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    MESSAGE S000(0K) WITH '* Batch ' WA-EXID 'packed into HU' HU_COM-EXID.

    IF C_USEMIRROR IS NOT INITIAL.
      CLEAR IT_EXIDV.
      IT_EXIDV-CHARG = WA-EXID.
      IT_EXIDV-EXIDV = HU_COM-EXID.
      INSERT TABLE IT_EXIDV.
    ENDIF.

    FLG = 'X'.
    EXIT.

  ENDLOOP.

  IF FLG IS INITIAL.
    REFRESH HU_PACK.
  ENDIF.
* Auto Scroll
  IF SY-TABIX > MAXLOOP.
    V1 = SY-TABIX / MAXLOOP.
    V2 = TRUNC( V1 ).
    PAGEBEGIN = V2 * MAXLOOP.
  ENDIF.

  CHECK FLG = 'X'.
* Update Status to "Pck" (Packed)
  READ TABLE HU_COM
    WITH KEY
      POSNR = WA-POSNR
      INS0 = WA-INS0
      INS1 = WA-INS1
      INS2 = WA-INS2
      INST = WA-INST
      EXID = WA-EXID.

  CHECK SY-SUBRC = 0.
  HU_COM-STAT = 'Pck'.
  MODIFY HU_COM INDEX SY-TABIX.

* Auto Scroll
*  IF sy-tabix >= maxloop.
*    v1 = sy-tabix / 18.
*    v2 = TRUNC( v1 ).
**    pagebegin = v2 * maxloop + 8.
*    pagebegin = v2 * maxloop + 6.
*
*  ENDIF.


  READ TABLE HU_COM WITH KEY EXID = HUKEY.
  CHECK SY-SUBRC = 0.
  HU_COM-STAT = 'Pck'.
  MODIFY HU_COM INDEX SY-TABIX.

* Delete HU itab
  READ TABLE HU_HU WITH KEY EXID = HUKEY.
  IF SY-SUBRC = 0.
    DELETE HU_HU INDEX SY-TABIX.
  ENDIF.

* Keep First Packed Characteristics
  IF GCHAR IS INITIAL AND VBAK-AUART(3) NE 'ZDM'.
    CHR1ST-MATNR0 = ZPACK00-MATNR0.
    CHR1ST-MATNR1 = ZPACK00-MATNR1.
    CHR1ST-CHARG  = ZPACK00-CHARGDC.
    PERFORM READ_CHARACTERISTICS CHANGING CHR1ST.
    GCHAR = 'X'.
  ENDIF.

*  CLEAR zpack00-chargdc.

ENDFORM.                    " auto_packing

*&---------------------------------------------------------------------*
*&      Form  popup_hu_hu
*&---------------------------------------------------------------------*
FORM POPUP_HU_HU  CHANGING P_ANS.
  P_ANS = 1.
  IF NOT HU_HU[] IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'HU Document Confirmation '
        TEXT_QUESTION         = 'Do you want to delete HU Document Created ? '
        TEXT_BUTTON_1         = 'Yes'
        TEXT_BUTTON_2         = 'No'
        DEFAULT_BUTTON        = 'A'
        DISPLAY_CANCEL_BUTTON = 'X'
      IMPORTING
        ANSWER                = P_ANS.
  ENDIF.
ENDFORM.                    " popup_hu_hu

*&---------------------------------------------------------------------*
*&      Form  delete_hu_hu
*&---------------------------------------------------------------------*
FORM DELETE_HU_HU .

  CHECK NOT HU_HU[] IS INITIAL.
  LOOP AT HU_HU.
    REFRESH RETRN.
    HUKEY = HU_HU-EXID.
    CALL FUNCTION 'BAPI_HU_DELETE'
      EXPORTING
        HUKEY  = HUKEY
      TABLES
        RETURN = RETRN.
    IF NOT RETRN[] IS INITIAL.
      READ TABLE RETRN INDEX 1.
      MESSAGE S000(0K) WITH RETRN-MESSAGE(50) RETRN-MESSAGE+50.
      IF RETRN-TYPE = 'E'.
        EXIT.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDLOOP.

ENDFORM.                    " delete_hu_hu

*----------------------------------------------------------------------*
*        Form bdc_dynpro                                               *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Form bdc_field                                                *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL <> '/'.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  process_delaying
*&---------------------------------------------------------------------*
FORM PROCESS_DELAYING .
  DATA : X1 TYPE P DECIMALS 4.                              "#EC NEEDED
  DO 80000 TIMES.
    X1 = SQRT( SY-INDEX ) / SQRT( SY-INDEX ).
  ENDDO.
ENDFORM.                    " process_delaying

*&---------------------------------------------------------------------*
*&      Form  close_status
*&---------------------------------------------------------------------*
FORM CLOSE_STATUS  USING    P_FLD01
                   CHANGING P_FLD02.

*  SELECT SINGLE venum INTO vekp-venum FROM vekp WHERE exidv = p_fld01.
*  IF sy-subrc = 0.
*    SELECT SINGLE * FROM humseg WHERE venum = vekp-venum.
*    IF sy-subrc = 0.
*      SELECT SINGLE mblnr INTO mseg-mblnr FROM mseg
*                          WHERE mblnr = humseg-mblnr
*                            AND kdauf = zpack00-vbeln
*                            AND kdpos = zpack00-posnr
*                            AND bwart = '311'
*                            AND xauto = 'X'.
*      IF sy-subrc = 0.
*        p_fld02 = 'X'.
*      ENDIF.
*    ENDIF.
*  ENDIF.
  SELECT SINGLE VENUM HANDLE INTO (VEKP-VENUM,VEKP-HANDLE)
                             FROM VEKP WHERE EXIDV = P_FLD01.
  IF SY-SUBRC = 0.
    SELECT * FROM VEVW WHERE HANDLE = VEKP-HANDLE.
      SELECT SINGLE MBLNR INTO MSEG-MBLNR FROM MSEG
                          WHERE MBLNR = VEVW-OBJKEY(10)
                            AND KDAUF = ZPACK00-VBELN
                            AND KDPOS = ZPACK00-POSNR
                            AND BWART = '311'
                            AND XAUTO = 'X'.
      IF SY-SUBRC = 0.
        P_FLD02 = 'X'.
        EXIT.
      ENDIF.
    ENDSELECT.
  ENDIF.

ENDFORM.                    " close_status


*&---------------------------------------------------------------------*
*&      Form  insert_batch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_BATCH .
* Inserting Batch Nr. into the 1st Empty Position
  READ TABLE HU_COM WITH KEY EXID = ZPACK00-CHARGDC.
  CHECK SY-SUBRC NE 0.

  DATA WS TYPE COMM1.

  IF D_MATERIALTYPEOK IS NOT INITIAL.
*   get the first record with empty batch number (exid)
    READ TABLE HU_COM
      WITH KEY
        INST = ZPACK00-MATNR1
        EXID = SPACE
        STAT = SPACE.

*   check handling unit readiness
    IF SY-SUBRC EQ 0.
      WA = HU_COM.

      IF WA-INS2 IS NOT INITIAL. "-- BOXED
        READ TABLE HU_COM
          WITH KEY
            INS0 = WA-INS0
            INS1 = WA-INS1
            INS2 = SPACE.

      ELSEIF WA-INS1 IS NOT INITIAL. "-- SUSPENDED
        READ TABLE HU_COM
          WITH KEY
            INS0 = WA-INS0
            INS1 = SPACE
            INS2 = SPACE.

      ENDIF.

*     not ready if no handling unit number or not packed
      IF HU_COM-EXID IS INITIAL  OR
        HU_COM-STAT NE 'Pck'.        "-- HU not ready

*       read the first item of the handling unit
        ADD 1 TO SY-TABIX.
        READ TABLE HU_COM INDEX SY-TABIX.

      ELSE.
        "-- read the first empty item of the handling unit
        READ TABLE HU_COM
          WITH KEY
            POSNR = WA-POSNR
            INS0 = WA-INS0
            INS1 = WA-INS1
            INS2 = WA-INS2
            EXID = WA-EXID.

      ENDIF.

      HU_COM-EXID = ZPACK00-CHARGDC.
      HU_COM-STAT = SPACE.
      MODIFY HU_COM INDEX SY-TABIX.

    ENDIF.

  ENDIF.

ENDFORM.                    " insert_batch


*&---------------------------------------------------------------------*
*&      Form  f_unlock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UNLOCK .
  IF NOT DLASTPOSNR IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EZPACK'
      EXPORTING
        MODE_ZPACK = 'E'
        MANDT      = SY-MANDT
        VBELN      = DLASTVBELN
        POSNR      = DLASTPOSNR.
*         X_VBELN          = ' '
*         X_POSNR          = ' '
*         _SCOPE           = '3'
*         _SYNCHRON        = ' '
*         _COLLECT         = ' '

  ENDIF.

ENDFORM.                    " f_unlock


*&---------------------------------------------------------------------*
*&      Form  f_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_REFRESH .
* unlock previous so item in packing instruction
  PERFORM F_UNLOCK.

* lock new so item in packing instruction
  CALL FUNCTION 'ENQUEUE_EZPACK'
    EXPORTING
      MODE_ZPACK     = 'E'
      MANDT          = SY-MANDT
      VBELN          = ZPACK00-VBELN
      POSNR          = ZPACK00-POSNR
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    D_FATALERR = 'X'.
    RETURN. "-- exit immediately
  ENDIF.

* Check and Re-Generate Packing Instruction.
  REFRESH : HU_COM, HU_TMP.
  CLEAR   : HU_COM, HU_TMP, D_FATALERR.

*  PERFORM GET_PACKING_INSTRUCTIONS.

  IF D_FATALERR IS INITIAL.
*   Regenerate Existing Pack
*    PERFORM GET_PACK_EXIST.

  ENDIF.

ENDFORM.                    " f_refresh


*&---------------------------------------------------------------------*
*&      Form  F_RELOADMIRROR
*&---------------------------------------------------------------------*
*       pre-load charg - exidv relationship to speedup some process
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_RELOADMIRROR .
  IF C_USEMIRROR IS NOT INITIAL.
    REFRESH IT_EXIDV.
    CLEAR   IT_EXIDV.

    SELECT DISTINCT VEPO~CHARG EXIDV
      INTO TABLE IT_EXIDV
      FROM VEKP INNER JOIN VEPO
        ON VEKP~VENUM = VEPO~VENUM
      WHERE VEPO~SONUM = GSONUM.

  ENDIF.

ENDFORM.                    " F_RELOADMIRROR


*&---------------------------------------------------------------------*
*&      Form  F_GETEXIDBYBATCH1
*&---------------------------------------------------------------------*
*       get charg - exidv relationship from using current hu_com
*       ASSUMPTION:
*          hu_com work area is pointed to the right position.
*          e.g: after calling INSERT_BATCH
*----------------------------------------------------------------------*
*  -->  FU_BATCH        batch number
*  <--  FC_EXIDV        exidv
*----------------------------------------------------------------------*
FORM F_GETEXIDBYBATCH1
  USING FU_BATCH
  CHANGING FC_EXIDV TYPE EXIDV.

  DATA WA TYPE COMM1.
  DATA WA_CURRENT TYPE COMM1.
  CLEAR FC_EXIDV.

* store current work area of hu_com
  WA_CURRENT = HU_COM.

* find requested record in hu_com
  READ TABLE HU_COM
    WITH KEY EXID = FU_BATCH.

  IF SY-SUBRC EQ 0.
*   store requested record in work area WA
    WA = HU_COM.

    IF WA-INS2 IS NOT INITIAL. "-- BOXED
      READ TABLE HU_COM
        WITH KEY
          POSNR = WA-POSNR
          INS0 = WA-INS0
          INS1 = WA-INS1
          INS2 = SPACE.

    ELSE.                      "-- SUSPENDED
      READ TABLE HU_COM
        WITH KEY
          POSNR = WA-POSNR
          INS0 = WA-INS0
          INS1 = SPACE
          INS2 = SPACE.

    ENDIF.

    IF SY-SUBRC EQ 0.
      IF HU_COM-STAT EQ 'Pck' AND WA-STAT EQ 'Pck'.
        FC_EXIDV = HU_COM-EXID.

      ENDIF.

    ENDIF.

  ENDIF.

* Restore work area
* we don't use: HU_COM = WA_CURRENT, so we can get correct SY-TABIX.
  READ TABLE HU_COM
    WITH KEY
      POSNR = WA_CURRENT-POSNR
      INS0 = WA_CURRENT-INS0
      INS1 = WA_CURRENT-INS1
      INS2 = WA_CURRENT-INS2.

ENDFORM.                    "F_GETEXIDBYBATCH1

*&---------------------------------------------------------------------*
*&      Form  F_GETEXIDBYBATCH2
*&---------------------------------------------------------------------*
*       get exidv using pre-loaded charg - exidv relationship
*----------------------------------------------------------------------*
*  -->  FU_BATCH        batch number
*  <--  FC_EXIDV        exidv
*----------------------------------------------------------------------*
FORM F_GETEXIDBYBATCH2
  USING FU_BATCH
  CHANGING FC_EXIDV TYPE EXIDV.

  CLEAR: IT_EXIDV, FC_EXIDV.

  READ TABLE IT_EXIDV WITH KEY CHARG = FU_BATCH.

  IF SY-SUBRC EQ 0.
    FC_EXIDV = IT_EXIDV-EXIDV.

  ENDIF.

ENDFORM.                    "F_GETEXIDBYBATCH2


*&---------------------------------------------------------------------*
*&      Form  F_GETEXIDBYBATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZPACK00_CHARG  text
*      <--P_LD_EXID  text
*----------------------------------------------------------------------*
FORM F_GETEXIDBYBATCH
  USING FU_BATCH
  CHANGING FC_EXIDV TYPE EXIDV.

  IF C_USEMIRROR IS NOT INITIAL.
    PERFORM F_GETEXIDBYBATCH2
      USING FU_BATCH
      CHANGING FC_EXIDV.

  ELSE.
*   Get External handling unit number from hu_com
    PERFORM F_GETEXIDBYBATCH1
      USING FU_BATCH
      CHANGING FC_EXIDV.

**   If not there then look in VEKP table
*    --NOTE: THIS IS NOT NEEDED SINCE ALL PACKED HU IS RECORDED IN HU_COM
*            (already checked in F_GETEXIDBYBATCH1)
*    IF FC_EXIDV IS INITIAL.
*      SELECT SINGLE venum INTO vepo-venum FROM vepo WHERE charg = zpack00-chargdc
*        %_HINTS ORACLE 'INDEX(VEPO"Z03")'.
*
*      IF sy-subrc = 0.
*        SELECT SINGLE exidv INTO vekp-exidv FROM vekp WHERE venum = vepo-venum.
*        FC_EXIDV = VEKP-EXIDV.
*      ENDIF.
*
*    ENDIF.
*
  ENDIF.

  IF FC_EXIDV IS NOT INITIAL.
    MESSAGE S000(0K) WITH
      '* Batch Number Already in Used for HU' FC_EXIDV.
    EXIT.
  ENDIF.


ENDFORM.                    " F_GETEXIDBYBATCH


*&---------------------------------------------------------------------*
*&      Form  F_GETCLOSEDBATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IT_CHARG[]  text
*----------------------------------------------------------------------*
FORM F_GETCLOSEDBATCH.
  REFRESH IT_CHARG.

*- update for RTS
  IF SY-TCODE = 'ZHU5FSR'.
    SELECT MSKA~CHARG
      INTO TABLE IT_CHARG
      FROM VEKP INNER JOIN VEVW
        ON VEKP~HANDLE = VEVW~HANDLE
        INNER JOIN MSKA
        ON VEKP~EXIDV = MSKA~CHARG
      WHERE MSKA~VBELN = ZPACK00-VBELN
        AND MSKA~POSNR = ZPACK00-POSNR
        AND MSKA~KAEIN NE 0
        AND ( ( MSKA~LGORT <> '1302' )
          OR  ( MSKA~LGORT <> '1802' )
          OR  ( MSKA~LGORT <> '2302' )
          OR  ( MSKA~LGORT <> '2802' ) ).
  ELSE.
    SELECT MSKA~CHARG
      INTO TABLE IT_CHARG
      FROM VEKP INNER JOIN VEVW
        ON VEKP~HANDLE = VEVW~HANDLE
        INNER JOIN MSKA
        ON VEKP~EXIDV = MSKA~CHARG
      WHERE MSKA~VBELN = ZPACK00-VBELN
        AND MSKA~POSNR = ZPACK00-POSNR
        AND MSKA~KALAB NE 0
        AND ( ( MSKA~LGORT <> '1302' )
          OR  ( MSKA~LGORT <> '1802' )
          OR  ( MSKA~LGORT <> '2302' )
          OR  ( MSKA~LGORT <> '2802' ) ).

  ENDIF.
ENDFORM.                    " F_GETCLOSEDBATCH

*&---------------------------------------------------------------------*
*&      Form  f_read_batch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_READ_BATCH .
  DATA EX TYPE REF TO CX_ROOT.

  TRY.
      IF SY-TCODE = 'ZHU5FS'.
        PERFORM F_LOCK_BATCH USING ZPACK00-CHARGDC.
      ENDIF.

      ZPACK00-CHARG = ZPACK00-CHARGDC.
      CASE GB_IS_NEW_BATCH.
        WHEN V_YES.
          PERFORM F_READ_BATCH_NEW.

        WHEN V_NO.
          PERFORM F_READ_BATCH_OLD.

        WHEN OTHERS.
          MESSAGE S001(00) WITH 'Input tidak benar.'.

      ENDCASE.

      PERFORM F_UNLOCK_BATCH USING ZPACK00-CHARGDC GS_COMPUTER_NAME SY-UNAME.

    CATCH CX_ROOT INTO EX.
      DATA S_MSG(100).
      DATA MSG TYPE REF TO IF_MESSAGE.

      MSG = EX.
      S_MSG = MSG->GET_TEXT( ).
      MESSAGE S001(00) WITH S_MSG.

  ENDTRY.

ENDFORM.                    " f_read_batch


*&---------------------------------------------------------------------*
*&      Form  f_read_batch_old
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_READ_BATCH_OLD .
  DATA: COUNT TYPE P.

  ZPACK00-CHARGDC = ZPACK00-CHARGDC+7(10).

* Check Stock > 0
  SELECT SINGLE MATNR KALAB VBELN POSNR
    INTO (MSKA-MATNR,MSKA-KALAB,MSKA-VBELN,MSKA-POSNR)
    FROM MSKA
    WHERE WERKS = HUPAST_T-PLANT
       AND LGORT = HUPAST_T-STGE_LOC
       AND CHARG = ZPACK00-CHARG
       AND KALAB > 0.

  IF SY-SUBRC NE 0.
    MESSAGE I000(0K) WITH
      '* Batch Number Does Not Exist or Stock not available.'.

    RETURN.

  ENDIF.

* Check Batch Packed
  SELECT COUNT(*) INTO COUNT FROM VEPO WHERE CHARG = ZPACK00-CHARGDC.
  IF SY-SUBRC = 0.
    MESSAGE I000(0K) WITH
      '* Batch Number Has already packed.'.

    RETURN.
  ENDIF.

   *ZPACK00 = ZPACK00.
  CTR1 = CTR2 = CTR3 = PAGEBEGIN = 0.

  IF ZPACK00-MATNR0 NE MSKA-MATNR.
*   Material Master - Get Base Unit of Measure and Name
    PERFORM F_GET_MATERIAL_MASTER USING ZPACK00-MATNR0
          CHANGING ZPACK00-MEINS0 MAKT-MAKTX MARA-MTART.

    ZPACK00-MATNR0 = MSKA-MATNR.
    ZPACK00-MATNR1 = MSKA-MATNR.      "Used for searching in process (key)

    IF ( MARA-MTART NE 'ZPCK' )
      AND ( MARA-MTART NE 'ZRTP' ).
      D_MATERIALTYPEOK = 'X'.

    ELSE.
      CLEAR D_MATERIALTYPEOK.

    ENDIF.

  ENDIF.

* Check Current Sales Order Nr and if different then
* update SO and Customer data in memory.
  DATA:
    DREADSO TYPE FLAG,
    DREGENERATE TYPE FLAG.

* Store last vbeln and last posnr for data unlocking purpose
  DLASTVBELN = ZPACK00-VBELN.
  DLASTPOSNR = ZPACK00-POSNR.

  IF DLASTVBELN NE MSKA-VBELN. "-- AND dlastvbeln NE space.
    DREADSO = 'X'.  "-- need to reread so

  ELSE.
    CLEAR DREADSO.

  ENDIF.


  IF ( DREADSO IS NOT INITIAL ) OR ( DLASTPOSNR NE MSKA-POSNR ).
    DREGENERATE = 'X'. "-- need to regenerate packing instruction

  ELSE.
    CLEAR DREGENERATE.

  ENDIF.

*- update for RTS
  IF SY-TCODE = 'ZHU5FSR'.
    ZPACK00-ZMENG  = MSKA-KAEIN.
  ELSE.
    ZPACK00-ZMENG  = MSKA-KALAB.
  ENDIF.
  ZPACK00-VBELN  = MSKA-VBELN.
  ZPACK00-POSNR  = MSKA-POSNR.

* Read Characteristics Specified
  PERFORM READ_CHARACTERISTICS CHANGING ZPACK00.

* Reread so and customer info if needed
  IF DREGENERATE IS NOT INITIAL.
    CLEAR : CHR1ST, GCHAR.

*   Build SONUM
    CONCATENATE ZPACK00-VBELN ZPACK00-POSNR INTO GSONUM.

  ENDIF.

  IF DREADSO IS NOT INITIAL.
*   Sales Order Header and customer info
    SELECT SINGLE VBELN AUART VBAK~KUNNR KNA1~KUNNR NAME1
      INTO (VBAK-VBELN, VBAK-AUART, VBAK-KUNNR, KNA1-KUNNR, KNA1-NAME1)
      FROM VBAK INNER JOIN KNA1 ON VBAK~KUNNR = KNA1~KUNNR
      WHERE VBELN = ZPACK00-VBELN
        AND KNA1~SPRAS = SY-LANGU.

    V_SO = ZPACK00-VBELN.
    PERFORM F_GET_DESTINATION USING V_SO.

    PERFORM F_RELOADMIRROR.
  ENDIF.

  IF VBAK-AUART(3) = 'ZDM'.
    SELECT SINGLE VBELN POSNR MATNR
      INTO (VBAP-VBELN,VBAP-POSNR,VBAP-MATNR)
      FROM VBAP WHERE VBELN = ZPACK00-VBELN
        AND POSNR = ZPACK00-POSNR.

    ZPACK00-MATNR1 = VBAP-MATNR.

    SELECT SINGLE *
      FROM MARA
      WHERE MATNR = ZPACK00-MATNR1
        AND MTART NE 'ZPCK'
        AND MTART NE 'ZRTP'.

    IF SY-SUBRC EQ 0.
      D_MATERIALTYPEOK = 'X'.

    ELSE.
      CLEAR D_MATERIALTYPEOK.

    ENDIF.

  ENDIF.


  IF DREGENERATE IS NOT INITIAL.
    PERFORM F_REFRESH.

  ENDIF.

  IF D_FATALERR IS INITIAL.
    PERFORM INSERT_BATCH.
    PERFORM AUTO_PACKING.

  ELSE.
    DREADSO = 'X'.

  ENDIF.

ENDFORM.                    " f_read_batch_old
*&---------------------------------------------------------------------*
*&      Form  F_GET_DESTINATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SO  text
*----------------------------------------------------------------------*
FORM F_GET_DESTINATION  USING    P_V_SO.
  DATA : TVBPA LIKE VBPAVB OCCURS 0 WITH HEADER LINE,
         TVBADR LIKE SADRVB OCCURS 0 WITH HEADER LINE.
  DATA : ORT01 TYPE KNA1-ORT01,
         LANDX TYPE T005T-LANDX,
         LAND1 TYPE KNA1-LAND1.

  CLEAR : TVBPA . REFRESH : TVBPA.
  CHECK P_V_SO NE V_NO.

  CALL FUNCTION 'SD_PARTNER_READ'
    EXPORTING
      F_VBELN  = P_V_SO
      OBJECT   = 'VBPA'
    TABLES
      I_XVBPA  = TVBPA
      I_XVBADR = TVBADR.

  READ TABLE TVBPA WITH KEY PARVW = 'WE'.
  SELECT SINGLE KNA1~ORT01 KNA1~LAND1 INTO (ORT01,LAND1)
    FROM KNA1
    WHERE  KNA1~KUNNR = TVBPA-KUNNR.

  SELECT SINGLE T005T~LANDX INTO LANDX
    FROM T005T
    WHERE SPRAS = 'EN'
    AND   LAND1 = LAND1.

  CONCATENATE ORT01 LANDX INTO ZPACK00-DESI SEPARATED BY '-'.



ENDFORM.                    " F_GET_DESTINATION

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOCK_BATCH USING P_CHARG  .
  DATA : TLOCK TYPE SEQG3 OCCURS 0 WITH HEADER LINE.
  DATA : V_CHARG TYPE ZTLOCK-LOOBJ,
         MSG(200),
         MESSAGE TYPE SM04DIC-POPUPMSG,
         VAR1 TYPE ZPACK00-CHARGDC,
         VAR2 TYPE STRING,
         VAR3 TYPE SY-UNAME.


  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GUNAME = ''
    TABLES
      ENQ    = TLOCK.

  "-> cek bacth di lock?
  LOOP AT TLOCK WHERE GNAME = 'ZTLOCK'
                 AND   GOBJ  = 'EZGR'.
    IF TLOCK-GARG+3(10) = P_CHARG.
      SPLIT TLOCK-GARG AT '-' INTO VAR1 VAR2 VAR3.
      CONCATENATE 'Kemungkinan' P_CHARG 'di Lock / nyangkut oleh' VAR3 VAR2 INTO MSG SEPARATED BY SPACE.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF MSG = SPACE.  "-> ga dilock
    CONCATENATE P_CHARG GS_COMPUTER_NAME SY-UNAME INTO V_CHARG SEPARATED BY '-'.
    CALL FUNCTION 'ENQUEUE_EZGR'
      EXPORTING
        MODE_ZTLOCK    = 'E'
        MANDT          = SY-MANDT
        LOOBJ          = V_CHARG
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

  ELSE. "-> dilock

    CHECK VAR2 NE GS_COMPUTER_NAME AND VAR3 NE SY-UNAME.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TEXT_QUESTION         = MSG
        TEXT_BUTTON_1         = 'Pack'
        TEXT_BUTTON_2         = 'Tidak'
        DISPLAY_CANCEL_BUTTON = ''
        DEFAULT_BUTTON        = '2'
      IMPORTING
        ANSWER                = ANS.
    WAIT UP TO 5 SECONDS.
    IF ANS = '1'.
      CONCATENATE 'User' SY-UNAME 'PC' GS_COMPUTER_NAME
       'Akan menggunakan Batch' P_CHARG INTO MESSAGE SEPARATED BY SPACE.
      CALL FUNCTION 'TH_POPUP'
        EXPORTING
          CLIENT         = SY-MANDT
          USER           = VAR3
          MESSAGE        = MESSAGE
          MESSAGE_LEN    = '12'
        EXCEPTIONS
          USER_NOT_FOUND = 1.
      IF SY-SUBRC = 0.
        PERFORM F_UNLOCK_BATCH CHANGING P_CHARG VAR2 VAR3.
      ELSE.
*
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.



ENDFORM.                    " F_LOCK_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BATCH  text
*----------------------------------------------------------------------*
FORM F_UNLOCK_BATCH  USING    P_CHARG
                              P_COMPUTER
                              P_NAME .
  DATA : V_CHARG TYPE ZTLOCK-LOOBJ.
  CONCATENATE SY-MANDT P_CHARG '-' P_COMPUTER '-' P_NAME INTO V_CHARG  .

  CALL FUNCTION 'DEQUEUE_EZGR'
    EXPORTING
      MODE_ZTLOCK    = 'E'
      MANDT          = SY-MANDT
      LOOBJ          = V_CHARG
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
ENDFORM.                    " F_UNLOCK_BATCH