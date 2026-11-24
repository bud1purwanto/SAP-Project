*&---------------------------------------------------------------------*
*&      Form  tyb_text_data
*&---------------------------------------------------------------------*

DATA: V_APOS(2),
      VX_MSG(50).

*&---------------------------------------------------------------------*
*&      Form  TYB_TEXT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TYB_TEXT_DATA .
  DATA : V_TY_ROLLN(10),
         V_TY_LOTN(6),
         V_TY_BASE(10),
         V_TY_TEXT1(30),
         V_TY_TEXT2(30),
         V_S_THICKNESS(3),V_S_WIDTH(5),V_S_LENGTH(6),
         V_TY_LOWER123(3),
         V_J1(2), "add text 'J1' when splice
         V_YEAR(2), "year for label b002 toyobo
         V_MONTH(2),
         V_DATE(3),
         V_BLN TYPE I,
         V_BLN_A TYPE I,
         V_BLN_GANJIL TYPE STRING,
         V_BLN_B TYPE I,
         V_BLN_GENAP TYPE STRING.


  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.
  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.

*Get Net weight...
  PERFORM GET_NET_WEIGHT.
  CLEAR : V_FLAG_ZZALIAS,
          V_TYPE,
          V_LABELTYPE,
          POSI.
*/---Changed on 150405---
*          v_zzconversionmtrkg.
*-----------------------/

  SORT V_TAB BY ATNAM.
  LOOP AT V_TAB.

* Reset v_flag_zzalias to ''.
    V_FLAG_ZZALIAS = ''.

    IF V_TAB-ATNAM = 'ZZALIAS'.
      V_TYPE = V_TAB-ATWRT.
      V_FLAG_ZZALIAS = 'X'.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC = 0.
        V_TAB-ATWRT = V_TYPE.
        MODIFY V_TAB  INDEX SY-TABIX TRANSPORTING ATWRT.
      ENDIF.
    ENDIF.



    IF V_FLAG_ZZALIAS <> 'X'.
      IF V_TAB-ATNAM = 'ZZTYPE'.
        V_TYPE = V_TAB-ATWRT.
      ENDIF.
    ENDIF.

    IF V_TAB-ATNAM = 'ZZLABEL'.
      V_LABELTYPE = V_TAB-ATWRT.
      V_LABELIMGNEW = V_TAB-ATWRT.
    ENDIF.




*/---changed on 150405---

***ZZCONVERSIONMTRKG
*    IF v_tab-atnam = 'ZZCONVERSIONMTRKG'.
**      v_ZZCONVERSIONMTRKG = v_tab-atwtb.
*      SHIFT v_tab-atwtb LEFT DELETING LEADING space.
*      SPLIT v_tab-atwtb AT v_del INTO v_zzconversionmtrkg v_1.
*    ENDIF.

*----------------------/

*    IF v_tab-atnam = 'ZZPRDDATE'.
*      CONCATENATE v_tab-atwrt+3(1) v_tab-atwrt+4(2) INTO v_ty_lower123.
*    ENDIF.

    IF V_TAB-ATNAM = 'ZZNOROLLTOYOBO'.
      V_TY_ROLLN = V_TAB-ATWRT.

      "add by whika label Toyobo type B002 by change year and mouth in barcode-2
      IF V_LABELTYPE EQ 'B002' OR V_LABELTYPE EQ 'B022' OR V_LABELTYPE EQ 'A002'.
        V_YEAR =  V_TY_ROLLN+0(1).
        V_MONTH =  V_TY_ROLLN+1(1).
        V_DATE =  V_TY_ROLLN+2(2).

        CALL FUNCTION 'CONVERT_STRING_TO_INTEGER'
          EXPORTING
            P_STRING = V_MONTH
          IMPORTING
            P_INT    = V_BLN.

        V_BLN_A = V_BLN * 2 - 1.
        V_BLN_GANJIL = V_BLN_A.
        V_BLN_B = V_BLN * 2.
        V_BLN_GENAP = V_BLN_B.

        IF V_DATE <= 50.
          IF V_BLN_GANJIL < 10.
            CONCATENATE  V_YEAR '0' V_BLN_GANJIL  INTO V_TY_LOWER123.
          ELSEIF V_BLN_GANJIL >= 10.
            CONCATENATE  V_YEAR V_BLN_GANJIL  INTO V_TY_LOWER123.
          ENDIF.
        ELSEIF V_DATE > 50.
          IF V_BLN_GENAP < 10.
            CONCATENATE  V_YEAR '0' V_BLN_GENAP  INTO V_TY_LOWER123.
          ELSEIF V_BLN_GENAP >= 10.
            CONCATENATE  V_YEAR V_BLN_GENAP  INTO V_TY_LOWER123.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR V_POSTDATE.
