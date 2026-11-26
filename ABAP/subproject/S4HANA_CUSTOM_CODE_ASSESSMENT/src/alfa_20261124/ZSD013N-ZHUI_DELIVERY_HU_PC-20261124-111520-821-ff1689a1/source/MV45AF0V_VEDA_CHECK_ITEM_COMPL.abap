*&---------------------------------------------------------------------*
*&      Form  VEDA_CHECK_ITEM_COMPLETENESS
*&---------------------------------------------------------------------*
*       Aktualisieren des Unvollständigkeitsprotokolls                 *
*       für Veda Daten auf Positionsebene                              *
*----------------------------------------------------------------------*
FORM VEDA_CHECK_ITEM_COMPLETENESS.

  LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE
                  AND PVPOS IS INITIAL.
    SVBAP-TABIX = SY-TABIX.
    SELECT SINGLE * FROM TVAP WHERE PSTYV EQ XVBAP-PSTYV.
    CALL FUNCTION 'SD_VEDA_CHECK_COMPLETENESS'
         EXPORTING
              I_VBELN             = XVBAP-VBELN
              I_VPOSN             = XVBAP-POSNR
              I_FEHGR             = TVAP-FEHGR
              I_DIALOG_INCOMPLETE = SPACE
         TABLES
              T_HVBUV             = XVBUV
              T_XVBUV             = XVBUV.

*   Status bei Vertragsdatenänderung neu ermitteln
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM XVBUP_PFLEGEN_AKTUELL(SAPFV45P).
  ENDLOOP.

ENDFORM.                               " VEDA_CHECK_ITEM_COMPLETENESS