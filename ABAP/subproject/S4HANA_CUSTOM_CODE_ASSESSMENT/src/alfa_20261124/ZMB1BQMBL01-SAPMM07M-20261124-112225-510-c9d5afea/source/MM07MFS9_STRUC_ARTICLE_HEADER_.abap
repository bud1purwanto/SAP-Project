*----------------------------------------------------------------------*
*       FORM STRUC_ARTICLE_HEADER_VALUE                                *
*----------------------------------------------------------------------*
*       following case:
*       one step transfer of a structured article (647)  and no        *
*       explosion of bom at the sender's but at the receiver's ;       *
*       purchasing value of header at the sender's must be caculated   *
*       here in order to hand it over in time to the header at the     *
*       receiver's ; thus the values of the components at the receiver's
*       can be calculated correctly                                    *
*----------------------------------------------------------------------*
FORM STRUC_ARTICLE_HEADER_VALUE changing p_zeile
                                         p_zeium
                                         p_wrbtr.

  data: h_ydm07m like ydm07m.

  clear: p_zeile, p_zeium, p_wrbtr.
* get '101' line at receiver's
  loop at ydm07m into h_ydm07m where oruml = zdm07m-zeild  and
                                     not zeild = zdm07m-zeild.
* bom is exploded at receiver's; otherwise oruml wouldn't be filled
* and we wouldn't enter the loop
    if zmseg-exbwr is initial.
* no external value -> valuate header at sender's
      CALL FUNCTION 'MB_CALCULATE_VALUES'
           EXPORTING
                DM07M     = ZDM07M
                VM07M     = ZVM07M
                MKPF      = MKPF
                MSEG      = ZMSEG
                MBEQU     = TCURM-MBEQU
                GLVOR     = RW_VORGANG
                KURST     = T003-KURST
                BRAZIL    = BRAZIL
                xmbwl     = xmbwl
           IMPORTING
                DM07M     = DM07M
                VM07M     = VM07M
                MSEG      = MSEG
                X_FWDIF   = FWDIF
                X_SHFWDIF = SHFWDIF
           TABLES
                XEKBN     = XEKBN
                XEKBV     = XEKBV
                XEKWS     = XEKWS
                XEKWV     = XEKWV
                XMBEW     = XMBEW
                XEBEW     = XEBEW
                XQBEW     = XQBEW
                XOBEW     = XOBEW                                   "kaz
                XEKLB     = ZEKLB
                XEKLS     = XEKLS
                XFAWS     = XFAWS
                XFAWV     = XFAWV
                X156W     = X156W
                XZCXCB    = XZCXCB
                XZCXCM    = XZCXCM
                YEKBNK    = YEKBNK
                YEKBNK_CR = YEKBNK_CR
                YEBEFU_CR = YEBEFU_CR
                YFBEFU_CR = YFBEFU_CR
                ZEKBE_CR  = ZEKBE_CR
                ZAUFBE_CR  = ZAUFBE_CR
                xekbnk_kdm = yekbnk_kdm.                   "N1027899 + 1520698
* store value in parameter
      LOOP AT XZCXCM WHERE VORSL = VORSL_BSX
                   AND   CURTP = CURTP10
                   AND   XUMBW = SPACE.
        IF XZCXCM-BUZID = M.
          P_WRBTR = XZCXCM-DMBTR.
          P_ZEILE = ZMSEG-ZEILE.
          P_ZEIUM = H_YDM07M-ZEILD.
          EXIT.
        ENDIF.
      ENDLOOP.
    else.
* take over external value
      P_WRBTR = ZMSEG-EXBWR.
      P_ZEILE = ZMSEG-ZEILE.
      P_ZEIUM = H_YDM07M-ZEILD.
    endif.
* there can just be one hit -> work is done here
    exit.
  endloop.
ENDFORM.                                   "STRUC_ARTICLE_HEADER_VALUE