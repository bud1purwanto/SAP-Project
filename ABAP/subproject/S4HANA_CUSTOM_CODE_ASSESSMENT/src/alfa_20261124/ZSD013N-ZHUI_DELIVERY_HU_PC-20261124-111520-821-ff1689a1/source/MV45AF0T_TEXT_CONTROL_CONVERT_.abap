*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_CONVERT_                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TEXT_CONTROL_CONVERT_FCODE
*&---------------------------------------------------------------------*
*       Umsetzen Fcode, falls Text Edit Control eingestellt
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_CONVERT_FCODE.

  IF FCODE EQ FCODE_UEBERSICHT_EINZEILIG.
* Nur falls die aktuelle Kopfgruppe zu den Panels ERF1 oder ERFA führt
    READ TABLE KGTAB WITH KEY TVAK-KOPGR BINARY SEARCH.
    CHECK: SY-SUBRC EQ 0,
           NOT TVAK-TXTGR IS INITIAL.
    IF NOT TVAK-TDID IS INITIAL AND
       ( SYSTEMTYP IS INITIAL OR
         SYSTEMTYP EQ 'WN32' ) AND
      NOT TEXT_CONTROL_AVAILABLE IS INITIAL.
      FCODE = FCODE_UEBERSICHT_MIT_TEC.
    ENDIF.
  ENDIF.

ENDFORM.                    " TEC_CONVERT_FCODE