*----------------------------------------------------------------------*
***INCLUDE ZPPI_TIMBANG_SCRAP_F01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  INITIAL_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INITIAL_LGORT .
  " Copy SLoc tujuan = SLoc asal
  CLEAR S_SLOCT.
  S_SLOCT = S_SLOCA.
ENDFORM.                    " INITIAL_LGORT

*&---------------------------------------------------------------------*
*&      Form  F_GET_RANGE_SLOC
*&---------------------------------------------------------------------*
*       Get range of SLoc Asal
*----------------------------------------------------------------------*
FORM F_GET_RANGE_SLOC .

  REFRESH : TSLOC, R_SLOCA.
  CLEAR :WR_SLOC.

  DATA: XDYNPFIELDS TYPE STANDARD TABLE OF DYNPREAD WITH HEADER LINE,
        DYNAME LIKE D020S-PROG.

  DYNAME = SY-REPID.

  XDYNPFIELDS-FIELDNAME = 'S_PLANT'.

  APPEND XDYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = DYNAME
      DYNUMB               = '1100'
      TRANSLATE_TO_UPPER   = 'X'
    TABLES
      DYNPFIELDS           = XDYNPFIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.


  IF SY-SUBRC = 0.
    READ TABLE XDYNPFIELDS WITH KEY FIELDNAME = 'S_PLANT'.
    S_PLANT = XDYNPFIELDS-FIELDVALUE.
  ENDIF.

  IF S_PLANT IS INITIAL.
    MESSAGE 'Masukkan Plant terlebih dahulu' TYPE 'I'.
    EXIT.
  ENDIF.

  SELECT DISTINCT ZRRLGORT AS SLOCA
    LGOBE AS DESC
    INTO CORRESPONDING FIELDS OF TABLE TSLOC
    FROM ZTMAP_SLOCRR
    JOIN T001L
    ON ZTMAP_SLOCRR~ZRRLGORT = T001L~LGORT AND ZTMAP_SLOCRR~WERKS = T001L~WERKS
    WHERE ZTMAP_SLOCRR~WERKS = S_PLANT.

  SORT TSLOC BY SLOCA ASCENDING.

  LOOP AT TSLOC.
    WR_SLOC-SIGN   = 'I'.
    WR_SLOC-OPTION = 'EQ'.
    WR_SLOC-LOW    = TSLOC-SLOCA.
    APPEND WR_SLOC TO R_SLOCA.
  ENDLOOP.


ENDFORM.                    " F_GET_RANGE_SLOC

*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOCA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_SLOCA .

  REFRESH IT_SLOC.
  SELECT DISTINCT ZTMAP_SLOCRR~ZWPLGORT AS SLOC
    INTO CORRESPONDING FIELDS OF TABLE IT_SLOC
    FROM ZTMAP_SLOCRR
    WHERE ZTMAP_SLOCRR~ZRRLGORT = S_SLOCA
        AND ZTMAP_SLOCRR~WERKS = S_PLANT
        AND ZTMAP_SLOCRR~ZLINE IN S_PLINE.

  SELECT DISTINCT ZTMAP_SLOCRR~ZJRLGORT AS SLOC   "ADDED BY FATHIR ON 12.11.2020 - get RR sisa core base film - TRDK917760
    APPENDING CORRESPONDING FIELDS OF TABLE IT_SLOC
    FROM ZTMAP_SLOCRR
    WHERE ZTMAP_SLOCRR~ZRRLGORT = S_SLOCA
        AND ZTMAP_SLOCRR~WERKS = S_PLANT
        AND ZTMAP_SLOCRR~ZLINE IN S_PLINE.

  SORT IT_SLOC BY SLOC ASCENDING. "ADDED BY FATHIR ON 12.11.2020 - hapus SLOC yang '' - TRDK917760
  DELETE IT_SLOC WHERE SLOC = ''.
  DELETE IT_SLOC WHERE SLOC = ''.

  REFRESH  R_SLOC.
  LOOP AT IT_SLOC.
    W_RSLOC-SIGN   = 'I'.
    W_RSLOC-OPTION = 'EQ'.
    W_RSLOC-LOW    = IT_SLOC-SLOC.
    APPEND W_RSLOC TO R_SLOC.
  ENDLOOP.

ENDFORM.                    " F_GET_SLOCA

*&---------------------------------------------------------------------*
*&      Form  COPYDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_COPYDATA .

  "Cek otorisasi Plant
  AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD S_PLANT.
  IF SY-SUBRC NE 0.
    CONCATENATE 'No Authorization for Plant' S_PLANT INTO DMESSAGE SEPARATED BY SPACE.
    MESSAGE DMESSAGE TYPE 'I'.
    CALL SCREEN 1100.
  ENDIF.
  "Cek otorisasi Plant

  " Validasi field required
  PERFORM F_CHECK_REQUIRED CHANGING L_ERRNO.
  CHECK L_ERRNO NE -1.

  " Validasi start dan end date
  PERFORM F_CHECK_DATE CHANGING L_ERRNO.
  CHECK L_ERRNO NE -1.

  " Validasi SLoc asal dan ProdLine
  " harus sesuai dengan tabel ZTMAP_SLOCWASTE
  PERFORM F_CHECK_PRODLINE CHANGING L_ERRNO.
  CHECK L_ERRNO NE -1.
*  PERFORM INITIAL_LGORT.   "CHANGED BY FATHIR ON 16.04.2020

  PERFORM F_CHECK_NIK CHANGING L_ERRNO.

  REFRESH : T_MATNR.
  "Ambil mapping raw recycle berdasarkan plant & material yang akan ditimbang
  SELECT RAR_A_MATNR AS LOW INTO CORRESPONDING FIELDS OF TABLE T_MATNR
   FROM ZTMAP_FGRRECYCLE
    WHERE FGR_B_MATNR = S_MATNR
    AND WERKS EQ S_PLANT.

  IF SY-SUBRC = 0.
    T_MATNR-SIGN = 'I'.
    T_MATNR-OPTION = 'EQ'.
    MODIFY T_MATNR TRANSPORTING SIGN OPTION WHERE LOW IS NOT INITIAL.
  ELSE.
    MESSAGE 'Material yang ditimbang Tidak memiliki Mapping Raw Recycle' TYPE 'I'.
    L_ERRNO = -1.
    EXIT.
  ENDIF.

  IF L_ERRNO = -1.
    MESSAGE MESSAGE TYPE 'I' DISPLAY LIKE 'W'.
  ELSE.
    IF IT_TIMBANG[] IS NOT INITIAL.
      MESSAGE 'Data telah dicopy' TYPE 'I'.
    ELSE.
      IF S_PLANT IS INITIAL.
        IF S_MATNR IS INITIAL.
          IF S_SLOCA IS INITIAL.
            MESSAGE 'Isi Plant, Material, dan SLoc Asal !' TYPE 'I'.
          ELSE.
            MESSAGE 'Isi Plant dan Material!' TYPE 'I'.
          ENDIF.
        ELSE.
          MESSAGE 'Isi Plant !' TYPE 'I'.
        ENDIF.
      ELSE.
        IF S_MATNR IS INITIAL.
          IF S_SLOCA IS INITIAL.
            MESSAGE 'Isi Material, dan SLoc Asal !' TYPE 'I'.
          ELSE.
            MESSAGE 'Isi Material!' TYPE 'I'.
          ENDIF.
        ELSE.
          IF S_SLOCA IS INITIAL..
            MESSAGE 'Isi SLoc Asal!' TYPE 'I'.
          ELSE.

            PERFORM F_GET_RANGE_SLOC.

            IF S_SLOCA NOT IN R_SLOCA.
              CLEAR VMSG.
              CONCATENATE 'SLoc asal bukan SLoc Raw Recycle di Plant' S_PLANT INTO VMSG SEPARATED BY SPACE.
              MESSAGE VMSG TYPE 'I' DISPLAY LIKE 'W'.
            ELSE.
              PERFORM F_CHECK_MATERIAL CHANGING L_ERRNO.
              IF L_ERRNO <> -1.
                CLEAR WA_TIMBANG.
                WA_TIMBANG-MATNR = S_MATNR.
                WA_TIMBANG-WERKS = S_PLANT.
                WA_TIMBANG-LGORT = S_SLOCT.
                WA_TIMBANG-LGORA = S_SLOCA.
                APPEND WA_TIMBANG TO IT_TIMBANG.

                LOOP AT IT_TIMBANG.
                  SELECT SINGLE MARA~MEINS
                    INTO IT_TIMBANG-MEINS
                    FROM MARA
                    WHERE MARA~MATNR = IT_TIMBANG-MATNR.

                  SELECT SINGLE MAKT~MAKTX
                    INTO IT_TIMBANG-MAKTX
                    FROM MAKT
                    WHERE MATNR = IT_TIMBANG-MATNR.

                  IT_TIMBANG-NO = SY-TABIX.

                  MODIFY IT_TIMBANG.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM ZPRODLINE.

*  DATA : COUNT_LINE TYPE I,
*         COUNTER TYPE I.
*
*  COUNTER = 1.
*  DESCRIBE TABLE S_PLINE LINES COUNT_LINE.
*
*  LOOP AT S_PLINE.
*    IF COUNTER = 1.
*      ZPRODLINE = S_PLINE-LOW.
*    ELSE.
*      CONCATENATE ZPRODLINE S_PLINE-LOW INTO ZPRODLINE SEPARATED BY ','.
*    ENDIF.
*    COUNTER = COUNTER + 1.
*  ENDLOOP.
ENDFORM.                    " COPYDATA

*&---------------------------------------------------------------------*
*&      Form  DELETEDATA
*&---------------------------------------------------------------------*
FORM F_DELETEDATA .
  IF IT_TIMBANG[] IS INITIAL.
    MESSAGE 'Tidak ada data yang akan dihapus' TYPE 'I'.
  ELSE.
    DELETE IT_TIMBANG WHERE FLAG = 'X'.
    IF SY-SUBRC <> 0.
      REFRESH IT_TIMBANG[].
    ENDIF.
  ENDIF.

ENDFORM.                    " DELETEDATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TIMBANG
*&---------------------------------------------------------------------*
FORM F_VALIDATE_TIMBANG  CHANGING FI_RET.

  IF S_MATNR = ''.
    MESSAGE 'Material yang akan ditimbang tidak boleh kosong' TYPE 'S' DISPLAY LIKE 'E'.
    FI_RET = -1.
  ELSE.

    PERFORM F_GET_RANGE_SLOC.

    LOOP AT IT_TIMBANG.

      "cek material
      IF IT_TIMBANG-MATNR = ''.
        MESSAGE 'Material yang akan ditimbang tidak boleh kosong' TYPE 'S' DISPLAY LIKE 'E'.
        FI_RET = -1.
      ELSE.

        "cek quantity gross dan quantity wadah
        IF IT_TIMBANG-GROSS < IT_TIMBANG-WADAH.
          MESSAGE 'Berat Wadah tidak boleh lebih besar dari Gross Qty' TYPE 'S' DISPLAY LIKE 'E'.
          FI_RET = -1.

        ELSE.
          "cek apakah quantity 0
          IF IT_TIMBANG-MENGE IS INITIAL.
            MESSAGE 'Quantity tidak boleh nol' TYPE 'S' DISPLAY LIKE 'E'.
            FI_RET = -1.
          ELSE.
            "CEK SLOC ASAL
            IF IT_TIMBANG-LGORA NOT IN R_SLOCA.
              CLEAR VMSG.
              CONCATENATE 'SLoc asal bukan SLoc Raw Recycle  di Plant' S_PLANT INTO VMSG SEPARATED BY SPACE.
              MESSAGE VMSG TYPE 'S' DISPLAY LIKE 'E'.
              FI_RET = -1.
            ELSE.
              "cek bagian
              IF IT_TIMBANG-BAGIAN IS INITIAL.
                CLEAR VMSG.
                MESSAGE 'Bagian tidak boleh kosong' TYPE 'S' DISPLAY LIKE 'E'.
                FI_RET = -1.
              ELSE.

                IF IT_TIMBANG-BAGIAN NOT IN R_BAGIAN.
                  CLEAR VMSG.
                  MESSAGE 'Bagian harus diisi dengan SLT,PRS,RCL,OTH,RND, atau GUD' TYPE 'S' DISPLAY LIKE 'E'.
                  FI_RET = -1.
                ELSE.
                  FI_RET = 1.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " F_VALIDATE_TIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_ALLOCATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DATA_ALLOCATION.

*  DATA : ZZCODE TYPE AUSP-ATWRT,  "CHANGED BY FATHIR ON 12.11.2020 - pindahkan ke fungsi tersendiri - TRDK917760
*         ZZTYPE TYPE AUSP-ATWRT,
*         ZZPRODLINE TYPE AUSP-ATWRT,
*         IT_KUPASJR TYPE TY_TIMBANG OCCURS 0 WITH HEADER LINE.

  REFRESH : ITAB_TIMBANG, R_BKTXT, R_MBLNR.
  CLEAR   : ITAB_TIMBANG, R_BKTXT, R_MBLNR, V_GRCOAT. "CHANGED BY FATHIR ON 12.11.2020 - clear flag (case GR JR Coat) - TRDK917760

  "Ambil sloc waste process berdasarkan plant, prod line & sloc raw recycle gabungan
  PERFORM F_GET_SLOCA.

  "Define Order Type untuk pencarian process order
  PERFORM F_DEFINE_AUART.

  IF T_MATNR[] IS NOT INITIAL AND R_SLOC[] IS NOT INITIAL.

    DATA  : IT_DATE TYPE SCSCP_PERIOD_STR OCCURS 0 WITH HEADER LINE.

    CALL FUNCTION 'CSCP_PARA1_GET_PERIODS'
      EXPORTING
        I_DATUV    = S_SDATE
        I_DATUB    = S_EDATE
        I_TIMEUNIT = 'D'
      TABLES
        ET_DATES   = IT_DATE.

    DELETE IT_DATE INDEX 1.

