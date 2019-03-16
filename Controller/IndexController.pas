unit IndexController;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject, View,
  BaseController;

type
  TIndexController = class(TBaseController)
  public
    procedure Index();
    procedure main;
  end;

implementation

uses
  UsersInterface, UsersService;

{ TIndexController }
var user_service:IUsersInterface;

procedure TIndexController.Index;
begin
  user_service:=TUsersService.Create(view.Db);
  with View do
  begin
  //  user_service.checkuser(null);
    ShowHTML('index');
  end;
end;

procedure TIndexController.main;
begin
  view.ShowHTML('main');
end;

end.

