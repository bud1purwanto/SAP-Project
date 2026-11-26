*-----------------------------------------------------------------------
*        Tabellen
*-----------------------------------------------------------------------
TABLES:  T003M,                        " Nummernkreise
         MSEGK.                        " Kontierungsfelder im MSEG


DATA:    BEGIN OF COMMON PART MM07MCWL.

*-----------------------------------------------------------------------
*       Datenfelder fuer das Programm SAPMM07M und zugehoerige
*       INCLUDEs
*
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*       Teil 3 :  Einzelfelder  ( variabel )
*       Teil 4 :  Konstanten
*       Teil 5 :  Field-Symbols
*
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*-----------------------------------------------------------------------

DATA: BEGIN OF YMBUZ   OCCURS 0.      " M-Beleg Zeilenzuordnung
        INCLUDE STRUCTURE MBUZ.
DATA: END OF YMBUZ.

DATA: BEGIN OF ZMBUZ   OCCURS 0.      " M-Beleg Zeilenzuordnung
        INCLUDE STRUCTURE MBUZZ.
DATA: END OF ZMBUZ.

*-----------------------------------------------------------------------
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*-----------------------------------------------------------------------

DATA: BEGIN OF YMBUZ_KEY,
        ZEILZ LIKE MBUZ-ZEILZ,
        XAUTO LIKE MBUZ-XAUTO,
      END OF YMBUZ_KEY.

DATA: BEGIN OF ZMBUZ_KEY,
        ZEILY LIKE MSEG-ZEILE,
        ZEILO LIKE MSEG-ZEILE,
      END OF ZMBUZ_KEY.

*-----------------------------------------------------------------------
*       Teil 3 :  Einzelfelder
*-----------------------------------------------------------------------


*-----------------------------------------------------------------------
*       Teil 4 :  Konstanten
*-----------------------------------------------------------------------


*-----------------------------------------------------------------------
*       Teil 5 :  Field-Symbols
*-----------------------------------------------------------------------

DATA:    END OF COMMON PART.
*eject