{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2022-2 苏兴迎(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.TplUnit;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Classes, MVC.Config,
  MVC.LogUnit, web.HTTPApp, Web.ReqMulti, System.RegularExpressions, mvc.json,
  System.JSON, MVC.Service, MVC.DataSet,MVC.Tool;

type
  TPage = class
  private
    PageContent: TStringList;
  public
    function Text(msg: string = ''): string;
    function Error404(msg: string): string;
    constructor Create(htmlfile: string);
    destructor Destroy; override;
  end;

  TPageCache = class
  public
    PageList: TDictionary<string, string>;
    function LoadPage(key: string): string;
    constructor Create();
    destructor Destroy; override;
  end;

  TSQLCache = class
  public
    SQLList: TDictionary<string, string>;
    function LoadPage(key: string): string;
    constructor Create();
    destructor Destroy; override;
  end;

var
  PageCache: TPageCache;
  SQLCache: TSQLCache;


implementation

{ TPage }

constructor TPage.Create(htmlfile: string);
begin
  htmlfile := htmlfile.Replace('/', '\');
  PageContent := TStringList.Create;
  if htmlfile.Trim = '' then
    exit;
  if not FileExists(htmlfile) then
    exit;
  if UpperCase(Config.document_charset) = 'UTF-8' then
  begin
    PageContent.LoadFromFile(htmlfile, TEncoding.UTF8);
  end
  else
  begin
    PageContent.LoadFromFile(htmlfile, TEncoding.Default);
  end;
end;

destructor TPage.Destroy;
begin
  PageContent.Free;
  inherited;
end;

function TPage.Error404(msg: string): string;
var
  htmlcontent: string;
begin
  htmlcontent := Text;
  if Trim(htmlcontent) = '' then
  begin
    htmlcontent := '<html><body><div style="text-align: left;">';
    htmlcontent := htmlcontent + '<div><h1>Error 404</h1></div>';
    htmlcontent := htmlcontent + '<hr><div>[ ' + msg + ' ] Not Find Page';
    htmlcontent := htmlcontent + '</div></div></body></html>';
  end;
  Result := htmlcontent;
end;

function TPage.Text(msg: string = ''): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
begin
  if msg <> '' then
  begin

    s := '#{message}';
    matchs := TRegEx.Matches(PageContent.Text, s);
    for match in matchs do
    begin
      if match.Value = s then
      begin
        PageContent.Text := PageContent.Text.Replace(match.Value, msg);
      end;
    end;

    Result := PageContent.Text;

  end
  else
    Result := PageContent.Text;
end;

{ TPageCache }

constructor TPageCache.Create;
begin
  PageList := TDictionary<string, string>.Create;
end;

destructor TPageCache.Destroy;
begin
  PageList.Free;
  inherited;
end;

function TPageCache.LoadPage(key: string): string;
var
  page: TPage;
  htmlcontent, pagefile: string;
begin
  if PageCache.PageList.ContainsKey(key) and not Config.open_debug then
  begin
    Lock(PageCache.PageList);
    PageCache.PageList.TryGetValue(key, htmlcontent);
    UnLock(PageCache.PageList);
  end
  else
  begin
    pagefile := Config.BasePath + config.WebRoot + '\' + Config.template + '\' + key;
    pagefile := IITool.PathFmt(pagefile);
    if FileExists(pagefile) then
    begin
      page := TPage.Create(pagefile);
      try
        htmlcontent := page.text;
        Lock(PageCache.PageList);
        PageCache.PageList.AddOrSetValue(key, htmlcontent);
        UnLock(PageCache.PageList);
      finally
        page.Free;
      end;
    end
    else
    begin
      htmlcontent := '';
    end;
  end;
  Result := htmlcontent;
end;

{ TSQLCache }

constructor TSQLCache.Create;
begin
  SQLList := TDictionary<string, string>.Create;
end;

destructor TSQLCache.Destroy;
begin
  SQLList.Free;
  inherited;
end;

function TSQLCache.LoadPage(key: string): string;
var
  page: TPage;
  sqlcontent, pagefile: string;
begin
  if SQLCache.SQLList.ContainsKey(key) and not Config.open_debug then
  begin
    Lock(SQLCache.SQLList);
    SQLCache.SQLList.TryGetValue(key, sqlcontent);
    UnLock(SQLCache.SQLList);
  end
  else
  begin
    pagefile := Config.BasePath + key;
    pagefile := IITool.PathFmt(pagefile);
    if FileExists(pagefile) then
    begin
      page := TPage.Create(pagefile);
      try
        sqlcontent := page.text;
        Lock(SQLCache.SQLList);
        SQLCache.SQLList.AddOrSetValue(key, sqlcontent);
        UnLock(SQLCache.SQLList);
      finally
        page.Free;
      end;
    end
    else
    begin
      sqlcontent := '';
    end;
  end;
  Result := sqlcontent;
end;

initialization
  PageCache := TPageCache.Create;
  SQLCache := TSQLCache.Create;


finalization
  PageCache.Free;
  SQLCache.Free;

end.

