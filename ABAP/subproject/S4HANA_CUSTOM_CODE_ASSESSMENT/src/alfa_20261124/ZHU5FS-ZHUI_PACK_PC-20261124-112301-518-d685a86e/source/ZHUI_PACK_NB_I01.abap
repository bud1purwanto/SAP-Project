*&---------------------------------------------------------------------*
*&  Include           ZHU_PACK_NB_I01                                  *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  read_packing_station  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_PACKING_STATION INPUT.
  DATA : VUNVEL TYPE VEPO-UNVEL.
  CLEAR : VCHARG,VUNVEL.
  IF RB2 = V_YES .

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = GS_EXIDV
      IMPORTING
        OUTPUT = GS_EXIDV.

    PERFORM GET_HUPLANT USING GS_EXIDV. "ADD NEW COMPANY

    PERFORM CHECK_AUTH_SLOC CHANGING V_ERRNO.
    IF V_ERRNO NE 0.
      RETURN.
    ENDIF.

    SELECT  ZPACK_PCL~PACKING_STATION ZPACK_PCL~PINNR VEPO~CHARG VEPO~UNVEL
      INTO (HUM_PROFILE_S-PACKING_STATION,GWA_PCH-PINNR,VCHARG,VUNVEL )
      FROM VEKP
      JOIN ZPACK_PCL ON VEKP~VENUM = ZPACK_PCL~VENUM
      JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV = GS_EXIDV.

      IF VUNVEL NE ''.
        SELECT SINGLE VEPO~CHARG INTO VCHARG
          FROM VEPO
          WHERE VEPO~VENUM = VUNVEL.
      ELSE.
        EXIT.
      ENDIF.

    ENDSELECT.
    IF GWA_PCH-PINNR = ''.
      MESSAGE I000(0K) WITH '* HU Number Does Not Exist.'.
      RETURN.
    ENDIF.
  ENDIF.

  CHECK HUM_PROFILE_S-PACKING_STATION NE SPACE.
  CLEAR : GCHAR.
  SELECT SINGLE * FROM HUPAST_T
                  WHERE PACKING_STATION = HUM_PROFILE_S-PACKING_STATION.

  IF SY-SUBRC NE 0.
    CLEAR HUM_PROFILE_S-PACKING_STATION.
    MESSAGE I000(0K) WITH '* Packing Station Does Not Exist.'.
  ELSE.
     *HUPAST_T = HUPAST_T.
  ENDIF.
  SELECT SINGLE * FROM T001W WHERE WERKS = HUPAST_T-PLANT.
  SELECT SINGLE * FROM T001L WHERE WERKS = HUPAST_T-PLANT
                               AND LGORT = HUPAST_T-STGE_LOC.
   *T001L = T001L.
  SELECT SINGLE * FROM T001L WHERE WERKS = HUPAST_T-PLANT
                               AND LGORT = HUPAST_T-HU_STGE_LOC.

ENDMODULE.                 " read_packing_station  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  OK_CODE = SY-UCOMM.
  CLEAR : SY-UCOMM,ERROR.
  CASE OK_CODE.
    WHEN 'ENTR' .
      CHECK NOT HUM_PROFILE_S-PACKING_STATION IS INITIAL.
      ZPACK00-WERKS = HUPAST_T-PLANT.
      IF SY-TCODE = 'ZHU5FS' .
        CHECK GWA_PCH-PINNR NE '' .
        PERFORM LOCK_FS.
      ENDIF.
      PERFORM F_UNLOCK_NEW.
      PERFORM F_RESET_ALL.
      PERFORM F_READ_GRADE_CRITERIA.
      IF ERROR = ''.
        SET SCREEN 200.
      ELSE.
        SET SCREEN 120.
      ENDIF.

    WHEN 'EXIT'.
      PERFORM F_UNLOCK_NEW.
      PERFORM DELETE_LOCK_FS  USING VLOCK .
      LEAVE TO SCREEN 10.

  ENDCASE.
ENDMODULE.                 " user_command_0100  INPUT


