*&---------------------------------------------------------------------*
*& Report  ZPPR_ZPP001
*&---------------------------------------------------------------------*
*& Program Name : ZPPR_ZPP001
*& Description  : Report Monitoring Hasil Transaksi Slitting (ZPP001)
*& Module       : PP (Production Planning) - Slitting Process
*& Target System: SAP NetWeaver 7.31 (ECC 6.0 EHP6)
*& Author       : SAP ABAP Senior Consultant
*& Date         : 28.10.2026
*&---------------------------------------------------------------------*
*& Catatan:
*& Program ini merangkum hasil eksekusi transaksi ZPP001 (Slitting
*& Process - Batch Defined) yang memproses Combine Order dan Original
*& Order, mencakup Order Header, Batch Output (Slit Roll), Karakteristik
*& Batch (Lebar, Panjang, Grade, No Roll), Status Order, dan Sales Order.
*&---------------------------------------------------------------------*
REPORT zppr_zpp001 NO STANDARD PAGE HEADING
                   LINE-SIZE 255.

TYPE-POOLS: slis, icon.

*----------------------------------------------------------------------*
* TABLES DEFINITION FOR SELECTION SCREEN
*----------------------------------------------------------------------*
TABLES: aufk, afko, afpo, crhd.

*----------------------------------------------------------------------*
* TYPES DEFINITION
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_aufk,
         aufnr TYPE aufnr,
         auart TYPE aufart,
         werks TYPE werks_d,
         ktext TYPE ktext,
         objnr TYPE j_objnr,
         erdat TYPE erdat,
       END OF ty_aufk.

TYPES: BEGIN OF ty_afko,
         aufnr TYPE aufnr,
         plnbez TYPE matnr,
         gamng TYPE gamng,
         gmein TYPE meins,
         aufpl TYPE co_aufpl,
         gltrp TYPE co_gltrp,
         gstrp TYPE co_gstrp,
       END OF ty_afko.

TYPES: BEGIN OF ty_afpo,
         aufnr          TYPE aufnr,
         posnr          TYPE co_posnr,
         pwerk          TYPE werks_d,
         matnr          TYPE matnr,
         charg          TYPE charg_d,
         kdauf          TYPE kdauf,
         kdpos          TYPE kdpos,
         mill_oc_aufnr_u TYPE aufnr,
         wemng          TYPE wemng,
         pamng          TYPE pamng,
         ablad          TYPE ablad,
         lgort          TYPE lgort_d,
       END OF ty_afpo.

TYPES: BEGIN OF ty_crhd,
         aufpl TYPE co_aufpl,
         arbpl TYPE arbpl,
         ktext TYPE cr_ktext,
       END OF ty_crhd.

TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbeln_va,
         kunnr TYPE kunag,
         name1 TYPE name1_gp,
       END OF ty_vbak.

TYPES: BEGIN OF ty_makt,
         matnr TYPE matnr,
         maktx TYPE maktx,
       END OF ty_makt.

TYPES: BEGIN OF ty_char_val,
         charg TYPE charg_d,
         width TYPE atwrt,
         leng  TYPE atwrt,
         grade TYPE atwrt,
         norol TYPE atwrt,
         pline TYPE atwrt,
       END OF ty_char_val.

TYPES: BEGIN OF ty_status,
         objnr TYPE j_objnr,
         txt04 TYPE j_txt04,
         txt30 TYPE j_txt30,
       END OF ty_status.

* ALV Output Structure
TYPES: BEGIN OF ty_output,
         werks          TYPE werks_d,
         arbpl          TYPE arbpl,
         arbpl_txt      TYPE cr_ktext,
         aufnr          TYPE aufnr,
         auart          TYPE aufart,
         orord          TYPE aufnr,
         matnr          TYPE matnr,
         maktx          TYPE maktx,
         ablad          TYPE ablad,
         charg          TYPE charg_d,
         norol          TYPE atwrt,
         width          TYPE atwrt,
         leng           TYPE atwrt,
         grade          TYPE atwrt,
         gamng          TYPE gamng,
         wemng          TYPE wemng,
         gmein          TYPE meins,
         kdauf          TYPE kdauf,
         kdpos          TYPE kdpos,
         kunnr          TYPE kunag,
         name1          TYPE name1_gp,
         lgort          TYPE lgort_d,
         status         TYPE j_txt04,
         status_txt     TYPE j_txt30,
         gltrp          TYPE co_gltrp,
         gstrp          TYPE co_gstrp,
         status_icon    TYPE icon_d,
       END OF ty_output.

