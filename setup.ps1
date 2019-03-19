# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# enable tls12 to be able to download from github.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# enable execute *.ps1
$exe_policy = Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Force 

function GetValidPath
{
    if( $env:USERPROFILE -match "[^\x01-\x7E]" )
    {
        mkdir "C:\tools\"
        return "C:\tools\"
    } else 
    {
        $env:USERPROFILE
    }
}

function down{
    Param( $url, $name)

    $down = GetValidPath + "\Downloads"

    $zip = $down + "\\${name}.zip"
    $dst = $down + "\\${name}"

    (New-Object System.Net.WebClient).DownloadFile($url, $zip)
    Expand-Archive $zip $dst
    return $dst
}

$down = GetValidPath + "\Downloads"

$yamy_url = "https://ja.osdn.net/frs/redir.php?m=jaist&f=yamy%2F43637%2Fyamy-0.03.zip"
$yamy_dst = down -url $yamy_url -name yamy

$dim_url = "http://www.dcmembers.com/skrommel/download/dimscreen/?wpdmdl=274&refresh=5bfd4fd861c641543327704"
$dim_dst = down -url $dim_url -name dim

$nodoka_url = "https://github.com/ryosuke-mondo/nodoka-excel/archive/master.zip"
$nodoka_dst = down -url $nodoka_url -name nodoka

function yamy_config
{
    Param($down)

    $yamy_setting = ".mayu0=hm;" + $down + "\yamy\bskbb22_master.nodoka;-DUSE104;-DUSEdefault"

    #ファイル読み込み
    $filePath = Join-Path $down "yamy\yamy.ini"

    Copy-Item (Join-Path $down "nodoka\nodoka-excel-master\bskbb22-hm\*.nodoka") (Join-Path $down "yamy")

    Get-Content $filepath | tee -Variable fileContent

    #正規表現で置換＆保存
    $input = '(.mayu0=.*)'
    $replacement = $yamy_setting
    $fileContent -replace $input, $replacement | tee -FilePath $filepath
}

yamy_config -down $down

Invoke-Item $yamy_dst\yamy.exe
Invoke-Item $dim_dst\DimScreen\DimScreen.exe


choco install vim -y
choco install teamviewer -y
choco install git -y

# restore
Set-ExecutionPolicy $exe_policy -Force
