unit uRouteMap;

interface

uses
  MVC.Route;

type
  TRouteMap = class(TRoute)
  public
    constructor Create(); override;
  end;

implementation

uses
  IndexController, MainController, RoleController, UserController, VIPController,
  PayController;

constructor TRouteMap.Create;
begin
  inherited;
  //Â·¾¶,¿ØÖÆÆ÷,ÊÓÍ¼Ä¿Â¼,À¹½ØÆ÷(Ä¬ÈÏÀ¹½Ø)

  SetRoute('', TIndexController, '', False);
  SetRoute('Main', TMainController, '');
  SetRoute('User', TUserController, 'User');
  SetRoute('Role', TRoleController, 'Role');
  SetRoute('VIP', TVIPController, 'VIP');
  SetRoute('Pay', TPayController, 'Pay');
end;

end.