*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  OK_CODE = SY-UCOMM.
  CLEAR SY-UCOMM.

  CASE OK_CODE.
    WHEN 'COMPLETE'.
      CASE GWA_HU_PALLET-HUSTAT.
        WHEN C_HUSTAT_COMPLETED OR C_HUSTAT_FORCED OR V_YES.
          MESSAGE I000(0K) WITH 'HU Sudah Terpenuhi.....'.
          RETURN.
      ENDCASE.

*- check authori by ALF at 09-01-2014
      LOOP AT HU_COM WHERE EXID NE ''.
        PERFORM CHECK_AUTH_BATCH USING HU_COM-EXID SY-TCODE CHANGING V_ERRNO.
        IF V_ERRNO NE 0.
          RETURN.
        ENDIF.
      ENDLOOP.
*-

      IF GB_IS_NEW_BATCH = V_YES.
        PERFORM F_FORCE_TO_COMPLETE.
      ENDIF.

    WHEN 'PRINT'.
      IF GB_IS_NEW_BATCH = V_YES.
        PERFORM F_HU_PRINT_SELECTION USING V_NO.
        CALL SCREEN '0220'.
        PERFORM F_HU_PRINT_MASS.
      ENDIF.

    WHEN 'REFRESH'.
      IF DLASTVBELN IS NOT INITIAL.
        PERFORM F_REFRESH.
      ENDIF.

    WHEN 'UNPACK'.
      REFRESH ITAB_UNPACK_TASK.

    WHEN 'HULIST'.
      IF ZPACK00-CHARGDC IS INITIAL.
        MESSAGE I000(0K) WITH '* Enter Batch Number !'.
        EXIT.
      ENDIF.
*     Get SONUM and Exist Pack
      CONCATENATE ZPACK00-VBELN ZPACK00-POSNR INTO GSONUM.
      REFRESH PACKG.
      SELECT VENUM  INTO VEPO-VENUM FROM VEPO
                    WHERE SONUM = GSONUM.
        SELECT SINGLE EXIDV VHILM INTO (VEKP-EXIDV, VEKP-VHILM)
                      FROM VEKP WHERE VENUM = VEPO-VENUM.
        CHECK SY-SUBRC = 0.
*       WRITE : / vekp-exidv, vekp-vhilm.
        WRITE VEKP-EXIDV TO PACKG-VALUE.
        CONCATENATE PACKG-VALUE '-' VEKP-VHILM INTO PACKG-VALUE
                    SEPARATED BY SPACE.
*        COLLECT packg.
        APPEND PACKG.
      ENDSELECT.

      CHECK NOT PACKG[] IS INITIAL.
      SORT PACKG DESCENDING.
      CALL FUNCTION 'MC_POPUP_TO_MARK_VALUES'
        EXPORTING
          I_MIN_MARKED_VALUES  = 0
          I_POPUP_TITLE        = 'HU Created By Sales Order/Item nr.'
*         i_textline           = 'HU already .. '
          I_TEXT_LENGTH        = 40
          I_ICONINFO_FOR_ENTER = 'Select Packaging material'
        TABLES
          T_VALUES_FOR_MARKING = PACKG
        EXCEPTIONS
          CANCEL_PUSHED        = 1
          OTHERS               = 2.

    WHEN 'BACK'.
      IF GB_IS_NEW_BATCH = V_NO.
        PERFORM POPUP_HU_HU CHANGING ANS.
        IF ANS = 'A' OR ANS = '2'.
          EXIT.
        ENDIF.
        IF ANS = '1'.