*    RANGES: R_MBLNR  FOR MSEG-MBLNR,  "CHANGED BY FATHIR ON 12.11.2020 - sudah ada di global variable - TRDK917760
    RANGES: R_MBLNR2 FOR MSEG-MBLNR,
            R_TMBLNR FOR MSEG-MBLNR.

    LOOP AT IT_DATE.
      CLEAR R_TMBLNR.
      REFRESH R_TMBLNR.

      SELECT MSEG~MBLNR AS LOW
      INTO CORRESPONDING FIELDS OF TABLE R_TMBLNR
      FROM MSEG JOIN MKPF ON MSEG~MBLNR EQ MKPF~MBLNR
      WHERE MSEG~LGORT IN R_SLOC
        AND MSEG~BWART IN ('531','532')
        AND MKPF~BUDAT EQ IT_DATE-DATUV
        AND MKPF~BKTXT NE ''
        AND MKPF~XBLNR EQ ''
        AND MSEG~WERKS IN L_WERKS.
      APPEND LINES OF R_TMBLNR TO R_MBLNR.

      IF SY-SUBRC = 0.
        R_MBLNR-SIGN = 'I'.
        R_MBLNR-OPTION = 'EQ'.
        MODIFY R_MBLNR TRANSPORTING SIGN OPTION WHERE LOW IS NOT INITIAL.
      ENDIF.

      "Jika Include PRO Kupas, maka cari PRO Kupas berdasarkan material pembentuk & range tanggal
      IF ZCB_RR IS NOT INITIAL.
        CLEAR R_TMBLNR.
        REFRESH R_TMBLNR.

        SELECT MSEG~MBLNR AS LOW
               INTO CORRESPONDING FIELDS OF TABLE R_TMBLNR
          FROM MSEG
          JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
          WHERE MKPF~BUDAT EQ IT_DATE-DATUV
            AND MSEG~LGORT = S_SLOCA
            AND MSEG~BWART IN ('531','532')
            AND MKPF~BKTXT NE ''
            AND MSEG~WERKS IN L_WERKS.
        APPEND LINES OF R_TMBLNR TO R_MBLNR2.

        SELECT MSEG~MBLNR AS LOW  "ADDED BY FATHIR ON 12.11.2020 - Get data RR (kupas JR) - TRDK917760
               INTO CORRESPONDING FIELDS OF TABLE R_TMBLNR
          FROM MSEG
          JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
          JOIN AFKO ON MSEG~AUFNR = AFKO~AUFNR
          WHERE MKPF~BUDAT EQ IT_DATE-DATUV
            AND MSEG~LGORT = S_SLOCA
            AND MSEG~BWART IN ('531','532')
            AND AFKO~PLNBEZ LIKE 'JR%'
            AND MSEG~WERKS IN L_WERKS.
        APPEND LINES OF R_TMBLNR TO R_MBLNR2.

        IF SY-SUBRC = 0.
          R_MBLNR2-SIGN = 'I'.
          R_MBLNR2-OPTION = 'EQ'.
          MODIFY R_MBLNR2 TRANSPORTING SIGN OPTION WHERE LOW IS NOT INITIAL.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF R_MBLNR[] IS NOT INITIAL.
      CLEAR ITAB_TIMBANG2.
      REFRESH ITAB_TIMBANG2.

      SELECT MSEG~MBLNR  MSEG~ZEILE MSEG~MATNR  MSEG~BWART
             MSEG~WERKS  MSEG~LGORT MSEG~CHARG  MSEG~MENGE
             MSEG~MEINS  MSEG~AUFNR MKPF~BKTXT  MKPF~BUDAT
             AUFK~AUART  MSEG~SMBLN MSEG~SMBLP  AUFK~OBJNR
             AUFK~ZLINE
      INTO CORRESPONDING FIELDS OF TABLE ITAB_TIMBANG2
      FROM MSEG
      JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
      JOIN AUFK ON MSEG~AUFNR = AUFK~AUFNR
      WHERE MSEG~MBLNR IN R_MBLNR
      AND   MSEG~MATNR IN T_MATNR
      AND   AUFK~AUART IN R_AUART
      AND   AUFK~ZLINE IN S_PLINE.
      APPEND LINES OF ITAB_TIMBANG2 TO ITAB_TIMBANG.
    ENDIF.

    IF ZCB_RR IS NOT INITIAL. " Jika Include PRO Kupas, maka cari PRO Kupas berdasarkan material pembentuk & range tanggal
      CLEAR ITAB_TIMBANG2.
      REFRESH ITAB_TIMBANG2.

      IF R_MBLNR2[] IS NOT INITIAL.
        SELECT MSEG~MBLNR  MSEG~ZEILE MSEG~MATNR  MSEG~BWART
               MSEG~WERKS  MSEG~LGORT MSEG~CHARG  MSEG~MENGE
               MSEG~MEINS  MSEG~AUFNR MKPF~BKTXT  MKPF~BUDAT
               AUFK~AUART  MSEG~SMBLN MSEG~SMBLP  AUFK~OBJNR
         INTO CORRESPONDING FIELDS OF TABLE ITAB_TIMBANG2
         FROM  MSEG
         JOIN  MKPF ON MSEG~MBLNR = MKPF~MBLNR
         JOIN  AUFK ON MSEG~AUFNR = AUFK~AUFNR
         WHERE MSEG~MATNR IN T_MATNR
           AND AUFK~AUART IN ('ZRR1', 'ZRR2')
           AND MSEG~MBLNR IN R_MBLNR2.
        APPEND LINES OF ITAB_TIMBANG2 TO ITAB_TIMBANG.
      ENDIF.
    ENDIF.

  ELSE.
    MESSAGE 'Tipe Film Tidak ditemukan' TYPE 'I'.
    EXIT.
  ENDIF.

  "Hapus data receipt by product yang dicancel
  LOOP AT ITAB_TIMBANG WHERE BWART = '532' AND SMBLN <> ''.
    DELETE ITAB_TIMBANG WHERE MBLNR = ITAB_TIMBANG-SMBLN AND ZEILE = ITAB_TIMBANG-SMBLP.
  ENDLOOP.

  DELETE ITAB_TIMBANG WHERE BWART = '532'.

  "Cari Status Order utk hapus yg status order nya sudah closed
  LOOP AT ITAB_TIMBANG.
    SELECT SINGLE ISTAT TXT30 TXT04 "COMPLETE STATUS
      INTO (ITAB_TIMBANG-ISTAT,ITAB_TIMBANG-TXT30, ITAB_TIMBANG-TXT04)
    FROM TJ02T
      JOIN JEST ON JEST~STAT = TJ02T~ISTAT
    WHERE OBJNR = ITAB_TIMBANG-OBJNR AND
          SPRAS = 'E' AND
          INACT NE 'X' AND
          TXT04 = 'CLSD'.
    MODIFY ITAB_TIMBANG.
  ENDLOOP.

  DELETE ITAB_TIMBANG WHERE TXT04 = 'CLSD'.

  IF ITAB_TIMBANG[] IS NOT INITIAL.

    LOOP AT ITAB_TIMBANG. " isi materialdocument 531 ke ranges
      R_MBLNR-LOW = ITAB_TIMBANG-MBLNR.
      R_MBLNR-SIGN = 'I'.
      R_MBLNR-OPTION = 'EQ'.
      APPEND R_MBLNR.
    ENDLOOP.

    PERFORM F_GET_GR_RR. " get GR RR - TRDK917760

  ELSE.

    IF ZCB_RR IS NOT INITIAL. "ADDED BY FATHIR ON 30.09.2020 - get GR JR Coating
      PERFORM F_GET_GR_JR.
    ELSE.
      MESSAGE 'Tipe Film Tidak ditemukan' TYPE 'I'.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.                    "F_GET_DATA_ALLOCATION


*&---------------------------------------------------------------------*
*&      Form  F_GET_GR_RR
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR ON 12.11.2020
*       get GR RR - TRDK917760
*----------------------------------------------------------------------*
FORM F_GET_GR_RR.
  DATA: ZZCODE TYPE AUSP-ATWRT,
        ZZTYPE TYPE AUSP-ATWRT,
        ZZPRODLINE TYPE AUSP-ATWRT,
        IT_KUPASJR TYPE TY_TIMBANG OCCURS 0 WITH HEADER LINE.

  "Cari material document yang pernah dilakukan pembebanan timbang
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_LOG_TIMBANG
    FROM ZTLOGTIMBANG
    WHERE ZOLDMD IN R_MBLNR.

  LOOP AT ITAB_TIMBANG.
    READ TABLE IT_LOG_TIMBANG WITH KEY ZOLDMD = ITAB_TIMBANG-MBLNR.
    IF SY-SUBRC = 0.
      "Hapus material document yang pernah dilakukan pembebanan timbang
      DELETE ITAB_TIMBANG WHERE MBLNR = IT_LOG_TIMBANG-ZOLDMD.
      CONTINUE.
    ELSE.
      "Isi nomor roll ke ranges
      R_BKTXT-LOW = ITAB_TIMBANG-BKTXT.
      R_BKTXT-SIGN = 'I'.
      R_BKTXT-OPTION = 'EQ'.
      APPEND R_BKTXT.
    ENDIF.

    " isi itab temporary dengan data PRO kupas JR
    IF ( ITAB_TIMBANG-AUART = 'ZRR1' OR ITAB_TIMBANG-AUART = 'ZRR2' ) AND ITAB_TIMBANG-BKTXT = ''.
      APPEND ITAB_TIMBANG TO IT_KUPASJR.
    ENDIF.
  ENDLOOP.

  IF ITAB_TIMBANG[] IS NOT INITIAL. " get GR JR dan GI JR Kupas - TRDK917760

    DATA: ITAB_TEMP_JR LIKE ITAB_JR OCCURS 0.

    " get GR JR berdasarkan roll number
    SORT R_BKTXT BY LOW ASCENDING.
    DELETE R_BKTXT WHERE LOW = ''.
    IF R_BKTXT[] IS NOT INITIAL.
      REFRESH: ITAB_TEMP_JR.
      SELECT MSEG~MBLNR
           MSEG~ZEILE
           MSEG~MATNR
           MSEG~BWART
           MSEG~WERKS
           MSEG~LGORT
           MSEG~CHARG
           MSEG~MENGE
           MSEG~AUFNR
           MKPF~BKTXT
           MKPF~BUDAT
           MSEG~SMBLN
           MSEG~SMBLP
           MAKT~MAKTX
         INTO CORRESPONDING FIELDS OF TABLE ITAB_TEMP_JR
         FROM MSEG
         JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
         JOIN MAKT ON MAKT~MATNR = MSEG~MATNR
         WHERE MSEG~BWART IN ('101','102')
               AND MKPF~BKTXT IN R_BKTXT.
      IF SY-SUBRC = 0.
        APPEND LINES OF ITAB_TEMP_JR TO ITAB_JR.
      ENDIF.
    ENDIF.

    " get GI JR berdasarkan PrO JR
    IF IT_KUPASJR[] IS NOT INITIAL.
      REFRESH: ITAB_TEMP_JR.
      SELECT MSEG~MBLNR
          MSEG~ZEILE
          MSEG~MATNR
          MSEG~BWART
          MSEG~WERKS
          MSEG~LGORT
          MSEG~CHARG
          MSEG~MENGE
          MSEG~AUFNR
          MKPF~BKTXT
          MKPF~BUDAT
          MSEG~SMBLN
          MSEG~SMBLP
          MAKT~MAKTX
        INTO CORRESPONDING FIELDS OF TABLE ITAB_TEMP_JR
        FROM MSEG
        JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
        JOIN MAKT ON MAKT~MATNR = MSEG~MATNR
        FOR ALL ENTRIES IN IT_KUPASJR
        WHERE MSEG~BWART IN ('261','262')
          AND MSEG~AUFNR = IT_KUPASJR-AUFNR.
      IF SY-SUBRC = 0.
        APPEND LINES OF ITAB_TEMP_JR TO ITAB_JR.
      ENDIF.
    ENDIF.

    LOOP AT ITAB_JR WHERE BWART = '102' AND SMBLN <> ''.
      DELETE ITAB_JR WHERE MBLNR = ITAB_JR-SMBLN AND ZEILE = ITAB_JR-SMBLP.
    ENDLOOP.
    DELETE ITAB_JR WHERE BWART = '102' AND SMBLN <> ''.

    LOOP AT ITAB_JR WHERE BWART = '262' AND SMBLN <> ''.
      DELETE ITAB_JR WHERE MBLNR = ITAB_JR-SMBLN AND ZEILE = ITAB_JR-SMBLP.
    ENDLOOP.
    DELETE ITAB_JR WHERE BWART = '262' AND SMBLN <> ''.

  ENDIF.

  "Pasangkan RR dengan GR JR
  LOOP AT ITAB_TIMBANG.
    CLEAR ITAB_JR.
    IF ITAB_TIMBANG-BKTXT NE ''.  " Memasangkan RR dengan GR JR - TRDK917760
      READ TABLE ITAB_JR WITH KEY BKTXT = ITAB_TIMBANG-BKTXT.
      IF SY-SUBRC = 0.
        ITAB_TIMBANG-MATNRJR = ITAB_JR-MATNR.
        ITAB_TIMBANG-CHARGJR = ITAB_JR-CHARG.
        ITAB_TIMBANG-MAKTXJR = ITAB_JR-MAKTX.
        ITAB_TIMBANG-MENGEJR = ITAB_JR-MENGE.
      ENDIF.
    ELSE.
      READ TABLE ITAB_JR WITH KEY AUFNR = ITAB_TIMBANG-AUFNR.
      IF SY-SUBRC = 0.
        ITAB_TIMBANG-MATNRJR = ITAB_JR-MATNR.
        ITAB_TIMBANG-CHARGJR = ITAB_JR-CHARG.
        ITAB_TIMBANG-MAKTXJR = ITAB_JR-MAKTX.
        ITAB_TIMBANG-MENGEJR = ITAB_JR-MENGE.
      ENDIF.
    ENDIF.

    IF ITAB_JR-CHARG NE ''.   " get characteristics JR
      SELECT AUSP~ATWRT INTO ZZCODE
            FROM AUSP
                 JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
                 JOIN CABN ON CABN~ATINN = AUSP~ATINN
            WHERE MCH1~CHARG = ITAB_JR-CHARG
                  AND CABN~ATNAM = 'ZZCODE'.
      ENDSELECT.

      SELECT CAWNT~ATWTB INTO ZZTYPE
        FROM CAWNT
             JOIN CAWN ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
             JOIN CABN ON CABN~ATINN = CAWN~ATINN
        WHERE CABN~ATNAM = 'ZZCODE'
              AND CAWN~ATWRT = ZZCODE.
      ENDSELECT.

      IF ITAB_TIMBANG-ZLINE IS INITIAL.   " get production line jika belum ditemukan (PRO kupas)
        SELECT AUSP~ATWRT INTO ITAB_TIMBANG-ZLINE
        FROM AUSP
             JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
             JOIN CABN ON CABN~ATINN = AUSP~ATINN
        WHERE MCH1~CHARG = ITAB_JR-CHARG
              AND CABN~ATNAM = 'ZZPRODLINE'.
        ENDSELECT.
      ENDIF.

      IF ITAB_TIMBANG-BKTXT IS INITIAL. " get nomor roll of JR kupas (case ZPP019) - TRDK917760
        SELECT AUSP~ATWRT INTO ITAB_TIMBANG-BKTXT
        FROM AUSP
             JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
             JOIN CABN ON CABN~ATINN = AUSP~ATINN
        WHERE MCH1~CHARG = ITAB_JR-CHARG
              AND CABN~ATNAM = 'ZZNOMORROLL'.
        ENDSELECT.

        MODIFY ITAB_TIMBANG TRANSPORTING BKTXT WHERE BKTXT = '' AND AUFNR = ITAB_TIMBANG-AUFNR.
      ENDIF.

      ITAB_TIMBANG-ZZCODE = ZZCODE.
      ITAB_TIMBANG-ZZTYPE = ZZTYPE.

      MODIFY ITAB_TIMBANG TRANSPORTING MATNRJR CHARGJR MAKTXJR MENGEJR ZZCODE ZZTYPE ZLINE WHERE BKTXT = ITAB_TIMBANG-BKTXT.  "CHANGED BY FATHIR ON 30.09.2020 - update baris berdasarkan order number (sebelumnya by docheader text)
    ENDIF.
  ENDLOOP.

  DELETE ITAB_TIMBANG WHERE ZLINE NOT IN S_PLINE.

  IF ITAB_TIMBANG[] IS INITIAL.

    IF ZCB_RR IS NOT INITIAL. " get GR JR Coating - TRDK917760
      PERFORM F_GET_GR_JR.
    ELSE.
      MESSAGE 'Tipe Film Tidak ditemukan' TYPE 'I'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    "F_GET_GR_RR


