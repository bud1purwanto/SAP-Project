***INCLUDE MM07MFJ2 .
*----------------------------------------------------------------------*
*        Form OFF_NUMBER_GLOBAL_NUMBERING                              *
*----------------------------------------------------------------------*
FORM OFF_NUMBER_GLOBAL_NUMBERING.
  CLEAR E_FIN1_PARAM.
* The external document number is only determined using the
* first line of the material document. This is no program error,
* but program design.
  READ TABLE xmkpf  INDEX 1.                                     "sdp462
  READ TABLE xmseg  INDEX 1.
  READ TABLE xvm07m INDEX 1.                                     "sdp462
  IF T158-TRTYP = H.
    E_FIN1_PARAM-AKTYP = C.
  ELSEIF T158-TRTYP = V.
    E_FIN1_PARAM-AKTYP = M.
  ELSE.
    E_FIN1_PARAM-AKTYP = D.
  ENDIF.
  E_FIN1_PARAM-APPLI = 'M'.
  E_FIN1_PARAM-BUKRS =  XMSEG-BUKRS.
  e_fin1_param-bwkey =  xvm07m-bwkey.                            "sdp462
  E_FIN1_PARAM-WERKS =  XMSEG-WERKS.
* Note 352589 - Consignment process xmseg-lgort is cleared
  IF XMSEG-LGORT IS INITIAL AND
     NOT FUSS-LGORT IS INITIAL AND
     NOT T156-J_1ADOCCL IS INITIAL.
      E_FIN1_PARAM-LGORT =  FUSS-LGORT.
  ELSE.
      E_FIN1_PARAM-LGORT =  XMSEG-LGORT.
  ENDIF.
  E_FIN1_PARAM-BWART =  XMSEG-BWART.
  E_FIN1_PARAM-BLGAR =  XMKPF-BLART.
  E_FIN1_PARAM-XBLNR =  XMKPF-XBLNR.
* If the material document is the background part of a cross system
* goods movement, the issuing plant is not known to this system.
* So this handling cannot be performed.
  CHECK cl_mmim_cross_system=>kzdir_get( xmseg-bwart ) <> r.     "sdp462
  CALL FUNCTION 'OFF_NUMBER_GLOBAL_NUMBERING'
       EXPORTING
            I_FIN1_PARAM     = E_FIN1_PARAM
            I_MKPF           = XMKPF
       IMPORTING
            O_XBLNR          = XMKPF-XBLNR
       EXCEPTIONS
            INPUT_INCOMPLETE = 1
            COUNTRY_UNKNOWN  = 2
            OTHERS           = 3.
  PERFORM SUBRC_HANDLE.
  MODIFY XMKPF INDEX 1.
ENDFORM.
*eject
*----------------------------------------------------------------------*
*        Form OFF_NUMBER_GLOBAL_SCREEN                                 *
*----------------------------------------------------------------------*
FORM OFF_NUMBER_GLOBAL_SCREEN.
  CLEAR E_FIN1_PARAM.
  READ TABLE YMSEG INDEX 1.
  IF T158-TRTYP = H.
    E_FIN1_PARAM-AKTYP = C.
  ELSEIF T158-TRTYP = V.
    E_FIN1_PARAM-AKTYP = M.
  ELSE.
    E_FIN1_PARAM-AKTYP = D.
  ENDIF.
  E_FIN1_PARAM-APPLI = 'M'.
  E_FIN1_PARAM-BUKRS =  YMSEG-BUKRS.
  E_FIN1_PARAM-BWKEY =  VM07M-BWKEY.
  E_FIN1_PARAM-WERKS =  YMSEG-WERKS.
  E_FIN1_PARAM-LGORT =  YMSEG-LGORT.
  E_FIN1_PARAM-BWART =  YMSEG-BWART.
  E_FIN1_PARAM-BLGAR =  MKPF-BLART.
  E_FIN1_PARAM-XBLNR =  MKPF-XBLNR.

  CALL FUNCTION 'OFF_NUMBER_GLOBAL_SCREEN'
       EXPORTING
            I_FIN1_PARAM     = E_FIN1_PARAM
            I_MKPF           = MKPF
            I_INPUT          = SCREEN-INPUT
            I_OUTPUT         = SCREEN-OUTPUT
            I_INVISIBLE      = SCREEN-INVISIBLE
       IMPORTING
            O_INPUT          = SCREEN-INPUT
            O_OUTPUT         = SCREEN-OUTPUT
            O_INVISIBLE      = SCREEN-INVISIBLE
       EXCEPTIONS
            INPUT_INCOMPLETE = 1
            COUNTRY_UNKNOWN  = 2
            OTHERS           = 3.
