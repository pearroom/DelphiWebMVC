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
  SynZip, SynWebReqRes, uConfig, command, superobject, LogUnit;

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
var
  jo: ISuperObject;
  Compress: string;
  HTTPQueueLength, ChildThreadCount: integer;
begin
  inherited Create;
  FActive := False;
  FOwner := AOwner;
  jo := OpenConfigFile();
  if jo <> nil then
  begin
    try
      FPort := jo.O['Server'].S['Port'];
      Compress := jo.O['Server'].S['Compress'];
      HTTPQueueLength := jo.O['Server'].i['HTTPQueueLength'];
      ChildThreadCount := jo.O['Server'].i['ChildThreadCount'];

      if (FOwner <> nil) and (FOwner.InheritsFrom(TWebRequestHandler)) then
        FReqHandler := TWebRequestHandler(FOwner)
      else
        FReqHandler := GetRequestHandler;
      FRoot := Root;
      FHttpServer := THttpApiServer.Create(False);
      FHttpServer.AddUrl(StringTOUTF8(FRoot), StringTOUTF8(FPort), False, '+', true);
      if UpperCase(Compress) = UpperCase('deflate') then
        FHttpServer.RegisterCompress(CompressDeflate)
      else if UpperCase(Compress) = UpperCase('gzip') then
        FHttpServer.RegisterCompress(CompressGZip);
      FHttpServer.OnRequest := Process;
      FHttpServer.HTTPQueueLength := HTTPQueueLength;
      FHttpServer.Clone(ChildThreadCount);
      FActive := true;
    except
      on E: Exception do
      begin
        log(E.Message);
      end;
    end;
  end;
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

