*----------------------------------------------------------------------*
* Report   ZHUI_PACKINST_ADD                                           *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: Manage Packing List                                     *
*                                                                      *
* Specification - MM                                                   *
* Abaper        - Bagus                                                *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~~               *
*----------------------------------------------------------------------*

PROGRAM  ZHUI_PACKINST_ADD.


TABLES: ZPACK_PCH, ZPACK_PC.

DATA ITAB_PCL TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
DATA ITAB_PC  TYPE TABLE OF ZPACK_PC WITH HEADER LINE.

DATA:
  BEGIN OF WA_MATERIAL,
    MATNR TYPE MATNR,
    VHART TYPE VHIART,
    MEINS TYPE MEINS,
    MAKTX TYPE MAKTX,
    MAGRV TYPE MAGRV,
  END OF WA_MATERIAL.

DATA:
  S_BOX TYPE MATNR,
  S_PALET TYPE MATNR,
  N_BOXCN TYPE I,
  N_PLTCN TYPE I,
  N_ROLCN TYPE I.

DATA:
  B_IS_REPLACE TYPE FLAG,
  S_PLTNO      TYPE NUMC2.


INCLUDE ZHUI_PACKINST_CONSTANTS.
INCLUDE ZHUI_PACKINST_ADD_PBO.
INCLUDE ZHUI_PACKINST_ADD_PAI.

**************
FORM F_ACTIVATE
  TABLES ITAB_PCL STRUCTURE ZPACK_PCL
  USING  FUWA_PC  STRUCTURE ZPACK_PC.

  DATA LD_SEQ_PALLET TYPE N LENGTH 4.
  DATA LD_SEQ_BOX TYPE N LENGTH 2.
  DATA LD_HUSEQ TYPE N LENGTH 6.

  SELECT MAX( HUSEQ ) INTO LD_HUSEQ
    FROM ZPACK_PCL
    WHERE PINNR = FUWA_PC-PINNR.

  IF SY-SUBRC NE 0.
    LD_HUSEQ = '000000'.
  ENDIF.

  LD_SEQ_PALLET = LD_HUSEQ(4).

  DO FUWA_PC-ZMENG TIMES.
    ADD 1 TO LD_SEQ_PALLET.
    LD_SEQ_BOX = 0.

    PERFORM F_ADD_PCL
      TABLES ITAB_PCL
      USING FUWA_PC LD_SEQ_PALLET LD_SEQ_BOX.

    PERFORM F_ADD_CHILDREN
      TABLES ITAB_PCL
      USING FUWA_PC LD_SEQ_PALLET LD_SEQ_BOX.
  ENDDO.
ENDFORM.                    "f_activate


*&---------------------------------------------------------------------*
*&      Form  f_add_pcl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_PCL         text
*      -->FU_PINS        text
*      -->FU_SEQ_PALLET  text
*      -->FU_SEQ_BOX     text
*----------------------------------------------------------------------*
FORM F_ADD_PCL  TABLES   FT_PCL STRUCTURE ZPACK_PCL
                USING    FU_PINS STRUCTURE ZPACK_PC
                         FU_SEQ_PALLET
                         FU_SEQ_BOX.

  DATA WA_PCL TYPE ZPACK_PCL.
  DATA LD_HUSEQ LIKE WA_PCL-HUSEQ.


  WA_PCL-PINNR = FU_PINS-PINNR.
  CONCATENATE FU_SEQ_PALLET FU_SEQ_BOX INTO WA_PCL-HUSEQ.

  IF FU_SEQ_BOX = 0.
    WA_PCL-HUSEQ_P = '000000'.
    WA_PCL-ZINS02 = '00'.

  ELSE.
    CONCATENATE FU_SEQ_PALLET '00' INTO WA_PCL-HUSEQ_P.
    WA_PCL-ZINS02 = FU_PINS-ZINS02.
  ENDIF.

  WA_PCL-ZINS01 = FU_PINS-ZINS01.
  WA_PCL-HUSTAT =   C_HUSTAT_OPEN.
  CLEAR WA_PCL-VENUM.
  CLEAR WA_PCL-PACKED.
  WA_PCL-MEINS  = FU_PINS-MEINS.
  CLEAR WA_PCL-PACKING_STATION.
  WA_PCL-AENAM  = SY-UNAME.
  WA_PCL-AEDAT  = SY-DATUM.
  WA_PCL-AETIM  = SY-UZEIT.
  WA_PCL-PRSTAT = C_PRSTAT_NOTPRINTED.

  APPEND WA_PCL TO FT_PCL.
ENDFORM.                    " f_add_pcl


