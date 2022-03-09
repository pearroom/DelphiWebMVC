unit ServiceMap;

interface

uses
  MainService, RoleService, UserService, IndexService;

type
  TServiceMap = record
  public
    Index: TIndexService;
    Main: TMainService;
    Role: TRoleService;
    User: TUserService;
  end;

implementation

end.

