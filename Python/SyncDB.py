import configparser
import smtplib
import time
import tkinter as tk
from email.mime.text import MIMEText
from tkinter import messagebox
from tkinter.ttk import Progressbar

import fdb
import pyodbc
import schedule

config = configparser.ConfigParser()
config.read('config.ini')

# Dane konfiguracyjne SMTP
SMTP_HOST = config.get('SMTP', 'host')
SMTP_PORT = int(config.get('SMTP', 'port'))
SMTP_USERNAME = config.get('SMTP', 'username')
SMTP_PASSWORD = config.get('SMTP', 'password')
EMAIL_FROM = config.get('Email', 'from')
EMAIL_TO = config.get('Email', 'to')

# Dane konfiguracyjne Firebird
firebird_dsn = config.get('Firebird', 'firebird_dsn')
firebird_username = config.get('Firebird', 'firebird_username')
firebird_password = config.get('Firebird', 'firebird_password')

# Dane konfiguracyjne MSSQL
mssql_server = config.get('MSSQL', 'server')
mssql_database = config.get('MSSQL', 'database')
mssql_username = config.get('MSSQL', 'username')
mssql_password = config.get('MSSQL', 'password')

scheduled_jobs = []
schedule_combobox = None  # Zadeklarowanie zmiennej jako globalnej
schedule_table = None  # Zadeklarowanie zmiennej jako globalnej

class CreateToolTip(object):
    """
    create a tooltip for a given widget
    """

    def __init__(self, widget, text='widget info'):
        self.waittime = 500  # miliseconds
        self.wraplength = 180  # pixels
        self.widget = widget
        self.text = text
        self.widget.bind("<Enter>", self.enter)
        self.widget.bind("<Leave>", self.leave)
        self.widget.bind("<ButtonPress>", self.leave)
        self.id = None
        self.tw = None

    def enter(self, event=None):
        self.schedule()

    def leave(self, event=None):
        self.unschedule()
        self.hidetip()

    def schedule(self):
        self.unschedule()
        self.id = self.widget.after(self.waittime, self.showtip)

    def unschedule(self):
        id = self.id
        self.id = None
        if id:
            self.widget.after_cancel(id)

    def showtip(self, event=None):
        x = y = 0
        x, y, cx, cy = self.widget.bbox("insert")
        x += self.widget.winfo_rootx() + 25
        y += self.widget.winfo_rooty() + 20
        # creates a toplevel window
        self.tw = tk.Toplevel(self.widget)
        # Leaves only the label and removes the app window
        self.tw.wm_overrideredirect(True)
        self.tw.wm_geometry("+%d+%d" % (x, y))
        label = tk.Label(self.tw, text=self.text, justify='left',
                         background="#ffffff", relief='solid', borderwidth=1,
                         wraplength=self.wraplength)
        label.pack(ipadx=1)

    def hidetip(self):
        tw = self.tw
        self.tw = None
        if tw:
            tw.destroy()

def delete_XXX_RCP_EVENTS_Table():
    global firebird_connection

    try:
        # Utwórz połączenie do bazy danych Firebird
        firebird_connection = fdb.connect(
            dsn=firebird_dsn,
            user=firebird_username,
            password=firebird_password
        )
        firebird_cursor = firebird_connection.cursor()

        query = "DELETE FROM XXX_RCP_EVENTS"
        firebird_cursor.execute(query)

        # Zatwierdź zmiany w bazie danych Firebird
        firebird_connection.commit()
        print("Cleaning completed successfully.")

        # Zapisz informację o udanym czyszczeniu tabeli do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Successful cleaning\n")

    except Exception as e:
        # W przypadku błędu, wycofaj zmiany w bazie danych Firebird
        firebird_connection.rollback()
        print("An error occurred during cleaning:", str(e))

        # Zapisz informację o błędzie do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Error during cleaning: {}\n".format(str(e)))

    finally:
        # Zamknij połączenie z baza firebird
        firebird_cursor.close()
        firebird_connection.close()

