{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2022-2 苏兴迎(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.DB;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Web.HTTPApp,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.Phys.FBDef, FireDAC.Phys.FB, FireDAC.DApt, Data.DB,
  FireDAC.Comp.Client, MVC.Config, MVC.LogUnit, MVC.DM, MVC.JSON, system.json,
  MVC.DataSet, FireDAC.Comp.DataSet, MVC.Tool;

type
  TDBConns = class
  private
    ConnList: Tlist<TFDConnection>;
  public
    function findDb(DbName: string): TFDConnection; //找对应名称的数据库链接
    constructor Create();
    destructor Destroy; override;
  end;

  TDBItem = class
  private
    DbConns: TDBConns;
    Conn: TFDConnection;
    FDbState: Integer;
    FID: string;
    TMP_CDS: TFDQuery;
    FOverTime: TDateTime;
    FDriverName: string;
    procedure SetDbState(const Value: Integer);
    procedure SetID(const Value: string);
    procedure SetOverTime(const Value: TDateTime);
    function PageMySql(sql: ISQL; pNumber, pSize: Integer): IDataSet;
    function PageSqlite(sql: ISQL; pNumber, pSize: Integer): IDataSet;

    function PageMSSQL08(sql: ISQL; pNumber, pSize: Integer): IDataSet;
    function PageMSSQL12(sql: ISQL; pNumber, pSize: Integer): IDataSet;
    function PageMSSQL(sql: ISQL; pNumber, pSize: Integer): IDataSet;
    function PageFireBird(sql: ISQL; pNumber, pSize: integer): IDataSet;
    function PageOracle(sql: ISQL; pNumber, pSize: integer): IDataSet;
    procedure SetDriverName(const Value: string);
  public
    property DbState: Integer read FDbState write SetDbState; //0可用，1使用中，2停用，3可删除
    property ID: string read FID write SetID;
    property OverTime: TDateTime read FOverTime write SetOverTime;
    property DriverName: string read FDriverName write SetDriverName;
   //
    function TryConn: boolean; //尝试进行数据库链接
    procedure StartTransaction(); //启动事务
    procedure Commit;        //事务提交
    procedure Rollback;      //事务回滚
    function GetFirstConn: TFDConnection;

    function GetMSSQLVer: string; //获取mssql 服务器版本 根据版本号使用不同的分页算法
    procedure SetConn(DbName: string); //设置使用数据库
    function Query(sql: string): IDataSet;
    function ExecSQL(sql: string): Integer; overload;
    function ExecSQL(sqltpl: ISQLTpl): Integer; overload;
    function Find(sql: ISQL): IDataSet; overload;
    function Find(sql: string): IDataSet; overload;
    function Find(sqltpl: ISQLTpl): IDataSet; overload;
    function Find(sqltpl: ISQLTpl; pNumber: Integer; pSize: integer): IDataSet; overload;
    function Find(sql: ISQL; pNumber: Integer; pSize: integer): IDataSet; overload;//分页查询
    function FindByKey(tablename: string; key: string; value: string): IDataSet;
    function Add(tablename: string): TFDQuery;
    function Edit(tablename: string; key: string; value: string): TFDQuery;
    function DelByKey(tablename: string; key: string; value: string): Boolean;
    function filterSQL(sql: string): string;
  //
    constructor Create(isConn: Boolean = True);
    destructor Destroy; override;
  end;

  TDBPool = class(TThread)
  private
    isClose: Boolean;
    DBList: TDictionary<string, TDBItem>;
    procedure ClearAction;
  protected
    procedure Execute; override;
  public
    procedure setParams;
    function getDbItem: TDBItem;
    procedure freeDbItem(dbitem: TDBItem);
    constructor Create;
    destructor Destroy; override;
  end;

  TDB = class(TDBItem)     //创建时不新建连接
  private
    dbitem: TDBItem;
    defdbitem: TDBItem;
  public     /// <remarks>
    /// 用来调用其它数据库.
    /// 例如:use('db2').
    /// 需要在配置文件内配置db2参数.
    /// </remarks>
    function use(DbName: string): TDBItem;
    constructor Create;
    destructor Destroy; override;
  end;

  TFieldT = TFieldType;

  TParamT = TParamType;

  IStoredProc = interface
    function Open: boolean;
    function StoredProc: TFDStoredProc;
    procedure AddParams(FieldName: string; FieldType: TFieldType; ParamValue: Variant; ParamType: TParamType = TParamT.ptInput);
    function ToJSON(): string;
  end;

  TStoredProc = class(TInterfacedObject, IStoredProc)
  private
    FStoredProc: TFDStoredProc;
    FDb: TDB;
  public
    function Open: boolean;
    function StoredProc: TFDStoredProc;
    procedure AddParams(FieldName: string; FieldType: TFieldType; ParamValue: Variant; ParamType: TParamType = TParamT.ptInput);
    function ToJSON(): string;
    constructor Create(db: TDB; StoredProcName: string);
    destructor Destroy; override;
  end;

  IConn = interface
    function Db: TDb;
  end;

  TConn = class(TInterfacedObject, IConn)
  private
    FDb: TDb;
  public
    function Db: TDb;
    constructor Create;
    destructor Destroy; override;
  end;

var
  DBPool: TDBPool;


function IIConn: IConn; //获取一个新的链接

function IIStoredProc(db: TDB; StoredProcName: string): IStoredProc;

implementation

function IIConn: IConn;
begin
  Result := TConn.Create as IConn;
end;

function IIStoredProc(db: TDB; StoredProcName: string): IStoredProc;
begin
  Result := TStoredProc.Create(db, StoredProcName) as IStoredProc;
end;
{ TDBItem }

function TDBItem.Add(tablename: string): TFDQuery;
var
  sql: string;
begin
  Result := nil;
  if not TryConn then
    Exit;
  if (Trim(tablename) = '') then
    Exit;
  try
    sql := filterSQL(sql);
    sql := 'select * from ' + tablename + ' where 1=2';
    TMP_CDS.Connection := Conn;
    TMP_CDS.SQL.Text := sql;
    TMP_CDS.Open;
    TMP_CDS.Append;
    Result := TMP_CDS;
  except
    on e: Exception do
    begin
      Result := nil;
      log(e.ToString);
    end;
  end;
end;

procedure TDBItem.Commit;
begin
  if not TryConn then
    Exit;
  conn.Commit;
end;

constructor TDBItem.Create(isConn: Boolean);
begin

  if isConn then
  begin
    DbConns := TDBConns.Create;
    if DbConns.ConnList.Count > -1 then
    begin
      Conn := DbConns.ConnList[0];
      DriverName := conn.DriverName;
    end;
  end;

  Dbstate := 0;
end;

function TDBItem.DelByKey(tablename, key, value: string): Boolean;
var
  sql: string;
begin
  Result := False;
  if not TryConn then
    Exit;
  if (Trim(tablename) = '') then
    Exit;
  if (Trim(key) = '') then
    Exit;
  if (Trim(value) = '') then
    Exit;
  try
    sql := 'delete from ' + tablename + ' where ' + key + '=' + value;
    Result := ExecSQL(sql) > 0;
  except
    on e: Exception do
    begin
      log('SQL执行异常:' + e.Message + '-' + sql);
      Result := False;
    end;
  end;
end;

destructor TDBItem.Destroy;
begin

  if Assigned(DbConns) then
  begin
    DbConns.Free;
  end;
  TMP_CDS.Free;
  inherited;
end;

function TDBItem.filterSQL(sql: string): string;
begin
  if Config.show_sql then
    log(sql);
 // Result := sql.Replace(';', '').Replace('-', '');
  Result := sql;
end;

function TDBItem.Edit(tablename, key, value: string): TFDQuery;
var
  sql: string;
begin
  Result := nil;
  if not TryConn then
    Exit;
  if (Trim(tablename) = '') then
    Exit;
  if (Trim(key) = '') then
    Exit;
  try
    sql := 'select * from ' + tablename + ' where ' + key + ' = ' + value;
    sql := filterSQL(sql);
    TMP_CDS.Connection := Conn;
    TMP_CDS.Open(sql);
    if (not TMP_CDS.IsEmpty) then
    begin
      TMP_CDS.First;
      TMP_CDS.Edit;
      Result := TMP_CDS;
    end
    else
      Result := nil;
  except
    Result := nil;
  end;
end;

function TDBItem.ExecSQL(sqltpl: ISQLTpl): Integer;
var
  sql: string;
begin
  sql := sqltpl.AsISQL.SQL.Text;
  Result := ExecSQL(sql);
end;

function TDBItem.ExecSQL(sql: string): Integer;
var
  cds: IDataSet;
begin
  Result := 0;
  if not TryConn then
    Exit;
  if (Trim(sql) = '') then
    Exit;
  try
    sql := filterSQL(sql);
    cds := IIDataSet;
    cds.DS.Connection := Conn;
    Result := cds.DS.ExecSQL(sql);

  except
    on e: Exception do
    begin
      log('SQL执行异常:' + e.Message + '-' + sql);
      Result := 0;
    end;
  end;
end;

function TDBItem.Find(sql: ISQL): IDataSet;
var
  cds: IDataSet;
  s: string;
begin
  Result := nil;

  if TryConn then
  begin
    try
      cds := IIDataSet;
      cds.DS.Connection := Conn;
      s := filterSQL(sql.Text);
      cds.DS.Open(s);
      Result := cds;
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message);
        Result := nil;
      end;

    end;
  end;

end;

function TDBItem.Find(sql: ISQL; pNumber, pSize: integer): IDataSet;
var
  device, mssqlver, ver: string;
begin

  device := DriverName;
  if device.ToLower = 'mysql' then
  begin
    Result := PageMySql(sql, pNumber, pSize);
  end
  else if device.ToLower = 'fb' then
  begin
    Result := PageFireBird(sql, pNumber, pSize);
  end
  else if device.ToLower = 'sqlite' then
  begin
    Result := PageSqlite(sql, pNumber, pSize);
  end
  else if device.ToLower = 'ora' then
  begin
    Result := PageOracle(sql, pNumber, pSize);
  end
  else if device.ToLower = 'mssql' then
  begin
  //如果是mssql 数据库 判断当前所使用版本来使用
  {SELECT SERVERPROPERTY('ProductVersion') AS 实例版本}
    mssqlver := GetMSSQLVer;
    ver := mssqlver.Split(['.'])[0];
    if ver.ToInteger = 10 then   // 版本是10 是 mssql2008
    begin
      Result := PageMSSQL08(sql, pNumber, pSize);
    end
    else if ver.ToInteger > 10 then   // 大于 10，11：mssql2012;12 mssql2014;13 mssql2016;14mssql2017;
    begin
      Result := PageMSSQL12(sql, pNumber, pSize);
    end
    else if ver.ToInteger = 8 then  //2000版本
    begin
      Result := PageMSSQL(sql, pNumber, pSize);
    end;
  end
  else
    Result := nil;
end;

function TDBItem.Find(sqltpl: ISQLTpl; pNumber, pSize: integer): IDataSet;
begin
  Result := find(sqltpl.AsISQL, pNumber, pSize);
end;

function TDBItem.Find(sqltpl: ISQLTpl): IDataSet;
var
  sql: string;
  i_sql: ISQL;
begin
  i_sql := sqltpl.AsISQL;
  if i_sql <> nil then
  begin
    sql := i_sql.sql.Text;
    Result := Query(sql);
  end
  else
  begin
    Log('没有获取SQL脚本');
  end;
end;

function TDBItem.Find(sql: string): IDataSet;
begin

  Result := query(sql);
end;

function TDBItem.FindByKey(tablename, key, value: string): IDataSet;
var
  sql: Isql;
begin

  try
    if not TryConn then
      Exit;
    if (Trim(tablename) = '') then
      Exit;
    if (Trim(key) = '') then
      Exit;
    if (Trim(value) = '') then
      Exit;
    sql := IISQL(tablename);
    sql.AndEq(key, value);
    Result := find(sql);
  except
    on e: Exception do
    begin
      log(e.Message);
      Result := nil;
    end;

  end;
end;

function TDBItem.GetFirstConn: TFDConnection;
begin
  if DbConns.ConnList.Count > 0 then
    Result := DbConns.ConnList[0]
  else
    Result := nil;
end;

function TDBItem.GetMSSQLVer: string;
var
  ds: IDataSet;
begin
  ds := Query('SELECT SERVERPROPERTY(''ProductVersion'') AS ver');
  Result := ds.DS.FieldByName('ver').AsString;
end;

function TDBItem.PageFireBird(sql: ISQL; pNumber, pSize: integer): IDataSet;
var
  sq, order: string;
  count: Integer;
  dataset: IDataSet;
begin
  Result := nil;
  if (not TryConn) or (Trim(sql.getSelect) = '') or (Trim(sql.getFrom) = '') then
    Exit;
  order := sql.getOrder;
  try
    try
      sq := 'select count(1) as N ' + sql.getFrom;
      sq := filterSQL(sq);
      count := conn.ExecSQLScalar(sq);
      sq := 'select FIRST ' + inttostr(pSize) + ' SKIP ' + inttostr(pNumber * pSize) + ' ' + sql.getSelect + sql.getFrom + ' ' + Trim(order);
      dataset := Query(sq);
      dataset.setCount(count);
      Result := dataset;
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sq);
        Result := nil;
      end;

    end;
  finally
    Result := dataset;
  end;

