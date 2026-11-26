*----------------------------------------------------------------------*
*   INCLUDE LMIGOKA2                               new with note 562898*
*   Availability check                                                 *
*----------------------------------------------------------------------*

METHOD availability_check.
* This method creates the correction lines for the ATP check performed
* during stock-/batch determination. It does not create the line that
* is actually checked by ATP (the one with chkflg = x). This one is
* created within the function modules performing the bstch stock
* determination. The correction lines are handed to
* VB_COMPLETE_DETERMINATION in table lt_available.
* This table can contain the following lines:
* - one line for each item for which already a stock-/batch
*   determination was performed (charg/lgort is filled). Those lines
*   decrease the ATP quantity -> BDMNG and VMENG are positive.
* - one line for each material/DELNR/DELPS combination containing the
*   sum of all those items which belong to this combination and for
*   which a stock/batch determination was already performed. They
*   increase the ATP quantity -> vmeng, bdmng are negative.
* - one correction line for the item for which currently the
*   determination is performed. This line increases the ATP quantity ->
*   vmeng is negative. The vmeng of this line is reduced by the
*   cumulated vmeng of all items of the same material/DELNR/DELPS
*   combination for which previously a stock/batch determination was
*   performed.
  DATA: tcode       TYPE t158-tcode,
        lt_resitem  TYPE TABLE OF resb INITIAL SIZE 0,
        ls_resitem  TYPE resb,
        ls_reshead  TYPE rkpf,
        goitem            TYPE goitem,
        batch_det         TYPE c,
        stock_det         TYPE c,
        chsmm       TYPE t156b-chsmm,
        ls_avail_curr_line TYPE atpcs,
        ls_avail_plant     TYPE atpcs,
        lt_avail_sum       TYPE TBL_ATPCS.

  DATA: l_atpca TYPE atpca,
        l_atpcb TYPE atpcb.
  DATA: lt_bfstock TYPE TABLE OF bfstock,                        "642082
        ls_bfstock TYPE bfstock.                                 "642082
  CALL FUNCTION 'BF_RESET_LOC_ENQ_TAB'.                          "642082
  CONCATENATE 'MIGO_' s_action-migo_mode '             ' INTO tcode.
  IF s_action-migo_mode = 'GT'.
    tcode = 'MIGO_TR             '.
*   ATP check only for GI
    IF ls_cdcom-shkzg_migo = '+'.
      CLEAR ls_cdcom.
      ls_cdcom-bwart = ls_goitem-bwart.
      ls_cdcom-sobkz = ls_goitem-sobkz.
    ENDIF.
  ENDIF.
  SELECT SINGLE prreg FROM t158 INTO ls_cdcom-prreg
        WHERE tcode = tcode.
  SELECT SINGLE kzvbp FROM t156sc INTO ls_cdcom-kzvbp
        WHERE bwart = ls_goitem-bwart
        AND   mengu = ls_goitem-mengu
        AND   wertu = ls_goitem-wertu
        AND   sobkz = ls_goitem-sobkz
        AND   kzbew = ls_goitem-kzbew
        AND   kzzug = ls_goitem-kzzug
        AND   kzvbr = ls_goitem-kzvbr.

* reservation data is needed for ATP correction lines.
  IF NOT ls_goitem-rsnum IS INITIAL.
    IF NOT l_transdet = space.
      SELECT SINGLE * FROM rkpf INTO ls_reshead
                                WHERE rsnum = ls_goitem-rsnum.
    ENDIF.
    SELECT * FROM resb INTO TABLE lt_resitem
                       WHERE rsnum = ls_goitem-rsnum.
    READ TABLE lt_resitem INTO ls_resitem
                          WITH KEY rsnum = ls_goitem-rsnum
                                   rspos = ls_goitem-rspos
                                   rsart = ls_goitem-rsart.
    IF sy-subrc <> 0.
      CLEAR ls_resitem.
      REFRESH lt_resitem.
    ENDIF.
  ENDIF.

