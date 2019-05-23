unit PayController;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseController;

type
  TPayController = class(TBaseController)
    procedure index;
  end;

implementation

{ TPayController }

procedure TPayController.index;
begin
  View.ShowHTML('index');
end;

end.

