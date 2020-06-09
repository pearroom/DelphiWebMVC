{*******************************************************}
{                                                       }
{       苏兴迎                                          }
{       E-Mail:pearroom@yeah.net                        }
{       管理员权限启动delphi,管理员权限启动部署程序     }
{                                                       }
{*******************************************************}
 {
安装指南：https://my.oschina.net/delphimvc/blog/1581715
我的博客：https://my.oschina.net/delphimvc
相关视频：https://my.oschina.net/delphimvc/blog/4291418
开发手册：http://129.211.87.47/doc/help.html
讨论QQ群: 685072623
开发工具:delphi xe10.3
注意:win10系统以管理员权限运行
}
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

