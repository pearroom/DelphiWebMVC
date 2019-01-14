unit UserPackage;

interface

uses
  System.Classes,Vcl.Controls,uConfig,superobject;

type
  TUserPackage = class(TPersistent)
  Published
    function getdata(Db:TDB;map:ISuperObject): ISuperObject;
  end;

implementation

uses
  uTableMap;

{ TUserPackage }

function TUserPackage.getdata(Db:TDB;map:ISuperObject): ISuperObject;
var
  s:string;
begin
  s:=map.AsString;
  Result := db.FindFirst(tb_users);
end;

initialization
  RegisterClass(TUserPackage);

finalization
  UnRegisterClass(TUserPackage);

end.

