/*
 * jQuery Impromptu
 * By: Trent Richardson [http://trentrichardson.com]
 * Version 1.0
 * Last Modified: 9/6/2007
 * 
 * Copyright 2007 Trent Richardson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
jQuery.extend({	
	ImpromptuDefaults: { prefix:'jqi', buttons:{ Ok:true }, submit:function(){return true;}, callback:function(){}, container:'body', opacity:0.6, overlayspeed:'slow', promptspeed:'fast', show:'show'},
	SetImpromptuDefaults: function(o){ 
		jQuery.ImpromptuDefaults = jQuery.extend({},jQuery.ImpromptuDefaults,o);
	},
	prompt: function(m,o){
		o = jQuery.extend({},jQuery.ImpromptuDefaults,o);
		
		var ie6 = (jQuery.browser.msie && jQuery.browser.version < 7);	
		var b = jQuery(o.container);		
		var fade = '<div class="'+ o.prefix +'fade" id="'+ o.prefix +'fade"></div>';
		var msgbox = '<div class="'+ o.prefix +'" id="'+ o.prefix +'"><div class="'+ o.prefix +'container"><div class="'+ o.prefix +'message">'+ m +'</div><div class="'+ o.prefix +'buttons" id="'+ o.prefix +'buttons">';
		jQuery.each(o.buttons,function(k,v){ msgbox += '<button name="'+ o.prefix +'button'+ k +'" id="'+ o.prefix +'button'+ k +'" value="'+ v +'">'+ k +'</button>'}) ;
		msgbox += '</div></div></div>';
		
		var jqi = b.prepend(msgbox).children('#'+ o.prefix);
		var jqif = b.prepend(fade).children('#'+ o.prefix +'fade');
				
		if(ie6) b.css({ overflow: "hidden" }).find("select").css({ visibility: "hidden" });//ie6
		jqif.css({ height: b.height(), width: b.width(), position: "absolute", top: 0, left: 0, right: 0, bottom: 0, zIndex: 998, display: "none", opacity: o.opacity });
		jqi.css({ position: (ie6)? "absolute" : "fixed", top: "30%", left: "50%", display: "none", zIndex: 999, marginLeft: ((((jqi.css("paddingLeft").split("px")[0]*1) + jqi.width())/2)*-1) });
		
		jQuery('#'+ o.prefix +'buttons').children('button').click(function(){ 
			var msg = jqi.children('.'+ o.prefix +'container').children('.'+ o.prefix +'message');
			var clicked = o.buttons[jQuery(this).text()];	
			if(o.submit(clicked,msg)){		
				jqi.remove(); 
				jqif.fadeOut(o.overlayspeed,function(){
					jqif.remove();
					if(ie6) b.css({ overflow: "auto" }).find("select").css({ visibility: "visible" });//ie6
					o.callback(clicked,msg);
				});
			}
		});
		
		jqif.fadeIn(o.overlayspeed);
		jqi[o.show](o.promptspeed);
		return jqi;	
	}	
});