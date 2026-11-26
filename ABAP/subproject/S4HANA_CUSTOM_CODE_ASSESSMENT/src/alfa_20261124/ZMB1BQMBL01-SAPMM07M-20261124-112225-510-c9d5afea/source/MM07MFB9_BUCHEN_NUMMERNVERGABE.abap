*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_NUMMERNVERGABE                                    *
*---------------------------------------------------------------------*
*       Zum Buchen wird die Nummernvergabe durchgeführt.              *
*---------------------------------------------------------------------*

* consider the tables XEKBE_MA and XEKBZ_MA for the         "MAA EhP4
* PO history of postings with multi account assignment, too "MAA EhP4

* error message m7 437 unjustifiable here                   "n1329660
FORM buchen_nummernvergabe.

* MAA EhP4 -Start                                           "MAA EhP4
* local working areas for better performance                "MAA EhP4
  FIELD-SYMBOLS :
    <ls_ekbe_ma>             LIKE  LINE OF xekbe_ma,
    <ls_ekbz_ma>             LIKE  LINE OF xekbz_ma,
    <ls_vm07m>               TYPE  vm07m.

  TYPES : BEGIN OF l_stype_ekbe_key,
            ebeln            TYPE  ekbe-ebeln,
            ebelp            TYPE  ekbe-ebelp,
            vgabe            TYPE  ekbe-vgabe,
            gjahr            TYPE  ekbe-gjahr,
            buzei            TYPE  ekbe-buzei,
          END   OF l_stype_ekbe_key.

  TYPES : BEGIN OF l_stype_ekbe_work.
  INCLUDE          TYPE  l_stype_ekbe_key.

  TYPES :   lfgja            TYPE  ekbe-lfgja,
            lfbnr            TYPE  ekbe-lfbnr,
            lfpos            TYPE  ekbe-lfpos,
            flag_found(01)   TYPE  c,
          END   OF l_stype_ekbe_work.

  DATA : ls_ekbe_key_new     TYPE  l_stype_ekbe_key,
         ls_ekbe_key_old     TYPE  l_stype_ekbe_key,

         ls_ekbe_work        TYPE  l_stype_ekbe_work,
         ls_ekbe_work_buff   TYPE  l_stype_ekbe_work,
         lt_ekbe_work        TYPE  STANDARD TABLE OF
                                   l_stype_ekbe_work.

  DATA : lflag_xekbe_ma(01)  TYPE  c.                       "MAA EhP4
* MAA EhP4 -End                                             "MAA EhP4

  DATA : lv_bustr            TYPE  t156-bustr.              "n1329660

  READ TABLE xmkpf INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e061.
  ENDIF.
  IF save_mblnr IS INITIAL.     "Übernahme der ersten MatBel-Nummer (FB)
    PERFORM m-belegnummer_vergeben.
    save_mblnr = xmkpf-mblnr.
  ELSE.
    xmkpf-mblnr = save_mblnr.
  ENDIF.
ENHANCEMENT-POINT BUCHEN_NUMMERNVERGABE_01 SPOTS ES_SAPMM07M.
  PERFORM jv_knumv_get_next.

* Too early to access XAB number here. Move this logic to Form
* BUCHEN_AUSFUEHREN.
* IF SAVE_XABLN IS INITIAL.        "Übernahme der ersten XAB-Nummer (FB)
*   PERFORM XAB-NUMMER_VERGEBEN.                            "HW 407326
*   SAVE_XABLN = XMKPF-XABLN.                               "HW 407326
* ELSE.                                                     "HW 407326
*   XMKPF-XABLN = SAVE_XABLN.                               "HW 407326

* note 442706:
* Adaption of WEVER for postings with MB_CREATE_GOODS_MOVEMENT.
  IF NOT xmbwl IS INITIAL.
    IF NOT x_mulko IS INITIAL AND xmkpf-wever = 3
      AND NOT rm07m-xnapr IS INITIAL.                       "HW 1145488
      xmkpf-wever = 1.
      t158-wever = 1.
      rm07m-wvers1 = x.
      CLEAR rm07m-wvers3.
    ENDIF.
  ENDIF.

