package knt.hud.notifications
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.Localization;
   import glacier.common.ObjectUtils;
   import glacier.common.TaskletSequencer;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class DangerNotificationWidget extends BaseControl
   {
      
      public static const SOFT_TRESPASSING:Number = 0;
      
      public static const TRESPASSING:Number = 1;
      
      public static const LETHAL:Number = 2;
      
      public static const SITUATION_CONTAINED:Number = 3;
      
      public static const REINFORCEMENTS_INCOMING:Number = 4;
      
      private var m_testlethalForceEnabled:Boolean = false;
      
      private var m_testtrespassing:Boolean = false;
      
      private var m_testsoftTrespassing:Boolean = false;
      
      private var m_testsituationContained:Boolean = false;
      
      private var m_testreinforcementsIncoming:Boolean = false;
      
      private var m_lethalForceEnabled:Boolean = false;
      
      private var m_trespassing:Boolean = false;
      
      private var m_softTrespassing:Boolean = false;
      
      private var m_situationContained:Boolean = false;
      
      private var m_reinforcementsIncoming:Boolean = false;
      
      private var m_wasTrespassing:Boolean = false;
      
      private var m_view:DangerNotificationWidgetView;
      
      private var m_ignoreDangerStates:Boolean = false;
      
      private var m_dataCloned:Object;
      
      private var m_softTrespassingEntry:DangerNotificationWidgetEntry;
      
      private var m_trespassingEntry:DangerNotificationWidgetEntry;
      
      private var m_lethalForceEntry:DangerNotificationWidgetEntry;
      
      private var m_situationContainedEntry:DangerNotificationWidgetEntry;
      
      private var m_reinforcementsIncomingEntry:DangerNotificationWidgetEntry;
      
      private var m_particles:DangerNotificationWidgetParticles;
      
      private var m_notificationIsShown:Boolean = false;
      
      private var m_situationContainedIsShown:Boolean = false;
      
      private var m_reinforcementsIncomingIsShown:Boolean = false;
      
      private var m_hidden:Boolean = false;
      
      private var m_disguised:Boolean = false;
      
      private var m_hiddenShown:Boolean = false;
      
      public function DangerNotificationWidget()
      {
         super();
         this.m_view = new DangerNotificationWidgetView();
         addChild(this.m_view);
         this.m_view.hidden_mc.visible = false;
         this.m_view.hidden_mc.alpha = 0;
         this.m_view.hidden_mc.y = 60;
         this.m_view.hidden_mc.inner_mc.y = 0;
         this.instantiateEntries();
         this.disableNotificationOverlay();
      }
      
      public function onSetData(param1:Object) : void
      {
         this.m_dataCloned = param1 == null ? null : ObjectUtils.cloneDeep(param1);
         this.disableNotificationOverlay();
      }
      
      public function callBackFromOverrideCheckPreviousState() : void
      {
         this.disableNotificationOverlay();
      }
      
      private function resetAllRoEShown() : void
      {
         this.m_softTrespassingEntry.callToExitAndHide();
         this.m_trespassingEntry.callToExitAndHide();
         this.m_lethalForceEntry.callToExitAndHide();
         this.m_particles.stopParticlesBaby();
      }
      
      private function resetAllOverridesShown() : void
      {
         this.m_situationContainedEntry.callToExitAndHide();
         this.m_reinforcementsIncomingEntry.callToExitAndHide();
         this.m_particles.stopParticlesBaby();
      }
      
      private function showHidden() : void
      {
         Animate.kill(this.m_view.hidden_mc);
         this.m_view.hidden_mc.visible = true;
         Animate.to(this.m_view.hidden_mc,0.4,0,{
            "alpha":1,
            "y":80
         },Animate.ExpoOut);
      }
      
      private function hideHidden() : void
      {
         Animate.kill(this.m_view.hidden_mc);
         Animate.to(this.m_view.hidden_mc,0.4,0,{
            "alpha":0,
            "y":60
         },Animate.ExpoOut,function():void
         {
            m_view.hidden_mc.visible = false;
            Animate.kill(m_view.hidden_mc.inner_mc);
            m_view.hidden_mc.inner_mc.y = 0;
         });
      }
      
      private function offsetHiddenMc(param1:Boolean) : void
      {
         var delay:Number = NaN;
         var useDelay:Boolean = param1;
         delay = useDelay ? 0.4 : 0;
         Animate.kill(this.m_view.hidden_mc.inner_mc);
         Animate.to(this.m_view.hidden_mc.inner_mc,0.4,delay,{"y":60},Animate.ExpoOut,function():void
         {
            Animate.to(m_view.hidden_mc.inner_mc,0.5,delay + 3.8,{"y":0},Animate.BackIn);
         });
      }
      
      public function set ignoreDangerStates(param1:Boolean) : void
      {
         this.m_ignoreDangerStates = true;
         this.disableNotificationOverlay();
      }
      
      private function instantiateEntries() : void
      {
         this.m_softTrespassingEntry = new DangerNotificationWidgetEntry();
         this.m_softTrespassingEntry.onSetData({
            "title":Localization.get("UI_HUD_DANGER_SOFT_TRESPASSING_TITLE",true),
            "dangerColor":MenuConstantsKnt.COLOR_HUD_DANGER_ALT,
            "type":SOFT_TRESPASSING
         });
         this.m_softTrespassingEntry.setParentClass(this);
         this.m_view.container_mc.addChild(this.m_softTrespassingEntry);
         this.m_trespassingEntry = new DangerNotificationWidgetEntry();
         this.m_trespassingEntry.onSetData({
            "title":Localization.get("UI_HUD_DANGER_TRESPASSING_TITLE",true),
            "dangerColor":MenuConstantsKnt.COLOR_HUD_DANGER_MED,
            "type":TRESPASSING
         });
         this.m_trespassingEntry.setParentClass(this);
         this.m_view.container_mc.addChild(this.m_trespassingEntry);
         this.m_lethalForceEntry = new DangerNotificationWidgetEntry();
         this.m_lethalForceEntry.onSetData({
            "title":Localization.get("UI_HUD_DANGER_LICENCE_TO_KILL_TITLE",true),
            "dangerColor":MenuConstantsKnt.COLOR_HUD_DANGER_HIGH,
            "type":LETHAL
         });
         this.m_lethalForceEntry.setParentClass(this);
         this.m_view.container_mc.addChild(this.m_lethalForceEntry);
         this.m_situationContainedEntry = new DangerNotificationWidgetEntry();
         this.m_situationContainedEntry.onSetData({
            "title":Localization.get("UI_HUD_DANGER_SITUATION_CONTAINED_TITLE",true),
            "dangerColor":MenuConstantsKnt.COLOR_HUD_DANGER_NONE,
            "type":SITUATION_CONTAINED
         });
         this.m_situationContainedEntry.setParentClass(this);
         this.m_view.container_mc.addChild(this.m_situationContainedEntry);
         this.m_reinforcementsIncomingEntry = new DangerNotificationWidgetEntry();
         this.m_reinforcementsIncomingEntry.onSetData({
            "title":Localization.get("UI_HUD_DANGER_REINFORCEMENTS_TITLE",true),
            "dangerColor":MenuConstantsKnt.COLOR_HUD_DANGER_HIGH,
            "type":REINFORCEMENTS_INCOMING
         });
         this.m_reinforcementsIncomingEntry.setParentClass(this);
         this.m_view.container_mc.addChild(this.m_reinforcementsIncomingEntry);
         this.m_particles = new DangerNotificationWidgetParticles();
         this.m_view.particles_container_mc.addChild(this.m_particles);
      }
      
      public function stopAndReset() : void
      {
         this.disableNotificationOverlay();
      }
      
      private function disableNotificationOverlay() : void
      {
         this.m_ignoreDangerStates = true;
         this.m_testtrespassing = false;
         this.m_testlethalForceEnabled = false;
         this.m_testsoftTrespassing = false;
         this.m_testsituationContained = false;
         this.m_testreinforcementsIncoming = false;
         this.m_softTrespassing = false;
         this.m_trespassing = false;
         this.m_lethalForceEnabled = false;
         this.m_situationContained = false;
         this.m_reinforcementsIncoming = false;
         this.m_wasTrespassing = false;
         this.m_notificationIsShown = false;
         this.m_situationContainedIsShown = false;
         this.m_reinforcementsIncomingIsShown = false;
         this.m_hidden = false;
         this.m_disguised = false;
         this.m_hiddenShown = false;
         this.resetAllRoEShown();
         this.resetAllOverridesShown();
         Animate.kill(this.m_view.hidden_mc);
         Animate.kill(this.m_view.hidden_mc.inner_mc);
         this.m_view.hidden_mc.visible = false;
         this.m_view.hidden_mc.alpha = 0;
         this.m_view.hidden_mc.y = 60;
         this.m_view.hidden_mc.inner_mc.y = 0;
         this.m_view.container_mc.visible = false;
         this.m_view.container_mc.alpha = 0;
         this.m_view.particles_container_mc.visible = false;
         this.m_view.particles_container_mc.alpha = 0;
      }
   }
}
