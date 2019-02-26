unit uRouleMap;

interface

uses
  Roule;

type
  TRouleMap = class(TRoule)
  public
    constructor Create(); override;
  end;

implementation

uses
  MainController, CaiWuController, FirstController, IndexController,
  KuCunController, LoginController, UsersController, XiaoShouController;

constructor TRouleMap.Create;
begin
  inherited;
  //路径,控制器,视图目录,是否拦截
  //SetRoule(name: string; ACtion: TClass; path: string = '';isInterceptor:Boolean=True);
  SetRoule('', TLoginController, 'login',False);
  SetRoule('Main', TMainController, 'main');
  SetRoule('Users', TUsersController, 'users');
  SetRoule('kucun', TKuCunController, 'kucun');
  SetRoule('caiwu', TCaiWuController, 'caiwu');
  SetRoule('xiaoshou', TXiaoShouController, 'xiaoshou');

end;

end.

