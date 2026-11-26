*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_GET_YMSEG                       *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 356129
*----------------------------------------------------------------------*
*       Form  retail_struct_GET_YMSEG
*----------------------------------------------------------------------*
*  IT_XYMSEG is a temporary reflection of YMSEG with relevant fields
*  for the hunt for Retail-structures in the remaining GR-lines
*  befor using buchen_ausfuehren
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_GET_YMSEG.
   DATA: WA_XYMSEG TYPE T_XYMSEG.
   DATA: WA_YVM07M LIKE VM07M.                                 " 424154
   data: wa_ydm07m like dm07m.                                 " 454005

   REFRESH IT_XYMSEG.

   LOOP AT YMSEG.
      WA_XYMSEG-MATNR  = YMSEG-MATNR.
      WA_XYMSEG-BSTME  = YMSEG-BSTME.
*                           * tell me whether you are a        " 424154
*                           * structured article header        " 424154
*                           * or not.                          " 424154
      WA_YVM07M-ZEILV = YMSEG-ZEILE.                           " 424154
      READ TABLE YVM07M INTO WA_YVM07M                         " 424154
           WITH KEY ZEILV = WA_YVM07M-ZEILV.                   " 424154
      IF NOT SY-SUBRC IS INITIAL.                              " 424154
         MESSAGE E001 WITH 'YVM07M' YMSEG-ZEILE.               " 424154
      ENDIF.                                                   " 424154
      WA_YdM07M-ZEILd = YMSEG-ZEILE.                           " 454005
      READ TABLE YdM07M INTO WA_YdM07M                         " 454005
           WITH KEY ZEILd = WA_YdM07M-ZEILd.                   " 454005
      IF NOT SY-SUBRC IS INITIAL.                              " 454005
         MESSAGE E001 WITH 'YdM07M' YMSEG-ZEILE.               " 454005
      ENDIF.                                                   " 454005
*                           * not copys for structured articles" 424154
      IF WA_XYMSEG-BSTME IS INITIAL                            " 403468
         AND NOT (  WA_YVM07M-ATTYP = '10'                     " 424154
                 OR WA_YVM07M-ATTYP = '11'                     " 424154
                 OR WA_YVM07M-ATTYP = '12'                     " 424154
                 )                                             " 424154
         AND NOT YMSEG-XAUTO = 'S'.                            " 403468
         WA_XYMSEG-BSTME  = YMSEG-ERFME.                       " 403468
      ENDIF.                                                   " 403468
*                           * get out if coming from delivery and
*                           * full product or tied empty       " 454005
*                           * (necessary cause VL02 doesn't hit
*                           * MB_CREATE_STRUCT... where it_rstruct gets
*                           * built for tied empties)          " 454005
*                           * Attention: full product from sender has
*                           * no upvor, but gets set KZOK = X later on!
      if ( wa_ydm07m-upvor = uptyp_lg or                       " 454005
           wa_ydm07m-uptyp = uptyp_lg )                        " 454005
         and t158-kzbew = L.                                   " 454005
         continue.                                             " 454005
      endif.                                                   " 454005
      WA_XYMSEG-ERFME  = YMSEG-ERFME.
      WA_XYMSEG-XAUTO  = YMSEG-XAUTO.
      WA_XYMSEG-EBELN  = YMSEG-EBELN.
      WA_XYMSEG-EBELP  = YMSEG-EBELP.
      WA_XYMSEG-LFBNR  = YMSEG-LFBNR.
      WA_XYMSEG-ZEILE  = YMSEG-ZEILE.
      WA_XYMSEG-URZEI  = YMSEG-URZEI.
      wa_xymseg-shkzg  = ymseg-shkzg.                          " 443478
      WA_XYMSEG-ERFMG  = YMSEG-ERFMG.
      WA_XYMSEG-ATTYP  = WA_YVM07M-ATTYP.                      " 454005
*                           * lines with erfmg = 0 should be OK
*                           * as well as standard-materials or
*                           * not connected items  (such as headers)
      IF WA_XYMSEG-ERFMG IS INITIAL
         OR ( WA_XYMSEG-XAUTO IS INITIAL
              AND ( WA_XYMSEG-URZEI IS INITIAL
                    OR WA_XYMSEG-URZEI = WA_XYMSEG-ZEILE )
            ).
         WA_XYMSEG-KZOK = X.
      ELSE.
         WA_XYMSEG-KZOK   = SPACE.
      ENDIF.
      APPEND WA_XYMSEG TO IT_XYMSEG.
   ENDLOOP.
ENDFORM.                    "RETAIL_STRUCT_GET_YMSEG
* *************************************************** END   Note 356129