unit JwtController;

interface

uses
  System.SysUtils, System.Classes, MVC.BaseController;

type
  TJwtController = class(TBaseController)
    procedure index;
    procedure getToken;
    procedure checktoken;
  end;

implementation

{ TJwtController }

procedure TJwtController.index;
begin

end;

procedure TJwtController.checktoken;
var
  token: string;
  ret: string;
begin
  token := Request.Authorization;       //获取认证token
  with view do
  begin
    ret:=Input('name');
    with JWT do
    begin
      if parser('88888888', token) then //解析token
      begin
        ret :=ret+'|'+ Id + '|' + Subject + '|' + IssuedAt + '|' + Expiration + '|' + claimGet('name') + '|' + Issuer + '|' + Audience;
        ShowText(ret);
      end
      else
      begin
        ShowText('验证失败');
      end;
    end;
  end;
end;

procedure TJwtController.getToken;
var
  s: string;
begin
  with View do
  begin
    with JWT do
    begin
      Id := GetGUID;
      Subject := '你好';
      claimAdd('name', '张立找');
      Expiration := DateTimeToStr(Now + 80);
      IssuedAt := DateTimeToStr(Now);
      sign := '88888888';
      Issuer := 'http://api.test.com';
      Audience := 'http://api.test.com';
      s := compact;
      ShowText(s);
    end;
  end;
end;

initialization
  SetRoute('jwt', TJwtController, 'jwt');

end.

