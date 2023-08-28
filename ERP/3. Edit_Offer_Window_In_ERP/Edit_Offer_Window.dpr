// TfDokGmEd

{$ADDTYPE TstMemo}
{$ADDTYPE TForm}
{$ADDTYPE TstBitBtn}
{$ADDTYPE TstComboBox}
{$ADDTYPE TstQuery}
{$ADDTYPE TobrDokGMPalec}
{$ADDTYPE TfDokGmEdv2}


var
  frm : TfDokGmEdv2;
  btn : TstBitBtn;
  Okno : TForm;
  id_grupadok: integer;
  ID_NAGL : Integer;
  defDok : Integer;

function GetIdDokumentu : integer;
var
 i : Integer;
begin
 Result := -1;
 for i := 0 to Screen.FormCount - 1 do
   if (Screen.Forms[i] is TfDokGmEdv2) then
   begin
     Result := TobrDokGMPalec(TfDokGmEdv2(Screen.Forms[i]).FObrDokGm).AktID_Nagl;
     id_grupadok := TobrDokGMPalec(TfDokGmEdv2(Screen.Forms[i]).FObrDokGm).AktGrupaDok;
     Break;
   end;
end;

procedure Dane;
var
  edit1, edit2: TstMemo;
  DefLang: TstComboBox;
  comboBox : TDataSource;
  DefLangPozycja: string;

begin
     defDok := TobrDokGMPalec(frm.FObrDokGm).AktDefDok
    ID_NAGL := GetIdDokumentu;

    edit1 := TstMemo(Okno.FindComponent('EditPowit1'));
    edit2 := TstMemo(Okno.FindComponent('EditPowit2'));
    DefLang := TstComboBox(Okno.FindComponent('DefLangLista'));

    if defDok = 1390 then
      begin
           DefLangPozycja := GetFromQuerySQL('SELECT COUNT(xpd.ID_POW_DEF) FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.DOK_TYPE = 1390;',0); //Pobierz listę definiowanych danych dla oferty
      end
      else
      begin
           DefLangPozycja := GetFromQuerySQL('SELECT COUNT(xpd.ID_POW_DEF) FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.DOK_TYPE = 10004;',0); //Pobierz listę definiowanych danych dla oferty
      end;

    if DefLang.Items.Count = 0 then
      begin
        try
        if defDok = 1390 then
           begin
                comboBox := OpenQuerySQL('SELECT XPD.LANG FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.DOK_TYPE = 1390', 0);
           end
           else
           begin
                comboBox := OpenQuerySQL('SELECT XPD.LANG FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.DOK_TYPE = 10004', 0);
           end;

          if comboBox <> nil then
          begin
            while not comboBox.dataset.eof do
            begin
              DefLang.items.add(comboBox.dataset.FieldByName('LANG').asstring);
              comboBox.dataset.next;
            end;
          end;
        finally
          comboBox.free;
        end;
      end;

      if defDok = 1390 then
      begin
       edit1.Text := GetFromQuerySQL('SELECT  xp.POWITANIE_CZ1 FROM XXX_POWITANIE xp WHERE xp.ID_NAGL = '+ inttostr(ID_NAGL), 0); //Pobierz dane do powitania na oferte czesc1
       edit2.Text := GetFromQuerySQL('SELECT xp.POWITANIE_CZ2 FROM XXX_POWITANIE xp WHERE xp.ID_NAGL = '+ inttostr(ID_NAGL), 0);  //Pobierz dane do powitania na oferte czesc2
      end
      else
      begin
       edit1.Text := GetFromQuerySQL('SELECT  xp.POWITANIE_CZ1 FROM XXX_POWITANIE xp WHERE xp.ID_NAGL_ZAM = '+ inttostr(ID_NAGL), 0); //Pobierz dane do powitania na zamowieniu czesc1
       edit2.Text := GetFromQuerySQL('SELECT xp.POWITANIE_CZ2 FROM XXX_POWITANIE xp WHERE xp.ID_NAGL_ZAM = '+ inttostr(ID_NAGL) , 0);  //Pobierz dane do powitania na zamowieniu czesc2
      end;

end;

procedure ZmianaJezykaPowitania(Sender : TObject);
var
  edit1, edit2: TstMemo;
  DefLang: TstComboBox;
  ComboBoxIndex: integer;

