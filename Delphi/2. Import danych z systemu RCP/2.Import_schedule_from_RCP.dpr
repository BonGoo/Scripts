{$ADDTYPE TForm}
{$ADDTYPE TstBitBtn}
{$ADDTYPE TstComboBox}
{$ADDTYPE TstLabel}
{$ADDTYPE TstQuery}

var
OknoModulu : TForm;
ZapytanieSQL: string;

procedure DaneWejsciowe;
var
  Synchro: TstLabel;
  Pracownik: TstComboBox;
  comboBox : TDataSource;
  ComboBoxPosition: string;

begin
  Pracownik := TstComboBox(OknoModulu.FindComponent('Pracownik'));
  Synchro := TstLabel(OknoModulu.FindComponent('DataSynchronizacji'));


  Synchro.Caption := GetFromQuerySQL('SELECT MAX(LASTSYNCHRO)FROM XXX_RCP_LASTSYNCHRO', 0);

  if Pracownik.Items.Count = 0 then
      begin
        try
           begin
                ComboBoxPosition := GetFromQuerySQL('SELECT COUNT(p.ID_PRACOWNIK)  FROM PRACOWNIK p WHERE p.WARCHIWUM = 0;',0);  // Count listy pracowników
                comboBox := OpenQuerySQL('SELECT p.KAL_NAZWISKOIMIE FROM PRACOWNIK p WHERE p.WARCHIWUM = 0 ORDER BY p.KAL_NAZWISKOIMIE ;', 0);     // Pobranie listy pracowników
           end;

          if comboBox <> nil then
          begin
            while not comboBox.dataset.eof do
            begin
              Pracownik.items.add(comboBox.DataSet.FieldByName('KAL_NAZWISKOIMIE').asstring);
              comboBox.dataset.next;
            end;
          end;
        finally
          comboBox.free;
        end;
      end;
end;


procedure ImportujWszystkichAction(Sender : TObject);