*----------------------------------------------------------------------*
* INTERNAL TABLES & WORK AREAS
*----------------------------------------------------------------------*
DATA: gt_aufk       TYPE STANDARD TABLE OF ty_aufk,
      gt_afko       TYPE STANDARD TABLE OF ty_afko,
      gt_afpo       TYPE STANDARD TABLE OF ty_afpo,
      gt_crhd       TYPE STANDARD TABLE OF ty_crhd,
      gt_vbak       TYPE STANDARD TABLE OF ty_vbak,
      gt_makt       TYPE STANDARD TABLE OF ty_makt,
      gt_char_val   TYPE STANDARD TABLE OF ty_char_val,
      gt_status     TYPE STANDARD TABLE OF ty_status,
      gt_output     TYPE STANDARD TABLE OF ty_output.

DATA: gs_output     TYPE ty_output.

* ALV Grid Data
DATA: gt_fieldcat   TYPE slis_t_fieldcat_alv,
      gs_layout     TYPE slis_layout_alv,
      gt_events     TYPE slis_t_event_alv,
      gt_header     TYPE slis_t_listheader_alv.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-s01.
SELECT-OPTIONS: s_werks FOR aufk-werks OBLIGATORY,
                s_auart FOR aufk-auart,
                s_aufnr FOR aufk-aufnr,
                s_matnr FOR afpo-matnr,
                s_gltrp FOR afko-gltrp,
                s_charg FOR afpo-charg,
                s_arbpl FOR crhd-arbpl,
                s_kdauf FOR afpo-kdauf.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-s02.
