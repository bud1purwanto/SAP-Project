*---------------------------------------------------------------------*
*       FORM CUA_MODIFIZIEREN                                         *
*---------------------------------------------------------------------*
*       CUA-Status Stelle 4-8 dynamisch modifizieren                  *
*       Aufbau:                                                       *
*              Stelle 1-4 : fest aus Tabelle 185V                     *
*              Stelle 5-8 : variabel                                  *
*---------------------------------------------------------------------*
FORM CUA_MODIFIZIEREN USING US_STATUS.

  DATA: BEGIN OF DA_STATUS,
          FIX(4),
          VAR(4),
        END OF DA_STATUS.

     DA_STATUS = US_STATUS.

*    Automobilzulieferer.
     IF   ( VBAK-ABDIS NE SPACE OR TVAK-ABDIS NE SPACE )
     AND    DA_STATUS-FIX = 'U   '.
       DA_STATUS-VAR = 'AUTO'.
     ENDIF.

*    MAIS-Auftrag Automobilzulieferer
     IF   VBAK-VBKLT EQ VBKLT_AUSL_AUFT
     AND  DA_STATUS-FIX = 'U   '.
       DA_STATUS-VAR = 'MAIS'.
     ENDIF.

*    Verträge
     IF   ( TVAK-VBTYP CA VBTYP_KONT )
     AND  DA_STATUS-FIX  = 'U   '.
       DA_STATUS-VAR = 'CONT'.
     ENDIF.

*    Gruppenkontrakt
     IF TVAK-VBTYP EQ VBTYP_GRUKO.

       IF   DA_STATUS-FIX = 'U   '.        "Übersichtsbild
         DA_STATUS-VAR = 'GRKO'.
       ENDIF.
       IF DA_STATUS-FIX = 'KK  '.          "Kaufmann Übersicht
         DA_STATUS-VAR = 'GRKO'.
       ENDIF.
       IF DA_STATUS-FIX = 'K   '.          "Kopf Status
         DA_STATUS-VAR = 'GRKO'.
       ENDIF.
       IF DA_STATUS-FIX = 'K1  '.          "Kaufmann Detail
         DA_STATUS-VAR = 'GRKO'.
       ENDIF.
       IF DA_STATUS-FIX = 'K_EX'.          "Status für externe Bilder
         DA_STATUS-VAR = 'GRKO'.
       ENDIF.
     ENDIF.

* Anlegen Abrufauftrag zu Wertkontrakt
     IF DA_STATUS-FIX = 'R   '.
       LOOP AT XVBAP WHERE ERLRE EQ CON_ERLRE_WERTKONTRAKT.
         DA_STATUS-VAR = '  WK'.
         EXIT.
       ENDLOOP.
     ENDIF.

     US_STATUS = DA_STATUS.

ENDFORM.