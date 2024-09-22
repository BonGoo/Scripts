'''
    1.0 - 16.07.2024 - Wersja startowa. Zawiera listę rozwijana, oraz dwa przyciski dla stop i start.
    1.1 - 05.08.2024 - Wprowadzenie powiadomienia o, że postój został poprawnie zapisany.
    1.2 - 07.08.2024 - Wprowadzenie Komunikatu o błędzie braku połaczenia z siecia oraz uniemożliwienie
                       kliknięcia przyisku Start bez kliknięcia przysicku Stop

    2.0 - 13.09.2024 - Optymalizacje wydajności aplikacji,
                       Całkowite przebudowanie narzędzia, od teraz aplikacja czeka na stan przycisku i wyświetla
                       odpowiedni Popup o podanie przyczyny dopiero przy wciśnięciu fizycznego przycisku,
                       Czas wyświtlenia okna będzie trwać prez 5 minut od usunięcia awari na przycisku
                       Wprowadzenie pliku error log który zbiera debugi do weryfikacji aplikacji
'''

from contextlib import contextmanager
import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime
import fdb
from stan_lakierni import odczytaj_stan


TimeTo = 300
previous_gp_state = None
start_time = None
stop_time = None

version = 2.0

def update_label():
    global previous_gp_state
    gp_state = odczytaj_stan()  # Wywołanie funkcji z pliku stan_lakierni

    if gp_state == 0:
        status_label.config(text="Lakiernia działa poprawnie...",font=('Calibri', 25),
                            foreground='green', justify='center')
        status_label.pack(pady=10, expand=True)
        if previous_gp_state == 1:
            create_stop_reason_frame()
            start_countdown(TimeTo)
    elif gp_state == 1:
        status_label.config(text="Lakiernia została zatrzymana i nie działa od: {}".format(stop_time), font=('Calibri', 25),
                            foreground='red', justify='center')
        status_label.pack(pady= 10, expand=True)
        remove_stop_reason_frame()
    else:
        status_label.config(text="Stan przycisku: Nieznany")

    previous_gp_state = gp_state

    status_label.after(500, update_label)

def create_stop_reason_frame():
    # Sprawdzenie, czy LabelFrame już istnieje (żeby nie tworzyć wielu na raz)
    if "label_frame" not in globals():
        global label_frame, countdown_label

        label_frame = tk.LabelFrame(window, text="Podaj powód zatrzymania lakierni", padx=5, pady=5)
        label_frame.pack(padx=5, pady=5, fill="both", expand=True)

        label_var = tk.StringVar()
        combobox = ttk.Combobox(label_frame, textvariable=label_var, state='readonly', width=30)
        combobox.pack(pady=15)
        combobox['values'] = ("Błąd mechaniczny", "Brak materiału", "Awaria elektryczna")

        sync_button = tk.Button(label_frame, text="Wyślij powód zatrzymania")
        sync_button.pack(pady=5)

        countdown_label = tk.Label(label_frame, text="Okno zniknie za 3 minuty")
        countdown_label.pack(pady=10)

def start_countdown(time_left):
    global countdown_label
    if time_left > 0:
        countdown_label.config(text=f"Okno zniknie za {time_left} sekund")
        # Aktualizuj licznik co sekundę
        window.after(100, start_countdown, time_left - 1)
    else:
        remove_stop_reason_frame()

def remove_stop_reason_frame():
    # Sprawdzenie, czy LabelFrame istnieje i usunięcie go
    if "label_frame" in globals():
        label_frame.destroy()
        del globals()['label_frame']  # Usuń referencję do label_frame

#Uruchomienie aplikacji
window = tk.Tk()
window.title("Zegar Przestoju - Lakierni")
window.geometry("650x300")
window.state("zoomed")

# Utwórz LabelFrame dla Statusu lakierni
status_frame = tk.LabelFrame(window, text="Status lakierni", padx=5, pady=5)
status_frame.pack(padx=5, pady=5, fill="both", expand=True)

status_label = tk.Label(status_frame)
status_label.pack(pady=10)
update_label()

creator_label = tk.Label(window, text="Arcom - Rafał Biel: wersja {}".format(version), relief=tk.SUNKEN, anchor=tk.W)
creator_label.pack(side=tk.BOTTOM, fill=tk.X)

window.mainloop()
