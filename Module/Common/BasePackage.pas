unit BasePackage;

interface

uses
  System.Classes, Vcl.Controls, uConfig;

type
  TBasePackage = class(TPersistent)
  published
    Db: TDB;
    function setDB(_Db: TDB): Boolean;
  end;

implementation

{ TBasePackage }

function TBasePackage.setDB(_Db: TDB): Boolean;
begin
  Result := true;
  try
    self.Db := _Db;
  except
    Result := False;
  end;
end;

end.

