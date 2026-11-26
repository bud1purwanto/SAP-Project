*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_TR_INIT                              *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Text Control Initialisierung im Transaktion_Init                   *
*----------------------------------------------------------------------*
form text_control_tr_init.

  data: da_nodialog type c.

* Ab Release 99A: Active X Controls (oder Beans) sind stets verfügbar
  text_control_available = charx.
  call function 'DIALOG_GET_STATUS'
       importing
            dialog_status = da_nodialog.
* Nicht im BAPI-, Batch- oder Catt-Modus
ENHANCEMENT-SECTION     TEXT_CONTROL_TR_INIT_01 SPOTS ES_SAPMV45A.
  if not da_nodialog is initial or
     not sy-binpt is initial or
     not sy-batch is initial or
     not cattaktiv is initial.
    text_control_available = space.
    exit.
  endif.
END-ENHANCEMENT-SECTION.

* Bestimme die Kopfgruppen mit Text Edit Control im Body Subscreen
  call function 'SD_SCREEN_GROUPS_WITH_TEC'
       tables
            kopgr_tab = kgtab.

endform.