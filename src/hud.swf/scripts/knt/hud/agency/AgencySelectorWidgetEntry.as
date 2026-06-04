package knt.hud.agency
{
   import flash.display.BlendMode;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   import knt.hud.buttonprompts.ButtonPromptWidget;
   
   public class AgencySelectorWidgetEntry extends BaseControl
   {
      
      private static const OPEN_ANIM_SPEED:Number = 0.2;
      
      private static const FLASH_ANIM_SPEED:Number = 0.03;
      
      private static const DISPLAY_TIME:Number = 1;
      
      private static const POST_ANIM_SPEED:Number = 0.2;
      
      private static const CLOSE_ANIM_SPEED:Number = 0.4;
      
      private static const ENTRY_EXTENDED_BASE_WIDTH:int = 70;
      
      private var m_view:AgencySelectorWidgetEntryView;
      
      private var m_prompt:ButtonPromptWidget;
      
      private var m_entryIndex:int = -1;
      
      private var m_isEnabled:Boolean = false;
      
      private var m_pressed:Boolean = false;
      
      private var m_promptInstantiated:Boolean = false;
      
      private var m_promptControllerType:String = "";
      
      private var m_parentClassInstance:AgencySelectorWidget;
      
      private var m_agencyLabel:String = "initialAgencyPromptString";
      
      private var m_agencyColor:int = -1;
      
      private var m_blockedLabel:String = "";
      
      private var m_isAgencyPrompt:Boolean = false;
      
      private var m_flareLoopIsRunning:Boolean = false;
      
      private var m_amount:int = -1;
      
      private var m_cost:int = -1;
      
      public function AgencySelectorWidgetEntry()
      {
         super();
         this.m_view = new AgencySelectorWidgetEntryView();
         addChild(this.m_view);
         MenuUtils.setupTextUpper(this.m_view.amount_mc.title_txt,"",24,MenuConstantsKnt.FONT_TYPE_NUMBERS_BOLD,MenuConstantsKnt.FontColorAgency);
         this.m_view.flares_mc.blendMode = BlendMode.ADD;
         this.loopFlares(false,true);
      }
      
      public function onSetData(param1:Object) : void
      {
         this.m_view.amount_mc.visible = false;
         if(param1.m_label != this.m_agencyLabel || this.m_agencyColor != MenuConstantsKnt.COLOR_AGENCY)
         {
            if(this.m_promptInstantiated)
            {
               this.removePrompt();
               this.loopFlares(false,true);
            }
            this.m_agencyLabel = param1.m_label;
            this.m_agencyColor = MenuConstantsKnt.COLOR_AGENCY;
         }
         if(param1.m_promptData[0].controllerType != this.m_promptControllerType)
         {
            if(this.m_promptInstantiated)
            {
               this.removePrompt();
               this.loopFlares(false,true);
            }
            this.m_promptControllerType = param1.m_promptData[0].controllerType;
         }
         else if(this.m_promptInstantiated)
         {
            if(!this.m_prompt.doesInputDataMatch(param1.m_promptData[0].aElements))
            {
               this.removePrompt();
            }
         }
         if(!this.m_promptInstantiated)
         {
            this.m_isAgencyPrompt = param1.m_isAgencyPrompt;
            this.m_entryIndex = param1.entryindex;
            this.m_prompt = new ButtonPromptWidget();
            this.m_view.prompt_container_mc.addChild(this.m_prompt);
            this.updatePrompt(param1);
            this.m_promptInstantiated = true;
         }
         if(param1.m_promptData[0].aElements[0].invertColor != this.m_pressed)
         {
            this.updatePrompt(param1);
            this.m_pressed = param1.m_promptData[0].aElements[0].invertColor;
         }
         if(param1.m_promptData[0].isEnabled != this.m_isEnabled)
         {
            this.updatePrompt(param1);
            this.m_isEnabled = param1.m_promptData[0].isEnabled;
         }
         if(param1.m_blockedLabel != this.m_blockedLabel)
         {
            this.updatePrompt(param1);
            this.m_blockedLabel = param1.m_blockedLabel;
         }
         if(param1.m_activationCost != this.m_cost)
         {
            this.m_cost = param1.m_activationCost;
         }
         if(this.m_isAgencyPrompt)
         {
            if(this.m_isEnabled && this.m_blockedLabel == "")
            {
               if(!this.m_flareLoopIsRunning)
               {
                  this.m_view.amount_mc.alpha = 1;
                  this.loopFlares(true);
               }
            }
            else
            {
               this.loopFlares(false);
            }
         }
      }
      
      public function getType() : String
      {
         return this.m_agencyLabel;
      }
      
      private function updatePrompt(param1:Object) : void
      {
         if(!param1.m_promptData[0])
         {
            return;
         }
         var _loc2_:Object = new Object();
         _loc2_.aElements = param1.m_promptData[0].aElements;
         _loc2_.controllerType = param1.m_promptData[0].controllerType;
         _loc2_.isEnabled = param1.m_promptData[0].isEnabled;
         _loc2_.multiPromptSpacing = 0;
         _loc2_.multiPromptSpacingIcon = "";
         _loc2_.sTitle = param1.m_label;
         _loc2_.sStatus = "";
         _loc2_.sPromptType = "press";
         _loc2_.bCurrentlyActive = false;
         _loc2_.fProgress = 0;
         _loc2_.bBlocked = param1.m_blockedLabel != "" ? true : false;
         _loc2_.bIsAgencyPrompt = param1.m_isAgencyPrompt;
         _loc2_.bIsSwap = false;
         _loc2_.bIsPickpocketing = false;
         _loc2_.bIsLegal = true;
         _loc2_.bIsTrespassing = true;
         _loc2_.eState = 0;
         _loc2_.eBlockedStatus = _loc2_.bBlocked ? ButtonPromptWidget.BLOCKED_STATUS_BLOCKED : ButtonPromptWidget.BLOCKED_STATUS_NONE;
         _loc2_.fBluffProbability = 0;
         _loc2_.eAgilityType = 0;
         _loc2_.eResourceType = -1;
         this.m_prompt.onSetData(_loc2_);
         this.m_view.amount_mc.visible = false;
         this.m_view.amount_mc.x = this.m_prompt.getPromptWidth() + 10;
         var _loc3_:Number = ENTRY_EXTENDED_BASE_WIDTH - 22;
         this.m_parentClassInstance.callBackEntryWidthAndRealignEntriesXPos(this.m_entryIndex,_loc3_ + this.m_prompt.getPromptWidth());
      }
      
      private function loopFlares(param1:Boolean, param2:Boolean = false) : void
      {
         var start:Boolean = param1;
         var instantOff:Boolean = param2;
         Animate.kill(this.m_view.flares_mc.flare_01_mc);
         Animate.kill(this.m_view.flares_mc.flare_02_mc);
         Animate.kill(this.m_view.flares_mc.flare_03_mc);
         if(start)
         {
            this.m_flareLoopIsRunning = true;
            Animate.to(this.m_view.flares_mc.flare_01_mc,0.4,0,{"alpha":0.5},Animate.ExpoOut,function():void
            {
               Animate.to(m_view.flares_mc.flare_01_mc,1.6,0.6,{"alpha":0},Animate.Linear,function():void
               {
                  Animate.to(m_view.flares_mc.flare_01_mc,2,0.4,{"alpha":0.4},Animate.Linear,function():void
                  {
                     loopFlares(true);
                  });
               });
            });
            Animate.to(this.m_view.flares_mc.flare_02_mc,1,0,{"alpha":0.5},Animate.ExpoOut,function():void
            {
               Animate.to(m_view.flares_mc.flare_02_mc,2,0.4,{"alpha":0.1},Animate.Linear,function():void
               {
                  m_view.flares_mc.flare_02_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
               });
            });
            Animate.to(this.m_view.flares_mc.flare_03_mc,2,1,{"alpha":0.5},Animate.ExpoOut,function():void
            {
               Animate.to(m_view.flares_mc.flare_03_mc,2,0,{"alpha":0.2},Animate.Linear,function():void
               {
                  m_view.flares_mc.flare_03_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
               });
            });
         }
         else
         {
            this.m_flareLoopIsRunning = false;
            if(instantOff)
            {
               this.m_view.flares_mc.flare_01_mc.alpha = 0;
               this.m_view.flares_mc.flare_02_mc.alpha = 0;
               this.m_view.flares_mc.flare_03_mc.alpha = 0;
            }
            else
            {
               Animate.to(this.m_view.flares_mc.flare_01_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
               Animate.to(this.m_view.flares_mc.flare_02_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
               Animate.to(this.m_view.flares_mc.flare_03_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            }
         }
      }
      
      public function setParentClass(param1:AgencySelectorWidget) : void
      {
         this.m_parentClassInstance = param1;
      }
      
      public function removePrompt() : void
      {
         while(this.m_view.prompt_container_mc.numChildren > 0)
         {
            this.m_view.prompt_container_mc.removeChildAt(0);
         }
         this.m_prompt = null;
         this.m_promptInstantiated = false;
      }
   }
}

