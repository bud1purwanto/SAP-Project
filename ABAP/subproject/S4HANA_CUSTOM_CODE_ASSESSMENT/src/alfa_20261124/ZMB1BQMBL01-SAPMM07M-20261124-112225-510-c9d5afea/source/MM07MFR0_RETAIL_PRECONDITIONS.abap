*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_PRECONDITIONS                    *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  RETAIL_STRUCT_PRECONDITIONS
*----------------------------------------------------------------------*
*  The testing of the Retail-structure can be used in specific
*  situations.
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_PRECONDITIONS USING PRE_COND_OK TYPE C.

   CLEAR PRE_COND_OK.
*                           * Checklist:
*                           * - GR for PO
*  CHECK XMBWL IS INITIAL.                               " note 356129
   CHECK T158-KZBEW = B OR T158-KZBEW = L.               " note 356129
   CHECK T158-KZBEW = B. "OR T158-KZBEW = L.             " note 460054
*  neglect delivery for simplicity reasons               " note 460054
*                           * Preconditions are OK
   PRE_COND_OK = X.
ENDFORM.                   " RETAIL_STRUCT_PRECONDITIONS
* *************************************************** END   Note 328675