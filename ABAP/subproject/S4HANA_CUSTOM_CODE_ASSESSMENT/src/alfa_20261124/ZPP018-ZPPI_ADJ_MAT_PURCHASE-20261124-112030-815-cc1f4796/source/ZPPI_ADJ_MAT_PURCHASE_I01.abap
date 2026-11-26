*&---------------------------------------------------------------------*
*&  Include           ZPPI_RESLIT_ROLL_I01
*&---------------------------------------------------------------------*
DATA: RB_MAINTAIN(1), RB_CANCEL(1), RB_DISPLAY(1).

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7000 INPUT.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BTNGO'.
      CLEAR: RIBUAN, PULUHAN.
      PERFORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.
      IF RB_MAINTAIN = 'X'.
        D_PILIH = 1.
        CLEAR: SO_PLANT, SO_MBLNR, SO_MJAHR, SO_NIK, SO_POSDT.
        REFRESH: SO_PLANT, SO_MBLNR, SO_MJAHR, SO_NIK, SO_POSDT.
        IF SO_POSDT-LOW IS INITIAL.
          SO_POSDT-LOW = SY-DATUM.
          APPEND SO_POSDT.
        ENDIF.
        CLEAR: MGODIS, RSTDIS, DSCITM.
        CALL SCREEN 7100.
      ELSEIF RB_CANCEL = 'X'.
        D_PILIH = 2.
        UNASSIGN: <FS_DISPLAY>.
        CLEAR: S_PLANT, S_NIK, S_POSDT, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2, IT_DISPLAY.
        REFRESH: S_PLANT, S_NIK, S_POSDT, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2, IT_DISPLAY.
        IF S_POSDT-LOW IS INITIAL.
          S_POSDT-LOW = SY-DATUM.
          APPEND S_POSDT.
        ENDIF.
        CALL SCREEN 7200.
      ELSEIF RB_DISPLAY = 'X'.
        D_PILIH = 3.
        UNASSIGN: <FS_DISPLAY>.
        CLEAR: S_PLANT, S_NIK, S_POSDT, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2, IT_DISPLAY.
        REFRESH: S_PLANT, S_NIK, S_POSDT, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2, IT_DISPLAY.
        IF S_POSDT-LOW IS INITIAL.
          S_POSDT-LOW = SY-DATUM.
          APPEND S_POSDT.
        ENDIF.
        CALL SCREEN 7300.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7000  INPUT

*&---------------------------------------------------------------------*
*&      Module  EX_7100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EX_7100 INPUT.

  CLEAR: IT_MAINTAIN, WA_MAINTAIN.
  REFRESH: IT_MAINTAIN.
  IF SY-UCOMM = 'BACK'.
    LEAVE TO SCREEN 7000.
  ELSE.
    LEAVE PROGRAM.
  ENDIF.

ENDMODULE.                 " EX_7100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7100 INPUT.

  OK_7100 = SY-UCOMM.
  CLEAR: VMESS, NUM, FLAG, IT_LOG, TANGGAL, MGODIS, RSTDIS.", IT_MAINTAIN.
  REFRESH: IT_LOG.", IT_MAINTAIN.
  CASE OK_7100.
    WHEN 'BTN_MGO'.
      IF SO_PLANT[] IS INITIAL.
        MESSAGE 'Plant Harus Diisi' TYPE 'I'.               "#EC NOTEXT
        EXIT.
      ELSEIF SO_MBLNR[] IS INITIAL.
        MESSAGE 'Mat.Doc GR PO Harus Diisi' TYPE 'I'.       "#EC NOTEXT
        EXIT.
      ELSEIF SO_MJAHR[] IS INITIAL.
        MESSAGE 'Mat.Doc Year GR PO Harus Diisi' TYPE 'I'.  "#EC NOTEXT
        EXIT.
      ELSEIF SO_POSDT[] IS INITIAL.
        MESSAGE 'Posting Date Harus Diisi' TYPE 'I'.        "#EC NOTEXT
        EXIT.
      ELSEIF SO_NIK[] IS INITIAL.
        MESSAGE 'NIK Harus Diisi' TYPE 'I'.                 "#EC NOTEXT
        EXIT.
      ENDIF.
      PERFORM VALIDASI_NIK_PLANT.
      IF FLAG = 'X'.
        CLEAR: FLAG.
        EXIT.
      ENDIF.
      CLEAR: OK_7100, SY-UCOMM.
      PERFORM GET_DATA_MAINTAIN. " Get Data
      UNASSIGN <FS_MAINTAIN>.
      READ TABLE IT_MAINTAIN ASSIGNING <FS_MAINTAIN> INDEX 1.
      IF SY-SUBRC NE 0.
        MESSAGE 'No data selected' TYPE 'I'.                "#EC NOTEXT
        CLEAR: SO_PLANT, SO_MBLNR, SO_MJAHR, SO_NIK.
        REFRESH: SO_PLANT, SO_MBLNR, SO_MJAHR, SO_NIK.
        FLAG = 'X'.
        EXIT.
      ELSE.
        MGODIS = 'X'.
      ENDIF.
    WHEN 'POST'.
      MGODIS = 'X'.
      CLEAR: OK_7100, SY-UCOMM.
      UNASSIGN <FS_MAINTAIN>.
      REFRESH: IT_AGSGRN.           "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Refresh IT_AGSGRN
      READ TABLE IT_MAINTAIN ASSIGNING <FS_MAINTAIN> INDEX 1.
      IF SY-SUBRC NE 0.
        MESSAGE 'Tidak ada data yang akan dieksekusi' TYPE 'I'. "#EC NOTEXT
        FLAG = 'X'.
        EXIT.
      ENDIF.
      IF FLAG = 'X'.
        CLEAR: FLAG.
        EXIT.
      ENDIF.
      UNASSIGN <FS_MAINTAIN>.
      READ TABLE IT_MAINTAIN ASSIGNING <FS_MAINTAIN> WITH KEY FLAGS = 'X'.
      IF SY-SUBRC NE 0.
        MESSAGE 'Belum ada line yang dipilih' TYPE 'I'.     "#EC NOTEXT
        FLAG = 'X'.
        EXIT.
      ENDIF.
      IF FLAG = 'X'.
        CLEAR: FLAG.
        EXIT.
      ENDIF.

      CLEAR: TMP_MAINTAIN, TMP_MAINTAIN2.
      REFRESH: TMP_MAINTAIN, TMP_MAINTAIN2.
      UNASSIGN: <FS_TMPMAINTAIN>.
      TMP_MAINTAIN2[] = IT_MAINTAIN[].
      DELETE TMP_MAINTAIN2 WHERE FLAGS = ''.
      SORT TMP_MAINTAIN2 BY MBLNR MJAHR MATNR.
      DELETE ADJACENT DUPLICATES FROM TMP_MAINTAIN2 COMPARING MBLNR MJAHR MATNR.
      TMP_MAINTAIN[] = IT_MAINTAIN[].
      DELETE TMP_MAINTAIN WHERE HDRLVL NE 'X'.
      UNASSIGN <FS_TMPMAINTAIN>.
      LOOP AT TMP_MAINTAIN ASSIGNING <FS_TMPMAINTAIN>.
        UNASSIGN <FS_TMPMAINTAIN2>.
        READ TABLE TMP_MAINTAIN2 ASSIGNING <FS_TMPMAINTAIN2> WITH KEY MBLNR = <FS_TMPMAINTAIN>-MBLNR
                                                                      MJAHR = <FS_TMPMAINTAIN>-MJAHR
                                                                      MATNR = <FS_TMPMAINTAIN>-MATNR.
        IF SY-SUBRC = 0.
          <FS_TMPMAINTAIN>-SELECTED = 'X'.
        ENDIF.
      ENDLOOP.
      DELETE TMP_MAINTAIN WHERE SELECTED NE 'X'.
      UNASSIGN <FS_TMPMAINTAIN>.
      LOOP AT TMP_MAINTAIN ASSIGNING <FS_TMPMAINTAIN>.
        CLEAR: VMESS.
