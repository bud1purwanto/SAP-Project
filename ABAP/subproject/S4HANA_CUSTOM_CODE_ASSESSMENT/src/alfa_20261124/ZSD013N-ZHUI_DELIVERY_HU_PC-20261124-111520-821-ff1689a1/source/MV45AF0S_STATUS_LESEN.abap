*----------------------------------------------------------------------*
*   INCLUDE MV45AF0S_STATUS_LESEN                                      *
*----------------------------------------------------------------------*
*  Es wird der aktuelle Zustand der im Übersichtsbild anzuzeigenden    *
*  System- und Anwenderstatus ermittelt                                *
*----------------------------------------------------------------------*
form status_lesen.

  data: begin of name,
      fest(10) value 'RV45A-STAT',
      nr type lfdst,
    end of name,
    statustyp,
    status type j_status,
    da_subrc like sy-subrc.

  statics: st_jsto like jsto.

  field-symbols: <status>.

* Nur wenn ein Statusobjekt zur Position vorhanden
  check: not vbap-objnr is initial.

  loop at xtvstat where auart = tvak-auart.
    move: xtvstat-lfdst to name-nr,
          xtvstat-status to status,
          xtvstat-status to statustyp.
    assign (name) to <status>.

* Anwenderstatus nur untersuchen, wenn aktuelles Statusschema stimmt
    if statustyp eq type_e.
* Statusschema ermitteln
      if st_jsto-objnr ne vbap-objnr.
        call function 'STATUS_OBJECT_READ'
             exporting
                  objnr  = vbap-objnr
             importing
                  e_jsto = st_jsto
             exceptions
                  others = 1.
      endif.
      check xtvstat-stsma eq st_jsto-stsma.
    endif.

* Ist der anzuzeigende Status aktiv?
    call function 'STATUS_CHECK'
         exporting
              objnr             = vbap-objnr
              status            = status
         exceptions
              object_not_found  = 1
              status_not_active = 2
              others            = 3.
    if sy-subrc <> 0 and sy-subrc <> 2.
      message id sy-msgid type type_s number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    elseif sy-subrc = 0.
      move charx to <status>.
    else.
      move space to <status>.
    endif.
  endloop.
endform.