*         zpack00-chargdc = *zpack00-chargdc.
          PERFORM DELETE_HU_HU.
        ENDIF.

        REFRESH : HU_COM, HU_TMP, HU_HU, HU_NEU.
        CLEAR   : CTR1, CTR2, CTR3, HUM_PROFILE_S, GTABIX, GCHAR.
        CLEAR   : ZPACK00, *ZPACK00, HUPAST_T, MSKA, MARA, MAKT, VBAK,
        KNA1,
                  T001W, *T001L, T001L.

        PERFORM F_UNLOCK.

      ELSE.
        PERFORM F_UNLOCK_NEW.
        PERFORM F_RESET_ALL.

      ENDIF.

      IF SY-TCODE = 'ZHU5FS' OR  SY-TCODE = 'ZHU5FSR'.
        PERFORM DELETE_LOCK_FS  USING VLOCK .
      ENDIF.

      IF GB_IS_FREESTOCK = V_YES.
        SET SCREEN 120.
      ELSE.
        SET SCREEN 100.
      ENDIF.

    WHEN 'TOP'.
      PAGEBEGIN = 0.

    WHEN 'PGUP'.
      IF PAGEBEGIN >= MAXLOOP.
        PAGEBEGIN = PAGEBEGIN - MAXLOOP.
      ELSE.
        PAGEBEGIN = 0.
      ENDIF.

    WHEN 'PGDN'.
      DESCRIBE TABLE HU_COM LINES MAXLINE.
*      IF maxline >= maxloop.
*        pagebegin = maxline - maxloop.
*      ELSE.
      PAGEBEGIN = PAGEBEGIN + MAXLOOP.
      IF PAGEBEGIN > MAXLINE.
        PAGEBEGIN = MAXLINE.
      ENDIF.
*      ENDIF.

    WHEN 'END'.
      DESCRIBE TABLE HU_COM LINES MAXLINE.
      IF MAXLINE >= MAXLOOP.
        PAGEBEGIN = MAXLINE - MAXLOOP.
      ENDIF.

    WHEN 'PREV'.
      PAGEBEGIN = PAGEBEGIN - 1.
      IF PAGEBEGIN < 1.
        PAGEBEGIN = 0.
      ENDIF.

    WHEN 'NEXT'.
      PAGEBEGIN = PAGEBEGIN + 1.

    WHEN 'CLOSE'.
      IF GB_IS_NEW_BATCH = V_YES.
        IF ( GWA_HU_PALLET-HUSTAT = C_HUSTAT_COMPLETED )
          OR ( GWA_HU_PALLET-HUSTAT = C_HUSTAT_FORCED )
*          AND ( gwa_hu_pallet-prstat = c_prstat_labelandreport )
          .
          DATA N_ERRNO TYPE I.

          PERFORM F_HU_CLOSE_NEW CHANGING N_ERRNO.
        ELSE.
          MESSAGE S000(0K) WITH 'Pallet belum bisa di-closing'.
        ENDIF.
      ENDIF.

  ENDCASE.
ENDMODULE.                 " user_command_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  read_batch  INPUT
*&---------------------------------------------------------------------*
MODULE READ_BATCH INPUT.
  CLEAR : N_ERRNO.
  PERFORM F_CHECK_BATCH_SLOC CHANGING N_ERRNO.
  CHECK N_ERRNO EQ 0.
  PERFORM F_CHECK_BATCH_SO USING ZPACK00-CHARGDC '' HUPAST_T-PLANT CHANGING N_ERRNO.
  CHECK N_ERRNO EQ 0.

  CHECK SY-UCOMM EQ SPACE.
  PERFORM F_READ_BATCH.

ENDMODULE.                 " read_batch  INPUT


*&---------------------------------------------------------------------*
*&      Module  update_instruction  INPUT
*&---------------------------------------------------------------------*
MODULE UPDATE_INSTRUCTION INPUT.

  CHECK NOT ZPACK00-VBELN IS INITIAL.
  READ_IDX = PAGEBEGIN + SY-STEPL.
  READ TABLE HU_COM INDEX READ_IDX.
  IF HU_COM-POSNR NE ZPACK00-POSNR.
    HU_COM-POSNR = ZPACK00-POSNR.
  ENDIF.

  HU_COM-INS0  = ZPACK00-ZINS01.
  HU_COM-INS1  = ZPACK00-ZINS02.
  HU_COM-INS2  = ZPACK00-ZINS03.
  HU_COM-INST  = ZPACK00-MATNR.
  HU_COM-EXID  = ZPACK00-EXIDV.
  HU_COM-STAT  = ZPACK00-STAT.

