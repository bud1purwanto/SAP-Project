*----------------------------------------------------------------------*
*   INCLUDE MV45AFFE_FELDAUSWAHL_RV45A_STA                             *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Feldauswahl für die Statusfelder und -Texte im Übersichtsbild.
*----------------------------------------------------------------------*

form feldauswahl_rv45a_status using us_name
                              changing ch_invisible
                                       ch_input
                                       ch_active.

  data: da_lfdst like tvstat-lfdst,
        da_type,
        da_vrgng type j_vorgang,
        da_subrc like sy-subrc,
        da_name(12).
  statics: st_jsto like jsto.

* Das Move liefert die letzten beiden Ziffern von RV45A-STATxx
  write us_name to da_name left-justified.
  move da_name to da_lfdst.

* Definierte Startwerte
  ch_invisible = 0.
  ch_active = 1.
  if t180-trtyp eq chara.
    ch_input  = 0.
  else.
    ch_input  = 1.
  endif.

* Nur soviele Status anzeigen wie im Customizing definiert
  if da_lfdst gt maxstats.
    ch_active = 0.
  elseif da_name cp 'RV45A-STAT*'. " Nicht bei der Spaltenüberschrift
* Nur wenn Statusobjekt existiert
    if vbap-objnr is initial.
      ch_active = 0.
    else.
      read table xtvstat with key auart = tvak-auart
                                  lfdst = da_lfdst
                         binary search.
      if sy-subrc ne 0 or
         xtvstat-status is initial.
        ch_active = 0.
      else.
* Anwender- oder Systemstatus
        move xtvstat-status to da_type.
* Bei Anwenderstatus: Aktuelles Statusschema ermitteln
        if da_type eq type_e.
          if st_jsto-objnr ne vbap-objnr.
            call function 'STATUS_OBJECT_READ'
                 exporting
                      objnr  = vbap-objnr
                 importing
                      e_jsto = st_jsto
                 exceptions
                      others = 1.
          endif.
        endif.
* Anwenderstatus: Stimmt Schema überein? Nein-> Ausblenden
        if da_type eq type_e and
           st_jsto-stsma ne xtvstat-stsma.
          ch_active = 0.
* War im Customizing nur Anzeigefunktion eingestellt?
        elseif xtvstat-only_display eq charx.
          ch_input = 0.
        else.
* Änderbarkeit für Feldauswahl (Regel 'F')
          perform status_aendern_pruefen(sapfv45p) using xtvstat-status
                                                           vbap-objnr
                                                           charf
                                                           space
                                                           charx
                                                  changing da_vrgng
                                                           da_subrc.
          if da_subrc ne 0.
            ch_input = 0.
          endif.
        endif.
      endif.
    endif.
  endif.
endform.