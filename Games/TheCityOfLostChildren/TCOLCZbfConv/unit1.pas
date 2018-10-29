unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, EditBtn, tcotlczbf, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ChckBxPng: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    Label1: TLabel;
    ListView1: TListView;
    procedure Button1Click(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { private declarations }
    procedure ScanDir(Path: string);
  public
    { public declarations }
  end;



var
  Form1: TForm1;
  FicList: TZbfFileListArray;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);

  var
    i: integer;
  begin
    for i := 0 to ListView1.Items.Count - 1 do
    begin
      if ListView1.Items[i].Selected then
      begin
        try
          //ConvertFile(DirectoryEdit1.Directory + '\' + FicList[i].Filename, ChckBxTitle.Checked, ChckBxDebug.Checked);
          ConvertFileToBmp(DirectoryEdit1.Directory + '\' + FicList[i].Filename);

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

procedure TForm1.DirectoryEdit1Change(Sender: TObject);
begin
  ScanDir(DirectoryEdit1.Directory+'\');
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  OpenURL(label1.Caption);
end;

procedure TForm1.ScanDir(Path: string);
var
  Cpt: integer;
  SR: TSearchRec;
  ItemFicEntry: TListItem;
  Idx: integer;
begin

  try
    if FindFirst(Path + '*.ZBF', faAnyFile, SR) = 0 then
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

