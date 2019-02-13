unit LoginPackage;

interface

uses
  System.Classes, Vcl.Controls, uConfig, superobject,BasePackage;

type
  TLoginPackage = class(TBasePackage)
  published
    function getdata(map: ISuperObject): ISuperObject;
  end;

implementation

{ TLoginPackage }


function TLoginPackage.getdata(map: ISuperObject): ISuperObject;
begin
  Result := map;

end;

initialization
  RegisterClass(TLoginPackage);

finalization
  UnRegisterClass(TLoginPackage);

end.

