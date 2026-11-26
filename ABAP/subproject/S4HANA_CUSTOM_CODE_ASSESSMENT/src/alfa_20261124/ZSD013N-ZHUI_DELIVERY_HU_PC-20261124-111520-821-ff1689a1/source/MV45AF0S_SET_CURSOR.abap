*eject
*---------------------------------------------------------------------*
*       FORM SET_CURSOR                                               *
*---------------------------------------------------------------------*
*       Der Cursor wird ergonomisch gesetzt.                          *
*---------------------------------------------------------------------*
FORM SET_CURSOR USING US_FELDNAME.

  DATA: DA_TFILL LIKE SY-TFILL.

* Sonderfall Anlegen Sortiment:
* ==> Cursor auf das Feld Bezeichnung setzen
  IF VBAK-VBTYP = VBTYP_SORT AND
     VBAK-KTEXT IS INITIAL AND
     T180-TRTYP = CHARH.
    SET CURSOR FIELD 'VBAK-KTEXT'.
    EXIT.
  ENDIF.

* Noch kein Auftraggeber eingegeben
* ==> Cursor auf das Feld Auftraggeber setzen
  PERFORM TPAER_SELECT USING TVAK-PARGR
                             'AG'
                             SPACE
                             SY-SUBRC.

  IF KUAGV-KUNNR IS INITIAL AND
     NOT TPAER-PAPFL IS INITIAL AND
     RV45A-PART0 = SPACE.
    SET CURSOR FIELD 'KUAGV-KUNNR'.
    EXIT.
  ENDIF.

* nur weiter wenn bereits ein Auftragskopf vorhanden ist
  CHECK SVBAK-TABIX > 0.
  DESCRIBE TABLE IVBAP LINES DA_TFILL.

* FCODE 'Position-Anlegen':
* ==> Cursor auf die erste freie Zeile setzen, damit die neue Position
*     direkt angelegt werden kann
  IF OLD_FCODE = FCODE_XVBAP_ANLEGEN.
    IF DA_TFILL EQ 0.
      SET CURSOR FIELD US_FELDNAME LINE 1.
    ELSE.
      SET CURSOR FIELD US_FELDNAME LINE 2.
    ENDIF.
    EXIT.
  ENDIF.

* Produktvorschlag aktiv
* ==> Cursor in die erste Zeile stellen
  IF DPP_ACTIVE   EQ CHARX AND
     XVBAP_UMFANG_OPV IS INITIAL.
*   in das Feld 'Zielmenge' wenn vorhanden
    IF KOPGR_MIT_ZMENG CS TVAK-KOPGR.
      SET CURSOR FIELD 'VBAP-ZMENG' LINE 1.
      EXIT.
    ELSE.
*   sonst in das Feld 'Auftragsmenge'
      SET CURSOR FIELD 'RV45A-KWMENG' LINE 1.
      EXIT.
    ENDIF.
  ENDIF.

* noch keine Position vorhanden, FCODE 'Positionieren' oder
* Sonderfall Lieferplan mit einer Position im Ändern
* ==> Cursor auf erste Position setzen, damit direkte Folgeaktion
*     möglich ist
  IF DA_TFILL      EQ 0 OR
     OLD_FCODE     EQ FCODE_POSITIONIEREN   OR
   ( VBAK-VBTYP CA VBTYP_LP AND
     DA_TFILL   EQ 1        AND
     T180-TRTYP EQ CHARV ).
    SET CURSOR FIELD US_FELDNAME LINE 1.
    EXIT.
  ENDIF.

* alle anderen Fälle:
* falls mehr XVPAP-Einträge als Loopzeilen vorhanden sind, wird der
* Cursor auf die 1. Position gesetzt, andernfalls wird der Cursor auf
* die nächste freie Zeile gesetzt
  DESCRIBE TABLE SVBAP LINES DA_TFILL.
  DA_TFILL = DA_TFILL + 1.
  IF DA_TFILL GT IVBAP_LOOPC OR T180-TRTYP EQ CHARA.
    SET CURSOR FIELD US_FELDNAME LINE 1.
  ELSE.
    SET CURSOR FIELD US_FELDNAME LINE DA_TFILL.
  ENDIF.

ENDFORM.