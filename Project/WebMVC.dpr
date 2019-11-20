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
  MVC.Command,
  MVC.Config,
  uRouleMap in '..\Config\uRouleMap.pas',
  uTableMap in '..\Config\uTableMap.pas',
  uInterceptor in '..\Config\uInterceptor.pas',
  uDBConfig in '..\Config\uDBConfig.pas',
  uGlobal in '..\Config\uGlobal.pas',
  uPlugin in '..\Config\uPlugin.pas',
  IndexController in '..\Controller\IndexController.pas',
  MainController in '..\Controller\MainController.pas',
  PayController in '..\Controller\PayController.pas',
  RoleController in '..\Controller\RoleController.pas',
  UserController in '..\Controller\UserController.pas',
  VIPController in '..\Controller\VIPController.pas',
  Plugin.Layui in '..\Plugin\Plugin.Layui.pas',
  Plugin.Tool in '..\Plugin\Plugin.Tool.pas',
  RoleService in '..\Service\RoleService.pas',
  UsersService in '..\Service\UsersService.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Config.password_key := '';   //配置文件解密秘钥
  _MVCFun.Run('WebMVC');
end.

