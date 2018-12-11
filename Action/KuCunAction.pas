unit KuCunAction;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject, View,
  Soap.EncdDecd, BaseAction, System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TKuCunAction = class(TBaseAction)
  private
  public
    procedure Index;
    procedure getdata;
  end;

implementation

{ TKuCunAction }


procedure TKuCunAction.getdata;
var
  ret: string;
  m, url: string;
  http: TNetHTTPClient;
  html: TStringStream;
begin
  if isPOST then
    with view do
    begin

      m := Input('m');
      url := Input('url');

      if Trim(url) <> '' then
      begin
        http := TNetHTTPClient.Create(nil);
        html := TStringStream.Create('',TEncoding.Default);
        http.UserAgent := 'User-Agent:Mozilla/4.0(compatible;MSIE7.0;WindowsNT5.1;360SE)';
        try
          try
            if m = 'GET' then
            begin
              http.Get(url, html);
            end;

            ret := (html.DataString);
          except
            ret:='请求异常';
          end;
        finally
          http.Free;
          html.Free;
        end;
      end;
      ShowText(ret);
    end;
end;

procedure TKuCunAction.Index;
begin
  with View do
  begin
    ShowHTML('index');

  end;
end;

end.

