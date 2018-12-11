unit FirstAction;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject,
  BaseAction;

type
  TFirstAction = class(TBaseAction)
  public
    procedure index();

  end;

implementation

{ TFirstAction }



procedure TFirstAction.index;
begin
  with View do
  begin
    setAttr('name',SessionValue('name'));
    ShowHTML('first');
  end;
end;


end.

