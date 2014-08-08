//= require jquery
//= require jquery_ujs
//= require_tree .
//= require zeroclipboard

"use strict";

var ohey = (function($){
	return {
		changeRoleSuccess : function(el, resp){
			var options = ["Contributor", "Moderator"];
			$(el).closest("td").find("span.role_name").text(options[resp.role]);
		},
		addUserSuccess : function(){
			location.reload();
		},
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
		   					if ($(this).attr('data-success-callback')){
		   						console.log("callback!");
		   						eval("that."+$(this).attr('data-success-callback')+"(this, data)");
		   					}
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
			var that = this;
			if ($('#settingsTabs').length){
				this.ajaxSaver($('.tab-pane input,.tab-pane textarea'));
			}
			//load proper tab
			this.bsTabsHashFix();

			//change role features
			this.changeRoleInit()
		},
		reloadTooltip : function(){
   			 //tooltip those
   			 $(".has_tooltip").tooltip('destroy').tooltip();
		},
		slideLeft : function(el, startfinish){
			var that = this;
			startfinish = (startfinish!=undefined) ? startfinish : {start : -1*el.width(), end: 0};
				$(".drawer").height(that.getEditorHeight($(".main")));
			el.css("margin-left", (startfinish.start)+"px").show().animate({"margin-left": startfinish.end+"px"},{
				duration : 300,
				queue : false,
				complete : function(){
				 	$(".drawer").height(that.getEditorHeight($(".main")));
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
			var body = document.body,
    		    html = document.documentElement;
			var docH = Math.max( body.scrollHeight, body.offsetHeight, 
			                       html.clientHeight, html.scrollHeight, html.offsetHeight );
			var elH =  (el==undefined) ? docH : el.offset().top+el.outerHeight(true);//returns window height
			var winH = $(window).height();
			var ret =  (elH<=winH) ? winH : elH;
			console.log("elh: "+elH+" winH: "+winH+" jquery doc height:"+$("body")[0].scrollHeight);
			return ret;
		},
		changeRoleInit : function(){
			var that = this;
			//for new users change role
			if ($("#newuser_role .newuser_moderator")){
				if (!$("#newuser_role").hasClass("disabled")){
					 $("#newuser_role").on("click", function(){
					 	var moderator = $(this).find(".newuser_moderator");
					 	if (moderator.is(":visible")){
					 		$("form.new_role #role_role").val(0);
					 		moderator.hide();
					 		$(this).attr("title", 'Invite a Collaborator. Click to change.');
					 	}
					 	else{
					 		moderator.show();
					 		$("form.new_role #role_role").val(1);
					 		$(this).attr("title", 'Invite a Moderator. Click to change.');
					 		
					 	}
					 	that.reloadTooltip();
					 });
				}
			}
			//for existing user change role
			$(".users_table .changeRole_icon").on("click", function(){
				// change hidden field..to submit form
				var form = $(this).closest("form"),
				input = form.find("input#role_role[type='hidden']");
				console.log(input.val())
				input.val(parseInt(input.val())==0 ? 1 : 0);
				input.trigger("change");

			});
		},
		editHotkeysInit : function(){
			var that = this,
			redirect_to = function(href){
			 location.href = href;
			},
			 binder = function(cmd, fn){
				$(document).on('keydown', null, cmd, fn);
			};
			//cmd + i = underline
			binder("meta+u", function(){
				that.editor.execAction("underline");
			});

			binder("meta+j", function(){
			if (window.getSelection()!="")
				that.editor.execAction("anchor");
			});

			binder("meta+k", function(){
				if (window.getSelection()!="")
					that.editor.execAction("image");
				console.log("#"+window.getSelection()+"#")
			});
			//cmd + shift + esc = go to posts 
			binder( 'meta+shift+esc', function(){redirect_to("/my-posts")});
			//cmd + shift + p = publish + go to posts 
			binder('meta+shift+p', function(){
				$("#post_published").bootstrapSwitch('state', true);
				$("#post_published").trigger("change");
				$("#post_published").closest("form").on("ajax:success", function(){
					redirect_to("/my-posts");
				});
			});
			//cmd + shift + o = draft and go to post
			binder('meta+shift+o', function(){
				$("#post_published").bootstrapSwitch('state', false);
				$("#post_published").trigger("change");
				$("#post_published").closest("form").on("ajax:success", function(){
					redirect_to("/my-posts");
				});
			});
			//cmd  + 1 = toggle drawer
			binder('meta+1', function(){
				$("#left_drawer_icon").trigger("click");
			});
		},
		blogInit : function(){
			if ($(".blogs_show").length){
				$(".drawer.left").on("ohey.drawerOpen", function(){
					$("#header").addClass('drawer_open');
				});
				$(".drawer.left").on("ohey.drawerClosed", function(){
					$("#header").removeClass('drawer_open');
				});
			}
		},
		leftDrawerInit : function(){
			var that = this;
			//initialize left drawer
			$("#left_drawer_icon, [data-drawer-toggle]").on("click", function(){	

				var el = $(".drawer.left");
				if (!el.hasClass("open")){
					el.addClass("open");
					that.slideLeft(el);
					that.slideLeft($(".main"), {start: 0, end: 300});
					$(this).addClass("active");
					el.trigger("ohey.drawerOpen");
				}
				else{
					el.removeClass("open")
					that.unslideLeft(el);
					that.unslideLeft($(".main"), {start: 300, end: 0});
					$(this).removeClass("active");
					el.trigger("ohey.drawerClosed");
				}
			});

			//resize function
			 window.addEventListener('resize', function() {
			 $(".drawer").height(that.getEditorHeight($(".main")));
			});
		},
		editPostsInit: function(){
			var that = this;
			//set up hotkeys
			this.editHotkeysInit();

			if ($("#left_drawer_icon").length && $(".editor").length){

				//initalize media-editor
				 that.editor = new MediumEditor('.editor .rt-textArea', {
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
 					$(".drawer").height(that.getEditorHeight($(".main"))+20);
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
		fakeSubmitsInit : function(){
			$("[data-input='submit']").on("click", function(){
				$(this).closest("form").submit();
			});
		},
		homeInit : function(){
			if ($("#homePage").length){


			$("#register_button").on("click", function(){
				 $('html,body').animate({scrollTop :0});
				introJs().setOptions({ 
					'skipLabel': 'Exit', 
					'tooltipPosition': 'bottom-right-aligned',
					'showButtons': false,
					'showStepNumbers': false,
					'showBullets' : false,
				}).start();



				$(".introjs-helperLayer").on("mouseover", function(e){
					introJs().exit();
				});
			});
			

		

		      $("#typer").css({whiteSpace: "pre"}).typed({
		        strings: ["O..^1000hey.", "Say hey to O..hey.", 
		         "It's a simple blogging \nplatform built with ❤.",  
		        "Multiple Blogs.\nMultiple Collaborators.\n Autosave everything.",
		        "So..^1000try it out dude."],
		         typeSpeed: 150, // typing speed
		         loop: true,
        		 backDelay: 1000 // pause before backspacing
		      });
			}
		},
		init : function(){
			var that = this;
			//auto resize textareas
			$('textarea.autosize').autosize({append : "\n\n"});
			//bs tabs click first
   			 $('#settingsTabs li > a:first').tab('show');
   			 //zeroclipboard
   			$(".zeroClipboard").each(function(){
   				  new ZeroClipboard($(this));
   			  });
   			 //bs tooltips
   			this.reloadTooltip();

   			//masonry
   			if ($(".masonry").length){
   				$('.masonry').masonry({
				  itemSelector: '.box',
				  columnWidth: 50
				});
   			}
   			//fake submits init
   			this.fakeSubmitsInit();
   			//leftDrawer init
   			this.leftDrawerInit();
   			//homepage init
   			this.homeInit();
   			 //settings init
   			 this.settingsInit();
   			 //blogs init
   			 this.blogInit();
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