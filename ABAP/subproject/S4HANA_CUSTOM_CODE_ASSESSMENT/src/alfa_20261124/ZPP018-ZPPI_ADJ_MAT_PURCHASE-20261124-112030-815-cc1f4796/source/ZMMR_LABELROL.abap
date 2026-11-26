*&---------------------------------------------------------------------*
*&  Report     :  ZMMR_LABELROL                                        *
*&  Appl. Area :  MM                                                   *
*&  Created by :  Mualifi                                              *
*&  Created on :  11 October 2012                                      *
*&---------------------------------------------------------------------*
REPORT  ZMMR_LABELROL NO STANDARD PAGE HEADING MESSAGE-ID PP.

TABLES: AFPO,MARA, MCHA, ZMAP_LABEL.

DATA: BEGIN OF IT_CHARG OCCURS 0,
      MATNR LIKE MCHA-MATNR,
      CHARG LIKE MCHA-CHARG,
      WERKS LIKE MCHA-WERKS,
  END OF IT_CHARG.

DATA : V_AUFNR TYPE AFPO-AUFNR,
       V_POS(2) TYPE C,
       V_DER(1) TYPE C,
       V_CRITERIAGRD(1) TYPE C.
DATA: V_MSG(135).

DATA: V_NUM TYPE P.
DATA: VPROGNAME LIKE TSTC-PGMNA.
DATA: V_AUTH(1).
DATA: V_IS_ZEBRA_LABELROL(1).
DATA: V_IS_NEW_LABEL(20) TYPE C.

SELECT-OPTIONS : P_CHARG FOR MCHA-CHARG.
PARAMETER      : V_COPIES(3) DEFAULT 1.

*INCLUDE ZLABEL_ZEBRA_INCL.
INCLUDE ZMMR_LABELROL_INCL.
INCLUDE ZMMR_LABELROL_STANDAR.
INCLUDE ZMMR_LABELROL_TOYOBO.
INCLUDE ZMMR_LABELROL_TTE.
INCLUDE ZMMR_LABELROL_TTA.    "Added by AKBAR 23.04.2020 (New label type for TTA)
*INCLUDE ZMMR_LABELROL_TYB_WIN.
INCLUDE ZMMR_LABELROL_INTER.
INCLUDE ZMMR_LABELROL_PRIMA.
INCLUDE ZMMR_LABELROL_PM.
INCLUDE ZMMR_LABELROL_INCHI.
INCLUDE ZLABEL_A211.

START-OF-SELECTION.
  IF P_CHARG[] IS NOT INITIAL.
    SELECT MATNR CHARG WERKS INTO TABLE IT_CHARG FROM MCHA
    WHERE CHARG IN P_CHARG.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING CHARG.

  "Add Authorization New Company
  CLEAR V_AUTH.
  LOOP AT IT_CHARG.
    AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD IT_CHARG-WERKS.
    IF SY-SUBRC NE 0.
      V_AUTH = 'X'.
      MESSAGE 'No Authorization to process data' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDLOOP.

  CHECK V_AUTH IS INITIAL.
  "End Add Authorization New Company

  LOOP AT IT_CHARG.
    CLEAR : V_MATNR,
            V_WERKS,
            V_CHARG,
            V_LGORT,
            V_CRITERIAGRD.

    V_CHARG = IT_CHARG-CHARG.
    V_MATNR = IT_CHARG-MATNR.

    CASE IT_CHARG-MATNR+0(2).
      WHEN 'SR'.
      WHEN OTHERS.
        CONCATENATE IT_CHARG-CHARG '-' IT_CHARG-MATNR ': bukan Finish goods..!' INTO V_MSG SEPARATED BY SPACE.
        MESSAGE V_MSG TYPE 'I'.
        CONTINUE.
    ENDCASE.

