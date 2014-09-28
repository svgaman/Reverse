unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, ButtonPanel, FileCtrl, EditBtn, StdCtrls, tcotlcex, strutils;

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
    ListView1: TListView;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure GameDirEditChange(Sender: TObject);
    procedure GameFilesListChange(Sender: TObject);
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
  ArchiveFileName := GameFilesList.Directory + '\' + GameFilesList.Items[GameFilesList.ItemIndex];
  OutputDir := GameDirExtract.Directory + '\';

  for i := 0 to ListView1.Items.Count - 1 do
  begin
    if ListView1.Items[i].Selected then
    begin
      try
        ExtrFileName := StringReplace(ListView1.Items[i].Caption, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
        ExtractFile(ArchiveFileName, OutputDir, ExtrFileName, Hex2Dec(ListView1.Items[i].SubItems[0]), Hex2Dec(ListView1.Items[i].SubItems[1]), False);
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
  ArchiveFileName: string;
  ResFileDir, OutputDir: string;
  FicList: TArchiveFileListArray;
  Cpt: integer;
  ItemFicEntry: TListItem;
begin
  ListView1.Items.Clear;
  ArchiveFileName := GameFilesList.Directory + '\' + GameFilesList.Items[GameFilesList.ItemIndex];

  try
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
  except
    on e: exception do
    begin
      ShowMessage(e.message);
    end;
  end;
end;

end.

