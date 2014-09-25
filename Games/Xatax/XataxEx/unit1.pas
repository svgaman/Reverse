unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, xataxres, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnParse: TButton;
    BtnExtract: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListView1: TListView;
    Panel1: TPanel;
    procedure BtnExtractClick(Sender: TObject);
    procedure BtnParseClick(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
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

procedure TForm1.BtnParseClick(Sender: TObject);
var
  ResFileDir, OutputDir: string;
  FicList: TXFileListArray;
  Cpt: integer;
  ItemFicEntry: TListItem;
begin
  try
    ResFileDir := Edit1.Text;
    OutputDir := Edit2.Text;

    if not DirectoryExists(ResFileDir) then
    begin
      raise Exception.create('XATAX Directory not found');
    end;

    if not DirectoryExists(OutputDir) then
    begin
      CreateDir(OutputDir);
    end;

    FicList := ParseResFile(ResFileDir);

    for Cpt := 0 to Length(FicList) - 1 do
    begin
      ItemFicEntry := ListView1.Items.Add();
      ItemFicEntry.Caption:= FicList[Cpt].Filename;
      ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Offset,8));
      ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Size,8));
      ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Unk, 2));
    end;

  except
    on e: exception do
    begin
      ShowMessage(e.message);
    end;
  end;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin

end;

procedure TForm1.BtnExtractClick(Sender: TObject);
var
  i: integer;
  ResFileDir, OutputDir: string;
  Offset, Size: DWORD;
  Li: TListItem;
begin
  ResFileDir := Edit1.Text;
  OutputDir := Edit2.Text;

  for i := 0 to ListView1.Items.Count - 1 do
  begin
    if ListView1.Items[i].Selected then
    begin
      try
        ExtractFile(ResFileDir, OutputDir, ListView1.Items[i].Caption, Hex2Dec(ListView1.Items[i].SubItems[0]), Hex2Dec(ListView1.Items[i].SubItems[1]));
      except
        on e: exception do
        begin
          ShowMessage(e.message);
        end;
      end;
    end;
  end;
end;

end.