* Update insertion table
  IF HU_COM-TABIX NE 0.

    READ TABLE HU_NEU WITH KEY TABIX = HU_COM-TABIX.

    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING HU_COM TO HU_NEU.
      MODIFY HU_NEU INDEX SY-TABIX.
    ENDIF.

    CONDENSE : HU_COM-INS0, HU_COM-INS1, HU_COM-INS2, HU_COM-STAT.

    IF SY-SUBRC = 0.
      MODIFY HU_COM INDEX READ_IDX.
      SORT HU_COM.
    ELSE.
      APPEND HU_COM.
    ENDIF.
  ENDIF.
ENDMODULE.                 " update_instruction  INPUT
*
**&---------------------------------------------------------------------*
*&      Module  update_selection  INPUT
*&---------------------------------------------------------------------*
MODULE UPDATE_SELECTION INPUT.

  CHECK OK_CODE NE 'BACK'.
  CASE OK_CODE.
    WHEN 'CREATE'.
*     PERFORM hu_create.
      PERFORM HU_CREATE_BY_BDC.

    WHEN 'PACK'.
      IF ( ZPACK00-STAT = 'CLS' ).
        MESSAGE I000(0K) WITH '* Packing Not Allowed'.
        EXIT.
      ENDIF.
      CHECK NOT ZPACK00-EXIDV IS INITIAL.
      CLEAR HU_PACK.
      HU_PACK-POSNR = ZPACK00-POSNR.
      HU_PACK-INS0  = ZPACK00-ZINS01.
      HU_PACK-INS1  = ZPACK00-ZINS02.
      HU_PACK-INS2  = ZPACK00-ZINS03.
      HU_PACK-INST  = ZPACK00-MATNR.
      HU_PACK-EXID  = ZPACK00-EXIDV.
      COLLECT HU_PACK.

*   Close HU
    WHEN 'CLOSE'.
      IF GB_IS_NEW_BATCH = V_NO.
        PERFORM HU_CLOSE.
      ENDIF.

    WHEN 'UNPACK'.
      IF GB_IS_NEW_BATCH = V_YES.
*        READ TABLE hu_com WITH KEY exid = zpack00-exidv.
        HU_COM-SELE = V_YES.
        MODIFY HU_COM TRANSPORTING SELE WHERE EXID = ZPACK00-EXIDV.
        PERFORM F_ADD_UNPACK_MATERIAL_TASK USING ZPACK00-EXIDV.

      ELSE.
        PERFORM HU_UNPACKING.
      ENDIF.

    WHEN 'DISPLAY'.
      PERFORM HU_DISPLAY.

    WHEN 'PRINT'.
*     PERFORM hu_printing.
      IF GB_IS_NEW_BATCH = V_NO.
        PERFORM HU_PRINTING_BY_BDC.
      ENDIF.

    WHEN 'DELHU'.
      PERFORM HU_DELETION.

*   Insert Packing Instruction
    WHEN 'INSE'.
      GTABIX = GTABIX + 1.
      READ_IDX = PAGEBEGIN + SY-STEPL.
      READ TABLE HU_COM INDEX READ_IDX.
      CLEAR : HU_COM, HU_NEU.
      HU_COM-TABIX = GTABIX.
      HU_NEU-TABIX = GTABIX.
      INSERT HU_COM INDEX READ_IDX.
      APPEND HU_NEU.

*   Deleting Packing Instruction
    WHEN 'DELE'.
*      PERFORM DELETE_PACKING_INSTRUCTION.

    WHEN 'DESE'.
      LOOP AT HU_COM WHERE SELE = 'X'.
        HU_COM-SELE = ' '.
        MODIFY HU_COM INDEX SY-TABIX.
      ENDLOOP.
      CLEAR VSELEK.

  ENDCASE.
