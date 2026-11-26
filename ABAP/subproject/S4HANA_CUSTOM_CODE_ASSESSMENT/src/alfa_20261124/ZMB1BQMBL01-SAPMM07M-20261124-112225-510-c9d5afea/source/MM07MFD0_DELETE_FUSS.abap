*eject
*##ngr-saanf
*&---------------------------------------------------------------------*
*&      Form  DELETE_FUSS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      Löschen von FUSS-Zeilen und evtl. abhängiger Varianten          *
*      in VAR_FUSS                                                     *
*----------------------------------------------------------------------*
FORM DELETE_FUSS USING    P_TABIX.
  READ TABLE FUSS INDEX P_TABIX.
  IF SY-SUBRC = 0 AND
     FUSS-XSELK IS INITIAL AND
     NOT FUSS-UPVOR IS INITIAL.
    DELETE VAR_FUSS WHERE KOPF_ZEILE = FUSS-ZEILE.
  ENDIF.
  DELETE FUSS INDEX P_TABIX.

ENDFORM.                               " DELETE_FUSS