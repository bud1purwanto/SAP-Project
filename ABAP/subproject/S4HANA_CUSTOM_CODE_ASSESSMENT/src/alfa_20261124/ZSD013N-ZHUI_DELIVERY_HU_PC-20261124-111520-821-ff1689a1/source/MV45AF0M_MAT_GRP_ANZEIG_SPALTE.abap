*----------------------------------------------------------------------*
*   INCLUDE MV45AF0M_MAT_GRP_ANZEIG_SPALTE                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MAT_GRP_ANZEIG_SPALTENAUSWAHL
*&---------------------------------------------------------------------*
*       Im Tablecontrol werden bestimmte Spalten ausgeblendet.
*       Dazu wird die Feldauswahl interpretiert.
*       Die Verarbeitung wird auf Ebene der Spaltenüberschrift
*       durchgeführt. Dort ist sy-stepl = 0.
*       Wenn die Spaltenüberschrift ausgeblendet ist, dann entfällt
*       die ganze Spalte
*----------------------------------------------------------------------*
FORM MAT_GRP_ANZEIG_SPALTENAUSWAHL.

  CHECK: SY-STEPL = 1.

  DATA: DA_NAME LIKE SCREEN-NAME,
        DA_INVISIBLE.

  DA_NAME = SCREEN-NAME.
  IF DA_NAME(1) = '*'.
    SHIFT DA_NAME LEFT.
  ENDIF.

* Nur für bestimmte Felder werden die Spalten beeinflußt:
  CHECK: DA_NAME = 'MAT_LISTE-AVQTY' OR
         DA_NAME = 'MAT_LISTE-FULLAVDAT'.
  IF SCREEN-ACTIVE = 0 OR
     SCREEN-INVISIBLE = 1.
    DA_INVISIBLE = CHARX.
  ENDIF.

  PERFORM MAT_GRP_ANZEIG_SPALTENMODIF TABLES TCTRL_MAT_GRP_ANZEIG-COLS
                        USING  DA_NAME
                               DA_INVISIBLE.


ENDFORM.                    " MAT_GRP_ANZEIG_SPALTENAUSWAHL

*&---------------------------------------------------------------------*
*&      Form  MAT_GRP_ANZEIG_SPALTENMODIF
*&---------------------------------------------------------------------*
*       Im Tablecontrol werden bestimmte Spalten ausgeblendet.
*----------------------------------------------------------------------*
FORM MAT_GRP_ANZEIG_SPALTENMODIF
                       TABLES US_COLUMN STRUCTURE
                              TCTRL_MAT_GRP_ANZEIG_COLUMN
                        USING US_NAME
                              US_INVISIBLE.

  READ TABLE US_COLUMN
             WITH KEY SCREEN-NAME = US_NAME.
  IF SY-SUBRC = 0.
    US_COLUMN-INVISIBLE = US_INVISIBLE.
    MODIFY US_COLUMN INDEX SY-TABIX.
  ENDIF.

ENDFORM.