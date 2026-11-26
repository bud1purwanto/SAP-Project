*---------------------------------------------------------------------*
*       Tabellen / Feldleisten für Kopieren von Lieferungen           *
*       aus Aufträgen                                                 *
*---------------------------------------------------------------------*

TABLES: VBSK.

*---------------------------------------------------------------------*
*       interne Tabellen / Feldleisten                                *
*---------------------------------------------------------------------*

DATA: BEGIN OF COMMON PART COPYLIF.

DATA:
  BEGIN OF POSNR_UMSETZUNG OCCURS 10,
           B_NEU LIKE LIKP-VBELN,
           B_ALT LIKE LIKP-VBELN,
           ALT LIKE VBAP-POSNR,
           NEU LIKE VBAP-POSNR,
  END OF POSNR_UMSETZUNG.

* erstellte Lieferungen
DATA:   BEGIN OF CVBLS OCCURS 1.
          INCLUDE STRUCTURE VBLS.
DATA:   END OF CVBLS.

* Fehlermeldungen
DATA:   BEGIN OF CVBFS OCCURS 1.
          INCLUDE STRUCTURE VBFS.
DATA:   END OF CVBFS.

*SPE INB ST Extended error protokoll
DATA:   GS_KOMDLGN TYPE KOMDLGN.
DATA:   GT_SPE_VBFS TYPE STANDARd TABLE OF /SPE/VBFS.


DATA:   NUMMER_SAMMELGANG LIKE VBLS-SAMMG,
        KZ_ZWEITER_ANLAUF.

* SPE: Lean Kit-to-Order Header
TYPES: BEGIN OF ty_kit_struc,
        vbeln   TYPE vbap-vbeln,
        posnr   TYPE vbap-posnr,
        uepos   TYPE vbap-uepos,
        struc   TYPE /spe/struc,
      END OF ty_kit_struc,
      BEGIN OF ty_kit_number,
        vbeln TYPE likp-vbeln,
        counter TYPE lips-spe_struc,
      END OF ty_kit_number.
DATA: gt_kit_struc TYPE SORTED TABLE OF ty_kit_struc
                   WITH UNIQUE KEY vbeln posnr,
      gt_kit_number TYPE SORTED TABLE OF ty_kit_number
                    WITH UNIQUE KEY vbeln.

DATA: END OF COMMON PART COPYLIF.
*---------------------------------------------------------------------*