********Cek Material Purchase kosong apa nggak
        IF <FS_TMPMAINTAIN>-MATNR = ''.
          CONCATENATE 'Tidak ada material purchase di' <FS_TMPMAINTAIN>-MBLNR INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          MESSAGE VMESS TYPE 'I'.
          FLAG = 'X'.
          EXIT.
        ENDIF.
********Cek material process order
        IF <FS_TMPMAINTAIN>-MTRPO = ''.
          CONCATENATE 'Isi material purchase order di' <FS_TMPMAINTAIN>-MBLNR 'material' <FS_TMPMAINTAIN>-MATNR INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          MESSAGE VMESS TYPE 'I'.
          FLAG = 'X'.
          EXIT.
        ENDIF.
********Cek production version
        IF <FS_TMPMAINTAIN>-VERID = ''.
          CONCATENATE 'Isi production version di' <FS_TMPMAINTAIN>-MBLNR INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          MESSAGE VMESS TYPE 'I'.
          FLAG = 'X'.
          EXIT.
        ENDIF.
********Cek material sudah di extend di sloc atau belum
        CLEAR: V_MATNR.
        SELECT SINGLE MATNR
          INTO V_MATNR
          FROM MARD
         WHERE MATNR = <FS_MAINTAIN>-MATNR AND WERKS = SO_PLANT-LOW AND
               LGORT = <FS_MAINTAIN>-LGORT.
        IF SY-SUBRC NE 0.
          CLEAR: VMESS.
          CONCATENATE 'Material' <FS_MAINTAIN>-MATNR 'belum di extend di plant' SO_PLANT-LOW 'sloc' <FS_MAINTAIN>-LGORT "#EC NOTEXT
                      INTO VMESS SEPARATED BY SPACE.
          FLAG = 'X'.
          EXIT.
        ENDIF.
********Cek Batch kosong apa nggak
        UNASSIGN <FS_MAINTAIN>.
        READ TABLE IT_MAINTAIN ASSIGNING <FS_MAINTAIN>
                               WITH KEY MBLNR = <FS_TMPMAINTAIN>-MBLNR
                                        MJAHR = <FS_TMPMAINTAIN>-MJAHR
                                        MATNR = <FS_TMPMAINTAIN>-MATNR
                                        CHARG = ''.
        IF SY-SUBRC = 0.
          CLEAR: VMESS.
          CONCATENATE 'Tidak ada batch di' <FS_TMPMAINTAIN>-MBLNR 'material' <FS_TMPMAINTAIN>-MATNR INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          FLAG = 'X'.
          EXIT.
        ENDIF.
********Cek Indicator
        UNASSIGN <FS_MAINTAIN>.
        READ TABLE IT_MAINTAIN ASSIGNING <FS_MAINTAIN>
                               WITH KEY MBLNR = <FS_TMPMAINTAIN>-MBLNR
                                        MJAHR = <FS_TMPMAINTAIN>-MJAHR
                                        MATNR = <FS_TMPMAINTAIN>-MATNR
                                        INDC  = '@5C@'.
        IF SY-SUBRC = 0.
          CLEAR: VMESS.
*          CONCATENATE 'Stock belum cukup untuk eksekusi' <fs_tmpmaintain>-mblnr INTO VMESS SEPARATED BY SPACE.
          MESSAGE 'Stock belum cukup untuk eksekusi' TYPE 'I'. "#EC NOTEXT
          FLAG = 'X'.
          EXIT.
        ENDIF.
********Cek Sloc GI/GR & Jumlahin Berat Teoritis Per mat doc per material purchase
        CLEAR: <FS_TMPMAINTAIN>-CONV.
        UNASSIGN <FS_MAINTAIN>.
        LOOP AT IT_MAINTAIN ASSIGNING <FS_MAINTAIN> WHERE MBLNR = <FS_TMPMAINTAIN>-MBLNR AND
                                                          MJAHR = <FS_TMPMAINTAIN>-MJAHR AND
                                                          MATNR = <FS_TMPMAINTAIN>-MATNR.

          IF <FS_MAINTAIN>-CONV = ''.
            CONCATENATE 'Berat teoritis di batch :' <FS_MAINTAIN>-CHARG 'tidak ditemukan' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
            MESSAGE VMESS TYPE 'I'.
            FLAG = 'X'.
            EXIT.
          ELSE.
            <FS_TMPMAINTAIN>-CONV = <FS_TMPMAINTAIN>-CONV + <FS_MAINTAIN>-CONV.
          ENDIF.

        ENDLOOP.
        IF FLAG = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF FLAG = 'X'.
        CLEAR: FLAG.
        EXIT.
      ENDIF.

