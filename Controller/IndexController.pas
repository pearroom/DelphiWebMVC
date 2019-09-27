unit IndexController;

interface

uses
  System.SysUtils, System.Classes, XSuperObject, MVC.BaseController,
  Vcl.Imaging.jpeg, Vcl.Graphics, UsersService;

type
  TIndexController = class(TBaseController)
  private
    user_service: TUsersService;
    function ShowVerifyCode(num: string): string;
  public
    procedure home(value1, value2, value3, value4, value5: string);
    procedure Index;
    procedure login;
    procedure check;
    procedure verifycode;
    procedure setdata;
    procedure showxml;
    procedure showxml1;
    procedure createview; override;
    destructor Destroy; override;
  end;

implementation

uses
  uTableMap, XSuperJSON;


{ TIndexController }
procedure TIndexController.createview;
begin
  inherited;
  user_service := TUsersService.Create(view.Db);
end;

destructor TIndexController.Destroy;
begin
  user_service.free;
  inherited;
end;

procedure TIndexController.home(value1, value2, value3, value4, value5: string);
var
  s: string;
begin
//http://localhost:8004/home/ddd/12/32/eee/333.html
//http://localhost:8004/home/ddd/12/32/eee/333
//http://localhost:8004/home/ddd/12/32/eee/333?name=admin
 //伪静态及Rest风格
  with view do
  begin
    s := InputByIndex(2);
    s := Input('name');
    ShowText(s + ' ' + value1 + ' ' + value2 + ' ' + value3 + ' ' + value4 + ' ' + value5);
  end;
end;

procedure TIndexController.check;
var
  s: string;
  map, ret: ISuperObject;
  code: string;
begin
  with view do
  begin
    map := SO();
    map.S['username'] := Input('username');
    map.S['pwd'] := Input('pwd');
  //  code := Input('vcode');
  //  if code.ToLower = SessionGet('vcode').ToLower then
 //   if code='1234' then

    begin

      ret := user_service.checkuser(map);
      if ret <> nil then
      begin
        SessionSet('user', ret.AsJSON());
        Success(0, '登录成功');
      end
      else
      begin
        Fail(-1, '登录失败,请检查用户名密码');
      end;
    end;
//    else
//    begin
//      Fail(-1, '验证码错误');
//    end;
  end;
end;

procedure TIndexController.verifycode;
var
  code, s: string;
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
    begin
      s := ShowVerifyCode(code);
      Response.ContentType:='text';
      Response.Content := 'data:image/jpeg;base64,' + s;
    end;
  end;
end;

function TIndexController.ShowVerifyCode(num: string): string;
var
  bmp_t: TBitmap;
  i: integer;
  s: string;
begin
  bmp_t := TBitmap.Create;
  try
    bmp_t.SetSize(90, 35);
    bmp_t.Transparent := True;
    for i := 1 to length(num) do
    begin
      s := num[i];
      bmp_t.Canvas.Rectangle(0, 0, 90, 35);
      bmp_t.Canvas.Pen.Style := psClear;
      bmp_t.Canvas.Brush.Style := bsClear;
      bmp_t.Canvas.Font.Color := Random(256) and $C0; // 新建个水印字体颜色
      bmp_t.Canvas.Font.Size := Random(6) + 11;
      bmp_t.Canvas.Font.Style := [fsBold];
      bmp_t.Canvas.Font.Name := 'Verdana';
      bmp_t.Canvas.TextOut(i * 15, 5, s); // 加入文字
    end;
    s := view.Plugin.Tool.BitmapToString(bmp_t);
    Result := s;
  finally
    FreeAndNil(bmp_t);
  end;
end;

procedure TIndexController.Index;
var
  s: string;
  jo1, jo: ISuperObject;
begin
  with View do
  begin
    s := Input('name');
    SessionSet('name', '你好');
    ShowHTML('login');
    //ShowText('hello');
  end;
end;

procedure TIndexController.login;
var
  s: string;
begin
  with View do
  begin

    SessionRemove('user');
    ShowHTML('login');
  end;
end;

procedure TIndexController.setdata;
var
  s: string;
begin
  s := Request.Content;
end;

procedure TIndexController.showxml;
begin
  with view do
  begin

    ShowJSON(db.Default.FindT(tb_users, ''));
  end;
end;

procedure TIndexController.showxml1;
begin
  with view do
  begin

    ShowJSON(db.Default.Find(tb_users, ''));
  end;
end;

end.