*&---------------------------------------------------------------------*
*&      Form  f_add_children
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_PCL         text
*      -->FU_PINS        text
*      -->FU_SEQ_PALLET  text
*      -->FU_SEQ_BOX     text
*----------------------------------------------------------------------*
FORM F_ADD_CHILDREN TABLES FT_PCL STRUCTURE ZPACK_PCL
                    USING  FU_PINS STRUCTURE ZPACK_PC
                           FU_SEQ_PALLET
                           FU_SEQ_BOX.

  LOOP AT ITAB_PC
    WHERE ZINS01 = FU_PINS-ZINS01
      AND INILVL = C_LEVEL_BOX.

    DO ITAB_PC-ZMENG TIMES.
      ADD 1 TO FU_SEQ_BOX.

      PERFORM F_ADD_PCL
        TABLES FT_PCL
        USING ITAB_PC FU_SEQ_PALLET FU_SEQ_BOX.

    ENDDO.

  ENDLOOP.

ENDFORM.                    " f_add_children

*&---------------------------------------------------------------------*
*&      Form  f_add_instruction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADD_INSTRUCTION .
  DATA N_COUNT TYPE N LENGTH 2.
  DATA EX TYPE REF TO CX_ROOT.
  DATA N_ERRNO TYPE I.
  DATA N_QTY TYPE I.
  DATA S_TCODE LIKE SY-TCODE.
  DATA SHEET.

  PERFORM CHECK_MATPALT_PLANT. "ADD NEW COMPANY

  TRY.
      GET PARAMETER ID 'TSOURCE' FIELD S_TCODE.

*      IF s_tcode = 'ZHU4SO' OR s_tcode = 'ZHU4FS'.
      IF S_TCODE IS INITIAL.
        PERFORM F_LOCK CHANGING N_ERRNO.
      ENDIF.

      CHECK N_ERRNO EQ 0.

      IF B_IS_REPLACE = 'X'.
        SELECT COUNT( * ) INTO N_QTY FROM ZPACK_PCL
          WHERE PINNR = ZPACK_PCH-PINNR
            AND HUSEQ_P = '000000'
            AND ZINS01 = S_PLTNO
            AND HUSTAT NE C_HUSTAT_OPEN.

        IF N_QTY > 0.
          MESSAGE I000(0K) WITH 'This pallet instruction is already used.'.
          RETURN.

        ELSE.
          DELETE FROM ZPACK_PC
            WHERE PINNR = ZPACK_PCH-PINNR
              AND ZINS01 = S_PLTNO.


          DELETE FROM ZPACK_PCL
            WHERE PINNR = ZPACK_PCH-PINNR
              AND ZINS01 = S_PLTNO.


          DATA:
          LD_SUBRC(2),
          LD_PACKED(18),
          LD_DESCR TYPE TEXT255.

          MOVE SY-SUBRC TO LD_SUBRC.

          CONCATENATE '(' LD_SUBRC ') F_ADD_INSTRUCTION, DELETE 1 RECORD, ZINS01=' S_PLTNO INTO LD_DESCR.


          N_COUNT = S_PLTNO.

        ENDIF.

      ELSE.
        SELECT MAX( ZINS01 ) INTO N_COUNT FROM ZPACK_PC
          WHERE PINNR = ZPACK_PCH-PINNR.

        ADD 1 TO N_COUNT.
      ENDIF.

      SELECT SINGLE ZZSHEET INTO SHEET
        FROM ZPACK_PCH
        WHERE PINNR = ZPACK_PCH-PINNR
        AND   VBELN = ZPACK_PCH-VBELN
        AND   POSNR = ZPACK_PCH-POSNR.

      ITAB_PC-PINNR  = ZPACK_PCH-PINNR.
      ITAB_PC-ZINS01 = N_COUNT.
      ITAB_PC-INILVL = C_LEVEL_PALLET.
      ITAB_PC-MATNR  = S_PALET.
      ITAB_PC-ZMENG  = N_PLTCN.
      ITAB_PC-MEINS  = 'UNT'.

      APPEND ITAB_PC.

      ITAB_PC-ZINS02 = '1'.

      IF S_BOX IS NOT INITIAL.
        IF N_BOXCN IS INITIAL.
          N_BOXCN = 1.
        ENDIF.

        ITAB_PC-INILVL = C_LEVEL_BOX.
        ITAB_PC-MATNR  = S_BOX.
        ITAB_PC-ZMENG  = N_BOXCN.
        ITAB_PC-MEINS  = 'BOX'.
        APPEND ITAB_PC.

        ITAB_PC-ZINS03 = '1'.

      ENDIF.

      ITAB_PC-INILVL = C_LEVEL_ROLL.
      ITAB_PC-MATNR  = ZPACK_PCH-MATNR.
      ITAB_PC-ZMENG  = N_ROLCN.
      IF SHEET = 'X'.
        ITAB_PC-MEINS  = 'PAK'.
      ELSE.
        ITAB_PC-MEINS  = 'ROL'.
      ENDIF.
      APPEND ITAB_PC.

      INSERT ZPACK_PC FROM TABLE ITAB_PC.

      ZPACK_PCH-AENAM = SY-UNAME.
      ZPACK_PCH-AEDAT = SY-DATUM.
      ZPACK_PCH-AETIM = SY-UZEIT.

      IF ZPACK_PCH-PINST EQ C_PINST_INACTIVE.
        UPDATE ZPACK_PCH FROM ZPACK_PCH.

      ELSE.
        IF ZPACK_PCH-PINST NE C_PINST_ACTIVE.
          ZPACK_PCH-PINST = C_PINST_INPROGRESS.
        ENDIF.
        UPDATE ZPACK_PCH FROM ZPACK_PCH.

        READ TABLE ITAB_PC INDEX 1.
        PERFORM F_ACTIVATE TABLES ITAB_PCL USING ITAB_PC.
      ENDIF.

      INSERT ZPACK_PCL FROM TABLE ITAB_PCL.
      COMMIT WORK AND WAIT.

      IF B_IS_REPLACE = 'X'.
        MESSAGE S001(00) WITH 'Packing instruction untuk palet berhasil diubah.'.
      ELSE.
        MESSAGE S001(00) WITH 'Packing instruction selesai ditambahkan.'.
      ENDIF.

      IF S_TCODE IS INITIAL.
        PERFORM F_UNLOCK.
      ENDIF.

      REFRESH:
        ITAB_PC,
        ITAB_PCL.

      CLEAR:
        ZPACK_PCH,
        S_PALET, N_PLTCN, S_BOX, N_BOXCN, N_ROLCN, S_PLTNO, B_IS_REPLACE.

      GET PARAMETER ID 'TSOURCE' FIELD S_TCODE.
      IF S_TCODE = 'ZHU4SO' OR S_TCODE = 'ZHU4FS' OR S_TCODE = 'ZAHU4SO' OR S_TCODE = 'ZAHU4FS'. "ADD NEW COMPANY
        LEAVE PROGRAM.
      ENDIF.

    CATCH CX_ROOT INTO EX.
      ROLLBACK WORK.
      MESSAGE S001(00) WITH
      'Packing instruction tidak dapat ditambahkan.'.

  ENDTRY.