*-----Process
      CLEAR: V_AUFART.
      IF SO_PLANT-LOW = '1000'.
        V_AUFART = 'ZAD1'.
      ELSEIF SO_PLANT-LOW = '2000'.
        V_AUFART = 'ZAD2'.
      ELSEIF SO_PLANT-LOW = 'TTA2'. " ADD NEW COMPANY
        V_AUFART = 'ZAD2'.
      ELSEIF SO_PLANT-LOW = 'TTE'. " ADD NEW COMPANY
        V_AUFART = 'ZAD2'.
      ENDIF.
      CLEAR: IT_LOG, R_BATCH.
      REFRESH: IT_LOG, R_BATCH.
      UNASSIGN <FS_TMPMAINTAIN>.
      LOOP AT TMP_MAINTAIN ASSIGNING <FS_TMPMAINTAIN>.
        CLEAR: FLAG, TANGGAL, C_QUANT, PROC_ORD, MBLNR_GI, MJAHR_GI,
               V_SGTXT, BATCH_GR, IT_LOG, L_MSTRING.
        CONCATENATE SY-DATUM+6(2) '.' SY-DATUM+4(2) '.' SY-DATUM+0(4) INTO TANGGAL.
        CONDENSE <FS_TMPMAINTAIN>-CONV NO-GAPS.
        C_QUANT = <FS_TMPMAINTAIN>-CONV.
        IT_LOG-NOMOR = <FS_TMPMAINTAIN>-NOMOR.
        IT_LOG-MBLNR = <FS_TMPMAINTAIN>-MBLNR.
        IT_LOG-MJAHR = <FS_TMPMAINTAIN>-MJAHR.
        IT_LOG-MATNR = <FS_TMPMAINTAIN>-MATNR.
        IT_LOG-CHARG = <FS_TMPMAINTAIN>-CHARG.
********Create Process Order
        PERFORM CREATE_PROCESS_ORDER USING <FS_TMPMAINTAIN>-MTRPO
                                           SO_PLANT-LOW
                                           V_AUFART
                                           <FS_TMPMAINTAIN>-VERID
                                           C_QUANT
                                           TANGGAL
                                  CHANGING FLAG
                                           PROC_ORD.
        IF FLAG = ''.
**********Goods Issue Batch Inputan
          PERFORM GI USING <FS_TMPMAINTAIN>-MBLNR
                           <FS_TMPMAINTAIN>-MJAHR
                           <FS_TMPMAINTAIN>-MATNR
                           <FS_TMPMAINTAIN>-VERID
                           SO_POSDT-LOW
                           SO_NIK-LOW
                           TANGGAL
                           SO_PLANT-LOW
                           PROC_ORD
                  CHANGING FLAG.
**********Kalau GI gagal, langsung TECO Order
          IF FLAG = 'X'.
            CLEAR: VMESS.
            IT_LOG-CRBTCH = '@0A@ - Failed'.                "#EC NOTEXT
            IT_LOG-SETCHR = '@0A@ - Failed'.                "#EC NOTEXT
            IT_LOG-GRBTCH = '@0A@ - Failed'.                "#EC NOTEXT
            APPEND IT_LOG.
          ELSE.
            UNASSIGN <FS_MAINTAIN>.
            LOOP AT IT_MAINTAIN ASSIGNING <FS_MAINTAIN> WHERE MBLNR = <FS_TMPMAINTAIN>-MBLNR AND
                                                              MJAHR = <FS_TMPMAINTAIN>-MJAHR AND
                                                              MATNR = <FS_TMPMAINTAIN>-MATNR.
              IT_LOG-CHARG = <FS_MAINTAIN>-CHARG.
              IF FLAG EQ ''.
****************Create Batch Untuk di GR
                PERFORM CREATE_BATCH USING <FS_TMPMAINTAIN>-MTRPO
                                           SO_PLANT-LOW
                                  CHANGING FLAG
                                           BATCH_GR.
                <FS_MAINTAIN>-BTCHGR = BATCH_GR.
              ENDIF.
              IF FLAG EQ ''.
****************Set Characteristic Batch Baru
                PERFORM SET_CHAR_BATCH_BR USING <FS_MAINTAIN>-MATNR
                                                <FS_MAINTAIN>-CHARG
                                                SO_PLANT-LOW
                                                <FS_TMPMAINTAIN>-MTRPO
                                                BATCH_GR
                                       CHANGING FLAG.
              ENDIF.
            ENDLOOP.
            IF FLAG EQ ''.
**************GR Batch yang baru terbentuk
              PERFORM GR_BATCH_BR USING <FS_TMPMAINTAIN>-MBLNR
                                        <FS_TMPMAINTAIN>-MJAHR
                                        <FS_TMPMAINTAIN>-MATNR
                                        <FS_TMPMAINTAIN>-MTRPO
                                        <FS_TMPMAINTAIN>-VERID
                                        SO_POSDT-LOW
                                        SO_NIK-LOW
                                        SO_PLANT-LOW
                                        PROC_ORD
                               CHANGING FLAG.
            ENDIF.
************Kalau GR gagal, cancel GI doc
            IF CANC = 'X'.
              CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
              REFRESH: RETURN.
              MATERIALDOCUMENT = MBLNR_GI.
              MATDOCUMENTYEAR  = MJAHR_GI.
              PERFORM CANCEL_GOODSMVT USING MBLNR_GI MJAHR_GI CHANGING FLAG GOODSMVT_HEADRET.
              LS_SUBRC = 0.
              CLEAR: VMESS, FLAG.
              LOOP AT RETURN WHERE TYPE = 'E'.
                LS_SUBRC = 1.
                FLAG = 'X'.
              ENDLOOP.
              CLEAR: SY-SUBRC.
              IF LS_SUBRC = 0.
                PERFORM BAPI_COMMIT.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          IT_LOG-GIBTCH = '@0A@ - Failed'.                  "#EC NOTEXT
          IT_LOG-CRBTCH = '@0A@ - Failed'.                  "#EC NOTEXT
          IT_LOG-SETCHR = '@0A@ - Failed'.                  "#EC NOTEXT
          IT_LOG-GRBTCH = '@0A@ - Failed'.                  "#EC NOTEXT
          APPEND IT_LOG.
        ENDIF.
********TECO Order
        PERFORM TECO_ORDER USING <FS_TMPMAINTAIN>-MBLNR
                                 <FS_TMPMAINTAIN>-MJAHR
                                 <FS_TMPMAINTAIN>-MATNR
                                 PROC_ORD
                        CHANGING FLAG.
********End Kalau GI gagal, langsung TECO Order

        "-- ADDED FOR AGS BY FATHIR 20.11.2019 - Get data for AGS download
        IF SO_PLANT-LOW EQ 'TTE'.
          CLEAR: IT_AGSGRN.
          IT_AGSGRN-CHARG = BATCH_GR.
          IT_AGSGRN-AUFNR = PROC_ORD.
          IT_AGSGRN-MBLNR = MTHEAD_GI+0(10).
          APPEND IT_AGSGRN.

          CLEAR: IT_AGSGRN.
          IT_AGSGRN-CHARG = BATCH_GR.
          IT_AGSGRN-AUFNR = PROC_ORD.
          IT_AGSGRN-MBLNR = MTHEAD_GR+0(10).
          APPEND IT_AGSGRN.
        ENDIF.
        "-- ADDED FOR AGS BY FATHIR 20.11.2019 - Get data for AGS download

      ENDLOOP.
