*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TAXI_FILTER_AND_CONVE                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TAXI_FILTER_AND_CONVERT_FCODE
*&---------------------------------------------------------------------*
*       Prüfen und ggf. Umsetzen des eingegangenen FCodes.
*       Wird im PAI jedes Trägerdynpros aufgerufen.
*
*       Funktion:
*       Falls eingegangener Funktionscode Tabstrip-Funktionscode,
*       Umsetzung in echten Funktionscode
*----------------------------------------------------------------------*
form taxi_filter_and_convert_fcode changing cf_fcode type fcode.

  data: lf_taxi_fcode_flag like taxi_params-flag.

* Check, ob Funktionscode von Tabstrip-Reiter stammt
  call function 'TAXI_FILTER_FCODE'
    exporting
      fcode         = cf_fcode
    importing
      is_taxi_fcode = lf_taxi_fcode_flag
    exceptions
      others        = 0.

* Eingangener Funktionscode stammt von Tabstrip:
*     Reiterfunktionscode in echten Funktionscode umsetzen
  if lf_taxi_fcode_flag = 'X'.

*   The sequence of tabs may be changed by BAdIs: Translation between
*   the visible tab structure and the tab structure inside function
*   group TAXI is necessary
    read table gt_taxi_admin with key fcode_new = cf_fcode
                             binary search.
    if sy-subrc eq 0.
      cf_fcode = gt_taxi_admin-fcode_old.
    endif.

    call function 'TAXI_CONVERT_FCODE'
      exporting
        fcode_in        = cf_fcode
      importing
        fcode_out       = cf_fcode
      exceptions
        fcode_not_found = 1
        others          = 2.
  endif.

endform.                               " TAXI_FILTER_AND_CONVERT_FCODE