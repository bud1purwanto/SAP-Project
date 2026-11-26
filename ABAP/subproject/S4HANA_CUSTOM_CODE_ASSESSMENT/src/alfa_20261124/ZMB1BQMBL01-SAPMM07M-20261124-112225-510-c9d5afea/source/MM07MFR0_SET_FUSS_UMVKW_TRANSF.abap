*----------------------------------------------------------------------*
*   INCLUDE MM07MFR0_SET_FUSS_UMVKW_TRANSF                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  set_fuss_umvkw_transfer
*&---------------------------------------------------------------------*
* This one's called by beleg_ergaenzen (MM07MFB1).
* Necessary to fill VKWRT of the receiver right in case we're
* cancelling a transfer article -> article and EXVKW has been used on
* sender's site.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_fuss_umvkw_transfer.

  data: wa_xmseg like xmseg.
  data: wa_tabix like sy-tabix.

* search for automatically generated lines (transfer) with only
* value posting
  wa_tabix = tabix + 1.
  read table xmseg index wa_tabix into wa_xmseg.
  if sy-subrc = 0.
    if     wa_xmseg-xauto =  X           and
           wa_xmseg-urzei =  xmseg-zeile and " transfer
         (    xmseg-matnr <> xmseg-ummat or
              xmseg-werks <> xmseg-umwrk or
              xmseg-lgort <> xmseg-umlgo or
              xmseg-matnr =  xmseg-matbf ) and     "816611
       not wa_xmseg-ummat is initial     and
           wa_xmseg-matnr =  xmseg-ummat and
              vm07m-xstor =  2           and " cancel
           wa_xmseg-mengu =  space       and
       not wa_xmseg-wertu is initial     .   " value-based at sender
*     UMVKW of sender gets VKWRT of receiver
      fuss-umvkw = wa_xmseg-vkwrt.
    endif.
  endif.

endform.                    " set_fuss_umvkw_transfer
*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_SET_FUSS_UMVKW_TRANSF                   *
*&---------------------------------------------------------------------*