* standard case and "From" material in case of transfer posting
  IF l_transdet = space.
    SELECT SINGLE mtvfp FROM marc INTO ls_cdcom-mtvfp
        WHERE matnr = ls_goitem-matnr
        AND   werks = ls_goitem-werks.
    SELECT SINGLE chsmm FROM t156b INTO chsmm
                                   WHERE bwart = ls_cdcom-bwart
                                   AND   sobkz = ls_cdcom-sobkz.
* Check for batch determination
    IF chsmm <> space AND ls_goitem-xchpf  <> space.
      batch_det = x.
    ENDIF.
* Check for stock determination
    IF batch_det IS INITIAL.
     IF NOT ls_cdcom-rules IS INITIAL AND NOT ls_cdcom-eprio IS INITIAL.
        stock_det = x.
      ENDIF.
    ENDIF.
* set lock for SC components                                   "757894_v
    IF ( batch_det <> space OR stock_det <> space ) and
       ls_goitem-sobkz = o.
      LOOP AT pt_goitem INTO goitem
                        WHERE matnr = ls_goitem-matnr
                        AND   werks = ls_goitem-werks.
        IF goitem-sobkz = o.
          CHECK goitem-charg <> SPACE.
        ENDIF.
        MOVE-CORRESPONDING goitem TO ls_bfstock.
        COLLECT ls_bfstock INTO lt_bfstock.
      ENDLOOP.
      IF NOT lt_bfstock IS INITIAL.
        CALL FUNCTION 'BF_SET_LOC_ENQ_TAB'
         EXPORTING
           lifnr     = goitem-mat_lifnr
         TABLES
           l_bfstock = lt_bfstock.
      ENDIF.
    ENDIF.                                                     "757894_^
* Customizing of ATP check is incomplete                         "608590
    CHECK ls_cdcom-prreg <> SPACE and ls_cdcom-kzvbp <> SPACE    "608590
      AND ls_cdcom-mtvfp <> SPACE.                               "608590
* Are there other items of the same material?
    IF batch_det <> space OR stock_det <> space.
      LOOP AT pt_goitem INTO goitem
                        WHERE matnr = ls_goitem-matnr
                        AND   werks = ls_goitem-werks.

*       IF goitem-sobkz = o OR goitem-sobkz = k.            "642082
       IF goitem-sobkz = k.                                 "757894
* AVAILABILITY_CHECK_CONTROLLER not for SC-components and special
* stock from vendor, to fill enqueue tables
          CHECK goitem-charg <> SPACE.
          IF goitem-sobkz = K.
            CHECK goitem-lgort <> SPACE.
          ENDIF.
          MOVE-CORRESPONDING goitem TO ls_bfstock.
          COLLECT ls_bfstock INTO lt_bfstock.
          CONTINUE.
        ENDIF.
        CALL METHOD availability_struc_fill
          EXPORTING
            is_goitem       = goitem
            is_resitem      = ls_resitem
            i_transdet      = l_transdet
            i_batch_det     = batch_det
            i_item          = ls_goitem-global_counter
            i_matnr         = goitem-matnr
            i_werks         = goitem-werks
            i_lgort         = goitem-lgort
            i_charg         = goitem-charg
            i_sobkz         = goitem-sobkz
            i_lief          = goitem-emlif
            i_prreg         = ls_cdcom-prreg
          IMPORTING
            es_avail_curr_line = ls_avail_curr_line
            es_avail_plant     = ls_avail_plant
          CHANGING
            ct_avail_prev_lines = lt_availability.
      ENDLOOP.
    ENDIF.
  ELSE.
* --------------------------------------------------------------------*
* In case of transfer posting: "To" material                          *
* --------------------------------------------------------------------*
    SELECT SINGLE mtvfp FROM marc INTO ls_cdcom-mtvfp
        WHERE matnr = ls_goitem-ummat
        AND   werks = ls_goitem-umwrk.
    SELECT SINGLE chsmm FROM t156b INTO chsmm
                                   WHERE bwart = ls_cdcom-bwart
                                   AND   sobkz = ls_cdcom-sobkz.
* Check for batch determination
    IF chsmm <> space AND ls_goitem-umxchpf  <> space.
      batch_det = x.
    ENDIF.