* ENDIF.                                                    "HW 407326

  MODIFY xmkpf INDEX 1.
  PERFORM kopfdialogstruktur_fuellen USING space.

  LOOP AT xmseg.
    xindex = sy-tabix.
    xmseg-mblnr = xmkpf-mblnr.
    IF xmseg-lgpla IS INITIAL AND NOT xmseg-xblvs IS INITIAL.
      xmseg-lgpla = xmkpf-mblnr.
    ENDIF.
    IF xmseg-lfbnr IS INITIAL AND ( xmseg-kzbew = b OR t158-kzbew = b ).
      LOOP AT lfbnr WHERE zeile = xmseg-zeile.
        xmseg-lfbnr = xmkpf-mblnr.
      ENDLOOP.
    ENDIF.
    MODIFY xmseg INDEX xindex.
    READ TABLE xvm07m INDEX xmseg-zeile.
    PERFORM posidialogstruktur_fuellen USING space.
    PERFORM messaging USING space.
    PERFORM new_nast_key.
    CALL FUNCTION 'RV_MESSAGES_RENAME'
      EXPORTING
        msg_objky_new = msg_objky_new
        msg_objky_old = msg_objky.
  ENDLOOP.

*----------------------------------------------------------------------*

* check the creation of the tables EKBE_MA and EKBZ_MA      "MAA EhP4
* MAA EhP4 -Start                                           "MAA EhP4
  IF  NOT xekbe_ma[] IS INITIAL.
    MOVE  x                  TO  lflag_xekbe_ma.
  ENDIF.
* MAA EhP4 -End                                             "MAA EhP4

  LOOP AT xekbe.
    xindex = sy-tabix.
    xekbe-belnr = xmkpf-mblnr.

    LOOP AT lfbnr WHERE zeile = xekbe-buzei.
      READ TABLE xmseg INDEX lfbnr-zeile.

      IF sy-subrc IS INITIAL.
*       check regarding movement Type = 141 was replaced    "n1329660
*       by check using posting string reference = 141 for   "n1329660
*       "GR G subseq. adjustm" because the customer could   "n1329660
*       a customer specific movement type                   "n1329660
        SELECT SINGLE bustr    FROM t156                    "n1329660
          INTO lv_bustr                                     "n1329660
            WHERE bwart = xmseg-bwart.                      "n1329660
                                                            "n1329660
        IF  lv_bustr <> '141'.                              "n1329660
          xekbe-lfbnr = xmkpf-mblnr.                        "n1329660
        ENDIF.                                              "n1329660
      ELSE.
        xekbe-lfbnr = xmkpf-mblnr.
      ENDIF.
    ENDLOOP.

    MODIFY xekbe INDEX xindex.

* MAA EhP4 -Start                                           "MAA EhP4
*   fill auxiliary working table if XEKBE_MA is filled      "MAA EhP4
    IF  lflag_xekbe_ma = x.
*     look for the item category of the PO
      READ TABLE xvm07m      ASSIGNING  <ls_vm07m>
                             INDEX xekbe-buzei.

      IF sy-subrc <> 0.
*       nothing found -> this PO history entry does not     "n1329660
*       belong to the current MM doc -> take the next entry "n1329660
        CONTINUE.                                           "n1329660
      ENDIF.

      IF  NOT <ls_vm07m>-pstyp = neun.
*       fill working table with the essential fields for EKBE_MA
        MOVE-CORRESPONDING xekbe       TO  ls_ekbe_work.
        APPEND  ls_ekbe_work            TO  lt_ekbe_work.
      ENDIF.
    ENDIF.                                                  "MAA EhP4
* MAA EhP4 -End                                             "MAA EhP4

  ENDLOOP.

* MAA EhP4 -Start                                           "MAA EhP4
* process XEKBE_MA if filled                                "MAA EhP4
  IF  lflag_xekbe_ma = x.

*   sort working table
    SORT  lt_ekbe_work       BY  ebeln ebelp vgabe gjahr buzei.

*   process all entries of table XEKBE_MA, too
*   (change fields directly using field-symbols)
    LOOP AT xekbe_ma         ASSIGNING  <ls_ekbe_ma>.

* --- begin ----------------------------------------------- MAA2
*     calculate the factor SHARE_F
      CALL METHOD go_mmim_maa_2->share_f_for_po_history
        EXPORTING
          iv_buzei   = <ls_ekbe_ma>-buzei
          iv_zekkn   = <ls_ekbe_ma>-zekkn
        CHANGING
          cv_share_f = <ls_ekbe_ma>-share_f. " modify
* --- end ------------------------------------------------- MAA2

      MOVE-CORRESPONDING  <ls_ekbe_ma>
                             TO  ls_ekbe_key_new.

