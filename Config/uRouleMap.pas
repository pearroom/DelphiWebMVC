unit uRouleMap;

interface

uses
  MVC.Roule;

type
  TRouleMap = class(TRoule)
  public
    constructor Create(); override;
  end;

implementation

uses
  IndexController, MainController, RoleController, UserController, VIPController,
  PayController;

constructor TRouleMap.Create;
begin
  inherited;
  //Â·¾¶,¿ØÖÆÆ÷,ÊÓÍ¼Ä¿Â¼,À¹½ØÆ÷(Ä¬ÈÏÀ¹½Ø)
  SetRoule('', TIndexController, '', False);
  SetRoule('Main', TMainController, '');
  SetRoule('User', TUserController, 'User');
  SetRoule('Role', TRoleController, 'Role');
  SetRoule('VIP', TVIPController, 'VIP');
  SetRoule('Pay', TPayController, 'Pay');

end;

end.

