*&---------------------------------------------------------------------*
*&  Include           ZPPI_JR_EXEC_FTE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE STATUS_0800 OUTPUT.
  PERFORM TITLE USING SY-TCODE RCREATED.
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'LCHARG'.
        SCREEN-INVISIBLE = 1.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      WHEN 'FCHARG'.
        SCREEN-INVISIBLE = 1.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      WHEN 'LBLNOSHEET'.
        IF AUFK-AUART NE 'ZP11'.
          SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'AUFK-ZNOSHEET'.
        IF AUFK-AUART NE 'ZP11'.
          SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.

*JIKA RECREATE BATCH
  IF RCREATED = 1.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'LCHARG'.
          SCREEN-INVISIBLE = 0.
          SCREEN-ACTIVE = 1.
        WHEN 'FCHARG'.
*          IF FCHARG IS INITIAL.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          SCREEN-INVISIBLE = 0.
          SCREEN-ACTIVE = 1.
          SCREEN-OUTPUT = 1.
*          ENDIF.
        WHEN 'FTXTLOC'.
          IF FCHARG IS INITIAL.
            SCREEN-REQUIRED = 0.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-REQUIRED = 1.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'FTXTPERNR'.
          IF FCHARG IS INITIAL.
            SCREEN-REQUIRED = 0.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-REQUIRED = 1.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'FTXTSPD'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'FTXTPCS'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'FTXTSTUP'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'FTXTLBR'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'FTXTPJ'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'FTXTWINDER'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'AUFK-ZNOSHEET'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        WHEN 'AUFK-SDATE'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 1.
          ELSE.
            SCREEN-INPUT = 0.
          ENDIF.
        WHEN 'AUFK-ERFZEIT'.
          IF FCHARG IS INITIAL.
            SCREEN-INPUT = 1.
          ELSE.
            SCREEN-INPUT = 0.
          ENDIF.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
*  ***************************************
  IF ZDCODE IS NOT INITIAL.
    PERFORM VLD_SCR.
  ENDIF.

  CASE SY-UCOMM.
    WHEN '&F03'.
      PERFORM CLEAR.
      LEAVE TO SCREEN 0.
    WHEN '&F15'.
      LEAVE SCREEN.
    WHEN '&F12'.
      PERFORM CLEAR.
      LEAVE TO SCREEN 0.
    WHEN '&STOP'.
*- protect back month finish date
      IF AUFK-SDATE+0(6) < SY-DATUM+0(6).
        MESSAGE 'Bulan finish date tidak boleh mundur..!' TYPE 'I'.
        EXIT.
      ENDIF.
*- end
      DATA : CNUM TYPE STRING.

      IF FTXTPJ IS INITIAL.
        MOVE FTXTZLENGTH TO CNUM.
        MOVE CNUM TO FTXTPJ.
      ENDIF.

      IF FTXTLBR IS INITIAL.
        CLEAR : CNUM.
        MOVE FTXTZWIDTH TO CNUM.
        MOVE CNUM TO FTXTLBR.
      ENDIF.

*      VALIDASI###########################################################
      CLEAR : DERROR.
      LOOP AT IT_INPT WHERE ERMSG NE ''.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            TEXTLINE1 = IT_INPT-ERMSG.
        DERROR = 1.
      ENDLOOP.
      IF FCHARG IS NOT INITIAL.
        CHECK DERROR NE 1.
        PERFORM VLDT_RCRT.
      ENDIF.
      CHECK DERROR NE 1.
      PERFORM REQUIRED.
      CHECK DERROR NE 1.
      IF AUFK-AUART NE 'ZP01' AND AUFK-AUART NE 'ZP02' AND AUFK-AUART NE 'ZP10' AND AUFK-AUART NE 'ZP11' AND AUFK-AUART NE 'ZTR1' AND AUFK-AUART NE 'ZTR3'
      " Added by William at 24.07.2022 (OPP7 CPP1)
      AND AUFK-AUART NE 'ZP13' AND AUFK-AUART NE 'ZP15' AND AUFK-AUART NE 'ZP17'
      AND AUFK-AUART NE 'ZTR8' AND AUFK-AUART NE 'ZTR9' AND AUFK-AUART NE 'ZTRA' AND AUFK-AUART NE 'ZTRB' AND AUFK-AUART NE 'ZTRC'.
        " End added by William at 24.07.2022 (OPP7 CPP1)
        PERFORM VLD_LENGTH USING FTXTZLENGTH FTXTZWIDTH.
        CHECK DERROR NE 1.
      ENDIF.
      IF AUFK-AUART EQ 'ZP09' OR AUFK-AUART EQ 'ZTR6'
      "Added by Ryan at 05.01.2025 (Laminator #2 #3)
         OR AUFK-AUART EQ 'ZTRD'
      "END added by Ryan at 05.01.2025 (Laminator #2 #3)
        .
        PERFORM VLD_MATNR.
        PERFORM VLD_CKI.
      ENDIF.
      SHIFT FTXTPERNR LEFT DELETING LEADING '0'. "add FOR NEW COMPANY
      PERFORM AUTH USING AUFK-WERKS CRHD-ARBPL FTXTPERNR 'CRT' CHANGING DSTATUS.
      CHECK DERROR NE 1.
      PERFORM CHK_SLOC.
      CHECK DERROR NE 1.
      PERFORM DISPLAY.
*      #######################################################################
  ENDCASE.

  IF FCHARG IS INITIAL AND RCREATED = 1 AND DERROR NE 1.
    SET PF-STATUS 'ZEXECUTION' EXCLUDING '&STOP'.
  ELSE.
    SET PF-STATUS 'ZEXECUTION'.
  ENDIF.

  IF SY-UCOMM = 'YA'.
    DATA : TEXT TYPE STRING,
           TEXT2 TYPE STRING.
    CLEAR : LMSG, LSEQ, DCREATED, DSTATUS, BSTATUS. REFRESH : LMSG, TMPMSEG.
*    TRANSACTION
    IF MCHB-CHARG IS INITIAL.
      CLEAR : NBATCH, BSTATUS.
      PERFORM CRT_BATCH USING AFKO-PLNBEZ AUFK-WERKS FTXTLOC FTXTWINDER AUFK-ZLINE AUFK-ZCODE FTXTPJ FTXTLBR AUFK-ZTREAT FTXTSPD AUFK-AUFNR 'C' CHANGING NBATCH.

      IF DSTATUS NE 'X'.
        IF DSTATUS NE 'W'.
          CLEAR : TEXT2, RVSEQ, RVARBPL, RVMON.
          PERFORM UPD_MAT_LOT USING AFKO-PLNBEZ AUFK-WERKS NBATCH CHANGING TEXT2 RVARBPL RVMON RVSEQ.
        ENDIF.

        IF DSTATUS = 'E'." AND NBATCH IS NOT INITIAL. "DO CANCEL
          IF BSTATUS IS NOT INITIAL.
            PERFORM REVERSE USING AUFK-WERKS AFKO-PLNBEZ NBATCH.
          ELSE.
            PERFORM CCL_BATCH USING NBATCH AUFK-AUFNR AUFK-AUART '' FTXTPERNR.
          ENDIF.
          IF RVARBPL IS NOT INITIAL.
            ZSEQNUM-ARBPL = RVARBPL.
            ZSEQNUM-ZSEQNO = RVSEQ.
            ZSEQNUM-ZMONTH = RVMON.
            UPDATE ZSEQNUM.
          ENDIF.
          DSTATUS = 'E'.
        ENDIF.
      ENDIF.

      "Mat to Mat (Change Caracteristic Batch Input & Aksen)
      LOOP AT RE_INPT WHERE CHARG_ASAL IS NOT INITIAL.
        DATA: V_WERKS LIKE MCHA-WERKS.

        DATA: BEGIN OF IT_CHARG OCCURS 0,
              MATNR LIKE MCHA-MATNR,
              CHARG LIKE MCHA-CHARG,
             END OF IT_CHARG.

        "Mat to Mat Characteristic (Batch Aksen)
        IF DSTATUS NE 'E'.
          SELECT SINGLE WERKS INTO V_WERKS FROM MCHA WHERE CHARG EQ RE_INPT-CHARG.

          PERFORM VB_GD_TAB USING RE_INPT-PLNBEZ RE_INPT-CHARG V_WERKS.

          DELETE ZCHAR WHERE CHARACT = 'ZZLENGTH'.

          ZCHAR-CHARACT = 'ZZLENGTH'.
          MOVE RE_INPT-LENGTH_AKSEN TO ZCHAR-VALUE_CHAR.
          CONDENSE ZCHAR-VALUE_CHAR.
          APPEND ZCHAR.

          PERFORM CHG_CHAR USING RE_INPT-PLNBEZ V_WERKS RE_INPT-CHARG.

          "Mat to Mat Characteristic (Batch Input)
          IF RE_INPT-SCRAP IS INITIAL.
            PERFORM VB_GD_TAB USING RE_INPT-MATNR_ASAL RE_INPT-CHARG_ASAL V_WERKS.

            DELETE ZCHAR WHERE CHARACT = 'ZZLENGTH'.

            ZCHAR-CHARACT = 'ZZLENGTH'.
            MOVE RE_INPT-NLENGTH TO ZCHAR-VALUE_CHAR.
            CONDENSE ZCHAR-VALUE_CHAR.
            APPEND ZCHAR.

            PERFORM CHG_CHAR USING RE_INPT-MATNR_ASAL V_WERKS RE_INPT-CHARG_ASAL.
          ENDIF.
        ENDIF.

        RE_INPT-CHARG = RE_INPT-CHARG_ASAL.
        RE_INPT-PLNBEZ = RE_INPT-MATNR_ASAL.
        MODIFY RE_INPT.
      ENDLOOP.

      IT_INPT[] = RE_INPT[].
    ENDIF.

    IF DSTATUS = 'S'.
      DATA : ROLLNO TYPE STRING.
      ROLLNO = TEXT2.
      CONCATENATE : 'Batch Jumbo Roll yang dihasilkan : ' NBATCH INTO TEXT.
      CONCATENATE : 'Nomor Jumbo Roll yang dihasilkan : ' TEXT2 INTO TEXT2.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
        EXPORTING
