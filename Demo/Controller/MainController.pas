unit MainController;

interface

uses
  System.SysUtils, System.Classes, XSuperObject, RoleService, MVC.BaseController;

type
  TMainController = class(TBaseController)
  private
    role_service: TRoleService;
  public
    procedure Index;
    procedure CreateView; override;
    destructor Destroy; override;
  end;

implementation


{ TMainController }

procedure TMainController.CreateView;
begin
  inherited;
  role_service := TRoleService.Create(view.Db);
end;

destructor TMainController.Destroy;
begin
  role_service.Free;
  inherited;
end;

procedure TMainController.Index;
var
  user: ISuperObject;
  con: Integer;
  map: ISuperObject;
  ret: ISuperObject;
  s: string;
begin
  with view do
  begin
    user := SO(SessionGet('user'));
  //  s:=user.AsString;
    setAttr('realname', user.S['realname']);
    map := SO();
    map.I['roleid'] := user.I['roleid'];
    map.I['page'] := 1;
    map.I['limit'] := 100;
    ret := role_service.getMenu(con, map);
    setAttrJSON('menuls', ret);
    ShowHTML('main');
  end;
end;

end.