ENDFORM.
*eject
*----------------------------------------------------------------------*
*        Form OFF_NUMBER_GLOBAL_DEFAULTS                               *
*----------------------------------------------------------------------*
MODULE OFF_NUMBER_GLOBAL_DEFAULTS OUTPUT.
  CLEAR E_FIN1_PARAM.
  IF T158-TRTYP = H.
    E_FIN1_PARAM-AKTYP = C.
  ELSEIF T158-TRTYP = V.
    E_FIN1_PARAM-AKTYP = M.
  ELSE.
    E_FIN1_PARAM-AKTYP = D.
  ENDIF.
  E_FIN1_PARAM-APPLI = 'M'.
  E_FIN1_PARAM-BUKRS =  MSEG-BUKRS.
  E_FIN1_PARAM-BWKEY =  VM07M-BWKEY.
  E_FIN1_PARAM-WERKS =  MSEG-WERKS.
  E_FIN1_PARAM-LGORT =  MSEG-LGORT.
  E_FIN1_PARAM-BWART =  MSEG-BWART.
  E_FIN1_PARAM-BLGAR =  MKPF-BLART.
  E_FIN1_PARAM-XBLNR =  MKPF-XBLNR.
  E_FIN1_PARAM-XSTOR =  T156N-XSTOR.

  CALL FUNCTION 'OFF_NUMBER_GLOBAL_DEFAULTS'
       EXPORTING
            I_FIN1_PARAM     = E_FIN1_PARAM
            I_MKPF           = MKPF
       IMPORTING
            O_XBLNR          = MKPF-XBLNR
       EXCEPTIONS
            INPUT_INCOMPLETE = 1
            COUNTRY_UNKNOWN  = 2
            OTHERS           = 3.
  RM07M-MTSNR = MKPF-XBLNR.
ENDMODULE.
*----------------------------------------------------------------------*
*        Form OFF_NUMBER_GLOBAL_CHECK                                  *
*----------------------------------------------------------------------*
FORM OFF_NUMBER_GLOBAL_CHECK.
  CLEAR E_FIN1_PARAM.
  READ TABLE YMSEG INDEX 1.
  CHECK SY-SUBRC EQ 0.
  IF T158-TRTYP = H.
    E_FIN1_PARAM-AKTYP = C.
  ELSEIF T158-TRTYP = V.
    E_FIN1_PARAM-AKTYP = M.
  ELSE.
    E_FIN1_PARAM-AKTYP = D.
  ENDIF.
  E_FIN1_PARAM-APPLI = 'M'.
  E_FIN1_PARAM-BUKRS =  YMSEG-BUKRS.
  E_FIN1_PARAM-BWKEY =  VM07M-BWKEY.
  E_FIN1_PARAM-WERKS =  YMSEG-WERKS.
  E_FIN1_PARAM-LGORT =  YMSEG-LGORT.
  E_FIN1_PARAM-BWART =  YMSEG-BWART.
  E_FIN1_PARAM-BLGAR =  MKPF-BLART.
  E_FIN1_PARAM-XBLNR =  MKPF-XBLNR.
  E_FIN1_PARAM-XSTOR =  T156N-XSTOR.

  CALL FUNCTION 'OFF_NUMBER_GLOBAL_CHECK'
       EXPORTING
            I_FIN1_PARAM     = E_FIN1_PARAM
            I_MKPF           = MKPF
       IMPORTING
            O_XBLNR          = MKPF-XBLNR
       EXCEPTIONS
            INPUT_INCOMPLETE = 1
            COUNTRY_UNKNOWN  = 2
            OTHERS           = 3.
ENDFORM.
*eject.
*----------------------------------------------------------------------*
*                 Fehlerhandling                                       *
*----------------------------------------------------------------------*
FORM SUBRC_HANDLE.
  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH
               SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.