*    IF SY-SUBRC = 0.
    REFRESH V_TAB.
    CLEAR V_TAB.
    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
      EXPORTING
        I_VAL_MATNR    = V_MATNR
        I_VAL_CHARGE   = V_CHARG
      TABLES
        T_VAL_TAB      = V_TAB
      EXCEPTIONS
        NO_CLASS       = 1
        INTERNAL_ERROR = 2
        NO_VALUES      = 3
        NO_CHARS       = 4
        OTHERS         = 5.

    IF SY-SUBRC = 0.
      "Added for RTP Core by Carfin 18.02.2019
      PERFORM CEK_RTP_CORE CHANGING FCN_ERRNO.
      IF FCN_ERRNO <> 0.
        STOP.
      ENDIF.
      "Added for RTP Core by Carfin 18.02.2019

      "Check using zebra printer or not
      PERFORM CHECK_USING_ZEBRA CHANGING V_IS_ZEBRA_LABELROL.

      "Under windows
      CLEAR V_TAB-ATWRT.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.

      SELECT SINGLE PROG_ROLL INTO VPROGNAME FROM ZMAP_LABEL WHERE CODE = V_TAB-ATWRT.
      IF VPROGNAME IS NOT INITIAL.
        IF V_IS_ZEBRA_LABELROL EQ 'X'.
           PERFORM CHANGE_ZEBRA_EMULATION USING 'NONE'.
        ENDIF.
        SUBMIT (VPROGNAME) WITH P_CHARG IN P_CHARG WITH V_MATNR = V_MATNR WITH V_COPIES = V_COPIES AND RETURN.
        EXIT.
      ENDIF.

       "Toyobo Under Windows
      SELECT SINGLE ZCODE FROM ZMAP_LABEL_TYB INTO V_TAB-ATWRT WHERE ZCODE = V_TAB-ATWRT.
      IF SY-SUBRC EQ 0.
        IF V_IS_ZEBRA_LABELROL EQ 'X'.
            PERFORM CHANGE_ZEBRA_EMULATION USING 'NONE'.
        ENDIF.
        SUBMIT ZMMR_LABELROL_TYB_WIN WITH P_CHARG IN P_CHARG WITH V_MATNR = V_MATNR WITH V_COPIES = V_COPIES AND RETURN.
        EXIT.
      ENDIF.



*- DOS
      CLEAR: V_DERIVATIVEMS, V_POSITIONMS, V_DERIVATIVESS,  V_POSITIONSS,
             V_GRADE, V_NUM, V_SPLICE1_D, V_SPLICE2_D.
      V_DERIVATIVEMS = '00'.
      V_POSITIONMS = '00'.
      V_DERIVATIVESS = '00'.
      V_POSITIONSS = '00'.

      LOOP AT V_TAB.
        IF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
          V_DERIVATIVEMS = V_TAB-ATWRT.
        ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
          V_POSITIONMS = V_TAB-ATWRT.
        ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
          V_DERIVATIVESS = V_TAB-ATWRT.
        ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
          V_POSITIONSS = V_TAB-ATWRT.
        ELSEIF V_TAB-ATNAM = 'ZZGRADE'.
          V_GRADE = V_TAB-ATWRT.
        ELSEIF V_TAB-ATNAM = 'ZZSPLICE-1'.
          V_NUM = V_TAB-ATFLV.
          V_SPLICE1_D = V_NUM.
        ELSEIF V_TAB-ATNAM = 'ZZSPLICE-2'.
          V_NUM = V_TAB-ATFLV.
          V_SPLICE2_D = V_NUM.
        ENDIF.
      ENDLOOP.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZCRITERIA'.
      IF SY-SUBRC = 0.
        V_CRITERIAGRD = V_TAB-ATWRT.
      ENDIF.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
      IF SY-SUBRC = 0.
        CLEAR MARA-MATKL.
        SELECT SINGLE MATKL
        INTO MARA-MATKL
        FROM MARA
        WHERE MATNR = V_MATNR.

        "Start Add Bothside Treatment by Fiqih (29.04.2026)
        "Dianggap New Label jika memiliki mapping (Apapun itu) pada TEXT2 ZMAP_LABEL. sehingga menggunakan NEW_TEXT_DATA.
        CLEAR V_IS_NEW_LABEL.
        SELECT SINGLE TEXT2
          INTO V_IS_NEW_LABEL
          FROM ZMAP_LABEL
          WHERE CODE EQ V_TAB-ATWRT.
        "End Add Bothside Treatment by Fiqih (29.04.2026)

        "IF V_TAB-ATWRT+1(1) = '0'. "Commented For Enhancement Bothside Treatment by Fiqih (29.04.2026)
        IF V_TAB-ATWRT+1(1) = '0' AND V_IS_NEW_LABEL IS INITIAL. "Edited For Enhancement Bothside Treatment by Fiqih (29.04.2026)
*Old Label - Jika nama tipe label menggunakan '0' pada karakter kedua Cth A0XX, B0XX, C0XX.