def delete_XXX_RCP_SCHEDULE_Table():
    global firebird_connection

    try:
        # Utwórz połączenie do bazy danych Firebird
        firebird_connection = fdb.connect(
            dsn=firebird_dsn,
            user=firebird_username,
            password=firebird_password
        )
        firebird_cursor = firebird_connection.cursor()

        query = "DELETE FROM XXX_RCP_SCHEDULES"
        firebird_cursor.execute(query)

        # Zatwierdź zmiany w bazie danych Firebird
        firebird_connection.commit()
        print("Cleaning completed successfully.")

        # Zapisz informację o udanym czyszczeniu tabeli do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Successful cleaning\n")

    except Exception as e:
        # W przypadku błędu, wycofaj zmiany w bazie danych Firebird
        firebird_connection.rollback()
        print("An error occurred during cleaning:", str(e))

        # Zapisz informację o błędzie do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Error during cleaning: {}\n".format(str(e)))

    finally:
        # Zamknij połączenie z baza firebird
        firebird_cursor.close()
        firebird_connection.close()

def synchronize_databases():
    # Dodaj zmienne jako globalne
    global firebird_connection, mssql_connection
    try:
        # Utwórz połączenie do bazy danych Firebird
        firebird_connection = fdb.connect(
            dsn=firebird_dsn,
            user=firebird_username,
            password=firebird_password
        )
        firebird_cursor = firebird_connection.cursor()

        # Utwórz połączenie do bazy danych MSSQL
        mssql_connection = pyodbc.connect(
            f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={mssql_server};DATABASE={mssql_database};UID={mssql_username};PWD={mssql_password}'
        )
        mssql_cursor = mssql_connection.cursor()

        # Pobierz rekordy z bazy danych MSSQL

        mssql_statement ="SELECT be.USER_ID, be.CHECK_TIME , be.CHECK_TYPE, bu.EXT_BADGE, CONVERT(DATE,be.CHECK_TIME) AS DATA, CONVERT(TIME,be.CHECK_TIME) AS CZAS, DATEPART(HOUR, be.CHECK_TIME) AS CZAS_GODZINY, ROUND((CAST(DATEPART(MINUTE, be.CHECK_TIME) AS FLOAT)/ 60), 4) AS CZAS_MINUTY, DATEPART(HOUR, brac.ACCEPTED) + ROUND((CAST(DATEPART(MINUTE, brac.ACCEPTED) AS FLOAT)/ 60), 4) AS NADGODZINY50, DATEPART(HOUR, brac2.ACCEPTED) + ROUND((CAST(DATEPART(MINUTE, brac2.ACCEPTED) AS FLOAT)/ 60), 4) AS NADGODZINY100, DATEPART(HOUR, be.CHECK_TIME) + ROUND((CAST(DATEPART(MINUTE, be.CHECK_TIME) AS FLOAT)/ 60), 4) AS CZAS_SUMA FROM [AR-RCP].dbo.BS_EVENT be left JOIN [AR-RCP].dbo.BS_USER bu on bu.ID = be.USER_ID left JOIN [AR-RCP].dbo.BS_RCP_ACCEPTED_OVERHOURS brac ON brac.EVENT_FROM_ID = be.ID AND brac.TYPE = 1 left JOIN [AR-RCP].dbo.BS_RCP_ACCEPTED_OVERHOURS brac2 ON brac2.EVENT_FROM_ID = be.ID AND brac2.TYPE = 2 WHERE ((be.ACTIVE = 1) AND (be.CHECK_TIME >= dateadd(MONTH, -1, datefromparts(YEAR(getdate()), MONTH(getdate()), 1)) AND be.CHECK_TIME < datefromparts(YEAR(getdate()), MONTH(getdate()), 1)))"
        mssql_cursor.execute(mssql_statement)
        mssql_records = mssql_cursor.fetchall()

        # Pasek postępu
        progress_bar["maximum"] = len(mssql_records)
        progress_bar["value"] = 0

        # Dla każdego rekordu w bazie MSSQL
        for mssql_record in mssql_records:
            # Zbuduj zapytanie MERGE INTO dla Firebird
            query = "UPDATE OR INSERT INTO XXX_RCP_EVENTS (USER_ID, CHECK_TIME, CHECK_TYPE, EXT_BADGE, DATA, CZAS, CZAS_GODZINY, CZAS_MINUTY, NADGODZINY50, NADGODZINY100, CZAS_SUMA) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) MATCHING (USER_ID, CHECK_TIME)"
            firebird_cursor.execute(query, tuple(mssql_record))

            # Aktualizuj pasek postępu
            progress_bar["value"] += 1
            window.update()

        # Zatwierdź zmiany w bazie danych Firebird
        firebird_connection.commit()
        print("Synchronization completed successfully.")

        # Zapisz informację o udanej synchronizacji do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Successful synchronization\n")

        # Wyślij wiadomość e-mail z potwierdzeniem udanej synchronizacji
        send_email('Successful synchronization', 'Synchronization completed successfully.')

    except Exception as e:
        # W przypadku błędu, wycofaj zmiany w bazie danych Firebird
        firebird_connection.rollback()
        print("An error occurred during synchronization:", str(e))

        # Zapisz informację o błędzie do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Error during synchronization: {}\n".format(str(e)))

    finally:
        # Zamknij połączenia
        firebird_cursor.close()
        firebird_connection.close()
        mssql_cursor.close()
        mssql_connection.close()


