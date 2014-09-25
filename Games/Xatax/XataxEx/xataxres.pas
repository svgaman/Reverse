unit xataxres;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

type

  TXataxResFile = packed record
    NbOfEntries: Word;
    FileName: string;
  end;

  TXataxResFileEntry = packed record
    FilenameLength: Byte;
    Filename: string;
    Offset: DWORD;
    Size: DWORD;
    Unk: BYTE;
  end;

  TXFileListArray = Array of TXataxResFileEntry;

procedure ExtractFile(InputDir, OutputDir, FileName: string; Offset, Size: DWORD);
function ParseResFile(InFileDir: string): TXFileListArray;
implementation


procedure ExtractFile(InputDir, OutputDir, FileName: string; Offset, Size: DWORD);
var
  InStream, OutStream: TFileStream;
begin
  try
    InStream := TFileStream.Create(InputDir + 'XATAX.RES', fmOpenRead);
    OutStream := TFileStream.Create(OutputDir + FileName, fmCreate);

    InStream.Seek(Offset, soFromBeginning);
    OutStream.CopyFrom(InStream, Size);

    FreeAndNil(InStream);
    FreeAndNil(OutStream);
  except
    on e: exception do
    begin
      Showmessage(e.Message);
      Exception.Create(e.Message);
    end;
  end;
end;

function ParseResFile(InFileDir: string): TXFileListArray;
var
  InStream: TFileStream;
  XFileList: array of TXataxResFileEntry;
  XFile: TXataxResFile;
  Idx, i, z: integer;
  c: Byte;
  position: integer;
  buffer: array [0..12] of AnsiChar;
begin
  try
    InStream := TFileStream.Create(InFileDir + 'XATAX.RES', fmOpenRead);

    // Nb of entries
    XFile.NbOfEntries := InStream.ReadWord();

    // For each entry
    for z := 1 to XFile.NbOfEntries do
    begin
      FillByte(buffer, 13, 0);
      Idx := Length(XFileList);
      SetLength(XFileList, Idx + 1);

      with XFileList[Idx] do
      begin
        // Length of filename
        FilenameLength := InStream.ReadByte();

        // Copy filename
        InStream.ReadBuffer(buffer, FilenameLength);
        Filename := StrPas(buffer);

        // Jump the padding of filename
        position := InStream.Position;
        InStream.Seek(12 - FilenameLength, soCurrent);

        // Offset of content
        Offset := InStream.ReadDWord();

        // Size of content
        Size := InStream.ReadDWord();

        // Don't know
        Unk := InStream.ReadByte();
      end;
    end;

    FreeAndNil(InStream);
    Result := XFileList;
  except
  end;
end;

end.

