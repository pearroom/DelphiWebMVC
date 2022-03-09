unit MVC.Net;

interface

uses
  System.SysUtils, System.Classes, System.Net.URLClient, Vcl.Forms,
  System.Generics.Collections, System.DateUtils, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.Mime, IdHashSHA;

const
  SessionKey = '__guid_session';


type
  INet = interface
    function Post(url, params: string): string;
    function PostMedia(url, filepath: string): string;
    function Get(url: string): string;
  end;

  TNet = class(TInterfacedObject, INet)
  public
    Cookie: string;
    function Post(url, params: string): string;
    function PostMedia(url, filepath: string): string;
    function Get(url: string): string;

  end;

  //此类为异步访问类
  TNetMethod = (sGet, sPost, sPostFile, sNone);

  TRetData = record
    FSessionID: string;
    FData: string;
  end;

  TURLData = record
    FSessionID: string;
    FURL: string;
    FFileName: string;
    FPostParams: string;
    FMethod: TNetMethod;
  end;

  TRetMethod = reference to procedure(RetVal: TRetData);

  TNetSyn = class(TThread)
    FRetMethod: TRetMethod;
    FCookie: string;
    FUrl: string;
    FFileName: string;
    FPostParam: string;
    HttpType: string;
  protected
    procedure Execute; override;
  public
    procedure SynRun;
    constructor Create(sUrlData: TURLData; RetMethod: TRetMethod);
    destructor Destroy; override;
  end;

function IINet: INet;

implementation

function IINet: INet;
begin
  result := TNet.create as INet;
end;

function TNet.Post(url: string; params: string): string;
var
  http: TNetHTTPClient;
  PostParm: TStringStream;
  html: TStringStream;
  ret: string;
  request: IHTTPResponse;
  cook: TCookie;
  head: TNetHeaders;
  head1: TNameValuePair;
begin
  ret := '';
  if Trim(url) <> '' then
  begin
    http := TNetHTTPClient.Create(nil);
    html := TStringStream.Create('', TEncoding.UTF8);
    PostParm := TStringStream.Create(params, TEncoding.UTF8);
    try

      http.UserAgent := 'User-Agent:Mozilla/4.0(compatible;MSIE7.0;WindowsNT5.1;360SE)';
      try
        if Cookie <> '' then
        begin
          head1.Name := 'Cookie';
          head1.Value := SessionKey + '=' + Cookie;
          SetLength(head, 1);
          head[0] := head1;
          request := http.Post(url, PostParm, html, head);

        end
        else
          request := http.Post(url, PostParm, html);
        Cookie := '';
        for cook in request.Cookies do
        begin
          if cook.Name = SessionKey then
          begin
            Cookie := cook.Value;
            break;
          end;
        end;
        ret := (html.DataString);
      except
        ret := '';
      end;
    finally
      PostParm.Free;
      html.Clear;
      FreeAndNil(html);
      FreeAndNil(http);
    end;
  end;
  Result := ret;
end;

function TNet.PostMedia(url, filepath: string): string;
var
  http: TNetHTTPClient;
  req: TMultipartFormData;
  html: TStringStream;
  ret: string;
  request: IHTTPResponse;
  cook: TCookie;
  head: TNetHeaders;
  head1: TNameValuePair;
begin
  ret := '';
  if Trim(url) <> '' then
  begin
    http := TNetHTTPClient.Create(nil);
    html := TStringStream.Create('', TEncoding.UTF8);
    req := TMultipartFormData.Create();
    try

      req.AddFile(ExtractFileName(filepath), filepath);
      http.UserAgent := 'User-Agent:Mozilla/4.0(compatible;MSIE7.0;WindowsNT5.1;360SE)';
      try
        http.ContentType := 'multipart/form-data';
        if Cookie <> '' then
        begin
          head1.Name := 'Cookie';
          head1.Value := SessionKey + '=' + Cookie;
          SetLength(head, 1);
          head[0] := head1;
          request := http.Post(url, req, html, head);

        end
        else
          request := http.Post(url, req, html);
        Cookie := '';
        for cook in request.Cookies do
        begin
          if cook.Name = SessionKey then
          begin
            Cookie := cook.Value;
            break;
          end;
        end;
        ret := (html.DataString);
      except
        ret := '';
      end;
    finally
      req.Free;
      html.Clear;
      FreeAndNil(html);
      FreeAndNil(http);
    end;
  end;
  Result := ret;
end;

function TNet.Get(url: string): string;
var
  http: TNetHTTPClient;
  html: TStringStream;
  ret: string;
  request: IHTTPResponse;
  cook: TCookie;
  head: TNetHeaders;
  head1: TNameValuePair;
begin
  ret := '';
  if Trim(url) <> '' then
  begin
    try
      http := TNetHTTPClient.Create(nil);
      html := TStringStream.Create('', TEncoding.UTF8);

      http.UserAgent := 'User-Agent:Mozilla/4.0(compatible;MSIE7.0;WindowsNT5.1;360SE)';
      try
        if Cookie <> '' then
        begin
          head1.Name := 'Cookie';
          head1.Value := SessionKey + '=' + Cookie;
          SetLength(head, 1);
          head[0] := head1;
          request := http.Get(url, html, head);

        end
        else
          request := http.Get(url, html);
        Cookie := '';
        for cook in request.Cookies do
        begin
          if cook.Name = SessionKey then
          begin
            Cookie := cook.Value;
            break;
          end;
        end;
        ret := (html.DataString);
      except
        ret := '';
      end;
    finally
      html.Clear;
      FreeAndNil(html);
      FreeAndNil(http);
    end;
  end;
  Result := ret;
end;

{ TNetSyn }

constructor TNetSyn.Create(sUrlData: TURLData; RetMethod: TRetMethod);
begin
  inherited Create(False);
  if sUrlData.FMethod <> sPost then
    if sUrlData.FMethod <> sPostFile then
      sUrlData.FMethod := sGet;
  self.FRetMethod := RetMethod;
  self.FUrl := sUrlData.FURL;
  if sUrlData.FMethod = sGet then
    HttpType := 'GET';
  if sUrlData.FMethod = sPost then
    HttpType := 'POST';
  if sUrlData.FMethod = sPostFile then
    HttpType := 'POSTFILE';
  FreeOnTerminate := true;
  FPostParam := sUrlData.FPostParams;
  FFileName := sUrlData.FFileName;
  FCookie := sUrlData.FSessionID;

end;

destructor TNetSyn.Destroy;
begin
  FUrl := '';
  inherited;
end;

procedure TNetSyn.Execute;
begin
  SynRun;
end;

procedure TNetSyn.SynRun;
var
  ret: TRetData;
  net: TNet;
  Cookie: string;
  s: string;

begin

  try
  //  Sleep(5000);
    net := TNet.Create;
    try
      net.Cookie := FCookie;
      if HttpType.ToUpper = 'GET' then
        s := net.Get(FUrl);
      if HttpType.ToUpper = 'POST' then
        s := net.Post(FUrl, FPostParam);
      if HttpType.ToUpper = 'POSTFILE' then
        s := net.PostMedia(FUrl, FFileName);
      Cookie := net.Cookie;
      ret.FSessionID := Cookie;
      ret.FData := s;
    finally
      net.Free;
    end;

    Synchronize(
      procedure
      begin

        FRetMethod(ret);
      end);
  except
    Synchronize(
      procedure
      begin
        FRetMethod(ret);
      end);
  end;

end;

end.

