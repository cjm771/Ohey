// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

"use strict";

var ohey = (function($){
	return {
		ajaxSaverSync : function(el, newVal){
			newVal = (newVal!=undefined) ? newVal.trim() : $(el).val().trim();
			console.log("placeholder is"+ $(el).attr("placeholder"));
			var newVal2 = (newVal.length==0) ? $(el).attr("placeholder") : newVal;
			console.log("value is #"+newVal2+"#"+(!newVal.trim));
			var identifier = $(el).closest('form').attr("class")+"_"+$(el).attr("data-saver");
			console.log(identifier);
			$("[data-saver-sync='"+identifier+"']").text(newVal2);
		},
		ajaxSaver : function(els){
			var that = this;
			console.log(els);
			//els = (typeof els != Array) ? [els] : els;
			$(els).each(function(){
				//lets make a data-field attribute
				var fieldName = (/\[(.*)\]/g).exec($(this).attr("name"));
				if (fieldName != null){
					$(this).attr("data-saver", fieldName[1] );
					
					$(this).bind('keyup change paste', function() { 
						that.ajaxSaverSync(this);
					    $(this).closest('form').delay(200).submit();
					});
					 $(this).closest('form').on("ajax:success", function(e, data, status, xhr){
	   					 console.log(xhr.responseText);
	   					 $(this).find(".glyphicon-remove").remove();
					}).on("ajax:error", function(e, xhr, status, error){
						var form = e.target;
						console.log(xhr.responseText);
						//remove all previous errors
						var errorData = $.parseJSON(xhr.responseText);
						$(form).find(".glyphicon-remove").remove();
						$.each(errorData.errors, function(field, error){
							console.log(field);
							var errorSymbol = $("<i class='glyphicon glyphicon-remove'></i>");
							errorSymbol.attr("title", field+" "+error[0]+", so it will remain as '"+errorData.model[field]+"'");
							var el = $(form).find("[data-saver='"+field+"']");
							el.after(errorSymbol);
							that.ajaxSaverSync(el,errorData.model[field]);
						});
						console.log(errorData);
	   					//$(this).after("<i class='glyphicon glyphicon-remove'></i>");
	    			})
				}
			});
		},
		settingsInit : function(){
			if ($('#settingsTabs').length){
				this.ajaxSaver($('.tab-pane input,.tab-pane textarea'));
			}
		},
		init : function(){
			//auto resize textareas
			$('textarea.autosize').autosize({append : "\n\n"});
			//bs tabs click first
   			 $('#settingsTabs a:first').tab('show');
   			 //settings init
   			 this.settingsInit();
		}
	}
})(jQuery);

$(function(){
	ohey.init();
});