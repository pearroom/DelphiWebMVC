unit LoginAction;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject,
  BaseAction;

type
  TLoginAction = class(TBaseAction)
  public
    procedure index();
    procedure check();
    procedure checknum();
  end;

implementation

uses
  uTableMap;

procedure TLoginAction.check();
var
  json: string;
  sdata, ret: ISuperObject;
  username, pwd: string;
  sql: string;
begin
  ret := SO();
  with View do
  begin
    //建立 tb_users 表 3 个字段 username,pwd,name
    try
      username := Input('username');
      pwd := Input('pwd');
      Sessionset('username', username);
      json:=Sessionget('username');
      sql := ' and username=' + Q(username) + ' and pwd=' + Q(pwd);
      sdata := Db.FindFirst(tb_users, sql);
      if (sdata <> nil) then
      begin
        json:=sdata.AsString;
        Sessionset('username', username);
        Sessionset('name', sdata.S['name']);
        ret.I['code'] := 0;
        ret.S['message'] := '登录成功';
      end else begin
        ret.I['code'] := -1;
        ret.S['message'] := '登录失败';
      end;
      ShowJson(ret);
    except on e:Exception do
      ShowText(e.ToString);
    end;

  end;
end;

procedure TLoginAction.checknum;
var
  num:string;
begin
  Randomize;
  num:= inttostr(Random(9))+inttostr(Random(9))+inttostr(Random(9))+inttostr(Random(9));
  View.ShowCheckIMG(num,60,30);
end;

procedure TLoginAction.index();
begin
  with View do
  begin
    Db.Find(tb_users, '');
   // Sleep(5000);
    ShowHTML('Login');
  end;
end;

end.

