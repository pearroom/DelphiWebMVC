unit uDBConfig;

interface

uses
  MVC.DBSQLite, MVC.DBMySql;

type
  TDBConfig = class
  public
    Default: TDBSQLite;   //必须有Default成员变量名
   // MYSQL: TDBMySql;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TDBConfig }

constructor TDBConfig.Create;
begin
  Default := TDBSQLite.Create('SQLite');
 // MYSQL := TDBMySql.Create('MYSQL');
end;

destructor TDBConfig.Destroy;
begin
  Default.Free;
 // MYSQL.Free;
  inherited;
end;

end.