******Print Batch GR
      SUBMIT ZMMR_LABELROL WITH  P_CHARG IN R_BATCH AND RETURN.
      CLEAR: R_BATCH.
      REFRESH: R_BATCH.
******Download data to AGS
      IF SO_PLANT-LOW EQ 'TTE'.
        PERFORM F_INSERTAGS_SQL TABLES IT_AGSGRN.     "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Perform download to AGS
      ENDIF.
******Display Report Log
      PERFORM F_BUILD_SORTCAT.
      PERFORM BUILD_FIELDCAT.
      PERFORM BUILD_LAYOUT.
      PERFORM ALV.
      CLEAR: IT_MAINTAIN, SO_PLANT, SO_MBLNR, SO_MJAHR, SO_POSDT, SO_NIK.
      REFRESH: IT_MAINTAIN, SO_PLANT, SO_MBLNR, SO_MJAHR, SO_POSDT, SO_NIK.
      SO_POSDT-LOW = SY-DATUM.
      APPEND SO_POSDT.
      MGODIS = ''.
      LEAVE TO SCREEN 7100.
    WHEN 'BTN_RST'.
      CLEAR: OK_7100, SY-UCOMM.
      CLEAR: IT_MAINTAIN, SO_PLANT, SO_MBLNR, SO_MJAHR, SO_POSDT, SO_NIK, FLAGMJAHR.
      REFRESH: IT_MAINTAIN, SO_PLANT, SO_MBLNR, SO_MJAHR, SO_POSDT, SO_NIK.
      SO_POSDT-LOW = SY-DATUM.
      APPEND SO_POSDT.
      LEAVE TO SCREEN 7100.
      RSTDIS = 'X'.
    WHEN OTHERS.
      CLEAR: OK_7100, SY-UCOMM.
      IF SO_PLANT[] IS INITIAL.
        MESSAGE 'Plant Harus Diisi' TYPE 'I'.               "#EC NOTEXT
        EXIT.
      ELSEIF SO_MBLNR[] IS INITIAL.
        MESSAGE 'Mat.Doc GR PO Harus Diisi' TYPE 'I'.       "#EC NOTEXT
        EXIT.
      ELSEIF SO_MJAHR[] IS INITIAL.
        MESSAGE 'Mat.Doc Year GR PO Harus Diisi' TYPE 'I'.  "#EC NOTEXT
        EXIT.
      ELSEIF SO_POSDT[] IS INITIAL.
        MESSAGE 'Posting Date Harus Diisi' TYPE 'I'.        "#EC NOTEXT
        EXIT.
      ELSEIF SO_NIK[] IS INITIAL.
        MESSAGE 'NIK Harus Diisi' TYPE 'I'.                 "#EC NOTEXT
        EXIT.
      ENDIF.
      PERFORM VALIDASI_NIK_PLANT.
      UNASSIGN: <FS_MAINTAIN>.
      READ TABLE IT_MAINTAIN ASSIGNING <FS_MAINTAIN> INDEX 1.
      IF SY-SUBRC = 0.
        MGODIS = 'X'.
      ELSE.
        MGODIS = ''.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EX_7300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EX_7300 INPUT.

  IF SY-UCOMM = 'BACK'.
    LEAVE TO SCREEN 7000.
  ELSE.
    LEAVE PROGRAM.
  ENDIF.

ENDMODULE.                 " EX_7300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7300 INPUT.

  OK_7300 = SY-UCOMM.

  UNASSIGN <FS_DISPLAY>.
  CLEAR: IT_DISPLAY, FLAG.
  REFRESH: IT_DISPLAY.

  CASE OK_7300.
    WHEN 'BTN_DGO'.
      IF S_PLANT[] IS INITIAL.
        MESSAGE 'Plant Harus Diisi' TYPE 'I'.               "#EC NOTEXT
        EXIT.
      ELSEIF S_POSDT[] IS INITIAL.
        MESSAGE 'Posting Date Harus Diisi' TYPE 'I'.        "#EC NOTEXT
        EXIT.
      ENDIF.
      CLEAR: OK_7300, SY-UCOMM.
      PERFORM VALIDASI_NIK_PLANT.
      IF FLAG = 'X'.
        CLEAR: FLAG.
        EXIT.
      ENDIF.
      PERFORM GET_DATA_DISPLAY.
      UNASSIGN <FS_DISPLAY>.
      READ TABLE IT_DISPLAY ASSIGNING <FS_DISPLAY> INDEX 1.
      IF SY-SUBRC NE 0.
        CLEAR: S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
        REFRESH: S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
        S_POSDT-LOW = SY-DATUM.
        APPEND S_POSDT.
        MESSAGE 'No data selected' TYPE 'I'.                "#EC NOTEXT
        FLAG = 'X'.
        EXIT.
      ENDIF.
      SORT IT_DISPLAY BY MBLNR EBELN MATNR AUFNR BWART MBLNR2 MATNR2.
******Display Report Log
*      PERFORM F_BUILD_SORTCAT2.
      PERFORM BUILD_FIELDCAT_DISPLAY.
      PERFORM BUILD_LAYOUT.
      PERFORM ALV_DISPLAY.
      CLEAR: IT_DISPLAY, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
      REFRESH: IT_DISPLAY, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
      S_POSDT-LOW = SY-DATUM.
      APPEND S_POSDT.
      LEAVE TO SCREEN 7300.
    WHEN OTHERS.
      PERFORM VALIDASI_NIK_PLANT.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7300  INPUT
*&---------------------------------------------------------------------*
*&      Module  EX_7200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EX_7200 INPUT.

  IF SY-UCOMM = 'BACK'.
    LEAVE TO SCREEN 7000.
  ELSE.
    LEAVE PROGRAM.
  ENDIF.

ENDMODULE.                 " EX_7200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7200 INPUT.

  OK_7200 = SY-UCOMM.

  UNASSIGN <FS_DISPLAY>.
  CLEAR: IT_DISPLAY, FLAG.
  REFRESH: IT_DISPLAY.
  CASE OK_7200.
    WHEN 'BTN_CGO'.
      IF S_PLANT[] IS INITIAL.
        MESSAGE 'Plant Harus Diisi' TYPE 'I'.               "#EC NOTEXT
        EXIT.
      ELSEIF S_POSDT[] IS INITIAL.
        MESSAGE 'Posting Date Harus Diisi' TYPE 'I'.        "#EC NOTEXT
        EXIT.
      ELSEIF S_NIK[] IS INITIAL.
        MESSAGE 'NIK Harus Diisi' TYPE 'I'.                 "#EC NOTEXT
        EXIT.
      ENDIF.
      PERFORM VALIDASI_NIK_PLANT.
      IF FLAG = 'X'.
        CLEAR: FLAG.
        EXIT.
      ENDIF.
      CLEAR: OK_7200, SY-UCOMM.
      PERFORM GET_DATA_DISPLAY.
