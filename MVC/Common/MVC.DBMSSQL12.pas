{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.DBMSSQL12;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, XSuperObject, MVC.DBBase, Data.DB,MVC.LogUnit;

type
  TDBMSSQL12 = class(TDBBase)
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


function TDBMSSQL12.FindFirst(tablename: string; where: string = ''): ISuperObject;
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

function TDBMSSQL12.GetSQL(tp: Boolean; var dataset: TFDQuery; var count: Integer; select, from, order: string; pageindex, pagesize: Integer): Boolean;
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
      count :=condb.ExecSQLScalar(sql);
      sql := 'select ' + Trim(select) + ' from ' + Trim(from) + ' ' + Trim(order) + ' offset ' + inttostr(pageindex * pagesize) + ' rows fetch next ' + inttostr(pagesize) + ' rows only ';
      Result := Query(sql, dataset);
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

function TDBMSSQL12.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
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

function TDBMSSQL12.QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string;

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

procedure TDBMSSQL12.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
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