*         TITEL        = ' '
          TEXTLINE1    = 'Transaksi SUKSES'
          TEXTLINE2    = TEXT
          TEXTLINE3    = TEXT2
          START_COLUMN = 25
*         START_ROW    =                       6
        .
      PERFORM INSERT_SQL USING NBATCH DAUFNR ROLLNO.
      DCREATED = 1.
      CLEAR : FCHARG,FTXTPERNR,FTXTSPD,FTXTPCS,FTXTSTUP,FTXTLOC,FTXTPJ,FTXTWINDER,AUFK-ZNOSHEET,IT_INPT,RE_INPT,WA_INPT, ZDCODE.
      REFRESH : IT_INPT, RE_INPT.
      AUFK-SDATE = SY-DATUM.
      AUFK-ERFZEIT = SY-UZEIT.
      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          I_MESSAGE_TAB = LMSG.
*      REFRESH CONTROL 'TC_INPUT' FROM SCREEN '0800'.
      IF AUFK-AUART NE 'ZP01' AND AUFK-AUART NE 'ZP02' AND AUFK-AUART NE 'ZP10' AND AUFK-AUART NE 'ZP11' AND AUFK-AUART NE 'ZTR1' AND AUFK-AUART NE 'ZTR3'
      " Added by William at 24.07.2022 (OPP7 CPP1)
      AND AUFK-AUART NE 'ZP13' AND AUFK-AUART NE 'ZP15' AND AUFK-AUART NE 'ZP17'
      AND AUFK-AUART NE 'ZTR8' AND AUFK-AUART NE 'ZTR9' AND AUFK-AUART NE 'ZTRA' AND AUFK-AUART NE 'ZTRB' AND AUFK-AUART NE 'ZTRC'.
        " End added by William at 24.07.2022 (OPP7 CPP1)
        LEAVE TO SCREEN 800.
      ENDIF.
    ELSE.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
        EXPORTING
*         TITEL        = ' '
          TEXTLINE1    = 'Transaksi GAGAL!!!'
          TEXTLINE2    = 'Nomor Jumbo Roll tidak berhasil terbentuk'
          TEXTLINE3    = 'Silahkan periksa kembali data yang anda input!'
          START_COLUMN = 25
*         START_ROW    =                       6
        .
      DCREATED = 0.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          I_MESSAGE_TAB = LMSG.
    ENDIF.
  ELSE.
*    SET PF-STATUS 'ZEXECUTION'.
    PERFORM GET_FT_DATA.

    IF AUFK-AUART EQ 'ZP02'.
*      TC_INPUT-INVISIBLE = 'X'.
      LOOP AT SCREEN.
        CASE SCREEN-NAME.
          WHEN 'WA_INPT-SCRAP'.
            SCREEN-INVISIBLE = 1.
            SCREEN-ACTIVE = 0.
            MODIFY SCREEN.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF AUFK-AUART EQ 'ZP11' AND DSTATUS NE 'S'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'LBLNOSHEET'.
          SCREEN-INVISIBLE = 0.
          SCREEN-ACTIVE = 1.
        WHEN 'AUFK-ZNOSHEET'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          SCREEN-INVISIBLE = 0.
          SCREEN-ACTIVE = 1.
          SCREEN-OUTPUT = 1.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  CONDENSE AUFK-ZLINE.
  IF ZDCODE IS NOT INITIAL.
    PERFORM VLD_SCR.
  ENDIF.
ENDMODULE.                 " STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0800 INPUT.
  CASE SY-UCOMM.
    WHEN '&F03'.
      PERFORM CLEAR.
      LEAVE TO SCREEN 0.
    WHEN '&F15'.
      LEAVE PROGRAM.
    WHEN '&F12'.
      PERFORM CLEAR.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0800  INPUT

*&---------------------------------------------------------------------*
*&      Form  GET_FT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_FT_DATA.
  DATA : ZPBASAL TYPE F,
         ZPYASAL TYPE F,
         ZPBBARU LIKE CALE-ABSDATE,
         ZPYBARU LIKE CALE-ABSDATE,
         ZWIDTH TYPE P,
         ZLENGTH TYPE P,
         ZNOSHEET TYPE P DECIMALS 2,
         DGAMNG TYPE AFKO-GAMNG,
         DMBLNR LIKE MSEG-MBLNR,
         DMJAHR LIKE MSEG-MJAHR,
         DFVDT LIKE MCHA-FVDT1.

  CLEAR DERROR.
  IF RCREATED = 1.
    IF FCHARG IS NOT INITIAL.
      IF VTMPCHARG IS INITIAL AND VTMPCHARG NE FCHARG.
        VTMPCHARG = FCHARG. " UNTUK CATAT HISTORY SEBELUMNYA
        PERFORM GET_FT_RDATA CHANGING DMBLNR DMJAHR. " GET DATA RECREATE
      ENDIF.
    ENDIF.
  ELSE.
    READ TABLE IT_TEMP INDEX 1.
    DOBJNR = IT_TEMP-DOBJNR.
    IF SY-SUBRC = 0.
      AUFK-AUFNR = IT_TEMP-DAUFNR.
      AUFK-WERKS = IT_TEMP-DWERKS.
      AFKO-PLNBEZ = IT_TEMP-DPLNBEZ.
      FTXTPLNROL = IT_TEMP-DGAMNG.
      AFKO-GMEIN = IT_TEMP-DGMEIN.
      CRHD-ARBPL = IT_TEMP-DARBPL.
    ENDIF.
  ENDIF.

  CHECK DOBJNR IS NOT INITIAL.
  CALL FUNCTION 'AIP9_STATUS_READ'
    EXPORTING
      I_OBJNR = DOBJNR
*     I_SPRAS = SY-LANGU
    IMPORTING
      E_SYSST = BSVX-STTXT
*     E_ANWST =
    EXCEPTIONS
      OTHERS  = 1.

  SELECT SINGLE AUART ZCODE ZWIDTH ZLENGTH ZLINE ZTREAT ZCUSTM ZNOSHEET
    INTO (AUFK-AUART,AUFK-ZCODE,AUFK-ZWIDTH,AUFK-ZLENGTH,AUFK-ZLINE,AUFK-ZTREAT,AUFK-ZCUSTM, AUFK-ZNOSHEET)
  FROM AUFK
    WHERE AUFNR = AUFK-AUFNR.

  MOVE AUFK-ZLENGTH TO FTXTZLENGTH.
  MOVE AUFK-ZWIDTH TO FTXTZWIDTH.
  IF FTXTLBR IS INITIAL.
    MOVE AUFK-ZWIDTH TO FTXTLBR.
  ENDIF.

  IF AUFK-AUART = 'ZP11'.
    LROL = 'Pac'.
    LROL2 = 'Pac'.
  ENDIF.

*THICKNESS*******************************************************
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZZCODE'
    IMPORTING
      OUTPUT = DATINN.

  SELECT SINGLE CAWNT~ATINN ATWTB
    INTO (CAWNT-ATINN, CAWNT-ATWTB)
  FROM CAWNT
   JOIN CAWN ON CAWN~ATINN = CAWNT~ATINN AND
                CAWN~ATZHL = CAWNT~ATZHL
  WHERE ATWRT = AUFK-ZCODE AND
        CAWN~ATINN = DATINN AND
        CAWNT~SPRAS = 'E'.

*HITUNG QTY PLAN***************************************************
  IF AUFK-ZCODE IS NOT INITIAL.
    CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
      EXPORTING
        VAR_TABLE       = 'ZZCODE'
*       CHANGE_NO       =
*       DATE            =
      TABLES
        VAR_TAB_ENTRIES = ZVENTRIES
      EXCEPTIONS
        ERROR           = 1
        OTHERS          = 2.

    CONDENSE AUFK-ZCODE.
    READ TABLE ZVENTRIES WITH KEY VTVALUE = AUFK-ZCODE.
    IF SY-SUBRC = 0.
      DELETE ZVENTRIES WHERE VTLINENO NE ZVENTRIES-VTLINENO.
      READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZGRAMMAGE'.
      IF SY-SUBRC = 0.
        MOVE ZVENTRIES-VTVALUE TO DTHICK.
        PDENS = 1.
        MOVE DTHICK TO PTHICK.

        IF DTHICK IS INITIAL.
          READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZTHICKNESS'.
          IF SY-SUBRC = 0.
            MOVE ZVENTRIES-VTVALUE TO DTHICK.
            REPLACE ALL OCCURRENCES OF ',' IN DTHICK WITH ''.
            MOVE DTHICK TO PTHICK.
          ENDIF.
          READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZDENSITY'.
          IF SY-SUBRC = 0.
            MOVE ZVENTRIES-VTVALUE TO DDENS.
            REPLACE ALL OCCURRENCES OF ',' IN DDENS WITH ''.
            MOVE DDENS TO PDENS.
          ENDIF.
        ENDIF.
      ELSE.
        READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZTHICKNESS'.
        IF SY-SUBRC = 0.
          MOVE ZVENTRIES-VTVALUE TO DTHICK.
          REPLACE ALL OCCURRENCES OF ',' IN DTHICK WITH ''.
          MOVE DTHICK TO PTHICK.
        ENDIF.
        READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZDENSITY'.
        IF SY-SUBRC = 0.
          MOVE ZVENTRIES-VTVALUE TO DDENS.
          REPLACE ALL OCCURRENCES OF ',' IN DDENS WITH ''.
          MOVE DDENS TO PDENS.
        ENDIF.
      ENDIF.

      SELECT SINGLE GAMNG GMEIN
        INTO (DGAMNG,AFKO-GMEIN)
      FROM AFKO
        WHERE AUFNR = AUFK-AUFNR.

      MOVE DGAMNG TO FTXTPLNROL.

      MOVE FTXTZWIDTH TO ZWIDTH.
      MOVE FTXTZLENGTH TO ZLENGTH.
      MOVE AUFK-ZNOSHEET TO ZNOSHEET.
