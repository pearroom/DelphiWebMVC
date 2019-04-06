var table;
var _roleid=null;

function showmenu(roleid) {
	if(_roleid!==null){
		_roleid = roleid;
		reloadmenu();
		return;
	}
	_roleid = roleid;
	$("#btnaddmenu").css("display", "block");	
	layui.use('table', function() {
		table = layui.table
		var index = layer.load(2),
			form = layui.form;
		table.render({
			elem: '#tbmenu',
			url: '../role/getmenu',
			loading: true,
			title: '菜单管理',
			page: true,
			id: 'tbmenu',
			where: {
				roleid: roleid
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
					field: 'menuname',
					title: '菜单名称'
				}, {
					field: '',
					title: '操作',
					width: 100,
					toolbar: '#barbut1',
				}]
			],
			done: function() {
				// 关闭loading
				layer.close(index)
			}
		});
		table.on('tool(tbmenu)', function(obj) {
			var data = obj.data;
			if (obj.event === 'del1') {
				del(data.id);
			}

		});

	});
}

function reloadmenu() {

	table.reload('tbmenu', {
		page: {
			curr: 1 //重新从第 1 页开始
		},
		where: {
			roleid: _roleid
		},
	});
}

function del(id) {
	layer.confirm('确定删除此记录?', {
		icon: 3,
		btnAlign: 'c', //按钮居中
		btn: ['确定', '取消'] //可以无限个按钮        
	}, function(index, layero) {
		$.post("../role/delmenu", {
			menuid: id,
			roleid: _roleid,
		}, function(ret) {
			if (ret.code == 0) {
				reloadmenu();
			}
			layer.msg(ret.message);
		});
	});
}
$("#btnaddmenu").click(function() {
	add();
});

function add() {
	$.get("../role/addmenuview", {}, function(ret) {
		layer.open({
			type: 1,
			title: '新增',
			id: 'layer1', //防止重复弹出

			content: ret,
			btn: ['确定', '取消'],
			btnAlign: 'c', //按钮居中

			area: ['600px', '550px'],
			yes: function() {
				var checkStatus = table.checkStatus('tbmenulist');
				data = checkStatus.data;
				menus="";
				for(var s in data){
					menus+=data[s].id+',';
				}
				$.post("../role/addmenu",{roleid:_roleid,menuid:menus},function(ret){
					if(ret.code==0){
						layer.closeAll();
						reloadmenu();
					}
					layer.msg(ret.message);
					
				});
			},
			btn2: function() {
				layer.closeAll();
			}
		});
	}, 'html');
}
