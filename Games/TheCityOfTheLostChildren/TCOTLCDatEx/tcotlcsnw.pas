unit tcotlcsnw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TSnwFile = packed record
    NbOfEntries: word;
    SizeOfData: Dword;
    FileName: string;
  end;

  TSnwFileEntry = packed record
    Size: DWORD;
    Offset: DWORD;
    Unk: DWORD;
    Unk1: DWORD;
  end;

  TSnwFileListArray = array of TSnwFileEntry;

function ParseSnwFile(InFile: string): TSnwFileListArray;

implementation


function ParseSnwFile(InFile: string): TSnwFileListArray;
var
  InStream: TFileStream;
  XFileList: array of TSnwFileEntry;
  XFile: TSnwFile;
  Idx, i, z, CptFiles: integer;
  c: byte;
  position: integer;
  buffer: array [0..12] of AnsiChar;
  ProcessFiles: boolean;
begin
  try
    ProcessFiles := True;
    InStream := TFileStream.Create(InFile, fmOpenRead);
    XFile.NbOfEntries := InStream.ReadWord;
    InStream.ReadWord;
    XFile.SizeOfData := InStream.ReadDWord();

    CptFiles := 1;

    // For each entry
    while ProcessFiles do
    begin
      Idx := Length(XFileList);
      SetLength(XFileList, Idx + 1);

      with XFileList[Idx] do
      begin
        // Size of content
        Size := InStream.ReadDWord();
        // Offset of content
        Offset := InStream.ReadDWord();

        InStream.ReadDWord();
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