*      IF AUFK-AUART = 'ZP11'.
*        ZPBASAL = ( ZWIDTH * ZLENGTH * PDENS * PTHICK * ZNOSHEET ) * 1000.
*        ZPYASAL = 1000000000000.
*      ELSE.
*        ZPBASAL = ( ZWIDTH * ZLENGTH * PDENS * PTHICK ) * 1000.
*        ZPYASAL = 1000000000.
*      ENDIF.
*
*      CALL FUNCTION 'CONVERT_TO_FRACT5'
*        EXPORTING
*          NOMIN                     = ZPBASAL
*          DENOMIN                   = ZPYASAL
*        IMPORTING
*          NOMOUT                    = ZPBBARU
*          DENOMOUT                  = ZPYBARU
*        EXCEPTIONS
*          CONVERSION_OVERFLOW       = 1
*          OTHERS                    = 2.

*      FTXTQTY = FTXTPLNROL * ZPBBARU / ZPYBARU.
      IF AUFK-AUART = 'ZP11'.
        ZPBASAL = ( ZWIDTH * ZLENGTH * PDENS * PTHICK * ZNOSHEET ).
        ZPYASAL = 1000000000.
      ELSE.
        ZPBASAL = ( ZWIDTH * ZLENGTH * PDENS * PTHICK ).
        ZPYASAL = 1000000.
      ENDIF.

      FTXTQTY = ZPBASAL / ZPYASAL * FTXTPLNROL.

      CALL FUNCTION 'Z_MMUR_ROUND_FOR_FRACT5'
        EXPORTING
          I_VALUE        = FTXTQTY
          I_DECIMALS     = 2
        IMPORTING
          O_NOMINATOR    = ZPBBARU
          O_DENOMINATOR  = ZPYBARU
          O_VALUE        = FTXTQTY
        EXCEPTIONS
          INPUT_INVALID  = 1
          OUTPUT_INVALID = 2
          OVERFLOW       = 3
          OTHERS         = 4.
    ENDIF.
  ENDIF.
*******************************************************************
*  ENDIF.

  IF LINES( IT_INPT ) < 9.
    DO 9 TIMES.
      APPEND IT_INPT.
    ENDDO.
  ENDIF.

  FTXTPLNLNGT = FTXTZLENGTH * FTXTPLNROL.

  PERFORM RECALCULATE.

  IF RCREATED = 1 AND FCHARG IS NOT INITIAL.
    CLEAR : ZDCODE, VLINE.
    SELECT SINGLE ZDCODE INTO  ZDCODE
      FROM ZTMAP_SLOC_JR_GR
    WHERE ZLINE = AUFK-ZLINE.
  ENDIF.

*  PERFORM UPD_STATUS USING AUFK-AUFNR CHANGING BSVX-STTXT.
ENDFORM.                    "GET_FT_DATA

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_INPUT' ITSELF
CONTROLS: TC_INPUT TYPE TABLEVIEW USING SCREEN 0800.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_INPUT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_INPUT_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_INPT LINES TC_INPUT-LINES.
ENDMODULE.                    "TC_INPUT_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_INPUT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_INPUT_MODIFY INPUT.
  READ TABLE IT_INPT INDEX TC_INPUT-CURRENT_LINE.
  CLEAR : IT_INPT,DERROR, WA_INPT-PLNBEZ, WA_INPT-TFILM, DMATNR, DOLENGTH, VFILM.
  WRITE WA_INPT-CHARG TO IT_INPT-CHARG.
  WRITE WA_INPT-LGORT TO IT_INPT-LGORT.
  MOVE WA_INPT-SPJG TO IT_INPT-SPJG.
  MOVE WA_INPT-REUSE TO IT_INPT-REUSE.
  MOVE WA_INPT-SCRAP TO IT_INPT-SCRAP.
  MOVE WA_INPT-OSCRAP TO IT_INPT-OSCRAP.

  MODIFY IT_INPT INDEX TC_INPUT-CURRENT_LINE.
*#####################################################################################################
  IF WA_INPT-LGORT IS INITIAL AND AUFK-ZLINE IS NOT INITIAL.
    SELECT SINGLE ZSLOCGIJR INTO WA_INPT-LGORT
      FROM ZTMAP_SLOC_JR_GR
    WHERE ZLINE = AUFK-ZLINE.
  ENDIF.

  CHECK ( WA_INPT-CHARG IS NOT INITIAL OR WA_INPT-SPJG IS NOT INITIAL ).
  IF WA_INPT-CHARG = '' OR WA_INPT-SPJG = ''.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = 'Masukkan Batch inputan dan Sisa Panjang inputan!!'.
    DERROR = 1.
  ELSE.
*  TYPE FILM**************************************
    CLEAR : DMATNR,ZCLBATCH.
    REFRESH : ZCLBATCH.
    SELECT SINGLE MATNR INTO WA_INPT-PLNBEZ"DMATNR
      FROM MCHB
    WHERE CHARG = WA_INPT-CHARG AND
          WERKS = AUFK-WERKS AND
          LGORT = WA_INPT-LGORT.

    IF WA_INPT-PLNBEZ IS NOT INITIAL.
      PERFORM VBGETDET USING WA_INPT-PLNBEZ WA_INPT-CHARG AUFK-WERKS 'ZZCODE' CHANGING WA_INPT-TFILM.
      READ TABLE ZCLBATCH WITH KEY ATNAM = 'ZZLENGTH'.
      IF SY-SUBRC = 0.
        MOVE ZCLBATCH-ATWTB TO DOLENGTH.
        REPLACE ALL OCCURRENCES OF ',' IN DOLENGTH WITH ''.
        MOVE DOLENGTH TO WA_INPT-OLENGTH.
      ENDIF.
      CLEAR : DOLENGTH.
      READ TABLE ZCLBATCH WITH KEY ATNAM = 'ZZWIDTH'.
      IF SY-SUBRC = 0.
        MOVE ZCLBATCH-ATWTB TO DOLENGTH.
        REPLACE ALL OCCURRENCES OF ',' IN DOLENGTH WITH ''.
        MOVE DOLENGTH TO WA_INPT-OWIDTH.
      ENDIF.

      READ TABLE ZCLBATCH WITH KEY ATNAM = 'ZZGRAMMAGE'.
      IF SY-SUBRC = 0.
        MOVE ZCLBATCH-ATWTB TO WA_INPT-GRM.
        REPLACE ALL OCCURRENCES OF ',' IN WA_INPT-GRM WITH ''.
      ENDIF.
    ENDIF.

    PERFORM GT_CHR_VAL USING WA_INPT-TFILM 'ZZCODE' CHANGING WA_INPT-CFILM.
    IF WA_INPT-CFILM IS NOT INITIAL.
      CONCATENATE '%' WA_INPT-CFILM '%' INTO VFILM.
      SELECT SINGLE MATNR INTO DMATNR
        FROM RESB
      WHERE AUFNR = AUFK-AUFNR AND
            MATNR LIKE VFILM.

      IF DMATNR IS INITIAL.
        CLEAR DMESSAGE.
        CONCATENATE 'Batch' WA_INPT-CHARG 'tidak sesuai dengan kode film' INTO WA_INPT-ERMSG SEPARATED BY SPACE.
        WRITE WA_INPT-ERMSG TO IT_INPT-ERMSG.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            TEXTLINE1 = WA_INPT-ERMSG.
        DERROR = 1.
      ELSE.
        WRITE '' TO IT_INPT-ERMSG.
      ENDIF.
    ELSE.
      CLEAR DMESSAGE.
      CONCATENATE 'Batch' WA_INPT-CHARG 'tidak memiliki kode film yang sesuai' INTO WA_INPT-ERMSG SEPARATED BY SPACE.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = WA_INPT-ERMSG.
      DERROR = 1.
    ENDIF.

*    VALIDASI STOCK*******************************************************
*    IF DERROR IS INITIAL.
*      CLEAR : DBDMNG, DCLABS, DMESSAGE.
*      SELECT SUM( BDMNG ) INTO DBDMNG
*        FROM RESB
*      WHERE MATNR = WA_INPT-PLNBEZ AND
*            AUFNR = AUFK-AUFNR AND
*            LGORT = WA_INPT-LGORT.
*
*      SELECT SUM( CLABS ) INTO DCLABS
*        FROM MCHB
*      WHERE MATNR = WA_INPT-PLNBEZ AND
*            LGORT = WA_INPT-LGORT AND
*            WERKS = AUFK-WERKS.
*
*      IF FTXTPLNROL = 0.
*        DBDMNG = 0.
*      ELSE.
*        DBDMNG = DBDMNG / FTXTPLNROL.
*      ENDIF.
*
*      IF DBDMNG GT DCLABS.
*        CLEAR DMESSAGE.
*        CONCATENATE 'Stock untuk batch' WA_INPT-CHARG 'tidak tersedia' INTO WA_INPT-ERMSG SEPARATED BY SPACE.
*        WRITE WA_INPT-ERMSG TO IT_INPT-ERMSG.
*        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*            TEXTLINE1 = WA_INPT-ERMSG.
*        DERROR = 1.
*      ELSE.
*        WRITE '' TO IT_INPT-ERMSG.
*      ENDIF.
*    ENDIF.

    WRITE WA_INPT-PLNBEZ TO IT_INPT-PLNBEZ.
    WRITE WA_INPT-REUSE TO IT_INPT-REUSE.
    WRITE WA_INPT-SCRAP TO IT_INPT-SCRAP.
    WRITE WA_INPT-TFILM TO IT_INPT-TFILM.
    WRITE WA_INPT-CFILM TO IT_INPT-CFILM.
    MOVE WA_INPT-OLENGTH TO IT_INPT-OLENGTH.
    MOVE WA_INPT-OWIDTH TO IT_INPT-OWIDTH.
    MOVE WA_INPT-GRM TO IT_INPT-GRM.

    " add New Company  menambahkan text 'Jumbo roll di batch inputan'
    IF WA_INPT-PLNBEZ(2) EQ 'JR'.
      CONCATENATE 'Jumbo Roll' IT_INPT-TFILM INTO IT_INPT-TFILM SEPARATED BY SPACE.
    ELSEIF WA_INPT-PLNBEZ(2) EQ 'SR'.
      CONCATENATE 'Slitt Roll' IT_INPT-TFILM INTO IT_INPT-TFILM SEPARATED BY SPACE.
    ENDIF.
    " end add New Company

    MODIFY IT_INPT INDEX TC_INPUT-CURRENT_LINE.
  ENDIF.
