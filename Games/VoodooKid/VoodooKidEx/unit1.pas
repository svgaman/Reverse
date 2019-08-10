unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  EditBtn, ComCtrls, StdCtrls, Menus, strutils, burp;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnReadArchive: TButton;
    BtnExtract: TButton;
    DirectoryEdit1: TDirectoryEdit;
    FileNameEdit1: TFileNameEdit;
    ListView1: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Panel1: TPanel;
    procedure BtnReadArchiveClick(Sender: TObject);
    procedure BtnExtractClick(Sender: TObject);
    procedure FileNameEdit1Change(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BtnReadArchiveClick(Sender: TObject);
var
  FicList: TArchiveFileListArray;
  Cpt: integer;
  ItemFicEntry: TListItem;
begin
  ListView1.Items.Clear;
  FicList := ParseResFile(FileNameEdit1.FileName);

  for Cpt := 0 to Length(FicList) - 1 do
  begin
    ItemFicEntry := ListView1.Items.Add();
    ItemFicEntry.Caption:= FicList[Cpt].Filename;
    ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Offset,8));
    ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Size,8));
    ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Flags,8));
    ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].UnpackedSize,8));
  end;

  BtnExtract.Enabled := true;
end;

procedure TForm1.BtnExtractClick(Sender: TObject);
var
  i: integer;
  ResFileDir, OutputDir: string;
  Offset, Size: DWORD;
  Li: TListItem;
  ArchiveFileName, ExtrFileName: string;
begin
  ArchiveFileName := FileNameEdit1.FileName;
  OutputDir := DirectoryEdit1.Directory + DirectorySeparator;

  if DirectoryExists(OutputDir) then
  begin
    for i := 0 to ListView1.Items.Count - 1 do
    begin
      if ListView1.Items[i].Selected then
      begin
        try
          ExtrFileName := StringReplace(ListView1.Items[i].Caption, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
          ExtractFile(ArchiveFileName, OutputDir, ExtrFileName, Hex2Dec(ListView1.Items[i].SubItems[0]), Hex2Dec(ListView1.Items[i].SubItems[1]), Hex2Dec(ListView1.Items[i].SubItems[3]), Hex2Dec(ListView1.Items[i].SubItems[2]), False);
        except
          on e: exception do
          begin
            ShowMessage(e.message);
          end;
        end;
      end;
    end;
  end;

end;

procedure TForm1.FileNameEdit1Change(Sender: TObject);
begin
  BtnReadArchive.Enabled := FileExists(FileNameEdit1.FileName);
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  ShowMessage('Voodoo Kid - Extractor, v1.00 (2019/08/10)');
end;

end.

