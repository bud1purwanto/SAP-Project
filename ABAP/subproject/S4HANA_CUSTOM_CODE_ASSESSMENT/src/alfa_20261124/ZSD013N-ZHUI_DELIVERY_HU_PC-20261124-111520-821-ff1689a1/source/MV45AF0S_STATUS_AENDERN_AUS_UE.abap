*----------------------------------------------------------------------*
*   INCLUDE MV45AF0S_STATUS_AENDERN_AUS_UE                             *
*----------------------------------------------------------------------*
form status_aendern_aus_uebersicht.

  data:
  begin of rname,
    fest(10) value 'RV45A-STAT',
    nr type lfdst,
  end of rname,
  da_vrgng like tj01-vrgng,
  da_subrc like sy-subrc,
  da_statustext like tj02t-txt30,
  da_statustext04 like tj02t-txt04,
  da_inact,
  da_vbap_status_object like jsto,
  da_status_changed,
  da_stonr like tj30-stonr,
  da_type.
  field-symbols: <status>.

* Nur wenn Position ein Statusobjekt besitzt
  check not vbap-objnr is initial.

* Statusschema der Position gemäß Statusverwaltung ermitteln
  call function 'STATUS_OBJECT_READ'
       exporting
            objnr  = vbap-objnr
       importing
            e_jsto = da_vbap_status_object
       exceptions
            others = 1.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Loop über die gemäß Customizing anzuzeigenden Status
  loop at xtvstat where auart = tvak-auart.

* Nur Systemstatus oder für das aktuelle Statusschema relevante Status
    move xtvstat-status to da_type.
    check da_type eq type_i or
          xtvstat-stsma eq da_vbap_status_object-stsma.

    move xtvstat-lfdst to rname-nr.
    assign: (rname) to <status>.

* Ordnungsnummer des Statuses auslsen
    select single stonr from tj30 into da_stonr
                        where stsma = xtvstat-stsma
                        and   estat = xtvstat-status.

* Prüfung nur dann, wenn sich auch etwas geändert hat
    call function 'STATUS_CHECK'
         exporting
              objnr             = vbap-objnr
              status            = xtvstat-status
         exceptions
              object_not_found  = 1
              status_not_active = 2
              others            = 3.
    if sy-subrc <> 0 and sy-subrc ne 2.
      continue.
    else.
      if <status> = 'X' and sy-subrc = '0' or
         <status> = ' ' and sy-subrc = '2'.
        continue.
      else.
* Keine Aktion wenn bereits ein Status mit Ordnungsnummer gesetzt ist
        if not da_stonr is initial and da_status_changed = 'X'.
          continue.
        endif.
      endif.
    endif.

* Prüfen, ob Status geändert werden dürfen
    perform status_aendern_pruefen(sapfv45p)     using xtvstat-status
                                                       vbap-objnr
                                                       <status>
                                                       space
                                                       space
                                              changing da_vrgng
                                                       da_subrc.
    if da_subrc ne 0.
* Statusbezeichnung aufbereiten
      call function 'STATUS_NUMBER_CONVERSION'
           exporting
                language      = sy-langu
                status_number = xtvstat-status
                stsma         = xtvstat-stsma
           importing
                txt04         = da_statustext04
                txt30         = da_statustext
           exceptions
                others        = 1.
      if <status> eq charx. " Status kann nicht gesetzt werden
        message i206(v2) with da_statustext da_statustext04.
      else.                " Status kann nicht gelöscht werden
        message i207(v2) with da_statustext da_statustext04.
      endif.
      exit.
    else.
* Änderung durchführen
* Anwenderstatus: direkt
      if da_type eq type_e.
        move <status> to da_inact.
        translate da_inact using 'X  X'.
* Status mit Ordnungsnummer wurde gesetzt
        if not da_stonr is initial and
               da_inact is initial.
          da_status_changed = 'X'.
        endif.
        call function 'STATUS_CHANGE_EXTERN'
             exporting
                  objnr       = vbap-objnr
                  user_status = xtvstat-status
                  set_inact   = da_inact
             exceptions
                  others      = 1.
        if sy-subrc <> 0.
* Statusbezeichnung aufbereiten
          call function 'STATUS_NUMBER_CONVERSION'
               exporting
                    language      = sy-langu
                    status_number = xtvstat-status
                    stsma         = xtvstat-stsma
               importing
                    txt30         = da_statustext
                    txt04         = da_statustext04
               exceptions
                    others        = 1.
          if da_inact = space.
            message i206(v2) with da_statustext da_statustext04.
          else.
            message i207(v2) with da_statustext da_statustext04.
          endif.
          exit.
        endif.
* Systemstatus: Über SD-eigenen Funktionsbaustein
      elseif not da_vrgng is initial.
        call function 'SD_ITEM_CHANGE_STATUS'
             exporting
                  i_vrgng          = da_vrgng
                  i_vbap           = vbap
                  i_vbak           = vbak
             tables
                  fxvbfa           = xvbfa
                  fxvbapf          = xvbapf
                  fxvbup           = xvbup
                  fxvbep           = xvbep
             exceptions
                  no_status_object = 1
                  no_activity      = 2
                  missing_data     = 3
                  not_allowed      = 4
                  fatal_error      = 5
                  others           = 6.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      endif.
    endif.
  endloop.
endform.