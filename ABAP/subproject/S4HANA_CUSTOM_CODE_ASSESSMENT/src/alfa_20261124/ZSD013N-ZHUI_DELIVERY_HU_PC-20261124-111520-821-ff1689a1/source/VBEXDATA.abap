*----------------------------------------------------------------------*
*   INCLUDE VBEXDATA                                                   *
*----------------------------------------------------------------------*

TABLES:  EMBK,                         "Genehmigungsstamm
         EMBKVB,                       "Bezugsstruktur für XEMBK
         VBEX,                         "Vertriebsbeleg: Exportdaten
         VBEXVB,                       "Bezugsstruktur für XVBEX, YVBEX
         VBEXAN.                       "Struktur für Analyseergebnis

TABLES:  T605, T605T.                  "Art des Geschaeftes

DATA:    BEGIN OF COMMON PART VBEXCOM.

*--------VBEX - neu
DATA:    BEGIN OF XVBEX OCCURS 0.
           INCLUDE STRUCTURE VBEXVB.
DATA:    END OF XVBEX.

*--------VBEX - alt
DATA:    BEGIN OF YVBEX OCCURS 0.
           INCLUDE STRUCTURE VBEXVB.
DATA:    END OF YVBEX.

*--------EMBK - neu
DATA:    BEGIN OF XEMBK OCCURS 0.
           INCLUDE STRUCTURE EMBKVB.
DATA:    END OF XEMBK.

*--------Analyseergebnis der Exportkontrolle
DATA:    BEGIN OF EXANALY OCCURS 0.
           INCLUDE STRUCTURE VBEXAN.
DATA:    END OF EXANALY.

DATA:    XVBEX_INDEX LIKE SY-TABIX.
DATA:    XVBEX_LOOPC LIKE SY-TABIX.         "Anzahl Loopzeilen
DATA:    AUSFUHR_NEU TYPE C      VALUE ' '. "Flag: Neuermittlung Ausfuhr

DATA:    END OF COMMON PART VBEXCOM.
*----------------------------------------------------------------------*