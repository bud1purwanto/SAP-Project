*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PARTNER_CALL_BACK                                 *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PARTNER_CALL_BACK
*&---------------------------------------------------------------------*
*       Änderungs-Flags aus Partnerverarbeitung holen
*----------------------------------------------------------------------*

form partner_call_back tables t_changes  type lv09a_changed_values
                       using us_event    type sd_partner_call_back_event
                             us_roletype type sd_partner_roletype
                             us_posnr    type posnr.

  case us_roletype.
    when part_call_back_roletype_rg.
      loop at t_changes where fieldname ne 'ADRNR' and
                              fieldname ne 'ADRDA' and
                              fieldname ne 'TITLE' and
                              fieldname ne 'NAME1' and
                              fieldname ne 'NAME2' and
                              fieldname ne 'NAME3' and
                              fieldname ne 'NAME4' and
                              fieldname ne 'CITY1' and
                              fieldname ne 'CITY2' and
                              fieldname ne 'CITY_CODE' and
                              fieldname ne 'CITYP_CODE' and
                              fieldname ne 'POST_CODE1' and
                              fieldname ne 'POST_CODE2' and
                              fieldname ne 'POST_CODE3' and
                              fieldname ne 'PO_BOX' and
                              fieldname ne 'PO_BOX_LOC' and
                              fieldname ne 'PO_BOX_REC' and
                              fieldname ne 'PO_BOX_CTY' and
                              fieldname ne 'TRANSPZONE' and
                              fieldname ne 'STREET' and
                              fieldname ne 'HOUSE_NUM1' and
                              fieldname ne 'STR_SUPPL1' and
                              fieldname ne 'STR_SUPPL2' and
                              fieldname ne 'STR_SUPPL3' and
                              fieldname ne 'LOCATION' and
                              fieldname ne 'BUILDING' and
                              fieldname ne 'ROOMNUMBER' and
                              fieldname ne 'COUNTRY' and
                              fieldname ne 'LANGU'  and
                              fieldname ne 'REGION' and
                              fieldname ne 'REMARK' and
                              fieldname ne 'DEFLT_COMM' and
                              fieldname ne 'TIME_ZONE' and
                              fieldname ne 'LANGU_CREA' and
                              fieldname ne 'ADDR_CHANGED' and
                              fieldname ne 'SORT1' and
                              fieldname ne 'SORT2'.
      endloop.
      if sy-subrc eq 0 or rv02p-rgupd = charx.
        rv02p-rgupd = charx.
      else.
        rv02p-rgupd = ' '.
      endif.
    when part_call_back_roletype_sb.
      rv02p-sbupd = charx.
    when part_call_back_roletype_we.
      loop at t_changes where fieldname eq 'PARNR' or
                              fieldname eq 'COUNTRY' or
                              fieldname eq 'TRANSPZONE' or
                              fieldname eq 'REGION' or
                              fieldname cp 'CITY*' or
                              fieldname cp 'PO*' or
                              fieldname eq 'TAXJURCODE' or
                              fieldname eq 'STCEG'.
        rv02p-weupd = charx.
        exit.
      endloop.
      if rv02p-weupd is initial.
        loop at t_changes where fieldname eq 'ABLAD'.
          gf_ablad_changed = charx.
          exit.
        endloop.
      endif.
  endcase.

  r185d-dataloss = charx.

endform.                               "PARTNER_CALL_BACK