{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.DBOracle;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, XSuperObject, MVC.DBBase, Data.DB;

type
  TDBOracle = class(TDBBase)
  private
    function GetSQL(tp: Boolean; var dataset: TFDQuery; var count: Integer; select, from, order: string; pageindex, pagesize: Integer): Boolean;
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
    function QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string; override;
    procedure StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant); overload;
  end;

implementation

{ TDBOracle }

function TDBOracle.FindFirst(tablename: string; where: string = ''): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  sql := 'select ' + Fields + ' from ' + tablename + ' where 1=1 ' + where;
  sql := 'select * from (' + sql + ') where rownum=1';
  Result := QueryFirst(sql);
end;

function TDBOracle.GetSQL(tp: Boolean; var dataset: TFDQuery; var count: Integer; select, from, order: string; pageindex, pagesize: Integer): Boolean;
var
  sql: string;
begin
  Result := True;
  if (not TryConnDB) or (Trim(select) = '') or (Trim(from) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  if Trim(order) <> '' then
    order := 'order by ' + Trim(order);
  try
    try
      sql := 'select count(1) as N from ' + from;
      sql := filterSQL(sql);
      count := condb.ExecSQLScalar(sql);
      sql := 'select A.*,rownum rn from(select ' + Fields + ' from ' + from + ') A ';
      sql := 'select * from (' + sql + ') where rn between ' + IntToStr(pagesize * pageindex) + ' and ' + IntToStr(pagesize * pageindex + pagesize);

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

function TDBOracle.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
var
  cds: TFDQuery;
begin
  cds := TFDQuery.Create(nil);
  try
    if GetSQL(True, cds, count, select, from, order, pageindex, pagesize) then
    begin
      Result := CDSToJSONArray(cds);
    end
    else
      Result := SA().AsObject;
  finally
    cds.Free;
  end;
end;

function TDBOracle.QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string;
var
  cds: TFDQuery;
begin
  cds := TFDQuery.Create(nil);
  try
    if GetSQL(False, cds, count, select, from, order, pageindex, pagesize) then
    begin
      Result := CDSToJSONText(cds);
    end
    else
      Result := '[]';
  finally
    cds.Free;
  end;
end;

procedure TDBOracle.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
begin
  inherited;
  with StoredProc.Params.Add do
  begin
    DisplayName := DisplayName_;
    Name := DisplayName_;
    DataType := DataType_;
    Value := Value_;
    ParamType := ParamType_;
  end;
end;

end.

