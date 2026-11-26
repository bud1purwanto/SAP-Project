*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T300T_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T300BT_SELECT                                             *
*---------------------------------------------------------------------*
*       Text zur Lagernummer ermitteln                                 *
*---------------------------------------------------------------------*
form t300t_select using i_lgnum like t300t-lgnum.

  check i_lgnum ne t300t-lgnum and
        i_lgnum ne space.

  select single * from t300t where spras = sy-langu and
                                   lgnum = i_lgnum.

  if sy-subrc ne 0.
    clear t300t.
  endif.

endform.                    "T300T_SELECT