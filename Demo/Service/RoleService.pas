unit RoleService;

interface

uses
  XSuperObject, uTableMap, MVC.BaseService, System.SysUtils;

type
  TRoleService = class(TBaseService)
  public
    function getdata(var con: integer; map: ISuperObject): ISuperObject;
    function getAlldata(map: ISuperObject = nil): ISuperObject;
    function save(map: ISuperObject): Boolean;
    function del(id: string): Boolean;
    function getMenu(var con: integer; map: ISuperObject): ISuperObject;
    function addmenu(roleid: string; menuid: string): Boolean;
    function delmenu(roleid: string; menuid: string): boolean;
    function getSelMenu(var con: integer; map: ISuperObject): ISuperObject;
  end;


implementation

{ TRoleService }

function TRoleService.addmenu(roleid, menuid: string): Boolean;
var
  menus: string;
  ret: ISuperObject;
begin

  try
    ret := db.Default.FindFirst(dict_role, 'and id=' + roleid);
    menus := ret.S['menus'] + menuid;
    with db.Default.EditData(dict_role, 'id', ret.I['id'].ToString) do
    begin
      FieldByName('menus').AsString := menus;
      Post;
      Result := true;
    end;
  except
    Result := false;
  end;
end;

function TRoleService.del(id: string): Boolean;
begin
  Result := Db.Default.DeleteByKey(dict_role, 'id', id);
end;

function TRoleService.delmenu(roleid, menuid: string): boolean;
var
  menus: string;
  ret: ISuperObject;
begin

  try

    ret := db.Default.FindFirst(dict_role, 'and id=' + roleid);
    menus := ret.S['menus'];
    menus := menus.replace(menuid + ',', '');
    with db.Default.EditData(dict_role, 'id', ret.I['id'].ToString) do
    begin
      FieldByName('menus').AsString := menus;
      Post;
      Result := true;
    end;
  except
    Result := false;
  end;
end;

function TRoleService.getAlldata(map: ISuperObject): ISuperObject;
begin

  Result := Db.Default.Query('select * from dict_role');
end;

function TRoleService.getMenu(var con: integer; map: ISuperObject): ISuperObject;
var
  rolejo: ISuperObject;
  list:ISuperObject;
  sql: string;
  roleid: string;
  menus: string;
  s:string;
begin
  s:=map.AsJSON();
  roleid := map.I['roleid'].ToString;
  rolejo := Db.Default.FindFirst(dict_role, 'and id=' + roleid);
  menus := rolejo.S['menus'];
  if menus <> '' then
  begin
    menus := Copy(menus, 0, Length(menus) - 1);
  end
  else
  begin
    menus := '0';
  end;
  sql := ' dict_menu where id in (' + menus + ')';
  list := Db.Default.QueryPage(con, '*', sql, 'id', map.I['page'] - 1, map.I['limit']);
  s:=list.AsJSON();
  Result := list;
end;

function TRoleService.getSelMenu(var con: integer; map: ISuperObject): ISuperObject;
var
  rolejo: ISuperObject;
  list:ISuperObject;
  sql: string;
  roleid: string;
  menus: string;
begin
  roleid := map.S['roleid'];
  rolejo := Db.Default.FindFirst(dict_role, 'and id=' + roleid);
  menus := rolejo.S['menus'];
  if menus <> '' then
  begin
    menus := Copy(menus, 0, Length(menus) - 1);
  end
  else
  begin
    menus := '0';
  end;
  sql := ' dict_menu where id not in (' + menus + ')';
  list := Db.Default.QueryPage(con, '*', sql, 'id', map.I['page'] - 1, map.I['limit']);
  Result := list;
end;

function TRoleService.getdata(var con: integer; map: ISuperObject): ISuperObject;
var
  list: ISuperObject;
  s:string;
begin
  list := Db.Default.FindPage(con, dict_role, 'id', map.I['page'] - 1, map.I['limit']);
  s:=list.AsJSON();
  Result := list;
end;

function TRoleService.save(map: ISuperObject): Boolean;
var
  ret: ISuperObject;
  id: string;
begin
  id := map.S['id'];
  if id = '' then
  begin
    //map.Delete('id');
    ret := Db.Default.FindFirst(dict_role, map);
    if ret = nil then
    begin
      with Db.Default.AddData(dict_role) do
      begin
        FieldByName('rolename').AsString := map.S['rolename'];
        Post;
        Result := true;
      end;
    end
    else
    begin
      Result := false;
    end;
  end
  else
  begin
    ret := Db.Default.FindFirst(dict_role, 'and id<>' + id + ' and rolename=' + Q(map.S['rolename']));
    if ret = nil then
    begin
      with db.Default.EditData(dict_role, 'id', id) do
      begin
        FieldByName('rolename').AsString := map.S['rolename'];
        Post;
        Result := true;
      end;
    end
    else
    begin
      Result := false;
    end;

  end;
end;

end.