end;

function TDBItem.PageMSSQL(sql: ISQL; pNumber, pSize: Integer): IDataSet;
var
  sq, order: string;
  count: integer;
  tmp: string;
  dataset: IDataSet;
begin
  Result := nil;
  if (not TryConn) or (Trim(sql.getSelect) = '') or (Trim(sql.getFrom) = '') then
    Exit;

  order := sql.getOrder;
  try
    try
      sq := 'select count(1) as N ' + sql.getFrom;
      sq := filterSQL(sq);
      count := conn.ExecSQLScalar(sq);
      if Pos('where', sql.getFrom) > 0 then
        tmp := ' and '
      else
        tmp := ' where ';
      sq := ' select top ' + inttostr(pSize) + ' ' + sql.getSelect + sql.getFrom;
      if pNumber > 0 then
      begin
        sq := sq + tmp + ' id not in(select top ' + IntToStr(pSize * pNumber) + ' id ' + sql.getFrom + ')';
      end;
      sq := sq + ' ' + Trim(order);
      dataset := Query(sq);
      dataset.setCount(count);
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sq);
        Result := nil;
      end;
    end;
  finally
    Result := dataset;
  end;
end;

function TDBItem.PageMSSQL08(sql: ISQL; pNumber, pSize: Integer): IDataSet;
var
  sq, order: string;
  count: integer;
  dataset: IDataSet;
