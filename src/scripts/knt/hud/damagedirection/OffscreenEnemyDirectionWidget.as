package knt.hud.damagedirection
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class OffscreenEnemyDirectionWidget extends BaseControl
   {
      
      private var m_view:OffscreenEnemyDirectionWidgetView;
      
      private var m_container:Sprite;
      
      public var m_childWidgets:Array = [];
      
      public function OffscreenEnemyDirectionWidget()
      {
         super();
         this.m_view = new OffscreenEnemyDirectionWidgetView();
         addChild(this.m_view);
         this.m_container = new Sprite();
         this.m_view.addChild(this.m_container);
         MenuUtils.setColor(this.m_container,MenuConstantsKnt.COLOR_HUD_DANGER_HIGH,false);
         this.m_container.visible = false;
         this.m_container.alpha = 0;
      }
      
      public function onSetData(param1:Array) : void
      {
         var _loc3_:OffscreenEnemyDirectionWidgetIndicatorView = null;
         var _loc4_:Object = null;
         var _loc5_:DisplayObject = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = null;
            if(_loc2_ < this.m_childWidgets.length)
            {
               _loc3_ = this.m_childWidgets[_loc2_] as OffscreenEnemyDirectionWidgetIndicatorView;
            }
            if(_loc3_ == null)
            {
               _loc3_ = new OffscreenEnemyDirectionWidgetIndicatorView();
               this.m_container.addChild(_loc3_);
               this.m_childWidgets.push(_loc3_);
            }
            _loc4_ = param1[_loc2_];
            _loc3_.visible = false;
            _loc2_++;
         }
         _loc2_ = int(param1.length);
         while(_loc2_ < this.m_childWidgets.length)
         {
            _loc5_ = this.m_childWidgets[_loc2_];
            _loc5_.visible = false;
            _loc2_++;
         }
         this.hideAllIndicators();
      }
      
      private function hideAllIndicators() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:int = 0;
         this.m_container.visible = false;
         this.m_container.alpha = 0;
         while(_loc2_ < this.m_childWidgets.length)
         {
            _loc1_ = this.m_childWidgets[_loc2_];
            _loc1_.visible = false;
            _loc2_++;
         }
      }
   }
}
