*----------------------------------------------------------------------*
*   INCLUDE MV45AF0V_VBELN_IN_PARTNER                                  *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM VBELN_IN_PARTNER                                         *
*---------------------------------------------------------------------*
*       Belegnummer wird beim Anlegen in Partnertabelle übernommen    *
*---------------------------------------------------------------------*

FORM VBELN_IN_PARTNER.

  CHECK T180-TRTYP EQ CHARH.

  LOOP AT XVBPA.
    XVBPA-VBELN = VBAK-VBELN.
    MODIFY XVBPA.
  ENDLOOP.

ENDFORM.