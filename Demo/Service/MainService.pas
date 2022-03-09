unit MainService;

interface

uses
  System.SysUtils, System.Classes, MVC.JSON, MVC.DataSet, MVC.Service, mvc.DB;

type
  TMainService = record
    function getMenu(): IDataSet;
  end;

implementation

uses
  TableMap;
{ TIndexService }

function TMainService.getMenu(): IDataSet;
var
  sql: ISQL;
begin
  var conn: IConn := IIConn;
  sql := IISQL(Tb_dict_menu);
  sql.Order('s_id');
  Result := conn.Db.Find(sql);
end;

end.

