unit UsersAction;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseAction;

type
  TUsersAction = class(TBaseAction)
  public
    procedure Index();
    procedure Add();
    procedure Edit();
    procedure Savedata();
    procedure getList();
  end;

implementation

{ TUsersAction }

uses
  uTableMap;

procedure TUsersAction.Add;
begin
  with View do
  begin
    ShowHTML('add');
  end;
end;

procedure TUsersAction.Edit;
var
  user: ISuperObject;
begin
  with View do
  begin
    user := Db.FindFirst(tb_users, 'and id=' + Input('id'));
    setAttr('user', user.AsString);

    ShowHTML('edit');
  end;
end;

procedure TUsersAction.getList;
var
  ret, sdata: ISuperObject;
  con: integer;
  pageindex, pagesize: integer;
begin

  ret := SO();
  with View do
  begin
    pageindex := StrToInt(Input('pageindex'));
    pagesize := StrToInt(Input('pagesize'));

    sdata := Db.FindPage(con, tb_users, 'id', pageindex, pagesize);
    ret.O['rows'] := sdata;
    ret.I['total'] := con;
    ShowJson(ret);
  end;
end;

procedure TUsersAction.Index;
var
  sdata: ISuperObject;
begin
  with View do
  begin
    sdata := Db.Find(tb_users, 'limit 10');
    setAttr('sdata', sdata.AsString);
    ShowHTML('index');
  end;
end;

procedure TUsersAction.Savedata;
var
  userid: string;
  ret: ISuperObject;

begin
  ret := SO();
  with View do
  begin
    userid := Input('id');
    if (userid = '') then
      db.dataset := Db.AddData(tb_users)
    else
      db.dataset := Db.EditData(tb_users, 'id' ,userid);
    try
      with db.dataset do
      begin

        FieldByName('name').AsString := Input('name');

        FieldByName('username').AsString := Input('username');

        FieldByName('phone').AsString := Input('phone');
        FieldByName('age').AsString := Input('age');
        FieldByName('sex').AsString := Input('sex');
        FieldByName('address').AsString := Input('address');
        FieldByName('idcard').AsString := Input('idcard');
        FieldByName('phone').AsString := Input('phone');
        Post;
      end;
      ret.I['code'] := 0;
      ret.S['message'] := '保存成功';
    except
      ret.I['code'] := -1;
      ret.S['message'] := '保存失败';
    end;
    ShowJson(ret);
  end;

end;

end.

