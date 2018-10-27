unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, ButtonPanel, FileCtrl, EditBtn, StdCtrls, Menus, tcotlcex, tcotlcsnw, strutils, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    GameDirExtract: TDirectoryEdit;
    GameDirEdit: TDirectoryEdit;
    GameFilesList: TFileListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListView1: TListView;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    MenuRessources: TPopupMenu;
    procedure Button1Click(Sender: TObject);
    procedure GameDirEditChange(Sender: TObject);
    procedure GameFilesListChange(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.GameDirEditChange(Sender: TObject);
begin
  GameFilesList.Directory := GameDirEdit.Directory;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
  ResFileDir, OutputDir: string;
  Offset, Size: DWORD;
  Li: TListItem;
  ArchiveFileName, ExtrFileName: string;
begin
  if GameDirEdit.Directory = '' then
  begin
    raise Exception.Create('Please provide game datas directory');
  end;

  if GameDirExtract.Directory = '' then
  begin
    raise Exception.Create('Please provide extraction directory');
  end;


  ArchiveFileName := GameFilesList.Directory + '\' + GameFilesList.Items[GameFilesList.ItemIndex];
  OutputDir := GameDirExtract.Directory + '\';

  for i := 0 to ListView1.Items.Count - 1 do
  begin
    if ListView1.Items[i].Selected then
    begin
      try
        ExtrFileName := StringReplace(ListView1.Items[i].Caption, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
        ExtractFile(ArchiveFileName, OutputDir, ExtrFileName, Hex2Dec(ListView1.Items[i].SubItems[0]), Hex2Dec(ListView1.Items[i].SubItems[1]));
      except
        on e: exception do
        begin
          ShowMessage(e.message);
        end;
      end;
    end;
  end;
end;

procedure TForm1.GameFilesListChange(Sender: TObject);
var
  ArchiveFileName, ArchiveExt, BaseName: string;
  ResFileDir, OutputDir: string;
  FicList: TArchiveFileListArray;
  FicListSnw: TSnwFileListArray;
  Cpt: integer;
  ItemFicEntry: TListItem;
begin
  ListView1.Items.Clear;
  if GameFilesList.SelCount > 0 then
    begin
    ArchiveFileName := GameFilesList.Directory + '\' + GameFilesList.Items[GameFilesList.ItemIndex];
    ArchiveExt := ExtractFileExt(ArchiveFileName);

    try
      if (ArchiveExt = '.DAT') then
      begin
        if CheckFile(ArchiveFileName) then
        begin
          FicList := ParseArchiveFile(ArchiveFileName);

          for Cpt := 0 to Length(FicList) - 1 do
          begin
            ItemFicEntry := ListView1.Items.Add();
            ItemFicEntry.Caption:= FicList[Cpt].Filename;
            ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Offset,8));
            ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Size,8));
          end;
        end
        else
        begin
          Raise Exception.Create('This file is not a game file');
        end;
      end;

      if (ArchiveExt = '.SNW') then
      begin
        FicListSnw := ParseSnwFile(ArchiveFileName);
        BaseName := ExtractFileNameOnly(ArchiveFileName);
        BaseName := ExtractFileNameWithoutExt(BaseName);
        for Cpt := 0 to Length(FicListSnw) - 1 do
        begin
          ItemFicEntry := ListView1.Items.Add();
          ItemFicEntry.Caption:= Format('Sound_%s_%d.wavbin', [BaseName, Cpt]);
          ItemFicEntry.SubItems.Add(IntToHex(FicListSnw[Cpt].Offset,8));
          ItemFicEntry.SubItems.Add(IntToHex(FicListSnw[Cpt].Size,8));
        end;
      end;
    except
      on e: exception do
      begin
        ShowMessage(e.message);
      end;
    end;

  end;
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  OpenURL(Label5.Caption);
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
  i: integer;
  ResFileDir, OutputDir: string;
  Offset, Size: DWORD;
  Li: TListItem;
  ArchiveFileName, ExtrFileName: string;
  List: TStringList;
begin
  //ArchiveFileName := GameFilesList.Directory + '\' + GameFilesList.Items[GameFilesList.ItemIndex];
  OutputDir := GameDirExtract.Directory + '\' + GameFilesList.Items[GameFilesList.ItemIndex] + '_List.txt';
  List := TStringList.Create;

  try
    for i := 0 to ListView1.Items.Count - 1 do
    begin
        try
          List.Add(ListView1.Items[i].Caption);
        except
          on e: exception do
          begin
            ShowMessage(e.message);
          end;
        end;
    end;

    List.SaveToFile(OutputDir);
  finally
    List.Free;
  end;


end;

end.