* Check for stock determination
    IF batch_det IS INITIAL.
     IF NOT ls_cdcom-rules IS INITIAL AND NOT ls_cdcom-eprio IS INITIAL.
        stock_det = x.
      ENDIF.
    ENDIF.
* are the other items of the same material
    IF batch_det <> space OR stock_det <> space.
      LOOP AT pt_goitem INTO goitem
                        WHERE ummat = ls_goitem-ummat
                        AND   umwrk = ls_goitem-umwrk.
        IF goitem-umsok = O OR goitem-umsok = K.                 "642082
* AVAILABILITY_CHECK_CONTROLLER not for SC-components and special
* stock from vendor, to fill enqueue tables
          CHECK goitem-umcha <> SPACE.
          IF goitem-umsok = K.
            CHECK goitem-umlgo <> SPACE.
          ENDIF.
          MOVE goitem-ummat TO ls_bfstock-matnr.
          MOVE goitem-umwrk TO ls_bfstock-werks.
          MOVE goitem-umlgo TO ls_bfstock-lgort.
          MOVE goitem-umcha TO ls_bfstock-charg.
          MOVE goitem-umbar TO ls_bfstock-bwtar.
          MOVE goitem-menge TO ls_bfstock-menge.
          COLLECT ls_bfstock INTO lt_bfstock.
          CONTINUE.
        ENDIF.                                                   "642082

        CALL METHOD availability_struc_fill
          EXPORTING
            is_goitem       = goitem
            is_resitem      = ls_resitem
            i_transdet      = l_transdet
            i_batch_det     = batch_det
            i_item          = ls_goitem-global_counter
            i_matnr         = goitem-ummat
            i_werks         = goitem-umwrk
            i_lgort         = goitem-umlgo
            i_charg         = goitem-umcha
            i_sobkz         = goitem-umsok
            i_lief          = goitem-mat_lifnr
            i_prreg         = ls_cdcom-prreg
          IMPORTING
            es_avail_curr_line = ls_avail_curr_line
            es_avail_plant     = ls_avail_plant
          CHANGING
            ct_avail_prev_lines = lt_availability.

      ENDLOOP.
    ENDIF.
  ENDIF.

* create additional correction line with sum of ATP quantities of other
* lines for the same material/plant combination
  DATA: lt_avail  TYPE TABLE OF atpcs,
        ls_avail  TYPE atpcs,
        ls_avail_sum TYPE atpcs,
        l_delnr   TYPE delnr,
        l_delps   TYPE delps,
        l_vmeng   TYPE bestmng,
        l_bdmng   TYPE bdmng,
        l_exit(1) TYPE c,
        l_index   TYPE sytabix VALUE '1'.

  IF ( batch_det <> space or stock_det <> space ) AND
     NOT lt_availability IS INITIAL.
    lt_avail[] = lt_availability[].
    if batch_det <> space.
      DELETE lt_avail WHERE charg = space.
    else.
      DELETE lt_avail WHERE lgort = space.
    endif.
    SORT lt_avail BY delnr delps.                              "818760
*   This loop sums up the quantities of all lines for which a batch
*   determination was already performed. And creates a correction line
*   (one for each delnr/delps combination) to be passed to ATP
*    management.
    WHILE l_exit IS INITIAL.
      READ TABLE lt_avail INTO ls_avail INDEX l_index.
      IF sy-subrc <> 0.
        l_exit = 'X'.
      ENDIF.
      l_index = l_index + 1.
*     For each delnr/delps a new record is created. l_exit = X means
*     'last line of lt_avail is reached -> create record'
      IF NOT l_delnr IS INITIAL AND
      ( ( l_delnr <> ls_avail-delnr OR l_delps <> ls_avail-delps ) OR
           l_exit <> space ).
        CHECK NOT ls_avail_sum IS INITIAL.
*       correction quantity must be negative
        ls_avail_sum-vmeng = - ls_avail_sum-vmeng.
        ls_avail_sum-bdmng = - ls_avail_sum-bdmng.