*            SELECT SINGLE ersda INTO v_postdate FROM mch1 WHERE charg EQ v_charg AND matnr EQ v_matnr.
        CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
          EXPORTING
            MATNR = V_MATNR
            CHARG = V_CHARG
          IMPORTING
            PDATE = V_POSTDATE.
        CONCATENATE V_POSTDATE+3(1) V_POSTDATE+4(2) INTO V_TY_LOWER123.
      ENDIF.
    ENDIF.

    IF V_TAB-ATNAM = 'ZZNOLOTTOYOBO'.
      PERFORM RIGHT_JUSTIFIED USING 6
                                    V_TAB-ATWRT.

      V_TY_LOTN = V_TAB-ATWRT.
    ENDIF.

    IF V_TAB-ATNAM = 'ZZSPECIALTOUCH-1'.
      CONDENSE V_TAB-ATWRT.
      V_TY_BASE = V_TAB-ATWRT.
    ENDIF.

    IF V_TAB-ATNAM = 'ZZSPLICE-1'.
      IF V_TAB-ATWRT NE ''.
        V_J1 = 'J1'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPLICE-2'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWRT NE ''.
      V_J1 = 'J2'.
    ENDIF.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC <> 0.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
    V_TAB-ATNAM = 'ZZLENGTH'.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    V_S_LENGTH = V_TAB-ATWTB.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
*    ENDIF.
  ELSE.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    V_S_LENGTH = V_TAB-ATWTB.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
*    ENDIF.
  ENDIF.


*---------------------/


*Getting the data atnam from table zlabel.
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE V_ZLABEL
  FROM ZLABEL.

  SORT V_ZLABEL BY ATNAM.
  LOOP AT V_ZLABEL.
    V_TABIX = SY-TABIX.
    CLEAR V_TAB-ATWTB.
    READ TABLE V_TAB WITH KEY ATNAM = V_ZLABEL-ATNAM.
    IF SY-SUBRC = 0.

*/---CHANGED ON 150405 ---
*      if v_zlabel-atnam = 'ZZTHICKNESS'.
*        split v_tab-atwtb at v_dot into v_tab-atwtb v_1.
*        perform conv_to_char using v_tab-atwtb.
*        perform right_justified using v_len_mic
*                                      v_tab-atwtb.
*        replace all occurrences of '.0' in v_tab-atwtb with ' '.
*
*        v_s_thickness = v_tab-atwtb.
*
*      endif.
*
*      if v_zlabel-atnam = 'ZZWIDTH'.
*        v_s_width = v_tab-atwtb.
*        perform right_justified using 5
*                                      v_tab-atwtb.
*      endif.
*
*      if v_zlabel-atnam = 'ZZLENGTH'.
*        v_s_length = v_tab-atwtb.
*        perform right_justified using 6
*                                      v_tab-atwtb.
*
*      endif.

      IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.
        SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.

        PERFORM TY_RIGHT_JUSTIFIED USING 2
                                      V_TAB-ATWTB.
        REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.


*        v_ty_input = v_tab-atwtb.
*        perform cleardotcomma using v_ty_input.

        V_S_THICKNESS = V_TAB-ATWTB.
      ENDIF.

      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.
        PERFORM TY_RIGHT_JUSTIFIED USING 4
                                      V_TAB-ATWTB.
*        v_ty_input = v_tab-atwtb.
*        perform cleardotcomma using v_ty_input.

        V_S_WIDTH = V_TAB-ATWTB.
      ENDIF.

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.
        PERFORM TY_RIGHT_JUSTIFIED USING 5
                                      V_TAB-ATWTB.

