{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit DBMSSQL;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, superobject, DBBase,Data.DB;

type
  TDBMSSQL = class(TDBBase)
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
    procedure StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant); overload;
  end;

implementation

{ TDBMSSQL }

function TDBMSSQL.FindFirst(tablename: string; where: string = ''): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  sql := 'select top 1 ' + Fields + ' from ' + tablename + ' where 1=1 ' + where;
  Result := QueryFirst(sql);
end;

function TDBMSSQL.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
var
  CDS: TFDQuery;
  sql: string;
  tmp: string;
begin
  Result := nil;
  if (not TryConnDB) or (Trim(select) = '') or (Trim(from) = '') then
    Exit;
  if PageKey.Trim = '' then
  begin
    DBlog('PageKey-分页主键设置MSSQL数据库特有属性');
    exit;
  end;
  if Trim(order) <> '' then
    order := 'order by ' + Trim(order);
  CDS := TFDQuery.Create(nil);
  try
    try
      CDS.Connection := condb;
      sql := 'select count(1) as N from ' + from;
      sql := filterSQL(sql);
      CDS.Open(sql);
      count := CDS.FieldByName('N').AsInteger;
      CDS.Close;
      if Pos('where', from) > 0 then
        tmp := ' and '
      else
        tmp := ' where ';
      sql := ' select top ' + inttostr(pagesize) + ' ' + Trim(select) + ' from ' + Trim(from);
      if pageindex > 0 then
      begin
        sql := sql + tmp + PageKey + ' not in(select top ' + IntToStr(pagesize * pageindex) + ' ' + PageKey + ' from ' + Trim(from) + ')';
      end;
      sql := sql + ' ' + Trim(order);
      Result := Query(sql);
      PageKey := '';
    except
      on e: Exception do
      begin
        DBlog(e.ToString);
        Result := nil;
      end;

    end;
  finally
    CDS.Free;
    //FreeAndNil(CDS);
  end;

end;

procedure TDBMSSQL.StoredProcAddParams(DisplayName_: string;
  DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
begin
   with StoredProc.Params.Add do
  begin
    DisplayName := '@' + DisplayName_;
    Name := '@' + DisplayName_;
    DataType := DataType_;
    Value := Value_;
    ParamType := ParamType_;
  end;
end;

end.

