unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  EditBtn, StdCtrls, LCLIntf, ComCtrls, tcolcwavbinconv;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnConvert: TButton;
    DirectoryEdit1: TDirectoryEdit;
    Label1: TLabel;
    ListView1: TListView;
    Panel1: TPanel;
    procedure BtnConvertClick(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    procedure ScanDir(Path: string);
  public

  end;

var
  Form1: TForm1;
  FicList: TWavBinFileListArray;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Label1Click(Sender: TObject);
begin
  OpenURL(Label1.Caption);
end;

procedure TForm1.DirectoryEdit1Change(Sender: TObject);
begin
  ScanDir(DirectoryEdit1.Directory+'\');
end;

procedure TForm1.BtnConvertClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to ListView1.Items.Count - 1 do
  begin
    if ListView1.Items[i].Selected then
    begin
      try
        ConvertFile(DirectoryEdit1.Directory + '\' + FicList[i].Filename);
      except
        on e: exception do
        begin
          ShowMessage(e.message);
        end;
      end;
    end;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.ScanDir(Path: string);
var
  Cpt: integer;
  SR: TSearchRec;
  ItemFicEntry: TListItem;
  Idx: integer;
begin

  try
    if FindFirst(Path + '*.wavbin', faAnyFile, SR) = 0 then
    begin
      repeat
        Idx := Length(FicList);
        SetLength(FicList, Idx + 1);
        FicList[Idx].Filename := SR.Name;
        FicList[Idx].Path := Path;
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;

    for Cpt := 0 to Length(FicList) - 1 do
    begin
      ItemFicEntry := ListView1.Items.Add();
      ItemFicEntry.Caption:= FicList[Cpt].Filename;
    end;
  finally

  end;
end;
end.

