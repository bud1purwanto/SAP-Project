*-----------------------------------------------------------------------
*        Datenbank-Tabelle VBLB
*-----------------------------------------------------------------------

TABLES:  TVZP,
         TVZPT,
         VBLB,
        *VBLB,
         VBLBVB,
         VBKFZ,                                                 " CMDS
        *VBKFZ,                                                 " CMDS
         VBKFZVB.                                               " CMDS

DATA:   BEGIN OF COMMON PART VBLBCOM.
* Alter Tabellenstand beim aendern

DATA:    BEGIN OF YVBLB OCCURS 1.
        INCLUDE STRUCTURE VBLBVB.
DATA:    END OF YVBLB.

* Aktueller Tabellenstand

DATA:    BEGIN OF XVBLB OCCURS 5.
        INCLUDE STRUCTURE VBLBVB.
DATA:    END OF XVBLB.

* Maximalwerte

DATA:    BEGIN OF FVBLB.
        INCLUDE STRUCTURE VBLB.
DATA:    END OF FVBLB.
DATA:    BEGIN OF MVBLB.
        INCLUDE STRUCTURE VBLB.
DATA:    END OF MVBLB.
DATA:    BEGIN OF LVBLB.
        INCLUDE STRUCTURE VBLB.
DATA:    END OF LVBLB.

* Historische Einteilungen
DATA:    BEGIN OF XVBEH OCCURS 0.
        INCLUDE STRUCTURE VBEH.
DATA:    END OF XVBEH.

DATA: SVBLB_TABIX LIKE SY-TABIX.
DATA: SVBLB_SUBRC LIKE SY-SUBRC.
* Änderungsbelege
DATA: UPD_VBLB.

* Flags zur Meldungsanzeige
DATA M_V4143_LAB.  "Nullstellungsdatum ignorieren - LAB
DATA M_V4143_FAB.  "Nullstellungsdatum ignorieren - FAB

* Flags zur Prüfung 'neuer Abruf'
* 'I' steht für inaktiv, d.h. es wurde noch nicht geprüft
* 'I' wird im POSITION_BEARBEITEN_VORBEREITEN gesetzt
* falls geprüft wurde, und es gibt einen neuen Abruf -> 'Y'
* falls geprüft wurde, und es gibt keinen neuen Abruf -> 'N'
DATA: NEUER_ABRUF_LAB(1) TYPE C,
      NEUER_ABRUF_FAB(1) TYPE C,
      NEUER_ABRUF_PLAB(1) TYPE C.

* Flag Vorschlag Eingangsfortschrittszahl
DATA VORSCHLAG_EFZ(1) TYPE C.

* CMDS - Collaborative Management of Delivery Schedules
* Globalization of hand-over-structure US_VBLBKOM
DATA: BEGIN OF us_vblbkom.
        INCLUDE STRUCTURE vblbkom.
DATA: END OF us_vblbkom.
DATA: BEGIN OF us_vblbkomx.
        INCLUDE STRUCTURE vblbkomx.
DATA: END OF us_vblbkomx.

* Global flags for proposal of cumulative received quantity and
* not yet closed fiscal year
DATA: gv_propose_rcq(1) TYPE c,
      gv_cu_fisc_year_nyc TYPE bapiupdate.

* Flag, ob der Abruf gerade neu angelegt wird:
* Das Flag wird gesetzt, wenn ein neuer Abruf mit dem Button
* [Neuer Abruf] angelegt wird (Form XVBLB_NEU), bzw. wenn der erste
* Abruf zu einem Lieferplan angelegt wird (Form VBLB_VORBEREITEN).
* Sobald der Abruf angelegt ist, wird das Flag zurückgesetzt
* (Form VBLB_FUELLEN, wenn sie nicht im Prüfmodus gerufen wird).
DATA: VBLB_NEU(1) TYPE C.

* CMDS - Collaborative Management of Delivery Schedules
* Cumulative correction quantities
DATA: BEGIN OF YVBKFZ OCCURS 0.
        INCLUDE STRUCTURE VBKFZVB.
DATA: END OF YVBKFZ.

DATA: BEGIN OF XVBKFZ OCCURS 0.
        INCLUDE STRUCTURE VBKFZVB.
DATA: END OF XVBKFZ.

DATA: SVBKFZ_TABIX LIKE SY-TABIX.
DATA: SVBKFZ_SUBRC LIKE SY-SUBRC.
* Änderungsbelege
DATA: UPD_VBKFZ.

DATA: END OF COMMON PART.