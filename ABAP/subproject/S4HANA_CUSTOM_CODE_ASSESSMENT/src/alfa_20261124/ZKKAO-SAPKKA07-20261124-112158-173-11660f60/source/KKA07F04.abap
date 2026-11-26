*-------------------------------------------------------------------
***INCLUDE KKA07F04 .
* Enthält ausgelagerte Form-Routinen von SAPKKA07
*-------------------------------------------------------------------
* Prüfen nur über Rahmenprogramm SAPKKA07 möglich!
*
* P30K081591/3.0E: Include neu angelegt
*&---------------------------------------------------------------------*
*&      Form  SETZE_MAX_NT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SETZE_MAX_NT
   USING PD_AMPEL    LIKE KKA0100-AMPEL
         PD_MAXNT    LIKE KKA0100-MSGMX.

  gd_num_msgs_old = gd_num_msgs_new.                       "I_46A_SCMA
* Weil Performance-kritisch: CM_F_INFO nur, wenn MNT pro Auft. gewünscht
* und wenn SCMA-Worklists im Einsatz                       "I_46A_SCMA
*  mit all = yes, weil nicht sicher alle Fehlermeldung objektabh.
*  wenn alle obj.abh. hier direkt Anzahl, ohne gs_old/newtotal
    CALL FUNCTION 'CM_F_INFO'
           EXPORTING ALL               = YES   " Begr. s.o.
                     APLID             = ABGR_APLID
                     OBJECT_ID         = ABGR_OBJECT_ID
*                    OBJECT            = ' '
           IMPORTING A_MSG_COUNTER_PRO = GS_NEWTOTAL-A
                     E_MSG_COUNTER_PRO = GS_NEWTOTAL-E
                     W_MSG_COUNTER_PRO = GS_NEWTOTAL-W
                     I_MSG_COUNTER_PRO = GS_NEWTOTAL-I
                     msg_counter_pro   = gd_num_msgs_new.   "I_46A_SCMA
*                    msgty_pro         =
*                    APLIDENT          =
*                    A_MSG_COUNTER_SCR =
*                    E_MSG_COUNTER_SCR =
*                    I_MSG_COUNTER_SCR =
*                    MAX_SEVERITY_PRO  =
*                    MAX_SEVERITY_SCR  =
*                    MSGTY_PRO         =
*                    MSGTY_SCR         =
*                    MSG_COUNTER_SCR   =
*                    NOT_ACTIVE        =
*                    OBJECT_IDENT      =
*                    W_MSG_COUNTER_SCR =
*          EXCEPTIONS WRONG_OBJECT_ID  = 01.
* Ermittle max. Nachrichtentyp des Auftrags
    CLEAR PD_MAXNT.
    IF GS_NEWTOTAL-I > GS_OLDTOTAL-I.
         PD_MAXNT = 'I'.
    ENDIF.
    IF GS_NEWTOTAL-W > GS_OLDTOTAL-W.
         PD_MAXNT = 'W'.                    "bei vorh. Warnungen
         IF PD_AMPEL EQ CON_GRUEN.          "und nicht schon rot,
             PD_AMPEL = CON_GELB.             "so setze Ampel gelb
         ENDIF.
    ENDIF.
*   Auch in 4.0C noch so, daß nur gelbe Ampel bei 'E'/'W', die NICHT
*   zu Abbruch des AUFTRAG_ABGRENZEN führen; erst wenn flex.Fehlerst.
*   völlig durchgezogen (gecust. 'E' führen zu Abbruch), dann auch so!
*   Eigentlich sollten keine E- oder A-Meldungen hier reinkommen,
*   da die KJ-Meldungen nicht in TCMF9 aufgenommen, weil eben nicht
*   steuerbar!
    IF GS_NEWTOTAL-E > GS_OLDTOTAL-E.
         PD_MAXNT = 'E'.                    "bei vorh. Fehlern
         IF PD_AMPEL EQ CON_GRUEN.          "und nicht schon rot,
             PD_AMPEL = CON_GELB.             "so setze Ampel gelb
         ENDIF.
    ENDIF.
    IF GS_NEWTOTAL-A > GS_OLDTOTAL-A.
         PD_MAXNT = 'A'.                    "bei vorh. A-Msg.
         IF PD_AMPEL EQ CON_GRUEN.          "und nicht schon rot,
             PD_AMPEL = CON_GELB.             "so setze Ampel gelb
         ENDIF.
    ENDIF.
    GS_OLDTOTAL = GS_NEWTOTAL.      " Meldungs-'Diff.' auf 0
