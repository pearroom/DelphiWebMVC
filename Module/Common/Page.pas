unit Page;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.HTTPProd, FireDAC.Comp.Client,
  superobject, uConfig;

type
  TPage = class
  private

//    Response: TWebResponse;
    url: string;
    plist: TStringList;
    procedure PageHTMLTag(Sender: TObject; Tag: TTag; const TagString: string; TagParams: TStrings; var ReplaceText: string);
  private
    function getTableHtml(jsondata, htmlfile: string): string;
  public
    Page: TPageProducer;
    procedure setAttr(key, value: string);
    function HTML(): string;
    constructor Create(htmlfile: string; params: TStringList; _url: string);
    destructor Destroy; override;
  end;

implementation

{ TPage }

constructor TPage.Create(htmlfile: string; params: TStringList; _url: string);
begin
  Page := TPageProducer.Create(nil);
  plist := params;
  if UpperCase(default_charset) = 'UTF-8' then
  begin
    Page.HTMLDoc.LoadFromFile(htmlfile, TEncoding.UTF8);
  end
  else if UpperCase(default_charset) = 'UTF-7' then
  begin
    Page.HTMLDoc.LoadFromFile(htmlfile, TEncoding.UTF7);
  end
  else if UpperCase(default_charset) = 'UNICODE' then
  begin
    Page.HTMLDoc.LoadFromFile(htmlfile, TEncoding.Unicode);
  end
  else
  begin
    Page.HTMLDoc.LoadFromFile(htmlfile, TEncoding.Default);
  end;
//  Page.OnHTMLTag := PageHTMLTag;
  url := _url;
end;

destructor TPage.Destroy;
begin

  FreeAndNil(Page);
  inherited;
end;

function TPage.HTML(): string;
begin
  Result := Page.HTMLDoc.Text;
end;

function TPage.getTableHtml(jsondata, htmlfile: string): string;
var
  i: Integer;
  jo: ISuperObject;
  item: TSuperAvlEntry;
  ar: TSuperArray;
  pag: Tpage;
  html: string;
begin
  html := '';
  jo := SO(jsondata);
  if (jo.IsType(stArray)) then
  begin
    pag := Tpage.Create(htmlfile, plist, self.url);
    ar := jo.AsArray;
    for i := 0 to ar.Length - 1 do
    begin
      for item in ar[i].AsObject do
      begin
        pag.setAttr(item.Name, item.value.AsString);
      end;
      html := html + pag.html;
    end;
    FreeAndNil(pag);
  end;
  result := html;
end;

procedure TPage.PageHTMLTag(Sender: TObject; Tag: TTag; const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  i: Integer;
  value, htmlfile, list, S: string;
  when_, then_, else_: string;
  value2: string;
  k: Integer;
  pag: Tpage;
  jo: ISuperObject;
  key: string;
  field: string;
begin
//  if (SameText(TagString, 'include')) then
//  begin
//    htmlfile := TagParams.Values['file'];
//    if (htmlfile.IndexOf('\') <> 0) then
//      htmlfile := '\' + htmlfile;
//    htmlfile := WebApplicationDirectory + template + htmlfile;
//    if (Trim(htmlfile) <> '') then
//    begin
//      if (not FileExists(htmlfile)) then
//      begin
//        S := htmlfile + '系统找不到指定文件';
//        ReplaceText := S;
//      end
//      else
//      begin
//        pag := Tpage.Create(htmlfile, plist, self.url);
//
//        ReplaceText := pag.html;
//        FreeAndNil(pag);
//      end;
//    end;
//  end;
//  for i := 0 to plist.Count - 1 do
//  begin
//    if (SameText(TagString, 'for')) then
//    begin
//      list := TagParams.Values['list'];
//      value := plist.Values[list];
//      htmlfile := TagParams.Values['htmlfile'];
//      if (TagParams.IndexOfName('list') > -1) and (TagParams.IndexOfName('htmlfile') > -1) then
//      begin
//        htmlfile := self.url + htmlfile;
//        if (not FileExists(htmlfile)) then
//        begin
//          S := htmlfile + '系统找不到指定文件';
//        end
//        else
//        begin
//          S := getTableHtml(value, htmlfile);
//        end;
//        ReplaceText := S;
//      end;
//    end
//    else if (SameText(TagString, 'if')) then
//    begin
//      if ((TagParams.IndexOfName('when') > -1) and (TagParams.IndexOfName('then') > -1) and (TagParams.IndexOfName('else') > -1)) then
//      begin
//        when_ := TagParams.Values['when'];
//        then_ := TagParams.Values['then'];
//        else_ := TagParams.Values['else'];
//        k := Pos('=', when_);
//        value := Copy(when_, 0, k - 1);
//        value2 := Copy(when_, k + 1, Length(when_) - k);
//        if (Pos('.', value) > 0) then
//        begin
//          key := Copy(value, 1, Pos('.', value) - 1);
//          field := Copy(value, Pos('.', value) + 1, Length(value) - Pos('.', value) + 1);
//          if (plist.IndexOfName(key) < 0) then
//          begin
//            S := '';
//          end
//          else
//          begin
//            value := plist.Values[key];
//            jo := SO(value);
//            if jo.IsType(stObject) then
//            begin
//              value := jo.S[field];
//            end
//            else
//              value := '';
//            if (value = value2) then
//              S := then_
//            else
//              S := else_;
//          end;
//        end
//        else
//        begin
//          if (plist.IndexOfName(value) < 0) then
//          begin
//            S := '';
//          end
//          else
//          begin
//            value := plist.Values[value];
//            if (value = value2) then
//              S := then_
//            else
//              S := else_;
//          end;
//        end;
//        ReplaceText := S;
//      end;
//    end
//    else if CompareText(TagString, plist.Names[i]) = 0 then
//    begin
//      value := plist.ValueFromIndex[i];
//      try
//        try
//          if (TagParams.Count = 1) then
//          begin
//            S := TagParams[0];
//            if Pos('.', S) > 0 then
//            begin
//              S := Copy(S, 2, Length(S) - 1);
//
//              jo := SO(value);
//              if jo.IsType(stObject) then
//              begin
//                value := jo.S[S];
//              end
//              else
//                value := '';
//
//            end;
//          end;
//        except
//
//        end;
//      finally
//        ReplaceText := value;
//      end;
//
//    end;
//
//  end;
end;

procedure TPage.setAttr(key, value: string);
begin
  plist.Values[key] := value;
end;

end.

