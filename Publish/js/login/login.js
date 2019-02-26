$(document).ready(
		function() {	
            $('input').iCheck({
                checkboxClass: 'icheckbox_square-blue',
                radioClass: 'iradio_square-blue',
                increaseArea: '20%' // optional
            });            
			formcheck();

});
function formcheck(){

	$('#loginform').formValidation({
		message : 'This value is not valid',
		err : {container : 'tooltip'},
		icon : {valid : 'glyphicon glyphicon-ok',invalid : 'glyphicon glyphicon-remove',validating : 'glyphicon glyphicon-refresh'},
		fields : {
			username :{group : '.col-md-12',validators : {notEmpty : {message : '不能为空'}}},
			pwd :{group : '.col-md-12',validators : {notEmpty : {message : '不能为空'}}},

		},
	
	}).on('err.form.fv', function(e, data) {
		MyAlert("请填写完整");
	}).on('success.form.fv', function(e) {
		e.preventDefault();
		var $form = $(e.target);
		var bv = $form.data('formValidation');
		$.post($form.attr('action'), $form.serialize(), function(result) {	
			if(result['code']==0){
               $(window).attr('location','Main/');
            }else{
               MyAlert(result['message']);
               }
			
            
		}, 'json');
	})	
}
