program DelphiMVC;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  Winapi.Windows,
  IdHTTPWebBrokerBridge,
  wnMain in '..\Module\wnMain.pas' {Main},
  WebModule in '..\Module\WebModule.pas' {WM: TWebModule},
  wnDM in '..\Module\wnDM.pas' {DM: TDataModule},
  uConfig in '..\Config\uConfig.pas',
  uRouleMap in '..\Config\uRouleMap.pas',
  uTableMap in '..\Config\uTableMap.pas',
  CaiWuController in '..\Controller\CaiWuController.pas',
  FirstController in '..\Controller\FirstController.pas',
  IndexController in '..\Controller\IndexController.pas',
  KuCunController in '..\Controller\KuCunController.pas',
  LoginController in '..\Controller\LoginController.pas',
  MainController in '..\Controller\MainController.pas',
  UsersController in '..\Controller\UsersController.pas',
  XiaoShouController in '..\Controller\XiaoShouController.pas',
  uInterceptor in '..\Config\uInterceptor.pas',
  UsersInterface in '..\Service\Interface\UsersInterface.pas',
  UsersService in '..\Service\UsersService.pas',
  SynWebApp in '..\Module\Syn\SynWebApp.pas',
  SynWebEnv in '..\Module\Syn\SynWebEnv.pas',
  SynWebReqRes in '..\Module\Syn\SynWebReqRes.pas',
  SynWebServer in '..\Module\Syn\SynWebServer.pas',
  SynWebUtils in '..\Module\Syn\SynWebUtils.pas',
  BaseController in '..\Module\Common\BaseController.pas',
  BaseService in '..\Module\Common\BaseService.pas',
  Command in '..\Module\Common\Command.pas',
  DES in '..\Module\Common\DES.pas',
  HTMLParser in '..\Module\Common\HTMLParser.pas',
  LogUnit in '..\Module\Common\LogUnit.pas',
  PackageManager in '..\Module\Common\PackageManager.pas',
  Page in '..\Module\Common\Page.pas',
  Roule in '..\Module\Common\Roule.pas',
  RouleItem in '..\Module\Common\RouleItem.pas',
  SessionList in '..\Module\Common\SessionList.pas',
  superobject in '..\Module\Common\superobject.pas',
  ThSessionClear in '..\Module\Common\ThSessionClear.pas',
  View in '..\Module\Common\View.pas',
  BasePackage in '..\Module\Common\BasePackage.pas',
  DBBase in '..\Module\Common\DBBase.pas',
  DBMSSQL in '..\Module\Common\DBMSSQL.pas',
  DBMSSQL12 in '..\Module\Common\DBMSSQL12.pas',
  DBMySql in '..\Module\Common\DBMySql.pas',
  DBOracle in '..\Module\Common\DBOracle.pas',
  DBSQLite in '..\Module\Common\DBSQLite.pas',
  SimpleXML in '..\Module\Common\SimpleXML.pas',
  FreeMemory in '..\Module\Common\FreeMemory.pas';

{$R *.res}
var
  hMutex: THandle;

begin
  ReportMemoryLeaksOnShutdown := DebugHook<>0;
  Application.Initialize;
  Application.Title := 'DelphiWebMVC';
  hMutex := CreateMutex(nil, false, PChar(Application.Title));
  try
    if GetLastError = Error_Already_Exists then
    begin
      Application.MessageBox(PChar(Application.Title + '已经启动'), '提示', MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON2);
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

