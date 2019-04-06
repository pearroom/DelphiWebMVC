unit RoleInterface;

interface

uses
  superobject;

type
  IRoleInterface = interface
    function getdata(var con: integer; map: ISuperObject): ISuperObject;
    function save(map: ISuperObject): Boolean;
    function del(id: string): Boolean;
    function getAlldata(map: ISuperObject = nil): ISuperObject;
    function getMenu(var con: integer; map: ISuperObject): ISuperObject;
    function getSelMenu(var con: integer; map: ISuperObject): ISuperObject;
    function addmenu(roleid: string; menuid: string): Boolean;
    function delmenu(roleid: string; menuid: string): boolean;
  end;



implementation

end.

