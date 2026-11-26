*----------------------------------------------------------------------*
*   INCLUDE LMIGOKN1                                                   *
*----------------------------------------------------------------------*
* METHOD NAME_SEARCH
*----------------------------------------------------------------------*
* Searches User name and complete name for a string
* IMPORTING i_string  TYPE so_adrnam
* EXPORTING e_sapname TYPE usnam
*           e_adrname TYPE so_adrnam,
* EXCEPTIONS NOT_FOUND
*----------------------------------------------------------------------*
METHOD name_search.
  DATA: ls_name_in     TYPE soud3,
        ls_name_out    TYPE soud3,
        lt_name_out TYPE STANDARD TABLE OF soud3.
  CLEAR: e_sapname, e_adrname.
  ls_name_in-adrname = i_string.
* Search SAPOffice user
  CALL FUNCTION 'SO_NAMES_GET'
       EXPORTING
*           SAPOFFICE_USER_ONLY         = ' '
            single_selection            = x
            user                        = ls_name_in
            intern_user                 = x
            extern_address              = space             "note454379
*           USE                         = ' '
*           SUPPRESS_DIALOG             = ' '
*      IMPORTING
*           F_CANCELED                  =
       TABLES
            user_tab                    = lt_name_out
       EXCEPTIONS
            OTHERS                      = 1
            .
  IF sy-subrc <> 0.
    RAISE not_found.
  ELSE.
    READ TABLE lt_name_out INTO ls_name_out INDEX 1.
    e_sapname = ls_name_out-sapnam.
    e_adrname = ls_name_out-adrname.
  ENDIF.
ENDMETHOD.                                 "NAME_SEARCH
*----------------------------------------------------------------------*
* METHOD NUMBER_SLIPS_PROPOSE                            note 333860
*----------------------------------------------------------------------*
* Proposes number of GR slips as entered qty ERFMG divided by qty GR
* slips from material master WESCH, rounded up to the next integer
*        IMPORTING i_erfmg TYPE mb_erfmg   type P decimals 3
*                  i_wesch TYPE wesch      type P decimals 3
*        EXPORTING e_weanz TYPE weanz      type N decimals 0
*----------------------------------------------------------------------*
METHOD number_slips_propose.                            "333860
  DATA: l_weanz_float type F,
        l_weanz_int   type I.
  IF i_wesch IS INITIAL OR i_erfmg IS INITIAL.
    e_weanz = 1.
    EXIT.
  ENDIF.
* Divide into a floating point to get decimals.
  l_weanz_float = i_erfmg / i_wesch.
* Find next integer
  l_weanz_int   = CEIL( l_weanz_float ).
* Convert type i to n
  e_weanz       = l_weanz_int.
ENDMETHOD.                                "NUMBER_SLIPS_PROPOSE