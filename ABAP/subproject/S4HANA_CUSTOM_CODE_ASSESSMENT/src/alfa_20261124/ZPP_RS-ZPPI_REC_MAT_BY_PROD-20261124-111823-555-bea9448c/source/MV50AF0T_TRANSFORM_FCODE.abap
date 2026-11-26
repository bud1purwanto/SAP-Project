*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRANSFORM_FCODE                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TRANSFORM_FCODE
*&---------------------------------------------------------------------*
*       FCODE is transformed to the FCODE compatible with the new
*       dialog (suffix _T)
*----------------------------------------------------------------------*
FORM TRANSFORM_FCODE CHANGING CF_FCODE TYPE FCODE.

* Do nothing if suffix is already appended
  CHECK CF_FCODE NS '_T'.

* Transform FCODE only if new dialog is active
  CHECK T180-BLDGR EQ GC_NEW_DIALOG_INB OR
        T180-BLDGR EQ GC_NEW_DIALOG_OUTB.

  CONCATENATE CF_FCODE '_T' INTO CF_FCODE.

ENDFORM.                               " TRANSFORM_FCODE