ENDFORM.                    " f_add_instruction


*&---------------------------------------------------------------------*
*&      Form  f_check_pallet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_PALLET .
  DATA S_MESSAGE(50).
  DATA S_TEXT TYPE MAKTX.
  DATA N_ERRNO TYPE I.

  IF N_PLTCN = 0.
    MESSAGE E001(00) WITH 'Masukkan jumlah pallet'.
    RETURN.
  ENDIF.

  SELECT SINGLE MARA~MATNR MARA~VHART MEINS MAKTX MAGRV INTO WA_MATERIAL
    FROM MARA INNER JOIN MAKT ON MARA~MATNR = MAKT~MATNR
    WHERE MARA~MATNR = S_PALET
      AND SPRAS = SY-LANGU.

  N_ERRNO = SY-SUBRC.
  IF N_ERRNO EQ 0.
    IF WA_MATERIAL-MAGRV NE 'PLT'.
      N_ERRNO = 4.
    ENDIF.
  ENDIF.

  IF N_ERRNO NE 0.
    MESSAGE E001(00) WITH 'Material ' S_PALET ' bukan pallet.'.
  ENDIF.

ENDFORM.                    " f_check_pallet


*&---------------------------------------------------------------------*
*&      Form  f_check_box
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_BOX .
  DATA S_MESSAGE(50).
  DATA S_TEXT TYPE MAKTX.
  DATA N_ERRNO TYPE I.

  IF N_BOXCN = 0.
    MESSAGE E001(00) WITH 'Masukkan jumlah box'.
    RETURN.
  ENDIF.

  SELECT SINGLE MARA~MATNR MARA~VHART MEINS MAKTX MAGRV INTO WA_MATERIAL
    FROM MARA INNER JOIN MAKT ON MARA~MATNR = MAKT~MATNR
    WHERE MARA~MATNR = S_BOX
      AND SPRAS = SY-LANGU.

  N_ERRNO = SY-SUBRC.

  IF N_ERRNO EQ 0.
    IF WA_MATERIAL-MAGRV NE 'BOX'.
      N_ERRNO = 4.
    ENDIF.
  ENDIF.

  IF N_ERRNO NE 0.
    MESSAGE E001(00) WITH 'Material ' S_BOX ' bukan untuk box'.
  ENDIF.

