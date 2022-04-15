unit MVC.TplParser;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Classes, MVC.Config,
  MVC.LogUnit, web.HTTPApp, Web.ReqMulti, System.RegularExpressions, mvc.json,
  System.JSON, MVC.Service, MVC.Tool;

type
  TTplParser = class(TService)
  private
    leftFmt: string; //左边字符
    rightFmt: string; //右边字符
    function foreachvalue(text, key, value: string; var isok: Boolean): string;
    function foreach(text: string; param: TStringList): string;
    procedure foreachinclude(var text: string; param: TStringList; url: string);
    procedure foreachclear(var text: string);
    function foreachjson(text: string; key: string; json: TJSONObject; var isok: Boolean): string;
    function foreachlist(text, key: string; json: TJSONArray; var isok: boolean): string;
    function foreachsubjson(text: string; key: string; json: IJArray; var isok: Boolean): string;
    function foreachsublist(text: string; key: string; json: IJArray; var isok: boolean): string;
    function foreachsetif(text: string): string;
    function foreachelseif(text: string): string;
    function checkifwhere(where: string): boolean;

  public
    procedure Parser(var text: string; param: TStringList; url: string);
  end;

implementation

uses
  MVC.TplUnit, MVC.DataSet;

function ckdata(value: string): boolean;
begin
  if (value = 'neq') or (value = 'eq') or (value = 'and')
    or (value = 'or') or (value = 'gte') or (value = 'gt')
    or (value = 'lte') or (value = 'lt') or (value = '==') then
    Result := true
  else
    Result := false;
end;

function TTplParser.checkifwhere(where: string): boolean;
var
  strlist: TStringList;
  i: Integer;
  s: string;
  device: string;
  mssqlver: string;
  sql: string;
  ver: string;
  dataset: IDataset;
