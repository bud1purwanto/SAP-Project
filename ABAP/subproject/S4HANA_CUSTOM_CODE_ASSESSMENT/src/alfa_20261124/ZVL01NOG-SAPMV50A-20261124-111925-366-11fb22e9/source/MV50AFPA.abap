***********************************************************************
*  Unterroutinen RV-Versand     Partner                               *
*  ------------------------------------                               *
*                                                                     *
*                                                                     *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM XVBPA_AUFBAUEN                                           *
*---------------------------------------------------------------------*
*       Die Belegpartner werden von der Datenbank gelesen.            *
*       MV50AFPA                                                      *
*       LV60AF0X: XVBPA_ERGAENZEN                                     *
*---------------------------------------------------------------------*
FORM XVBPA_AUFBAUEN.

  XVBPA = VBPA.
  VTCOM-PARVW = VBPA-PARVW.
  VTCOM-KUNNR = VBPA-KUNNR.
  VTCOM-LIFNR = VBPA-LIFNR.
  VTCOM-PARNR = VBPA-PARNR.
  VTCOM-PERNR = VBPA-PERNR.
  CLEAR KUPAV.
  VTCOM-MSGKZ = 'U'.

  CALL FUNCTION 'VIEW_KUPAV'
    EXPORTING COMWA    = VTCOM
    IMPORTING PAWA     = KUPAV
              TPAR_WA  = TPAR.

  VTCOM-MSGKZ = ' '.
  XVBPA-NAME1 = KUPAV-NAME1.
  XVBPA-FEHGR = TPAR-FEHGR.
  XVBPA-NRART = TPAR-NRART.
  XVBPA-SPRAS = KUPAV-SPRAS.
  XVBPA-TELFX = KUPAV-TELFX.
  XVBPA-TELTX = KUPAV-TELTX.
  XVBPA-TELX1 = KUPAV-TELX1.

  IF XVBPA-ADRNR CN '0 '.
    PERFORM SADR_SELECT USING XVBPA-ADRNR XVBPA-ADRNP XVBPA-ADRDA.
    IF XVBADR-NAME1 NE ' '.
      XVBPA-NAME1 = XVBADR-NAME1.
      XVBPA-TELFX = XVBADR-TELFX.
      XVBPA-TELTX = XVBADR-TELTX.
      XVBPA-TELX1 = XVBADR-TELX1.
      XVBPA-SPRAS = XVBADR-SPRAS.
    ENDIF.
  ENDIF.

  APPEND XVBPA.
ENDFORM.

*eject