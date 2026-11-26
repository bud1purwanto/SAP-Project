*&---------------------------------------------------------------------*
*&      Form  vas_subitems_uebergeben
*&---------------------------------------------------------------------*
*       text: in global table vas_mseg there might be some subitems
*             which belong to a main item which shall not be posted;
*             these subitems are filtered out before calling ..adjust;
*             the remaining subitems get the right value for urzei;
*----------------------------------------------------------------------*
FORM vas_subitems_uebergeben tables p_cd_mseg_adjust structure mseg
                                    p_vas_adjust structure rfrmmseg.

  loop at vas_mseg.
    clear sy-subrc.
* just read main item if necessary
    if vas_mseg-ebeln ne p_cd_mseg_adjust-ebeln  or
       vas_mseg-uebpo ne p_cd_mseg_adjust-ebelp.
* get main item
      read table p_cd_mseg_adjust with key ebeln = vas_mseg-ebeln
                                           ebelp = vas_mseg-uebpo.
    endif.
    if sy-subrc is initial.
      vas_mseg-urzei = p_cd_mseg_adjust-zeile.
      vas_mseg-mblnr = p_cd_mseg_adjust-mblnr.   "kh
      vas_mseg-mjahr = p_cd_mseg_adjust-mjahr.   "kh
      vas_mseg-bwart = p_cd_mseg_adjust-bwart.   "kh
      move vas_mseg to p_vas_adjust.
      append p_vas_adjust.
    endif.
  endloop.

ENDFORM.                    " vas_subitems_uebergeben