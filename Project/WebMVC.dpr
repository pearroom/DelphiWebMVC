{*******************************************************}
{                                                       }
{       苏兴迎                                          }
{       E-Mail:pearroom@yeah.net                        }
{       管理员权限启动delphi,管理员权限启动部署程序     }
{                                                       }
{*******************************************************}

program WebMVC;
{$APPTYPE GUI}
//{$APPTYPE CONSOLE}

uses
  MVC.Command,
  MVC.Config,
  IndexController in '..\Controller\IndexController.pas',
  MainController in '..\Controller\MainController.pas',
  RoleController in '..\Controller\RoleController.pas',
  UserController in '..\Controller\UserController.pas',
  RoleService in '..\Service\RoleService.pas',
  UsersService in '..\Service\UsersService.pas',
  VIPController in '..\Controller\VIPController.pas',
  PayController in '..\Controller\PayController.pas',
  Plugin.Layui in '..\Plugin\Plugin.Layui.pas',
  Plugin.Tool in '..\Plugin\Plugin.Tool.pas',
  QRCodeController in '..\Controller\QRCodeController.pas',
  JwtController in '..\Controller\JwtController.pas',
  uDBConfig in '..\Config\uDBConfig.pas',
  uGlobal in '..\Config\uGlobal.pas',
  uInterceptor in '..\Config\uInterceptor.pas',
  uPlugin in '..\Config\uPlugin.pas',
  uTableMap in '..\Config\uTableMap.pas',
  uRouteMap in '..\Config\uRouteMap.pas';

{$R *.res}
begin
  Config.password_key := '';   //配置文件解密秘钥
  _MVCFun.Run();

end.

