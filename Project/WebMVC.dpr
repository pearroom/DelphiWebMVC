{*******************************************************}
{                                                       }
{       苏兴迎                                         }
{                                                       }
{       管理权限启动delphi ，部署exe管理员启动          }
{                                                       }
{*******************************************************}

program WebMVC;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  Winapi.Windows,
  wnMain in '..\Module\wnMain.pas' {Main},
  wnWeb in '..\Module\wnWeb.pas' {WM: TWebModule},
  wnDM in '..\Module\wnDM.pas' {DM: TDataModule},
  uConfig in '..\Config\uConfig.pas',
  uRouleMap in '..\Config\uRouleMap.pas',
  uTableMap in '..\Config\uTableMap.pas',
  uInterceptor in '..\Config\uInterceptor.pas',
  BaseController in '..\Module\Common\BaseController.pas',
  command in '..\Module\Common\command.pas',
  DBBase in '..\Module\Common\DBBase.pas',
  DBMSSQL in '..\Module\Common\DBMSSQL.pas',
  DBMSSQL12 in '..\Module\Common\DBMSSQL12.pas',
  DBMySql in '..\Module\Common\DBMySql.pas',
  DBOracle in '..\Module\Common\DBOracle.pas',
  DBSQLite in '..\Module\Common\DBSQLite.pas',
  DES in '..\Module\Common\DES.pas',
  HTMLParser in '..\Module\Common\HTMLParser.pas',
  Page in '..\Module\Common\Page.pas',
  Roule in '..\Module\Common\Roule.pas',
  RouleItem in '..\Module\Common\RouleItem.pas',
  SessionList in '..\Module\Common\SessionList.pas',
  superobject in '..\Module\Common\superobject.pas',
  ThSessionClear in '..\Module\Common\ThSessionClear.pas',
  View in '..\Module\Common\View.pas',
  BaseService in '..\Module\Common\BaseService.pas',
  FreeMemory in '..\Module\Common\FreeMemory.pas',
  LogUnit in '..\Module\Common\LogUnit.pas',
  IndexController in '..\Controller\IndexController.pas',
  MainController in '..\Controller\MainController.pas',
  RoleController in '..\Controller\RoleController.pas',
  UserController in '..\Controller\UserController.pas',
  RoleService in '..\Service\RoleService.pas',
  UsersService in '..\Service\UsersService.pas',
  RoleInterface in '..\Service\Interface\RoleInterface.pas',
  UsersInterface in '..\Service\Interface\UsersInterface.pas',
  RedisM in '..\Module\Common\RedisM.pas',
  RedisList in '..\Module\Common\RedisList.pas',
  RedisClear in '..\Module\Common\RedisClear.pas',
  uDBConfig in '..\Config\uDBConfig.pas',
  DBMSSQL08 in '..\Module\Common\DBMSSQL08.pas',
  uGlobal in '..\Config\uGlobal.pas',
  VIPController in '..\Controller\VIPController.pas',
  PayController in '..\Controller\PayController.pas',
  uPlugin in '..\Config\uPlugin.pas',
  MHashMap in '..\Module\Common\MHashMap.pas',
  SynWebApp in '..\Module\Net\SynWebApp.pas',
  SynWebConfig in '..\Module\Net\SynWebConfig.pas',
  SynWebEnv in '..\Module\Net\SynWebEnv.pas',
  SynWebReqRes in '..\Module\Net\SynWebReqRes.pas',
  SynWebServer in '..\Module\Net\SynWebServer.pas',
  SynWebUtils in '..\Module\Net\SynWebUtils.pas';

{$R *.res}
var
  hMutex: THandle;

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.Title := 'WebMVC';
  hMutex := CreateMutex(nil, false, PChar(Application.Title));
  try
    if GetLastError = Error_Already_Exists then
    begin
      Application.MessageBox(PChar(Application.Title + '已经启动'),
        '提示', MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON2);
      Exit;
    end;
  finally
    ReleaseMutex(hMutex);
  end;

  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.

