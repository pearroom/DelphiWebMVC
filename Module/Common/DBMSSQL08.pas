{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit DBMSSQL08;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, superobject, DBBase, Data.DB;

type
  TDBMSSQL08 = class(TDBBase)
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
    procedure StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant); overload;
  end;

implementation

{ TDBMSSQL }

function TDBMSSQL08.FindFirst(tablename: string; where: string = ''): ISuperObject;
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

function TDBMSSQL08.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
var
  CDS: TFDQuery;
  sql: string;
  tmp: string;
begin
  Result := nil;
  if (not TryConnDB) or (Trim(select) = '') or (Trim(from) = '') then
    Exit;

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
      if select.Trim = '' then
        select := '*';
      sql := ' select *,ROW_NUMBER() OVER(ORDER BY tmprow) AS RowNo from (select 0 tmprow,' + select + ' from ' + from + ') tmp1 ';
      sql := ' select * from (' + sql + ') tmp2 where RowNo between ' + IntToStr(pageindex * pagesize) + ' and ' + IntToStr(pageindex * pagesize + pagesize);
      sql := sql + ' ' + order;
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

procedure TDBMSSQL08.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
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

