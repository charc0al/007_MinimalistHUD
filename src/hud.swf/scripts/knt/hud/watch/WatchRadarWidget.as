package knt.hud.watch
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.eavesdrop.EavesdropWidget;
   import knt.hud.objectives.ObjectivesMarkerWidget;
   import knt.hud.*;
   
   public class WatchRadarWidget extends BaseControl
   {
      private static const BASE_SCALE:Number = 0.75;
      
      private static const AIMING_SCALE:Number = BASE_SCALE * 1.3;
      
      private static const BASE_X_OFFSET:Number = -45;
      
      private static const PING_TYPE_HUMANOID:int = 1;
      
      private static const PING_TYPE_ITEM:int = 2;
      
      public var m_view:WatchRadarWidgetView;
      
      private var m_targetsArray:Array;
      
      private var m_qModeTargetsArray:Array;
      
      private var m_QlensRegular:Boolean = false;
      
      private var m_QlensGodMode:Boolean = false;
      
      private var m_isAimingWatch:Boolean = false;
      
      public function WatchRadarWidget()
      {
         super();
         this.m_view = new WatchRadarWidgetView();
         this.m_view.scaleX = this.m_view.scaleY = BASE_SCALE;
         this.m_view.x = BASE_X_OFFSET;
         addChild(this.m_view);
         this.m_targetsArray = new Array();
         this.m_qModeTargetsArray = new Array();
         this.hideCompass();
      }
      
      public function onSetData(param1:Object) : void
      {
         ObjectivesMarkerWidget.setGlobalWatchState(Boolean(param1.IsAimingWatch));
         EavesdropWidget.setGlobalWatchState(Boolean(param1.IsAimingWatch));
         this.hideCompass();
         if(param1.HasInfiniteGadgetResources)
         {
            if(!this.m_QlensGodMode)
            {
               this.runFancyShimmerFx();
               this.m_QlensRegular = false;
               this.m_QlensGodMode = true;
            }
         }
         else if(!this.m_QlensRegular)
         {
            if(this.m_QlensGodMode)
            {
               this.runRemoveFancyShimmerFx();
            }
            this.m_QlensGodMode = false;
            this.m_QlensRegular = true;
         }
         if(param1.IsAimingWatch)
         {
            if(!this.m_isAimingWatch)
            {
               Animate.kill(this.m_view);
               Animate.to(this.m_view,0.2,0,{
                  "x":BASE_X_OFFSET - 180,
                  "y":100,
                  "scaleX":AIMING_SCALE,
                  "scaleY":AIMING_SCALE,
                  "alpha":0
               },Animate.ExpoOut);
               this.m_isAimingWatch = true;
            }
         }
         else if(this.m_isAimingWatch)
         {
            Animate.kill(this.m_view);
            Animate.to(this.m_view,0.2,0,{
               "x":BASE_X_OFFSET,
               "y":0,
               "scaleX":BASE_SCALE,
               "scaleY":BASE_SCALE,
               "alpha":1
            },Animate.ExpoOut);
            this.m_isAimingWatch = false;
         }
         if(this.m_isAimingWatch)
         {
            return;
         }
         if(param1.Objectives != null)
         {
            this.syncTargets(param1.Objectives);
         }
         if(param1.GadgetTargets != null)
         {
            this.syncQModeTargets(param1.GadgetTargets);
         }
      }
      
      public function syncQModeTargets(param1:Array) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.m_qModeTargetsArray.length)
         {
            _loc4_ = false;
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               if(param1[_loc5_].ID == this.m_qModeTargetsArray[_loc2_].ID)
               {
                  _loc4_ = true;
               }
               _loc5_++;
            }
            if(!_loc4_)
            {
               this.m_view.container_mc.removeChild(this.m_qModeTargetsArray[_loc2_].pingTarget);
               this.m_qModeTargetsArray.splice(_loc2_,1);
               _loc2_--;
            }
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc6_ = false;
            _loc7_ = 0;
            while(_loc7_ < this.m_qModeTargetsArray.length)
            {
               if(param1[_loc3_].ID == this.m_qModeTargetsArray[_loc7_].ID)
               {
                  _loc6_ = true;
                  this.updateQModeTargetView(this.m_qModeTargetsArray[_loc7_].pingTarget,param1[_loc3_]);
               }
               _loc7_++;
            }
            if(!_loc6_)
            {
               if(param1[_loc3_].TargetType == PING_TYPE_HUMANOID)
               {
                  _loc8_ = new WatchRadarWidgetQModeHumanoidArrowView();
                  MenuUtils.setColor(_loc8_,MenuConstantsKnt.COLOR_RED);
                  this.m_view.container_mc.addChild(_loc8_);
                  this.updateQModeTargetView(_loc8_,param1[_loc3_]);
                  this.m_qModeTargetsArray.push({
                     "pingTarget":_loc8_,
                     "ID":param1[_loc3_].ID
                  });
               }
            }
            _loc3_++;
         }
      }
      
      private function updateQModeTargetView(param1:*, param2:Object) : void
      {
         param1.rotation = param2.Angle;
      }
      
      private function syncTargets(param1:Array) : void
      {
         var j:int;
         var m:int;
         var foundTargetToKeep:Boolean = false;
         var i:int = 0;
         var foundTarget:Boolean = false;
         var n:int = 0;
         var pingTarget:WatchRadarWidgetArrowView = null;
         var targets:Array = param1;
         if(targets == null)
         {
            return;
         }
         j = 0;
         while(j < this.m_targetsArray.length)
         {
            foundTargetToKeep = false;
            i = 0;
            while(i < targets.length)
            {
               if(targets[i].Id == this.m_targetsArray[j].Id)
               {
                  foundTargetToKeep = true;
               }
               i++;
            }
            if(!foundTargetToKeep)
            {
               Animate.kill(this.m_targetsArray[j].pingTarget.arrow_mc.fill_mc);
               Animate.kill(this.m_targetsArray[j].pingTarget.init_mc);
               this.m_view.container_mc.removeChild(this.m_targetsArray[j].pingTarget);
               this.m_targetsArray.splice(j,1);
               j--;
            }
            j++;
         }
         m = 0;
         while(m < targets.length)
         {
            foundTarget = false;
            n = 0;
            while(n < this.m_targetsArray.length)
            {
               if(targets[m].Id == this.m_targetsArray[n].Id)
               {
                  foundTarget = true;
                  this.updateTargetView(this.m_targetsArray[n].pingTarget,targets[m]);
               }
               n++;
            }
            if(!foundTarget)
            {
               pingTarget = new WatchRadarWidgetArrowView();
               MenuUtils.setColor(pingTarget,MenuConstantsKnt.COLOR_OBJECTIVE);
               this.m_view.container_mc.addChild(pingTarget);
               Animate.to(pingTarget.arrow_mc.fill_mc,1.2,0.5,{"alpha":0},Animate.ExpoOut);
               pingTarget.init_mc.visible = true;
               pingTarget.init_mc.gotoAndPlay(2);
               Animate.delay(pingTarget.init_mc,1.2,function():void
               {
                  pingTarget.init_mc.visible = false;
               });
               this.updateTargetView(pingTarget,targets[m]);
               this.m_targetsArray.push({
                  "pingTarget":pingTarget,
                  "Id":targets[m].Id
               });
            }
            m++;
         }
      }
      
      private function updateTargetView(param1:*, param2:Object) : void
      {
         param1.rotation = param2.Angle;
      }
      
      private function runFancyShimmerFx() : void
      {
         this.hideCompass();
      }
      
      private function runRemoveFancyShimmerFx() : void
      {
         this.hideCompass();
      }
      
      private function hideCompass() : void
      {
         Animate.kill(this.m_view.compass_mc);
         Animate.kill(this.m_view.compass_mc.shimmer_mc);
         this.m_view.compass_mc.visible = false;
         this.m_view.compass_mc.alpha = 0;
      }
      
      public function testQMode() : void
      {
         if(this.m_QlensGodMode)
         {
            this.runFancyShimmerFx();
         }
      }
   }
}
