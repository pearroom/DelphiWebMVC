unit MVC.PageCache;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TPageCache = class
  public
    PageList: TDictionary<string, string>;
    constructor Create();
    destructor Destroy; override;
  end;

var
  _PageCache: TPageCache;

implementation

{ TPageCache }

constructor TPageCache.Create;
begin
  PageList := TDictionary<string, string>.Create;
end;

destructor TPageCache.Destroy;
begin
  PageList.Clear;
  PageList.Free;
  inherited;
end;

end.

