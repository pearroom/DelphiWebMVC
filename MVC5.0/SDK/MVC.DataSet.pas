{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2022-2 苏兴迎(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.DataSet;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.RegularExpressions, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, MVC.Config, MVC.LogUnit, MVC.JSON, System.JSON,
  web.HTTPApp, mvc.Tool, Data.DB;

type
  TResData = record
    Code: integer;
    Msg: string;
    procedure Value(sCode: Integer; sMsg: string);
  end;

  ISQL = interface
    procedure Select(fields: string);
    procedure From(tables: string);
    procedure And_(value: string);
    procedure OR_(value: string);
    procedure Order(value: string);
    procedure Insert(tables: string);
    procedure Edit(tables: string);
    procedure Del(tables: string);
    procedure Value(value: string);
    procedure Set_(value: string);
    function getSelect: string;
    function getFrom: string;
    function getOrder: string;
    function getInsert: string;
    function getEdit: string;
    function getDel: string;
    function getValue: string;
    function getSet_: string;
    function Text: string;
    function getWhere: string;
    function SQL: TStringList;
    procedure Clear;
    //不带引号
    procedure AndEq(key, value: string); //等于
    procedure AndNe(key, value: string); //不等于
    procedure AndLt(key, value: string); //小于
    procedure AndLte(key, value: string); //小于等于
    procedure AndGt(key, value: string); //大于
    procedure AndGte(key, value: string); //大于等于
     //带引号
    procedure AndEqF(key, value: string); //等于
    procedure AndNeF(key, value: string); //不等于
    procedure AndLtF(key, value: string); //小于
    procedure AndLteF(key, value: string); //小于等于
    procedure AndGtF(key, value: string); //大于
    procedure AndGteF(key, value: string); //大于等于
  end;

  TSQL = class(TInterfacedObject, ISQL)
  private
    FSelect: string;
    FFrom: string;
    FWhere: string;
    FOrder: string;
    FInsert: string;
    FEdit: string;
    FDelete: string;
    FValue: string;
    FSet: string;
    SQL_V: TStringList;
  public
    function SQL: TStringList;
    procedure Select(fields: string);
    procedure From(tables: string);
    procedure And_(value: string);

    procedure Insert(tables: string);
    procedure Edit(tables: string);
    procedure Del(tables: string);
    procedure Value(value: string);
    procedure Set_(value: string);

    function getSelect: string;
    function getFrom: string;
    function getOrder: string;

    function getInsert: string;
    function getEdit: string;
    function getDel: string;
    function getValue: string;
    function getSet_: string;
    function getWhere: string;
    function Text: string;
    //不带引号
    procedure AndEq(key, value: string); //等于
    procedure AndNe(key, value: string); //不等于
    procedure AndLt(key, value: string); //小于
    procedure AndLte(key, value: string); //小于等于
    procedure AndGt(key, value: string); //大于
    procedure AndGte(key, value: string); //大于等于
     //带引号
    procedure AndEqF(key, value: string); //等于
    procedure AndNeF(key, value: string); //不等于
    procedure AndLtF(key, value: string); //小于
    procedure AndLteF(key, value: string); //小于等于
    procedure AndGtF(key, value: string); //大于
    procedure AndGteF(key, value: string); //大于等于

    procedure OR_(value: string);
    procedure Order(value: string);

    procedure Clear;
    //
    constructor Create(table: string);
    destructor Destroy; override;
  end;

  ISQLTpl = interface
    procedure SetKey(key: string; sParam: IJObject = nil);
    procedure SetParam(sParam: IJObject);
    procedure SetTpl(tpl: string);
    function AsISQL: ISQL;
  end;

  TSQLTpl = class(TInterfacedObject, ISQLTpl)
  private
    FTpl: string;
    Fkey: string;
    FParam: IJObject;
    function getSQL(sql: string; sType: string): ISQL;
    function ClearNotes(txt: string): string; //清理注释
    function getSQLKey(sql: string; sKey: string; _T: Boolean = False): string;
  public
    function AsISQL: ISQL;
    procedure SetKey(key: string; sParam: IJObject = nil);
    procedure SetParam(sParam: IJObject);
    procedure SetTpl(tpl: string);
    constructor Create(tpl: string; key: string; sParam: IJObject); overload;
    constructor Create(tpl: string); overload;

    destructor Destroy; override;
  end;

  IDataSet = interface
    function DS: TFDQuery;
    function toJSONArray: string;
    function toJSONObject: string;
    function S(fieldname: string): string;
    function I(fieldname: string): Integer;
    function D(fieldname: string): Double;
    procedure setS(fieldname: string; value: string);
    procedure setI(fieldname: string; value: Integer);
    procedure setD(fieldname: string; value: Double);
    function isEmpty: Boolean;
    function Eof: Boolean;
    function Count: Integer;
    procedure Next;
    procedure Post;
    procedure Append;
    procedure Edit;
    procedure setCount(n: Integer);
    function JsonToDataSet(json: string; var dataset: TFDMemTable): boolean;
  end;

  TDataSet = class(TInterfacedObject, IDataSet)
  private
    FCount: integer;
    dataset: TFDQuery;
    function checkType(dbtype: TFieldType): Boolean;
  public
    function DS: TFDQuery;

    function toJSONArray: string;
    function toJSONObject: string;
    function S(fieldname: string): string;
    function I(fieldname: string): Integer;
    function D(fieldname: string): Double;

    procedure setS(fieldname: string; value: string);
    procedure setI(fieldname: string; value: Integer);
    procedure setD(fieldname: string; value: Double);

    function isEmpty: Boolean;
    function Eof: Boolean;
    function Count: Integer;
    procedure Next;
    procedure Post;
    procedure Append;
    procedure Edit;
    procedure setCount(n: Integer);

    function JsonToDataSet(json: string; var dataset: TFDMemTable): boolean;

    constructor Create();
    destructor Destroy; override;
  end;

function IIDataSet: IDataSet;

function IISQL(table: string = ''): ISQL;

function IISQLTpl(tpl: string; key: string; sParam: IJObject = nil): ISQLTpl; overload;

function IISQLTpl(tpl: string): ISQLTpl; overload;

implementation

uses
  MVC.TplParser, MVC.TplUnit;

function IISQLTpl(tpl: string; key: string; sParam: IJObject = nil): ISQLTpl;
begin
  Result := TSQLTpl.Create(tpl, key, sParam) as ISQLTpl;
end;

function IISQLTpl(tpl: string): ISQLTpl;
begin
  Result := TSQLTpl.Create(tpl) as ISQLTpl;
end;

function IISQL(table: string): ISQL;
begin
  Result := Tsql.Create(table) as ISQL;
end;

function IIDataSet: IDataSet;
begin
  Result := TDataSet.Create as IDataSet
end;
{ TDataSet }

procedure TDataSet.Append;
begin
  DS.Append;
end;

function TDataSet.checkType(dbtype: TFieldType): Boolean;
begin
  if dbtype in [ftString, ftWideString, ftUnknown, ftWideMemo, ftMemo, ftDate, ftDateTime, ftTime, ftFmtMemo, ftTimeStamp, ftTimeStampOffset] then
  begin
    Result := true;
  end
  else
  begin
    Result := false;
  end;
end;

function TDataSet.Count: Integer;
begin
  if FCount <> 0 then
    Result := FCount
  else
    Result := DS.RecordCount;
end;

constructor TDataSet.Create;
begin
  dataset := TFDQuery.Create(nil);
end;

destructor TDataSet.Destroy;
begin
 // dataset.Close;
  dataset.Free;
  inherited;
end;

function TDataSet.DS: TFDQuery;
begin
  Result := dataset;
end;

procedure TDataSet.Edit;
begin
  ds.Edit;
end;

function TDataSet.Eof: Boolean;
begin
  Result := ds.Eof;
end;

function TDataSet.D(fieldname: string): Double;
begin
  Result := ds.FieldByName(fieldname).AsFloat;
end;

function TDataSet.I(fieldname: string): Integer;
begin
  Result := ds.FieldByName(fieldname).AsInteger;
end;

function TDataSet.S(fieldname: string): string;
begin
  Result := ds.FieldByName(fieldname).AsString;
end;

function TDataSet.isEmpty: boolean;
begin
  Result := dataset.IsEmpty;
end;

function TDataSet.JsonToDataSet(json: string; var dataset: TFDMemTable): boolean;
var
  jo1: TJSONObject;
  field: TFieldDef;
  j, i: integer;
  s: string;
  ja: IJArray;
begin
  if dataset.Active and not dataset.IsEmpty then
  begin
    dataset.Delete;
    dataset.FieldDefs.Clear;
    dataset.Close;

  end;
  ja := IIJArray(json);

  if ja.A.Count > 0 then
  begin
    for i := 0 to ja.A.Count - 1 do
    begin
      jo1 := ja.A.Items[i] as TJSONObject;

      for j := 0 to jo1.Count - 1 do
      begin

        field := dataset.FieldDefs.AddFieldDef;
        field.Name := jo1.Pairs[j].JsonString.Value;
        field.DataType := ftString;
        field.Size := 500;

      end;
      break;
    end;
    dataset.CreateDataSet;
    for i := ja.A.Count - 1 downto 0 do
    begin
      try
        dataset.Insert;
        jo1 := ja.A.Items[i] as TJSONObject;
        for j := 0 to jo1.Count - 1 do
        begin
          s := jo1.Pairs[j].JsonValue.Value.Replace('\r', #13).Replace('\n', #10);
          dataset.FieldByName(jo1.Pairs[j].JsonString.Value).AsString := s;
        end;

        dataset.Post;
      except
        on e: Exception do
        begin
          Log(e.Message);
          Result := false;
          exit;
        end;
      end;
    end;
  end;
  Result := true;
end;

procedure TDataSet.Next;
begin
  ds.Next;
end;

procedure TDataSet.Post;
begin
  DS.Post;
end;

procedure TDataSet.setCount(n: integer);
begin
  FCount := n;
end;

procedure TDataSet.setD(fieldname: string; value: Double);
begin
  ds.FieldByName(fieldname).AsFloat := value;
end;

procedure TDataSet.setI(fieldname: string; value: Integer);
begin
  ds.FieldByName(fieldname).AsInteger := value;
end;

procedure TDataSet.setS(fieldname, value: string);
begin
  ds.FieldByName(fieldname).AsString := value;
end;

function TDataSet.toJSONArray: string;
var
  i: Integer;
  ret: string;
  ftype: TFieldType;
  json, item, key, value: string;
begin
  ret := '';
  try
    if dataset = nil then
    begin
      Result := '[]';
      exit;
    end;
    json := '[';
    with dataset do
    begin
      First;

      while not Eof do
      begin
        item := '{';
        for i := 0 to Fields.Count - 1 do
        begin
          ftype := Fields[i].DataType;
          if Config.JsonToLower then
            key := Fields[i].DisplayLabel.ToLower
          else
            key := Fields[i].DisplayLabel;
          if checkType(ftype) then
            value := '"' + IITool.UnicodeEncode(Fields[i].AsString) + '"'
          else if ftype = ftBoolean then
            value := Fields[i].AsString.ToLower
          else
            value := Fields[i].AsString;

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
    end;
  end;
end;

function TDataSet.toJSONObject: string;
var
  i: Integer;
  ftype: TFieldType;
  json, item, key, value: string;
begin
  json := '';
  try
    if dataset = nil then
    begin
      Result := '{}';
      exit;
    end;
    with dataset do
    begin

      if not IsEmpty then
      begin
        item := '{';
        for i := 0 to Fields.Count - 1 do
        begin
          ftype := Fields[i].DataType;
          if Config.JsonToLower then
            key := Fields[i].DisplayLabel.ToLower
          else
            key := Fields[i].DisplayLabel;

          if checkType(ftype) then
            value := '"' + IITool.UnicodeEncode(Fields[i].AsString) + '"'
          else if ftype = ftBoolean then
            value := Fields[i].AsString.ToLower
          else
            value := Fields[i].AsString;

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
    Result := json;
  except
    on e: Exception do
    begin
      log(e.Message);
    end;
  end;
end;

procedure TSQL.Clear;
begin
  FFrom := '';
  FWhere := '';
  FSelect := '';
  FOrder := '';
  SQL_V.Clear;
end;

constructor TSQL.Create(table: string);
begin
  SQL_V := TStringList.Create;
  SQL_V.Clear;
  if table.Trim <> '' then
    FFrom := ' from ' + table;
end;

procedure TSQL.Del(tables: string);
begin
  if Trim(tables) = '' then
    exit;
  FDelete := tables;
  SQL_V.Clear;
end;

destructor TSQL.Destroy;
begin
  SQL_V.Clear;
  SQL_V.Free;
  inherited;
end;

procedure TSQL.Edit(tables: string);
begin
  if Trim(tables) = '' then
    exit;
  FEdit := tables;
  SQL_V.Clear;
end;

procedure TSQL.AndEq(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '=' + value);
end;

procedure TSQL.AndEqF(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '=' + QuotedStr(value));
end;

procedure TSQL.AndGt(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '>' + value);
end;

procedure TSQL.AndGte(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '>=' + value);
end;

procedure TSQL.AndGteF(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '>=' + QuotedStr(value));
end;

procedure TSQL.AndGtF(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '>' + QuotedStr(value))
end;

procedure TSQL.AndLt(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '>' + value);
end;

procedure TSQL.AndLte(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '<=' + value);
end;

procedure TSQL.AndLteF(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '<=' + QuotedStr(value));
end;

procedure TSQL.AndLtF(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '<' + QuotedStr(value));
end;

procedure TSQL.AndNe(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '<>' + value);
end;

procedure TSQL.AndNeF(key, value: string);
begin
  if (Trim(value) = '') or (Trim(key) = '') then
    exit;
  And_(key + '<>' + QuotedStr(value));
end;

procedure TSQL.And_(value: string);
begin
  if Trim(value) = '' then
    exit;
  if FWhere = '' then
    FWhere := ' where 1=1 ';
  FWhere := FWhere + ' and ' + value;
  SQL_V.Clear;
end;

procedure TSQL.From(tables: string);
begin
  if Trim(tables) = '' then
    exit;
  if FFrom = '' then
    FFrom := ' from ';
  FFrom := FFrom + tables;
  SQL_V.Clear;
end;

function TSQL.getDel: string;
begin
  Result := FDelete;
end;

function TSQL.getEdit: string;
begin
  Result := FEdit;
end;

function TSQL.getFrom: string;
begin
  Result := FFrom + FWhere;
end;

function TSQL.getInsert: string;
begin
  Result := FInsert;
end;

function TSQL.getOrder: string;
begin
  Result := FOrder;
end;

function TSQL.getSelect: string;
begin

  if FSelect = '' then
    FSelect := 'select * ';
  Result := FSelect;
end;

function TSQL.getSet_: string;
begin
  Result := FSet;
end;

function TSQL.getValue: string;
begin
  Result := FValue;
end;

function TSQL.getWhere: string;
begin
  Result := FWhere;
end;

procedure TSQL.Insert(tables: string);
begin
  if Trim(tables) = '' then
    exit;
  FInsert := tables;
  SQL_V.Clear;
end;

procedure TSQL.OR_(value: string);
begin
  if Trim(value) = '' then
    exit;
  if FWhere = '' then
    FWhere := ' where 1=1 ';
  FWhere := FWhere + ' or ' + value;
  SQL_V.Clear;
end;

procedure TSQL.Order(value: string);
begin
  if Trim(value) = '' then
    exit;
  if FOrder = '' then
    FOrder := ' order by ';
  FOrder := FOrder + value;
  SQL_V.Clear;

end;

procedure TSQL.Select(fields: string);
begin
  if Trim(fields) = '' then
    exit;
  if FSelect = '' then
    FSelect := 'select ';
  FSelect := FSelect + fields;
  SQL_V.Clear;

end;

procedure TSQL.Set_(value: string);
begin
  if Trim(value) = '' then
    exit;
  FSet := value;
  SQL_V.Clear;
end;

function TSQL.SQL: TStringList;
begin
  Result := SQL_V;
end;

function TSQL.Text: string;
begin
  if SQL_V.Text.Trim <> '' then
  begin
    Result := SQL_V.Text;
    Exit;
  end;
  if (FSelect = '') and (FFrom <> '') then
    FSelect := 'select * ';
  SQL_V.Text := FSelect + FFrom + FWhere + FOrder;
  Result := SQL_V.Text;

end;

procedure TSQL.value(value: string);
begin
  if Trim(value) = '' then
    exit;
  FValue := value;
  SQL_V.Clear;
end;

{ TSQLTpl }

constructor TSQLTpl.Create(tpl: string; key: string; sParam: IJObject);
begin
  FTpl := tpl;
  Fkey := key;
  FParam := sParam;
end;

function TSQLTpl.ClearNotes(txt: string): string; //清理注释;
var
  matchs: TMatchCollection;
  match: TMatch;
  text: string;
begin
  text := txt;
  matchs := TRegEx.Matches(text, '<!--[\s\S]*?-->');
  for match in matchs do
  begin
    text := TRegEx.Replace(text, match.Value, '');
  end;
  Result := text;
end;

constructor TSQLTpl.Create(tpl: string);
begin
  FTpl := tpl;
  Fkey := '';
  FParam := nil;
end;

destructor TSQLTpl.Destroy;
begin
  inherited;
end;

function TSQLTpl.getSQLKey(sql: string; sKey: string; _T: Boolean = False): string;
var
  key, s: string;
  matchs: TMatchCollection;
  match: TMatch;
begin
  s := '';
  if not _T then
    key := '<' + sKey + ' key="' + Fkey + '"[\s\S]*?</' + sKey + '>'
  else
    key := '(?<=<' + sKey + ' key="' + Fkey + '">)[\s\S]*(?=</' + sKey + '>)';
  matchs := TRegEx.Matches(sql, key, [roIgnoreCase]);
  for match in matchs do
  begin
    s := match.Value;
    break;
  end;
  Result := s.Trim;
end;

procedure TSQLTpl.SetKey(key: string; sParam: IJObject);
begin
  Fkey := key;
  FParam := sParam;
end;

procedure TSQLTpl.SetParam(sParam: IJObject);
begin
  FParam := sParam;
end;

procedure TSQLTpl.SetTpl(tpl: string);
begin
  FTpl := tpl;
end;

function TSQLTpl.getSQL(sql: string; sType: string): ISQL;
var
  retsql: string;
  select, from, where, order, insert, edit, del, value, set_: string;
  FSQL: ISQL;
  arr: TArray<string>;
  fieldname, fieldvalue: string;

  function getkeyvalue(sKey: string): string;
  var
    key, s: string;
    matchs: TMatchCollection;
    match: TMatch;
  begin
    s := '';
    key := '(?<=<' + sKey + '>)[\s\S]*(?=</' + sKey + '>)';
    matchs := TRegEx.Matches(sql, key, [roIgnoreCase]);
    for match in matchs do
    begin
      s := match.Value;
     // s := sKey + ' ' + s;
      break;
    end;
    Result := s;
  end;

begin
  FSQL := IISQL;
  select := getkeyvalue('select');
  from := getkeyvalue('from');
  where := getkeyvalue('where');
  order := getkeyvalue('order');
  insert := getkeyvalue('insert');
  edit := getkeyvalue('update');
  value := getkeyvalue('value');
  set_ := getkeyvalue('set');
  del := getkeyvalue('delete');

  FSQL.Select(select);
  FSQL.From(from);
  FSQL.And_(where);
  FSQL.Order(order);
  FSQL.Insert(insert);
  FSQL.Edit(edit);
  FSQL.Del(del);
  FSQL.Value(value);
  FSQL.Set_(set_);

  //
  if Trim(del) <> '' then
    del := 'delete from ' + del;
  if Trim(edit) <> '' then
    edit := 'update ' + edit;
  if Trim(insert) <> '' then
  begin
    insert := 'insert into ' + insert;
    fieldname := '(';
    fieldvalue := '(';
    arr := value.Split([',']);
    for retsql in arr do
    begin
      fieldname := fieldname + retsql.Split(['='])[0] + ',';
      fieldvalue := fieldvalue + retsql.Split(['='])[1] + ',';
    end;
    fieldname := fieldname.Substring(0, fieldname.Length - 1) + ')';
    fieldvalue := fieldvalue.Substring(0, fieldvalue.Length - 1) + ')';
    insert := insert + fieldname + ' value ' + fieldvalue;
  end;

  if Trim(set_) <> '' then
    set_ := 'set ' + set_;
  if Trim(where) <> '' then
    where := 'where ' + where;
  //
  if sType.ToLower = 'querysql' then
  begin
    retsql := FSQL.Text;
    if Trim(retsql) = '' then
      FSQL.SQL.Text := getSQLKey(sql, 'querysql', True)
    else
      FSQL.sql.Text := retsql;
  end;
  if sType.ToLower = 'insertsql' then
  begin
    FSQL.SQL.Text := insert;
  end;
  if sType.ToLower = 'updatesql' then
  begin
    FSQL.SQL.Text := edit + ' ' + set_ + ' ' + where;
  end;
  if sType.ToLower = 'deletesql' then
  begin
    FSQL.SQL.Text := del + ' ' + where;
  end;
  if sType.ToLower = 'procsql' then
  begin
    FSQL.SQL.Text := getSQLKey(sql, 'procsql', True)
  end;
  Result := FSQL;
end;

function TSQLTpl.AsISQL: ISQL;
var
  TplContent, params: TStringList;
  Parser: TTplParser;
  sql: string;
begin
  Result := nil;
  if (FTpl.Trim = '') or (Fkey.Trim = '') then
    exit;
  TplContent := TStringList.Create;
  params := TStringList.Create;
  Parser := TTplParser.create;
  if FParam <> nil then
    params.Values['_Param'] := FParam.toJSON;

  try
    TplContent.Text := SQLCache.LoadPage(FTpl);
    TplContent.Text := ClearNotes(TplContent.Text);
    if TplContent.Text = '' then
    begin
      Log(FTpl + '文件不存在');
      exit;
    end;
    sql := getSQLKey(TplContent.Text, 'QuerySQL');
    if sql <> '' then
    begin
      Parser.Parser(sql, params, '');
      Result := getSQL(sql, 'querysql');  //解析成功该进行sql拼接组装了。
      exit;
    end;
    sql := getSQLKey(TplContent.Text, 'InsertSQL');
    if sql <> '' then
    begin
      Parser.Parser(sql, params, '');
      Result := getSQL(sql, 'InsertSQL');  //解析成功该进行sql拼接组装了。
      exit;
    end;
    sql := getSQLKey(TplContent.Text, 'UpdateSQL');
    if sql <> '' then
    begin
      Parser.Parser(sql, params, '');
      Result := getSQL(sql, 'UpdateSQL');  //解析成功该进行sql拼接组装了。
      exit;
    end;
    sql := getSQLKey(TplContent.Text, 'DeleteSQL');
    if sql <> '' then
    begin
      Parser.Parser(sql, params, '');
      Result := getSQL(sql, 'DeleteSQL');  //解析成功该进行sql拼接组装了。
      exit;
    end;
    sql := getSQLKey(TplContent.Text, 'ProcSQL');
    if sql <> '' then
    begin
      Parser.Parser(sql, params, '');
      Result := getSQL(sql, 'ProcSQL');  //解析成功该进行sql拼接组装了。
      exit;
    end;
  finally
    params.Free;
    TplContent.Free;
    Parser.free;
  end;

end;

{ TResData }

procedure TResData.value(sCode: Integer; sMsg: string);
begin
  Self.Code := sCode;
  Self.Msg := sMsg;
end;

end.

