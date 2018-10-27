unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { private declarations }
    procedure CreateDATFile(filename: string);
  public
    { public declarations }
  end;

  TArchiveFile = packed record
    NbOfEntries: Word;
    FileName: string;
  end;

  TOldString4 = array[0..11] of char;

  TArchiveFileEntry = packed record
    Size: DWORD;
    Size2: DWORD;
    Offset: DWORD;
    Filename: TOldString4;
    Unk: DWORD;
  end;

var
  Form1: TForm1;
  DirFiles: string;
      StartingPoint : TPoint;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  OpenDialog1.Filter := 'Text|*.txt' ;
  if OpenDialog1.Execute then
  begin
    DirFiles := ExtractFileDir(OpenDialog1.FileName);
    ListBox1.Items.LoadFromFile(OpenDialog1.FileName);
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
       CreateDATFile(SaveDialog1.FileName);
  end;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin
  OpenURL(Label2.Caption);
end;

procedure TForm1.CreateDATFile(filename: string);
var
  OutStream, InStream: TMemoryStream;
  XFile: TArchiveFile;
  IFile: TArchiveFileEntry;
  i : integer;
  CurOffset:  DWORD;
begin
  Memo1.Clear;
  OutStream := TMemoryStream.Create;

  try
    XFile.NbOfEntries := ListBox1.Items.Count;
    OutStream.WriteDWord($4C535243);
    OutStream.WriteWord($0001);
    OutStream.WriteWord(XFile.NbOfEntries);

    CurOffset := 8 + XFile.NbOfEntries * sizeof (TArchiveFileEntry);

    for i := 0 to ListBox1.Items.Count - 1 do
    begin
      FillByte(IFile.Filename, 12, 0);
      IFile.Filename := ListBox1.Items[i];
      IFile.Offset:= CurOffset;
      IFile.Size:= FileUtil.FileSize(DirFiles + '\' + ListBox1.Items[i]);
      IFile.Size2:= IFile.Size;
      IFile.Unk:= $01000000; //$0140a308;
      memo1.lines.add('>>'+IFile.Filename);
      OutStream.Write(IFile, sizeof(IFile));
      CurOffset := CurOffset + IFile.Size;
    end;


    for i := 0 to ListBox1.Items.Count - 1 do
    begin
      IFile.Filename := ListBox1.Items[i];
      IFile.Offset:= CurOffset;
      IFile.Size:= FileUtil.FileSize(DirFiles + '\' + ListBox1.Items[i]);
      IFile.Size2:= IFile.Size;

      InStream := TMemoryStream.Create;

      try
        InStream.LoadFromFile(DirFiles + '\' + ListBox1.Items[i]);
        OutStream.CopyFrom(InStream, IFile.Size);
      finally
        InStream.Free;
      end;
    end;

    OutStream.SaveToFile(filename);
    ShowMessage('File saved');
  finally
    OutStream.Free;
  end;
end;

end.

