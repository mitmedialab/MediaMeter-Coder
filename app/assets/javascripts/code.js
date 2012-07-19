

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
    var articleId = currentArticle.find('.article_id').val();
	var validKey = false;
	var answerName = null;
	if(actualkey=="1"){
		validKey = true;
		answerName = 'answer_one';
	} else if(actualkey=="5"){
		validKey = true;
		answerName = 'answer_two';
	} else if(actualkey=="0"){
		validKey = true;
		answerName = 'answer_three';
	} else if(actualkey=="d"){
		validKey = true;
		answerName = 'answer_four';
	} else if(actualkey=="m"){
		validKey = true;
		answerName = 'answer_five';
	}
	if(validKey) {
		pickedAnswer = currentArticle.find('#'+answerName); 
		pickedAnswer.attr('checked',true);
		code_codeArticle(articleId,pickedAnswer.val());
	}
}

function code_codeArticle(articleId, answer){
	var currentArticle = $('#article_'+articleId);
	currentArticle.addClass('done');
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
	currentArticle.find('input').attr('disabled',true);	
}

function code_init() {
	$(function(){ $(document).keypress(code_handleKeyPress)})
	$(code_loadFirstArticle);
}