*&---------------------------------------------------------------------*
*&      Form  F_GET_GR_JR
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR ON 12.11.2020
*       get GR JR Coating, untuk case pembebanan PRO JR Coating - TRDK917760
*----------------------------------------------------------------------*
FORM F_GET_GR_JR.
  DATA: ZZCODE TYPE AUSP-ATWRT,
        ZZTYPE TYPE AUSP-ATWRT,
        ZZPRODLINE TYPE AUSP-ATWRT.
  DATA: IT_DATE TYPE SCSCP_PERIOD_STR OCCURS 0 WITH HEADER LINE,
        IT_MATRR TYPE ZTMAP_MATRECYCLE OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF IT_LOGTB OCCURS 0.
          INCLUDE TYPE ZTLOGTIMBANG.
  DATA:   BKTXT LIKE MKPF-BKTXT,
        END OF IT_LOGTB.

  CALL FUNCTION 'CSCP_PARA1_GET_PERIODS'  " get interval harian dari startdate-enddate
    EXPORTING
      I_DATUV    = S_SDATE
      I_DATUB    = S_EDATE
      I_TIMEUNIT = 'D'
    TABLES
      ET_DATES   = IT_DATE.
  DELETE IT_DATE INDEX 1.

  CLEAR: C_MATNR, IT_MATRR, ITAB_JR, ITAB_TIMBANG.
  REFRESH: C_MATNR, IT_MATRR, ITAB_JR, ITAB_TIMBANG.

  " get material JR berdasarkan RR
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MATRR
    FROM MARA
    JOIN ZTMAP_MATRECYCLE AS MAPRR ON MARA~MATNR = MAPRR~MATNR
    WHERE MAPRR~WERKS = S_PLANT
      AND MAPRR~RAR_A_MATNR IN T_MATNR
      AND MARA~MATKL IN ('400005', '400006').
  IF SY-SUBRC NE 0.
    MESSAGE 'Tipe Film Tidak ditemukan' TYPE 'I'.
    EXIT.
  ELSE.
    C_MATNR-SIGN = 'I'.
    C_MATNR-OPTION = 'EQ'.
    LOOP AT IT_MATRR.
      C_MATNR-LOW = IT_MATRR-MATNR.
      APPEND C_MATNR.
    ENDLOOP.

    V_GRCOAT = 'X'.
  ENDIF.

  LOOP AT IT_DATE.  " get material GR JR berdasarkan RR

    SELECT
        MSEG~MBLNR
        MSEG~ZEILE
        MSEG~MATNR
        MSEG~BWART
        MSEG~WERKS
        MSEG~LGORT
        MSEG~CHARG
        MSEG~MENGE
        MSEG~MEINS
        MSEG~AUFNR
        MKPF~BKTXT
        MKPF~BUDAT
        MSEG~SMBLN
        MSEG~SMBLP
        MAKT~MAKTX
      APPENDING CORRESPONDING FIELDS OF TABLE ITAB_JR
      FROM MKPF
      JOIN MSEG ON MKPF~MBLNR = MSEG~MBLNR AND MKPF~MJAHR = MSEG~MJAHR
      JOIN MAKT ON MAKT~MATNR = MSEG~MATNR
      WHERE MKPF~BUDAT = IT_DATE-DATUV
        AND MSEG~WERKS = S_PLANT
        AND MSEG~BWART IN ('101', '102')
        AND MSEG~MATNR IN C_MATNR.

  ENDLOOP.

  LOOP AT ITAB_JR WHERE BWART = '102' AND SMBLN <> ''.  " hapus matdoc yang sudah dicancel
    DELETE ITAB_JR WHERE MBLNR = ITAB_JR-SMBLN AND ZEILE = ITAB_JR-SMBLP.
  ENDLOOP.
  DELETE ITAB_JR WHERE BWART = '102' AND SMBLN <> ''.

  "Cari material document yang pernah dilakukan pembebanan timbang
  REFRESH: IT_LOGTB.
  SELECT
      LOGTB~MANDT
      LOGTB~ZIDLOG
      LOGTB~ZITEMLOG
      LOGTB~ZOLDMD
      LOGTB~ZNEWMD
      LOGTB~ZBWART
      LOGTB~ZAUFNR
      LOGTB~ZMATNR
      LOGTB~ZQTY
      LOGTB~ZLGORT
      LOGTB~ZWERKS
      LOGTB~ZBAGIAN
      LOGTB~ZBUDAT
      LOGTB~ZCPUDT
      LOGTB~ZCPUTM
      LOGTB~ZUSNAM
      LOGTB~ZIND
      MKPF~BKTXT
    INTO CORRESPONDING FIELDS OF TABLE IT_LOGTB
    FROM ZTLOGTIMBANG AS LOGTB
    JOIN MKPF ON LOGTB~ZOLDMD = MKPF~MBLNR
    FOR ALL ENTRIES IN ITAB_JR
    WHERE MKPF~BKTXT = ITAB_JR-BKTXT
      AND MKPF~BUDAT = ITAB_JR-BUDAT.

  LOOP AT ITAB_JR.  "Hapus matdoc yang pernah dibebani
    READ TABLE IT_LOGTB WITH KEY BKTXT = ITAB_JR-BKTXT.
    IF SY-SUBRC = 0.
      DELETE ITAB_JR WHERE BKTXT = ITAB_JR-BKTXT.
    ENDIF.
  ENDLOOP.

  LOOP AT ITAB_JR.    " set data JR ke ITAB_TIMBANG
    READ TABLE IT_MATRR WITH KEY MATNR = ITAB_JR-MATNR.
    ITAB_TIMBANG-MATNR = IT_MATRR-RAR_A_MATNR.  " material RR

    ITAB_TIMBANG-MBLNR = ITAB_JR-MBLNR.
    ITAB_TIMBANG-MATNRJR = ITAB_JR-MATNR.
    ITAB_TIMBANG-CHARGJR = ITAB_JR-CHARG.
    ITAB_TIMBANG-MAKTXJR = ITAB_JR-MAKTX.
    ITAB_TIMBANG-MENGEJR = ITAB_JR-MENGE.
    ITAB_TIMBANG-AUFNR = ITAB_JR-AUFNR.
    ITAB_TIMBANG-BKTXT = ITAB_JR-BKTXT.
    ITAB_TIMBANG-MEINS = ITAB_JR-MEINS.

    SELECT SINGLE OBJNR AUART
      INTO (ITAB_TIMBANG-OBJNR, ITAB_TIMBANG-AUART)
      FROM AUFK
      WHERE AUFNR = ITAB_TIMBANG-AUFNR.

    IF ITAB_JR-CHARG NE ''.   " get characteristics JR
      SELECT AUSP~ATWRT INTO ZZCODE
            FROM AUSP
                 JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
                 JOIN CABN ON CABN~ATINN = AUSP~ATINN
            WHERE MCH1~CHARG = ITAB_JR-CHARG
                  AND CABN~ATNAM = 'ZZCODE'.
      ENDSELECT.

      SELECT CAWNT~ATWTB INTO ZZTYPE
        FROM CAWNT
             JOIN CAWN ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
             JOIN CABN ON CABN~ATINN = CAWN~ATINN
        WHERE CABN~ATNAM = 'ZZCODE'
              AND CAWN~ATWRT = ZZCODE.
      ENDSELECT.

      SELECT SINGLE ZLINE INTO ITAB_TIMBANG-ZLINE
        FROM AUFK
        WHERE AUFNR = ITAB_TIMBANG-AUFNR.

      ITAB_TIMBANG-ZZCODE = ZZCODE.
      ITAB_TIMBANG-ZZTYPE = ZZTYPE.

      APPEND ITAB_TIMBANG.
    ENDIF.

  ENDLOOP.

  DELETE ITAB_TIMBANG WHERE ZLINE NOT IN S_PLINE.

  IF ITAB_TIMBANG[] IS INITIAL.
    MESSAGE 'Tipe Film Tidak ditemukan' TYPE 'I'.
    EXIT.
  ENDIF.

ENDFORM.                    "F_GET_GR_JR


*&---------------------------------------------------------------------*
*&      Form  F_GETTIPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GETTIPE.
  DATA : ZGRANDTOTALRR TYPE MENGE_D,
         ZTOTALRR TYPE MENGE_D,
         PERSEN TYPE PROZT,
         PERSENTOTAL TYPE PROZT,
         COUNT TYPE I,
         COUNTER TYPE I.

  COUNTER = 0.
  PERSENTOTAL = 0.

  REFRESH ITAB_RRTIPE[].
  CLEAR ITAB_RRTIPE.

  ITAB_RRTIPE[] = ITAB_TIMBANG[].

  SORT ITAB_RRTIPE[] BY ZZTYPE MATNR.
  DELETE ADJACENT DUPLICATES FROM ITAB_RRTIPE COMPARING ZZTYPE MATNR.

  DESCRIBE TABLE ITAB_RRTIPE LINES COUNT.

  LOOP AT ITAB_TIMBANG.
    IF V_GRCOAT = 'X'.  "ADDED BY FATHIR ON 12.11.2020 - case pembebanan GR JR Coating - TRDK917760
      ZGRANDTOTALRR = ZGRANDTOTALRR + ITAB_TIMBANG-MENGEJR.
    ELSE.
      ZGRANDTOTALRR = ZGRANDTOTALRR + ITAB_TIMBANG-MENGE.
    ENDIF.
  ENDLOOP.

  LOOP AT ITAB_RRTIPE.
    CLEAR : PERSEN, ZTOTALRR.

    COUNTER = COUNTER + 1.

    LOOP AT ITAB_TIMBANG WHERE MATNR = ITAB_RRTIPE-MATNR
                           AND ZZTYPE = ITAB_RRTIPE-ZZTYPE.

      IF V_GRCOAT = 'X'.  "ADDED BY FATHIR ON 12.11.2020 - case pembebanan GR JR Coating - TRDK917760
        ZTOTALRR = ZTOTALRR + ITAB_TIMBANG-MENGEJR.
      ELSE.
        ZTOTALRR = ZTOTALRR + ITAB_TIMBANG-MENGE.
      ENDIF.

    ENDLOOP.
    PERSEN = ZTOTALRR / ZGRANDTOTALRR * 100.
    PERSENTOTAL = PERSENTOTAL + PERSEN.

    WA_TIPE-ATWRT = ITAB_RRTIPE-ZZCODE.
    WA_TIPE-ATWTB = ITAB_RRTIPE-ZZTYPE.
    WA_TIPE-MATNR = ITAB_RRTIPE-MATNR.
    WA_TIPE-MEINS = ITAB_RRTIPE-MEINS.
    WA_TIPE-QTYTOT = ZTOTALRR.

    IF COUNTER > 1 AND COUNTER = COUNT.
      IF PERSENTOTAL > 100.
        WA_TIPE-PRSN = PERSEN - ( PERSENTOTAL - 100 ).
        WA_TIPE-MENGE = WA_TIMBANG-MENGE * WA_TIPE-PRSN / 100.
      ELSEIF PERSENTOTAL < 100.
        WA_TIPE-PRSN = PERSEN + ( PERSENTOTAL - 100 ).
        WA_TIPE-MENGE = WA_TIMBANG-MENGE * WA_TIPE-PRSN / 100.
      ELSE.
        WA_TIPE-PRSN = PERSEN.
        WA_TIPE-MENGE = WA_TIMBANG-MENGE * WA_TIPE-PRSN / 100.
      ENDIF.
    ELSE.
      WA_TIPE-PRSN = PERSEN.
      WA_TIPE-MENGE = WA_TIMBANG-MENGE * WA_TIPE-PRSN / 100.
    ENDIF.
    APPEND WA_TIPE TO ITAB_TIPE.
  ENDLOOP.

  LOOP AT ITAB_TIPE.
    PRSNTOTAL = PRSNTOTAL + ITAB_TIPE-PRSN.
  ENDLOOP.

  IF PRSNTOTAL LT 100.
    DESCRIBE TABLE ITAB_TIPE LINES V_INDX.
    PRSNTOTAL2 = 100 - PRSNTOTAL.

    READ TABLE ITAB_TIPE INDEX V_INDX.
    ITAB_TIPE-PRSN = ITAB_TIPE-PRSN + PRSNTOTAL2.

    V_MENGE = PRSNTOTAL2 * IT_TIMBANG-MENGE / 100.
    ITAB_TIPE-MENGE = ITAB_TIPE-MENGE + V_MENGE.

    MODIFY ITAB_TIPE TRANSPORTING PRSN MENGE WHERE ATWRT EQ ITAB_TIPE-ATWRT AND ATWTB EQ ITAB_TIPE-ATWTB.
    CLEAR PRSNTOTAL.
    LOOP AT ITAB_TIPE.
      PRSNTOTAL = PRSNTOTAL + ITAB_TIPE-PRSN.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "F_GETTIPE