ENDFORM.                    " SETZE_MAX_NT
*&---------------------------------------------------------------------*
*&      Form  FUELLE_AUFTRAGSLISTE
*&---------------------------------------------------------------------*
*   Füllt die Liste der Aufträge, falls Eintrag relevant für Ausgabe
*   sowohl für serielle wie auch parallele Verarbeitung
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FUELLE_AUFTRAGSLISTE
   TABLES PT_AUFTRAGSLISTE  STRUCTURE KKAPARA_TA
   USING  PS_VERSION        LIKE KKAPARA_VS
          PD_WAEHR          LIKE KKAPARA_IN-WAEHR
          PD_FEHLAUFT       LIKE KKAPARA_IN-FEHLAUFT
          PD_FEHLERAUFTRAG  LIKE SY-DEBUG "Char(1)           "I_40B_CCC
          PD_NO_0_WIP       LIKE KKAPARA_IN-NO_0_WIP        "I_40A_0WIP
          PD_AMPEL          LIKE KKA0100-AMPEL
          PD_MAXNT          LIKE KKA0100-MSGMX.

CON_BST = TEXT-BST. "für Parallelverarb. auch hier zu füllen      "I40C
CON_RST = TEXT-RST. "für Parallelverarb. auch hier zu füllen      "I40C
PT_AUFTRAGSLISTE-VERSN   = PS_VERSION-VERSA.
PT_AUFTRAGSLISTE-VALUTYP = PS_VERSION-VALUTYP.
PERFORM GET_VALUTEXT
  USING PS_VERSION-VALUTYP PT_AUFTRAGSLISTE-VALUTEXT.
*pt_auftragsliste-wrtk    = gd_auft_wipk. "schon übergeben   "D_40B_CCC
*pt_auftragsliste-wrt     = gd_auft_wipp.                    "D_40B_CCC
*pt_auftragsliste-wrt_upd = gd_auft_wipb.                    "D_40B_CCC
PT_AUFTRAGSLISTE-WAEHR   = PD_WAEHR.
PT_AUFTRAGSLISTE-AMPEL   = PD_AMPEL.
PT_AUFTRAGSLISTE-MAXNT   = PD_MAXNT.
IF NOT PD_FEHLERAUFTRAG IS INITIAL.                         "I_40A_0WIP
  IF NOT PD_FEHLAUFT IS INITIAL.                            "I_40A_0WIP
* fehlerhafte Aufträge bei Flag fehlauft immer ausg.        "I_40A_0WIP
*   da fehlerhaft keine Werte und Waehrung
    CLEAR PT_AUFTRAGSLISTE-WRTK.
    CLEAR PT_AUFTRAGSLISTE-WRT.
    CLEAR PT_AUFTRAGSLISTE-WRT_UPD.
*   clear pt_auftragsliste-waehr.                            "D_40B_CCC
    APPEND PT_AUFTRAGSLISTE.                                "I_40A_0WIP
  ENDIF.                                                    "I_40A_0WIP
ELSEIF PD_NO_0_WIP IS INITIAL OR                            "I_40A_0WIP
* fehlerfr. Auftr. bei Flag no_0_wip, falls Wip <> 0        "I_40A_0WIP
       PT_AUFTRAGSLISTE-WRTK    NE 0   OR                   "I_40A_0WIP
       PT_AUFTRAGSLISTE-WRT     NE 0   OR                   "I_40A_0WIP
       PT_AUFTRAGSLISTE-WRT_UPD NE 0.                       "I_40A_0WIP
  IF PT_AUFTRAGSLISTE-WRTK < 0.                                   "I40C
    PT_AUFTRAGSLISTE-WIPTYP = CON_RST.                            "I40C
  ELSE.                                                           "I40C
    PT_AUFTRAGSLISTE-WIPTYP = CON_BST.                            "I40C
  ENDIF.                                                          "I40C
  APPEND PT_AUFTRAGSLISTE.
ENDIF.
ENDFORM.                    " FUELLE_AUFTRAGSLISTE
*&---------------------------------------------------------------------*
*&      Form  CM_F_SET_OBJECT
*&---------------------------------------------------------------------*
*    Setzen der aktuell bearbeiteten Objekt-ID für CM_F_MESSAGE
*----------------------------------------------------------------------*
*   -->PS_AUFTRAG  Auftrags-Struktur
*   -->PS_VERSION  Versions-Struktur
*   -->PD_STEP     Schritt (als erläuternder Text), wo Fehler auftrat
*----------------------------------------------------------------------*
FORM CM_F_SET_OBJECT USING PS_AUFTRAG LIKE KKAPARA_TA
                           PS_VERSION LIKE KKAPARA_VS.

 DATA: LS_OBJECT LIKE CMIOBJKKA.
