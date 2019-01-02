unit MainController;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject,
  BaseController;

type
  TMainController = class(TBaseController)
  public
    procedure index();
  end;

implementation

uses
  UsersInterface, UsersService;

{ TFirstAction }

var
  users_service: IUsersInterface;

procedure TMainController.index;
var
  ret: boolean;
begin
  with View do
  begin
    setAttr('name', SessionGet('name'));
    ShowHTML('main');
  end;
end;

end.

