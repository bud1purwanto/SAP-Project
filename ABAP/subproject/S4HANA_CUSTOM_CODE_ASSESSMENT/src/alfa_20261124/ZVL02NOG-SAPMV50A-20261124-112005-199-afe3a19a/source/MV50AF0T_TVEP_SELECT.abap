*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVEP_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVEP_SELECT                                              *
*---------------------------------------------------------------------*
*       Die Einteilungstypentabelle wird gelesen                      *
*---------------------------------------------------------------------*
FORM tvep_select USING ts_ettyp LIKE tvep-ettyp
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_ettyp NE tvep-ettyp.

  IF ts_ettyp = space.
    CLEAR: tvep.
    EXIT.
  ENDIF.
  SELECT SINGLE * FROM tvep WHERE ettyp = ts_ettyp.
  IF sy-subrc NE 0.
    CLEAR: tvep.
    ts_subrc = 4.
  ENDIF.

ENDFORM.                    "TVEP_SELECT
*eject