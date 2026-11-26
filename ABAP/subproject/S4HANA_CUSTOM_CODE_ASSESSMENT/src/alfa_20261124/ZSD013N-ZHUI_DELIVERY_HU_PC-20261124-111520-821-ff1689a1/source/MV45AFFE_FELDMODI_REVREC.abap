***INCLUDE MV45AFFE_FELDMODI_REVREC .
* start Revenue Recognition Project
FORM FIELDMODIFICATION_REV_REG.

* no changes of the item category, if revenue recognition relevant and
* if revenue already recognized or
* if invoices are created and released to accounting and then cancelled
  if screen-name eq 'VBAP-PSTYV' and
     t180-aktyp eq 'V' and
     not vbkd-rrrel is initial.

    if vbup-rrsta ca 'A' and
       vbup-fksaa ca 'A'.

      call function 'SD_FIND_VBREVR'
       exporting
         fif_vbap_vbeln              = vbup-vbeln
         fif_vbap_posnr              = vbup-posnr
       exceptions
         no_vbrevr_lines_found       = 1
         others                      = 2.

      if sy-subrc eq 0.
        screen-input = '0'.
      endif.

    else.

      if vbup-rrsta ca 'BC'.
        screen-input = '0'.
      endif.

    endif.

  ENDIF.

* no changes of billing date allowed, if revenue already recognized
* to prevent a bogus forecast line
  IF SCREEN-NAME EQ 'VBKD-FKDAT' AND
     VBUP-RRSTA CA 'BC' AND
     T180-AKTYP  EQ 'V'  AND
     VBKD-RRREL  EQ 'B'.
    SCREEN-INPUT = '0'.
  ENDIF.

ENDFORM.
* end Revenue Recognition Project