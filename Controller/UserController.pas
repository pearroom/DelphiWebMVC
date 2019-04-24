unit UserController;

interface

uses
  System.SysUtils, System.Classes, superobject, View,
  BaseController;

type
  TUserController = class(TBaseController)
  public
    procedure Index;
    procedure getData;
    procedure Add;
    procedure Edit;
    procedure Del;
    procedure Save;
  end;

implementation

uses
  UsersService, RoleService, UsersInterface, RoleInterface;

{ TUserController }

procedure TUserController.Add;
var
  role: ISuperObject;
    role_service: IRoleInterface;
begin
  with view do
  begin
    Role_Service := TRoleService.Create(Db);
    role := Role_Service.getAlldata();
    setAttrJSON('role', role);
    ShowHTML('add');
  end;
end;

procedure TUserController.Del;
var
  id: string;
  user_service: IUsersInterface;
begin
  user_service := TUsersService.Create(view.Db);
  with view do
  begin
    id := Input('id');
    if id <> '' then
    begin
      if user_service.delById(id) then
        Success(0, 'É¾³ý³É¹¦')
      else
        Fail(-1, 'É¾³ýÊ§°Ü');
    end;
  end;
end;

procedure TUserController.Edit;
var
  role: ISuperObject;
    role_service: IRoleInterface;
begin

  with view do
  begin
    Role_Service := TRoleService.Create(Db);
    role := Role_Service.getAlldata();
    setAttrJSON('role', role);
    ShowHTML('edit');
  end;
end;

procedure TUserController.getData;
var
  con: Integer;
  ret: ISuperObject;
  map: ISuperObject;
  user_service: IUsersInterface;
begin
  user_service := TUsersService.Create(View.Db);
  with View do
  begin
    map := SO();
    map.I['page'] := InputInt('page');
    map.I['limit'] := InputInt('limit');
    map.S['roleid'] := Input('roleid');
    ret := user_service.getdata(con, map);
    ShowPage(con, ret);
  end;

end;

procedure TUserController.Index;
var
  role: ISuperObject;
    role_service: IRoleInterface;
begin
  with view do
  begin
    Role_Service := TRoleService.Create(Db);
    role := Role_Service.getAlldata();
    setAttrJSON('role', role);
    ShowHTML('index');
  end;
end;

procedure TUserController.Save;
var
  map: ISuperObject;
  user_service: IUsersInterface;
begin
  user_service := TUsersService.Create(View.Db);
  with view do
  begin
    map := SO();
    map.S['username'] := Input('username');
    map.S['roleid'] := Input('roleid');
    map.S['realname'] := Input('realname');
    map.S['pwd'] := Input('pwd');
    map.S['id'] := Input('id');
    if user_service.save(map) then
    begin
      Success(0, '±£´æ³É¹¦');
    end
    else
    begin
      Fail(-1, '±£´æÊ§°Ü');
    end;

  end;
end;

end.