*       stock identifiers of correction record need to be set to the
*       original value taken from the reservation or the transfer PO.
        IF NOT ls_resitem-rsnum IS INITIAL.
          IF l_transdet = space.
            IF NOT ( ls_avail_sum-delnr = ls_resitem-rsnum AND
               ls_avail_sum-delps = ls_resitem-rspos ).
              READ TABLE lt_resitem INTO ls_resitem
                                    WITH KEY rsnum = ls_avail_sum-delnr
                                             rspos = ls_avail_sum-delps
                                             rsart = ' '.
            ENDIF.
            ls_avail_sum-lgort = ls_resitem-lgort.
            ls_avail_sum-charg = ls_resitem-charg.
            ls_avail_sum-sobkz = ls_resitem-sobkz.
          ELSE.
            ls_avail_sum-werks = ls_reshead-umwrk.
            ls_avail_sum-lgort = ls_reshead-umlgo.
            CLEAR: ls_avail_sum-charg, ls_avail_sum-sobkz.
          ENDIF.
        elseif not ls_goitem-ebeln is initial and             "810352_v
               not ls_goitem-kzzug is initial and
                   ls_goitem-kzbew is initial.
          clear: ls_avail_sum-lgort,
                 ls_avail_sum-charg,
                 ls_avail_sum-sobkz.                          "810352_^
        else.
*         NO reservation involved.
          if batch_det <> space.
            CLEAR: ls_avail_sum-charg.
          else.
            clear: ls_avail_sum-lgort.
          endif.
        endif.
        APPEND ls_avail_sum TO lt_avail_sum.
        CLEAR ls_avail_sum.
      ENDIF.
      l_delnr = ls_avail-delnr.
      l_delps = ls_avail-delps.
      l_vmeng = ls_avail_sum-vmeng.
      l_bdmng = ls_avail_sum-bdmng.
      MOVE ls_avail TO ls_avail_sum.
      ls_avail_sum-vmeng = l_vmeng + ls_avail_sum-vmeng.
      ls_avail_sum-bdmng = l_bdmng + ls_avail_sum-bdmng.
    ENDWHILE.
  ENDIF.

* lt_avail_sum: total of already 'used' ATP-quantity summed by DELNR,
*               DELPS
* ls_avail_curr_line: There is no delta handling, therefore this
* correction line is needed to free the needed quantity for the used
* reservation in the ATP server.
if not lt_avail_sum[] is initial.
  read table lt_avail_sum into ls_avail
                          with key delnr = ls_avail_curr_line-delnr
                                   delps = ls_avail_curr_line-delps
                                   delkz = ls_avail_curr_line-delkz.
  if sy-subrc is initial and ( not ls_goitem-rsnum is initial or
   ( not ls_goitem-ebeln is initial and                      "810352_v
     not ls_goitem-kzzug is initial and
         ls_goitem-kzbew is initial ) ).                     "810352_^
   ls_avail_curr_line-vmeng = ls_avail_curr_line-vmeng - ls_avail-vmeng.
  endif.
  append lines of lt_avail_sum to lt_availability.
endif.

data: l_count type i value '0'.

* the global counter cannot be used to fill xline because due to the
* correction lines xline would not be unique but FUNCTION
* 'AVAILABILITY_CHECK_CONTROLLER' needs xline to be unique.
loop at lt_availability into ls_avail.
  l_count = l_count + 1.
  ls_avail-xline = l_count.
  modify lt_availability from ls_avail
                         index sy-tabix
                         transporting xline.
endloop.
ls_avail_plant-xline = l_count + 1.
ls_avail_curr_line-xline = l_count + 2.

CALL METHOD availability_plant_check
       EXPORTING
         is_goitem           = ls_goitem
         is_avail_curr_line  = ls_avail_curr_line
         is_avail_plant      = ls_avail_plant
         it_avail_prev_lines = lt_availability
         i_kzvbp             = ls_cdcom-kzvbp
       IMPORTING
         e_shortage_plant    = e_shortage_plant.

if not ls_goitem-rsnum is initial or
   ( not ls_goitem-ebeln is initial and                      "810352_v
     not ls_goitem-kzzug is initial and
         ls_goitem-kzbew is initial ).                       "810352_^
  append ls_avail_curr_line to lt_availability.
endif.

