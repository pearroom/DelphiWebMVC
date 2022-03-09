unit UserService;

interface

uses
  System.SysUtils, System.Classes, MVC.JSON, MVC.DataSet, MVC.Service, TableMap,
  mvc.DB;

type
  TUserService = record
  public
    function getData(map: IJObject): IDataSet;
    function getAllData(map: IJObject): IDataSet;
    function save(map: IJObject): Boolean;
    function Del(id: string): boolean;
  end;

implementation

{ TIndexService }

function TUserService.Del(id: string): boolean;
begin
  var conn: IConn := IIConn;
  Result := conn.Db.DelByKey(Tb_Uses, 'id', id);
end;

function TUserService.getAllData(map: IJObject): IDataSet;
var
  sql: ISQL;
  roleid: string;
begin
  var conn: IConn := IIConn;
  roleid := map.GetS('roleid');
  sql := IISQL(Tb_Uses);
  if roleid <> '0' then
    sql.AndEq('roleid', roleid);
  Result := conn.Db.use('db1').Find(sql);
end;

function TUserService.getData(map: IJObject): IDataSet;
var
  sql: ISQL;
  page, limit: integer;
  roleid: string;
begin
  var conn: IConn := IIConn;
  page := map.GetI('page');
  limit := map.GetI('limit');
  roleid := map.GetS('roleid');
  sql := IISQL(Tb_Uses);
  if roleid <> '0' then
    sql.And_('roleid=' + roleid);
  Result := conn.Db.Find(sql, page - 1, limit);
end;

function TUserService.save(map: IJObject): Boolean;
var
  ret: IDataSet;
  id: string;
  sql: ISQL;
begin
  var conn: IConn := IIConn;
  id := map.GetS('id');
  sql := IISQL;
  conn.Db.StartTransaction; //事务启动
  try
    if id = '' then
    begin
     // map.Delete('id');
      sql.From(Tb_Uses);
      sql.AndEqF('username', map.GetS('username'));

      ret := conn.Db.find(sql);
      if ret.IsEmpty then
      begin
        with conn.Db.Add(Tb_Uses) do
        begin
          FieldByName('username').AsString := map.GetS('username');
          FieldByName('realname').AsString := map.GetS('realname');
          FieldByName('roleid').AsString := map.GetS('roleid');
          FieldByName('pwd').AsString := map.GetS('pwd');
          FieldByName('uptime').AsDateTime := Now;
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
      sql.Clear;
      sql.AndNe('id', id);
      sql.AndEqF('username', map.GetS('username'));
      sql.From(Tb_Uses);
      ret := conn.Db.Find(sql);
      if ret.IsEmpty then
      begin
        with conn.db.Edit(Tb_Uses, 'id', id) do
        begin
          FieldByName('username').AsString := map.GetS('username');
          FieldByName('realname').AsString := map.GetS('realname');
          FieldByName('roleid').AsString := map.GetS('roleid');
          FieldByName('uptime').AsDateTime := Now;
          Post;
          Result := true;
        end;
      end
      else
      begin
        Result := false;
      end;

    end;
    conn.db.Commit; // 事务执行
  except
    conn.Db.Rollback; //事务回滚
    Result := false;
  end;
end;

end.