ENDMODULE.                    "TC_INPUT_MODIFY INPUT

*&---------------------------------------------------------------------*
*&      Form  REQUIRED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REQUIRED.
  CLEAR : DERROR.
  CHECK AUFK-AUART = 'ZP03' AND AUFK-AUART = 'ZP04' AND AUFK-AUART = 'ZP05' AND AUFK-AUART = 'ZP06' AND AUFK-AUART = 'ZP09' AND AUFK-AUART = 'ZTR2' AND AUFK-AUART = 'ZTR4'
  AND AUFK-AUART = 'ZP14' AND AUFK-AUART = 'ZP16' AND AUFK-AUART = 'ZP18'  " Added by William at 26.07.2022 (OPP7 CPP1)
  "Added by Ryan at 05.01.2025 (Laminator #2 #3)
  AND AUFK-AUART = 'ZTRD'.
  "END added by Ryan at 05.01.2025 (Laminator #2 #3)
  READ TABLE IT_INPT INDEX 1.
  IF IT_INPT-CHARG = '' AND IT_INPT-SPJG = ''.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = 'Masukkan Batch inputan dan Sisa Panjang inputan!!'.
    DERROR = 1.
  ENDIF.
ENDFORM.                    "REQUIRED

*&---------------------------------------------------------------------*
*&      Form  DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY.
  IF V_CANC_JOIN EQ 'X'.
    CLEAR V_CANC_JOIN.
    EXIT.
  ENDIF.

  CLEAR : DANSWR.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR              = ' '
      TEXT_QUESTION         = 'Apakah Jumbo Roll yang dihasilkan OK?'
      TEXT_BUTTON_1         = 'Ya'
      TEXT_BUTTON_2         = 'Tidak'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = DANSWR
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF DANSWR = 1.
    FTXTJRSTAT = 'OK'.
  ELSE.
    FTXTJRSTAT = 'NA'.
  ENDIF.

  IF AUFK-AUART = 'ZP01' OR AUFK-AUART = 'ZP02' OR AUFK-AUART = 'ZP10' OR AUFK-AUART = 'ZP11' OR AUFK-AUART = 'ZTR1' OR AUFK-AUART = 'ZTR3'
  " Added by William at 24.07.2022 (OPP7 CPP1)
  OR AUFK-AUART = 'ZP13' OR AUFK-AUART = 'ZP15' OR AUFK-AUART = 'ZP17'
  OR AUFK-AUART = 'ZTR8' OR AUFK-AUART = 'ZTR9' OR AUFK-AUART = 'ZTRA' OR AUFK-AUART = 'ZTRB' OR AUFK-AUART = 'ZTRC'.
    " End added by William at 24.07.2022 (OPP7 CPP1)
    CALL SCREEN 1300 STARTING AT 30 6.
  ELSE.
    CALL SCREEN 900 STARTING AT 30 2.
  ENDIF.

ENDFORM.                    "DISPLAY
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMODULE.                 " USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.
  SET PF-STATUS 'TEXT' .
  SET TITLEBAR '000' WITH 'Konfirmasi'.
ENDMODULE.                 " STATUS_0900  OUTPUT


*&SPWIZARD: DECLARATION OF TABLECONTROL 'IT_INPUT' ITSELF
CONTROLS: IT_INPUT TYPE TABLEVIEW USING SCREEN 0900.

*&SPWIZARD: OUTPUT MODULE FOR TC 'IT_INPUT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE IT_INPUT_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_INPT LINES IT_INPUT-LINES.
ENDMODULE.                    "IT_INPUT_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Form  CLEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CLEAR.
  CLEAR : FTXTPCS, FTXTLBR, FTXTPJ, IT_INPT, AUFK, FTXTQTY, FTXTSPD, DERROR, FTXTPERNR, FTXTLOC, FTXTSTUP, FTXTWINDER, CRHD,AUFK, AFKO,TJ02T,BSVX,AFPO,CAWNT.
  REFRESH : IT_INPT.
ENDFORM.                    "CLEAR
*&---------------------------------------------------------------------*
*&      Module  CALCULATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CALCULATE INPUT.
  IF FTXTSPD IS NOT INITIAL.
    IF FTXTPJ IS NOT INITIAL AND FTXTSPD IS NOT INITIAL.
      FTXTPCS = FTXTPJ / FTXTSPD.
    ELSE.
      IF FTXTZLENGTH NE 0.
        FTXTPCS = FTXTZLENGTH / FTXTSPD.
      ELSE.
        FTXTPCS = 0.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CALCULATE  INPUT

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROG       text
*      -->SCR        text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TCODE      text
*----------------------------------------------------------------------*
FORM BDC_TRANSACTION USING TCODE.
  DATA: L_MSTRING(480).
  WAIT UP TO '0.5' SECONDS.
  REFRESH : IT_BDCMSGCOLL, ZBRETURN.
  OPT-DEFSIZE = 'X'.
  OPT-DISMODE = 'E'.
  OPT-UPDMODE = 'S'.
  OPT-RACOMMIT = 'X'.
  CALL TRANSACTION TCODE USING IT_BDCDATA
                  OPTIONS FROM OPT
                  MESSAGES INTO IT_BDCMSGCOLL.

  LOOP AT IT_BDCMSGCOLL.
    MESSAGE ID     IT_BDCMSGCOLL-MSGID
            TYPE   IT_BDCMSGCOLL-MSGTYP
            NUMBER IT_BDCMSGCOLL-MSGNR
            INTO L_MSTRING
            WITH IT_BDCMSGCOLL-MSGV1
                 IT_BDCMSGCOLL-MSGV2
                 IT_BDCMSGCOLL-MSGV3
                 IT_BDCMSGCOLL-MSGV4.
    ZBRETURN-TYPE = IT_BDCMSGCOLL-MSGTYP.
    MOVE L_MSTRING(250) TO ZBRETURN-MESSAGE.
    APPEND ZBRETURN.
  ENDLOOP.
ENDFORM.                    "BDC_TRANSACTION

*&---------------------------------------------------------------------*
*&      Form  BAPI_COMMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BAPI_COMMIT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDFORM.                    "BAPI_COMMIT

*&---------------------------------------------------------------------*
*&      Form  BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BAPI_ROLLBACK.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
ENDFORM.                    "BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.
  IF OKCODE NE '&BTL'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.
  SET PF-STATUS 'ZBLANK'.
*  SET TITLEBAR 'xxx'.
*  CLEAR : TXTREASON, TXTNIK.
  MOVE IT_ORDER-CHARG TO BCHARG.
ENDMODULE.                 " STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TRANSACTION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TRANSACTION INPUT.
  DATA : MTXT TYPE STRING,
         DARBPL LIKE CRHD-ARBPL,
         DWERKS LIKE MSEG-WERKS,
         DPERNR LIKE AFRU-PERNR,
         DMBLNR LIKE MSEG-MBLNR.

  IF OKCODE = '&BTL'.
    CLEAR : LMSG,DSTATUS,DRUECK,DRMZHL. REFRESH : LMSG.

    SELECT SINGLE MBLNR INTO DMBLNR
      FROM MSEG
    WHERE CHARG = DCHARG AND
          BWART = '101'.

    SELECT SINGLE PERNR INTO DPERNR
      FROM AFRU
    WHERE LTXA1 = DMBLNR.

    MOVE DPERNR TO TXTNIK.

    CONCATENATE TXTNIK '-' TXTREASON INTO TXTREASON.

    PERFORM GT_WRK_CTR USING BCHARG CHANGING DARBPL DWERKS.
    PERFORM AUTH USING DWERKS DARBPL TXTNIK 'CCL' CHANGING DSTATUS.
    IF DSTATUS NE 'P'.
      PERFORM CCL_BATCH USING DCHARG DAUFNR DAUART TXTREASON TXTNIK.
    ENDIF.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        I_MESSAGE_TAB = LMSG.

    IF DSTATUS NE 'E'.
      PERFORM INSERT_SQL USING DCHARG '' ''.
    ENDIF.

    CLEAR : LMSG. REFRESH : LMSG.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " TRANSACTION  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1200 OUTPUT.
*  SET PF-STATUS 'ZINFO'.
*  SET TITLEBAR 'xxx'.

*  LEAVE TO LIST-PROCESSING. "AND RETURN TO SCREEN 0.
*  LOOP AT ZINFO.
*    WRITE : / ZINFO-NOTES.
*  ENDLOOP.
*  LEAVE SCREEN.
  CLEAR : IT_INPT. REFRESH :  IT_INPT.
