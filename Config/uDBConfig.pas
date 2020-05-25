unit uDBConfig;

interface

uses
  MVC.DBSQLite, MVC.DBMySql, MVC.DBBase;

type
  TDBConfig = class
  public
    Default: TDBSQLite;   //必须有Default成员变量名
    MYSQL: TDBMySql;
    function use(db: string): TDBBase;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TDBConfig }

constructor TDBConfig.Create;
begin
  Default := TDBSQLite.Create('SQLite');
  MYSQL := TDBMySql.Create('MYSQL');
end;

destructor TDBConfig.Destroy;
begin
  Default.Free;
  MYSQL.Free;
  inherited;
end;

function TDBConfig.use(db: string): TDBBase;
begin
  if db = 'sqlite' then
  begin
    Result := Default;
  end;
  if db = 'MYSQL' then
  begin
    Result := MYSQL;
  end;
end;

end.

