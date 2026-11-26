*&---------------------------------------------------------------------*
*&  Include           ZPPI_UP_REV_PR_JR_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD .
  DATA : FNAME TYPE STRING.
  " UPLOAD EXCEL
**  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
**    EXPORTING
**      FILENAME                = P_FILE
**      I_BEGIN_COL             = 1
**      I_BEGIN_ROW             = 1
**      I_END_COL               = P_COLUMN
**      I_END_ROW               = P_ROW
**    TABLES
**      INTERN                  = T_EXCEL_TAB
**    EXCEPTIONS
**      INCONSISTENT_PARAMETERS = 1
**      UPLOAD_OLE              = 2
**      OTHERS                  = 3.
**
**  IF SY-SUBRC <> 0.
**    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**  ELSE.
**    PERFORM INSERT_ITAB.
**  ENDIF.
  MOVE P_FILE TO FNAME.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB.
  IF SY-SUBRC <> 0.
    MESSAGE W000(0K) WITH 'Upload Error'.
  ELSE.
    DELETE ITAB INDEX 1.
  ENDIF.

  CLEAR: ZVTENTRIES.
  REFRESH: ZVTENTRIES.

  CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
    EXPORTING
      VAR_TABLE       = 'ZZCODE'
    TABLES
      VAR_TAB_ENTRIES = ZVTENTRIES.

  IF SY-SUBRC <> 0.

  ENDIF.

  PERFORM GET_MAPPING.
  PERFORM VALIDASI.
ENDFORM.                    " UPLOAD

*&---------------------------------------------------------------------*
*&      Form  VALIDASI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALIDASI.
  DATA: GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
        GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
        LS_SELFIELD TYPE SLIS_SELFIELD,
        IT_EXCLUDING TYPE SLIS_T_EXTAB WITH HEADER LINE,
        V_INDEX TYPE I,
        V_INDEX2 TYPE I,

        IT_T001W LIKE T001W OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF IT_WARNING OCCURS 0,
        MESS           TYPE CHAR255,
        TYPE           TYPE ATWRT,
        END OF IT_WARNING.

  DATA: V_PLANT_PATTERN TYPE STRING,
        V_HAS_SPECIAL   TYPE C,
        V_REQ_TCODE     TYPE TSTC-TCODE.

  DATA: BEGIN OF IT_TSTCT OCCURS 0,
          TCODE TYPE TSTCT-TCODE,
          TTEXT TYPE TSTCT-TTEXT,
        END OF IT_TSTCT.

* Ambil semua text t-code dari program ini untuk mencari tahu
* mana saja plant yang "Spesial" secara otomatis (tanpa hardcode)
  SELECT TCODE TTEXT
    INTO CORRESPONDING FIELDS OF TABLE IT_TSTCT
    FROM TSTCT
   WHERE TCODE LIKE 'Z%PP%002'
     AND SPRSL = SY-LANGU.

*--------------------------------------------------------------------*
* 2. Loop Data & Eksekusi Logika Validasi
*--------------------------------------------------------------------*
* DEKLARASIKAN 1 VARIABEL TAMBAHAN UNTUK PENCARIAN
  DATA: V_SEARCH_PLANT TYPE STRING.

  LOOP AT ITAB.
    CLEAR: V_HAS_SPECIAL, V_REQ_TCODE, V_MSG, V_SEARCH_PLANT.

    " 1. Pindahkan isi plant ke variabel penampung pencarian
    V_SEARCH_PLANT = ITAB-PLANT.

    " 2. HANDLE KASUS SPESIAL TTA2 -> TTA
    IF V_SEARCH_PLANT = 'TTA2'.
      V_SEARCH_PLANT = 'TTA'.
    ENDIF.

    " 3. Buat pola pencarian menggunakan V_SEARCH_PLANT (bukan ITAB-PLANT lagi)
    " Hasilnya akan menjadi '(TTA)' meskipun plant aslinya 'TTA2'
    CONCATENATE '(' V_SEARCH_PLANT ')' INTO V_PLANT_PATTERN.

    " CEK 1: Apakah Plant sesuai dengan T-Code yang SEDANG JALAN (V_TTEXT)?
    IF V_TTEXT CS V_PLANT_PATTERN.
      CONTINUE.
    ENDIF.

    " CEK 2: Cari T-Code apa yang SEHARUSNYA dipakai oleh Plant ini
    LOOP AT IT_TSTCT.
      IF IT_TSTCT-TTEXT CS V_PLANT_PATTERN.
        V_HAS_SPECIAL = 'X'.
        V_REQ_TCODE   = IT_TSTCT-TCODE.
        EXIT.
      ENDIF.
    ENDLOOP.

    " CEK 3: Eksekusi Error / Lolos
    IF V_HAS_SPECIAL = 'X'.
      " Pesan error tetap memunculkan nama plant aslinya (TTA2)
      V_MSG = |Untuk plant { ITAB-PLANT } ya harus menggunakan tcode { V_REQ_TCODE }!|.
      MESSAGE V_MSG TYPE 'E'.
    ENDIF.

  ENDLOOP.

  IF IT_TREATMENT[] IS INITIAL.
    EXIT.
  ENDIF.

  LOOP AT ITAB.
    READ TABLE IT_TREATMENT WITH KEY TEXT1 = ITAB-TIPEFILM.
    IF SY-SUBRC EQ 0.
      READ TABLE IT_TREATMENT WITH KEY TEXT1 = ITAB-TIPEFILM TEXT2 = ITAB-TREATMENT.
      IF SY-SUBRC NE 0.
        MOVE-CORRESPONDING ITAB TO W_REPORT.
        IT_WARNING-MESS    = IT_TREATMENT-TEXT5.
        IT_WARNING-TYPE    = ITAB-TIPEFILM.

        REPLACE FIRST OCCURRENCE OF '&' IN IT_WARNING-MESS WITH ITAB-TREATMENT.
        REPLACE FIRST OCCURRENCE OF '&' IN IT_WARNING-MESS WITH IT_TREATMENT-TEXT2.

        APPEND IT_WARNING.
        CLEAR IT_WARNING.
      ENDIF.
    ELSE.
      IT_WARNING-MESS    = 'Mapping treatment not found!'.
      IT_WARNING-TYPE    = ITAB-TIPEFILM.

      APPEND IT_WARNING.
      CLEAR IT_WARNING.
    ENDIF.
  ENDLOOP.

  SORT IT_WARNING BY TYPE.
  DELETE ADJACENT DUPLICATES FROM IT_WARNING COMPARING TYPE.

  IF IT_WARNING[] IS NOT INITIAL.
    IT_WARNING-MESS = ''.
    APPEND IT_WARNING.
    CLEAR IT_WARNING.

    IT_WARNING-MESS = 'Still continue...?'.
    APPEND IT_WARNING.
    CLEAR IT_WARNING.

    DESCRIBE TABLE IT_WARNING LINES V_INDEX.

    V_INDEX2 = V_INDEX + 3.

    CLEAR: GS_FIELDCAT, GT_FIELDCAT, LS_SELFIELD, IT_EXCLUDING.
    REFRESH: GT_FIELDCAT, IT_EXCLUDING.

    GS_FIELDCAT-FIELDNAME = 'TYPE'.
    GS_FIELDCAT-SELTEXT_M = 'Film Type'.
    GS_FIELDCAT-OUTPUTLEN = 15.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    GS_FIELDCAT-FIELDNAME = 'MESS'.
    GS_FIELDCAT-SELTEXT_M = 'Message'.
    GS_FIELDCAT-OUTPUTLEN = 78.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    V_INDEX2 = V_INDEX + 4.

    APPEND '&OUP'  TO IT_EXCLUDING.
    APPEND '&ODN'  TO IT_EXCLUDING.
    APPEND '&OL0'  TO IT_EXCLUDING.
    APPEND '&ILT'  TO IT_EXCLUDING.
    APPEND '%SC'   TO IT_EXCLUDING.
    APPEND '%SC+'  TO IT_EXCLUDING.
    APPEND '&ETA'  TO IT_EXCLUDING.

*    APPEND '&VLP'  TO IT_EXCLUDING.
*    APPEND '&VPP'  TO IT_EXCLUDING.
*    APPEND '&VNP'  TO IT_EXCLUDING.
*    APPEND '&VLP'  TO IT_EXCLUDING.

    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        I_TITLE                 = 'Warning...!!'
        I_SELECTION             = 'X'
        I_ALLOW_NO_SELECTION    = 'X'
        I_ZEBRA                 = ''
        I_SCREEN_START_COLUMN   = 30
        I_SCREEN_START_LINE     = V_INDEX
        I_SCREEN_END_COLUMN     = 130
        I_SCREEN_END_LINE       = V_INDEX2
        IT_FIELDCAT             = GT_FIELDCAT
        I_TABNAME               = 'A'
        IT_EXCLUDING            = IT_EXCLUDING[]
        I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      IMPORTING
        ES_SELFIELD             = LS_SELFIELD
      TABLES
        T_OUTTAB                = IT_WARNING
      EXCEPTIONS
        PROGRAM_ERROR           = 1
        OTHERS                  = 2.

    IF SY-XCODE EQ '&AC1'.
      LOOP AT ITAB.
        MOVE-CORRESPONDING ITAB TO W_REPORT.
        W_REPORT-MSG     = 'Action cancelled by user..!'.
        W_REPORT-MSGTYP  = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CLEAR: W_REPORT.
      ENDLOOP.

      PERFORM REPORT.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.                    "VALIDASI

*&---------------------------------------------------------------------*
*&      Form  RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RECORD .
  CLEAR : T_REPORT,W_REPORT.
  REFRESH : T_REPORT.
  DESCRIBE TABLE  ITAB LINES LINE.
  IF LINE NE 0.

    LOOP AT ITAB.
      ITAB-NO = SY-TABIX.
      MODIFY ITAB INDEX ITAB-NO TRANSPORTING NO.
    ENDLOOP.
    TA_UPLOAD[] = ITAB[].
    DELETE TA_UPLOAD WHERE PONO NE ''.
    TA_REV[] = ITAB[].
    DELETE TA_REV WHERE PONO = ''.

    CLEAR: TA_MESSAGE.

    IF TA_UPLOAD IS NOT INITIAL.
      PERFORM UPLOAD_PO.
    ENDIF.

    IF TA_REV IS NOT INITIAL.
      PERFORM REVISI_PO.
    ENDIF.

    IF SY-SUBRC = 0.
      PERFORM INSERT_TO_SQL.
    ENDIF.

    PERFORM REPORT.
  ELSE.
    MESSAGE 'Upload Error' TYPE 'W'.
    RETURN.
  ENDIF.
ENDFORM.                    " RECORD
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_PO .
  CLEAR : BDC_DATA,FLAG_NOT_CONTINUE.
  REFRESH : BDC_DATA.

