param([string]$Path, [string]$InputName, [string]$Origin, [string[]]$Lines,
      [switch]$Migration, [string]$Release, [object[]]$Rules, [object[]]$Evidence)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$sheets = [ordered]@{}
$objects = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$categories = @('Program','INCLUDE','Tabel dan View','Function Module','BAPI','BDC','Transaksi','Layar Seleksi','Teks Seleksi','Layar dan GUI','Tipe DDIC','Field DDIC','Class dan Interface')
foreach ($category in $categories) {
    $sheets[$category] = [Collections.Generic.List[object]]::new()
    $sheets[$category].Add(@('Objek source', 'Baris', 'Jenis referensi', 'Objek atau deklarasi'))
}
$categoryByType = @{
    includes='INCLUDE'; submitPrograms='Program'; tableReads='Tabel dan View'
    databaseWrites='Tabel dan View'; callFunctions='Function Module'; callTransactions='Transaksi'
    'Sumber data pada SELECT atau JOIN'='Tabel dan View'; 'Program yang dirujuk SUBMIT'='Program'
    'Function module'='Function Module'; 'Tujuan CALL TRANSACTION (periksa literal atau variabel)'='Transaksi'
    'Indikasi penulisan data (perlu konfirmasi)'='Tabel dan View'
}
$object = ''
foreach ($line in $Lines) {
    if ($line -match '^Objek (.+) \(\d+ baris\)$') {
        $object = $Matches[1]
        [void]$objects.Add($object)
        $sheets['Program'].Add(@($object,'','Source terbaca',$object))
    } elseif ($line -match '^(.+)\.abap$') {
        $object = $Matches[1]
        if ($objects.Count -eq 0) { $sheets['Program'].Add(@($object,'','File source lokal',$object)) }
    } elseif ($line -match '^  (Baris )?(\d+) \| (.*?) \| (.*)$') {
        if ($Matches[1] -and $objects.Contains($object)) { continue }
        $kind = $Matches[3]
        $target = $Matches[4]
        $entry = @($object,$Matches[2],$kind,$target)
        $category = if ($categoryByType.ContainsKey($kind)) { $categoryByType[$kind] } else { $kind }
        if ($category -eq 'Function Module' -and $target.StartsWith('BAPI_')) { $category = 'BAPI' }
        if ($categories -contains $category) { $sheets[$category].Add($entry) }
    }
}
foreach ($category in $categories) {
    if ($sheets[$category].Count -eq 1) {
        $sheets[$category].Add(@('','','','Belum terdeteksi dalam scan statis.'))
    }
}
function XmlText([string]$Value) {
    return [Security.SecurityElement]::Escape(($Value -replace '[\x00-\x08\x0B\x0C\x0E-\x1F]', ''))
}

if ($Migration) {
    $catalog = @{}
    $repositoryEvidence = @{}
    foreach ($item in $Evidence) {
        $repositoryEvidence["$($item.Jenis)|$($item.Objek)"] = $item.Bukti
    }
    foreach ($rule in $Rules) {
        if ($Release -and $rule.Rilis -eq $Release) {
            $catalog["$($rule.Jenis)|$($rule.Objek)"] = $rule
        }
    }
    $guidance = @{
        'Tabel dan View'='Cek tabel/view, field, join, dan hasil query.'
        'Function Module'='Cek ketersediaan fungsi dan parameter yang dipakai.'
        'BAPI'='Cek parameter, pesan, dan hasil proses bisnis.'
        'BDC'='Cek urutan layar, field, dan OKCODE.'
        'Transaksi'='Cek definisi transaksi dan navigasi di target.'
        'Layar Seleksi'='Cek deklarasi, tipe field, dan varian.'
        'Teks Seleksi'='Cek text pool dan label per bahasa.'
    }
    foreach ($category in $categories) {
        $tab = $sheets[$category]
        $tab[0] += @('Catatan S/4HANA','Status cek target','Tindakan','Referensi','Bukti pencarian repository')
        for ($i = 1; $i -lt $tab.Count; $i++) {
            $row = $tab[$i]
            if (-not $row[2]) { continue }
            $rule = $catalog["$category|$($row[3])"]
            if ($rule) {
                $tab[$i] += @($rule.Catatan,'Belum diperiksa',$rule.Tindakan,$rule.Referensi)
            } else {
                $action = $guidance[$category]
                if (-not $action) { $action = 'Periksa objek atau deklarasi di sistem tujuan.' }
                $note = if ($Release) { 'Belum ada aturan untuk rilis ini.' } else { 'Rilis tujuan belum diisi.' }
                $tab[$i] += @($note,'Belum diperiksa',$action,'')
            }
            $proof = $repositoryEvidence["$category|$($row[3])"]
            if (-not $proof) { $proof = 'Belum ada bukti repository yang dapat dipakai.' }
            $tab[$i] += $proof
        }
    }
}

