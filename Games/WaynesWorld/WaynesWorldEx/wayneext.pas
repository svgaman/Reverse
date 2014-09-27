unit wayneext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, fpimage, fpreadpcx, fpwritebmp;

type

  TArchiveFile = packed record
    NbOfEntries: Word;
    FileName: string;
  end;

  TArchiveFileEntry = packed record
    Filename: string;
    Offset: DWORD;
    Size: DWORD;
  end;

  TArchiveFileListArray = Array of TArchiveFileEntry;

procedure ExtractFile(InputFile, OutputDir, FileName: string; Offset, Size: DWORD; Convert:boolean);
function ParseResFile(InFile: string): TArchiveFileListArray;
procedure ConvertPcxToBmp(PcxFileName: string);
implementation


procedure ExtractFile(InputFile, OutputDir, FileName: string; Offset, Size: DWORD; Convert:boolean);
var
  InStream, OutStream: TFileStream;
begin
  try
    InStream := TFileStream.Create(InputFile, fmOpenRead);
    OutStream := TFileStream.Create(OutputDir + FileName, fmCreate);

    InStream.Seek(Offset, soFromBeginning);
    OutStream.CopyFrom(InStream, Size);

    FreeAndNil(InStream);
    FreeAndNil(OutStream);

    if Convert then
    begin
      ConvertPcxToBmp(OutputDir + FileName);
    end;
  except
    on e: exception do
    begin
      Showmessage(e.Message);
      Exception.Create(e.Message);
    end;
  end;
end;

procedure ConvertPcxToBmp(PcxFileName: string);
var
  image: TFPCustomImage;
  reader: TFPCustomImageReader;
  writer: TFPCustomImageWriter;
begin
  Image := TFPMemoryImage.Create(10, 10);
  Reader := TFPReaderPCX.Create;
  Writer := TFPWriterBMP.Create;

  Image.LoadFromFile(PcxFileName, Reader);
  Image.SaveToFile(PcxFileName + '.bmp', Writer);
end;

function ParseResFile(InFile: string): TArchiveFileListArray;
var
  InStream: TFileStream;
  XFileList: array of TArchiveFileEntry;
  XFile: TArchiveFile;
  Idx, i, z: integer;
  c: Byte;
  position: integer;
  buffer: array [0..12] of AnsiChar;
  ProcessFiles: Boolean;
begin
  try
    ProcessFiles := True;
    InStream := TFileStream.Create(InFile, fmOpenRead);
    InStream.Seek(129, soFromBeginning);

    // For each entry
    while ProcessFiles do
    begin
      FillByte(buffer, 13, 0);
      Idx := Length(XFileList);
      SetLength(XFileList, Idx + 1);

      with XFileList[Idx] do
      begin
        // Copy filename
        InStream.ReadBuffer(buffer, 13);
        Filename := StrPas(buffer);

        // Offset of content
        Offset := InStream.ReadDWord();

        // Size of content
        Size := InStream.ReadDWord();

        // Unknow
        InStream.ReadDWord();
        InStream.ReadByte();
      end;

      ProcessFiles := XFileList[0].Offset > InStream.Position;
    end;

    FreeAndNil(InStream);
    Result := XFileList;
  except
  end;
end;

end.

