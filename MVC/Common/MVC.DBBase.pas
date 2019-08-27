{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.DBBase;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, xsuperobject,
  System.Generics.Collections, System.RegularExpressions, System.Variants,
  MVC.DBPool;

type
  TDBBase = class
  private
    DBType_: string;
    FFields: string;
    FPageKey: string;
    function getJSONWhere(JSONwhere: ISuperObject): string;
    procedure SetFields(const Value: string);
    procedure SetPageKey(const Value: string);
    procedure CreateStoredProc;
    { Private declarations }
  protected
    condb: TFDConnection;
    StoredProc: TFDStoredProc;
  public
    TMP_CDS: TFDQuery;
    dataset: TFDQuery;
    property Fields: string read FFields write SetFields; // 用来设置查询时显示那些字段
    property PageKey: string read FPageKey write SetPageKey; //分页ID设置 mssql2000 使用
    { Public declarations }
    function filterSQL(sql: string): string;
    procedure DBlog(msg: string);
    procedure StartTransaction(); //启动事务
    procedure Commit;        //事务提交
    procedure Rollback;      //事务回滚
    procedure StoredProcSetName(StoredProcName: string);
    function StoredProcOpen(var json: ISuperObject): Boolean;
    procedure StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant); overload; virtual;
    function StoredProcToJSON(StoredProc: TFDStoredProc): ISuperObject;
    function FindByKey(tablename: string; key: string; value: Integer): ISuperObject; overload;
    function FindByKey(tablename: string; key: string; value: string): ISuperObject; overload;
    function Find(tablename: string; where: string): ISuperObject; overload;
    function FindT(tablename: string; where: string): string; overload;
    function Find(tablename: string; JSONwhere: ISuperObject): ISuperObject; overload;
    function Find(tablename: string; where: string; var cds: TFDQuery): Boolean; overload;
    function Find(tablename: string; JSONwhere: ISuperObject; var cds: TFDQuery): Boolean; overload;
    function FindFirst(tablename: string; where: string): ISuperObject; overload; virtual;
    function FindFirst(tablename: string; JSONwhere: ISuperObject): ISuperObject; overload;
    function FindPage(var count: Integer; tablename, order: string; pageindex, pagesize: Integer): ISuperObject; overload;
    function FindPageT(var count: Integer; tablename, order: string; pageindex, pagesize: Integer): string; overload;
    function FindPage(var count: Integer; tablename, where, order: string; pageindex, pagesize: Integer): ISuperObject; overload;
    function FindPageT(var count: Integer; tablename, where, order: string; pageindex, pagesize: Integer): string; overload;
    function FindPage(var count: Integer; tablename: string; JSONWhere: ISuperObject; order: string; pageindex, pagesize: Integer): ISuperObject; overload;
    function FindPageT(var count: Integer; tablename: string; JSONWhere: ISuperObject; order: string; pageindex, pagesize: Integer): string; overload;
    function CDSToJSONText(cds: TFDQuery): string;
    function CDSToJSONArray(cds: TFDQuery; isfirst: Boolean = false): ISuperObject;
    function CDSToJSONObject(cds: TFDQuery): ISuperObject;
    function Query(sql: string): ISuperObject; overload;
    function Query(sql: string; var cds: TFDQuery): Boolean; overload;
    function QueryT(sql: string): string; overload;
    function QueryFirst(sql: string): ISuperObject;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; virtual;
    function QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string; virtual;
    function ExecSQL(sql: string): Boolean;
    function ExecCDS(var cds: TFDQuery): Boolean;
    function AddData(tablename: string): TFDQuery;
    function EditData(tablename: string; key: string; value: string): TFDQuery;
    function DeleteByKey(tablename: string; key: string; value: string): Boolean;
    function Delete(tablename: string; JSONwhere: ISuperObject): Boolean; overload;
    function Delete(tablename: string; where: string): Boolean; overload;
    function TryConnDB(): Boolean;
    function closeDB(): Boolean;
    constructor Create(dbtype: string);
    destructor Destroy; override;
  end;

implementation

uses
  uConfig, MVC.LogUnit, XSuperJSON;

function TDBBase.AddData(tablename: string): TFDQuery;
var
  sql: string;
begin
  Result := nil;
  if not TryConnDB then
    Exit;
  if (Trim(tablename) = '') then
    Exit;
  try
    sql := 'select * from ' + tablename + ' where 1=2';
    sql := filterSQL(sql);
    TMP_CDS.Open(sql);
    Fields := '';
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

procedure TDBBase.Commit;
begin
  condb.Commit;
end;

procedure TDBBase.Rollback;
begin
  condb.Rollback;
end;

procedure TDBBase.StartTransaction;
begin
  if not TryConnDB then
    Exit;
  condb.StartTransaction;
end;