begin
  Result := nil;
  if (not TryConn) or (Trim(sql.getSelect) = '') or (Trim(sql.getFrom) = '') then
    Exit;

  order := sql.getOrder;

  try
    try

      sq := 'select count(1) as N ' + sql.getFrom;
      sq := filterSQL(sq);
      count := Conn.ExecSQLScalar(sq);

      sq := ' select *,ROW_NUMBER() OVER(ORDER BY row) AS RowNo from (' + sql.getSelect + ',0 row' + sql.getFrom + ') tmp1 ';

      sq := ' select * from (' + sq + ') tmp2 where RowNo between ' + IntToStr(pNumber * pSize) + ' and ' + IntToStr(pNumber * pSize + pSize);
      sq := sq + ' ' + order;
      dataset := Query(sq);
      dataset.setCount(count);
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sq);
        Result := nil;
      end;
    end;
  finally
    Result := dataset;
  end;
end;

function TDBItem.PageMSSQL12(sql: ISQL; pNumber, pSize: Integer): IDataSet;
var
  sq, order: string;
  count: integer;
  dataset: IDataSet;
begin
  Result := nil;
  if (not TryConn) or (Trim(sql.getSelect) = '') or (Trim(sql.getFrom) = '') then
    Exit;
  order := sql.getOrder;
  try
    try
      sq := 'select count(1) as N ' + sql.getFrom;
      sq := filterSQL(sq);
      count := Conn.ExecSQLScalar(sq);
      sq := sql.getSelect + sql.getFrom + ' ' + Trim(order) + ' offset ' + inttostr(pNumber * pSize) + ' rows fetch next ' + inttostr(pSize) + ' rows only ';
      dataset := Query(sq);
      dataset.setCount(count);
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sq);
        Result := nil;
      end;

    end;
  finally
    Result := dataset;
  end;

