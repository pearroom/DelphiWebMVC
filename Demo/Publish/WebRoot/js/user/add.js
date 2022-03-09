layui.use(['form'], function() {
	form = layui.form;
	form.render();

	//验证规则
	form.verify({
		username: function(value) {
			if (value.length == '') {
				return '用户名';
			}
		},
		realname: function(value) {
			if (value.length == '') {
				return '姓名';
			}
		},
		pwd: function(value) {
			if (value.length == '') {
				return '密码';
			}
		}		
	});


	//监听提交
	form.on('submit(add)', function(data) {
		$.post("/user/save", data.field, function(ret) {
			if (ret.code == 0) {
				parent.reload();
				layer.closeAll();
			}
			layer.msg(ret.message);
		});

		return false;
	});

	
});