def synchronize_schedules():
    # Dodaj zmienne jako globalne
    global firebird_connection, mssql_connection
    try:
        # Utwórz połączenie do bazy danych Firebird
        firebird_connection = fdb.connect(
            dsn=firebird_dsn,
            user=firebird_username,
            password=firebird_password
        )
        firebird_cursor = firebird_connection.cursor()

        # Utwórz połączenie do bazy danych MSSQL
        mssql_connection = pyodbc.connect(
            f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={mssql_server};DATABASE={mssql_database};UID={mssql_username};PWD={mssql_password}'
        )
        mssql_cursor = mssql_connection.cursor()

        # Pobierz rekordy z bazy danych MSSQL
        mssql_statement = "SELECT bu.EXT_BADGE AS ID, brs.[DAY] AS DZIEN , brs2.NAME AS ZMIANA_RCP, CASE WHEN brs2.NAME = 'Biuro' THEN 'B' WHEN brs2.name = 'Zmiana__I' THEN 'I' WHEN brs2.name = 'Zmiana__II' THEN 'II' WHEN brs2.name = 'Zmiana__III' THEN 'III' WHEN brs2.name = 'Biuro_7' THEN '7' WHEN brs2.name = 'Biuro_730' THEN '7,5' END AS ZMIANA_PRESTIGE, CASE WHEN brs2.NAME = 'Zmiana__I' THEN CAST(10001 AS INTEGER) WHEN brs2.NAME = 'Zmiana__II' THEN CAST(10002 AS INTEGER) WHEN brs2.NAME = 'Zmiana__III' THEN CAST(10003 AS INTEGER) WHEN brs2.NAME = 'Biuro' THEN CAST(10004 AS INTEGER) WHEN brs2.NAME = 'Biuro_7' THEN CAST(10010 AS INTEGER) WHEN brs2.NAME = 'Biuro_730' THEN CAST(10011 AS INTEGER) END AS ID_SYMBOLDNIWZORCA FROM BS_RCP_SCHEDULE brs LEFT JOIN BS_RCP_SHIFT brs2 ON brs2.ID = brs.RCP_SHIFT_ID LEFT JOIN BS_USER bu ON bu.ID = brs.USER_ID WHERE bu.BADGE >0 AND brs.RCP_SHIFT_ID IS NOT NULL AND brs.[DAY] >= dateadd(MONTH, -1, datefromparts(YEAR(getdate()), MONTH(getdate()), 1)) AND brs.[DAY] <= DATEFROMPARTS(YEAR(EOMONTH(GETDATE())), MONTH(EOMONTH(GETDATE())), DAY(EOMONTH(GETDATE())))"
        mssql_cursor.execute(mssql_statement)
        mssql_records = mssql_cursor.fetchall()


        # Pasek postępu
        progress_bar["maximum"] = len(mssql_records)
        progress_bar["value"] = 0

        # Dla każdego rekordu w bazie MSSQL
        for mssql_record in mssql_records:
            # Zbuduj zapytanie MERGE INTO dla Firebird
            query = "UPDATE OR INSERT INTO XXX_RCP_SCHEDULES (RCP_ID, RCP_DZIEN, RCP_ZMIANA, PRESTIGE_ZMIANA, ZMIANA_ID ) VALUES (?, ?, ?, ?, ?) MATCHING (RCP_ID, RCP_DZIEN)"
            firebird_cursor.execute(query, tuple(mssql_record))

            # Aktualizuj pasek postępu
            progress_bar["value"] += 1
            window.update()

        # Zatwierdź zmiany w bazie danych Firebird
        firebird_connection.commit()
        print("Synchronization completed successfully.")

        # Zapisz informację o udanej synchronizacji do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Successful synchronization\n")

        # Wyślij wiadomość e-mail z potwierdzeniem udanej synchronizacji
        send_email('Successful synchronization', 'Synchronization completed successfully.')

    except Exception as e:
        # W przypadku błędu, wycofaj zmiany w bazie danych Firebird
        firebird_connection.rollback()
        print("An error occurred during synchronization:", str(e))

        # Zapisz informację o błędzie do pliku error.log
        with open("error.log", "a") as log_file:
            log_file.write("Error during synchronization: {}\n".format(str(e)))

    finally:
        # Zamknij połączenia
        firebird_cursor.close()
        firebird_connection.close()
        mssql_cursor.close()
        mssql_connection.close()


