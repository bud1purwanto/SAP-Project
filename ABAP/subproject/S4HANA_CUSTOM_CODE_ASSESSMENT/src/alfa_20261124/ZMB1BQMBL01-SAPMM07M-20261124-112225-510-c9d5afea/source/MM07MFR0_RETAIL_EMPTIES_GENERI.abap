*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_EMPTIES_GENERI                   *
*&---------------------------------------------------------------------*

* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  retail_struct_empties_generic
*----------------------------------------------------------------------*
*  Write down Retail-specific article structure infos for
*  afterwards consistence-checks in structure RSTRUCT.
*  You have to distinguish the different Retail article types
*  and the data-sources depending of the calling form. In this case
*  calling from bestellung_uebernehmen there could be empties
*  and generic articles.
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_EMPTIES_GENERIC USING P_EBELN P_UEBPO P_LFBNR.
   DATA: WA_RSTRUCT TYPE T_RSTRUCT.
   DATA: PRE_COND_OK   TYPE C.
   DATA: WA_FUSS LIKE FUSS.
   clear WA_RSTRUCT.

* *************************** testing preconditions
   PRE_COND_OK = SPACE.
   PERFORM RETAIL_STRUCT_PRECONDITIONS USING PRE_COND_OK.
   CHECK PRE_COND_OK = X.
* ***************************

*                            * extraction-struture is XEBEFU
   IF     DM07M-UPVOR = UPTYP_LG.
*                            * full item position
*                            * ***************************
       WA_RSTRUCT-MATNR    = XEBEFU-MATNR.
       WA_RSTRUCT-BSTME    = XEBEFU-BSTME.
       WA_RSTRUCT-ERFME    = XEBEFU-BSTME.
       WA_RSTRUCT-MATNRVOR = SPACE.
       WA_RSTRUCT-BSTMEVOR = SPACE.
       WA_RSTRUCT-ERFMEVOR = SPACE.
       WA_RSTRUCT-XAUTO    = SPACE.
       WA_RSTRUCT-UPTYP    = XEBEFU-UPTYP.
       WA_RSTRUCT-UPVOR    = XEBEFU-UPVOR.
       WA_RSTRUCT-ATTYP    = XEBEFU-ATTYP.
       wa_rstruct-shkzg    = fuss-shkzg.                    " 443478
       COLLECT WA_RSTRUCT INTO IT_RSTRUCT.

   ELSEIF DM07M-UPTYP = UPTYP_LG.
*                            * empties position
*                            * ***************************
*                            * searching prior head-position in FUSS
       CLEAR WA_FUSS.
       READ TABLE FUSS INTO WA_FUSS
             WITH KEY EBELN = P_EBELN
                      EBELP = P_UEBPO
                      LFBNR = P_LFBNR.
       IF NOT SY-SUBRC IS INITIAL.
*                            * head-position must be found
          MESSAGE E001 WITH 'FUSS' P_EBELN P_UEBPO P_LFBNR.
       ENDIF.

       WA_RSTRUCT-MATNR    = XEBEFU-MATNR.
       WA_RSTRUCT-BSTME    = XEBEFU-BSTME.
       WA_RSTRUCT-ERFME    = XEBEFU-BSTME.
       WA_RSTRUCT-MATNRVOR = WA_FUSS-MATNR.
       WA_RSTRUCT-BSTMEVOR = WA_FUSS-BSTME.
       WA_RSTRUCT-ERFMEVOR = WA_FUSS-BSTME.
       WA_RSTRUCT-XAUTO    = L.
       WA_RSTRUCT-UPTYP    = XEBEFU-UPTYP.
       WA_RSTRUCT-UPVOR    = XEBEFU-UPVOR.
       WA_RSTRUCT-ATTYP    = XEBEFU-ATTYP.
       wa_rstruct-shkzg    = wa_fuss-shkzg.                 " 443478
       COLLECT WA_RSTRUCT INTO IT_RSTRUCT.

   ELSEIF DM07M-UPVOR = UPTYP_VAR.
