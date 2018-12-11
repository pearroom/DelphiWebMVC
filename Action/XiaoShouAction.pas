unit XiaoShouAction;

interface
uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject, View,
  BaseAction;
type
  TXiaoShouAction = class(TBaseAction)
  public
    procedure Index();
  end;
implementation

uses
  uTableMap;

{ TXiaoShouAction }

procedure TXiaoShouAction.Index;
var
  list:ISuperObject;
begin
  with View do
  begin
    list:=Db.Find(tb_users,'limit 200');
    setAttr('ls',list.AsString);
    setAttr('key1','1');
    setAttr('key2','2');
    setAttr('key3','3');
    setAttr('username','admin');
    ShowHTML('index');
  end;
end;

end.