PARAMETERS: p_dlv AS CHECKBOX DEFAULT ' ', " Hanya order berstatus DLV/Completed
            p_det AS CHECKBOX DEFAULT 'X'. " Tampilkan baris per batch slit
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  " Default text jika text element belum terpasang
  %_s_werks_%_app_%-text = 'Plant'.
  %_s_auart_%_app_%-text = 'Order Type'.
  %_s_aufnr_%_app_%-text = 'Order Number'.
  %_s_matnr_%_app_%-text = 'Material Number'.
  %_s_gltrp_%_app_%-text = 'Prod. Finish Date'.
  %_s_charg_%_app_%-text = 'Output Batch'.
  %_s_arbpl_%_app_%-text = 'Resource / Slitter'.
  %_s_kdauf_%_app_%-text = 'Sales Order'.
  %_p_dlv_%_app_%-text   = 'Only Goods Receipt (DLV)'.
  %_p_det_%_app_%-text   = 'Detail per Slit Batch'.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  PERFORM build_output.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF gt_output IS INITIAL.
    MESSAGE 'Tidak ada data transaksi ZPP001 yang sesuai kriteria.' TYPE 'S' DISPLAY LIKE 'W'.
    EXIT.
  ENDIF.
  PERFORM display_alv.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data.
  DATA: lt_objnr TYPE STANDARD TABLE OF j_objnr,
        lv_objnr TYPE j_objnr,
        ls_aufk  TYPE ty_aufk,
        ls_afko  TYPE ty_afko,
        ls_afpo  TYPE ty_afpo.

  CLEAR: gt_aufk, gt_afko, gt_afpo, gt_crhd, gt_vbak, gt_makt,
         gt_char_val, gt_status, gt_output.

  " 1. Ambil Order Header dari AUFK
  SELECT aufnr auart werks ktext objnr erdat
    FROM aufk
    INTO TABLE gt_aufk
    WHERE aufnr IN s_aufnr
      AND werks IN s_werks
      AND auart IN s_auart.

  IF gt_aufk IS INITIAL.
    EXIT.
  ENDIF.

  SORT gt_aufk BY aufnr.

  " 2. Ambil Data Tambahan Order dari AFKO
  SELECT aufnr plnbez gamng gmein aufpl gltrp gstrp
    FROM afko
    INTO TABLE gt_afko
    FOR ALL ENTRIES IN gt_aufk
    WHERE aufnr = gt_aufk-aufnr
      AND gltrp IN s_gltrp.

  IF gt_afko IS INITIAL.
    CLEAR gt_aufk.
    EXIT.
  ENDIF.

  SORT gt_afko BY aufnr.

  " Filter balik AUFK agar sinkron dengan AFKO
  LOOP AT gt_aufk INTO ls_aufk.
    READ TABLE gt_afko WITH KEY aufnr = ls_aufk-aufnr
      BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      DELETE gt_aufk.
    ENDIF.
  ENDLOOP.

  IF gt_aufk IS INITIAL.
    EXIT.
  ENDIF.

  " 3. Ambil Item Order & Batch Hasil Slitting dari AFPO
  SELECT aufnr posnr pwerk matnr charg kdauf kdpos
         mill_oc_aufnr_u wemng pamng ablad lgort
    FROM afpo
    INTO TABLE gt_afpo
    FOR ALL ENTRIES IN gt_afko
    WHERE aufnr = gt_afko-aufnr
      AND matnr IN s_matnr
      AND charg IN s_charg
      AND kdauf IN s_kdauf.

  IF gt_afpo IS INITIAL.
    EXIT.
  ENDIF.

  SORT gt_afpo BY aufnr posnr.

  " 4. Ambil Work Center / Resource dari AFVC + CRHD
  SELECT afvc~aufpl crhd~arbpl crhd~ktext
    FROM afvc
    INNER JOIN crhd ON crhd~objid = afvc~arbid
    INTO TABLE gt_crhd
    FOR ALL ENTRIES IN gt_afko
    WHERE afvc~aufpl = gt_afko-aufpl
      AND ( afvc~steus = 'ZP01' OR afvc~steus = 'ZP02' )
      AND crhd~arbpl IN s_arbpl.

  SORT gt_crhd BY aufpl.

  " 5. Ambil Sales Order & Customer Name dari VBAK + KNA1
  SELECT vbak~vbeln vbak~kunnr kna1~name1
    FROM vbak
    INNER JOIN kna1 ON kna1~kunnr = vbak~kunnr
    INTO TABLE gt_vbak
    FOR ALL ENTRIES IN gt_afpo
    WHERE vbak~vbeln = gt_afpo-kdauf.

  SORT gt_vbak BY vbeln.

  " 6. Ambil Deskripsi Material dari MAKT
  SELECT matnr maktx
    FROM makt
    INTO TABLE gt_makt
    FOR ALL ENTRIES IN gt_afpo
    WHERE matnr = gt_afpo-matnr
      AND spras = sy-langu.

  SORT gt_makt BY matnr.

  " 7. Ambil Status Sistem Order
  PERFORM get_status_multi.

  " 8. Ambil Karakteristik Batch Hasil Slitting (AUSP / CABN)
  PERFORM get_batch_classification.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_STATUS_MULTI