*        v_ty_input = v_tab-atwtb.
*        perform cleardotcomma using v_ty_input.

        V_S_LENGTH = V_TAB-ATWTB.
      ENDIF.

      IF V_ZLABEL-ATNAM = 'ZZSPLICE-1' OR V_ZLABEL-ATNAM = 'ZZSPLICE-2'.
        IF V_LABELTYPE = 'B026' OR V_LABELTYPE = 'B027' OR V_LABELTYPE = 'B029' OR V_LABELTYPE = 'B030' OR V_LABELTYPE = 'B031'.
          REPLACE ALL OCCURRENCES OF ',' IN  V_TAB-ATWTB WITH ''.
          CONDENSE V_TAB-ATWTB.
        ENDIF.
      ENDIF.

*----------------------/
      V_ZLABEL-DATA2 = V_TAB-ATWTB.
    ELSE.
      V_ZLABEL-DATA2 = ' '.
    ENDIF.

    MODIFY V_ZLABEL INDEX V_TABIX TRANSPORTING DATA2.
  ENDLOOP.


*/---Added on 150405---
*cek previouly label

  IF V_LABELIMGOLD <> V_LABELIMGNEW.

*clear image and format to text-data---------------------
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  'CLEAR.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
*            if sy-tabix = 2.
*              shift text_data-str_text+7  right by 2 places .
*              add 1 to posi.
*              text_data-str_text+6(3) = posi.
*            endif.

      APPEND TEXT_DATA.
    ENDLOOP.


    SELECT IMAG1
      INTO CORRESPONDING FIELDS OF TABLE V_ZLABELMAPIMAGE
      FROM ZLABELMAPIMAGE
      WHERE KODE = V_LABELIMGNEW.


    LOOP AT V_ZLABELMAPIMAGE.
*load image to text-data---------------------
      REFRESH TEXT_DATA2.
      CLEAR TEXT_DATA2.

      CONCATENATE FILE_DIR  V_ZLABELMAPIMAGE-IMAG1 '.TAX' INTO FILE_F.

      PERFORM GETFRSRV_F.
      TEXT_DATA2[] = IT[].

      LOOP AT TEXT_DATA2.
        TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
*            if sy-tabix = 2.
*              shift text_data-str_text+7  right by 2 places .
*              add 1 to posi.
*              text_data-str_text+6(3) = posi.
*            endif.

        APPEND TEXT_DATA.
      ENDLOOP.

    ENDLOOP.

  ENDIF.

*---------------------/



******
*  DO V_COPIES TIMES.
  REFRESH TEXT_DATA2.
  CLEAR TEXT_DATA2.

  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.

  PERFORM GETFRSRV_F.
  TEXT_DATA2[] = IT[].

  LOOP AT TEXT_DATA2.
    TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
    IF SY-TABIX = 2.
      SHIFT TEXT_DATA-STR_TEXT+7  RIGHT BY 2 PLACES .
      ADD 1 TO POSI.
      TEXT_DATA-STR_TEXT+6(3) = POSI.
    ENDIF.

    APPEND TEXT_DATA.
  ENDLOOP.

******

******
*/---changed on 150405---
*    CONCATENATE v_type v_s_thickness v_s_width v_s_length 'AT'
*                                      INTO v_ty_text1 SEPARATED BY space.
  CONCATENATE V_TYPE V_S_THICKNESS INTO V_TY_TEXT1 SEPARATED BY SPACE.
  IF V_LABELTYPE = 'B026' OR V_LABELTYPE = 'B027' OR V_LABELTYPE = 'B029'. " OR V_LABELTYPE = 'B030'.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH 'A' INTO V_TY_TEXT1.
  ELSEIF V_LABELTYPE = 'B021'.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH 'ATAT' INTO V_TY_TEXT1.
  ELSEIF V_LABELTYPE = 'B023'.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH 'ATAL' INTO V_TY_TEXT1.
  ELSEIF V_LABELTYPE = 'B024'.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH 'ATAC' INTO V_TY_TEXT1.
  ELSEIF V_LABELTYPE = 'B025'.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH 'ATAR' INTO V_TY_TEXT1.
  ELSEIF V_LABELTYPE = 'B031' OR V_LABELTYPE = 'B030'.
    CLEAR: V_APOS, VX_MSG.
    PERFORM GET_JR_POSITION USING V_APOS.
    IF VX_MSG IS NOT INITIAL.
      MESSAGE VX_MSG TYPE 'E' DISPLAY LIKE 'A'.
      EXIT.
    ENDIF.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH V_APOS INTO V_TY_TEXT1.
  ELSEIF V_LABELTYPE = 'A002'.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH 'AH' INTO V_TY_TEXT1.
  ELSE.
    CONCATENATE V_TY_TEXT1 V_S_WIDTH V_S_LENGTH 'AT' INTO V_TY_TEXT1.
  ENDIF.