ENDFORM.                    " f_check_box


*&---------------------------------------------------------------------*
*&      Form  f_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_LOCK CHANGING FCN_ERRNO .
  CALL FUNCTION 'ENQUEUE_EZPACK_PCH'
    EXPORTING
      MODE_ZPACK_PCH = 'X'
      MODE_ZPACK_PC  = 'X'
      MANDT          = SY-MANDT
      PINNR          = ZPACK_PCH-PINNR
      _WAIT          = 'X'
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
    DATA N_ERRNO TYPE I.
    PERFORM F_LOCK_LIST CHANGING FCN_ERRNO.
    IF FCN_ERRNO NE 0.
      PERFORM F_UNLOCK.

    ENDIF.
  ENDIF.

ENDFORM.                    " f_lock

*&---------------------------------------------------------------------*
*&      Form  f_lock_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_LOCK_LIST  CHANGING FCN_ERRNO.
  DATA S_LOOBJ TYPE ZTLOCK-LOOBJ.
  DATA S_HUSEQ TYPE ZPACK_PCL-HUSEQ.
  DATA ITAB_LOCKED TYPE TABLE OF ZTLOCK-LOOBJ WITH HEADER LINE.

  SELECT HUSEQ INTO S_HUSEQ
    FROM ZPACK_PCL
    WHERE PINNR = ZPACK_PCH-PINNR
      AND HUSEQ_P = '000000'.

    CONCATENATE 'PCL' ZPACK_PCH-PINNR S_HUSEQ INTO S_LOOBJ.
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
    IF FCN_ERRNO EQ 0.
      APPEND S_LOOBJ TO ITAB_LOCKED.

    ELSE.
      LOOP AT ITAB_LOCKED.
        CALL FUNCTION 'DEQUEUE_EZPACK_PCL'
          EXPORTING
            LOOBJ = ITAB_LOCKED.

      ENDLOOP.
      MESSAGE E001(00) WITH 'Pallet sedang diproses.'.
      RETURN.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " f_lock_list


*&---------------------------------------------------------------------*
*&      Form  f_unlock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UNLOCK .
  DATA S_LOOBJ TYPE ZTLOCK-LOOBJ.
  DATA S_HUSEQ TYPE ZPOSNR_PL.

  CALL FUNCTION 'DEQUEUE_EZPACK_PCH'
    EXPORTING
      MODE_ZPACK_PCH = 'X'
      MODE_ZPACK_PC  = 'X'
      MANDT          = SY-MANDT
      PINNR          = ZPACK_PCH-PINNR.

  SELECT HUSEQ INTO S_HUSEQ
    FROM ZPACK_PCL
    WHERE PINNR = ZPACK_PCH-PINNR
      AND HUSEQ_P = '000000'.

    CONCATENATE 'PCL' ZPACK_PCH-PINNR S_HUSEQ INTO S_LOOBJ.
    CALL FUNCTION 'DEQUEUE_EZPACK_PCL'
      EXPORTING
        LOOBJ = S_LOOBJ.
  ENDSELECT.

ENDFORM.                    " f_unlock

*&---------------------------------------------------------------------*
*&      Form  f_search_packing_instruction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SEARCH_PACKING_INSTRUCTION .
  DATA LT_RETVAL TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA NCOUNT TYPE I.

  DATA:
    BEGIN OF ITAB_SELECTION OCCURS 0,
      PINNR  TYPE ZPINNR,
      VBELN  TYPE VBELN_VA,
      POSNR  TYPE POSNR_VA,
      DESCR  TYPE TEXT50,
      MATNR  TYPE MATNR,
      CRNAM  TYPE CRNAM,
      CRDAT  TYPE CRDAT,
      CRTIM  TYPE ERZET,
      AENAM  TYPE AENAM,
      AEDAT  TYPE AEDAT,
      AETIM  TYPE AEZEIT,
    END OF ITAB_SELECTION.

  DATA ITAB_PCH TYPE TABLE OF ZPACK_PCH WITH HEADER LINE.

  SELECT * INTO TABLE ITAB_PCH
    FROM ZPACK_PCH
    WHERE ( PINST = C_PINST_INPROGRESS
      OR  PINST = C_PINST_COMPLETED )
      AND LOEVR = SPACE.

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
      ZPACK_PCH-PINNR = ITAB_PCH-PINNR.
      ZPACK_PCH-VBELN = ITAB_PCH-VBELN.
      ZPACK_PCH-POSNR = ITAB_PCH-POSNR.

    ENDIF.

  ENDIF.