*&---------------------------------------------------------------------*
FORM get_status_multi.
  DATA: ls_aufk   TYPE ty_aufk,
        lv_objnr  TYPE j_objnr,
        lt_jstat  TYPE STANDARD TABLE OF jstat,
        ls_jstat  TYPE jstat,
        ls_status TYPE ty_status,
        lt_tj02t  TYPE STANDARD TABLE OF tj02t,
        ls_tj02t  TYPE tj02t.

  " Ambil teks status aktif sistem
  SELECT * FROM tj02t
    INTO TABLE lt_tj02t
    WHERE spras = sy-langu
      AND txt04 IN ('CRTD', 'REL', 'PCNF', 'CNF', 'DLV', 'TECO', 'CLSD').

  SORT lt_tj02t BY istat.

  LOOP AT gt_aufk INTO ls_aufk.
    lv_objnr = ls_aufk-objnr.
    IF lv_objnr IS INITIAL.
      CONCATENATE 'OR' ls_aufk-aufnr INTO lv_objnr.
    ENDIF.

    CLEAR: lt_jstat, ls_status.
    CALL FUNCTION 'STATUS_READ'
      EXPORTING
        objnr       = lv_objnr
        only_active = 'X'
      TABLES
        status      = lt_jstat
      EXCEPTIONS
        OTHERS      = 1.

    IF sy-subrc = 0.
      ls_status-objnr = lv_objnr.

      " Prioritas evaluasi status slitting (TECO > CLSD > DLV > CNF > PCNF > REL > CRTD)
      READ TABLE lt_jstat WITH KEY stat = 'I0045' TRANSPORTING NO FIELDS. " TECO
      IF sy-subrc = 0.
        ls_status-txt04 = 'TECO'.
        ls_status-txt30 = 'Technically Completed'.
      ELSE.
        READ TABLE lt_jstat WITH KEY stat = 'I0046' TRANSPORTING NO FIELDS. " CLSD
        IF sy-subrc = 0.
          ls_status-txt04 = 'CLSD'.
          ls_status-txt30 = 'Closed'.
        ELSE.
          READ TABLE lt_jstat WITH KEY stat = 'I0012' TRANSPORTING NO FIELDS. " DLV
          IF sy-subrc = 0.
            ls_status-txt04 = 'DLV'.
            ls_status-txt30 = 'Delivered / GR'.
          ELSE.
            READ TABLE lt_jstat WITH KEY stat = 'I0010' TRANSPORTING NO FIELDS. " CNF
            IF sy-subrc = 0.
              ls_status-txt04 = 'CNF'.
              ls_status-txt30 = 'Confirmed'.
            ELSE.
              READ TABLE lt_jstat WITH KEY stat = 'I0009' TRANSPORTING NO FIELDS. " PCNF
              IF sy-subrc = 0.
                ls_status-txt04 = 'PCNF'.
                ls_status-txt30 = 'Partially Confirmed'.
              ELSE.
                READ TABLE lt_jstat WITH KEY stat = 'I0002' TRANSPORTING NO FIELDS. " REL
                IF sy-subrc = 0.
                  ls_status-txt04 = 'REL'.
                  ls_status-txt30 = 'Released / Active'.
                ELSE.
                  ls_status-txt04 = 'CRTD'.
                  ls_status-txt30 = 'Created'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND ls_status TO gt_status.
    ENDIF.
  ENDLOOP.

  SORT gt_status BY objnr.
ENDFORM.                    " GET_STATUS_MULTI

