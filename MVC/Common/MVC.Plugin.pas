unit MVC.Plugin;

interface
type
  TPlugin = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TPlugin }

constructor TPlugin.Create;
begin

end;

destructor TPlugin.Destroy;
begin
  
  inherited;
end;

end.

