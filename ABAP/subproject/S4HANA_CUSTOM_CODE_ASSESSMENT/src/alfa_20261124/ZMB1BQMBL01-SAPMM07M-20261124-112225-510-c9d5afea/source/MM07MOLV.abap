*---------------------------------------------------------------------*
*       Modulpool MM07M     Process-Before-Output LVS                 *
*---------------------------------------------------------------------*
*       Inhalt:                                                       *
*                                                                     *
*         D1420_DATEN             Vorschlagsdaten Dynpro 1420         *
*         D1421_DATEN             Vorschlagsdaten Dynpro 1421         *
*         LVS_XBLVS_PRUEFEN       Prüfen, ob Zeile LVS-relevant       *
*         LVS_UMBLV_PRUEFEN       Prüfen, ob Uml.Zeile LVS-relevant   *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       MODULE D1420_DATEN                                            *
*---------------------------------------------------------------------*
*       Setzen Vorschlagsdaten fuer Dynpro 1420                       *
*---------------------------------------------------------------------*
MODULE D1420_DATEN OUTPUT.

*........Lesen Bewegungsartentext.......................................

  PERFORM T333T_LESEN USING MSEG-LGNUM MSEG-BWLVS.

*........Lesen Lagernummertext..........................................

    PERFORM T300T_LESEN USING MSEG-LGNUM.

*........Lesen Lagertyptext.............................................

    PERFORM T301T_LESEN USING MSEG-LGNUM MSEG-LGTYP.

*........Lesen Palettierungsdaten aus Transportbedarf
    IF NOT MSEG-TBNUM IS INITIAL AND
       NOT MSEG-TBPOS IS INITIAL.
      PERFORM TBPOS_LESEN USING MSEG-LGNUM MSEG-TBNUM MSEG-TBPOS.
    ENDIF.
ENDMODULE.
*---------------------------------------------------------------------*
*       MODULE D1421_DATEN                                            *
*---------------------------------------------------------------------*
*       Setzen Vorschlagsdaten fuer Dynpro 1421                       *
*---------------------------------------------------------------------*
MODULE D1421_DATEN OUTPUT.

*........Lesen Bewegungsartentext.......................................

  PERFORM T333T_LESEN USING DM07M-UMLGN DM07M-UMBLV.

*........Lesen Lagernummertext..........................................

    PERFORM T300T_LESEN USING DM07M-UMLGN.

*........Lesen Lagertyptext.............................................

    PERFORM T301T_LESEN USING DM07M-UMLGN DM07M-UMLGT.


ENDMODULE.
*---------------------------------------------------------------------*
*       MODULE LVS_XBLVS_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Prüfen, ob Zeile relevant ist für das LVS. Wenn ja, wird      *
*       das Fenster mit den LVS-Daten hell durchlaufen.               *
*---------------------------------------------------------------------*
MODULE LVS_XBLVS_PRUEFEN OUTPUT.

   IF MSEG-XBLVS IS INITIAL AND DM07M-UMBLV IS INITIAL.
     SUPPRESS DIALOG.
     MESSAGE S202.
     CLEAR T063C-CCODE_NEXT.
   ENDIF.

   IF MSEG-XBLVS IS INITIAL.
     SUPPRESS DIALOG.
   ENDIF.

   IF DM07M-UMBLV IS INITIAL.
     CLEAR T063C-CCODE_NEXT.
   ENDIF.

ENDMODULE.


*---------------------------------------------------------------------*
*       MODULE LVS_UMBLV_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Prüfen, ob Zeile relevant ist für das LVS. Wenn ja, wird      *
*       das Fenster mit den LVS-Umlagerdaten hell durchlaufen.        *
*---------------------------------------------------------------------*
MODULE LVS_UMBLV_PRUEFEN OUTPUT.

   IF DM07M-UMBLV IS INITIAL.
     SUPPRESS DIALOG.
   ENDIF.

ENDMODULE.





