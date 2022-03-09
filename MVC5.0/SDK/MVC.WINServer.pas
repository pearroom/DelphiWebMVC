unit MVC.WINServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TMServiceType = Vcl.SvcMgr.TServiceType;

  TMStartType = Vcl.SvcMgr.TStartType;

  TWINService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    procedure setParam(sName, sDisplayName: string; sServiceType: TMServiceType; sStartType: TMStartType);
    { Public declarations }
  end;

var
  WINService: TWINService;


implementation

{$R *.dfm}
uses
  MVC.App;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  WINService.Controller(CtrlCode);

end;

function TWINService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TWINService.ServiceStart(Sender: TService; var Started: Boolean);
begin

  StartServer();
  Started := true;
end;

procedure TWINService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin

  CloseServer();
  Stopped := true;
end;

procedure TWINService.setParam(sName, sDisplayName: string; sServiceType: TMServiceType; sStartType: TMStartType);
begin
  Name := sName;
//  Dependencies
  DisplayName := sDisplayName;
  ServiceType := sServiceType;
  StartType := sStartType;
end;

end.

