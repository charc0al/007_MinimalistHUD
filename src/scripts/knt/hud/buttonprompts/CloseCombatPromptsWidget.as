package knt.hud.buttonprompts
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.Localization;
   import glacier.common.menu.MenuConstants;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class CloseCombatPromptsWidget extends BaseControl
   {
      
      private const MAX_PROMPTS:int = 6;
      
      private var m_view:CloseCombatPromptsWidgetView;
      
      private var m_buttonClips:Vector.<MovieClip>;
      
      private var m_notUsedClips:Vector.<MovieClip>;
      
      private var m_textFields:Vector.<TextField>;
      
      private var m_takedown:Boolean = false;
      
      public function CloseCombatPromptsWidget()
      {
         var _loc1_:ButtonPromptImage = null;
         var _loc3_:MovieClip = null;
         var _loc4_:TextField = null;
         var _loc5_:MovieClip = null;
         this.m_buttonClips = new Vector.<MovieClip>();
         this.m_notUsedClips = new Vector.<MovieClip>();
         this.m_textFields = new Vector.<TextField>();
         super();
         this.m_view = new CloseCombatPromptsWidgetView();
         addChild(this.m_view);
         var _loc2_:int = 0;
         while(_loc2_ < this.MAX_PROMPTS)
         {
            _loc3_ = this.getButtonClip(_loc2_);
            _loc4_ = this.getTextField(_loc2_);
            MenuUtils.setupTextUpper(_loc4_,"",22,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
            _loc3_.hold_mc.visible = false;
            _loc1_ = new ButtonPromptImage();
            _loc3_.prompt = _loc3_.promptHolder_mc.addChild(_loc1_);
            _loc3_.prompt.platform = ControlsMain.getControllerType();
            _loc3_.visible = false;
            _loc4_.visible = false;
            this.m_buttonClips.push(_loc3_);
            this.m_textFields.push(_loc4_);
            if(_loc2_ < 4)
            {
               _loc5_ = this.getNotUsedClip(_loc2_);
               if(_loc5_ != null)
               {
                  _loc5_.visible = false;
                  this.m_notUsedClips.push(_loc5_);
               }
            }
            _loc2_++;
         }
         this.m_view.combo_mc.visible = this.m_view.combo_txt.visible = false;
         this.m_view.visible = false;
         this.m_view.alpha = 0;
      }
      
      public function onSetData(param1:Object) : void
      {
         var elements:Array;
         var anyButtonVisible:Boolean;
         var i:int;
         var h:int;
         var data:Object = null;
         var isTakedownButton:Boolean = false;
         var oData:Object = param1;
         if(!oData.isInCombat)
         {
            Animate.to(this.m_view,0.2,0,{"alpha":0},Animate.Linear,function():void
            {
               m_view.visible = false;
            });
            Animate.kill(this.m_view.combo_mc.outline_mc);
            return;
         }
         if(this.m_takedown != oData.isTakedownAvailable)
         {
            this.m_takedown = oData.isTakedownAvailable;
            this.m_view.combo_mc.visible = this.m_view.combo_txt.visible = this.m_takedown;
            this.m_view.combo_txt.text = Localization.toUpperCase(oData.takedownLabel);
            if(this.m_takedown)
            {
               this.comboButtonBlink(true);
            }
            else
            {
               Animate.kill(this.m_view.combo_mc.outline_mc);
            }
         }
         elements = oData.promptData;
         anyButtonVisible = false;
         i = 0;
         while(i < elements.length && i < this.MAX_PROMPTS)
         {
            data = elements[i];
            isTakedownButton = this.m_takedown && i <= 1;
            if(Boolean(data.isValid) || isTakedownButton)
            {
               this.showActionButton(i,data,isTakedownButton);
               anyButtonVisible = true;
               if(i < this.m_notUsedClips.length)
               {
                  this.m_notUsedClips[i].visible = false;
               }
            }
            else if(!data.isValid && i < this.m_notUsedClips.length)
            {
               this.showActionButton(i,data,false,true);
               this.m_notUsedClips[i].visible = true;
            }
            else
            {
               this.m_buttonClips[i].visible = false;
               this.m_textFields[i].visible = false;
               if(i < this.m_notUsedClips.length)
               {
                  this.m_notUsedClips[i].visible = true;
               }
            }
            i++;
         }
         h = int(elements.length);
         while(h < this.MAX_PROMPTS)
         {
            this.m_buttonClips[h].visible = false;
            this.m_textFields[h].visible = false;
            h++;
         }
         if(elements.length > 4 && Boolean(elements[4].isValid))
         {
            this.m_view.additional_mc.visible = true;
            this.m_view.additional_mc.x = 80 + this.m_textFields[3].textWidth;
            this.m_view.additional_mc.y = this.m_textFields[5].visible ? 16 : 0;
         }
         else
         {
            this.m_view.additional_mc.visible = false;
         }
         this.m_view.visible = true;
         Animate.to(this.m_view,0.2,0,{"alpha":1},Animate.Linear);
      }
      
      private function comboButtonBlink(param1:Boolean) : void
      {
         var on:Boolean = param1;
         Animate.to(this.m_view.combo_mc.outline_mc,0.03,0.15,{"alpha":(on ? 1 : 0)},Animate.Linear,function():void
         {
            comboButtonBlink(!on);
         });
      }
      
      private function showActionButton(param1:int, param2:Object, param3:Boolean, param4:Boolean = false) : void
      {
         var _loc5_:String = null;
         var _loc10_:Object = null;
         var _loc6_:Array = param2.labels = undefined ? [] : param2.labels;
         var _loc7_:MovieClip = this.m_buttonClips[param1];
         var _loc8_:TextField = this.m_textFields[param1];
         _loc7_.visible = true;
         _loc7_.promptHolder_mc.alpha = _loc8_.alpha = _loc7_.hold_mc.alpha = 1;
         if(Boolean(param2.isEnabled) && Boolean(param2.isValid))
         {
            MenuUtils.removeColor(_loc7_.promptHolder_mc);
         }
         else
         {
            MenuUtils.setColor(_loc7_.promptHolder_mc,MenuConstantsKnt.COLOR_GREY_DARK,false,1,0.7);
         }
         if(!param4)
         {
            _loc8_.visible = !param3;
            _loc5_ = this.getTitleStrings(param2.labels);
            _loc8_.htmlText = _loc5_;
         }
         else
         {
            _loc8_.visible = false;
         }
         var _loc9_:* = param2.prompt.aElements.length > 0;
         if(_loc9_)
         {
            _loc10_ = param2.prompt.aElements[0];
            _loc7_.prompt.platform = param2.prompt.controllerType;
            _loc7_.promptHolder_mc.scaleX = _loc7_.promptHolder_mc.scaleY = _loc7_.prompt.platform == "key" ? 0.8 : 1;
            if(_loc7_.prompt.platform == "key" || _loc10_.iconId == -1)
            {
               _loc7_.prompt.customKey = _loc10_.keyGlyph;
            }
            else
            {
               _loc7_.prompt.button = _loc10_.iconId;
            }
            if(!this.isAnyEnabled(param2.labels) && !(_loc10_.invertColor != null ? _loc10_.invertColor : false) && !param3)
            {
               MenuUtils.setTint(_loc7_.promptHolder_mc,MenuConstantsKnt.COLOR_GREY_MEDIUM);
            }
            else
            {
               MenuUtils.removeTint(_loc7_.promptHolder_mc);
            }
            if(_loc10_.showProgress)
            {
               _loc7_.hold_mc.visible = true;
               _loc7_.hold_mc.gotoAndStop(Math.ceil(_loc10_.progress * 60));
            }
            else
            {
               _loc7_.hold_mc.visible = false;
            }
         }
      }
      
      private function getTitleStrings(param1:Array) : String
      {
         var _loc2_:* = "";
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(_loc3_ > 0)
            {
               _loc2_ += " | ";
            }
            _loc2_ += "<font color=\"" + (param1[_loc3_].isEnabled ? MenuConstants.FontColorWhite : MenuConstants.FontColorGreyMedium) + "\">";
            _loc2_ += Localization.toUpperCase(param1[_loc3_].label);
            _loc2_ += "</font>";
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function isAnyEnabled(param1:Array) : Boolean
      {
         var _loc2_:Object = null;
         for each(_loc2_ in param1)
         {
            if(_loc2_.isEnabled)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getButtonClip(param1:int) : MovieClip
      {
         if(param1 < 4)
         {
            return this.m_view.getChildByName("button" + String(param1 + 1) + "_mc") as MovieClip;
         }
         return this.m_view.additional_mc.getChildByName("button" + String(param1 + 1) + "_mc") as MovieClip;
      }
      
      private function getNotUsedClip(param1:int) : MovieClip
      {
         return this.m_view.getChildByName("notInUse" + String(param1 + 1) + "_mc") as MovieClip;
      }
      
      private function getTextField(param1:int) : TextField
      {
         if(param1 < 4)
         {
            return this.m_view.getChildByName("title" + String(param1 + 1) + "_txt") as TextField;
         }
         return this.m_view.additional_mc.getChildByName("title" + String(param1 + 1) + "_txt") as TextField;
      }
   }
}

