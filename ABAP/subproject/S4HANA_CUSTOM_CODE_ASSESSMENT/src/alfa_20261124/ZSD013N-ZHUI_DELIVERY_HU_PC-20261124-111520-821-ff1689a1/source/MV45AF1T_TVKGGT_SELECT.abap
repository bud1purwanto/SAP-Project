*&---------------------------------------------------------------------*
*&      Form  TVKGGT_SELECT
*&---------------------------------------------------------------------*
*       Kundenkonditionsgruppen Texte lesen
*----------------------------------------------------------------------*
*      -->P_KDKG1  Kunde: Attribut 11                                  *
*      -->P_KDKG2  Kunde: Attribut 12                                  *
*      -->P_KDKG3  Kunde: Attribut 13                                  *
*      -->P_KDKG4  Kunde: Attribut 14                                  *
*      -->P_KDKG5  Kunde: Attribut 15                                  *
*      -->P_SUBRC                                                      *
*----------------------------------------------------------------------*
FORM TVKGGT_SELECT USING    P_KDKG1
                            P_KDKG2
                            P_KDKG3
                            P_KDKG4
                            P_KDKG5
                            P_SUBRC.

  P_SUBRC = 0.
  CLEAR: TVKGGT_TXT1,  TVKGGT_TXT2,  TVKGGT_TXT3,
         TVKGGT_TXT4,  TVKGGT_TXT5.

  IF NOT P_KDKG1 IS INITIAL.
    SELECT SINGLE * FROM TVKGGT WHERE SPRAS = SY-LANGU AND
                                      KDKGR = P_KDKG1.
    IF SY-SUBRC = 0.
      TVKGGT_TXT1 = TVKGGT-VTEXT.
    ELSE.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

  IF NOT P_KDKG2 IS INITIAL.
    SELECT SINGLE * FROM TVKGGT WHERE SPRAS = SY-LANGU AND
                                      KDKGR = P_KDKG2.
    IF SY-SUBRC = 0.
      TVKGGT_TXT2 = TVKGGT-VTEXT.
    ELSE.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

  IF NOT P_KDKG3 IS INITIAL.
    SELECT SINGLE * FROM TVKGGT WHERE SPRAS = SY-LANGU AND
                                      KDKGR = P_KDKG3.
    IF SY-SUBRC = 0.
      TVKGGT_TXT3 = TVKGGT-VTEXT.
    ELSE.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

  IF NOT P_KDKG4 IS INITIAL.
    SELECT SINGLE * FROM TVKGGT WHERE SPRAS = SY-LANGU AND
                                      KDKGR = P_KDKG4.
    IF SY-SUBRC = 0.
      TVKGGT_TXT4 = TVKGGT-VTEXT.
    ELSE.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

  IF NOT P_KDKG5 IS INITIAL.
    SELECT SINGLE * FROM TVKGGT WHERE SPRAS = SY-LANGU AND
                                      KDKGR = P_KDKG5.
    IF SY-SUBRC = 0.
      TVKGGT_TXT5 = TVKGGT-VTEXT.
    ELSE.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.                               " TVKGGT_SELECT