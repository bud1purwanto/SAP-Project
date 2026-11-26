*---------------------------------------------------------------------*
*       FORM VBEX_LESEN                                               *
*---------------------------------------------------------------------*
*       Fuellen der internen Tabelle XVBEX mit den Daten von der      *
*       Datenbank                                                     *
*---------------------------------------------------------------------*
*       ==> H_XVBEX       : Exportkontrolldaten : Neu                 *
*       ==> H_YVBEX       : Exportkontrolldaten : Alt                 *
*       ==> H_VBELN       : Belegnummer                               *
*---------------------------------------------------------------------*
FORM VBEX_LESEN
     TABLES H_XVBEX STRUCTURE XVBEX
            H_YVBEX STRUCTURE YVBEX
     USING  H_VBELN.

  REFRESH: H_XVBEX,
           H_YVBEX.

  SELECT * FROM VBEX WHERE VBELN = H_VBELN.

    MOVE-CORRESPONDING: VBEX TO H_XVBEX.
    H_XVBEX-UPDKZ = UPDKZ_OLD.

    APPEND H_XVBEX.

  ENDSELECT.

  SORT H_XVBEX BY VBELN POSNR GEGRU ASCENDING.

  CLEAR: H_XVBEX,
         H_YVBEX.

ENDFORM.