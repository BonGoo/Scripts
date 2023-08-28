{$ADDTYPE TstMemo}
{$ADDTYPE TForm}
{$ADDTYPE TstBitBtn}
{$ADDTYPE TstMemo}
{$ADDTYPE TstComboBox}
{$ADDTYPE TstLabel}
{$ADDTYPE TstQuery}

var
OknoModulu : TForm;

procedure DaneWejsciowe;
var
  Dostawca,WyrobGotowy: TstComboBox;
  comboBox : TDataSource;
  ComboBoxPosition: string;

begin
  Dostawca := TstComboBox(OknoModulu.FindComponent('Dostawca'));
  WyrobGotowy := TstComboBox(OknoModulu.FindComponent('Wyrób'));

  if Dostawca.Items.Count = 0 then
      begin
        try
           begin
                ComboBoxPosition := GetFromQuerySQL('SELECT COUNT(xrd2.ID_DOSTAWCA) FROM XXX_RAMKA_DOSTAWCY xrd2;',0);  // Count listy dostawców
                comboBox := OpenQuerySQL('SELECT xrd.NAZWA FROM XXX_RAMKA_DOSTAWCY xrd;', 0);     // Pobranie listy dostawców
           end;

          if comboBox <> nil then
          begin
            while not comboBox.dataset.eof do
            begin
              Dostawca.items.add(comboBox.DataSet.FieldByName('NAZWA').asstring);
              comboBox.dataset.next;
            end;
          end;
        finally
          comboBox.free;
        end;
      end;

   if WyrobGotowy.Items.Count = 0 then
      begin
        try
           begin
                ComboBoxPosition := GetFromQuerySQL('SELECT COUNT(XRW.ID_WYROBGOTOWY) FROM XXX_RAMKO_WYROBGOTOWY xrw; ',0);  // Count listy wyrobów gotowych
                comboBox := OpenQuerySQL('SELECT xrw.NAZWA FROM XXX_RAMKO_WYROBGOTOWY xrw;', 0);     // Pobranie listy wyrobów gotowych
           end;

          if comboBox <> nil then
          begin
            while not comboBox.dataset.eof do
            begin
              WyrobGotowy.items.add(comboBox.DataSet.FieldByName('NAZWA').asstring);
              comboBox.dataset.next;
            end;
          end;
        finally
          comboBox.free;
        end;
      end;
end;


procedure ZapiszZmiany(Sender : TObject);
var
  IloscRamek,NotOkEdit : TstEdit;
  IDDostawca,IDWyrob: TstComboBox;
  Uwaga: TstMemo;
  ZapytanieSQL, Ramka,RamkaNotOk , UwagaText: string;
  IDDostawcaIndex,IDWyrobIndex: integer;