*     look for the corresponding entry in the working table
*     when the key fields have changed
      IF  ls_ekbe_key_new <> ls_ekbe_key_old.
        MOVE-CORRESPONDING  <ls_ekbe_ma>
                             TO  ls_ekbe_key_old.

*       get the corresponding fields from XEKBE
        READ TABLE lt_ekbe_work
          INTO  ls_ekbe_work_buff
            WITH KEY ebeln = <ls_ekbe_ma>-ebeln
                     ebelp = <ls_ekbe_ma>-ebelp
                     vgabe = <ls_ekbe_ma>-vgabe
                     gjahr = <ls_ekbe_ma>-gjahr
                     buzei = <ls_ekbe_ma>-buzei
                             BINARY SEARCH.

        IF sy-subrc IS INITIAL.
          MOVE  x            TO  ls_ekbe_work_buff-flag_found.
        ELSE.
          CLEAR              ls_ekbe_work_buff.
        ENDIF.
      ENDIF.

*     take the data from the buffer if buffer is filled
      IF  ls_ekbe_work_buff-flag_found = x.
        MOVE : ls_ekbe_work_buff-lfgja TO  <ls_ekbe_ma>-lfgja,
               ls_ekbe_work_buff-lfbnr TO  <ls_ekbe_ma>-lfbnr,
               ls_ekbe_work_buff-lfpos TO  <ls_ekbe_ma>-lfpos.
      ENDIF.

      MOVE : xmkpf-mblnr     TO  <ls_ekbe_ma>-belnr.
    ENDLOOP.

    FREE                     lt_ekbe_work.
  ENDIF.                                                    "MAA EhP4
* MAA EhP4 -End                                             "MAA EhP4

* Subcontracting History Table of Components
  LOOP AT xekbe_sc WHERE belnr IS INITIAL.                  " Begin of Outsourced Manufacturing EhP 4
    xindex = sy-tabix.
    xekbe_sc-belnr = xmkpf-mblnr.
    xekbe_sc-gjahr = xmkpf-mjahr.                           "n1480559
    MODIFY xekbe_sc INDEX xindex.
  ENDLOOP.                                                  " End of Outsourced Manufacturing EhP 4

  IF NOT vas_vorgang_aktiv IS INITIAL.
    LOOP AT vas_ekbe.
      xindex = sy-tabix.
      vas_ekbe-belnr = xmkpf-mblnr.
      MODIFY vas_ekbe INDEX xindex.
    ENDLOOP.
  ENDIF.

  LOOP AT xaufbe.
    xindex = sy-tabix.
    xaufbe-belnr = xmkpf-mblnr.
    MODIFY xaufbe INDEX xindex.
  ENDLOOP.

  LOOP AT xaufbe_cr.
    xindex = sy-tabix.
    xaufbe_cr-belnr = xmkpf-mblnr.
    MODIFY xaufbe_cr INDEX xindex.
  ENDLOOP.


  LOOP AT xekbz.
    xindex = sy-tabix.
    xekbz-gjahr = xmkpf-mjahr.
    xekbz-belnr = xmkpf-mblnr.
    MODIFY xekbz INDEX xindex.
  ENDLOOP.

* MAA EhP4 -Start                                           "MAA EhP4
* process all entries of table XEKBZ_MA, too                "MAA EhP4
* (change fields directly using field-symbols)              "MAA EhP4
  LOOP AT xekbz_ma           ASSIGNING  <ls_ekbz_ma>.       "MAA EhP4
    MOVE : xmkpf-mjahr       TO  <ls_ekbz_ma>-gjahr,        "MAA EhP4
           xmkpf-mblnr       TO  <ls_ekbz_ma>-belnr.        "MAA EhP4

* --- begin ----------------------------------------------- MAA2
*   calculate the factor SHARE_F
    CALL METHOD go_mmim_maa_2->share_f_for_po_history
      EXPORTING
        iv_buzei   = <ls_ekbz_ma>-buzei
        iv_zekkn   = <ls_ekbz_ma>-zekkn
      CHANGING
        cv_share_f = <ls_ekbz_ma>-share_f. " modify
* --- end ------------------------------------------------- MAA2

  ENDLOOP.                                                  "MAA EhP4
