*&---------------------------------------------------------------------*
*&      Form  vas_simulate_aufrufen
*&---------------------------------------------------------------------*
*       text: call function module w_frm...simulate; record main item
*             and subitems for lateron call of w_frm..correct
*----------------------------------------------------------------------*
FORM vas_simulate_aufrufen.

  DATA: BEGIN OF H_MSEG OCCURS 0.
          INCLUDE STRUCTURE MSEG.
  DATA: END OF H_MSEG.
  DATA: BEGIN OF U_MSEG OCCURS 0.
          INCLUDE STRUCTURE RFRMMSEG.
  DATA: END OF U_MSEG.

* fill interface of fct module
  clear: h_mseg, u_mseg.
  refresh: h_mseg, u_mseg.
  move mseg to h_mseg.
  append h_mseg.
  loop at vas_mseg where ebeln = mseg-ebeln and uebpo = mseg-ebelp.
    move vas_mseg to u_mseg.
* urzei is an important pointer for FRM
    move mseg-zeile to u_mseg-urzei.
    append u_mseg.
  endloop.

  CALL FUNCTION 'W_FRM_GR_ASSIGNMENT_SIMULATE'
       EXPORTING
            NO_RELEVANCE  = ' '
       TABLES
            T_MSEG          = H_MSEG
            T_MSEG_SUBITEMS = U_MSEG
       EXCEPTIONS
            NOTHING_TO_DO = 1
            OTHERS        = 2.

  if sy-subrc is initial.
* memorizing flag for buchen_ausfuehren
    vas_vorgang_aktiv = x.
    fuss-xvash = xvash_passed.
* memorize main and subitems for lateron call of ..correct
    move h_mseg to cd_mseg_eingemischt.
    append cd_mseg_eingemischt.
    if sy-subrc is initial.
      loop at u_mseg.
        move u_mseg to vas_mseg_eingemischt.
        append vas_mseg_eingemischt.
      endloop.
    endif.
  endif.

ENDFORM.                    " vas_simulate_aufrufen