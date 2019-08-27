{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.DBMSSQL08;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, xsuperobject, MVC.DBBase, Data.DB;

type
  TDBMSSQL08 = class(TDBBase)
  private
    function GetSQL(tp: Boolean; var dataset: TFDQuery; var count: Integer; select, from, order: string; pageindex, pagesize: Integer): Boolean;
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
    function QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string; override;
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

function TDBMSSQL08.GetSQL(tp: Boolean; var dataset: TFDQuery; var count: Integer; select, from, order: string; pageindex, pagesize: Integer): Boolean;
var
  sql: string;
begin
  Result := True;
  if (not TryConnDB) or (Trim(select) = '') or (Trim(from) = '') then
    Exit;

  if Trim(order) <> '' then
    order := 'order by ' + Trim(order);

  try
    try

      sql := 'select count(1) as N from ' + from;
      sql := filterSQL(sql);
      count := condb.ExecSQLScalar(sql);
     // CDS.Close;
      if select.Trim = '' then
        select := '*';
      sql := ' select *,ROW_NUMBER() OVER(ORDER BY tmprow) AS RowNo from (select 0 tmprow,' + select + ' from ' + from + ') tmp1 ';
      sql := ' select * from (' + sql + ') tmp2 where RowNo between ' + IntToStr(pageindex * pagesize) + ' and ' + IntToStr(pageindex * pagesize + pagesize);
      sql := sql + ' ' + order;
      Result := Query(sql, dataset);
      PageKey := '';
    except
      on e: Exception do
      begin
        DBlog(e.ToString);
        Result := False;
      end;
    end;
  finally

  end;
end;

function TDBMSSQL08.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;

begin
  try
    if GetSQL(True, TMP_CDS, count, select, from, order, pageindex, pagesize) then
    begin
      Result := CDSToJSONArray(TMP_CDS);
    end
    else
      Result := SA().AsObject;
  finally

  end;
end;

function TDBMSSQL08.QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string;
begin
  try
    if GetSQL(False, TMP_CDS, count, select, from, order, pageindex, pagesize) then
    begin
      Result := CDSToJSONText(TMP_CDS);
    end
    else
      Result := '[]';
  finally

  end;
end;

procedure TDBMSSQL08.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
begin
  inherited;
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

