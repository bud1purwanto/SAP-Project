*&---------------------------------------------------------------------*
*&  Include           LMIGOKA3                                         *
*&---------------------------------------------------------------------*
* added by note 703419


METHOD availability_plant_check.
* used to perform an ATP check on plant level before the stock or batch
* determination.
* This is necessary because batch- and stock determination assume that
* this check was successfully performed before they are called -> based
* on this assumption the full requirement quantity is distributed among
* the available batches/st.locations without checking if there are ATP
* relevant requirements on plant level.
* is_avail_plant      = ls_avail_plant
* it_avail_prev_lines = lt_availability.
  DATA: lt_atp_plant  TYPE tbl_atpcs,
        ls_avail      TYPE atpcs,
        ls_atpca      TYPE atpca,
        ls_atpcb      TYPE atpcb,
        l_error       TYPE c,
        l_quantity_out(18) TYPE c,
        l_unit_out(3)      TYPE c.
  DATA lv_diskz TYPE diskz.                                     "1651476
  IF NOT is_goitem-lgort IS INITIAL.                            "1651476
* no plant check if storage loc. is planned separately          "1651476
    SELECT SINGLE diskz FROM mard INTO lv_diskz                 "1651476
      WHERE matnr = is_goitem-matnr AND                         "1651476
            werks = is_goitem-werks AND                         "1651476
            lgort = is_goitem-lgort.                            "1651476
    IF sy-subrc = 0 AND NOT lv_diskz IS INITIAL.                "1651476
      EXIT.                                                     "1651476
    ENDIF.                                                      "1651476
  ENDIF.                                                        "1651476
  if not is_goitem-rsnum is initial or
   ( not is_goitem-ebeln is initial and                      "810352_v
     not is_goitem-kzzug is initial and
         is_goitem-kzbew is initial ).                       "810352_^
    APPEND is_avail_curr_line TO lt_atp_plant.
  endif.
  APPEND is_avail_plant     TO lt_atp_plant.
  APPEND LINES OF it_avail_prev_lines TO lt_atp_plant.

  ls_atpca-anwdg = ' '.
  ls_atpca-azerg = '1'.
  ls_atpca-rdmod = a.
  ls_atpcb-meins = is_goitem-meins.
  CALL FUNCTION 'AVAILABILITY_CHECK_CONTROLLER'
    TABLES
      p_atpcsx = lt_atp_plant
    CHANGING
      p_atpca  = ls_atpca
      p_atpcb  = ls_atpcb
    EXCEPTIONS
      error    = 1.

  CHECK sy-subrc IS INITIAL.

  READ TABLE lt_atp_plant INTO ls_avail
                          WITH KEY chkflg = 'X'.
  IF sy-subrc = 0 AND ( ls_avail-vmeng < ls_avail-bdmng ).
    l_error = 'X'.
  ENDIF.

  IF ( i_kzvbp = 'B' OR i_kzvbp = 'F' ) AND l_error = 'X'.
    WRITE ls_avail-vmeng UNIT is_goitem-meins TO l_quantity_out
    LEFT-JUSTIFIED.
    WRITE is_goitem-meins TO l_unit_out.

    CALL METHOD oref_atp_log->refresh.

    CALL METHOD oref_atp_log->context_set
         EXPORTING i_global_counter = is_goitem-global_counter.

    CALL METHOD oref_atp_log->message_add
      EXPORTING i_msgty = 'E'
                i_msgid = 'M7'
                i_msgno = '181'
                i_msgv1 = ls_avail-bdter
                i_msgv2 = l_quantity_out
                i_msgv3 = l_unit_out.

    e_shortage_plant = 'E'.
*      CALL METHOD oref_atp_log->display.
  ENDIF.

ENDMETHOD.                    "availability_check


**********************************************************************
*  METHOD availability_gi_po - created by note 810352
**********************************************************************
METHOD availability_gi_po.
  data: lt_eket type standard table of eket,
        ls_eket type eket,
*       confirmed quantity cumulated over all schedule lines.
        l_vmeng type BESTMNG,
*       l_plifz (planned delivery time in EKPO) and l_dat01 (confirmed
*       date) are needed in case of partially confirmed schedule lines
*       they are use to determin the confirmed date.
        l_dat01 TYPE DAT05,
        l_plifz TYPE EPLIF.

  clear e_bdter.

  CALL FUNCTION 'ME_READ_SCHEDULES_HEADER'
       EXPORTING
            i_ebeln   = i_po_numb
            i_ebelp   = i_po_item
       tables
            t_eket    = lt_eket
      EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  clear: l_vmeng.
* the loop adds up the quantitis of all relevant schedule lines for
* the PO item
  Loop at lt_eket into ls_eket.
    clear: l_dat01.
*                                                  start of note 1466907
    if ( ls_eket-dat01  = '99991231' and ls_eket-mng02 <> 0 ).
      l_dat01 = ls_eket-mbdat.
      if l_dat01 is initial.
        select single plifz from ekpo
                            into l_plifz
                            where EBELN = i_po_numb and
                                  EBELP = i_po_item.
        l_dat01 = ls_eket-eindt - l_plifz.
      endif.
    elseif not ls_eket-dat01 is initial.
      l_dat01 = ls_eket-dat01.
    endif.
    if not l_dat01 is initial.
*                                                    end of note 1466907
      l_vmeng = l_vmeng + ls_eket-mng02 - ls_eket-wamng.
      if e_bdter < l_dat01.
        e_bdter = l_dat01.
      endif.
    endif.
  endloop.
  if l_vmeng < 0.
    clear l_vmeng.
  endif.

  c_vmeng = l_vmeng.

ENDMETHOD.                    "availability_gi_po