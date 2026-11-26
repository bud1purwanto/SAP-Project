***INCLUDE MV50AF0F_FCODE_XPAR .
*---------------------------------------------------------------------*
*       FORM FCODE_XPAR                                               *
*---------------------------------------------------------------------*
*       Anzeigen der Partner (Kopf-Ebene)                             *
*---------------------------------------------------------------------*
FORM FCODE_XPAR USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: CAM_MEMORY_ID TYPE i.

  T185F = H185F.
  T185V = H185V.
  T185  = H185 .
  MOVE LIKP-VBELN  TO RV02P-VBELN.
  CLEAR               RV02P-POSNR.
  MOVE 'L'         TO RV02P-VBOBJ.
  MOVE LIKP-VKORG  TO RV02P-VKORG.
  MOVE RV50A-VTWEG TO RV02P-VTWEG.
  MOVE RV50A-SPART TO RV02P-SPART.
  MOVE TVLK-PARGR  TO RV02P-PARGR.
  MOVE TVLK-VBTYP  TO RV02P-VBTYP.
  MOVE TVLK-LFART  TO RV02P-LFART.
  MOVE KUWEV-KUNNR TO RV02P-KUNAG.
  MOVE TVLKT-VTEXT TO RV02P-VBARTBEZ.

  CALL FUNCTION 'SD_CAM_ADDRESS_PUSH'
       IMPORTING
            FEF_MEMORY_ID = cam_memory_id.

  CALL DIALOG 'RV_BELEG_PARTNER'
       EXPORTING
            T185F
            T185
            T185V
            RV02P
            XVBPA
            YVBPA
            KUWEV
            XVBADR
            YVBADR
            CAM_MEMORY_ID
       IMPORTING
            T185F
            T185
            FCODE
            R185D
            XVBPA
            YVBPA
            KUWEV
            XVBADR
            YVBADR.

  CALL FUNCTION 'SD_CAM_ADDRESS_POP'.

  H185F = T185F.
  H185V = T185V.
  H185  = T185 .

ENDFORM.