******Ambil yang belum di cancel saja
      DELETE IT_DISPLAY WHERE INDC = '@5C@'.
******End Ambil yang belum di cancel saja
*      SORT IT_DISPLAY BY AUFNR BWART.
      SORT IT_DISPLAY BY MBLNR EBELN MATNR AUFNR BWART MBLNR2 MATNR2.
      UNASSIGN <FS_DISPLAY>.
      READ TABLE IT_DISPLAY ASSIGNING <FS_DISPLAY> INDEX 1.
      IF SY-SUBRC NE 0.
        CLEAR: S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
        REFRESH: S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
        S_POSDT-LOW = SY-DATUM.
        APPEND S_POSDT.
        MESSAGE 'No data selected' TYPE 'I'.                "#EC NOTEXT
        FLAG = 'X'.
        EXIT.
      ENDIF.
      CALL SCREEN 7220.
******Display Report Log
*      PERFORM BUILD_FIELDCAT_DISPLAY.
*      PERFORM BUILD_LAYOUT.
*      PERFORM ALV_DISPLAY.
*      CLEAR: IT_DISPLAY, S_PLANT, S_BATCH, s_posdt, s_nik, s_mblnr, s_mjahr.
*      REFRESH: IT_DISPLAY, S_PLANT, S_BATCH, s_posdt, s_nik, s_mblnr, s_mjahr.
*      S_POSDT-LOW = SY-DATUM.
*      APPEND S_POSDT.
*      LEAVE TO SCREEN 7200.
    WHEN OTHERS.
      PERFORM VALIDASI_NIK_PLANT.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7200  INPUT

*&---------------------------------------------------------------------*
*&      Module  EX_7220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EX_7220 INPUT.

  CLEAR: IT_DISPLAY, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
  REFRESH: IT_DISPLAY, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
  S_POSDT-LOW = SY-DATUM.
  APPEND S_POSDT.
  IF SY-UCOMM = 'BACK'.
    LEAVE TO SCREEN 7200.
  ELSEIF SY-UCOMM = 'CANCEL'.
    LEAVE TO SCREEN 7000.
  ELSE.
    LEAVE PROGRAM.
  ENDIF.

ENDMODULE.                 " EX_7220  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7220 INPUT.

  UNASSIGN <FS_CANCEL>.
  CLEAR: IT_CANCEL, CANCT.
  REFRESH: IT_CANCEL.

  OK_7220 = SY-UCOMM.

  IT_CANCEL[] = IT_DISPLAY[].
  DELETE IT_CANCEL WHERE FLAGS = ''.
  SORT IT_CANCEL BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM IT_CANCEL COMPARING AUFNR.
  READ TABLE IT_CANCEL ASSIGNING <FS_CANCEL> INDEX 1.
  IF SY-SUBRC NE 0.
    IF OK_7220 = 'CANCT' OR OK_7220 = 'CANC'.
      MESSAGE 'No data selected' TYPE 'I'.                  "#EC NOTEXT
      FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  CASE OK_7220.
    WHEN 'CANCT'.
      CLEAR: IT_TEST.
      REFRESH: IT_TEST.
      UNASSIGN <FS_CANCEL>.
      LOOP AT IT_CANCEL ASSIGNING <FS_CANCEL> WHERE FLAGS = 'X'.
        UNASSIGN <FS_DISPLAY>.

        LOOP AT IT_DISPLAY ASSIGNING <FS_DISPLAY> WHERE AUFNR = <FS_CANCEL>-AUFNR AND BWART = '101'.
          CLEAR: IT_TEST.
          IT_TEST-MBLNR  = <FS_DISPLAY>-MBLNR.
          IT_TEST-EBELN  = <FS_DISPLAY>-EBELN.
          IT_TEST-MATNR  = <FS_DISPLAY>-MATNR.
          IT_TEST-AUFNR  = <FS_DISPLAY>-AUFNR.
          IT_TEST-BWART  = ''.
          IT_TEST-MBLNR2 = <FS_DISPLAY>-MBLNR2.
          IT_TEST-MATNR2 = <FS_DISPLAY>-MATNR2.
          IT_TEST-MENGE  = <FS_DISPLAY>-MENGE.
          IT_TEST-CHARG  = <FS_DISPLAY>-CHARG.
          CLEAR: VCLABS.
          SELECT SINGLE CLABS
            INTO VCLABS
            FROM MCHB
           WHERE CHARG = <FS_DISPLAY>-CHARG AND MATNR = <FS_DISPLAY>-MATNR2.
          IF SY-SUBRC = 0.
            IF VCLABS >= <FS_DISPLAY>-MENGE.
              IT_TEST-CANCGR = '@08@'.
              IT_TEST-CANCGI = '@08@'.
              APPEND IT_TEST.
            ELSE.
              IT_TEST-CANCGR = '@0A@ - Stok tidak cukup'.   "#EC NOTEXT
              IT_TEST-CANCGI = '@0A@'.
              APPEND IT_TEST.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
