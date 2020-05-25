{ *************************************************************************** }
{  SynWebApp.pas is the 4th file of SynBroker Project                         }
{  by c5soft@189.cn  Version 0.9.1.0  2018-6-2                                }
{ *************************************************************************** }

{$DENYPACKAGEUNIT}

unit CrossWebApp;

interface

uses
  Classes, SysUtils, WebBroker, HTTPApp, CrossWebServer, Web.HTTPProd,
  Web.ReqMulti, SynWebConfig, MVC.LogUnit;

var
  AppOpen: boolean;

type
  TCrossWebApplication = class(TWebApplication)
  private
    fServer: TCrossWebServer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure InitApplication;

implementation

{ TCrossWebApplication }

constructor TCrossWebApplication.Create(AOwner: TComponent);
begin
  inherited;
  AppOpen := False;
  AppRun := False;
  AppClose := false;
  //self.MaxConnections := -1;
 // self.CacheConnections := true;
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
            fServer := TCrossWebServer.Create(Self);
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
  fServer.Free;
  inherited;
end;

procedure InitApplication;
begin
  Application := TCrossWebApplication.Create(nil);
end;

initialization


end.