begin
  edit1 := TstMemo(Okno.FindComponent('EditPowit1'));
  edit2 := TstMemo(Okno.FindComponent('EditPowit2'));
  DefLang := TstComboBox(Okno.FindComponent('DefLangLista'));




  if sender is TstComboBox then
  begin
  if defDok = 1390 then
      begin
      ComboBoxIndex := DefLang.ItemIndex;
           edit1.Text := GetFromQuerySQL('SELECT XPD.POW_DEF_CZ1 FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.ID_POW_DEF ='+ + inttostr(ComboBoxIndex) + 'AND XPD.DOK_TYPE = 1390', 0);
           edit2.Text := GetFromQuerySQL('SELECT XPD.POW_DEF_CZ2 FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.ID_POW_DEF ='+ + inttostr(ComboBoxIndex) + 'AND XPD.DOK_TYPE = 1390', 0);
      end
      else
      begin
      ComboBoxIndex := DefLang.ItemIndex + 6;
           edit1.Text := GetFromQuerySQL('SELECT XPD.POW_DEF_CZ1 FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.ID_POW_DEF ='+ inttostr(ComboBoxIndex) + 'AND XPD.DOK_TYPE = 10004', 0);
           edit2.Text := GetFromQuerySQL('SELECT XPD.POW_DEF_CZ2 FROM XXX_POWITANIE_DEFINIOWANE xpd WHERE XPD.ID_POW_DEF ='+ inttostr(ComboBoxIndex) + 'AND XPD.DOK_TYPE = 10004', 0);
      end;
  end;
end;

procedure AnulujZmiany(Sender : TObject);
var
  edit1, edit2 : TstMemo;

begin
  ID_NAGL := GetIdDokumentu;

  if sender is TstBitBtn then
    begin
      edit1 := TstMemo(Okno.FindComponent('EditPowit1'));
      edit2 := TstMemo(Okno.FindComponent('EditPowit2'));

      edit1.Text := GetFromQuerySQL('SELECT  xp.POWITANIE_CZ1 FROM XXX_POWITANIE xp WHERE xp.ID_NAGL = '+ inttostr(ID_NAGL), 0);
      edit2.Text := GetFromQuerySQL('SELECT xp.POWITANIE_CZ2 FROM XXX_POWITANIE xp WHERE xp.ID_NAGL = '+ inttostr(ID_NAGL), 0);
  end;
end;

procedure ZapiszZmiany(Sender : TObject);
var
  poleTekstowe1, poleTekstowe2 : TstMemo;
  TrescPowitania1, TrescPowitania2, ZapytanieSQL : string;

