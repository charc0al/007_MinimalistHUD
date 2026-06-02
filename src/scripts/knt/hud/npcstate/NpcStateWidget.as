package knt.hud.npcstate
{
   import flash.display.MovieClip;
   import flash.filters.DropShadowFilter;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class NpcStateWidget extends BaseControl
   {
      
      public static const DISTRACTED_IN_AMBIENT:int = 0;
      
      public static const ESCALATING_FROM_AMBIENT:int = 1;
      
      public static const MANHUNT:int = 2;
      
      public static const MANHUNT_INVESTIGATING_DISTURBANCE:int = 3;
      
      public static const COMBAT:int = 4;
      
      public static const COMBAT_DISTRACTED:int = 5;
      
      public static const CALLING_FOR_REINFORCEMENTS:int = 6;
      
      public static const ESCORTING_OUT:int = 7;
      
      public static const ESCORTING_IN:int = 8;
      
      public static const BLUFFED:int = 9;
      
      public static const WATCHER:int = 10;
      
      public static const WATCHER_INFLUENCING:int = 100;
      
      public static const DISORIENTED:int = 11;
      
      public static const INFLUENCED_BY_WATCHER:int = 12;
      
      public static const IS_PRE_CONFRONTING:int = 13;
      
      public static const IS_CONFRONTING:int = 14;
      
      public static const ABOUT_TO_FIRE:int = 103;
      
      public static const RELOADING:int = 101;
      
      public static const POSSIBLY_DISTRACTED:int = 102;
      
      public static const ALLIED_RECRUIT:int = 104;
      
      private static const ICON_CYCLE_DELAY:Number = 1.7;
      
      private var m_pulseAnimRunning:Boolean = false;
      
      private var m_progressShown:Boolean = false;
      
      private var m_currentPrimary:int = -1;
      
      private var m_currentSecondary:int = -1;
      
      private var m_edgeLocked:Boolean = false;
      
      private var m_showEdgeMarker:Boolean = false;
      
      private var m_view:NpcStateWidgetView;
      
      public function NpcStateWidget()
      {
         super();
         this.m_view = new NpcStateWidgetView();
         this.m_view.bg_mc.alpha = 0.2;
         this.m_view.progress_mc.bar_mc.gotoAndStop(0);
         MenuUtils.setColor(this.m_view.progress_mc.bar_mc,MenuConstantsKnt.COLOR_HUD_DANGER_MED);
         this.m_view.progress_mc.bg_mc.alpha = 0.2;
         this.m_view.state_mc.allied_recruit_mc.dropshadow_mc.filters = [new DropShadowFilter(4,90,0,0.5,4,4,0.4,1,false,true)];
         this.m_view.scaleX = this.m_view.scaleY = 0.74;
         this.hideAllStateMcs();
         this.m_view.direction_mc.visible = false;
         this.m_view.progress_mc.visible = false;
         this.m_view.bg_mc.visible = false;
         MenuUtils.setColor(this.m_view.pulse_mc.bg_mc,MenuConstantsKnt.COLOR_HUD_DANGER_HIGH);
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
         if(param1 == null || param1.id == "distance")
         {
            return;
         }
         if(!param1.m_isInWatchView)
         {
            this.hideAllStateMcs();
            this.m_currentPrimary = -1;
            this.m_currentSecondary = -1;
            this.m_progressShown = false;
            this.m_view.progress_mc.visible = false;
            return;
         }
         this.m_progressShown = false;
         var _loc2_:int = -1;
         this.m_view.progress_mc.visible = false;
         if(param1.m_isRecruit)
         {
            _loc2_ = ALLIED_RECRUIT;
            this.m_progressShown = false;
         }
         else if(param1.m_isNpcAboutToFire)
         {
            _loc2_ = ABOUT_TO_FIRE;
            this.m_progressShown = true;
         }
         else if(Boolean(param1.m_isPossiblyDistracted) && Boolean(param1.m_isInWatchView) && !param1.m_isInManhunt)
         {
            _loc2_ = POSSIBLY_DISTRACTED;
         }
         else if(param1.m_isBluffedByPlayerDisguise)
         {
            _loc2_ = BLUFFED;
            this.m_progressShown = false;
         }
         else if(param1.m_isNpcReloading)
         {
            _loc2_ = RELOADING;
            this.m_progressShown = false;
         }
         else if(param1.m_isDisoriented)
         {
            _loc2_ = DISORIENTED;
            this.m_progressShown = true;
         }
         else if(param1.m_isCallingForReinforcements)
         {
            _loc2_ = CALLING_FOR_REINFORCEMENTS;
            this.m_progressShown = true;
         }
         else if(param1.m_isPreConfrontation)
         {
            _loc2_ = IS_PRE_CONFRONTING;
            this.m_progressShown = true;
         }
         else if(param1.m_isConfronting)
         {
            _loc2_ = IS_CONFRONTING;
            this.m_progressShown = true;
         }
         else if(param1.m_isDistracted && !param1.m_isInCombat && !param1.m_isInFakeSurrender && !param1.m_isInManhunt)
         {
            _loc2_ = DISTRACTED_IN_AMBIENT;
         }
         else if(Boolean(param1.m_isWatcher) && Boolean(param1.m_isInWatchView) && !param1.m_isInCombat)
         {
            _loc2_ = param1.m_isInfluencingNPCs ? WATCHER_INFLUENCING : WATCHER;
         }
         else if(param1.m_isBluffed)
         {
            _loc2_ = BLUFFED;
            this.m_progressShown = true;
         }
         else if(Boolean(param1.m_isInfluencedByWatcher) && Boolean(param1.m_isInWatchView))
         {
            _loc2_ = INFLUENCED_BY_WATCHER;
         }
         var _loc3_:int = -1;
         if(_loc2_ != CALLING_FOR_REINFORCEMENTS && _loc2_ != DISORIENTED && _loc2_ != ABOUT_TO_FIRE && _loc2_ != ALLIED_RECRUIT)
         {
            if(Boolean(param1.m_isBluffed) && _loc2_ != BLUFFED)
            {
               _loc3_ = BLUFFED;
               this.m_progressShown = true;
            }
            else if(Boolean(param1.m_isCallingForReinforcements) && _loc2_ != CALLING_FOR_REINFORCEMENTS)
            {
               _loc3_ = CALLING_FOR_REINFORCEMENTS;
               this.m_progressShown = true;
            }
            else if(param1.m_isWatcher && param1.m_isInWatchView && _loc2_ != WATCHER && _loc2_ != WATCHER_INFLUENCING && !param1.m_isInCombat && _loc2_ != DISORIENTED && _loc2_ != DISTRACTED_IN_AMBIENT)
            {
               _loc3_ = param1.m_isInfluencingNPCs ? WATCHER_INFLUENCING : WATCHER;
            }
            else if(param1.m_isInfluencedByWatcher && param1.m_isInWatchView && _loc2_ != INFLUENCED_BY_WATCHER && _loc2_ != DISORIENTED && _loc2_ != POSSIBLY_DISTRACTED)
            {
               _loc3_ = INFLUENCED_BY_WATCHER;
            }
            else if(Boolean(param1.m_isDisoriented) && _loc2_ != DISORIENTED)
            {
               _loc3_ = DISORIENTED;
               this.m_progressShown = true;
            }
            else if(param1.m_isDistracted && _loc2_ != DISTRACTED_IN_AMBIENT && !param1.m_isInCombat && !param1.m_isInFakeSurrender && !param1.m_isInManhunt)
            {
               _loc3_ = DISTRACTED_IN_AMBIENT;
            }
         }
         if(this.m_currentPrimary != _loc2_ || this.m_currentSecondary != _loc3_)
         {
            if(_loc3_ < 0)
            {
               this.m_view.state_mc.scaleX = 1;
               this.showIcon(_loc2_);
            }
            else
            {
               this.cycleIcons(_loc2_,_loc3_);
            }
            this.m_currentPrimary = _loc2_;
            this.m_currentSecondary = _loc3_;
         }
         if(this.m_progressShown)
         {
            if(this.m_currentPrimary == RELOADING || this.m_currentSecondary == RELOADING)
            {
               this.setProgress(param1.m_npcStateIconReloadingProgress,true);
            }
            else if(this.m_currentPrimary == ABOUT_TO_FIRE)
            {
               this.setProgress(param1.m_npcStateIconAboutToFireProgress,true);
            }
            else if(this.m_currentPrimary == IS_PRE_CONFRONTING)
            {
               this.setProgress(param1.m_npcStateIconPreConfrontationProgress,true);
            }
            else if(this.m_currentPrimary == IS_CONFRONTING)
            {
               this.setProgress(param1.m_npcStateIconLastWarningProgress,true);
            }
            else if(this.m_currentPrimary == CALLING_FOR_REINFORCEMENTS || this.m_currentSecondary == CALLING_FOR_REINFORCEMENTS)
            {
               this.setProgress(param1.m_stateIconReinforcementsCallProgress,true);
            }
            else if(this.m_currentPrimary == BLUFFED || this.m_currentSecondary == BLUFFED)
            {
               this.setProgress(param1.m_npcStateIconBluffProgress,true);
            }
            else if(this.m_currentPrimary == DISORIENTED || this.m_currentSecondary == DISORIENTED)
            {
               this.setProgress(1 - param1.m_npcStateIconDisorientedProgress,true);
            }
            else
            {
               this.setProgress(0,false);
            }
         }
         else
         {
            this.setProgress(0,false);
         }
      }
      
      private function showIcon(param1:int) : void
      {
         this.hideAllStateMcs();
         this.m_showEdgeMarker = true;
         this.m_view.bg_mc.width = this.m_view.bg_mc.height = this.m_progressShown ? 45 : 36;
         this.m_view.bg_mc.visible = true;
         switch(param1)
         {
            case ABOUT_TO_FIRE:
               this.m_view.state_mc.about_to_fire_mc.visible = true;
               this.blinkIcon(this.m_view.state_mc.about_to_fire_mc.back_mc,true,0.4);
               MenuUtils.setColor(this.m_view.progress_mc.bar_mc,MenuConstantsKnt.COLOR_WHITE);
               this.pulseAnim(true);
               break;
            case DISTRACTED_IN_AMBIENT:
               CommonUtils.playSound(this,"UI_HUD_AI_DistractedtoInvestigate");
               this.m_view.state_mc.distracted_in_ambient_mc.visible = true;
               this.send_OnDistractedInAmbientTriggered();
               break;
            case CALLING_FOR_REINFORCEMENTS:
               this.m_view.state_mc.calling_for_reinforcements_mc.visible = true;
               this.blinkIcon(this.m_view.state_mc.calling_for_reinforcements_mc.back_mc,true,0.4);
               break;
            case BLUFFED:
               this.m_view.state_mc.bluffed_mc.visible = true;
               this.m_view.state_mc.bluffed_mc.alpha = 1;
               break;
            case WATCHER:
               this.m_view.state_mc.watcher_mc.visible = true;
               this.m_view.state_mc.watcher_mc.alpha = 1;
               Animate.kill(this.m_view.state_mc.watcher_mc);
               break;
            case WATCHER_INFLUENCING:
               this.m_view.state_mc.watcher_mc.visible = true;
               this.m_view.state_mc.watcher_mc.alpha = 1;
               break;
            case INFLUENCED_BY_WATCHER:
               this.m_view.state_mc.watcher_influenced_mc.visible = true;
               this.m_view.state_mc.watcher_influenced_mc.alpha = 1;
               this.blinkIcon(this.m_view.state_mc.watcher_influenced_mc);
               break;
            case DISORIENTED:
               this.m_view.state_mc.disoriented_mc.visible = true;
               this.m_view.state_mc.disoriented_mc.alpha = 1;
               break;
            case IS_PRE_CONFRONTING:
               this.m_view.state_mc.distracted_in_ambient_mc.visible = true;
               break;
            case IS_CONFRONTING:
               this.m_view.state_mc.distracted_in_ambient_mc.visible = true;
               break;
            case POSSIBLY_DISTRACTED:
               CommonUtils.playSound(this,"UI_HUD_AI_DistractedtoInvestigate");
               this.m_view.state_mc.distracted_possibly_mc.visible = true;
               this.m_view.state_mc.distracted_possibly_mc.alpha = 1;
               this.blinkIcon(this.m_view.state_mc.distracted_possibly_mc);
               break;
            case ALLIED_RECRUIT:
               this.m_view.state_mc.allied_recruit_mc.visible = true;
               MenuUtils.setColor(this.m_view.state_mc.allied_recruit_mc.main_mc,MenuConstantsKnt.COLOR_YELLOW,false);
               break;
            default:
               this.hideAllStateMcs();
         }
      }
      
      private function cycleIcons(param1:int, param2:int) : void
      {
         var firstIcon:int = param1;
         var secondIcon:int = param2;
         this.showIcon(firstIcon);
         Animate.to(this.m_view.state_mc,0.2,0,{"scaleX":1},Animate.ExpoOut,function():void
         {
            Animate.to(m_view.state_mc,0.2,ICON_CYCLE_DELAY,{"scaleX":0},Animate.ExpoIn,function():void
            {
               cycleIcons(secondIcon,firstIcon);
            });
         });
      }
      
      private function blinkIcon(param1:MovieClip, param2:Boolean = true, param3:Number = 0.6, param4:Boolean = true) : void
      {
         var clip:MovieClip = param1;
         var show:Boolean = param2;
         var speed:Number = param3;
         var flip:Boolean = param4;
         if(show)
         {
            Animate.to(clip,0.07,0.3,{"alpha":flip ? 0.5 : 1},Animate.Linear,function():void
            {
               blinkIcon(clip,true,speed,!flip);
            });
         }
         else
         {
            Animate.kill(clip);
         }
      }
      
      private function setProgress(param1:Number, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         if(param2)
         {
            this.m_view.progress_mc.visible = true;
            _loc3_ = MenuUtils.roundDecimal(param1 * 0.6,2) * 100;
            this.m_view.progress_mc.bar_mc.gotoAndStop(_loc3_);
         }
         else
         {
            this.m_view.progress_mc.visible = false;
         }
      }
      
      public function setTimer(param1:Number) : void
      {
      }
      
      private function pulseAnim(param1:Boolean) : void
      {
         var show:Boolean = param1;
         Animate.kill(this.m_view.pulse_mc.rings_mc);
         Animate.kill(this.m_view.pulse_mc.bg_mc);
         this.m_view.pulse_mc.rings_mc.gotoAndStop(0);
         this.m_view.pulse_mc.bg_mc.gotoAndStop(0);
         if(show)
         {
            Animate.fromTo(this.m_view.pulse_mc.rings_mc,0.6,0,{"frames":0},{"frames":60},Animate.Linear);
            Animate.fromTo(this.m_view.pulse_mc.bg_mc,0.6,0,{"frames":0},{"frames":60},Animate.Linear,function():void
            {
               pulseAnim(true);
            });
            this.m_pulseAnimRunning = true;
         }
         else
         {
            this.m_pulseAnimRunning = false;
         }
      }
      
      private function hideAllStateMcs() : void
      {
         Animate.kill(this.m_view.state_mc);
         MenuUtils.setColor(this.m_view.progress_mc.bar_mc,MenuConstantsKnt.COLOR_HUD_DANGER_MED);
         this.blinkIcon(this.m_view.state_mc.watcher_influenced_mc,false);
         this.blinkIcon(this.m_view.state_mc.distracted_possibly_mc,false);
         this.blinkIcon(this.m_view.state_mc.about_to_fire_mc.back_mc,false);
         if(this.m_pulseAnimRunning)
         {
            this.pulseAnim(false);
         }
         this.m_showEdgeMarker = false;
         this.m_view.direction_mc.visible = false;
         this.m_view.bg_mc.visible = false;
         this.m_view.state_mc.allied_recruit_mc.visible = false;
         this.m_view.state_mc.distracted_in_ambient_mc.visible = false;
         this.m_view.state_mc.calling_for_reinforcements_mc.visible = false;
         this.m_view.state_mc.bluffed_mc.visible = false;
         this.m_view.state_mc.watcher_mc.visible = false;
         this.m_view.state_mc.watcher_influenced_mc.visible = false;
         this.m_view.state_mc.disoriented_mc.visible = false;
         this.m_view.state_mc.reload_mc.visible = false;
         this.m_view.state_mc.distracted_possibly_mc.visible = false;
         this.m_view.state_mc.about_to_fire_mc.visible = false;
      }
      
      public function edgeAngle(param1:Number) : void
      {
         if(param1 < 0)
         {
            if(this.m_edgeLocked)
            {
               this.m_view.direction_mc.visible = false;
               this.m_edgeLocked = false;
            }
         }
         else
         {
            if(!this.m_edgeLocked && this.m_showEdgeMarker)
            {
               this.m_view.direction_mc.visible = true;
               this.m_edgeLocked = true;
            }
            this.m_view.direction_mc.rotation = param1;
         }
      }
      
      public function send_OnDistractedInAmbientTriggered() : void
      {
         sendEvent("OnDistractedInAmbientTriggered");
      }
      
      private function getState(param1:int) : String
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case ABOUT_TO_FIRE:
               _loc2_ = "ABOUT_TO_FIRE";
               break;
            case DISTRACTED_IN_AMBIENT:
               _loc2_ = "DISTRACTED_IN_AMBIENT";
               break;
            case CALLING_FOR_REINFORCEMENTS:
               _loc2_ = "CALLING_FOR_REINFORCEMENTS";
               break;
            case BLUFFED:
               _loc2_ = "BLUFFED";
               break;
            case IS_PRE_CONFRONTING:
               _loc2_ = "IS_PRE_CONFRONTING";
               break;
            case IS_CONFRONTING:
               _loc2_ = "IS_CONFRONTING";
               break;
            case WATCHER:
               _loc2_ = "WATCHER";
               break;
            case WATCHER_INFLUENCING:
               _loc2_ = "WATCHER_INFLUENCING";
               break;
            case INFLUENCED_BY_WATCHER:
               _loc2_ = "INFLUENCED_BY_WATCHER";
               break;
            case DISORIENTED:
               _loc2_ = "DISORIENTED";
               break;
            case RELOADING:
               _loc2_ = "RELOADING";
               break;
            case POSSIBLY_DISTRACTED:
               _loc2_ = "POSSIBLY_DISTRACTED";
               break;
            case ALLIED_RECRUIT:
               _loc2_ = "ALLIED_RECRUIT";
               break;
            default:
               _loc2_ = "DIDANT GET NO STATE...?";
         }
         return _loc2_;
      }
   }
}
