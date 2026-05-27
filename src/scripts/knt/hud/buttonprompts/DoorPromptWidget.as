package knt.hud.buttonprompts
{
   import flash.display.Sprite;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.hud.*;
   
   public class DoorPromptWidget extends BaseControl
   {
      
      private var m_view:Sprite;
      
      private var m_OpenClosePrompt:ButtonPromptWidget;
      
      private var m_KickPrompt:ButtonPromptWidget;
      
      private var m_SabotagePrompt:ButtonPromptWidget;
      
      private var m_OpenCloseVisible:Boolean = false;
      
      private var m_KickVisible:Boolean = false;
      
      private var m_SabotageVisible:Boolean = false;
      
      private var m_sabotageHadProgress:Boolean = false;
      
      private const PROMPTSPACING:Number = 42;
      
      private var m_expand_delay:Number = 0;
      
      public function DoorPromptWidget()
      {
         super();
         this.m_view = new Sprite();
         addChild(this.m_view);
         this.m_OpenClosePrompt = new ButtonPromptWidget();
         this.m_KickPrompt = new ButtonPromptWidget();
         this.m_SabotagePrompt = new ButtonPromptWidget();
         this.m_view.addChild(this.m_OpenClosePrompt);
         this.m_view.addChild(this.m_KickPrompt);
         this.m_view.addChild(this.m_SabotagePrompt);
         this.m_OpenClosePrompt.visible = this.m_KickPrompt.visible = this.m_SabotagePrompt.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc2_:Boolean = Boolean(param1.SabotagePrompt.isEnabled) && param1.SabotagePrompt.fProgress > 0;
         param1.SabotagePrompt.bCurrentlyActive = _loc2_;
         this.m_OpenClosePrompt.onSetData(param1.OpenClosePrompt);
         this.m_KickPrompt.onSetData(param1.KickPrompt);
         this.m_SabotagePrompt.onSetData(param1.SabotagePrompt);
         this.arrangePrompts(param1.OpenClosePrompt.isEnabled && !_loc2_ && param1.OpenClosePrompt.estate != 3 && param1.OpenClosePrompt.aElements.length > 0,param1.KickPrompt.isEnabled && !_loc2_ && param1.KickPrompt.estate != 3 && param1.KickPrompt.aElements.length > 0,Boolean(param1.SabotagePrompt.isEnabled) && param1.SabotagePrompt.estate != 3 && param1.SabotagePrompt.aElements.length > 0,_loc2_);
      }
      
      private function arrangePrompts(param1:Boolean, param2:Boolean, param3:Boolean, param4:Boolean = false) : void
      {
         this.m_OpenClosePrompt.visible = param1;
         this.m_KickPrompt.visible = param2;
         this.m_SabotagePrompt.visible = param3;
         if(param4)
         {
            Animate.complete(this.m_SabotagePrompt);
         }
         if(param1 != this.m_OpenCloseVisible || param2 != this.m_KickVisible)
         {
            this.m_KickPrompt.y = param1 ? this.PROMPTSPACING : 0;
            this.m_SabotagePrompt.y = (param1 ? this.PROMPTSPACING : 0) + (param2 ? this.PROMPTSPACING : 0);
         }
         if(!this.m_OpenCloseVisible && param1)
         {
            this.m_OpenClosePrompt.alpha = 0;
            Animate.to(this.m_OpenClosePrompt,0.1,0,{"alpha":1},Animate.Linear);
         }
         if(!this.m_KickVisible && param2)
         {
            this.m_KickPrompt.alpha = 0;
            Animate.to(this.m_KickPrompt,0.1,param4 || this.m_SabotageVisible ? 0 : (param1 && !this.m_sabotageHadProgress ? this.m_expand_delay : 0),{"alpha":1},Animate.Linear);
         }
         if(!this.m_SabotageVisible && param3)
         {
            this.m_SabotagePrompt.alpha = 0;
            Animate.to(this.m_SabotagePrompt,0.1,param4 ? 0 : (param1 ? this.m_expand_delay : 0),{"alpha":1},Animate.Linear);
         }
         this.m_OpenCloseVisible = param1;
         this.m_KickVisible = param2;
         this.m_SabotageVisible = param3;
         this.m_sabotageHadProgress = param4;
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         if(!param1)
         {
            this.m_OpenCloseVisible = this.m_KickVisible = this.m_SabotageVisible = false;
         }
         this.visible = param1;
      }
   }
}

