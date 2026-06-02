package knt.hud.agency
{
   import flash.filters.DropShadowFilter;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.TaskletSequencer;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class AgencySelectorWidget extends BaseControl
   {
      
      private var m_view:AgencySelectorWidgetView;
      
      private var m_agencyEntriesInstantiated:Boolean = false;
      
      private var m_entriesArray:Array = new Array();
      
      private var m_entriesXPosArray:Array = new Array();
      
      private var m_isAimingWatch:Boolean = false;
      
      private var m_accumulatedXPos:Number = 0;
      
      private var m_testDataObject:Object = new Object();
      
      private var m_ishiddenDueToSocial:Boolean = false;
      
      private var m_ishiddenDueToNoInstinctMovesAvailable:Boolean = false;
      
      private var m_frameHiddenDueToForceShow:Boolean = false;
      
      public function AgencySelectorWidget()
      {
         super();
         this.m_view = new AgencySelectorWidgetView();
         addChild(this.m_view);
         MenuUtils.setColor(this.m_view.frame_mc.icon_mc,MenuConstantsKnt.COLOR_AGENCY,false);
         this.m_view.frame_mc.corner_R_mc.filters = [new DropShadowFilter(2,90,0,0.8,4,4,0.8,1)];
         this.m_view.frame_mc.corner_L_mc.filters = [new DropShadowFilter(2,90,0,0.8,4,4,0.8,1)];
         this.m_view.frame_mc.line_R_mc.filters = [new DropShadowFilter(2,90,0,1,4,4,0.8,1)];
         this.m_view.frame_mc.line_L_mc.filters = [new DropShadowFilter(2,90,0,1,4,4,0.8,1)];
         this.m_view.frame_mc.num_mc.filters = [new DropShadowFilter(2,90,0,0.8,4,4,0.8,1)];
         this.m_view.frame_mc.icon_mc.alpha = 0.3;
         this.m_view.frame_mc.corner_R_mc.alpha = 0.6;
         this.m_view.frame_mc.corner_L_mc.alpha = 0.6;
         this.m_view.frame_mc.line_R_mc.alpha = 0.2;
         this.m_view.frame_mc.line_L_mc.alpha = 0.2;
         this.m_view.frame_mc.bg_mc.alpha = 0.1;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _this:AgencySelectorWidget = null;
         var abort:Boolean = false;
         var data:Object = param1;
         _this = this;
         var ts:TaskletSequencer = TaskletSequencer.getGlobalInstance();
         ts.addChunk(function():void
         {
            var _loc1_:int = 0;
            if(m_agencyEntriesInstantiated && data.agencyPrompts.length != m_entriesArray.length)
            {
               Animate.kill(m_view.container_mc);
               _loc1_ = 0;
               while(_loc1_ < m_entriesArray.length)
               {
                  Animate.kill(m_entriesArray[_loc1_]);
                  m_entriesArray[_loc1_].removePrompt();
                  _loc1_++;
               }
               while(m_view.container_mc.numChildren > 0)
               {
                  m_view.container_mc.removeChildAt(0);
               }
               m_entriesArray = [];
               m_entriesXPosArray = [];
               m_agencyEntriesInstantiated = false;
               m_ishiddenDueToNoInstinctMovesAvailable = false;
            }
         });
         if(!data.agencyPrompts.length || !this.hasAnyActionablePrompt(data.agencyPrompts))
         {
            this.hideForNoActionablePrompts();
            return;
         }
         this.m_ishiddenDueToNoInstinctMovesAvailable = false;
         abort = false;
         ts.addChunk(function():void
         {
            var _loc1_:int = 0;
            var _loc2_:AgencySelectorWidgetEntry = null;
            if(!m_agencyEntriesInstantiated)
            {
               m_entriesXPosArray = [];
               _loc1_ = 0;
               while(_loc1_ < data.agencyPrompts.length)
               {
                  if(!data.agencyPrompts[_loc1_].m_promptData)
                  {
                     abort = true;
                     return;
                  }
                  if(!data.agencyPrompts[_loc1_].m_promptData.length)
                  {
                     abort = true;
                     return;
                  }
                  if(!data.agencyPrompts[_loc1_].m_promptData[0].aElements)
                  {
                     abort = true;
                     return;
                  }
                  if(!data.agencyPrompts[_loc1_].m_promptData[0].aElements.length)
                  {
                     abort = true;
                     return;
                  }
                  if(data.agencyPrompts[_loc1_].m_promptData[0].aElements[0].iconId == -1 && data.agencyPrompts[_loc1_].m_promptData[0].aElements[0].keyGlyph == "")
                  {
                     abort = true;
                     return;
                  }
                  _loc2_ = new AgencySelectorWidgetEntry();
                  _loc2_.setParentClass(_this);
                  m_view.container_mc.addChild(_loc2_);
                  m_entriesArray.push(_loc2_);
                  m_entriesXPosArray.push(0);
                  _loc1_++;
               }
               m_ishiddenDueToNoInstinctMovesAvailable = false;
               m_agencyEntriesInstantiated = true;
               Animate.kill(m_view);
               Animate.to(m_view,0.2,0,{
                  "y":0,
                  "alpha":1
               },Animate.ExpoOut);
            }
         });
         ts.addChunk(function():void
         {
            var _loc2_:Object = null;
            if(abort)
            {
               return;
            }
            var _loc1_:int = 0;
            while(_loc1_ < data.agencyPrompts.length)
            {
               _loc2_ = new Object();
               _loc2_ = data.agencyPrompts[_loc1_];
               _loc2_.entryindex = _loc1_;
               _loc2_.hideAmount = data.forceShow ? true : false;
               m_entriesArray[_loc1_].onSetData(_loc2_);
               _loc1_++;
            }
            MenuUtils.setupTextUpper(m_view.frame_mc.num_mc.title_txt,data.agencyData.playerChunks,30,MenuConstantsKnt.FONT_TYPE_NUMBERS_BOLD,MenuConstantsKnt.FontColorAgency);
         });
         ts.addChunk(function():void
         {
            if(abort)
            {
               return;
            }
            if(Boolean(data.forceShow) || Boolean(data.commonData.isLethalForceEnabled) || Boolean(data.commonData.isTrespassing) || Boolean(data.commonData.isLicenseToPunch) || Boolean(data.commonData.isSoftTrespassing))
            {
               if(data.forceShow != m_frameHiddenDueToForceShow)
               {
                  m_view.frame_mc.num_mc.visible = data.forceShow ? false : true;
                  m_frameHiddenDueToForceShow = data.forceShow;
               }
               if(m_ishiddenDueToSocial)
               {
                  Animate.kill(m_view);
                  if(data.commonData.isAimingWatch)
                  {
                     Animate.to(m_view,0.2,0,{
                        "y":200,
                        "scaleX":1.2,
                        "scaleY":1.2,
                        "alpha":0
                     },Animate.ExpoOut);
                  }
                  else
                  {
                     Animate.to(m_view,0.2,0,{
                        "y":0,
                        "alpha":1
                     },Animate.ExpoOut);
                  }
                  m_ishiddenDueToSocial = false;
               }
               return;
            }
            if(!m_ishiddenDueToSocial)
            {
               Animate.kill(m_view);
               Animate.to(m_view,0.2,0,{
                  "y":0,
                  "alpha":0
               },Animate.ExpoOut);
               m_ishiddenDueToSocial = true;
            }
         });
         ts.addChunk(function():void
         {
            if(abort)
            {
               return;
            }
            if(m_ishiddenDueToSocial)
            {
               return;
            }
            if(data.commonData.isAimingWatch)
            {
               if(!m_isAimingWatch)
               {
                  Animate.kill(m_view);
                  Animate.to(m_view,0.2,0,{
                     "y":200,
                     "scaleX":1.2,
                     "scaleY":1.2,
                     "alpha":0
                  },Animate.ExpoOut);
                  m_isAimingWatch = true;
               }
            }
            else if(m_isAimingWatch)
            {
               Animate.kill(m_view);
               Animate.to(m_view,0.2,0,{
                  "y":0,
                  "scaleX":1,
                  "scaleY":1,
                  "alpha":1
               },Animate.ExpoOut);
               m_isAimingWatch = false;
            }
         });
      }
      
      public function callBackEntryWidthAndRealignEntriesXPos(param1:int, param2:Number) : void
      {
         this.m_entriesXPosArray[param1] = param2;
         this.m_accumulatedXPos = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_entriesArray.length)
         {
            Animate.kill(this.m_entriesArray[_loc3_]);
            Animate.to(this.m_entriesArray[_loc3_],0.2,0,{"x":this.m_accumulatedXPos},Animate.ExpoOut);
            this.m_accumulatedXPos += this.m_entriesXPosArray[_loc3_];
            _loc3_++;
         }
         Animate.kill(this.m_view.container_mc);
         Animate.to(this.m_view.container_mc,0.2,0,{"x":this.m_accumulatedXPos / -2 + 33},Animate.ExpoOut);
         Animate.kill(this.m_view.frame_mc.corner_R_mc);
         Animate.kill(this.m_view.frame_mc.corner_L_mc);
         Animate.kill(this.m_view.frame_mc.line_R_mc);
         Animate.kill(this.m_view.frame_mc.line_L_mc);
         Animate.kill(this.m_view.frame_mc.bg_mc);
         Animate.to(this.m_view.frame_mc.corner_R_mc,0.2,0,{"x":this.m_accumulatedXPos / 2 + 20},Animate.ExpoOut);
         Animate.to(this.m_view.frame_mc.corner_L_mc,0.2,0,{"x":this.m_accumulatedXPos / -2 - 20},Animate.ExpoOut);
         Animate.to(this.m_view.frame_mc.line_R_mc,0.2,0,{"width":this.m_accumulatedXPos / 2},Animate.ExpoOut);
         Animate.to(this.m_view.frame_mc.line_L_mc,0.2,0,{"width":this.m_accumulatedXPos / 2},Animate.ExpoOut);
         Animate.to(this.m_view.frame_mc.bg_mc,0.2,0,{"width":this.m_accumulatedXPos + 220},Animate.ExpoOut);
      }
      
      private function hasAnyActionablePrompt(param1:Array) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_];
            if(_loc3_ != null && _loc3_.m_promptData != null && _loc3_.m_promptData.length > 0 && _loc3_.m_promptData[0] != null && Boolean(_loc3_.m_promptData[0].isEnabled) && (_loc3_.m_blockedLabel == null || _loc3_.m_blockedLabel == ""))
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function hideForNoActionablePrompts() : void
      {
         Animate.kill(this.m_view);
         this.m_view.visible = true;
         Animate.to(this.m_view,0.2,0,{
            "y":200,
            "scaleX":1.2,
            "scaleY":1.2,
            "alpha":0
         },Animate.ExpoOut,function():void
         {
            m_view.visible = false;
         });
         this.m_ishiddenDueToNoInstinctMovesAvailable = true;
      }
   }
}