******Display Report Cancellation Test
      CANCT = 'X'.
      PERFORM BUILD_FIELDCAT_TEST.
      PERFORM BUILD_LAYOUT.
      I_GRID_TITLE = 'Cancellation Test Log'.               "#EC NOTEXT
      PERFORM ALV_TEST.
      CLEAR: IT_TEST, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
      REFRESH: IT_TEST, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
      S_POSDT-LOW = SY-DATUM.
      APPEND S_POSDT.
      LEAVE TO SCREEN 7220.
    WHEN 'CANC'.
      CLEAR: IT_TEST, CANCT.
      REFRESH: IT_TEST,
               IT_AGSGRN.                   "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Refresh IT_AGSGRN
      UNASSIGN <FS_CANCEL>.
      LOOP AT IT_CANCEL ASSIGNING <FS_CANCEL> WHERE FLAGS = 'X'.
        CLEAR: VKALAB, VCLABS, IT_TEST, FLAG.
        UNASSIGN <FS_DISPLAY>.
        IT_TEST-MBLNR  = <FS_CANCEL>-MBLNR.
        IT_TEST-EBELN  = <FS_CANCEL>-EBELN.
        IT_TEST-MATNR  = <FS_CANCEL>-MATNR.
        IT_TEST-AUFNR  = <FS_CANCEL>-AUFNR.
        READ TABLE IT_DISPLAY ASSIGNING <FS_DISPLAY> WITH KEY AUFNR = <FS_CANCEL>-AUFNR BWART = '101' BINARY SEARCH.
        IF SY-SUBRC = 0.
          IT_TEST-BWART  = '102'.
          IT_TEST-MBLNR2 = <FS_DISPLAY>-MBLNR2.
          IT_TEST-MATNR2 = <FS_DISPLAY>-MATNR2.
          CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
          REFRESH: RETURN.
          MATERIALDOCUMENT = <FS_DISPLAY>-MBLNR2.
          MATDOCUMENTYEAR  = <FS_DISPLAY>-MJAHR2.
          PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.
          LS_SUBRC = 0.
          CLEAR: VMESS, FLAG.
          LOOP AT RETURN WHERE TYPE = 'E'.
            CLEAR: VMESS.
            CONCATENATE '@0A@ - Failed :' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
            LS_SUBRC = 1.
            FLAG = 'X'.
            IT_TEST-CANCGR = VMESS.
            IT_TEST-CANCGI = '@0A@ - Failed'.               "#EC NOTEXT
            APPEND IT_TEST.
          ENDLOOP.
          CLEAR: SY-SUBRC.
          IF LS_SUBRC = 0.
            PERFORM BAPI_COMMIT.
            CLEAR: VMESS.
            CONCATENATE '@08@ - No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
            IT_TEST-CANCGR = VMESS.
            APPEND IT_TEST.

            "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Get GR data for AGS download (While Cancel)
            IF S_PLANT-LOW EQ 'TTE'.
              CLEAR: IT_AGSGRN.
              IT_AGSGRN-MBLNR = GOODSMVT_HEADRET+0(10).
              IT_AGSGRN-CHARG = <FS_DISPLAY>-CHARG.
              IT_AGSGRN-AUFNR = <FS_DISPLAY>-AUFNR.
              APPEND IT_AGSGRN.
            ENDIF.
            "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Get GR data for AGS download (While Cancel)

          ENDIF.
        ENDIF.

        CHECK FLAG = ''.

        READ TABLE IT_DISPLAY ASSIGNING <FS_DISPLAY> WITH KEY AUFNR = <FS_CANCEL>-AUFNR BWART = '261' BINARY SEARCH.
        IF SY-SUBRC = 0.
          CLEAR: IT_TEST-CANCGR.
          IT_TEST-BWART  = '262'.
          IT_TEST-MBLNR2 = <FS_DISPLAY>-MBLNR2.
          IT_TEST-MATNR2 = <FS_DISPLAY>-MATNR2.
          CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
          REFRESH: RETURN.
          MATERIALDOCUMENT = <FS_DISPLAY>-MBLNR2.
          MATDOCUMENTYEAR  = <FS_DISPLAY>-MJAHR2.
          PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.
          LS_SUBRC = 0.
          CLEAR: VMESS, FLAG.
          LOOP AT RETURN WHERE TYPE = 'E'.
            CLEAR: VMESS.
            CONCATENATE '@0A@ - Failed :' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
            LS_SUBRC = 1.
            FLAG = 'X'.
            IT_TEST-CANCGI = VMESS.
            APPEND IT_TEST.
          ENDLOOP.
          CLEAR: SY-SUBRC.
          IF LS_SUBRC = 0.
            PERFORM BAPI_COMMIT.
            CLEAR: VMESS.
            CONCATENATE '@08@ - No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
            IT_TEST-CANCGI = VMESS.
            APPEND IT_TEST.

            "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Get GI data for AGS download (While Cancel)
            IF S_PLANT-LOW EQ 'TTE'.
              CLEAR: IT_AGSGRN.
              IT_AGSGRN-MBLNR = GOODSMVT_HEADRET+0(10).
              IT_AGSGRN-CHARG = <FS_DISPLAY>-CHARG.
              IT_AGSGRN-AUFNR = <FS_DISPLAY>-AUFNR.
              APPEND IT_AGSGRN.
            ENDIF.
            "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Get GI data for AGS download (While Cancel)

          ENDIF.
        ENDIF.
      ENDLOOP.
******Download data to AGS
      IF S_PLANT-LOW EQ 'TTE'.
        PERFORM F_INSERTAGS_SQL TABLES IT_AGSGRN.     "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Perform download to AGS
      ENDIF.
******Display Report Cancellation Test
      CANCT = ''.
      PERFORM BUILD_FIELDCAT_TEST.
      PERFORM BUILD_LAYOUT.
      I_GRID_TITLE = 'Cancellation Log'.                    "#EC NOTEXT
      PERFORM ALV_TEST.
      CLEAR: IT_CANCEL, IT_TEST, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
      REFRESH: IT_CANCEL, IT_TEST, S_PLANT, S_POSDT, S_NIK, S_MBLNR, S_MJAHR, S_MBLNR2, S_MJAHR2.
      S_POSDT-LOW = SY-DATUM.
      APPEND S_POSDT.
      LEAVE TO SCREEN 7200.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7220  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_MAINTAIN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_MAINTAIN_MODIFY INPUT.
  MODIFY IT_MAINTAIN
    FROM WA_MAINTAIN
    INDEX TC_MAINTAIN-CURRENT_LINE.
ENDMODULE.                    "TC_MAINTAIN_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_MAINTAIN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_MAINTAIN_MARK INPUT.
  DATA: G_TC_MAINTAIN_WA2 LIKE LINE OF IT_MAINTAIN.
  IF TC_MAINTAIN-LINE_SEL_MODE = 1
  AND WA_MAINTAIN-FLAGS = 'X'.
    LOOP AT IT_MAINTAIN INTO G_TC_MAINTAIN_WA2
      WHERE FLAGS = 'X'.
      G_TC_MAINTAIN_WA2-FLAGS = ''.
      MODIFY IT_MAINTAIN
        FROM G_TC_MAINTAIN_WA2
        TRANSPORTING FLAGS.
    ENDLOOP.
  ENDIF.
  MODIFY IT_MAINTAIN
    FROM WA_MAINTAIN
    INDEX TC_MAINTAIN-CURRENT_LINE
    TRANSPORTING FLAGS.