ENDMODULE.                 " STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.
*  IF SY-UCOMM = '&CCL'.
*    LEAVE TO SCREEN 0.
*  ENDIF.
ENDMODULE.                 " USER_COMMAND_1200  INPUT
" POPUP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SC_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SC_HELP INPUT.
  REFRESH IT_F4.

  SELECT DISTINCT ZSLOCJR ZLDESC ZSLOCDESC
    INTO CORRESPONDING FIELDS OF TABLE IT_F4
  FROM ZTMAP_SLOC_JR_GR
    WHERE ZLINE = AUFK-ZLINE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ZSLOCJR'
      WINDOW_TITLE = 'Sloc JR Help List'
      VALUE_ORG    = 'S'
      DYNPROFIELD  = 'ZSLOCJR'
    TABLES
      VALUE_TAB    = IT_F4
      RETURN_TAB   = IT_RETURN.

  FTXTLOC = IT_RETURN-FIELDVAL.

ENDMODULE.                 " SC_HELP  INPUT

*&---------------------------------------------------------------------*
*&      Form  VLD_SCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VLD_SCR.
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'FTXTSPD'.
        IF ZDCODE = 'S' OR ZDCODE = 'SPT' OR ZDCODE = 'SS'.
          SCREEN-INVISIBLE = 0. "required
          SCREEN-INPUT = 1.
          SCREEN-OUTPUT = 1.
          SCREEN-REQUIRED = 1.
          SCREEN-ACTIVE = 1.
        ELSEIF ZDCODE = 'PT'.
          SCREEN-INVISIBLE = 1. "hidden
          SCREEN-INPUT = 0.
          SCREEN-OUTPUT = 0.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 0.
        ENDIF.
      WHEN 'FTXTPCS'.
        IF ZDCODE = 'S' OR ZDCODE = 'SS'.
          SCREEN-INVISIBLE = 0. "grey
          SCREEN-INPUT = 0.
          SCREEN-OUTPUT = 1.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 1.
        ELSEIF ZDCODE = 'PT'.
          SCREEN-INVISIBLE = 0. "required
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          SCREEN-OUTPUT = 1.
          SCREEN-ACTIVE = 1.
        ELSEIF ZDCODE = 'SPT'.
          SCREEN-INVISIBLE = 0. "optional
          IF FTXTSPD IS NOT INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
          SCREEN-OUTPUT = 1.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 1.
        ENDIF.
      WHEN 'FTXTSTUP'.
        IF ZDCODE = 'S'.
          SCREEN-INVISIBLE = 1. "hidden
          SCREEN-INPUT = 0.
          SCREEN-OUTPUT = 0.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 0.
        ELSEIF ZDCODE = 'PT' OR ZDCODE = 'SPT' OR ZDCODE = 'SS'.
          SCREEN-INVISIBLE = 0. "optional
          SCREEN-INPUT = 1.
          SCREEN-OUTPUT = 1.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 1.
        ENDIF.
    ENDCASE.
    IF SCREEN-GROUP1 = 'SPD'.
      IF ZDCODE = 'S' OR ZDCODE = 'SPT' OR ZDCODE = 'SS'.
        SCREEN-INVISIBLE = 0. "required
        SCREEN-ACTIVE = 1.
      ELSEIF ZDCODE = 'PT'.
        SCREEN-INVISIBLE = 1. "hidden
        SCREEN-ACTIVE = 0.
      ENDIF.
    ELSEIF SCREEN-GROUP1 = 'SUT'.
      IF ZDCODE = 'S'.
        SCREEN-INVISIBLE = 1. "hidden
        SCREEN-ACTIVE = 0.
      ELSEIF ZDCODE = 'PT' OR ZDCODE = 'SPT' OR ZDCODE = 'SS'.
        SCREEN-INVISIBLE = 0. "optional
        SCREEN-ACTIVE = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    "VLD_SCR
*&---------------------------------------------------------------------*
*&      Module  GET_CODE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CODE OUTPUT.
  CLEAR : DOBJNR.
  IF ZDCODE IS INITIAL.
    IF RCREATED IS INITIAL.
      AUFK-AUFNR = IT_TEMP-DAUFNR.
    ELSE.
      AUFK-AUFNR = IT_ORDER-AUFNR.
      IF AUFK-AUFNR IS INITIAL.
        AUFK-AUFNR = IT_EXEC-AUFNR.
      ENDIF.
    ENDIF.
    SELECT SINGLE AUART ZCODE ZWIDTH ZLENGTH ZLINE ZTREAT ZCUSTM ZNOSHEET OBJNR
      INTO (AUFK-AUART,AUFK-ZCODE,AUFK-ZWIDTH,AUFK-ZLENGTH,AUFK-ZLINE,AUFK-ZTREAT,AUFK-ZCUSTM, AUFK-ZNOSHEET, DOBJNR)
    FROM AUFK
      WHERE AUFNR = AUFK-AUFNR.

    MOVE AUFK-ZLENGTH TO FTXTZLENGTH.
    MOVE AUFK-ZWIDTH TO FTXTZWIDTH.

    SELECT SINGLE ZDCODE ZLINE
      INTO (ZDCODE,VLINE)
    FROM ZTMAP_SLOC_JR_GR
      WHERE ZLINE = AUFK-ZLINE.

    IF AUFK-SDATE IS INITIAL.
      AUFK-SDATE = IT_TEMP-DSDATE.
      AUFK-ERFZEIT = IT_TEMP-DERFZEIT.
    ENDIF.

    IF LINES( IT_INPT ) = 0.
      DO 9 TIMES.
        SELECT SINGLE ZSLOCGIJR INTO IT_INPT-LGORT
          FROM ZTMAP_SLOC_JR_GR
        WHERE ZLINE = AUFK-ZLINE.
        APPEND IT_INPT.
      ENDDO.
    ENDIF.

    IF RCREATED IS NOT INITIAL AND FCHARG IS INITIAL. "UNTUK MEMATIKAN MANDATORY AWAL PADA REEXECUTE
      CLEAR : ZDCODE, VLINE.
    ENDIF.
  ENDIF.
ENDMODULE.                 " GET_CODE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CLEAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR INPUT.
  CLEAR : LMSG, LSEQ, DERROR. REFRESH : LMSG.
ENDMODULE.                 " CLEAR  INPUT

*&---------------------------------------------------------------------*
*&      Form  VLDT_RCRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VLDT_RCRT.
  DATA : DCHARG LIKE MCHB-CHARG,
         DOBJNR LIKE IMZO-OBJNR,
         DFVDT LIKE MCHA-FVDT1.

  DCHARG = FCHARG.
* CHECK AFKO-PLNBEZ IS INITIAL.
  DATA : ZWINDER TYPE C LENGTH 40.

  PERFORM GT_WRK_CTR USING FCHARG CHANGING CRHD-ARBPL AUFK-WERKS.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = FCHARG
    IMPORTING
      OUTPUT = FCHARG.

  IF FCHARG IS INITIAL.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = 'Batch tersebut tidak ditemukan'.
    DERROR = 1.
  ENDIF.

  CHECK FCHARG IS NOT INITIAL.

  PERFORM VLD_RE_BATCH USING FCHARG.

  CHECK DERROR IS INITIAL.

  IF AUFK-AUFNR IS INITIAL.
    CLEAR DMESSAGE.
    CONCATENATE 'Batch' FCHARG 'tidak dapat memiliki order' INTO DMESSAGE SEPARATED BY SPACE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = DMESSAGE.
    DERROR = 1.
  ENDIF.

  CHECK DERROR IS INITIAL.

  IF AFKO-PLNBEZ IS INITIAL.
    CLEAR DMESSAGE.
    CONCATENATE 'Order' AUFK-AUFNR 'tidak memiliki Material' INTO DMESSAGE SEPARATED BY SPACE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = DMESSAGE.
    DERROR = 1.
  ENDIF.

  CHECK DERROR IS INITIAL.

  DATA : VAUFNR LIKE AFRU-AUFNR.
  VAUFNR = IT_ORDER-AUFNR.
  IF VAUFNR IS INITIAL.
    VAUFNR = IT_EXEC-AUFNR.
  ENDIF.

  IF AUFK-AUFNR NE VAUFNR.
    CLEAR DMESSAGE.
    CONCATENATE 'Batch tersebut tidak dapat dilakukan pada order' AUFK-AUFNR INTO DMESSAGE SEPARATED BY SPACE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = DMESSAGE.
    DERROR = 1.
  ENDIF.
*
* IF DMBLNR IS INITIAL.
*   MESSAGE 'No Batch Reference yang diinput salah' TYPE 'I'.
* ENDIF.
ENDFORM.                    "VLDT_RCRT

*&---------------------------------------------------------------------*
*&      Form  VLD_RE_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZCHARG     text
*----------------------------------------------------------------------*
FORM VLD_RE_BATCH USING ZCHARG.
  DATA : DFVDT LIKE MCHA-FVDT1,
         VMBLNR LIKE MSEG-MBLNR,
         VSTOKZ LIKE AFRU-STOKZ.

  SELECT SINGLE FVDT1 INTO DFVDT
    FROM MCH1
  WHERE CHARG = ZCHARG.

  IF DFVDT IS NOT INITIAL.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = 'Batch tersebut sudah pernah dieksekusi'.
    DERROR = 1.
  ENDIF.

  CHECK DERROR IS INITIAL.

  SELECT SINGLE MBLNR INTO VMBLNR
    FROM MSEG
  WHERE CHARG = ZCHARG AND
        BWART = '101'.

  SELECT SINGLE STOKZ INTO VSTOKZ
    FROM AFRU
  WHERE LTXA1 = VMBLNR.

  IF VSTOKZ IS INITIAL.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = 'Batch tersebut belum pernah cancel'.
    DERROR = 1.
  ENDIF.
ENDFORM.                    "VLD_RE_BATCH