end;

function TDBItem.PageMySql(sql: ISQL; pNumber, pSize: Integer): IDataSet;
var
  sq: string;
  count: integer;
  dataset: IDataSet;
begin
  dataset := nil;
  if (not TryConn) or (Trim(sql.getSelect) = '') or (Trim(sql.getFrom) = '') then
    Exit;
  try
    try
      sq := 'select count(1) as N' + sql.getFrom;
      sq := filterSQL(sq);
      count := Conn.ExecSQLScalar(sq);
      sq := sql.getSelect + sql.getFrom + ' ' + sql.getOrder + ' limit ' + inttostr(pNumber * pSize) + ',' + inttostr(pSize);
      dataset := Query(sq);
      dataset.setCount(count);
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sq);
        Result := nil;
      end;
    end;
  finally
    Result := dataset;
  end;
end;

function TDBItem.PageOracle(sql: ISQL; pNumber, pSize: integer): IDataSet;
var
  sq: string;
  count: integer;
  dataset: Idataset;
begin
  Result := nil;
  if (not TryConn) or (Trim(sql.getSelect) = '') or (Trim(sql.getFrom) = '') then
    Exit;
  try
    try
      sq := 'select count(1) as N ' + sql.getFrom;
      sq := filterSQL(sq);
      count := conn.ExecSQLScalar(sq);
      sq := 'select A.*,to_number(rownum) rn from(' + sql.getSelect + sql.getFrom + ' ' + sql.getOrder + ') A ';
      sq := 'select * from (' + sq + ') where rn > ' + IntToStr(pSize * pNumber) + ' and rn <=' + IntToStr(pSize * pNumber + pSize);

      dataset := Query(sq);
      dataset.setCount(count);
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sq);
        Result := nil;
      end;
    end;
  finally
    Result := dataset;
  end;