*&---------------------------------------------------------------------*
*&      Form  F_GETORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GETORDER.

  DATA : COUNTER TYPE I,
         ZTOTALRR TYPE MSEG-MENGE,
         QTY_TIMBANG TYPE MENGE_D,
         ZMSG TYPE STRING,
         QTYTOTAL TYPE MENGE_D,
         PERSENTOTAL TYPE PROZT,
         COUNT TYPE I.
  REFRESH : ITAB_ORDER.

  COUNTER = 1.
  "Copy data timbang yg ditemukan ke itab order
  ITAB_ORDER[] = ITAB_TIMBANG[].

  "Urutkan itab order berdasarkan film & quantity ascending
  IF V_GRCOAT = 'X'. "ADDED BY FATHIR ON 12.11.2020 - case pembebanan GR JR Coating - TRDK917760
    SORT ITAB_ORDER[] BY ZZCODE MENGEJR.
  ELSE.
    SORT ITAB_ORDER[] BY ZZCODE MENGE.
  ENDIF.

  "hapus data timbang yang total RR nya melebihi qty timbang
  LOOP AT ITAB_TIPE WHERE MENGE > 0.
    CLEAR ZTOTALRR.

    ZTOTALRR = ITAB_TIPE-MENGE.

    LOOP AT ITAB_ORDER WHERE ZZCODE = ITAB_TIPE-ATWRT AND MATNR = ITAB_TIPE-MATNR.  "CHANGED BY FATHIR ON 12.11.2020 - tambah kondisi by MATNR (RR) - TRDK917760
      IF ZTOTALRR < 0.
        IF V_GRCOAT = 'X'.
          DELETE ITAB_ORDER WHERE CHARGJR = ITAB_ORDER-CHARGJR.
        ELSE.
          DELETE ITAB_ORDER WHERE MBLNR = ITAB_ORDER-MBLNR.
        ENDIF.
      ELSE.
        IF V_GRCOAT = 'X'.
          ZTOTALRR = ZTOTALRR - ITAB_ORDER-MENGEJR.
        ELSE.
          ZTOTALRR = ZTOTALRR - ITAB_ORDER-MENGE.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT ITAB_ORDER BY ZLINE ZZTYPE.

  LOOP AT ITAB_TIPE WHERE MENGE > 0.

    CLEAR: ZTOTALRR.

    LOOP AT ITAB_ORDER WHERE ZZCODE = ITAB_TIPE-ATWRT AND MATNR = ITAB_TIPE-MATNR.  "CHANGED BY FATHIR ON 12.11.2020 - tambah kondisi by MATNR (RR) - TRDK917760

      IF V_GRCOAT = 'X'.
        ZTOTALRR = ZTOTALRR + ITAB_ORDER-MENGEJR.
      ELSE.
        ZTOTALRR = ZTOTALRR + ITAB_ORDER-MENGE.
      ENDIF.

    ENDLOOP.

    LOOP AT ITAB_ORDER WHERE ZZCODE = ITAB_TIPE-ATWRT AND MATNR = ITAB_TIPE-MATNR.    "CHANGED BY FATHIR ON 12.11.2020 - tambah kondisi by MATNR (RR) - TRDK917760
      WA_DIST-ITEM = COUNTER.
      WA_DIST-MATNR_W = WA_TIMBANG-MATNR.
      WA_DIST-MENGE_W = WA_TIMBANG-MENGE.
      WA_DIST-MBLNR = ITAB_ORDER-MBLNR.
      WA_DIST-ATWRT = ITAB_ORDER-ZZTYPE.
      WA_DIST-MATNR = ITAB_ORDER-MATNRJR.
      WA_DIST-MAKTX = ITAB_ORDER-MAKTXJR.
      WA_DIST-AUFNR = ITAB_ORDER-AUFNR.
      WA_DIST-CHARG = ITAB_ORDER-CHARGJR.
      WA_DIST-MEINS = ITAB_ORDER-MEINS.
      WA_DIST-ZLINE = ITAB_ORDER-ZLINE.
      WA_DIST-BKTXT = ITAB_ORDER-BKTXT.
      WA_DIST-MATNR_RR = ITAB_TIPE-MATNR.
      WA_DIST-MENGEJR = ITAB_ORDER-MENGEJR.

      IF V_GRCOAT = 'X'.  "ADDED BY FATHIR ON 12.11.2020 - case pembebanan GR JR Coating - TRDK917760
        READ TABLE ITAB_JR WITH KEY MBLNR = ITAB_ORDER-MBLNR.
        IF SY-SUBRC = 0.
          WA_DIST-LGORT = ITAB_JR-LGORT.
        ELSE.
          WA_DIST-LGORT = S_SLOCA.
        ENDIF.

        WA_DIST-BWART = '101'.
        WA_DIST-MENGA = ITAB_ORDER-MENGEJR / ZTOTALRR * ITAB_TIPE-MENGE.
      ELSE.
        WA_DIST-MENGE = ITAB_ORDER-MENGE.
        WA_DIST-BWART = ITAB_ORDER-BWART.
        WA_DIST-LGORT = ITAB_ORDER-LGORT.
        WA_DIST-MENGA = ITAB_ORDER-MENGE / ZTOTALRR * ITAB_TIPE-MENGE.
      ENDIF.

      WA_DIST-PRSN = WA_DIST-MENGA / WA_TIMBANG-MENGE * 100.
      APPEND WA_DIST TO ITAB_DIST.

      COUNTER = COUNTER + 1.
    ENDLOOP.
  ENDLOOP.

*Adjustment Quantity
  LOOP AT ITAB_TIPE ASSIGNING <FS_TIPE> WHERE PRSN > 0.
    QTYTOTAL = 0.
    LOOP AT ITAB_DIST ASSIGNING <FS_DIST> WHERE ATWRT = <FS_TIPE>-ATWTB AND MATNR_RR = <FS_TIPE>-MATNR.  "CHANGED BY FATHIR ON 12.11.2020 - tambah kondisi by MATNR (RR) - TRDK917760
      QTYTOTAL = QTYTOTAL + <FS_DIST>-MENGA.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      IF QTYTOTAL LT <FS_TIPE>-MENGE.
        <FS_DIST>-MENGA = <FS_DIST>-MENGA + ( <FS_TIPE>-MENGE - QTYTOTAL ).
      ELSEIF QTYTOTAL GT <FS_TIPE>-QTYDISP.
        <FS_DIST>-MENGA = <FS_DIST>-MENGA - ( QTYTOTAL - <FS_TIPE>-MENGE ).
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE ITAB_DIST LINES COUNT.
  COUNTER = 1.

  LOOP AT ITAB_DIST ASSIGNING <FS_DIST>.
    PRSNORDTOTAL = PRSNORDTOTAL + <FS_DIST>-PRSN.
    IF COUNTER = COUNT.
      IF PRSNORDTOTAL > 100.
        <FS_DIST>-PRSN = <FS_DIST>-PRSN - ( PRSNORDTOTAL - 100 ).
      ELSEIF PRSNORDTOTAL < 100.
        <FS_DIST>-PRSN  = <FS_DIST>-PRSN + ( 100 - PRSNORDTOTAL ).
      ELSE.
        PRSNORDTOTAL = PRSNORDTOTAL + <FS_DIST>-PRSN.
      ENDIF.
    ENDIF.
    COUNTER = COUNTER + 1.
  ENDLOOP.

  CLEAR PRSNORDTOTAL.
  LOOP AT ITAB_DIST.
    PRSNORDTOTAL = PRSNORDTOTAL + ITAB_DIST-PRSN.
  ENDLOOP.

  CLEAR TOTALRR.
  LOOP AT ITAB_DIST.
    TOTALRR = TOTALRR + ITAB_DIST-MENGA.
  ENDLOOP.

  CLEAR V_MENGE.
  IF TOTALRR > ITAB_DIST-MENGE_W.
    V_MENGE = TOTALRR - ITAB_DIST-MENGE_W.

    DESCRIBE TABLE ITAB_DIST LINES V_LINES.
    READ TABLE ITAB_DIST INDEX V_LINES INTO WA_DIST.
    WA_DIST-MENGA = WA_DIST-MENGA - V_MENGE.
    MODIFY ITAB_DIST FROM WA_DIST TRANSPORTING MENGA WHERE ITEM EQ V_LINES.
  ENDIF.

ENDFORM.                    "F_GETORDER


*&---------------------------------------------------------------------*
*&      Form  F_TESTRUN
*&---------------------------------------------------------------------*
FORM F_TESTRUN .
  CLEAR : IS_TEST_RUN.
  IS_TEST_RUN = 'X'.

  IF IT_TIMBANG[] IS INITIAL.
    MESSAGE 'Tidak ada data.' TYPE 'I'.
  ELSE.
    PERFORM F_EXECUTE.
*    PERFORM F_GETORDERGI CHANGING L_ERRNO.
    IF L_ERRNO = -1.
      MESSAGE 'Data tidak tersedia.' TYPE 'I'.
    ELSE.
      PERFORM F_FIELD_CATALOG.
      PERFORM F_LAYOUT_TIMBANG.
      PERFORM F_LIST_DETAILTIMBANG.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_TESTRUN

*&---------------------------------------------------------------------*
*&      Form  F_EXECUTE
*&---------------------------------------------------------------------*
FORM F_EXECUTE.

  DATA : VMSG LIKE MESSAGE,
         L_ITEM  TYPE ZTLOGTIMBANG-ZITEMLOG.

  CLEAR : L_ITEM.


  LOOP AT IT_TIMBANG.

    PERFORM F_GET_DOC_TIMBANG.

    DATA : LS_SUBRC    TYPE SY-SUBRC.
    CLEAR : GMHEADER, GMITEM, L_ERRNO, MATDOC.
    REFRESH : GMITEM, IT_RET.

    DELETE ITAB_DIST WHERE MENGA IS INITIAL.
    LOOP AT ITAB_DIST.
      L_ITEM = L_ITEM + 1.
      PERFORM F_CREATE_GMVS USING '531' '532'
                           S_PLANT
                           ITAB_DIST-CHARG
                           S_SLOCT
                           S_SLOCA
                           ITAB_DIST-AUFNR
                           S_MATNR
                           ITAB_DIST-MATNR_RR
                           ITAB_DIST-MENGA
                           ITAB_DIST-MBLNR
                           L_ITEM
                           WA_TIMBANG-BAGIAN
                           CHANGING L_ERRNO
                           VMSG.
    ENDLOOP.

    "CALL BAPI
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = GMHEADER
        GOODSMVT_CODE    = '03'
        TESTRUN          = IS_TEST_RUN
      IMPORTING
        MATERIALDOCUMENT = MATDOC
      TABLES
        GOODSMVT_ITEM    = GMITEM
        RETURN           = IT_RET.

    CLEAR L_ERRNO.
    READ TABLE IT_RET WITH KEY TYPE = 'E'.
    IF SY-SUBRC = 0.

      L_ERRNO = -1.
      CLEAR MESSAGE.
      MESSAGE = 'Posting GI Material Timbang Gagal!'.

      LOOP AT ITAB_DIST.
        ITAB_DIST-EMSG     = MESSAGE.
        ITAB_DIST-ETYPE    = 'E'.
        ITAB_DIST-ZSTAT = GCF_E1.
        MODIFY ITAB_DIST.
      ENDLOOP.
    ELSE.
      IF IS_TEST_RUN IS NOT INITIAL.
        LOOP AT ITAB_DIST.
          ITAB_DIST-ZSTAT = GCF_S1.
          MODIFY ITAB_DIST.
        ENDLOOP.
      ENDIF.

      IF MATDOC = '' AND IS_TEST_RUN IS INITIAL.
        MESSAGE = 'Posting GI Material Timbang Gagal!'.
      ELSE.
        CLEAR MESSAGE.
        CONCATENATE 'Posting GI Material Timbang berhasil dengan Material Dokumen' MATDOC INTO MESSAGE SEPARATED BY SPACE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        "MATERIAL DOCUMENT TIMBANG FOR SALE
        CLEAR WA_MATDOC.
        WA_MATDOC-MATDOC = MATDOC.
        APPEND WA_MATDOC TO T_MATDOC.

