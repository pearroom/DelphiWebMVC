unit BaseController;

interface

uses
  System.SysUtils, System.Classes, MVC.Route, MVC.JSON, MVC.Controller,
  MVC.DataSet, System.JSON, jpeg, Vcl.Graphics, MVC.TOOL, ServiceMap;

type
  MURL = TMURL;

  TMethod = THTTPMethod;

  TBaseController = class(TController)
  private
    function NumToImage(num: string): string;
  public
    Service: TServiceMap;                     {业务单元工厂}
    function getVCode: string;                {获取验证码}
    function Intercept: Boolean; override;    {拦截器在控制器的父类添加，每个子类也可以重构，添加自已的拦截器}
    procedure ShowPage(ds: IDataSet);         {封装分页参数，可根据自己的需要修改}

  end;

implementation



{ TBaseController }

function TBaseController.getVCode: string;
var
  code: string;
  i: integer;
const
  str = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
begin
  for i := 0 to 3 do
  begin
    code := code + Copy(str, Random(Length(str)), 1);
  end;
  Session.setValue('vcode', code);
  Result := NumToImage(code);
end;

function TBaseController.Intercept: Boolean;
begin
  if Session.getValue('username') = '' then
  begin
    Response.SendRedirect('/');
    Result := True;
  end
  else
    Result := False;

end;

procedure TBaseController.ShowPage(ds: IDataSet);
var
  list: IJObject;
begin
  list := IIJObject;
  list.SetI('code', 0);
  list.SetS('msg', '获取成功');
  list.SetI('count', ds.Count);
  list.O.AddPair('data', TJSONObject.ParseJSONValue(ds.toJSONArray) as TJSONArray);
  ShowJSON(list);
end;

function TBaseController.NumToImage(num: string): string;
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
//      bmp_t.Canvas.Font.Size := Random(6) + 11;
      bmp_t.Canvas.Font.Height := Random(5) + 24; //高分屏显示不全
      bmp_t.Canvas.Font.Style := [fsBold];
      bmp_t.Canvas.Font.Name := 'Verdana';
      bmp_t.Canvas.TextOut(i * 15, 5, s); // 加入文字
    end;
    s := IITool.BitmapToString(bmp_t);
    Result := s;
  finally
    FreeAndNil(bmp_t);
  end;
end;

end.


