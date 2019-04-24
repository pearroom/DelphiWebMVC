unit uInterceptor;

interface

uses
  System.SysUtils, View, System.Classes;

type
  TInterceptor = class
    url: string;
    function execute(View: TView; error: Boolean): Boolean;
    constructor Create;
  end;

implementation

uses
  uConfig;

{ TInterceptor }

constructor TInterceptor.Create;
begin
  url := '/';
  if __APP__.Trim <> '' then
    url := '/' + __APP__ + '/';
end;

function TInterceptor.execute(View: TView; error: Boolean): Boolean;
begin
  Result := false;
  with View do
  begin
    if (SessionGet('user') = '') then
    begin
      Result := true;
      Response.Content := '<script>window.location.href=''' + url + ''';</script>';
     // Response.SendRedirect(url);
      Response.SendResponse;
    end;

  end;
end;

end.

