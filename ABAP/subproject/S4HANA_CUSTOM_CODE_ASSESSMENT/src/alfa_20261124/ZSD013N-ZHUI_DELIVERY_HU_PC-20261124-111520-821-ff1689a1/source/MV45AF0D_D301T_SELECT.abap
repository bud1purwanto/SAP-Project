*---------------------------------------------------------------------*
*       FORM D031T_SELECT                                             *
*---------------------------------------------------------------------*
*       Lesen der Dictionary-Tabelle D301T: Fcodes                    *
*---------------------------------------------------------------------*
*  -->  DS_FCODE       Funktionscode                                  *
*  <--  RV45A-CUA_LONG Text zum Funktionscode                         *
*---------------------------------------------------------------------*

FORM D301T_SELECT USING VALUE(US_FCODE).

DATA: DA_TEXT LIKE RSEU1-MENU.

  CASE US_FCODE.
    WHEN 'UALL'.
      RV45A-CUA_LONG = TEXT-014.
    WHEN 'UHAU'.
      RV45A-CUA_LONG = TEXT-015.
    WHEN 'UMAR'.
      RV45A-CUA_LONG = TEXT-016.
    WHEN 'UKDP'.
      RV45A-CUA_LONG = TEXT-017.
    WHEN 'PEIN'.
      EXIT.
    WHEN OTHERS.
ENHANCEMENT-SECTION     D301T_SELECT_01 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'CUABUFFER_READ'
       EXPORTING
            FUNCTION = US_FCODE
            PROGRAM  = T180-AGIDV
       IMPORTING
            L_TEXT   = DA_TEXT
       EXCEPTIONS
            OTHERS   = 01.
  IF SY-SUBRC GT 0.
    MESSAGE E328 WITH US_FCODE.
     ENDIF.
     RV45A-CUA_LONG = DA_TEXT.
END-ENHANCEMENT-SECTION.
  ENDCASE.


ENDFORM.