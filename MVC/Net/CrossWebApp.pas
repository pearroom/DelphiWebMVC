{ *************************************************************************** }
{  SynWebApp.pas is the 4th file of SynBroker Project                         }
{  by c5soft@189.cn  Version 0.9.1.0  2018-6-2                                }
{ *************************************************************************** }

{$DENYPACKAGEUNIT}

unit CrossWebApp;

interface

uses
  Classes, SysUtils, WebBroker, HTTPApp, CrossWebServer, Web.HTTPProd, Web.ReqMulti,
  SynWebConfig, MVC.LogUnit;

var
  AppOpen: boolean;

type
  TCrossWebApplication = class
  private
    fServer: TCrossWebServer;
  public
    constructor Create();
    destructor Destroy; override;
  end;

procedure InitApplication;

procedure FreeApplication;

var
  CrossWebApplication: TCrossWebApplication;

implementation

{ TCrossWebApplication }

constructor TCrossWebApplication.Create();
begin
  AppOpen := False;
  AppRun := False;
  AppClose := false;
  TThread.CreateAnonymousThread(
    procedure
    begin
      while True do
      begin
        if AppClose then
          break;
        sleep(10);
        if AppOpen then
        begin
          if AppRun then
          begin
            fServer := TCrossWebServer.Create;
            break;
          end;
        end
        else
        begin
          break;
        end;
      end;
    end).Start;
end;

destructor TCrossWebApplication.Destroy;
begin
  if fServer <> nil then
    fServer.Free;
  fServer := nil;
  inherited;
end;

procedure InitApplication;
begin
  CrossWebApplication := TCrossWebApplication.Create();
end;

procedure FreeApplication;
begin
  CrossWebApplication.Free;
end;

initialization


end.

