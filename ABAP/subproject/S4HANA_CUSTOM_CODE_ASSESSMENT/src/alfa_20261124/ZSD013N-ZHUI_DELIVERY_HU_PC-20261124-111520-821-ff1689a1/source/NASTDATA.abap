*-----------------------------------------------------------------------
*        Tabellen für Nachrichtenvorschlag (ohne Konditionstechnik)
*-----------------------------------------------------------------------

TABLES: T683S,
        T685B,
        TNAD1,
        TNAD2,
        TNAD3,
        TNAD4,
        TNAD5.


DATA:    BEGIN OF PROP OCCURS 0.       " Nachrichtenvorschlag
           INCLUDE STRUCTURE NAST.
DATA:    END OF PROP.

*eject

DATA:    BEGIN OF XKNVD OCCURS 0.      " Nachrichten im Kundenstamm
           INCLUDE STRUCTURE KNVD.
DATA:    END OF XKNVD.

*eject

DATA:    BEGIN OF NACHR OCCURS 0,      "gueltige Nachrichten aus T683S
           KSCHL LIKE T683S-KSCHL,     "Nachricht
         END OF NACHR.

*eject

DATA:    BEGIN OF xmesstab occurs 0.   "aufgetretene Warnungen
           include structure bdcmsgcoll.
data:    END OF xmesstab.

data:   text_name like thead-tdname value 'V1ESYM$'.

*eject