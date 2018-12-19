program DelphiMVC;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  wnMain in '..\Module\wnMain.pas' {Main},
  WebModule in '..\Module\WebModule.pas' {WM: TWebModule},
  wnDM in '..\Module\wnDM.pas' {DM: TDataModule},
  BaseController in '..\Config\BaseController.pas',
  DBMySql in '..\Common\DBMySql.pas',
  Page in '..\Common\Page.pas',
  Roule in '..\Common\Roule.pas',
  RouleItem in '..\Common\RouleItem.pas',
  superobject in '..\Common\superobject.pas',
  ThSessionClear in '..\Common\ThSessionClear.pas',
  View in '..\Common\View.pas',
  uConfig in '..\Config\uConfig.pas',
  uRouleMap in '..\Config\uRouleMap.pas',
  uTableMap in '..\Config\uTableMap.pas',
  Command in '..\Common\Command.pas',
  SynHTTPWebBrokerBridge in '..\Syn\SynHTTPWebBrokerBridge.pas',
  SynWebApp in '..\Syn\SynWebApp.pas',
  SynWebEnv in '..\Syn\SynWebEnv.pas',
  SynWebReqRes in '..\Syn\SynWebReqRes.pas',
  SynWebServer in '..\Syn\SynWebServer.pas',
  SynWebUtils in '..\Syn\SynWebUtils.pas',
  DBSQLite in '..\Common\DBSQLite.pas',
  DBBase in '..\Common\DBBase.pas',
  DBMSSQL in '..\Common\DBMSSQL.pas',
  DBMSSQL12 in '..\Common\DBMSSQL12.pas',
  DBOracle in '..\Common\DBOracle.pas',
  HTMLParser in '..\Common\HTMLParser.pas',
  CaiWuController in '..\Controller\CaiWuController.pas',
  FirstController in '..\Controller\FirstController.pas',
  IndexController in '..\Controller\IndexController.pas',
  KuCunController in '..\Controller\KuCunController.pas',
  LoginController in '..\Controller\LoginController.pas',
  MainController in '..\Controller\MainController.pas',
  UsersController in '..\Controller\UsersController.pas',
  XiaoShouController in '..\Controller\XiaoShouController.pas',
  SessionList in '..\Common\SessionList.pas',
  DES in '..\Common\DES.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.Title:='DelphiMVC';
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
