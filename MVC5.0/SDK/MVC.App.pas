{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2022-2 苏兴迎(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.App;
{$I mvc.inc}

interface

uses
  System.SysUtils, {$IFDEF SERVICE} Vcl.SvcMgr,  {$ELSE} Vcl.Forms, {$ENDIF}
  System.Variants, System.Rtti, System.Classes, Web.HTTPApp, System.DateUtils,
  MVC.LogUnit, System.StrUtils, System.Generics.Collections, IdURI, Web.WebReq,
  Winapi.Windows, MVC.Config, MVC.HttpMmt, MVC.WINServer, MVC.Route, MVC.JSON,
  mvc.Net;

const
  SECURITY_NT_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (
    Value: (0, 0, 0, 0, 0, 5)
  );
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;


type
  TMVCWinService = class
  private

  public
    FSName: string;
    FDisplayName: string;
    FServiceType: TMServiceType;
    FStartType: TMStartType;
    {$IFDEF SERVICE}
    procedure Init;
    {$ENDIF}
  end;

  TMVCApp = class
  private

  public
    Service: TMVCWinService;
    procedure Run(password: string = '');
    function Command: boolean;
    constructor Create;
    destructor Destroy; override;
  end;

var
  MVCApp: TMVCApp;


function StartServer(): string;

procedure CloseServer();

procedure StartWin;

procedure StartWinServer();

implementation

uses
  MVC.Main;

function IsAdmin: Boolean;   //判断当前是否以管理员权限运行
var
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  psidAdministrators: PSID;
  x: Integer;
  bSuccess: BOOL;
begin
  Result := False;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken);
  end;
  if bSuccess then
  begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups, ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then
    begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, psidAdministrators);
      {$R-}
      for x := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then
        begin
          Result := True;
          Break;
        end;
      {$R+}
      FreeSid(psidAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
end;

procedure StartWinServer();
begin
  {$IFDEF SERVICE}
    //以windows服务形式运行
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TWINService, WINService);
  WINService.setParam(MVCApp.Service.FSName, MVCApp.Service.FDisplayName, MVCApp.Service.FServiceType, MVCApp.Service.FStartType);
  Application.Run;

  {$ELSE}
  log('没有声明【SERVICE】编译条件');
  Application.MessageBox('服务生成失败,没有声明【SERVICE】编译条件', '提示', MB_OK);
  {$ENDIF}

end;

procedure StartWin;
var
  hMutex: THandle;
begin
{$IFNDEF SERVICE}
  if Config.isOver then
  begin
    Application.Title := Config.AppTitle;
    hMutex := CreateMutex(nil, false, PChar(Config.AppTitle));
    try
      if GetLastError = Error_Already_Exists then
      begin
        Log(Config.AppTitle + '已启动');
        Application.MessageBox(PChar(Config.AppTitle + '已启动'), '提示', MB_OK);

      end
      else
      begin
        if not Assigned(MVCMain) then
        begin
          Application.Initialize;
          Application.CreateForm(TMVCMain, MVCMain);
          Application.Run;
        end;
      end;
    finally
      ReleaseMutex(hMutex);
    end;
  end
  else
  begin
    Log(Config.AppTitle + '配置文件读取失败');
    Application.MessageBox(PChar(Config.AppTitle + '配置文件读取失败'), '提示', MB_OK);
  end;
  {$ENDIF}
end;

function StartServer(): string;
begin
  Result := '-1';
  if Assigned(Config) then
  begin
    if (Config.initParams) then
    begin
      httpServer := THTTPServer.Create;
      httpServer.Start;
      if httpServer.Action then
        Result := Config.Port;
    end;
  end;
end;

procedure CloseServer();
begin
  httpServer.Stop;
  httpServer.Free;
end;

{ TMVC }

function TMVCApp.Command: boolean;
var
  LResponse: string;
begin
  Writeln('input ''q:'' Close Server');
  readln(LResponse);
  if LResponse.ToLower = 'q:' then
    Result := False
  else
    Result := true;
end;

constructor TMVCApp.Create;
begin
  Service := TMVCWinService.Create;
end;

destructor TMVCApp.Destroy;
begin
  Service.Free;
  inherited;
end;

procedure TMVCApp.Run(password: string);
begin
  initRoute;
  Config.setPassword(password);
  ReportMemoryLeaksOnShutdown := True;

  /////////////////////////////////////////////////////////
  {$IFDEF CONSOLE}

  if Config.initParams then
  begin
    SetConsoleTitle(PChar(Config.AppTitle));
    var url: string := 'http://localhost:' + Config.Port;
    Writeln(url);
    StartServer();
    while True do
    begin
      if not Command then
        Break;

    end;
    CloseServer();

  end
  else
  begin
    WriteLog('配置文件读取失败，请检查文件格式');
  end;
  {$ELSE}
  {$IFDEF SERVICE}
  if Config.initParams then
  begin
    MVCApp.Service.Init;
    if (Service <> nil) and (Service.FSName = '') then
    begin
      WriteLog('启动失败，请配置服务参数');
    end
    else
      StartWinServer;
  end
  else
  begin
    WriteLog('配置文件读取失败，请检查文件格式');
  end;
  {$ELSE}
  if IsAdmin then
  begin

    if Config.initParams then
    begin
      StartWin;
    end
    else
    begin
      WriteLog('配置文件读取失败，请检查文件格式');
    end;
  end
  else
  begin
    Application.MessageBox('启动失败,请使用管理员权限运行！', '提示', MB_OK);
    WriteLog('启动失败,请使用管理员权限运行！');
  end;
  {$ENDIF}
  {$ENDIF}
end;



{ TWinService }
{$IFDEF SERVICE}
procedure TMVCWinService.Init;
var
  ServiceT, StartT: string;
  cof: IJObject;
begin

  if config.WinServiceConfig <> '' then
  begin
    cof := IIjobject(Config.WinServiceConfig);
    FSName := cof.GetS('Name');
    FDisplayName := cof.GetS('DisplayName');
    ServiceT := cof.GetS('ServiceType');
    StartT := cof.GetS('StartType');

    if ServiceT = 'stWin32' then
      FServiceType := TMServiceType.stWin32;
    if ServiceT = 'stDevice' then
      FServiceType := TMServiceType.stDevice;
    if ServiceT = 'stFileSystem' then
      FServiceType := TMServiceType.stFileSystem;

    if StartT = 'stBoot' then
      FStartType := TStartType.stBoot;
    if StartT = 'stSystem' then
      FStartType := TStartType.stSystem;
    if StartT = 'stAuto' then
      FStartType := TStartType.stAuto;
    if StartT = 'stManual' then
      FStartType := TStartType.stManual;
  end;
end;
{$ENDIF}

initialization
  MVCApp := TMVCApp.Create;


finalization
  MVCApp.Free;

end.

