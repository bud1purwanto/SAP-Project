FUNCTION ZMM_CHARACTERISTIC_MKG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(GLOBALS) LIKE  CUOV_00 STRUCTURE  CUOV_00
*"  TABLES
*"      MATCH STRUCTURE  CUOV_01
*"      QUERY STRUCTURE  CUOV_01
*"  EXCEPTIONS
*"      FAIL
*"      INTERNAL_ERROR
*"----------------------------------------------------------------------

  DATA: VALUE1 LIKE CUOV_01-ATFLV,
        VALUE2 LIKE CUOV_01-ATFLV,
        VALUE3 LIKE CALE-ABSDATE,
        VALUE4 LIKE CALE-ABSDATE,
        VALUE3_NUM LIKE CUOV_01-ATFLV,
        VALUE4_NUM LIKE CUOV_01-ATFLV,
        I_VALUE TYPE F,
        O_VALUE TYPE F.

  CALL FUNCTION'CUOV_GET_FUNCTION_ARGUMENT'
    EXPORTING
        ARGUMENT = 'ZZPEMBILANGASAL'
    IMPORTING
        NUM_VAL = VALUE1
    TABLES
        QUERY = QUERY
    EXCEPTIONS
        ARG_NOT_FOUND = 01.

  IF SY-SUBRC <> 0.
    RAISE INTERNAL_ERROR.
  ENDIF.

  CALL FUNCTION'CUOV_GET_FUNCTION_ARGUMENT'
    EXPORTING
        ARGUMENT = 'ZZPENYEBUTASAL'
    IMPORTING
        NUM_VAL = VALUE2
    TABLES
        QUERY = QUERY
    EXCEPTIONS
        ARG_NOT_FOUND = 01.

  IF SY-SUBRC <> 0.
    RAISE INTERNAL_ERROR.
  ENDIF.

  I_VALUE = VALUE1 / VALUE2.

  CALL FUNCTION 'Z_MMUR_ROUND_FOR_FRACT5'
   EXPORTING
     I_VALUE               = I_VALUE
     I_DECIMALS            = 2
   IMPORTING
     O_NOMINATOR           = VALUE3
     O_DENOMINATOR         = VALUE4
     O_VALUE               = O_VALUE
*     O_VALUE_CHANGED       =
   EXCEPTIONS
     INPUT_INVALID         = 1
     OUTPUT_INVALID        = 2
     OVERFLOW              = 3
     OTHERS                = 4
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

*  CALL FUNCTION 'CONVERT_TO_FRACT5'
*    EXPORTING
*      NOMIN               = VALUE1
*      DENOMIN             = VALUE2
*    IMPORTING
*      NOMOUT              = VALUE3
*      DENOMOUT            = VALUE4
*    EXCEPTIONS
*      CONVERSION_OVERFLOW = 1
*      OTHERS              = 2.
*  IF SY-SUBRC <> 0.
*    RAISE INTERNAL_ERROR.
*  ENDIF.

  MOVE VALUE3 TO VALUE3_NUM.
  MOVE VALUE4 TO VALUE4_NUM.

  CALL FUNCTION 'CUOV_SET_FUNCTION_ARGUMENT'
    EXPORTING
      ARGUMENT                = 'ZZPEMBILANGBARU'
      NUM_VAL                 = VALUE3_NUM
      VTYPE                   = 'NUM'
    TABLES
      MATCH                   = MATCH
    EXCEPTIONS
      EXISTING_VALUE_REPLACED = 01.

  CALL FUNCTION 'CUOV_SET_FUNCTION_ARGUMENT'
    EXPORTING
      ARGUMENT                = 'ZZPENYEBUTBARU'
      NUM_VAL                 = VALUE4_NUM
      VTYPE                   = 'NUM'
    TABLES
      MATCH                   = MATCH
    EXCEPTIONS
      EXISTING_VALUE_REPLACED = 01.

ENDFUNCTION.