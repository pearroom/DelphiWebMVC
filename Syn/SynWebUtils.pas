{ *************************************************************************** }
{ SynWebUtils.pas is the 0st file of SynBroker Project                        }
{ by c5soft@189.cn  Version 0.9.2.0  2018-6-7                                 }
{ *************************************************************************** }

unit SynWebUtils;

interface

{$IFNDEF UNICODE}
type
 RawByteString=AnsiString;
{$ENDIF}

function VariantArrayToString(const V: OleVariant): RawByteString;
function StringToVariantArray(const S: RawByteString): OleVariant;

implementation

uses Variants;

function VariantArrayToString(const V: OleVariant): RawByteString;
var
  P: Pointer;
  Size: Integer;
begin
  Result := '';
  if VarIsArray(V) and (VarType(V) and varTypeMask = varByte) then begin
    Size := VarArrayHighBound(V, 1) - VarArrayLowBound(V, 1) + 1;
    if Size > 0 then begin
      SetLength(Result, Size);
      P := VarArrayLock(V);
      try
        Move(P^, Result[1], Size);
      finally
        VarArrayUnlock(V);
      end;
    end;
  end;
end;

function StringToVariantArray(const S: RawByteString): OleVariant;
var
  P: Pointer;
begin
  Result := NULL;
  if Length(S) > 0 then begin
    Result := VarArrayCreate([0, Length(S) - 1], varByte);
    P := VarArrayLock(Result);
    try
      Move(S[1], P^, Length(S));
    finally
      VarArrayUnlock(Result);
    end;
  end;
end;
end.
