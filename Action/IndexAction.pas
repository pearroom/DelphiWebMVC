unit IndexAction;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject, View,
  BaseAction;
type
  TIndexAction = class(TBaseAction)
  public
    procedure Index();
  end;
implementation

{ TIndexAction }

procedure TIndexAction.Index;
begin
  with View do
  begin
    Redirect('login','index');

  end;
end;

end.

