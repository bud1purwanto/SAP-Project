*----------------------------------------------------------------------*
*   INCLUDE MV45AO0S_SETZEN_TRANSAKTION_KO                             *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*   MODULE  SETZEN_TRANSAKTION_KONTRAKTE OUTPUT                       *
*---------------------------------------------------------------------*
*   Es werden die Transaktionen VA41/2/3X für neue Kontraktarten      *
*   verboten, da sie für diese Belegarten nicht funktionieren         *
*---------------------------------------------------------------------*
MODULE  SETZEN_TRANSAKTION_KONTRAKTE OUTPUT.

  DATA: DA_TCODE LIKE T180-TCODE.

  CHECK T180-TCODE = 'VA41X' OR
        T180-TCODE = 'VA42X' OR
        T180-TCODE = 'VA43X'.

  IF TVAK-KOPGR = 'GK' OR
     TVAK-KOPGR = 'WK' OR
     TVAK-KOPGR = 'WK1'.

    DA_TCODE = T180-TCODE.
    REPLACE CHARX WITH SPACE INTO DA_TCODE.
    MESSAGE S778 WITH TVAK-AUART DA_TCODE.
    LEAVE TO TRANSACTION DA_TCODE AND SKIP FIRST SCREEN.

  ENDIF.

ENDMODULE.