*&---------------------------------------------------------------------*
*&      Form  GRUKO_LESEN
*&---------------------------------------------------------------------*
*       Sperren des Gruppenkontrakts mit allen abhängigen Belegen
*       wenn hierfür noch offene Workitems vorhanden sind
*----------------------------------------------------------------------*
FORM GRUKO_SPERREN USING US_OBJTYPE US_VBELN.

  DATA: DA_OBJKEY LIKE SWEINSTCOU-OBJKEY.
  DATA: DA_REQUESTER LIKE SWOTOBJID OCCURS 0.

  CHECK: T180-TRTYP NE CHARA,
         NOT US_VBELN IS INITIAL.

* Nur für Gruppenkontrakte oder Unterkontrakte mit Referenz prüfen
  CHECK: VBAK-VBTYP EQ VBTYP_GRUKO OR
         NOT VBAK-VBELN_GRP IS INITIAL.

* Sperre nicht für Workflow aus GK auslösen
  IF CALL_ACTIVITY EQ ACTIVITY_GRUKO_PUSHDATA.
*   Workflow zum GK ist im Hintergrund aktiv
    EXIT.
  ELSEIF T180-TRVEW EQ CHARA.
    CALL FUNCTION 'SWO_QUERY_REQUESTER'
         TABLES
              REQUESTER = DA_REQUESTER
         EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
    IF SY-SUBRC EQ 0.
*     Workflow zum GK ist im Dialog aktiv
      EXIT.
    ELSE.
*     VA42W wird nicht durch einen Workflow augerufen
      MESSAGE E793 WITH T180-TCODE.
    ENDIF.
  ENDIF.

* Prüfen ob der Beleg gesperrt werden soll
  DA_OBJKEY = US_VBELN.
  CALL FUNCTION 'SD_GROUPCONTRACT_ITEMSTATUS_WF'
       EXPORTING
            I_OBJTYPE = US_OBJTYPE
            I_OBJKEY  = DA_OBJKEY
            I_VBAK    = VBAK
       EXCEPTIONS
            DOCUMENT_BLOCKED = 1.
  IF SY-SUBRC NE 0.
    PERFORM BELEG_ENTSPERREN USING US_VBELN.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                               " GRUKO_LESEN