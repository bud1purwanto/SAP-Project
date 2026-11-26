*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_COPY_YMSEG                       *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  retail_struct_copy_YMSEG
*----------------------------------------------------------------------*
*  IT_XYMSEG is a temporary reflection of YMSEG with relevant fields
*  for the hunt for Retail-structures in the remaining GR-lines
*  befor using buchen_ausfuehren
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_COPY_YMSEG.
   DATA: WA_XYMSEG TYPE T_XYMSEG.

   REFRESH IT_XYMSEG.

   LOOP AT YMSEG.
      WA_XYMSEG-MATNR  = YMSEG-MATNR.
      WA_XYMSEG-BSTME  = YMSEG-BSTME.
      WA_XYMSEG-ERFME  = YMSEG-ERFME.
      WA_XYMSEG-XAUTO  = YMSEG-XAUTO.
      WA_XYMSEG-EBELN  = YMSEG-EBELN.
      WA_XYMSEG-EBELP  = YMSEG-EBELP.
      WA_XYMSEG-LFBNR  = YMSEG-LFBNR.
      WA_XYMSEG-ZEILE  = YMSEG-ZEILE.
      WA_XYMSEG-URZEI  = YMSEG-URZEI.
      WA_XYMSEG-ERFMG  = YMSEG-ERFMG.
*                          * lines with erfmg = 0 should be OK
      IF WA_XYMSEG-ERFMG IS INITIAL.
         WA_XYMSEG-KZOK = X.
      ELSE.
         WA_XYMSEG-KZOK   = SPACE.
      ENDIF.
      APPEND WA_XYMSEG TO IT_XYMSEG.
   ENDLOOP.
ENDFORM.                    "RETAIL_STRUCT_COPY_XMSEG
* *************************************************** END   Note 328675