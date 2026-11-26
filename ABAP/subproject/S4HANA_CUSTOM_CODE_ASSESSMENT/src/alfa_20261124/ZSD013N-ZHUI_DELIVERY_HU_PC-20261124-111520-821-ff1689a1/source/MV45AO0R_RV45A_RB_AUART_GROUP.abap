*---------------------------------------------------------------------*
*       MODULE RV45A_RB_AUART_GROUP                                   *
*---------------------------------------------------------------------*
*       Texte für alternative Auftragsarten ermitteln                 *
*---------------------------------------------------------------------*
MODULE RV45A_RB_AUART_GROUP OUTPUT.

* Text für 1. alternative Auftragsart lesen
  IF TVAK-AAUART1 IS INITIAL.
    CLEAR RV45A-TXT_RB_AAUART1.
  ELSE.
    PERFORM TVAKT_SELECT USING TVAK-AAUART1
                               SPACE
                               SY-SUBRC.
    IF SY-SUBRC NE 0 OR
       TVAKT-BEZEI IS INITIAL.
      MESSAGE E889 WITH TVAK-AAUART1 SY-LANGU.
    ELSE.
      RV45A-TXT_RB_AAUART1 = TVAKT-BEZEI.
    ENDIF.
  ENDIF.

* Text für 2. alternative Auftragsart lesen
  IF TVAK-AAUART2 IS INITIAL.
    CLEAR RV45A-TXT_RB_AAUART2.
  ELSE.
    PERFORM TVAKT_SELECT USING TVAK-AAUART2
                               SPACE
                               SY-SUBRC.
    IF SY-SUBRC NE 0 OR
       TVAKT-BEZEI IS INITIAL.
      MESSAGE E889 WITH TVAK-AAUART2 SY-LANGU.
    ELSE.
      RV45A-TXT_RB_AAUART2 = TVAKT-BEZEI.
    ENDIF.
  ENDIF.

* Text für aktuelle Auftragsart lesen
  PERFORM TVAKT_SELECT USING TVAK-AUART
                               SPACE
                               SY-SUBRC.
  IF SY-SUBRC NE 0 OR
     TVAKT-BEZEI IS INITIAL.
    MESSAGE E119 WITH TVAK-AUART SY-LANGU.
  ELSE.
    RV45A-TXT_RB_AUART = TVAKT-BEZEI.
  ENDIF.

* Radiobutton für alternative Auftragsart setzen (beim Anzeigen)
  IF T180-TRTYP EQ CHARA.
    CASE TVAK-AUART.
      WHEN TVAK-AAUART1.
        RV45A-RB_AAUART1 = CHARX.
      WHEN TVAK-AAUART2.
        RV45A-RB_AAUART2 = CHARX.
      WHEN OTHERS.
        RV45A-RB_AUART = CHARX.
    ENDCASE.
  ENDIF.

* Default Radiobutton setzen wenn er bisher nicht aktiv gesetzt wurde
  IF RV45A-RB_AUART   IS INITIAL AND
     RV45A-RB_AAUART1 IS INITIAL AND
     RV45A-RB_AAUART2 IS INITIAL.
    RV45A-RB_AUART = CHARX.
  ENDIF.

ENDMODULE.