*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_CLASSIFICATION
*&---------------------------------------------------------------------*
FORM get_batch_classification.
  TYPES: BEGIN OF ty_mch1_key,
           matnr    TYPE matnr,
           charg    TYPE charg_d,
           cuobj_bm TYPE cuobj_bm,
         END OF ty_mch1_key.

  TYPES: BEGIN OF ty_ausp_val,
           objek TYPE cuob_obkey,
           atnam TYPE atnam,
           atwrt TYPE atwrt,
         END OF ty_ausp_val.

  DATA: lt_mch1     TYPE STANDARD TABLE OF ty_mch1_key,
        ls_mch1     TYPE ty_mch1_key,
        lt_ausp     TYPE STANDARD TABLE OF ty_ausp_val,
        ls_ausp     TYPE ty_ausp_val,
        ls_char_val TYPE ty_char_val,
        lt_charg    TYPE STANDARD TABLE OF ty_afpo,
        ls_charg    TYPE ty_afpo.

  " Filter hanya item yang memiliki nomor batch
  lt_charg = gt_afpo.
  DELETE lt_charg WHERE charg IS INITIAL.

  IF lt_charg IS INITIAL.
    EXIT.
  ENDIF.

  SORT lt_charg BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_charg COMPARING matnr charg.

  SELECT matnr charg cuobj_bm
    FROM mch1
    INTO TABLE lt_mch1
    FOR ALL ENTRIES IN lt_charg
    WHERE matnr = lt_charg-matnr
      AND charg = lt_charg-charg
      AND cuobj_bm <> 0.

  IF lt_mch1 IS INITIAL.
    EXIT.
  ENDIF.

  SORT lt_mch1 BY cuobj_bm.

  " Ambil nilai karakteristik batch slitting
  SELECT ausp~objek cabn~atnam ausp~atwrt
    FROM ausp
    INNER JOIN cabn ON cabn~atinn = ausp~atinn
    INTO TABLE lt_ausp
    FOR ALL ENTRIES IN lt_mch1
    WHERE ausp~objek = lt_mch1-cuobj_bm
      AND cabn~atnam IN ('ZZWIDTH', 'ZZLENGTH', 'ZZGRADE', 'ZZNOMORROLL', 'ZZPRODLINE').

  SORT lt_ausp BY objek atnam.

  LOOP AT lt_mch1 INTO ls_mch1.
    CLEAR ls_char_val.
    ls_char_val-charg = ls_mch1-charg.

    READ TABLE lt_ausp INTO ls_ausp WITH KEY objek = ls_mch1-cuobj_bm atnam = 'ZZWIDTH' BINARY SEARCH.
    IF sy-subrc = 0.
      ls_char_val-width = ls_ausp-atwrt.
    ENDIF.

    READ TABLE lt_ausp INTO ls_ausp WITH KEY objek = ls_mch1-cuobj_bm atnam = 'ZZLENGTH' BINARY SEARCH.
    IF sy-subrc = 0.
      ls_char_val-leng = ls_ausp-atwrt.
    ENDIF.

    READ TABLE lt_ausp INTO ls_ausp WITH KEY objek = ls_mch1-cuobj_bm atnam = 'ZZGRADE' BINARY SEARCH.
    IF sy-subrc = 0.
      ls_char_val-grade = ls_ausp-atwrt.
    ENDIF.

    READ TABLE lt_ausp INTO ls_ausp WITH KEY objek = ls_mch1-cuobj_bm atnam = 'ZZNOMORROLL' BINARY SEARCH.
    IF sy-subrc = 0.
      ls_char_val-norol = ls_ausp-atwrt.
    ENDIF.

    READ TABLE lt_ausp INTO ls_ausp WITH KEY objek = ls_mch1-cuobj_bm atnam = 'ZZPRODLINE' BINARY SEARCH.
    IF sy-subrc = 0.
      ls_char_val-pline = ls_ausp-atwrt.
    ENDIF.

    APPEND ls_char_val TO gt_char_val.
  ENDLOOP.

  SORT gt_char_val BY charg.
ENDFORM.                    " GET_BATCH_CLASSIFICATION