* Keep flag selection when the screen scrolling
  CHECK : OK_CODE NE 'DESE' AND OK_CODE NE 'UNPACK'.
  READ TABLE HU_COM WITH KEY POSNR = ZPACK00-POSNR
                             INS0  = ZPACK00-ZINS01
                             INS1  = ZPACK00-ZINS02
                             INS2  = ZPACK00-ZINS03
                             INST  = ZPACK00-MATNR
                             EXID  = ZPACK00-EXIDV.
  IF SY-SUBRC = 0.
    HU_COM-SELE = 'X'.
    MODIFY HU_COM INDEX SY-TABIX.
  ENDIF.

ENDMODULE.                 " update_selection  INPUT


*&---------------------------------------------------------------------*
*&      Module  next_processing  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE NEXT_PROCESSING INPUT.
  PERFORM F_NEXT_PROCESSING.
ENDMODULE.                 " next_processing  INPUT


*&---------------------------------------------------------------------*
*&      Module  SELECT_FREE_PINNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SELECT_FREE_PINNR INPUT.
  PERFORM F_SELECT_FREE_PINNR.

ENDMODULE.                 " SELECT_FREE_PINNR  INPUT


*&---------------------------------------------------------------------*
*&      Module  check_pinnr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PINNR INPUT.
  PERFORM F_CHECK_PINNR.

ENDMODULE.                 " check_pinnr  INPUT


*&---------------------------------------------------------------------*
*&      Module  check_batch_model  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BATCH_MODEL INPUT.
  PERFORM F_CHECK_BATCH_MODEL.
ENDMODULE.                 " check_batch_model  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0210 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'PRINT'.
      PERFORM F_HU_PRINT_NEW.

    WHEN 'CLOSE'.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0210  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0010 INPUT.
*- update for RTS
  IF SY-TCODE = 'ZHU5FS' OR SY-TCODE = 'ZHU5FSR'.
    SET SCREEN 120.
  ELSEIF SY-TCODE = 'ZHU5SO' OR SY-TCODE = 'ZHU5SOR'.
    SET SCREEN 100.
  ENDIF.
*- end of update for RTS

  IF OK_CODE = 'BACK'.
    LEAVE PROGRAM.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0010  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  PERFORM F_UNLOCK_NEW.
  PERFORM DELETE_LOCK_FS  USING VLOCK .
  LEAVE TO SCREEN 10.
ENDMODULE.                 " EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BATCH_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CHARG  text
*      -->P_SLOC  text
*      -->P_WERKS  text
*      <--P_LINE  text
*----------------------------------------------------------------------*
FORM F_CHECK_BATCH_SO  USING    P_CHARG
                                P_SLOC
                                P_WERKS
                       CHANGING P_ERRNO.

  DATA : T_SO LIKE ITAB_SO OCCURS 0 WITH HEADER LINE.
  DATA : LINE TYPE I.

*- update for RTS
  CHECK SY-TCODE EQ 'ZHU5SO' OR  SY-TCODE EQ 'ZHU5SOR'.
  IF SY-TCODE = 'ZHU5SOR'.
    SELECT MATNR VBELN POSNR KAEIN KAINS KASPE KAVLA KAVIN KAVSP KAILL KAILQ KAILS
           WERKS LGORT
      INTO TABLE T_SO
      FROM MSKA
      WHERE CHARG = P_CHARG(10).
  ELSE.
    SELECT MATNR VBELN POSNR KALAB KAINS KASPE KAVLA KAVIN KAVSP KAILL KAILQ KAILS
           WERKS LGORT
      INTO TABLE T_SO
      FROM MSKA
      WHERE CHARG = P_CHARG(10).
  ENDIF.

  LOOP AT T_SO WHERE KALAB NE 0.
    IF T_SO-WERKS NE '1000' AND T_SO-WERKS NE '2000'.
      P_ERRNO = 1.
      MESSAGE I000(0K) WITH  'Sloc Batch Harus 1000 atau 2000'. "ADD NEW COMPANY
      EXIT.
    ENDIF.
  ENDLOOP.

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

  LOOP AT T_SO.
    T_SO-TOT = T_SO-KALAB + T_SO-KAINS +  T_SO-KASPE.
