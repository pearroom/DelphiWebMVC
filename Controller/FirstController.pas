unit FirstController;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject,
  BaseController;

type
  TFirstController = class(TBaseController)
  public
    procedure index();

  end;

implementation

{ TFirstController }



procedure TFirstController.index;
begin
  with View do
  begin
    setAttr('name',SessionGet('name'));
    ShowHTML('first');
  end;
end;


end.