begin
  strlist := TStringList.Create;
  try
    strlist.Delimiter := ' ';
    strlist.DelimitedText := where;
    for i := 0 to strlist.Count - 1 do
    begin
      s := Trim(strlist[i]);
      if (s <> '') and (Pos(#39, s) <= 0) and (not ckdata(s)) then
      begin
        s := Q(s);
        strlist[i] := s;
      end;
    end;
    s := '';
    for i := 0 to strlist.Count - 1 do
    begin
      s := s + strlist[i];
    end;
    where := s;
  finally
    strlist.Free;
  end;

  where := where.Replace('neq', ' != ');
  where := where.Replace('eq', ' = ');
  where := where.Replace('and', ' and ');
  where := where.Replace('or', ' or ');
  where := where.Replace('gte', ' >= ').Replace('ge', ' >= ');
  where := where.Replace('gt', ' > ');
  where := where.Replace('lte', ' <= ').Replace('le', ' <= ');
  where := where.Replace('lt', ' < ');
  where := where.Replace('==', ' = ');
  //这里需要对where条件进行计算获取结果
  try
    if Db.TryConn then
    begin
      sql := 'select ' + where + ' as sn';
      device := db.DriverName;
      if device.ToLower = 'ora' then
      begin
        sql := 'select 1 as sn from user_role_privs where ' + where;
      end;
      if device.ToLower = 'mssql' then
      begin
        mssqlver := db.GetMSSQLVer;
        ver := mssqlver.Split(['.'])[0];
        if ver.ToInteger = 10 then   // 版本是10 是 mssql2008
        begin
          sql := 'select 1 as sn where ' + where;
        end
        else if ver.ToInteger > 10 then   // 大于 10 mssql2008以上数据库;
        begin
          sql := 'select 1 as sn where ' + where;
        end
        else if ver.ToInteger = 8 then  //2000版本
        begin
          sql := 'select 1 as sn where ' + where;
        end;
      end;
      dataset := db.Find(sql);
      if dataset.ds.FieldByName('sn').AsString = '1' then
        Result := true
      else
        Result := False;
    end
    else
      Result := false;
  except
    Result := false;
  end;
end;

function TTplParser.foreach(text: string; param: TStringList): string;
var
  isok: Boolean;
  key, value: string;
  i: Integer;
  jo: IJObject;
  ja: IJArray;
begin
  for i := 0 to param.Count - 1 do
  begin
    key := param.Names[i];
    value := param.ValueFromIndex[i];
    text := foreachvalue(text, key, value, isok);

    if (value[1] = '{') and (value[value.Length] = '}') then
    begin
      jo := IIJObject(value);
      text := foreachjson(text, key, jo.O, isok);
    end
    else if (value[1] = '[') and (value[value.Length] = ']') then
    begin
      ja := IIJArray(value);
      text := foreachlist(text, key, ja.A, isok);
    end;
  end;

  text := foreachsetif(text);
  Result := text;
end;

procedure TTplParser.foreachclear(var text: string);
var
  matchs: TMatchCollection;
  match: TMatch;
begin
  matchs := TRegEx.Matches(text, Self.leftFmt + '[\s\S]*?\' + self.rightFmt);
  for match in matchs do
  begin
    text := TRegEx.Replace(text, match.Value, '');
  end;
  matchs := TRegEx.Matches(text, '<#list[\s\S]*?</#list>');
  for match in matchs do
  begin
    text := TRegEx.Replace(text, match.Value, '');
  end;
  matchs := TRegEx.Matches(text, '<#if[\s\S]*?</#if>');
  for match in matchs do
  begin
    text := TRegEx.Replace(text, match.Value, '');
  end;
end;

function TTplParser.foreachelseif(text: string): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, datavalue: string;
  strls: TStringList;
  html: string;
  isok: Boolean;
begin
  isok := False;
  strls := TStringList.Create;
  try
    matchs := TRegEx.Matches(text, 'if[\s\S]*?<#else');
    for match in matchs do
    begin
      strls.Text := match.Value;
      s := TRegEx.Replace(strls.Text, 'if.*?>', '');
      s := TRegEx.Replace(s, '<#else', '');
      html := s;
      datavalue := Trim(TRegEx.Match(strls.Text, 'if.*?>').value);
      datavalue := datavalue.Replace('if', '');
      datavalue := datavalue.Replace('>', '');
     // datavalue := datavalue.Replace(' ', '');
     // datavalue := datavalue.Replace('''', '');
      if checkifwhere(datavalue) then
      begin
        text := html;
        isok := true;
        break;
      end;
    end;

    if not isok then
    begin
      matchs := TRegEx.Matches(text, 'if[\s\S]*?</#if>');
      for match in matchs do
      begin
        if match.Value.IndexOf('else') < 0 then
        begin
          strls.Text := match.Value;
          s := TRegEx.Replace(strls.Text, 'if.*?>', '');
          s := TRegEx.Replace(s, '</#', '');
          html := s;
          datavalue := Trim(TRegEx.Match(strls.Text, 'if.*?>').value);
          datavalue := datavalue.Replace('if', '');
          datavalue := datavalue.Replace('>', '');
         // datavalue := datavalue.Replace(' ', '');
         // datavalue := datavalue.Replace('''', '');
          if checkifwhere(datavalue) then
          begin
            text := html;
            isok := true;
            break;
          end;
        end;
      end;
    end;
    if not isok then
    begin
      matchs := TRegEx.Matches(text, '<#else>[\s\S]*?</#if>');
      for match in matchs do
      begin
        strls.Text := match.Value;
        s := TRegEx.Replace(strls.Text, '<#else>', '');
        s := TRegEx.Replace(s, '</#if>', '');
        text := s;
        isok := true;
        Break;
      end;
    end;
    if not isok then
    begin
      text := '';
    end;
    Result := text;
  finally
    strls.Free;
  end;
end;

procedure TTplParser.foreachinclude(var text: string; param: TStringList; url: string);
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
  htmlfile: string;
  page: TPage;
  root: string;
begin
  matchs := TRegEx.Matches(text, '<#include.*file=[\s\S]*?\>');

  for match in matchs do
  begin
    s := match.Value;

    begin
      htmlfile := Trim(TRegEx.Match(s, 'file=.*?>').value);
      htmlfile := Copy(htmlfile, Pos('=', htmlfile) + 1, Pos('>', htmlfile) - Pos('=', htmlfile) - 1);
      htmlfile := Trim(htmlfile);
      if htmlfile[htmlfile.Length] = '/' then
      begin
        htmlfile := Copy(htmlfile, 0, htmlfile.Length - 1);
        htmlfile := Trim(htmlfile);
      end;
      if Config.WebRoot.Trim <> '' then
      begin
        root := Config.WebRoot + '/';
      end;
      htmlfile := htmlfile.Replace('''', '').Replace('"', '');
      if (htmlfile.IndexOf('/') = 0) then
        htmlfile := Config.BasePath + root + Config.template + htmlfile
      else
        htmlfile := Config.BasePath + root + Config.template + '/' + url + htmlfile;
      htmlfile := IITool.PathFmt(htmlfile);
      if (Trim(htmlfile) <> '') then
      begin
        if (not FileExists(htmlfile)) then
        begin
          text := '';
        end
        else
        begin
          page := TPage.Create(htmlfile);
          try
            text := TRegEx.Replace(text, match.Value, page.Text(''));
          finally
            page.Free;
          end;
        //  foreachinclude(text, param, url);
        end;
      end;
    end;
  end;
  s := '__APP__';
  matchs := TRegEx.Matches(text, s);
  for match in matchs do
  begin
    if match.Value = s then
    begin
      text := text.Replace(match.Value, Config.App);
    end;
  end;
end;

function TTplParser.foreachjson(text, key: string; json: TJSONObject; var isok: Boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, html: string;
  i: Integer;
begin
  html := text;
  isok := false;
  begin
    for i := 0 to json.Count - 1 do
    begin
    //  html := foreachif(html, key + '.' + json.Pairs[i].JsonString.Value, json.Pairs[i].JsonValue.Value, isok);
      s := self.leftFmt + key + '.' + json.Pairs[i].JsonString.Value + self.rightFmt;
      matchs := TRegEx.Matches(html, s, [roIgnoreCase]);
      for match in matchs do
      begin
        if match.Value.ToLower = s.ToLower then
        begin
          html := html.Replace(match.Value, json.Pairs[i].JsonValue.Value);
          isok := true;
        end;
      end;
      s := self.leftFmt + key + '.' + json.Pairs[i].JsonString.Value + '\|s' + self.rightFmt;
      matchs := TRegEx.Matches(html, s, [roIgnoreCase]);
      for match in matchs do
      begin
        if match.Value.ToLower = s.Replace('\', '').ToLower then
        begin
          html := html.Replace(match.Value, Q(json.Pairs[i].JsonValue.Value));
          isok := true;
        end;
      end;
    end;
  end;
  Result := html;
end;

function TTplParser.foreachvalue(text, key, value: string; var isok: Boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
begin
  isok := false;
  s := self.leftFmt + key + self.rightFmt;
  matchs := TRegEx.Matches(text, s, [roIgnoreCase]);
  for match in matchs do
  begin
    if match.Value.ToLower = s.ToLower then
    begin
      text := text.Replace(match.Value, value);
      isok := true;
    end;
  end;
  s := self.leftFmt + key + '\|s' + Self.rightFmt;
  matchs := TRegEx.Matches(text, s, [roIgnoreCase]);
  for match in matchs do
  begin
    if match.Value.ToLower = s.Replace('\', '').ToLower then
    begin
      text := text.Replace(match.Value, Q(value));
      isok := true;
    end;
  end;
  Result := text;
end;

function TTplParser.foreachlist(text, key: string; json: TJSONArray; var isok: boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, datavalue, itemvalue: string;
  strls: TStringList;
  html, html1: string;
  arr: TJSONArray;
  I: Integer;
begin
  strls := TStringList.Create;

  arr := json;
  isok := false;
  matchs := TRegEx.Matches(text, '<#list.*data=' + key + ' [\s\S]*?</#list>');
  try
    for match in matchs do
    begin
      strls.Text := match.Value;

      s := TRegEx.Replace(strls.Text, '<#list.*?>', '');
      s := TRegEx.Replace(s, '</#list>', '');
      html1 := s;
      s := Trim(TRegEx.Match(strls.Text, '<#list.*?>').value);
      datavalue := Trim(TRegEx.Match(s, 'data=.*? ').value);
      itemvalue := Trim(TRegEx.Match(s, 'item=.*?>').value.Replace('>', ''));
      datavalue := Copy(datavalue, 6, Length(datavalue) - 5);
      itemvalue := Copy(itemvalue, 6, Length(itemvalue) - 5);
      if datavalue = key then
      begin
        for I := 0 to arr.Count - 1 do
        begin
          html := html + foreachjson(html1, itemvalue, arr.Items[I] as TJSONObject, isok);
        end;
        html := foreachsetif(html);
        text := text.Replace(match.Value, html);
        isok := true;
      end;
    end;

    Result := text;
  finally
    strls.Clear;
    strls.Free;
  end;
end;

function TTplParser.foreachsetif(text: string): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
  html: string;
begin

  matchs := TRegEx.Matches(text, '<#if[\s\S]*?</#if>');
  for match in matchs do
  begin
    html := foreachelseif(match.Value);
    s := text.Replace(match.Value, html);
    text := s;
  end;

  Result := text;
end;

function TTplParser.foreachsubjson(text, key: string; json: IJArray; var isok: Boolean): string;
//var
//  match: TMatch;
//  s, html: string;
begin
//  html := text;
//  isok := false;
 // if json.IsType(TSuperType.stObject) then
//  begin
//    json.First;
//    while not json.EoF do
//    begin
//
//      html := foreachif(html, key + '.' + json.CurrentKey, json.CurrentValue.AsVariant, isok);
//      s := '#{' + key + '.' + json.CurrentKey + '}';
//      matchs := TRegEx.Matches(html, s);
//      for match in matchs do
//      begin
//        if match.Value = s then
//        begin
//          html := html.Replace(match.Value, json.CurrentValue.AsVariant);
//          isok := true;
//        end;
//      end;
//    end;
//  end;
//  Result := html;
end;

function TTplParser.foreachsublist(text, key: string; json: IJArray; var isok: boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, datavalue, itemvalue: string;
  strls: TStringList;
  html, html1: string;
  arr: IJArray;
  I: Integer;
begin
  strls := TStringList.Create;

  arr := json;
  isok := false;
  matchs := TRegEx.Matches(text, '<#sublist.*data=' + key + ' [\s\S]*?</#sublist>');
  try
    for match in matchs do
    begin
      strls.Text := match.Value;

      s := TRegEx.Replace(strls.Text, '<#sublist.*?>', '');
      s := TRegEx.Replace(s, '</#sublist>', '');
      html1 := s;
      s := Trim(TRegEx.Match(strls.Text, '<#sublist.*?>').value);
      datavalue := Trim(TRegEx.Match(s, 'data=.*? ').value);
      itemvalue := Trim(TRegEx.Match(s, 'item=.*?>').value.Replace('>', ''));
      datavalue := Copy(datavalue, 6, Length(datavalue) - 5);
      itemvalue := Copy(itemvalue, 6, Length(itemvalue) - 5);
      if datavalue = key then
      begin
        for I := 0 to arr.A.Count - 1 do
        begin
        //  html := html + foreachsubjson(html1, itemvalue, arr.A.Get(i) as System.JSON.TJSONArray, isok);
        end;
        html := foreachsetif(html);
        text := text.Replace(match.Value, html);
        isok := true;
      end;
    end;

    Result := text;
  finally
    strls.Clear;
    strls.Free;
  end;
end;

procedure TTplParser.Parser(var text: string; param: TStringList; url: string);
begin
  if text = '' then
    Exit;
  self.leftFmt := Config.leftFmt;
  self.rightFmt := Config.rightFmt;
  foreachinclude(text, param, url);
  text := foreach(text, param);
 // foreachclear(text);
end;

end.

