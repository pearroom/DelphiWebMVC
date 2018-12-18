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

{ TFirstAction }



procedure TMainController.index;
begin
  with View do
  begin
    setAttr('name',SessionGet('name'));
    ShowHTML('main');
  end;
end;


end.

