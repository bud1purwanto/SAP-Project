*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_PEFZ                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FCODE_PEFZ                                               *
*---------------------------------------------------------------------*
*                                                                     *
*       Die Eingangsfortschrittszahl wird auf Anforderung             *
*       vorgeschlagen, wenn ein neuer Abruf angelegt wurde und        *
*       sowohl Lieferfortschrittszahl als auch Nummer der letzten     *
*       Lieferung fehlen                                              *
*                                                                     *
*---------------------------------------------------------------------*
FORM FCODE_PEFZ.

  DATA: DA_IDOCS_MIT_EFZ,
        DA_RESET_CDQ.

  PERFORM VBLB_BEARBEITEN_VORBEREITEN(SAPFV45L).

  CALL FUNCTION 'SD_DETERMINE_FISC_YEAR_CHANGE'
     EXPORTING
          I_KUNNR     = VBAK-KUNNR
          I_MATNR     = VBAP-MATNR
          I_VBELN     = VBLB-VBELN
          I_POSNR     = VBLB-POSNR
     IMPORTING
          E_RESET_CDQ = DA_RESET_CDQ
     EXCEPTIONS
          OTHERS      = 1.

  PERFORM VBLB-ABEFZ_VORSCHLAGEN(SAPFV45L) USING    SPACE
                                                    DA_RESET_CDQ
                                           CHANGING DA_IDOCS_MIT_EFZ.
  PERFORM VBLB_BEARBEITEN(SAPFV45L).

* CMDS - Collaborative Management of Delivery Schedules
  clear gv_propose_rcq.

ENDFORM.                               " FCODE_PEFZ