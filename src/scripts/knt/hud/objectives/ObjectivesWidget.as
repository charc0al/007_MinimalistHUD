package knt.hud.objectives
{
   import flash.display.Sprite;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.hud.*;
   
   public class ObjectivesWidget extends BaseControl
   {
      
      public static const LIST_DISPLAY_TIME:Number = 6;
      
      public static const LIST_TRANSITION_TIME:Number = 0.7;
      
      private static const SUBOBJ_INDENT:int = 36;
      
      private static const OPPORTUNITY_OBJECTIVE_INDENT:int = 36;
      
      private static const OPPORTUNITY_SUBOBJECTIVE_INDENT:int = 72;
      
      private static const OBJECTIVES_SCALE:Number = 0.85;
      
      private var m_view:ObjectivesWidgetView;
      
      private var m_delaySprite:Sprite = new Sprite();
      
      private var m_objectivesYOffset:Number = 0;
      
      private var m_widestEntryWidth:Number = 0;
      
      private var m_widestOpportunityProgress:Number = 0;
      
      private var m_entries:Vector.<Object>;
      
      private var m_isAimingWatch:Boolean = false;
      
      private var m_lastUpdateWasInWatchMode:Boolean = false;
      
      private var m_openJournalPrompt:String;
      
      private var m_collapseNonTracked:Boolean = false;
      
      private var m_undiscovered_opportunities:int = 0;
      
      private var m_newOpportunityFound:Boolean = false;
      
      public function ObjectivesWidget()
      {
         super();
         this.m_view = new ObjectivesWidgetView();
         addChild(this.m_view);
         this.m_view.scaleX = this.m_view.scaleY = OBJECTIVES_SCALE;
         this.m_view.visible = false;
         this.m_view.alpha = 0;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc3_:ObjectivesWidgetGameChangerEntry = null;
         var _loc4_:int = 0;
         var _loc5_:ObjectivesWidgetObjectiveEntry = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:ObjectivesWidgetSubObjectiveEntry = null;
         if(param1 == null)
         {
            this.hideWidget();
            return;
         }
         this.m_isAimingWatch = Boolean(param1.IsInQLens);
         ObjectivesMarkerWidget.setGlobalWatchState(this.m_isAimingWatch);
         this.updateVisibility();
         while(this.m_view.container_mc.numChildren > 0)
         {
            this.m_view.container_mc.removeChildAt(0);
         }
         Animate.kill(this.m_delaySprite);
         this.m_entries = new Vector.<Object>();
         this.m_widestEntryWidth = 0;
         this.m_widestOpportunityProgress = 0;
         this.m_undiscovered_opportunities = 0;
         this.m_newOpportunityFound = false;
         var _loc2_:Boolean = false;
         this.m_objectivesYOffset = 0;
         if(param1.GameChangers)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.GameChangers.length)
            {
               _loc3_ = new ObjectivesWidgetGameChangerEntry();
               this.m_view.container_mc.addChild(_loc3_);
               _loc3_.instantiateEntry(param1.GameChangers[_loc4_],false,param1.IsInQLens,this.m_entries.length,_loc4_ == 0,_loc4_ == param1.GameChangers.length - 1);
               _loc3_.setParentClass(this);
               this.m_entries.push({
                  "type":"GameChanger",
                  "id":"",
                  "entry":_loc3_,
                  "collapse":false,
                  "height":_loc3_.getHeight(),
                  "entryOffset":0
               });
               if(_loc3_.getWidth() > this.m_widestEntryWidth)
               {
                  this.m_widestEntryWidth = _loc3_.getWidth();
               }
               _loc4_++;
            }
         }
         if(param1.Objectives)
         {
            _loc8_ = 0;
            while(_loc8_ < param1.Objectives.length)
            {
               _loc6_ = !this.m_isAimingWatch && !this.m_lastUpdateWasInWatchMode && (Boolean(param1.Objectives[_loc8_].DidStateChange) || Boolean(param1.Objectives[_loc8_].IsNew));
               _loc7_ = (param1.Objectives[_loc8_].IsTracked || !this.m_collapseNonTracked) && param1.Objectives[_loc8_].State != ObjectivesData.STATE_COMPLETED && param1.Objectives[_loc8_].State != ObjectivesData.STATE_FAILED;
               if(param1.Objectives[_loc8_].Type != ObjectivesData.TYPE_ITEM && (param1.Objectives[_loc8_].State == ObjectivesData.STATE_ACTIVE || param1.Objectives[_loc8_].State == ObjectivesData.STATE_FAILED && _loc6_ || param1.Objectives[_loc8_].State == ObjectivesData.STATE_COMPLETED && _loc6_))
               {
                  if(_loc7_ || _loc6_)
                  {
                     _loc5_ = new ObjectivesWidgetObjectiveEntry();
                     this.m_view.container_mc.addChild(_loc5_);
                     _loc5_.instantiateEntry(param1.Objectives[_loc8_].State,param1.Objectives[_loc8_].Title,_loc6_,this.m_isAimingWatch,param1.Objectives[_loc8_].IsTracked,this.m_entries.length,{
                        "type":param1.Objectives[_loc8_].DynamicDataType,
                        "current":param1.Objectives[_loc8_].CurrentCount,
                        "target":param1.Objectives[_loc8_].TargetCount,
                        "stateText":param1.Objectives[_loc8_].StateText
                     });
                     _loc5_.setParentClass(this);
                     this.m_entries.push({
                        "type":ObjectivesData.TYPE_OBJECTIVE,
                        "id":param1.Objectives[_loc8_].ObjectiveID,
                        "entry":_loc5_,
                        "collapse":!_loc7_,
                        "height":_loc5_.getHeight(),
                        "entryOffset":0
                     });
                     if(_loc5_.getWidth() > this.m_widestEntryWidth)
                     {
                        this.m_widestEntryWidth = _loc5_.getWidth();
                     }
                  }
                  if(param1.Objectives[_loc8_].Opportunities.length > 0)
                  {
                     this.addOpportunities(param1.Objectives[_loc8_].Opportunities,false);
                  }
                  if(param1.Objectives[_loc8_].UnrevealedOpportunities.length > 0)
                  {
                     this.m_undiscovered_opportunities += param1.Objectives[_loc8_].UnrevealedOpportunities.length;
                     if(param1.Objectives[_loc8_].IsNew)
                     {
                        _loc2_ = true;
                     }
                  }
                  _loc11_ = 0;
                  while(_loc11_ < param1.Objectives[_loc8_].SubObjectives.length)
                  {
                     _loc9_ = !this.m_isAimingWatch && !this.m_lastUpdateWasInWatchMode && (Boolean(param1.Objectives[_loc8_].SubObjectives[_loc11_].IsNew) || Boolean(param1.Objectives[_loc8_].SubObjectives[_loc11_].DidStateChange));
                     _loc10_ = param1.Objectives[_loc8_].SubObjectives[_loc11_].IsTracked && !this.m_collapseNonTracked && param1.Objectives[_loc8_].SubObjectives[_loc11_].State != ObjectivesData.STATE_COMPLETED && param1.Objectives[_loc8_].SubObjectives[_loc11_].State != ObjectivesData.STATE_FAILED;
                     if(_loc10_ || _loc9_)
                     {
                        _loc12_ = new ObjectivesWidgetSubObjectiveEntry();
                        this.m_view.container_mc.addChild(_loc12_);
                        _loc12_.x = SUBOBJ_INDENT;
                        _loc12_.instantiateEntry(param1.Objectives[_loc8_].SubObjectives[_loc11_].State,param1.Objectives[_loc8_].SubObjectives[_loc11_].Title,_loc9_,this.m_isAimingWatch,param1.Objectives[_loc8_].SubObjectives[_loc11_].IsTracked,this.m_entries.length,{
                           "type":param1.Objectives[_loc8_].SubObjectives[_loc11_].DynamicDataType,
                           "current":param1.Objectives[_loc8_].SubObjectives[_loc11_].CurrentCount,
                           "target":param1.Objectives[_loc8_].SubObjectives[_loc11_].TargetCount,
                           "stateText":param1.Objectives[_loc8_].SubObjectives[_loc11_].StateText
                        });
                        _loc12_.setParentClass(this);
                        this.m_entries.push({
                           "type":ObjectivesData.TYPE_SUB_OBJECTIVE,
                           "id":param1.Objectives[_loc8_].SubObjectives[_loc11_].ObjectiveID,
                           "entry":_loc12_,
                           "collapse":!_loc10_,
                           "height":_loc12_.getHeight(),
                           "entryOffset":SUBOBJ_INDENT
                        });
                        if(_loc12_.getWidth() + SUBOBJ_INDENT > this.m_widestEntryWidth)
                        {
                           this.m_widestEntryWidth = _loc12_.getWidth() + SUBOBJ_INDENT;
                        }
                     }
                     if(param1.Objectives[_loc8_].SubObjectives[_loc11_].Opportunities.length > 0)
                     {
                        this.addOpportunities(param1.Objectives[_loc8_].SubObjectives[_loc11_].Opportunities,true);
                     }
                     if(param1.Objectives[_loc8_].SubObjectives[_loc11_].UnrevealedOpportunities.length > 0)
                     {
                        this.m_undiscovered_opportunities += param1.Objectives[_loc8_].SubObjectives[_loc11_].UnrevealedOpportunities.length;
                        if(param1.Objectives[_loc8_].SubObjectives[_loc11_].IsNew)
                        {
                           _loc2_ = true;
                        }
                     }
                     _loc11_++;
                  }
               }
               _loc8_++;
            }
            if(this.m_undiscovered_opportunities > 0 && (this.m_newOpportunityFound || _loc2_) && !this.m_lastUpdateWasInWatchMode)
            {
               this.addUnrevealedOpportunities();
            }
            this.arrangeList();
            if(this.m_isAimingWatch)
            {
               Animate.kill(this.m_delaySprite);
            }
            else
            {
               Animate.delay(this.m_delaySprite,LIST_DISPLAY_TIME,this.arrangeList,true);
            }
         }
         this.m_lastUpdateWasInWatchMode = this.m_isAimingWatch;
      }
      
      private function addOpportunities(param1:Array, param2:Boolean = false) : void
      {
         var _loc5_:ObjectivesWidgetOpportunityEntry = null;
         var _loc3_:Number = param2 ? OPPORTUNITY_SUBOBJECTIVE_INDENT : OPPORTUNITY_OBJECTIVE_INDENT;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            if(param1[_loc4_].IsTracked && param1[_loc4_].State != ObjectivesData.STATE_COMPLETED && param1[_loc4_].State != ObjectivesData.STATE_FAILED || param1[_loc4_].IsNew && !this.m_lastUpdateWasInWatchMode && !this.m_isAimingWatch && param1[_loc4_].State == ObjectivesData.STATE_ACTIVE || param1[_loc4_].DidStateChange && !this.m_lastUpdateWasInWatchMode && !this.m_isAimingWatch)
            {
               _loc5_ = new ObjectivesWidgetOpportunityEntry();
               this.m_view.container_mc.addChild(_loc5_);
               _loc5_.instantiateEntry(param1[_loc4_],_loc4_,this.m_isAimingWatch || this.m_lastUpdateWasInWatchMode,param1[_loc4_].IsTracked,this.m_entries.length);
               _loc5_.setParentClass(this);
               _loc5_.x = _loc3_;
               this.m_entries.push({
                  "type":ObjectivesData.TYPE_OPPERTUNITY,
                  "entry":_loc5_,
                  "collapse":!param1[_loc4_].IsTracked || param1[_loc4_].State == ObjectivesData.STATE_COMPLETED || param1[_loc4_].State == ObjectivesData.STATE_FAILED,
                  "entryOffset":_loc3_,
                  "height":_loc5_.getHeight()
               });
               if(_loc5_.getWidth() + _loc3_ > this.m_widestEntryWidth)
               {
                  this.m_widestEntryWidth = _loc5_.getWidth() + _loc3_;
               }
            }
            if(param1[_loc4_].IsNew && param1[_loc4_].CurrentStepIndex == 0 && !this.m_lastUpdateWasInWatchMode)
            {
               this.m_newOpportunityFound = true;
            }
            _loc4_++;
         }
      }
      
      public function setTimers(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_];
            _loc4_ = 0;
            while(_loc4_ < this.m_entries.length)
            {
               _loc5_ = this.m_entries[_loc4_];
               if((_loc5_.type == ObjectivesData.TYPE_OBJECTIVE || _loc5_.type == ObjectivesData.TYPE_SUB_OBJECTIVE) && _loc5_.id == _loc3_.ObjectiveID)
               {
                  _loc5_.entry.setTimer(_loc3_);
               }
               _loc4_++;
            }
            _loc2_++;
         }
      }
      
      private function addUnrevealedOpportunities() : void
      {
         var _loc1_:ObjectivesWidgetOpportunityEntry = new ObjectivesWidgetOpportunityEntry();
         this.m_view.container_mc.addChild(_loc1_);
         _loc1_.x = SUBOBJ_INDENT;
         _loc1_.instantiateUnrevealedOppertunity({"State":ObjectivesData.STATE_DEACTIVATED},0,this.m_isAimingWatch,this.m_entries.length,this.m_undiscovered_opportunities);
         this.m_entries.push({
            "type":ObjectivesData.TYPE_OPPERTUNITY,
            "entry":_loc1_,
            "collapse":!this.m_isAimingWatch,
            "entryOffset":0,
            "height":_loc1_.getHeight()
         });
      }
      
      public function callBackEntryHeightUpdate(param1:int, param2:int) : void
      {
         this.m_entries[param1].height = param2;
         this.arrangeList();
      }
      
      private function arrangeList(param1:Boolean = false) : void
      {
         this.m_objectivesYOffset = 0;
         var _loc2_:Number = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_entries.length)
         {
            this.m_entries[_loc3_].entry.setEntryWidth(Math.ceil(this.m_widestEntryWidth),this.m_entries[_loc3_].entryOffset);
            if(param1 && Boolean(this.m_entries[_loc3_].collapse))
            {
               this.m_entries[_loc3_].entry.doCollapse();
            }
            else
            {
               this.m_objectivesYOffset += _loc2_;
               _loc2_ = 0;
               if(this.m_entries[_loc3_].type == ObjectivesData.TYPE_OBJECTIVE && _loc3_ > 0)
               {
                  this.m_objectivesYOffset += 16;
                  _loc2_ += 16;
               }
               if(param1)
               {
                  Animate.to(this.m_entries[_loc3_].entry,LIST_TRANSITION_TIME,0.3 + 0.05 * _loc3_,{"y":this.m_objectivesYOffset},Animate.ExpoOut);
               }
               else
               {
                  this.m_entries[_loc3_].entry.y = this.m_objectivesYOffset;
               }
               _loc2_ += this.m_entries[_loc3_].height;
            }
            _loc3_++;
         }
      }
      
      private function updateVisibility() : void
      {
         this.m_view.visible = this.m_isAimingWatch;
         this.m_view.alpha = this.m_isAimingWatch ? 1 : 0;
         this.m_view.x = 0;
         this.m_view.y = 0;
         this.m_view.scaleX = this.m_view.scaleY = OBJECTIVES_SCALE;
      }
      
      private function hideWidget() : void
      {
         Animate.kill(this.m_view);
         Animate.kill(this.m_delaySprite);
         this.m_isAimingWatch = false;
         ObjectivesMarkerWidget.setGlobalWatchState(false);
         this.m_lastUpdateWasInWatchMode = false;
         this.m_view.visible = false;
         this.m_view.alpha = 0;
         this.m_view.x = 0;
         this.m_view.y = 0;
         this.m_view.scaleX = this.m_view.scaleY = OBJECTIVES_SCALE;
      }
   }
}
