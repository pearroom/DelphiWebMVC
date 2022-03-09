program WebDemo;
 //{$APPTYPE CONSOLE}  //控制台模式
{$I mvc.inc}
{$R *.res}

uses
  MVC.App,
  BaseController in '..\Controller\BaseController.pas',
  IndexController in '..\Controller\IndexController.pas',
  MainController in '..\Controller\MainController.pas',
  IndexService in '..\Service\IndexService.pas',
  MainService in '..\Service\MainService.pas',
  UserController in '..\Controller\UserController.pas',
  UserService in '..\Service\UserService.pas',
  RoleService in '..\Service\RoleService.pas',
  SQLMap in '..\Service\Map\SQLMap.pas',
  TableMap in '..\Service\Map\TableMap.pas',
  ServiceMap in '..\Service\Map\ServiceMap.pas';

begin
   {
    生成windows服务(注:无法在控制台模式下使用)：
    1：在Project目录mvc.inc文件中打开SERVICE开关。
    2：在config文件中设置WinService参数。
  }
  MVCApp.Run();

end.

