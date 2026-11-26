*eject
*----------------------------------------------------------------------*
* Zuordnen von Wareneingängen u. Warenausgängen
*----------------------------------------------------------------------*
FORM NACHRICHT_ARCHIVE_ZUORDNEN.

  DATA: BEGIN OF XOBJECT OCCURS 0,
        OBJECT LIKE SAPB-SAPOBJID.
  DATA: END OF XOBJECT.
  XOBJECT-OBJECT       = MKPF-MBLNR.
  XOBJECT-OBJECT+10(4) = MKPF-MJAHR.
  APPEND XOBJECT.

  CALL FUNCTION 'ARCHIV_APPEND_DIALOG_META'
       EXPORTING
            AR_OBJECT                = 'MMIDELNTOR'
            OBJECT_ID                =  XOBJECT-OBJECT
            SAP_OBJECT               = 'BUS2017'
            SELECT_FLAG              = 'X'
       EXCEPTIONS
            ERROR_ARCHIV             = 01
            ERROR_COMMUNICATIONTABLE = 02
            ERROR_CONNECTIONTABLE    = 03
            ERROR_KERNEL             = 04
            ERROR_PARAMETER          = 05
            NOT_UNIQUE               = 06
            NOVIEWER                 = 07.

  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.