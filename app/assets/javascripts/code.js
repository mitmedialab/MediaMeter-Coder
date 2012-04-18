

function code_loadFirstArticle(){
	var authenticityToken =$('#authenticity_token').val();
	var answerType = $('#answer_type').val();
	var dataToSubmit = { answer_type: answerType, authenticity_token: authenticityToken};
	$.ajax({
		url:'/code/answer',
		data: dataToSubmit,
		success: function(data) {
			$('#articles').prepend(data);
		}
	});
}

function code_handleKeyPress(evt){
	var unicode=evt.charCode? evt.charCode : evt.keyCode;
    var actualkey=String.fromCharCode(unicode);
    var currentArticle = $('#articles').find('div:first'); 
    var articleId = currentArticle.attr('id');
	if(actualkey=="y"){
		currentArticle.addClass('yes');
        code_codeArticle(articleId, "yes");
	} else if(actualkey=="n"){
		currentArticle.addClass('no');
		code_codeArticle(articleId, "no");
	}
}

function code_codeArticle(articleId, answer){
	var authenticityToken =$('#authenticity_token').val();
	var answerType = $('#answer_type').val();
	var dataToSubmit = { id: articleId, answer_type: answerType, answer: answer,  
		answer_type: answerType, authenticity_token: authenticityToken};
	$.ajax({
		url:'/code/answer',
		data: dataToSubmit,
		success: function(data) {
			$('#articles').prepend(data);
		}
	});
}

function code_init() {
	$(function(){ $(document).keypress(code_handleKeyPress)})
	$(code_loadFirstArticle);
}
