package knt.hud.watch
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.TaskletSequencer;
   import knt.hud.*;
   
   public class WatchGadgetResourcesWidget extends BaseControl
   {
      
      private static const PLAYER_RESOURCETYPE_INVALID:uint = 0;
      
      private static const PLAYER_RESOURCETYPE_UNKNOWN:uint = 1;
      
      private static const PLAYER_RESOURCETYPE_ELECTRICAL:uint = 2;
      
      private static const PLAYER_RESOURCETYPE_CHEMICAL:uint = 3;
      
      private static const BASE_X_OFFSET:Number = -18;
      
      private static const AIMING_X_OFFSET:Number = BASE_X_OFFSET - 180;
      
      private static const ELECTRIC_X_OFFSET:Number = -63;
      
      private static const CHEMICAL_X_OFFSET:Number = 9;
      
      private var m_view:WatchGadgetResourcesWidgetView;
      
      private var m_electric:WatchGadgetResourceDialWidget;
      
      private var m_chemical:WatchGadgetResourceDialWidget;
      
      private var m_triangulationModeHidden:Boolean = false;
      
      private var m_electricIsRecharging:Boolean = false;
      
      private var m_chemicalIsRecharging:Boolean = false;
      
      private var m_QlensRegular:Boolean = false;
      
      private var m_QlensGodMode:Boolean = false;
      
      private var m_rechargeDuration:Number = 0;
      
      private var m_isAimingWatch:Boolean = true;
      
      public function WatchGadgetResourcesWidget()
      {
         super();
         this.m_view = new WatchGadgetResourcesWidgetView();
         this.m_view.x = AIMING_X_OFFSET;
         this.m_view.y = 100;
         this.m_view.scaleX = this.m_view.scaleY = 1.3;
         this.m_view.alpha = 0;
         this.m_electric = new WatchGadgetResourceDialWidget();
         this.m_electric.setParentClass(this);
         this.m_electric.x = ELECTRIC_X_OFFSET;
         this.m_view.container_mc.addChild(this.m_electric);
         this.m_chemical = new WatchGadgetResourceDialWidget();
         this.m_chemical.setParentClass(this);
         this.m_chemical.x = CHEMICAL_X_OFFSET;
         this.m_view.container_mc.addChild(this.m_chemical);
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
         var ts:TaskletSequencer = null;
         var data:Object = param1;
         ts = TaskletSequencer.getGlobalInstance();
         ts.addChunk(function():void
         {
            if(data.isInTriangulationMode)
            {
               if(!m_triangulationModeHidden)
               {
                  m_view.visible = false;
                  m_triangulationModeHidden = true;
                  return;
               }
            }
            else if(m_triangulationModeHidden)
            {
               m_view.visible = true;
               m_triangulationModeHidden = false;
            }
             if(data.isAimingWatch)
             {
                if(m_isAimingWatch)
                {
                   Animate.kill(m_view);
                   Animate.to(m_view,0.2,0,{
                      "x":BASE_X_OFFSET,
                      "y":0,
                      "scaleX":1,
                      "scaleY":1,
                      "alpha":1
                   },Animate.ExpoOut);
                   m_isAimingWatch = false;
                }
             }
             else if(!m_isAimingWatch)
             {
                Animate.kill(m_view);
                Animate.to(m_view,0.2,0,{
                   "x":AIMING_X_OFFSET,
                   "y":100,
                   "scaleX":1.3,
                   "scaleY":1.3,
                   "alpha":0
                },Animate.ExpoOut);
                m_isAimingWatch = true;
             }
             if(m_isAimingWatch)
             {
                return;
             }
             ts.addChunk(function():void
             {
                m_electric.onSetData(data.electricalResource);
                m_chemical.onSetData(data.chemicalResource);
             });
             ts.addChunk(function():void
             {
                if(data.hasInfiniteGadgetResources)
                {
                   if(!m_QlensGodMode)
                   {
                      runFancyShimmerFx();
                      m_QlensRegular = false;
                      m_QlensGodMode = true;
                   }
                }
                else if(!m_QlensRegular)
                {
                   if(m_QlensGodMode)
                   {
                      runRemoveFancyShimmerFx();
                   }
                   m_QlensGodMode = false;
                   m_QlensRegular = true;
                }
             });
          });
       }
      
      private function runFancyShimmerFx() : void
      {
         Animate.kill(this.m_view.shimmer_mc);
         Animate.kill(this.m_view.container_mc);
         Animate.fromTo(this.m_view.shimmer_mc,2,0,{"frames":0},{"frames":40},Animate.Linear);
         Animate.fromTo(this.m_view.container_mc,0.2,0.1,{
            "scaleX":1.3,
            "scaleY":1.3
         },{
            "scaleX":1,
            "scaleY":1
         },Animate.Linear);
      }
      
      private function runRemoveFancyShimmerFx() : void
      {
         Animate.kill(this.m_view.shimmer_mc);
         Animate.kill(this.m_view.container_mc);
         Animate.fromTo(this.m_view.shimmer_mc,0.4,0,{"frames":8},{"frames":0},Animate.Linear);
         Animate.fromTo(this.m_view.container_mc,0.2,0.1,{
            "scaleX":0.9,
            "scaleY":0.9
         },{
            "scaleX":1,
            "scaleY":1
         },Animate.Linear);
      }
      
      public function set electricRecharging(param1:Boolean) : void
      {
         if(this.m_electricIsRecharging != param1)
         {
            this.m_electric.showRechargeTimer(param1);
            this.m_electricIsRecharging = param1;
         }
      }
      
      public function set electricRechargeRemainingTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(this.m_electricIsRecharging)
         {
            _loc2_ = 360 - 360 * (param1 / this.m_rechargeDuration);
            this.m_electric.setRechargeTimer(_loc2_);
         }
      }
      
      public function set chemicalRecharging(param1:Boolean) : void
      {
         if(this.m_chemicalIsRecharging != param1)
         {
            this.m_chemical.showRechargeTimer(param1);
            this.m_chemicalIsRecharging = param1;
         }
      }
      
      public function set chemicalRechargeRemainingTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(this.m_chemicalIsRecharging)
         {
            _loc2_ = 360 - 360 * (param1 / this.m_rechargeDuration);
            this.m_chemical.setRechargeTimer(_loc2_);
         }
      }
      
      public function set rechargeDuration(param1:Number) : void
      {
         if(this.m_rechargeDuration != param1)
         {
            this.m_rechargeDuration = param1;
            this.m_electric.rechargeDuration(param1);
            this.m_chemical.rechargeDuration(param1);
         }
      }
   }
}

