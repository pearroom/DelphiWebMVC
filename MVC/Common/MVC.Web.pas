unit MVC.Web;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.HTTPProd, Web.ReqMulti;

type
  TMVCWeb = class(TWebModule)
    WebFile: TWebFileDispatcher;
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  end;

var
  WebModuleClass: TComponentClass = TMVCWeb;

implementation

uses
  MVC.command, MVC.LogUnit, MVC.Config, XSuperObject, XSuperJSON, MVC.Page;

{$R *.dfm}

procedure TMVCWeb.WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  s: string;
  error: string;
  page: Tpage;
begin
  try
    OpenRoule(Self, _RouleMap, Handled);
  except
    on e: Exception do
    begin
      error := e.ToString;
      log(error);
      s := '<html><body><div style="text-align: left;">';
      s := s + '<div><h1> Error 500 </h1></div>';
      s := s + '<hr><div>' + error + '</div></div></body></html>';
      if Trim(Config.Error500) <> '' then
      begin
        if FileExists(Config.Error500) then
        begin
          page := TPage.Create(Config.Error500, nil, '');
          try
            s := page.HTML;
          finally
            page.Free;
          end;
        end;
      end;
      Response.StatusCode := 500;
      Response.ContentType := 'text/html; charset=' + Config.document_charset;
      Response.Content := s;
      Response.SendResponse;
    end;
  end;
end;

procedure TMVCWeb.WebModuleCreate(Sender: TObject);
var
  json, jo: ISuperObject;
  ja: ISuperArray;
  I: Integer;
begin
  if Config.__WebRoot__.Trim <> '' then
  begin
    webFile.RootDirectory := Config.__WebRoot__;
  end;
  if Config.__APP__.Trim <> '' then
  begin
    WebFile.VirtualPath := Config.__APP__;
  end
  else
  begin
    WebFile.VirtualPath := '/';
  end;
  WebFile.WebFileExtensions.Clear;
  json := SO(_MIMEConfig);
  if json.DataType = TDataType.dtArray then
  begin
    ja := json.AsArray;
    for I := 0 to ja.Length - 1 do
    begin
      with WebFile.WebFileExtensions.Add do
      begin
        try
          jo := ja.O[I];
          Extensions := jo.s['Extensions'];
          MimeType := jo.s['MimeType'] + '; charset=' + Config.document_charset;
        except
          log('MIME配置文件错误,服务启动失败');
          break;
        end;
      end;
    end;
  end;
end;

end.

