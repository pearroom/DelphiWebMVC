unit Plugin.Layui;

interface

uses
  XSuperObject;

type
  TLayui = class
  public
    function getPage(count: Integer; data: ISuperObject): ISuperObject;
  end;

implementation

{ TLayui }

function TLayui.getPage(count: Integer; data: ISuperObject): ISuperObject;
var
  json: ISuperObject;
begin
  json := SO();
  json.I['code'] := 0;
  json.S['msg'] := '';
  json.I['count'] := count;
  json.A['data'] := data.AsArray;
  Result := json;
end;

end.

