package knt.hud.attentiongain
{
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.objectives.ObjectivesMarkerWidget;
   import knt.hud.*;
   
   public class AttentionGainWidget extends BaseControl
   {
      
      private var m_cameraPitch:Number = 0;
      
      private var m_angleAndPitchFactor:Number = MenuUtils.roundDecimal(1 / 90,3);
      
      private var m_wedgeContainer:Sprite = new Sprite();
      
      private var m_aWedges:Array = new Array();
      
      private var i:int;
      
      public function AttentionGainWidget()
      {
         super();
         addChild(this.m_wedgeContainer);
         this.i = 0;
         while(this.i < 10)
         {
            this.m_aWedges.push(this.addNewWedge());
            ++this.i;
         }
         this.m_wedgeContainer.visible = false;
         this.m_wedgeContainer.alpha = 0;
      }
      
      private function addNewWedge() : Object
      {
         var _loc1_:AttentionGainWidgetView = new AttentionGainWidgetView();
         _loc1_.wedge_mc.yellow_mc.filters = [new GlowFilter(MenuConstantsKnt.COLOR_YELLOW,0.4,8,8,2,2)];
         _loc1_.wedge_mc.white_mc.filters = [new GlowFilter(MenuConstantsKnt.COLOR_WHITE,0.4,8,8,2,2)];
         _loc1_.wedge_mc.bg_mc.filters = [new GlowFilter(MenuConstantsKnt.COLOR_BLACK,0.4,8,8,2,2)];
         _loc1_.visible = false;
         this.m_wedgeContainer.addChild(_loc1_);
         return {
            "iWedge":_loc1_,
            "activated":false
         };
      }
      
      public function onSetData(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:AttentionGainWidgetView = null;
         var _loc4_:int = 0;
         if(!ObjectivesMarkerWidget.s_isAimingWatchGlobal)
         {
            this.hideAllWedges();
            return;
         }
         this.m_wedgeContainer.visible = true;
         this.m_wedgeContainer.alpha = 1;
         while(param1.length > this.m_aWedges.length)
         {
            this.m_aWedges.push(this.addNewWedge());
         }
         this.i = 0;
         while(this.i < param1.length)
         {
            _loc2_ = param1[this.i];
            _loc3_ = this.m_aWedges[this.i].iWedge;
            _loc3_.visible = true;
            this.m_aWedges[this.i].activated = true;
            _loc3_.rotation = -_loc2_.m_angle;
            if(_loc2_.m_attention > 0)
            {
               if(_loc2_.m_prevAttention < 1 && _loc2_.m_attention >= 1)
               {
                  this.playFullAttentionAnim(_loc3_,this.i);
               }
               else if(_loc2_.m_attention < 1)
               {
                  _loc4_ = this.attentionToWedgeFrame(_loc2_.m_attention,_loc2_.m_identificationThresholdToReact,_loc2_.m_identificationThresholdToInvestigate);
                  _loc3_.wedge_mc.yellow_mc.gotoAndStop(_loc4_);
                  _loc3_.wedge_mc.white_mc.gotoAndStop(_loc4_);
                  _loc3_.wedge_mc.bg_mc.gotoAndStop(_loc4_);
               }
            }
            ++this.i;
         }
         while(this.i < this.m_aWedges.length)
         {
            this.m_aWedges[this.i].iWedge.visible = false;
            ++this.i;
         }
      }
      
      private function playFullAttentionAnim(param1:AttentionGainWidgetView, param2:int) : void
      {
         var iWedge:AttentionGainWidgetView = param1;
         var index:int = param2;
         Animate.fromTo(iWedge.wedge_mc.yellow_mc,0.8,0,{"frames":123},{"frames":165},Animate.Linear);
         Animate.fromTo(iWedge.wedge_mc.white_mc,0.8,0,{"frames":123},{"frames":165},Animate.Linear);
         Animate.fromTo(iWedge.wedge_mc.bg_mc,0.8,0,{"frames":123},{"frames":165},Animate.Linear,function():void
         {
         });
      }
      
      private function attentionToWedgeFrame(param1:Number, param2:Number, param3:Number) : int
      {
         var _loc5_:Number = 0;
         if(param1 <= param2)
         {
            _loc5_ = param1 * (1 / param2);
            return int(1 + Math.floor(5 * _loc5_));
         }
         if(param1 <= param3)
         {
            _loc5_ = (param1 - param2) * (1 / (param3 - param2));
            return int(6 + Math.floor(56 * _loc5_));
         }
         _loc5_ = (param1 - param3) * (1 / (1 - param3));
         return int(62 + Math.floor(61 * _loc5_));
      }
      
      private function hideAllWedges() : void
      {
         var _loc1_:int = 0;
         this.m_wedgeContainer.visible = false;
         this.m_wedgeContainer.alpha = 0;
         _loc1_ = 0;
         while(_loc1_ < this.m_aWedges.length)
         {
            this.m_aWedges[_loc1_].activated = false;
            this.m_aWedges[_loc1_].iWedge.visible = false;
            _loc1_++;
         }
      }
   }
}
