unit IndexController;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject, View,
  BaseController;
type
  TIndexController = class(TBaseController)
  public
    procedure Index();
  end;
implementation

{ TIndexController }

procedure TIndexController.Index;
begin
  with View do
  begin
    Redirect('login','index');

  end;
end;

end.

