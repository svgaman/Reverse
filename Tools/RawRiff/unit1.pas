unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls;

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

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CbNbCanaux: TComboBox;
    CbFrequence: TComboBox;
    CbBitsPerSample: TComboBox;
    CbAudioFormat: TComboBox;
    ComboBox1: TComboBox;
    EdtSize: TEdit;
    EdtStartOffset: TEdit;
    EdtNbrCanaux: TEdit;
    EdtBlocSize: TEdit;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure EdtStartOffsetChange(Sender: TObject);
    procedure FileNameEdit1Change(Sender: TObject);
  private
    procedure BuildWaveFile(FileName: string);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  BuildWaveFile(FileNameEdit1.FileName);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  case ComboBox1.ItemIndex of
       0:
         begin
         CbFrequence.ItemIndex:=0;
         end;
       1:
         begin
         CbFrequence.ItemIndex:=1;
         end;
       2:
         begin
         CbFrequence.ItemIndex:=0;
         end;
  end;
end;

procedure TForm1.EdtStartOffsetChange(Sender: TObject);
var
  StartOffset, FSize, FSize2: integer;
begin
  FSize := FileSize(FileNameEdit1.FileName);
  FSize2 := StrToInt(EdtSize.Text);
  StartOffset := StrToInt(EdtStartOffset.Text);

  if StartOffset + FSize2 > FSize then
  begin
    FSize2 := FSize - StartOffset;
    EdtSize.Text := IntToStr(FSize2);
  end;
end;

procedure TForm1.FileNameEdit1Change(Sender: TObject);
begin
  Button1.Enabled := FileExists(FileNameEdit1.FileName);
  EdtSize.Text := IntToStr(FileSize(FileNameEdit1.FileName));
end;

procedure TForm1.BuildWaveFile(FileName: string);
var
  InStream : TFileStream;
  OutStream : TMemoryStream;
  Riff: TRiff;
  WavSize, StartPos: integer;
begin
  InStream := TFileStream.Create(FileName, fmOpenRead);
  OutStream := TMemoryStream.Create;

  try
    WavSize := StrToInt(EdtSize.Text);
    StartPos := StrToInt(EdtStartOffset.Text);
    InStream.Seek(StartPos, soFromBeginning);

    Riff.FileTypeBlocId := $46464952;
    Riff.FileSize := SizeOf(TRiff) + WavSize - 8;
    Riff.FileFormatId := $45564157;
    Riff.FormatBlocId := $20746D66;
    Riff.BlocSize := StrToInt('$' + EdtBlocSize.Text);//$10;
    Riff.AudioFormat := StrToInt('$' + IntToStr(CbAudioFormat.ItemIndex)); //1;
    Riff.NbrCanaux := StrToInt('$' + IntToStr(CbNbCanaux.ItemIndex + 1)); //1;
    Riff.Frequence := StrToInt(CbFrequence.Caption); //11025;
    Riff.BitsPerSample := StrToInt('$' + CbBitsPerSample.Caption); //8;
    Riff.BytePerBloc := Riff.NbrCanaux * Riff.BitsPerSample div 8;
    Riff.BytePerSec := Riff.Frequence * Riff.BytePerBloc;

    Riff.DataBlocId := $61746164;
    Riff.DataSize := InStream.Size;
    OutStream.WriteBuffer(Riff, sizeof(TRiff));
    OutStream.CopyFrom(InStream, WavSize);
    OutStream.SaveToFile(FileName + '.wav');
  finally
    InStream.Free;
    OutStream.Free;
  end;
end;

end.