*                            * generic article head
*                            * ***************************
       WA_RSTRUCT-MATNR    = XEBEFU-MATNR.
       WA_RSTRUCT-BSTME    = XEBEFU-BSTME.
       WA_RSTRUCT-ERFME    = XEBEFU-BSTME.
       WA_RSTRUCT-MATNRVOR = SPACE.
       WA_RSTRUCT-BSTMEVOR = SPACE.
       WA_RSTRUCT-ERFMEVOR = SPACE.
       WA_RSTRUCT-XAUTO    = SPACE.
       WA_RSTRUCT-UPTYP    = XEBEFU-UPTYP.
       WA_RSTRUCT-UPVOR    = XEBEFU-UPVOR.
       WA_RSTRUCT-ATTYP    = XEBEFU-ATTYP.
       wa_rstruct-shkzg    = fuss-shkzg.                    " 443478
       COLLECT WA_RSTRUCT INTO IT_RSTRUCT.

   ELSEIF DM07M-UPTYP = UPTYP_VAR
    " AND NOT MSEG-URZEI IS INITIAL
      AND NOT MSEG-ZEILE = MSEG-URZEI.
*                            * generic article component
*                            * ***************************
*                            * searching prior head-position in FUSS
       CLEAR WA_FUSS.
       READ TABLE FUSS INTO WA_FUSS
             WITH KEY EBELN = P_EBELN
                      EBELP = P_UEBPO
                      LFBNR = P_LFBNR.
*                                                   * Begin note 373596
*      IF NOT SY-SUBRC IS INITIAL.
*                            * head-position must be found
*         MESSAGE E001 WITH 'FUSS' P_EBELN P_UEBPO P_LFBNR.
*      ENDIF.
*
*      WA_RSTRUCT-MATNR    = XEBEFU-MATNR.
*      WA_RSTRUCT-BSTME    = XEBEFU-BSTME.
*      WA_RSTRUCT-ERFME    = XEBEFU-BSTME.
*      WA_RSTRUCT-MATNRVOR = WA_FUSS-MATNR.
*      WA_RSTRUCT-BSTMEVOR = WA_FUSS-BSTME.
*      WA_RSTRUCT-ERFMEVOR = WA_FUSS-BSTME.
*      WA_RSTRUCT-XAUTO    = SPACE.
*      WA_RSTRUCT-UPTYP    = XEBEFU-UPTYP.
*      WA_RSTRUCT-UPVOR    = XEBEFU-UPVOR.
*      WA_RSTRUCT-ATTYP    = XEBEFU-ATTYP.
*      COLLECT WA_RSTRUCT INTO IT_RSTRUCT.

       IF SY-SUBRC IS INITIAL.
*                           * Head-position must NOT be found, because
*                           * GR can be done on several explict
*                           * positions without selecting the head.
*                           * Thus analysing of structure-data is only
*                           * meaningful if head can be found
          WA_RSTRUCT-MATNR    = XEBEFU-MATNR.
          WA_RSTRUCT-BSTME    = XEBEFU-BSTME.
          WA_RSTRUCT-ERFME    = XEBEFU-BSTME.
          WA_RSTRUCT-MATNRVOR = WA_FUSS-MATNR.
          WA_RSTRUCT-BSTMEVOR = WA_FUSS-BSTME.
          WA_RSTRUCT-ERFMEVOR = WA_FUSS-BSTME.
          WA_RSTRUCT-XAUTO    = SPACE.
          WA_RSTRUCT-UPTYP    = XEBEFU-UPTYP.
          WA_RSTRUCT-UPVOR    = XEBEFU-UPVOR.
          WA_RSTRUCT-ATTYP    = XEBEFU-ATTYP.
          wa_rstruct-shkzg    = wa_fuss-shkzg.              " 443478
          COLLECT WA_RSTRUCT INTO IT_RSTRUCT.
       ENDIF.
*                                                   * End  note 373596
   ENDIF.

  FREE WA_RSTRUCT.
ENDFORM.                    " RETAIL_STRUCT_EMPTIES_GENERIC
* *************************************************** Begin Note 328675