unit MainController;

interface

uses
  System.SysUtils, System.Classes, MVC.DataSet, BaseController, MainService;

type
  [MURL('main', 'main')]  //这是路由地址，视图地址
  TMainController = class(TBaseController)
  public
    [MURL('index')]  // test为index方法的访问地址 ，设置访问地址的 index 方法将无法再访问
    procedure index;
    procedure menu; //获取菜单信息
  end;

implementation

{ TMainController }

procedure TMainController.index;
var
  ds: Idataset;
begin
  SetAttr('realname', Session.getValue('username'));
  ds := Service.Main.getmenu;
  SetAttr('menuls', ds.toJSONArray);
  Show('main');
end;

procedure TMainController.menu;
var
  ds: Idataset;
begin
  ds := Service.Main.getmenu;
  ShowJSON(ds);
end;

end.

