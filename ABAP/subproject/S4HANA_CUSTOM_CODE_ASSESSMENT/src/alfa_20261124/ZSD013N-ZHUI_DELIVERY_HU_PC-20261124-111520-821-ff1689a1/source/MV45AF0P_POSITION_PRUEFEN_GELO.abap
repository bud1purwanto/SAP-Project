*&--------------------------------------------------------------------*
*&      Form  POSITION_PRUEFEN_GELOESCHT                              *
*&--------------------------------------------------------------------*
*       text                                                          *
*---------------------------------------------------------------------*
*      -->P_VBAP_VBELN  text
*      -->P_VBAP_POSNR  text
*      <--P_SUBRC       P_SUBRC = 4 -> Position gelöscht
*                       P_SUBRC = 0 -> Position nicht gelöscht
*---------------------------------------------------------------------*
FORM POSITION_PRUEFEN_GELOESCHT  USING    P_VBAP_VBELN
                                          P_VBAP_POSNR
                                 CHANGING P_SUBRC.

  CLEAR: P_SUBRC.

  READ TABLE XVBAP WITH KEY VBELN = P_VBAP_VBELN
                            POSNR = P_VBAP_POSNR
                            UPDKZ = UPDKZ_DELETE
                   TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    P_SUBRC = 4.
  ENDIF.

ENDFORM.                    " POSITION_PRUEFEN_GELOESCHT