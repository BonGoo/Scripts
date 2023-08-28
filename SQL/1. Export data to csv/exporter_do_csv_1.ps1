$pliki_sql = Get-ChildItem -Path "D:\exporty_b2b\SQL_files" | Foreach-Object {$_.BaseName}  #Pobranie nazw plików w folderze sql_files


ForEach ($plik_sql in $pliki_sql){
    Invoke-Sqlcmd -InputFile "D:\exporty_b2b\SQL_files\$plik_sql.sql" `
    -Database CDN_DB `
    -Server localhost |
    Export-Csv `
    -Path "D:\exporty_b2b\wyeksportowane\$plik_sql.csv" `
    -Delimiter ";" `
    -NoTypeInformation `
    -Encoding UTF8 

    $Client = New-Object System.Net.WebClient
    $Client.Credentials = New-Object System.Net.NetworkCredential("xxxxx", "xxxxxxx")
    $Client.UploadFile("ftp://s.server.pl/$plik_sql/$plik_sql.csv", "D:\exporty_b2b\wyeksportowane\$plik_sql.csv")
}