* set lock for SC components and special stocks from vendor      "642082
  IF ( ls_goitem-sobkz = k OR ls_goitem-umsok = k OR             "757894
     ls_goitem-umsok = o )                                       "757894
    AND NOT lt_bfstock IS INITIAL.
    CALL FUNCTION 'BF_SET_LOC_ENQ_TAB'
      EXPORTING
        lifnr     = goitem-mat_lifnr
      TABLES
        l_bfstock = lt_bfstock.
  ENDIF.

ENDMETHOD.                    "availability_check


*----------------------------------------------------------------------*
*   availability_struc_fill
*   added by note 703419
*   fills the interface structure for ATP Check during batch
*   determination and stock determination
*----------------------------------------------------------------------*

METHOD availability_struc_fill.

  DATA: ls_availability    TYPE atpcs,
        ls_mdlv            TYPE mdlv,
        xissue             TYPE char1,
        atpdt              TYPE atpdt,
        l_bdter_po         TYPE BDTER.

  MOVE-CORRESPONDING is_goitem TO ls_availability.
  ls_availability-prreg = i_prreg.
  ls_availability-matnr = i_matnr.
  ls_availability-werks = i_werks.
  ls_availability-lgort = i_lgort.
  ls_availability-charg = i_charg.
* The requirement date has to be set to the original value from the
* reservation or transfer PO. For transfer PO this is more complicated
* and is done later on in method availability_gi_po
  IF NOT is_goitem-rsnum IS INITIAL AND                     "703419
     NOT is_goitem-bdter IS INITIAL.                        "703419
    ls_availability-bdter = is_goitem-bdter.                "703419
  ELSE.                                                     "703419
    ls_availability-bdter = sy-datlo.                       "703419
  ENDIF.                                                    "703419

*       Do not check this item if there is more than one item in "666840
*       pt_goitem and the selected item is not the one that is   "666840
*       currently being processed or the selected item has not   "666840
*       been checked already                                     "666840
  IF i_batch_det = abap_true.
    IF i_item <> is_goitem-global_counter AND
       ls_availability-charg IS INITIAL.                    "666840
      EXIT.                                                 "703419
    ENDIF.                                                  "666840
  ELSE.                             "stock determintation   "666840
    IF i_item <> is_goitem-global_counter AND
       ls_availability-lgort IS INITIAL.                    "666840
      EXIT.                                                 "703419
          ENDIF.                                                 "666840
        ENDIF.                                                   "666840
        CALL FUNCTION 'MD_MRP_AREA_GET'
          EXPORTING
      i_matnr                = i_matnr
      i_werks                = i_werks
      i_lgort                = i_lgort
      i_lbear                = i_lief
      i_sobkz                = i_sobkz
    IMPORTING
      e_db_mdlv              = ls_mdlv
    EXCEPTIONS
      wrong_parameters       = 1
      OTHERS                 = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        ls_availability-berid = ls_mdlv-berid.
  ls_availability-bdmng = is_goitem-menge.
  ls_availability-ordnum = is_goitem-aufnr.
  IF NOT is_goitem-rsnum IS INITIAL.
    ls_availability-delnr = is_goitem-rsnum.
    ls_availability-delps = is_goitem-rspos.
*    SELECT SINGLE * FROM resb INTO ls_reservation_item
*      WHERE rsnum = is_goitem-rsnum
*      AND   rspos = is_goitem-rspos.
*    IF sy-subrc = 0 AND ls_reservation_item-aufnr <> space.
    IF is_resitem-aufnr <> space.
      ls_availability-delkz = 'AR'.
*    ELSEIF sy-subrc = 0.
    ELSE.
      ls_availability-delkz = is_resitem-bdart.
* ATP-Deltamanagement
      IF is_goitem-rsnum <> space AND
        ( i_transdet = abap_false OR
        ( i_transdet = abap_true AND is_goitem-umwrk <> space ) ).
