unit Plugin.Tool;

interface

uses
  System.SysUtils, System.Classes,Vcl.Imaging.jpeg, Vcl.Graphics,IdURI, IdGlobal,IdCoderMIME,EncdDecd;

type
  TTool = class
  public
    function URLDecode(Asrc: string; AByteEncoding: IIdtextEncoding): string;
    function URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding): string;
    function Base64Decode(S: string): string;
    function Base64Encode(S: string): string;
    function BitmapToString(img:TBitmap):string;
    function StringToBitmap(imgStr: string): TBitmap;
  end;

implementation

function TTool.URLDecode(Asrc: string; AByteEncoding: IIdtextEncoding): string;
begin
  if AByteEncoding <> nil then
    Result := TIdURI.URLDecode(Asrc, AByteEncoding)
  else
    Result := TIdURI.URLDecode(Asrc);
end;

function TTool.URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding): string;
begin
  if AByteEncoding <> nil then
    Result := TIdURI.URLEncode(Asrc, AByteEncoding)
  else
    Result := TIdURI.URLEncode(Asrc);
end;
function TTool.Base64Encode(S: string): string;
var
  base64: TIdEncoderMIME;
 // tmpBytes: TBytes;
begin
  base64 := TIdEncoderMIME.Create(nil);
  try
    base64.FillChar := '=';
    Result := base64.EncodeString(S);
   // tmpBytes := TEncoding.UTF8.GetBytes(S);
   // Result := base64.EncodeBytes(TIdBytes(tmpBytes));
  finally
    base64.Free;
  end;
end;
///将base64字符串转化为Bitmap位图
function TTool.StringToBitmap(imgStr:string):TBitmap;
var ss:TStringStream;
    ms:TMemoryStream;
    bitmap:TBitmap;
begin
    ss := TStringStream.Create(imgStr);
    ms := TMemoryStream.Create;
    DecodeStream(ss,ms);//将base64字符流还原为内存流
    ms.Position:=0;
    bitmap := TBitmap.Create;
    bitmap.LoadFromStream(ms);
    ss.Free;
    ms.Free;
    result :=bitmap;
end;
///将Bitmap位图转化为base64字符串
function TTool.BitmapToString(img:TBitmap): string;
var
  ms:TMemoryStream;
  ss:TStringStream;
  s:string;
begin
    ms := TMemoryStream.Create;
    img.SaveToStream(ms);
    ss := TStringStream.Create('');
    ms.Position:=0;
    EncodeStream(ms,ss);//将内存流编码为base64字符流
    s:=ss.DataString;
    ms.Free;
    ss.Free;
    result:=s;
end;

function TTool.Base64Decode(S: string): string;
var
  base64: TIdDeCoderMIME;
 // tmpBytes: TBytes;
begin
  Result := S;
  base64 := TIdDecoderMIME.Create(nil);
  try
    base64.FillChar := '=';
   // tmpBytes := TBytes(base64.DecodeBytes(S));
    //Result := TEncoding.UTF8.GetString(tmpBytes);
    Result := base64.DecodeString(S);
  finally
    base64.Free;
  end;
end;
end.

