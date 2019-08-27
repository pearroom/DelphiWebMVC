unit uRouleMap;

interface

uses
  MVC.Roule;

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
  //Â·¾¶,¿ØÖÆÆ÷,ÊÓÍ¼Ä¿Â¼,À¹½ØÆ÷(Ä¬ÈÏÀ¹½Ø)
  SetRoule('', TIndexController, '', False);


end;

end.

