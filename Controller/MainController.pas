unit MainController;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseController;

type
  TMainController = class(TBaseController)
  public
    procedure Index;
  end;

implementation

uses
  RoleService, RoleInterface;

{ TMainController }

procedure TMainController.Index;
var
  user: ISuperObject;
  con: Integer;
  map: ISuperObject;
  ret: ISuperObject;
  role_service: IRoleInterface;
  s: string;
begin
  role_service := Troleservice.Create(view.Db);
  with view do
  begin
    user := SO(SessionGet('user'));
    s := user.AsString;
    setAttr('realname', user.S['realname']);
    map := SO();
    map.S['roleid'] := user.S['roleid'];
    map.I['page'] := 1;
    map.I['limit'] := 100;
    ret := role_service.getMenu(con, map);
    setAttrJSON('menuls', ret);
    ShowHTML('main');
  end;
end;

end.