*  PERFORM GET_MAPPING.

  SELECT SINGLE STATUS INTO V_STATUS FROM ZMAP_INDICATOR WHERE INDC EQ 'SBU'.

  LOOP AT TA_UPLOAD INTO WA_UPLOAD.
    CLEAR: ZZTOTALC,TA_MESSAGE,WA_MESSAGE,V_MATNR_ACC,V_SR,IT_CHARG.
    REFRESH: TA_MESSAGE,IT_CHARG.
    TMP_I = WA_UPLOAD-NO.
    WA_MESSAGE-LINENO = TMP_I.

    "Check Mat to Mat Material Accent
    IF ( WA_UPLOAD-ORTYPE EQ 'ZP03'
    OR WA_UPLOAD-ORTYPE EQ 'ZP04'
    OR WA_UPLOAD-ORTYPE EQ 'ZP05'
    OR WA_UPLOAD-ORTYPE EQ 'ZP06'
    OR WA_UPLOAD-ORTYPE EQ 'ZP07'
    OR WA_UPLOAD-ORTYPE EQ 'ZP08'
    OR WA_UPLOAD-ORTYPE EQ 'ZP09'
    OR WA_UPLOAD-ORTYPE EQ 'ZP12'
    OR WA_UPLOAD-ORTYPE EQ 'ZP14'
    OR WA_UPLOAD-ORTYPE EQ 'ZP18' )
    AND ( WA_UPLOAD-PLANT EQ '1000' OR WA_UPLOAD-PLANT EQ '2000' )
    AND V_STATUS EQ 'X'.
      "Check Material JR SBU Asset
      V_SR = 'SR' && WA_UPLOAD-MATERIAL+2(10).

      CLEAR: V_SBU_AO.

      SELECT SINGLE SBU_ASSET INTO V_SBU_AO
        FROM ZMAPPG
        JOIN T001K ON T001K~BUKRS EQ ZMAPPG~BUKRS
       WHERE MATNR EQ V_SR
         AND BWKEY EQ WA_UPLOAD-PLANT.

      IF V_SBU_AO IS INITIAL.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        CONCATENATE 'SBU Asset for' V_SR 'not yet maintained' INTO W_REPORT-MSG SEPARATED BY SPACE.
        W_REPORT-MSGTYP  = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CONTINUE.
      ENDIF.

      CLEAR: V_MATNR_RR.
      SELECT SINGLE RAR_A_MATNR INTO V_MATNR_RR FROM ZTMAP_MATRECYCLE WHERE WERKS EQ WA_UPLOAD-PLANT AND MATNR EQ WA_UPLOAD-MATERIAL.
      IF V_MATNR_RR IS INITIAL.
        CONCATENATE 'Material RR Mapping for Material' WA_UPLOAD-MATERIAL 'not yet maintained!' INTO W_REPORT-MSG SEPARATED BY SPACE.
        W_REPORT-MSGTYP  = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CONTINUE.
      ELSE.
        SELECT SINGLE MATNR INTO V_MATNR_RR FROM MARA WHERE MATNR EQ V_MATNR_RR.
        IF SY-SUBRC NE 0.
          CONCATENATE 'Material RR Master Data' WA_UPLOAD-MATERIAL 'not yet maintained!' INTO W_REPORT-MSG SEPARATED BY SPACE.
          W_REPORT-MSGTYP  = 'E'.
          APPEND W_REPORT TO T_REPORT.
          CONTINUE.
        ENDIF.
      ENDIF.

      CLEAR: V_BOM, V_STLAL.
      "Check BOM
      SELECT SINGLE STLNR MAST~STLAL
        INTO (V_BOM, V_STLAL)
        FROM MKAL
        JOIN MAST ON MAST~MATNR EQ MKAL~MATNR AND MAST~WERKS EQ MKAL~WERKS AND MAST~STLAN EQ MKAL~STLAN AND MAST~STLAL EQ MKAL~STLAL
       WHERE MKAL~MATNR EQ WA_UPLOAD-MATERIAL
         AND MKAL~WERKS EQ WA_UPLOAD-PLANT
         AND MKAL~VERID EQ WA_UPLOAD-PRODVER.

      "Check Material Input
      IF V_BOM IS INITIAL.
        CONCATENATE 'BOM is invalid for material' WA_UPLOAD-MATERIAL '!' INTO W_REPORT-MSG SEPARATED BY SPACE.
        W_REPORT-MSGTYP  = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CONTINUE.
      ENDIF.

      SELECT STPO~IDNRK AS MATNR MARA~MATKL
        INTO CORRESPONDING FIELDS OF TABLE IT_CHARG
        FROM STAS
        JOIN STPO ON STPO~STLNR EQ STAS~STLNR AND STPO~STLKN EQ STAS~STLKN
        JOIN MARA ON MARA~MATNR EQ STPO~IDNRK
       WHERE STPO~STLNR EQ V_BOM
         AND STAS~STLAL EQ V_STLAL
         AND MARA~MATKL LIKE '3%'
         AND MARA~MATNR LIKE 'SR%'.

      SORT IT_CHARG BY MATNR.
      DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING MATNR.

      LOOP AT IT_CHARG.
        CLEAR: V_SBU_AI.

        "Start of CKI Update ---------------------------------------------------------------------------------------------------
        DATA: V_MATKL TYPE MATKL,
              V_KUNNR TYPE KUNNR,
              V_LIFNR TYPE LIFNR.

        "Validation Material Group based on Mapping
        IF R_MATKL[] IS NOT INITIAL.
          SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR EQ IT_CHARG-MATNR.
          IF V_MATKL IN R_MATKL.
            IF WA_UPLOAD-CUST IS INITIAL.
              V_ERR = 'X'.
              V_MSG = 'Please fill customer in template!'.
              CONTINUE.
            ENDIF.

            SELECT SINGLE KUNNR LIFNR INTO (V_KUNNR, V_LIFNR) FROM KNA1 WHERE KUNNR EQ WA_UPLOAD-CUST.
            IF V_KUNNR IS INITIAL.
              V_ERR = 'X'.
              CONCATENATE 'Customer' WA_UPLOAD-CUST 'is not valid!' INTO V_MSG SEPARATED BY SPACE.
              CONTINUE.
            ENDIF.

            IF V_LIFNR IS INITIAL.
              V_ERR = 'X'.
              CONCATENATE 'Vendor is not found in customer ' WA_UPLOAD-CUST '!' INTO V_MSG SEPARATED BY SPACE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
        "End of CKI Update ---------------------------------------------------------------------------------------------------

        "Input material X atau O without mat to mat
        IF IT_CHARG-MATNR+5(1) EQ 'O' OR IT_CHARG-MATNR+5(1) EQ 'X'.
          CONTINUE.
        ENDIF.

        "Check Material SR SBU Asset
        SELECT SINGLE SBU_ASSET INTO V_SBU_AI
          FROM ZMAPPG
          JOIN T001K ON T001K~BUKRS EQ ZMAPPG~BUKRS
         WHERE MATNR EQ IT_CHARG-MATNR
           AND BWKEY EQ WA_UPLOAD-PLANT.

        IF V_SBU_AI IS INITIAL.
          V_ERR = 'X'.
          CONCATENATE 'SBU Asset for' IT_CHARG-MATNR 'not yet maintained' INTO V_MSG SEPARATED BY SPACE.
          CONTINUE.
        ENDIF.

        IF V_SBU_AI NE V_SBU_AO.
          CLEAR: V_MATNR_ACC, IT_ZMAP_SBU.
          REFRESH: IT_ZMAP_SBU.

          SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ZMAP_SBU FROM ZMAP_MAT_SBU
           WHERE WERKS      EQ WA_UPLOAD-PLANT
             AND MATNR_OUT  EQ WA_UPLOAD-MATERIAL.

          SORT IT_ZMAP_SBU BY MATNR_ACC.
          DELETE ADJACENT DUPLICATES FROM IT_ZMAP_SBU COMPARING MATNR_ACC.

          "Check False Order Type
          DESCRIBE TABLE IT_ZMAP_SBU LINES LINE.
          IF LINE > 1 AND WA_UPLOAD-ORTYPE NE 'ZP09'.
            V_ERR = 'X'.
            CONCATENATE 'Please use order type ZP09 for material' WA_UPLOAD-MATERIAL 'Laminate!' INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ENDIF.

          IF WA_UPLOAD-ORTYPE EQ 'ZP09'.
            SELECT SINGLE MATNR_ACC INTO V_MATNR_ACC FROM ZMAP_MAT_SBU WHERE WERKS EQ WA_UPLOAD-PLANT AND MATNR_BF EQ IT_CHARG-MATNR AND MATNR_OUT EQ WA_UPLOAD-MATERIAL.
          ELSE.
            SELECT SINGLE MATNR_ACC INTO V_MATNR_ACC FROM ZMAP_MAT_SBU WHERE WERKS EQ WA_UPLOAD-PLANT AND MATNR_OUT EQ WA_UPLOAD-MATERIAL.
          ENDIF.
          IF V_MATNR_ACC IS INITIAL.
            V_ERR = 'X'.
            CONCATENATE 'Material Accent for' WA_UPLOAD-MATERIAL '-' IT_CHARG-MATNR 'not yet maintained in plant' WA_UPLOAD-PLANT INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ELSE.
            SELECT SINGLE MATNR INTO V_MATNR_ACC FROM MARA WHERE MATNR EQ V_MATNR_ACC.
            IF SY-SUBRC NE 0.
              V_ERR = 'X'.
              CONCATENATE 'Material Accent Master Data' V_MATNR_ACC 'not yet maintained!' INTO V_MSG SEPARATED BY SPACE.
              CONTINUE.
            ENDIF.
          ENDIF.

          "Check PV 1000 Accent
          CLEAR: V_VERID.
          SELECT SINGLE VERID
            INTO V_VERID
            FROM MKAL
           WHERE MATNR EQ V_MATNR_ACC
             AND WERKS EQ WA_UPLOAD-PLANT
             AND VERID EQ '1000'.

          IF V_VERID IS INITIAL.
            V_ERR = 'X'.
            CONCATENATE 'Version 1000 does not exist for material' V_MATNR_ACC 'in plant' WA_UPLOAD-PLANT INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ENDIF.

          "Check PV 1000 Alt 93 94 Accnet
          CLEAR: V_BOM.
          SELECT SINGLE STLNR
            INTO V_BOM
            FROM MAST
           WHERE MATNR EQ V_MATNR_ACC
             AND WERKS EQ WA_UPLOAD-PLANT
             AND ( STLAL EQ '93' OR STLAL EQ '94' ).

          IF V_BOM IS INITIAL.
            V_ERR = 'X'.
            CONCATENATE 'Please check alt BOM 93/94 for material' V_MATNR_ACC 'in plant' WA_UPLOAD-PLANT INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ENDIF.

          "Check Master Recipe Accent
          CLEAR: V_PLNAL.
          SELECT SINGLE PLNAL
            INTO V_PLNAL
            FROM MAPL
           WHERE MATNR EQ V_MATNR_ACC
             AND PLNNR EQ V_MATNR_ACC
             AND WERKS EQ WA_UPLOAD-PLANT
             AND ( PLNAL EQ '93' OR PLNAL EQ '94' ).

          IF V_PLNAL IS INITIAL.
            V_ERR = 'X'.
            CONCATENATE 'Please check master recipe 93/94 for material' V_MATNR_ACC 'in plant' WA_UPLOAD-PLANT INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ENDIF.

          "Check PV 1000 BF
          CLEAR: V_VERID.
          SELECT SINGLE VERID
            INTO V_VERID
            FROM MKAL
           WHERE MATNR EQ IT_CHARG-MATNR
             AND WERKS EQ WA_UPLOAD-PLANT
             AND VERID EQ '1000'.

          IF V_VERID IS INITIAL.
            V_ERR = 'X'.
            CONCATENATE 'Version 1000 does not exist for material' IT_CHARG-MATNR 'in plant' WA_UPLOAD-PLANT INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ENDIF.

          "Check PV 1000 Alt 93 94 BF
          CLEAR: V_BOM.
          SELECT SINGLE STLNR
            INTO V_BOM
            FROM MAST
           WHERE MATNR EQ IT_CHARG-MATNR
             AND WERKS EQ WA_UPLOAD-PLANT
             AND ( STLAL EQ '93' OR STLAL EQ '94' ).

          IF V_BOM IS INITIAL.
            V_ERR = 'X'.
            CONCATENATE 'Please check alt BOM 93/94 for material' IT_CHARG-MATNR 'in plant' WA_UPLOAD-PLANT INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ENDIF.

          "Check Master Recipe BF
          CLEAR: V_PLNAL.
          SELECT SINGLE PLNAL
            INTO V_PLNAL
            FROM MAPL
           WHERE MATNR EQ IT_CHARG-MATNR
             AND PLNNR EQ IT_CHARG-MATNR
             AND WERKS EQ WA_UPLOAD-PLANT
             AND ( PLNAL EQ '93' OR PLNAL EQ '94' ).

          IF V_PLNAL IS INITIAL.
            V_ERR = 'X'.
            CONCATENATE 'Please check master recipe 93/94 for material' IT_CHARG-MATNR 'in plant' WA_UPLOAD-PLANT INTO V_MSG SEPARATED BY SPACE.
            CONTINUE.
          ENDIF.
        ENDIF.

        "Check material Mapping RR BF
        CLEAR: V_MATNR_RR.
        SELECT SINGLE RAR_A_MATNR INTO V_MATNR_RR FROM ZTMAP_MATRECYCLE WHERE WERKS EQ WA_UPLOAD-PLANT AND MATNR EQ IT_CHARG-MATNR.
        IF V_MATNR_RR IS INITIAL.
          V_ERR = 'X'.
          CONCATENATE 'Material RR Mapping for Material' IT_CHARG-MATNR 'not yet maintained!' INTO V_MSG SEPARATED BY SPACE.
          CONTINUE.
        ELSE.
          SELECT SINGLE MATNR INTO V_MATNR_RR FROM MARA WHERE MATNR EQ V_MATNR_RR.
          IF SY-SUBRC NE 0.
            CONCATENATE 'Material RR Master Data' IT_CHARG-MATNR 'not yet maintained!' INTO V_MSG SEPARATED BY SPACE.
            V_ERR = 'X'.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF V_ERR EQ 'X'.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-MSG = V_MSG.
        W_REPORT-MSGTYP  = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CONTINUE.
      ENDIF.
    ENDIF.

    READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZCODE'
                                   VTVALUE   = WA_UPLOAD-TYPEFILM
                                   FLDELETE = ' '.
    IF SY-SUBRC = 0.
      CLEAR: ZVTLINENO.
      ZVTLINENO = ZVTENTRIES-VTLINENO.
      READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZTHICKNESS'
                                     VTLINENO  = ZVTLINENO
                                     FLDELETE = ' '.
      CLEAR: ZVTVALUE1.
      IF SY-SUBRC = 0.
        ZVTVALUE1 = ZVTENTRIES-VTVALUE.
      ELSE.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-MSG     = 'Thickness Not Found'.
        W_REPORT-MSGTYP  = 'E'.
        APPEND W_REPORT TO T_REPORT.
      ENDIF.

      READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZDENSITY'
                                     VTLINENO  = ZVTLINENO
                                     FLDELETE = ' '.
      CLEAR: ZVTVALUE2.
      IF SY-SUBRC = 0.
        ZVTVALUE2 = ZVTENTRIES-VTVALUE.
      ELSE.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-MSG     = 'Density Not Found'.
        W_REPORT-MSGTYP  = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CONTINUE.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
      W_REPORT-MSG     = 'Code Film Not Found'.
      W_REPORT-MSGTYP  = 'E'.
      APPEND W_REPORT TO T_REPORT.
      CONTINUE.
    ENDIF.

    CLEAR : ZZGRAMMAGE.
    READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZGRAMMAGE'
                                   VTLINENO  = ZVTLINENO
                                   FLDELETE = ' '.
    IF SY-SUBRC = 0.
      ZZGRAMMAGE = ZVTENTRIES-VTVALUE.
    ENDIF.

    ZZQTY = 0.
    ZZLENGTH = 0.
    ZZWIDTH = 0.
    ZZNOSHEET = 0.
    ZZVTVALUE1 = 0.
    ZZVTVALUE2 = 0.
    ZZTOTAL = 0.
    ZZPEMBILANGASAL = 0.
    ZZPENYEBUTASAL = 0.
    ZZPEMBILANGBARU = 0.
    ZZPENYEBUTBARU = 0.
    IF WA_UPLOAD-UOM NE 'KG'.
      MOVE WA_UPLOAD-QTY TO ZZQTY.
      MOVE WA_UPLOAD-LENGTH TO ZZLENGTH.
      MOVE WA_UPLOAD-WIDTH TO ZZWIDTH.
      MOVE WA_UPLOAD-ZNOSHEET TO ZZNOSHEET.
      MOVE ZVTVALUE1 TO ZZVTVALUE1.
      MOVE ZVTVALUE2 TO ZZVTVALUE2.
      ZZPEMBILANGASAL = ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 * 1000.
      ZZPENYEBUTASAL = 1000000. "1000000000.
