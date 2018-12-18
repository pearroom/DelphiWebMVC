unit XiaoShouController;

interface
uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject, View,
  BaseController;
type
  TXiaoShouController = class(TBaseController)
  public
    procedure Index();
  end;
implementation

uses
  uTableMap;

{ TXiaoShouController }

procedure TXiaoShouController.Index;
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