*    T_SO-TOT = T_SO-KALAB + T_SO-KAINS +  T_SO-KAVLA
*              + T_SO-KAVIN + T_SO-KAVSP + T_SO-KAILL + T_SO-KAILQ
*              + T_SO-KAILS + T_SO-KASPE.
*    IF  T_SO-TOT NE 0.
*        AUTHORITY-CHECK OBJECT 'Z_UNPACK' ID 'Z_UNPACK' FIELD MCHB-LGORT .
*        IF SY-SUBRC NE 0.
*          MESSAGE W000(0K) WITH 'No Authorization to process data' .
*          P_ERRNO = '9'.
*          RETURN.
*        ENDIF.
*    ENDIF.

    MODIFY T_SO.
  ENDLOOP.
  DELETE T_SO WHERE TOT = 0.
  DESCRIBE TABLE T_SO LINES LINE.
  IF LINE = 0.
    P_ERRNO = 1.
    MESSAGE I000(0K) WITH  'Batch tidak ada di so'.
  ENDIF.
ENDFORM.                    " F_CHECK_BATCH_SO
*&---------------------------------------------------------------------*
*&      Module  CHECK_AUTH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_AUTH INPUT.
  AUTHORITY-CHECK OBJECT 'Z_STATION' ID 'ZSTATION' FIELD HUM_PROFILE_S-PACKING_STATION .
  IF SY-SUBRC NE 0.
    MESSAGE W000(0K) WITH 'No Authorization to process data' .
    CLEAR : HUM_PROFILE_S-PACKING_STATION.
    RETURN.
  ENDIF.
ENDMODULE.                 " CHECK_AUTH  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTH_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
FORM CHECK_AUTH_BATCH  USING CHARG TIKOD CHANGING P_ERRNO.
  DATA : JUM TYPE P DECIMALS 3.
  DATA : IT_SO LIKE ITAB_SO OCCURS 0 WITH HEADER LINE.

*- update for RTS
  IF TIKOD = 'ZHU5FS' OR TIKOD = 'ZHU5FSR'.
    IF TIKOD = 'ZHU5FSR'.
      SELECT  * FROM MCHB
        WHERE CHARG = CHARG.

        JUM = MCHB-CEINM + MCHB-CINSM + MCHB-CSPEM.
        IF  JUM NE 0.
          AUTHORITY-CHECK OBJECT 'Z_UNPACK' ID 'Z_UNPACK' FIELD MCHB-LGORT .
          IF SY-SUBRC NE 0.
            MESSAGE W000(0K) WITH 'No Authorization to process data' .
            P_ERRNO = '9'.
            RETURN.
          ENDIF.
        ENDIF.
      ENDSELECT.
    ELSE.
      SELECT  * FROM MCHB
      WHERE CHARG = CHARG.

        JUM = MCHB-CLABS + MCHB-CINSM + MCHB-CSPEM.
        IF  JUM NE 0.
          AUTHORITY-CHECK OBJECT 'Z_UNPACK' ID 'Z_UNPACK' FIELD MCHB-LGORT .
          IF SY-SUBRC NE 0.
            MESSAGE W000(0K) WITH 'No Authorization to process data' .
            P_ERRNO = '9'.
            RETURN.
          ENDIF.
        ENDIF.
      ENDSELECT.
    ENDIF.
  ELSEIF  TIKOD = 'ZHU5SO' OR TIKOD = 'ZHU5SOR'.
    CLEAR : IT_SO. REFRESH : IT_SO.
    IF  TIKOD = 'ZHU5SOR'.
      SELECT MATNR VBELN POSNR KAEIN KAINS KASPE KAVLA KAVIN KAVSP KAILL KAILQ KAILS
            WERKS LGORT
       INTO TABLE IT_SO
       FROM MSKA
       WHERE CHARG = CHARG.

      LOOP AT IT_SO.
        JUM = IT_SO-KALAB + IT_SO-KASPE + IT_SO-KAINS .
        IF  JUM NE 0.
          AUTHORITY-CHECK OBJECT 'Z_UNPACK' ID 'Z_UNPACK' FIELD IT_SO-LGORT .
          IF SY-SUBRC NE 0.
            MESSAGE W000(0K) WITH 'No Authorization to process data' .
            P_ERRNO = '9'.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      SELECT MATNR VBELN POSNR KALAB KAINS KASPE KAVLA KAVIN KAVSP KAILL KAILQ KAILS
            WERKS LGORT
       INTO TABLE IT_SO
       FROM MSKA
       WHERE CHARG = CHARG.

      LOOP AT IT_SO.
