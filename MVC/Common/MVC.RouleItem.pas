{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.RouleItem;

interface
type
  TRouleItem = class
  private
    FPath: string;
    FName: string;
    FAction: TClass;
    FInterceptor: Boolean;
    procedure SetAction(const Value: TClass);
    procedure SetName(const Value: string);
    procedure SetPath(const Value: string);
    procedure SetInterceptor(const Value: Boolean);
  public
    property Interceptor:Boolean read FInterceptor write SetInterceptor;
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

procedure TRouleItem.SetInterceptor(const Value: Boolean);
begin
  FInterceptor := Value;
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
