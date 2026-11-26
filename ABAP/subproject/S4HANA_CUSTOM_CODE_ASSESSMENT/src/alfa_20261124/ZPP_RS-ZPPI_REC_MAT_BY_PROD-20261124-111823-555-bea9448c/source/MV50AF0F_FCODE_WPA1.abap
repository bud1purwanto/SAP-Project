*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_WPA1                                        *
*----------------------------------------------------------------------*
FORM FCODE_WPA1.

  data: lvf_objecttype type SWO_OBJTYP,
        lvf_objectkey  type SWO_TYPEID,
        lvf_tempobj    type NAST-OBJTYPE.

* determination of BOR Object
  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            I_DOCUMENT_TYPE        = XLIKP-vbtyp
       IMPORTING
            E_BUSINESS_OBJECT      = lvf_tempobj.

  lvf_objecttype = lvf_tempobj.
  lvf_objectkey  = XLIKP-VBELN.

*  this form routine should only be executed during incompletion log
*  processing
    CALL FUNCTION 'SD_PARTNER_DATA_PUT'
         EXPORTING
              FIC_OBJECTTYPE      = lvf_objecttype
              FIC_OBJECTKEY       = lvf_objectkey
         TABLES
              FRT_XVBPA           = XVBPA                "#EC ENHOK
              FRT_YVBPA           = YVBPA                "#EC ENHOK
              FRT_XVBUV           = XVBUV
              FRT_HVBUV           = HVBUV
              FRT_XVBADR          = XVBADR
              FRT_YVBADR          = YVBADR
         EXCEPTIONS
              NO_OBJECT_SPECIFIED = 1
              OTHERS              = 2.
    DATA: LVF_PARVW TYPE PARVW_4,
          LVF_PARNR TYPE SD_PARTNER_PARNR.

    read table xvbpa with key posnr = xvbuv-posnr
                              parvw =  XVBUV-PARVW.
    if sy-subrc ne 0.
      exit.
    endif.

    CASE XVBPA-NRART.
      when 'KU'. LVF_PARNR = XVBPA-KUNNR.
      when 'LI'. LVF_PARNR = XVBPA-LIFNR.
      when 'PE'. LVF_PARNR = XVBPA-PERNR.
      when 'AP'. LVF_PARNR = XVBPA-PARNR.
    endcase.
    LVF_PARVW = XVBPA-PARVW.

    CALL FUNCTION 'SD_PARTNER_ADDRESS_DIALOG'
       EXPORTING
              FIC_OBJECTTYPE        = lvf_objecttype
              FIC_OBJECTKEY         = lvf_objectkey
              FIF_PARVW             = lvf_PARVW
              FIF_POSNR             = XVBPA-POSNR
              FIF_PARNR             = LVF_PARNR
*               FIF_FIRST_MAINTAINING = ' '
              FIS_VBUV              = XVBUV
       EXCEPTIONS
              PARAMETER_INCOMPLETE  = 1
              OBJECT_NOT_FOUND      = 2
              OTHERS                = 3.


    CALL FUNCTION 'SD_PARTNER_DATA_GET'
         EXPORTING
              FIC_OBJECTTYPE      = lvf_objecttype
              FIC_OBJECTKEY       = lvf_objectkey
              FIC_XVBUV_MERGED    = 'X'
              FIC_HVBUV_MERGED    = 'X'
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

ENDFORM.                               " FCODE_KPAR_GUI40