*--In Transit
        IF IS_TEST_RUN IS INITIAL.
          PERFORM F_INTRANSIT USING '313'
                                    S_PLANT
                                    ITAB_DIST-CHARG
                                    S_SLOCT
                                    S_SLOCA
                                    ITAB_DIST-AUFNR
                                    S_MATNR
                                    ITAB_DIST-MATNR_RR
                                    WA_TIMBANG-MENGE
                                    ITAB_DIST-MBLNR
                                    L_ITEM
                                    WA_TIMBANG-BAGIAN
                           CHANGING L_ERRNO
                                    VMSG.

          "CALL BAPI
          CLEAR MATDOC2.
          CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
            EXPORTING
              GOODSMVT_HEADER  = GMHEADER
              GOODSMVT_CODE    = '04'
              TESTRUN          = IS_TEST_RUN
            IMPORTING
              MATERIALDOCUMENT = MATDOC2
            TABLES
              GOODSMVT_ITEM    = GMITEM
              RETURN           = IT_RET.

          CLEAR L_ERRNO.
          READ TABLE IT_RET WITH KEY TYPE = 'E'.
          IF SY-SUBRC = 0.
            L_ERRNO = -1.
            CLEAR MESSAGE.
            MESSAGE = 'Transfer Posting In Transit Material Timbang Gagal!'.
          ELSE.
*            CLEAR MESSAGE.
*            MESSAGE = 'Transfer Posting Material Timbang berhasil'.
*            CONCATENATE MESSAGE MATDOC2 INTO MESSAGE SEPARATED BY SPACE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.
          ENDIF.
        ENDIF.
*---In Transit

        CLEAR : L_ITEM.
        IF IS_TEST_RUN IS INITIAL.
          LOOP AT ITAB_DIST.
            L_ITEM = L_ITEM + 1.
            PERFORM F_CREATE_LOGTIMBANG USING '531'
                                        S_PLANT
                                        S_SLOCT
                                        ITAB_DIST-AUFNR
                                        S_MATNR
                                        ITAB_DIST-MBLNR
                                        MATDOC
                                        L_ITEM
                                        IT_TIMBANG-BAGIAN
                                        ITAB_DIST-MENGA.

            PERFORM F_CREATE_LOGTIMBANG USING '532'
                                             S_PLANT
                                             S_SLOCA
                                             ITAB_DIST-AUFNR
                                             ITAB_DIST-MATNR_RR
                                             ITAB_DIST-MBLNR
                                             MATDOC
                                             L_ITEM
                                             IT_TIMBANG-BAGIAN
                                             ITAB_DIST-MENGA.

            VMSG = MESSAGE.

            IF IT_RET[] IS NOT INITIAL.
              LOOP AT IT_RET.
                ITAB_DIST-ETYPE    = IT_RET-TYPE.
                ITAB_DIST-EID      = IT_RET-ID.
                ITAB_DIST-ENUMBER  = IT_RET-NUMBER.
                ITAB_DIST-EMSG     = IT_RET-MESSAGE.
                ITAB_DIST-ZSTAT    = GCF_E1.
              ENDLOOP.

            ELSE.
              ITAB_DIST-EMSG     = VMSG.
              IF VMSG CP '*gagal*'.
                ITAB_DIST-ETYPE    = 'E'.
                ITAB_DIST-ZSTAT = GCF_E1.
              ELSE.
                ITAB_DIST-ZSTAT = GCF_S1.
              ENDIF.

            ENDIF.

            MODIFY ITAB_DIST.
          ENDLOOP.

          READ TABLE ITAB_DIST WITH KEY ETYPE = 'E'.

          IF SY-SUBRC = 0.

          ELSE.
            CLEAR : WA_ORDERF.
            REFRESH IT_ORDERF.
            WA_ORDERF-MATNR = IT_TIMBANG-MATNR.

            SELECT SINGLE  MARA~MEINS MAKT~MAKTX
              INTO (WA_ORDERF-UOM, WA_ORDERF-MAKTX)
              FROM MARA
              JOIN MAKT ON MARA~MATNR = MAKT~MATNR
              WHERE MAKT~MATNR = WA_ORDERF-MATNR.


*            WA_ORDERF-QTY   = IT_TIMBANG-MENGE.    " to be deleted
            WA_ORDERF-QTY   = WA_TIMBANG-MENGE.
            APPEND WA_ORDERF TO IT_ORDERF.
            PERFORM F_PRINT_DATA_TIMBANG.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  CLEAR: ZCB_RR, S_PLINE-LOW.
  REFRESH: S_PLINE.
ENDFORM.                    " F_EXECUTE


*&---------------------------------------------------------------------*
*&      Form  F_GET_DOC_TIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DOC_TIMBANG .
  CLEAR L_DOCNO.

  "GET LAST DOCUMENT TIMBANG
  SELECT MAX( ZTLOGTIMBANG~ZIDLOG )
    INTO L_DOCNO
    FROM ZTLOGTIMBANG.

  IF SY-SUBRC <> 0.
    L_DOCNO = 1.
  ELSE.
    ADD 1 TO L_DOCNO.
  ENDIF.

ENDFORM.                    " F_GET_DOC_TIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_CREATE_LOGTIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MTYPE  text
*      -->P_P_PLANT  text
*      -->P_P_SLOC  text
*      -->P_P_AUFNR  text
*      -->P_P_MATNR  text
*      -->P_MATDOC  text
*      -->P_P_ZPROPORSI  text
*----------------------------------------------------------------------*
FORM F_CREATE_LOGTIMBANG  USING    P_P_MTYPE
                                   P_P_PLANT
                                   P_P_SLOC
                                   P_P_AUFNR
                                   P_P_MATNR
                                   P_P_MBLNR
                                   P_MATDOC
                                   P_P_L_ITEM
                                   P_P_BAGIAN
                                   P_P_ZPROPORSI.

  "GET POSTING DATE NEW MATERIAL DOCUMENT.
  CLEAR : V_BUDAT, V_CPUDT, V_CPUTM.
  SELECT SINGLE MKPF~BUDAT MKPF~CPUDT MKPF~CPUTM
    INTO (V_BUDAT, V_CPUDT, V_CPUTM)
    FROM MKPF
    WHERE MKPF~MBLNR = P_MATDOC.

  CLEAR WA_LOG_TIMBANG.
  WA_LOG_TIMBANG-ZIDLOG   = L_DOCNO.
  WA_LOG_TIMBANG-ZITEMLOG = P_P_L_ITEM.
  WA_LOG_TIMBANG-ZOLDMD   = P_P_MBLNR.
  WA_LOG_TIMBANG-ZNEWMD   = P_MATDOC.
  WA_LOG_TIMBANG-ZBWART   = P_P_MTYPE.
  WA_LOG_TIMBANG-ZAUFNR   = P_P_AUFNR.
  WA_LOG_TIMBANG-ZMATNR   = P_P_MATNR.
  WA_LOG_TIMBANG-ZQTY     = P_P_ZPROPORSI.
  WA_LOG_TIMBANG-ZBAGIAN  = P_P_BAGIAN.
  WA_LOG_TIMBANG-ZWERKS   = P_P_PLANT.
  WA_LOG_TIMBANG-ZLGORT   = P_P_SLOC.
  WA_LOG_TIMBANG-ZBUDAT   = V_BUDAT.
  WA_LOG_TIMBANG-ZCPUDT   = V_CPUDT.
  WA_LOG_TIMBANG-ZCPUTM   = V_CPUTM.
  WA_LOG_TIMBANG-ZUSNAM   = S_NIKPR.

  INSERT ZTLOGTIMBANG FROM WA_LOG_TIMBANG.
  COMMIT WORK AND WAIT.

ENDFORM.                    " F_CREATE_LOGTIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_GMVS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3795   text
*      -->P_3796   text
*      -->P_S_PLANT  text
*      -->P_IT_ORDERGI_CHARG  text
*      -->P_S_SLOCA  text
*      -->P_IT_ORDERGI_SLOC  text
*      -->P_IT_ORDERGI_AUFNR  text
*      -->P_IT_ORDERGI_MATNR  text
*      -->P_IT_ORDERGI_ZPROPORSI  text
*      -->P_IT_ORDERGI_MBLNR  text
*      -->P_L_ITEM  text
*      -->P_IT_TIMBANG_BAGIAN  text
*      -->P_IT_TIMBANG_PRCTR  text
*      <--P_L_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CREATE_GMVS  "TABLES PIT_RET STRUCTURE BAPIRET2
                    USING    P_MTYPE1
                             P_MTYPE2
                             P_PLANT
                             P_CHARG
                             P_S_SLOCT
                             P_SLOC
                             P_AUFNR
                             P_S_MATNR
                             P_MATNR
                             P_ZPROPORSI
                             P_MBLNR
                             P_LITEM
                             P_BAGIAN
                    CHANGING P_ERRNO
                      P_MSG.


  "FILL  HEADER DATA
  IF P_ZPROPORSI NE ''.
    GMHEADER-PSTNG_DATE = S_PDATE .
    GMHEADER-DOC_DATE = S_PDATE.
    GMHEADER-REF_DOC_NO = 'TIMBANG SCRAP'.

    SHIFT S_NIKP LEFT DELETING LEADING ''.
    SHIFT S_NIKPR LEFT DELETING LEADING ''.
    CONCATENATE S_NIKP '/' S_NIKPR INTO GMHEADER-HEADER_TXT.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = P_CHARG
      IMPORTING
        OUTPUT = P_CHARG.

    "DATA FOR ITEM WITH MOVM. TYPE 531
    GMITEM-PLANT      = P_PLANT.
    GMITEM-STGE_LOC   = P_S_SLOCT .
    GMITEM-WITHDRAWN  = 'X'.
    GMITEM-MOVE_TYPE  = P_MTYPE1.
    GMITEM-ENTRY_UOM  = 'KG'.
    GMITEM-ORDERID    = P_AUFNR.
    GMITEM-MATERIAL   = P_S_MATNR.
    GMITEM-ENTRY_QNT  = P_ZPROPORSI.
    GMITEM-GR_RCPT    = 'TIMBANG'.
    APPEND GMITEM.

    "DATA FOR ITEM WITH MOVM. TYPE 532
    GMITEM-STGE_LOC   = P_SLOC."P_S_SLOCA.
    GMITEM-WITHDRAWN  = 'X'.
    GMITEM-MOVE_TYPE  = P_MTYPE2.
    GMITEM-ENTRY_UOM  = 'KG'.
    GMITEM-ORDERID    = P_AUFNR.
    GMITEM-MATERIAL   = P_MATNR.
    GMITEM-ENTRY_QNT  = P_ZPROPORSI.
    GMITEM-GR_RCPT    = 'TIMBANG'.
    APPEND GMITEM.
  ENDIF.

ENDFORM.                    " F_CREATE_GMVS

*&---------------------------------------------------------------------*
*&      Form  F_GET_LOG_TIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_LOG_TIMBANG.
  REFRESH ITLOGTIMBANG.

  PERFORM F_DEFINE_AUART.

  IF R_SUM IS NOT INITIAL.
    SELECT MAKTX ZTLOGTIMBANG~MANDT ZIDLOG ZITEMLOG ZOLDMD ZNEWMD ZBWART ZAUFNR ZMATNR ZQTY ZLGORT ZWERKS ZBAGIAN ZBUDAT
           ZCPUDT ZCPUTM ZUSNAM ZLINE
        FROM ZTLOGTIMBANG
            JOIN AUFK ON ZTLOGTIMBANG~ZAUFNR = AUFK~AUFNR
            JOIN MAKT ON ZTLOGTIMBANG~ZMATNR = MAKT~MATNR
        INTO CORRESPONDING FIELDS OF TABLE ITLOGTIMBANG
        WHERE ZNEWMD       IN L_MBLNR
              AND ZBUDAT   IN L_BUDAT
              AND ZUSNAM   IN L_NIK
              AND ZBWART = '531'
              AND ZWERKS   IN L_WERKS.

    " Lengkapi ProdLine pada data Log Maintenance
    PERFORM F_GETLOGSUMMARY.
    SORT ITLOGTIMBANG DESCENDING BY ZNEWMD.

  ELSEIF R_DET IS NOT INITIAL.
    SELECT MAKTX ZTLOGTIMBANG~MANDT ZIDLOG ZITEMLOG ZOLDMD ZNEWMD ZBWART ZAUFNR ZMATNR ZQTY ZLGORT ZWERKS ZBAGIAN ZBUDAT
           ZCPUDT ZCPUTM ZUSNAM ZLINE
        FROM ZTLOGTIMBANG
            JOIN AUFK ON ZTLOGTIMBANG~ZAUFNR = AUFK~AUFNR
            JOIN MAKT ON ZTLOGTIMBANG~ZMATNR = MAKT~MATNR
        INTO CORRESPONDING FIELDS OF TABLE ITLOGTIMBANG
        WHERE ZNEWMD       IN L_MBLNR
              AND ZBUDAT   IN L_BUDAT
              AND ZUSNAM   IN L_NIK
              AND ZWERKS   IN L_WERKS.

    " Lengkapi ProdLine pada data Log Maintenance
    PERFORM F_GETLOGDETAIL.
    SORT ITLOGTIMBANG BY ZIDLOG DESCENDING ZITEMLOG DESCENDING ZNEWMD DESCENDING.
  ENDIF.

