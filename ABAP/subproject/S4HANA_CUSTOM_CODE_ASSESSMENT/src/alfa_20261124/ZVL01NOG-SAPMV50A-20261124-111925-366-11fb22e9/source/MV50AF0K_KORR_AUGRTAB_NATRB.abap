*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_AUGRTAB_NATRB                                *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_AUGRTAB_NATRB
*&---------------------------------------------------------------------*
*       Aufsummieren der Naturalrabatt-Hauptpositionen
*       und aller Naturalrabatt-Unterpositionen (falls es
*       einmal mehrere geben sollte)
*
*       Summiert die Einträge der      aupstab in der augrtab auf
*       und löscht jeden verarbeiteten aupstab-Eintrag
*
*----------------------------------------------------------------------*
FORM KORR_AUGRTAB_NATRB TABLES AUPSTAB TYPE VLKOR_AUPSTAB
                               AUGRTAB TYPE VLKOR_AUGRTAB.

  LOOP AT AUPSTAB WHERE UEPVW CA NATURALRABATT
                    AND NOT UEPOS IS INITIAL.
    MOVE-CORRESPONDING AUPSTAB TO AUGRTAB.
    CLEAR AUGRTAB-GRKOR.
    COLLECT AUGRTAB.

*   Zugehörige Hauptposition dazu addieren
    READ TABLE AUPSTAB WITH KEY VBELN = AUPSTAB-VBELN
                                POSNR = AUPSTAB-UEPOS.
    MOVE-CORRESPONDING AUPSTAB TO AUGRTAB.
    AUGRTAB-UEPOS = AUPSTAB-POSNR.
    CLEAR AUGRTAB-GRKOR.
    COLLECT AUGRTAB.
  ENDLOOP.
ENDFORM.                               " KORR_AUGRTAB_NATRB