end;

function TDBItem.PageSqlite(sql: ISQL; pNumber, pSize: Integer): IDataSet;
var
  sq: string;
  count: integer;
  dataset: IDataSet;
begin
  dataset := nil;
  if (not TryConn) or (Trim(sql.getSelect) = '') or (Trim(sql.getFrom) = '') then
    Exit;

  try
    try
      sq := 'select count(1) as N ' + sql.getFrom;
      sq := filterSQL(sq);
      count := Conn.ExecSQLScalar(sq);
      sq := sql.getSelect + sql.getFrom + ' ' + sql.getOrder + ' limit ' + inttostr(pNumber * pSize) + ',' + inttostr(pSize);
      dataset := Query(sq);
      dataset.setCount(count);
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sq);
        Result := nil;
      end;

    end;
  finally
    Result := dataset;
  end;

end;

function TDBItem.Query(sql: string): IDataSet;
var
  cds: IDataSet;
begin
  Result := nil;
  if Trim(sql) = '' then
  begin
    exit;
  end;

  if TryConn then
  begin
    try
      cds := IIDataSet;
      cds.DS.Connection := Conn;
      sql := filterSQL(sql);
      cds.DS.Open(sql);
      Result := cds;
    except
      on e: Exception do
      begin
        log('SQL执行异常:' + e.Message + '-' + sql);
        Result := nil;

      end;
    end;
  end;

