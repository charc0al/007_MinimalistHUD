package knt.hud.buttonprompts
{
   import flash.display.MovieClip;
   import flash.filters.DropShadowFilter;
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.Localization;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class NPCCombatPromptsWidget extends BaseControl
   {
      
      public static const TYPE_INVALID:int = 0;
      
      public static const TYPE_SILENT_TAKEDOWN:int = 1;
      
      public static const TYPE_MELEE_FINISHER:int = 2;
      
      public static const TYPE_AGENCY_FINISHER:int = 3;
      
      public static const TYPE_GRAB:int = 4;
      
      public static const TYPE_ESCAPE_DETAIN:int = 5;
      
      public static const TYPE_BLUFF:int = 6;
      
      public static const TYPE_CONFRONTATION_OPT_IN:int = 7;
      
      public static const TYPE_COMBAT_RUSH:int = 8;
      
      public static const TYPE_FAKE_SURRENDER:int = 9;
      
      public static const TYPE_QUICK_DISTRACT:int = 10;
      
      public static const TYPE_IMPERSONATION:int = 11;
      
      public static const TYPE_PARTIAL_PARRY:int = 12;
      
      public static const TYPE_PERFECT_PARRY:int = 13;
      
      public static const TYPE_FAKE_SURRENDER_MELEE_FINISHER:int = 14;
      
      public static const TYPE_ESCORTED_OUT:int = 15;
      
      public static const TYPE_LURE:int = 16;
      
      public static const TYPE_DIALOGUE:int = 17;
      
      public static const DIALOGUE_FLAVOR:int = 0;
      
      public static const DIALOGUE_MISSION:int = 1;
      
      public static const DIALOGUE_EXIT:int = 2;
      
      public static const BACK_NONE:int = 0;
      
      public static const BACK_TAKEDOWN:int = 1;
      
      public static const BACK_COMBO:int = 2;
      
      public static const BACK_COMBO_AGENCY:int = 3;
      
      public static const BACK_CONFRONT:int = 4;
      
      public static const BACK_PARTIAL_PARRY:int = 5;
      
      public static const BACK_PERFECT_PARRY:int = 6;
      
      private static const TAKEDOWN_TEXT_COLOR:String = "#FF8888";
      
      private static const TEXT_X_POS:Number = 22;
      
      private static const TEXT_X_POS_BLOCKED:Number = 38;
      
      private static const TEXT_Y_POS_SINGLE:Number = -15;
      
      private static const TEXT_Y_POS_MULTILINE:Number = -25;
      
      private static const TITLE_SHADOW_EXTRA_WIDTH:int = 60;
      
      private static const DESC_SHADOW_EXTRA_WIDTH:int = 40;
      
      private static const PROMPT_ICON_SCALE:Number = 30 / 36;
      
      private static const PROMPT_SCALE_MULTIPLIER:Number = 0.8;
      
      private static const PERF_PARRY_PREBUFFER:Number = 0.01;
      
      private static const SHOW_PROMPT_HIGHLIGHTS:Boolean = false;
      
      private const PROMPTS_PER_COMBO:int = 2;
      
      private var m_view:NPCCombatPromptsWidgetView;
      
      private var m_buttonClips:Vector.<MovieClip>;
      
      private var m_promptShowDirectionAtEdge:Boolean = false;
      
      private var m_promptDirectionAnimating:Boolean = false;
      
      private var m_promptBackCanBeAligned:Boolean = false;
      
      private var m_isBlocked:Boolean = false;
      
      private var m_isIllegal:Boolean = false;
      
      private var m_hasDescription:Boolean = false;
      
      private var m_perfParryTime:Number = -1;
      
      private var m_PerfParryDuration:Number = -1;
      
      private var m_holdArrowAnimCalled:Boolean = false;
      
      public var m_promptType:int;
      
      public function NPCCombatPromptsWidget()
      {
         var _loc1_:ButtonPromptImage = null;
         var _loc3_:MovieClip = null;
         this.m_buttonClips = new Vector.<MovieClip>();
         super();
         this.m_view = new NPCCombatPromptsWidgetView();
         addChild(this.m_view);
         this.promptBackground(BACK_NONE);
         this.m_view.button_mc.direction_mc.visible = false;
         this.m_view.button_mc.highlight_mc.visible = false;
         this.m_view.button_mc.parry_mc.visible = false;
         this.m_view.button_mc.agency_mc.filters = [new DropShadowFilter(1,45,0,0.9,2,2,0.75,3)];
         this.m_view.button_mc.dialogue_exit_mc.filters = [new DropShadowFilter(1,45,0,0.9,2,2,0.75,3)];
         this.m_view.button_mc.dialogue_mission_mc.filters = [new DropShadowFilter(1,45,0,0.9,2,2,0.75,3)];
         this.m_view.button_mc.title_txt.y = -15;
         this.m_view.button_mc.shadows_mc.title_shadow_mc.y = 0;
         this.m_view.button_mc.status_txt.alpha = 0.88;
         MenuUtils.setColor(this.m_view.button_mc.dialogue_mission_mc.inner_mc,MenuConstantsKnt.COLOR_OBJECTIVE,true,1);
         this.m_view.button_mc.visible = false;
         var _loc2_:int = 0;
         while(_loc2_ < this.PROMPTS_PER_COMBO)
         {
            _loc3_ = this.m_view.button_mc.getChildByName("prompt" + String(_loc2_ + 1) + "_mc") as MovieClip;
            _loc3_.hold_mc.visible = false;
            _loc3_.hold_arrow_mc.visible = false;
            _loc1_ = new ButtonPromptImage();
            _loc3_.prompt = _loc3_.promptHolder_mc.addChild(_loc1_);
            _loc3_.prompt.platform = ControlsMain.getControllerType();
            _loc3_.visible = false;
            _loc2_++;
         }
         this.m_view.visible = false;
         this.m_view.alpha = 0;
         this.m_view.button_mc.shadows_mc.alpha = 0.8;
         this.m_view.button_mc.shadows_mc.prompt_shadow_mc.visible = false;
         this.m_view.button_mc.shadows_mc.combo_shadow_mc.visible = false;
         this.m_view.button_mc.shadows_mc.title_shadow_mc.visible = false;
         this.m_view.button_mc.shadows_mc.status_shadow_mc.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         if(!param1.m_prompts.length || !param1.m_prompts[0].m_promptData.length || !param1.m_prompts[0].isVisible || param1.m_prompts[0].m_promptType == TYPE_PERFECT_PARRY || param1.m_prompts[0].m_promptType == TYPE_PARTIAL_PARRY || param1.m_prompts[0].m_promptType == TYPE_COMBAT_RUSH)
         {
            this.m_view.visible = false;
            this.m_view.alpha = 0;
            this.m_view.button_mc.combo_mc.gotoAndStop(1);
            Animate.kill(this.m_view.button_mc.direction_mc.arrow_mc);
            Animate.kill(this.m_view.button_mc.parry_mc.parryTimingRing_mc);
            Animate.kill(this.m_view.button_mc.parry_mc.back_mc);
            this.promptBackground(BACK_NONE);
            return;
         }
         var _loc2_:String = "right";
         this.m_promptType = param1.m_prompts[0].m_promptType;
         if(param1.confrontationMultiPromptIndex != null)
         {
            if(param1.confrontationMultiPromptIndex == 0 || param1.confrontationMultiPromptIndex == 1)
            {
               _loc2_ = "left";
            }
         }
         if(param1.confrontationMultiPromptIndex == null && Boolean(param1.m_prompts[0].m_promptData[0].isEnabled))
         {
            if(this.m_promptType == TYPE_CONFRONTATION_OPT_IN && !param1.lastSetHadAConfrontPrompt)
            {
               CommonUtils.playSound(this,"UI_HUD_Confrontation_ShowPrompt");
               this.animatePromptHighlight();
            }
         }
         if(this.m_promptType == TYPE_PERFECT_PARRY || this.m_promptType == TYPE_PARTIAL_PARRY)
         {
            if(this.m_promptType == TYPE_PERFECT_PARRY)
            {
               this.m_perfParryTime = param1.m_prompts[0].m_timedEventStartTime - param1.m_prompts[0].m_animStartTime;
               this.m_PerfParryDuration = param1.m_prompts[0].m_timedEventEndTime - param1.m_prompts[0].m_timedEventStartTime;
            }
            if(param1.m_prompts[0].m_isSpecial === true)
            {
               this.m_view.scaleX = this.m_view.scaleY = 1.8;
            }
            else
            {
               this.m_view.scaleX = this.m_view.scaleY = 1.5;
            }
         }
         else
         {
            this.m_view.scaleX = this.m_view.scaleY = 1;
            this.m_view.button_mc.parry_mc.visible = false;
         }
         if(param1.m_prompts[0].m_requiresHoldInput)
         {
            param1.m_prompts[0].m_promptData[0].aElements[0].showProgress = true;
            param1.m_prompts[0].m_promptData[0].aElements[0].progress = param1.m_prompts[0].m_holdInputProgress;
         }
         this.showActionButton(param1.m_prompts[0].m_promptData[0],param1.m_agencyData,this.m_promptType,_loc2_,Boolean(param1.m_prompts[0].m_isTapping) && this.m_promptType == TYPE_ESCAPE_DETAIN,param1.m_prompts[0].m_isAgencyPrompt,param1.m_prompts[0].m_label,param1.m_prompts[0].m_blockedLabel != null ? param1.m_prompts[0].m_blockedLabel : "",param1.m_prompts[0].m_iconID != null ? param1.m_prompts[0].m_iconID : "",param1.m_prompts[0].m_conversationChoiceType);
         this.m_view.visible = true;
         this.m_view.alpha = 1;
      }
      
      private function showActionButton(param1:Object, param2:Object, param3:int, param4:String, param5:Boolean, param6:Boolean, param7:String, param8:String, param9:String, param10:int) : void
      {
         var _loc14_:Object = null;
         var _loc15_:MovieClip = null;
         var _loc16_:int = 0;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc11_:* = param1.aElements.length > 0;
         var _loc12_:Boolean = param7 != null && param7 != "" && param7 != " ";
         var _loc13_:Boolean = param9 != "" && param3 != TYPE_CONFRONTATION_OPT_IN;
         param6 &&= param3 != TYPE_CONFRONTATION_OPT_IN;
         this.m_hasDescription = false;
         this.m_view.button_mc.agency_mc.visible = param6;
         if(param6)
         {
            MenuUtils.setTint(this.m_view.button_mc.agency_mc.inner_mc,param1.isEnabled ? uint(MenuConstantsKnt.COLOR_AGENCY) : uint(MenuConstantsKnt.COLOR_GREY_MEDIUM));
         }
         this.m_view.button_mc.combo_mc.gotoAndStop(1);
         this.m_view.button_mc.direction_mc.visible = false;
         Animate.kill(this.m_view.button_mc.direction_mc.arrow_mc);
         Animate.kill(this.m_view.button_mc.parry_mc.parryTimingRing_mc);
         Animate.kill(this.m_view.button_mc.parry_mc);
         this.m_view.button_mc.visible = true;
         this.m_view.button_mc.blocked_mc.visible = false;
         this.m_view.button_mc.illegal_mc.visible = false;
         if(_loc11_)
         {
            _loc16_ = 0;
            while(_loc16_ < this.PROMPTS_PER_COMBO)
            {
               _loc15_ = this.m_view.button_mc.getChildByName("prompt" + String(_loc16_ + 1) + "_mc") as MovieClip;
               if(_loc16_ < param1.aElements.length)
               {
                  _loc14_ = param1.aElements[_loc16_];
                  _loc15_.prompt.platform = param1.controllerType;
                  _loc15_.promptHolder_mc.scaleX = _loc15_.promptHolder_mc.scaleY = (_loc15_.prompt.platform == "key" ? 0.75 : PROMPT_ICON_SCALE) * PROMPT_SCALE_MULTIPLIER;
                  if((_loc15_.prompt.platform == CommonUtils.CONTROLLER_TYPE_KEY || _loc14_.iconId == -1) && _loc14_.keyGlyph != "")
                  {
                     _loc15_.prompt.customKey = _loc14_.keyGlyph;
                  }
                  else
                  {
                     _loc15_.prompt.button = _loc14_.iconId;
                  }
                  MenuUtils.addColorFilter(_loc15_.prompt,[MenuConstantsKnt.COLOR_MATRIX_INVERTED]);
                  if(_loc14_.showProgress)
                  {
                     if(_loc14_.invertColor)
                     {
                        if(!this.m_holdArrowAnimCalled)
                        {
                           Animate.kill(_loc15_.hold_arrow_mc.inner_mc);
                           Animate.to(_loc15_.hold_arrow_mc.inner_mc,0.6,0,{"y":-16},Animate.ExpoOut);
                           this.m_holdArrowAnimCalled = true;
                        }
                     }
                     else if(this.m_holdArrowAnimCalled)
                     {
                        Animate.kill(_loc15_.hold_arrow_mc.inner_mc);
                        Animate.to(_loc15_.hold_arrow_mc.inner_mc,0.6,0,{"y":-18},Animate.ExpoOut);
                        this.m_holdArrowAnimCalled = false;
                     }
                     _loc15_.hold_mc.visible = true;
                     _loc15_.hold_arrow_mc.visible = true;
                     _loc15_.hold_mc.progress_mc.gotoAndStop(Math.ceil(_loc14_.progress * 60));
                  }
                  else
                  {
                     if(this.m_holdArrowAnimCalled)
                     {
                        Animate.kill(_loc15_.hold_arrow_mc.inner_mc);
                        _loc15_.hold_arrow_mc.inner_mc.y = -18;
                        this.m_holdArrowAnimCalled = false;
                     }
                     _loc15_.hold_mc.visible = false;
                     _loc15_.hold_arrow_mc.visible = false;
                  }
                  _loc15_.visible = true;
                  if(param5)
                  {
                     _loc15_.tap_mc.visible = true;
                     _loc15_.tap_mc.gotoAndPlay(2);
                  }
                  else
                  {
                     _loc15_.tap_mc.visible = false;
                     _loc15_.tap_mc.gotoAndStop(1);
                  }
                  if(param1.isEnabled)
                  {
                     MenuUtils.removeColor(_loc15_);
                  }
                  else
                  {
                     MenuUtils.setColor(_loc15_,MenuConstantsKnt.COLOR_GREY_DARK,false,1,0.7);
                  }
               }
               else
               {
                  _loc15_.visible = false;
               }
               _loc16_++;
            }
         }
         if(_loc12_ || param6 || _loc13_)
         {
            this.m_promptBackCanBeAligned = true;
            _loc18_ = this.getPromptTextColor(param3);
            if(_loc12_)
            {
               MenuUtils.setupText(this.m_view.button_mc.title_txt,param7,21,MenuConstantsKnt.FONT_TYPE_MEDIUM,_loc18_);
               this.m_view.button_mc.title_txt.alpha = param1.isEnabled ? 1 : 0.6;
               this.m_view.button_mc.shadows_mc.title_shadow_mc.width = this.m_view.button_mc.title_txt.textWidth + TITLE_SHADOW_EXTRA_WIDTH;
               this.m_view.button_mc.shadows_mc.title_shadow_mc.x = this.m_view.button_mc.title_txt.x + this.m_view.button_mc.title_txt.textWidth / 2;
            }
            else
            {
               this.m_view.button_mc.title_txt.text = "";
            }
            _loc17_ = "";
            if(param1.sDescription != null && param1.sDescription != "")
            {
               _loc17_ = param1.sDescription;
            }
            else if(_loc13_ && param9 == "wary" && param3 == TYPE_BLUFF)
            {
               _loc17_ = Localization.get("UI_Interaction_Illegal_WatcherNearby");
            }
            else if(_loc13_ && param9 == "bluffed")
            {
               _loc17_ = "BLUFFED**";
            }
            else if(param6 && param3 == TYPE_BLUFF && param2.playerChunks < param2.bluffTier0Cost)
            {
               _loc17_ = Localization.get("UI_Interaction_NoAgency");
            }
            this.m_hasDescription = _loc17_ != "";
            this.m_isBlocked = param1.bBlocked === true || !param1.isEnabled && this.m_hasDescription;
            this.m_view.button_mc.blocked_mc.visible = this.m_isBlocked;
            if(this.m_hasDescription)
            {
               MenuUtils.setupText(this.m_view.button_mc.status_txt,_loc17_,18,MenuConstantsKnt.FONT_TYPE_NORMAL,_loc18_);
               this.m_view.button_mc.shadows_mc.status_shadow_mc.width = this.m_view.button_mc.status_txt.textWidth + DESC_SHADOW_EXTRA_WIDTH;
               this.m_view.button_mc.shadows_mc.status_shadow_mc.x = this.m_view.button_mc.status_txt.x + this.m_view.button_mc.status_txt.textWidth / 2;
               this.m_view.button_mc.shadows_mc.status_shadow_mc.visible = true;
               this.m_view.button_mc.title_txt.y = -25;
               this.m_view.button_mc.shadows_mc.title_shadow_mc.y = -10;
            }
            else
            {
               MenuUtils.setupText(this.m_view.button_mc.status_txt,"",18,MenuConstantsKnt.FONT_TYPE_NORMAL,_loc18_);
               this.m_view.button_mc.status_txt.visible = false;
               this.m_view.button_mc.shadows_mc.status_shadow_mc.visible = false;
               this.m_view.button_mc.title_txt.y = -15;
               this.m_view.button_mc.shadows_mc.title_shadow_mc.y = 0;
            }
            this.setPromptAlignment(param4);
            this.promptBackground(BACK_NONE);
         }
         this.m_view.button_mc.title_txt.visible = _loc12_;
         this.m_view.button_mc.shadows_mc.title_shadow_mc.visible = _loc12_;
         if(param3 == TYPE_DIALOGUE)
         {
            this.m_view.button_mc.dialogue_mission_mc.visible = param10 === DIALOGUE_MISSION;
            this.m_view.button_mc.dialogue_exit_mc.visible = param10 === DIALOGUE_EXIT;
         }
         else
         {
            this.m_view.button_mc.dialogue_mission_mc.visible = false;
            this.m_view.button_mc.dialogue_exit_mc.visible = false;
         }
         if(param1.aElements.length > 1)
         {
            this.m_view.button_mc.combo_mc.visible = true;
            this.m_view.button_mc.comboagency_mc.visible = false;
            this.m_view.button_mc.shadows_mc.prompt_shadow_mc.visible = false;
            this.m_view.button_mc.shadows_mc.combo_shadow_mc.visible = true;
            this.m_promptBackCanBeAligned = false;
            if(param3 == TYPE_MELEE_FINISHER)
            {
               this.m_view.button_mc.combo_mc.gotoAndPlay("anim");
               this.m_view.button_mc.combo_mc.rotation = 225;
               this.m_view.button_mc.prompt2_mc.x = 32;
               this.m_view.button_mc.prompt2_mc.y = 32;
               this.m_view.button_mc.combo_mc.scaleX = this.m_view.button_mc.combo_mc.scaleY = 1;
               this.m_view.button_mc.combo_mc.x = 0;
               this.m_view.button_mc.shadows_mc.combo_shadow_mc.rotation = 225;
            }
            else if(param3 == TYPE_COMBAT_RUSH)
            {
               this.m_view.button_mc.combo_mc.gotoAndStop(1);
               this.m_view.button_mc.combo_mc.rotation = 180;
               this.m_view.button_mc.prompt2_mc.x = 44;
               this.m_view.button_mc.prompt2_mc.y = 0;
               this.m_view.button_mc.combo_mc.scaleX = this.m_view.button_mc.combo_mc.scaleY = param1.controllerType == "key" ? 1.1 : 1;
               this.m_view.button_mc.combo_mc.x = param1.controllerType == "key" ? -6 : 0;
               this.m_view.button_mc.shadows_mc.combo_shadow_mc.rotation = 180;
            }
            else
            {
               this.m_view.button_mc.combo_mc.gotoAndStop(1);
               this.m_view.button_mc.combo_mc.rotation = 0;
               this.m_view.button_mc.prompt2_mc.x = -44;
               this.m_view.button_mc.prompt2_mc.y = 0;
               this.m_view.button_mc.combo_mc.scaleX = this.m_view.button_mc.combo_mc.scaleY = 1;
               this.m_view.button_mc.combo_mc.x = 0;
               this.m_view.button_mc.shadows_mc.combo_shadow_mc.rotation = 0;
            }
            this.promptBackground(BACK_NONE);
         }
         else
         {
            this.m_view.button_mc.combo_mc.visible = this.m_view.button_mc.comboagency_mc.visible = false;
            this.m_view.button_mc.combo_mc.gotoAndStop(1);
            this.m_view.button_mc.shadows_mc.prompt_shadow_mc.visible = true;
            this.m_view.button_mc.shadows_mc.combo_shadow_mc.visible = false;
            if(param3 == TYPE_CONFRONTATION_OPT_IN)
            {
               this.promptBackground(BACK_CONFRONT);
            }
            else if(param3 == TYPE_SILENT_TAKEDOWN || param3 == TYPE_MELEE_FINISHER)
            {
               this.promptBackground(BACK_TAKEDOWN);
            }
            else if(param3 == TYPE_PARTIAL_PARRY)
            {
               this.promptBackground(BACK_PARTIAL_PARRY);
            }
            else if(param3 == TYPE_PERFECT_PARRY)
            {
               this.promptBackground(BACK_PERFECT_PARRY);
            }
            else
            {
               this.promptBackground(BACK_NONE);
            }
            this.m_view.button_mc.combo_mc.gotoAndStop(1);
         }
      }
      
      private function promptBackground(param1:int) : void
      {
         var backType:int = param1;
         this.m_view.button_mc.anim_mc.visible = false;
         this.m_view.button_mc.anim_mc.gotoAndStop(0);
         MenuUtils.removeColor(this.m_view.button_mc.anim_mc);
         if(backType == BACK_PARTIAL_PARRY)
         {
            this.m_view.button_mc.parry_mc.visible = true;
            this.m_view.button_mc.parry_mc.parryTimingRing_mc.visible = false;
            this.m_view.button_mc.parry_mc.back_mc.scaleX = this.m_view.button_mc.parry_mc.back_mc.scaleY = 0.45;
            MenuUtils.removeColor(this.m_view.button_mc.parry_mc.back_mc);
         }
         else if(backType == BACK_PERFECT_PARRY)
         {
            this.m_view.button_mc.parry_mc.parryTimingRing_mc.visible = true;
            this.m_view.button_mc.parry_mc.back_mc.scaleX = this.m_view.button_mc.parry_mc.back_mc.scaleY = 0.45;
            MenuUtils.removeColor(this.m_view.button_mc.parry_mc.back_mc);
            if(this.m_PerfParryDuration > 0)
            {
               Animate.fromTo(this.m_view.button_mc.parry_mc.parryTimingRing_mc,this.m_perfParryTime - PERF_PARRY_PREBUFFER,0,{"frames":100},{"frames":1},Animate.Linear,function():void
               {
                  m_view.button_mc.parry_mc.parryTimingRing_mc.visible = false;
               });
               Animate.delay(this.m_view.button_mc.parry_mc.back_mc,this.m_perfParryTime - PERF_PARRY_PREBUFFER,function():void
               {
                  MenuUtils.setColor(m_view.button_mc.parry_mc.back_mc,MenuConstantsKnt.COLOR_YELLOW,true);
                  Animate.delay(m_view.button_mc.parry_mc.back_mc,m_PerfParryDuration,function():void
                  {
                     MenuUtils.removeColor(m_view.button_mc.parry_mc.back_mc);
                  });
               });
            }
            this.m_view.button_mc.parry_mc.scaleX = this.m_view.button_mc.parry_mc.scaleY = 1;
            this.m_view.button_mc.parry_mc.visible = true;
         }
         else
         {
            this.m_view.button_mc.parry_mc.visible = false;
         }
         this.m_view.x = backType == BACK_COMBO || backType == BACK_COMBO_AGENCY ? 16 : 0;
      }
      
      private function getPromptTextColor(param1:int) : String
      {
         if(param1 == TYPE_SILENT_TAKEDOWN || param1 == TYPE_MELEE_FINISHER || param1 == TYPE_FAKE_SURRENDER_MELEE_FINISHER)
         {
            return TAKEDOWN_TEXT_COLOR;
         }
         return MenuConstantsKnt.FontColorWhite;
      }
      
      public function setPromptAlignment(param1:String) : void
      {
         if(!this.m_promptBackCanBeAligned)
         {
            return;
         }
         if(param1 == "right" && this.m_hasDescription)
         {
            this.m_view.button_mc.title_txt.x = TEXT_X_POS;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.width = this.m_view.button_mc.title_txt.textWidth + TITLE_SHADOW_EXTRA_WIDTH;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.x = this.m_view.button_mc.title_txt.x + this.m_view.button_mc.title_txt.textWidth / 2;
            this.m_view.button_mc.status_txt.x = this.m_isBlocked || this.m_isIllegal ? TEXT_X_POS_BLOCKED : TEXT_X_POS;
            this.m_view.button_mc.shadows_mc.status_shadow_mc.width = this.m_view.button_mc.status_txt.textWidth + DESC_SHADOW_EXTRA_WIDTH;
            this.m_view.button_mc.shadows_mc.status_shadow_mc.x = this.m_view.button_mc.status_txt.x + this.m_view.button_mc.status_txt.textWidth / 2;
         }
         else if(param1 == "right" && !this.m_hasDescription)
         {
            this.m_view.button_mc.title_txt.x = TEXT_X_POS;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.width = this.m_view.button_mc.title_txt.textWidth + TITLE_SHADOW_EXTRA_WIDTH;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.x = this.m_view.button_mc.title_txt.x + this.m_view.button_mc.title_txt.textWidth / 2;
         }
         else if(param1 == "left" && this.m_hasDescription)
         {
            this.m_view.button_mc.title_txt.x = -TEXT_X_POS - this.m_view.button_mc.title_txt.textWidth;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.width = this.m_view.button_mc.title_txt.textWidth + TITLE_SHADOW_EXTRA_WIDTH;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.x = this.m_view.button_mc.title_txt.x + this.m_view.button_mc.title_txt.textWidth / 2;
            this.m_view.button_mc.status_txt.x = -(this.m_isBlocked || this.m_isIllegal ? TEXT_X_POS_BLOCKED : TEXT_X_POS) - this.m_view.button_mc.status_txt.textWidth - 8;
            this.m_view.button_mc.shadows_mc.status_shadow_mc.width = this.m_view.button_mc.status_txt.textWidth + DESC_SHADOW_EXTRA_WIDTH;
            this.m_view.button_mc.shadows_mc.status_shadow_mc.x = this.m_view.button_mc.status_txt.x + this.m_view.button_mc.status_txt.textWidth / 2;
         }
         else if(param1 == "left" && !this.m_hasDescription)
         {
            this.m_view.button_mc.title_txt.x = -TEXT_X_POS - this.m_view.button_mc.title_txt.textWidth;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.width = this.m_view.button_mc.title_txt.textWidth + TITLE_SHADOW_EXTRA_WIDTH;
            this.m_view.button_mc.shadows_mc.title_shadow_mc.x = this.m_view.button_mc.title_txt.x + this.m_view.button_mc.title_txt.textWidth / 2;
         }
         this.m_view.button_mc.agency_mc.x = this.m_view.button_mc.dialogue_exit_mc.x = this.m_view.button_mc.dialogue_mission_mc.x = (param1 == "right" ? 1 : -1) * (TEXT_X_POS + this.m_view.button_mc.title_txt.textWidth + 10);
         this.m_view.button_mc.agency_mc.y = this.m_view.button_mc.dialogue_exit_mc.y = this.m_view.button_mc.dialogue_mission_mc.y = this.m_hasDescription ? -7 : 0;
         this.m_view.button_mc.title_txt.y = this.m_hasDescription ? TEXT_Y_POS_MULTILINE : TEXT_Y_POS_SINGLE;
         this.m_view.button_mc.blocked_mc.x = this.m_view.button_mc.illegal_mc.x = param1 == "right" ? 30 : -30;
      }
      
      public function setPromptDirectionMarker(param1:Number) : void
      {
         if(param1 < 0)
         {
            this.m_view.button_mc.direction_mc.visible = false;
            this.m_promptDirectionAnimating = false;
            Animate.kill(this.m_view.button_mc.direction_mc.arrow_mc);
            if(this.m_promptType == TYPE_CONFRONTATION_OPT_IN)
            {
               this.m_promptBackCanBeAligned = true;
               this.m_view.button_mc.title_txt.visible = true;
            }
            return;
         }
         this.m_view.button_mc.direction_mc.visible = true;
         if(!this.m_promptDirectionAnimating && this.m_promptShowDirectionAtEdge)
         {
            this.m_promptDirectionAnimating = true;
            this.m_view.button_mc.direction_mc.visible = true;
            this.animatePromptHighlight();
            this.animatePromptDirection();
            if(this.m_promptType == TYPE_CONFRONTATION_OPT_IN)
            {
               this.promptBackground(BACK_CONFRONT);
               this.m_promptBackCanBeAligned = false;
               this.m_view.button_mc.title_txt.visible = false;
            }
         }
         this.m_view.button_mc.direction_mc.rotation = param1;
      }
      
      private function animatePromptDirection(param1:Boolean = true) : void
      {
         Animate.to(this.m_view.button_mc.direction_mc.arrow_mc,param1 ? 0.2 : 0.4,param1 ? 0 : 0.1,{"y":(param1 ? -15 : 0)},param1 ? Animate.ExpoIn : Animate.ExpoOut,this.animatePromptDirection,!param1);
      }
      
      private function animatePromptHighlight() : void
      {
         if(!SHOW_PROMPT_HIGHLIGHTS)
         {
            this.m_view.button_mc.highlight_mc.visible = false;
            this.m_view.button_mc.highlight_mc.circle_mc.visible = false;
            return;
         }
         this.m_view.button_mc.highlight_mc.visible = true;
         this.m_view.button_mc.highlight_mc.circle_mc.visible = true;
         this.m_view.button_mc.highlight_mc.circle_mc.scaleX = this.m_view.button_mc.highlight_mc.circle_mc.scaleY = 0.2;
         this.m_view.button_mc.highlight_mc.circle_mc.alpha = 0.5;
         Animate.to(this.m_view.button_mc.highlight_mc.circle_mc,0.1,0,{
            "scaleX":1.5,
            "scaleY":1.5,
            "alpha":1
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.button_mc.highlight_mc.circle_mc,0.3,0,{
               "scaleX":0.5,
               "scaleY":0.5,
               "alpha":0.2
            },Animate.ExpoIn,function():void
            {
               m_view.button_mc.highlight_mc.circle_mc.visible = false;
            });
         });
      }
   }
}