*      CALL FUNCTION 'CONVERT_TO_FRACT5'
*        EXPORTING
*          NOMIN               = ZZPEMBILANGASAL
*          DENOMIN             = ZZPENYEBUTASAL
*        IMPORTING
*          NOMOUT              = ZZPEMBILANGBARU
*          DENOMOUT            = ZZPENYEBUTBARU
*        EXCEPTIONS
*          CONVERSION_OVERFLOW = 1
*          OTHERS              = 2.

*      IF SY-SUBRC <> 0.
* Implement suitable error handling here
*      ENDIF.

      IF WA_UPLOAD-ORTYPE NE 'ZP11'.
*        IF ZZPENYEBUTBARU NE 0.
        IF ZZGRAMMAGE NE ''.
          ZZTOTAL =  ( ( ZZLENGTH * ZZWIDTH * ZZGRAMMAGE ) / 1000000 ) .
        ELSE.
          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 ) / 1000000 ) .
        ENDIF.
*        ENDIF.
      ELSEIF WA_UPLOAD-ORTYPE EQ 'ZP90'.
        ZZTOTAL  = 0.
      ELSEIF WA_UPLOAD-ORTYPE EQ 'ZP11'.
*        IF ZZPENYEBUTBARU NE 0.
        IF ZZGRAMMAGE = ''.
*          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 ) / 1000000 ) * ZZNOSHEET  .
          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 ) / 1000000000 ) .
        ELSE.
          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZGRAMMAGE ) / 1000000000 )  .
        ENDIF.
*        ENDIF.
      ENDIF.


      CALL FUNCTION 'Z_MMUR_ROUND_FOR_FRACT5'
        EXPORTING
          I_VALUE        = ZZTOTAL
          I_DECIMALS     = 2
        IMPORTING
          O_VALUE        = ZZCONVERT
        EXCEPTIONS
          INPUT_INVALID  = 1
          OUTPUT_INVALID = 2
          OVERFLOWS      = 3
          OTHERS         = 4.

      IF WA_UPLOAD-ORTYPE EQ 'ZP11'.
        ZZTOTAL = ZZCONVERT * ZZQTY * ZZNOSHEET.
      ELSE.
        ZZTOTAL = ZZCONVERT * ZZQTY.
      ENDIF.

      IF ZZTOTAL = 0.
        ZZTOTAL = ZZQTY.
      ENDIF.
      ZZTOTALC = ZZTOTAL .
    ELSE.
      ZZTOTAL = ZZQTY.
      ZZTOTALC = ZZTOTAL.
    ENDIF.

    CONDENSE ZZTOTALC.
    CLEAR: BDC_DATA, L_TA_MSG,L_WA_MSG.
    REFRESH: BDC_DATA[], L_TA_MSG.
    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5100'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=ENTK'.
    BDC_FIELD BDC_DATA   'CAUFVD-MATNR' WA_UPLOAD-MATERIAL.
    BDC_FIELD BDC_DATA   'CAUFVD-WERKS' WA_UPLOAD-PLANT.
    BDC_FIELD BDC_DATA   'AUFPAR-PI_AUFART' WA_UPLOAD-ORTYPE.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=SLAP'.
    BDC_FIELD BDC_DATA   'CAUFVD-GAMNG' WA_UPLOAD-QTY.
    BDC_FIELD BDC_DATA   'CAUFVD-GMEIN' WA_UPLOAD-UOM.
    BDC_FIELD BDC_DATA   'CAUFVD-GLUZS' WA_UPLOAD-FTIME.
    BDC_FIELD BDC_DATA   'CAUFVD-GLTRS' WA_UPLOAD-FDATE.
    BDC_FIELD BDC_DATA   'CAUFVD-GSTRS' WA_UPLOAD-SDATE.
    BDC_FIELD BDC_DATA   'CAUFVD-GSUZS' WA_UPLOAD-STIME.

    BDC_DYNPRO BDC_DATA  'SAPLCOSD' '5132'.
    BDC_FIELD BDC_DATA   'BDC_CURSOR' 'MDFQ-VERID(01)'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=AUSW'.


    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=STAK'.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5131'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=ENT1'.
    BDC_FIELD BDC_DATA   'RC62F-VER_SEL' 'X'.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_UPLOAD-PRODVER
      IMPORTING
        OUTPUT = WA_UPLOAD-PRODVER.
    BDC_FIELD BDC_DATA   'RC62F-PROD_VERS' WA_UPLOAD-PRODVER.
    BDC_FIELD BDC_DATA   'RC62F-NEW_ROUT' 'X'.
    BDC_FIELD BDC_DATA   'RC62F-NEW_BOM' 'X'.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=+COI'.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE'  '=FREI'.
    BDC_FIELD BDC_DATA   'ZFILM-ZCODE' WA_UPLOAD-TYPEFILM.
    BDC_FIELD BDC_DATA   'ZFILM-ZWIDTH' WA_UPLOAD-WIDTH.
    BDC_FIELD BDC_DATA   'ZFILM-ZLENGTH' WA_UPLOAD-LENGTH.
    BDC_FIELD BDC_DATA   'ZFILM-ZTREAT' WA_UPLOAD-TREATMENT.
    BDC_FIELD BDC_DATA   'ZFILM-ZLINE' WA_UPLOAD-PRODLINE.
    BDC_FIELD BDC_DATA   'ZFILM-ZMONTH' WA_UPLOAD-BTPROD.
    BDC_FIELD BDC_DATA   'ZFILM-ZCUSTM' WA_UPLOAD-CUST.
    BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_UPLOAD-ZNOSHEET.

    "Begin add new company
    IF WA_UPLOAD-ZRESEV IS NOT INITIAL.
      BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_UPLOAD-ZRESEV.
    ENDIF.
    "End add new company

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=KOSD'.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD  BDC_DATA  'BDC_CURSOR' 'CAUFVD-AUTERM'.
    BDC_FIELD BDC_DATA   'CAUFVD-AUTERM' ''.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=KOMG'.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '0133'.
    BDC_FIELD  BDC_DATA  'BDC_CURSOR' 'CAUFVD-BMENGE'.
    BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=ENT1'.
    BDC_FIELD  BDC_DATA  'CAUFVD-BMENGE' ZZTOTALC.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=BU'.


    OPTION-DISMODE = 'N'.
    OPTION-UPDMODE = 'A'.
    OPTION-DEFSIZE = 'X'.

    CALL TRANSACTION 'COR1' USING BDC_DATA OPTIONS FROM OPTION MESSAGES INTO L_TA_MSG.
    COMMIT WORK AND WAIT.

    CLEAR : PONO.
    READ TABLE L_TA_MSG INTO L_WA_MSG WITH KEY MSGID  = '40'
                                               MSGNR  = '582'
                                               MSGTYP = 'S'.
    PONO = L_WA_MSG-MSGV1.

