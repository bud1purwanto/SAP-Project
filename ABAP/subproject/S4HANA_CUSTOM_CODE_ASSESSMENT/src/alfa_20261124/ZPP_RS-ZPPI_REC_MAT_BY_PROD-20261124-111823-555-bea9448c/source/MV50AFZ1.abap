***INCLUDE MV50AFZ1 .

************************************************************************
*                                                                      *
* This include is reserved for user modifications                      *
*                                                                      *
* Forms for delivery processing                                        *
*                                                                      *
* The name of modification modules should begin with 'ZZ'.             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       FORM ZZEXAMPLE                                                *
*---------------------------------------------------------------------*
*       text......................................                    *
*---------------------------------------------------------------------*
*FORM ZZEXAMPLE.

*  ...

*ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM USEREXIT_DELETE_DOCUMENT                                 *
*---------------------------------------------------------------------*
*       This userexit can be used to delete data in additional tables *
*       when a delivery is deleted.                                   *
*                                                                     *
*      This form is called in dialog at the end of form BELEG_LOESCHEN*
*      just before form BELEG_SICHERN is performed to delete the      *
*      datas on the database.                                         *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_DELETE_DOCUMENT.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_LIKP                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       delivery header workaerea LIKP.                               *
*       This form is called, when a header is created                 *
*       This form is called at the end of form LIKP_FUELLEN.          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_LIKP.

*  LIKP-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_LIPS                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       delivery item workaerea LIPS                                  *
*       This form is called, when an item is created                  *
*                                                                     *
*                                                                     *
*       This form is called at the end of form LIPS_FUELLEN.          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_LIPS.

*  LIPS-zzfield = xxxx-zzfield2.

ENDFORM.
*eject


*---------------------------------------------------------------------*
*       FORM USEREXIT_NUMBER_RANGE                                    *
*---------------------------------------------------------------------*
*       This userexit can be used to determine the numberranges for   *
*       the internal document number.                                 *
*                                                                     *
*       US_RANGE_INTERN - internal number range                       *
*                                                                     *
*       This form is called from form BELEG_SICHERN                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_NUMBER_RANGE USING US_RANGE_INTERN.

* Example: Numer range from TVLK like in standard
* US_RANGE_INTERN = TVLK-NUMKI.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_READ_DOCUMENT                                   *
*---------------------------------------------------------------------*
*       This userexit can be used to read data in additional tables   *
*       when the program reads a delivery.                            *
*                                                                     *
*       This form is called at the end of form BELEG_LESEN.           *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_READ_DOCUMENT.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_SAVE_DOCUMENT                                   *
*---------------------------------------------------------------------*
*       This userexit can be used to save data in additional tables   *
*       when a document is saved.                                     *
*                                                                     *
*       If field T180-TRTYP contents 'H', the document will be        *
*       created, else it will be changed.                             *
*                                                                     *
*       This form is called at from form BELEG_SICHERN, before COMMIT *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_SAVE_DOCUMENT.

* Example:
* CALL FUNCTION 'ZZ_EXAMPLE'
*      IN UPDATE TASK
*      EXPORTING
*           ZZTAB = ZZTAB.

ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM USEREXIT_SAVE_DOCUMENT_PREPARE                           *
*---------------------------------------------------------------------*
*       This userexit can be used for changes or checks, before a     *
*       document is saved.                                            *
*                                                                     *
*       If field T180-TRTYP contents 'H', the document will be        *
*       created, else it will be changed.                             *
*                                                                     *
*       This form is called at the beginning of form BELEG_SICHERN    *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_SAVE_DOCUMENT_PREPARE.

ENDFORM.
*eject


*---------------------------------------------------------------------*
*       FORM USEREXIT_REFRESH_DOCUMENT                                *
*---------------------------------------------------------------------*
*       It is always necessary to refresh user-specific data before   *
*       the next document will be processed.                          *
*       This can be done in this userexit.                            *
*       This userexit can be used to refresh user-specific data       *
*       when the processing of a delivery is finished                 *
*       - after the document is saved                                 *
*       - when you leave the document processing with F3 or F15       *
*       It may be necessary to refresh user-specific data before      *
*       the next document will be processed.                          *
*                                                                     *
*      This form is called in dialog at the end of form               *
*      BELEG_INITIALISIEREN                                           *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_REFRESH_DOCUMENT.

* clear: ZZ50A.
* refresh: zzitemtab.

ENDFORM.
*eject