ENDFORM.                    " F_GET_LOG_TIMBANG

*&---------------------------------------------------------------------*
*       ADDED BY FATHIR ON 17.06.2020
*       Set flag untuk skip proses pencarian Prodline
*----------------------------------------------------------------------*
*      -->P_AUFNR    text
*      -->P_BWART    text
*      -->P_ISSKIP   text
*----------------------------------------------------------------------*
FORM F_SKIP_GETPRODLINE USING P_AUFNR TYPE AUFK-AUFNR
                              P_BWART TYPE MSEG-BWART
                        CHANGING P_ISSKIP TYPE C.

  DATA: V_AUART LIKE AUFK-AUART.

  " get order type by AUFNR
  SELECT AUART INTO V_AUART
    UP TO 1 ROWS
    FROM AUFK
    WHERE AUFNR = P_AUFNR.
  ENDSELECT.

  READ TABLE R_AUART WITH KEY LOW = V_AUART.
  IF SY-SUBRC = 0.
    IF P_BWART = '261'.
      P_ISSKIP = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    "F_SKIP_GETPRODLINE

*&---------------------------------------------------------------------*
*&      Form  F_GETJR
*&---------------------------------------------------------------------*
*       ADDED ON 20.01.2021 - tuning get Log Timbang
*       Get data JR
*----------------------------------------------------------------------*
*      -->TYLTIMBANG text
*----------------------------------------------------------------------*
FORM F_GETJR TABLES TYLTIMBANG.

  DATA: TEMPLOGTIMBANG TYPE TABLE OF TYLTIMBANG WITH HEADER LINE.
  DATA: IT_MBRR2 TYPE TABLE OF TY_MATDOCRR WITH HEADER LINE.
  DATA: V_MBLNR LIKE MKPF-MBLNR.

  REFRESH: IT_MBRR, IT_MBRR2, TEMPLOGTIMBANG.

  " get Matdoc RR untuk setiap Matdoc Timbang
  TEMPLOGTIMBANG[] = TYLTIMBANG[].
  LOOP AT TEMPLOGTIMBANG.
    IT_MBRR-MBLNR_RR = TEMPLOGTIMBANG-ZOLDMD.
    APPEND IT_MBRR.
  ENDLOOP.

  SORT IT_MBRR BY MBLNR_RR ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IT_MBRR COMPARING MBLNR_RR. "ADDED ON 20.01.2021 - tuning get Log Timbang
  CHECK IT_MBRR[] IS NOT INITIAL.

  " get DocHeaderText dari Matdoc RR
  SELECT MBLNR BKTXT
    INTO (V_MBLNR, IT_MBRR-BKTXT)
    FROM MKPF
    FOR ALL ENTRIES IN IT_MBRR
    WHERE MBLNR = IT_MBRR-MBLNR_RR.

    MODIFY IT_MBRR TRANSPORTING BKTXT WHERE MBLNR_RR = V_MBLNR.

  ENDSELECT.

  IT_MBRR2[] = IT_MBRR[].

  SORT IT_MBRR BY MBLNR_RR BKTXT ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IT_MBRR COMPARING MBLNR_RR BKTXT.

  SORT IT_MBRR BY BKTXT DESCENDING.
  SORT IT_MBRR2 BY BKTXT ASCENDING.

  DELETE IT_MBRR WHERE BKTXT = ''.
  DELETE IT_MBRR2 WHERE BKTXT <> ''.

  " get data roll berdasarkan nomor roll (doc header text)
  REFRESH: ITAB_JR.
  IF IT_MBRR[] IS NOT INITIAL.  " Matdoc RR yang ada BKTXT
    SELECT MSEG~MBLNR
         MSEG~ZEILE
         MSEG~MATNR
         MSEG~BWART
         MSEG~WERKS
         MSEG~LGORT
         MSEG~CHARG
         MSEG~MENGE
         MSEG~AUFNR
         MKPF~BKTXT
         MKPF~BUDAT
         MSEG~SMBLN
         MSEG~SMBLP
         MSEG~AUFNR
    APPENDING CORRESPONDING FIELDS OF TABLE ITAB_JR
    FROM MSEG
    JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
    FOR ALL ENTRIES IN IT_MBRR
    WHERE MSEG~BWART IN ('101','102','261','262')
      AND MSEG~CHARG <> ''
      AND MKPF~BKTXT = IT_MBRR-BKTXT.
  ENDIF.

  IF IT_MBRR2[] IS NOT INITIAL. " Matdoc RR tanpa BKTXT

    SELECT MBLNR MSEG~AUFNR " get order by Matdoc RR
      INTO (V_MBLNR, IT_MBRR2-AUFNR)
      FROM MSEG
      FOR ALL ENTRIES IN IT_MBRR2
      WHERE MBLNR = IT_MBRR2-MBLNR_RR.

      MODIFY IT_MBRR2 TRANSPORTING AUFNR WHERE MBLNR_RR = V_MBLNR.

    ENDSELECT.

    SELECT MSEG~MBLNR
         MSEG~ZEILE
         MSEG~MATNR
         MSEG~BWART
         MSEG~WERKS
         MSEG~LGORT
         MSEG~CHARG
         MSEG~MENGE
         MSEG~AUFNR
         MKPF~BKTXT
         MKPF~BUDAT
         MSEG~SMBLN
         MSEG~SMBLP
         MSEG~AUFNR
      APPENDING CORRESPONDING FIELDS OF TABLE ITAB_JR
      FROM MSEG
      JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
      FOR ALL ENTRIES IN IT_MBRR2
      WHERE MSEG~BWART IN ('261','262')
        AND MSEG~CHARG <> ''
        AND MSEG~AUFNR = IT_MBRR2-AUFNR.

  ENDIF.

  " hapus matdoc GR yang sudah cancel
  SORT ITAB_JR BY BWART DESCENDING.
  LOOP AT ITAB_JR WHERE BWART = '102' AND SMBLN <> ''.
    DELETE ITAB_JR WHERE MBLNR = ITAB_JR-SMBLN AND ZEILE = ITAB_JR-SMBLP.
  ENDLOOP.
  DELETE ITAB_JR WHERE BWART = '102' AND SMBLN <> ''.

  " hapus matdoc GI yang sudah cancel
  SORT ITAB_JR BY BWART DESCENDING.
  LOOP AT ITAB_JR WHERE BWART = '262' AND SMBLN <> ''.
    DELETE ITAB_JR WHERE MBLNR = ITAB_JR-SMBLN AND ZEILE = ITAB_JR-SMBLP.
  ENDLOOP.
  DELETE ITAB_JR WHERE BWART = '262' AND SMBLN <> ''.
  SORT ITAB_JR BY AUFNR ASCENDING.

ENDFORM.                    "F_GETJR

*&---------------------------------------------------------------------*
*&      Form  F_GETLOGSUMMARY
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR ON 25.04.2020
*       Get data Prodline dari PO Kupas untuk Log Maintenance Summary
*----------------------------------------------------------------------*
FORM F_GETLOGSUMMARY.
  RANGES: R_ZAUFNR FOR ZTLOGTIMBANG-ZAUFNR.
  DATA: TEMPLOGTIMBANG TYPE TABLE OF TYLTIMBANG WITH HEADER LINE,
        TEMPLOGTIMBANG2 TYPE TABLE OF TYLTIMBANG WITH HEADER LINE.
  DATA: ZZPRODLINE TYPE AUSP-ATWRT,
        V_FLAGLINE TYPE AUSP-ATWRT,
        V_CONLINE TYPE AUSP-ATWRT,
        V_ZAUFNR TYPE ZTLOGTIMBANG-ZAUFNR,
        V_ZNEWMD TYPE ZTLOGTIMBANG-ZNEWMD,
        V_ISSKIP(1) TYPE C.

  REFRESH: R_MBLNR, R_BKTXT, TEMPLOGTIMBANG, IT_MBRR. "ADDED ON 20.01.2021 - tuning get Log Timbang
  CLEAR: TEMPLOGTIMBANG.

  IF ITLOGTIMBANG[] IS NOT INITIAL.

    " get Matdoc RR untuk setiap Matdoc Timbang
    TEMPLOGTIMBANG[] = ITLOGTIMBANG[].

    PERFORM F_GETJR TABLES TEMPLOGTIMBANG.  "ADDED ON 20.01.2021 - tuning get Log Timbang

    CHECK ITAB_JR[] IS NOT INITIAL.

    " copy PRO ke variable ranges
    SORT TEMPLOGTIMBANG BY ZAUFNR ASCENDING.
    LOOP AT TEMPLOGTIMBANG.
      IF TEMPLOGTIMBANG-ZAUFNR = V_ZAUFNR.
        CONTINUE.
      ENDIF.
      V_ZAUFNR = TEMPLOGTIMBANG-ZAUFNR.
      R_ZAUFNR-LOW = TEMPLOGTIMBANG-ZAUFNR.
      R_ZAUFNR-SIGN = 'I'.
      R_ZAUFNR-OPTION = 'EQ'.
      APPEND R_ZAUFNR.
    ENDLOOP.

    " hapus roll yang tidak diperlukan (berdasarkan PRO)
    SORT ITAB_JR BY AUFNR ASCENDING.
    DELETE ITAB_JR WHERE AUFNR NOT IN R_ZAUFNR.

    " get ProdLine untuk setiap batch yang ditemukan
    CLEAR: V_ZAUFNR.
    SORT TEMPLOGTIMBANG BY ZAUFNR ZNEWMD ASCENDING.
    LOOP AT TEMPLOGTIMBANG.
      " jika PRO sama dengan iterasi sebelumnya / Prodline sudah terisi,
      " maka continue
      IF V_ZAUFNR = TEMPLOGTIMBANG-ZAUFNR OR TEMPLOGTIMBANG-ZLINE <> ''.
        CONTINUE.
      ENDIF.
      V_ZAUFNR = TEMPLOGTIMBANG-ZAUFNR.

      " get ProdLine setiap batch
      CLEAR: V_CONLINE, V_FLAGLINE.    " clear temp ProdLine untuk setiap di setiap iterasi
      SORT ITAB_JR BY AUFNR BWART ASCENDING.
      LOOP AT ITAB_JR WHERE AUFNR = TEMPLOGTIMBANG-ZAUFNR.

        " skip loop, jika BWART = 261 dan Order Non-kupas
        CLEAR: V_ISSKIP.
        PERFORM F_SKIP_GETPRODLINE USING ITAB_JR-AUFNR
                                         ITAB_JR-BWART
                                   CHANGING V_ISSKIP.
        IF V_ISSKIP = 'X'.
          CONTINUE.
        ENDIF.

        SELECT SINGLE AUSP~ATWRT
          INTO ZZPRODLINE
          FROM AUSP
          JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
          JOIN CABN ON CABN~ATINN = AUSP~ATINN
          WHERE MCH1~CHARG = ITAB_JR-CHARG
            AND CABN~ATNAM = 'ZZPRODLINE'.

        CONDENSE V_CONLINE.
        TEMPLOGTIMBANG-ZLINE = ZZPRODLINE.

        MODIFY TEMPLOGTIMBANG
          TRANSPORTING ZLINE
          WHERE ZAUFNR = TEMPLOGTIMBANG-ZAUFNR.

      ENDLOOP.
    ENDLOOP.

    CHECK TEMPLOGTIMBANG[] IS NOT INITIAL.
    " filter ProdLine berdasarkan input Selection Screen
    IF L_LINE[] IS NOT INITIAL.
      SORT TEMPLOGTIMBANG BY ZLINE ASCENDING.
      DELETE TEMPLOGTIMBANG WHERE ZLINE NOT IN L_LINE.
    ENDIF.

    " concat ProdLine jika diperlukan
    TEMPLOGTIMBANG2[] = TEMPLOGTIMBANG[].
    CLEAR: WALOGTIMBANG.
    SORT TEMPLOGTIMBANG BY ZNEWMD ZLINE ASCENDING.
    LOOP AT TEMPLOGTIMBANG.
      IF TEMPLOGTIMBANG-ZNEWMD <> V_ZNEWMD.
        CLEAR: V_FLAGLINE, V_CONLINE.
      ENDIF.
      V_ZNEWMD = TEMPLOGTIMBANG-ZNEWMD.

      IF V_FLAGLINE = TEMPLOGTIMBANG-ZLINE.
        CONTINUE.
      ENDIF.

      V_FLAGLINE = TEMPLOGTIMBANG-ZLINE.

      IF V_FLAGLINE CO V_CONLINE.
      ELSE.
        IF V_CONLINE IS INITIAL.
          V_CONLINE = V_FLAGLINE.
        ELSE.
          CONCATENATE V_CONLINE V_FLAGLINE INTO V_CONLINE SEPARATED BY ', '.
        ENDIF.
      ENDIF.

      WALOGTIMBANG-ZLINE = V_CONLINE.
      MODIFY TEMPLOGTIMBANG2 FROM WALOGTIMBANG TRANSPORTING ZLINE
      WHERE ZNEWMD = TEMPLOGTIMBANG-ZNEWMD.

    ENDLOOP.

    " isi ProdLine pada tabel Log Timbang
    TEMPLOGTIMBANG[] = TEMPLOGTIMBANG2[].
    REFRESH: ITLOGTIMBANG.
    CLEAR: WALOGTIMBANG, TEMPLOGTIMBANG.
    LOOP AT TEMPLOGTIMBANG.
      WALOGTIMBANG-ZBUDAT = TEMPLOGTIMBANG-ZBUDAT.
      WALOGTIMBANG-ZCPUDT = TEMPLOGTIMBANG-ZCPUDT.
      WALOGTIMBANG-ZCPUTM = TEMPLOGTIMBANG-ZCPUTM.
      WALOGTIMBANG-ZLINE = TEMPLOGTIMBANG-ZLINE.
      WALOGTIMBANG-ZUSNAM = TEMPLOGTIMBANG-ZUSNAM.
      WALOGTIMBANG-ZNEWMD = TEMPLOGTIMBANG-ZNEWMD.
      WALOGTIMBANG-ZMATNR = TEMPLOGTIMBANG-ZMATNR.
      WALOGTIMBANG-MAKTX = TEMPLOGTIMBANG-MAKTX.
      WALOGTIMBANG-ZWERKS = TEMPLOGTIMBANG-ZWERKS.
      WALOGTIMBANG-ZBAGIAN = TEMPLOGTIMBANG-ZBAGIAN.
      WALOGTIMBANG-ZQTY = TEMPLOGTIMBANG-ZQTY.

      COLLECT WALOGTIMBANG INTO ITLOGTIMBANG.
    ENDLOOP.

  ENDIF.
