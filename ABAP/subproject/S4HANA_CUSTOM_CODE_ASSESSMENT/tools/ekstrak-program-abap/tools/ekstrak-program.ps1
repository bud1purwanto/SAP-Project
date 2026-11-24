param([string]$Pilihan, [switch]$TanpaBuka)
$ErrorActionPreference = 'Stop'
$tempSource = $null
try {
    $project = Split-Path $PSScriptRoot
    $data = Join-Path (Split-Path $project) 'SAP-Agent-Discovery-Platform\data'
    if (-not $Pilihan) {
        $Pilihan = Read-Host 'Masukkan nama program/T-code, file .abap, atau SAP:NAMA untuk membaca langsung dari SAP DEV'
    }
    $Pilihan = $Pilihan.Trim().Trim('"')
    if (-not $Pilihan) { throw 'Belum ada program yang dipilih.' }
    $live = $Pilihan.StartsWith('SAP:', [StringComparison]::OrdinalIgnoreCase)
    if ($live) { $Pilihan = $Pilihan.Substring(4).Trim() }
    if ($Pilihan -match '^(?:/[a-z0-9_]+/)?[a-z0-9_=]+$') {
            Write-Host 'Membaca repository SAP development secara baca-saja...'
            $discovery = Join-Path (Split-Path $project) 'discovery-ai-tools'
            # Distribusi yang diekstrak ke artifacts juga dapat memakai driver workspace.
            $parent = Split-Path $project
            if ((Split-Path $parent -Leaf) -eq 'artifacts') {
                $workspaceTools = Join-Path (Split-Path (Split-Path $parent)) 'discovery-ai-tools'
                if (Test-Path (Join-Path $workspaceTools 'node_modules/node-rfc')) { $discovery = $workspaceTools }
            }
            if (-not $env:ABAP_RFC_PACKAGE -and -not (Test-Path (Join-Path $project 'node_modules/node-rfc')) -and (Test-Path (Join-Path $discovery 'node_modules/node-rfc'))) {
                $env:ABAP_RFC_PACKAGE = Join-Path $discovery 'package.json'
            }
            $tempSource = Join-Path ([IO.Path]::GetTempPath()) ('abap-read-' + [guid]::NewGuid())
            [IO.Directory]::CreateDirectory($tempSource) | Out-Null
            $nama = & node.exe (Join-Path $PSScriptRoot 'ambil-source.mjs') $Pilihan.ToUpperInvariant() $tempSource
            if ($LASTEXITCODE -ne 0 -or -not $nama) { throw 'Source SAP belum diperoleh. Lihat pesan di atas.' }
            $source = Join-Path $tempSource "$nama.abap"
    } else {
        $source = $Pilihan
    }
    if ([IO.Path]::GetExtension($source) -ne '.abap' -or -not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Source lokal belum ditemukan untuk $Pilihan. Masukkan lokasi lengkap file .abap atau seret file ke peluncur."
    }
    $source = (Get-Item -LiteralPath $source).FullName
    $node = Get-Command node.exe -ErrorAction SilentlyContinue
    if (-not $node) { throw 'Node.js belum tersedia di PATH.' }
    $name = [IO.Path]::GetFileNameWithoutExtension($source)
    $run = "$name-$(Get-Date -Format yyyyMMdd-HHmmss-fff)-$([guid]::NewGuid().ToString('N').Substring(0,8))"
    $folder = Join-Path $project "artifacts\ekstraksi-abap\$run"
    $sourceFolder = Join-Path $folder 'source'
    [IO.Directory]::CreateDirectory($sourceFolder) | Out-Null
    [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
    $lines = & $node.Source (Join-Path $PSScriptRoot 'ringkas-abap.mjs') $source $sourceFolder
    if ($LASTEXITCODE -ne 0) { throw "Pembacaan source gagal. Hasil parsial: $folder" }
    if ($tempSource) {
        Get-ChildItem -LiteralPath $tempSource -File -Filter '*.abap' | Copy-Item -Destination $sourceFolder
        $lines = @(Get-Content -Encoding UTF8 -LiteralPath (Join-Path $tempSource 'scan.txt')) + @('','INVENTARIS PROGRAM UTAMA') + @($lines)
    }
    $file = Join-Path $folder "$name.txt"
    $origin = if ($tempSource) { "Source SAP development (RFC baca-saja): $nama" } else { "Source lokal: $source" }
    [IO.File]::WriteAllLines($file, [string[]](@("Input: $Pilihan", $origin, '') + $lines), [Text.UTF8Encoding]::new($true))
    Write-Host "Hasil tersimpan di $file"
    $excel = [IO.Path]::ChangeExtension($file, '.xlsx')
    & (Join-Path $PSScriptRoot 'ekspor-excel.ps1') -Path $excel -InputName $Pilihan -Origin $origin -Lines $lines
    Write-Host "Excel tersimpan di $excel"
    if (-not $TanpaBuka) { Invoke-Item -LiteralPath $excel }
} catch {
    Write-Host $_.Exception.Message
    exit 1
} finally {
    if ($tempSource -and (Test-Path -LiteralPath $tempSource)) {
        Get-ChildItem -LiteralPath $tempSource -File -Filter '*.abap' | Remove-Item
        $scanLog = Join-Path $tempSource 'scan.txt'
        if (Test-Path -LiteralPath $scanLog) { Remove-Item -LiteralPath $scanLog }
        Remove-Item -LiteralPath $tempSource
    }
}