end;

procedure TDBItem.Rollback;
begin
  if not TryConn then
    Exit;
  conn.Rollback;
end;

procedure TDBItem.SetConn(DbName: string);
begin
  Self.Conn := DbConns.findDb(DbName);
  self.DriverName := Self.Conn.DriverName;
end;

procedure TDBItem.SetDbState(const Value: Integer);
begin
  FDbState := Value;
end;

procedure TDBItem.SetDriverName(const Value: string);
begin
  FDriverName := Value;
end;

procedure TDBItem.SetID(const Value: string);
begin
  FID := Value;
end;

procedure TDBItem.SetOverTime(const Value: TDateTime);
begin
  FOverTime := Value;
end;

procedure TDBItem.StartTransaction;
begin
  if not TryConn then
    Exit;
  conn.StartTransaction;
end;

function TDBItem.TryConn: boolean;
begin
  if Conn = nil then
  begin
    Result := false;
    exit;
  end;
  try
    if not Conn.Connected then
      Conn.Connected := true;
    if TMP_CDS = nil then
    begin
      TMP_CDS := TFDQuery.Create(nil);
      TMP_CDS.Connection := Conn;
    end;
    if Conn.Connected then
    begin
      LogDebug('数据库链接成功');
      Result := true;
    end
    else
    begin
      Result := False;
      LogDebug('数据库链接失败');
    end;

  except
    on e: Exception do
    begin
      log(e.Message);
      Result := false;

    end;
  end;
end;


{ TDB }

constructor TDB.Create;
begin
  defdbitem := DBPool.getDbItem;
  Conn := defdbitem.Conn;
  DriverName := conn.DriverName;
  //获取链接池链接
  //设置 conn值
end;

destructor TDB.Destroy;
begin
  //释放链接到连接池
  DBPool.freeDbItem(defdbitem);
  if Assigned(dbitem) then
    DBPool.freeDbItem(dbitem);
  inherited;
end;

function TDB.use(DbName: string): TDBItem;
begin
  if not Assigned(dbitem) then
    dbitem := DBPool.getDbItem;
  //连接池查找dbitem
  dbitem.SetConn(DbName);
  Result := dbitem;

end;

{ TDBConns }

constructor TDBConns.Create();
var
  dbconfig: IJObject;
  DbType: string;
  i: integer;
  Db: TFDConnection;
begin
  ConnList := TList<TFDConnection>.Create();

  dbconfig := IIJObject(config.DBConfig);
  for i := 0 to dbconfig.O.Count - 1 do
  begin
    DbType := dbconfig.O.Pairs[i].JsonString.Value;
    Db := TFDConnection.Create(nil);
    Db.ConnectionDefName := DbType;
    ConnList.Add(Db);
  end;

end;

destructor TDBConns.Destroy;
var
  i: Integer;
begin
  for i := 0 to ConnList.Count - 1 do
  begin
    ConnList[i].Connected := false;
    ConnList[i].Free;
  end;
  ConnList.Free;
  inherited;
end;

function TDBConns.findDb(DbName: string): TFDConnection;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to ConnList.Count - 1 do
  begin
    if ConnList[i].ConnectionDefName = DbName then
    begin
      Result := ConnList[i];
      Break;
    end;
  end;
  if Result = nil then
  begin
    log(DbName + '数据库名称未配置');
  end;
