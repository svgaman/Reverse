unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ShellCtrls, ComCtrls, EditBtn, StdCtrls, tcotlcconv;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnExtract: TButton;
    ChckBxPng: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    ListView1: TListView;
    Panel1: TPanel;
    procedure BtnExtractClick(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
  private
    { private declarations }
    procedure ScanDir(Path: string);
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  FicList: TCrpFileListArray;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.ListView1DblClick(Sender: TObject);
begin
  ConvertFile(DirectoryEdit1.Directory + '\' + FicList[ListView1.ItemIndex].Filename);

  if ChckBxPng.Checked then
  begin
    ConvertBmpToPng(DirectoryEdit1.Directory + '\' + FicList[ListView1.ItemIndex].Filename + '.bmp');
  end;
end;

procedure TForm1.DirectoryEdit1Change(Sender: TObject);
begin
  ScanDir(DirectoryEdit1.Directory+'\');
end;

procedure TForm1.BtnExtractClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to ListView1.Items.Count - 1 do
  begin
    if ListView1.Items[i].Selected then
    begin
      try
        ConvertFile(DirectoryEdit1.Directory + '\' + FicList[i].Filename);

        if ChckBxPng.Checked then
        begin
          ConvertBmpToPng(DirectoryEdit1.Directory + '\' + FicList[i].Filename + '.bmp');
        end;
      except
        on e: exception do
        begin
          ShowMessage(e.message);
        end;
      end;
    end;
  end;
end;

procedure TForm1.ScanDir(Path: string);
var
  Cpt: integer;
  SR: TSearchRec;
  ItemFicEntry: TListItem;
  Idx: integer;
begin

  try
    if FindFirst(Path + '*.CRP', faAnyFile, SR) = 0 then
    begin
      repeat
        Idx := Length(FicList);
        SetLength(FicList, Idx + 1);
        FicList[Idx].Filename := SR.Name;
        FicList[Idx].Path := Path;
        FicList[Idx].Header := FileInfo(Path + SR.Name);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;

    for Cpt := 0 to Length(FicList) - 1 do
    begin
      ItemFicEntry := ListView1.Items.Add();
      ItemFicEntry.Caption:= FicList[Cpt].Filename;
      ItemFicEntry.SubItems.Add(IntToStr(FicList[Cpt].Header.Width));
      ItemFicEntry.SubItems.Add(IntToStr(FicList[Cpt].Header.Height));
    end;
  finally

  end;
end;

end.