ENDMODULE.                    "TC_MAINTAIN_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_MAINTAIN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_MAINTAIN_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_MAINTAIN'
                              'IT_MAINTAIN'
                              'FLAGS'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TC_MAINTAIN_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_HELP_MTRPO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_HELP_MTRPO INPUT.

  DATA: BEGIN OF IT_MATNR OCCURS 0,
          MATNR LIKE MARA-MATNR,
          MAKTX LIKE MAKT-MAKTX,
        END OF IT_MATNR.

  CLEAR: IT_MATNR.
  REFRESH: IT_MATNR.

  SELECT MARA~MATNR MAKT~MAKTX
    INTO TABLE IT_MATNR
    FROM MARA
    JOIN MAKT ON MARA~MATNR = MAKT~MATNR
   WHERE ( MATKL BETWEEN '300001' AND '300014' ) OR ( MATKL BETWEEN '300016' AND '300019' ). " Added by William at 24.07.2022 (OPP7 CPP1)

  IF SY-SUBRC = 0.
    SORT IT_MATNR.
    DELETE IT_MATNR WHERE MATNR = ''.
    DELETE ADJACENT DUPLICATES FROM IT_MATNR COMPARING MATNR.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD    = 'MATNR'
        DYNPPROG    = SY-REPID
        DYNPNR      = SY-DYNNR
        DYNPROFIELD = 'WA_MAINTAIN-MTRPO'
        VALUE_ORG   = 'S'
      TABLES
        VALUE_TAB   = IT_MATNR.
  ENDIF.

ENDMODULE.                 " F4_HELP_MTRPO  INPUT
*&---------------------------------------------------------------------*
*&      Module  CEK_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CEK_MATNR INPUT.

  CLEAR: V_MATNR.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = WA_MAINTAIN-MTRPO
    IMPORTING
      OUTPUT       = WA_MAINTAIN-MTRPO
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  IF WA_MAINTAIN-MTRPO NE ''.
    SELECT SINGLE MATNR
      INTO V_MATNR
      FROM MARA
     WHERE MATNR = WA_MAINTAIN-MTRPO.
    IF SY-SUBRC = 0.
      CLEAR: V_MATNR.
      SELECT SINGLE MATNR
        INTO V_MATNR
        FROM MARA
       WHERE MATNR = WA_MAINTAIN-MTRPO AND
             ( ( MATKL BETWEEN '300001' AND '300014' ) OR ( MATKL BETWEEN '300016' AND '300019' ) ).  " Added by William at 28.07.2022 (OPP7 CPP1)
      IF SY-SUBRC NE 0.
        MESSAGE 'Material number bukan material slitting' TYPE 'I'. "#EC NOTEXT
        CLEAR: WA_MAINTAIN-MTRPO, SY-UCOMM.
        EXIT.
      ENDIF.
    ELSE.
      MESSAGE 'Material number salah' TYPE 'I'.             "#EC NOTEXT
      CLEAR: WA_MAINTAIN-MTRPO, SY-UCOMM.
      EXIT.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = WA_MAINTAIN-MTRPO
    IMPORTING
      OUTPUT = WA_MAINTAIN-MTRPO.

ENDMODULE.                 " CEK_MATNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  CEK_VERID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CEK_VERID INPUT.

  CLEAR: V_STLAL, T_STPO, MATERIAL, PLANT, BOM_USAGE, ALTERNATIVE.
  REFRESH: T_STPO.
  IF WA_MAINTAIN-VERID NE ''.
    IF WA_MAINTAIN-MTRPO = ''.
      MESSAGE 'Harap isi Material PO' TYPE 'I'.             "#EC NOTEXT
      CLEAR: WA_MAINTAIN-VERID, SY-UCOMM.
      EXIT.
    ENDIF.
    SELECT SINGLE STLAL
      INTO V_STLAL
      FROM MKAL
     WHERE MATNR = WA_MAINTAIN-MTRPO AND WERKS = SO_PLANT-LOW AND
           VERID = WA_MAINTAIN-VERID.
    IF SY-SUBRC = 0.
      IF WA_MAINTAIN-MATNR = ''.
        MESSAGE 'Material Number kosong!!' TYPE 'I'.        "#EC NOTEXT
        CLEAR: SY-UCOMM.
        EXIT.
      ELSE.
*        MATERIAL    = WA_MAINTAIN-MATNR.
        MATERIAL    = WA_MAINTAIN-MTRPO.
        PLANT       = SO_PLANT-LOW.
        BOM_USAGE   = 1.
        ALTERNATIVE = V_STLAL.
        CALL FUNCTION 'CSAP_MAT_BOM_READ'
          EXPORTING
            MATERIAL             = MATERIAL
            PLANT                = PLANT
            BOM_USAGE            = BOM_USAGE
            ALTERNATIVE          = ALTERNATIVE
*         IMPORTING
*           FL_WARNING           =
          TABLES
            T_STPO               = T_STPO
          EXCEPTIONS
            ERROR                = 1
            OTHERS               = 2
                  .
        IF SY-SUBRC <> 0.
          CLEAR: VMESS.
          CONCATENATE 'Material purchase' WA_MAINTAIN-MATNR 'tidak ada di BOM' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
*          MESSAGE 'Material purchase tidak ada di BOM' TYPE 'I'.
          MESSAGE VMESS TYPE 'I'.
          CLEAR: WA_MAINTAIN-VERID, SY-UCOMM.
          EXIT.
        ELSE.
          UNASSIGN <FS_STPO>.
          READ TABLE T_STPO ASSIGNING <FS_STPO> WITH KEY COMPONENT = WA_MAINTAIN-MATNR.
          IF SY-SUBRC NE 0.
            CLEAR: VMESS.
            CONCATENATE 'Material purchase' WA_MAINTAIN-MATNR 'tidak ada di BOM' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
*            MESSAGE 'Material purchase tidak ada di BOM' TYPE 'I'.
            MESSAGE VMESS TYPE 'I'.
            CLEAR: WA_MAINTAIN-VERID, SY-UCOMM.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE 'Material dengan production version tidak sesuai' TYPE 'I'. "#EC NOTEXT
      CLEAR: WA_MAINTAIN-MTRPO, WA_MAINTAIN-VERID, SY-UCOMM.
      EXIT.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CEK_VERID  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_CANCEL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_CANCEL_MARK INPUT.
  DATA: G_TC_CANCEL_WA2 LIKE LINE OF IT_DISPLAY.
  IF TC_CANCEL-LINE_SEL_MODE = 1
  AND IT_DISPLAY-FLAGS = 'X'.
    LOOP AT IT_DISPLAY INTO G_TC_CANCEL_WA2
      WHERE FLAGS = 'X'.
      G_TC_CANCEL_WA2-FLAGS = ''.
      MODIFY IT_DISPLAY
        FROM G_TC_CANCEL_WA2
        TRANSPORTING FLAGS.
    ENDLOOP.
  ENDIF.
  MODIFY IT_DISPLAY
    INDEX TC_CANCEL-CURRENT_LINE
    TRANSPORTING FLAGS.
