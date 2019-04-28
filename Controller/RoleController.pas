unit RoleController;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseController;

type
  TRoleController = class(TBaseController)
  public
    procedure Index;
    procedure add;
    procedure edit;
    procedure save;
    procedure getData;
    procedure getAllData;
    procedure getMenu;
    procedure del;
    procedure addmenu;
    procedure delmenu;
    procedure addmenuview;
    procedure getselmenu;
  end;

implementation

uses
  RoleService, RoleInterface;

{ TRoleController }

procedure TRoleController.add;
begin
  with view do
  begin
    ShowHTML('add');
  end;
end;

procedure TRoleController.addmenu;
var
  roleid, menuid: string;
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with view do
  begin
    roleid := Input('roleid');
    menuid := Input('menuid');
    if role_service.addmenu(roleid, menuid) then
      Success(0, 'Ìí¼Ó³É¹¦')
    else
      Fail(-1, 'Ìí¼ÓÊ§°Ü');
  end;
end;

procedure TRoleController.addmenuview;
begin
  with view do
  begin
    ShowHTML('addmenu');
  end;
end;

procedure TRoleController.del;
var
  id: Integer;
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with view do
  begin
    id := InputInt('id');
    if role_service.del(IntToStr(id)) then
      Success(0, 'É¾³ý³É¹¦')
    else
      Fail(-1, 'É¾³ýÊ§°Ü');

  end;
end;

procedure TRoleController.delmenu;
var
  roleid, menuid: string;
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with view do
  begin
    roleid := Input('roleid');
    menuid := Input('menuid');
    if role_service.delmenu(roleid, menuid) then
      Success(0, 'É¾³ý³É¹¦')
    else
      Fail(-1, 'É¾³ýÊ§°Ü');
  end;
end;

procedure TRoleController.edit;
begin
  with view do
  begin
    ShowHTML('edit');
  end;
end;

procedure TRoleController.getAllData;
var
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with view do
  begin
    ShowJSON(role_service.getAlldata());
  end;
end;

procedure TRoleController.getData;
var
  con: Integer;
  ret: ISuperObject;
  map: ISuperObject;
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with View do
  begin
    map := SO();
    map.I['page'] := InputInt('page');
    map.I['limit'] := InputInt('limit');
    ret := role_service.getdata(con, map);
    ShowPage(con, ret);
  end;

end;

procedure TRoleController.getMenu;
var
  ret, map: ISuperObject;
  con: integer;
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with view do
  begin
    map := SO();
    map.I['page'] := InputInt('page');
    map.I['limit'] := InputInt('limit');
    map.S['roleid'] := Input('roleid');
    ret := role_service.getMenu(con, map);
    ShowPage(con, ret);
  end;
end;

procedure TRoleController.getselmenu;
var
  roleid: string;
  con: integer;
  map, ret: ISuperObject;
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with view do
  begin
    map := SO();
    roleid := Input('roleid');
    map.I['page'] := InputInt('page');
    map.I['limit'] := InputInt('limit');
    map.S['roleid'] := roleid;
    ret := role_service.getSelMenu(con, map);
    ShowPage(con, ret);
  end;
end;

procedure TRoleController.Index;
begin
  with View do
  begin
    ShowHTML('index');
  end;
end;

procedure TRoleController.save;
var
  map: ISuperObject;
  role_service: IRoleInterface;
begin
  role_service := TRoleService.Create(View.Db);
  with view do
  begin
    map := SO();
    map.S['rolename'] := Input('rolename');
    map.S['id'] := Input('id');
    if role_service.save(map) then
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

