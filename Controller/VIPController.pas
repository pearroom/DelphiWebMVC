unit VIPController;

interface

uses
  System.SysUtils, System.Classes, MVC.BaseController;

type
  TVIPController = class(TBaseController)
    procedure index;
  end;

implementation

{ TVIPController }

procedure TVIPController.index;
begin
  with view do
  begin
    ShowHTML('index');
  end;
end;

end.