*    DELETE L_TA_MSG WHERE MSGV1 = '' AND MSGV2 = ''.
    SORT L_TA_MSG BY MSGV1.
    DELETE ADJACENT DUPLICATES FROM L_TA_MSG COMPARING MSGV1.

    READ TABLE L_TA_MSG INTO L_WA_MSG WITH KEY MSGTYP = 'S'.
    IF SY-SUBRC = 0.
      LOOP AT L_TA_MSG INTO L_WA_MSG.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-AUFNR  = PONO.
*        W_REPORT-QTY    = ZZTOTALC.
        CONCATENATE L_WA_MSG-MSGV1 L_WA_MSG-MSGV2 INTO W_REPORT-MSG.
        W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
        APPEND W_REPORT TO T_REPORT.
      ENDLOOP.
    ELSE.

      LOOP AT L_TA_MSG INTO L_WA_MSG WHERE MSGTYP NE 'S'.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-AUFNR  = PONO.
*        W_REPORT-QTY    = ZZTOTALC.
        IF L_WA_MSG-MSGV1 NE '' OR L_WA_MSG-MSGV2 NE ''.
          CONCATENATE L_WA_MSG-MSGV1 L_WA_MSG-MSGV2 INTO W_REPORT-MSG SEPARATED BY SPACE.
        ELSE.
          CONCATENATE L_WA_MSG-MSGID L_WA_MSG-MSGNR INTO W_REPORT-MSG SEPARATED BY SPACE.
        ENDIF.
        W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
        APPEND W_REPORT TO T_REPORT.
      ENDLOOP.

      LOOP AT TA_MESSAGE INTO WA_MESSAGE.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-AUFNR  = PONO.
*        W_REPORT-QTY    = ZZTOTALC.
        CONCATENATE WA_MESSAGE-MSGV1 WA_MESSAGE-MSGV2 INTO W_REPORT-MSG.
        W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
        APPEND W_REPORT TO T_REPORT.
      ENDLOOP.
    ENDIF.

    "Order for SBU
    READ TABLE L_TA_MSG INTO L_WA_MSG WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC NE 0 AND ( WA_UPLOAD-ORTYPE EQ 'ZP03'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP04'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP05'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP06'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP07'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP08'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP09'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP12'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP14'
                        OR WA_UPLOAD-ORTYPE EQ 'ZP18' )
                        AND ( WA_UPLOAD-PLANT EQ '1000' OR WA_UPLOAD-PLANT EQ '2000' )
                        AND V_STATUS EQ 'X'
                        AND V_SBU_AI NE V_SBU_AO.

      REFRESH: IT_ZMAP_SBU.
      CLEAR: IT_ZMAP_SBU.

      LOOP AT IT_CHARG.
        CLEAR: V_MATNR_ACC.
        IF WA_UPLOAD-ORTYPE EQ 'ZP09'.
          SELECT SINGLE MATNR_ACC INTO V_MATNR_ACC FROM ZMAP_MAT_SBU WHERE WERKS      EQ WA_UPLOAD-PLANT
                                                                       AND MATNR_BF   EQ IT_CHARG-MATNR
                                                                       AND MATNR_OUT  EQ WA_UPLOAD-MATERIAL.
        ELSE.
          SELECT SINGLE MATNR_ACC INTO V_MATNR_ACC FROM ZMAP_MAT_SBU WHERE WERKS      EQ WA_UPLOAD-PLANT
                                                                       AND MATNR_OUT  EQ WA_UPLOAD-MATERIAL.
        ENDIF.

        IF V_MATNR_ACC IS NOT INITIAL.
          IT_ZMAP_SBU-WERKS     = WA_UPLOAD-PLANT.
          IT_ZMAP_SBU-MATNR_BF  = IT_CHARG-MATNR.
          IT_ZMAP_SBU-MATNR_ACC = V_MATNR_ACC.
          IT_ZMAP_SBU-MATNR_OUT = WA_UPLOAD-MATERIAL.
          APPEND IT_ZMAP_SBU.
          CLEAR IT_ZMAP_SBU.
        ENDIF.
      ENDLOOP.

      SORT IT_ZMAP_SBU BY MATNR_ACC.
      DELETE ADJACENT DUPLICATES FROM IT_ZMAP_SBU COMPARING MATNR_ACC.

      LOOP AT IT_ZMAP_SBU.
        CLEAR: V_AUFNR, V_COUNTER, V_TEMP.

        SELECT MAX( AUFNR ) INTO V_AUFNR FROM AUFK WHERE AUART EQ 'ZMMS'.

        IF V_AUFNR IS INITIAL.
          V_AUFNR = 'M10000000000'.
        ENDIF.

        V_COUNTER = V_AUFNR+2(10).

        ADD 1 TO V_COUNTER.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = V_COUNTER
          IMPORTING
            OUTPUT = V_COUNTER.

        V_AUFNR+2(10) = V_COUNTER.

        CLEAR: V_DATE, LS_SUBRC, TORDER, ORDERO.

        "Fill Data Order
        TORDER-ORDER_NUMBER     = V_AUFNR.
        TORDER-MATERIAL         = IT_ZMAP_SBU-MATNR_ACC.
        TORDER-PLANT            = WA_UPLOAD-PLANT.
        TORDER-ORDER_TYPE       = 'ZMMS'.
        TORDER-QUANTITY         = ZZTOTALC.
        TORDER-PROD_VERSION     = '1000'.

        CLEAR V_DATE.
        PERFORM CONVERT_DATE_I USING WA_UPLOAD-SDATE CHANGING V_DATE.
        TORDER-BASIC_START_DATE = V_DATE.
        CLEAR V_DATE.
        PERFORM CONVERT_DATE_I USING WA_UPLOAD-FDATE CHANGING V_DATE.
        TORDER-BASIC_END_DATE   = V_DATE.

        CALL FUNCTION 'BAPI_PROCORD_CREATE'
          EXPORTING
            ORDERDATA    = TORDER
          IMPORTING
            RETURN       = IT_RETURN
            ORDER_NUMBER = ORDERO.

        APPEND IT_RETURN.
        DELETE IT_RETURN WHERE TYPE IS INITIAL.

        LOOP AT IT_RETURN.
          IF IT_RETURN-TYPE EQ 'E'.
            READ TABLE T_REPORT INTO W_REPORT WITH KEY AUFNR = PONO MSG = ''.
            IF SY-SUBRC EQ 0.
              CONCATENATE 'PRO M2M not created: ' IT_RETURN-MESSAGE IT_RETURN-MESSAGE_V1 INTO W_REPORT-MSG SEPARATED BY SPACE.
              W_REPORT-MSGTYP = IT_RETURN-TYPE.
              MODIFY T_REPORT FROM W_REPORT TRANSPORTING MSGTYP MSG WHERE AUFNR EQ PONO AND MSG IS INITIAL.
            ELSE.
              MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
              CONCATENATE 'PRO M2M not created: ' IT_RETURN-MESSAGE IT_RETURN-MESSAGE_V1 INTO W_REPORT-MSG SEPARATED BY SPACE.
              W_REPORT-MSGTYP = IT_RETURN-TYPE.
              APPEND W_REPORT TO T_REPORT.
            ENDIF.
          ENDIF.

          IF IT_RETURN-TYPE EQ 'E' AND LS_SUBRC EQ 0.
            LS_SUBRC = 1.
          ENDIF.
        ENDLOOP.

        IF LS_SUBRC EQ 0.
          COMMIT WORK AND WAIT.
          PERFORM PROCESS_DELAYING.

          CLEAR: BDC_DATA, L_TA_MSG,L_WA_MSG.
          REFRESH: BDC_DATA[], L_TA_MSG.

          BDC_DYNPRO BDC_DATA   'SAPLCOKO' '5110'.
          BDC_FIELD BDC_DATA    'BDC_OKCODE' '/00'.
          BDC_FIELD BDC_DATA    'CAUFVD-AUFNR' V_AUFNR.
          BDC_FIELD BDC_DATA    'R62CLORD-FLG_COMPL' 'X'.

*         Quantity -------------------------------

          BDC_DYNPRO BDC_DATA   'SAPLCOKO' '5115'.
          BDC_FIELD BDC_DATA    'BDC_OKCODE' '=KOMG'.
          BDC_FIELD BDC_DATA    'BDC_CURSOR' 'CAUFVD-GAMNG'.

          CLEAR V_CLABS.
          MOVE WA_UPLOAD-QTY TO V_CLABS.
          BDC_FIELD BDC_DATA    'CAUFVD-GAMNG'  V_CLABS.

          "QTY STOCK
          CLEAR V_CLABS.
          MOVE ZZTOTALC TO V_CLABS.

*          BDC_FIELD BDC_DATA    'CAUFVD-BMENGE' V_CLABS.
          BDC_DYNPRO BDC_DATA   'SAPLCOKO' '0133'.
          BDC_FIELD BDC_DATA    'BDC_CURSOR' 'CAUFVD-BMENGE'.
          "QTY BATCH
          BDC_FIELD BDC_DATA    'BDC_OKCODE' '=ENT1'.
          CLEAR V_CLABS.
          MOVE WA_UPLOAD-QTY TO V_CLABS.
          BDC_FIELD BDC_DATA    'CAUFVD-GAMNG'  V_CLABS.

          "QTY STOCK
          CLEAR V_CLABS.
          MOVE ZZTOTALC TO V_CLABS.
          BDC_FIELD BDC_DATA    'CAUFVD-BMENGE' V_CLABS.

*          BDC_DYNPRO BDC_DATA   'SAPLCOKO' '5115'.
*          BDC_FIELD BDC_DATA    'BDC_OKCODE' '=OMLA'.
*          CLEAR V_CLABS.
*          MOVE WA_UPLOAD-QTY TO V_CLABS.
*          BDC_FIELD BDC_DATA    'CAUFVD-GAMNG'  V_CLABS.

          "QTY STOCK
          CLEAR V_CLABS.
          MOVE ZZTOTALC TO V_CLABS.
          BDC_FIELD BDC_DATA 'CAUFVD-BMENGE' V_CLABS.