procedure TDBBase.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
begin
  CreateStoredProc;
end;

function TDBBase.StoredProcOpen(var json: ISuperObject): Boolean;
begin
  CreateStoredProc;
  Result := StoredProc.OpenOrExecute;
  json := StoredProcToJSON(StoredProc);
  StoredProc.Close;
  StoredProc.Params.ClearAndResetID;
end;

procedure TDBBase.StoredProcSetName(StoredProcName: string);
begin
  CreateStoredProc;
  StoredProc.StoredProcName := StoredProcName;
end;

function TDBBase.StoredProcToJSON(StoredProc: TFDStoredProc): ISuperObject;
var
  jo: ISuperObject;
  ja: ISuperArray;
  i: Integer;
  ret: string;
  ftype: TFieldType;
begin
  ja := SA;
  ret := '';
  with StoredProc do
  begin
    First;
    while not Eof do
    begin
      jo := SO();
      for i := 0 to Fields.Count - 1 do
      begin
        ftype := Fields[i].DataType;
        if (ftype = ftAutoInc) then
          jo.I[Fields[i].DisplayLabel] := Fields[i].AsInteger
        else if (ftype = ftInteger) then
          jo.I[Fields[i].DisplayLabel] := Fields[i].AsInteger
        else if (ftype = ftBoolean) then
          jo.B[Fields[i].DisplayLabel] := Fields[i].AsBoolean
        else
        begin
          jo.S[Fields[i].DisplayLabel] := Fields[i].AsString;
        end;
      end;
      ja.Add(jo);
      Next;
    end;
  end;
  Result := ja.AsObject;
end;

function TDBBase.CDSToJSONArray(cds: TFDQuery; isfirst: Boolean = false): ISuperObject;
var
  jo: ISuperObject;
  ja: ISuperArray;
  i: Integer;
  ret: string;
  ftype: TFieldType;
begin

  ja := SA;
  ret := '';
  with cds do
  begin
    First;
    while not Eof do
    begin

      jo := SO();
      for i := 0 to Fields.Count - 1 do
      begin
        ftype := Fields[i].DataType;
        if (ftype = ftAutoInc) then
          jo.I[Fields[i].DisplayLabel] := Fields[i].AsInteger
        else if (ftype = ftInteger) then
          jo.I[Fields[i].DisplayLabel] := Fields[i].AsInteger
        else if (ftype = ftBoolean) then
          jo.B[Fields[i].DisplayLabel] := Fields[i].AsBoolean
        else
        begin
          jo.S[Fields[i].DisplayLabel] := Fields[i].AsString;
        end;
      end;
      ja.Add(jo);
      if isfirst then
        break
      else
        Next;
    end;
  end;
  Result := ja.AsObject;
end;

function TDBBase.CDSToJSONObject(cds: TFDQuery): ISuperObject;
var
  jo: ISuperArray;
begin
  jo := CDSToJSONArray(cds, true).AsArray;
  if jo.Length > 0 then
    Result := jo.O[0]
  else
    Result := nil;
end;

function TDBBase.CDSToJSONText(cds: TFDQuery): string;
var
  i: Integer;
  ret: string;
  ftype: TFieldType;
  json, item, key, value: string;
begin
  ret := '';

  json := '[';
  with cds do
  begin
    First;

    while not Eof do
    begin
      item := '{';
      for i := 0 to Fields.Count - 1 do
      begin
        key := Fields[i].DisplayLabel;
        ftype := Fields[i].DataType;
        if (ftype = ftAutoInc) then
          value := Fields[i].AsString
        else if (ftype = ftInteger) then
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
end;

function TDBBase.closeDB: Boolean;
begin

  try
    try
      condb.Connected := false;
    except
      on e: Exception do
      begin
        log(e.ToString);
      end;
    end;
  finally
    Result := condb.Connected;
  end;
end;

function TDBBase.TryConnDB: Boolean;
begin
  if not Assigned(condb) then
  begin
    condb := _DbPool.GetDb(DBType_);
    if condb = nil then
    begin
      condb := TFDConnection.Create(nil);
      condb.ConnectionDefName := DBType_;
    end;
    TMP_CDS := TFDQuery.Create(nil);
  //  TMP_CDS.FetchOptions.Mode := fmAll;
   // TMP_CDS.FetchOptions.RecordCountMode := TFDRecordCountMode.cmTotal;
    TMP_CDS.Connection := condb;
  end;
  try
    try
      if not condb.Connected then
        condb.Connected := true;
    except
      on e: Exception do
      begin
        log('数据库连接失败:' + e.ToString);
        condb.Connected := False
      end;
    end;
  finally
    Result := condb.Connected;
  end;
end;

constructor TDBBase.Create(dbtype: string);
begin
  DBType_ := dbtype;
end;

