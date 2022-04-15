program WebDemo;
{$I mvc.inc}

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

{$R *.res}

begin
  MVCApp.Run();
end.

