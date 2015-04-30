unit tcotlcconv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;
Type

TPalette = packed record
  R: BYTE;
  G: BYTE;
  B: BYTE;
end;

TPicHeader = packed record
  Magic: packed array [1..4] of char;
  unk: BYTE;
  unk2: BYTE;
  unk3: BYTE;
  Width: WORD;
  Height: WORD;
  SizeOfData: DWORD;
end;

TCrpFileEntry = packed record
  Path: string;
  Filename: string;
  Header: TPicHeader;
end;

TCrpFileListArray = Array of TCrpFileEntry;

function FileInfo(FileName: string): TPicHeader;
procedure ConvertFile(FileName: string);

implementation

function FileInfo(FileName: string): TPicHeader;
var
  FsIn: TFileStream;
  PH: TPicHeader;
begin
  FsIn := TFileStream.Create(FileName, fmOpenRead);
  FsIn.ReadBuffer(PH, sizeof(TPicHeader));

  if PH.Magic <> 'CRSL' then
  begin
    PH.Width := 640;
    PH.Height := 480;
  end;

  FsIn.Free;

  Result := PH;
end;

procedure ConvertFile(FileName: string);
var
  Palette: array of TPalette;
  PaletteFileName: string;
  InStream: TFileStream;
  Idx, I, X, Y: integer;
  Bmp: TBitmap;
  Pxl, Pxl2: BYTE;
  NbPxl, Repetition: integer;
  PH: TPicHeader;
begin
  // Palette
  PaletteFileName := ChangeFileExt(FileName, '.CPA');

  if not FileExists(PaletteFileName) then
  begin
    PaletteFileName := ExtractFilePath(PaletteFileName) + '\DEFAULTS.CPA';
  end;

  if not FileExists(PaletteFileName) then
  begin
    raise Exception.Create('Can''t find DEFAULTS.CPA');
  end;

  InStream := TFileStream.Create(PaletteFileName, fmOpenRead);

  // Jump over header
  InStream.Seek(8, soFromBeginning);

  // Read each RGB triple
  while InStream.Position < InStream.Size do
  begin
    Idx := Length(Palette);
    SetLength(Palette, Idx + 1);
    Palette[Idx].R := InStream.ReadByte;
    Palette[Idx].G := InStream.ReadByte;
    Palette[Idx].B := InStream.ReadByte;
  end;

  InStream.Free;

  // Picture
  InStream := TFileStream.Create(FileName, fmOpenRead);

  // Read header
  InStream.ReadBuffer(PH, sizeof(TPicHeader));

  if PH.Magic <> 'CRSL' then
  begin
    PH.Width := 640;
    PH.Height := 480;
    InStream.Seek(0, soFromBeginning);
  end;

  // Bitmap canvas
  Bmp := TBitmap.Create;
  Bmp.PixelFormat:= pf16bit;
  Bmp.Width := PH.Width;
  Bmp.Height := PH.Height;

  X := 0;
  Y := 0;

  // Read pixels data
  while (InStream.Position < InStream.Size) do
  begin
    Pxl := InStream.ReadByte;

    // Not Packed image else Packed image
    if PH.Magic <> 'CRSL' then
    begin
      Bmp.Canvas.Pixels[X, Y] := RGBToColor(Palette[Pxl].R shl 2, Palette[Pxl].G shl 2, Palette[Pxl].B shl 2);
      inc(X);

      if (X mod PH.Width = 0) then
      begin
        X := 0;
        inc(Y);
      end;
    end
    else
    begin
      if Pxl < $80 then
      begin
        NbPxl := Pxl;

        for I := 0 to NbPxl do
        begin
          Pxl2 := InStream.ReadByte;
          Bmp.Canvas.Pixels[X, Y] := RGBToColor( Palette[Pxl2].R shl 2, Palette[Pxl2].G shl 2,  Palette[Pxl2].B shl 2);
          inc(X);

          if X mod PH.Width = 0 then
          begin
            X := 0;
            inc(Y);
          end;
        end;
      end
      else
      begin
        Pxl2 := InStream.ReadByte;
        Repetition := Pxl - $80 + 1;

        For I := 0 To Repetition do
        begin
          Bmp.Canvas.Pixels[X, Y] := RGBToColor( Palette[Pxl2].R shl 2, Palette[Pxl2].G shl 2,  Palette[Pxl2].B shl 2);
          inc(X);

          if X mod PH.Width = 0 then
          begin
            X := 0;
            inc(Y);
          end;
        end;
      end;
    end;
  end;

  InStream.Free;
  Bmp.SaveToFile(FileName + '.bmp');
  Bmp.Free;
end;
end.

