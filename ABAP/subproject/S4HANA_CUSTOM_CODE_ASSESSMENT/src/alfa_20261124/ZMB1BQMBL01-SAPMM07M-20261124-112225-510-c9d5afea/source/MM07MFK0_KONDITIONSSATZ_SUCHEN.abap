*eject
*---------------------------------------------------------------------*
*       FORM KONDITIONSSATZ_SUCHEN                                    *
*---------------------------------------------------------------------*
*       Zum Material/Lieferant wird ein Konditionssatz gesucht.       *
*---------------------------------------------------------------------*
form konditionssatz_suchen.
  data: l_msgvs type t160m-msgvs,                               "543499
        l_msgty type sy-msgty.                                  "543499

  check aktyp ne a and rm07m-kzbew = b and not t156-xnebe is initial
  and not mseg-matnr is initial.
  if mseg-erfmg is initial.
    set cursor field 'MSEG-ERFMG' line sy-stepl.
    message e129.
  endif.

  data: i_retpo like ekpo-retpo.
  if t156-shkzg = h.
    if t158b-xkzbew = 4.
      i_retpo = x.
    else.
      message e251.
    endif.
  endif.

  call function 'ME_SET_PO_HEAD'
       exporting
            pi_lifnr      = mseg-lifnr
            pi_budat      = mkpf-budat
            pi_kurstyp    = t003-kurst
       exceptions
            err_calling_seq = 1
            err_parameter   = 2
            others          = 3.
  if not sy-subrc is initial.
*   If we have an error, we issue the stored error message, if
*   available. If not, we use a default message.
    if not sy-msgid is initial.                                  "572712
      message id sy-msgid type e number sy-msgno
                          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    else.
      message e250 with mseg-zeile.
    endif.
  endif.
  data: bwtar like mseg-bwtar.
  clear bwtar.
  if vm07m-xchpf is initial and not dm07m-xchar is initial.
    bwtar = mseg-charg.
  endif.
  call function 'ME_CHECK_ITEM'
       exporting
            pi_matnr      = mseg-matnr
            pi_menge      = mseg-erfmg
            pi_meins      = mseg-erfme
            pi_werks      = mseg-werks
            pi_lgort      = mseg-lgort
            pi_bwtar      = bwtar
            pi_retpo      = i_retpo
       importing
            po_dbefu      = dbefu
       exceptions
            err_create_head   = 1
            err_create_item   = 2
            err_call_sequence = 3
            others            = 4.
  if not sy-subrc is initial.
*   Same procedure as during header creation
    if not sy-msgid is initial.                                  "572712
      message id sy-msgid type e number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    else.
      message e250 with mseg-zeile.
    endif.
  else.
* note 543499:
* If there is a valuation type set in the info record, it is obligatory
* when the purchase order is created automatically during the goods
* receipt. The user gets a message here and it is taken over for the
* posting of the material document if the customizing for the message is
* set to I. Otherwise, the document cannot be posted.
    if not dm07m-xchar is initial and bwtar <> dbefu-bwtar.      "543499
      get parameter id 'MSV' field l_msgvs.                      "543499
      if l_msgvs = space.                                        "543499
        l_msgvs = '00'.                                          "543499
      endif.                                                     "543499
      call function 'ME_CHECK_T160M'                             "543499
           exporting                                             "543499
                i_arbgb      = 'M7'                              "543499
                i_msgnr      = '380'                             "543499
                i_msgvs      = l_msgvs                           "543499
           exceptions                                            "543499
                warning      = 1                                 "543499
                success      = 2                                 "543499
                information  = 3                                 "543499
                others       = 4.                                "543499
* We change the screen using this valuation type -> the user has to get
* the information that it has been changed -> not possible to get no
* message. This is a very early moment, so that the user often did not
* make an entry yet. Therefore, an error message does not make sense.
* Customizing is especially required for MIGO (green/ red light).
      case sy-subrc.                                             "543499
        when 1 or 4.                                             "543499
          l_msgty = 'W'.                                         "543499
        when 2.                                                  "543499
          l_msgty = 'S'.                                         "543499
        when 3.                                                  "543499
          l_msgty = 'I'.                                         "543499
      endcase.                                                   "543499
      if xmigo = 'X'.                                            "543499
        call function 'MICK_MESSAGE_ADD'                         "543499
             exporting                                           "543499
                  i_msgty      = l_msgty                         "543499
                  i_msgid      = 'M7'                            "543499
                  i_msgno      = '380'                           "543499
                  i_msgv1      = dbefu-bwtar                     "543499
                  i_msgv2      = mseg-matnr.                     "543499
      else.                                                      "543499
        message id 'M7' type l_msgty number '380'                "543499
                with dbefu-bwtar mseg-matnr.                     "543499
      endif.                                                     "543499
    endif.                                                       "543499
    mseg-kzbew  = rm07m-kzbew.
    mseg-ebelp  = dbefu-ebelp.
    mseg-kzvbr  = dbefu-kzvbr.
