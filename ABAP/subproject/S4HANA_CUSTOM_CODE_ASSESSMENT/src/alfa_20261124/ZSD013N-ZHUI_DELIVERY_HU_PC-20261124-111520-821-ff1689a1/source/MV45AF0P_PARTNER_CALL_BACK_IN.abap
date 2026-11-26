*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PARTNER_CALL_BACK_IN                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PARTNER_CALL_BACK_IN
*&---------------------------------------------------------------------*
*       Partner-Call-Back initialisieren
*----------------------------------------------------------------------*
FORM PARTNER_CALL_BACK_IN USING US_VBELN LIKE VBAK-VBELN
                                US_VBTYP LIKE VBAK-VBTYP
                                US_TVAK LIKE TVAK.

  DATA: LF_OBJECTKEY TYPE SWO_TYPEID,
        LF_OBJECTTYPE TYPE NAST-OBJTYPE,
        LF_OBJECTTYPE_ITEM TYPE NAST-OBJTYPE,
        LF_PARTNER_OBJECTTYPE TYPE SWO_OBJTYP,
        LF_PARTNER_OBJECTTYPE_ITEM TYPE SWO_OBJTYP.


* Initialize call-back-memory
  LF_OBJECTKEY = US_VBELN.

  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            I_DOCUMENT_TYPE        = US_VBTYP
            I_TVAK                 = US_TVAK
       IMPORTING
            E_BUSINESS_OBJECT      = LF_OBJECTTYPE
            E_BUSINESS_OBJECT_ITEM = LF_OBJECTTYPE_ITEM.

  LF_PARTNER_OBJECTTYPE = LF_OBJECTTYPE.
  LF_PARTNER_OBJECTTYPE_ITEM = LF_OBJECTTYPE_ITEM.

  CALL FUNCTION 'SD_PARTNER_CALL_BACK_CLEAR'
       EXPORTING
            FIC_OBJECTTYPE = LF_PARTNER_OBJECTTYPE
            FIC_OBJECTKEY  = LF_OBJECTKEY.


ENDFORM.                               " PARTNER_CALL_BACK_IN



















