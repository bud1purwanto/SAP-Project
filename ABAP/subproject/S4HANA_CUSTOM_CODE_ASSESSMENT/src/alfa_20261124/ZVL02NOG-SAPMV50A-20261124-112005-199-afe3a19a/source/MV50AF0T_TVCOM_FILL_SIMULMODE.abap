*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVCOM_FILL_SIMULMODE                              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       Form  TVCOM_FILL_SIMULMODE
*----------------------------------------------------------------------*
*       fill TVCOM for simulation RV_TEXT_COPY                         *
*----------------------------------------------------------------------*

FORM tvcom_fill_simulmode USING value(level) TYPE c.

  CLEAR: tvcom.
* TVCOM-TDOBJECT = LEVEL.
  IF level = 'LIKP'.
* TVCOM-VBELV    = ???
* In der Regel wurde bei der Ermittlung des Kopftextes
* der Vorgaengerbeleg der jetzt ersten Position verwendet
* Stimmt nicht mehr, falls spaeter die erste Position
* geloescht wurde:
    MOVE-CORRESPONDING likp TO tvcom.
    tvcom-ernamv = likp-ernam.

    READ TABLE xlips INDEX 1.
    tvcom-vbelv = xlips-vgbel.
    tvcom-vtweg = rv50a-vtweg.
    tvcom-spart = rv50a-spart.
    tvcom-tdobject = 'VBBK'.
    tvcom-posnv    = posnr_low.
    tvcom-vbeln    = likp-vbeln.
    tvcom-posnn    = posnr_low.
    tvcom-txtgn    = tvlk-txtgr.
    tvcom-sd_caller = 'L'.
  ELSEIF level = 'LIPS'.
    MOVE-CORRESPONDING likp TO tvcom.
    MOVE-CORRESPONDING lips TO tvcom.
    tvcom-ernamv = lips-ernam.

    tvcom-tdobject = 'VBBP'.
    tvcom-vbelv = lips-vgbel.
    tvcom-posnv = lips-vgpos.
    tvcom-vbeln = likp-vbeln.
    tvcom-posnn = lips-posnr.
    tvcom-txtgn = tvlp-txtgr.
    tvcom-matnr = lips-matnr.
    tvcom-vkorg = likp-vkorg.
*   TVCOM-BUKRS = TVKO-BUKRS.
*   TVCOM-VKOSP = TVKO_SADR-SPRAS.
    tvcom-sd_caller = 'L'.
  ENDIF.

ENDFORM.                               " TVCOM_SIMULMODE_FILL