*        CLEAR atpdt.
*        atpdt-atptk = 'RE'.
*        atpdt-atpap = 'MB'.
*        atpdt-delst = c.
*        atpdt-delnr = is_goitem-rsnum.
*        atpdt-delps = is_goitem-rspos.
*        atpdt-rsart = is_goitem-rsart.
*              CALL FUNCTION 'DELTA_MANAGEMENT'
*                EXPORTING
*                  p_atpdt = atpdt
*                EXCEPTIONS
*                  OTHERS  = 0.
*              CLEAR ls_availability-vmeng.
              IF ls_availability-dat01 IS INITIAL.
                ls_availability-dat01 = ls_availability-bdter.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
  IF NOT is_goitem-ebeln IS INITIAL AND
     NOT is_goitem-kzzug IS INITIAL AND
     is_goitem-kzbew IS INITIAL.
    ls_availability-delnr = is_goitem-ebeln.
    ls_availability-delps = is_goitem-ebelp.
    ls_availability-delkz = 'U1'.
    call method availability_gi_po                           "810352_v
           EXPORTING i_po_numb = is_goitem-ebeln
                     i_po_item = is_goitem-ebelp
           IMPORTING e_bdter   = l_bdter_po
           CHANGING  c_vmeng   = ls_availability-vmeng.
  ENDIF.                                                     "810352_^
* If delkz is still initial that means no referenz           "818760_v
* to reservation or PO
  if ls_availability-delkz is initial.
    ls_availability-delkz = 'MB'.
    ls_availability-delps = is_goitem-global_counter.
  endif.                                                     "818760_^
*  ls_availability-xline = is_goitem-global_counter.
* xissue = indicator for withdrawls from sales order stock or
*          project stock
  IF ( ( is_goitem-sobkz = e AND is_goitem-shkzg = h ) OR  "sales
      ( is_goitem-umsok = e AND is_goitem-shkzg = s ) )   "order stock
     OR
    ( ( is_goitem-sobkz = q AND is_goitem-shkzg = h ) OR  "for project
       ( is_goitem-umsok = q AND is_goitem-shkzg = s ) )   "stock
     OR
      ( ( is_goitem-sobkz = w AND is_goitem-shkzg = h ) OR "Customer
        ( is_goitem-umsok = w AND is_goitem-shkzg = s ) ). "consi
          xissue = 'X'.
        ELSE.
          CLEAR xissue.
        ENDIF.
* Sales order stock
* ATP check on plant level...
  IF ( ( is_goitem-sobkz = e OR is_goitem-umsok = e ) OR
       ( NOT is_goitem-mat_kdauf IS INITIAL
       AND is_goitem-kzzug IS INITIAL ) )
      AND xissue = 'X'.
    IF is_goitem-rsnum IS INITIAL.
      ls_availability-kdauf = ls_availability-delnr
                            = is_goitem-mat_kdauf.
      ls_availability-kdpos = ls_availability-delps
                            = is_goitem-mat_kdpos.
      ls_availability-delet = is_goitem-kdein.
      ls_availability-delkz = 'VW'.
      ls_availability-sobkz = is_goitem-sobkz.
*      CLEAR: ls_availability-lgort,                           "750674
*             ls_availability-charg.                           "750674
      IF is_goitem-umsok = e AND is_goitem-shkzg = s.
        ls_availability-sobkz = is_goitem-umsok.
      ENDIF.
    ELSE.
      ls_availability-sobkz = is_goitem-sobkz.
      ls_availability-kdauf = is_goitem-mat_kdauf.
      ls_availability-kdpos = is_goitem-mat_kdpos.
          ENDIF.
        ENDIF.
* Project stock
* ATP check on plant level...
  IF ( is_goitem-sobkz = q OR is_goitem-umsok = q ) AND
    xissue = 'X'.
    ls_availability-pspel = is_goitem-mat_pspnr.
    ls_availability-sobkz = is_goitem-sobkz.
*    CLEAR: ls_availability-lgort,                             "750674
*           ls_availability-charg.                             "750674
    IF is_goitem-umsok = q AND is_goitem-shkzg = s.
      ls_availability-sobkz = is_goitem-umsok.
          ENDIF.
        ENDIF.
* ATP check on plant level...
*        IF ls_availability-sobkz = q OR ls_availability-sobkz = e
*          CLEAR: ls_availability-lgort,                       "750674
*                 ls_availability-charg.                       "750674
*        ENDIF.                                                "750674
* Customer consignation stock
  IF ( is_goitem-sobkz = w OR is_goitem-umsok = w ) AND
     xissue = 'X'.
    ls_availability-kunnr = is_goitem-kunnr.
    ls_availability-sobkz = is_goitem-sobkz.