*   setting of INSMK changed per note 435007 due to the following
*   reasons:
*
*   1. We should never use the suggested INSMK in case of returns as
*      this is a goods issue process. In that case the customer has
*      to decide about the INSMK for posting. (1)
*   2. We should always use the INSMK entered and determined in MIGO. If
*      QM is active they will change insmk in all necessary cases in
*      qss_testen. (2)
*
*   behaviour before/after correction:
*   legend: material master purchasing view : MM.PUR
*        insmk MM.PUR-101  insmk QM-101  insmk MM.PUR-161  insmk QM-161
*   MB01
*    _          X/X             X/X         X/_   (1)      X/_  (1)
*    X          X/X             X/X         X/X            X/X
*    S          S/S             S/S         S/S            S/S
*   MIGO
*    _          X/_  (2)        X/_  (2)     X/_  (1)+(2)  X/_  (1)+(2)
*    2          2/2             2/2          2/2           2/2
*    3          3/3             3/3          3/3           3/3
*
*   If additional correction is necessary, do not forget to change
*   comment.
    if mseg-insmk is initial             "only if not entered manually
       and i_retpo is initial            "and in case of GR
       and xmigo is initial.             "and never in MIGO
      mseg-insmk  = dbefu-insmk.         "take over suggested INSMK
    endif.
*   end of note 435007

*   begin of note 1396307
    if ( ( mseg-insmk = '2' or mseg-insmk = 'X' )
      or ( dbefu-insmk = 'X' ) ) and vm07m-ekorg is initial
      and i_retpo is initial.
*      Determine EKORG that it will be passed to the inspection lot.
*      Same as GR for PO when the EKORG comes from ME_READ...
      CALL FUNCTION 'ME_SELECT_EKORG_FOR_PLANT'
        EXPORTING
          I_WERKS                          = mseg-werks
*         I_PIPEL                          =
*         I_UMLAG                          =
*         I_KONSI                          =
          I_STANDARD                       = 'X'
        IMPORTING
          E_EKORG                          = vm07m-ekorg
        EXCEPTIONS
          MORE_THAN_ONE_ORGANIZATION       = 1
          NO_ENTRY_FOUND                   = 2
          NO_DEFAULT_FOUND                 = 3
          OTHERS                           = 4.
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      endif..
    endif.
*   end of note 1396307

    mseg-bstmg  = dbefu-bstmg.
    mseg-bstme  = dbefu-bstme.
    mseg-bprme  = dbefu-bprme.
    mseg-weunb  = dbefu-weunb.
    vm07m-webre = dbefu-webre.
    vm07m-retpo = dbefu-retpo.
    dm07m-umrez = dbefu-umrez.
    dm07m-umren = dbefu-umren.
    vm07m-bumrz = dbefu-umrez.
    vm07m-bumrn = dbefu-umren.
    dm07m-bpumz = dbefu-bpumz.
    dm07m-bpumn = dbefu-bpumn.
    vm07m-xnebe = t156-xnebe.
    vm07m-xkzbew = t158b-xkzbew.
    if not dbefu-bwtar is initial and
       vm07m-xchpf is initial and
       not dm07m-xchar is initial.
      mseg-charg = dbefu-bwtar.
      mseg-bwtar = dbefu-bwtar.                                  "543499
      dm07m-bwtor = dbefu-bwtar.                                 "543499
    elseif not dbefu-bwtar is initial and                        "543499
       not dm07m-xchar is initial.                               "543499
      mseg-bwtar = dbefu-bwtar.                                  "543499
      dm07m-bwtor = dbefu-bwtar.                                 "543499
    endif.
ENHANCEMENT-POINT KONDITIONSSATZ_SUCHEN_01 SPOTS ES_SAPMM07M.
    perform fuss_fuellen using space.
  endif.
endform.