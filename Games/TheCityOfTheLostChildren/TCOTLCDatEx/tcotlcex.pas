unit tcotlcex;

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

procedure ExtractFile(InputFile, OutputDir, FileName: string; Offset, Size: DWORD);
function ParseArchiveFile(InFile: string): TArchiveFileListArray;
function CheckFile(InputFile: string):boolean;
implementation

function CheckFile(InputFile: string):boolean;
var
  InStream: TFileStream;
  buffer: array [0..4] of AnsiChar;
  Magic: string;
begin
  FillByte(buffer, 5, 0);
  InStream := TFileStream.Create(InputFile, fmOpenRead);
  InStream.ReadBuffer(buffer, 4);
  Magic := StrPas(buffer);
  FreeAndNil(InStream);
  Result := (Magic = 'CRSL');
end;

procedure ExtractFile(InputFile, OutputDir, FileName: string; Offset, Size: DWORD);
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
  except
    on e: exception do
    begin
      Showmessage(e.Message);
      Exception.Create(e.Message);
    end;
  end;
end;

function ParseArchiveFile(InFile: string): TArchiveFileListArray;
var
  InStream: TFileStream;
  XFileList: array of TArchiveFileEntry;
  XFile: TArchiveFile;
  Idx, i, z, CptFiles: integer;
  c: Byte;
  position: integer;
  buffer: array [0..12] of AnsiChar;
  ProcessFiles: Boolean;
begin
  try
    ProcessFiles := True;
    InStream := TFileStream.Create(InFile, fmOpenRead);
    InStream.Seek(6, soFromBeginning);

    XFile.NbOfEntries := InStream.ReadWord();
    CptFiles := 1;

    // For each entry
    while ProcessFiles do
    begin
      FillByte(buffer, 13, 0);
      Idx := Length(XFileList);
      SetLength(XFileList, Idx + 1);

      with XFileList[Idx] do
      begin
        // Size of content
        Size := InStream.ReadDWord();
        InStream.ReadDWord();

        // Offset of content
        Offset := InStream.ReadDWord();

        // Copy filename
        InStream.ReadBuffer(buffer, 12);
        Filename := StrPas(buffer);

        InStream.ReadDWord();
      end;

      Inc(CptFiles);
      ProcessFiles := CptFiles <= XFile.NbOfEntries;
    end;

    FreeAndNil(InStream);
    Result := XFileList;
  except
  end;
end;

end.

