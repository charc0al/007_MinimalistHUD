package knt.hud.weapons
{
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import knt.hud.*;
   
   public class ThrowableReticleWidget extends BaseControl
   {
      
      private var m_view:ThrowableReticleWidgetView;
      
      private var m_buttonPrompts:Vector.<ButtonPromptImage>;
      
      private var m_data:Object = new Object();
      
      public function ThrowableReticleWidget()
      {
         super();
         this.m_view = new ThrowableReticleWidgetView();
         this.m_view.center_mc.alpha = 0;
         this.m_view.frame_mc.alpha = 0;
         this.m_view.frame_mc.inner_mc.alpha = 0;
         this.m_view.center_mc.visible = false;
         this.m_view.frame_mc.visible = false;
         this.m_view.frame_mc.inner_mc.visible = false;
         this.m_buttonPrompts = new Vector.<ButtonPromptImage>();
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
         if(this.m_data.quickThrowPromptData != param1.quickThrowPromptData)
         {
            this.processButtonPrompts(param1.quickThrowPromptData);
         }
         if(this.m_data.showPrompt != param1.showPrompt)
         {
            this.m_view.promptholder_mc.visible = param1.showPrompt;
         }
         if(param1.targetId == 0)
         {
            this.initCrosshair(false);
         }
         else if(this.m_data.targetId != param1.targetId)
         {
            this.initCrosshair(true);
         }
         this.m_data = param1;
      }
      
      private function initCrosshair(param1:Boolean) : void
      {
         Animate.kill(this.m_view.center_mc);
         Animate.kill(this.m_view.frame_mc);
         this.m_view.center_mc.alpha = 0;
         this.m_view.frame_mc.alpha = 0;
         this.m_view.frame_mc.scaleX = this.m_view.frame_mc.scaleY = 2;
         this.loopFrameInnerMc(false);
         this.m_view.center_mc.visible = false;
         this.m_view.frame_mc.visible = false;
         this.m_view.frame_mc.inner_mc.visible = false;
         if(param1)
         {
            this.m_view.center_mc.visible = true;
            this.m_view.frame_mc.visible = true;
            this.m_view.frame_mc.inner_mc.visible = true;
            Animate.to(this.m_view.frame_mc,0.4,0,{
               "alpha":1,
               "scaleX":1,
               "scaleY":1
            },Animate.ExpoOut);
            Animate.fromTo(this.m_view.center_mc,0.2,0.2,{"frames":0},{"frames":20},Animate.Linear);
            Animate.addTo(this.m_view.center_mc,0.2,0.2,{"alpha":0.8},Animate.ExpoOut);
            this.loopFrameInnerMc(true);
         }
      }
      
      private function loopFrameInnerMc(param1:Boolean) : void
      {
         var loop:Boolean = param1;
         Animate.kill(this.m_view.frame_mc.inner_mc);
         this.m_view.frame_mc.inner_mc.alpha = 0;
         this.m_view.frame_mc.inner_mc.scaleX = this.m_view.frame_mc.inner_mc.scaleY = 1;
         if(loop)
         {
            Animate.delay(this.m_view.frame_mc.inner_mc,0.4,function():void
            {
               m_view.frame_mc.alpha = 1;
               Animate.to(m_view.frame_mc,0.6,0,{"alpha":0.6},Animate.Linear);
               m_view.frame_mc.inner_mc.alpha = 1;
               Animate.to(m_view.frame_mc.inner_mc,0.6,0,{
                  "alpha":0,
                  "scaleX":0.6,
                  "scaleY":0.6
               },Animate.Linear,function():void
               {
                  loopFrameInnerMc(true);
               });
            });
         }
      }
      
      public function setCrosshairPosition(param1:Number, param2:Number) : void
      {
         this.m_view.center_mc.x = param1;
         this.m_view.center_mc.y = param2 - 10;
         this.m_view.frame_mc.x = param1;
         this.m_view.frame_mc.y = param2 - 10;
         this.m_view.promptholder_mc.x = param1;
         this.m_view.promptholder_mc.y = param2 - 10;
      }
      
      private function processButtonPrompts(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:ButtonPromptImage = null;
         var _loc6_:ButtonPromptImage = null;
         var _loc2_:int = 0;
         var _loc3_:Array = param1.aElements;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(_loc2_ >= this.m_buttonPrompts.length)
            {
               _loc6_ = ButtonPromptImage.AcquireInstance();
               _loc6_.x = 40 + _loc2_ * 25;
               this.m_buttonPrompts.push(_loc6_);
               this.m_view.promptholder_mc.addChild(_loc6_);
            }
            _loc4_ = _loc3_[_loc2_];
            _loc5_ = this.m_buttonPrompts[_loc2_];
            _loc5_.visible = true;
            _loc5_.platform = param1.controllerType;
            _loc5_.scaleX = _loc5_.scaleY = _loc5_.platform == "key" ? 0.5 : 0.7;
            if((_loc5_.platform == CommonUtils.CONTROLLER_TYPE_KEY || _loc4_.iconId == -1) && _loc4_.keyGlyph != "")
            {
               _loc5_.customKey = _loc4_.keyGlyph;
            }
            else
            {
               _loc5_.button = _loc4_.iconId;
            }
            _loc2_++;
         }
         _loc2_ = int(_loc3_.length);
         while(_loc2_ < this.m_buttonPrompts.length)
         {
            this.m_buttonPrompts[_loc2_].visible = false;
            _loc2_++;
         }
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         super.onSetSize(param1,param2);
         this.m_view.x = param1 / 2;
         this.m_view.y = param2 / 2;
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         this.visible = param1;
         if(!param1)
         {
            this.initCrosshair(false);
         }
      }
   }
}