*            IF mara-matkl = '300002'.
          IF V_TAB-ATWRT = 'B001' OR      "ADDED BY FATHIR 26.11.2018
             V_TAB-ATWRT = 'B020' OR      "Added by AKBAR 09.05.2019 (AT-TA)
             V_TAB-ATWRT = 'B005' OR      "Added by AKBAR 21.06.2019 (AT-PF)
             V_TAB-ATWRT = 'B002' OR V_TAB-ATWRT = 'B003' OR V_TAB-ATWRT = 'B004' OR
             V_TAB-ATWRT = 'B021' OR V_TAB-ATWRT = 'B022' OR V_TAB-ATWRT = 'B023' OR V_TAB-ATWRT = 'B024' OR V_TAB-ATWRT = 'B025' OR
             V_TAB-ATWRT = 'B026' OR V_TAB-ATWRT = 'B027' OR V_TAB-ATWRT = 'B029' OR V_TAB-ATWRT = 'B030' OR V_TAB-ATWRT = 'B031' OR
             V_TAB-ATWRT = 'B044' OR V_TAB-ATWRT = 'B045' OR V_TAB-ATWRT = 'B046' OR V_TAB-ATWRT = 'B047' OR V_TAB-ATWRT = 'B048' OR
             V_TAB-ATWRT = 'A002' OR
             V_TAB-ATWRT = 'B032'.        "Added by AKBAR 05.08.2019 (Ref. B031 passing Join 2).
            IF ( V_CRITERIAGRD = '1'  OR  V_CRITERIAGRD = '2' ).
              PERFORM TYB_TEXT_DATA.
            ELSE.
*                  CONTINUE.
            ENDIF.

*Interfilm DigitCtrl
*--- Merge Digit and Non digit (no more non digit).
          ELSEIF ( V_TAB-ATWRT = 'D009' OR V_TAB-ATWRT = 'D010' OR V_TAB-ATWRT = 'B013' OR V_TAB-ATWRT = 'B014'
                OR V_TAB-ATWRT = 'B015' OR V_TAB-ATWRT = 'B016' OR V_TAB-ATWRT = 'A011' OR V_TAB-ATWRT = 'A012'
                OR V_TAB-ATWRT = 'A013' OR V_TAB-ATWRT = 'B017' OR V_TAB-ATWRT = 'B018'

                OR V_TAB-ATWRT = 'A014' OR V_TAB-ATWRT = 'A015' OR V_TAB-ATWRT = 'A016' OR V_TAB-ATWRT = 'A017'
                OR V_TAB-ATWRT = 'A018' OR V_TAB-ATWRT = 'A019' OR V_TAB-ATWRT = 'B020' OR V_TAB-ATWRT = 'A010'
                OR V_TAB-ATWRT = 'D020' OR V_TAB-ATWRT = 'A020' OR V_TAB-ATWRT = 'A021' OR V_TAB-ATWRT = 'L001'
                OR V_TAB-ATWRT = 'L002' OR V_TAB-ATWRT = 'L003' OR V_TAB-ATWRT = 'L004' OR V_TAB-ATWRT = 'L005'
                OR V_TAB-ATWRT = 'D013' OR V_TAB-ATWRT = 'D014' OR V_TAB-ATWRT = 'D015' OR V_TAB-ATWRT = 'G001'
                OR V_TAB-ATWRT = 'L011' OR V_TAB-ATWRT = 'L012'
                ).
            PERFORM INTER_TEXT_DATA2.
*PrimaPack
          ELSEIF ( V_TAB-ATWRT = 'A009').
            PERFORM PRIMA_TEXT_DATA.
          ELSE.
            PERFORM TEXT_DATA.
          ENDIF.

        ELSE.
*New Label
*Sampoerna
          IF ( V_TAB-ATWRT = 'K100' OR V_TAB-ATWRT = 'K101'      "sampoerna
            OR V_TAB-ATWRT = 'K102' OR V_TAB-ATWRT = 'K103').    "Asia tembakau
            PERFORM SAMPOERNA_TEXT_DATA.
*TTE Label
            "Start - Added by AKBAR 30.10.2019 (New label type for TTE)
          ELSEIF V_TAB-ATWRT = 'TE02'.
*            IF ( V_CRITERIAGRD = '1'  OR  V_CRITERIAGRD = '2' ).    "Modified by AKBAR 03.04.2020 (for Print RW/RS TTE)
            PERFORM TYB_TEXT_DATA_TTE.
