unit uPlugin;

interface


type
  TPlugin = class
  public
   // Wechat: TWechatApi;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TPlugin }

constructor TPlugin.Create;
begin
  //Wechat := TWechatApi.Create;
end;

destructor TPlugin.Destroy;
begin
//  Wechat.Free;
  inherited;
end;

end.

