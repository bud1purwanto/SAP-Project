*-------------------------------------------------------------------
***INCLUDE MV45AF0T_TAXI_P0_VIA_FCODE_ITE .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  TAXI_P0_VIA_FCODE_ITEM
*&---------------------------------------------------------------------*
* Dieses Unterprogramm wird als C-Modul von der Folgebildsteuerung
* gerufen, nachdem innerhalb der Bildgruppe Position einer der Knöpfe
* erste, vorige, nächste oder letzte Position gedrückt wurde.
* Das UP setzt als Fcode "ITEM" und ruft die Folgebildsteuerung,
* Dies entspricht dem Drücken der Positions-Lupe auf Übersichtsbildern.
*
* Hintergrund:
* Beim Wechsel auf eine andere Position kann es sein, das vorher aktive
* Reiter des Tabstrips deaktiviert werden müssen, oder umgekehrt.
* Diese dynamische Modifikation der Reiterleiste wird bei jedem Wechsel
* der Bildgruppe durchgeführt.
*
* Lösung:
* Für den Wechsel auf eine andere Position wird ein Bildgruppenwechsel
* simuliert, indem die entsprechenden Fcodes auf das Panel (PX,ITEM)
* führen. In diesem Panel wird das vorliegende Unterprogramm gerufen,
* das via Fcode "ITEM" wieder zurück in die Bildgruppe Position führt.
*----------------------------------------------------------------------*

FORM TAXI_P0_VIA_FCODE_ITEM USING H185F STRUCTURE T185F
                                  H185  STRUCTURE T185
                                  H185V STRUCTURE T185V.
  H185F-FCODE = 'ITEM'.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

ENDFORM.                    " TAXI_P0_VIA_FCODE_ITEM