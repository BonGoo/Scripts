$pliki_sql = Get-ChildItem -Path "D:\exporty_b2b\SQL_files\Tyre24" | Foreach-Object { $_.BaseName }

ForEach ($plik_sql in $pliki_sql){
    Invoke-Sqlcmd -InputFile "D:\exporty_b2b\SQL_files\Tyre24\$plik_sql.sql" `
    -Database CDN_DB `
    -Server localhost |
    Export-Csv `
    -Path "D:\exporty_b2b\wyeksportowane\$plik_sql.csv" `
    -Delimiter ";" `
    -NoTypeInformation `
    -Encoding UTF8

    $Client = New-Object System.Net.WebClient
    $Client.Credentials = New-Object System.Net.NetworkCredential("xxxxxx", "xxxxxxx")

    $localFile = "D:\exporty_b2b\wyeksportowane\$plik_sql.csv"
    $remoteFile = "/$plik_sql.csv"
    $ftpUrl = "ftp://server.com$remoteFile"

    try {
        $Client.UploadFile($ftpUrl, $localFile)
        Write-Host "Plik $plik_sql.csv został wysłany na serwer FTPS."
    } catch {
        Write-Host "Błąd podczas wysyłania pliku $plik_sql.csv na serwer FTPS: $_"
    } finally {
        $Client.Dispose()
    }
}
