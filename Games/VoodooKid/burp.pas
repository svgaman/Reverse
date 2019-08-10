unit burp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, paszlib;

type
  TArchiveFile = packed record
    Identifier: DWord; // $70727542 pruB
    NbOfFile: DWord;
  end;

  TArchiveFileEntry = packed record
    UnpackedSize: DWord;
    Size: DWord;
    OffsetFileName: DWord;
    OffsetFileStart: DWord;
    Flags: DWord;
  end;

  TArchiveFileEntry2 = packed record
    UnpackedSize: DWord;
    Size: DWord;
    Offset: DWord;
    FileName: string;
    Flags: DWord;
  end;

  TArchiveFileListArray = Array of TArchiveFileEntry2;

  procedure ExtractFile(InputFile, OutputDir, FileName: string; Offset, Size, InflateSize, Flags: DWORD; Convert:boolean);
  function ParseResFile(InFile: string): TArchiveFileListArray;
implementation

procedure ExtractFile(InputFile, OutputDir, FileName: string; Offset, Size, InflateSize, Flags: DWORD; Convert:boolean);
var
  InStream, OutStream: TFileStream;
  MemInStream, MemOutStream: TMemoryStream;
  zstream: TZStream;
begin
  try
    InStream := TFileStream.Create(InputFile, fmOpenRead);
    MemInStream := TMemoryStream.Create;
    MemOutStream := TMemoryStream.Create;
    MemOutStream.SetSize(InflateSize);

    InStream.Seek(Offset, soFromBeginning);
    MemInStream.CopyFrom(InStream, Size);

    MemInStream.Position := 0;
    MemOutStream.Position := 0;

    if Flags = 4 then
    begin
      zstream.next_in := MemInStream.Memory;
      zstream.avail_in := MemInStream.Size;

      zstream.next_out := MemOutStream.Memory;
      zstream.avail_out := MemOutStream.Size;

      inflateInit2(zstream, -15) ;

      inflate(zstream, Z_FULL_FLUSH);
      inflateEnd(zstream);
    end;

    MemOutStream.SaveToFile(OutputDir + FileName);

    FreeAndNil(InStream);
    FreeAndNil(MemInStream);
    FreeAndNil(MemOutStream);
  except
    on e: exception do
    begin
      Showmessage(e.Message);
      Exception.Create(e.Message);
    end;
  end;
end;

function ParseResFile(InFile: string): TArchiveFileListArray;
var
  InStream: TFileStream;
  XFileList: array of TArchiveFileEntry2;
  XFile: TArchiveFile;
  Idx, i, z: integer;
  c: Byte;
  position: integer;
  bufferHeader: TArchiveFile;
  bufferFileEntry: TArchiveFileEntry;
  buffer: array [0..12] of AnsiChar;
  ProcessFiles: Boolean;
  Oc: Byte;
begin
  try
    ProcessFiles := True;
    InStream := TFileStream.Create(InFile, fmOpenRead);
    InStream.Seek(0, soFromBeginning);
    InStream.ReadBuffer(bufferHeader, SizeOf(TArchiveFile));
    Idx := 0;

    // For each entry
    for i := 0 to bufferHeader.NbOfFile - 1 do
    begin
      SetLength(XFileList, Idx + 1);

      InStream.ReadBuffer(bufferFileEntry, SizeOf(TArchiveFileEntry));
      position := InStream.Position;
      InStream.Seek(bufferFileEntry.OffsetFileName, soFromBeginning);

      with XFileList[Idx] do
      begin
        c := InStream.ReadByte;
        c := InStream.ReadByte;

        InStream.ReadBuffer(buffer, c);
        Filename := StrPas(buffer);
        Size := bufferFileEntry.Size;
        Offset := bufferFileEntry.OffsetFileStart;
        UnpackedSize := bufferFileEntry.UnpackedSize;
        Flags := bufferFileEntry.Flags;
      end;

      InStream.Seek(position, soFromBeginning);

      inc(Idx);
    end;

    FreeAndNil(InStream);
    Result := XFileList;
  except
  end;
end;

end.

