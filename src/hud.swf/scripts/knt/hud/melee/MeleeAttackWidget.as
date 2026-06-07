package knt.hud.melee
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
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
         this.killAllExceptSuccess();
         this.killParrySuccess();
         this.hideWidget();
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

