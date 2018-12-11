var LODOP; // 声明为全局变量

var iRadioValue = 1;
var _confirm;

function confirm(title, text, backfunc) {
    $.confirm({title: title, content: text, buttons: {
            ok: {text: '确定', btnClass: 'btn-blue', action: function () {
                    backfunc();
                }},
            cancel: {text: '取消', action: function () {}}
        }
    });
}
function MyAlert(Msg) {
    $.confirm({title: '提示', content: Msg, buttons: {buttonA: {text: '确定', action: function () {
                    return true;
                }}}});
}

function SetDialogSize(width, height) {
    $('#SetDialogD').css('width', width);
    $('#ifSetDialog').css('height', height);
}
function SetDialogShow(URL, Title) {
    var tmpurl = URL;
    $('#SetModalLabel').html(Title);
    $('#SetDialog').modal('show');
    $("#ifSetDialog").empty();
    $('#ifSetDialog').load(tmpurl);
}
function SetDialogHide() {
    $('#SetDialog').modal('hide');
}
function DateDialogShow() {
    $('#dateDialog').modal('show');
    var mydate = new Date();
    year = mydate.getFullYear();
    month = (mydate.getMonth() + 1);
    day = mydate.getDate();
    str = year + "-" + month.toString().replace(/^[0-9]{1}$/, "0" + month) + "-" + day.toString().replace(/^[0-9]{1}$/, "0" + day);
    $('#date1').val(str);
    $('#date2').val(str);
}
function DateDialogClose() {
    $('#dateDialog').modal('hide');
}
function DateDialogDate1() {
    return $('#date1').val();
}
function DateDialogDate2() {
    return $('#date2').val();
}


function DialogShow(URL, Title) {
    var tmpurl = URL;
    url = "url:" + tmpurl;
    var dlg = $.confirm({title: Title, content: url, buttons: {buttonA: {text: '确定', action: function () {
                    return true;
                }}}});
    return dlg;
}
var looprun = false;
function chktokentimer() {
    if (looprun) {
        $.ajax({
            type: 'get',
            url: "Index/checktoken",
            cache: true,
            async:true,
            dataType: 'json',
            success: function (result) {
                if (result.tokencode === 1) {
                    alert("账号在其它设备登录，将退出此设备！");
                    location = "/examw";
                } else {
                    well = $("#onlinewell");
                    if (well !== null) {
                        well.html("在线人数：" + result.onlinecount + "    " + "注册人数：" + result.count);
                    }
                    setTimeout('chktokentimer()', 5000);
                }
            }
        });

    } else {
        setTimeout('chktokentimer()', 1000);
    }
}
$(document).ready(function () {
   // setTimeout('chktokentimer()', 1000);
});
//------解决ie8 keys 不支持问题
//var DONT_ENUM =  "propertyIsEnumerable,isPrototypeOf,hasOwnProperty,toLocaleString,toString,valueOf,constructor,indexOf".split(","),
//hasOwn = ({}).hasOwnProperty;
//for (var i in {toString: 1}){DONT_ENUM = false;}
//Object.keys = Object.keys || function(obj){//ecma262v5 15.2.3.14
//        var result = [];
//        for(var key in obj ) if(hasOwn.call(obj,key)){result.push(key) ;}
//        if(DONT_ENUM && obj){for(var i = 0 ;key = DONT_ENUM[i++]; ){if(hasOwn.call(obj,key)){result.push(key);}}}
//        return result;
//    };
//function extend(dst) {
//    var h = dst.$$hashKey;
//    for (var i = 1, ii = arguments.length; i < ii; i++) {
//        var obj = arguments[i];
//        if (obj) {var keys = Object.keys(obj);for (var j = 0, jj = keys.length; j < jj; j++) {var key = keys[j];dst[key] = obj[key];}}    }
//    setHashKey(dst, h);
//    return dst;
//}
//-----解决ie8 keys 不支持问题