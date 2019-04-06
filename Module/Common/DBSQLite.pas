{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit DBSQLite;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, superobject, DBBase;

type
  TDBSQLite = class(TDBBase)
  private
  public
    function FindFirst(tablename: string; where: string=''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
  end;

implementation


{ TDBSQLite }
function TDBSQLite.FindFirst(tablename: string; where: string=''): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  sql := 'select ' + Fields + ' from ' + tablename + ' where 1=1 ' + where + ' limit 1';
  Result := QueryFirst(sql);
end;

function TDBSQLite.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;
var
  CDS: TFDQuery;
  sql: string;
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
      sql:=filterSQL(sql);
      CDS.Open(sql);
      count := CDS.FieldByName('N').AsInteger;
      CDS.Close;
      sql := 'select ' + Trim(select) + ' from ' + Trim(from) + ' ' + Trim(order) + ' limit ' + inttostr(pageindex * pagesize) + ',' + inttostr(pagesize);
      Result := Query(sql);
    except
      on e: Exception do
      begin
        DBlog(e.ToString);
        Result := nil;
      end;

    end;
  finally
    FreeAndNil(CDS);
  end;

end;

end.