end;


{ TDBPool }

constructor TDBPool.Create;
begin
  inherited Create(False);
  DBList := TDictionary<string, TDBItem>.Create();
  isClose := false;
  TThread.CreateAnonymousThread(
    procedure
    begin
      while not isClose do
      begin
        Sleep(10);
        if Config.isOver then
        begin
          setParams;
          break;
        end;
      end;
    end).Start;
end;

destructor TDBPool.Destroy;
var
  key: string;
begin
  inherited;
  isClose := true;
  for key in DBList.Keys do
    DBList.Items[key].Free;
  DBList.Free;
//  Sleep(20);   //等待20 等线程10后退出

end;

procedure TDBPool.ClearAction;
var
  item: TDbItem;
  key: string;
  tmp_dblist: TDictionary<string, TDbItem>;
begin
  if DBList.Count < 2 then
    exit;
  Lock(DBList);
  tmp_dblist := TDictionary<string, TDbItem>.Create(DBList);
  UnLock(DBList);
  try
    for key in tmp_dblist.Keys do
    begin

      DBlist.TryGetValue(key, item);
      if Assigned(item) then
      begin
        if (Now() > item.OverTime) and (item.DbState = 0) then
        begin
          Lock(DBList);
          item.DbState := 2;
          DBList.AddOrSetValue(item.ID, item);
          UnLock(DBList);
          Break;
        end
        else if item.DbState = 2 then
        begin
          Lock(DBList);
          DBList.Remove(item.ID);
          item.Free;
          UnLock(DBList);
          Break;
        end;
      end;
      Sleep(100);
    end;
  finally
    tmp_dblist.Clear;
    tmp_dblist.Free;
  end;
end;

procedure TDBPool.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    try
      Inc(k);
      if k >= 1000 then
      begin
        k := 0;
        try
          ClearAction;
        except
          on e: Exception do
            log(e.Message);
        end;
      end;
    finally
      Sleep(10);
    end;
  end;
end;

procedure TDBPool.freeDbItem(dbitem: TDBItem);
begin
  Lock(DBList);
  if dbitem <> nil then
  begin
    dbitem.DbState := 0;
    DBList.AddOrSetValue(dbitem.ID, dbitem);
  end;
  UnLock(DBList);
end;

function TDBPool.getDbItem: TDBItem;
var
  key: string;
  item: TDBItem;
  findDb: boolean;
begin
  findDb := false;
  Lock(DBList);
  for key in DBList.Keys do
  begin
    if dblist.TryGetValue(key, item) then
    begin
      if item.DbState = 0 then
      begin
        findDb := true;
        Break;
      end;
    end;
  end;
  if not findDb then
  begin
    item := TDBItem.Create();
    item.ID := GetGUID;
  end;
  item.Conn := item.GetFirstConn;
  item.DbState := 1; //修改为使用中状态
  item.OverTime := Now + (1 / 24 / 60) * 1;
  DBList.AddOrSetValue(item.ID, item);
  UnLock(DBList);
  Result := item;

end;

procedure TDBPool.setParams;
var
  dbconfig: IJObject;
  connjo: TJSONObject;
  i: Integer;
  key, value: string;
  oParams: TStringList;
  j: Integer;
  connkey, connValue: string;
  driverID, Database: string;
