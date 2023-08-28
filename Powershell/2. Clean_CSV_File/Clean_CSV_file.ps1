# Zadaniem tego plikuj jest przygotowanie go do importu w aplikacji 
# Część 1 skryptu. Zmienia nazwy plików z PLIK_20231291 - która za każdym razem zawiera w nazwie, date eksportu, na CZP-RCP

# Ścieżka do katalogu zawierającego pliki
$csvPath = "\\192.168.0.250\arcom_share\Intranet\Department\Kadry\RCP"

# Pobierz listę plików z podanego katalogu
$pliki = Get-ChildItem -Path $csvPath

# Przejdź przez każdy plik i zmień jego nazwę, jeśli zaczyna się od "CZP-RCP"
foreach ($plik in $pliki) {
    # Sprawdź, czy nazwa pliku zaczyna się od "CZP-RCP"
    if ($plik.Name -like "CZP-RCP*") {
        # Pobierz indeks pierwszego wystąpienia znaku "_"
        $indeks = $plik.Name.IndexOf("_")
        
        # Utwórz nową nazwę pliku bez części po pierwszym znaku "_"
        $nowaNazwa = $plik.Name.Substring(0, $indeks) + ".csv"
        
        # Utwórz nową ścieżkę pliku
        $nowaSciezka = Join-Path -Path $csvPath -ChildPath $nowaNazwa
        
        # Zmień kodowanie pliku na ANSI i zapisz go w nowej lokalizacji
        (Get-Content -Path $plik.FullName -Encoding UTF8) | Set-Content -Path $nowaSciezka -Encoding oem
        
        # Usuń oryginalny plik
        Remove-Item -Path $plik.FullName
    }
}

Write-Host "Nazwy plików zostały zmienione i zapisane w kodowaniu ANSI."

# Część 2 skryptu. Służy do "wysprzatania" pliku który, na 9 pozycji w pliku CSV, czyści plik danych, ponieważ dla analizy danych, dane mniejsze niż 1h sa bezużyteczne .  

# Ścieżka do pliku CSV
$csvPath = "\\192.168.0.250\share\Intranet\xxx\CZP-RCP.csv"

# Wczytaj zawartość pliku CSV
$csvContent = Get-Content -Path $csvPath

# Zmodyfikuj dziewiątą wartość dla każdego wiersza
for ($i = 0; $i -lt $csvContent.Count; $i++) {
    $row = $csvContent[$i]

    # Podziel wiersz na pola
    $fields = $row -split ';'

    # Sprawdź czy istnieje dziewiąta wartość
    if ($fields.Length -ge 9) {
        $ninthValue = $fields[8].Trim()

        # Sprawdź czy wartość jest mniejsza niż "01:00:00" i różna od "00:00:00"
        if ($ninthValue -lt "01:00:00" -and $ninthValue -ne "00:00:00") {
            # Zmień dziewiątą wartość na "00:00:00"
            $fields[8] = "00:00:00"
        }
    }

    # Połącz zmodyfikowane pola w wiersz
    $modifiedRow = $fields -join ';'

    # Zaktualizuj zawartość pliku CSV
    $csvContent[$i] = $modifiedRow
}

# Zapisz zmieniony plik CSV
$csvContent | Set-Content -Path $csvPath
