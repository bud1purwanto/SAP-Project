***INCLUDE MV45AFZD.

************************************************************************
*                                                                      *
* This include is reserved for user modifications                      *
*                                                                      *
* Forms for sales document processing                                  *
*                                                                      *
* The name of modification modules should begin with 'ZZ'.             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*      Form  userexit_config_date_explosion                           *
*---------------------------------------------------------------------*
*      This userexit can be used to determine the BoM explosion date  *
*      that is used for the variant configuration.                    *
*                                                                     *
*      This form is called from CONFIGURATION_DATE_EXPLOSION          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CONFIG_DATE_EXPLOSION USING CH_MBDAT.

* Example

*  CH_MBDAT = XVBKD-PRDAT.

ENDFORM.
*eject