
************************************************************************
*         FORM OBJECTREFERENCE_CREAT                                   *
*----------------------------------------------------------------------*
* Schreiben der allgemeinen Objektreferenz                             *
************************************************************************
FORM OBJECTREFERENCE_CREAT TABLES US_ATTR_TAB STRUCTURE BRELATTR
                           USING  US_ROLEA    STRUCTURE BORIDENT
                                  US_ROLEB    STRUCTURE BORIDENT
                                  US_RELATIONTYPE.

  CALL FUNCTION 'BINARY_RELATION_CREATE'
       EXPORTING
            OBJ_ROLEA      =  US_ROLEA
            OBJ_ROLEB      =  US_ROLEB
            RELATIONTYPE   =  US_RELATIONTYPE
       TABLES
            BINREL_ATTRIB  = US_ATTR_TAB
       EXCEPTIONS
            NO_MODEL       = 1
            INTERNAL_ERROR = 2
            UNKNOWN        = 3
            OTHERS         = 4.

  IF SY-SUBRC > 0.
    MESSAGE ID SY-MSGID
            TYPE CHARA
            NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.