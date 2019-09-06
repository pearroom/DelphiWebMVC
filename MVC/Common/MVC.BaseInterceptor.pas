unit MVC.BaseInterceptor;

interface

uses
  System.SysUtils, System.Classes, MVC.Config;

type
  TBaseInterceptor = class
  public
    url: string;
    constructor Create;
  end;

implementation

constructor TBaseInterceptor.Create;
begin
  url := '/';
  if Config.__APP__.Trim <> '' then
    url := '/' + Config.__APP__ + '/';
end;

end.