*          ------------------------------

          BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
          BDC_FIELD BDC_DATA   'BDC_OKCODE' '=+COI'.
          BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
          BDC_FIELD BDC_DATA   'BDC_OKCODE' '/00'.

          BDC_FIELD BDC_DATA   'ZFILM-ZCODE' WA_UPLOAD-TYPEFILM.
          BDC_FIELD BDC_DATA   'ZFILM-ZWIDTH' WA_UPLOAD-WIDTH.
          BDC_FIELD BDC_DATA   'ZFILM-ZLENGTH' WA_UPLOAD-LENGTH.
          BDC_FIELD BDC_DATA   'ZFILM-ZTREAT' WA_UPLOAD-TREATMENT.
          BDC_FIELD BDC_DATA   'ZFILM-ZLINE' WA_UPLOAD-PRODLINE.
          BDC_FIELD BDC_DATA   'ZFILM-ZMONTH' WA_UPLOAD-BTPROD.
          BDC_FIELD BDC_DATA   'ZFILM-ZCUSTM' WA_UPLOAD-CUST.
          BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_UPLOAD-ZNOSHEET.
          BDC_FIELD BDC_DATA   'ZFILM-ZSBUORDER' PONO.

          "Begin add new company
          IF WA_UPLOAD-ZRESEV IS NOT INITIAL.
            BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_UPLOAD-ZRESEV.
          ENDIF.
          "End add new company

          "Release Order
          BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
          BDC_FIELD BDC_DATA    'BDC_OKCODE' '=FREI'.
*        BDC_FIELD BDC_DATA    'BDC_CURSOR'
*                              'AFPOD-STRMP'.

          BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
          BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=BU'.

          OPTION-DISMODE = 'N'.
          OPTION-UPDMODE = 'A'.
          OPTION-DEFSIZE = 'X'.

          CALL TRANSACTION 'COR2' USING BDC_DATA OPTIONS FROM OPTION MESSAGES INTO L_TA_MSG.
          COMMIT WORK AND WAIT.

*
          LOOP AT L_TA_MSG INTO L_WA_MSG WHERE MSGTYP = 'E'.
            READ TABLE T_REPORT INTO W_REPORT WITH KEY AUFNR = PONO MSG = ''.
            IF SY-SUBRC EQ 0.
              SELECT SINGLE TEXT INTO W_REPORT-MSG FROM T100 WHERE SPRSL = 'E' AND ARBGB = L_WA_MSG-MSGID AND MSGNR = L_WA_MSG-MSGNR.
              REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV1.
              REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV2.
              W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
              MODIFY T_REPORT FROM W_REPORT TRANSPORTING MSGTYP MSG WHERE AUFNR EQ PONO AND MSG IS INITIAL.
            ELSE.
              MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
              W_REPORT-AUFNR  = PONO.
              SELECT SINGLE TEXT INTO W_REPORT-MSG FROM T100 WHERE SPRSL = 'E' AND ARBGB = L_WA_MSG-MSGID AND MSGNR = L_WA_MSG-MSGNR.
              REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV1.
              REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV2.
              W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
              APPEND W_REPORT TO T_REPORT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " UPLOAD_PO
*&---------------------------------------------------------------------*
*&      Form  REVISI_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVISI_PO .
  TABLES: AFRU.
  DATA: CHECK1 TYPE C.
  CLEAR : BDC_DATA,FLAG_NOT_CONTINUE.
  REFRESH : BDC_DATA.

  SELECT SINGLE STATUS INTO V_STATUS FROM ZMAP_INDICATOR WHERE INDC EQ 'SBU'.

  LOOP AT TA_REV INTO WA_REV.
    CLEAR: ZZTOTALC, IT_CHARG.
    REFRESH: IT_CHARG.
    TMP_I = WA_REV-NO.
    WA_MESSAGE-LINENO = TMP_I.

    SELECT SINGLE AUART WERKS INTO (WA_REV-ORTYPE,WA_REV-PLANT)
      FROM AUFK
      WHERE AUFNR = WA_REV-PONO.

    READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZCODE'
                                   VTVALUE   = WA_REV-TYPEFILM
                                   FLDELETE = ' '.
    IF SY-SUBRC = 0.
      CLEAR: ZVTLINENO.
      ZVTLINENO = ZVTENTRIES-VTLINENO.
      READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZTHICKNESS'
                                     VTLINENO  = ZVTLINENO
                                     FLDELETE = ' '.
      CLEAR: ZVTVALUE1.
      IF SY-SUBRC = 0.
        ZVTVALUE1 = ZVTENTRIES-VTVALUE.
      ELSE.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-MSG    = 'Thickness Not Found'.
        W_REPORT-MSGTYP = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CLEAR : W_REPORT.
      ENDIF.

      READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZDENSITY'
                                     VTLINENO  = ZVTLINENO
                                     FLDELETE = ' '.
      CLEAR: ZVTVALUE2.
      IF SY-SUBRC = 0.
        ZVTVALUE2 = ZVTENTRIES-VTVALUE.
      ELSE.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-MSG    = 'Density Not Found'.
        W_REPORT-MSGTYP = 'E'.
        APPEND W_REPORT TO T_REPORT.
        CLEAR : W_REPORT.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
      W_REPORT-MSG    = 'Code Film Not Found'.
      W_REPORT-MSGTYP = 'E'.
      APPEND W_REPORT TO T_REPORT.
      CLEAR : W_REPORT.
    ENDIF.

    CLEAR : ZZGRAMMAGE.
    READ TABLE ZVTENTRIES WITH KEY VTCHARACT = 'ZZGRAMMAGE'
                                   VTLINENO  = ZVTLINENO
                                   FLDELETE = ' '.
    IF SY-SUBRC = 0.
      ZZGRAMMAGE = ZVTENTRIES-VTVALUE.
    ENDIF.

    ZZQTY = 0.
    ZZLENGTH = 0.
    ZZWIDTH = 0.
    ZZNOSHEET = 0.
    ZZVTVALUE1 = 0.
    ZZVTVALUE2 = 0.
    ZZTOTAL = 0.
    ZZPEMBILANGASAL = 0.
    ZZPENYEBUTASAL = 0.
    ZZPEMBILANGBARU = 0.
    ZZPENYEBUTBARU = 0.
    IF WA_REV-UOM NE 'KG'.
      MOVE WA_REV-QTY TO ZZQTY.
      MOVE WA_REV-LENGTH TO ZZLENGTH.
      MOVE WA_REV-WIDTH TO ZZWIDTH.
      MOVE WA_REV-ZNOSHEET TO ZZNOSHEET.
      MOVE ZVTVALUE1 TO ZZVTVALUE1.
      MOVE ZVTVALUE2 TO ZZVTVALUE2.
*      ZZPEMBILANGASAL = ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 * 1000.
      ZZPENYEBUTASAL = 1000000000.
*      CALL FUNCTION 'CONVERT_TO_FRACT5'
*        EXPORTING
*          NOMIN               = ZZPEMBILANGASAL
*          DENOMIN             = ZZPENYEBUTASAL
*        IMPORTING
*          NOMOUT              = ZZPEMBILANGBARU
*          DENOMOUT            = ZZPENYEBUTBARU
*        EXCEPTIONS
*          CONVERSION_OVERFLOW = 1
*          OTHERS              = 2.

      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      IF WA_REV-ORTYPE NE 'ZP11'.
*        IF ZZPENYEBUTBARU NE 0.
        IF ZZGRAMMAGE NE ''.
          ZZTOTAL = ( ZZLENGTH * ZZWIDTH * ZZGRAMMAGE ) / 1000000. " ZZPENYEBUTASAL .
        ELSE.
          ZZTOTAL = ( ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 ) / 1000000. "ZZPENYEBUTASAL .
        ENDIF.
*        ENDIF.
      ELSEIF WA_REV-ORTYPE EQ 'ZP90'.
        ZZTOTAL  = 0.
      ELSEIF WA_REV-ORTYPE EQ 'ZP11'.
*        IF ZZPENYEBUTBARU NE 0.
        IF ZZGRAMMAGE = ''.
          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 ) / 1000000000 ) .
*          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZVTVALUE1 * ZZVTVALUE2 ) / ZZPENYEBUTASAL ) * ZZNOSHEET .
        ELSE.
*          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZGRAMMAGE ) / ZZPENYEBUTASAL ) * ZZNOSHEET .
          ZZTOTAL = ( ( ZZLENGTH * ZZWIDTH * ZZGRAMMAGE ) / 1000000000 )  .
        ENDIF.
*        ENDIF.
      ENDIF.

      CALL FUNCTION 'Z_MMUR_ROUND_FOR_FRACT5'
        EXPORTING
          I_VALUE        = ZZTOTAL
          I_DECIMALS     = 2
        IMPORTING
          O_VALUE        = ZZCONVERT
        EXCEPTIONS
          INPUT_INVALID  = 1
          OUTPUT_INVALID = 2
          OVERFLOWS      = 3
          OTHERS         = 4.

      IF WA_UPLOAD-ORTYPE EQ 'ZP11'.
        ZZTOTAL = ZZCONVERT * ZZQTY * ZZNOSHEET.
      ELSE.
        ZZTOTAL = ZZCONVERT * ZZQTY.
      ENDIF.

      IF ZZTOTAL = 0.
        ZZTOTAL = ZZQTY.
      ENDIF.
      ZZTOTALC = ZZTOTAL.
    ELSE.
      ZZTOTAL = ZZQTY.
      ZZTOTALC = ZZTOTAL.
    ENDIF.

    CONDENSE ZZTOTALC.
    CLEAR: BDC_DATA,L_TA_MSG,L_WA_MSG.
    REFRESH: BDC_DATA[],L_TA_MSG.

    SELECT SINGLE *
      FROM AFRU
      WHERE AUFNR EQ WA_REV-PONO AND
            STOKZ EQ ' ' AND
            STZHL EQ ' '.

    IF SY-SUBRC NE 0.
      CHECK1 = 'Y'.
    ELSE.
      CHECK1 = 'N'.
    ENDIF.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5110'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '/00'.
    BDC_FIELD BDC_DATA   'CAUFVD-AUFNR' WA_REV-PONO.
    BDC_FIELD BDC_DATA   'R62CLORD-FLG_COMPL' 'X'.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=TERM'.
    BDC_FIELD BDC_DATA   'CAUFVD-GAMNG' WA_REV-QTY.
    BDC_FIELD BDC_DATA   'CAUFVD-GLUZS' WA_REV-FTIME.
    BDC_FIELD BDC_DATA   'CAUFVD-GLTRS' WA_REV-FDATE.

    IF CHECK1 EQ 'Y'.
      BDC_FIELD BDC_DATA   'CAUFVD-GSTRS' WA_REV-SDATE.
      BDC_FIELD BDC_DATA   'CAUFVD-GSUZS' WA_REV-STIME.
    ENDIF.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=SLAP'.

    IF CHECK1 EQ 'Y'.
      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
      BDC_FIELD BDC_DATA   'BDC_OKCODE' '=STAK'.

      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5131'.
      BDC_FIELD BDC_DATA   'BDC_OKCODE' '=ENT1'.
      BDC_FIELD BDC_DATA   'RC62F-VER_SEL' 'X'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = WA_REV-PRODVER
        IMPORTING
          OUTPUT = WA_REV-PRODVER.
      BDC_FIELD BDC_DATA   'RC62F-PROD_VERS' WA_REV-PRODVER.
      BDC_FIELD BDC_DATA   'RC62F-NEW_ROUT' 'X'.
      BDC_FIELD BDC_DATA   'RC62F-NEW_BOM' 'X'.
    ENDIF.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=+COI'.

    IF CHECK1 EQ 'Y'.
      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
      BDC_FIELD BDC_DATA   'BDC_OKCODE'  '=FREI'.
      BDC_FIELD BDC_DATA   'ZFILM-ZCODE' WA_REV-TYPEFILM.
      BDC_FIELD BDC_DATA   'ZFILM-ZWIDTH' WA_REV-WIDTH.
      BDC_FIELD BDC_DATA   'ZFILM-ZLENGTH' WA_REV-LENGTH.
      BDC_FIELD BDC_DATA   'ZFILM-ZTREAT' WA_REV-TREATMENT.
      BDC_FIELD BDC_DATA   'ZFILM-ZLINE' WA_REV-PRODLINE.
      BDC_FIELD BDC_DATA   'ZFILM-ZMONTH' WA_REV-BTPROD.
      BDC_FIELD BDC_DATA   'ZFILM-ZCUSTM' WA_REV-CUST.
      BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_REV-ZNOSHEET.

      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
      BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=KOMG'.
    ELSE.
      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
      BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=KOMG'.
      BDC_FIELD BDC_DATA   'ZFILM-ZCODE' WA_REV-TYPEFILM.
      BDC_FIELD BDC_DATA   'ZFILM-ZWIDTH' WA_REV-WIDTH.
      BDC_FIELD BDC_DATA   'ZFILM-ZLENGTH' WA_REV-LENGTH.
      BDC_FIELD BDC_DATA   'ZFILM-ZTREAT' WA_REV-TREATMENT.
      BDC_FIELD BDC_DATA   'ZFILM-ZLINE' WA_REV-PRODLINE.
      BDC_FIELD BDC_DATA   'ZFILM-ZMONTH' WA_REV-BTPROD.
      BDC_FIELD BDC_DATA   'ZFILM-ZCUSTM' WA_REV-CUST.
      BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_REV-ZNOSHEET.
    ENDIF.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '0133'.
    BDC_FIELD  BDC_DATA  'BDC_CURSOR' 'CAUFVD-BMENGE'.
    BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=ENT1'.
    BDC_FIELD  BDC_DATA  'CAUFVD-BMENGE' ZZTOTALC.


    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=KOSD'.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD  BDC_DATA  'BDC_CURSOR' 'CAUFVD-AUTERM'.
    BDC_FIELD BDC_DATA   'CAUFVD-AUTERM' ''.

    BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
    BDC_FIELD BDC_DATA   'BDC_OKCODE' '=BU'.

    OPTION-DISMODE = 'N'.
    OPTION-UPDMODE = 'A'.
    OPTION-DEFSIZE = 'X'.

    CALL TRANSACTION 'COR2' USING BDC_DATA OPTIONS FROM OPTION MESSAGES INTO L_TA_MSG.
    COMMIT WORK AND WAIT.

