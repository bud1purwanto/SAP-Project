***INCLUDE MV45AFZ4 .

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
*       FORM USEREXIT_MOVE_FIELD_TO_KOMK                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for free goods.                        *
*                                                                     *
*       This form is called from form FV45PF0K_KOMK_KOMP_FUELLEN.     *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMK.

*  KOMK-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMP                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for free goods.                        *
*                                                                     *
*       This form is called from form FV45PF0K_KOMK_KOMP_FUELLEN.     *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMP.

*  KOMP-zzfield = xxxx-zzfield2.

ENDFORM.
*eject