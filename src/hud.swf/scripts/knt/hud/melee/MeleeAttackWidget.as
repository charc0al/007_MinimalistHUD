package knt.hud.melee
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class MeleeAttackWidget extends BaseControl
   {
      
      private const ATTACK_INTERRUPTED:int = 0;
      
      private const ATTACK_NORMAL:int = 1;
      
      private const ATTACK_PERFECT:int = 2;
      
      private const ATTACK_SIDESTEP:int = 3;
      
      private const ATTACK_SIDESTEPGRAB:int = 4;
      
      private const COUNTER_PARRY:int = 5;
      
      private const COUNTER_SIDESTEP:int = 6;
      
      private var m_view:MeleeAttackWidgetView;
      
      private var m_isUnblockable:Boolean = false;
      
      private var m_isParry:Boolean = false;
      
      private var m_isPerfectParry:Boolean = false;
      
      public function MeleeAttackWidget()
      {
         super();
         this.m_view = new MeleeAttackWidgetView();
         addChild(this.m_view);
         this.m_view.parry_mc.scaleX = this.m_view.parry_mc.scaleY = 0.6;
         this.m_view.unblockable_mc.scaleX = this.m_view.unblockable_mc.scaleY = 0.4;
         this.m_view.parry_success_mc.scaleX = this.m_view.parry_success_mc.scaleY = 0.6;
         this.hideWidget();
      }
      
      public function onSetData(param1:Object) : void
      {
         var parryDelay:Number;
         var perfectParryDelay:Number;
         var data:Object = param1;
         if(!MenuConstantsKnt.SHOW_MELEE_ATTACK_WIDGET)
         {
            this.killAllExceptSuccess();
            this.killParrySuccess();
            this.hideWidget();
            return;
         }
         this.showWidget();
         if(data.type == undefined)
         {
            return;
         }
         if(data.type == this.ATTACK_INTERRUPTED)
         {
            this.killAllExceptSuccess();
         }
         if(data.type == this.COUNTER_SIDESTEP)
         {
            this.killAllExceptSuccess();
         }
         if(data.type == this.COUNTER_PARRY)
         {
            this.killAllExceptSuccess();
            Animate.fromTo(this.m_view.parry_success_mc,0.4,0,{"frames":0},{"frames":7},Animate.ExpoOut,function():void
            {
               m_view.parry_success_mc.gotoAndStop(0);
            });
         }
         parryDelay = 0;
         perfectParryDelay = 0;
         if(data.type == this.ATTACK_NORMAL && !this.m_isParry)
         {
            parryDelay = data.attackToImpactDuration - data.parryWindowDuration;
            Animate.fromTo(this.m_view.parry_mc,data.parryWindowDuration,parryDelay,{"frames":0},{"frames":60},Animate.Linear,function():void
            {
               m_view.parry_mc.gotoAndStop(0);
               m_isParry = false;
            });
            this.m_isParry = true;
         }
         if(data.type == this.ATTACK_PERFECT && !this.m_isPerfectParry)
         {
            parryDelay = data.attackToImpactDuration - data.parryWindowDuration;
            perfectParryDelay = data.attackToImpactDuration - data.perfectParryWindowDuration;
            Animate.fromTo(this.m_view.parry_mc,data.parryWindowDuration,parryDelay,{"frames":0},{"frames":60},Animate.Linear);
            Animate.fromTo(this.m_view.perfect_parry_mc,data.perfectParryWindowDuration,perfectParryDelay,{"frames":0},{"frames":60},Animate.Linear,function():void
            {
               m_view.parry_mc.gotoAndStop(0);
               m_view.perfect_parry_mc.gotoAndStop(0);
               m_isPerfectParry = false;
            });
            this.m_isPerfectParry = true;
         }
         if(data.type == this.ATTACK_SIDESTEP && !this.m_isUnblockable || data.type == this.ATTACK_SIDESTEPGRAB && !this.m_isUnblockable)
         {
            Animate.fromTo(this.m_view.unblockable_mc,data.attackToImpactDuration,0,{"frames":0},{"frames":60},Animate.Linear,function():void
            {
               m_view.unblockable_mc.gotoAndStop(0);
               m_isUnblockable = false;
            });
            this.m_isUnblockable = true;
         }
      }
      
      private function killAllExceptSuccess() : void
      {
         Animate.kill(this.m_view.parry_mc);
         Animate.kill(this.m_view.perfect_parry_mc);
         Animate.kill(this.m_view.unblockable_mc);
         this.m_view.parry_mc.gotoAndStop(0);
         this.m_view.perfect_parry_mc.gotoAndStop(0);
         this.m_view.unblockable_mc.gotoAndStop(0);
         this.m_isParry = false;
         this.m_isPerfectParry = false;
         this.m_isUnblockable = false;
      }
      
      private function killParrySuccess() : void
      {
         Animate.kill(this.m_view.parry_success_mc);
         this.m_view.parry_success_mc.gotoAndStop(0);
      }

      private function hideWidget() : void
      {
         this.visible = false;
         this.alpha = 0;
         this.m_view.visible = false;
         this.m_view.alpha = 0;
      }

      private function showWidget() : void
      {
         this.visible = true;
         this.alpha = 1;
         this.m_view.visible = true;
         this.m_view.alpha = 1;
      }
      
      private function getType(param1:int) : String
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case 0:
               _loc2_ = "ATTACK_INTERRUPTED";
               break;
            case 1:
               _loc2_ = "ATTACK_NORMAL";
               break;
            case 2:
               _loc2_ = "ATTACK_PERFECT";
               break;
            case 3:
               _loc2_ = "ATTACK_SIDESTEP";
               break;
            case 4:
               _loc2_ = "ATTACK_SIDESTEPGRAB";
               break;
            case 5:
               _loc2_ = "COUNTER_PARRY";
               break;
            case 6:
               _loc2_ = "COUNTER_SIDESTEP";
               break;
            default:
               _loc2_ = "NO TYPE SET OR IT DEFAULTS to DEFAULT";
         }
         return _loc2_;
      }
   }
}

