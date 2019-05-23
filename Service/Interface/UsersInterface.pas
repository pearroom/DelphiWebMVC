unit UsersInterface;

interface

uses
  superobject,MHashMap;

type
  IUsersInterface = interface
    function checkuser(map: ISuperObject): ISuperObject;
    function getdata(var con: integer; map: ISuperObject): ISuperObject;
    function save(map: ISuperObject): boolean;
    function delById(id: string): boolean;
  end;



implementation

end.