procedure TDBBase.CreateStoredProc;
begin
  if not TryConnDB then
    Exit;
  if not Assigned(StoredProc) then
  begin
    StoredProc := TFDStoredProc.Create(nil);
    StoredProc.Connection := condb;
  end;
end;

function TDBBase.Delete(tablename: string; JSONwhere: ISuperObject): Boolean;
var
  sql: string;
begin
  Result := false;
  sql := getJSONWhere(JSONwhere);
  if (sql <> '') then
  begin
    sql := 'delete from ' + tablename + ' where 1=1 ' + sql;
    Result := ExecSQL(sql);
  end;
end;

procedure TDBBase.DBlog(msg: string);
begin
  log(msg);
end;

function TDBBase.Delete(tablename, where: string): Boolean;
var
  sql: string;
begin
  Result := false;
  if (where <> '') then
  begin
    sql := 'delete from ' + tablename + ' where 1=1 ' + where;
    Result := ExecSQL(sql);
  end;
end;

function TDBBase.DeleteByKey(tablename, key: string; value: string): Boolean;
var
  sql: string;
begin
  Result := False;
  if not TryConnDB then
    Exit;
  if (Trim(tablename) = '') then
    Exit;
  if (Trim(key) = '') then
    Exit;
  if (Trim(value) = '') then
    Exit;
  try
    sql := 'delete from ' + tablename + ' where ' + key + '=' + value;
    Result := ExecSQL(sql);
  except
    on e: Exception do
    begin
      log(e.ToString);
      Result := False;
    end;
  end;
end;

destructor TDBBase.Destroy;
var
  i: Integer;
begin
  if Assigned(condb) then
  begin
    try
      if condb.Connected then
      begin
        if condb.InTransaction then
          condb.Rollback;
      end;
    finally
      condb.Connected := False;
      condb.Free;
      TMP_CDS.Free;
    end;
  end;
  if Assigned(StoredProc) then
  begin
    StoredProc.Free;
  end;
  inherited;
end;

function TDBBase.EditData(tablename, key: string; value: string): TFDQuery;
var
  sql: string;
begin
  Result := nil;
  if not TryConnDB then
    Exit;
  if (Trim(tablename) = '') then
    Exit;
  if (Trim(key) = '') then
    Exit;
  try
    sql := 'select * from ' + tablename + ' where ' + key + ' = ' + value;
    sql := filterSQL(sql);
    TMP_CDS.Open(sql);
    Fields := '';
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

function TDBBase.ExecCDS(var cds: TFDQuery): Boolean;
begin

  try
    cds.Connection := condb;
    Result := cds.OpenOrExecute;
  except
    on e: Exception do
    begin
      log(e.ToString);
      Result := False;
    end;
  end;
end;

function TDBBase.ExecSQL(sql: string): Boolean;
begin
  Result := False;

  if not TryConnDB then
    Exit;

  try
    try
      sql := filterSQL(sql);
      TMP_CDS.sql.Text := sql;
      TMP_CDS.ExecSQL;
      Result := true;
    except
      on e: Exception do
      begin
        log(e.ToString);
        Result := False;
      end;
    end;
  finally

  end;
end;

function TDBBase.filterSQL(sql: string): string;
begin
  if show_sql then
    log(sql);
 // Result := sql.Replace(';', '').Replace('-', '');
  Result := sql;
end;

function TDBBase.Query(sql: string): ISuperObject;
begin
  Result := nil;
  if not TryConnDB then
    Exit;

  try

    try
      sql := filterSQL(sql);
      TMP_CDS.Open(sql);
      Fields := '';
      Result := CDSToJSONArray(TMP_CDS);
    except
      on e: Exception do
      begin
        log(e.ToString);
      end;
    end;
  finally
  //  cds.Free;
  end;
end;

function TDBBase.Query(sql: string; var cds: TFDQuery): Boolean;
begin
  Result := false;
  if not TryConnDB then
    Exit;

  try
    cds.Connection := condb;
    sql := filterSQL(sql);
    cds.Open(sql);
    Fields := '';
    Result := true;
  except
    on e: Exception do
    begin
      log(e.ToString);
    end;
  end;
end;

function TDBBase.QueryT(sql: string): string;
begin
  Result := '';
  if not TryConnDB then
    Exit;
  try
    try
      sql := filterSQL(sql);
      TMP_CDS.Open(sql);
      Fields := '';
      Result := CDSToJSONText(TMP_CDS);
    except
      on e: Exception do
      begin
        log(e.ToString);
      end;
    end;
  finally
    //cds.Free;
  end;
end;

function TDBBase.QueryFirst(sql: string): ISuperObject;
begin
  Result := nil;
  if not TryConnDB then
    Exit;

  try
    try

      sql := filterSQL(sql);
      TMP_CDS.Open(sql);
      Fields := '';
      result := CDSToJSONObject(TMP_CDS);
     // TMP_CDS.Close();
    except
      on e: Exception do
      begin
        log(e.ToString);
      end;
    end;
  finally

  end;
