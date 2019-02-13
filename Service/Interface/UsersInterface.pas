unit UsersInterface;

interface

uses
  superobject;

type
  IUsersInterface = interface
    function checkuser(map: ISuperObject): ISuperObject;
    function check(map: ISuperObject): ISuperObject;
    function getAlldata(map: ISuperObject): ISuperObject;
  end;

implementation

end.