ENDMODULE.                    "TC_CANCEL_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_CANCEL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_CANCEL_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_CANCEL'
                              'IT_DISPLAY'
                              'FLAGS'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TC_CANCEL_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_HELP_VERID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_HELP_VERID INPUT.

  CLEAR: V_STLAL, T_STPO, MATERIAL, PLANT, BOM_USAGE, ALTERNATIVE,
         V_DYNINDEX, WA_DYNPREAD, T_DYNPREAD.
  REFRESH: T_STPO, T_DYNPREAD.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL = V_DYNINDEX.   "(v_dynindex  is a  variable  to  hold  the  index  value)

  WA_DYNPREAD-STEPL = V_DYNINDEX.
  WA_DYNPREAD-FIELDNAME = 'WA_MAINTAIN-MTRPO'.
  APPEND WA_DYNPREAD TO T_DYNPREAD.
  WA_DYNPREAD-STEPL = V_DYNINDEX.
  WA_DYNPREAD-FIELDNAME = 'WA_MAINTAIN-MATNR'.
  APPEND WA_DYNPREAD TO T_DYNPREAD.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME             = SY-REPID
      DYNUMB             = SY-DYNNR
      TRANSLATE_TO_UPPER = 'X'
    TABLES
      DYNPFIELDS         = T_DYNPREAD.

  CLEAR: WA_DYNPREAD, IT_VERID.
  REFRESH: IT_VERID.
  READ TABLE T_DYNPREAD INTO WA_DYNPREAD INDEX 1.
  IF SY-SUBRC = 0 AND WA_DYNPREAD-FIELDVALUE NE ''.

    SELECT MKAL~MATNR MKAL~WERKS MKAL~VERID
      INTO TABLE IT_VERID
      FROM MKAL
     WHERE MATNR = WA_DYNPREAD-FIELDVALUE AND WERKS = SO_PLANT-LOW.

    IF SY-SUBRC = 0.

      UNASSIGN <FS_VERID>.
      LOOP AT IT_VERID ASSIGNING <FS_VERID>.

        CLEAR: V_STLAL, MATERIAL, PLANT, BOM_USAGE, ALTERNATIVE, T_STPO.
        REFRESH: T_STPO.
        SELECT SINGLE STLAL
          INTO V_STLAL
          FROM MKAL
         WHERE MATNR = <FS_VERID>-MATNR AND WERKS = <FS_VERID>-WERKS AND VERID = <FS_VERID>-VERID.
        IF SY-SUBRC = 0.

          MATERIAL    = <FS_VERID>-MATNR. "WA_MAINTAIN-MTRPO.
          PLANT       = SO_PLANT-LOW.
          BOM_USAGE   = 1.
          ALTERNATIVE = V_STLAL.
          CALL FUNCTION 'CSAP_MAT_BOM_READ'
            EXPORTING
              MATERIAL             = MATERIAL
              PLANT                = PLANT
              BOM_USAGE            = BOM_USAGE
              ALTERNATIVE          = ALTERNATIVE
*           IMPORTING
*             FL_WARNING           =
            TABLES
              T_STPO               = T_STPO
            EXCEPTIONS
              ERROR                = 1
              OTHERS               = 2
                    .
          IF SY-SUBRC = 0.
            UNASSIGN <FS_STPO>.
            READ TABLE T_STPO ASSIGNING <FS_STPO> INDEX 1.
            IF SY-SUBRC = 0.
              <FS_VERID>-COMPONENT = <FS_STPO>-COMPONENT.
            ENDIF.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

  CLEAR: WA_DYNPREAD.
  READ TABLE T_DYNPREAD INTO WA_DYNPREAD INDEX 2.
  IF SY-SUBRC = 0 AND WA_DYNPREAD-FIELDVALUE NE ''.
    DELETE IT_VERID WHERE COMPONENT NE WA_DYNPREAD-FIELDVALUE.
  ENDIF.

  READ TABLE IT_VERID INDEX 1.
  IF SY-SUBRC = 0.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD    = 'VERID'
        DYNPPROG    = SY-REPID
        DYNPNR      = SY-DYNNR
        DYNPROFIELD = 'WA_MAINTAIN-VERID'
        VALUE_ORG   = 'S'
      TABLES
        VALUE_TAB   = IT_VERID.
  ENDIF.

*  IF sy-subrc = 0.
*      SORT IT_MATNR.
*      DELETE IT_MATNR WHERE MATNR = ''.
*      DELETE ADJACENT DUPLICATES FROM IT_MATNR COMPARING MATNR.
*
*      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*        EXPORTING
*          RETFIELD    = 'MATNR'
*          DYNPPROG    = SY-REPID
*          DYNPNR      = SY-DYNNR
*          DYNPROFIELD = 'WA_MAINTAIN-MTRPO'
*          VALUE_ORG   = 'S'
*        TABLES
*          VALUE_TAB   = IT_MATNR.
*    ENDIF.

ENDMODULE.                 " F4_HELP_VERID  INPUT



*&---------------------------------------------------------------------*
*&      Form  F_INSERTAGS_SQL
*&---------------------------------------------------------------------*
*       Insert GR data to AGS SQL database
*
*       ADDED FOR AGS BY FATHIR ON 20.11.2019
*----------------------------------------------------------------------*
*      -->PIN_GRN    text
*----------------------------------------------------------------------*
 FORM F_INSERTAGS_SQL TABLES PIN_GRN LIKE IT_AGSPARAM.

   RANGES: R_CHARG FOR MCHB-CHARG,
           R_MBLNR FOR MKPF-MBLNR,
           R_AUFNR FOR AUFK-AUFNR.
   REFRESH: R_CHARG,
            R_MBLNR,
            R_AUFNR.
   CLEAR: R_CHARG,
          R_MBLNR,
          R_AUFNR.

   IF PIN_GRN[] IS NOT INITIAL.

     LOOP AT PIN_GRN.

       R_CHARG-SIGN = 'I'.
       R_CHARG-OPTION = 'EQ'.
       R_CHARG-LOW = PIN_GRN-CHARG.
       APPEND R_CHARG.
       CLEAR R_CHARG.

       R_AUFNR-SIGN = 'I'.
       R_AUFNR-OPTION = 'EQ'.
       R_AUFNR-LOW = PIN_GRN-AUFNR.
       APPEND R_AUFNR.
       CLEAR R_AUFNR.

       R_MBLNR-SIGN = 'I'.
       R_MBLNR-OPTION = 'EQ'.
       R_MBLNR-LOW = PIN_GRN-MBLNR.
       APPEND R_MBLNR.
       CLEAR R_MBLNR.

     ENDLOOP.

     SUBMIT ZTPPI_ADJ_MAT_PURCHASE_AGS
       WITH S_CHARG IN R_CHARG
       WITH S_AUFNR IN R_AUFNR
       WITH S_MBLNR IN R_MBLNR
       AND RETURN.

   ENDIF.

 ENDFORM.                    "F_INSERTAGS_SQL