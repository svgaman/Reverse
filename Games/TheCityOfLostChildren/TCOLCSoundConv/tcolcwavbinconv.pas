unit tcolcwavbinconv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
type
  //https://fr.wikipedia.org/wiki/Waveform_Audio_File_Format
  TRiff = packed record
    FileTypeBlocId: DWORD; // "RIFF"
    FileSize: DWORD;
    FileFormatId: DWORD; // "WAVE"
    FormatBlocId: DWORD; // "fmt"
    BlocSize: DWORD;
    AudioFormat: WORD;
    NbrCanaux: WORD;
    Frequence: DWORD;
    BytePerSec: DWORD;
    BytePerBloc: WORD;
    BitsPerSample: WORD;
    DataBlocId: DWORD; // "data"
    DataSize: DWORD;
  end;

  TWavBinEntry = packed record
    Path: string;
    Filename: string;
  end;

  TWavBinFileListArray = Array of TWavBinEntry;

  procedure ConvertFile(FileName: string);
implementation

procedure ConvertFile(FileName: string);
var
  InStream : TFileStream;
  OutStream : TMemoryStream;
  Riff: TRiff;
begin
  InStream := TFileStream.Create(FileName, fmOpenRead);
  OutStream := TMemoryStream.Create;

  try
    Riff.FileTypeBlocId := $46464952;
    Riff.FileSize := SizeOf(TRiff) + InStream.Size - 8;
    Riff.FileFormatId := $45564157;
    Riff.FormatBlocId := $20746D66;
    Riff.BlocSize := $10;
    Riff.AudioFormat := 1;
    Riff.NbrCanaux := 1;
    Riff.Frequence := 11025;
    Riff.BytePerSec := Riff.Frequence * Riff.BytePerBloc;
    Riff.BitsPerSample := 8;
    Riff.BytePerBloc := Riff.NbrCanaux * Riff.BitsPerSample div 8;

    Riff.DataBlocId := $61746164;
    Riff.DataSize := InStream.Size;
    OutStream.WriteBuffer(Riff, sizeof(TRiff));
    OutStream.CopyFrom(InStream, InStream.Size);
    OutStream.SaveToFile(FileName + '.wav');
  finally
    InStream.Free;
    OutStream.Free;
  end;



end;

end.

