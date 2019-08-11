unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ShellCtrls,
  EditBtn, StdCtrls, ComCtrls, LazFileUtils, FPimage, FPWritePNG, FPReadBMP;

type
  TPalette = packed record
    R: byte;
    G: byte;
    B: byte;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ChckBxPng: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    Label1: TLabel;
    Label2: TLabel;
    ShellListView1: TShellListView;
    procedure Button1Click(Sender: TObject);
    procedure ChckBxPngChange(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShellListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
  private
    procedure ConvertBitmap(FileName: string);
    procedure ConvertBmpToPng(BmpFileName: string);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.DirectoryEdit1Change(Sender: TObject);
begin
  if DirectoryExists(DirectoryEdit1.Directory) then
  begin
    ShellListView1.Root := DirectoryEdit1.Directory;
  end
  else
  begin
    ShellListView1.Root := '';
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to ShellListView1.Items.Count - 1 do
  begin
    if ShellListView1.Items[i].Selected then
    begin
      try
        ConvertBitmap(DirectoryEdit1.Directory + DirectorySeparator +
          ShellListView1.Items[i].Caption);

        if ChckBxPng.Checked then
        begin
          ConvertBmpToPng(DirectoryEdit1.Directory + DirectorySeparator +
          ShellListView1.Items[i].Caption + '.bmp');
        end;
      except
        on e: Exception do
        begin
          ShowMessage(e.message);
        end;
      end;
    end;
  end;
end;

procedure TForm1.ChckBxPngChange(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Label1.Caption := '';
  Label2.Caption := '';
end;

procedure TForm1.ShellListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: boolean);
var
  BaseName, PalName: string;
  Path: string;
begin
  Path := DirectoryEdit1.Directory;
  BaseName := ExtractFileNameWithoutExt(Item.Caption);
  PalName := BaseName + '.PAL';
  Label1.Caption := Format('Bitmap : %s', [Item.Caption]);

  if FileExists(Path + DirectorySeparator + PalName) then
  begin
    Label2.Caption := Format('Palette : %s', [PalName]);
    Button1.Enabled := True;
  end
  else
  begin
    Label2.Caption := Format('Palette %s non trouvée', [PalName]);
    Button1.Enabled := False;
  end;

end;

procedure TForm1.ConvertBitmap(FileName: string);
var
  Bmp: TBitmap;
  Path, BaseName, PalName, BmpName: string;
  InStream, PalStream, OutStream: TMemoryStream;
  aWidth, aHeight, Idx, X, Y: integer;
  Palette: array [0..255] of TPalette;
  Pxl: BYTE;
begin
  BaseName := ExtractFileNameWithoutExt(FileName);
  PalName := BaseName + '.PAL';
  BmpName := FileName + '.bmp';

  InStream := TMemoryStream.Create;
  PalStream := TMemoryStream.Create;
  OutStream := TMemoryStream.Create;

  Bmp := TBitmap.Create;
  Bmp.PixelFormat:= pf16bit;

  try
    InStream.LoadFromFile(FileName);
    PalStream.LoadFromFile(PalName);

    PalStream.Seek(0, soFromBeginning);
    Idx := 0;

    // Read each RGB triple
    while PalStream.Position < PalStream.Size do
    begin
      Palette[Idx].R := PalStream.ReadByte;
      Palette[Idx].G := PalStream.ReadByte;
      Palette[Idx].B := PalStream.ReadByte;
      Inc(Idx);
    end;

    InStream.Seek(0, soFromBeginning);

    Bmp.Width := InStream.ReadWord;
    Bmp.Height := InStream.ReadWord;

    Bmp.Canvas.FillRect(0, 0, Bmp.Width, Bmp.Height);

    X := 0;
    Y := 0;

    while InStream.Position < InStream.Size do
    begin
      Pxl := InStream.ReadByte;

      Bmp.Canvas.Pixels[X, Y] :=
        RGBToColor(Palette[Pxl].R, Palette[Pxl].G, Palette[Pxl].B);

      Inc(X);

      if (X mod Bmp.Width = 0) then
      begin
        X := 0;
        Inc(Y);
      end;
    end;

    Bmp.SaveToFile(BmpName);
  finally
    Bmp.Free;
    InStream.Free;
    PalStream.Free;
    OutStream.Free;
  end;
end;

procedure TForm1.ConvertBmpToPng(BmpFileName: string);
var
  image: TFPCustomImage;
  reader: TFPCustomImageReader;
  writer: TFPCustomImageWriter;
begin
  Image := TFPMemoryImage.Create(10, 10);
  Reader := TFPReaderBMP.Create;
  Writer := TFPWriterPNG.Create;
  Image.LoadFromFile(BmpFileName, Reader);
  Image.SaveToFile(ChangeFileExt(BmpFileName, '.png'), Writer);
end;


end.
