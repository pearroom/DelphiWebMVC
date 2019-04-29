unit IndexController;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseController;

type
  TIndexController = class(TBaseController)
  public
    procedure Index;
    procedure check;
    procedure verifycode;
    procedure setdata;
  end;

implementation

uses
  UsersService, UsersInterface;


{ TIndexController }

procedure TIndexController.check;
var
  s: string;
  map, ret: ISuperObject;
  code: string;
  user_service: IUsersInterface;
begin
  user_service := TUsersService.Create(View.Db);
  with view do
  begin
//    ret := Db.MYSQL.FindFirst('tb_users');  //mysql 使用
//    s := ret.AsString;
    map := SO();
    map.S['username'] := Input('username');
    map.S['pwd'] := Input('pwd');
    code := Input('vcode');
    if code.ToLower = SessionGet('vcode').ToLower then
    begin

      ret := user_service.checkuser(map);
      if ret <> nil then
      begin
        SessionSet('user', ret.AsString);
        Success(0, '登录成功');
      end
      else
      begin
        Fail(-1, '登录失败,请检查用户名密码');
      end;
    end
    else
    begin
      Fail(-1, '验证码错误');
    end;
  end;
end;

procedure TIndexController.Index;
var
  s: string;
  jo: ISuperObject;
begin
  with View do
  begin

    SessionRemove('user');
//    jo := SO();
//    jo.S['msg'] := '你好呀';
//    RedisSetKeyJSON('name', jo);
//    s := RedisGetKeyJSON('name').AsString;
//    RedisSetKeyText('sex', '男');
//    s := RedisGetKeyText('sex');
    ShowHTML('login');
  end;
end;

procedure TIndexController.setdata;
var
  s: string;
begin
  s := Request.Content;
end;

procedure TIndexController.verifycode;
var
  code: string;
  i: integer;
const
  str = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
begin

  with view do
  begin
    for i := 0 to 3 do
    begin
      code := code + Copy(str, Random(Length(str)), 1);
    end;
    SessionSet('vcode', code);
    if Length(code) <> 4 then
    begin
      ShowText('error');
    end
    else
      ShowVerifyCode(code);
  end;
end;

end.

