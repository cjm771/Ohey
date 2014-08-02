//= require jquery
//= require jquery_ujs
//= require_tree .

"use strict";

var ohey = (function($){
	return {
		ajaxSaverSync : function(el, newVal){
			newVal = (newVal!=undefined) ? newVal.trim() : $(el).val().trim();
			var newVal2 = (newVal.length==0) ? $(el).attr("placeholder") : newVal;
			var identifier = $(el).closest('form').attr("class")+"_"+$(el).attr("data-saver");
			$("[data-saver-sync='"+identifier+"']").text(newVal2);
		},
		ajaxSaver : function(els){
			var that = this;

			$(els).each(function(){
				//lets make a data-field attribute
				if  (!$(this).attr("data-nosaver")){
					var fieldName = (/\[(.*)\]/g).exec($(this).attr("name"));
					if (fieldName != null){
						$(this).attr("data-saver", fieldName[1] );
						
						
							$(this).bind('keyup change paste', function() { 
								if (!$(this).attr('data-noautosubmit')){
									//attempt to sync on key up if autosumbit
									that.ajaxSaverSync(this);
								    $(this).closest('form').delay(200).submit();
								}else{
									//else just clear errors out
									 $(this).closest('form').find('.error_notifier').remove();
								}
							});
						
						 $(this).closest('form').on("ajax:success", function(e, data, status, xhr){
		   					 $(this).find(".glyphicon-remove").remove();
		   					$("[data-updated-sync]").each(function(){
		   						$(this).attr("data-time", new Date().toISOString());  
		   						that.updateUpdatedEls();
		   					}) 
		   					console.log('saved.');
						}).on("ajax:error", function(e, xhr, status, error){
							var form = e.target;
							//console.log(xhr.responseText);
							//remove all previous errors
							try{
							var errorData = $.parseJSON(xhr.responseText);

							$(form).find(".glyphicon-remove").remove();
							$.each(errorData.errors, function(field, error){
								var errorSymbol = $("<i class='error_notifier glyphicon glyphicon-remove has_tooltip'></i>");
								errorSymbol.attr("title", field+" "+error[0]+((errorData.model==undefined) ? "" : ", so it will remain as '"+errorData.model[field]+"'"));
								var el = $(form).find("[data-saver='"+field+"']");
								el.after(errorSymbol.hide().show("slow", function(){
									that.reloadTooltip();
								}));

								if (errorData.model!=undefined)
									that.ajaxSaverSync(el,errorData.model[field]);
							});
							}catch(e){
								console.log("Error not parsable: "+xhr.responseText)
							}
							console.log('error!');
		    			})
					}
				}
			});
		},
		settingsInit : function(){
			if ($('#settingsTabs').length){
				this.ajaxSaver($('.tab-pane input,.tab-pane textarea'));
			}
			//load proper tab
			this.bsTabsHashFix();
		},
		reloadTooltip : function(){
   			 //tooltip those
   			 $(".has_tooltip").tooltip();
		},
		slideLeft : function(el, startfinish){
			var that = this;
			startfinish = (startfinish!=undefined) ? startfinish : {start : -1*el.width(), end: 0};
			el.css("margin-left", (startfinish.start)+"px").show().animate({"margin-left": startfinish.end+"px"},{
				duration : 300,
				queue : false,
				complete : function(){
					$("#container").height(that.getEditorHeight($(".main"))+"px");
				}
			});

		},
		unslideLeft : function(el, startfinish){
			startfinish = (startfinish!=undefined) ?  startfinish : {start: 0, end: -1*el.width()};
				el.animate({"margin-left": (startfinish.end)+"px"}, { 
				duration: 300,
				queue : false,
				complete : function(){
				}
			});
		},
		getEditorHeight : function(el){
			var elH =  (el==undefined) ? $(window).height() : el.offset().top+el.outerHeight(true);//returns window height
			var winH = $(window).height()
			var docH = document.body.scrollHeight;
			var ret =  (elH<=winH) ? winH : elH;
			return ret;
		},
		editPostsInit: function(){
			var that = this;
			if ($("#left_drawer_icon").length && $(".editor").length){

				//initalize media-editor
				 new MediumEditor('.editor .rt-textArea', {
				 	anchorInputPlaceholder: 'Type a link',
				    buttons:  ['bold', 'italic', 'underline', 'anchor', 'image', 'header1', 'header2', 'quote'],
				    firstHeader: 'h1',
				    secondHeader: 'h2',
				    placeholder : 'Type your awesome post here...You can see settings by hovering in the lower left corner.',
				    targetBlank: true
				 });

				 $('.editor .rt-textArea').on('input', function() {
 					 //edit container to match
 					 $(".editor .form-group textarea").html($(this).html()).trigger("change");
 					 $("#container").height(that.getEditorHeight($(".main"))+"px");
				});

				 //resize function
				 window.addEventListener('resize', function() {
				  $("#container").height(that.getEditorHeight($(".main"))+"px");
				});

				//initialize left drawer
				$("#left_drawer_icon").on("click", function(){	

					var el = $(".drawer.left");
					if (!el.hasClass("open")){
						el.addClass("open");
						that.slideLeft(el);
						that.slideLeft($(".rt-wpr"), {start: 0, end: 300});
						$(this).addClass("active");
					}
					else{
						el.removeClass("open")
						that.unslideLeft(el);
						that.unslideLeft($(".rt-wpr"), {start: 300, end: 0});
						$(this).removeClass("active");

					}
				});

				//add savers for
				this.ajaxSaver($('.drawer.left input,.editor input,.editor textarea'));
				//make checkbox pretty
				$("#post_published").bootstrapSwitch({
					onText : "Published",
					offText : "Draft",
					onColor : "success",
					offColor : "primary",
					onSwitchChange: function(e, state){
						$("#post_published").val(state);
						$("#post_published").trigger("change");
					}
				});
				//init height thing
				$("#container").height(that.getEditorHeight($(".main"))+"px");
			}
		},
		updateUpdatedEls : function(){
			   $("[data-updated-sync]").each(function(){
   			 	$(this).text($.timeago($(this).attr("data-time")));
   			 	});
		},
		bsTabsHashFix : function(){
			var hash = window.location.hash;
			  hash && $('ul.nav a[href="' + hash + '"]').tab('show');

			  $('.nav-tabs a').click(function (e) {
			    $(this).tab('show');
			    var scrollmem = $('body').scrollTop();
			    window.location.hash = this.hash;
			    $('html,body').scrollTop(scrollmem);
			  });
		},
		init : function(){
			var that = this;
			//auto resize textareas
			$('textarea.autosize').autosize({append : "\n\n"});
			//bs tabs click first
   			 $('#settingsTabs li > a:first').tab('show');
   			 //bs tooltips
   			this.reloadTooltip();
   			 //settings init
   			 this.settingsInit();
   			 //edit post
   			 this.editPostsInit();
   			 //data syncs
   			 setInterval(function(){
   			 	that.updateUpdatedEls();
   			 }, 1000*60);

		}
	}
})(jQuery);

$(function(){
	ohey.init();
});