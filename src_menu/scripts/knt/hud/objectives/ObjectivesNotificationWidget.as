package knt.hud.objectives
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.Localization;
   import glacier.common.TaskletSequencer;
   import glacier.common.menu.MenuUtils;
   import knt.common.hud.KntHudUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class ObjectivesNotificationWidget extends BaseControl
   {
      private static const NOTIFICATION_SCALE:Number = 0.5;
      
      private var m_view:ObjectivesNotificationWidgetView;
      
      private var m_xpos_title:Number;
      
      private var m_xpos_headline:Number;
      
      private var m_xpos_icon:Number;
      
      private var m_soundTrigger:String = "";
      
      private var m_isAnimatingClosingSequence:Boolean = false;
      
      private var m_objState:String = "";
      
      private var m_objType:String = "";
      
      private const ICON_SCALE:Number = 1.4;
      
      private const NOTIFICATION_HEIGHT:Number = 96;
      
      private const MAX_TITLE_WIDTH:Number = 460;
      
      private const MAX_TITLE_HEIGHT:Number = 40;
      
      public function ObjectivesNotificationWidget()
      {
         super();
         this.m_view = new ObjectivesNotificationWidgetView();
         this.m_view.y = -this.NOTIFICATION_HEIGHT / 2;
         this.m_view.scaleX = this.m_view.scaleY = NOTIFICATION_SCALE;
         addChild(this.m_view);
         this.m_view.visible = false;
         KntHudUtils.addOutline(this.m_view.headline_txt,MenuConstantsKnt.COLOR_BLACK,0.32);
         KntHudUtils.addOutline(this.m_view.title_txt,MenuConstantsKnt.COLOR_BLACK,0.32);
         KntHudUtils.addOutline(this.m_view.track_txt,MenuConstantsKnt.COLOR_BLACK,0.32);
         KntHudUtils.addOutline(this.m_view.progressbar_mc.fill_mc,MenuConstantsKnt.COLOR_BLACK,0.32);
         this.m_xpos_headline = this.m_view.headline_txt.x;
         this.m_xpos_title = this.m_view.title_txt.x;
         this.m_xpos_icon = this.m_view.icon_container_mc.x;
         this.m_view.icon_container_mc.scaleX = this.m_view.icon_container_mc.scaleY = this.ICON_SCALE;
         this.m_view.flame_mc.stop();
         this.m_view.progressbar_mc.visible = false;
         this.m_view.track_txt.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         if(!param1.IsValid)
         {
            if(this.m_view.visible && !this.m_isAnimatingClosingSequence)
            {
               this.killAllAnimations();
               this.animateClosingSequence(this.m_objState,this.m_objType);
            }
            this.m_objState = "";
            this.m_objType = "";
            return;
         }
         if(param1.NotificationType == ObjectivesData.TYPE_ITEM || param1.NotificationType == ObjectivesData.TYPE_NOTIFICATION)
         {
            return;
         }
         if(param1.NotificationType == ObjectivesData.TYPE_HINT && param1.ObjectiveState != ObjectivesData.STATE_COMPLETED)
         {
            return;
         }
         if(param1.Headline == null || param1.Headline == "")
         {
            return;
         }
         this.killAllAnimations();
         while(this.m_view.icon_container_mc.numChildren > 0)
         {
            this.m_view.icon_container_mc.removeChildAt(0);
         }
         this.m_soundTrigger = "";
         switch(param1.NotificationType)
         {
            case ObjectivesData.TYPE_OBJECTIVE:
               _loc2_ = new ObjectivesIconMainObjectiveView();
               MenuUtils.setupTextAndShrinkToFitUpper(this.m_view.title_txt,param1.Headline,32,MenuConstantsKnt.FONT_TYPE_NORMAL,this.MAX_TITLE_WIDTH,this.MAX_TITLE_HEIGHT,20,MenuConstantsKnt.FontColorWhite);
               break;
            case ObjectivesData.TYPE_SUB_OBJECTIVE:
               _loc2_ = new ObjectivesIconMainSubobjectiveView();
               MenuUtils.setupTextAndShrinkToFitUpper(this.m_view.title_txt,param1.Headline,32,MenuConstantsKnt.FONT_TYPE_NORMAL,this.MAX_TITLE_WIDTH,this.MAX_TITLE_HEIGHT,20,MenuConstantsKnt.FontColorWhite);
               break;
            case ObjectivesData.TYPE_OPPERTUNITY:
            case ObjectivesData.TYPE_OPPERTUNITYSTEP:
               _loc2_ = new ObjectivesIconOpportunityView();
               MenuUtils.setupTextAndShrinkToFitUpper(this.m_view.title_txt,param1.Headline,32,MenuConstantsKnt.FONT_TYPE_NORMAL,this.MAX_TITLE_WIDTH,this.MAX_TITLE_HEIGHT,20,MenuConstantsKnt.FontColorWhite);
               break;
            case ObjectivesData.TYPE_HINT:
               _loc2_ = new ObjectivesIconMainHintView();
               MenuUtils.setupTextAndShrinkToFitUpper(this.m_view.title_txt,param1.Headline,32,MenuConstantsKnt.FONT_TYPE_NORMAL,this.MAX_TITLE_WIDTH,this.MAX_TITLE_HEIGHT,20,MenuConstantsKnt.FontColorWhite);
         }
         switch(param1.ObjectiveState)
         {
            case ObjectivesData.STATE_ACTIVE:
               if(param1.IsObjectiveTracked)
               {
                  _loc2_.gotoAndStop("tracked");
               }
               else
               {
                  _loc2_.gotoAndStop("untracked");
               }
               MenuUtils.setColor(_loc2_,MenuConstantsKnt.COLOR_OBJECTIVE,false);
               if(param1.NotificationType == ObjectivesData.TYPE_OBJECTIVE)
               {
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_NEWOBJ"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorTeal);
                  this.m_soundTrigger = "UI_HUD_Obj_Main_Reveal";
               }
               else if(param1.NotificationType == ObjectivesData.TYPE_SUB_OBJECTIVE)
               {
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_NEWSUBOBJ"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorTeal);
                  this.m_soundTrigger = "UI_HUD_Obj_Sub_Reveal";
               }
               else if(param1.NotificationType == ObjectivesData.TYPE_OPPERTUNITY || param1.NotificationType == ObjectivesData.TYPE_OPPERTUNITYSTEP)
               {
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_OPPORTUNITY"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorTeal);
                  this.m_soundTrigger = "UI_HUD_Obj_Opp_Reveal";
               }
               break;
            case ObjectivesData.STATE_COMPLETED:
               _loc2_.gotoAndStop("completed");
               if(param1.NotificationType == ObjectivesData.TYPE_OBJECTIVE)
               {
                  MenuUtils.setColor(_loc2_,MenuConstantsKnt.COLOR_OBJECTIVE_COMPLETED,false);
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_COMPOBJ"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorTeal);
                  this.m_soundTrigger = "UI_HUD_Obj_Main_Complete";
               }
               else if(param1.NotificationType == ObjectivesData.TYPE_SUB_OBJECTIVE)
               {
                  MenuUtils.setColor(_loc2_,MenuConstantsKnt.COLOR_OBJECTIVE_COMPLETED,false);
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_COMPSUBOBJ"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorTeal);
                  this.m_soundTrigger = "UI_HUD_Obj_Sub_Complete";
               }
               else if(param1.NotificationType == ObjectivesData.TYPE_OPPERTUNITY || param1.NotificationType == ObjectivesData.TYPE_OPPERTUNITYSTEP)
               {
                  MenuUtils.setColor(_loc2_,MenuConstantsKnt.COLOR_OBJECTIVE_COMPLETED,false);
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_COMPOPPORT"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorTeal);
                  this.m_soundTrigger = "UI_HUD_Obj_Opp_Complete";
               }
               else if(param1.NotificationType == ObjectivesData.TYPE_HINT)
               {
                  MenuUtils.setColor(_loc2_,MenuConstantsKnt.COLOR_PRIMARY,false);
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_HINT"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorBrandPrimary);
                  this.m_soundTrigger = "UI_HUD_IntelItem_Hint_Shown";
               }
               break;
            case ObjectivesData.STATE_FAILED:
               MenuUtils.setColor(_loc2_,MenuConstantsKnt.COLOR_OBJECTIVE_FAILED,false);
               _loc2_.gotoAndStop("failed");
               if(param1.NotificationType == ObjectivesData.TYPE_OBJECTIVE)
               {
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_COMPOBJ"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorGrey);
                  this.m_soundTrigger = "UI_HUD_Obj_Main_Failed";
               }
               else if(param1.NotificationType == ObjectivesData.TYPE_SUB_OBJECTIVE)
               {
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_COMPSUBOBJ"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorGrey);
                  this.m_soundTrigger = "UI_HUD_Obj_Sub_Failed";
               }
               else if(param1.NotificationType == ObjectivesData.TYPE_OPPERTUNITY || param1.NotificationType == ObjectivesData.TYPE_OPPERTUNITYSTEP)
               {
                  MenuUtils.setupTextUpper(this.m_view.headline_txt,Localization.get("UI_HUD_NOTIFICATION_COMPOPPORT"),16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorGrey);
                  this.m_soundTrigger = "UI_HUD_Obj_Opp_Failed";
               }
         }
         MenuUtils.setColor(this.m_view.flame_mc,param1.NotificationType == ObjectivesData.TYPE_HINT ? uint(MenuConstantsKnt.COLOR_PRIMARY) : uint(MenuConstantsKnt.COLOR_TEAL));
         MenuUtils.setColor(this.m_view.orb_mc,param1.NotificationType == ObjectivesData.TYPE_HINT ? uint(MenuConstantsKnt.COLOR_PRIMARY) : uint(MenuConstantsKnt.COLOR_TEAL));
         this.m_view.icon_container_mc.addChild(_loc2_);
         this.onControlLayoutChanged();
         this.m_objState = param1.ObjectiveState;
         this.m_objType = param1.NotificationType;
         this.animateOpeningSequence(param1.Duration,this.m_objState,this.m_objType,param1.IsObjectiveTracked);
      }
      
      private function animateOpeningSequence(param1:Number, param2:String, param3:String, param4:Boolean) : void
      {
         var maxTextWidth:Number;
         var duration:Number = param1;
         var objState:String = param2;
         var objType:String = param3;
         var isTracked:Boolean = param4;
         this.m_view.visible = true;
         this.m_view.title_txt.x = this.m_xpos_title - 16;
         this.m_view.title_txt.alpha = 0;
         Animate.to(this.m_view.title_txt,0.23,0.14,{
            "x":this.m_xpos_title,
            "alpha":1
         },Animate.QuadOut,function():void
         {
            CommonUtils.playSound(this,m_soundTrigger);
            m_soundTrigger = "";
            m_view.title_txt.alpha = 0;
            Animate.delay(m_view.title_txt,0.13,function():void
            {
               m_view.title_txt.alpha = 1;
               Animate.delay(m_view.title_txt,0.03,function():void
               {
                  m_view.title_txt.alpha = 0;
                  Animate.delay(m_view.title_txt,0.08,function():void
                  {
                     m_view.title_txt.alpha = 0.75;
                     Animate.to(m_view.title_txt,0.01,0.01,{"alpha":1},Animate.Linear);
                  });
               });
            });
         });
         this.m_view.headline_txt.x = this.m_xpos_headline - 16;
         this.m_view.headline_txt.alpha = 0;
         Animate.to(this.m_view.headline_txt,0.23,0.08,{
            "x":this.m_xpos_headline,
            "alpha":1
         },Animate.QuadOut,function():void
         {
            m_view.headline_txt.alpha = 0;
            Animate.delay(m_view.headline_txt,0.13,function():void
            {
               m_view.headline_txt.alpha = 1;
               Animate.delay(m_view.headline_txt,0.03,function():void
               {
                  m_view.headline_txt.alpha = 0;
                  Animate.delay(m_view.headline_txt,0.08,function():void
                  {
                     m_view.headline_txt.alpha = 0.75;
                     Animate.to(m_view.headline_txt,0.01,0.01,{"alpha":1},Animate.Linear);
                  });
               });
            });
         });
         this.m_view.icon_container_mc.alpha = 0;
         this.m_view.icon_container_mc.scaleX = this.m_view.icon_container_mc.scaleY = 2;
         Animate.to(this.m_view.icon_container_mc,0.25,0,{
            "scaleX":1.4,
            "scaleY":1.4,
            "alpha":1
         },Animate.QuadOut,function():void
         {
            m_view.icon_container_mc.alpha = 0;
            Animate.delay(m_view.icon_container_mc,0.13,function():void
            {
               m_view.icon_container_mc.alpha = 1;
               Animate.delay(m_view.icon_container_mc,0.13,function():void
               {
                  m_view.icon_container_mc.alpha = 0;
                  Animate.delay(m_view.icon_container_mc,0.13,function():void
                  {
                     m_view.icon_container_mc.scaleX = m_view.icon_container_mc.scaleY = 1;
                     m_view.icon_container_mc.alpha = 0.8;
                     Animate.to(m_view.icon_container_mc,0.08,0.13,{
                        "scaleX":1.4,
                        "scaleY":1.4,
                        "alpha":1
                     },Animate.QuadOut);
                  });
               });
            });
         });
         maxTextWidth = Math.max(this.m_view.title_txt.textWidth,this.m_view.headline_txt.textWidth);
         this.m_view.lines_mc.width = maxTextWidth + 100;
         this.m_view.lines_mc.alpha = 0;
         this.m_view.darkBack_mc.width = 40;
         this.m_view.darkBack_mc.alpha = 0;
         Animate.to(this.m_view.darkBack_mc,0.65,0,{
            "width":maxTextWidth + 250,
            "alpha":1
         },Animate.QuadOut);
         Animate.to(this.m_view.lines_mc,0.65,0,{"alpha":0.16},Animate.QuadOut);
         this.m_view.flame_mc.scaleX = 0.75;
         this.m_view.flame_mc.scaleY = 1.3;
         this.m_view.flame_mc.alpha = 0;
         this.m_view.flame_mc.gotoAndPlay(Math.abs(Math.random() * this.m_view.flame_mc.totalFrames));
         Animate.to(this.m_view.flame_mc,0.5,0,{
            "scaleX":1,
            "scaleY":1,
            "alpha":1
         },Animate.QuadInOut);
         this.m_view.orb_mc.alpha = 0;
         this.m_view.orb_mc.scaleX = this.m_view.orb_mc.scaleY = 0.5;
         Animate.to(this.m_view.orb_mc,0.25,0,{
            "scaleX":0.75,
            "scaleY":0.75,
            "alpha":0.1
         },Animate.QuadOut,function():void
         {
            Animate.to(m_view.orb_mc,0.25,0,{
               "scaleX":0.6,
               "scaleY":0.6,
               "alpha":0.3
            },Animate.QuadIn);
         });
         if((objType == ObjectivesData.TYPE_OPPERTUNITY || objType == ObjectivesData.TYPE_OPPERTUNITYSTEP) && objState == ObjectivesData.STATE_ACTIVE && !isTracked)
         {
            this.m_view.progressbar_mc.visible = true;
            this.m_view.track_txt.visible = true;
            this.m_view.track_txt.alpha = 0;
            this.m_view.progressbar_mc.width = this.m_view.title_txt.x - this.m_view.progressbar_mc.x + this.m_view.title_txt.textWidth;
            this.m_view.progressbar_mc.fill_mc.scaleX = 1;
            this.m_view.progressbar_mc.alpha = 0;
            Animate.to(this.m_view.track_txt,0.3,0.4,{"alpha":1},Animate.QuadOut);
            Animate.to(this.m_view.progressbar_mc,0.3,0.4,{"alpha":1},Animate.QuadOut,function():void
            {
               Animate.to(m_view.progressbar_mc.fill_mc,duration - 0.9,0,{"scaleX":0},Animate.Linear);
            });
         }
         else
         {
            this.m_view.progressbar_mc.visible = false;
            this.m_view.track_txt.visible = false;
         }
         Animate.delay(this.m_view,duration - 1.4,this.animateClosingSequence,objState,objType);
      }
      
      private function animateClosingSequence(param1:String, param2:String) : void
      {
         var objState:String = param1;
         var objType:String = param2;
         TaskletSequencer.getGlobalInstance().addChunk(function():void
         {
            m_isAnimatingClosingSequence = true;
            Animate.to(m_view.flame_mc,0.5,0,{"alpha":0},Animate.QuadIn);
            Animate.to(m_view.title_txt,0.6,0.2,{
               "x":m_xpos_title - 16,
               "alpha":0
            },Animate.QuadIn);
            Animate.to(m_view.headline_txt,0.6,0,{
               "x":m_xpos_headline - 16,
               "alpha":0
            },Animate.QuadIn);
            Animate.to(m_view.icon_container_mc,0.5,0,{
               "scaleX":0.5,
               "scaleY":0.5,
               "alpha":0
            },Animate.QuadIn);
            Animate.to(m_view.darkBack_mc,0.66,0,{
               "width":60,
               "alpha":0
            },Animate.QuadIn);
            Animate.to(m_view.lines_mc,0.66,0,{"alpha":0},Animate.QuadIn);
            Animate.to(m_view.progressbar_mc,0.4,0,{"alpha":0},Animate.QuadIn);
            Animate.to(m_view.track_txt,0.4,0.1,{"alpha":0},Animate.QuadIn);
            Animate.to(m_view.orb_mc,0.5,0,{"alpha":0},Animate.QuadIn);
            Animate.delay(m_view,1,function():void
            {
               m_view.visible = false;
               m_isAnimatingClosingSequence = false;
               killAllAnimations();
            });
         });
      }
      
      private function killAllAnimations() : void
      {
         Animate.kill(this.m_view);
         Animate.kill(this.m_view.flame_mc);
         Animate.kill(this.m_view.orb_mc);
         Animate.kill(this.m_view.title_txt);
         Animate.kill(this.m_view.headline_txt);
         Animate.kill(this.m_view.icon_container_mc);
         Animate.kill(this.m_view.darkBack_mc);
         Animate.kill(this.m_view.lines_mc);
         Animate.kill(this.m_view.track_txt);
         Animate.kill(this.m_view.progressbar_mc);
         Animate.kill(this.m_view.progressbar_mc.fill_mc);
         this.m_view.flame_mc.stop();
      }
      
      override public function onControlLayoutChanged() : void
      {
         MenuUtils.setupTextUpper(this.m_view.track_txt,Localization.get("UI_Open_Journal_Track_Prompt"),21,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
      }
      
      public function testMainObjective() : void
      {
         var _loc1_:Object = {
            "IsValid":true,
            "ObjectiveID":"",
            "Headline":"Testing Main Objective Notification",
            "Image":"",
            "Completed":false,
            "NotificationType":"MainObjective",
            "ObjectiveState":"Active",
            "Duration":5,
            "IsObjectiveTracked":true
         };
         this.onSetData(_loc1_);
      }
      
      public function testSubObjective() : void
      {
         var _loc1_:Object = {
            "IsValid":true,
            "ObjectiveID":"",
            "Headline":"Testing Sub Objective",
            "Image":"",
            "Completed":false,
            "NotificationType":"SubObjective",
            "ObjectiveState":"Active",
            "Duration":5,
            "IsObjectiveTracked":true
         };
         this.onSetData(_loc1_);
      }
      
      public function testShortSubObjective() : void
      {
         var _loc1_:Object = {
            "IsValid":true,
            "ObjectiveID":"",
            "Headline":"Ass",
            "Image":"",
            "Completed":false,
            "NotificationType":"SubObjective",
            "ObjectiveState":"Active",
            "Duration":5,
            "IsObjectiveTracked":true
         };
         this.onSetData(_loc1_);
      }
      
      public function testOpportunityUntracked() : void
      {
         var _loc1_:Object = {
            "IsValid":true,
            "ObjectiveID":"",
            "Headline":"Testing New Opportunity",
            "Image":"",
            "Completed":false,
            "NotificationType":"Opportunity",
            "ObjectiveState":"Active",
            "Duration":5,
            "IsObjectiveTracked":false
         };
         this.onSetData(_loc1_);
      }
      
      public function testOpportunitytracked() : void
      {
         var _loc1_:Object = {
            "IsValid":true,
            "ObjectiveID":"",
            "Headline":"Testing Opportunity Step",
            "Image":"",
            "Completed":false,
            "NotificationType":"OpportunityStep",
            "ObjectiveState":"Active",
            "Duration":5,
            "IsObjectiveTracked":true
         };
         this.onSetData(_loc1_);
      }
   }
}
