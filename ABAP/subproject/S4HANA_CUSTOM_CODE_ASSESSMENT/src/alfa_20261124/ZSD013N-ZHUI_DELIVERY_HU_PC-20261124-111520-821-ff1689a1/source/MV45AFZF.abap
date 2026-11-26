***INCLUDE MV45AFZF.


************************************************************************
*                                                                      *
* This include is reserved for user modifications                      *
* Forms for sales document processing                                  *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       FORM USEREXIT_AVAIL_CHECK_CREDIT                              *
*---------------------------------------------------------------------*
*       This userexit can be used, to determine, if an                *
*       availibility check should be carried out at release or recheck*
*       of credit blocked orders. This routine is called per          *
*       item line.                                                    *
*       Set CH_CHECK !                                                *
*---------------------------------------------------------------------*
*  -->  US_VBAK     Header information                                *
*  -->  US_VBUK     Header status information                         *
*  -->  US_VBAP     Item line information                             *
*  -->  US_RELEASE  at release ('X')                                  *
*  -->  US_RECHECK  at recheck ('X')                                  *
*  <--  CH_CHECK    0 = check                                         *
*                   4 = processing like standard                      *
*                   8 = no check                                      *
*---------------------------------------------------------------------*
FORM USEREXIT_AVAIL_CHECK_CREDIT USING    US_VBAK STRUCTURE VBAK
                                          US_VBUK STRUCTURE VBUKVB
                                          US_VBAP STRUCTURE VBAPVB
                                          US_RELEASE
                                          US_RECHECK
                                 CHANGING CH_CHECK.
  DATA: CON_CHECK_STANDARD LIKE SY-SUBRC VALUE 4,
        CON_CHECK_NO       LIKE SY-SUBRC VALUE 8,
        CON_CHECK_YES      LIKE SY-SUBRC VALUE 0.
*
  CH_CHECK = CON_CHECK_STANDARD.
* CH_CHECK = CON_CHECK_NO.
* CH_CHECK = CON_CHECK_YES.
ENDFORM.

*---------------------------------------------------------------------*
*      Form  userexit_configuration_mode                              *
*---------------------------------------------------------------------*
*      This userexit can be used to determine the mode which is       *
*      used for the variant configuration. Basically, there are       *
*      two modes available.                                           *
*      1. CREATE and CHANGE mode                                      *
*      2. DISPLAY mode                                                *
*                                                                     *
*      This userexit should only be used to achieve a more restric-   *
*      tive logic regarding the question 'Until when is it allowed    *
*      to change the configuration data of a line item ?'. This       *
*      means you should only change the mode from CREATE/CHANGE to    *
*      DISPLAY and not vice versa.                                    *
*                                                                     *
*      This form is called from CONFIGURATION_PROCESSING              *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CONFIGURATION_MODE CHANGING CH_DISPLAY.

* Example

* user status 01 is set
*  if vbuk-uvk01 eq chara.
*    ch_display = charx.
*  endif.

ENDFORM.
*eject