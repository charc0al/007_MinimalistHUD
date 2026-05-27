package knt.hud.melee
{
   import flash.events.Event;
   import glacier.common.BaseControl;
   import knt.hud.*;
   import knt.hud.buttonprompts.ButtonPromptsWrapper;
   
   public class MeleeFinisherPrompt extends BaseControl
   {
      
      private static const PROMPT_Y_SPACING:int = -30;
      
      private var m_buttonPrompts:Vector.<ButtonPromptsWrapper>;
      
      private var m_data:Object = new Object();
      
      public function MeleeFinisherPrompt()
      {
         super();
         this.m_buttonPrompts = new Vector.<ButtonPromptsWrapper>();
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoved);
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:ButtonPromptsWrapper = null;
         var _loc5_:ButtonPromptsWrapper = null;
         if(this.m_data.PromptData != param1.PromptData)
         {
            _loc2_ = param1.PromptData;
            _loc3_ = 0;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc3_ >= this.m_buttonPrompts.length)
               {
                  _loc5_ = new ButtonPromptsWrapper();
                  _loc5_.y = _loc3_ * PROMPT_Y_SPACING;
                  addChild(_loc5_);
                  this.m_buttonPrompts.push(_loc5_);
               }
               _loc4_ = this.m_buttonPrompts[_loc3_];
               _loc4_.visible = true;
               _loc4_.updateData(_loc2_[_loc3_]);
               _loc3_++;
            }
            _loc3_ = int(_loc2_.length);
            while(_loc3_ < this.m_buttonPrompts.length)
            {
               this.m_buttonPrompts[_loc3_].visible = false;
               _loc3_++;
            }
         }
         this.m_data = param1;
      }
      
      private function onRemoved(param1:Event) : void
      {
         while(this.m_buttonPrompts.length > 0)
         {
            this.m_buttonPrompts.pop().release();
         }
      }
   }
}

