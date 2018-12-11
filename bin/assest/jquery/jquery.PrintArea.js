(function ($) {
    var counter = 0;
    var modes = { iframe: "iframe", popup: "popup" };
    var defaults = { mode: modes.iframe,
        popHt: 500,
        popWd: 400,
        popX: 200,
        popY: 200,
        popTitle: '',
        popClose: false
    };

    var settings = {}; //global settings

    $.fn.printArea = function (options) {
        $.extend(settings, defaults, options);

        counter++;
        var idPrefix = "printArea_";
        $("[id^=" + idPrefix + "]").remove();
        var ele = getFormData($(this));

        settings.id = idPrefix + counter;

        var writeDoc;
        var printWindow;

        switch (settings.mode) {
            case modes.iframe:
                var f = new Iframe();
                writeDoc = f.doc;
                printWindow = f.contentWindow || f;
                break;
            case modes.popup:
                printWindow = new Popup();
                writeDoc = printWindow.doc;
        }

        writeDoc.open();
        writeDoc.write(docType() + "<html>" + getHead() + getBody(ele) + "</html>");
        writeDoc.close();

        printWindow.focus();
        printWindow.print();

        if (settings.mode == modes.popup && settings.popClose)
            printWindow.close();
    }

    function docType() {
        if (settings.mode == modes.iframe || !settings.strict) return "";

        var standard = settings.strict == false ? " Trasitional" : "";
        var dtd = settings.strict == false ? "loose" : "strict";

        return '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01' + standard + '//EN" "http://www.w3.org/TR/html4/' + dtd + '.dtd">';
    }

    function getHead() {
        var head = "<head><title>" + settings.popTitle + "</title>";
        $(document).find("link")
            .filter(function () {
                return $(this).attr("rel").toLowerCase() == "stylesheet";
            })
            .filter(function () { // this filter contributed by "mindinquiring"
                var media = $(this).attr("media");
                if (media == undefined) {
                    return false;
                }
                else {
                    return (media.toLowerCase() == "" || media.toLowerCase() == "print");
                }
            })
            .each(function () {
                head += '<link type="text/css" rel="stylesheet" href="' + $(this).attr("href") + '" >';
            });
        head += "</head>";
        return head;
    }

    function getBody(printElement) {
        return '<body><div class="' + $(printElement).attr("class") + '">' + $(printElement).html() + '</div></body>';
    }

    function getFormData(ele) {
        $("input,select,textarea", ele).each(function () {
            // In cases where radio, checkboxes and select elements are selected and deselected, and the print
            // button is pressed between select/deselect, the print screen shows incorrectly selected elements.
            // To ensure that the correct inputs are selected, when eventually printed, we must inspect each dom element
            var type = $(this).attr("type");
            if (type == "radio" || type == "checkbox") {
                if ($(this).is(":not(:checked)")) this.removeAttribute("checked");
                else this.setAttribute("checked", true);
            }
            else if (type == "text")
                this.setAttribute("value", $(this).val());
            else if (type == "select-multiple" || type == "select-one")
                $(this).find("option").each(function () {
                    if ($(this).is(":not(:selected)")) this.removeAttribute("selected");
                    else this.setAttribute("selected", true);
                });
            else if (type == "textarea") {
                var v = $(this).attr("value");
                if ($.browser.mozilla) {
                    if (this.firstChild) this.firstChild.textContent = v;
                    else this.textContent = v;
                }
                else this.innerHTML = v;
            }
        });
        return ele;
    }

    function Iframe() {
        var frameId = settings.id;
        var iframeStyle = 'border:0;position:absolute;width:0px;height:0px;left:0px;top:0px;';
        var iframe;

        try {
            iframe = document.createElement('iframe');
            document.body.appendChild(iframe);
            $(iframe).attr({ style: iframeStyle, id: frameId, src: "" });
            iframe.doc = null;
            iframe.doc = iframe.contentDocument ? iframe.contentDocument : (iframe.contentWindow ? iframe.contentWindow.document : iframe.document);
        }
        catch (e) { throw e + ". iframes may not be supported in this browser."; }

        if (iframe.doc == null) throw "Cannot find document.";

        return iframe;
    }

    function Popup() {
        var windowAttr = "location=no,statusbar=no,directories=no,menubar=no,titlebar=no,toolbar=no,dependent=no";
        windowAttr += ",width=595px,height=842px,top=0,left=0,toolbar=no,scrollbars=no,personalbar=no";
        windowAttr += ",resizable=yes,screenX=" + settings.popX + ",screenY=" + settings.popY + "";

        var newWin = window.open("", "_blank", windowAttr);

        newWin.doc = newWin.document;

        return newWin;
    }

})(jQuery);