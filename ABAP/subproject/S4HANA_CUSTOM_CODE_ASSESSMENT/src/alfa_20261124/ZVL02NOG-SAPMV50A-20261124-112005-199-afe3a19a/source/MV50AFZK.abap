*----------------------------------------------------------------------*
*   INCLUDE MV50AFZK                                                   *
*----------------------------------------------------------------------*
*
* The userexits in this include can be used to fill the condition tables
* for material listing and material exclusion (KOMKG and KOMPG) and
* product selection (KOMKD and KOMPD) with own data. They supplement the
* userexits
*
* USEREXIT_MOVE_FIELD_TO_KOMKD
* USEREXIT_MOVE_FIELD_TO_KOMPD
* USEREXIT_MOVE_FIELD_TO_KOMKG
* USEREXIT_MOVE_FIELD_TO_KOMPG
*
* in program MV45AFZA which are called during sales order processing.
* These form routines can not be called during delivery processing since
* they refer to a different main program.

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMKD                             *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for product substitution.              *
*                                                                     *
*       This form is called from form KOMKD_KOMPD_FUELLEN.            *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMKD.

*  KOMKD-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMPD                             *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for product substitution.              *
*                                                                     *
*       This form is called from form KOMKD_KOMPD_FUELLEN.            *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMPD.

*  KOMPD-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMKG                             *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for product listing or exclusion.      *
*                                                                     *
*       This form is called from form KOMKG_KOMPG_FUELLEN.            *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMKG.

*  KOMKG-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMPG                             *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for product listing or exclusion.      *
*                                                                     *
*       This form is called from form KOMKG_KOMPG_FUELLEN.            *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMPG.

*  KOMPG-zzfield = xxxx-zzfield2.

ENDFORM.
*eject


