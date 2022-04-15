unit IndexController;

interface

uses
  System.SysUtils, System.Classes, MVC.Route, MVC.JSON, MVC.Controller,
  MVC.LogUnit, System.JSON, MVC.DataSet, BaseController, MVC.Verify, MVC.Tool,
  IndexService;

type
  [MURL('')]                                //设置空值为根目录
  TIndexContrller = class(TBaseController)  //继承父类

  public
    [MURL('index')]                         //index方法的请求访问路径，如果没有设置，访问路径为方法名称 ，默认是get方式访问
    procedure index;
    procedure login;
    procedure check;                        //check 没有设置 请求路径，将以check 路径访问
    procedure verifycode;
    function Intercept: Boolean; override;  //实现自己的拦截器 ，这里不采取拦截返回 false
    [MURL('getdata', GET)]                 //这里请求rqdata地址并且请求是post方式，将会访问 getdata 方法,
    procedure getdata;
    procedure getone;
    procedure socket;
  end;

implementation




{ TIndexContrller }

procedure TIndexContrller.verifycode;
begin
  ShowText('data:image/jpeg;base64,' + getVCode);
end;

procedure TIndexContrller.check;
var
  vcode, scode: string;
  map: IJObject;
  ds: IDataSet;
  name: string;
begin
  vcode := input('vcode');

  scode := Session.getValue('vcode');
  map := InputToJSON;
  ds := Service.Index.checkuser(map);

  if ds.IsEmpty then
  begin
    Fail(-1, '账号密码错误');

  end
  else if vcode.ToUpper = scode.ToUpper then
  begin
    name := ds.DS.FieldByName('realname').Value;
    Session.setValue('username', name);

    Success();
  end
  else
    Fail(-1, '验证码错误');
end;

procedure TIndexContrller.getdata;
begin
  ShowJSON(Service.Index.getdata);
end;

procedure TIndexContrller.getone;
begin

end;

procedure TIndexContrller.index;
var
  jo: IJObject;
  verify: IVerify;
  ret: IJArray;
  msg: string;
  i: Integer;
begin

  SetAttr('username', 'hello');
  SetAttr('kk', '20');
  SetAttr('dd', 'ok');
  jo := IIJObject;
  jo.SetS('name', '你好');
  jo.SetS('sex', '男');
  jo.SetS('idcard', '130124198312');
  jo.SetS('phone', '15512132874');
  SetAttr('data', jo);

  verify := IIVerify;
  verify.Add('idcard', VerifyType.vIdCard, '身份证格式错误');
  verify.Add('phone', VerifyType.vPhone, '手机号错误');

  ret := IIJArray();
  if verify.Verify(jo, ret) then
    SetAttr('msg', '谢谢支持')
  else
  begin
    for i := 0 to ret.A.Count - 1 do
      msg := msg + ret.A.Items[i].FindValue('Error').Value + '|';
    SetAttr('msg', msg);
  end;
end;

function TIndexContrller.Intercept: Boolean;
begin
  Result := false;
end;

procedure TIndexContrller.login;
begin
  Session.remove('username');
end;

procedure TIndexContrller.socket;
begin
  Show('socket');
end;

end.

