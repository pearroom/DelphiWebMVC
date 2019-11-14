{*******************************************************}
{                                                       }
{       苏兴迎                                          }
{       E-Mail:pearroom@yeah.net                        }
{       管理员权限启动delphi,管理员权限启动部署程序     }
{                                                       }
{*******************************************************}

program WebMVC;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  uRouleMap in '..\Config\uRouleMap.pas',
  uTableMap in '..\Config\uTableMap.pas',
  uInterceptor in '..\Config\uInterceptor.pas',
  uDBConfig in '..\Config\uDBConfig.pas',
  uGlobal in '..\Config\uGlobal.pas',
  uPlugin in '..\Config\uPlugin.pas',
  SynWebApp in '..\MVC\Net\SynWebApp.pas',
  SynWebConfig in '..\MVC\Net\SynWebConfig.pas',
  SynWebEnv in '..\MVC\Net\SynWebEnv.pas',
  SynWebReqRes in '..\MVC\Net\SynWebReqRes.pas',
  SynWebServer in '..\MVC\Net\SynWebServer.pas',
  SynWebUtils in '..\MVC\Net\SynWebUtils.pas',
  IndexController in '..\Controller\IndexController.pas',
  MainController in '..\Controller\MainController.pas',
  PayController in '..\Controller\PayController.pas',
  RoleController in '..\Controller\RoleController.pas',
  UserController in '..\Controller\UserController.pas',
  VIPController in '..\Controller\VIPController.pas',
  Plugin.Layui in '..\Plugin\Plugin.Layui.pas',
  Plugin.Tool in '..\Plugin\Plugin.Tool.pas',
  RoleService in '..\Service\RoleService.pas',
  UsersService in '..\Service\UsersService.pas',
  MVC.ActionClear in '..\MVC\Common\MVC.ActionClear.pas',
  MVC.ActionList in '..\MVC\Common\MVC.ActionList.pas',
  MVC.BaseController in '..\MVC\Common\MVC.BaseController.pas',
  MVC.BaseInterceptor in '..\MVC\Common\MVC.BaseInterceptor.pas',
  MVC.BasePackage in '..\MVC\Common\MVC.BasePackage.pas',
  MVC.BaseService in '..\MVC\Common\MVC.BaseService.pas',
  MVC.Command in '..\MVC\Common\MVC.Command.pas',
  MVC.Config in '..\MVC\Common\MVC.Config.pas',
  MVC.DBBase in '..\MVC\Common\MVC.DBBase.pas',
  MVC.DBFirebird in '..\MVC\Common\MVC.DBFirebird.pas',
  MVC.DBMSSQL in '..\MVC\Common\MVC.DBMSSQL.pas',
  MVC.DBMSSQL08 in '..\MVC\Common\MVC.DBMSSQL08.pas',
  MVC.DBMSSQL12 in '..\MVC\Common\MVC.DBMSSQL12.pas',
  MVC.DBMySql in '..\MVC\Common\MVC.DBMySql.pas',
  MVC.DBOracle in '..\MVC\Common\MVC.DBOracle.pas',
  MVC.DBPool in '..\MVC\Common\MVC.DBPool.pas',
  MVC.DBPoolClear in '..\MVC\Common\MVC.DBPoolClear.pas',
  MVC.DBPoolList in '..\MVC\Common\MVC.DBPoolList.pas',
  MVC.DBSQLite in '..\MVC\Common\MVC.DBSQLite.pas',
  MVC.DES in '..\MVC\Common\MVC.DES.pas',
  MVC.DM in '..\MVC\Common\MVC.DM.pas' {MVCDM: TDataModule},
  MVC.HTMLParser in '..\MVC\Common\MVC.HTMLParser.pas',
  MVC.Interceptor in '..\MVC\Common\MVC.Interceptor.pas',
  MVC.LogUnit in '..\MVC\Common\MVC.LogUnit.pas',
  MVC.Main in '..\MVC\Common\MVC.Main.pas' {MVCMain},
  MVC.PackageManager in '..\MVC\Common\MVC.PackageManager.pas',
  MVC.Page in '..\MVC\Common\MVC.Page.pas',
  MVC.PageCache in '..\MVC\Common\MVC.PageCache.pas',
  MVC.RedisClear in '..\MVC\Common\MVC.RedisClear.pas',
  MVC.RedisList in '..\MVC\Common\MVC.RedisList.pas',
  MVC.RedisM in '..\MVC\Common\MVC.RedisM.pas',
  MVC.Roule in '..\MVC\Common\MVC.Roule.pas',
  MVC.RouleItem in '..\MVC\Common\MVC.RouleItem.pas',
  MVC.SessionList in '..\MVC\Common\MVC.SessionList.pas',
  MVC.ThSessionClear in '..\MVC\Common\MVC.ThSessionClear.pas',
  MVC.View in '..\MVC\Common\MVC.View.pas',
  MVC.Web in '..\MVC\Common\MVC.Web.pas' {MVCWeb: TWebModule},
  XSuperJSON in '..\MVC\Common\XSuperJSON.pas',
  XSuperObject in '..\MVC\Common\XSuperObject.pas';

{$R *.res}

begin
  Config.password_key := '';   //配置文件解密秘钥
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.Title := 'WebMVC';
  _MVCFun.Run(Application.Title);
end.