begin



    if sender is TstBitBtn then
    begin
      IloscRamek := TstEdit(OknoModulu.FindComponent('InsertIlosc'));
      NotOkEdit := TstEdit(OknoModulu.FindComponent('NotEdit'));
      IDDostawca := TstComboBox(OknoModulu.FindComponent('Dostawca'));
      IDWyrob := TstComboBox(OknoModulu.FindComponent('Wyrób'));
      Uwaga:= TstMemo(OknoModulu.FindComponent('UwagaMemo'));
      IDDostawcaIndex := IDDostawca.ItemIndex+1;
      IDWyrobIndex := IDWyrob.ItemIndex+1;
      Ramka:= IloscRamek.Text;
      RamkaNotOk := NotOkEdit.Text;
      UwagaText:= Uwaga.Text;


           begin
             //ZapytanieSQL := 'INSERT INTO XXX_RAMKA (ID_DOSTAWCA, ID_WYROBGOTOWY, ILOSC, DATA_WPISU) VALUES('+QuotedStr(IDDostawca)+',' +QuotedStr(IDWyrob)+',' +QuotedStr(IloscRamek)+', CURRENT_TIMESTAMP);';
             ZapytanieSQL := 'INSERT INTO XXX_RAMKA (ID_DOSTAWCA, ID_WYROBGOTOWY, ILOSC,ILOSCNOK, UWAGA , DATA_WPISU) VALUES(' +inttostr(IDDostawcaIndex)+',' +inttostr(IDWyrobIndex)+',' +QuotedStr(Ramka)+',' +QuotedStr(RamkaNotOk)+','+QuotedStr(UwagaText)+', CURRENT_TIMESTAMP)';
           end

        if ExecuteSQL(ZapytanieSQL, 0) = 1 then
           inf300('Pomyślnie zapisano zmiany w bazie.')
          else
        if ExecuteSQL(ZapytanieSQL, 0) <> 1 then
           inf300('Blad przy zapisie do bazy. ' + #13#10 + GetLastAPIError);

    end
end;

procedure AnulujZmiany(Sender : TOBject);
var
  InsertDane : TstEdit;

begin

  if sender is TstBitBtn then
    begin
      InsertDane := TstEdit(OknoModulu.FindComponent('InsertIlosc'));
      InsertDane.Caption := '';
      end;
end;

procedure NotOkChecked(Sender : TOBject);
var
  NotOk: TstCheckBox;
  NotOkEdit: TstEdit;
begin

  NotOk :=TstCheckBox(OknoModulu.FindComponent('CzyNot'));
  NotOkEdit :=TstEdit(OknoModulu.FindComponent('NotEdit'));

   if NotOK.Checked = True then
      begin
           NotOkEdit.Visible := True
      end
   else
       begin
            NotOkEdit.Visible := False
       end;
end;

procedure KomponentyInterfejsuOknaGlownego;
var
        Panel : TstPanel;
        Tytul,IleRamekLabel,IleRamekHint,Wlasciciel,KtoLabel,KtoHint,CoLabel,CoHint,Uwaga,UwagaHint,IleRamekNotLabel,IleRamekNotHint: TstLabel;
        IleRamekInsert,IleRamekNotOK:TstEdit;
        UwagaInsert:TstMemo;
        IleRamekCheckBox:TstCheckBox;
        KtoInsert,CoInsert:TstComboBox;
        ZapiszZamknij, Anuluj:TstBitBtn;
        LabelFontSize: Integer;

begin
     LabelFontSize :=10;

     begin
          Tytul := TstLabel.Create(OknoModulu);
          Tytul.parent := OknoModulu;
          Tytul.Name := 'WlascicielProcesu';
          Tytul.Caption := 'Raporting Ramek';
          Tytul.Left := 40;
          Tytul.Top := 5;
          Tytul.Font.Style := [fsBold];
          Tytul.Font.Size := 20;

          Wlasciciel := TstLabel.Create(OknoModulu);
          Wlasciciel.parent := OknoModulu;
          Wlasciciel.Left := 50;
          Wlasciciel.Top := 70;
          Wlasciciel.Font.Size := 12;
          Wlasciciel.Caption := 'Dane wprowadza: Magazynier';

          Panel := TstPanel.Create(OknoModulu);
          Panel.Parent := OknoModulu;
          Panel.Name := '';
          Panel.Top := 100;
          Panel.Height := 550;
          Panel.Left := 25;
          Panel.Width := 275;
          Panel.BevelKind := bsHorizontal;

          IleRamekLabel := TstLabel.Create(OknoModulu);
          IleRamekLabel.parent := Panel;
          IleRamekLabel.Name := 'WlascicielProcesu';
          IleRamekLabel.Left := 20;
          IleRamekLabel.Top := 20;
          IleRamekLabel.Font.Style := [fsBold];
          IleRamekLabel.Font.Size := 10;
          IleRamekLabel.Caption := 'Ile ramek przyjechało?';

          IleRamekHint := TstLabel.Create(OknoModulu);
          IleRamekHint.parent := Panel;
          IleRamekHint.Caption := 'Wpisz ile zgodnych ramek przyjechało z dostawą.';
          IleRamekHint.Left := 20;
          IleRamekHint.Top := 40;
          IleRamekHint.Font.Size := 7;

          IleRamekInsert := TstEdit.Create(OknoModulu);
          IleRamekInsert.Name := 'InsertIlosc';
          IleRamekInsert.parent := Panel;
          IleRamekInsert.Left := 20;
          IleRamekInsert.Top:= 60;
          IleRamekInsert.Width:= 225;
          IleRamekInsert.Height:= 50;
          IleRamekInsert.Caption:= '';

          IleRamekNotLabel := TstLabel.Create(OknoModulu);
          IleRamekNotLabel.parent := Panel;
          IleRamekNotLabel.Name := 'WlascicielProcesu';
          IleRamekNotLabel.Left := 20;
          IleRamekNotLabel.Top := 100;
          IleRamekNotLabel.Font.Style := [fsBold];
          IleRamekNotLabel.Font.Size := 10;
          IleRamekNotLabel.Caption := 'Czy przyjechały niezgodne ramka?';

          IleRamekNotHint := TstLabel.Create(OknoModulu);
          IleRamekNotHint.parent := Panel;
          IleRamekNotHint.Caption := 'Czy z dostawą przyjechały NIE zgodne ramka?';
          IleRamekNotHint.Left := 20;
          IleRamekNotHint.Top := 120;
          IleRamekNotHint.Font.Size := 7;

          IleRamekCheckBox := TstCheckBox.Create(OknoModulu);
          IleRamekCheckBox.Name := 'CzyNot';
          IleRamekCheckBox.Caption := 'Tak/Nie';
          IleRamekCheckBox.parent := Panel;
          IleRamekCheckBox.Left := 20;
          IleRamekCheckBox.Top:= 140;
          IleRamekCheckBox.OnClick := @NotOkChecked

          IleRamekNotOK := TstEdit.Create(OknoModulu);
          IleRamekNotOK.Name := 'NotEdit';
          IleRamekNotOK.parent := Panel;
          IleRamekNotOK.Left := 100;
          IleRamekNotOK.Top:= 140;
          IleRamekNotOK.Width:= 145;
          IleRamekNotOK.Visible := False;
          IleRamekNotOk.Caption :='0';

          KtoLabel := TstLabel.Create(OknoModulu);
          KtoLabel.parent := Panel;
          KtoLabel.Name := 'WlascicielProcesu';
          KtoLabel.Left := 20;
          KtoLabel.Top := 180;
          KtoLabel.Font.Style := [fsBold];
          KtoLabel.Font.Size := 10;
          KtoLabel.Caption := 'Kto dostarczył ramka?';

          KtoHint := TstLabel.Create(OknoModulu);
          KtoHint.parent := Panel;
          KtoHint.Caption := 'Wybierz z listy kto przywiózł Ramka.';
          KtoHint.Left := 20;
          KtoHint.Top := 200;
          KtoHint.Font.Size := 7;

          KtoInsert := TstComboBox.Create(OknoModulu);
          KtoInsert.Parent := Panel;
          KtoInsert.Name :='Dostawca';
          KtoInsert.AutoComplete := true;
          KtoInsert.Width := 225;
          KtoInsert.Height := 50;
          KtoInsert.Left := 20;
          KtoInsert.Top := 220;


          CoLabel := TstLabel.Create(OknoModulu);
          CoLabel.parent := Panel;
          CoLabel.Name := 'WlascicielProcesu';
          CoLabel.Left := 20;
          CoLabel.Top := 260;
          CoLabel.Font.Style := [fsBold];
          CoLabel.Font.Size := 10;
          CoLabel.Caption := 'Na jaki wyrób?';

          CoHint := TstLabel.Create(OknoModulu);
          CoHint.parent := Panel;
          CoHint.Caption := 'Wybierz z listy wyrób dla którego przyjechały Ramka.';
          CoHint.Left := 20;
          CoHint.Top := 280;
          CoHint.Font.Size := 7;

          CoInsert := TstComboBox.Create(OknoModulu);
          CoInsert.parent := Panel;
          CoInsert.Name := 'Wyrób';
          CoInsert.Left := 20;
          CoInsert.Top:= 300;
          CoInsert.Width:= 225;
          CoInsert.Height:= 50;

          Uwaga := TstLabel.Create(OknoModulu);
          Uwaga.parent := Panel;
          Uwaga.Name := 'Uwaga';
          Uwaga.Left := 20;
          Uwaga.Top := 340;
          Uwaga.Font.Style := [fsBold];
          Uwaga.Font.Size := 10;
          Uwaga.Caption := 'Komentarz';

          UwagaHint := TstLabel.Create(OknoModulu);
          UwagaHint.parent := Panel;
          UwagaHint.Caption := 'Napisz swój komentarz do dostawy.';
          UwagaHint.Left := 20;
          UwagaHint.Top := 360;
          UwagaHint.Font.Size := 7;

          UwagaInsert := TstMemo.Create(OknoModulu);
          UwagaInsert.parent := Panel;
          UwagaInsert.Name := 'UwagaMemo';
          UwagaInsert.Left := 20;
          UwagaInsert.Top:= 380;
          UwagaInsert.Width:= 225;
          UwagaInsert.Height:= 100;
          UwagaInsert.Caption:='';


          ZapiszZamknij := TstBitBtn.Create(OknoModulu);
          ZapiszZamknij.parent := Panel;
          ZapiszZamknij.Top := 500;
          ZapiszZamknij.Left := 20;
          ZapiszZamknij.Width := 100;
          ZapiszZamknij.Caption := 'Zapisz formularz';
          ZapiszZamknij.OnClick := @ZapiszZmiany;


          Anuluj:= TstBitBtn.Create(OknoModulu);
          Anuluj.parent := Panel;
          Anuluj.Top :=500;
          Anuluj.Left := 170;
          Anuluj.Caption := 'Anuluj'
          Anuluj.OnClick := @AnulujZmiany;
     end
end;

procedure UruchomWtyczke;
var
        modalStatus : longint;
begin
          try
            OknoModulu := TForm.Create(Self);
            OknoModulu.Name := 'Raport Ramek';
            OknoModulu.Width := 350;
            OknoModulu.Height := 725;

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
