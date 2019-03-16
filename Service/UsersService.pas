unit UsersService;

interface

uses
  UsersInterface, uConfig, superobject, uTableMap, BaseService;

type
  TUsersService = class(TBaseService, IUsersInterface)
  public
    function checkuser(wh: ISuperObject): ISuperObject;
  end;

implementation

{ TUsersService }

function TUsersService.checkuser(wh: ISuperObject): ISuperObject;
begin
  Result := Db.FindFirst(tb_users, wh);
end;


end.

