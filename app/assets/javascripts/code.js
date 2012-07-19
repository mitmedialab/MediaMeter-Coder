

function code_loadFirstArticle(){
	var authenticityToken =$('#authenticity_token').val();
	var questionId = $('#question_id').val();
	var dataToSubmit = { question_id: questionId, authenticity_token: authenticityToken};
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
	var questionId = $('#question_id').val();
	var dataToSubmit = { id: articleId, question_id: questionId, answer: answer,  
		authenticity_token: authenticityToken};
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
