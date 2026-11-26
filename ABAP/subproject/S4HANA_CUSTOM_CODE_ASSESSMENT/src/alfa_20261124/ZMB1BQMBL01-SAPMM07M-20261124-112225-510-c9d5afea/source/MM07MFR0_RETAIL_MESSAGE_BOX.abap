*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_MESSAGE_BOX                      *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*---------------------------------------------------------------------*
*       FORM RETAIL_STRUCT_MESSAGE_BOX
*---------------------------------------------------------------------*
*  Informing the user that there is a problem with a position that
*  can't correct in usual manner. So he can correct it by confirming
*  the question
*---------------------------------------------------------------------*
FORM RETAIL_STRUCT_MESSAGE_BOX USING LINE_XYMSEG LIKE SY-TABIX
                                     HEADER      LIKE MSEG-ZEILE
                                     ARTICLE     LIKE MSEG-MATNR
                                     LINE        LIKE MSEG-ZEILE
                                     XAUTO_COMP  LIKE MSEG-XAUTO
                                     KZ_YMSEG    TYPE C.

   DATA: SEP(3)     VALUE ' / ',
         RT2(30)    TYPE C.
   DATA: WA_XYMSEG  TYPE T_XYMSEG.

   CLEAR: CONFIRM.

   CONCATENATE LINE ARTICLE INTO RT2 SEPARATED BY SEP.

*                                                   " begin note 356129
*                           * for dialog function use a popup
   IF XMBWL IS INITIAL.
*                                                   " End   note 356129
   CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
                  EXPORTING DEFAULTOPTION = N
                            DIAGNOSETEXT1 = TEXT-RT1
                            DIAGNOSETEXT2 = RT2
                            TEXTLINE1     = TEXT-RT3
                            TITEL         = TEXT-RT4
                  IMPORTING ANSWER        = CONFIRM.
   CASE CONFIRM.
     WHEN J.
*                            * strike out position by using erfmg = 0
       PERFORM RETAIL_STRUCT_DEL USING LINE_XYMSEG
                                          XAUTO_COMP
                                          KZ_YMSEG.
*                 * Erfassmenge der Komponenten zu ... zurückgesetzt
         MESSAGE W366 WITH LINE ARTICLE.
     WHEN OTHERS.
*                           * refresh mark on actual line because
*                           * seen error not corrected yet
         READ TABLE IT_XYMSEG INTO WA_XYMSEG INDEX LINE_XYMSEG.
         IF  SY-SUBRC IS INITIAL.
            WA_XYMSEG-KZOK  = SPACE.
            MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.
         ENDIF.
*                           * ignoring the automatic strike out
*                           * the Switch KZ_OK keeps value W
         MESSAGE W367.
   ENDCASE.
*                                                   " begin note 356129
   ELSE.
*                           * for mb_create define consistency,
*                           * strike out position by using erfmg = 0
      PERFORM RETAIL_STRUCT_DEL USING LINE_XYMSEG
                                      XAUTO_COMP
                                      KZ_YMSEG.
*                           * But is hard to define meaningfull
*                           * informations for the errormessage because
*                           * only header-information is interesting.
*                           * So what is the right header to put it in
*                           * a message
      READ TABLE IT_XYMSEG INTO WA_XYMSEG INDEX LINE_XYMSEG.
      IF  SY-SUBRC IS INITIAL.
*                           * standing on a component or header
         IF NOT WA_XYMSEG-URZEI IS INITIAL.
            HEADER = WA_XYMSEG-URZEI.
            READ TABLE IT_XYMSEG INTO WA_XYMSEG WITH KEY ZEILE = HEADER
                                                         XAUTO = SPACE.
            IF  SY-SUBRC IS INITIAL.
*                           * material-numer of the header is found
               ARTICLE = WA_XYMSEG-MATNR.
            ENDIF.
         ENDIF.
      ENDIF.
*                 * fault in the structure for material ... found
      MESSAGE E368 WITH ARTICLE.
   ENDIF.
*                                                   " End   note 356129
ENDFORM.
* *************************************************** END   Note 328675