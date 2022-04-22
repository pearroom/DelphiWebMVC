unit MVC.Tool;

interface

uses
  System.SysUtils, System.Classes, Vcl.Imaging.jpeg, Vcl.Graphics, IdURI,
  System.NetEncoding, IdGlobal, IdCoderMIME, EncdDecd, System.RegularExpressions;

type
  ITool = interface
    ['{178CA435-81DE-4D50-AC60-6FA8E4C56A9A}']
    function URLDecode(Asrc: string; AByteEncoding: IIdtextEncoding): string;
    function URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding): string;
    function UnicodeDecode(Asrc: string): string;
    function UnicodeEncode(Asrc: string): string;
    function Base64Decode(S: string): string;
    function Base64Encode(S: string): string;
    function BitmapToString(img: TBitmap): string;
    function StringToBitmap(imgStr: string): TBitmap;
    function StringFormat(Asrc: string): string;
    function Unicode(Asrc: string): string;
    function StringFormatF(Asrc: string): string;
    function PathFmt(path: string): string;
    function UrlFmt(url: string): string;
    function GetGUID: string;
    function NumToImage(num: string): string;
    function getVCode(out num: string): string; //����ͼƬ��base64����
  end;

  TTool = class(TInterfacedObject, ITool)
  private
  public
    function URLDecode(Asrc: string; AByteEncoding: IIdtextEncoding): string;
    function URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding): string;
    function UnicodeDecode(Asrc: string): string;
    function UnicodeEncode(Asrc: string): string;
    function Unicode(Asrc: string): string;
    function Base64Decode(S: string): string;
    function Base64Encode(S: string): string;
    function BitmapToString(img: TBitmap): string;
    function StringToBitmap(imgStr: string): TBitmap;
    function StringFormat(Asrc: string): string;
    function StringFormatF(Asrc: string): string;
    function PathFmt(path: string): string;
    function UrlFmt(url: string): string;
    function GetGUID: string;
    function NumToImage(num: string): string;
    function getVCode(out num: string): string;
  end;

function IITool: ITool;

implementation

function IITool: ITool;
begin
  Result := TTool.Create as ITool;
end;

function TTool.getVCode(out num: string): string;
var
  code: string;
  i: integer;
const
  str = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
begin
  for i := 0 to 3 do
  begin
    code := code + Copy(str, Random(Length(str)), 1);
  end;
  num := code;
  Result := NumToImage(code);
end;

function TTool.NumToImage(num: string): string;
var
  bmp_t: TBitmap;
  i: integer;
  s: string;
begin
  bmp_t := TBitmap.Create;
  try
    bmp_t.SetSize(90, 35);
    bmp_t.Transparent := True;
    for i := 1 to length(num) do
    begin
      s := num[i];
      bmp_t.Canvas.Rectangle(0, 0, 90, 35);
      bmp_t.Canvas.Pen.Style := psClear;
      bmp_t.Canvas.Brush.Style := bsClear;
      bmp_t.Canvas.Font.Color := Random(256) and $C0; // �½���ˮӡ������ɫ
//      bmp_t.Canvas.Font.Size := Random(6) + 11;
      bmp_t.Canvas.Font.Height := Random(5) + 24; //�߷�����ʾ��ȫ
      bmp_t.Canvas.Font.Style := [fsBold];
      bmp_t.Canvas.Font.Name := 'Verdana';
      bmp_t.Canvas.TextOut(i * 15, 5, s); // ��������
    end;
    s := IITool.BitmapToString(bmp_t);
    Result := s;
  finally
    FreeAndNil(bmp_t);
  end;
end;

function TTool.Unicode(Asrc: string): string;
var
  w: Word;
  hz: WideString;
  i: Integer;
  s: string;
begin

  hz := Asrc;

  for i := 1 to Length(hz) do
  begin
    w := Ord(hz[i]);
    s := s + '\u' + IntToHex(w, 4);
  end;
  Result := LowerCase(s);
end;

function TTool.UnicodeDecode(Asrc: string): string;
var
  index: Integer;
  temp, top, last: string;