*    DELETE L_TA_MSG WHERE MSGV1 = '' AND MSGV2 = ''.
    SORT L_TA_MSG BY MSGV1.
    DELETE ADJACENT DUPLICATES FROM L_TA_MSG COMPARING MSGV1.

    READ TABLE L_TA_MSG INTO L_WA_MSG WITH KEY MSGTYP = 'S'.

    IF SY-SUBRC = 0.
      LOOP AT L_TA_MSG INTO L_WA_MSG.
        MOVE-CORRESPONDING WA_REV TO W_REPORT.
        W_REPORT-AUFNR  = WA_REV-PONO.
*        W_REPORT-QTY    = ZZTOTALC.
        IF L_WA_MSG-MSGV1 NE '' OR L_WA_MSG-MSGV2 NE ''.
          CONCATENATE L_WA_MSG-MSGV1 L_WA_MSG-MSGV2 INTO W_REPORT-MSG SEPARATED BY SPACE.
        ELSE.
          CONCATENATE L_WA_MSG-MSGID L_WA_MSG-MSGNR INTO W_REPORT-MSG SEPARATED BY SPACE.
        ENDIF.
        W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
        APPEND W_REPORT TO T_REPORT.
      ENDLOOP.
    ELSE.

      LOOP AT L_TA_MSG INTO L_WA_MSG WHERE MSGTYP NE 'S'.
        MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
        W_REPORT-AUFNR  = WA_REV-PONO.
*        W_REPORT-QTY    = ZZTOTALC.
        IF L_WA_MSG-MSGV1 NE '' OR L_WA_MSG-MSGV2 NE ''.
          CONCATENATE L_WA_MSG-MSGV1 L_WA_MSG-MSGV2 INTO W_REPORT-MSG SEPARATED BY SPACE.
        ELSE.
          CONCATENATE L_WA_MSG-MSGID L_WA_MSG-MSGNR INTO W_REPORT-MSG SEPARATED BY SPACE.
        ENDIF.
        W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
        APPEND W_REPORT TO T_REPORT.
      ENDLOOP.

      LOOP AT TA_MESSAGE INTO WA_MESSAGE.
        MOVE-CORRESPONDING WA_REV TO W_REPORT.
        W_REPORT-AUFNR  = WA_REV-PONO.
*        W_REPORT-QTY    = ZZTOTALC.
        CONCATENATE WA_MESSAGE-MSGV1 WA_MESSAGE-MSGV2 INTO W_REPORT-MSG.
        W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
        APPEND W_REPORT TO T_REPORT.
      ENDLOOP.
    ENDIF.

    "Order for SBU
    READ TABLE L_TA_MSG INTO L_WA_MSG WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC NE 0 AND ( WA_REV-ORTYPE EQ 'ZP03'
                        OR WA_REV-ORTYPE EQ 'ZP04'
                        OR WA_REV-ORTYPE EQ 'ZP05'
                        OR WA_REV-ORTYPE EQ 'ZP06'
                        OR WA_REV-ORTYPE EQ 'ZP07'
                        OR WA_REV-ORTYPE EQ 'ZP08'
                        OR WA_REV-ORTYPE EQ 'ZP09'
                        OR WA_REV-ORTYPE EQ 'ZP12'
                        OR WA_REV-ORTYPE EQ 'ZP14'
                        OR WA_REV-ORTYPE EQ 'ZP18' )
                        AND ( WA_REV-PLANT EQ '1000' OR WA_REV-PLANT EQ '2000' )
                        AND V_STATUS EQ 'X'.

      REFRESH: IT_ZMAP_SBU, IT_AUFK.
      CLEAR: IT_ZMAP_SBU, IT_AUFK.

      SELECT AUFK~AUFNR INTO CORRESPONDING FIELDS OF TABLE IT_AUFK
        FROM AUFK
        JOIN AFPO ON AUFK~AUFNR EQ AFPO~AUFNR
       WHERE ZSBUORDER EQ WA_REV-PONO
         AND WERKS EQ WA_REV-PLANT
         AND AUART EQ 'ZMMS'.

      SORT IT_AUFK BY AUFNR.
      DELETE ADJACENT DUPLICATES FROM IT_AUFK COMPARING AUFNR.

      IF IT_AUFK[] IS INITIAL.
        "Check JR SBU
        V_SR = 'SR' && WA_REV-MATERIAL+2(10).

        SELECT SINGLE SBU_ASSET INTO V_SBU_AO
          FROM ZMAPPG
          JOIN T001K ON T001K~BUKRS EQ ZMAPPG~BUKRS
         WHERE MATNR EQ V_SR
           AND BWKEY EQ WA_REV-PLANT.

        "Check BOM
        SELECT SINGLE STLNR MAST~STLAL
          INTO (V_BOM, V_STLAL)
          FROM MKAL
          JOIN MAST ON MAST~MATNR EQ MKAL~MATNR AND MAST~WERKS EQ MKAL~WERKS AND MAST~STLAN EQ MKAL~STLAN AND MAST~STLAL EQ MKAL~STLAL
         WHERE MKAL~MATNR EQ WA_REV-MATERIAL
           AND MKAL~WERKS EQ WA_REV-PLANT
           AND MKAL~VERID EQ WA_REV-PRODVER.

        SELECT STPO~IDNRK AS MATNR MARA~MATKL
              INTO CORRESPONDING FIELDS OF TABLE IT_CHARG
              FROM STAS
              JOIN STPO ON STPO~STLNR EQ STAS~STLNR AND STPO~STLKN EQ STAS~STLKN
              JOIN MARA ON MARA~MATNR EQ STPO~IDNRK
             WHERE STPO~STLNR EQ V_BOM
               AND STAS~STLAL EQ V_STLAL
               AND MARA~MATKL LIKE '3%'
               AND MARA~MATNR LIKE 'SR%'.

        SORT IT_CHARG BY MATNR.
        DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING MATNR.

        LOOP AT IT_CHARG.
          CLEAR: V_SBU_AI.

          "Input material X atau O without mat to mat
          IF IT_CHARG-MATNR+5(1) EQ 'O' OR IT_CHARG-MATNR+5(1) EQ 'X'.
            CLEAR: V_SBU_AO.
            CONTINUE.
          ENDIF.

          "Check Material SR SBU Asset
          SELECT SINGLE SBU_ASSET INTO V_SBU_AI
            FROM ZMAPPG
            JOIN T001K ON T001K~BUKRS EQ ZMAPPG~BUKRS
           WHERE MATNR EQ IT_CHARG-MATNR
             AND BWKEY EQ WA_REV-PLANT.

          IF V_SBU_AI NE V_SBU_AO.
            CLEAR: V_MATNR_ACC.
            IF WA_REV-ORTYPE EQ 'ZP09'.
              SELECT SINGLE MATNR_ACC INTO V_MATNR_ACC FROM ZMAP_MAT_SBU WHERE WERKS      EQ WA_REV-PLANT
                                                                           AND MATNR_BF   EQ IT_CHARG-MATNR
                                                                           AND MATNR_OUT  EQ WA_REV-MATERIAL.
            ELSE.
              SELECT SINGLE MATNR_ACC INTO V_MATNR_ACC FROM ZMAP_MAT_SBU WHERE WERKS      EQ WA_REV-PLANT
                                                                         AND MATNR_OUT    EQ WA_REV-MATERIAL.
            ENDIF.

            IF V_MATNR_ACC IS NOT INITIAL.
              IT_ZMAP_SBU-WERKS     = WA_REV-PLANT.
              IT_ZMAP_SBU-MATNR_BF  = IT_CHARG-MATNR.
              IT_ZMAP_SBU-MATNR_ACC = V_MATNR_ACC.
              IT_ZMAP_SBU-MATNR_OUT = WA_REV-MATERIAL.
              APPEND IT_ZMAP_SBU.
              CLEAR IT_ZMAP_SBU.
            ENDIF.
          ENDIF.
        ENDLOOP.

        SORT IT_ZMAP_SBU BY MATNR_ACC.
        DELETE ADJACENT DUPLICATES FROM IT_ZMAP_SBU COMPARING MATNR_ACC.

        LOOP AT IT_ZMAP_SBU.
          CLEAR: V_AUFNR, V_COUNTER, V_TEMP.

          SELECT MAX( AUFNR ) INTO V_AUFNR FROM AUFK WHERE AUART EQ 'ZMMS'.

          IF V_AUFNR IS INITIAL.
            V_AUFNR = 'M10000000000'.
          ENDIF.

          V_COUNTER = V_AUFNR+2(10).

          ADD 1 TO V_COUNTER.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = V_COUNTER
            IMPORTING
              OUTPUT = V_COUNTER.

          V_AUFNR+2(10) = V_COUNTER.

          CLEAR: V_DATE, LS_SUBRC, TORDER, ORDERO.

          "Fill Data Order
          TORDER-ORDER_NUMBER     = V_AUFNR.
          TORDER-MATERIAL         = IT_ZMAP_SBU-MATNR_ACC.
          TORDER-PLANT            = WA_REV-PLANT.
          TORDER-ORDER_TYPE       = 'ZMMS'.
          TORDER-QUANTITY         = ZZTOTALC.
          TORDER-PROD_VERSION     = '1000'.

          CLEAR V_DATE.
          PERFORM CONVERT_DATE_I USING WA_REV-SDATE CHANGING V_DATE.
          TORDER-BASIC_START_DATE = V_DATE.
          CLEAR V_DATE.
          PERFORM CONVERT_DATE_I USING WA_REV-FDATE CHANGING V_DATE.
          TORDER-BASIC_END_DATE   = V_DATE.

          CALL FUNCTION 'BAPI_PROCORD_CREATE'
            EXPORTING
              ORDERDATA    = TORDER
            IMPORTING
              RETURN       = IT_RETURN
              ORDER_NUMBER = ORDERO.

          APPEND IT_RETURN.
          DELETE IT_RETURN WHERE TYPE IS INITIAL.

          LOOP AT IT_RETURN.
            IF IT_RETURN-TYPE EQ 'E'.
              READ TABLE T_REPORT INTO W_REPORT WITH KEY AUFNR = PONO MSG = ''.
              IF SY-SUBRC EQ 0.
                CONCATENATE 'PRO M2M not created: ' IT_RETURN-MESSAGE IT_RETURN-MESSAGE_V1 INTO W_REPORT-MSG SEPARATED BY SPACE.
                W_REPORT-MSGTYP = IT_RETURN-TYPE.
                MODIFY T_REPORT FROM W_REPORT TRANSPORTING MSGTYP MSG WHERE AUFNR EQ PONO AND MSG IS INITIAL.
              ELSE.
                MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
                CONCATENATE 'PRO M2M not created: ' IT_RETURN-MESSAGE IT_RETURN-MESSAGE_V1 INTO W_REPORT-MSG SEPARATED BY SPACE.
                W_REPORT-MSGTYP = IT_RETURN-TYPE.
                APPEND W_REPORT TO T_REPORT.
              ENDIF.
            ENDIF.

            IF IT_RETURN-TYPE EQ 'E' AND LS_SUBRC EQ 0.
              LS_SUBRC = 1.
            ENDIF.
          ENDLOOP.

          IF LS_SUBRC EQ 0.
            IT_AUFK-AUFNR = V_AUFNR.
            APPEND IT_AUFK.
          ENDIF.
        ENDLOOP.
      ENDIF.

      PERFORM PROCESS_DELAYING.

      LOOP AT IT_AUFK.
        CLEAR: BDC_DATA, L_TA_MSG,L_WA_MSG.
        REFRESH: BDC_DATA[], L_TA_MSG.

        BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5110'.
        BDC_FIELD BDC_DATA   'BDC_OKCODE' '/00'.
        BDC_FIELD BDC_DATA   'CAUFVD-AUFNR' IT_AUFK-AUFNR.
        BDC_FIELD BDC_DATA   'R62CLORD-FLG_COMPL' 'X'.


