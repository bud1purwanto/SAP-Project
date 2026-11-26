*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_DEL_XYMSEG                       *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  RETAIL_STRUCT_DEL_XYMSEG
*----------------------------------------------------------------------*
*  so strike out in orginial tables;
*  but you have to distinguish between working on Y- or XMSEG
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_DEL_XYMSEG USING TABIX LIKE SY-TABIX
                                       KZ_YMSEG TYPE C.
   DATA: WA_XYMSEG LIKE XMSEG.

*                           * working on YMSEG or XMSEG
   IF NOT KZ_YMSEG IS INITIAL.
     READ TABLE YMSEG INTO WA_XYMSEG INDEX TABIX.     "YMSEG
     WA_XYMSEG-XAUTO = D.                             "YMSEG
     WA_XYMSEG-ERFMG = 0.                             "YMSEG
     WA_XYMSEG-ELIKZ = SPACE.                         "YMSEG
     MODIFY YMSEG INDEX SY-TABIX FROM WA_XYMSEG.      "YMSEG
   ELSE.
     READ TABLE XMSEG INTO WA_XYMSEG INDEX TABIX.     "XMSEG
     WA_XYMSEG-ERFMG = 0.                             "XMSEG
     WA_XYMSEG-ELIKZ = SPACE.                         "XMSEG
     MODIFY XMSEG INDEX SY-TABIX FROM WA_XYMSEG.      "XMSEG
   ENDIF.
ENDFORM.
* *************************************************** END   Note 328675