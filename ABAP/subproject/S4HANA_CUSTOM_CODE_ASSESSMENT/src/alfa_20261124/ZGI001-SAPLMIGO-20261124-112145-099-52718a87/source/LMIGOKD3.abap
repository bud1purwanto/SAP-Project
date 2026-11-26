*----------------------------------------------------------------------*
*   INCLUDE LMIGOKD3                                                   *
*----------------------------------------------------------------------*
***********************************************************************
* Defaults_merge
* Merge the current set of default values into GOITEM.
* ATTENTION: This routine does not check whether we are in display,
*            cancel or whatsoever mode. This is entierly under control
*            of the DEFAULTSVALUES-class!
***********************************************************************
METHOD defaults_merge.
* Plant
  IF cs_goitem-werks IS INITIAL.
    cs_goitem-werks = s_defaults-werks.
  ENDIF.
* Storage location
* Filled, if 1) empty, 2) required, 3) the sloc/plant combination fits
  IF cs_goitem-lgort IS INITIAL AND cs_goitem-werks = s_defaults-werks.
    cs_goitem-lgort = s_defaults-lgort.
  ENDIF.
* Movement type.
  IF cs_goitem-bwart IS INITIAL.
    cs_goitem-bwart = s_defaults-bwart.
  ENDIF.
* Special stock indicator
  IF cs_goitem-sobkz IS INITIAL.
    cs_goitem-sobkz = s_defaults-sobkz.
  ENDIF.
* Stock type                                                     "375396
  IF cs_goitem-migo_insmk IS INITIAL.                            "375396
    cs_goitem-migo_insmk = s_defaults-insmk.                     "375396
  ENDIF.                                                         "375396
* Checkbox "Position O.K."
  IF cs_goitem-take_it IS INITIAL.
    cs_goitem-take_it = s_defaults-take_it_all.
  ENDIF.
* Checkbox "seralnumbers automatically"
  IF cs_goitem-xsaut IS INITIAL.
    cs_goitem-xsaut = s_defaults-xsaut.
  ENDIF.
ENDMETHOD.