unit uInterceptor;

interface

uses
  System.SysUtils, MVC.View, System.Classes, MVC.BaseInterceptor;

type
  TInterceptor = class(TBaseInterceptor)
  public
    function execute(View: TView; error: Boolean): Boolean;
  end;

implementation


{ TInterceptor }

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

