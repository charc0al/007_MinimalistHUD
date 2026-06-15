package knt.hud.buttonprompts
{
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.hud.KntHudUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class ButtonPromptWidget extends BaseControl
   {
      
      public static const STATE_SELECTED:int = 0;
      
      public static const STATE_AVAILABLE:int = 1;
      
      public static const STATE_COLLAPSED:int = 2;
      
      public static const STATE_NOTAVAILABLE:int = 3;
      
      public static const BLOCKED_STATUS_NONE:int = 0;
      
      public static const BLOCKED_STATUS_BLOCKED:int = 1;
      
      public static const BLOCKED_STATUS_CANBEUNBLOCKED:int = 2;
      
      public static const AGGRESSION_LEVEL_NONE:int = 0;
      
      public static const AGGRESSION_LEVEL_SOFT:int = 1;
      
      public static const AGGRESSION_LEVEL_HARD:int = 2;
      
      private static const SHOW_PROMPT_HIGHLIGHTS:Boolean = false;
      
      private static const AGILITY_TYPE_VAULT_ATTACK:int = 5;
      
      private static const AGILITY_TYPE_ITEM_QUICK_THROW:int = 23;
      
      private static const AGILITY_TYPE_SWAP_COVER:int = 26;
      
      private static const TEXT_X_POS:Number = 22;
      
      private static const TEXT_X_POS_BLOCKED:Number = 37;
      
      private static const TEXT_Y_POS_SINGLE:Number = -13;
      
      private static const TEXT_Y_POS_MULTILINE:Number = -20;
      
      private static const TITLE_SHADOW_EXTRA_WIDTH:int = 60;
      
      private static const DESC_SHADOW_EXTRA_WIDTH:int = 40;
      
      private static const PROMPT_ICON_SCALE:Number = 30 / 36;
      
      private static const PROMPT_SCALE_MULTIPLIER:Number = 0.8;
      
      private static const PROMPT_X_SPACING:Number = 44;
      
      private static const AGENCY_ACTIONABLE_TEXT_COLOR:String = "#FFFFAA";
      
      public static const PLAYER_RESOURCETYPE_CHEMICAL:uint = 0;
      
      public static const PLAYER_RESOURCETYPE_ELECTRICAL:uint = 1;
      
      public static const RESOURCETYPE_ICON_XPOS:Number = -40;
      
      public static const RESOURCE_SHOWN_XPOS_OFFSET:int = 40;
      
      private var m_view:ButtonPromptWidgetView;
      
      private var m_promptInstances:Vector.<ButtonPromptImage> = new Vector.<ButtonPromptImage>();
      
      private var m_nextPromptInstanceIndex:int = 0;
      
      private var m_iconId:int = 0;
      
      private var m_manuallySetIconId:int = 0;
      
      private var m_actionKeyGlyph:String = "F";
      
      private var m_platform:String = "";
      
      private var m_debugIsActive:Boolean = false;
      
      private var m_debugText:String = "";
      
      private var m_data:Object = {};
      
      private var m_currentProgress:Number = 0;
      
      private var m_isCollectiblePrompt:Boolean = false;
      
      private var m_isAgencyPrompt:Boolean = false;
      
      private var m_isResourcePickUpPrompt:Boolean = false;
      
      private var m_resourceTypeShown:int = -1;
      
      private var m_eState:int = 3;
      
      private var m_aggressiveAnimRunning:Boolean = false;
      
      private var m_holdArrowAnimCalled:Boolean = false;
      
      private var m_newFormat:TextFormat = new TextFormat();
      
      public function ButtonPromptWidget()
      {
         super();
         this.m_view = new ButtonPromptWidgetView();
         addChild(this.m_view);
         this.m_view.title_mc.blocked_mc.visible = false;
         this.m_view.title_mc.illegal_mc.visible = false;
         this.m_view.title_mc.unblocked_mc.visible = false;
         MenuUtils.setColor(this.m_view.title_mc.blocked_mc.bg_mc,MenuConstantsKnt.COLOR_HUD_DANGER_MED);
         MenuUtils.setColor(this.m_view.title_mc.illegal_mc.bg_mc,MenuConstantsKnt.COLOR_HUD_DANGER_HIGH);
         MenuUtils.setColor(this.m_view.title_mc.unblocked_mc.bg_mc,MenuConstantsKnt.COLOR_GREEN_LEGAL_PROMPT);
         this.m_view.hold_mc.visible = false;
         this.m_view.hold_arrow_mc.visible = false;
         this.m_view.collectible_icon_mc.visible = false;
         this.m_view.collectible_icon_mc.filters = [new DropShadowFilter(1,45,0,0.9,2,2,0.75,3)];
         this.m_view.collectible_icon_mc.x = -40;
         this.m_view.collectible_icon_mc.bg_mc.alpha = 0.4;
         this.m_view.resource_icon_mc.visible = false;
         this.m_view.resource_icon_mc.chemical_icon_mc.visible = false;
         this.m_view.resource_icon_mc.electrical_icon_mc.visible = false;
         this.m_view.resource_icon_mc.bg_mc.alpha = 0.4;
         this.m_view.resource_icon_mc.x = 0;
         MenuUtils.setColor(this.m_view.resource_icon_mc.chemical_icon_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL,true);
         MenuUtils.setColor(this.m_view.resource_icon_mc.electrical_icon_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL,true);
         this.m_view.resource_icon_mc.filters = [new DropShadowFilter(1,45,0,0.9,2,2,0.75,3)];
         this.m_view.title_mc.title_txt.autoSize = this.m_view.title_mc.status_txt.autoSize = this.m_view.title_mc.description_txt.autoSize = TextFieldAutoSize.LEFT;
         this.m_view.title_mc.title_txt.y = -15;
         this.m_view.shadows_mc.title_shadow_mc.y = 0;
         this.m_view.title_mc.status_txt.alpha = 0.88;
         this.m_view.title_mc.description_txt.alpha = 0.74;
         this.m_view.collapsed_mc.visible = false;
         this.m_view.collapsed_mc.scaleX = this.m_view.collapsed_mc.scaleY = 0;
         this.m_view.promptHolder_mc.x = 0;
         KntHudUtils.addOutline(this.m_view.collapsed_mc.outline_mc);
         MenuUtils.setColor(this.m_view.collapsed_mc.fill_mc,MenuConstantsKnt.COLOR_GREY_ULTRA_LIGHT);
         this.m_view.anim_mc.visible = false;
         MenuUtils.setColor(this.m_view.anim_mc,MenuConstantsKnt.COLOR_HUD_DANGER_MED);
         this.m_view.shadows_mc.alpha = 0.8;
         this.m_view.shadows_mc.icons_shadow_mc.alpha = 0.6;
         this.m_view.shadows_mc.icons_shadow_mc.visible = false;
         this.m_view.shadows_mc.prompt_shadow_mc.visible = false;
         this.m_view.shadows_mc.combo_shadow_mc.visible = false;
         this.m_view.shadows_mc.title_shadow_mc.visible = false;
         this.m_view.shadows_mc.status_shadow_mc.visible = false;
         this.m_view.shadows_mc.description_shadow_mc.visible = false;
         this.m_newFormat.letterSpacing = 1.3;
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         this.visible = param1;
         if(param1 && this.m_data != null)
         {
            this.onSetData(this.m_data);
         }
         else if(!param1)
         {
            this.showResourceType(false,-1);
         }
      }
      
      public function onSetData(param1:Object) : void
      {
         this.m_data = param1;
         this.visible = true;
         if(this.shouldHideAgilityPromptCompletely(param1))
         {
            this.releaseAllPromptInstances();
            this.m_view.combo_mc.visible = false;
            this.m_view.shadows_mc.combo_shadow_mc.visible = false;
            this.m_view.hold_mc.visible = false;
            this.m_view.hold_arrow_mc.visible = false;
            this.m_view.title_mc.title_txt.visible = false;
            this.m_view.title_mc.status_txt.visible = false;
            this.m_view.title_mc.description_txt.visible = false;
            this.m_view.title_mc.blocked_mc.visible = false;
            this.m_view.title_mc.illegal_mc.visible = false;
            this.m_view.title_mc.unblocked_mc.visible = false;
            this.m_view.shadows_mc.prompt_shadow_mc.visible = false;
            this.m_view.shadows_mc.title_shadow_mc.visible = false;
            this.m_view.shadows_mc.status_shadow_mc.visible = false;
            this.m_view.shadows_mc.description_shadow_mc.visible = false;
            this.showCollectibleIcon(false);
            this.showResourceType(false,-1);
            this.setStateNotAvailable(param1);
            return;
         }
         this.m_view.combo_mc.visible = false;
         this.m_view.shadows_mc.combo_shadow_mc.visible = false;
         switch(param1.eState)
         {
            case STATE_SELECTED:
               this.setStateSelected(param1);
               break;
            case STATE_AVAILABLE:
               if(param1.eAgilityType != AGILITY_TYPE_SWAP_COVER)
               {
                  this.setStateAvailable(param1);
               }
               else
               {
                  param1.eBlockedStatus = BLOCKED_STATUS_BLOCKED;
                  this.setStateSelected(param1);
               }
               break;
            case STATE_COLLAPSED:
               this.setStateCollapsed(param1);
               break;
            case STATE_NOTAVAILABLE:
               this.setStateNotAvailable(param1);
               break;
            default:
               this.setStateSelected(param1);
         }
         this.syncResourceIconSuppression();
         this.m_eState = param1.eState;
      }
      
      private function setStateSelected(param1:Object) : void
      {
         var agilityDebugPrefix:String = null;
         var crushedPromptTitle:String = null;
         var promptDebugSuffix:String = null;
         var _loc12_:String = null;
         var _loc13_:Boolean = false;
         var _loc14_:ButtonPromptImage = null;
         var _loc15_:Boolean = false;
         var _loc16_:int = 0;
         var _loc17_:ButtonPromptImage = null;
         var _loc18_:* = undefined;
         var _loc19_:ButtonPromptImage = null;
         var _loc20_:ButtonPromptImage = null;
         if(param1 == null || param1.aElements == null || param1.aElements.length < 1)
         {
            return;
         }
         Animate.kill(this.m_view.collapsed_mc);
         this.m_view.collapsed_mc.visible = false;
         if(this.m_aggressiveAnimRunning)
         {
            this.m_view.anim_mc.visible = false;
            this.m_view.anim_mc.gotoAndStop(0);
            this.m_aggressiveAnimRunning = false;
         }
         this.m_isAgencyPrompt = param1.bIsAgencyPrompt;
         var _loc2_:* = param1.eBlockedStatus === BLOCKED_STATUS_BLOCKED;
         var _loc3_:* = param1.eBlockedStatus === BLOCKED_STATUS_CANBEUNBLOCKED;
         var _loc4_:* = param1.bIsLegal === false;
         var _loc5_:* = param1.isEnabled === false;
         if(_loc2_ || _loc5_)
         {
            MenuUtils.setColor(this.m_view.resource_icon_mc.chemical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
            MenuUtils.setColor(this.m_view.resource_icon_mc.electrical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
            this.m_view.promptHolder_mc.alpha = 0.48;
            this.m_view.hold_mc.alpha = 0.48;
            this.m_view.hold_arrow_mc.alpha = 0.48;
            this.m_view.collectible_icon_mc.alpha = 0.48;
            this.m_view.resource_icon_mc.chemical_icon_mc.alpha = 0.48;
            this.m_view.resource_icon_mc.electrical_icon_mc.alpha = 0.48;
         }
         else
         {
            MenuUtils.setColor(this.m_view.resource_icon_mc.chemical_icon_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL,false);
            MenuUtils.setColor(this.m_view.resource_icon_mc.electrical_icon_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL,false);
            this.m_view.promptHolder_mc.alpha = 1;
            this.m_view.hold_mc.alpha = 1;
            this.m_view.hold_arrow_mc.alpha = 1;
            this.m_view.collectible_icon_mc.alpha = 1;
            this.m_view.resource_icon_mc.chemical_icon_mc.alpha = 1;
            this.m_view.resource_icon_mc.electrical_icon_mc.alpha = 1;
         }
         var _loc6_:String = param1.sTitle != null ? param1.sTitle : "";
         var _loc7_:Boolean = _loc6_ != "" && _loc6_ != " ";
         this.m_view.title_mc.title_txt.visible = _loc7_;
         this.m_view.shadows_mc.title_shadow_mc.visible = _loc7_;
         if(this.m_debugIsActive)
         {
            _loc6_ = this.m_debugText;
         }
         if(MenuConstantsKnt.DEBUG_AGILITY_TYPES && param1.eAgilityType != 0)
         {
            agilityDebugPrefix = "[AG:" + param1.eAgilityType + "] ";
            _loc6_ = agilityDebugPrefix + _loc6_;
         }
         if(MenuConstantsKnt.DEBUG_PROMPT_METADATA)
         {
            promptDebugSuffix = this.getPromptDebugSuffix(param1);
            if(promptDebugSuffix != "")
            {
               _loc6_ += promptDebugSuffix;
            }
         }
         crushedPromptTitle = this.getCrushedPromptTitle(param1);
         if(crushedPromptTitle != "")
         {
            _loc6_ = crushedPromptTitle;
         }
         if(param1.aElements.length > 0)
         {
            this.m_iconId = param1.aElements[0].iconId;
            this.m_actionKeyGlyph = param1.aElements[0].keyGlyph;
            this.m_platform = param1.controllerType;
         }
         else
         {
            this.m_iconId = this.m_manuallySetIconId;
            this.m_platform = ControlsMain.getControllerType();
         }
         var _loc8_:Boolean = this.m_iconId != -1 || this.m_actionKeyGlyph != "";
         var _loc9_:String = _loc13_ && !_loc8_ ? MenuConstantsKnt.FontColorHighlight : MenuConstantsKnt.FontColorWhite;
         if(this.m_isAgencyPrompt && !_loc2_ && !_loc5_)
         {
            _loc9_ = AGENCY_ACTIONABLE_TEXT_COLOR;
         }
         MenuUtils.setupText(this.m_view.title_mc.title_txt,_loc6_,21,MenuConstantsKnt.FONT_TYPE_MEDIUM,_loc9_);
         this.m_view.title_mc.title_txt.alpha = _loc2_ || _loc5_ ? 0.6 : 1;
         this.m_view.shadows_mc.title_shadow_mc.width = this.m_view.title_mc.title_txt.textWidth + TITLE_SHADOW_EXTRA_WIDTH;
         this.m_view.shadows_mc.title_shadow_mc.x = this.m_view.title_mc.title_txt.x + this.m_view.title_mc.title_txt.textWidth / 2;
         var _loc10_:String = "";
         if(param1.sDescription != null && param1.sDescription != "")
         {
            _loc10_ = param1.sDescription;
         }
         if(_loc10_ != "")
         {
            MenuUtils.setupTextUpper(this.m_view.title_mc.description_txt,_loc10_,16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
            this.m_view.title_mc.description_txt.setTextFormat(this.m_newFormat);
            this.m_view.title_mc.description_txt.visible = true;
            this.m_view.shadows_mc.description_shadow_mc.width = this.m_view.title_mc.description_txt.textWidth + DESC_SHADOW_EXTRA_WIDTH;
            this.m_view.shadows_mc.description_shadow_mc.x = this.m_view.title_mc.description_txt.x + this.m_view.title_mc.description_txt.textWidth / 2;
            this.m_view.shadows_mc.description_shadow_mc.visible = true;
         }
         else
         {
            MenuUtils.setupTextUpper(this.m_view.title_mc.description_txt,"",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
            this.m_view.title_mc.description_txt.setTextFormat(this.m_newFormat);
            this.m_view.title_mc.description_txt.visible = false;
            this.m_view.shadows_mc.description_shadow_mc.visible = false;
         }
         var _loc11_:String = "";
         if(param1.sStatus != null && param1.sStatus != "")
         {
            _loc11_ = param1.sStatus;
         }
         this.m_view.title_mc.blocked_mc.visible = this.shouldShowVanillaPromptStatus(param1) && _loc2_ && param1.eAgilityType != AGILITY_TYPE_SWAP_COVER && !_loc4_ && !this.m_isAgencyPrompt && _loc11_ != "";
         this.m_view.title_mc.illegal_mc.visible = this.shouldShowVanillaPromptStatus(param1) && _loc4_ && !this.m_isAgencyPrompt;
         this.m_view.title_mc.unblocked_mc.visible = this.shouldShowVanillaPromptStatus(param1) && _loc3_ && param1.eAgilityType != AGILITY_TYPE_SWAP_COVER && !_loc4_ && !this.m_isAgencyPrompt;
         if(this.shouldShowVanillaPromptStatus(param1) && (_loc11_ != "" || _loc2_ || _loc3_ || _loc4_) && param1.eAgilityType != AGILITY_TYPE_SWAP_COVER)
         {
            if(_loc11_ == "")
            {
               MenuUtils.setupText(this.m_view.title_mc.status_txt,"",18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
               this.m_view.title_mc.status_txt.visible = false;
               this.m_view.shadows_mc.status_shadow_mc.visible = false;
               this.m_view.title_mc.title_txt.y = -15;
               this.m_view.shadows_mc.title_shadow_mc.y = 0;
            }
            else
            {
               MenuUtils.setupText(this.m_view.title_mc.status_txt,_loc11_,18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
               this.m_view.title_mc.status_txt.visible = true;
               this.m_view.shadows_mc.status_shadow_mc.width = this.m_view.title_mc.status_txt.textWidth + DESC_SHADOW_EXTRA_WIDTH;
               this.m_view.shadows_mc.status_shadow_mc.x = this.m_view.title_mc.status_txt.x + this.m_view.title_mc.status_txt.textWidth / 2;
               this.m_view.shadows_mc.status_shadow_mc.visible = true;
               this.m_view.title_mc.title_txt.y = -25;
               this.m_view.shadows_mc.title_shadow_mc.y = -10;
            }
         }
         else
         {
            MenuUtils.setupText(this.m_view.title_mc.status_txt,"",18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
            this.m_view.title_mc.status_txt.visible = false;
            this.m_view.shadows_mc.status_shadow_mc.visible = false;
            this.m_view.title_mc.title_txt.y = -15;
            this.m_view.shadows_mc.title_shadow_mc.y = 0;
         }
         this.applyAgilityTextVisibility(param1);
         this.applyCrushedPromptVisibility(crushedPromptTitle);
         this.applySuppressedPickupPromptTextVisibility(param1);
         if(_loc8_)
         {
            this.m_nextPromptInstanceIndex = 0;
            _loc12_ = param1.sPromptType != null ? param1.sPromptType : "press";
            _loc13_ = param1.bCurrentlyActive != null ? Boolean(param1.bCurrentlyActive) : false;
            _loc14_ = this.getPromptInstance();
            _loc14_.x = 0;
            _loc14_.y = 0;
            _loc14_.platform = this.m_platform;
            this.m_view.promptHolder_mc.scaleX = this.m_view.promptHolder_mc.scaleY = (_loc14_.platform == "key" ? 0.75 : PROMPT_ICON_SCALE) * PROMPT_SCALE_MULTIPLIER;
            if((_loc14_.platform == CommonUtils.CONTROLLER_TYPE_KEY || this.m_iconId == -1) && this.m_actionKeyGlyph != "")
            {
               _loc14_.customKey = this.m_actionKeyGlyph;
            }
            else
            {
               _loc14_.button = this.m_iconId;
            }
            if(this.m_isAgencyPrompt)
            {
               if(param1.aElements.length == 1)
               {
                  this.applyPromptImageStyle(_loc14_);
               }
            }
            else
            {
               _loc15_ = param1.aElements.length == 1 ? _loc13_ : Boolean(param1.aElements[0].invertColor);
               this.applyPromptImageStyle(_loc14_);
            }
            if(SHOW_PROMPT_HIGHLIGHTS && (param1.eAgilityType == AGILITY_TYPE_VAULT_ATTACK || param1.eAgilityType == AGILITY_TYPE_ITEM_QUICK_THROW || param1.eAggressionLevel > AGGRESSION_LEVEL_NONE))
            {
               MenuUtils.setColor(this.m_view.anim_mc,param1.eAggressionLevel == AGGRESSION_LEVEL_HARD ? uint(MenuConstantsKnt.COLOR_HUD_DANGER_HIGH) : uint(MenuConstantsKnt.COLOR_HUD_DANGER_MED));
               if(!this.m_aggressiveAnimRunning)
               {
                  this.m_view.anim_mc.visible = true;
                  this.m_view.anim_mc.gotoAndPlay("anim");
                  this.m_aggressiveAnimRunning = true;
               }
            }
            else if(this.m_aggressiveAnimRunning)
            {
               this.m_view.anim_mc.visible = false;
               this.m_view.anim_mc.gotoAndStop(0);
               this.m_aggressiveAnimRunning = false;
            }
            if(_loc12_ != "holdwithprogress")
            {
               if(this.m_holdArrowAnimCalled)
               {
                  Animate.kill(this.m_view.hold_arrow_mc.inner_mc);
                  this.m_view.hold_arrow_mc.inner_mc.y = -18;
                  this.m_holdArrowAnimCalled = false;
               }
            }
            if(_loc12_ == "press")
            {
               this.m_view.hold_mc.visible = false;
               this.m_view.hold_arrow_mc.visible = false;
               if(param1.aElements.length > 1)
               {
                  _loc14_.x = (param1.aElements.length - 1) * -PROMPT_X_SPACING;
                  _loc14_.y = 0;
                  _loc16_ = 1;
                  while(_loc16_ < param1.aElements.length)
                  {
                     _loc17_ = this.getPromptInstance();
                     _loc17_.x = (param1.aElements.length - 1 - _loc16_) * -PROMPT_X_SPACING;
                     _loc17_.y = 0;
                     _loc17_.platform = this.m_platform;
                     _loc18_ = param1.aElements[_loc16_];
                     if((_loc17_.platform == CommonUtils.CONTROLLER_TYPE_KEY || _loc18_.iconId == -1) && _loc18_.keyGlyph != "")
                     {
                        _loc17_.customKey = _loc18_.keyGlyph;
                     }
                     else
                     {
                        _loc17_.button = _loc18_.iconId;
                     }
                     this.applyPromptImageStyle(_loc17_);
                     _loc16_++;
                  }
               }
            }
            else if(_loc12_ == "hold")
            {
               this.m_view.hold_mc.visible = true;
               this.m_view.hold_arrow_mc.visible = true;
               this.m_view.hold_mc.progress_mc.gotoAndStop(_loc13_ ? 61 : 0);
            }
            else if(_loc12_ == "holdwithprogress")
            {
               this.m_view.hold_mc.visible = true;
               this.m_view.hold_arrow_mc.visible = true;
               if(param1.aElements[0].invertColor)
               {
                  if(!this.m_holdArrowAnimCalled)
                  {
                     Animate.kill(this.m_view.hold_arrow_mc.inner_mc);
                     Animate.to(this.m_view.hold_arrow_mc.inner_mc,0.6,0,{"y":-16},Animate.ExpoOut);
                     this.m_holdArrowAnimCalled = true;
                  }
               }
               else if(this.m_holdArrowAnimCalled)
               {
                  Animate.kill(this.m_view.hold_arrow_mc.inner_mc);
                  Animate.to(this.m_view.hold_arrow_mc.inner_mc,0.6,0,{"y":-18},Animate.ExpoOut);
                  this.m_holdArrowAnimCalled = false;
               }
               if(this.m_currentProgress != param1.fProgress)
               {
                  this.m_view.hold_mc.progress_mc.gotoAndStop(Math.ceil(param1.fProgress * 60));
                  this.m_currentProgress = param1.fProgress;
               }
            }
            else if(_loc12_ == "doubletap")
            {
               this.m_view.hold_mc.visible = false;
               this.m_view.hold_arrow_mc.visible = false;
               _loc19_ = this.getPromptInstance();
               _loc19_.x = -32;
               _loc19_.y = 0;
               _loc19_.platform = this.m_platform;
               if((_loc19_.platform == CommonUtils.CONTROLLER_TYPE_KEY || this.m_iconId == -1) && this.m_actionKeyGlyph != "")
               {
                  _loc19_.customKey = this.m_actionKeyGlyph;
               }
               else
               {
                  _loc19_.button = this.m_iconId;
               }
               this.applyPromptImageStyle(_loc19_);
            }
            else if(_loc12_ == "combo" || _loc12_ == "combofinisher")
            {
               _loc20_ = this.getPromptInstance();
               if(param1.eAgilityType === AGILITY_TYPE_SWAP_COVER)
               {
                  _loc20_.x = -44;
                  _loc20_.y = 0;
                  this.m_view.combo_mc.rotation = 0;
                  this.m_view.shadows_mc.combo_shadow_mc.rotation = 0;
               }
               else if(_loc12_ == "combo")
               {
                  _loc14_.x = -54;
                  _loc14_.y = 0;
                  _loc20_.x = 0;
                  _loc20_.y = 0;
                  this.m_view.combo_mc.rotation = 0;
                  this.m_view.shadows_mc.combo_shadow_mc.rotation = 0;
               }
               else
               {
                  if(param1.aElements[0].iconId == 3 && param1.aElements[1].iconId == 1)
                  {
                     _loc14_.x = -38;
                     _loc14_.y = -38;
                     _loc20_.x = 0;
                     _loc20_.y = 0;
                  }
                  else if(_loc14_.platform == "key")
                  {
                     _loc20_.x = -42;
                     _loc20_.y = -42;
                  }
                  else
                  {
                     _loc20_.x = -38;
                     _loc20_.y = -38;
                  }
                  this.m_view.combo_mc.rotation = 45;
                  this.m_view.shadows_mc.combo_shadow_mc.rotation = 45;
               }
               this.m_view.combo_mc.alpha = _loc2_ || _loc5_ ? 0.5 : 1;
               this.m_view.hold_mc.visible = false;
               this.m_view.hold_arrow_mc.visible = false;
               this.m_view.combo_mc.visible = true;
               this.m_view.shadows_mc.prompt_shadow_mc.visible = false;
               this.m_view.shadows_mc.combo_shadow_mc.visible = true;
               _loc20_.platform = this.m_platform;
               if((_loc20_.platform == CommonUtils.CONTROLLER_TYPE_KEY || param1.aElements[1].iconId == -1) && param1.aElements[1].keyGlyph != "")
               {
                  _loc20_.customKey = param1.aElements[1].keyGlyph;
               }
               else
               {
                  _loc20_.button = param1.aElements[1].iconId;
               }
               this.applyPromptImageStyle(_loc20_);
            }
            this.releaseUnusedPromptInstances();
         }
         else
         {
            this.releaseAllPromptInstances();
         }
         this.showCollectibleIcon(param1.bIsCollectible ? true : false);
         if(param1.eResourceType != -1 && !this.shouldSuppressResourceTypeIcon(param1))
         {
            this.showResourceType(true,param1.eResourceType);
         }
         else
         {
            this.showResourceType(false,-1);
         }
      }
      
      private function setStateAvailable(param1:Object) : void
      {
         var title:String;
         var data:Object = param1;
         Animate.kill(this.m_view.collapsed_mc);
         title = data.sTitle != null ? data.sTitle : "";
         if(this.m_debugIsActive)
         {
            title = this.m_debugText;
         }
         if(MenuConstantsKnt.DEBUG_AGILITY_TYPES && data.eAgilityType != 0)
         {
            title = "[AG:" + data.eAgilityType + "] " + title;
         }
         if(MenuConstantsKnt.DEBUG_PROMPT_METADATA)
         {
            title += this.getPromptDebugSuffix(data);
         }
         this.releaseAllPromptInstances();
         this.m_view.title_mc.blocked_mc.visible = false;
         this.m_view.title_mc.illegal_mc.visible = false;
         this.m_view.title_mc.unblocked_mc.visible = false;
         this.m_view.hold_mc.visible = false;
         this.m_view.hold_arrow_mc.visible = false;
         this.m_view.title_mc.description_txt.visible = false;
         this.m_view.title_mc.title_txt.visible = false;
         this.m_view.title_mc.status_txt.visible = false;
         this.m_view.shadows_mc.icons_shadow_mc.visible = false;
         this.m_view.shadows_mc.prompt_shadow_mc.visible = false;
         this.m_view.shadows_mc.combo_shadow_mc.visible = false;
         this.m_view.shadows_mc.title_shadow_mc.visible = false;
         this.m_view.shadows_mc.status_shadow_mc.visible = false;
         this.m_view.shadows_mc.description_shadow_mc.visible = false;
         this.m_view.title_mc.title_txt.y = -15;
         this.m_view.shadows_mc.title_shadow_mc.y = 0;
         this.m_view.collapsed_mc.outline_mc.alpha = 1;
         this.m_view.collapsed_mc.fill_mc.alpha = 1;
         MenuUtils.setColor(this.m_view.collapsed_mc.fill_mc,MenuConstantsKnt.COLOR_WHITE);
         this.m_view.collapsed_mc.visible = true;
         Animate.to(this.m_view.collapsed_mc,0.1,0,{
            "scaleX":1.6,
            "scaleY":1.6
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.collapsed_mc,0.2,0,{
               "scaleX":1.2,
               "scaleY":1.2
            },Animate.BackOut);
         });
         this.showCollectibleIcon(false);
         this.showResourceType(false,-1);
         this.applyAgilityTextVisibility(data);
         this.applySuppressedPickupPromptTextVisibility(data);
      }
      
      private function setStateCollapsed(param1:Object) : void
      {
         var title:String;
         var data:Object = param1;
         Animate.kill(this.m_view.collapsed_mc);
         if(this.m_aggressiveAnimRunning)
         {
            this.m_view.anim_mc.visible = false;
            this.m_view.anim_mc.gotoAndStop(0);
            this.m_aggressiveAnimRunning = false;
         }
         title = data.sTitle != null ? data.sTitle : "";
         if(this.m_debugIsActive)
         {
            title = this.m_debugText;
         }
         if(MenuConstantsKnt.DEBUG_AGILITY_TYPES && data.eAgilityType != 0)
         {
            title = "[AG:" + data.eAgilityType + "] " + title;
         }
         if(MenuConstantsKnt.DEBUG_PROMPT_METADATA)
         {
            title += this.getPromptDebugSuffix(data);
         }
         MenuUtils.setupText(this.m_view.title_mc.title_txt,title,21,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
         this.m_view.shadows_mc.title_shadow_mc.width = this.m_view.title_mc.title_txt.textWidth + TITLE_SHADOW_EXTRA_WIDTH;
         this.m_view.shadows_mc.title_shadow_mc.x = this.m_view.title_mc.title_txt.x + this.m_view.title_mc.title_txt.textWidth / 2;
         if(this.shouldShowVanillaPromptStatus(data) && data.sStatus != null && data.sStatus != "" && title != "" && title != " ")
         {
            MenuUtils.setupText(this.m_view.title_mc.status_txt,data.sStatus,18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
            this.m_view.title_mc.status_txt.visible = true;
            this.m_view.shadows_mc.status_shadow_mc.width = this.m_view.title_mc.status_txt.textWidth + DESC_SHADOW_EXTRA_WIDTH;
            this.m_view.shadows_mc.status_shadow_mc.x = this.m_view.title_mc.status_txt.x + this.m_view.title_mc.status_txt.textWidth / 2;
            this.m_view.shadows_mc.status_shadow_mc.visible = true;
            this.m_view.title_mc.title_txt.y = -25;
            this.m_view.shadows_mc.title_shadow_mc.y = -10;
         }
         else
         {
            this.m_view.title_mc.status_txt.visible = false;
            this.m_view.shadows_mc.status_shadow_mc.visible = false;
            this.m_view.title_mc.title_txt.y = -15;
            this.m_view.shadows_mc.title_shadow_mc.y = 0;
         }
         if(data.sDescription != null && data.sDescription != "" && title != "" && title != " ")
         {
            MenuUtils.setupTextUpper(this.m_view.title_mc.description_txt,data.sDescription,16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
            this.m_view.title_mc.description_txt.setTextFormat(this.m_newFormat);
            this.m_view.title_mc.description_txt.visible = true;
            this.m_view.shadows_mc.description_shadow_mc.width = this.m_view.title_mc.description_txt.textWidth + DESC_SHADOW_EXTRA_WIDTH;
            this.m_view.shadows_mc.description_shadow_mc.x = this.m_view.title_mc.description_txt.x + this.m_view.title_mc.description_txt.textWidth / 2;
            this.m_view.shadows_mc.description_shadow_mc.visible = true;
         }
         else
         {
            this.m_view.title_mc.description_txt.visible = false;
            this.m_view.shadows_mc.description_shadow_mc.visible = false;
         }
         this.releaseAllPromptInstances();
         this.m_view.title_mc.blocked_mc.visible = false;
         this.m_view.title_mc.illegal_mc.visible = false;
         this.m_view.title_mc.unblocked_mc.visible = false;
         this.m_view.hold_mc.visible = false;
         this.m_view.hold_arrow_mc.visible = false;
         this.m_view.shadows_mc.icons_shadow_mc.visible = false;
         this.m_view.shadows_mc.prompt_shadow_mc.visible = false;
         this.m_view.shadows_mc.combo_shadow_mc.visible = false;
         this.m_view.shadows_mc.title_shadow_mc.visible = false;
         this.m_view.shadows_mc.status_shadow_mc.visible = false;
         this.m_view.shadows_mc.description_shadow_mc.visible = false;
         this.m_view.collapsed_mc.outline_mc.alpha = 1;
         this.m_view.collapsed_mc.fill_mc.alpha = 0.7;
         MenuUtils.setColor(this.m_view.collapsed_mc.fill_mc,MenuConstantsKnt.COLOR_GREY_LIGHT);
         if(data.eResourceType == -1 || this.shouldSuppressResourceTypeIcon(data))
         {
            this.m_view.collapsed_mc.visible = true;
            this.showResourceType(false,-1);
            if(this.m_eState == STATE_AVAILABLE)
            {
               Animate.to(this.m_view.collapsed_mc,0.1,0,{
                  "scaleX":0.6,
                  "scaleY":0.6
               },Animate.ExpoOut,function():void
               {
                  Animate.to(m_view.collapsed_mc,0.2,0,{
                     "scaleX":1,
                     "scaleY":1
                  },Animate.BackOut);
               });
            }
            else
            {
               this.m_view.collapsed_mc.scaleX = this.m_view.collapsed_mc.scaleY = 0;
               Animate.to(this.m_view.collapsed_mc,0.2,0,{
                  "scaleX":1,
                  "scaleY":1
               },Animate.BackOut);
            }
         }
         else
         {
            this.m_view.collapsed_mc.visible = false;
            this.showResourceType(true,data.eResourceType,true);
            if(data.eBlockedStatus)
            {
               MenuUtils.setColor(this.m_view.resource_icon_mc.chemical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
               MenuUtils.setColor(this.m_view.resource_icon_mc.electrical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
               this.m_view.resource_icon_mc.chemical_icon_mc.alpha = 0.6;
               this.m_view.resource_icon_mc.electrical_icon_mc.alpha = 0.6;
            }
            else
            {
               MenuUtils.setColor(this.m_view.resource_icon_mc.chemical_icon_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL,false);
               MenuUtils.setColor(this.m_view.resource_icon_mc.electrical_icon_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL,false);
               this.m_view.resource_icon_mc.chemical_icon_mc.alpha = 1;
               this.m_view.resource_icon_mc.electrical_icon_mc.alpha = 1;
            }
         }
         this.showCollectibleIcon(false);
         this.applyAgilityTextVisibility(data);
         this.applySuppressedPickupPromptTextVisibility(data);
      }
      
      private function setStateNotAvailable(param1:Object) : void
      {
         Animate.kill(this.m_view.collapsed_mc);
         this.showCollectibleIcon(false);
         this.showResourceType(false,-1);
      }
      
      private function getPromptInstance() : ButtonPromptImage
      {
         var _loc2_:ButtonPromptImage = null;
         var _loc1_:int = this.m_nextPromptInstanceIndex++;
         if(_loc1_ >= this.m_promptInstances.length)
         {
            _loc2_ = ButtonPromptImage.AcquireInstance();
            this.m_view.promptHolder_mc.addChild(_loc2_);
            this.m_promptInstances.push(_loc2_);
            this.m_view.shadows_mc.prompt_shadow_mc.visible = true;
         }
         return this.m_promptInstances[_loc1_];
      }
      
      private function applyPromptImageStyle(param1:ButtonPromptImage) : void
      {
         if(param1 == null)
         {
            return;
         }
         MenuUtils.addColorFilter(param1,[MenuConstantsKnt.COLOR_MATRIX_INVERTED]);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:int = 0;
         if(!this.visible)
         {
            return;
         }
         this.syncResourceIconSuppression();
         this.m_view.collapsed_mc.visible = false;
         this.m_view.collapsed_mc.alpha = 0;
         this.m_view.collapsed_mc.scaleX = this.m_view.collapsed_mc.scaleY = 0;
         _loc2_ = 0;
         while(_loc2_ < this.m_promptInstances.length)
         {
            this.applyPromptImageStyle(this.m_promptInstances[_loc2_]);
            _loc2_++;
         }
      }
      
      private function releaseAllPromptInstances() : void
      {
         this.m_nextPromptInstanceIndex = 0;
         this.releaseUnusedPromptInstances();
      }
      
      private function releaseUnusedPromptInstances() : void
      {
         var _loc1_:ButtonPromptImage = null;
         while(this.m_promptInstances.length > this.m_nextPromptInstanceIndex)
         {
            _loc1_ = this.m_promptInstances.pop();
            this.m_view.promptHolder_mc.removeChild(_loc1_);
            ButtonPromptImage.ReleaseInstance(_loc1_);
            this.m_view.shadows_mc.prompt_shadow_mc.visible = false;
         }
      }
      
      private function showCollectibleIcon(param1:Boolean) : void
      {
         if(param1 != this.m_isCollectiblePrompt)
         {
            this.m_view.collectible_icon_mc.visible = param1;
            this.m_isCollectiblePrompt = param1;
         }
      }
      
      private function showResourceType(param1:Boolean, param2:int, param3:Boolean = false) : void
      {
         if(param1 != this.m_isResourcePickUpPrompt || param1 && param2 != this.m_resourceTypeShown)
         {
            this.m_view.resource_icon_mc.visible = param1;
            this.m_view.promptHolder_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.doublePromptHolder_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.hold_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.hold_arrow_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.title_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.collapsed_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.anim_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.combo_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            this.m_view.shadows_mc.x = param1 ? RESOURCE_SHOWN_XPOS_OFFSET : 0;
            if(param1)
            {
               if(param2 == PLAYER_RESOURCETYPE_CHEMICAL)
               {
                  this.m_view.resource_icon_mc.chemical_icon_mc.visible = true;
                  this.m_view.resource_icon_mc.electrical_icon_mc.visible = false;
               }
               else if(param2 == PLAYER_RESOURCETYPE_ELECTRICAL)
               {
                  this.m_view.resource_icon_mc.chemical_icon_mc.visible = false;
                  this.m_view.resource_icon_mc.electrical_icon_mc.visible = true;
               }
            }
            else
            {
               this.m_view.resource_icon_mc.chemical_icon_mc.visible = false;
               this.m_view.resource_icon_mc.electrical_icon_mc.visible = false;
            }
            this.m_resourceTypeShown = param2;
            this.m_isResourcePickUpPrompt = param1;
         }
      }

      private function shouldSuppressResourceTypeIcon(param1:Object) : Boolean
      {
         if(param1 == null || param1.eResourceType == -1)
         {
            return false;
         }
         if(MenuConstantsKnt.SHOW_PICKUP_NOTIFICATIONS)
         {
            return false;
         }
         return param1.isEnabled === false || param1.eBlockedStatus === BLOCKED_STATUS_BLOCKED || param1.eBlockedStatus === BLOCKED_STATUS_CANBEUNBLOCKED;
      }

      private function syncResourceIconSuppression() : void
      {
         if(this.shouldSuppressResourceTypeIcon(this.m_data))
         {
            this.showResourceType(false,-1);
         }
      }

      private function shouldShowVanillaPromptStatus(param1:Object) : Boolean
      {
         return MenuConstantsKnt.VANILLA_TEXT_PROMPTS;
      }

      private function getCrushedPromptTitle(param1:Object) : String
      {
         if(!MenuConstantsKnt.CRUSH_BUTTON_PROMPTS)
         {
            return "";
         }
         if(param1 == null || param1.sDescription == null || param1.sDescription == "" || param1.sDescription == " ")
         {
            return "";
         }
         return String(param1.sDescription);
      }

      private function shouldHideAgilityPromptCompletely(param1:Object) : Boolean
      {
         if(param1 == null || MenuConstantsKnt.SHOW_AGILITY_VANILLA)
         {
            return false;
         }
         return param1.eAgilityType == 24;
      }

      private function shouldHideAgilityText(param1:Object) : Boolean
      {
         if(param1 == null || MenuConstantsKnt.SHOW_AGILITY_VANILLA)
         {
            return false;
         }
         switch(param1.eAgilityType)
         {
            case 3:
            case 4:
            case 8:
            case 23:
            case 25:
               return true;
            default:
               return false;
         }
      }

      private function applyAgilityTextVisibility(param1:Object) : void
      {
         if(this.shouldHideAgilityText(param1))
         {
            this.m_view.title_mc.title_txt.visible = false;
            this.m_view.title_mc.status_txt.visible = false;
            this.m_view.title_mc.description_txt.visible = false;
            this.m_view.shadows_mc.title_shadow_mc.visible = false;
            this.m_view.shadows_mc.status_shadow_mc.visible = false;
            this.m_view.shadows_mc.description_shadow_mc.visible = false;
            this.m_view.title_mc.blocked_mc.visible = false;
            this.m_view.title_mc.illegal_mc.visible = false;
            this.m_view.title_mc.unblocked_mc.visible = false;
         }
      }

      private function applyCrushedPromptVisibility(param1:String) : void
      {
         if(param1 == "")
         {
            return;
         }
         this.m_view.title_mc.description_txt.visible = false;
         this.m_view.shadows_mc.description_shadow_mc.visible = false;
         this.m_view.title_mc.status_txt.visible = false;
         this.m_view.shadows_mc.status_shadow_mc.visible = false;
         this.m_view.title_mc.blocked_mc.visible = false;
         this.m_view.title_mc.illegal_mc.visible = false;
         this.m_view.title_mc.unblocked_mc.visible = false;
      }

      private function applySuppressedPickupPromptTextVisibility(param1:Object) : void
      {
         if(!this.shouldSuppressResourceTypeIcon(param1))
         {
            return;
         }
         this.m_view.title_mc.title_txt.visible = false;
         this.m_view.title_mc.status_txt.visible = false;
         this.m_view.title_mc.description_txt.visible = false;
         this.m_view.shadows_mc.title_shadow_mc.visible = false;
         this.m_view.shadows_mc.status_shadow_mc.visible = false;
         this.m_view.shadows_mc.description_shadow_mc.visible = false;
         this.m_view.title_mc.blocked_mc.visible = false;
         this.m_view.title_mc.illegal_mc.visible = false;
         this.m_view.title_mc.unblocked_mc.visible = false;
      }

      private function getPromptDebugSuffix(param1:Object) : String
      {
         var blockedStatus:* = null;
         var legalState:* = null;
         var resourceType:* = null;
         var promptType:* = null;
         if(param1 == null)
         {
            return "";
         }
         blockedStatus = param1.eBlockedStatus != null ? param1.eBlockedStatus : "?";
         legalState = param1.bIsLegal !== false ? 1 : 0;
         resourceType = param1.eResourceType != null ? param1.eResourceType : "?";
         promptType = param1.sPromptType != null ? param1.sPromptType : "?";
         return " [BS:" + blockedStatus + " LEG:" + legalState + " RES:" + resourceType + " PT:" + promptType + "]";
      }
      
      public function doesInputDataMatch(param1:Array) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(this.m_data.aElements.length != param1.length)
         {
            return false;
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = this.m_data.aElements[_loc2_];
            _loc4_ = param1[_loc2_];
            if(_loc3_.keyGlyph != _loc4_.keyGlyph || _loc3_.iconId != _loc4_.iconId)
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function getPromptWidth() : Number
      {
         var _loc1_:Number = this.m_view.title_mc.status_txt.x + this.m_view.title_mc.status_txt.textWidth;
         var _loc2_:Number = this.m_view.title_mc.description_txt.x + this.m_view.title_mc.description_txt.textWidth;
         var _loc3_:Number = this.m_view.title_mc.title_txt.x + this.m_view.title_mc.title_txt.textWidth;
         return Math.max(_loc1_,_loc2_,_loc3_);
      }
      
      public function set iconId(param1:int) : void
      {
         this.m_iconId = param1;
         this.m_manuallySetIconId = param1;
         this.onSetData(this.m_data);
      }
      
      public function set actionKeyGlyph(param1:String) : void
      {
         this.m_actionKeyGlyph = param1;
         this.onSetData(this.m_data);
      }
      
      public function set debugIsActive(param1:Boolean) : void
      {
         this.m_debugIsActive = param1;
         this.onSetData(this.m_data);
      }
      
      public function set debugText(param1:String) : void
      {
         this.m_debugText = param1;
         this.onSetData(this.m_data);
      }
   }
}
