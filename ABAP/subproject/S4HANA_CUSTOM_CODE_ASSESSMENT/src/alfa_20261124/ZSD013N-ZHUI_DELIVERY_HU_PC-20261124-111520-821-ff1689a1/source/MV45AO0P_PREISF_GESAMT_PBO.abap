*----------------------------------------------------------------------*
***INCLUDE MV45AO0P_PREISF_GESAMT_PBO .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PREISFINDUNG_GESAMT_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module preisfindung_gesamt_pbo output.
* Dieser Preisfindungsaufruf soll aus Performance-Gründen nur bei
* einem Dynpro-Wechsel auf das Kopfkonditionsbild stattfinden.

* Evtl. zusätzlich nach neuer Preisfindung auf Kopfebene und nach
* drücken des Aktivieren-Buttons

* Das wird an dem Dummy-FCODE 'PRSA' aus der Folgebildsteuerung
* erkannt.

  if fcode = 'PRSA'.
    perform preisfindung_gesamt using chara.
    fcode = 'ENT1'.
  endif.

endmodule.                             " PREISFINDUNG_GESAMT_PBO  OUTPUT