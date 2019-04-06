var table;
layui.use('table', function() {
	table = layui.table
	var index = layer.load(2),
		form = layui.form;
	table.render({
		elem: '#tbrole',
		url: '../role/getData',
		loading: true,
		title: '角色管理',
		page: true,
		id: 'tbrole',
		page: {
			layout: ['prev', 'page', 'next', 'count', 'skip', 'limit'] //自定义分页布局            
		},
		cols: [
			[{
				field: 'id',
				title: '编号',
				width: 60
			}, {
				field: 'rolename',
				title: '角色名称'
			}, {
				field: '',
				title: '操作',
				width: 180,
				toolbar: '#barbut',
			}]
		],
		done: function() {
			// 关闭loading
			layer.close(index)
		}
	});
	table.on('tool(tbrole)', function(obj) {
		var data = obj.data;
		if (obj.event === 'show') {
			showmenu(data.id);
		} else if (obj.event === 'edit') {
			edit(data);
		} else if (obj.event === 'del') {
			delrole(data.id);
		}

	});

});

function reload() {
	table.reload('tbrole', {
		page: {
			curr: 1 //重新从第 1 页开始
		},
		where: {
			key: {

			}
		}
	});
}

function delrole(id) {
	layer.confirm('确定删除此记录?', {
		icon: 3,
		btnAlign: 'c', //按钮居中
		btn: ['确定', '取消'] //可以无限个按钮        
	}, function(index, layero) {
		$.post("../role/del", {
			id:id
		}, function(ret) {
			if (ret.code == 0) {
				reload();
			}
			layer.msg(ret.message);
		});
	});
}
$("#btnadd").click(function() {
	addrole();
});

function addrole() {
	$.get("../role/add", {}, function(ret) {
		layer.open({
			type: 1,
			title: '新增',
			id: 'layer1' //防止重复弹出
				,
			content: ret,
			btn: ['确定', '取消'],
			btnAlign: 'c' //按钮居中
				,
			area: ['350px', '200px'],
			yes: function() {
				var rolename = $("#txtname").val();
				if (rolename == '') {
					layer.msg("请输入角色名称");
				} else {
					$.post("../role/save", {
						rolename: rolename
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
	$.get("../role/edit", {}, function(ret) {
		layer.open({
			type: 1,
			title: '修改',
			id: 'layer1' //防止重复弹出
				,
			content: ret,
			btn: ['确定', '取消'],
			btnAlign: 'c' //按钮居中
				,
			success: function() {
				$("#txtname").val(data.rolename);
			},
			yes: function() {
				var rolename = $("#txtname").val();
				if (rolename == '') {
					layer.msg("请输入角色名称");
				} else {
					$.post("../role/save", {
						id: data.id,
						rolename: rolename
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
