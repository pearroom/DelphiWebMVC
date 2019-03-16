unit uRouleMap;

interface

uses
  Roule;

type
  TRouleMap = class(TRoule)
  public
    constructor Create(); override;
  end;

implementation

uses
  IndexController;

constructor TRouleMap.Create;
begin
  inherited;
  //路径,控制器,视图目录
  SetRoule('', TIndexController, 'index');

end;

end.

