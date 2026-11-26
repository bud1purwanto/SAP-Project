*&---------------------------------------------------------------------*
*&      Form  GRUKO_VORBEREITEN
*&---------------------------------------------------------------------*
*       Beim ändern des Gruppenkontrakts wird die interne Tabelle
*       GRULI mit den entsprechenden Feldern vor der Änderung des
*       Kontrakts gefüllte, damit bei PUSH mit dem Zustand der Felder
*       vor der Änderung verglichen werden kann.
*----------------------------------------------------------------------*
form gruko_vorbereiten.

* Globale Daten für Gruppenkontrakt setzen
  call function 'SD_GROUPCONTRACT_SETDATA'
       exporting
            i_vbtyp = vbak-vbtyp.

* Originaldaten für Gruppenkontrakt einlesen
  check: vbak-vbtyp eq vbtyp_gruko.

  perform gruli_tables_prepare(sapfv45k).

  call function 'SD_GROUPCONTRACT_PREPAREDATA'
       exporting
            i_mode       = 'PUSH_OLD'
            i_vbeln_grp  = vbak-vbeln
            i_scheme_grp = vbak-scheme_grp
            i_gvbak      = vbak
            i_gvbkd      = vbkd
            i_gveda      = veda
            i_gfpla      = fpla
       tables
            t_gvbpa      = xvbpa.

* Referenzierte Unterkontrakte einlesen
  perform gruko_aufsetzen.

endform.                               " GRUKO_VORBEREITEN