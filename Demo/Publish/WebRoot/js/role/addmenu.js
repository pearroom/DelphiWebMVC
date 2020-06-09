function showselmenu(roleid) {
	layui.use('table', function() {
		var table = layui.table
		var index = layer.load(2),
			form = layui.form;
		table.render({
			elem: '#tbmenulist',
			url: '../role/getselmenu',
			loading: true,
			title: '菜单管理',
			page: true,
			id: 'tbmenulist',
			where: {
				roleid: roleid
			},

			cols: [
				[{
					type: 'checkbox',
					
				}, {
					field: 'menuname',
					title: '菜单名称'
				}]
			],
			done: function() {
				// 关闭loading
				layer.close(index)
			}
		});

	});
}

$(function() {
	showselmenu(_roleid);
});