*&---------------------------------------------------------------------*
*&      Form  GET_FT_RDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DMBLNR     text
*      -->DMJAHR     text
*----------------------------------------------------------------------*
FORM GET_FT_RDATA CHANGING DMBLNR DMJAHR.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = FCHARG
    IMPORTING
      OUTPUT = FCHARG.

  CLEAR : AUFK-AUFNR, DOBJNR, AFKO-PLNBEZ, AUFK-WERKS, FTXTLOC, DCHARG.

  SELECT SINGLE MSEG~AUFNR OBJNR MBLNR MJAHR
    INTO (AUFK-AUFNR,DOBJNR,DMBLNR, DMJAHR)
  FROM MSEG
    JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
  WHERE CHARG = FCHARG AND
        BWART = '101' AND
        AUART IN ('ZP01','ZP02','ZP03','ZP04','ZP05','ZP06','ZP07','ZP08','ZP09','ZP10','ZP11','ZTR1','ZTR2','ZTR3','ZTR4','ZTR5','ZTR6',
                  'ZP13','ZP14','ZP15','ZP16','ZP17','ZP18','ZTR8','ZTR9','ZTRA','ZTRB','ZTRC',  " Added by William at 24.07.2022 (OPP7 CPP1)
                  "Added by Ryan at 05.01.2025 (Laminator #2 #3)
                  'ZTRD').
  "END added by Ryan at 05.01.2025 (Laminator #2 #3)

  IF AUFK-AUFNR IS INITIAL.
    CLEAR DMESSAGE.
    CONCATENATE 'Batch' FCHARG 'tidak dapat memiliki order' INTO DMESSAGE SEPARATED BY SPACE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = DMESSAGE.
    DERROR = 1.
  ENDIF.
  CHECK AUFK-AUFNR IS NOT INITIAL.

* CHECK MATERIAL*******************************************************************
  SELECT SINGLE MATNR WERKS LGORT CHARG
     INTO (AFKO-PLNBEZ, AUFK-WERKS, FTXTLOC, DCHARG)
   FROM MCHB
    JOIN ZTMAP_SLOC_JR_GR ON MCHB~LGORT = ZTMAP_SLOC_JR_GR~ZSLOCJR
     WHERE CHARG = FCHARG.

  IF AFKO-PLNBEZ IS INITIAL.
    CLEAR DMESSAGE.
    CONCATENATE 'Order' AUFK-AUFNR 'tidak memiliki Material' INTO DMESSAGE SEPARATED BY SPACE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = DMESSAGE.
    DERROR = 1.
  ENDIF.
  CHECK AFKO-PLNBEZ IS NOT INITIAL.
****************************************************************************************************
  PERFORM VLD_RE_BATCH USING FCHARG.

  DATA : VAUFNR LIKE AFRU-AUFNR.
  VAUFNR = IT_ORDER-AUFNR.
  IF VAUFNR IS INITIAL.
    VAUFNR = IT_EXEC-AUFNR.
  ENDIF.

  IF AUFK-AUFNR NE VAUFNR.
    CLEAR DMESSAGE.
    CONCATENATE 'Batch tersebut tidak dapat dilakukan pada order' AUFK-AUFNR INTO DMESSAGE SEPARATED BY SPACE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = DMESSAGE.
    DERROR = 1.
  ENDIF.

  SELECT SINGLE IEDD IEDZ
    INTO (AUFK-SDATE,AUFK-ERFZEIT)
  FROM  AFRU
    WHERE LTXA1 = DMBLNR.

  PERFORM GT_WINDER USING FCHARG AFKO-PLNBEZ CHANGING FTXTWINDER.
ENDFORM.                    "GET_FT_RDATA


*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BATCH    text
*----------------------------------------------------------------------*
FORM INSERT_SQL USING P_BATCH P_AUFNR P_ROLLNO.
  RANGES : R_CHARG FOR MSEG-CHARG.
  REFRESH : R_CHARG. CLEAR : R_CHARG.

  IF P_BATCH IS NOT INITIAL.
    R_CHARG-SIGN = 'I'.
    R_CHARG-OPTION = 'EQ'.
    R_CHARG-LOW = P_BATCH.
    APPEND R_CHARG.
    SUBMIT ZTPPR_NEW_LIST_JR WITH S_CHARG IN R_CHARG AND RETURN.
    SUBMIT ZTPPR_JR_DAILY_PROCESS_CV_TH WITH S_CHARG IN R_CHARG AND RETURN.
    SUBMIT ZTPPI_CHANGE_BOM_PO WITH S_CHARG IN R_CHARG AND RETURN.
  ENDIF.

  IF P_AUFNR IS NOT INITIAL.
    RANGES : R_AUFNR FOR AUFK-AUFNR.
    REFRESH : R_AUFNR. CLEAR : R_AUFNR.

    R_AUFNR-SIGN = 'I'.
    R_AUFNR-OPTION = 'EQ'.
    R_AUFNR-LOW = P_AUFNR.
    APPEND R_AUFNR.
    SUBMIT ZTPPR_PRO_RAW_RECYCLE WITH S_AUFNR IN R_AUFNR AND RETURN.
  ENDIF.

  IF SY-TCODE = 'ZTYB01' AND P_BATCH IS NOT INITIAL.
    SUBMIT ZTTYB_LABEL WITH P_CHARG IN R_CHARG AND RETURN.
  ENDIF.

  IF P_ROLLNO IS NOT INITIAL.
    IF AUFK-AUART = 'ZP01' OR AUFK-AUART = 'ZP02' OR AUFK-AUART = 'ZP10' OR AUFK-AUART = 'ZP11' OR AUFK-AUART = 'ZTR1' OR AUFK-AUART = 'ZTR3'
    " Added by William at 24.07.2022 (OPP7 CPP1)
    OR AUFK-AUART = 'ZP13' OR AUFK-AUART = 'ZP15' OR AUFK-AUART = 'ZP17'
    OR AUFK-AUART = 'ZTR8' OR AUFK-AUART = 'ZTR9' OR AUFK-AUART = 'ZTRA' OR AUFK-AUART = 'ZTRB' OR AUFK-AUART = 'ZTRC'.
      " End added by William at 24.07.2022 (OPP7 CPP1)
    ELSE.
      RANGES : R_ROLLNO FOR MKPF-BKTXT.
      REFRESH : R_ROLLNO.
      R_ROLLNO-SIGN = 'I'.
      R_ROLLNO-OPTION = 'EQ'.
      R_ROLLNO-LOW = P_ROLLNO.
      APPEND R_ROLLNO.
      CLEAR R_ROLLNO.
      IF R_ROLLNO[] IS NOT INITIAL.
        SUBMIT ZTPPR_PRO_MOVEMENT WITH S_BKTXT IN R_ROLLNO AND RETURN.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "INSERT_SQL

*&---------------------------------------------------------------------*
*&      Form  VLD_CKI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VLD_CKI.
  DATA: IT_MAPPING LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE,
        LOTNUMB TYPE I VALUE 0,
        LOTCHAR TYPE ATNAM VALUE 'ZZNOLOTSUBCONT',
        LOTCHAR_COUNT TYPE ATNAM,
        LOTVAL  TYPE ATWRT,
        V_ATWRT TYPE ATWRT,
        V_MATKL TYPE MATKL,
        V_COUNT_PRINT TYPE I,
        V_LOT1 TYPE I,
        V_LOT2 TYPE I.


  DATA: BEGIN OF IT_LOT OCCURS 0,
       CHARG   TYPE CHARG_D,
       LOT     TYPE ATWRT,
      END OF IT_LOT.

  DATA: IT_LOT2 LIKE IT_LOT OCCURS 0.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAPPING
    FROM ZMAP_TYPE
   WHERE TCODE    EQ SY-TCODE
     AND TYPE     EQ 'MATERIAL GROUP'
     AND OPT      EQ 'SUBCONTRACTING'
     AND DELETION EQ ''.

  IF IT_MAPPING[] IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAPPING
    FROM ZMAP_TYPE
   WHERE PROG     EQ SY-CPROG
     AND TYPE     EQ 'MATERIAL GROUP'
     AND OPT      EQ 'SUBCONTRACTING'
     AND DELETION EQ ''.
  ENDIF.

  IF IT_MAPPING[] IS INITIAL.
    EXIT.
  ENDIF.

  REFRESH: IT_LOT, IT_LOT2.
  CLEAR: IT_LOT, IT_LOT2, V_LOT1, V_LOT2, V_COUNT_PRINT.

  LOOP AT IT_INPT WHERE CHARG IS NOT INITIAL.
    CLEAR: V_MATKL, V_ATWRT, LOTNUMB, LOTVAL.

    "Get Material group inputan
    SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR EQ IT_INPT-PLNBEZ.

    "Check value same or not
    READ TABLE IT_MAPPING WITH KEY VALUE = V_MATKL.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    "Check mapping, fill No Lot 1 on Output
    IF IT_MAPPING-TEXT1 IS NOT INITIAL.
      LOTCHAR_COUNT = IT_MAPPING-TEXT1.
      PERFORM VBGETDET USING IT_INPT-PLNBEZ IT_INPT-CHARG AUFK-WERKS LOTCHAR_COUNT CHANGING V_ATWRT.
      IF V_ATWRT IS NOT INITIAL.
        LOTVAL = V_ATWRT.

        ADD 1 TO V_COUNT_PRINT.

        IT_LOT-CHARG = IT_INPT-CHARG.
        IT_LOT-LOT   = LOTVAL.
        APPEND IT_LOT.
      ENDIF.
    ELSE.
      LOTNUMB = 0.
      DO 9 TIMES.
        "Check no lot inputan
        ADD 1 TO LOTNUMB.
        IF LOTNUMB GT 1.
          LOTCHAR_COUNT = LOTCHAR && LOTNUMB.
        ELSE.
          LOTCHAR_COUNT = LOTCHAR.
        ENDIF.

        "Check Value
        PERFORM VBGETDET USING IT_INPT-PLNBEZ IT_INPT-CHARG AUFK-WERKS LOTCHAR_COUNT CHANGING V_ATWRT.
        IF V_ATWRT IS NOT INITIAL.
          LOTVAL = V_ATWRT.
          IF IT_MAPPING-TEXT2 EQ LOTCHAR_COUNT.
            ADD 1 TO V_COUNT_PRINT.
          ENDIF.

          IT_LOT-CHARG = IT_INPT-CHARG.
          IT_LOT-LOT   = LOTVAL.
          APPEND IT_LOT.
        ENDIF.
      ENDDO.
    ENDIF.

    IF LOTVAL IS INITIAL.
      CLEAR: DMESSAGE.
      CONCATENATE 'No Lot batch input: ' IT_INPT-CHARG 'kosong!' INTO DMESSAGE SEPARATED BY SPACE.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = DMESSAGE.
      DERROR = 1.
    ENDIF.

    CLEAR: V_ATWRT, DMESSAGE.
    PERFORM VBGETDET USING IT_INPT-PLNBEZ IT_INPT-CHARG AUFK-WERKS 'ZZCUSTOMER' CHANGING V_ATWRT.
    IF V_ATWRT IS INITIAL.
      CONCATENATE 'Customer batch input: ' IT_INPT-CHARG 'kosong!' INTO DMESSAGE SEPARATED BY SPACE.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = DMESSAGE.
      DERROR = 1.
    ELSE.
      IF V_ATWRT NE AUFK-ZCUSTM.
        CONCATENATE 'Customer batch input: ' IT_INPT-CHARG 'berbeda dengan customer pada Order!' INTO DMESSAGE SEPARATED BY SPACE.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            TEXTLINE1 = DMESSAGE.
        DERROR = 1.
      ENDIF.
    ENDIF.

    "Check duplicate inputan/join
    IF IT_MAPPING-TEXT4 IS NOT INITIAL.
      IF IT_MAPPING-TEXT4 EQ 'X'.
        IT_MAPPING-TEXT4 = IT_INPT-CHARG.
      ENDIF.
      MODIFY IT_MAPPING TRANSPORTING TEXT4 WHERE VALUE = V_MATKL.
    ENDIF.

    "Check duplicate inputan/join
    IF IT_MAPPING-TEXT4 IS NOT INITIAL.
      IF IT_MAPPING-TEXT4 NE 'X' AND IT_INPT-CHARG NE IT_MAPPING-TEXT4.
        CLEAR: DMESSAGE.
        CONCATENATE 'Batch input' IT_INPT-CHARG 'memiliki matgroup yang sama dengan' IT_MAPPING-TEXT4 '!' INTO DMESSAGE SEPARATED BY SPACE.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            TEXTLINE1 = DMESSAGE.
        DERROR = 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  "Check batch printing more than 1
