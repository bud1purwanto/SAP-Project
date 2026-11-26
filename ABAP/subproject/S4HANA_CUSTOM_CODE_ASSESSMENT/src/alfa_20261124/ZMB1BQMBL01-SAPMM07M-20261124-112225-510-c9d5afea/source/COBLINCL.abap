***INCLUDE COBLINCL .
*--------------------------------------------------------------------
*
* Allgemeine Deklarationen für den Kontierungsblock
*
*--------------------------------------------------------------------
DATA: DYNNR   LIKE TCOBL-DYNNR,    "Dynpronummer des Subscreens
      PROGN   LIKE SY-CPROG,       "Name des Kontierungsblockmodulpools
      PROCESS LIKE COBL-PROCESS,   "RWIN-Prozeß
      EVENT   LIKE COBL-EVENT.     "RWIN-Zeitpunkt
*
* Übergabestruktur des Kontierungsblocks
*
DATA: BEGIN OF COBL.
        INCLUDE STRUCTURE COBL.
DATA: END OF COBL.
*
* Interne Tabelle der Felder eines Subscreens im Kontierungsblock
*
DATA BEGIN OF INT_COBLF OCCURS 0.
        INCLUDE STRUCTURE COBLF.
DATA END OF INT_COBLF.