unit tcotlczbf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, FPimage, FPWritePNG, FPReadBMP;

type
  TPalette = packed record
    R: BYTE;
    G: BYTE;
    B: BYTE;
  end;

  TZbfHeader = packed record
    Unk1: DWORD;
    Unk2: DWORD;
    Unk3: DWORD;
    Unk4: DWORD;
    Width: WORD;
    Height: WORD;
    Unk5: DWORD;
    SizeOfData: DWORD;
  end;

  TZbfFileEntry = packed record
    Path: string;
    Filename: string;
  end;

  TZbfFileListArray = Array of TZbfFileEntry;

  procedure ConvertFileToBmp(FileName: string);
  procedure ConvertBmpToPng(BmpFileName: string);

implementation

procedure ConvertFileToBmp(FileName: string);
var
  Palette: array of TPalette;
  InStream: TFileStream;
  Idx, I, X, Y: integer;
  Bmp: TBitmap;
  Pxl, Pxl2: BYTE;
  ZbfH: TZbfHeader;
  NbPxl, Repetition: integer;
begin
  InStream := TFileStream.Create(FileName, fmOpenRead);
  Bmp := TBitmap.Create;
  Bmp.PixelFormat:= pf16bit;

  try
    Pxl := 0;

    for Idx := 0 to 255 do
    begin
      SetLength(Palette, Idx + 1);
      Palette[Idx].R := Pxl;
      Palette[Idx].G := Pxl;
      Palette[Idx].B := Pxl;
      Inc(Pxl);
    end;

    // Read header
    InStream.ReadBuffer(ZbfH, sizeof(TZbfHeader));

    // Bitmap canvas
    Bmp.Width := ZbfH.Width;
    Bmp.Height := ZbfH.Height;

    X := 0;
    Y := 0;

    // Read pixels data
    while (InStream.Position < InStream.Size) do
    begin
      Pxl := InStream.ReadByte;
      if Pxl < $80 then
       begin
         NbPxl := Pxl;

         if InStream.Position + NbPxl < InStream.Size then
         begin
           for I := 0 to NbPxl do
           begin
             Pxl2 := InStream.ReadByte;
             Bmp.Canvas.Pixels[X, Y] := RGBToColor( Palette[Pxl2].R, Palette[Pxl2].G,  Palette[Pxl2].B);
             inc(X);

             if X mod ZbfH.Width = 0 then
             begin
               X := 0;
               inc(Y);
             end;
           end;
         end;
       end
       else
       begin
         Pxl2 := InStream.ReadByte;
         Repetition := Pxl - $80 + 1;

         For I := 0 To Repetition do
         begin
           Bmp.Canvas.Pixels[X, Y] := RGBToColor( Palette[Pxl2].R , Palette[Pxl2].G ,  Palette[Pxl2].B );
           inc(X);

           if X mod ZbfH.Width = 0 then
           begin
             X := 0;
             inc(Y);
           end;
         end;
       end;
    end;
  finally
    Bmp.Canvas.TextOut(20, Bmp.Height - 30, ExtractFileName(FileName));
    Bmp.Canvas.CopyMode := cmSrcCopy;

    Bmp.SaveToFile(FileName + '.bmp');
    Bmp.Free;
    InStream.Free;
  end;
end;

procedure ConvertBmpToPng(BmpFileName: string);
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

