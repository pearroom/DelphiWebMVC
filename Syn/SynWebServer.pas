{ *************************************************************************** }
{  SynWebReqRes.pas is the 3rd file of SynBroker Project                      }
{  by c5soft@189.cn  Version 0.9.2.0  2018-6-7                                }
{ *************************************************************************** }

unit SynWebServer;

interface

uses
  SysUtils, Classes, IniFiles, HTTPApp, Contnrs, WebReq, SynCommons, SynCrtSock,
  SynWebEnv;

type
  TSynWebRequestHandler = class(TWebRequestHandler);

  TSynWebServer = class
  private
    FOwner: TObject;
    FIniFile: TIniFile;
    FActive: Boolean;
    FRoot, FPort: string;
    FHttpServer: THttpApiServer;
    FReqHandler: TWebRequestHandler;
    function Process(AContext: THttpServerRequest): cardinal;
    function WebBrokerDispatch(const AEnv: TSynWebEnv): Boolean;
  public
  public
    procedure Start();
    property Active: Boolean read FActive;
    property Port: string read FPort;
    constructor Create(AOwner: TComponent = nil; Root: string = ''; Port: string = '');
    destructor Destroy; override;
  end;

implementation

uses
  SynZip, SynWebReqRes, uConfig;

var
  RequestHandler: TWebRequestHandler = nil;

function GetRequestHandler: TWebRequestHandler;
begin
  if RequestHandler = nil then
    RequestHandler := TSynWebRequestHandler.Create(nil);
  Result := RequestHandler;
end;

{ TSynWebServer }

constructor TSynWebServer.Create(AOwner: TComponent; Root: string; Port: string);
begin
  inherited Create;
  FActive := False;
  FOwner := AOwner;
  if (FOwner <> nil) and (FOwner.InheritsFrom(TWebRequestHandler)) then
    FReqHandler := TWebRequestHandler(FOwner)
  else
    FReqHandler := GetRequestHandler;
  FIniFile := TIniFile.Create(WebApplicationDirectory + config);
  FRoot := FIniFile.ReadString('Server', 'Root', '');
  FPort := FIniFile.ReadString('Server', 'Port', '8001');
 // FIniFile.Free;
  FHttpServer := THttpApiServer.Create(False);
  FHttpServer.AddUrl(StringTOUTF8(FRoot), StringTOUTF8(FPort), False, '+', true);
  FHttpServer.RegisterCompress(CompressDeflate);
  // our server will deflate html :)
  FHttpServer.OnRequest := Process;
  FHttpServer.HTTPQueueLength := 5000;
  FHttpServer.Clone(7); // will use a thread pool of 32 threads in total
  FActive := true;
end;

destructor TSynWebServer.Destroy;
begin
  FHttpServer.RemoveUrl(StringTOUTF8(FRoot), StringTOUTF8(FPort), False, '+');
  FHttpServer.Free;
  FIniFile.Free;
  inherited;
end;

function TSynWebServer.Process(AContext: THttpServerRequest): cardinal;
var
  LEnv: TSynWebEnv;
begin
  try
    LEnv := TSynWebEnv.Create(AContext);
    try
      if WebBrokerDispatch(LEnv) then
        Result := LEnv.StatusCode
      else
        Result := 404;
    finally
      LEnv.Free;
    end;
  except
    on e: Exception do
    begin
      AContext.OutContent := StringTOUTF8('<HTML><BODY>' + '<H1>服务器运行出错</H1>' + '<P>' + UTF8ToString(AContext.Method + ' ' + AContext.URL) + '</P>' + '<P>' + e.Message + '</P>' + '</HTML></BODY>');
      AContext.OutContentType := HTML_CONTENT_TYPE;
      Result := 500;
    end;
  end;
end;

procedure TSynWebServer.Start;
begin

end;

function TSynWebServer.WebBrokerDispatch(const AEnv: TSynWebEnv): Boolean;
var
  HTTPRequest: TSynWebRequest;
  HTTPResponse: TSynWebResponse;
begin
  HTTPRequest := TSynWebRequest.Create(AEnv);
  try
    HTTPResponse := TSynWebResponse.Create(HTTPRequest);
    try
      Result := TSynWebRequestHandler(FReqHandler).HandleRequest(HTTPRequest, HTTPResponse);
    finally
      HTTPResponse.Free;
    end;
  finally
    HTTPRequest.Free;
  end;
end;

initialization
  WebReq.WebRequestHandlerProc := GetRequestHandler;

finalization
  if RequestHandler <> nil then
    FreeAndNil(RequestHandler);

end.

