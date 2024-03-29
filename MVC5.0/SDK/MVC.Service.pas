{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       ��Ȩ���� (C) 2022-2 ����ӭ(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.Service;

interface

uses
  System.SysUtils, System.Classes, MVC.DB, MVC.Config;

type
  TService = class(TInterfacedObject)
  private
    FDb: TDB;

  public
    property Db: TDB read FDb;
    function Q(str: string): string;
    function GetGUID: string;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TService }
function TService.GetGUID: string;
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

constructor TService.Create;
begin
  FDb := TDB.Create;
end;

destructor TService.Destroy;
begin
  Db.Free;
  inherited;
end;

function TService.Q(str: string): string;
begin
  Result := QuotedStr(str);
end;

end.

