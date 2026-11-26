*&---------------------------------------------------------------------*
*&      Form  SD_CHECK_XDELIV
*&---------------------------------------------------------------------*
*  Check if xdeliv='X' is correct.
*  For example: MB01 reads the PO and sets xdeliv='X' directly (in case
*  of HU-duty). After that, the user is able to change all storage
*  locations. If there is no position with a HU-duty storage location
*  xdeliv is still 'X'. This form is able to clear XDELIV.
*----------------------------------------------------------------------*
form sd_check_xdeliv.
  data: l_subrc type sy-subrc.

  read table zdm07m with key umxhupf = x.
  l_subrc = sy-subrc.
  read table xvm07m with key xhupf   = x.
  if l_subrc <> 0 and sy-subrc <> 0.
    clear xdeliv.
  endif.
endform.                    " SD_CHECK_XDELIV