*         Quantity -------------------------------

        BDC_DYNPRO BDC_DATA   'SAPLCOKO' '5115'.
        BDC_FIELD BDC_DATA    'BDC_OKCODE' '=KOMG'.
        BDC_FIELD BDC_DATA    'BDC_CURSOR' 'CAUFVD-GAMNG'.

        CLEAR V_CLABS.
        MOVE WA_REV-QTY TO V_CLABS.
        BDC_FIELD BDC_DATA    'CAUFVD-GAMNG'  V_CLABS.

        "QTY STOCK
        CLEAR V_CLABS.
        MOVE ZZTOTALC TO V_CLABS.

*        BDC_FIELD BDC_DATA    'CAUFVD-BMENGE' V_CLABS.
        BDC_DYNPRO BDC_DATA   'SAPLCOKO' '0133'.
        BDC_FIELD BDC_DATA    'BDC_CURSOR' 'CAUFVD-BMENGE'.
        "QTY BATCH
        BDC_FIELD BDC_DATA    'BDC_OKCODE' '=ENT1'.
        CLEAR V_CLABS.
        MOVE WA_REV-QTY TO V_CLABS.
        BDC_FIELD BDC_DATA    'CAUFVD-GAMNG'  V_CLABS.

        "QTY STOCK
        CLEAR V_CLABS.
        MOVE ZZTOTALC TO V_CLABS.
        BDC_FIELD BDC_DATA    'CAUFVD-BMENGE' V_CLABS.

*          BDC_DYNPRO BDC_DATA   'SAPLCOKO' '5115'.
*          BDC_FIELD BDC_DATA    'BDC_OKCODE' '=OMLA'.
*          CLEAR V_CLABS.
*          MOVE WA_UPLOAD-QTY TO V_CLABS.
*          BDC_FIELD BDC_DATA    'CAUFVD-GAMNG'  V_CLABS.

        "QTY STOCK
        CLEAR V_CLABS.
        MOVE ZZTOTALC TO V_CLABS.
        BDC_FIELD BDC_DATA 'CAUFVD-BMENGE' V_CLABS.

*          ------------------------------

*      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
*      BDC_FIELD BDC_DATA   'BDC_OKCODE' '/00'.
*      BDC_FIELD BDC_DATA   'BDC_CURSOR' 'CAUFVD-BMENGE'.
*      BDC_FIELD BDC_DATA   'CAUFVD-BMENGE' ZZTOTALC.

*        SELECT SINGLE *
*          FROM AFRU
*         WHERE AUFNR EQ IT_AUFK-AUFNR AND
*          STOKZ EQ ' ' AND
*          STZHL EQ ' '.
*
*        IF SY-SUBRC NE 0.
*          CHECK1 = 'Y'.
*        ELSE.
*          CHECK1 = 'N'.
*        ENDIF.
*
*        BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
*        BDC_FIELD BDC_DATA   'BDC_OKCODE' '=TERM'.
*        BDC_FIELD BDC_DATA   'CAUFVD-GAMNG' WA_REV-QTY.
*        BDC_FIELD BDC_DATA   'CAUFVD-GLUZS' WA_REV-FTIME.
*        BDC_FIELD BDC_DATA   'CAUFVD-GLTRS' WA_REV-FDATE.
*
*        IF CHECK1 EQ 'Y'.
*          BDC_FIELD BDC_DATA   'CAUFVD-GSTRS' WA_REV-SDATE.
*          BDC_FIELD BDC_DATA   'CAUFVD-GSUZS' WA_REV-STIME.
*        ENDIF.

        BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
        BDC_FIELD BDC_DATA   'BDC_OKCODE' '=+COI'.
        BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
        BDC_FIELD BDC_DATA   'BDC_OKCODE' '/00'.

        BDC_FIELD BDC_DATA   'ZFILM-ZCODE'    WA_REV-TYPEFILM.
        BDC_FIELD BDC_DATA   'ZFILM-ZWIDTH'   WA_REV-WIDTH.
        BDC_FIELD BDC_DATA   'ZFILM-ZLENGTH'  WA_REV-LENGTH.
        BDC_FIELD BDC_DATA   'ZFILM-ZTREAT'   WA_REV-TREATMENT.
        BDC_FIELD BDC_DATA   'ZFILM-ZLINE'    WA_REV-PRODLINE.
        BDC_FIELD BDC_DATA   'ZFILM-ZMONTH'   WA_REV-BTPROD.
        BDC_FIELD BDC_DATA   'ZFILM-ZCUSTM'   WA_REV-CUST.
        BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_REV-ZNOSHEET.
        BDC_FIELD BDC_DATA   'ZFILM-ZSBUORDER' WA_REV-PONO.


*        IF CHECK1 EQ 'Y'.
*      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
*      BDC_FIELD BDC_DATA   'BDC_OKCODE'  '=FREI'.
*      BDC_FIELD BDC_DATA   'ZFILM-ZCODE' WA_REV-TYPEFILM.
*      BDC_FIELD BDC_DATA   'ZFILM-ZWIDTH' WA_REV-WIDTH.
*      BDC_FIELD BDC_DATA   'ZFILM-ZLENGTH' WA_REV-LENGTH.
*      BDC_FIELD BDC_DATA   'ZFILM-ZTREAT' WA_REV-TREATMENT.
*      BDC_FIELD BDC_DATA   'ZFILM-ZLINE' WA_REV-PRODLINE.
*      BDC_FIELD BDC_DATA   'ZFILM-ZMONTH' WA_REV-BTPROD.
*      BDC_FIELD BDC_DATA   'ZFILM-ZCUSTM' WA_REV-CUST.
*      BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_REV-ZNOSHEET.
*
*      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
*      BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=KOMG'.
*    ELSE.
*      BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
*      BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=KOMG'.
*      BDC_FIELD BDC_DATA   'ZFILM-ZCODE' WA_REV-TYPEFILM.
*      BDC_FIELD BDC_DATA   'ZFILM-ZWIDTH' WA_REV-WIDTH.
*      BDC_FIELD BDC_DATA   'ZFILM-ZLENGTH' WA_REV-LENGTH.
*      BDC_FIELD BDC_DATA   'ZFILM-ZTREAT' WA_REV-TREATMENT.
*      BDC_FIELD BDC_DATA   'ZFILM-ZLINE' WA_REV-PRODLINE.
*      BDC_FIELD BDC_DATA   'ZFILM-ZMONTH' WA_REV-BTPROD.
*      BDC_FIELD BDC_DATA   'ZFILM-ZCUSTM' WA_REV-CUST.
*      BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_REV-ZNOSHEET.
*    ENDIF.

        "Begin add new company
        IF WA_UPLOAD-ZRESEV IS NOT INITIAL.
          BDC_FIELD BDC_DATA   'ZFILM-ZNOSHEET' WA_REV-ZRESEV.
        ENDIF.
        "End add new company

