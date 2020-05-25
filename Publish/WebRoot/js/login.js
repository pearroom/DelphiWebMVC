
	// $(function(){
	//demo1
	var regconfig = [{
		eleinput: "login_phone",
		eletext: "login_phone_text",
		rule: [{
			reg: /^.+$/,
			text: "手机号不能为空"
		}, {
			reg: /^1[34578]\d{9}$/,
			text: "手机号格式错误"
		}]
	},
	{
		eleinput: "login_password",
		eletext: "login_password_text",
		rule: [{
			reg: /^.+$/,
			text: "密码不能为空"
		}]
	}
	];
	tbdValidate(
		regconfig, {
			elesubmit: "login_submit", //提交按钮
			funsubmit: function () { //验证通过可提交回调
				$.post("check", { "username": $("#login_phone").val(), "pwd": $("#login_password").val() }, function (ret) {
					if (ret.code == 0) {
						$(window).attr('location', 'Main/');
					} else {
						layer.msg(ret.message);
					}

				}, 'json');


			},
			funerr: function () { //不可提交回调

			},
			funerrlist: function (errlist) {
				$('#' + errlist[0]).focus();
			}
		}
	);