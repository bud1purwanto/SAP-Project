*&---------------------------------------------------------------------*
*&  Include           MV50AF0F_FELDA_DOCUBATCH
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_DOCUBATCH                                    *
*---------------------------------------------------------------------*
*       Feste Feldmodifikation zur Eingabebereitschaft von            *
*       Dokumentationschargen                                         *
*---------------------------------------------------------------------*
form feldauswahl_docubatch
  changing
    cf_exit_flag        type c.

  data:
    ls_vbup             type vbup,
    ls_t340D            type t340D.

  check not gf_docubatch_active is initial.

  check screen-group1 eq 'DBT'.

  if likp-vbtyp ne vbtyp_lino and
     likp-vbtyp ne vbtyp_liav.
    screen-active    = '0'.
    screen-input     = '0'.
    screen-invisible = '1'.
    cf_exit_flag = 'X'.
    exit.
  endif.

  if  lips-posnr is initial.
*   do not change any setting
*    cf_exit_flag = 'X'.
*    exit.
  endif.

  if lipsd-docubatch_control is initial.
    screen-active    = '0'.
    screen-input     = '0'.
    screen-invisible = '1'.
    cf_exit_flag = 'X'.
    exit.
  else.
    if lips-vbeln is not initial and
       lips-posnr is not initial.
      read table xvbup
        into ls_vbup
        with key vbeln = lips-vbeln
                 posnr = lips-posnr.
      if sy-subrc      is initial and
         ls_vbup-wbsta is initial.
        screen-active    = '0'.
        screen-input     = '0'.
        screen-invisible = '1'.
        cf_exit_flag = 'X'.
        exit.
      endif.
    endif. " lips-vbeln is not initial and
  endif.

  if screen-name eq 'LIPSD-DOCUBATCH_CHARG'.
    if lipsd-docubatch_mult_entries eq 'X' or
       ls_vbup-wbsta                eq 'C' or
       lips-komkz                   CA 'C12' or
       ( lips-komkz                  = 'D' and
         vbup-lvsta                 CA 'AB'    ).
      screen-active    = '1'.
      screen-input     = '0'.
      screen-invisible = '0'.
      cf_exit_flag = 'X'.
    elseif likp-vlstk <> ' ' "distirbution case  note
      and lips-lgnum is not initial.
      CALL FUNCTION 'L_T340D_READ_SINGLE'
        EXPORTING
          iv_lgnum        = lips-lgnum
        IMPORTING
          ES_T340D        = ls_t340D
        EXCEPTIONS
          NOT_FOUND       = 1
          OTHERS          = 2.
      IF sy-subrc <> 0 or
         ls_t340D-decsy <> ' '.
        screen-active    = '1'.
        screen-input     = '0'.
        screen-invisible = '0'.
        cf_exit_flag = 'X'.
      ENDIF.

    endif.
  endif.
ENHANCEMENT-POINT EHP603_FELDAUSWAHL_DOCUBATCH01 SPOTS ES_SAPMV50A.

endform.                    "feldauswahl_docubatch

*&--------------------------------------------------------------------*
*&      Form  feldauswahl_docubatch_tc
*&--------------------------------------------------------------------*
*       set columns of table control (picking) invisible
*       if fucntion 'documentary batch' not active
*---------------------------------------------------------------------*
form feldauswahl_docubatch_tc.

  field-symbols:
    <fs_screen>         type cxtab_column.

  if gf_docubatch_active is initial or
   ( likp-vbtyp ne vbtyp_lino and
     likp-vbtyp ne vbtyp_liav ).

* documentary batch not active => set columns invisible
    loop at <tc>-cols
      assigning <fs_screen>
      where screen-group1 eq 'DBT'.
      <fs_screen>-invisible = '1'.
    endloop.

  endif.

endform.                    "feldauswahl_docubatch_tc