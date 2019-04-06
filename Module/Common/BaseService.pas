{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit BaseService;

interface

uses
  uConfig;

type
  TBaseService = class(TInterfacedObject)
  public
    Db: TDB;
    function Q(str: string): string;
    constructor Create(_Db: TDB);
  end;

implementation

{ TBaseService }

constructor TBaseService.Create(_Db: TDB);
begin
  Db := _Db;
end;

function TBaseService.Q(str: string): string;
begin
  result := '''' + str + '''';
end;

end.

