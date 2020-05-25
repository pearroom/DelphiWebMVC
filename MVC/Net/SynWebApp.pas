{ *************************************************************************** }
{  SynWebApp.pas is the 4th file of SynBroker Project                         }
{  by c5soft@189.cn  Version 0.9.1.0  2018-6-2                                }
{ *************************************************************************** }

{$DENYPACKAGEUNIT}

unit SynWebApp;

interface

uses
  Classes, SysUtils, WebBroker, HTTPApp, SynCommons, SynCrtSock, SynWebServer,
  SynWebConfig;

var
  AppOpen: boolean;

type
  TSynWebApplication = class(TWebApplication)
  private
    fServer: TSynWebServer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure InitApplication;

implementation

uses
  MVC.LogUnit;

{ TSynWebApplication }

constructor TSynWebApplication.Create(AOwner: TComponent);
begin
  inherited;
  AppOpen := False;
  AppRun := False;
  AppClose := false;
 // self.MaxConnections := -1;
 // self.CacheConnections := true;

  TThread.CreateAnonymousThread(
    procedure
    begin
      while (True) do
      begin
        if AppClose then
          break;
        sleep(10);
        if AppOpen then
        begin
          if AppRun then
          begin
            fServer := TSynWebServer.Create(Self);
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

destructor TSynWebApplication.Destroy;
begin
  fServer.Free;
  inherited;
end;

procedure InitApplication;
begin
  Application := TSynWebApplication.Create(nil);
end;

initialization


end.