begin
    if sender is TstBitBtn then
    begin
           begin
             //ZapytanieSQL := 'INSERT INTO XXX_RAMKA (ID_DOSTAWCA, ID_WYROBGOTOWY, ILOSC, DATA_WPISU) VALUES('+QuotedStr(IDDostawca)+',' +QuotedStr(IDWyrob)+',' +QuotedStr(IloscRamek)+', CURRENT_TIMESTAMP);';
             ZapytanieSQL := 'INSERT INTO POZWZDNIPRAC ( ID_POZWZDNIPRAC, ID_WZORDNIPRAC, ID_SYMBDNIAWZORCA, "DATA") SELECT Gen_id(GEN_POZWZDNIPRACY,1), MAX(w.ID_WZORDNIPRAC) AS ID_WZORDNIPRAC, MAX(xrs.ZMIANA_ID) AS ID_SYMBOLDNIWZORCA, CAST (xrs.RCP_DZIEN AS TIMESTAMP) AS "DATA" '
             + 'FROM XXX_RCP_SCHEDULES xrs JOIN PRACOWNIK p ON p.NRUNIK = xrs.RCP_ID JOIN ANGAZ a ON a.ID_PRACOWNIK = p.ID_PRACOWNIK JOIN ZASZEREG z ON z.ID_ANGAZ = a.ID_ANGAZ JOIN WZORDNIPRAC w ON w.ID_WZORDNIPRAC = z.ID_WZORDNIPRAC WHERE p.NRUNIK IN (xrs.RCP_ID) AND z.DATAROZPOCZECIA >= ''2023-08-01 00:00:00.000'' GROUP BY p.NRUNIK, "DATA" ';

             ZapytanieSQL := 'INSERT INTO XXX_RCP_LASTSYNCHRO (LASTSYNCHRO) VALUES(CURRENT_TIMESTAMP)';
           end

        if ExecuteSQL(ZapytanieSQL, 0) = 1 then
           inf300('Pomyślnie zapisano zmiany w bazie.')
          else
        if ExecuteSQL(ZapytanieSQL, 0) <> 1 then
           inf300('Blad przy zapisie do bazy. ' + #13#10 + GetLastAPIError);

    end
end;

procedure ImportujPracownikaAction(Sender: TObject);
var
  PracownikCombo: TstComboBox;
  PracownikLabel: string;

begin
  PracownikCombo := TstComboBox(OknoModulu.FindComponent('Pracownik'));

  if Sender is TstBitBtn then
  begin
    if PracownikCombo.ItemIndex > -1 then
    begin
         PracownikLabel := GetFromQuerySQL('SELECT p.NRUNIK FROM pracownik p WHERE p.KAL_NAZWISKOIMIE ='+ QuotedStr(PracownikCombo.Items[PracownikCombo.ItemIndex]),0)
         ZapytanieSQL := 'INSERT INTO POZWZDNIPRAC ( ID_POZWZDNIPRAC, ID_WZORDNIPRAC, ID_SYMBDNIAWZORCA, "DATA") SELECT Gen_id(GEN_POZWZDNIPRACY,1), MAX(w.ID_WZORDNIPRAC) AS ID_WZORDNIPRAC, MAX(xrs.ZMIANA_ID) AS ID_SYMBOLDNIWZORCA, CAST (xrs.RCP_DZIEN AS TIMESTAMP) AS "DATA" '
             + 'FROM XXX_RCP_SCHEDULES xrs JOIN PRACOWNIK p ON p.NRUNIK = xrs.RCP_ID JOIN ANGAZ a ON a.ID_PRACOWNIK = p.ID_PRACOWNIK JOIN ZASZEREG z ON z.ID_ANGAZ = a.ID_ANGAZ JOIN WZORDNIPRAC w ON w.ID_WZORDNIPRAC = z.ID_WZORDNIPRAC WHERE p.NRUNIK ='+QuotedStr(PracownikLabel)+' AND z.DATAROZPOCZECIA >= ''2023-08-01 00:00:00.000'' GROUP BY p.NRUNIK, "DATA" ';

         if ExecuteSQL(ZapytanieSQL, 0) = 1 then
           inf300('Pomyślnie zapisano zmiany w bazie.')
          else
        if ExecuteSQL(ZapytanieSQL, 0) <> 1 then
           inf300('Blad przy zapisie do bazy. ' + #13#10 + GetLastAPIError);

    end
    else
      ShowMessage('Nic nie wybrałeś');
  end;
end;

procedure KomponentyInterfejsuOknaGlownego;
var
        Panel : TstPanel;
        Tytul,PracownikLabel,PracownikHint,Wlasciciel,WszyscyLabel,WszyscyHint, OstatniaSynchronizacja, DataSynchronizacji: TstLabel;
        PracownikCombo:TstComboBox;
        ImportujWszystkich, ImportujPracownika:TstBitBtn;
        LabelFontSize: Integer;

begin
     LabelFontSize :=10;

     begin
          Tytul := TstLabel.Create(OknoModulu);
          Tytul.parent := OknoModulu;
          Tytul.Name := 'WlascicielProcesu';
          Tytul.Caption := 'Konwersja Grafików';
          Tytul.Left := 100;
          Tytul.Top := 5;
          Tytul.Font.Style := [fsBold];
          Tytul.Font.Size := 18;

          Wlasciciel := TstLabel.Create(OknoModulu);
          Wlasciciel.parent := OknoModulu;
          Wlasciciel.Left := 50;
          Wlasciciel.Top := 70;
          Wlasciciel.Font.Size := 12;
          Wlasciciel.Caption := 'Dane wprowadza: Kadrowa';

          Panel := TstPanel.Create(OknoModulu);
          Panel.Parent := OknoModulu;
          Panel.Name := '';
          Panel.Top := 100;
          Panel.Height := 250;
          Panel.Left := 25;
          Panel.Width := 375;
          Panel.BevelKind := bsHorizontal;

          WszyscyLabel := TstLabel.Create(OknoModulu);
          WszyscyLabel.parent := Panel;
          WszyscyLabel.Name := 'WlascicielProcesu';
          WszyscyLabel.Left := 20;
          WszyscyLabel.Top := 20;
          WszyscyLabel.Font.Style := [fsBold];
          WszyscyLabel.Font.Size := 10;
          WszyscyLabel.Caption := 'Importuj wszystkich pracowników';

          WszyscyHint := TstLabel.Create(OknoModulu);
          WszyscyHint.parent := Panel;
          WszyscyHint.Caption := 'Wybierz ta opcję, po zamknięciu grafików przez kierowników. ';
          WszyscyHint.Left := 20;
          WszyscyHint.Top := 40;
          WszyscyHint.Font.Size := 7;

          OstatniaSynchronizacja := TstLabel.Create(OknoModulu);
          OstatniaSynchronizacja.parent := Panel;
          OstatniaSynchronizacja.Caption := 'Ostatnia synchronizacja :';
          OstatniaSynchronizacja.Left := 20;
          OstatniaSynchronizacja.Top := 60;
          OstatniaSynchronizacja.Font.Size := 7;

          DataSynchronizacji := TstLabel.Create(OknoModulu);
          DataSynchronizacji.parent := Panel;
          DataSynchronizacji.Name := 'DataSynchronizacji';
          DataSynchronizacji.Caption := '' ;
          DataSynchronizacji.Left := 130;
          DataSynchronizacji.Top := 60;
          DataSynchronizacji.Font.Size := 7;

          ImportujWszystkich := TstBitBtn.Create(OknoModulu);
          ImportujWszystkich.parent := Panel;
          ImportujWszystkich.Top := 80;
          ImportujWszystkich.Left := 20;
          ImportujWszystkich.Width := 170;
          ImportujWszystkich.Caption := 'Importuj grafiki pracowników';
          ImportujWszystkich.OnClick := @ImportujWszystkichAction;

          PracownikLabel := TstLabel.Create(OknoModulu);
          PracownikLabel.parent := Panel;
          PracownikLabel.Name := 'WlascicielProcesu';
          PracownikLabel.Left := 20;
          PracownikLabel.Top := 120;
          PracownikLabel.Font.Style := [fsBold];
          PracownikLabel.Font.Size := 10;
          PracownikLabel.Caption := 'Wybierz pracownika';

          PracownikHint := TstLabel.Create(OknoModulu);
          PracownikHint.parent := Panel;
          PracownikHint.Caption := 'Wybierz pracownika któremu chcesz dodać/zaktualizować grafik.';
          PracownikHint.Left := 20;
          PracownikHint.Top := 140;
          PracownikHint.Font.Size := 7;

          PracownikCombo := TstComboBox.Create(OknoModulu);
          PracownikCombo.Parent := Panel;
          PracownikCombo.Name :='Pracownik';
          PracownikCombo.AutoComplete := true;
          PracownikCombo.Width := 225;
          PracownikCombo.Height := 50;
          PracownikCombo.Left := 20;
          PracownikCombo.Top := 160;

          ImportujPracownika := TstBitBtn.Create(OknoModulu);
          ImportujPracownika.parent := Panel;
          ImportujPracownika.Top := 200;
          ImportujPracownika.Left := 20;
          ImportujPracownika.Width := 150;
          ImportujPracownika.Caption := 'Importuj grafik pracownika';
          ImportujPracownika.OnClick := @ImportujPracownikaAction;
     end
end;

procedure UruchomWtyczke;
var
        modalStatus : longint;
begin
          try
            OknoModulu := TForm.Create(Self);
            OknoModulu.Name := 'Import Grafików';
            OknoModulu.Width := 450;
            OknoModulu.Height := 425;

            KomponentyInterfejsuOknaGlownego;
            DaneWejsciowe;

            modalStatus := OknoModulu.ShowModal;

            finally
                   OknoModulu.Free;
            end;
end;

begin
     begin
          UruchomWtyczke
     end;
end.
