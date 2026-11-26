***INCLUDE MV45AF0C_CHECK_CRM_DOCUMENT .
*
*----------------------------------------------------------------------*
***INCLUDE MV45AF0C_CHECK_CRM_DOCUMENT .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_CRM_DOCUMENT
*&---------------------------------------------------------------------*
* Lesen der Objektverknüpfung
*----------------------------------------------------------------------*
FORM CHECK_CRM_DOCUMENT USING    US_VBAK    STRUCTURE VBAK
                                 US_MESSAGE TYPE C
                        CHANGING EV_BAPI    TYPE C
                                 ES_OBJECT  TYPE BORIDENT.

  DATA:
    DA_LINKS TYPE STANDARD TABLE OF RELGRAPHLK WITH HEADER LINE,
    DA_OBJTYPE      LIKE BAPIUSW01-OBJTYPE,
    DA_LOGSYS       LIKE TBDLS-LOGSYS,
    DA_ROLE         LIKE BORIDENT,
    da_relationtype like breltyp-reltype.

  CLEAR ES_OBJECT.

  EV_BAPI = CALL_BAPI.                 " is this a bapi call ?
  IF EV_BAPI IS INITIAL.
*   evtl. trotzdem im Dunkeln per Call FUNCTION
    EV_BAPI = CALL_FUNCTION.
  ENDIF.

  check us_vbak-vbkla+0(2) =  'CR' and
        us_vbak-vbkla+3(3) >= '20B'.   " Identifies a crm-order
  CHECK T180-TRTYP NE CHARA.           " Do not check in create-mode
  check not ( sy-tcode eq 'VCC1' or    " payment card and letter of
              sy-tcode eq 'VXA3' or    " credit processing is allowed
         call_activity eq 'CRRL' ).    " credit releasing, too

* Bestimmen des Businessobjektes des Belegs
  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            I_DOCUMENT_TYPE   = US_VBAK-VBTYP
       IMPORTING
            E_BUSINESS_OBJECT = DA_OBJTYPE
       EXCEPTIONS
            OTHERS            = 1.

  IF SY-SUBRC = 0.
*   Bestimmen des eigenen Systems
    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
         IMPORTING
              OWN_LOGICAL_SYSTEM             = DA_LOGSYS
         EXCEPTIONS
              OWN_LOGICAL_SYSTEM_NOT_DEFINED = 1
              OTHERS                         = 2.
  ENDIF.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID
            TYPE CHARA
            NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Belegdaten füllen
  DA_ROLE-OBJKEY  = US_VBAK-VBELN.
  DA_ROLE-OBJTYPE = DA_OBJTYPE.
  DA_ROLE-LOGSYS  = DA_LOGSYS.

* Objektverknüpfungen lesen
  CALL FUNCTION 'SREL_GET_NEXT_RELATIONS'
       EXPORTING
            OBJECT         = DA_ROLE
       TABLES
            LINKS          = DA_LINKS
       EXCEPTIONS
            INTERNAL_ERROR = 1
            OTHERS         = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
*   Auf Objektverknüpung in CRM prüfen
    READ TABLE DA_LINKS WITH KEY RELTYPE = 'CRM6'.
    IF SY-SUBRC = 0.
      ES_OBJECT-OBJKEY  = DA_LINKS-OBJKEY_A.
      ES_OBJECT-OBJTYPE = DA_LINKS-OBJTYPE_A.
      ES_OBJECT-LOGSYS  = DA_LINKS-LOGSYS_A.

*     Meldung erwünscht ?
      IF NOT US_MESSAGE IS INITIAL AND
             ev_bapi    is initial    and
         us_vbak-vbkla+2(1) <> charz  and
         us_vbak-vbkla+2(1) <> charx  and
         us_vbak-vbkla+2(1) <> chara.
        PERFORM  MESSAGE_VARIABEL(SAPFV45L)
          USING  'V4' '310' RV45Z-MSGVS CHARX
                 SPACE SPACE SPACE SPACE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.