begin
  with MVCDM do
  begin
    DBManager.Active := false;
    dbconfig := IIJObject(config.DBConfig);
    for i := 0 to dbconfig.O.Count - 1 do
    begin
      oParams := TStringList.Create;
      key := dbconfig.O.Pairs[i].JsonString.Value;
      connjo := dbconfig.O.Pairs[i].JsonValue as TJSONObject;
      Database := '';
      driverID := '';
      for j := 0 to connjo.Count - 1 do
      begin
        connkey := connjo.Pairs[j].JsonString.Value;
        connValue := connjo.Pairs[j].JsonValue.Value;
        value := connkey + '=' + Trim(connValue);
        oParams.Add(value);
        if connkey = 'DriverID' then
          driverID := connValue;
        if connkey = 'Database' then
          Database := connValue;
        if (driverID = 'SQLite') and (Database <> '') then
        begin
		      {$IFDEF SERVICE}
          Database := Config.BasePath + oParams.Values['Database'];
		      {$ELSE}
          Database := oParams.Values['Database'];
		      {$ENDIF}
          Database := IITool.PathFmt(Database);
          LogDebug(Database);
          oParams.Values['Database'] := Database;
          Database := '';
        end;
      end;
      DBManager.AddConnectionDef(key, driverID, oParams);
      oParams.Free;
    end;
    DBManager.Active := true;
  end;

end;

{ TStoredProc }

constructor TStoredProc.Create(db: TDB; StoredProcName: string);
begin
  FDb := db;
  if not FDb.TryConn then
    Exit;
  if FStoredProc = nil then
  begin
    FStoredProc := TFDStoredProc.Create(nil);
  end;
  FStoredProc.Connection := FDb.Conn;
  FStoredProc.StoredProcName := StoredProcName;
end;

destructor TStoredProc.Destroy;
begin
  StoredProc.Free;
  inherited;
end;

procedure TStoredProc.AddParams(FieldName: string; FieldType: TFieldType; ParamValue: Variant; ParamType: TParamType);
var
  device, tmp: string;
begin
  tmp := '';
  device := FDb.DriverName;
  if device.ToLower = 'mssql' then
    tmp := '@';
  with FStoredProc.Params.Add do
  begin
    DisplayName := tmp + FieldName;
    Name := tmp + FieldName;
    DataType := FieldType;
    value := ParamValue;
    ParamType := ParamType;
  end;
end;

function TStoredProc.Open: Boolean;
begin

  Result := FStoredProc.OpenOrExecute;
end;

function TStoredProc.StoredProc: TFDStoredProc;
begin
  Result := FStoredProc;
end;

function TStoredProc.ToJSON(): string;
var
  i: Integer;
  ret: string;
  ftype: TFieldType;
  json, item, key, value: string;
begin
  ret := '';
  try

    json := '[';
    with FStoredProc do
    begin
      First;
      while not Eof do
      begin
        item := '{';
        for i := 0 to Fields.Count - 1 do
        begin
          if Config.JsonToLower then
            key := Fields[i].DisplayLabel.ToLower
          else
            key := Fields[i].DisplayLabel;
          ftype := Fields[i].DataType;
          if (ftype = ftAutoInc) or (ftype = ftShortint) or (ftype = ftSingle) or (ftype = ftLargeint) then
            value := Fields[i].AsString
          else if (ftype = ftInteger) or (ftype = ftWord) or (ftype = ftBCD) or (ftype = ftFMTBcd) then
            value := Fields[i].AsString
          else if (ftype = ftBoolean) then
            value := Fields[i].AsString
          else
          begin
            value := '"' + Fields[i].AsString + '"';
          end;
          if value = '' then
            value := '0';
          item := item + '"' + key + '"' + ':' + value + ',';
        end;
        item := copy(item, 1, item.Length - 1);
        item := item + '},';
        json := json + item;
        Next;
      end;
    end;
    if json.Length > 1 then
      json := copy(json, 1, json.Length - 1);
    json := json + ']';
    Result := json;
  except
    on e: Exception do
    begin
      log(e.Message);
      result := '';
    end;

  end;
end;

{ TConn }

constructor TConn.Create;
begin
  FDb := TDB.Create;
end;

function TConn.db: TDb;
begin
  Result := FDb;
end;

destructor TConn.Destroy;
begin
  FDb.Free;
  inherited;
end;

initialization
  DBPool := TDBPool.Create;


finalization
  DBPool.Free;

end.

