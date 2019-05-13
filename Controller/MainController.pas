unit MainController;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseController;

type
  TMainController = class(TBaseController)
  public
    procedure Index;
    procedure home(value1, value2, value3, value4, value5: string);
  end;

implementation

uses
  RoleService, RoleInterface;

{ TMainController }

procedure TMainController.home(value1, value2, value3, value4, value5: string);
var
  s: string;
begin
//http://localhost:8004/main/home/ddd/12/32/eee/333.html
//http://localhost:8004/main/home/ddd/12/32/eee/333
//http://localhost:8004/main/home/ddd/12/32/eee/333?name=admin
 //伪静态及Rest风格
  with view do
  begin
    s := InputByIndex(2);   //按下标获取参数
    s := Input('name');     //获取get参数值
    ShowText(s + ' ' + value1 + ' ' + value2 + ' ' + value3 + ' ' + value4 + ' ' + value5);
  end;
end;

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

