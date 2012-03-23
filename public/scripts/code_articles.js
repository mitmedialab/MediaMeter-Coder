      function alertmsg(e){
        var evtobj=window.event? event : e //distinguish between IE's explicit event object (window.event) and Firefox's implicit.
        var unicode=evtobj.charCode? evtobj.charCode : evtobj.keyCode
        var actualkey=String.fromCharCode(unicode)
        var current = $('articles').down('div').firstDescendant();
        var article_id = current.getAttribute("id");

        if(actualkey=="y"){
          current.addClassName('yes');
          codeArticle(article_id, "yes");
        }else if(actualkey=="n"){
           current.addClassName('no');
           codeArticle(article_id, "no");
        }

      }

      function codeArticle(article_id, answer){
        authenticity_token =$('authenticity_token').value
        answer_type = $('answer_type').value
        new Ajax.Request("/code/answer", {
          method: 'post',
          parameters: {id: article_id, answer_type: answer_type, answer: answer,
                       authenticity_token: authenticity_token},
          onSuccess: function(transport) {
            var notice = $('notice');
            $('articles').insert({top:transport.responseText});
          }
        });
        
      }
      
      function loadFirstArticle(){
        authenticity_token =$('authenticity_token').value
        answer_type = $('answer_type').value
        new Ajax.Request("/code/answer", {
          method: 'post',
          parameters: { answer_type: answer_type, authenticity_token: authenticity_token},
          onSuccess: function(transport) {
            var notice = $('notice');
            $('articles').insert({top:transport.responseText});
          }
        });
      }