*-----------------------/

  CONDENSE V_TY_ROLLN.
  CONDENSE V_TY_LOTN.
  CONCATENATE V_TY_LOWER123 V_TY_ROLLN V_TY_LOTN '000' INTO V_TY_TEXT2.



*Condition for start and end syntax label command.
  TEXT_DATA-STR_TEXT = '<STX><ESC>E1,1<CAN><ETX>'.
  APPEND TEXT_DATA.

*Combine all command into internal table.
  LOOP AT V_ZLABEL.
    IF V_ZLABEL-ATNAM = 'ZZBARC1'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_ROLLN '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZBARC2'.
      IF V_LABELTYPE = 'B026' OR V_LABELTYPE = 'B027' OR V_LABELTYPE = 'B029'. " OR V_LABELTYPE = 'B030'.
        IF V_J1 EQ 'J1'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 ' J1<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'J2'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 ' J2<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '   <ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
      ELSEIF V_LABELTYPE = 'B031' OR V_LABELTYPE = 'B030'.
        PERFORM GET_GRADE USING V_J1.
        IF V_J1 EQ 'J1'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'J1<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'J2'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'J2<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'JS'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'JS<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'JD'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'JD<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '  <ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
      ELSEIF V_LABELTYPE = 'B002' OR V_LABELTYPE = 'B022' OR V_LABELTYPE = 'A002'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '  <ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZBARC3'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZROLL1'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_ROLLN '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZROLL2'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_ROLLN '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZROLL3'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_BASE '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZTEXT1'.
      IF V_LABELTYPE = 'B026' OR V_LABELTYPE = 'B027' OR V_LABELTYPE = 'B029'." OR V_LABELTYPE = 'B030'.
        IF V_J1 EQ 'J1'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 ' J1<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'J2'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 ' J2<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '   <ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
      ELSEIF V_LABELTYPE = 'B031' OR V_LABELTYPE = 'B030'.
        PERFORM GET_GRADE USING V_J1.
        IF V_J1 EQ 'J1'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'J1<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'J2'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'J2<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'JS'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'JS<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_J1 EQ 'JD'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 'JD<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '  <ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZTEXT2'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZFILM'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TYPE '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZLOTNUMBER'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_LOTN '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
*clear data
    ELSEIF V_ZLABEL-ATNAM = 'ZZGRADE'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 '' '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZINSIDE'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 '' '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZOUTSIDE'.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 '' '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ELSEIF V_ZLABEL-ATNAM = 'ZZSPLICE-1' AND V_ZLABEL-DATA2 NE ''.
      IF  V_LABELTYPE = 'B026' OR V_LABELTYPE = 'B027' OR V_LABELTYPE = 'B029' OR V_LABELTYPE = 'B030' OR V_LABELTYPE = 'B031'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 'J1: ' V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ENDIF.
    ELSEIF V_ZLABEL-ATNAM = 'ZZSPLICE-2' AND V_ZLABEL-DATA2 NE ''.
      IF  V_LABELTYPE = 'B026' OR V_LABELTYPE = 'B027' OR V_LABELTYPE = 'B029' OR V_LABELTYPE = 'B030' OR V_LABELTYPE = 'B031'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 'J2: ' V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ENDIF.
    ELSEIF V_ZLABEL-ATNAM = 'ZZUSERNAME'.
      IF V_LABELTYPE = 'B026' OR V_LABELTYPE = 'B027' OR V_LABELTYPE = 'B029' OR V_LABELTYPE = 'B030' OR V_LABELTYPE = 'B031'.
        PERFORM GET_GRADE USING V_J1.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_J1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ENDIF.
    ELSEIF  V_ZLABEL-ATNAM = 'ZZBOX'. "POSISI SR BASE FILM
      IF V_LABELTYPE = 'B031' OR V_LABELTYPE = 'B030'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_APOS '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ENDIF.

    ELSE.
      CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      APPEND TEXT_DATA.
    ENDIF.
  ENDLOOP.