end;

function TDBBase.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
begin

end;

function TDBBase.QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string;
begin

end;

procedure TDBBase.SetFields(const Value: string);
begin
  FFields := Value;
end;

procedure TDBBase.SetPageKey(const Value: string);
begin
  FPageKey := Value;
end;

function TDBBase.Find(tablename, where: string): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;

  if Fields = '' then
    Fields := '*';
  sql := 'select ' + Fields + ' from ' + tablename + ' where 1=1 ' + where;
  Result := Query(sql);
end;

function TDBBase.Find(tablename: string; JSONwhere: ISuperObject): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  sql := getJSONWhere(JSONwhere);
  if (sql <> '') then
  begin
    Result := Find(tablename, sql);
  end;
end;

function TDBBase.FindByKey(tablename, key: string; value: Integer): ISuperObject;
begin
  Result := FindFirst(tablename, 'and ' + key + ' = ' + IntToStr(value));
end;

function TDBBase.Find(tablename, where: string; var cds: TFDQuery): Boolean;
var
  sql: string;
begin
  Result := False;
  if (Trim(tablename) = '') then
    Exit;

  if Fields = '' then
    Fields := '*';
  sql := 'select ' + Fields + ' from ' + tablename + ' where 1=1 ' + where;
  Result := Query(sql, cds);
end;

function TDBBase.FindByKey(tablename, key, value: string): ISuperObject;
begin
  Result := FindFirst(tablename, 'and ' + key + ' = ' + QuotedStr(value));
end;

function TDBBase.FindFirst(tablename, where: string): ISuperObject;
begin

end;

function TDBBase.FindFirst(tablename: string; JSONwhere: ISuperObject): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  sql := getJSONWhere(JSONwhere);
  if (sql <> '') then
  begin
    Result := FindFirst(tablename, sql);
  end;
end;

function TDBBase.FindPage(var count: Integer; tablename: string; JSONWhere: ISuperObject; order: string; pageindex, pagesize: Integer): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  sql := getJSONWhere(JSONWhere);
  if sql <> '' then
  begin
    Result := FindPage(count, tablename, sql, order, pageindex, pagesize);
  end;
end;

function TDBBase.getJSONWhere(JSONwhere: ISuperObject): string;
var
  sql: string;
  wh: string;
begin
  sql := '';
  JSONwhere.First;
  while not JSONwhere.EoF do

  begin
    wh := JSONwhere.CurrentKey + '=' + QuotedStr(VarToStr(JSONwhere.CurrentValue.AsVariant));
    sql := sql + ' and ' + wh;
    JSONwhere.Next;
  end;
  Result := sql;
end;

function TDBBase.FindPage(var count: Integer; tablename, where, order: string; pageindex, pagesize: Integer): ISuperObject;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  Result := QueryPage(count, Fields, tablename + ' where 1=1 ' + where, order, pageindex, pagesize);
end;

function TDBBase.FindPage(var count: Integer; tablename, order: string; pageindex, pagesize: Integer): ISuperObject;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  Result := QueryPage(count, Fields, tablename, order, pageindex, pagesize);
end;

function TDBBase.Find(tablename: string; JSONwhere: ISuperObject; var cds: TFDQuery): Boolean;
var
  sql: string;
begin
  Result := False;
  sql := getJSONWhere(JSONwhere);
  if (sql <> '') then
  begin
    Result := Find(tablename, sql, cds);
  end;
end;

function TDBBase.FindPageT(var count: Integer; tablename, order: string; pageindex, pagesize: Integer): string;
begin
  Result := '';
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  Result := QueryPageT(count, Fields, tablename, order, pageindex, pagesize);
end;

function TDBBase.FindPageT(var count: Integer; tablename, where, order: string; pageindex, pagesize: Integer): string;
begin
  Result := '';
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  Result := QueryPageT(count, Fields, tablename + ' where 1=1 ' + where, order, pageindex, pagesize);
end;

function TDBBase.FindPageT(var count: Integer; tablename: string; JSONWhere: ISuperObject; order: string; pageindex, pagesize: Integer): string;
var
  sql: string;
begin
  Result := '';
  sql := getJSONWhere(JSONWhere);
  if sql <> '' then
  begin
    Result := FindPageT(count, tablename, sql, order, pageindex, pagesize);
  end;
end;

function TDBBase.FindT(tablename, where: string): string;
var
  sql: string;
begin
  Result := '';
  if (Trim(tablename) = '') then
    Exit;

  if Fields = '' then
    Fields := '*';
  sql := 'select ' + Fields + ' from ' + tablename + ' where 1=1 ' + where;
  Result := QueryT(sql);
end;

end.

