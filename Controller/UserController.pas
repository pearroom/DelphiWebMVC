unit UserController;

interface

uses
  System.SysUtils, System.Classes, XSuperObject, MVC.BaseController,
  UsersService, RoleService;

type
  TUserController = class(TBaseController)
  private
    role_service: TRoleService;
    user_service: TUsersService;
  public
    procedure Index;
    procedure getData;
    procedure Add;
    procedure Edit;
    procedure Del;
    procedure Save;
    procedure print;
    procedure CreateView; override;
    destructor Destroy; override;
  end;

implementation



{ TUserController }

procedure TUserController.Add;
var
  role: ISuperObject;
begin
  with view do
  begin
    role := role_service.getAlldata();
    setAttrJSON('role', role);
    ShowHTML('add');
  end;
end;

procedure TUserController.CreateView;
begin
  inherited;
  role_service := TRoleService.Create(View.Db);
  user_service := TUsersService.Create(view.Db);
end;

procedure TUserController.Del;
var
  id: string;
begin

  with view do
  begin
    id := Input('id');
    if id <> '' then
    begin
      if user_service.delById(id) then
        Success(0, '删除成功')
      else
        Fail(-1, '删除失败');
    end;
  end;
end;

destructor TUserController.Destroy;
begin
  role_service.Free;
  user_service.Free;
  inherited;
end;

procedure TUserController.Edit;
var
  role: ISuperObject;
begin

  with view do
  begin
    role := role_service.getAlldata();
    setAttrJSON('role', role);
    ShowHTML('edit');
  end;
end;

procedure TUserController.print;
var
  con: Integer;
  ret: ISuperObject;
  map: ISuperObject;
  nowdate: string;
begin
  with View do
  begin
    map := SO();
    map.S['roleid'] := Input('roleid');
    ret := user_service.getAlldata(map);
    setAttrJSON('list', ret);
    nowdate := FormatDateTime('yyyy年MM月dd日', Now);
    setAttr('nowdate', nowdate);
    ShowHTML('print');
  end;
end;

procedure TUserController.getData;
var
  con: Integer;
  ret: ISuperObject;
  map: ISuperObject;
begin
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
begin
  with view do
  begin
    role := role_service.getAlldata();
    setAttrJSON('role', role);
    ShowHTML('index');
  end;
end;

procedure TUserController.Save;
var
  map: ISuperObject;
begin
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
      Success(0, '保存成功');
    end
    else
    begin
      Fail(-1, '保存失败');
    end;
  end;
end;

end.

