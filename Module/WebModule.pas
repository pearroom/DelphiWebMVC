unit WebModule;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.HTTPProd, Web.ReqMulti;

type
  TWM = class(TWebModule)
    WebFile: TWebFileDispatcher;
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  end;

var
  WebModuleClass: TComponentClass = TWM;

implementation

uses
  command, superobject, LogUnit, uConfig;

{$R *.dfm}

procedure TWM.WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  s: string;
  error: string;

begin
  try
    OpenRoule(Self, RouleMap, Handled);
  except
    on e: Exception do
    begin
      error := e.ToString;
      log(error);
      Response.StatusCode := 500;
      s := '<html><body><div style="text-align: center;">';
      s := s + '<div><h1> Error 500 </h1></div>';
      s := s + '<div>' + error + '</div></div></body></html>';
      Response.Content := s;
      Response.SendResponse;
    end;

  end;
end;

procedure TWM.WebModuleCreate(Sender: TObject);
var
  json: ISuperObject;
  ja: TSuperArray;
  I: Integer;
begin
  if __APP__.Trim <> '' then
  begin
    WebFile.VirtualPath := __APP__;
  end
  else
  begin
    WebFile.VirtualPath := '/';
  end;
  WebFile.WebFileExtensions.Clear;
  json := OpenMIMEFile;
  if json <> nil then
  begin
    ja := json.AsArray;
    for I := 0 to ja.Length - 1 do
    begin
      with WebFile.WebFileExtensions.Add do
      begin
        try
          Extensions := ja[I]['Extensions'].AsString;
          MimeType := ja[I]['MimeType'].AsString;
        except
          log('MIME配置文件错误,服务启动失败');
          break;
        end;
      end;
    end;
  end;
end;

end.

