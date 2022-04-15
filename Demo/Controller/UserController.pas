unit UserController;

interface

uses
  System.SysUtils, System.Classes, MVC.DataSet, MVC.JSON, BaseController,
  UserService, RoleService;

type
  [MURL('user', 'user')]
  TUserController = class(TBaseController)
  public
    procedure index;
    //
    [MURL('getData', TMethod.GET)]
    procedure getData;
    procedure getrole;
    procedure add;
    procedure edit;

//    [MURL('del/:id', TMethod.sGET)]
    procedure del(id: string);

    [MURL('save', TMethod.POST)]
    procedure save;
    procedure print;

  end;

implementation


{ TMainController }

procedure TUserController.add;
begin

  SetAttr('role', Service.Role.getData);

end;

procedure TUserController.del(id: string);
begin
  if Service.User.Del(id) then
    Success(0, '删除成功')
  else
    Fail(-1, '删除失败');
end;

procedure TUserController.edit;
begin
  SetAttr('role', Service.Role.getData);
end;

procedure TUserController.getData;
begin
  var ds: Idataset := Service.User.getData(InputToJSON);
  ShowPage(ds);
end;

procedure TUserController.getrole;
begin
  ShowJSON(Service.Role.getData);
end;

procedure TUserController.index;
begin
  SetAttr('role', Service.Role.getData);
  show('index');
end;

procedure TUserController.print;
var
  nowdate: string;
begin
  SetAttr('list', Service.User.getAllData(InputToJSON));
  nowdate := FormatDateTime('yyyy年MM月dd日', Now);
  setAttr('nowdate', nowdate);
end;

procedure TUserController.save;
begin
  if Service.User.save(InputToJSON) then
    Success(0, '保存成功')
  else
    Fail(-1, '保存失败');
end;

end.

