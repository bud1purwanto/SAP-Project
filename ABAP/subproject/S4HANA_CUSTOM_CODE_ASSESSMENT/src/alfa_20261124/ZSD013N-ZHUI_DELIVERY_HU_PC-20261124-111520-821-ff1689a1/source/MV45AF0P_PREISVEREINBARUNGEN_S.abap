*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PREISVEREINBARUNGEN_S                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREISVEREINBARUNGEN_SICHERN
*&---------------------------------------------------------------------*
*       Verbuchen der Preisvereinbarungen und übernehmen der neu
*       vergebenen KNUMHs in XKONV
*----------------------------------------------------------------------*
FORM preisvereinbarungen_sichern.

  DATA: BEGIN OF xknumh OCCURS 0.
          INCLUDE STRUCTURE knumh_comp.
  DATA: END OF xknumh.

* Set last mv13a context
  IF t180-trtyp NE chara AND NOT tvak-vterl IS INITIAL.
    CALL FUNCTION 'SD_LAST_MV13A_CONTEXT'.
  ENDIF.

* Vertragsnummer an Konditionssätze geben
  IF t180-trtyp EQ charh AND NOT tvak-vterl IS INITIAL.
    CALL FUNCTION 'RV_CONDITION_FIELD_CHANGE'
      EXPORTING
        name_of_field       = 'VBELN'
        new_value           = vbak-vbeln
        old_value           = '$TEMP'
      EXCEPTIONS
        old_value_not_found = 01
        unknown_field       = 02.
  ENDIF.

* Vertragskonditionen buchen
  IF t180-trtyp NE chara AND NOT tvak-vterl IS INITIAL.
    CALL FUNCTION 'RV_CONDITION_SAVE'
      EXPORTING
        i_no_posting = 'X'
      TABLES
        knumh_map    = xknumh.
  ENDIF.

  LOOP AT xknumh.
    LOOP AT xkomv WHERE knumh = xknumh-knumh_old.
      xkomv-knumh = xknumh-knumh_new.
      MODIFY xkomv.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                               " PREISVEREINBARUNGEN_SICHERN