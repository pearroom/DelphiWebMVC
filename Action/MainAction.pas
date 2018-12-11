unit MainAction;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject,
  BaseAction;

type
  TMainAction = class(TBaseAction)
  public
    procedure index();

  end;

implementation

{ TFirstAction }



procedure TMainAction.index;
begin
  with View do
  begin
    setAttr('name',SessionGet('name'));
    ShowHTML('main');
  end;
end;


end.