*Conditiion for end syntax label command.
  TEXT_DATA-STR_TEXT = '<STX><RS>1<ETX>'.
  APPEND TEXT_DATA.

*    TEXT_DATA-STR_TEXT = '<STX><US>1<ETX>'.
  CONCATENATE '<STX><US>' V_COPIES '<ETX>' INTO TEXT_DATA-STR_TEXT.
  APPEND TEXT_DATA.

  TEXT_DATA-STR_TEXT = '<STX><ETB><ETX>'.
  APPEND TEXT_DATA.

*  ENDDO.

ENDFORM.                    " tyb_text_data

*&---------------------------------------------------------------------*
*&      Form  GET_JR_POSITION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_APOS     text
*----------------------------------------------------------------------*
FORM GET_JR_POSITION USING V_APOS.
  "BACA KODE POSISI JR DI CHARACTERISTIC ZZUNITOFMEASURE

  DATA: VX_ATNROL LIKE CABN-ATINN,
        VX_ATNUOM LIKE CABN-ATINN,
        VX_ROLNO LIKE AUSP-ATWRT,
        VX_UOM LIKE AUSP-ATWRT,
        VX_MATNR_JR LIKE MCH1-MATNR,
        VX_CHARG_JR LIKE MCH1-CHARG.

  CLEAR: VX_ATNROL,VX_ATNUOM,VX_ROLNO,VX_MATNR_JR,VX_CHARG_JR,VX_UOM.

  SELECT SINGLE ATINN INTO VX_ATNROL FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
  SELECT SINGLE ATINN INTO VX_ATNUOM FROM CABN WHERE ATNAM = 'ZZUNITOFMEASURE'.

  SELECT SINGLE  AUSP~ATWRT INTO VX_ROLNO
    FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
    WHERE MCH1~MATNR = V_MATNR AND MCH1~CHARG = V_CHARG AND AUSP~ATINN = VX_ATNROL.

  VX_ROLNO = VX_ROLNO+0(13).

  SELECT SINGLE MCH1~MATNR MCH1~CHARG INTO (VX_MATNR_JR, VX_CHARG_JR)
    FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
    WHERE AUSP~ATINN = VX_ATNROL AND AUSP~KLART = '023' AND AUSP~ATWRT = VX_ROLNO.

  IF SY-SUBRC NE 0.
    CONCATENATE 'DATA MOTHER ROLL BATCH' V_CHARG 'TIDAK DITEMUKAN' INTO VX_MSG SEPARATED BY SPACE.
    EXIT.
  ENDIF.

  "BACA KODE POSISI JR DI CHARACTERISTIC ZZUNITOFMEASURE
  SELECT SINGLE  AUSP~ATWRT INTO VX_UOM
    FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
    WHERE MCH1~MATNR = VX_MATNR_JR AND MCH1~CHARG = VX_CHARG_JR AND AUSP~ATINN = VX_ATNUOM.

  IF SY-SUBRC NE 0.
    CONCATENATE 'KODE POSISI BATCH' V_CHARG 'TIDAK DITEMUKAN' INTO VX_MSG SEPARATED BY SPACE.
    EXIT.
  ENDIF.

  V_APOS = VX_UOM.
  CONCATENATE 'A' V_APOS INTO V_APOS.

ENDFORM.                    "GET_JR_POSITION


*&---------------------------------------------------------------------*
*&      Form  get_grade
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_GRADE USING V_J1.
  CLEAR V_TAB.
  LOOP AT V_TAB WHERE ATNAM = 'ZZGRADE'.
    IF V_TAB-ATWRT = 'JS' OR V_TAB-ATWRT = 'JD'.
      IF V_J1 = 'J1' OR V_J1 = 'JS' OR V_J1 = 'JD'.
        V_J1 = V_TAB-ATWRT.
      ELSEIF V_J1 = 'J2'.
        MESSAGE 'Tidak boleh Join 2...!' TYPE 'I'.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF V_J1 = 'J1'.
      MESSAGE 'Grade harus JD atau JS...!' TYPE 'I'.
      LEAVE SCREEN.
    ELSEIF V_J1 = 'J2'.
      MESSAGE 'Tidak boleh Join 2...!' TYPE 'I'.
      LEAVE SCREEN.

    ENDIF.
  ENDLOOP.
ENDFORM.                    "get_grade