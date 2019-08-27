{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.Roule;

interface

uses
  System.Classes, MVC.RouleItem, System.StrUtils, System.Generics.Collections,
  System.SysUtils;

type
  TRoule = class
  private
    list: TObjectList<TRouleItem>;
    listkey: TStringList;
    function GetItem(roule: string): TRouleItem;
  public
    procedure SetRoule(name: string; ACtion: TClass; path: string = ''; isInterceptor: Boolean = True);
    function GetRoule(url: string; var roule: string; var method: string): TRouleItem;
    constructor Create(); virtual;
    destructor Destroy; override;
  end;

implementation

uses
  uConfig;

{ TRoule }

constructor TRoule.Create;
begin
  list := TObjectList<TRouleItem>.Create;
  listkey := TStringList.Create;
end;

destructor TRoule.Destroy;
begin
  listkey.Clear;
  listkey.Free;
  list.Clear;
  list.Free;
end;

function TRoule.GetItem(roule: string): TRouleItem;
var
  I, j: Integer;
  item, defitem: TRouleItem;
  key: string;
  isFind: Boolean;
begin
  Result := nil;
  defitem := nil;
  isFind := false;
  for j := 0 to listkey.Count - 1 do
  begin
    key := listkey.Strings[j];
    if (UpperCase(key) = LeftStr(UpperCase(roule), Length(key)))
      or (UpperCase(key) = LeftStr(UpperCase(roule + '/'), Length(key))) then
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
      if ((key = item.Name) or ((key + '/') = item.Name))
        and (Length(item.Name) > 1) then
      begin
        Result := item;
        break;
      end
      else if ((key = item.Name) or ((key + '/') = item.Name))
        and (item.Name = '/') then
      begin
        defitem := item;
      end;
    end;
  end;
  if Result = nil then
    Result := defitem;
end;

function TRoule.GetRoule(url: string; var roule: string; var method: string): TRouleItem;
var
  item: TRouleItem;
  url1: string;
  tmp: string;
begin
  Result := nil;
  url1 := Trim(url);
  item := GetItem(url1);
  if item <> nil then
  begin
    roule := url1;
    tmp := Copy(roule, Length(item.Name) + 1, Length(roule) - Length(item.Name));
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

procedure TRoule.SetRoule(name: string; ACtion: TClass; path: string; isInterceptor: Boolean);
var
  item: TRouleItem;
begin
  if name.Trim <> '' then
    name := '/' + name + '/'
  else
    name := '/';
  if __APP__.Trim <> '' then
  begin
    name := '/' + __APP__ + name;
  end;

  item := TRouleItem.Create;
  item.name := name;
  item.Interceptor := isInterceptor;
  item.ACtion := ACtion;
  item.path := path;
  List.Add(item);
  listkey.Add(name);
  listkey.CustomSort(DescCompareStrings);
end;

end.

