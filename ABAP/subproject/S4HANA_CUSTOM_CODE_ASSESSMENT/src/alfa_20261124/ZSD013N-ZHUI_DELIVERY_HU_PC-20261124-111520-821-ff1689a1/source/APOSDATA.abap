***INCLUDE APOSDATA.

TABLES: qtvb,
        qtch.

DATA:    BEGIN OF COMMON PART apocom.

* Merkmalskatalog für regelbasierte Prüfung und Kontingentierung
DATA:  BEGIN OF x_sdfields OCCURS 0.
        INCLUDE STRUCTURE atpfield.
DATA:  END OF x_sdfields.

* Kontingentierung: Kontingentbelegung
DATA:    BEGIN OF yqtvb OCCURS 0.
        INCLUDE STRUCTURE qtvbd.
DATA:    END OF yqtvb.

DATA:    BEGIN OF xqtvb OCCURS 0.
        INCLUDE STRUCTURE qtvbd.
DATA:      posguid LIKE quot_vb-posguid.
DATA:    END OF xqtvb.

DATA:    BEGIN OF qtvb_key.
        INCLUDE STRUCTURE qtvb_key.
DATA:    END OF qtvb_key.


* Kontingentierung: Merkmalsverzeichnis
DATA:    BEGIN OF yqtch OCCURS 0.
        INCLUDE STRUCTURE qtchd.
DATA:    END OF yqtch.

DATA:    BEGIN OF xqtch OCCURS 0.
        INCLUDE STRUCTURE qtchd.
DATA:    END OF xqtch.

DATA:    BEGIN OF qtch_key.
        INCLUDE STRUCTURE qtch_key.
DATA:    END OF qtch_key.



DATA:    END OF COMMON PART apocom.