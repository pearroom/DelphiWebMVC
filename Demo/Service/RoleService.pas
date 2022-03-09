unit RoleService;

interface

uses
  System.SysUtils, System.Classes, MVC.JSON, MVC.DataSet, MVC.Service, mvc.DB;

type
  TRoleService = record
    function getdata(): IDataSet;
  end;

implementation

uses
  TableMap;


{ TRoleService }

function TRoleService.getdata: IDataSet;
begin
  var conn: Iconn := IIConn;
  var sql: ISQL := IISQL(tb_dict_role);
  Result := conn.db.Find(sql);
end;

end.

