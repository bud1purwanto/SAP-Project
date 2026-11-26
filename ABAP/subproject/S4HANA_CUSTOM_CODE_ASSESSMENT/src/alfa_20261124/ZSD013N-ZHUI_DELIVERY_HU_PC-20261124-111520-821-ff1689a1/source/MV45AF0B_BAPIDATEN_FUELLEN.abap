*&---------------------------------------------------------------------*
*&      Form  BAPIDATEN_FUELLEN                                        *
*&---------------------------------------------------------------------*
* Da im Beleg Sichern  ev. die Einteilungen geändert werden , werden   *
* diese in die Sondertabelle gefüllt.                                  *
*----------------------------------------------------------------------*
FORM BAPIDATEN_FUELLEN.
     REFRESH FXVBEP.
     CLEAR   FXVBEP.
     LOOP AT IVBEP1.
          READ TABLE XVBEP INDEX IVBEP1-TABIX.
          MOVE-CORRESPONDING XVBEP TO FXVBEP.
          APPEND FXVBEP.
     ENDLOOP.

     refresh fxvbap. clear fxvbap.
     loop at xvbap into fxvbap where updkz ne updkz_delete.
          append fxvbap.
     endloop.
ENDFORM.

form bapidaten_fuellen_xvbpa.
     refresh fxvbpa. clear fxvbpa.
     fxvbpa[] = xvbpa[].
endform.