ENDFORM.                    "F_GETLOGSUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_GETLOGDETAIL
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR ON 27.04.2020
*       Get data Prodline dari PO Kupas untuk Log Maintenance Detail
*----------------------------------------------------------------------*
FORM F_GETLOGDETAIL.
  RANGES: R_ZAUFNR FOR ZTLOGTIMBANG-ZAUFNR.
  DATA: TEMPLOGTIMBANG TYPE TABLE OF TYLTIMBANG WITH HEADER LINE,
        TEMPLOGTIMBANG2 TYPE TABLE OF TYLTIMBANG WITH HEADER LINE.
  DATA: ZZPRODLINE TYPE AUSP-ATWRT,
        V_FLAGLINE TYPE AUSP-ATWRT,
        V_CONLINE TYPE AUSP-ATWRT,
        V_ZAUFNR TYPE ZTLOGTIMBANG-ZAUFNR,
        V_ZNEWMD TYPE ZTLOGTIMBANG-ZNEWMD.

  REFRESH: R_MBLNR, R_BKTXT, TEMPLOGTIMBANG.
  CLEAR: TEMPLOGTIMBANG.

  IF ITLOGTIMBANG[] IS NOT INITIAL.
    " get Matdoc RR untuk setiap Matdoc Timbang
    TEMPLOGTIMBANG[] = ITLOGTIMBANG[].
    " hapus data yang sudah ada ProdLine-nya
    DELETE TEMPLOGTIMBANG WHERE ZLINE <> ''.

    " get data JR
    PERFORM F_GETJR TABLES TEMPLOGTIMBANG.  "ADDED ON 20.01.2021 - tuning get Log Timbang

    CHECK ITAB_JR[] IS NOT INITIAL.

    " copy PRO ke variable ranges
    SORT TEMPLOGTIMBANG BY ZAUFNR ASCENDING.
    LOOP AT TEMPLOGTIMBANG.
      IF TEMPLOGTIMBANG-ZAUFNR = V_ZAUFNR.
        CONTINUE.
      ENDIF.
      V_ZAUFNR = TEMPLOGTIMBANG-ZAUFNR.
      R_ZAUFNR-LOW = TEMPLOGTIMBANG-ZAUFNR.
      R_ZAUFNR-SIGN = 'I'.
      R_ZAUFNR-OPTION = 'EQ'.
      APPEND R_ZAUFNR.
    ENDLOOP.

    " hapus roll yang tidak diperlukan (berdasarkan PRO)
    DELETE ITAB_JR WHERE AUFNR NOT IN R_ZAUFNR.

    " get ProdLine untuk setiap batch yang ditemukan
    CLEAR: V_ZAUFNR.
    SORT TEMPLOGTIMBANG BY ZNEWMD ZAUFNR ASCENDING.
    LOOP AT TEMPLOGTIMBANG.
      " jika PRO sama dengan iterasi sebelumnya / Prodline sudah terisi,
      " maka continue
      IF V_ZAUFNR = TEMPLOGTIMBANG-ZAUFNR OR TEMPLOGTIMBANG-ZLINE NE ''.
        CONTINUE.
      ENDIF.
      V_ZAUFNR = TEMPLOGTIMBANG-ZAUFNR.

      " get ProdLine setiap batch
      CLEAR: V_CONLINE, V_FLAGLINE.    " clear temp ProdLine untuk setiap di setiap iterasi
      SORT ITAB_JR BY AUFNR BWART ASCENDING.
      LOOP AT ITAB_JR WHERE AUFNR = TEMPLOGTIMBANG-ZAUFNR.

        SELECT SINGLE AUSP~ATWRT
          INTO ZZPRODLINE
          FROM AUSP
          JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
          JOIN CABN ON CABN~ATINN = AUSP~ATINN
          WHERE MCH1~CHARG = ITAB_JR-CHARG
            AND CABN~ATNAM = 'ZZPRODLINE'.

        CONDENSE V_CONLINE.
        TEMPLOGTIMBANG-ZLINE = ZZPRODLINE.

        MODIFY TEMPLOGTIMBANG
          TRANSPORTING ZLINE
          WHERE ZAUFNR = TEMPLOGTIMBANG-ZAUFNR.

      ENDLOOP.
    ENDLOOP.

    CHECK TEMPLOGTIMBANG[] IS NOT INITIAL.

    " isi ProdLine pada tabel Log Timbang
    CLEAR: WALOGTIMBANG.
    LOOP AT TEMPLOGTIMBANG.
      WALOGTIMBANG-ZLINE = TEMPLOGTIMBANG-ZLINE.
      MODIFY ITLOGTIMBANG FROM WALOGTIMBANG TRANSPORTING ZLINE
        WHERE ZOLDMD = TEMPLOGTIMBANG-ZOLDMD.
    ENDLOOP.

    " filter ProdLine berdasarkan input Selection Screen
    " taruh buat ITLOGTIMBANG
    IF L_LINE[] IS NOT INITIAL.
      SORT ITLOGTIMBANG BY ZLINE ASCENDING.
      DELETE ITLOGTIMBANG WHERE ZLINE NOT IN L_LINE.
    ENDIF.

  ENDIF.
ENDFORM.                    "F_GETLOGDETAIL

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA_TIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PRINT_DATA_TIMBANG .
  DATA: VCOMPANY(50).
  LOOP AT IT_ORDERF INTO WA_ORDERF.
    EXIT.
  ENDLOOP.

  IF S_PLANT EQ '1000' OR S_PLANT EQ '2000'.
    VCOMPANY = 'PT. TRIAS SENTOSA'.
  ELSEIF S_PLANT EQ 'TTA2'.
    VCOMPANY = 'PT. TRIAS TOYOBO ASTRIA'.
  ELSEIF S_PLANT EQ 'TTE'.
    VCOMPANY = 'PT. TOYOBO TRIAS ECOSYAR'.
  ENDIF.

  CLEAR FM_NAME.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME = 'ZPPF_TIMBANG_SCRAP'
    IMPORTING
      FM_NAME  = FM_NAME.

  CALL FUNCTION FM_NAME
    EXPORTING
      VMATDOC    = MATDOC
      VBUDAT     = V_BUDAT
      VCPUTM     = V_CPUTM
      VNIKP      = S_NIKP "GANTI
      VNIKPR     = S_NIKPR
      VCOMPANY   = VCOMPANY
      IF_TIMBANG = WA_ORDERF
    TABLES
      IT_TIMBANG = IT_ORDERF.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " F_PRINT_DATA_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PRODLINE
*&---------------------------------------------------------------------*
*       Validasi SLoc dan Production Line sesuai dengan tabel
*       ZTMAP_SLOCWASTE
*----------------------------------------------------------------------*
*      -->P_L_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_PRODLINE CHANGING P_L_ERRNO.
  CLEAR: P_L_ERRNO.

  SELECT SINGLE ZRRLGORT
    INTO S_SLOCT
    FROM ZTMAP_SLOCWASTE
    WHERE ZRRLGORT = S_SLOCA
      AND WERKS = S_PLANT
      AND ZLINE IN S_PLINE.

  IF SY-SUBRC <> 0.
    P_L_ERRNO = -1.
    CLEAR MESSAGE.
    MESSAGE = 'SLoc Asal dan Production Line tidak sesuai.'.
    MESSAGE MESSAGE TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.                    "F_CHECK_PRODLINEV

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_REQUIRED
*&---------------------------------------------------------------------*
*       Validasi field required
*----------------------------------------------------------------------*
*      -->P_L_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_REQUIRED CHANGING P_L_ERRNO.
  CLEAR: P_L_ERRNO.

  IF S_PLANT IS INITIAL OR
     S_MATNR IS INITIAL OR
     S_NIKP IS INITIAL OR
     S_NIKPR IS INITIAL.

    P_L_ERRNO = -1.
    MESSAGE 'Pastikan field Plant / Material / NIK Penerima / NIK Pengirim terisi' TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.

ENDFORM.                    "F_CHECK_REQUIRED

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DATE
*&---------------------------------------------------------------------*
*       Validasi start dan end date
*----------------------------------------------------------------------*
*      -->P_L_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_DATE CHANGING P_L_ERRNO.
  CLEAR: P_L_ERRNO.

  " Validasi Start Date > End Date
  IF S_SDATE > S_EDATE.
    P_L_ERRNO = -1.
    MESSAGE 'Start date tidak boleh lebih dari End date' TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.

  " Validasi start date & end date tidak boleh beda bulan
  IF S_SDATE+4(2) <> S_EDATE+4(2).
    P_L_ERRNO = -1.
    MESSAGE 'Start date dan End date tidak boleh beda bulan' TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.

  " Validasi start date & end date tidak boleh bulan lalu
  IF S_PDATE(6) < SY-DATUM(6).
    P_L_ERRNO = -1.
    MESSAGE 'Posting Date tidak boleh beda bulan' TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.

  " Validasi Start / End date tidak boleh beda bulan
  IF S_SDATE(6) < SY-DATUM(6)
    OR S_EDATE(6) < SY-DATUM(6).
    P_L_ERRNO = -1.
    MESSAGE 'Start Date / End Date tidak boleh beda bulan' TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.                    "F_CHECK_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CHECK_NIK CHANGING P_L_ERRNO.
  DATA : VPERNR TYPE PA0001-PERNR.
  CLEAR : VPERNR, P_L_ERRNO.

  "cek nik pengirim.
  SELECT SINGLE PA0001~PERNR
    FROM PA0001
    INTO VPERNR
    WHERE PA0001~PERNR = S_NIKP.

  IF SY-SUBRC <> 0.
    P_L_ERRNO = -1.
    CLEAR MESSAGE.
    MESSAGE =  'NIK Penerima Salah.' .

    CLEAR : VPERNR.
    "cek nik penerima.
    SELECT SINGLE PA0001~PERNR
      FROM PA0001
      INTO VPERNR
      WHERE PA0001~PERNR = S_NIKPR.

    IF SY-SUBRC <> 0.
      CLEAR MESSAGE.
      MESSAGE = 'NIK Pengirim dan NIK Penerima Salah.' .
    ENDIF.
  ELSE.
    CLEAR : VPERNR.
    "cek nik penerima.
    SELECT SINGLE PA0001~PERNR
      FROM PA0001
      INTO VPERNR
      WHERE PA0001~PERNR = S_NIKPR.

    IF SY-SUBRC <> 0.
      P_L_ERRNO = -1.
      CLEAR MESSAGE.
      MESSAGE = 'NIK Pengirim Salah.' .
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_NIK

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_MATERIAL
*&---------------------------------------------------------------------*
FORM F_CHECK_MATERIAL  CHANGING P_L_ERRNO.
  CLEAR : P_L_ERRNO.

  IF S_MATNR = ''.
    MESSAGE 'Isi Material' TYPE 'I' DISPLAY LIKE 'W'.
    P_L_ERRNO = -1.
  ELSE.

    "CEK MATERIAL GROUP
    SELECT SINGLE MARA~MATNR
    INTO V_MATNR
    FROM MARA
    WHERE MARA~MATNR = S_MATNR
    AND MARA~MATKL IN ('B00502','B00504','B00507', 'B00508').

    IF SY-SUBRC <> 0.
      MESSAGE 'Material bukan merupakan FG-Sisa RcycleJual maupun FG-Waste Film Jual' TYPE 'I'.
      P_L_ERRNO = -1.
    ELSE.
      "CEK PLANT
      CLEAR V_MATNR.
      SELECT SINGLE MARD~MATNR
      INTO V_MATNR
      FROM MARD
      WHERE MARD~MATNR = S_MATNR
      AND MARD~WERKS = S_PLANT.

      IF SY-SUBRC <> 0.
        CLEAR VMSG.
        CONCATENATE 'Material tidak berada di Plant' S_PLANT INTO VMSG SEPARATED BY SPACE.
        MESSAGE VMSG TYPE 'I'.
        P_L_ERRNO = -1.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_CEKSTOCKRR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CEKSTOCKRR CHANGING  P_L_ERRNO.

  DATA : TOTALRR TYPE MSEG-MENGE,
         ZMSG TYPE STRING.
  CLEAR: P_L_ERRNO, V_FLAG.
  REFRESH ITAB_STOCKRR.

  SELECT MATNR WERKS LGORT LABST
    INTO CORRESPONDING FIELDS OF TABLE ITAB_STOCKRR
    FROM MARD
    WHERE MATNR IN T_MATNR AND WERKS = S_PLANT AND LGORT = S_SLOCA.

  LOOP AT ITAB_RRTIPE.
    CLEAR TOTALRR.

    LOOP AT ITAB_TIPE WHERE MATNR = ITAB_RRTIPE-MATNR.
      TOTALRR = TOTALRR + ITAB_TIPE-MENGE.
    ENDLOOP.

    READ TABLE ITAB_STOCKRR WITH KEY MATNR = ITAB_RRTIPE-MATNR.

    IF SY-SUBRC = 0.
      IF ITAB_STOCKRR-LABST < TOTALRR.
        CONCATENATE 'Stock Material' ITAB_RRTIPE-MATNR 'tidak mencukupi untuk ditimbang' INTO ZMSG SEPARATED BY SPACE.
        MESSAGE ZMSG TYPE 'I'.
        P_L_ERRNO = -1.
        V_FLAG = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      CONCATENATE 'Stock Material' ITAB_RRTIPE-MATNR 'tidak mencukupi untuk ditimbang' INTO ZMSG SEPARATED BY SPACE.
      MESSAGE ZMSG TYPE 'I'.
      P_L_ERRNO = -1.
      V_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF V_FLAG EQ 'X'.
    LEAVE TO SCREEN 1200.
  ENDIF.
