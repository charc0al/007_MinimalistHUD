package knt.hud.objectives
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.hud.KntHudUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class ObjectivesMarkerWidget extends BaseControl
   {
      public static var s_isAimingWatchGlobal:Boolean = false;
      
      private static var s_instances:Array = [];
       
      public static const STATE_ACTIVE:int = 0;
      
      public static const STATE_COMPLETED:int = 1;
      
      public static const STATE_MISSED:int = 2;
      
      public static const TYPE_OBJECTIVE:int = 0;
      
      public static const TYPE_SUB_OBJECTIVE:int = 1;
      
      public static const TYPE_HINT:int = 2;
      
      public static const TYPE_ITEM:int = 3;
      
      public static const TYPE_OPPORTUNITY:int = 4;
      
      public static const TYPE_OPPORTUNITYSTEP:int = 5;
      
      private static const ICON_BASE_SCALE:Number = 0.84;
      
      private var m_animTestTimeExtension:int = 1;
      
      private var m_view:ObjectivesMarkerWidgetView;
      
      private var m_distanceToTitleThreshold:Number = 0;
      
      private var m_iconMc:*;
      
      private var m_iconHighlightMc:*;
      
      private var m_currentType:int = -1;
      
      private var m_edgeLocked:Boolean = false;
      
      private var m_elevationUpShown:Boolean = false;
      
      private var m_elevationDownShown:Boolean = false;
      
      private var m_isAimingWatch:Boolean = false;
      
      private var m_shouldBeVisible:Boolean = true;
      
      private var m_lastData:Object = null;
      
      public static function setGlobalWatchState(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         s_isAimingWatchGlobal = param1;
         while(_loc2_ < s_instances.length)
         {
            ObjectivesMarkerWidget(s_instances[_loc2_]).onGlobalWatchStateChanged();
            _loc2_++;
         }
      }
      
      public function ObjectivesMarkerWidget()
      {
         super();
         this.m_view = new ObjectivesMarkerWidgetView();
         this.m_view.visible = false;
         this.m_view.direction_mc.alpha = 0;
         this.m_view.elevation_up_mc.visible = false;
         this.m_view.elevation_down_mc.visible = false;
         KntHudUtils.addOutline(this.m_view.icon_container_mc);
         KntHudUtils.addOutline(this.m_view.direction_mc);
         KntHudUtils.addOutline(this.m_view.distance_txt);
         addChild(this.m_view);
         s_instances.push(this);
      }
      
      public function onSetData(param1:Object) : void
      {
         if(param1.id == "distance")
         {
            return;
         }
         this.m_lastData = param1;
         this.m_shouldBeVisible = param1.shouldBeVisible != false;
         this.m_isAimingWatch = this.resolveWatchState(param1);
         if(!this.applyWatchVisibility())
         {
            return;
         }
         if(param1.state == STATE_ACTIVE)
         {
            this.m_view.visible = true;
            if(param1.type != this.m_currentType)
            {
               this.killAllAnimations();
               while(this.m_view.icon_container_mc.numChildren > 0)
               {
                  this.m_view.icon_container_mc.removeChildAt(0);
               }
               this.m_iconMc = null;
               this.m_iconHighlightMc = null;
               switch(param1.type)
               {
                  case TYPE_OBJECTIVE:
                     this.m_iconMc = new ObjectivesIconMainObjectiveView();
                     this.m_iconMc.gotoAndStop("tracked");
                     this.m_iconHighlightMc = new ObjectivesIconMainObjectiveView();
                     this.m_iconHighlightMc.gotoAndStop("tracked");
                     break;
                  case TYPE_SUB_OBJECTIVE:
                     this.m_iconMc = new ObjectivesIconMainSubobjectiveView();
                     this.m_iconMc.gotoAndStop("tracked");
                     this.m_iconHighlightMc = new ObjectivesIconMainSubobjectiveView();
                     this.m_iconHighlightMc.gotoAndStop("tracked");
                     break;
                  case TYPE_OPPORTUNITY:
                  case TYPE_OPPORTUNITYSTEP:
                     this.m_iconMc = new ObjectivesIconOpportunityView();
                     this.m_iconMc.gotoAndStop("tracked");
                     this.m_iconHighlightMc = new ObjectivesIconOpportunityView();
                     this.m_iconHighlightMc.gotoAndStop("tracked");
                     break;
                  default:
                     this.m_iconMc = new ObjectivesNotificationWidgetIconErrorView();
                     this.m_iconHighlightMc = new ObjectivesNotificationWidgetIconErrorView();
               }
               this.m_iconHighlightMc.alpha = 0;
               MenuUtils.setColor(this.m_iconMc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
               MenuUtils.setColor(this.m_iconHighlightMc,MenuConstantsKnt.COLOR_WHITE,false);
               this.m_view.icon_container_mc.addChild(this.m_iconMc);
               this.m_view.icon_container_mc.addChild(this.m_iconHighlightMc);
                this.applyStaticIconState();
                this.m_currentType = param1.type;
             }
            MenuUtils.setupText(this.m_view.distance_txt,"<font face=\"$numbersbold\">" + MenuUtils.formatNumber(Math.round(param1.distance),false) + "</font>m",12,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
            this.calcElevation(param1.distanceZ);
         }
         else if(param1.state == STATE_COMPLETED)
         {
            this.killAllAnimations();
            this.m_view.visible = false;
         }
         else if(param1.state == STATE_MISSED)
         {
            this.killAllAnimations();
            this.m_view.visible = false;
         }
      }
      
      private function onGlobalWatchStateChanged() : void
      {
         if(this.m_lastData == null)
         {
            return;
         }
         this.m_isAimingWatch = this.resolveWatchState(this.m_lastData);
         this.applyWatchVisibility();
      }
      
       private function applyStaticIconState() : void
       {
          if(this.m_iconMc != null)
          {
             this.m_iconMc.scaleX = this.m_iconMc.scaleY = ICON_BASE_SCALE;
          }
          if(this.m_iconHighlightMc != null)
          {
             this.m_iconHighlightMc.scaleX = this.m_iconHighlightMc.scaleY = ICON_BASE_SCALE;
             this.m_iconHighlightMc.alpha = 0;
          }
       }
      
      public function edgeAngle(param1:Number) : void
      {
         if(param1 < 0)
         {
            if(this.m_edgeLocked)
            {
               this.killAllAnimations();
               Animate.to(this.m_view.distance_txt,0.15,0.05,{"alpha":1},Animate.Linear);
               Animate.to(this.m_view.direction_mc,0.15,0,{"alpha":0},Animate.Linear);
               this.applyStaticIconState();
               this.m_edgeLocked = false;
            }
         }
         else
         {
            if(!this.m_edgeLocked)
            {
               this.killAllAnimations();
               Animate.to(this.m_view.distance_txt,0.15,0,{"alpha":0},Animate.Linear);
               Animate.to(this.m_view.direction_mc,0.15,0.05,{"alpha":1},Animate.Linear);
                this.applyStaticIconState();
                this.m_edgeLocked = true;
            }
            this.m_view.direction_mc.rotation = param1;
         }
      }
      
      private function calcElevation(param1:Number) : void
      {
         if(param1 > 3)
         {
            if(!this.m_elevationDownShown)
            {
               this.m_view.elevation_up_mc.visible = false;
               this.m_view.elevation_down_mc.visible = true;
               this.m_elevationUpShown = false;
               this.m_elevationDownShown = true;
            }
         }
         else if(param1 < -3)
         {
            if(!this.m_elevationUpShown)
            {
               this.m_view.elevation_up_mc.visible = true;
               this.m_view.elevation_down_mc.visible = false;
               this.m_elevationUpShown = true;
               this.m_elevationDownShown = false;
            }
         }
         else if(this.m_elevationUpShown || this.m_elevationDownShown)
         {
            this.m_view.elevation_up_mc.visible = false;
            this.m_view.elevation_down_mc.visible = false;
            this.m_elevationUpShown = false;
            this.m_elevationDownShown = false;
         }
      }
      
      private function killAllAnimations(param1:Boolean = false) : void
      {
         if(this.m_iconHighlightMc && this.m_iconMc)
         {
            Animate.kill(this.m_iconHighlightMc);
            Animate.kill(this.m_iconMc);
         }
         if(!param1)
         {
            Animate.kill(this.m_view.distance_txt);
            Animate.kill(this.m_view.direction_mc);
         }
      }
      
      [PROPERTY(HELPTEXT="Proximity distance for when to hide the Objective Title")]
      public function set hideTitleDistance(param1:Number) : void
      {
         this.m_distanceToTitleThreshold = param1;
      }
      
      private function resolveWatchState(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1.commonData != null && param1.commonData.isAimingWatch != undefined)
         {
            return Boolean(param1.commonData.isAimingWatch);
         }
         if(param1.isAimingWatch != undefined)
         {
            return Boolean(param1.isAimingWatch);
         }
         if(param1.m_isAimingWatch != undefined)
         {
            return Boolean(param1.m_isAimingWatch);
         }
         if(param1.IsInQLens != undefined)
         {
            return Boolean(param1.IsInQLens);
         }
         return s_isAimingWatchGlobal;
      }
      
      private function applyWatchVisibility() : Boolean
      {
         if(!this.m_isAimingWatch || !this.m_shouldBeVisible)
         {
            this.killAllAnimations();
            this.m_view.visible = false;
            return false;
         }
         if(this.m_lastData != null && this.m_lastData.state == STATE_ACTIVE)
         {
            this.m_view.visible = true;
         }
         return true;
      }
   }
}
