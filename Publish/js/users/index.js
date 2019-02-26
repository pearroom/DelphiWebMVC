var ID = "";
var oldelement = null;
$("#add").click(function(){
    BootstrapDialog.show({
		title : "增加",
		message : $('<div></div>').load('../users/add'),
		closable : true,
		cssClass : 'dialog400',

		closeByBackdrop : false,
		closeByKeyboard : false,
		buttons : [{
			label : '保存',
			cssClass: 'btn-primary',
			action : function(dialogItself) {
				$("#usersadd").submit();
			}
		} ,{
			label : '取消',
			cssClass: 'btn-danger',
			action : function(dialogItself) {
				dialogItself.close(); 
			}
		}]
	});
})
var dialogItself_;
$("#edit").click(function(){
    if(ID==""){
        MyAlert("请选择记录");
        return;
    }
    BootstrapDialog.show({
		title : "修改",
		message : $('<div></div>').load('../users/edit?id='+ID),
		closable : true,
		cssClass : 'dialog400',

		closeByBackdrop : false,
		closeByKeyboard : false,
		buttons : [{
			label : '保存',
			cssClass: 'btn-primary',
			action : function(dialogItself) {
                dialogItself_=dialogItself;
				$("#usersedit").submit();
                
			}
		} ,{
			label : '取消',
			cssClass: 'btn-danger',
			action : function(dialogItself) {
				dialogItself.close(); 
			}
		}]
	});
})
$("#delete").click(function(){
    if(ID==""){
        MyAlert("请选择记录");
        return;
    }
    confirm("提示","是否删除",deldata);
})
function deldata(){
    MyAlert('删除');
}
function initTable() {
    $("#usertable1").bootstrapTable({
        dataType : "json",
                
        showHeader : true,
        method : "get",  
        url : "../Users/getList",   
        pagination : true, 
        sidePagination : 'server',
        idField : "id",
        pageSize:10,
        pageList:[],
        onClickRow : function(row, $element, field) {
            ID= row.id;
            if (oldelement != null)
                oldelement.css("background-color", "#FFFFFF");
            $element.css("background-color", "#99CCFF");
            oldelement = $element;
        },
        columns : [
        	{field : 'id',title : 'id',visible : false},
            {field : 'username',title : '用户名称',width : 50},
        	{field : 'name',title : '姓名',width : 100},
        	{field : 'age',title : '年龄',width : 80},
        	{field : 'sex',title : '性别',width : 30,
            formatter : function(value, row, index) {
            if(value=='1')
                return "男";
            else 
                return "女";
            }
            },

        ],
      	queryParams : function queryParams(params) { //设置查询参数  
            var param = {'pagesize':params.limit,'pageindex':params.offset/params.limit};
            return param;
        },
        onLoadSuccess : function() {},
        onLoadError : function() {}   
    });
	}
$(function(){
    initTable();
})
function search(){
	ID="";
    var param = {url:'../Users/getList','pageindex':1};
    $('#usertable1').bootstrapTable('refresh', param);
    
}