*
  LS_OBJECT-BUKRS = PS_AUFTRAG-BUKRS.
  LS_OBJECT-WERKS = PS_AUFTRAG-WERKS.
  LS_OBJECT-AUART = PS_AUFTRAG-AUART.
*  LS_OBJECT-AUFNR = PS_AUFTRAG-AUFNR.                            "46B
* beginning 46B: OBJID statt AUFNR im Meldungsprotokoll
* beginning 187150: bei Positionen OBJNP nehmen
  IF NOT PS_AUFTRAG-OBJNP IS INITIAL.
    CALL FUNCTION 'K_OBJECT_ID_GET'
         EXPORTING
               PAR_OBJNR         = PS_AUFTRAG-OBJNP
               PAR_MATNR         = PS_AUFTRAG-MATNR
               PAR_WERKS         = PS_AUFTRAG-WERKS
               PAR_VERID         = PS_AUFTRAG-VERID
               PAR_AUTYP         = PS_AUFTRAG-AUTYP
               PAR_PROCNR        = PS_AUFTRAG-PROCNR
         IMPORTING
               PAR_OBJID         = PS_AUFTRAG-OBJID
         EXCEPTIONS
               OTHERS            = 0.
  ELSE.
* end 187150
    CALL FUNCTION 'K_OBJECT_ID_GET'
         EXPORTING
               PAR_OBJNR         = PS_AUFTRAG-OBJNR
               PAR_MATNR         = PS_AUFTRAG-MATNR
               PAR_WERKS         = PS_AUFTRAG-WERKS
               PAR_VERID         = PS_AUFTRAG-VERID
               PAR_AUTYP         = PS_AUFTRAG-AUTYP
               PAR_PROCNR        = PS_AUFTRAG-PROCNR
         IMPORTING
               PAR_OBJID         = PS_AUFTRAG-OBJID
         EXCEPTIONS
               OTHERS            = 0.
  ENDIF.                                                     "187150
  ls_object-aufnr = ps_auftrag-objid.
* end 46B
  LS_OBJECT-POSNR = PS_AUFTRAG-POSNR.
  LS_OBJECT-VERSA   = PS_VERSION-VERSA.
  LS_OBJECT-VALUTYP = PS_VERSION-VALUTYP.
* Begin of FSSC EHP5e Part: pass through order number into log
  LS_OBJECT-ORDERNO = PS_AUFTRAG-AUFNR.
* End of FSSC EHP5e Part
* Für den Text sollte dann DD07T mit den Texten in start-sel. gelesen w.
  CALL FUNCTION 'CM_F_SET_OBJECT'
             EXPORTING  OBJECT    = LS_OBJECT
*                       subobj    = ls_subobj  "nicht gesetzt
                        OBJECT_ID = ABGR_OBJECT_ID.
ENDFORM.                    " CM_F_SET_OBJECT
*&---------------------------------------------------------------------*
*&      Form  GET_MSGTYP_TEXT
*&---------------------------------------------------------------------*
*    Setzt zu Msg-Typ die Text-Bezeichnungen
*----------------------------------------------------------------------*
*      -->P_MAX_MSG  text
*      -->PD_MSGTYPTEXT  text
*----------------------------------------------------------------------*
FORM GET_MSGTYP_TEXT USING  PD_MAX_MSG LIKE KKA0100-MSGMX
                            PD_MSGTYPTEXT TYPE C.
*
  CASE PD_MAX_MSG.
    WHEN 'I'.
      PD_MSGTYPTEXT = TEXT-MSI.
    WHEN 'W'.
      PD_MSGTYPTEXT = TEXT-MSW.
    WHEN 'E'.
      PD_MSGTYPTEXT = TEXT-MSE.
    WHEN 'A'.
      PD_MSGTYPTEXT = TEXT-MSA.
  ENDCASE.
ENDFORM.                    " GET_MSGTYP_TEXT
*&---------------------------------------------------------------------*
*&      Form  GET_VALUTEXT
*&---------------------------------------------------------------------*
*    Ermittelt den Text der Bewertung
*----------------------------------------------------------------------*
*      -->P_VALUTYP   text
*      -->P_VALUTEXT  text
*----------------------------------------------------------------------*
FORM GET_VALUTEXT USING    P_VALUTYP  LIKE TKKAP-VALUTYP
                           P_VALUTEXT TYPE C.
*
  CASE P_VALUTYP.
    WHEN '0'.
      P_VALUTEXT = TEXT-BW0.
    WHEN '1'.
      P_VALUTEXT = TEXT-BW1.
    WHEN '2'.
      P_VALUTEXT = TEXT-BW2.
  ENDCASE.
ENDFORM.                    " GET_VALUTEXT