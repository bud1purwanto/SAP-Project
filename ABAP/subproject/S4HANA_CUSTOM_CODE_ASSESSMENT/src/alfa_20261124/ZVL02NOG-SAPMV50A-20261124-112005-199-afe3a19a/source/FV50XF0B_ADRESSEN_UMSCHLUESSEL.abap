***INCLUDE FV50XF0B_ADRESSEN_UMSCHLUESSEL .
*---------------------------------------------------------------------*
*       FORM ADRESSEN_UMSCHLUESSELN (4.0C)                            *
*---------------------------------------------------------------------*
*       In der ZAV wird der Verwendungsnachweis für die Adressen      *
*       gleich bei der Vergabe der Adressnummer geschrieben. Daher    *
*       darf die Umschlüsselung der Adressen erst nach der Vergabe    *
*       der Belegnummern stattfinden                                  *
*       Für künftige Entwicklungen: Die vorläufige Adressnummer bei   *
*       manuellen Adressen muß innerhalb eines Sammellaufs eindeutig  *
*       sein, wenn man dereinst mehrere Belege mit manuellen Adressen *
*       gleichzeitig sichern möchte.                                  *
*                                                                     *
*---------------------------------------------------------------------*
* This form is inactive in release 4.6A
*
form adressen_umschluesseln.

* address handle, application key and application table in CAM
  data: lf_appl_key        like   addr_ref-appl_key,
        lf_appl_table      like   addr_ref-appl_table,
        lf_appl_field      like   addr_ref-appl_field,
        lf_address_handle  like   szad_field-handle,
        lf_update_task     type   c.

  if v50agl-synchron ne space.
    lf_update_task = space.
  else.
    lf_update_task = charx.
  endif.

  loop at xvbadr where updkz eq updkz_new.

*   address handle used in CAM
    lf_address_handle = xvbadr-adrnr.
*   application table and application field
    case aufrufer.
      when chart.                      "transport
        lf_appl_table = gcf_appl_table_tra.
        lf_appl_field = gcf_appl_field_tra.
      when others.
        lf_appl_table = gcf_appl_table_sd.
        lf_appl_field = gcf_appl_field_sd.
    endcase.

*   Build application key used in CAM
    read table xvbpa with key adrnr = xvbadr-adrnr.
    if sy-subrc ne 0.
      continue.
    endif.
    concatenate sy-mandt xvbpa-vbeln into lf_appl_key.

*   get address number
    call function 'SD_ADDRESS_NUMBER_GET'
         exporting
              fif_address_handle         = lf_address_handle
*             FIF_ADDRESS_GROUP          = 'SD01'
              fif_appl_table             = lf_appl_table
              fif_appl_field             = lf_appl_field
              fif_appl_key               = lf_appl_key
              fif_execute_in_update_task = lf_update_task
         importing
              fef_address_number         = xvbadr-adrnr
         exceptions
              number_not_found           = 0
              others                     = 0.

*   modify address numbers in XVBADR
    clear xvbadr-adrnp. "clear person number (manual address)
    modify xvbadr.

*   modify address numbers in XVBPA
*   Note: one address number can be assigned to several partner roles
*   if partner is a CPD customer
    loop at xvbpa where adrnr eq lf_address_handle.
      xvbpa-adrnr = xvbadr-adrnr.
      clear xvbpa-adrnp.
      modify xvbpa.
    endloop.

  endloop.

endform.                    "ADRESSEN_UMSCHLUESSELN