$ns = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
$rel = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
$package = 'http://schemas.openxmlformats.org/package/2006/relationships'
$temp = "$Path.tmp"
$zip = [IO.Compression.ZipFile]::Open($temp, 'Create')
function AddPart([string]$Name, [string]$Xml) {
    $writer = [IO.StreamWriter]::new($zip.CreateEntry($Name).Open(), [Text.UTF8Encoding]::new($false))
    try { $writer.Write($Xml) } finally { $writer.Dispose() }
}
try {
    $tabs = ''
    $links = ''
    $types = ''
    $index = 0
    foreach ($sheet in $sheets.GetEnumerator()) {
        $index++
        $tabs += "<sheet name=`"$($sheet.Key)`" sheetId=`"$index`" r:id=`"rId$index`"/>"
        $links += "<Relationship Id=`"rId$index`" Type=`"$rel/worksheet`" Target=`"worksheets/sheet$index.xml`"/>"
        $types += "<Override PartName=`"/xl/worksheets/sheet$index.xml`" ContentType=`"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml`"/>"
        $rows = [Collections.Generic.List[object]]::new()
        $rows.Add(@('Input', $InputName))
        $rows.Add(@('Baseline', $Origin, 'Rilis S/4HANA', $Release))
        $rows.AddRange($sheet.Value)
        $body = [Text.StringBuilder]::new()
        for ($r = 0; $r -lt $rows.Count; $r++) {
            $row = $rows[$r]
            [void]$body.Append("<row r=`"$($r+1)`">")
            for ($c = 0; $c -lt $row.Count; $c++) {
                $address = "$([char](65+$c))$($r+1)"
                $style = if ($r -eq 2) { 1 } else { 0 }
                [void]$body.Append("<c r=`"$address`" s=`"$style`" t=`"inlineStr`"><is><t xml:space=`"preserve`">$(XmlText $row[$c])</t></is></c>")
            }
            [void]$body.Append('</row>')
        }
        $end = [char](64 + $sheet.Value[0].Count)
        AddPart "xl/worksheets/sheet$index.xml" "<worksheet xmlns=`"$ns`"><sheetViews><sheetView workbookViewId=`"0`"><pane ySplit=`"3`" topLeftCell=`"A4`" activePane=`"bottomLeft`" state=`"frozen`"/></sheetView></sheetViews><cols><col min=`"1`" max=`"6`" width=`"36`" customWidth=`"1`"/></cols><sheetData>$body</sheetData><autoFilter ref=`"A3:$end$($rows.Count)`"/></worksheet>"
    }
    AddPart 'xl/styles.xml' "<styleSheet xmlns=`"$ns`"><fonts count=`"2`"><font><sz val=`"11`"/><name val=`"Calibri`"/></font><font><b/><color rgb=`"FFFFFFFF`"/><sz val=`"11`"/><name val=`"Calibri`"/></font></fonts><fills count=`"3`"><fill><patternFill patternType=`"none`"/></fill><fill><patternFill patternType=`"gray125`"/></fill><fill><patternFill patternType=`"solid`"><fgColor rgb=`"FF203F5B`"/><bgColor indexed=`"64`"/></patternFill></fill></fills><borders count=`"1`"><border/></borders><cellStyleXfs count=`"1`"><xf/></cellStyleXfs><cellXfs count=`"2`"><xf xfId=`"0`" applyAlignment=`"1`"><alignment wrapText=`"1`" vertical=`"top`"/></xf><xf xfId=`"0`" fontId=`"1`" fillId=`"2`" applyFont=`"1`" applyFill=`"1`"/></cellXfs><cellStyles count=`"1`"><cellStyle name=`"Normal`" xfId=`"0`" builtinId=`"0`"/></cellStyles></styleSheet>"
    AddPart 'xl/workbook.xml' "<workbook xmlns=`"$ns`" xmlns:r=`"$rel`"><sheets>$tabs</sheets></workbook>"
    AddPart 'xl/_rels/workbook.xml.rels' "<Relationships xmlns=`"$package`">$links<Relationship Id=`"styles`" Type=`"$rel/styles`" Target=`"styles.xml`"/></Relationships>"
    AddPart '_rels/.rels' "<Relationships xmlns=`"$package`"><Relationship Id=`"book`" Type=`"$rel/officeDocument`" Target=`"xl/workbook.xml`"/></Relationships>"
    AddPart '[Content_Types].xml' "<Types xmlns=`"http://schemas.openxmlformats.org/package/2006/content-types`"><Default Extension=`"rels`" ContentType=`"application/vnd.openxmlformats-package.relationships+xml`"/><Default Extension=`"xml`" ContentType=`"application/xml`"/><Override PartName=`"/xl/workbook.xml`" ContentType=`"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml`"/><Override PartName=`"/xl/styles.xml`" ContentType=`"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml`"/>$types</Types>"
} finally {
    $zip.Dispose()
}
[IO.File]::Move($temp, $Path)
