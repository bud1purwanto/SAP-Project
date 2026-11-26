TABLES: VBFA, *VBFA, VBFAD.

DATA:    BEGIN OF COMMON PART VBFACOM.
* Alter Tabellenstand beim Ändern

DATA:    BEGIN OF YVBFA OCCURS 0.
           INCLUDE STRUCTURE VBFAVB.
DATA:    END OF YVBFA.

* Aktueller Tabellenstand

DATA:    BEGIN OF XVBFA OCCURS 0.
           INCLUDE STRUCTURE VBFAVB.
DATA:    END OF XVBFA.

* XVBFA for SD_ORDER_GET_DATA
data:    begin of x1vbfa occurs 0.
           include structure vbfavb.
data:    end of x1vbfa.

  DATA: BEGIN OF VBFA_KOR OCCURS 100,   "3.0B
          VBELV LIKE VBFA-VBELV,        "3.0B
          POSNV LIKE VBFA-POSNV,        "3.0B
          VBELN LIKE VBFA-VBELN,        "3.0B
        END OF VBFA_KOR.                "3.0B
  DATA: BEGIN OF VBFA_KOR_KEY,          "3.0B
          VBELV LIKE VBFA-VBELV,        "3.0B
          POSNV LIKE VBFA-POSNV,        "3.0B
          VBELN LIKE VBFA-VBELN,        "3.0B
        END OF VBFA_KOR_KEY.            "3.0B
                                        "3.0B
DATA:    END OF COMMON PART VBFACOM.


DATA:    BEGIN OF COMMON PART VBFACO1.
* Aktueller Stand des Versandelementflusses
DATA:    BEGIN OF XPACKVBFA OCCURS 5.
           INCLUDE STRUCTURE VBFAVB.
DATA:    END OF XPACKVBFA.
* Alter Stand des Versandelementflusses
DATA:    BEGIN OF YPACKVBFA OCCURS 5.
           INCLUDE STRUCTURE VBFAVB.
DATA:    END OF YPACKVBFA.
DATA:    END OF COMMON PART VBFACO1.
*eject