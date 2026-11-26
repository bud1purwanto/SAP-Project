*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_ARTICLES                         *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  retail_struct_articles
*----------------------------------------------------------------------*
*  Write down Retail-specific article structure infos for
*  afterwards consistence-checks in structure RSTRUCT.
*  You need to distinguish the different Retail article types
*  and the data-sources depending of the calling form. Calling
*  STRUKT_MATERIAL_VORBEREITEN only structured articles will be
*  processed
*----------------------------------------------------------------------*
* ymseg = bwart_matnr____zeile_urzei_xauto_bstme_ebelp_ebeln______erfme
* ymseg = 101__|FJJSET01_0001_|0001_|_____|ST___|00010|4500014721|ST__
* ymseg = 319__|FJJSET01_0002_|0001_|S____|_____|00000|__________|ST__
* ymseg = 319__|FJ01_____0003_|0001_|S____|_____|00000|__________|ST__
* ymseg = 319__|FJ02_____0004_|0001_|S____|_____|00000|__________|ST__
* ymseg = 101__|FJ02_____0005_|0005_|_____|ST___|00020|4500014721|ST__
* ymseg = 101__|FJJSET01_0006_|0006_|_____|ST___|00030|4500014721|ST__
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_ARTICLES.
   DATA: WA_RSTRUCT TYPE T_RSTRUCT.
   DATA: WA_YMSEG LIKE MSEG.
   CLEAR WA_RSTRUCT.
   DATA: PRE_COND_OK   TYPE C.

* *************************** testing preconditions
   PRE_COND_OK = SPACE.
   PERFORM RETAIL_STRUCT_PRECONDITIONS USING PRE_COND_OK.
   CHECK PRE_COND_OK = X.
* ***************************
*                            * ***************************
*                            * after structure_article_get
*                            * ***************************
    IF ( VM07M-ATTYP = ATTYP-VKS  OR  VM07M-ATTYP = ATTYP-LOT  OR
         VM07M-ATTYP = ATTYP-DIS ) AND MSEG-XAUTO = S.
*                           * structured article head
*                           * ***************************
        READ TABLE YMSEG INTO WA_YMSEG
              WITH KEY ZEILE = MSEG-URZEI
                       MATNR = MSEG-MATNR.
        IF NOT SY-SUBRC IS INITIAL.
*                            * head-position must be found
           MESSAGE E001 WITH 'YMSEG' mseg-matnr mseg-urzei.
        ENDIF.
*                            * ORIGINAL LINE
        WA_RSTRUCT-MATNR    = WA_YMSEG-MATNR.
        WA_RSTRUCT-BSTME    = WA_YMSEG-BSTME.
        WA_RSTRUCT-ERFME    = WA_YMSEG-ERFME.
        WA_RSTRUCT-MATNRVOR = SPACE.
        WA_RSTRUCT-BSTMEVOR = SPACE.
        WA_RSTRUCT-ERFMEVOR = SPACE.
        WA_RSTRUCT-XAUTO    = SPACE.
        WA_RSTRUCT-UPTYP    = DM07M-UPTYP.
        WA_RSTRUCT-UPVOR    = DM07M-UPVOR.
        WA_RSTRUCT-ATTYP    = VM07M-ATTYP.
        wa_rstruct-shkzg    = wa_ymseg-shkzg.                  " 443478
        COLLECT WA_RSTRUCT INTO IT_RSTRUCT.
*                            * header of structure
        WA_RSTRUCT-MATNR    = MSEG-MATNR.
        WA_RSTRUCT-BSTME    = MSEG-BSTME.
        WA_RSTRUCT-ERFME    = MSEG-ERFME.
        WA_RSTRUCT-MATNRVOR = WA_YMSEG-MATNR.
        WA_RSTRUCT-BSTMEVOR = WA_YMSEG-BSTME.
        WA_RSTRUCT-ERFMEVOR = WA_YMSEG-ERFME.
        WA_RSTRUCT-XAUTO    = S.
        WA_RSTRUCT-UPTYP    = DM07M-UPTYP.
        WA_RSTRUCT-UPVOR    = DM07M-UPVOR.
        WA_RSTRUCT-ATTYP    = VM07M-ATTYP.
        wa_rstruct-shkzg    = mseg-shkzg.                      " 443478
        COLLECT WA_RSTRUCT INTO IT_RSTRUCT.

    ELSEIF MSEG-XAUTO = S.
*                           * structured article component
*                           * ***************************
        READ TABLE YMSEG INTO WA_YMSEG
              WITH KEY ZEILE = MSEG-URZEI.
        IF NOT SY-SUBRC IS INITIAL.
*                            * head-position must be found
           MESSAGE E001 WITH 'YMSEG' mseg-urzei.
        ENDIF.
        WA_RSTRUCT-MATNR    = MSEG-MATNR.
        WA_RSTRUCT-BSTME    = MSEG-BSTME.
        WA_RSTRUCT-ERFME    = MSEG-ERFME.
        WA_RSTRUCT-MATNRVOR = WA_YMSEG-MATNR.
        WA_RSTRUCT-BSTMEVOR = WA_YMSEG-BSTME.
        WA_RSTRUCT-ERFMEVOR = WA_YMSEG-ERFME.
        WA_RSTRUCT-XAUTO    = S.
        WA_RSTRUCT-UPTYP    = DM07M-UPTYP.
        WA_RSTRUCT-UPVOR    = DM07M-UPVOR.
        WA_RSTRUCT-ATTYP    = VM07M-ATTYP.
        COLLECT WA_RSTRUCT INTO IT_RSTRUCT.
    ENDIF.

    FREE WA_RSTRUCT.
    FREE WA_YMSEG.
ENDFORM.                    " RETAIL_STRUCT_ARTICLES
* *************************************************** END   Note 328675