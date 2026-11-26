*----------------------------------------------------------------------*
*   INCLUDE FV50XF0K_KORR_AUPSTAB_INSERT                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_AUPSTAB_INSERT
*&---------------------------------------------------------------------*
*       Fügt an aupstab einen Eintrag an, wenn noch nicht da.
*----------------------------------------------------------------------*
FORM KORR_AUPSTAB_INSERT TABLES AUPSTAB TYPE VLKOR_AUPSTAB.

  DATA: D_TABIX LIKE SY-TABIX.
  READ TABLE AUPSTAB WITH KEY VBELN = AUPSTAB-VBELN
                              POSNR = AUPSTAB-POSNR
                              GRKOR = AUPSTAB-GRKOR
                              UEPOS = AUPSTAB-UEPOS
                     BINARY SEARCH.
  D_TABIX = SY-TABIX.
  IF SY-SUBRC <> 0.
    AUPSTAB-ANZAUP = 1.
    CLEAR AUPSTAB-ANZLFA.
    CLEAR AUPSTAB-ANZLFG.
    INSERT AUPSTAB INDEX D_TABIX.
  ENDIF.

ENDFORM.                               " KORR_AUPSTAB_INSERT