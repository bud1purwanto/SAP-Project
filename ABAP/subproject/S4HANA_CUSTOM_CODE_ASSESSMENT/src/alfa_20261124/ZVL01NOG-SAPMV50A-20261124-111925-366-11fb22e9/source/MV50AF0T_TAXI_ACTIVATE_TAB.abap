*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TAXI_ACTIVATE_TAB                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TAXI_ACTIVATE_TAB
*&---------------------------------------------------------------------*
*       Bringt den zu übergebenen semantischen Funktionscode gehören-
*       den Tabstrip-Reiter in den Vordergrund und speichert diesen
*       Funktionscode anschließend in der Tabelle der Bildgruppen-
*       attribute.
*----------------------------------------------------------------------*
form taxi_activate_tab
   tables   ta_screen_groups  like taxi_screen_groups[]
                              "Tabelle der Bildgruppenattribute
   using    us_fcode          like taxi_params-fcode
                              "FCode aus Folgebildsteuerung
            us_screen_group   like taxi_screen_group
                              "aktuelle Bildgruppe
   changing ch_tabstrip       like taxi_tabstrip.
  "Tabstrip-Control zur aktuellen Bildgruppe

* Reiteraktivierung veranlassen
  call function 'TAXI_ACTIVATE_TAB'
    exporting
      fcode        = us_fcode
    changing
      tabstrip     = ch_tabstrip
    exceptions
      no_tab_fcode = 1
      others       = 2.

* Ist der ausgelöste Funktionscode überhaupt ein Reiter-Funktionscode ?
  if sy-subrc eq 0.

*   The sequence of tabs may be changed by BAdIs: Translation between
*   the visible tab structure and the tab structure inside function
*   group TAXI is necessary. Note that GT_TAXI_ADMIN is sorted by
*   FCODE_NEW (no binary access is possible here)
    read table gt_taxi_admin
               with key fcode_old = ch_tabstrip-activetab.
    if sy-subrc eq 0.
      ch_tabstrip-activetab = gt_taxi_admin-fcode_new.
    endif.

*   Falls ja, FCode in der Tabelle der Bildgruppenattribute ablegen
    loop at taxi_screen_groups
          where screen_group = us_screen_group.
      taxi_screen_groups-tab_fcode = us_fcode.
      modify taxi_screen_groups.
    endloop.
  endif.

endform.                               " TAXI_ACTIVATE_TAB