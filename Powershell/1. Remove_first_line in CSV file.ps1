# Ten skrypt służy do usunięcia pierwszej linijki w pliku csv, 
# Pierwsza linijka zawiera nazwy kolumn, które nie pozwalaja na poprawne odczytanie danych. 


# Ścieżka do pliku CSV, który chcesz modyfikować
$sciezkaDoPliku = "\\192.168.0.250\share\Intranet\Department\xxx\xxx\file.csv"

# Sprawdzenie, czy plik istnieje
if (Test-Path $sciezkaDoPliku) {
    # Odczytanie zawartości pliku
    $zawartosc = Get-Content $sciezkaDoPliku | Select-Object -Skip 1

    # Zapisanie zmodyfikowanej zawartości do pliku
    $zawartosc | Out-File -FilePath $sciezkaDoPliku -Force -Encoding UTF8

    Write-Host "Usunięto pierwszą linijkę z pliku CSV."
}
else {
    Write-Host "Plik nie istnieje. Sprawdź ścieżkę pliku i uruchom skrypt ponownie."
}
