{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit Roule;

interface

uses
  System.Classes, RouleItem, System.StrUtils, System.Generics.Collections,
  System.SysUtils;

type
  TRoule = class
  private
    list: TObjectList<TRouleItem>;
  public
    procedure SetRoule(name: string; ACtion: TClass; path: string = '';isInterceptor:Boolean=True);
    function GetRoule(url: string; var roule: string; var method: string): TRouleItem;
    function GetItem(roule: string): TRouleItem;
    constructor Create(); virtual;
    destructor Destroy; override;
  end;

implementation

{ TRoule }

constructor TRoule.Create;
begin
  list := TObjectList<TRouleItem>.Create;
end;

destructor TRoule.Destroy;
begin
  list.Clear;
  list.Free;
end;

function TRoule.GetItem(roule: string): TRouleItem;
var
  I: Integer;
  item: TRouleItem;
begin
  Result := nil;
  for I := 0 to list.Count - 1 do
  begin
    item := list.Items[I];
    if UpperCase(item.Name) = UpperCase(roule) then
    begin
      Result := item;
      break;
    end;
  end;

end;

function TRoule.GetRoule(url: string; var roule: string; var method: string): TRouleItem;
var
  I: Integer;
  item: TRouleItem;
  url1, url2: string;
  tmp: TStringList;
begin
  Result := nil;
  url1 := '';
  url2 := '';
  method := '';
  tmp := TStringList.Create;
  try
    url := Trim(url);
    if url[url.Length] = '/' then
    begin
      url := LeftStr(url, url.Length - 1);
    end;

    tmp.Delimiter := '/';
    tmp.DelimitedText := url;

    for I := 0 to tmp.Count - 1 do
    begin
      if tmp.Strings[I] <> '' then
      begin
        url1 := url1 + '/' + tmp.Strings[I];
        if (tmp.Count >= 2) then
        begin
          if I <= tmp.Count - 2 then
          begin
            url2 := url2 + '/' + tmp.Strings[I];
          end;
        end;
      end;
    end;
    if url1 = '' then
      url1 := '/';
    if url2 = '' then
      url2 := '/';

    item := GetItem(url1);
    if (item <> nil) then
    begin
      roule := url1;
      method := 'index';
    end
    else
    begin
      item := GetItem(url2);
      if item <> nil then
      begin
        roule := url2;
        method := tmp.Strings[tmp.Count - 1];
      end;
    end;
    Result := item;
  finally
    tmp.Clear;
    tmp.Free;
  end;

end;

procedure TRoule.SetRoule(name: string; ACtion: TClass; path: string;isInterceptor:Boolean);
var
  item: TRouleItem;
begin
  item := TRouleItem.Create;
  item.name := name;
  item.Interceptor:=isInterceptor;
  item.ACtion := ACtion;
  item.path := path;
  list.Add(item);

end;

end.

