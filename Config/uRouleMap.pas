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
  LoginAction, UsersAction, MainAction, IndexAction, KuCunAction, CaiWuAction, XiaoShouAction;

constructor TRouleMap.Create;
begin
  inherited; //±ØÐë¼Ì³Ð
 // SetRoule('', TIndexAction);
  SetRoule('/', TLoginAction, 'login');
  SetRoule('/Main', TMainAction, 'main');
  SetRoule('/Users', TUsersAction, 'users');
  SetRoule('/kucun', TKuCunAction, 'kucun');
  SetRoule('/caiwu', TCaiWuAction, 'caiwu');
  SetRoule('/xiaoshou', TXiaoShouAction, 'xiaoshou');


end;

end.