*&---------------------------------------------------------------------*
*&      Form  BUILD_OUTPUT
*&---------------------------------------------------------------------*
FORM build_output.
  DATA: ls_aufk     TYPE ty_aufk,
        ls_afko     TYPE ty_afko,
        ls_afpo     TYPE ty_afpo,
        ls_crhd     TYPE ty_crhd,
        ls_vbak     TYPE ty_vbak,
        ls_makt     TYPE ty_makt,
        ls_status   TYPE ty_status,
        ls_char_val TYPE ty_char_val,
        lv_objnr    TYPE j_objnr.

  CLEAR gt_output.

  LOOP AT gt_afpo INTO ls_afpo.
    CLEAR gs_output.

    READ TABLE gt_aufk INTO ls_aufk WITH KEY aufnr = ls_afpo-aufnr BINARY SEARCH.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_afko INTO ls_afko WITH KEY aufnr = ls_afpo-aufnr BINARY SEARCH.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    " Status filter
    lv_objnr = ls_aufk-objnr.
    IF lv_objnr IS INITIAL.
      CONCATENATE 'OR' ls_aufk-aufnr INTO lv_objnr.
    ENDIF.

    READ TABLE gt_status INTO ls_status WITH KEY objnr = lv_objnr BINARY SEARCH.
    IF p_dlv = 'X' AND ls_status-txt04 <> 'DLV'.
      CONTINUE.
    ENDIF.

    " Assignment Field Dasar
    gs_output-werks     = ls_aufk-werks.
    gs_output-aufnr     = ls_afpo-aufnr.
    gs_output-auart     = ls_aufk-auart.
    gs_output-orord     = ls_afpo-mill_oc_aufnr_u.
    gs_output-matnr     = ls_afpo-matnr.
    gs_output-ablad     = ls_afpo-ablad.
    gs_output-charg     = ls_afpo-charg.
    gs_output-gamng     = ls_afko-gamng.
    gs_output-wemng     = ls_afpo-wemng.
    gs_output-gmein     = ls_afko-gmein.
    gs_output-kdauf     = ls_afpo-kdauf.
    gs_output-kdpos     = ls_afpo-kdpos.
    gs_output-lgort     = ls_afpo-lgort.
    gs_output-gltrp     = ls_afko-gltrp.
    gs_output-gstrp     = ls_afko-gstrp.

    " Status
    IF ls_status-txt04 IS NOT INITIAL.
      gs_output-status     = ls_status-txt04.
      gs_output-status_txt = ls_status-txt30.
      CASE ls_status-txt04.
        WHEN 'DLV'.
          gs_output-status_icon = icon_checked.
        WHEN 'CNF' OR 'PCNF'.
          gs_output-status_icon = icon_incomplete.
        WHEN 'REL'.
          gs_output-status_icon = icon_execute.
        WHEN 'TECO' OR 'CLSD'.
          gs_output-status_icon = icon_locked.
        WHEN OTHERS.
          gs_output-status_icon = icon_create.
      ENDCASE.
    ENDIF.

    " Work Center
    READ TABLE gt_crhd INTO ls_crhd WITH KEY aufpl = ls_afko-aufpl BINARY SEARCH.
    IF sy-subrc = 0.
      gs_output-arbpl     = ls_crhd-arbpl.
      gs_output-arbpl_txt = ls_crhd-ktext.
    ENDIF.

    " Material Text
    READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_afpo-matnr BINARY SEARCH.
    IF sy-subrc = 0.
      gs_output-maktx     = ls_makt-maktx.
    ENDIF.

    " Customer & Sales Order
    READ TABLE gt_vbak INTO ls_vbak WITH KEY vbeln = ls_afpo-kdauf BINARY SEARCH.
    IF sy-subrc = 0.
      gs_output-kunnr     = ls_vbak-kunnr.
      gs_output-name1     = ls_vbak-name1.
    ENDIF.

    " Batch Characteristics
    IF ls_afpo-charg IS NOT INITIAL.
      READ TABLE gt_char_val INTO ls_char_val WITH KEY charg = ls_afpo-charg BINARY SEARCH.
      IF sy-subrc = 0.
        gs_output-width = ls_char_val-width.
        gs_output-leng  = ls_char_val-leng.
        gs_output-grade = ls_char_val-grade.
        gs_output-norol = ls_char_val-norol.
      ENDIF.
    ENDIF.

    APPEND gs_output TO gt_output.
  ENDLOOP.

  SORT gt_output BY werks arbpl aufnr charg.
