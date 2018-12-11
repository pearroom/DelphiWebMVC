program DelphiMVC;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  wnMain in 'Module\wnMain.pas' {Main},
  WebModule in 'Module\WebModule.pas' {WM: TWebModule},
  wnDM in 'Module\wnDM.pas' {DM: TDataModule},
  LoginAction in 'Action\LoginAction.pas',
  UsersAction in 'Action\UsersAction.pas',
  KuCunAction in 'Action\KuCunAction.pas',
  XiaoShouAction in 'Action\XiaoShouAction.pas',
  CaiWuAction in 'Action\CaiWuAction.pas',
  BaseAction in 'Config\BaseAction.pas',
  DBMySql in 'Common\DBMySql.pas',
  Page in 'Common\Page.pas',
  Roule in 'Common\Roule.pas',
  RouleItem in 'Common\RouleItem.pas',
  superobject in 'Common\superobject.pas',
  ThSessionClear in 'Common\ThSessionClear.pas',
  View in 'Common\View.pas',
  uConfig in 'Config\uConfig.pas',
  uRouleMap in 'Config\uRouleMap.pas',
  uTableMap in 'Config\uTableMap.pas',
  command in 'Common\command.pas',
  MainAction in 'Action\MainAction.pas',
  IndexAction in 'Action\IndexAction.pas',
  SynHTTPWebBrokerBridge in 'Syn\SynHTTPWebBrokerBridge.pas',
  SynWebApp in 'Syn\SynWebApp.pas',
  SynWebEnv in 'Syn\SynWebEnv.pas',
  SynWebReqRes in 'Syn\SynWebReqRes.pas',
  SynWebServer in 'Syn\SynWebServer.pas',
  SynWebUtils in 'Syn\SynWebUtils.pas',
  SessionList in 'Common\SessionList.pas',
  DBSQLite in 'Common\DBSQLite.pas',
  DBBase in 'Common\DBBase.pas',
  DBMSSQL in 'Common\DBMSSQL.pas',
  DBMSSQL12 in 'Common\DBMSSQL12.pas',
  DBOracle in 'Common\DBOracle.pas',
  HTMLParser in 'Common\HTMLParser.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.Title:='DelphiMVC';
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
