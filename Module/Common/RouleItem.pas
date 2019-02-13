{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit RouleItem;

interface
type
  TRouleItem = class
  private
    FPath: string;
    FName: string;
    FAction: TClass;
    procedure SetAction(const Value: TClass);
    procedure SetName(const Value: string);
    procedure SetPath(const Value: string);
  public
    property Name: string read FName write SetName;
    property ACtion: TClass read FAction write SetAction;
    property path: string read FPath write SetPath;
  end;
implementation

{ TRouleItem }

procedure TRouleItem.SetAction(const Value: TClass);
begin
  FAction := Value;
end;

procedure TRouleItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TRouleItem.SetPath(const Value: string);
begin
  FPath := Value;
end;

end.
