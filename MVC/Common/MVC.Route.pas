{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.Route;

interface

uses
  System.Classes, MVC.RouteItem, System.StrUtils, System.Generics.Collections,
  System.SysUtils, System.Rtti;

type
  TRoute = class(TPersistent)
  private
    _RTTIContext: TRttiContext;
    list: TObjectList<TRouteItem>;
    listkey: TStringList;
    function GetItem(Route: string): TRouteItem;
    function finditem(name: string): Boolean;
  public
    procedure SetRoute(name: string; Action: TClass; path: string = ''; isInterceptor: Boolean = True);
    function GetRoute(url: string; var Route: string; var method: string): TRouteItem;
    constructor Create(); virtual;
    destructor Destroy; override;
  end;

implementation

uses
  MVC.Config;

{ TRoute }

constructor TRoute.Create;
begin
  list := TObjectList<TRouteItem>.Create;
  listkey := TStringList.Create;
end;

destructor TRoute.Destroy;
begin
  listkey.Clear;
  listkey.Free;
  list.Clear;
  list.Free;
end;

function TRoute.finditem(name: string): Boolean;
var
  j: integer;
  key: string;
begin
  Result := false;
  for j := 0 to listkey.Count - 1 do
  begin
    key := listkey.Strings[j];
    if UpperCase(key) = UpperCase(name) then
    begin
      Result := true;
      break;
    end;
  end;
end;

function TRoute.GetItem(Route: string): TRouteItem;
var
  I, j: Integer;
  item, defitem: TRouteItem;
  key: string;
  isFind: Boolean;
begin
  Result := nil;
  defitem := nil;
  isFind := false;
  for j := 0 to listkey.Count - 1 do
  begin
    key := listkey.Strings[j];
    if (UpperCase(key) = LeftStr(UpperCase(Route), Length(key))) or (UpperCase(key) = LeftStr(UpperCase(Route + '/'), Length(key))) then
    begin
      isFind := true;
      break;
    end;
  end;
  if isFind then
  begin
    for I := 0 to list.Count - 1 do
    begin
      item := list.Items[I];
      if ((key = item.Name) or ((key + '/') = item.Name)) and (Length(item.Name) > 1) then
      begin
        Result := item;
        break;
      end
      else if ((key = item.Name) or ((key + '/') = item.Name)) and (item.Name = '/') then
      begin
        defitem := item;
      end;
    end;
  end;
  if Result = nil then
    Result := defitem;
end;

function TRoute.GetRoute(url: string; var Route: string; var method: string): TRouteItem;
var
  item: TRouteItem;
  url1: string;
  tmp: string;
begin
  Result := nil;
  url1 := Trim(url);
  item := GetItem(url1);
  if item <> nil then
  begin
    Route := url1;
    tmp := Copy(Route, Length(item.Name) + 1, Length(Route) - Length(item.Name));
    method := Copy(tmp, 1, Pos('/', tmp) - 1);
    if method = '' then
    begin
      if tmp <> '' then
        method := tmp
      else
        method := 'index';
    end;
  end;
  Result := item;
end;

function DescCompareStrings(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := -AnsiCompareText(List[Index1], List[Index2]);
end;

procedure TRoute.SetRoute(name: string; Action: TClass; path: string; isInterceptor: Boolean);
var
  item: TRouteItem;
begin
  if (name.Trim <> '') and (name.Trim <> '/') then
    name := '/' + name + '/'
  else
    name := '/';
  if Config.__APP__.Trim <> '' then
  begin
    name := '/' + Config.__APP__ + name;
  end;
  name := name.Replace('///', '/').Replace('//', '/');
  if not finditem(name) then
  begin

    item := TRouteItem.Create;
    item.name := name;
    item.isInterceptor := isInterceptor;
    item.Action := Action;
    item.path := path;
    item.ActoinClass := _RTTIContext.GetType(item.Action);
    with item do
    begin
      SetParams := ActoinClass.GetMethod('SetParams');
      FreeDb := ActoinClass.GetMethod('FreeDb');
      ShowHTML := ActoinClass.GetMethod('ShowHTML');

      Interceptor := ActoinClass.GetMethod('Interceptor');
      Request := ActoinClass.GetProperty('Request');
      Response := ActoinClass.GetProperty('Response');
      ActionPath := ActoinClass.GetProperty('ActionPath');
      ActionRoute := ActoinClass.GetProperty('ActionRoute');
    end;
    List.Add(item);
    listkey.Add(name);
    listkey.CustomSort(DescCompareStrings);

  end;
end;

end.