*      JUM = IT_SO-KALAB + IT_SO-KAINS +  IT_SO-KAVLA
*                + IT_SO-KAVIN + IT_SO-KAVSP + IT_SO-KAILL + IT_SO-KAILQ
*                + IT_SO-KAILS + IT_SO-KASPE.
        JUM = IT_SO-KALAB + IT_SO-KASPE + IT_SO-KAINS .
        IF  JUM NE 0.
          AUTHORITY-CHECK OBJECT 'Z_UNPACK' ID 'Z_UNPACK' FIELD IT_SO-LGORT .
          IF SY-SUBRC NE 0.
            MESSAGE W000(0K) WITH 'No Authorization to process data' .
            P_ERRNO = '9'.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_AUTH_BATCH


*----------------------------------------------------------------------*
*  MODULE GETPACK_STAT INPUT
*----------------------------------------------------------------------*
* add new company
*----------------------------------------------------------------------*
MODULE GETPACK_STAT INPUT.

  DATA : BEGIN OF ITAB OCCURS 0,
        PACKING_STATION LIKE HUPAST_T-PACKING_STATION,
        END OF ITAB.

  SELECT * FROM HUPAST_T INTO CORRESPONDING FIELDS OF TABLE ITAB WHERE PLANT IN ('1000','2000').

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'PACKING_STATION'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = ITAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDMODULE. " abc INPUT

*&---------------------------------------------------------------------*
*&      Form  CEK_RESTRICTED_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_RESTRICTED_STOCK.
  DATA: BEGIN OF IT_REST OCCURS 0,
    CHARG LIKE VEPO-CHARG,
    UNVEL LIKE VEPO-UNVEL,
    ZUSTD LIKE MCH1-ZUSTD,
    END OF IT_REST.

  DATA: IT_REST2 LIKE IT_REST OCCURS 0 WITH HEADER LINE.

  REFRESH: IT_REST, IT_REST2.
  CLEAR: IT_REST, IT_REST2.

  SELECT VEPO~CHARG VEPO~UNVEL INTO TABLE IT_REST
    FROM VEPO JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
    WHERE VEKP~EXIDV = GS_EXIDV.

  IT_REST2[] = IT_REST[].
  DELETE IT_REST WHERE CHARG = ''.

  LOOP AT IT_REST2 WHERE UNVEL NE ''.
    SELECT VEPO~CHARG VEPO~UNVEL INTO IT_REST
          FROM VEPO WHERE VENUM = IT_REST2-UNVEL.
      APPEND IT_REST.
    ENDSELECT.

  ENDLOOP.

  CLEAR IT_REST-ZUSTD.
  LOOP AT IT_REST.
    CLEAR: IT_REST-ZUSTD.
    SELECT SINGLE ZUSTD INTO IT_REST-ZUSTD FROM MCH1 WHERE CHARG = IT_REST-CHARG.
    IF IT_REST-ZUSTD = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF IT_REST-ZUSTD = ''.
*    GWA_PCH-PINNR = '' .
    CLEAR OK_CODE.
    MESSAGE 'Batch bukan Restricted.....' TYPE 'I'.
  ENDIF.
ENDFORM.                    "CEK_RESTRICTED_STOCK