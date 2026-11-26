************************************************************************
*         FORM OBJECTREFERENCE_delet                                   *
*----------------------------------------------------------------------*
* Löschen   der allgemeinen Objektreferenz                             *
* 1. Wenn Vorgänger initial, dann ermittle sie                         *
* 2. Vorgängerreferenzen löschen                                       *
************************************************************************
FORM OBJECTREFERENCE_DELET USING US_ROLEA  STRUCTURE BORIDENT
                                 US_ROLEB  STRUCTURE BORIDENT
                                 US_RELATIONTYPE.

  DATA: BEGIN OF DA_LINKS OCCURS 1.
              INCLUDE STRUCTURE RELGRAPHLK.
  DATA: END   OF DA_LINKS.

  REFRESH: DA_LINKS. CLEAR DA_LINKS.

* 1. Wenn Vorgänger initial, dann ermittle sie                         *
  IF US_ROLEA IS INITIAL.
     CALL FUNCTION 'SREL_GET_NEXT_RELATIONS'
          EXPORTING
              OBJECT         =  US_ROLEB
          TABLES
              LINKS          = DA_LINKS
          EXCEPTIONS
              INTERNAL_ERROR = 01.
  ELSE.
       DA_LINKS-OBJKEY_A  = US_ROLEA-OBJKEY.
       DA_LINKS-OBJTYPE_A = US_ROLEA-OBJTYPE.
       DA_LINKS-LOGSYS_A  = US_ROLEA-LOGSYS.
       APPEND DA_LINKS.
  ENDIF.

  CHECK NOT DA_LINKS[] IS INITIAL.

* 2. Vorgängerreferenzen löschen                                       *
  LOOP AT DA_LINKS.
       US_ROLEA-OBJKEY  = DA_LINKS-OBJKEY_A.
       US_ROLEA-OBJTYPE = DA_LINKS-OBJTYPE_A.
       US_ROLEA-LOGSYS  = DA_LINKS-LOGSYS_A.
* bei externe ist das VORL, bei R/3 R/3 kann das was anderes sein.
       US_RELATIONTYPE  = DA_LINKS-RELTYPE.

       CALL FUNCTION 'BINARY_RELATION_DELETE'
            EXPORTING
               OBJ_ROLEA      =  US_ROLEA
               OBJ_ROLEB      =  US_ROLEB
               RELATIONTYPE   =  US_RELATIONTYPE
            EXCEPTIONS
               ENTRY_NOT_EXISTING = 1
               INTERNAL_ERROR     = 2
               NO_RELATION        = 3
               NO_ROLE            = 4.

  ENDLOOP.
ENDFORM.