*        BDC_DYNPRO BDC_DATA  'SAPLCOKO' '0133'.
*    BDC_FIELD  BDC_DATA  'BDC_CURSOR' 'CAUFVD-BMENGE'.
*    BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=ENT1'.
*    BDC_FIELD  BDC_DATA  'CAUFVD-BMENGE' ZZTOTALC.

        BDC_DYNPRO BDC_DATA  'SAPLCOKO' '5115'.
        BDC_FIELD  BDC_DATA  'BDC_OKCODE' '=BU'.

        OPTION-DISMODE = 'N'.
        OPTION-UPDMODE = 'A'.
        OPTION-DEFSIZE = 'X'.

        CALL TRANSACTION 'COR2' USING BDC_DATA OPTIONS FROM OPTION MESSAGES INTO L_TA_MSG.
        COMMIT WORK AND WAIT.

        LOOP AT L_TA_MSG INTO L_WA_MSG WHERE MSGTYP = 'E'.
          READ TABLE T_REPORT INTO W_REPORT WITH KEY AUFNR = WA_REV-PONO MSG = ''.
          IF SY-SUBRC EQ 0.
            SELECT SINGLE TEXT INTO W_REPORT-MSG FROM T100 WHERE SPRSL = 'E' AND ARBGB = L_WA_MSG-MSGID AND MSGNR = L_WA_MSG-MSGNR.
            REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV1.
            REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV2.
            W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
            MODIFY T_REPORT FROM W_REPORT TRANSPORTING MSGTYP MSG WHERE AUFNR EQ WA_REV-PONO AND MSG IS INITIAL.
          ELSE.
            MOVE-CORRESPONDING WA_UPLOAD TO W_REPORT.
            W_REPORT-AUFNR  = PONO.
            SELECT SINGLE TEXT INTO W_REPORT-MSG FROM T100 WHERE SPRSL = 'E' AND ARBGB = L_WA_MSG-MSGID AND MSGNR = L_WA_MSG-MSGNR.
            REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV1.
            REPLACE FIRST OCCURRENCE OF '&' IN W_REPORT-MSG WITH L_WA_MSG-MSGV2.
            W_REPORT-MSGTYP = L_WA_MSG-MSGTYP.
            APPEND W_REPORT TO T_REPORT.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " REVISI_PO
*&---------------------------------------------------------------------*
*&      Form  F4_OPEN_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_OPEN_FILE .
  " EXCEL
*  DATA: LT_FILETABLE    TYPE FILETABLE,
*        LX_FILETABLE    TYPE FILE_TABLE,
*        LV_RETURN_CODE  TYPE I,
*        LV_WINDOW_TITLE TYPE STRING.
*
*  LV_WINDOW_TITLE = TEXT-001.
*
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*    EXPORTING
*      WINDOW_TITLE            = LV_WINDOW_TITLE
*      DEFAULT_EXTENSION       = C_EXT_XLS
*    CHANGING
*      FILE_TABLE              = LT_FILETABLE
*      RC                      = LV_RETURN_CODE
*    EXCEPTIONS
*      FILE_OPEN_DIALOG_FAILED = 1
*      CNTL_ERROR              = 2
*      ERROR_NO_GUI            = 3
*      NOT_SUPPORTED_BY_GUI    = 4
*      OTHERS                  = 5.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  READ TABLE LT_FILETABLE INTO LX_FILETABLE INDEX 1.
*  P_FILE = LX_FILETABLE-FILENAME.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = P_FILE.
  IF SY-SUBRC <> 0 OR P_FILE EQ ''.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.                    " F4_OPEN_FILE
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITAB .

  DELETE T_EXCEL_TAB WHERE ROW = '0001'.


  LOOP AT T_EXCEL_TAB INTO W_EXCEL_TAB.

    CASE W_EXCEL_TAB-COL.
      WHEN 0001.
        ITAB-PONO = W_EXCEL_TAB-VALUE .
      WHEN 0002.
        ITAB-MATERIAL = W_EXCEL_TAB-VALUE .
      WHEN 0003.
        ITAB-PLANT = W_EXCEL_TAB-VALUE .
      WHEN 0004.
        ITAB-ORTYPE = W_EXCEL_TAB-VALUE .
      WHEN 0005.
        ITAB-QTY = W_EXCEL_TAB-VALUE .
      WHEN 0006.
        ITAB-UOM = W_EXCEL_TAB-VALUE .
      WHEN 0007.
        ITAB-SDATE = W_EXCEL_TAB-VALUE .
      WHEN 0008.
        ITAB-STIME = W_EXCEL_TAB-VALUE .
      WHEN 0009.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = W_EXCEL_TAB-VALUE
          IMPORTING
            OUTPUT = ITAB-PRODVER.

      WHEN 0010.
        ITAB-TYPEFILM = W_EXCEL_TAB-VALUE .
      WHEN 00011.
        ITAB-WIDTH  = W_EXCEL_TAB-VALUE .
      WHEN 0012.
        ITAB-LENGTH = W_EXCEL_TAB-VALUE .
      WHEN 0013.
        ITAB-TREATMENT = W_EXCEL_TAB-VALUE .
      WHEN 0014.
        ITAB-PRODLINE = W_EXCEL_TAB-VALUE .
      WHEN 0015.
        ITAB-BTPROD = W_EXCEL_TAB-VALUE .
      WHEN 0016.
        ITAB-CUST = W_EXCEL_TAB-VALUE .
        APPEND ITAB.
    ENDCASE.
  ENDLOOP.



ENDFORM.                    " INSERT_ITAB
*&---------------------------------------------------------------------*
*&      Form  REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REPORT .
  DELETE T_REPORT WHERE MSG = ''.
  LOOP AT T_REPORT INTO W_REPORT.
    CASE W_REPORT-MSGTYP.
      WHEN 'E'.
        W_REPORT-ICON = '@0A@'."  Red light; negative
      WHEN 'W'.
        W_REPORT-ICON = '@09@'."  Yellow light; neutral''.
      WHEN 'S'.
        W_REPORT-ICON = '@08@'."  Green light; positive
    ENDCASE.
    MODIFY T_REPORT FROM W_REPORT INDEX SY-TABIX.
  ENDLOOP.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " REPORT

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
*  T_PRINT-NO_PRINT_LISTINFOS = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
*     IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
*     I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = T_REPORT
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.


ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  REFRESH FT_EXTAB.
  CLEAR FT_EXTAB.

  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING FT_EXTAB.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  CASE FU_UCOMM.
    WHEN '&BACK'.
      LEAVE SCREEN.
    WHEN '&EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  WA_LAYOUT-ZEBRA                = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT  = 'X'.
*  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-BOX_TABNAME          = 'T_HEADER'.
  WA_LAYOUT-EXPAND_FIELDNAME     = 'EXPAND'.
  WA_LAYOUT-EXPAND_ALL           = 'X'.
  WA_LAYOUT-CELL_MERGE           = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE    = 'X'.
  WA_LAYOUT-INFO_FIELDNAME       = 'LINE_COL'.
ENDFORM.                    " F_LAYOUT

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
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'TA_DETAIL' :
   'PLANT'      '' ''  '' '4' 'Plant'   '' ' ' '' '' ,
   'PRODLINE'   '' ''  '' '20' 'Production Line'   '' ' ' '' '' ,
   'AUFNR'      '' ''  '' '10' 'PO No'   '' ' ' '' '' ,
   'TIPEFILM'   '' ''  '' '100' 'Tipe Film'   '' ' ' '' '' ,
   'WIDTH'      '' ''  '' '20' 'Width(per roll)'   '' ' ' '' '' ,
   'LENGTH'     '' ''  '' '20' 'Length(per roll)'   '' ' ' '' '' ,
   'TREATMENT'  '' ''  '' '20' 'Treatment'   '' ' ' '' '' ,
   'QTY'        '' ''  '' '10' 'Quantity'   '' ' ' '' '' ,
   'UOM'        '' ''  '' '20' 'UOM'   '' ' ' '' '' ,
   'CUST'       '' ''  '' '20' 'Customer'   '' ' ' '' '' ,
   'SDATE'      '' ''  '' '20' 'Start Date'   '' ' ' '' '' ,
   'STIME'      '' ''  '' '20' 'Start Time'   '' ' ' '' '' ,
   'FDATE'      '' ''  '' '20' 'Finish Date'   '' ' ' '' '' ,
   'FTIME'      '' ''  '' '20' 'Finish Time'   '' ' ' '' '' ,
   'BTPROD'     '' ''  '' '20' 'Bulan/Tahun Produksi'   '' ' ' '' '' ,
   'MATERIAL'   '' ''  '' '20' 'Material'   '' ' ' '' '' ,
   'TYPEFILM'   '' ''  '' '20' 'Kode Film'   '' ' ' '' '' ,
   'ORTYPE'     '' ''  '' '20' 'Order Type'   '' ' ' '' '' ,
   'PRODVER'    '' ''  '' '20' 'Prod. Version'   '' ' ' '' '' ,
   'ZNOSHEET'   '' ''  '' '20' 'Number of Sheets'   '' ' ' '' '' ,
   'MSG'        '' ''  '' '200' 'Message'   '' ' ' '' '' ,
   'ICON'       '' ''  '' '4' 'Monitor'   '' ' ' '' '' .

ENDFORM.                    " F_FIELD_CATALOG


*&---------------------------------------------------------------------*
*&      Form  INSERT_TO_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_TO_SQL.
  RANGES : R_AUFNR FOR AUFK-AUFNR.

  LOOP AT T_REPORT INTO W_REPORT." WHERE AUFNR IS NOT INITIAL.
    R_AUFNR-SIGN = 'I'.
    R_AUFNR-OPTION = 'EQ'.
    R_AUFNR-LOW = W_REPORT-AUFNR.
    APPEND R_AUFNR.
    CLEAR R_AUFNR.
  ENDLOOP.

  IF R_AUFNR[] IS NOT INITIAL.
    DELETE R_AUFNR WHERE LOW IS INITIAL.
    SUBMIT ZTPPR_JR_PLANNING WITH S_AUFNR IN R_AUFNR AND RETURN.
  ENDIF.
ENDFORM.                    "INSERT_TO_SQL

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DELAYING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PROCESS_DELAYING .
  DATA : X1 TYPE P DECIMALS 4.                              "#EC NEEDED
  DO 80000 TIMES.
    X1 = SQRT( SY-INDEX ) / SQRT( SY-INDEX ).
  ENDDO.
  WAIT UP TO 3 SECONDS. "ADD DELAY TIME
ENDFORM.                    " PROCESS_DELAYING


*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATE_O
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DATE       text
*      -->ZDATE      text
*----------------------------------------------------------------------*
FORM CONVERT_DATE_O USING DATE CHANGING ZDATE.
  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      INPUT  = DATE
    IMPORTING
      OUTPUT = ZDATE.
ENDFORM.                    "CONVERT_DATE

*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATE_I
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DATE       text
*      -->ZDATE      text
*----------------------------------------------------------------------*
FORM CONVERT_DATE_I USING DATE CHANGING ZDATE.
  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      DATE_EXTERNAL            = DATE
    IMPORTING
      DATE_INTERNAL            = ZDATE
    EXCEPTIONS
      DATE_EXTERNAL_IS_INVALID = 1
      OTHERS                   = 2.
ENDFORM.                    "CONVERT_DATE_I

*&---------------------------------------------------------------------*
*&      Form  GET_MAPPING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MAPPING.
  SELECT VALUE AS LOW INTO CORRESPONDING FIELDS OF TABLE R_MATKL
    FROM ZMAP_TYPE
   WHERE TCODE  EQ SY-TCODE
     AND TYPE   EQ 'MATERIAL GROUP'
     AND OPT    EQ 'SUBCONTRACTING'.

  IF SY-SUBRC EQ 0.
    R_MATKL-SIGN = 'I'.
    R_MATKL-OPTION = 'EQ'.
    MODIFY R_MATKL TRANSPORTING OPTION SIGN WHERE SIGN = ''.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_TREATMENT
    FROM ZMAP_TYPE
   WHERE TCODE    EQ SY-TCODE
     AND TYPE     EQ 'TREATMENT'
     AND DELETION EQ ''.
ENDFORM.                    "GET_MAPPING