begin
  index := 1;
  while index >= 0 do
  begin
    index := Pos('\u', Asrc) - 1;
    if index < 0 then         //�� unicode���벻ת�� ,�Զ�����
    begin
      last := Asrc;
      Result := Result + last;
      Exit;
    end;
    top := Copy(Asrc, 1, index); // ȡ�� �����ַ�ǰ�� �� unic ������ַ���������
    temp := temp + Copy(Asrc, index + 1, 6); // ȡ�����룬���� \u,��\u4e3f
    Delete(temp, 1, 2);
    Delete(Asrc, 1, index + 6);
  end;
  Result := Result + top + WideChar(StrToInt('$' + temp));
end;
//�ж��ַ��Ƿ��Ǻ���

function IsHZ(ch: WideChar): boolean;
var
  i: integer;
begin
  i := ord(ch);
  if (i < 19968) or (i > 40869) then
    result := false
  else
    result := true;
end;

function TTool.UnicodeEncode(Asrc: string): string;
var
  w: Word;
  hz: WideString;
  i: Integer;
  s: string;
begin

  hz := StringFormat(Asrc);

  for i := 1 to Length(hz) do
  begin
    if IsHZ(hz[i]) then
    begin
      w := Ord(hz[i]);
      s := s + '\u' + IntToHex(w, 4);
    end
    else
      s := s + hz[i];
  end;
  Result := s;
end;

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

function TTool.UrlFmt(url: string): string;
var
  ret: string;
begin
  ret := url.Replace('\\', '/').Replace('//', '/').Replace('\', '/');
  Result := ret;
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
///��base64�ַ���ת��ΪBitmapλͼ

function TTool.StringFormat(Asrc: string): string;
var
  s: string;
begin
  s := Asrc.Replace(#7, '\a').Replace(#8, '\b').Replace(#12, '\f');
  s := s.Replace(#9, '\t').Replace(#11, '\v').Replace(#92, '\\');
  s := s.Replace(#39, '''').Replace(#34, '\"').Replace(#63, '\?');
  s := s.Replace(#13, '\\r').Replace(#10, '\\n');
  Result := s;
end;

function TTool.StringFormatF(Asrc: string): string;
var
  s: string;
begin
  s := Asrc;
  s := s.Replace(#92, '\\');
  Result := s;
end;

function TTool.StringToBitmap(imgStr: string): TBitmap;
var
  ss: TStringStream;
  ms: TMemoryStream;
  bitmap: TBitmap;
begin
  ss := TStringStream.Create(imgStr);
  ms := TMemoryStream.Create;
  DecodeStream(ss, ms); //��base64�ַ�����ԭΪ�ڴ���
  ms.Position := 0;
  bitmap := TBitmap.Create;
  bitmap.LoadFromStream(ms);
  ss.Free;
  ms.Free;
  result := bitmap;
end;
///��Bitmapλͼת��Ϊbase64�ַ���

function TTool.BitmapToString(img: TBitmap): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
  s: string;
begin
  ms := TMemoryStream.Create;
  img.SaveToStream(ms);
  ss := TStringStream.Create('');
  ms.Position := 0;
  EncodeStream(ms, ss); //���ڴ�������Ϊbase64�ַ���
  s := ss.DataString;
  ms.Free;
  ss.Free;
  result := s;
end;

function TTool.GetGUID: string;
var
  LTep: TGUID;
  sGUID: string;
begin
  CreateGUID(LTep);
  sGUID := GUIDToString(LTep);
  sGUID := StringReplace(sGUID, '-', '', [rfReplaceAll]);
  sGUID := Copy(sGUID, 2, Length(sGUID) - 2);
  result := sGUID;
end;

function TTool.PathFmt(path: string): string;
var
  ret: string;
begin
  {$IFDEF MSWINDOWS}
  ret := path.Replace('\\', '\').Replace('//', '\').Replace('/', '\');
  {$ELSE}
  ret := path.Replace('\\', '/').Replace('//', '/').Replace('\', '/');
  {$ENDIF}
  Result := ret;
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

