var table;
layui.use(['table', 'form'], function() {
	table = layui.table;
	form = layui.form;
	form.render();
	var index = layer.load(2),
		form = layui.form;
	table.render({
		elem: '#tbuser',
		url: '../user/getData',
		loading: true,

		title: '用户管理',
		page: true,
		id: 'tbuser',
		where: {
			roleid: $("#role").val()
		},
		page: {
			layout: ['prev', 'page', 'next', 'count', 'skip', 'limit'] //自定义分页布局            
		},
		cols: [
			[{
				field: 'id',
				title: '编号',
				width: 60
			}, {
				field: 'username',
				title: '用户名称'
			}, {
				field: 'realname',
				title: '姓名'
			}, {
				field: '',
				title: '操作',
				width: 180,
				toolbar: '#barDemo',
			}]
		],
		done: function() {
			// 关闭loading
			layer.close(index)
		}
	});
	table.on('tool(tbuser)', function(obj) {
		var data = obj.data;
		if (obj.event === 'edit') {
			edit(data);
		} else if (obj.event === 'del') {
			del(data.id);
		}

	});

});

function reload() {
	table.reload('tbuser', {
		page: {
			curr: 1
		},
		where: {
			roleid: $("#role").val()
		}
	});
}

function del(id) {
	layer.confirm('确定删除此记录?', {
		icon: 3,
		btnAlign: 'c', //按钮居中
		btn: ['确定', '取消'] //可以无限个按钮        
	}, function(index, layero) {
		$.post("../user/del", {
			id,
			id
		}, function(ret) {
			if (ret.code == 0) {
				reload();
			}
			layer.msg(ret.message);
		});
	});
}
$("#btnadd").click(function() {
	add();
	form.render();
});
$("#btnsearch").click(function() {
	reload();
});

function add() {
	$.get("../user/add", {}, function(ret) {
		layer.open({
			type: 1,
			title: '新增',
			id: 'layer1', //防止重复弹出
			area: ['450px', '400px'],
			content: ret,
			btn: ['确定', '取消'],
			btnAlign: 'c', //按钮居中


			yes: function() {

				var username = $("#username").val();
				var realname = $("#realname").val();
				var roleid = $("#roleid").val();
				var pwd = $("#pwd").val();
				if (username == '') {
					layer.msg("请输入用户名称");
				} else {
					$.post("../user/save", {
						username: username,
						roleid: roleid,
						pwd: pwd,
						realname: realname,
					}, function(ret) {
						if (ret.code == 0) {
							layer.closeAll();
							reload();
						}
						layer.msg(ret.message);
					}, "json");
				}
			},
			btn2: function() {
				layer.closeAll();
			}
		});
	}, 'html');
}

function edit(data) {
	$.get("../user/edit", {}, function(ret) {
		layer.open({
			type: 1,
			title: '修改',
			id: 'layer1', //防止重复弹出
			content: ret,
			area: ['450px', '400px'],
			btn: ['确定', '取消'],
			btnAlign: 'c', //按钮居中
			success: function() {
				$("#username").val(data.username);
				$("#roleid").val(data.roleid);
				$("#realname").val(data.realname);
				$("#id").val(data.id);
				form.render();
			},
			yes: function() {
				var username = $("#username").val();
				var realname = $("#realname").val();
				var roleid = $("#roleid").val();
				var pwd = $("#pwd").val();
				var id = $("#id").val();
				if (username == '') {
					layer.msg("请输入用户名称");
				} else {
					$.post("../user/save", {
						id: data.id,
						username: username,
						roleid: roleid,
						pwd: pwd,
						realname: realname,

					}, function(ret) {
						if (ret.code == 0) {
							layer.closeAll();
							reload();
						}
						layer.msg(ret.message);
						form.render();
					}, "json");
				}
			},
			btn2: function() {
				layer.closeAll();
			}
		});
	}, 'html');
}
