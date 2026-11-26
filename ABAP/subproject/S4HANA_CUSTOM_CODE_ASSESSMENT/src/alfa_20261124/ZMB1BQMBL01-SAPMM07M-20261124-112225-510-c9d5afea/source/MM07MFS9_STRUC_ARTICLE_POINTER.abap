* vsa struct. article
*&---------------------------------------------------------------------*
*&      Form  STRUC_ARTICLE_POINTER
*&---------------------------------------------------------------------*
*       text: get the line index of the original line item (647) and   *
*             assign it to the automatically created line item (101)   *
*----------------------------------------------------------------------*
FORM STRUC_ARTICLE_POINTER.

  if vm07m-kzbwa = kzbwa-05.
    if not ( vm07m-attyp = attyp-vks  or  vm07m-attyp = attyp-lot  or
             vm07m-attyp = attyp-dis ).
* no structured article involved -> forget about oruml
      clear dm07m-oruml.
    endif.
  elseif vm07m-kzbwa is initial.
* receiver line item
*   if not vm07m-xhead is initial.                         "note 307556
*   für logistische Mengeneinheiten nicht ermitteln        "note 307556
    if not vm07m-xhead is initial                          "note 307556
       and vm07m-bflme is initial.                         "note 307556
* get 'zeile' of sender's line
      data h_ydm07m like ydm07m.
      read table ydm07m with key oruml = dm07m-oruml into h_ydm07m.
      if not sy-subrc is initial.
        message e001 with dm07m-oruml space space 'YDM07M'.
      endif.
      move h_ydm07m-zeild to dm07m-oruml.
    else.
      clear dm07m-oruml.
    endif.
  endif.

ENDFORM.                    " STRUC_ARTICLE_POINTER