// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

// functions for automatically showing a status indicator while remote forms are loading
function loadingFadeIn(){
	$("#uwc-loading").toggle(true);
}
function loadingHide(){
	$("#uwc-loading").fadeOut(100);	
}
function loadingFadeOut(){
	setTimeout(loadingHide,1000);
}

function loadingInit(){
  $("form[data-remote='true']")
  	.bind("ajax:beforeSend", loadingFadeIn)
  	.bind("ajax:complete", loadingHide)
  	.bind("ajax:success", loadingHide);
}

$(loadingInit);
