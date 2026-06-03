package knt.hud.buttonprompts
{
   import flash.display.Sprite;
   import glacier.common.BaseControl;
   import glacier.common.ObjectUtils;
   import knt.hud.*;
   
   public class ConfrontationPromptsWidget extends BaseControl
   {
      
      private const MAX_PROMPTS:int = 4;
      
      private var m_view:ConfrontationPromptsWidgetView;
      
      private var m_aPrompts:Array;
      
      private var m_bluffPromptIndex:int = 1;
      
      private var m_exitConversationPromptCentered:Boolean = false;
      
      public function ConfrontationPromptsWidget()
      {
         var _loc2_:NPCCombatPromptsWidget = null;
         var _loc3_:Sprite = null;
         this.m_aPrompts = new Array();
         super();
         this.m_view = new ConfrontationPromptsWidgetView();
         addChild(this.m_view);
         var _loc1_:int = 0;
         while(_loc1_ < this.MAX_PROMPTS)
         {
            _loc2_ = new NPCCombatPromptsWidget();
            _loc3_ = this.m_view.getChildByName("promt_" + String(_loc1_ + 1) + "_container_mc") as Sprite;
            _loc3_.addChild(_loc2_);
            this.m_aPrompts.push(_loc2_);
            _loc1_++;
         }
         this.m_view.timer_mc.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(!param1.isActive)
         {
            this.m_view.visible = false;
            return;
         }
         if(param1.m_prompts.length == 0)
         {
            this.m_view.visible = false;
            return;
         }
         if(param1.m_prompts.length != this.MAX_PROMPTS)
         {
            this.m_view.visible = false;
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.MAX_PROMPTS)
         {
            _loc3_ = param1.m_prompts[_loc2_];
            _loc4_ = ObjectUtils.cloneDeep(param1);
            _loc4_.m_prompts = [];
            _loc4_.m_prompts.push(_loc3_);
            _loc4_.confrontationMultiPromptIndex = _loc2_;
            this.m_aPrompts[_loc2_].onSetData(_loc4_);
            _loc2_++;
         }
         this.m_view.visible = true;
         if((param1.m_prompts[0].m_promptData.length == 0 || !param1.m_prompts[0].isVisible) && (param1.m_prompts[1].m_promptData.length == 0 || !param1.m_prompts[1].isVisible) && (param1.m_prompts[3].m_promptData.length == 0 || !param1.m_prompts[3].isVisible) && (param1.m_prompts[2].m_promptData.length > 0 || param1.m_prompts[2].isVisible) && param1.m_prompts[2].m_promptType == 17)
         {
            if(!this.m_exitConversationPromptCentered)
            {
               this.centerExitConversationPrompt(true);
            }
         }
         else if(this.m_exitConversationPromptCentered)
         {
            this.centerExitConversationPrompt(false);
         }
      }
      
      private function centerExitConversationPrompt(param1:Boolean) : void
      {
         this.m_view.promt_3_container_mc.x = param1 ? -36 : 36;
         this.m_exitConversationPromptCentered = param1;
      }
      
      public function setTimer(param1:Number) : void
      {
         if(param1 > 0)
         {
            this.m_view.timer_mc.visible = true;
            this.m_view.timer_mc.dial_mc.gotoAndStop(100 - Math.ceil(99 * param1));
            if(this.m_exitConversationPromptCentered)
            {
               this.centerExitConversationPrompt(false);
            }
         }
         else
         {
            this.m_view.timer_mc.visible = false;
         }
      }
   }
}