*  IF V_COUNT_PRINT > 1.
*    CLEAR: DMESSAGE.
*    DMESSAGE = 'Batch input printing lebih dari 1, mohon cek kembali!'.
*    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*      EXPORTING
*        TEXTLINE1 = DMESSAGE.
*    DERROR = 1.
*  ENDIF.

  "Check no lot duplicate
  IT_LOT2[] = IT_LOT[].

  SORT IT_LOT2 BY LOT.
  DELETE ADJACENT DUPLICATES FROM IT_LOT2 COMPARING LOT.

  DESCRIBE TABLE IT_LOT LINES V_LOT1.
  DESCRIBE TABLE IT_LOT2 LINES V_LOT2.

  IF V_LOT1 NE V_LOT2.
    CLEAR: DMESSAGE.
    DMESSAGE = 'Batch input memiliki no lot kembar, mohon cek kembali!'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = DMESSAGE.
    DERROR = 1.
  ENDIF.

  CHECK DERROR NE 1.

*  CLEAR: JANSWR.
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      TITLEBAR              = 'Check condition of derivative?'
*      TEXT_QUESTION         = 'Apakah order ini?'
*      TEXT_BUTTON_1         = 'Normal'
*      TEXT_BUTTON_2         = 'Join'
*      DEFAULT_BUTTON        = '1'
*      DISPLAY_CANCEL_BUTTON = ''
*    IMPORTING
*      ANSWER                = JANSWR.

  DATA V_COUNT_JOIN  TYPE I.
  DATA : V_SUB_COUNT_JOIN TYPE I.
  DATA : BEGIN OF IT_JOINVALIDATE OCCURS 0,
            CHARG LIKE MCH1-CHARG,
            TFILM LIKE CAWNT-ATWTB,
            JOINT TYPE I,
            LENGTH TYPE I,
         END OF IT_JOINVALIDATE.

  DATA : IT_JOINVALIDATE2 LIKE IT_JOINVALIDATE OCCURS 0 WITH HEADER LINE.
  DATA : IT_JOINVALIDATE3 LIKE IT_JOINVALIDATE OCCURS 0 WITH HEADER LINE.

  CLEAR: IT_JOIN, V_MAX_JOIN.
  REFRESH: IT_JOIN.

  LOOP AT IT_FILM.
    CLEAR V_COUNT_JOIN.
    LOOP AT IT_INPT WHERE CHARG IS NOT INITIAL AND TFILM = IT_FILM-TFILM.
      IT_JOIN-CHARG = IT_INPT-CHARG.
      IT_JOIN-TFILM = IT_INPT-TFILM.
      APPEND IT_JOIN.
      ADD 1 TO V_COUNT_JOIN.
    ENDLOOP.
    "Delete if there are no join

    IF V_COUNT_JOIN GT V_MAX_JOIN.
      V_MAX_JOIN = V_COUNT_JOIN.
    ENDIF.

    IF V_COUNT_JOIN LE 1.
      DELETE IT_JOIN WHERE TFILM = IT_FILM-TFILM.
    ENDIF.
  ENDLOOP.

  SORT IT_JOIN BY TFILM.

  "JR Join
*  IF JANSWR EQ 2.
  IF IT_JOIN[] IS NOT INITIAL.
    DATA: V_CONSUMPTION TYPE P.

    PERFORM BUILD_FIELDCAT2.
    PERFORM BUILD_LAYOUT2.

*    LOOP AT IT_FILM.
*      CLEAR V_COUNT_JOIN.
*      LOOP AT IT_INPT WHERE CHARG IS NOT INITIAL AND TFILM = IT_FILM-TFILM.
*        IT_JOIN-CHARG = IT_INPT-CHARG.
*        IT_JOIN-TFILM = IT_INPT-TFILM.
*        APPEND IT_JOIN.
*        ADD 1 TO V_COUNT_JOIN.
*      ENDLOOP.
*      "Delete if there are no join
*      IF V_COUNT_JOIN LE 1.
*        DELETE IT_JOIN WHERE TFILM = IT_FILM-TFILM.
*      ENDIF.
*    ENDLOOP.
*
*    SORT IT_JOIN BY TFILM.

*    LOOP AT IT_JOIN.
*      READ TABLE IT_INPT WITH KEY CHARG = IT_JOIN-CHARG.
*        IF SY-SUBRC EQ 0 .
*
*        ENDIF.
*    ENDLOOP.

    SORT IT_JOIN BY TFILM .
    LOOP AT IT_FILM.
      CLEAR V_COUNT_JOIN.
      LOOP AT IT_JOIN WHERE TFILM = IT_FILM-TFILM.
        ADD 1 TO V_COUNT_JOIN.
      ENDLOOP.

*        SORT IT_INPT BY PLNBEZ OLENGTH DESCENDING.
      CLEAR: V_SUB_COUNT_JOIN.
      LOOP AT IT_INPT WHERE TFILM = IT_FILM-TFILM.
        ADD 1 TO V_SUB_COUNT_JOIN.
        CASE V_COUNT_JOIN.
          WHEN 2.
            LOOP AT IT_JOIN WHERE CHARG = IT_INPT-CHARG.
              IF V_SUB_COUNT_JOIN EQ 1.
                IT_JOIN-JOINT1 = IT_INPT-OLENGTH - IT_INPT-SPJG.
              ENDIF.
              MODIFY IT_JOIN.
            ENDLOOP.
          WHEN 3.
            LOOP AT IT_JOIN WHERE CHARG = IT_INPT-CHARG.
              IF V_SUB_COUNT_JOIN EQ 1.
                IT_JOIN-JOINT1 = IT_INPT-OLENGTH - IT_INPT-SPJG.
              ELSEIF V_SUB_COUNT_JOIN EQ 2.
                IT_JOIN-JOINT2 = IT_INPT-OLENGTH - IT_INPT-SPJG.
              ENDIF.
              MODIFY IT_JOIN.
            ENDLOOP.
          WHEN 4.
            LOOP AT IT_JOIN WHERE CHARG = IT_INPT-CHARG.
              IF V_SUB_COUNT_JOIN EQ 1.
                IT_JOIN-JOINT1 = IT_INPT-OLENGTH - IT_INPT-SPJG.
              ELSEIF V_SUB_COUNT_JOIN EQ 2.
                IT_JOIN-JOINT2 = IT_INPT-OLENGTH - IT_INPT-SPJG.
              ELSEIF V_SUB_COUNT_JOIN EQ 3.
                IT_JOIN-JOINT3 = IT_INPT-OLENGTH - IT_INPT-SPJG.
              ENDIF.
              MODIFY IT_JOIN.
            ENDLOOP.
        ENDCASE.
      ENDLOOP.