def send_email(subject, body):
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = EMAIL_FROM
    msg['To'] = EMAIL_TO

    with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as smtp:
        smtp.login(SMTP_USERNAME, SMTP_PASSWORD)
        smtp.send_message(msg)


def synchronize_button_click():
    delete_XXX_RCP_EVENTS_Table()
    synchronize_databases()
    messagebox.showinfo("Synchronizacja", "Synchronizacja została przeprowadzona pomyślnie.")


def synchronize_schedule_button_click():
    delete_XXX_RCP_SCHEDULE_Table()
    synchronize_schedules()
    messagebox.showinfo("Synchronizacja grafików", "Synchronizacja została przeprowadzona pomyślnie.")


def schedule_button_click():
    selected_time = schedule_combobox.get()
    job = schedule.every().day.at(selected_time).do(synchronize_databases)
    scheduled_jobs.append(job)
    schedule_table.insert('', 'end', text=str(len(scheduled_jobs)), values=(selected_time, 'Aktywne', 'Synchronizacja'))


def remove_schedule_button_click():
    selected_items = schedule_table.selection()
    if selected_items:
        for item in selected_items:
            index = int(schedule_table.item(item, 'text'))
            job = scheduled_jobs.pop(index - 1)
            schedule.cancel_job(job)
            schedule_table.delete(item)


def minimize_to_tray():
    window.iconify()


def close_program():
    window.destroy()


def show_window_from_tray(icon, item):
    window.deiconify()


# Tworzenie głównego okna
window = tk.Tk()
window.title("Synchronizator RCP->Prestiż")
window.geometry("300x200")

# Tworzenie paska menu
menu_bar = tk.Menu(window)
window.config(menu=menu_bar)

# Dodawanie opcji w menu
file_menu = tk.Menu(menu_bar, tearoff=0)
program_menu = tk.Menu(menu_bar, tearoff=0)
settings_menu = tk.Menu(menu_bar, tearoff=0)

# Dodawanie opcji w menu "Program"
menu_bar.add_cascade(label="Program", menu=program_menu)
program_menu.add_command(label="Zminimalizuj do tray", command=minimize_to_tray)
program_menu.add_command(label="Zamknij", command=close_program)

# Pasek postępu synchronizacji
progress_bar = Progressbar(window, orient="horizontal", length=200, mode="determinate")
progress_bar.pack(pady=10)

# Przycisk "Synchronizuj Grafiki"
sync_button = tk.Button(window, text="Synchronizuj grafiki", command=synchronize_schedule_button_click)
sync_button.pack(pady=5)
sync_button_ttp = CreateToolTip(sync_button, \
                                "Synchronizacja może odbyć się w dowolnym momencie"
                                )

# Przycisk "Synchronizuj Bazy"
sync_button1 = tk.Button(window, text="Synchronizuj obecności", command=synchronize_button_click)
sync_button1.pack(pady=5)
sync_button_ttp = CreateToolTip(sync_button1, \
                                "Synchronizacja obecności zaciągana jest w algorytmie: Obecny miesiąc -1."
                                "Przykład: Zaciągamy obecności z Lipca to musimy je zrobić w Sierpniu aby program widział dane z Lipca."
                                )

# Tworzenie paska na dole z informacją o twórcy
creator_label = tk.Label(window, text="Created by Rafał Biel", relief=tk.SUNKEN, anchor=tk.W)
creator_label.pack(side=tk.BOTTOM, fill=tk.X)

# Uruchomienie głównej pętli aplikacji
window.mainloop()
