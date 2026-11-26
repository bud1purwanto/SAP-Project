*---------------------------------------------------------------------*
*       FORM FCODE_WPA1                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM FCODE_WPA1.

  DATA:
    LVF_OBJECTTYPE         TYPE SWO_OBJTYP,
    LVF_OBJECTKEY          TYPE SWO_TYPEID,
    DA_CALL_BACK_MEMORY_WA TYPE LV09A_TY_CALL_BACK_MEMORY_WA,
    DA_CALL_BACK_MEMORY    TYPE LV09A_TY_CALL_BACK_MEMORY,
    LVF_PARVW              TYPE PARVW_4,
    LVF_PARNR              TYPE SD_PARTNER_PARNR.

* Execute this form routine only during incompletion log processing
  CHECK FEHLER EQ CHARX.

  LVF_OBJECTTYPE = BUSINESSOBJEKT.
  LVF_OBJECTKEY  = VBAK-VBELN.

  DA_CALL_BACK_MEMORY_WA-OBJECTTYPE = LVF_OBJECTTYPE.
  DA_CALL_BACK_MEMORY_WA-OBJECTKEY  = LVF_OBJECTKEY.
  DA_CALL_BACK_MEMORY_WA-PROGRAM    = 'SAPMV45A'.
  DA_CALL_BACK_MEMORY_WA-SUBROUTINE = 'PARTNER_CALL_BACK'.
  DA_CALL_BACK_MEMORY_WA-FIELDNAME  = SPACE.
  DA_CALL_BACK_MEMORY_WA-EVENT      = PART_CALL_BACK_EVENT_CHANGE.
  APPEND DA_CALL_BACK_MEMORY_WA TO DA_CALL_BACK_MEMORY.

  CALL FUNCTION 'SD_PARTNER_CALL_BACK_SET_EVENT'
    EXPORTING
      FIC_OBJECTTYPE       = LVF_OBJECTTYPE
      FIC_OBJECTKEY        = LVF_OBJECTKEY
      FIF_PROGRAM          = 'SAPMV45A'
      FIF_SUBROUTINE       = 'PARTNER_CALL_BACK'
    TABLES
      FIT_EVENT_TABLE      = DA_CALL_BACK_MEMORY
    EXCEPTIONS
      PARAMETER_INCOMPLETE = 1
      OTHERS               = 2.
  CALL FUNCTION 'SD_PARTNER_DATA_PUT'
    EXPORTING
      FIC_OBJECTTYPE       = LVF_OBJECTTYPE
      FIC_OBJECTKEY        = LVF_OBJECTKEY
    TABLES
      FRT_XVBPA            = XVBPA
      FRT_YVBPA            = YVBPA
      FRT_XVBUV            = XVBUV
      FRT_HVBUV            = HVBUV
      FRT_XVBADR           = XVBADR
      FRT_YVBADR           = YVBADR
    EXCEPTIONS
      NO_OBJECT_SPECIFIED = 1
      OTHERS              = 2.
  LVF_PARVW = XVBPA-PARVW.
  CASE XVBPA-NRART.
    WHEN 'KU'. LVF_PARNR = XVBPA-KUNNR.
    WHEN 'LI'. LVF_PARNR = XVBPA-LIFNR.
    WHEN 'PE'. LVF_PARNR = XVBPA-PERNR.
    WHEN 'AP'. LVF_PARNR = XVBPA-PARNR.
  ENDCASE.
  CALL FUNCTION 'SD_PARTNER_ADDRESS_DIALOG'
    EXPORTING
      FIC_OBJECTTYPE        = LVF_OBJECTTYPE
      FIC_OBJECTKEY         = LVF_OBJECTKEY
      FIF_PARVW             = LVF_PARVW
      FIF_POSNR             = XVBPA-POSNR
      FIF_PARNR             = LVF_PARNR
      FIS_VBUV              = XVBUV
    EXCEPTIONS
      PARAMETER_INCOMPLETE  = 1
      OBJECT_NOT_FOUND      = 2
      OTHERS                = 3.

  IF SY-SUBRC EQ 0.
    PERFORM SUB_PROCESS USING CHARH.
*   Gruppenverfügbarkeitsprüfung (da in FCODE_BEARBEITEN schon vorbei,
*   wegen möglicherweise erfolgter Positionsänderungen mit ATP-Check)
    PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P) USING VERARB_HELL.
  ENDIF.

  CALL FUNCTION 'SD_PARTNER_DATA_GET'
    EXPORTING
      FIC_OBJECTTYPE      = LVF_OBJECTTYPE
      FIC_OBJECTKEY       = LVF_OBJECTKEY
      FIC_XVBUV_MERGED    = CHARX
      FIC_HVBUV_MERGED    = CHARX
    TABLES
      FET_XVBPA           = XVBPA
      FET_YVBPA           = YVBPA
      FET_XVBUV           = XVBUV
      FET_HVBUV           = HVBUV
      FET_XVBADR          = XVBADR
      FET_YVBADR          = YVBADR
    EXCEPTIONS
      NO_OBJECT_SPECIFIED = 1
      NO_OBJECT_FOUND     = 2
      MERGE_FAILED        = 3
      OTHERS              = 4.

  CALL FUNCTION 'SD_PARTNER_CALL_BACK_CLEAR'
    EXPORTING
      FIC_OBJECTTYPE = LVF_OBJECTTYPE
      FIC_OBJECTKEY  = LVF_OBJECTKEY.

ENDFORM.