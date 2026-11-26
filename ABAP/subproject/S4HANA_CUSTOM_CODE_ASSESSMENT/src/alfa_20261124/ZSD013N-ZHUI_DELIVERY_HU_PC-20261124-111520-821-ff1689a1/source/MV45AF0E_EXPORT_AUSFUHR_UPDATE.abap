*eject
*----------------------------------------------------------------------*
*       Form  EXPORT_AUSFUHR_UPDATE_PREPARE                            *
*----------------------------------------------------------------------*
*       Vorbereitung der Verbuchung der Ausfuhrkontrolldaten           *
*----------------------------------------------------------------------*
FORM EXPORT_AUSFUHR_UPDATE_PREPARE.

*------- Vorbereitung der Verbuchung
  CALL FUNCTION 'RV_EXPORT_CONTROL_UPD_PREPARE'
    EXPORTING
       ORDER_TYPE      = TVAK-VBTYP
    TABLES
       I_XVBAP         = XVBAP
       I_YVBAP         = YVBAP
       I_XVBEX         = XVBEX
       I_YVBEX         = YVBEX
       E_XEMBK         = XEMBK.

*------- Einfuegen der Belegnummer
   CALL FUNCTION 'RV_EXPORT_XVBEX_RENAME'
        EXPORTING
             DOCUMENT_NUMBER = VBAK-VBELN
        TABLES
             I_XVBEX         = XVBEX.

ENDFORM.