*      ENDIF.

    ENDLOOP.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_CALLBACK_PROGRAM       = SY-REPID
        I_GRID_TITLE             = 'Masukkan joint di meter ke-' "#EC NOTEXT
        IS_LAYOUT                = LT_LAYOUT2
        IT_FIELDCAT              = LT_FIELDCATLOG2
        I_SCREEN_START_COLUMN    = 5  "10
        I_SCREEN_START_LINE      = 3  "20
        I_SCREEN_END_COLUMN      = 60 "60 "100
        I_SCREEN_END_LINE        = 15 "30 "40
        I_CALLBACK_USER_COMMAND  = 'USER_COMMAND2'
        I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS2'
      TABLES
        T_OUTTAB                 = IT_JOIN
      EXCEPTIONS
        PROGRAM_ERROR            = 1
        OTHERS                   = 2.


    REFRESH: IT_JOINVALIDATE2.
    CLEAR: IT_JOINVALIDATE2, V_COUNT_PRINT.

    LOOP AT IT_FILM.

      CLEAR V_COUNT_JOIN.
      CLEAR : IT_JOINVALIDATE.
      REFRESH : IT_JOINVALIDATE.

      LOOP AT IT_JOIN WHERE TFILM = IT_FILM-TFILM.
        ADD 1 TO V_COUNT_JOIN.

        IF IT_JOIN-JOINT1 NE ''.
          IT_JOINVALIDATE-TFILM = IT_FILM-TFILM.
          IT_JOINVALIDATE-CHARG = IT_JOIN-CHARG.
          IT_JOINVALIDATE-JOINT = 1.
          IT_JOINVALIDATE-LENGTH = IT_JOIN-JOINT1.
          APPEND IT_JOINVALIDATE.
        ENDIF.
        IF IT_JOIN-JOINT2 NE ''.
          IT_JOINVALIDATE-TFILM = IT_FILM-TFILM.
          IT_JOINVALIDATE-CHARG = IT_JOIN-CHARG.
          IT_JOINVALIDATE-JOINT = 2.
          IT_JOINVALIDATE-LENGTH = IT_JOIN-JOINT2.
          APPEND IT_JOINVALIDATE.
        ENDIF.
        IF IT_JOIN-JOINT3 NE ''.
          IT_JOINVALIDATE-TFILM = IT_FILM-TFILM.
          IT_JOINVALIDATE-CHARG = IT_JOIN-CHARG.
          IT_JOINVALIDATE-JOINT = 3.
          IT_JOINVALIDATE-LENGTH = IT_JOIN-JOINT3.
          APPEND IT_JOINVALIDATE.
        ENDIF.
      ENDLOOP.

      "Validasi Join
      IF V_COUNT_JOIN >= 2.
        CLEAR : IT_JOINVALIDATE.
        READ TABLE IT_JOINVALIDATE WITH KEY JOINT = 1.
        IF SY-SUBRC NE 0.
          CLEAR: DMESSAGE.
          DMESSAGE = 'Silahkan input joint 1 meter keberapa!'.
          CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
            EXPORTING
              TEXTLINE1 = DMESSAGE.
          DERROR = 1.
          EXIT.
        ELSE.
          READ TABLE IT_INPT WITH KEY CHARG = IT_JOINVALIDATE-CHARG.
          "Validate if join more than consumption
          IF SY-SUBRC EQ 0.
            IF IT_INPT-SCRAP EQ 'X'.
              V_CONSUMPTION = IT_INPT-OLENGTH.
            ELSEIF IT_INPT-REUSE EQ 'X'.
              V_CONSUMPTION = IT_INPT-OLENGTH - IT_INPT-SPJG.
            ENDIF.
          ENDIF.
          READ TABLE IT_JOIN WITH KEY CHARG = IT_JOINVALIDATE-CHARG.
          IF SY-SUBRC EQ 0.
            IF IT_JOINVALIDATE-LENGTH GT V_CONSUMPTION.
              CLEAR: DMESSAGE.
              DMESSAGE = 'Input join 1 melebihi panjang konsumsi...!'.
              CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                EXPORTING
                  TEXTLINE1 = DMESSAGE.
              DERROR = 1.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF V_COUNT_JOIN >= 3.
        CLEAR : IT_JOINVALIDATE.
        READ TABLE IT_JOINVALIDATE WITH KEY JOINT = 2.
        IF SY-SUBRC NE 0.
          CLEAR: DMESSAGE.
          DMESSAGE = 'Silahkan input joint 2 meter keberapa!'.
          CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
            EXPORTING
              TEXTLINE1 = DMESSAGE.
          DERROR = 1.
          EXIT.
        ELSE.
          READ TABLE IT_INPT WITH KEY CHARG = IT_JOINVALIDATE-CHARG.
          "Validate if join more than consumption
          IF SY-SUBRC EQ 0.
            IF IT_INPT-SCRAP EQ 'X'.
              V_CONSUMPTION = IT_INPT-OLENGTH.
            ELSEIF IT_INPT-REUSE EQ 'X'.
              V_CONSUMPTION = IT_INPT-OLENGTH - IT_INPT-SPJG.
            ENDIF.
          ENDIF.
          READ TABLE IT_JOIN WITH KEY CHARG = IT_JOINVALIDATE-CHARG.
          IF SY-SUBRC EQ 0.
            IF IT_JOINVALIDATE-LENGTH GT V_CONSUMPTION.
              CLEAR: DMESSAGE.
              DMESSAGE = 'Input join 2 melebihi panjang konsumsi...!'.
              CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                EXPORTING
                  TEXTLINE1 = DMESSAGE.
              DERROR = 1.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF V_COUNT_JOIN >= 4.
        CLEAR : IT_JOINVALIDATE.
        READ TABLE IT_JOINVALIDATE WITH KEY JOINT = 3.
        IF SY-SUBRC NE 0.
          CLEAR: DMESSAGE.
          DMESSAGE = 'Silahkan input joint 3 meter keberapa!'.
          CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
            EXPORTING
              TEXTLINE1 = DMESSAGE.
          DERROR = 1.
          EXIT.
        ELSE.
          READ TABLE IT_INPT WITH KEY CHARG = IT_JOINVALIDATE-CHARG.
          "Validate if join more than consumption
          IF SY-SUBRC EQ 0.
            IF IT_INPT-SCRAP EQ 'X'.
              V_CONSUMPTION = IT_INPT-OLENGTH.
            ELSEIF IT_INPT-REUSE EQ 'X'.
              V_CONSUMPTION = IT_INPT-OLENGTH - IT_INPT-SPJG.
            ENDIF.
          ENDIF.
          READ TABLE IT_JOIN WITH KEY CHARG = IT_JOINVALIDATE-CHARG.
          IF SY-SUBRC EQ 0.
            IF IT_JOINVALIDATE-LENGTH GT V_CONSUMPTION.
              CLEAR: DMESSAGE.
              DMESSAGE = 'Input join 3 melebihi panjang konsumsi...!'.
              CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                EXPORTING
                  TEXTLINE1 = DMESSAGE.
              DERROR = 1.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND LINES OF IT_JOINVALIDATE TO IT_JOINVALIDATE2.
    ENDLOOP.

    V_COUNT_JOIN = 0.
    LOOP AT IT_FILM.
      DO 4 TIMES.
        CLEAR: IT_JOINVALIDATE3, V_COUNT_PRINT.
        REFRESH: IT_JOINVALIDATE3.

        ADD 1 TO V_COUNT_JOIN.

        IT_JOINVALIDATE3[] = IT_JOINVALIDATE2[].

        DELETE IT_JOINVALIDATE3 WHERE JOINT NE V_COUNT_JOIN.
        DELETE IT_JOINVALIDATE3 WHERE TFILM NE IT_FILM-TFILM.

        DESCRIBE TABLE IT_JOINVALIDATE3 LINES V_COUNT_PRINT.

        IF V_COUNT_PRINT GT 1.
          CLEAR: DMESSAGE.
          DMESSAGE = 'Masukkan join di salah satu data...!'.
          CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
            EXPORTING
              TEXTLINE1 = DMESSAGE.
          DERROR = 1.
          EXIT.
        ENDIF.
      ENDDO.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "VLD_CKI

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT2 .
  CLEAR: LT_FIELDCATLOG2.
  REFRESH: LT_FIELDCATLOG2.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '1'.
  LS_FIELDCATLOG2-FIELDNAME = 'PIDX'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Index'.                      "#EC NOTEXT
  LS_FIELDCATLOG2-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '2'.
  LS_FIELDCATLOG2-FIELDNAME = 'CHARG'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Batch'.
  LS_FIELDCATLOG2-NO_OUT    = ''.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '3'.
  LS_FIELDCATLOG2-FIELDNAME = 'TFILM'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Type Film'.
  LS_FIELDCATLOG2-NO_OUT    = ''.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '4'.
  LS_FIELDCATLOG2-FIELDNAME = 'JOINT1'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Joint 1 (M)'.
  IF V_MAX_JOIN EQ 2.
    LS_FIELDCATLOG2-EDIT      = 'X'.
  ENDIF.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '5'.
  LS_FIELDCATLOG2-FIELDNAME = 'JOINT2'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Joint 2 (M)'.
  IF V_MAX_JOIN EQ 3.
    LS_FIELDCATLOG2-EDIT      = 'X'.
  ENDIF.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '6'.
  LS_FIELDCATLOG2-FIELDNAME = 'JOINT3'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Joint 3 (M)'.
  IF V_MAX_JOIN EQ 4.
    LS_FIELDCATLOG2-EDIT      = 'X'.
  ENDIF.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
ENDFORM.                    "BUILD_FIELDCAT2

*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_LAYOUT2 .
  LT_LAYOUT2-ZEBRA = 'X'.
  LT_LAYOUT2-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    "BUILD_LAYOUT2


*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS2 USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDPOPUP2'.
ENDFORM.                    "SET_PF_STATUS2

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND2 USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
  CASE R_UCOMM.
    WHEN '&ONT'.
*      BREAK-POINT.
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
        IMPORTING
          E_GRID = REF_GRID.
      IF REF_GRID IS NOT INITIAL.
        CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).  "After calling this method your internal table will have updated values
      ENDIF.
    WHEN 'CANC_JOIN'.
      V_CANC_JOIN = 'X'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDFORM.                    "USER_COMMAND2