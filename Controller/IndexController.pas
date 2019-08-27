unit IndexController;

interface

uses
  System.SysUtils, System.Classes, XSuperObject, MVC.BaseController,
  Vcl.Imaging.jpeg, Vcl.Graphics;

type
  TIndexController = class(TBaseController)
    procedure Index;
  end;

implementation

uses
  uTableMap, XSuperJSON;


{ TIndexController }

procedure TIndexController.Index;
var
  s: string;
begin
  s := 'hello';
  view.ShowText(s);
end;

end.

