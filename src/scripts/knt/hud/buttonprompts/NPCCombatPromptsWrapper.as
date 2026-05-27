package knt.hud.buttonprompts
{
   import flash.display.Sprite;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.ObjectUtils;
   import knt.hud.*;
   
   public class NPCCombatPromptsWrapper extends BaseControl
   {
      
      private var m_aPrompts:Vector.<NPCCombatPromptsWidget>;
      
      private var m_promptsContainer:Sprite;
      
      private var m_edgeLocked:Boolean = false;
      
      private var m_lastSetHadAConfrontPrompt:Boolean = false;
      
      private const MAX_PROMPTS:int = 4;
      
      private const VERTICALSPACING:Number = 38;
      
      private var m_verticalOffset:Number = 0;
      
      private var m_isConfrontPrompt:Boolean = false;
      
      private var m_enableFaceButtonArrangement:Boolean = false;
      
      private var m_nowShowingFaceButtonArrangement:Boolean = false;
      
      private var m_faceButtonPositionsX:Array;
      
      private var m_faceButtonPositionsY:Array;
      
      private var m_aNotUsedMarkers:Array;
      
      public function NPCCombatPromptsWrapper()
      {
         var _loc3_:ConfrontationPromptsNotUsedPrompt = null;
         var _loc4_:NPCCombatPromptsWidget = null;
         this.m_aPrompts = new Vector.<NPCCombatPromptsWidget>();
         this.m_aNotUsedMarkers = new Array();
         super();
         this.m_promptsContainer = new Sprite();
         addChild(this.m_promptsContainer);
         this.m_faceButtonPositionsX = new Array(0,0,-32,32,0,0);
         this.m_faceButtonPositionsY = new Array(32,-32,0,0,74,116);
         var _loc1_:int = 0;
         while(_loc1_ < 4)
         {
            _loc3_ = new ConfrontationPromptsNotUsedPrompt();
            _loc3_.x = this.m_faceButtonPositionsX[_loc1_];
            _loc3_.y = this.m_faceButtonPositionsY[_loc1_];
            _loc3_.visible = false;
            this.m_promptsContainer.addChild(_loc3_);
            this.m_aNotUsedMarkers.push(_loc3_);
            _loc1_++;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.MAX_PROMPTS)
         {
            _loc4_ = new NPCCombatPromptsWidget();
            this.m_promptsContainer.addChild(_loc4_);
            this.m_aPrompts.push(_loc4_);
            _loc2_++;
         }
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc4_:* = false;
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         var _loc12_:int = 0;
         if(param1.id && param1.id == "distance" && param1.isActice == undefined)
         {
            return;
         }
         if(!param1.isActive || !param1.m_prompts.length)
         {
            this.m_promptsContainer.visible = false;
            this.edgeAngle(-1);
            return;
         }
         var _loc2_:Number = 0;
         this.m_isConfrontPrompt = false;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = ControlsMain.getControllerType();
         this.m_nowShowingFaceButtonArrangement = this.m_enableFaceButtonArrangement && (_loc7_ == CommonUtils.CONTROLLER_TYPE_PS4 || _loc7_ == CommonUtils.CONTROLLER_TYPE_PS5 || _loc7_ == CommonUtils.CONTROLLER_TYPE_XBOXONE || _loc7_ == CommonUtils.CONTROLLER_TYPE_XBOXSERIESX || _loc7_ == CommonUtils.CONTROLLER_TYPE_PC);
         _loc3_ = 0;
         while(_loc3_ < param1.m_prompts.length)
         {
            _loc10_ = param1.m_prompts[_loc3_];
            _loc11_ = ObjectUtils.cloneDeep(param1);
            _loc11_.m_prompts = [];
            _loc11_.m_prompts.push(_loc10_);
            _loc11_.lastSetHadAConfrontPrompt = this.m_lastSetHadAConfrontPrompt;
            this.m_aPrompts[_loc3_].onSetData(_loc11_);
            this.m_aPrompts[_loc3_].visible = true;
            if(param1.m_prompts[_loc3_].m_promptType == 7)
            {
               this.m_nowShowingFaceButtonArrangement = false;
            }
            if(this.m_nowShowingFaceButtonArrangement)
            {
               if(Boolean(_loc11_.m_prompts[0].m_promptData.length) && _loc11_.m_prompts[0].m_promptData[0].aElements[0].iconId <= 4)
               {
                  _loc5_ += _loc11_.m_prompts[0].m_promptData[0].aElements.length;
               }
               else
               {
                  _loc6_++;
               }
            }
            _loc3_++;
         }
         this.m_promptsContainer.visible = true;
         this.m_nowShowingFaceButtonArrangement = this.m_nowShowingFaceButtonArrangement && _loc5_ > 1;
         var _loc8_:int = 0;
         while(_loc8_ < 4)
         {
            this.m_aNotUsedMarkers[_loc8_].visible = this.m_nowShowingFaceButtonArrangement;
            _loc8_++;
         }
         var _loc9_:int = -1;
         _loc3_ = 0;
         while(_loc3_ < param1.m_prompts.length)
         {
            _loc4_ = _loc3_ == param1.m_prompts.length - 1;
            if(this.m_nowShowingFaceButtonArrangement)
            {
               if(param1.m_prompts[_loc3_].m_promptData.length)
               {
                  _loc9_ = int(param1.m_prompts[_loc3_].m_promptData[0].aElements[0].iconId);
               }
               if(param1.m_prompts[_loc3_].m_promptType == 7)
               {
                  this.m_isConfrontPrompt = true;
               }
               if(_loc9_ <= 4 && param1.m_prompts[_loc3_].m_promptType != 16)
               {
                  this.m_aPrompts[_loc3_].setPromptAlignment(_loc9_ == 2 || _loc9_ == 3 ? "left" : "right");
                  this.m_aPrompts[_loc3_].x = this.m_faceButtonPositionsX[_loc9_ - 1];
                  this.m_aPrompts[_loc3_].y = this.m_faceButtonPositionsY[_loc9_ - 1];
                  if(param1.m_prompts[_loc3_].m_promptData.length)
                  {
                     _loc12_ = 0;
                     while(_loc12_ < param1.m_prompts[_loc3_].m_promptData[0].aElements.length)
                     {
                        this.m_aNotUsedMarkers[param1.m_prompts[_loc3_].m_promptData[0].aElements[_loc12_].iconId - 1].visible = false;
                        _loc12_++;
                     }
                  }
               }
               else
               {
                  this.m_aPrompts[_loc3_].setPromptAlignment("right");
                  this.m_aPrompts[_loc3_].x = this.m_faceButtonPositionsX[4 + _loc6_];
                  this.m_aPrompts[_loc3_].y = this.m_faceButtonPositionsY[4 + _loc6_];
               }
            }
            else
            {
               if(_loc3_ < 4)
               {
                  this.m_aNotUsedMarkers[_loc3_].visible = false;
               }
               this.m_aPrompts[_loc3_].setPromptAlignment("right");
               this.m_aPrompts[_loc3_].x = 0;
               if(Boolean(_loc11_.m_prompts[0].m_promptData.length) && _loc11_.m_prompts[0].m_promptData[0].aElements.length > 1)
               {
                  this.m_aPrompts[_loc3_].y = _loc2_ + 32;
                  if(!_loc4_)
                  {
                     _loc2_ += this.VERTICALSPACING + 32;
                  }
               }
               else if(_loc11_.m_prompts[0].m_promptType == 7)
               {
                  this.m_isConfrontPrompt = true;
                  this.m_aPrompts[_loc3_].y = _loc2_ + 5;
                  if(!_loc4_)
                  {
                     _loc2_ += this.VERTICALSPACING + 10;
                  }
               }
               else
               {
                  this.m_aPrompts[_loc3_].y = _loc2_;
                  if(!_loc4_)
                  {
                     _loc2_ += this.VERTICALSPACING;
                  }
               }
            }
            _loc3_++;
         }
         this.m_promptsContainer.y = this.m_verticalOffset - _loc2_ * 0.3;
         this.m_lastSetHadAConfrontPrompt = this.m_isConfrontPrompt;
         _loc3_ = int(param1.m_prompts.length);
         while(_loc3_ < this.MAX_PROMPTS)
         {
            this.m_aPrompts[_loc3_].visible = false;
            _loc3_++;
         }
         this.filterEdgePrompts(this.m_edgeLocked);
      }
      
      public function set verticalOffset(param1:Number) : void
      {
         this.m_verticalOffset = param1;
      }
      
      public function edgeAngle(param1:Number) : void
      {
         if(param1 < 0)
         {
            if(this.m_edgeLocked)
            {
               this.m_edgeLocked = false;
               this.updatePromptDirection(-1);
               this.filterEdgePrompts(false);
            }
         }
         else
         {
            if(!this.m_edgeLocked)
            {
               this.m_edgeLocked = true;
               this.filterEdgePrompts(true);
            }
            this.updatePromptDirection(param1);
         }
      }
      
      private function updatePromptDirection(param1:Number) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this.m_aPrompts.length)
         {
            if(this.m_aPrompts[_loc2_].visible)
            {
               this.m_aPrompts[_loc2_].setPromptDirectionMarker(param1);
            }
            _loc2_++;
         }
      }
      
      private function filterEdgePrompts(param1:Boolean = false) : void
      {
         var _loc3_:NPCCombatPromptsWidget = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_aPrompts.length)
         {
            _loc3_ = this.m_aPrompts[_loc2_];
            if(param1)
            {
               _loc3_.alpha = _loc3_.m_promptType == 7 ? 1 : 0;
            }
            else
            {
               _loc3_.alpha = 1;
            }
            _loc2_++;
         }
      }
      
      public function set forceFaceButtonArrangement(param1:Boolean) : void
      {
         this.m_enableFaceButtonArrangement = param1;
      }
   }
}