* MAA EhP4 -End                                             "MAA EhP4

  LOOP AT xekbe_cr.
    xindex = sy-tabix.
    xekbe_cr-belnr = xmkpf-mblnr.
    MODIFY xekbe_cr INDEX xindex.
  ENDLOOP.

  LOOP AT xekbz_cr.
    xindex = sy-tabix.
    xekbz_cr-gjahr = xmkpf-mjahr.
    xekbz_cr-belnr = xmkpf-mblnr.
    MODIFY xekbz_cr INDEX xindex.
  ENDLOOP.

  LOOP AT xaufm.
    xaufm-mblnr = xmkpf-mblnr.
    MODIFY xaufm.
  ENDLOOP.

  LOOP AT xauwei.
    xauwei-belnr = xmkpf-mblnr.
    MODIFY xauwei.
  ENDLOOP.

  LOOP AT xpbat.
    xpbat-mblnr = xmkpf-mblnr.
    MODIFY xpbat.
  ENDLOOP.

  LOOP AT xlk01.
    xlk01-mblnr = xmkpf-mblnr.
    xlk01-mjahr = xmkpf-mjahr.
    IF NOT xlk01-vschn IS INITIAL AND
           xlk01-vlpla IS INITIAL.
      xlk01-vlpla = xmkpf-mblnr.
    ENDIF.
    IF NOT xlk01-nschn IS INITIAL AND
           xlk01-nlpla IS INITIAL.
      xlk01-nlpla = xmkpf-mblnr.
    ENDIF.
    MODIFY xlk01.
  ENDLOOP.

  LOOP AT xlk02.
    xlk02-mblnr = xmkpf-mblnr.
    xlk02-mjahr = xmkpf-mjahr.
    MODIFY xlk02.
  ENDLOOP.

  LOOP AT xmcwmhd.
    xmcwmhd-mblnr = xmkpf-mblnr.
    xmcwmhd-mjahr = xmkpf-mjahr.
    xmcwmhd-bdatu = xmkpf-budat.
    MODIFY xmcwmhd.
  ENDLOOP.

  LOOP AT xmcwmit.
    xmcwmit-mb_mblnr = xmkpf-mblnr.
    xmcwmit-mb_mjahr = xmkpf-mjahr.
    MODIFY xmcwmit.
  ENDLOOP.

  LOOP AT xmcmseg.
*   xmcmseg-mblnr = xmkpf-mblnr.
*   xmcmseg-mjahr = xmkpf-mjahr.
*   xmcmseg-budat = xmkpf-budat.
*   xmcmseg-bldat = xmkpf-bldat.
ENHANCEMENT-SECTION     BUCHEN_NUMMERNVERGABE_02 SPOTS ES_SAPMM07M.
    MOVE-CORRESPONDING xmkpf TO xmcmseg.
END-ENHANCEMENT-SECTION.
    MODIFY xmcmseg.
  ENDLOOP.

  LOOP AT xchvw.
    xchvw-mblnr = xmkpf-mblnr.
    xchvw-mjahr = xmkpf-mjahr.
    xchvw-budat = xmkpf-budat.
    MODIFY xchvw.
  ENDLOOP.

  LOOP AT xvbfa.
    xvbfa-vbeln = xmkpf-mblnr.
    MODIFY xvbfa.
  ENDLOOP.

  LOOP AT xrkwa.
    xrkwa-mblnr = xmseg-mblnr.
    MODIFY xrkwa.
  ENDLOOP.

  LOOP AT xrowa.                                            "kaz
    xrowa-mblnr = xmseg-mblnr.                              "kaz
    MODIFY xrowa.                                           "kaz
  ENDLOOP.                                                  "kaz

  IF inventur IS INITIAL.
    LOOP AT yibuz.
      READ TABLE yiseg INDEX yibuz-zeili.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'YISEG' yibuz-zeili.
      ENDIF.
      READ TABLE xmseg INDEX yibuz-zeile.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'XMSEG' yibuz-zeile.
      ENDIF.
      yiseg-mblnr = xmseg-mblnr.
      yiseg-mjahr = xmseg-mjahr.
      yiseg-zeile = xmseg-zeile.
      MODIFY yiseg INDEX yibuz-zeili.
    ENDLOOP.
  ENDIF.

*- batch determination selection criteria
  CALL FUNCTION 'V01F_BDSEL_OBJECTS_VERIFY'
    EXPORTING
      i_mblnr = xmkpf-mblnr
      i_mjahr = xmkpf-mjahr
    TABLES
      t_mseg  = xmseg.

  PERFORM off_number_global_numbering.

ENDFORM.                    "BUCHEN_NUMMERNVERGABE