*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_COPY_XMSEG                       *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  retail_struct_copy_xmseg
*----------------------------------------------------------------------*
*  IT_XYMSEG is a temporary reflection of XMSEG with relevant fields
*  for the hunt for Retail-structures in the remaining GR-lines
*  befor using buchen_ausfuehren
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_COPY_XMSEG.
   DATA: WA_XYMSEG TYPE T_XYMSEG.

   REFRESH IT_XYMSEG.

   LOOP AT XMSEG.
      WA_XYMSEG-MATNR  = XMSEG-MATNR.
      WA_XYMSEG-BSTME  = XMSEG-BSTME.
      WA_XYMSEG-ERFME  = XMSEG-ERFME.
      WA_XYMSEG-XAUTO  = XMSEG-XAUTO.
      WA_XYMSEG-EBELN  = XMSEG-EBELN.
      WA_XYMSEG-EBELP  = XMSEG-EBELP.
      WA_XYMSEG-LFBNR  = XMSEG-LFBNR.
      WA_XYMSEG-ZEILE  = XMSEG-ZEILE.
      WA_XYMSEG-URZEI  = XMSEG-URZEI.
      WA_XYMSEG-ERFMG  = XMSEG-ERFMG.
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