ENDFORM.                    "F_CEKSTOCKRR


*&---------------------------------------------------------------------*
*&      Form  F_DEFINE_AUART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DEFINE_AUART.

  REFRESH R_AUART.
  CLEAR R_AUART.

  R_AUART-LOW = 'ZP01'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP02'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP03'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP04'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP05'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP06'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP07'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP08'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP09'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP10'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP11'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP12'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  " Added by Wiliam at 24.07.2022 (OPP7 CPP1)
  R_AUART-LOW = 'ZP13'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP14'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP15'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP16'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP17'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZP18'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  " End added by Wiliam at 24.07.2022 (OPP7 CPP1)
  R_AUART-LOW = 'ZTR1'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZTR2'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZTR7'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  " Added by Wiliam at 24.07.2022 (OPP7 CPP1)
  R_AUART-LOW = 'ZTR8'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZTR9'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZTRA'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZTRB'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  R_AUART-LOW = 'ZTRC'.  R_AUART-SIGN   = 'I'.  R_AUART-OPTION = 'EQ'. APPEND R_AUART.
  " End added by Wiliam at 24.07.2022 (OPP7 CPP1)

ENDFORM.                    "F_DEFINE_AUART


*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GETDATA_PRINT.
  DATA : V_REF TYPE MKPF-BKTXT.

  CLEAR : WA_ORDERF.
  REFRESH IT_ORDERF.

  SELECT ZTLOGTIMBANG~ZMATNR AS MATNR MAKT~MAKTX SUM( ZTLOGTIMBANG~ZQTY ) AS QTY MARA~MEINS AS UOM
    INTO CORRESPONDING FIELDS OF TABLE IT_ORDERF
    FROM ZTLOGTIMBANG
      JOIN MARA ON ZTLOGTIMBANG~ZMATNR = MARA~MATNR
      JOIN MAKT ON MARA~MATNR = MAKT~MATNR
    WHERE ZNEWMD = P_MBLNR
          AND ZBWART = '531'
          AND MAKT~SPRAS = 'EN'
    GROUP BY ZTLOGTIMBANG~ZMATNR MAKT~MAKTX MARA~MEINS.

  SELECT SINGLE MKPF~MBLNR BUDAT CPUTM BKTXT WERKS
    INTO (MATDOC,V_BUDAT,V_CPUTM, V_REF, S_PLANT)
    FROM MKPF
    JOIN MSEG ON MKPF~MBLNR = MSEG~MBLNR
    WHERE MKPF~MBLNR = P_MBLNR.


  SPLIT V_REF AT '/' INTO S_NIKP S_NIKPR.

  PERFORM F_PRINT_DATA_TIMBANG.
ENDFORM.                    "F_GETDATA_PRINT

*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTH_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_AUTH_PLANT.

  "Cek otorisasi Plant
  SELECT WERKS FROM T001W INTO TABLE IT_T001W WHERE WERKS IN L_WERKS.
  IF SY-SUBRC NE 0.
    MESSAGE 'No Plant found..!' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT IT_T001W.
    AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD IT_T001W-WERKS.
    IF SY-SUBRC NE 0.
      CONCATENATE 'No Authorization for Plant' IT_T001W-WERKS INTO DMESSAGE SEPARATED BY SPACE.
      MESSAGE DMESSAGE TYPE 'I' DISPLAY LIKE 'E'.
      CALL SCREEN 2000.
    ENDIF.
  ENDLOOP.
  "Cek otorisasi Plant

ENDFORM.                    "CHECK_AUTH_PLANT

*&---------------------------------------------------------------------*
*&      Form  INSERT_OLAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_OLAP.
  IF S_CONN IS NOT INITIAL.
    TRY .
      IF R_SUM EQ 'X'.
        EXEC SQL.
          DELETE FROM XPP_TB_SUMM
        ENDEXEC.

        EXEC SQL.
          COMMIT WORK
        ENDEXEC.
      ENDIF.

      IF R_DET EQ 'X'.
        EXEC SQL.
          DELETE FROM XPP_TB_DTL
        ENDEXEC.

        EXEC SQL.
          COMMIT WORK
        ENDEXEC.
      ENDIF.

      CATCH CX_SY_NATIVE_SQL_ERROR.
        MESSAGE `Error in procedure execution delete` TYPE 'I'.
        RETURN.
    ENDTRY.

     TRY .
        IF R_SUM EQ 'X'.
          LOOP AT ITLOGTIMBANG.
            EXEC SQL.
              INSERT INTO XPP_TB_SUMM([Posting Date],[Entered On],[Entered At],[Prod. Line],[NIK],[Mat Doc. Timbang],[Material],[Material Description],[Plant],[Bagian],[Qty. Timbang])
              VALUES(:ITLOGTIMBANG-ZBUDAT, :ITLOGTIMBANG-ZCPUDT, :ITLOGTIMBANG-ZCPUTM,  :ITLOGTIMBANG-ZLINE, :ITLOGTIMBANG-ZUSNAM, :ITLOGTIMBANG-ZNEWMD,
               :ITLOGTIMBANG-ZMATNR, :ITLOGTIMBANG-MAKTX, :ITLOGTIMBANG-ZWERKS,  :ITLOGTIMBANG-ZBAGIAN, :ITLOGTIMBANG-ZQTY)
            ENDEXEC.
          ENDLOOP.

          EXEC SQL.
            COMMIT WORK
          ENDEXEC.

          EXEC SQL.
           EXEC [SP_Merge_ZPP_TB_SUMM]
          ENDEXEC.

          EXEC SQL.
            COMMIT WORK
          ENDEXEC.
        ENDIF.

        IF R_DET EQ 'X'.
             LOOP AT ITLOGTIMBANG.
              EXEC SQL.
                INSERT INTO XPP_TB_DTL([ID Log Timbang],[Item Log Timbang],[Mat Doc. RR],[Mat Doc. Timbang],[Order],[Posting Date],[Entered On],[Entered At],[Prod. Line],[NIK],[Movement Type],[Material],[Material Description],[Plant],[S.Loc],[Bagian],
[Qty. Timbang])
                VALUES(:ITLOGTIMBANG-ZIDLOG, :ITLOGTIMBANG-ZITEMLOG, :ITLOGTIMBANG-ZOLDMD,  :ITLOGTIMBANG-ZNEWMD, :ITLOGTIMBANG-ZAUFNR, :ITLOGTIMBANG-ZBUDAT, :ITLOGTIMBANG-ZCPUDT, :ITLOGTIMBANG-ZCPUTM,
                :ITLOGTIMBANG-ZLINE, :ITLOGTIMBANG-ZUSNAM, :ITLOGTIMBANG-ZBWART,  :ITLOGTIMBANG-ZMATNR, :ITLOGTIMBANG-MAKTX, :ITLOGTIMBANG-ZWERKS, :ITLOGTIMBANG-ZLGORT, :ITLOGTIMBANG-ZBAGIAN, :ITLOGTIMBANG-ZQTY )
              ENDEXEC.
            ENDLOOP.

            EXEC SQL.
              COMMIT WORK
            ENDEXEC.

            EXEC SQL.
             EXEC [SP_Merge_ZPP_TB_DTL]
            ENDEXEC.

            EXEC SQL.
              COMMIT WORK
            ENDEXEC.
        ENDIF.

        MESSAGE 'Data downloaded successfully!' TYPE 'S' DISPLAY LIKE 'I'.

      CATCH CX_SY_NATIVE_SQL_ERROR.
        MESSAGE 'Insert Error' TYPE 'I'.
        RETURN.
    ENDTRY.

  ENDIF.

ENDFORM.                    "INSERT_OLAP

*&---------------------------------------------------------------------*
*&      Form  ZPRODLINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ZPRODLINE.
  DATA : COUNT_LINE TYPE I,
         COUNTER TYPE I.

  COUNTER = 1.
  DESCRIBE TABLE S_PLINE LINES COUNT_LINE.

  LOOP AT S_PLINE.
    IF COUNTER = 1.
      ZPRODLINE = S_PLINE-LOW.
    ELSE.
      CONCATENATE ZPRODLINE S_PLINE-LOW INTO ZPRODLINE SEPARATED BY ','.
    ENDIF.
    COUNTER = COUNTER + 1.
  ENDLOOP.

  IF SY-SUBRC NE 0.
    ZPRODLINE = S_PLINE-LOW.
  ENDIF.

ENDFORM.                    "ZPRODLINE

*&---------------------------------------------------------------------*
*&      Form  F_INTRANSIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MTYPE1     text
*      -->P_PLANT      text
*      -->P_CHARG      text
*      -->P_S_SLOCT    text
*      -->P_SLOC       text
*      -->P_AUFNR      text
*      -->P_S_MATNR    text
*      -->P_MATNR      text
*      -->P_ZPROPORSI  text
*      -->P_MBLNR      text
*      -->P_LITEM      text
*      -->P_BAGIAN     text
*      -->P_ERRNO      text
*      -->P_MSG        text
*----------------------------------------------------------------------*
FORM F_INTRANSIT    USING    P_MTYPE1
                             P_PLANT
                             P_CHARG
                             P_S_SLOCT
                             P_SLOC
                             P_AUFNR
                             P_S_MATNR
                             P_MATNR
                             P_ZPROPORSI
                             P_MBLNR
                             P_LITEM
                             P_BAGIAN
                    CHANGING P_ERRNO
                             P_MSG.

  CLEAR: GMHEADER, GMITEM.
  REFRESH: GMITEM.

  "FILL  HEADER DATA
  GMHEADER-PSTNG_DATE = S_PDATE .
  GMHEADER-DOC_DATE = S_PDATE.
  GMHEADER-REF_DOC_NO = 'TIMBANG SCRAP'.

  SHIFT S_NIKP LEFT DELETING LEADING ''.
  SHIFT S_NIKPR LEFT DELETING LEADING ''.
  CONCATENATE S_NIKP '/' S_NIKPR INTO GMHEADER-HEADER_TXT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_CHARG
    IMPORTING
      OUTPUT = P_CHARG.

  "DATA FOR ITEM WITH MOVM. TYPE 531
  GMITEM-PLANT      = P_PLANT.
  GMITEM-STGE_LOC   = P_S_SLOCT .
  GMITEM-WITHDRAWN  = 'X'.
  GMITEM-MOVE_TYPE  = P_MTYPE1.
  GMITEM-ENTRY_UOM  = 'KG'.
  GMITEM-MATERIAL   = P_S_MATNR.
  GMITEM-ENTRY_QNT  = P_ZPROPORSI.
  GMITEM-GR_RCPT    = 'TIMBANG'.
  APPEND GMITEM.

ENDFORM.                    "F_INTRANSIT

*&---------------------------------------------------------------------*
*&      Form  F_SET_QTY_DISPLAY
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR ON 12.11.2020
*       Ubah data qty yang akan ditampilkan di table result - TRDK917760
*----------------------------------------------------------------------*
*      -->VALUE      text
*      -->(V_ISEXIT) text
*----------------------------------------------------------------------*
FORM F_SET_QTY_DISPLAY USING VALUE(V_ISEXIT) TYPE C.

  IF V_GRCOAT = 'X'.  " ubah hanya untuk case pembebanan Coating 101

    CASE V_ISEXIT.
      WHEN ''.
        LOOP AT ITAB_DIST.
          ITAB_DIST-MENGE = ITAB_DIST-MENGEJR.
          MODIFY ITAB_DIST.
        ENDLOOP.

      WHEN 'X'.
        LOOP AT ITAB_DIST.
          ITAB_DIST-MENGE = 0.
          MODIFY ITAB_DIST.
        ENDLOOP.
    ENDCASE.

  ENDIF.

ENDFORM.                    "F_SET_QTY_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  CONNECT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONNECT_SQL .
  DATA: CON_NAME        LIKE DBCON-CON_NAME,
        O_CX TYPE REF TO CX_ROOT,
        V_CX_MSG(500).

  IF S_CONN IS INITIAL.
    MESSAGE 'Enter DBCO Connection name...!' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  SELECT SINGLE CON_NAME
    INTO CON_NAME
    FROM DBCON
   WHERE CON_NAME = S_CONN.
  IF SY-SUBRC NE 0.
    CONCATENATE 'Connection' S_CONN 'not found!' INTO V_CX_MSG SEPARATED BY SPACE.
    MESSAGE V_CX_MSG TYPE 'I'.
    STOP.
  ELSE.
  ENDIF.

  CLEAR: V_CX_MSG.
  TRY.
      EXEC SQL.
        SET CONNECTION :S_CONN
      ENDEXEC.

      EXEC SQL.
        CONNECT TO :S_CONN
      ENDEXEC.

    CATCH CX_ROOT INTO O_CX.
      V_CX_MSG = O_CX->GET_TEXT( ).

      IF V_CX_MSG EQ 'Error creating a secondary database connection'.
        V_CX_MSG = 'Please use SAP Windows server'.
      ENDIF.

      CONCATENATE 'Cannot establish the SQL connection: ' V_CX_MSG INTO V_CX_MSG SEPARATED BY SPACE.
      MESSAGE V_CX_MSG TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
  ENDTRY.
ENDFORM.                    " CONNECT_SQL