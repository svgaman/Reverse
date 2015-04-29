unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ShellCtrls, ComCtrls, EditBtn, tcotlcconv;

type

  { TForm1 }

  TForm1 = class(TForm)
    DirectoryEdit1: TDirectoryEdit;
    ListView1: TListView;
    Panel1: TPanel;
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
end;

procedure TForm1.DirectoryEdit1Change(Sender: TObject);
begin
  ScanDir(DirectoryEdit1.Directory+'\');
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

