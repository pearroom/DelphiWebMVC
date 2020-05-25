{ *************************************************************************** }
{  SynWebReqRes.pas is the 3rd file of SynBroker Project                      }
{  by c5soft@189.cn  Version 0.9.2.0  2018-6-7                                }
{ *************************************************************************** }

unit CrossWebServer;

interface

uses
  SysUtils, Classes, IniFiles, HTTPApp, WebBroker, Contnrs, WebReq,
  CrossWebReqRes, CrossWebEnv, Rtti, Net.CrossHttpServer, Net.CrossHttpParams,
  Net.CrossSocket.Base, SynWebConfig, Web.HTTPProd, Web.ReqMulti, MVC.LogUnit,MVC.Page;

var
  _LContext: TRttiContext;

type
  TCrossWebRequestHandler = class(TWebRequestHandler);

  TCrossWebServer = class
  private
    FOwner: TObject;
    FIniFile: TIniFile;

//    FActive: Boolean;
    FRoot, FPort: string;
    FReqHandler: TWebRequestHandler;
    procedure ONCrossHttpRequest(Sender: TObject; ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse; var AHandled: Boolean);
    function WebBrokerDispatch(const AEnv: TCrossWebEnv): Boolean;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  protected
    FHttpServer: ICrossHttpServer;
  public
    procedure Start();
    property Active: Boolean read GetActive write SetActive;
    property Port: string read FPort;
    constructor Create(AOwner: TComponent = nil);
    destructor Destroy; override;
  end;

  TWebCrossHttpServer = class(TCrossHttpServer)
  protected
    procedure TriggerPostDataBegin(AConnection: ICrossHttpConnection); override;
    procedure TriggerPostData(AConnection: ICrossHttpConnection; const ABuf: Pointer; ALen: Integer); override;
  end;

implementation

uses
  MVC.Command, MVC.Config;

var
  RequestHandler: TWebRequestHandler = nil;

function GetRequestHandler: TWebRequestHandler;
begin
  if RequestHandler = nil then
    RequestHandler := TCrossWebRequestHandler.Create(nil);
  Result := RequestHandler;
end;

{ TCrossWebServer }

constructor TCrossWebServer.Create(AOwner: TComponent);
var
  Compress: string;
  HTTPQueueLength, ChildThreadCount: integer;
begin
  inherited Create;
  FOwner := AOwner;
  _LContext := TRttiContext.Create;
  begin
    try
      FPort := syn_Port;
      Compress := syn_Compress;
      HTTPQueueLength := syn_HTTPQueueLength;
      ChildThreadCount := syn_ChildThreadCount;

      if (FOwner <> nil) and (FOwner.InheritsFrom(TWebRequestHandler)) then
        FReqHandler := TWebRequestHandler(FOwner)
      else
        FReqHandler := GetRequestHandler;

      FRoot := '';
      FHttpServer := TWebCrossHttpServer.Create(ChildThreadCount);
      FHttpServer.Addr := IPv4v6_ALL;
      FHttpServer.Port := StrToIntDef(FPort, 8080);
      if UpperCase(Compress) = UpperCase('deflate') then
        FHttpServer.Compressible := True
      else if UpperCase(Compress) = UpperCase('gzip') then
        FHttpServer.Compressible := True
      else
      begin
        FHttpServer.Compressible := False;
      end;
      FHttpServer.OnRequest := ONCrossHttpRequest;
      FHttpServer.Active := True;
	 {$IFDEF CONSOLE}
      Writeln('StartServer Port:' + FHttpServer.Port.ToString);
	 {$ENDIF}
    except
      on E: Exception do
      begin
        //log(E.Message);
      end;
    end;
  end;
end;

destructor TCrossWebServer.Destroy;
begin
  if FHttpServer.Active then
  begin
    FHttpServer.Active := False;
  end;
  _LContext.Free;
  FIniFile.Free;
  inherited;
end;

function TCrossWebServer.GetActive: Boolean;
begin
  Result := FHttpServer.Active;
end;

procedure TCrossWebServer.ONCrossHttpRequest(Sender: TObject; ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse; var AHandled: Boolean);
var
  LEnv: TCrossWebEnv;
begin

  LEnv := TCrossWebEnv.Create(ARequest, AResponse);
  try
    if WebBrokerDispatch(LEnv) then
      AResponse.StatusCode := LEnv.StatusCode
    else
      AResponse.StatusCode := 500;
  finally
    LEnv.Free;
  end;
end;

procedure TCrossWebServer.SetActive(const Value: Boolean);
begin
  FHttpServer.Active := Value;
end;

procedure TCrossWebServer.Start;
begin
  FHttpServer.Active := True;
end;

function TCrossWebServer.WebBrokerDispatch(const AEnv: TCrossWebEnv): Boolean;
var
  HTTPRequest: TCrossWebRequest;
  HTTPResponse: TCrossWebResponse;
  Handled: Boolean;
  s: string;
  page: Tpage;
begin
  HTTPRequest := TCrossWebRequest.Create(AEnv);
  try
    HTTPResponse := TCrossWebResponse.Create(HTTPRequest);
    try
      try
        OpenRoute(HTTPRequest, HTTPResponse, _RouteMap, Handled);
        Result := Handled;
      except
        on e: Exception do
        begin
          log(HTTPRequest.PathInfo + ':' + e.Message);
          s := '<html><body><div style="text-align: left;"><div><h1> Error 500 </h1></div>';
          s := s + '<hr><div>' + e.Message + '</div></div></body></html>';
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
          HTTPResponse.ContentType := 'text/html; charset=' + Config.document_charset;
          HTTPResponse.Content := s;
          HTTPResponse.SendResponse;
          Result := false;
        end;

      end;
    //  Result := TCrossWebRequestHandler(FReqHandler).HandleRequest(HTTPRequest, HTTPResponse);
    finally
      HTTPResponse.Free;
    end;
  finally
    HTTPRequest.Free;
  end;
end;

{ TWebCrossHttpServer }

procedure TWebCrossHttpServer.TriggerPostData(AConnection: ICrossHttpConnection; const ABuf: Pointer; ALen: Integer);
var
  LRequest: TCrossHttpRequest;
begin
  LRequest := AConnection.Request as TCrossHttpRequest;
  (LRequest.Body as TBytesStream).Write(ABuf^, ALen);
  if Assigned(OnPostData) then
    OnPostData(Self, AConnection, ABuf, ALen);
end;

procedure TWebCrossHttpServer.TriggerPostDataBegin(AConnection: ICrossHttpConnection);
var
  LRequest: TCrossHttpRequest;
  LMultiPart: THttpMultiPartFormData;
  LStream: TStream;
  LType: TRttiType;
  LField: TRttiField;
  LBody: TObject;
begin
  LRequest := AConnection.Request as TCrossHttpRequest;

  LType := _LContext.GetType(TCrossHttpRequest);
  LField := LType.GetField('FBody');
  LBody := LField.GetValue(LRequest).AsObject;
  FreeAndNil(LBody);
  LStream := TBytesStream.Create(nil);
  LField.SetValue(LRequest, LStream);
  if Assigned(OnPostDataBegin) then
    OnPostDataBegin(Self, AConnection);
end;

initialization
  WebReq.WebRequestHandlerProc := GetRequestHandler;

finalization
  if RequestHandler <> nil then
    FreeAndNil(RequestHandler);

end.