*            ELSE.
*                  CONTINUE.
*            ENDIF.
*TTA Label
            "Start - Added by AKBAR 23.04.2020 (New label type for TTA)
          ELSEIF V_TAB-ATWRT = 'TA02' OR V_TAB-ATWRT = 'TA03' OR V_TAB-ATWRT = 'TA04' OR
                 V_TAB-ATWRT = 'TA05' OR V_TAB-ATWRT = 'TA06' OR V_TAB-ATWRT = 'TA07'.
            PERFORM TYB_TEXT_DATA_TTA.
            "End - Added by AKBAR 23.04.2020 (New label type for TTA)
          ELSEIF ( V_TAB-ATWRT = 'K110' OR V_TAB-ATWRT = 'K120' OR V_TAB-ATWRT = 'K130' OR
                   V_TAB-ATWRT = 'K140' OR V_TAB-ATWRT = 'K150' OR V_TAB-ATWRT = 'K160' ).
            PERFORM PM_TEXT_DATA.
          ELSEIF ( V_TAB-ATWRT = 'A300' OR V_TAB-ATWRT = 'A301' OR V_TAB-ATWRT = 'A304' OR V_TAB-ATWRT = 'A305' OR
                   V_TAB-ATWRT = 'A134' OR V_TAB-ATWRT = 'A137' OR V_TAB-ATWRT = 'A142' OR V_TAB-ATWRT = 'J129' OR
                   V_TAB-ATWRT = 'A145'). "Added by AKBAR 09.01.2019 (Type A137 & J129)
            PERFORM INCHI_TEXT_DATA.  "set inchi in SO item text
          ELSEIF ( V_TAB-ATWRT = 'A211' OR V_TAB-ATWRT = 'A212' OR V_TAB-ATWRT = 'A213' ).
            PERFORM F_A211.
          ELSE.
            PERFORM NEW_TEXT_DATA.
            PERFORM F_EXIT_LABEL. " Added by William at 21.05.2022 (for label with special case)
          ENDIF.
        ENDIF.

        AT LAST.
          PERFORM DOWNLOAD_DATA.
          PERFORM GETFRSRV_B.
          PERFORM PRINT.
          PERFORM REFRESH_ALL.
*            REFRESH TEXT_DATA.
*            CLEAR TEXT_DATA.
        ENDAT.
      ELSE.
        MESSAGE I000(0K) WITH 'Label type is not exist! (Order#)' P_CHARG-LOW.
        STOP.
      ENDIF.
    ENDIF.
*    ENDIF.
  ENDLOOP.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  refresh_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH_ALL.
  REFRESH: V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, IT_CHARG, TEXT_DATA, TEXT_DATA2, P_CHARG, IT.
  CLEAR: V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, IT_CHARG, TEXT_DATA, TEXT_DATA2, P_CHARG, IT.
ENDFORM.                    "refresh_all

*&---------------------------------------------------------------------*
*&      Form  F_EXIT_LABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_EXIT_LABEL.
  DATA: V_CHARG1 LIKE V_TAB-ATWRT.
  DATA: V_CHARG2 LIKE V_TAB-ATWRT.
  DATA: LT_MAP_LABEL LIKE ZMAP_LABEL OCCURS 0 WITH HEADER LINE.
  DATA: EXECUTE(1).

  "Mapping Deconvert
  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_MAP_LABEL FROM ZMAP_LABEL WHERE TEXT1 = 'CONVB64'.
  IF SY-SUBRC NE 0. "Jika semua label sudah menerapkan, tinggal menghapus data di table dengan text1 CONVB64
    EXECUTE = 'X'.
  ELSE.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC EQ 0.
      READ TABLE LT_MAP_LABEL WITH KEY CODE = V_TAB-ATWRT TEXT1 = 'CONVB64'.
      IF SY-SUBRC EQ 0.
        EXECUTE = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

*- exit-001

  IF EXECUTE = 'X'.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZBARC1'.
    SPLIT V_TAB-ATWTB AT '-' INTO V_CHARG1 V_CHARG2.

    LOOP AT TEXT_DATA.
      IF TEXT_DATA-STR_TEXT CS '<STX><ESC>F"BARC  "<LF>' AND TEXT_DATA-STR_TEXT CS V_CHARG2.
        CONCATENATE '<STX><ESC>F"BARC  "<LF>' V_CHARG1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        MODIFY TEXT_DATA.
      ENDIF.

      IF TEXT_DATA-STR_TEXT CS 'STX><ESC>F"BARC1 "' AND TEXT_DATA-STR_TEXT CS V_TAB-ATWTB.
        CONCATENATE '<STX><ESC>F"BARC1 "<LF>' V_CHARG1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        MODIFY TEXT_DATA.
      ENDIF.

      IF TEXT_DATA-STR_TEXT CS 'STX><ESC>F"BCROLL"'.
        TEXT_DATA-STR_TEXT = '<STX><ESC>F"BCROLL"<LF><ETX>'.
        MODIFY TEXT_DATA.
      ENDIF.
    ENDLOOP.
  ENDIF.

*- exit-002

ENDFORM.                    "F_EXIT_LABEL