ENDFORM.                    " f_search_packing_instruction

*&---------------------------------------------------------------------*
*&      Form  CHECK_MATPALT_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_MATPALT_PLANT.
  DATA:PLANT_SO LIKE VBAP-WERKS,
       TCODE LIKE SY-TCODE.

  RANGES:PLANT_MAT FOR MARC-WERKS.

  DATA: BEGIN OF IT_PLANT OCCURS 0,
          WERKS LIKE MARC-WERKS,
        END OF IT_PLANT.

  CLEAR: IT_PLANT,PLANT_MAT.
  REFRESH: IT_PLANT,PLANT_MAT.

  GET PARAMETER ID 'TSOURCE' FIELD TCODE.

  IF TCODE EQ 'ZHU4SO' OR TCODE EQ 'ZAHU4SO'.
    SELECT SINGLE WERKS FROM VBAP INTO (PLANT_SO)
    WHERE VBELN EQ ZPACK_PCH-VBELN
    AND POSNR EQ ZPACK_PCH-POSNR.

    SELECT WERKS FROM MARC INTO TABLE IT_PLANT
      WHERE MATNR EQ S_PALET.

    LOOP AT IT_PLANT.
      PLANT_MAT-SIGN = 'I'.
      PLANT_MAT-OPTION = 'EQ'.
      PLANT_MAT-LOW = IT_PLANT-WERKS.
      APPEND PLANT_MAT.
    ENDLOOP.

    IF PLANT_SO NOT IN PLANT_MAT.
      MESSAGE 'Material Pallet Tidak Berada Pada Plant SO' TYPE 'I'.
      LEAVE TO SCREEN 9000.
    ENDIF.

    IF S_BOX IS NOT INITIAL.
      CLEAR: IT_PLANT,PLANT_MAT.
      REFRESH: IT_PLANT,PLANT_MAT.

      SELECT WERKS FROM MARC INTO TABLE IT_PLANT
      WHERE MATNR EQ S_BOX.

      LOOP AT IT_PLANT.
        PLANT_MAT-SIGN = 'I'.
        PLANT_MAT-OPTION = 'EQ'.
        PLANT_MAT-LOW = IT_PLANT-WERKS.
        APPEND PLANT_MAT.
      ENDLOOP.

      IF PLANT_SO NOT IN PLANT_MAT.
        MESSAGE 'Material Box Tidak Berada Pada Plant SO' TYPE 'I'.
        LEAVE TO SCREEN 9000.
      ENDIF.

    ENDIF.


  ELSEIF TCODE EQ 'ZHU4FS' OR TCODE EQ 'ZAHU4FS'.
    GET PARAMETER ID 'PLANT' FIELD PLANT_SO.

    SELECT WERKS FROM MARC INTO TABLE IT_PLANT
      WHERE MATNR EQ S_PALET.

    LOOP AT IT_PLANT.
      PLANT_MAT-SIGN = 'I'.
      PLANT_MAT-OPTION = 'EQ'.
      PLANT_MAT-LOW = IT_PLANT-WERKS.
      APPEND PLANT_MAT.
    ENDLOOP.

    IF PLANT_SO NOT IN PLANT_MAT.
      MESSAGE 'Material Pallet Tidak Berada Pada Plant' TYPE 'I'.
      LEAVE TO SCREEN 9000.
    ENDIF.

    IF S_BOX IS NOT INITIAL.
      CLEAR: IT_PLANT,PLANT_MAT.
      REFRESH: IT_PLANT,PLANT_MAT.

      SELECT WERKS FROM MARC INTO TABLE IT_PLANT
      WHERE MATNR EQ S_BOX.

      LOOP AT IT_PLANT.
        PLANT_MAT-SIGN = 'I'.
        PLANT_MAT-OPTION = 'EQ'.
        PLANT_MAT-LOW = IT_PLANT-WERKS.
        APPEND PLANT_MAT.
      ENDLOOP.

      IF PLANT_SO NOT IN PLANT_MAT.
        MESSAGE 'Material Box Tidak Berada Pada Plant' TYPE 'I'.
        LEAVE TO SCREEN 9000.
      ENDIF.

    ENDIF.

  ENDIF.


ENDFORM.                    "CHECK_MATPALT_PLANT