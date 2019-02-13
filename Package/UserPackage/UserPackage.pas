unit UserPackage;

interface

uses
  System.Classes, Vcl.Controls, uConfig, superobject, BasePackage;

type
  TUserPackageV2 = class(TBasePackage)
  published
    function checkuser(map: ISuperObject): ISuperObject;
    function getAlldata(map: ISuperObject): ISuperObject;
  end;

implementation

uses
  uTableMap;

{ TUserPackageV2 }

function TUserPackageV2.checkuser(map: ISuperObject): ISuperObject;
var
  s: string;
begin

  s := map.AsString;
  Result := db.FindFirst(tb_users, map);
end;

function TUserPackageV2.getAlldata(map: ISuperObject): ISuperObject;
begin
  Result := db.Find(tb_users,'');
end;

initialization
  RegisterClass(TUserPackageV2);

finalization
  UnRegisterClass(TUserPackageV2);

end.