* For Bwart 631/632
    IF is_goitem-umsok = w AND is_goitem-shkzg = s.
      ls_availability-sobkz = is_goitem-umsok.
    ENDIF.
  ENDIF.

*  ls_availability-delkzord = ls_availability-delkz.
*  ls_availability-ordnum = is_goitem-aufnr.
   if not is_goitem-aufnr is initial.                           "719669
     ls_availability-delkzord =
     lcl_migo_buffer=>order_type_get( is_goitem-aufnr ).
     ls_availability-ordnum = is_goitem-aufnr.
   endif.                                                       "719669
        ls_availability-trtyp = v.
        ls_availability-idxatp = 1.
*       Check if an automatic reservation can be withdrawn.      "666840
*       Every AR reservation at this point has RESB-XWAOK=X.     "666840
        IF ls_availability-delkz = 'AR'.                         "666840
          ls_availability-atpif = 'X'.                           "666840
        ENDIF.                                                   "666840
        CLEAR ls_availability-enqflg.
*       ls_availability-chkflg = x.                              "666840
        ls_availability-corflg = x.
  ls_availability-prreg = i_prreg.
*       ls_availability-bdter = sy-datlo.
  IF NOT is_goitem-rsnum IS INITIAL AND
     NOT is_goitem-bdter IS INITIAL.
    ls_availability-bdter = is_goitem-bdter.
  ELSE.
    ls_availability-bdter = sy-datlo.
  ENDIF.
*  ls_availability-xline = is_goitem-global_counter.
  IF i_batch_det = abap_true.
*   Check item with negative quantities                         "666840
    IF ls_availability-charg IS INITIAL AND
      ( ( is_goitem-shkzg = 'H' AND i_transdet = abap_false ) OR
        ( is_goitem-shkzg = 'S' AND i_transdet = abap_true ) ).
            ls_availability-bdmng = - ls_availability-bdmng.     "666840
            ls_availability-vmeng = - ls_availability-vmeng.     "666840
          ELSE.                                                  "666840
*     Item already checked                                       "666840
            ls_availability-vmeng = ls_availability-bdmng.       "666840
          ENDIF.                                                 "666840
        ELSE.                                                    "666840
*   Check item with negative quantities                          "666840
    IF ls_availability-lgort IS INITIAL AND
         ( ( is_goitem-shkzg = 'H' AND i_transdet = abap_false )
            OR
           ( is_goitem-shkzg = 'S' AND i_transdet = abap_true ) ).
            ls_availability-bdmng = - ls_availability-bdmng.     "666840
            ls_availability-vmeng = - ls_availability-vmeng.     "666840
          ELSE.                                                  "666840
*     Item already checked                                       "666840
            ls_availability-vmeng = ls_availability-bdmng.       "666840
          ENDIF.                                                 "666840
        ENDIF.                                                   "666840
  IF i_item <> is_goitem-global_counter.
*   correction lines for items for which a batch-/stock determination
*   + ATP check was performed before
    APPEND ls_availability TO ct_avail_prev_lines.
  else.
*   es_avail_curr_line = correction line for the item currently
*   processed by stock-/batch determination. The stock-/batch
*   determination needs this line if a reservation is involved
    es_avail_curr_line = ls_availability.
    if not is_goitem-ebeln is initial and                     "827643_v
       not is_goitem-kzzug is initial and
           is_goitem-kzbew is initial.
      es_avail_curr_line-bdter = l_bdter_po.                    "810352
    endif.                                                    "827643_^
*   es_avail_plant is used for the ATP check on plant level before the
*   stock-/batch determination is called.
    clear: ls_availability-lgort, ls_availability-charg,
           ls_availability-corflg.
    ls_availability-chkflg = 'X'.
    ls_availability-bdmng  = is_goitem-menge.
    ls_availability-vmeng  = is_goitem-vmeng.
*   ls_availability-xline  = is_goitem-global_counter.
    es_avail_plant = ls_availability.
  endif.

ENDMETHOD.                    "availability_struc_fill