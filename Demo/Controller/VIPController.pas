unit VIPController;

interface

uses
  System.SysUtils, System.Classes, MVC.BaseController, XSuperObject;

type
  TVIPController = class(TBaseController)
    procedure index;
    procedure getdata;
  end;

implementation

uses
  uTableMap;

{ TVIPController }

procedure TVIPController.getdata;
var
  name, phone, sex: string;
  page, limit: integer;
  sql: string;
  con: integer;
  ret: ISuperObject;
  s:string;
begin
  with view do
  begin
    name := Input('name');
    phone := input('phone');
    sex := Input('sex');
    page := InputInt('page');
    limit := InputInt('limit');

    if name <> '' then
      sql := sql + ' and name like ' + Q('%' + name + '%');
    if phone <> '' then
      sql := sql + ' and phone = ' + Q(phone);
    if sex <> '' then
      sql := sql + ' and sex = ' + Q(sex);

    ret := Db.Default.FindPage(con, tb_vip, sql, '', page-1, limit);
    s:=ret.AsJSON();
    ShowPage(con,ret);
  end;
end;

procedure TVIPController.index;
begin
  with view do
  begin
    ShowHTML('index');
  end;
end;

end.