begin
     defDok := TobrDokGMPalec(frm.FObrDokGm).AktDefDok
    ID_NAGL := GetIdDokumentu;

    if sender is TstBitBtn then
    begin
      poleTekstowe1 := TstMemo(Okno.FindComponent('EditPowit1')); // Pobierz dane do powitania cz1
      poleTekstowe2 := TstMemo(Okno.FindComponent('EditPowit2')); // Pobierz dane do powitania cz2
      TrescPowitania1 := poleTekstowe1.text; // Przypisz dane do komponentu tekstowego
      TrescPowitania2 := poleTekstowe2.Text; // Przypisz dane do komponentu tekstowego

      //inf300(IntToStr(ID_NAGL) +', '+ IloscZnakow); // okno do testów
        if defDok = 1390 then
        begin
             ZapytanieSQL:= 'UPDATE OR INSERT INTO XXX_POWITANIE ( POWITANIE_CZ1, POWITANIE_CZ2, ID_NAGL) values ('+QuotedStr(TrescPowitania1)+', '+QuotedStr(TrescPowitania2)+','+IntToStr(ID_NAGL)+') matching (ID_NAGL) ';
        end
        else
        begin
             ZapytanieSQL:= 'UPDATE OR INSERT INTO XXX_POWITANIE ( POWITANIE_CZ1, POWITANIE_CZ2, ID_NAGL, ID_NAGL_ZAM) values ('+QuotedStr(TrescPowitania1)+', '+QuotedStr(TrescPowitania2)+', 0,'+IntToStr(ID_NAGL)+') matching (ID_NAGL_ZAM) ';
        end;

        if ExecuteSQL(ZapytanieSQL, 0) = 1 then
           inf300('Pomyślnie zapisano zwrot grzecznościowy.')
          else
        if ExecuteSQL(ZapytanieSQL, 0) <> 1 then
           inf300('Blad przy zapisie do bazy. ' + #13#10 + GetLastAPIError);

    end
end;

procedure KomponentyMenu();
var
ZwrotGrzecznoscsiowyEtykieta, PowitanieEtykieta, OknoGlowne, DefLangEtykieta: TstLabel;
ZwrotGrzecznoscsiowyPoleEdycji,PowitaniePoleEdycji: TstMemo;
PrzyciskZapisz,PrzyciskAnuluj: TstBitBtn;
DefaultLang : TstComboBox;

begin
    if defDok = 1390 then
       begin
            OknoGlowne := TstLabel.Create(Okno);
            OknoGlowne.parent := Okno;
            OknoGlowne.Left := 40;
            OknoGlowne.Top := 10;
            OknoGlowne.Font.Size := 20;
            OknoGlowne.Caption := 'Powitanie na ofercie';
       end
       else
       begin
            OknoGlowne := TstLabel.Create(Okno);
            OknoGlowne.parent := Okno;
            OknoGlowne.Left := 40;
            OknoGlowne.Top := 10;
            OknoGlowne.Font.Size := 20;
            OknoGlowne.Caption := 'Powitanie na potwierdzeniu zamówienia';
       end;

    ZwrotGrzecznoscsiowyEtykieta := TstLabel.Create(Okno);
    ZwrotGrzecznoscsiowyEtykieta.Width := 65;
    ZwrotGrzecznoscsiowyEtykieta.AutoSize := True;
    ZwrotGrzecznoscsiowyEtykieta.Left := 25;
    ZwrotGrzecznoscsiowyEtykieta.Parent := Okno;
    ZwrotGrzecznoscsiowyEtykieta.Caption := 'Zwrot grzecznościowy (max 100 znaków): ';
    ZwrotGrzecznoscsiowyEtykieta.Top := 65;

    PowitanieEtykieta := TstLabel.Create(Okno);
    PowitanieEtykieta.Width := 65;
    PowitanieEtykieta.AutoSize := True;
    PowitanieEtykieta.Left := 25;
    PowitanieEtykieta.Parent := Okno;
    PowitanieEtykieta.Caption := 'Wstęp (max 500 znaków): ';
    PowitanieEtykieta.Top := 130;

    ZwrotGrzecznoscsiowyPoleEdycji := TstMemo.Create(Okno);
    ZwrotGrzecznoscsiowyPoleEdycji.Parent := Okno;
    ZwrotGrzecznoscsiowyPoleEdycji.Name := 'EditPowit1';
    ZwrotGrzecznoscsiowyPoleEdycji.Width := 250;
    ZwrotGrzecznoscsiowyPoleEdycji.Height := 60;
    ZwrotGrzecznoscsiowyPoleEdycji.Left := 250;
    ZwrotGrzecznoscsiowyPoleEdycji.Top := 65;
    ZwrotGrzecznoscsiowyPoleEdycji.MaxLength := 100;
    ZwrotGrzecznoscsiowyPoleEdycji.Text := '';

    PowitaniePoleEdycji := TstMemo.Create(Okno);
    PowitaniePoleEdycji.Parent := Okno;
    PowitaniePoleEdycji.Name := 'EditPowit2';
    PowitaniePoleEdycji.Width := 250;
    PowitaniePoleEdycji.Height := 100;
    PowitaniePoleEdycji.Left := 250;
    PowitaniePoleEdycji.Top := 130;
    PowitaniePoleEdycji.SelLength:=0;
    PowitaniePoleEdycji.MaxLength := 500;
    PowitaniePoleEdycji.Text := '';


    DefLangEtykieta := TstLabel.Create(Okno);
    DefLangEtykieta.parent := Okno;
    DefLangEtykieta.Left := 25;
    DefLangEtykieta.Top := 250;
    DefLangEtykieta.Caption := 'Wybierz predefiniowany tekst: ';

    DefaultLang := TstComboBox.Create(Okno);
    DefaultLang.Parent := Okno;
    DefaultLang.Name :='DefLangLista';
    DefaultLang.AutoComplete := true;
    DefaultLang.Width := 250;
    DefaultLang.Height := 30;
    DefaultLang.Left := 250;
    DefaultLang.Top := 250;
    DefaultLang.OnChange := @ZmianaJezykaPowitania;

    PrzyciskZapisz := TstBitBtn.Create(Okno);
    PrzyciskZapisz.Parent := Okno;
    PrzyciskZapisz.Name := 'btnZapisz';
    PrzyciskZapisz.Top := 300;
    PrzyciskZapisz.Left := 150;
    PrzyciskZapisz.Height := 25;
    PrzyciskZapisz.Width := 75;
    PrzyciskZapisz.Caption := 'Zapisz';
    PrzyciskZapisz.ModalResult := 1;
    PrzyciskZapisz.Default := True;
    PrzyciskZapisz.TabOrder := 0;
    PrzyciskZapisz.OnClick := @ZapiszZmiany;

    PrzyciskAnuluj := TstBitBtn.Create(Okno);
    PrzyciskAnuluj.Parent := Okno;
    PrzyciskAnuluj.Name := 'btnAnuluj';
    PrzyciskAnuluj.Top := 300;
    PrzyciskAnuluj.Left := 250;
    PrzyciskAnuluj.Height := 25;
    PrzyciskAnuluj.Width := 75;
    PrzyciskAnuluj.Caption := 'Anuluj';
    PrzyciskAnuluj.TabOrder := 1;
    PrzyciskAnuluj.OnClick := @AnulujZmiany;

end;

procedure clickButton(Sender : TOBject);
var
  modalStatus : longint;
begin
  try
    Okno := TForm.Create(Self);
    Okno.Name := 'Zwrot Grzecznościowy';
    Okno.Width := 550;
    Okno.Height := 380;

    KomponentyMenu;
    Dane;

    modalStatus := Okno.ShowModal;

  finally
    Okno.Free;
  end;

end;

procedure Powitanie;
var
  frmPrev : TobrDokGMPalec;
  defDok : integer;
begin
  frmPrev := TobrDokGMPalec(frm.FObrDokGm);
  if (frmPrev<>nil) then
    defDok := frmPrev.AktDefDok
  else
    defDok := 0;

  if defDok = 1390 then
  begin
    if btn = nil then
    begin
      btn := TstBitBtn.Create(Self);
      btn.Parent := frm.BB_Opcje.Parent;
      btn.Name := 'btnPowitanie';
      btn.Top := frm.BB_Opcje.Top;
      btn.Left := frm.BB_Opcje.Left + frm.BB_Opcje.Width + 3;
      btn.Height := frm.BB_Opcje.Height;
      btn.Width := frm.BB_Opcje.Width;
      btn.Caption := 'Powitanie';
      btn.Font := frm.BB_Opcje.Font;
      btn.OnClick := @clickButton;
    end;
  end
  else if defDok = 10004 then
  begin
    if btn = nil then
    begin
      btn := TstBitBtn.Create(Self);
      btn.Parent := frm.BB_Opcje.Parent;
      btn.Name := 'btnPowitanie';
      btn.Top := frm.BB_Opcje.Top;
      btn.Left := frm.BB_Opcje.Left + frm.BB_Opcje.Width + 3;
      btn.Height := frm.BB_Opcje.Height;
      btn.Width := frm.BB_Opcje.Width;
      btn.Caption := 'Powitanie';
      btn.Font := frm.BB_Opcje.Font;
      btn.OnClick := @clickButton;
    end;
  end
  else if defDok = 10005 then
  begin
    if btn = nil then
    begin
      btn := TstBitBtn.Create(Self);
      btn.Parent := frm.BB_Opcje.Parent;
      btn.Name := 'btnPowitanie';
      btn.Top := frm.BB_Opcje.Top;
      btn.Left := frm.BB_Opcje.Left + frm.BB_Opcje.Width + 3;
      btn.Height := frm.BB_Opcje.Height;
      btn.Width := frm.BB_Opcje.Width;
      btn.Caption := 'Powitanie';
      btn.Font := frm.BB_Opcje.Font;
      btn.OnClick := @clickButton;
    end;
  end
  else if defDok = 910 then
  begin
    if btn = nil then
    begin
      btn := TstBitBtn.Create(Self);
      btn.Parent := frm.BB_Opcje.Parent;
      btn.Name := 'btnPowitanie';
      btn.Top := frm.BB_Opcje.Top;
      btn.Left := frm.BB_Opcje.Left + frm.BB_Opcje.Width + 3;
      btn.Height := frm.BB_Opcje.Height;
      btn.Width := frm.BB_Opcje.Width;
      btn.Caption := 'Powitanie';
      btn.Font := frm.BB_Opcje.Font;
      btn.OnClick := @clickButton;
    end;
  end;
end;

begin
  if frm = nil then frm := self as TfDokGmEdv2;
  if frm <> nil then
  begin
    Powitanie;
  end;
end.
