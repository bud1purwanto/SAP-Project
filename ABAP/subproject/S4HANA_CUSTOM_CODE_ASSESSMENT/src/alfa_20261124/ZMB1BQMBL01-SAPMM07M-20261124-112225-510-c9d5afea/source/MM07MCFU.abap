DATA: BEGIN OF COMMON PART MM07MCFU.

*------- Tabelle der möglichen Positionen (im Selektionsmodus)
DATA: BEGIN OF FUSS OCCURS 0.
        INCLUDE STRUCTURE FUSS_MB.
DATA: END OF FUSS.
*------- Tabelle der Varianten eines Sammelartikels; wird der Sammel-
*        artikel selektiert, werden die Einträge aus dieser Tabelle nach
*        FUSS übernommen
DATA: BEGIN OF VAR_FUSS OCCURS 0.
        INCLUDE STRUCTURE FUSS_MB.
DATA: KOPF_ZEILE LIKE MSEG-ZEILE.
DATA: KZ_NEU TYPE C.
DATA: STATU  TYPE C.                                              " PPF
DATA: END OF VAR_FUSS.

DATA: BEGIN OF YFUSS OCCURS 0.
        INCLUDE STRUCTURE FUSS_MB.
DATA: STATU  TYPE C.                                              " PPF
DATA: END OF YFUSS.

DATA: BEGIN OF ZFUSS OCCURS 0.
        INCLUDE STRUCTURE FUSS_MB.
DATA: STATU  TYPE C.                                              " PPF
DATA: END OF ZFUSS.

DATA: END OF COMMON PART.
*eject