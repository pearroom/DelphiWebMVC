unit LoginController;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject,
  BaseController;

type
  TLoginController = class(TBaseController)
  public
    procedure index();
    procedure check();
    procedure checknum();
    procedure getalldata();
    procedure getxml;
  end;

implementation

uses
  uTableMap, UsersService, UsersInterface, SimpleXML, uConfig;

procedure TLoginController.check();
var
  users_service: IUsersInterface;
  json: string;
  sdata, ret, wh: ISuperObject;
  username, pwd: string;
  sql: string;
begin
  ret := SO();

  with View do
  begin
    users_service := TUsersService.Create(Db);
    try
      username := Input('username');
      pwd := Input('pwd');
      wh := SO();
      wh.S['username'] := username;
      wh.S['pwd'] := pwd;
      sdata := users_service.checkuser(wh);
      if (sdata <> nil) then
      begin
        json := sdata.AsString;
        Sessionset('username', username);
        Sessionset('name', sdata.S['name']);
        SessionSet('user', sdata.AsString);
        json := Sessionget('user');
        ret.I['code'] := 0;
        ret.S['message'] := 'µÇÂ¼³É¹¦';
      end
      else
      begin
        ret.I['code'] := -1;
        ret.S['message'] := 'µÇÂ¼Ê§°Ü';
      end;
      ShowJson(ret);
    except
      on e: Exception do
        ShowText(e.ToString);
    end;

  end;
end;

procedure TLoginController.checknum;
var
  num: string;
begin
  Randomize;
  num := inttostr(Random(9)) + inttostr(Random(9)) + inttostr(Random(9)) + inttostr(Random(9));
  View.ShowCheckIMG(num, 60, 30);
end;

procedure TLoginController.getalldata;
var
  users_service: IUsersInterface;
  ret: ISuperObject;
begin
  users_service := TUsersService.Create(View.Db);
  ret := users_service.getAlldata(nil);
  view.ShowJSON(ret);
end;

procedure TLoginController.getxml;
var
  XmlDocument: IXmlDocument;
  node: IXmlNode;
begin
  XmlDocument := CreateXmlDocument('data', '1.0', 'utf-8');
  node := XmlDocument.DocumentElement.CloneNode();
  node.SetChildText('name', 'admin');
  XmlDocument.DocumentElement.AppendChild(node);
  view.ShowXML(XmlDocument);
end;

procedure TLoginController.index();
var
  users_service: IUsersInterface;
  ret: boolean;
  jo: ISuperObject;
  s: string;
begin

  if isGET then
    with View do
    begin
      users_service := TUsersService.Create(Db);
      jo := SO();
      jo.S['id'] := '1212';
      users_service.check(jo);
//      SessionSet('username','123');
//      s:=SessionGet('username');
      SessionRemove('username');
      ShowHTML('Login');
    end;
end;

end.

