package knt.hud.damagedirection
{
   import flash.display.Sprite;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.hud.*;
   
   public class OffscreenMeleeDirectionWidget extends BaseControl
   {
      
      private static const PARRY_TYPE_NON_BLOCKABLE:int = 0;
      
      private static const PARRY_TYPE_PERFECTABLE:int = 1;
      
      private static const PARRY_TYPE_STANDARD_BLOCK:int = 2;
      
      private var m_view:OffscreenMeleeDirectionWidgetView;
      
      private var m_container:Sprite;
      
      public var m_widgetElements:Array = [];
      
      public function OffscreenMeleeDirectionWidget()
      {
         super();
         this.m_view = new OffscreenMeleeDirectionWidgetView();
         addChild(this.m_view);
         this.m_container = new Sprite();
         this.m_view.addChild(this.m_container);
      }
      
      public function onSetData(param1:Array) : void
      {
         var _loc3_:WidgetElement = null;
         var _loc4_:OffscreenMeleeDirectionWidgetIndicatorView = null;
         var _loc5_:Object = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:WidgetElement = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = null;
            _loc4_ = null;
            if(_loc2_ >= this.m_widgetElements.length)
            {
               _loc3_ = new WidgetElement();
               _loc3_.view = new OffscreenMeleeDirectionWidgetIndicatorView();
               _loc3_.view.visible = false;
               this.m_container.addChild(_loc3_.view);
               this.m_widgetElements.push(_loc3_);
            }
            else
            {
               _loc3_ = this.m_widgetElements[_loc2_];
            }
            _loc4_ = _loc3_.view;
            _loc5_ = param1[_loc2_];
            if(_loc5_.isActive)
            {
               _loc6_ = _loc3_.humanoidID != _loc5_.humanoidID || _loc3_.isActive != _loc5_.isActive || _loc3_.isAttackerOnScreen != _loc5_.isAttackerOnScreen;
               if(_loc6_)
               {
                  _loc7_ = 0;
                  switch(_loc5_.eParryType)
                  {
                     case PARRY_TYPE_NON_BLOCKABLE:
                        break;
                     case PARRY_TYPE_PERFECTABLE:
                        _loc7_ = 40;
                        break;
                     case PARRY_TYPE_STANDARD_BLOCK:
                        _loc7_ = 40;
                  }
                  if(!_loc5_.isAttackerOnScreen)
                  {
                     this.playMarkerClip(_loc4_,_loc7_);
                  }
                  else if(!_loc3_.isAttackerOnScreen)
                  {
                     this.stopMarkerClip(_loc4_,_loc7_);
                  }
                  else
                  {
                     _loc4_.visible = false;
                  }
               }
            }
            else if(_loc3_.isActive)
            {
               Animate.kill(_loc4_);
               _loc4_.visible = false;
            }
            _loc3_.humanoidID = _loc5_.humanoidID;
            _loc3_.isActive = _loc5_.isActive;
            _loc3_.isAttackerOnScreen = _loc5_.isAttackerOnScreen;
            _loc2_++;
         }
         _loc2_ = int(param1.length);
         while(_loc2_ < this.m_widgetElements.length)
         {
            _loc8_ = this.m_widgetElements[_loc2_];
            if(_loc8_.isActive)
            {
               _loc8_.isActive = false;
               _loc8_.humanoidID = -1;
               _loc8_.isAttackerOnScreen = true;
               _loc8_.view.visible = false;
               Animate.kill(_loc8_.view);
            }
            _loc2_++;
         }
      }
      
      private function playMarkerClip(param1:Sprite, param2:int) : void
      {
         param1.visible = true;
         param1.alpha = 1;
         Animate.fromTo(param1,1.2,0,{"frames":1 + param2},{"frames":20 + param2},Animate.ExpoOut);
      }
      
      private function stopMarkerClip(param1:Sprite, param2:int) : void
      {
         var mc:Sprite = param1;
         var frameOffset:int = param2;
         Animate.fromTo(mc,0.2,0,{"frames":26 + frameOffset},{"frames":36 + frameOffset},Animate.ExpoOut,function():void
         {
            mc.visible = false;
         });
      }
   }
}

import knt.hud.OffscreenMeleeDirectionWidgetIndicatorView;

class WidgetElement
{
   
   public var view:OffscreenMeleeDirectionWidgetIndicatorView;
   
   public var humanoidID:int = -1;
   
   public var isActive:Boolean = false;
   
   public var isAttackerOnScreen:Boolean = true;
   
   public function WidgetElement()
   {
      super();
   }
}
