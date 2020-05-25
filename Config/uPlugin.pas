unit uPlugin;

interface

uses
  Plugin.Layui, Plugin.Tool;

type
  TPlugin = class
  public
    Layui: TLayui;
    Tool: TTool;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TPlugin }

constructor TPlugin.Create;
begin
  Layui := TLayui.Create;
  Tool := TTool.Create;
end;

destructor TPlugin.Destroy;
begin
  Layui.Free;
  Tool.Free;
  inherited;
end;

end.

