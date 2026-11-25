***INCLUDE MV45AFZZ .

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
*       when a sales document is deleted.                             *
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
*       FORM USEREXIT_FIELD_MODIFICATION                              *
*---------------------------------------------------------------------*
*       This userexit can be used to modify the attributes of         *
*       screen fields.                                                *
*       This form is processed for each field in the screen.          *
*                                                                     *
*       The use of the fields screen-group1 to screen-group4 is:      *
*                                                                     *
*       Screen-group1: Automatic modification contolles by transaction*
*                      MFAW.                                          *
*       Screen-group2: Contents 'LOO' for steploop-fields.            *
*       Screen-group3: Used for modififaction, which are dependent on *
*                      control tables or other fix information.       *
*       Screen-group4: Unused                                         *
*                                                                     *
*       For field mofifications, which are dependent on the document  *
*       status, you can use the status field in the workareas         *
*       XVBAP for item status and XVBUK for header status.            *
*                                                                     *
*       This form is called from module FELDAUSWAHL.                  *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_FIELD_MODIFICATION.

* CASE SCREEN-GROUP3.
*   WHEN '900'.
*     IF VBAK-VBTYP NE 'A'.
*       SCREEN-ACTIVE = 0.
*     ENDIF.
* ENDCASE.

* CASE SCREEN-NAME.
*   WHEN 'VBAK-VBELN'.
*     SCREEN-ACTIVE = 0.
* ENDCASE.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_VBAK                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the sales  *
*       dokument header workaerea VBAK.                               *
*                                                                     *
*       SVBAK-TABIX = 0:  Create header                               *
*       SVBAK-TABIX > 0:  Change header                               *
*                                                                     *
*       This form is called at the end of form VBAK_FUELLEN.          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBAK.

*  vbak-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_VBAP                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the sales  *
*       dokument item workaerea VBAP                                  *
*                                                                     *
*       SVBAP-TABIX = 0:  Create item                                 *
*       SVBAP-TABIX > 0:  Change item                                 *
*                                                                     *
*       This form is called at the end of form VBAP_FUELLEN.          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBAP.

*  VBAP-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_VBEP                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the sales  *
*       dokument schedule line workaerea VBEP                         *
*                                                                     *
*       SVBEP-TABIX = 0:  Create schedule line                        *
*       SVBEP-TABIX > 0:  Change schedule line                        *
*                                                                     *
*       This form is called at the end of form VBEP_FUELLEN.          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBEP.

*  VBEP-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_VBKD                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the sales  *
*       dokument business data workaerea VBKD                         *
*                                                                     *
*       SVBKD-TABIX = 0:  Create data                                 *
*       SVBKD-TABIX > 0:  Change data                                 *
*                                                                     *
*       This form is called at the end of form VBKD_FUELLEN.          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBKD.

*  VBKD-zzfield = xxxx-zzfield2.

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

* Example: Numer range from TVAK like in standard
* US_RANGE_INTERN = TVAK-NUMKI.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_PRICING_PREPARE_TKOMK                           *
*---------------------------------------------------------------------*
*       This userexit can be used to move additional fields into the  *
*       communication table which is used for pricing:                *
*                                                                     *
*       TKOMK for header fields                                       *
*                                                                     *
*       This form is called from form PREISFINDUNG_VORBEREITEN.       *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_PRICING_PREPARE_TKOMK.

*  TKOMK-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_PRICING_PREPARE_TKOMP                           *
*---------------------------------------------------------------------*
*       This userexit can be used to move additional fields into the  *
*       communication table which is used for pricing:                *
*                                                                     *
*       TKOMP for item fields                                         *
*                                                                     *
*       This form is called from form PREISFINDUNG_VORBEREITEN.       *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_PRICING_PREPARE_TKOMP.

*  TKOMP-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_READ_DOCUMENT                                   *
*---------------------------------------------------------------------*
*       This userexit can be used to read data in additional tables   *
*       when the program reads a sales document.                      *
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