ENDFORM.                    " BUILD_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv.
  PERFORM build_fieldcat.
  PERFORM build_layout.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat
      i_save                  = 'A'
    TABLES
      t_outtab                = gt_output
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error saat menampilkan ALV Grid.' TYPE 'E'.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM build_fieldcat.
  DATA: ls_fc TYPE slis_fieldcat_alv.

  CLEAR gt_fieldcat.

  DEFINE add_fc.
    clear ls_fc.
    ls_fc-fieldname   = &1.
    ls_fc-seltext_m   = &2.
    ls_fc-seltext_l   = &2.
    ls_fc-seltext_s   = &2.
    ls_fc-outputlen   = &3.
    ls_fc-just        = &4.
    ls_fc-hotspot     = &5.
    ls_fc-do_sum      = &6.
    append ls_fc to gt_fieldcat.
  END-OF-DEFINITION.

  add_fc 'STATUS_ICON' 'St'                 4  'C' ' ' ' '.
  add_fc 'STATUS'      'Status'             6  'C' ' ' ' '.
  add_fc 'STATUS_TXT'  'Deskripsi Status'   18 'L' ' ' ' '.
  add_fc 'WERKS'       'Plant'              5  'C' ' ' ' '.
  add_fc 'ARBPL'       'Resource / Mesin'   10 'L' ' ' ' '.
  add_fc 'ARBPL_TXT'   'Deskripsi Mesin'    20 'L' ' ' ' '.
  add_fc 'AUFNR'       'Combine Order'      12 'C' 'X' ' '.
  add_fc 'AUART'       'Tipe'               5  'C' ' ' ' '.
  add_fc 'ORORD'       'Original Order'     12 'C' 'X' ' '.
  add_fc 'MATNR'       'Material'           18 'L' 'X' ' '.
  add_fc 'MAKTX'       'Deskripsi Material' 30 'L' ' ' ' '.
  add_fc 'CHARG'       'Batch Slit Roll'    12 'C' 'X' ' '.
  add_fc 'NOROL'       'No Roll'            10 'C' ' ' ' '.
  add_fc 'WIDTH'       'Lebar (mm)'         10 'R' ' ' ' '.
  add_fc 'LENG'        'Panjang (m)'        10 'R' ' ' ' '.
  add_fc 'GRADE'       'Grade'              6  'C' ' ' ' '.
  add_fc 'GAMNG'       'Target Order'       13 'R' ' ' 'X'.
  add_fc 'WEMNG'       'GR Slit / Actual'   13 'R' ' ' 'X'.
  add_fc 'GMEIN'       'Satuan'             4  'C' ' ' ' '.
  add_fc 'LGORT'       'SLoc'               5  'C' ' ' ' '.
  add_fc 'KDAUF'       'Sales Order'        10 'C' 'X' ' '.
  add_fc 'KDPOS'       'SO Item'            6  'C' ' ' ' '.
  add_fc 'NAME1'       'Customer'           25 'L' ' ' ' '.
  add_fc 'GLTRP'       'Tgl Rencana Finish' 10 'C' ' ' ' '.
  add_fc 'GSTRP'       'Tgl Rencana Start'  10 'C' ' ' ' '.
ENDFORM.                    " BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM build_layout.
  CLEAR gs_layout.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
  gs_layout-box_fieldname     = ' '.
ENDFORM.                    " BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.
  DATA: ls_header TYPE slis_listheader.

  CLEAR gt_header.

  CLEAR ls_header.
  ls_header-typ  = 'H'.
  ls_header-info = 'MONITORING HASIL TRANSAKSI SLITTING (ZPP001)'.
  APPEND ls_header TO gt_header.

  CLEAR ls_header.
  ls_header-typ  = 'S'.
  ls_header-key  = 'Tanggal Cetak :'.
  WRITE sy-datum TO ls_header-info.
  APPEND ls_header TO gt_header.

  CLEAR ls_header.
  ls_header-typ  = 'S'.
  ls_header-key  = 'User Pelaksana :'.
  ls_header-info = sy-uname.
  APPEND ls_header TO gt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header.
ENDFORM.                    " TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  DATA: lv_aufnr TYPE aufnr,
        lv_matnr TYPE matnr,
        lv_charg TYPE charg_d,
        lv_kdauf TYPE kdauf.

  CASE r_ucomm.
    WHEN '&IC1'. " Double Click / Hotspot
      CASE rs_selfield-fieldname.
        WHEN 'AUFNR' OR 'ORORD'.
          lv_aufnr = rs_selfield-value.
          IF lv_aufnr IS NOT INITIAL.
            SET PARAMETER ID 'ANR' FIELD lv_aufnr.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'MATNR'.
          lv_matnr = rs_selfield-value.
          IF lv_matnr IS NOT INITIAL.
            SET PARAMETER ID 'MAT' FIELD lv_matnr.
            CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'CHARG'.
          READ TABLE gt_output INTO gs_output INDEX rs_selfield-tabindex.
          IF sy-subrc = 0 AND gs_output-matnr IS NOT INITIAL.
            SET PARAMETER ID 'MAT' FIELD gs_output-matnr.
            SET PARAMETER ID 'CHA' FIELD gs_output-charg.
            SET PARAMETER ID 'WRK' FIELD gs_output-werks.
            CALL TRANSACTION 'MSC3N' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'KDAUF'.
          lv_kdauf = rs_selfield-value.
          IF lv_kdauf IS NOT INITIAL.
            SET PARAMETER ID 'AUN' FIELD lv_kdauf.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " USER_COMMAND
