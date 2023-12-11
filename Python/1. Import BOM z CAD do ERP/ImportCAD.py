import os
import csv
import xml.etree.ElementTree as ET
import tkinter as tk
from tkinter import messagebox, filedialog
import webbrowser

global file_path
xml = None


def open_file():
    file_path = filedialog.askopenfile(mode='r', filetypes=[('CSV Files', '*.csv')])
    if file_path is not None:
        return file_path.name
    return None


def convert_row(headers, line, file_path):
    for item in line:
        s = f'<BOMITEM LP="{line[0]}" INDEKS="{line[1]}" JM = "{line[2]}" ILOSC = "{line[3]}" CENA = "" LINK = "{line[4]}" UWAGI = "{line[5]}" WAGA = "{line[6]}">\n'
        s += f'<OPERACJE>\n'
        s += f'<OPERACJA KOD = "MA" TJ = "1:00:00" TPZ = "1:00:00"/>\n'
        s += f'</OPERACJE>\n'
    return s + f'</BOMITEM>\n'


def save_xml(xml_content, csv_file_path):
    # Pobranie folderu gdzie plik CSV jest zlokalizowany
    csv_directory = os.path.dirname(csv_file_path)

    # Generowanie pliku XML ze zmienionym rozszerzeniem
    xml_file_path = os.path.splitext(csv_file_path)[0] + '.xml'

    try:
        # Generowanie pliku XML
        root = ET.fromstring(xml_content)
        pretty_xml = ET.tostring(root, encoding="utf-8", method="xml")

        with open(xml_file_path, 'wb') as xml_file:
            xml_file.write(pretty_xml)
        messagebox.showinfo('Zapisano', 'Plik XML został zapisany')
    except Exception as e:
        messagebox.showerror('Błąd', f'Wystąpił błąd podczas zapisywania pliku XML: {str(e)}')


# Wywołanie funkcji open_file, aby uzyskać ścieżkę do pliku
file_path = None  # Domyślnie brak wczytanego pliku


def select_csv_file():
    global file_path
    file_path = open_file()
    if file_path:
        selected_file.config(text="Wczytany plik: " + file_path)
        global xml  # Ustawić zmienną xml jako globalną, aby była dostępna poza blokiem if
        with open(file_path, 'r', newline='', encoding='utf-8') as f:
            r = csv.reader(f)
            headers = next(r)
            line = next(r)
            xml = f'<?xml version = "1.0" encoding = "UTF-8"?>\n'
            xml += f'<DANE_CAD UZYTKOWNIK="Rafał Biel">\n'
            xml += f'<PRODUKT INDEKS="{line[1]}" JM="{line[2]}" ILOSC="{line[3]}" CENA="" LINK="{line[4]}" UWAGI="{line[5]}" WAGA="{line[6]}">\n'
            xml += f'</PRODUKT>\n'
            xml += f'<BOM>\n'
            for row in r:
                xml += convert_row(headers, row, file_path) + '\n'
            xml += f'</BOM>'
            xml += f'</DANE_CAD>'


def save_xml_wrapper():
    if xml and file_path:
        save_xml(xml, file_path)


def open_documentation():
    webbrowser.open_new(r"file://C:/Users/rafal.biel/Desktop/Import Danych z CAD/cad.json")


# Tworzenie głównego okna
window = tk.Tk()
window.title("SolidEdge <=> Import danych CAD => Streamsoft Prestiż")
window.geometry("500x200")

# Etykieta do opisu programu
main_label = tk.Label(window,
                      text="Aplikacja do konwersji plików CSV z Solida\n do przeprowadzenia Importu danych z CAD.")
main_label.pack(pady=5)

# Przycisk "Importuj plik"
select_file = tk.Button(window, text="Wybierz plik", command=select_csv_file)
select_file.pack(pady=5)

# Label o wczytanym pliku
selected_file = tk.Label(window, text="Wczytany plik: ")
selected_file.pack(pady=5)

# Przycisk "Zapisz XML"

save_button = tk.Button(window, text="Zapisz XML", command=save_xml_wrapper)
save_button.pack(pady=5)

# Etykieta z linkiem do dokumentacji
docu_label = tk.Label(window, text="Dokumentacja do aplikacji znajduje się tutaj.")
docu_label.pack(pady=5)

# Otwieranie linku w przeglądarce po kliknięciu

docu_label.bind("<Button-1>", lambda event: open_documentation())

# Tworzenie paska na dole z informacją o twórcy
creator_label = tk.Label(window, text="Created by Rafał Biel", relief=tk.SUNKEN, anchor=tk.W)
creator_label.pack(side=tk.BOTTOM, fill=tk.X)

# Uruchomienie aplikacji
window.mainloop()
