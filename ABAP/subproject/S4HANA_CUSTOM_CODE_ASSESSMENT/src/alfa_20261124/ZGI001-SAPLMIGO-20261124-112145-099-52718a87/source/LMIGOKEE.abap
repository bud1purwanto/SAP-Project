*----------------------------------------------------------------------*
*                    <lg>
*   INCLUDE LMIGOKEE: defintion of types for processing of tied empties
*
* up to note 333860 (see LMIGOGL2) extensions of goitem integrated here
*
*----------------------------------------------------------------------*
  TYPES:
* copying data from full product to tied empty: some fields have
* to be dealt with as individual, some others as potentially individual
*
    BEGIN OF ty_s_empties_individual,
* fields relevant to line processing
      depth                   TYPE  migo_line_level,
      parent                  TYPE  migo_parent_glc,
      expand                  TYPE  migo_expander,
      invisible               TYPE  migo_line_invisible,
      xlbtype                 TYPE  migo_lbitem,
      xvgtype                 TYPE  xvgtype,
      xauto                   TYPE  xauto,                       "sdp462
      global_counter          TYPE  migo_global_counter,
* Fields from table T156 Movement types (got156 could not be copied
* because bwart, shkzg.. are not individual)
      kzwes                   TYPE  kzwes,
      kzmhd                   TYPE  kzmhd,
* fields relevant to control of empties processing
      uptyp                   TYPE  uptyp,
      hpos_wws                TYPE  hpos_wws,
* material master
      matnr                   TYPE  matnr,
      matkl                   TYPE  matkl,
      meins                   TYPE  meins,
      maktx                   TYPE  maktx_d,
      ean11_bme               TYPE  ean11_bme,
      ean11_kon               TYPE  ean11_kon,
      eanme                   TYPE  meins,
      matbf                   TYPE  matbf,
      ausme                   TYPE  ausme,
      xchpf                   TYPE  xchpf,
      xlort                   TYPE  xlort,
      kzwsm                   TYPE  kzwso,
      umrez                   TYPE  umrez,
      umren                   TYPE  umren,
      wertu                   TYPE  wertu,
      mengu                   TYPE  mengu,
      lgpbe                   TYPE  lgpbe,
      mwskz                   TYPE  mwskz,
      eprio                   type  eprio,                 "note 209343
* batches
      xchar                   TYPE  xchar,
      licha                   TYPE  lichn,
      charg                   TYPE  charg_d,
      zustd                   TYPE  dzustd,
      batch_from_refdoc       TYPE  charg_d,
      vendorbatch_from_refdoc TYPE  lichn,
      zusch                   TYPE  dzusch,
      mhdrz                   TYPE  mhdrz,
      mhdhb                   TYPE  mhdhb,
      iprkz                   TYPE  dattp,
      rdmhd                   TYPE  rdmhd,
      vfdat                   TYPE  vfdat,
      hsdat                   TYPE  hsdat,
* text
      sgtxt                   TYPE  sgtxt,
* quantity
      erfme                   TYPE  erfme,
* valuation
      bwtty                   TYPE  bwtty_d,
      bwtar                   TYPE  bwtar_d,
      bwtor                   TYPE  bwtar_d,
      kzbaa                   TYPE  kzbaa,                 "note 313811
      exbwr                   TYPE  exbwr,
      exvkw                   TYPE  exvkw,
      vkwrt                   TYPE  vkwrt,
      dmbtr                   TYPE  dmbtr,
* purchasing
      bpmng                   TYPE  bpmng_input,
      bprme                   TYPE  mb_bprme,
      ebeln                   TYPE  bstnr,
      ebelp                   TYPE  ebelp,
      etens                   TYPE  etens,                 "note 321534
      lsmng                   TYPE  lsmng,
      lsmeh                   TYPE  lsmeh,
      bsmng                   TYPE  bsmng,
      wemng                   TYPE  wemng,
      wamng                   TYPE  wamng,
      bstme                   TYPE  bstme,
      bpumz                   TYPE  bpumz,
      bpumn                   TYPE  bpumn,
      bumrz                   TYPE  umrez,
      bumrn                   TYPE  umren,
      knttp                   TYPE  knttp,
      mulko                   TYPE  mulko,
      evers                   TYPE  evers,
      evere                   TYPE  evere,
      bstmg                   TYPE  mb_bstmg,
      ematn                   TYPE  ematn,
      idnlf                   TYPE  idnlf,
* QM
      gebeh                   TYPE  qgebeh,
      anzgeb                  TYPE  qanzgeb,
      qinspst                 TYPE  qinspst,
      prfrq                   TYPE  prfrq,
      ssqss                   TYPE  ssqss,
* reservation
      rsnum                   TYPE  rsnum,
      rspos                   TYPE  rspos,
      bdmng                   TYPE  bdmng,
      enmng                   TYPE  enmng,
      vmeng                   TYPE  vmeng,
      meins_res               TYPE  meins,
* GR based IR
      lfbnr                   TYPE  lfbnr,
      lfpos                   TYPE  lfpos,
      lfbja                   TYPE  lfbja,
* sales order
      mat_kdauf               TYPE  mat_kdauf,
      mat_kdpos               TYPE  mat_kdpos,
      kzbws                   TYPE  kzbws,
* shipping notification, delivery
      vlief_avis              TYPE  vbeln_vl,
      vbelp_avis              TYPE  posnr_vl,
* delivery
      vbeln                   TYPE  vbeln_vl,
      posnr                   TYPE  posnr_vl,
* reversal
      smbln                   TYPE  mblnr,
      smblp                   TYPE  mblpo,
      sjahr                   TYPE  mjahr,
* warehouse management
      lgnum                   TYPE  lgnum,
      lgtyp                   TYPE  lgtyp,
      lgpla                   TYPE  lgpla,
      bwlvs                   TYPE  bwlvs,
      bsskz                   TYPE  lvs_bsskz,
* transfer
      ummat                   TYPE  ummat,
      umcha                   TYPE  umcha,
      umzst                   TYPE  umzst,
      umzus                   TYPE  umzus,
      umbar                   TYPE  umbar,
      ummaktx                 TYPE  maktx_d,
      umlgobe                 TYPE  lgobe,
      umbwtty                 TYPE  bwtty_d,
      umxchar                 TYPE  xchar,
      umxchpf                 TYPE  xchpf,
* serial numbers
      sernp                   TYPE  serail,
      equnr                   TYPE  equnr,
      anzsn                   TYPE  anzser,
      xsaut                   TYPE  xsaut,
    END OF ty_s_empties_individual,
*
*******
*
    BEGIN OF ty_s_empties_optional,
* account assignment block
      aab                     TYPE gocobl,
      konto                   TYPE saknr,
* reason for movement
      grtxt                   TYPE grtxt,
      grund                   TYPE mb_grbew,
    END OF ty_s_empties_optional.