package knt.hud.watch
{
   import flash.display.BlendMode;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.eavesdrop.EavesdropWidget;
   import knt.hud.objectives.ObjectivesMarkerWidget;
   import knt.hud.*;
   
   public class WatchBaseWidget extends BaseControl
   {
      private static const BASE_SCALE:Number = 0.75;
      
      private static const AIMING_SCALE:Number = BASE_SCALE * 1.3;
      
      private static const BASE_X_OFFSET:Number = -45;
      
      private var m_view:WatchBaseWidgetView;
      
      private var m_interface:*;
      
      private var m_triangulationModeHidden:Boolean = false;
      
      private var m_QlensRegular:Boolean = false;
      
      private var m_QlensGodMode:Boolean = false;
      
      private var m_isAimingWatch:Boolean = false;
      
      public function WatchBaseWidget()
      {
         super();
         this.m_view = new WatchBaseWidgetView();
         if(MenuConstantsKnt.INVERT_Q_WATCH_DISPLAY)
         {
            this.m_view.scaleX = this.m_view.scaleY = AIMING_SCALE;
            this.m_view.x = BASE_X_OFFSET - 180;
            this.m_view.y = 100;
            this.m_view.alpha = 0;
            this.m_isAimingWatch = true;
         }
         else
         {
            this.m_view.scaleX = this.m_view.scaleY = BASE_SCALE;
            this.m_view.x = BASE_X_OFFSET;
            this.m_view.y = 0;
            this.m_view.alpha = 1;
            this.m_isAimingWatch = false;
         }
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
         ObjectivesMarkerWidget.setGlobalWatchState(Boolean(param1.commonData.isAimingWatch));
         EavesdropWidget.setGlobalWatchState(Boolean(param1.commonData.isAimingWatch));
         if(param1.commonData.hasInfiniteGadgetResources)
         {
            if(!this.m_QlensGodMode)
            {
               while(this.m_view.container_mc.numChildren > 0)
               {
                  this.m_view.container_mc.removeChildAt(0);
               }
               this.m_interface = new WatchBaseWidgetInterfaceQModeView();
               this.prepareInterface();
               this.m_view.container_mc.addChild(this.m_interface);
               this.runFancyShimmerFx();
               this.m_QlensRegular = false;
               this.m_QlensGodMode = true;
            }
         }
         else if(!this.m_QlensRegular)
         {
            while(this.m_view.container_mc.numChildren > 0)
            {
               this.m_view.container_mc.removeChildAt(0);
            }
            this.m_interface = new WatchBaseWidgetInterfaceRegularView();
            this.prepareInterface();
            this.m_view.container_mc.addChild(this.m_interface);
            if(this.m_QlensGodMode)
            {
            }
            this.m_QlensGodMode = false;
            this.m_QlensRegular = true;
         }
         if(param1.commonData.isInTriangulationMode)
         {
            if(!this.m_triangulationModeHidden)
            {
               this.m_interface.logo_mc.visible = false;
               this.m_interface.bg_dials_mc.visible = false;
               this.m_interface.bg_no_dials_mc.visible = false;
               this.m_triangulationModeHidden = true;
            }
         }
         else if(this.m_triangulationModeHidden)
         {
            this.m_interface.logo_mc.visible = true;
            this.m_interface.bg_dials_mc.visible = false;
            this.m_interface.bg_no_dials_mc.visible = false;
            this.m_triangulationModeHidden = false;
         }
         this.hideBackgroundFace();
          if((MenuConstantsKnt.INVERT_Q_WATCH_DISPLAY ? Boolean(param1.commonData.isAimingWatch) : !Boolean(param1.commonData.isAimingWatch)))
          {
             if(this.m_isAimingWatch)
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
          }
          else if(!this.m_isAimingWatch)
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
       
       private function runFancyShimmerFx() : void
       {
          Animate.kill(this.m_interface);
          Animate.kill(this.m_interface.shimmer_mc);
          Animate.fromTo(this.m_interface.shimmer_mc,2,0,{"frames":0},{"frames":40},Animate.Linear);
          Animate.fromTo(this.m_interface,0.2,0.1,{
             "scaleX":0.9,
             "scaleY":0.9
          },{
             "scaleX":1,
             "scaleY":1
          },Animate.Linear);
       }
      
      private function prepareInterface() : void
      {
         this.m_interface.bg_dials_mc.blendMode = BlendMode.SUBTRACT;
         this.m_interface.bg_no_dials_mc.blendMode = BlendMode.SUBTRACT;
         this.m_interface.bg_dials_mc.alpha = 0.2;
         this.m_interface.bg_no_dials_mc.alpha = 0.2;
         this.m_interface.bg_dials_mc.visible = false;
         this.m_interface.bg_no_dials_mc.visible = false;
      }
      
      private function hideBackgroundFace() : void
      {
         this.m_interface.bg_dials_mc.visible = false;
         this.m_interface.bg_no_dials_mc.visible = false;
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
