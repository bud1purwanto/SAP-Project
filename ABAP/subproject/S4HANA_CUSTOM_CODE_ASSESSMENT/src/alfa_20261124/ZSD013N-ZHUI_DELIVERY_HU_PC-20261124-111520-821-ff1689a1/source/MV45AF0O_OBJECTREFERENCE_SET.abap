
************************************************************************
*         FORM OBJECTREFERENCE_WRITE                                   *
*----------------------------------------------------------------------*
* Übergeben der Objektreferenzdaten an den SAPMV45A vor dem Sichern    *
* aus dem Funktionsbaustein SD_SALES_DOCUMENT_SAVE                     *
************************************************************************
FORM OBJECTREFERENCE_SET TABLES US_ATTR_TAB  STRUCTURE BRELATTR
                         USING  US_VBAKKOM_REF.

     I_VBAKKOM_REF = US_VBAKKOM_REF.
     I_ATTR_TAB[]  = US_ATTR_TAB[].

ENDFORM.