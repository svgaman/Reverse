unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  EditBtn, FileCtrl, ComCtrls, StdCtrls, ExtCtrls, Wayneext, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ChkConvertBmp: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    DirectoryEdit2: TDirectoryEdit;
    FileListBox1: TFileListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListView1: TListView;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TForm1.DirectoryEdit1Change(Sender: TObject);
begin
  FileListBox1.Directory := DirectoryEdit1.Directory;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
  ResFileDir, OutputDir: string;
  Offset, Size: DWORD;
  Li: TListItem;
  ArchiveFileName, ExtrFileName: string;
begin
  ArchiveFileName := FileListBox1.Directory + '\' + FileListBox1.Items[FileListBox1.ItemIndex];
  OutputDir := DirectoryEdit2.Directory + '\';

  for i := 0 to ListView1.Items.Count - 1 do
  begin
    if ListView1.Items[i].Selected then
    begin
      try
        ExtrFileName := StringReplace(ListView1.Items[i].Caption, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
        ExtractFile(ArchiveFileName, OutputDir, ExtrFileName, Hex2Dec(ListView1.Items[i].SubItems[0]), Hex2Dec(ListView1.Items[i].SubItems[1]), ChkConvertBmp.Checked);
      except
        on e: exception do
        begin
          ShowMessage(e.message);
        end;
      end;
    end;
  end;

end;

procedure TForm1.FileListBox1Change(Sender: TObject);
var
  ArchiveFileName: string;
  ResFileDir, OutputDir: string;
  FicList: TArchiveFileListArray;
  Cpt: integer;
  ItemFicEntry: TListItem;
begin
  ListView1.Items.Clear;
  ArchiveFileName := FileListBox1.Directory + '\' + FileListBox1.Items[FileListBox1.ItemIndex];

  try
    FicList := ParseResFile(ArchiveFileName);

    for Cpt := 0 to Length(FicList) - 1 do
    begin
      ItemFicEntry := ListView1.Items.Add();
      ItemFicEntry.Caption:= FicList[Cpt].Filename;
      ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Offset,8));
      ItemFicEntry.SubItems.Add(IntToHex(FicList[Cpt].Size,8));
    end;

  except
    on e: exception do
    begin
      ShowMessage(e.message);
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

end.

