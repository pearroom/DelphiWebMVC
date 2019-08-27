{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.BasePackage;

interface

uses
  System.Classes, Vcl.Controls,System.SysUtils, uConfig,uDBConfig;

type
  TBasePackage = class(TPersistent)
  private

  published
    Db: TDBConfig;
    function JsonToString(json: string): string;
    function setDB(_Db: TDBConfig): Boolean;
  end;

implementation

{ TBasePackage }

function TBasePackage.setDB(_Db: TDBConfig): Boolean;
begin
  Result := true;
  try
    self.Db := _Db;
  except
    Result := False;
  end;
end;
function TBasePackage.JsonToString(json: string): string;
var
  i: Integer;
  index: Integer;
  temp, top, last: string;
begin
  index := 1;
  while index >= 0 do
  begin
    index := json.IndexOf('\u');
    if index < 0 then
    begin
      last := json;
      Result := Result + last;
      Exit;
    end;
    top := Copy(json, 1, index); //取出 编码字符前的 非 unic 编码的字符，如数字
    temp := Copy(json, index + 1, 6); //取出编码，包括 \u    ,如\u4e3f
    Delete(temp, 1, 2);
    Delete(json, 1, index + 6);
    result := Result + top + WideChar(StrToInt('$' + temp));
  end;
end;
end.

