unit MVC.CrossCommon;

interface

const CODEPAGE_US = 1252;

type
 {$ifdef CPU64} // Delphi XE2 seems stable about those types (not Delphi 2009)
  PtrInt = NativeInt;
  PtrUInt = NativeUInt;
  {$else}
  /// a CPU-dependent signed integer type cast of a pointer / register
  // - used for 64-bit compatibility, native under Free Pascal Compiler
  PtrInt = integer;
  /// a CPU-dependent unsigned integer type cast of a pointer / register
  // - used for 64-bit compatibility, native under Free Pascal Compiler
  PtrUInt = cardinal;
  {$endif}

  PStrRec = ^TStrRec;
  /// map the Delphi/FPC dynamic array header (stored before each instance)
  TDynArrayRec = packed record
    /// dynamic array reference count (basic garbage memory mechanism)
    {$ifdef CPUX64}
    _Padding: LongInt; // Delphi/FPC XE2+ expects 16 byte alignment
    {$endif}
    refCnt: Longint;
    /// length in element count
    // - size in bytes = length*ElemSize
    length: PtrInt;
  end;
  PDynArrayRec = ^TDynArrayRec;

   TStrRec =
    {$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
    packed
    {$endif FPC_REQUIRES_PROPER_ALIGNMENT}
    record
{$ifdef FPC}
  {$ifdef ISFPC27}
    codePage: Word;
    elemSize: Word;
  {$endif}
  {$ifdef CPU64}
    _Padding: LongInt;
  {$endif}
    refCnt: SizeInt;
    length: SizeInt;
{$else FPC}
  {$ifdef UNICODE}
    {$ifdef CPU64}
    /// padding bytes for 16 byte alignment of the header
    _Padding: LongInt;
    {$endif}
    /// the associated code page used for this string
    // - exist only since Delphi/FPC 2009
    // - 0 or 65535 for RawByteString
    // - 1200=CP_UTF16 for UnicodeString
    // - 65001=CP_UTF8 for RawUTF8
    // - the current code page for AnsiString
    codePage: Word;
    /// either 1 (for AnsiString) or 2 (for UnicodeString)
    // - exist only since Delphi/FPC 2009
    elemSize: Word;
  {$endif UNICODE}
    /// COW string reference count (basic garbage memory mechanism)
    refCnt: Longint;
    /// length in characters
    // - size in bytes = length*elemSize
    length: Longint;
{$endif FPC}
  end;


  PIntegerDynArray = ^TIntegerDynArray;
  TIntegerDynArray = array of integer;

   TNormTable = packed array[AnsiChar] of AnsiChar;
   PNormTable = ^TNormTable;
   TNormTableByte = packed array[byte] of byte;

   RawUTF8 = type AnsiString(CP_UTF8);
   PUTF8Char = type PAnsiChar;
   PPUTF8Char = ^PUTF8Char;
   function StringToUTF8(const S:string): RawUTF8;
   function UTF8ToString(const S: RawUTF8):string;
   function IdemPChar(p: PUTF8Char; up: PAnsiChar): boolean;


   function StringReplaceAll(const S, OldPattern, NewPattern: RawUTF8): RawUTF8;

   procedure AddInteger(var Values: TIntegerDynArray; var ValuesCount: integer;
                         Value: integer);
   function PosExPas(pSub, p: PUTF8Char; Offset: PtrUInt): PtrInt;
   function PosEx(const SubStr, S: RawUTF8; Offset: PtrUInt): integer;
   function StrPosI(uppersubstr,str: PUTF8Char): PUTF8Char;
   function UrlEncode(const svar: RawUTF8): RawUTF8; overload;
   /// encode a string to be compatible with URI encoding
   function UrlEncode(Text: PUTF8Char): RawUTF8; overload;

    /// decode a string compatible with URI encoding into its original value
   function UrlDecode(U: PUTF8Char): RawUTF8; overload;

   function HexToChar(Hex: PAnsiChar; Bin: PUTF8Char): boolean;

   procedure InitSynCommonsConversionTables;
const
   STRRECSIZE = SizeOf(TStrRec);

type
  TAnsiCharToWord = array[AnsiChar] of word;
  TByteToWord = array[byte] of word;
var
  NormToUpperAnsi7: TNormTable;

  NormToUpperAnsi7Byte: TNormTableByte absolute NormToUpperAnsi7;

  TwoDigitsHex: array[byte] of array[1..2] of AnsiChar;
  TwoDigitsHexW: TAnsiCharToWord absolute TwoDigitsHex;
  TwoDigitsHexWB: array[byte] of word absolute TwoDigitsHex;
  /// lowercase hexadecimal lookup table
  TwoDigitsHexLower: array[byte] of array[1..2] of AnsiChar;
  TwoDigitsHexWLower: TAnsiCharToWord absolute TwoDigitsHexLower;
  TwoDigitsHexWBLower: array[byte] of word absolute TwoDigitsHexLower;
  ConvertHexToBin: array[byte] of byte;
  NormToUpper: TNormTable;
implementation
uses System.SysUtils;

procedure FastSetString(var s: RawUTF8; p: pointer; len: PtrInt);
var r: PAnsiChar;
    sr: PStrRec;
begin
  if len<=0 then
    r := nil else begin
    GetMem(r,len+(STRRECSIZE+4));
    sr := pointer(r);
    sr^.codePage := CP_UTF8;
    sr^.elemSize := 1;
    sr^.refCnt := 1;
    sr^.length := len;
    inc(sr);
    PCardinal(PAnsiChar(sr)+len)^ := 0; // ends with four #0
    r := pointer(sr);
    if p<>nil then
      Move(p^,sr^,len);
  end;
  s := '';
  pointer(s) := r;
end;
function Utf8ToUnicode(const Dest: PWideChar; MaxDestChars: Cardinal; const Source: PAnsiChar; SourceBytes: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Byte;
  wc: Cardinal;
begin
  if Source = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := Cardinal(-1);
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceBytes) and (count < MaxDestChars) do
    begin
      wc := Cardinal(Source[i]);
      Inc(i);
      if (wc and $80) <> 0 then
      begin
        if i >= SourceBytes then Exit;          // incomplete multibyte AnsiChar
        wc := wc and $3F;
        if (wc and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then Exit;      // malformed trail byte or out of range AnsiChar
          if i >= SourceBytes then Exit;        // incomplete multibyte AnsiChar
          wc := (wc shl 6) or (c and $3F);
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then Exit;       // malformed trail byte

        Dest[count] := WideChar((wc shl 6) or (c and $3F));
      end
      else
        Dest[count] := WideChar(wc);
      Inc(count);
    end;
    if count >= MaxDestChars then count := MaxDestChars-1;
    Dest[count] := #0;
  end
  else
  begin
    while (i < SourceBytes) do
    begin
      c := Byte(Source[i]);
      Inc(i);
      if (c and $80) <> 0 then
      begin
        if i >= SourceBytes then Exit;          // incomplete multibyte AnsiChar
        c := c and $3F;
        if (c and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then Exit;      // malformed trail byte or out of range AnsiChar
          if i >= SourceBytes then Exit;        // incomplete multibyte AnsiChar
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then Exit;       // malformed trail byte
      end;
      Inc(count);
    end;
  end;
  Result := count+1;
end;
function UnicodeToUtf8(const Dest: PAnsiChar; MaxDestBytes: Cardinal; const Source: PWideChar; SourceChars: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Cardinal;
begin
  Result := 0;
  if Source = nil then Exit;
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceChars) and (count < MaxDestBytes) do
    begin
      c := Cardinal(Source[i]);
      Inc(i);
      if c <= $7F then
      begin
        Dest[count] := AnsiChar(c);
        Inc(count);
      end
      else if c > $7FF then
      begin
        if count + 3 > MaxDestBytes then
          break;
        Dest[count] := AnsiChar($E0 or (c shr 12));
        Dest[count+1] := AnsiChar($80 or ((c shr 6) and $3F));
        Dest[count+2] := AnsiChar($80 or (c and $3F));
        Inc(count,3);
      end
      else //  $7F < Source[i] <= $7FF
      begin
        if count + 2 > MaxDestBytes then
          break;
        Dest[count] := AnsiChar($C0 or (c shr 6));
        Dest[count+1] := AnsiChar($80 or (c and $3F));
        Inc(count,2);
      end;
    end;
    if count >= MaxDestBytes then count := MaxDestBytes-1;
    Dest[count] := #0;
  end
  else
  begin
    while i < SourceChars do
    begin
      c := Integer(Source[i]);
      Inc(i);
      if c > $7F then
      begin
        if c > $7FF then
          Inc(count);
        Inc(count);
      end;
      Inc(count);
    end;
  end;
  Result := count+1;  // convert zero based index to byte count
end;
function HexToChar(Hex: PAnsiChar; Bin: PUTF8Char): boolean;
var B,C: PtrUInt;
begin
  if Hex<>nil then begin
    B := ConvertHexToBin[Ord(Hex[0])];
    if B<=15 then begin
      C := ConvertHexToBin[Ord(Hex[1])];
      if C<=15 then begin
        if Bin<>nil then
          Bin^ := AnsiChar(B shl 4+C);
        result := true;
        exit;
      end;
    end;
  end;
  result := false; // return false if any invalid char
end;

function UrlDecode(U: PUTF8Char): RawUTF8;
var P,Dest: PUTF8Char;
    L: integer;
    tmp: array[byte] of AnsiChar;
begin
result := '';
  L := Length(U);
  if L=0 then
    exit;
  if L>SizeOf(tmp) then begin
    SetLength(result,L);
    Dest := pointer(result);
  end else
    Dest := @tmp;
  P := Dest;
  repeat
    case U^ of
      #0:  break; // reached end of URI
      '%': if not HexToChar(PAnsiChar(U+1),P) then
             P^ := U^ else
             inc(U,2); // browsers may not follow the RFC (e.g. encode % as % !)
      '+': P^  := ' ';
    else
      P^ := U^;
    end; // case s[i] of
    inc(U);
    inc(P);
  until false;
  if Dest=@tmp then
    SetString(result,PUTF8Char(@tmp),P-Dest) else
    SetLength(result,P-Dest);
end;

function UrlEncode(const svar: RawUTF8): RawUTF8;
begin
  result := UrlEncode(pointer(svar));
end;
function UrlEncode(Text: PUTF8Char): RawUTF8;
  function Enc(s, p: PUTF8Char): PUTF8Char;
  var c: PtrInt;
  begin
    repeat
      c := ord(s^);
      case c of
      0: break;
      ord('0')..ord('9'),ord('a')..ord('z'),ord('A')..ord('Z'),
      ord('_'),ord('-'),ord('.'),ord('~'): begin
        // cf. rfc3986 2.3. Unreserved Characters
        p^ := AnsiChar(c);
        inc(p);
        inc(s);
        continue;
      end;
      ord(' '): p^ := '+';
      else begin
        p^ := '%'; inc(p);
        PWord(p)^ := TwoDigitsHexWB[c]; inc(p);
      end;
      end; // case c of
      inc(p);
      inc(s);
    until false;
    result := p;
  end;
  function Size(s: PUTF8Char): PtrInt;
  begin
    result := 0;
    if s<>nil then
    repeat
      case s^ of
        #0: exit;
        '0'..'9','a'..'z','A'..'Z','_','-','.','~',' ': begin
          inc(result);
          inc(s);
          continue;
        end;
        else inc(result,3);
      end;
      inc(s);
    until false;
  end;
begin
  result := '';
  if Text=nil then
    exit;
  SetLength(result,Size(Text)); // reserve exact memory count
  Enc(Text,pointer(result));
end;
function StringToUTF8(const S:string): RawUTF8;
var
  L, LS: Integer;
  Temp: pointer;
begin
  Result := '';

  LS:=Length(s);
  if LS = 0 then Exit;

  GetMem(Temp, LS*3 + 4);
  try
    L := UnicodeToUtf8(PAnsiChar(Temp), LS*3+4, PWideChar(@s[1]), LS);
    if L > 0 then
      begin
      SetLength(Result, L-1);
      Move(Temp^,Result[1],L-1);
      end;
  finally
    FreeMem(Temp);
    end;
end;
function UTF8ToString(const S: RawUTF8):string;
var
  L, LS: Integer;
  Temp: pointer;
begin
  Result := '';

  LS:=length(s);
  if LS = 0 then Exit;

  GetMem(Temp,LS*SizeOf(WideChar)+4);
  try
    L := Utf8ToUnicode(PWideChar(Temp), LS+1, PAnsiChar(@S[1]), LS);
    if L > 0 then
      begin
      SetLength(Result,L-1);
      Move(Temp^,Result[1],(L-1)*SizeOf(WideChar));
      end
    else
      Result := '';
  finally
    FreeMem(Temp);
  end;
end;

function StrPosI(uppersubstr,str: PUTF8Char): PUTF8Char;
var C: AnsiChar;
begin
  if (uppersubstr<>nil) and (str<>nil) then begin
    C := uppersubstr^;
    result := str;
    while result^<>#0 do begin
      if NormToUpperAnsi7[result^]=C then
        if IdemPChar(result+1,PAnsiChar(uppersubstr)+1) then
          exit;
      inc(result);
    end;
  end;
  result := nil;
end;
procedure AddInteger(var Values: TIntegerDynArray; var ValuesCount: integer;
                         Value: integer);
function NextGrow(capacity: integer): integer;
begin // algorithm similar to TFPList.Expand for the increasing ranges
  result := capacity;
  if result<128 shl 20 then
    if result<8 shl 20 then
      if result<=128 then
        if result>8 then
          inc(result,16) else
          inc(result,4) else
        inc(result,result shr 2) else
      inc(result,result shr 3) else
    inc(result,16 shl 20);
end;
begin
  if ValuesCount=length(Values) then
    SetLength(Values,NextGrow(ValuesCount));
  Values[ValuesCount] := Value;
  inc(ValuesCount)
end;
function PosExPas(pSub, p: PUTF8Char; Offset: PtrUInt): PtrInt;
var len, lenSub: PtrInt;
    ch: AnsiChar;
    pStart, pStop: PUTF8Char;
label Loop2, Loop6, TestT, Test0, Test1, Test2, Test3, Test4,
      AfterTestT, AfterTest0, Ret, Exit;
begin
  result := 0;
  if (p=nil) or (pSub=nil) or (Offset<1) then
    goto Exit;
  {$ifdef FPC}
  len := _LStrLenP(p);
  lenSub := _LStrLenP(pSub)-1;
  {$else}
  len := PInteger(p-4)^;
  lenSub := PInteger(pSub-4)^-1;
  {$endif}
  if (len<lenSub+PtrInt(Offset)) or (lenSub<0) then
    goto Exit;
  pStop := p+len;
  inc(p,lenSub);
  inc(pSub,lenSub);
  pStart := p;
  inc(p,Offset+3);
  ch := pSub[0];
  lenSub := -lenSub;
  if p<pStop then goto Loop6;
  dec(p,4);
  goto Loop2;
Loop6: // check 6 chars per loop iteration
  if ch=p[-4] then goto Test4;
  if ch=p[-3] then goto Test3;
  if ch=p[-2] then goto Test2;
  if ch=p[-1] then goto Test1;
Loop2:
  if ch=p[0] then goto Test0;
AfterTest0:
  if ch=p[1] then goto TestT;
AfterTestT:
  inc(p,6);
  if p<pStop then goto Loop6;
  dec(p,4);
  if p>=pStop then goto Exit;
  goto Loop2;
Test4: dec(p,2);
Test2: dec(p,2);
  goto Test0;
Test3: dec(p,2);
Test1: dec(p,2);
TestT: len := lenSub;
  if lenSub<>0 then
    repeat
      if (psub[len]<>p[len+1]) or (psub[len+1]<>p[len+2]) then
        goto AfterTestT;
      inc(len,2);
    until len>=0;
  inc(p,2);
  if p<=pStop then goto Ret;
  goto Exit;
Test0: len := lenSub;
  if lenSub<>0 then
    repeat
      if (psub[len]<>p[len]) or (psub[len+1]<>p[len+1]) then
        goto AfterTest0;
      inc(len,2);
    until len>=0;
  inc(p);
Ret:
  result := p-pStart;
Exit:
end;
function PosEx(const SubStr, S: RawUTF8; Offset: PtrUInt): integer;
begin
 result := PosExPas(pointer(SubStr),pointer(S),Offset);
end;

function StringReplaceAll(const S, OldPattern, NewPattern: RawUTF8): RawUTF8;
  procedure Process(found: integer);
  var oldlen,newlen,i,last,posCount,sharedlen: integer;
      pos: TIntegerDynArray;
      src,dst: PAnsiChar;
  begin
    oldlen := length(OldPattern);
    newlen := length(NewPattern);
    SetLength(pos,64);
    pos[0] := found;
    posCount := 1;
    repeat
      found := PosEx(OldPattern,S,found+oldlen);
      if found=0 then
        break;
      AddInteger(pos,posCount,found);
    until false;
    FastSetString(result,nil,Length(S)+(newlen-oldlen)*posCount);
    last := 1;
    src := pointer(s);
    dst := pointer(result);
    for i := 0 to posCount-1 do begin
      sharedlen := pos[i]-last;
      Move(src^,dst^,sharedlen);
      inc(src,sharedlen+oldlen);
      inc(dst,sharedlen);
      Move(pointer(NewPattern)^,dst^,newlen);
      inc(dst,newlen);
      last := pos[i]+oldlen;
    end;
    Move(src^,dst^,length(S)-last+1);
  end;

var j: integer;
begin
  if (S='') or (OldPattern='') or (OldPattern=NewPattern) then
    result := S else begin
    j := PosEx(OldPattern, S, 1); // our PosEx() is faster than Pos()
    if j=0 then
      result := S else
      Process(j);
  end;
end;
function IdemPChar(p: PUTF8Char; up: PAnsiChar): boolean;
begin
 result := false;
  if p=nil then
    exit;
  if (up<>nil) and (up^<>#0) then
    repeat
      if up^<>NormToUpperAnsi7[p^] then
        exit;
      inc(up);
      inc(p);
    until up^=#0;
  result := true;
end;
procedure InitSynCommonsConversionTables;
var
 i:integer;
begin
  for i := 0 to 255 do
    NormToUpperAnsi7Byte[i] := i;
  for i := ord('a') to ord('z') do
    dec(NormToUpperAnsi7Byte[i],32);
  Move(NormToUpperAnsi7,NormToUpper,138);
end;
initialization
InitSynCommonsConversionTables;
finalization
end.
