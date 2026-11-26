*----------------------------------------------------------------------*
*   INCLUDE RM07RESL_FIELDCAT                                          *
*   Fieldcatalog for reservations.
*   Used in RM07RESL and LMIGOGD2 (MIGO)
*----------------------------------------------------------------------*
* priority (of requirement and urgency)
  DATA: lv_mm_prio_active TYPE xfeld.
  CALL FUNCTION 'GET_DEFAULT_PRIO_ACTIVE'
    IMPORTING
      ev_mm_prio_active = lv_mm_prio_active
    EXCEPTIONS
      no_pact_entry     = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    CLEAR lv_mm_prio_active.
  ENDIF.
  def_add 'RSNUM_I' 'RSNUM' 'RESB'  space space.
  def_add 'RSPOS_I' 'RSPOS' 'RESB'  space space.
  def_add 'RSART_I' 'RSART' 'RESB'  space space.
  def_add 'BDTER_I' 'BDTER' 'RESB'  space space.
  def_add 'BWART_I' 'BWART' 'RESB'  space space.
  def_add 'SHKZG_I' 'SHKZG' 'RESB'  space space.
  def_add 'SOBKZ_I' 'SOBKZ' 'RESB'  'X'   space.
  def_add 'BTEXT'   'BTEXT' 'T156T' 'X'   space.
  def_add 'MATNR_I' 'MATNR' 'RESB'  space space.
  def_add 'MAKTX'   'MAKTX' 'MAKT'  'X'   space.
  def_add 'WERKS_I' 'WERKS' 'RESB'  'X'   space.
  def_add 'LGORT_I' 'LGORT' 'RESB'  'X'   space.
  def_add 'CHARG_I' 'CHARG' 'RESB'  'X'   space.
  def_add 'BDMNG_I' 'BDMNG' 'RESB'  space 'MEINS_I'.
  def_add 'ENMNG_I' 'DABMG' 'AM07M' 'X' 'MEINS_I'.
  def_add 'DIFFMG'  'DIFMG_RES' 'AM07M' space 'MEINS_I'.
  def_add 'MEINS_I' 'MEINS' 'RESB'  space space.
  def_add 'ERFMG_I' 'ERFMG' 'RESB'  'X' 'ERFME_I'.
  def_add 'ERFME_I' 'ERFME' 'RESB'  'X' space.
  IF lv_mm_prio_active IS NOT INITIAL.
    def_add 'PRIO_URG_I' 'PRIO_URG' 'RESB' space space.
    def_add 'PRIO_REQ_I' 'PRIO_REQ' 'RESB' space space.
  ENDIF.
* Status
  def_add 'XLOEK_I' 'XLOEK' 'RESB' 'X' space.
  def_add 'XWAOK_I' 'XWAOK' 'RESB' 'X' space.
  def_add 'KZEAR_I' 'KZEAR' 'RESB' 'X' space.
  def_add 'SCHGT_I' 'SCHGT' 'RESB' 'X' space.
  def_add 'DUMPS_I' 'DUMPS' 'RESB' 'X' space.
  def_add 'RSTYP'   'RSTYP' 'T156' space space.
  def_add 'RSSTA_I' 'RSSTA' 'RESB' 'X' space.
  def_add 'BDART_I' 'BDART' 'RESB' 'X' space.
* Organization
  def_add 'WEMPF_H' 'WEMPF' 'RKPF' 'X' space.
  def_add 'RSDAT_H' 'RSDAT' 'RKPF' 'X' space.
  def_add 'USNAM_H' 'USNAM' 'RKPF' 'X' space.
* Accountings
  def_add 'ACCOU'   'ACCOU' 'AM07M' space space.
  def_add 'KOSTL_H' 'KOSTL' 'RKPF' 'X' space.
  def_add 'AUFNR_H' 'AUFNR' 'RKPF' 'X' space.
  def_add 'PS_PSP_PNR_H' 'PS_PSP_PNR' 'RKPF' 'X' space.
  def_add 'ANLN1_H' 'ANLN1' 'RKPF' 'X' space.
  def_add 'ANLN2_H' 'ANLN2' 'RKPF' 'X' space.
  def_add 'NPLNR_H' 'NPLNR' 'RKPF' 'X' space.
  def_add 'VORNR_I' 'VORNR' 'RESB' 'X' space.
  def_add 'UMWRK_H' 'UMWRK' 'RKPF' 'X' space.
  def_add 'UMLGO_H' 'UMLGO' 'RKPF' 'X' space.
  def_add 'KDAUF_H' 'KDAUF' 'RKPF' 'X' space.
  def_add 'KDPOS_H' 'KDPOS' 'RKPF' 'X' space.
  def_add 'KDEIN_H' 'KDEIN' 'RKPF' 'X' space.
* note 432208
  def_add 'ROANZ_I' 'ROANZ' 'RESB' 'X' space.
* note 576983
  def_add 'VMENG_I' 'VMENG' 'RESB' 'X' 'MEINS_I'.
* note 1500349
  def_add 'NO_DISP_I' 'NO_DISP' 'RESB' 'X' space.