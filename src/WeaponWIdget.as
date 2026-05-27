package knt.hud.weapons
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.ImageLoader;
   import glacier.common.TaskletSequencer;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   import knt.hud.buttonprompts.ButtonPromptWidget;
   
   public class WeaponWidget extends BaseControl
   {
      
      private static const OPEN_ANIM_SPEED:Number = 0.2;
      
      private static const REMOVAL_ANIM_SPEED:Number = 0.1;
      
      private var m_view:WeaponWidgetView;
      
      private var m_ammoArrayActiveBulletEnd:int = 0;
      
      private var m_resourceIcon:GadgetSelectorEntryResourceIconsInnerView;
      
      private var m_ammoIcon:GadgetSelectorEntryResourceIconsInnerView;
      
      private var m_weaponUsesResource:Boolean = false;
      
      private var m_reloadDelaySprite:Sprite = new Sprite();
      
      private var m_reloadBarDelaySprite:Sprite = new Sprite();
      
      private var m_registeredAmmoTotal:int = 0;
      
      private var m_previousResourceCount:int = 0;
      
      private var m_currentWeapon:String = "";
      
      private var m_currentWeaponSecondary:String = "";
      
      private var m_currentWeaponSpecial:String = "";
      
      private var m_imageLoaderPrimary:ImageLoader;
      
      private var m_imageLoaderSecondary:ImageLoader;
      
      private var m_imageLoaderTertiary:ImageLoader;
      
      private var m_ammoBarSegments:Array = new Array();
      
      private var m_specialAmmoBarSegments:Array = new Array();
      
      private var m_ammoBarIndents:Array = new Array();
      
      private var m_specialAmmoBarIndents:Array = new Array();
      
      private var m_ammoBarReloadIndents:Array = new Array();
      
      private var m_infiniteAmmoTotal:Boolean = false;
      
      private var m_reloadInProgress:Boolean = false;
      
      private var m_reloadPulsating:Boolean = false;
      
      private var m_reloadStringEnabled:Boolean = false;
      
      private var m_outOfAmmoStringEnabled:Boolean = false;
      
      private var m_isDisabled:Boolean = false;
      
      private var m_wasDisabled:Boolean = false;
      
      private var m_nMaxAmount:int = 0;
      
      private var m_isAimingWatch:Boolean = false;
      
      private var m_isPlayerAiming:Boolean = false;
      
      private var m_outOfAmmoInGun:Boolean = false;
      
      private var m_outOfAmmoInStash:Boolean = false;
      
      private var m_hasGadgetResources:Boolean = false;
      
      private var m_currentWeaponSwapPromptIconId:int = -9;
      
      private var m_currentSpecialWeaponSwapPromptIconId:int = -9;
      
      private var m_ESPPrompt:ButtonPromptWidget;
      
      private var m_ESPPromptIsEnabled:Boolean = false;
      
      private var m_ESPPromptPressed:Boolean = false;
      
      private var m_ESPPromptInstantiated:Boolean = false;
      
      private var m_ESPPromptControllerType:String = "";
      
      private var m_ESPPromptIconId:int = -9;
      
      private var m_ESPPromptPositionSet:Boolean = false;
      
      private var m_ESPPromptTitle:String = "";
      
      private var m_controllerType:String = "";
      
      private var m_specialControllerType:String = "";
      
      private const PROMPT_TOP_YPOS:Number = 55;
      
      private const PROMPT_BOTTOM_YPOS:Number = 97;
      
      private const ICON_SCALE_FACTOR:Number = 0.5;
      
      private const ICON_X_TRANSLATE:Number = -14;
      
      public function WeaponWidget()
      {
         super();
         this.m_view = new WeaponWidgetView();
         this.m_view.secondary_container_mc.alpha = 0.4;
         this.m_view.special_container_mc.alpha = 0.4;
         this.m_view.ammo_bar.numb_mc.alpha = 0.6;
         this.m_view.ammo_bar.bar_bg_mc.outline_bg_mc.alpha = 0.2;
         this.m_view.ammo_bar.bar_bg_mc.dark_bg_mc.alpha = 0.1;
         this.m_view.ammo_bar.dropshadow_mc.alpha = 0.4;
         this.m_view.special_ammo_bar.bar_bg_mc.outline_bg_mc.alpha = 0.2;
         this.m_view.special_ammo_bar.bar_bg_mc.dark_bg_mc.alpha = 0.1;
         this.m_view.special_ammo_bar.dropshadow_mc.alpha = 0.4;
         MenuUtils.setColor(this.m_view.special_ammo_bar.end_pins_mc,8829393);
         this.m_view.ammo_bar.visible = false;
         this.m_view.special_ammo_bar.visible = false;
         this.m_view.gradient_lines_mc.visible = false;
         this.m_resourceIcon = new GadgetSelectorEntryResourceIconsInnerView();
         this.m_resourceIcon.scaleX = this.m_resourceIcon.scaleY = 1.13;
         this.m_view.gadget_resource_icon_container_mc.addChild(this.m_resourceIcon);
         this.m_ammoIcon = new GadgetSelectorEntryResourceIconsInnerView();
         this.m_ammoIcon.scaleX = this.m_ammoIcon.scaleY = 1.13;
         this.m_view.ammo_icon_container_mc.addChild(this.m_ammoIcon);
         this.m_view.ammo_info_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.weapon_container_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.secondary_container_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.special_container_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.gadget_resource_icon_container_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.ammo_icon_container_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.prompt_container_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.special_prompt_container_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.ammo_bar.numb_mc.filters = [new DropShadowFilter(4,29,0,0.3,4,4,0.4,1)];
         this.m_view.ammo_info_mc.visible = false;
         this.m_view.prompt_container_mc.alpha = 0.6;
         this.m_view.special_prompt_container_mc.alpha = 0.6;
         this.m_view.prompt_container_mc.visible = false;
         this.m_view.special_prompt_container_mc.visible = false;
         addChild(this.m_view);
         this.m_currentWeapon = "";
         this.m_currentWeaponSecondary = "";
         this.m_currentWeaponSpecial = "";
      }
      
      public function onSetData(param1:Object) : void
      {
         var ts:TaskletSequencer;
         var data:Object = param1;
         if(data == null)
         {
            return;
         }
         ts = TaskletSequencer.getGlobalInstance();
         ts.addChunk(function():void
         {
            if(data.isAimingWatch)
            {
               if(!m_isAimingWatch)
               {
                  Animate.kill(m_view);
                  Animate.to(m_view,0.2,0,{
                     "x":140,
                     "y":100,
                     "scaleX":1.3,
                     "scaleY":1.3,
                     "alpha":0
                  },Animate.ExpoOut);
                  m_isAimingWatch = true;
               }
            }
            else if(m_isAimingWatch)
            {
               Animate.kill(m_view);
               Animate.to(m_view,0.2,0,{
                  "x":0,
                  "y":0,
                  "scaleX":1,
                  "scaleY":1,
                  "alpha":(data.ItemData.isDisabled ? 0.4 : 1)
               },Animate.ExpoOut);
               m_isAimingWatch = false;
            }
         });
         ts.addChunk(function():void
         {
            onItemData(data.ItemData);
         });
      }
      
      private function onItemData(param1:Object) : void
      {
         var updatedSecondary:Boolean;
         var updatedSpecial:Boolean;
         var ammoDiff:Boolean = false;
         var i:int = 0;
         var previousAmmoTotalString:String = null;
         var currentAmmoTotalString:String = null;
         var bulletsDecreased:Boolean = false;
         var ammoI:int = 0;
         var ammoLoopEnd:int = 0;
         var ammoVisible:Boolean = false;
         var resourceColor:int = 0;
         var flooredResourceAmount:int = 0;
         var specialAmmoDiff:Boolean = false;
         var resourcesDecreased:Boolean = false;
         var resourceI:int = 0;
         var resourceLoopEnd:int = 0;
         var resourceVisible:Boolean = false;
         var data:Object = param1;
         if(data.sIconResource != null && data.sIconResource != "")
         {
            if(data.sIconResource != this.m_currentWeapon || data.sIconResource == this.m_currentWeapon && data.nMaxAmount != this.m_nMaxAmount)
            {
               if(this.m_reloadInProgress)
               {
                  this.interruptReload();
               }
               this.removeWeapon();
               if(this.m_ESPPromptInstantiated)
               {
                  this.removeESPPrompt();
               }
               this.m_currentWeapon = data.sIconResource;
               this.m_view.ammo_info_mc.ammo_txt_mc.alpha = 0.8;
               this.m_view.ammo_info_mc.ammo_txt_mc.ammo_pop_mc.alpha = 0;
               if(data.nRemainingAmount == 0 && data.nTotalAmount == 0)
               {
                  this.m_view.ammo_info_mc.ammo_txt_mc.alpha = 0.4;
               }
               this.m_view.weapon_container_mc.scaleX = this.m_view.weapon_container_mc.scaleY = 1 * this.ICON_SCALE_FACTOR;
               this.loadWeaponImage(this.m_currentWeapon,this.m_imageLoaderPrimary,this.m_view.weapon_container_mc);
               this.m_view.ammo_bar.visible = true;
               this.m_ammoIcon.gotoAndStop("ammo");
               this.m_view.gradient_lines_mc.visible = true;
               this.m_view.ammo_info_mc.visible = true;
               this.m_view.ammo_info_mc.alpha = 1;
               this.m_view.ammo_info_mc.infinite_mc.visible = false;
               this.m_view.ammo_info_mc.ammo_txt_mc.visible = true;
               this.m_view.ammo_info_mc.ammo_txt_mc.alpha = 0.8;
               if(data.nTotalAmount == -1)
               {
                  this.m_view.ammo_info_mc.infinite_mc.visible = true;
                  this.m_view.ammo_info_mc.ammo_txt_mc.visible = false;
                  MenuUtils.setupText(this.m_view.ammo_bar.numb_mc.total_amount_txt,this.addLeadingZero(0),16,MenuConstantsKnt.FONT_TYPE_NUMBERS_BOLD,MenuConstantsKnt.FontColorWhite);
                  MenuUtils.setupText(this.m_view.ammo_bar.numb_mc.zero_amount_txt,this.addLeadingZero(0),16,MenuConstantsKnt.FONT_TYPE_NUMBERS_BOLD,MenuConstantsKnt.FontColorWhite);
                  this.m_infiniteAmmoTotal = true;
               }
               else
               {
                  this.m_registeredAmmoTotal = data.nTotalAmount;
                  MenuUtils.setupText(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.ammo_txt,this.addLeadingZero(data.nRemainingAmount),80,MenuConstantsKnt.FONT_TYPE_NUMBERS_LIGHT,MenuConstantsKnt.FontColorWhite);
                  MenuUtils.setupText(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.ammo_total_txt,this.addLeadingZero(data.nTotalAmount),38,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorWhite);
                  MenuUtils.setupText(this.m_view.ammo_bar.numb_mc.total_amount_txt,this.addLeadingZero(data.nMaxAmount),16,MenuConstantsKnt.FONT_TYPE_NUMBERS_BOLD,MenuConstantsKnt.FontColorWhite);
                  MenuUtils.setupText(this.m_view.ammo_bar.numb_mc.zero_amount_txt,this.addLeadingZero(0),16,MenuConstantsKnt.FONT_TYPE_NUMBERS_BOLD,MenuConstantsKnt.FontColorWhite);
                  this.m_infiniteAmmoTotal = false;
               }
               this.drawAmmoBarSegments(data.nMaxAmount,142,90,1);
               ammoDiff = data.nMaxAmount - data.nRemainingAmount == 0 ? false : true;
               i = 0;
               i = 0;
               while(i < data.nMaxAmount)
               {
                  if(ammoDiff && i >= data.nRemainingAmount)
                  {
                     this.m_ammoBarSegments[i].barSegment.visible = false;
                  }
                  i++;
               }
            }
            if(this.m_controllerType != data.nextFirearmPromptData.controllerType || data.nextFirearmPromptData.aElements[0].iconId && data.nextFirearmPromptData.aElements[0].iconId != this.m_currentWeaponSwapPromptIconId)
            {
               this.setPromptImage(this.m_view.prompt_container_mc,data.nextFirearmPromptData);
               this.m_currentWeaponSwapPromptIconId = data.nextFirearmPromptData.aElements[0].iconId;
               this.m_controllerType = data.nextFirearmPromptData.controllerType;
            }
            if(this.m_specialControllerType != data.specialFirearmPromptData.controllerType || data.specialFirearmPromptData.aElements[0].iconId && data.specialFirearmPromptData.aElements[0].iconId != this.m_currentSpecialWeaponSwapPromptIconId)
            {
               this.setPromptImage(this.m_view.special_prompt_container_mc,data.specialFirearmPromptData);
               this.m_currentSpecialWeaponSwapPromptIconId = data.specialFirearmPromptData.aElements[0].iconId;
               this.m_specialControllerType = data.specialFirearmPromptData.controllerType;
            }
            this.m_nMaxAmount = data.nMaxAmount;
            if(this.m_currentWeapon != "")
            {
               if(data.isDisabled)
               {
                  if(!this.m_isDisabled)
                  {
                     if(this.m_weaponUsesResource)
                     {
                        this.m_view.gadget_resource_icon_container_mc.alpha = 1;
                        this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.alpha = 1;
                     }
                     this.m_view.ammo_icon_container_mc.alpha = 1;
                     this.m_view.alpha = 0.4;
                     this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.alpha = 1;
                     this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.alpha = 1;
                     this.m_view.weapon_container_mc.alpha = 1;
                     this.m_outOfAmmoInGun = false;
                     this.m_outOfAmmoInStash = false;
                     this.m_wasDisabled = true;
                     this.m_isDisabled = true;
                  }
               }
               else if(this.m_isDisabled)
               {
                  if(this.m_weaponUsesResource)
                  {
                     if(!this.m_hasGadgetResources)
                     {
                        this.m_view.gadget_resource_icon_container_mc.alpha = 0.4;
                        this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.alpha = 0.4;
                     }
                  }
                  this.m_view.alpha = 1;
                  this.m_isDisabled = false;
               }
               if(!this.m_reloadInProgress)
               {
                  MenuUtils.setupText(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.ammo_txt,this.addLeadingZero(data.nRemainingAmount),80,MenuConstantsKnt.FONT_TYPE_NUMBERS_LIGHT,MenuConstantsKnt.FontColorWhite);
               }
               if(data.nMaxAmount >= 2)
               {
                  if(!this.m_isDisabled)
                  {
                     if(data.nRemainingAmount <= 2 && data.nRemainingAmount > 0 && data.nTotalAmount >= 1)
                     {
                        if(this.m_outOfAmmoInGun || this.m_outOfAmmoInStash)
                        {
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.alpha = 1;
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.alpha = 1;
                           this.m_view.weapon_container_mc.alpha = 1;
                           this.m_view.ammo_icon_container_mc.alpha = 1;
                           this.m_view.ammo_bar.end_pins_mc.alpha = 1;
                           this.m_outOfAmmoInGun = false;
                           this.m_outOfAmmoInStash = false;
                        }
                     }
                     else if(data.nRemainingAmount <= 0 && data.nTotalAmount >= 1)
                     {
                        if(!this.m_outOfAmmoInGun)
                        {
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.alpha = 0.4;
                           this.m_view.ammo_icon_container_mc.alpha = 1;
                           this.m_view.ammo_bar.end_pins_mc.alpha = 1;
                           this.m_outOfAmmoInGun = true;
                        }
                        if(this.m_outOfAmmoInStash)
                        {
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.alpha = 1;
                           this.m_view.weapon_container_mc.alpha = 1;
                           this.m_view.ammo_icon_container_mc.alpha = 1;
                           this.m_view.ammo_bar.end_pins_mc.alpha = 1;
                           this.m_outOfAmmoInStash = false;
                        }
                     }
                     else if(data.nRemainingAmount > 0 && data.nTotalAmount <= 0)
                     {
                        if(this.m_outOfAmmoInGun)
                        {
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.alpha = 1;
                           this.m_view.ammo_icon_container_mc.alpha = 1;
                           this.m_view.ammo_bar.end_pins_mc.alpha = 1;
                           this.m_view.weapon_container_mc.alpha = 1;
                           this.m_outOfAmmoInGun = false;
                        }
                        if(!this.m_outOfAmmoInStash)
                        {
                           if(!this.m_reloadInProgress)
                           {
                              this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.alpha = 0.4;
                           }
                           this.m_view.ammo_icon_container_mc.alpha = 1;
                           this.m_view.ammo_bar.end_pins_mc.alpha = 1;
                           this.m_outOfAmmoInStash = true;
                        }
                     }
                     else if(data.nRemainingAmount <= 0 && data.nTotalAmount <= 0)
                     {
                        if(!this.m_outOfAmmoInGun || !this.m_outOfAmmoInStash)
                        {
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.alpha = 0.4;
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.alpha = 0.4;
                           this.m_view.weapon_container_mc.alpha = 0.4;
                           this.m_view.ammo_icon_container_mc.alpha = 0.4;
                           this.m_view.ammo_bar.end_pins_mc.alpha = 0.4;
                           this.m_outOfAmmoInGun = true;
                           this.m_outOfAmmoInStash = true;
                        }
                     }
                     else if(this.m_outOfAmmoInGun || this.m_outOfAmmoInStash || this.m_wasDisabled)
                     {
                        this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.alpha = 1;
                        this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.alpha = 1;
                        this.m_view.weapon_container_mc.alpha = 1;
                        this.m_view.ammo_icon_container_mc.alpha = 1;
                        this.m_view.ammo_bar.end_pins_mc.alpha = 1;
                        this.m_outOfAmmoInGun = false;
                        this.m_outOfAmmoInStash = false;
                        this.m_wasDisabled = false;
                     }
                  }
               }
               if(data.nTotalAmount > this.m_registeredAmmoTotal || data.nTotalAmount < this.m_registeredAmmoTotal && !data.bIsReloading && !this.m_reloadInProgress)
               {
                  Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc);
                  Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_pop_mc);
                  this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleX = this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleY = 1.4;
                  Animate.to(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc,0.6,0,{
                     "scaleX":1,
                     "scaleY":1
                  },Animate.ExpoOut);
                  this.m_view.ammo_info_mc.ammo_txt_mc.ammo_pop_mc.alpha = 1;
                  this.m_view.ammo_info_mc.ammo_txt_mc.ammo_pop_mc.scaleY = 0.3;
                  Animate.to(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_pop_mc,0.4,0,{
                     "alpha":0,
                     "scaleY":0.8
                  },Animate.ExpoOut);
                  previousAmmoTotalString = String(this.m_registeredAmmoTotal);
                  currentAmmoTotalString = String(data.nTotalAmount);
                  Animate.addFromToExtended(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.ammo_total_txt,0.6,0,{"intAnimation":previousAmmoTotalString},{"intAnimation":currentAmmoTotalString},Animate.Linear,"","",2,function():void
                  {
                     TaskletSequencer.getGlobalInstance().addChunk(function():void
                     {
                        MenuUtils.setupText(m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.ammo_total_txt,addLeadingZero(data.nTotalAmount),38,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorWhite);
                     });
                  });
                  this.m_registeredAmmoTotal = data.nTotalAmount;
               }
               if(data.bIsReloading)
               {
                  if(!this.m_reloadInProgress)
                  {
                     this.m_reloadInProgress = true;
                     this.showReloadTimer(data.fReloadDuration);
                     if(data.nTotalAmount == -1)
                     {
                        this.reload(data.nMaxAmount,data.fReloadDuration);
                     }
                     else if(this.m_registeredAmmoTotal + data.nRemainingAmount >= data.nMaxAmount)
                     {
                        this.reload(data.nMaxAmount,data.fReloadDuration);
                     }
                     else
                     {
                        this.reload(this.m_registeredAmmoTotal + data.nRemainingAmount,data.fReloadDuration);
                     }
                  }
               }
               else
               {
                  if(this.m_reloadInProgress)
                  {
                     this.interruptReload();
                     if(data.nTotalAmount != -1)
                     {
                        Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc);
                        MenuUtils.setupText(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_mc.ammo_txt,this.addLeadingZero(data.nRemainingAmount),80,MenuConstantsKnt.FONT_TYPE_NUMBERS_LIGHT,MenuConstantsKnt.FontColorWhite);
                        MenuUtils.setupText(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.ammo_total_txt,this.addLeadingZero(data.nTotalAmount),38,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorWhite);
                        if(this.m_outOfAmmoInStash)
                        {
                           this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.alpha = 0.4;
                        }
                        this.m_registeredAmmoTotal = data.nTotalAmount;
                     }
                     this.m_reloadInProgress = false;
                  }
                  if(data.nRemainingAmount != this.m_ammoArrayActiveBulletEnd)
                  {
                     bulletsDecreased = data.nRemainingAmount < this.m_ammoArrayActiveBulletEnd;
                     ammoI = bulletsDecreased ? int(data.nRemainingAmount) : this.m_ammoArrayActiveBulletEnd;
                     ammoLoopEnd = bulletsDecreased ? this.m_ammoArrayActiveBulletEnd : int(data.nRemainingAmount);
                     ammoVisible = bulletsDecreased ? false : true;
                     while(ammoI < ammoLoopEnd)
                     {
                        if(ammoI < this.m_ammoBarSegments.length)
                        {
                           this.m_ammoBarSegments[ammoI].barSegment.visible = ammoVisible;
                        }
                        ammoI++;
                     }
                     this.m_ammoArrayActiveBulletEnd = data.nRemainingAmount;
                  }
               }
               if(data.nTotalAmount == -1 && !this.m_infiniteAmmoTotal)
               {
                  this.m_view.ammo_info_mc.infinite_mc.visible = true;
                  this.m_view.ammo_info_mc.ammo_txt_mc.visible = false;
                  Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc);
                  this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleX = this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleY = 1;
                  this.m_infiniteAmmoTotal = true;
               }
               else if(data.nTotalAmount != -1 && this.m_infiniteAmmoTotal)
               {
                  this.m_view.ammo_info_mc.infinite_mc.visible = false;
                  this.m_view.ammo_info_mc.ammo_txt_mc.visible = true;
                  this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleX = this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleY = 1;
                  this.m_infiniteAmmoTotal = false;
               }
            }
            if(data.bIsQPistol != this.m_weaponUsesResource)
            {
               if(data.bIsQPistol)
               {
                  flooredResourceAmount = Math.floor(data.nResourceCurrentAmount);
                  switch(data.nResourceType)
                  {
                     case 2:
                        this.m_resourceIcon.gotoAndStop("electric");
                        MenuUtils.setupText(this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.ammo_total_txt,this.addLeadingZero(flooredResourceAmount),38,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorHudResourceElectric);
                        resourceColor = MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL;
                        break;
                     case 3:
                        this.m_resourceIcon.gotoAndStop("chemical");
                        MenuUtils.setupText(this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.ammo_total_txt,this.addLeadingZero(flooredResourceAmount),38,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorHudResourceChemical);
                        resourceColor = MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL;
                  }
                  MenuUtils.setColor(this.m_resourceIcon,resourceColor,true);
                  this.m_view.special_ammo_bar.visible = true;
                  this.m_view.gradient_lines_mc.gotoAndStop("single");
                  this.drawSpecialAmmoBarSegments(data.nResourceMaxAmount,123,90,1.6,resourceColor);
                  specialAmmoDiff = data.nResourceMaxAmount - flooredResourceAmount == 0 ? false : true;
                  i = 0;
                  while(i < data.nResourceMaxAmount)
                  {
                     if(specialAmmoDiff && i >= flooredResourceAmount)
                     {
                        this.m_specialAmmoBarSegments[i].barSegment.visible = false;
                     }
                     i++;
                  }
                  this.m_weaponUsesResource = true;
               }
               else
               {
                  this.m_resourceIcon.gotoAndStop("default");
                  this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.ammo_total_txt.text = "";
                  this.m_view.special_ammo_bar.visible = false;
                  this.m_previousResourceCount = 0;
                  this.m_view.gradient_lines_mc.gotoAndStop("double");
                  this.m_weaponUsesResource = false;
               }
            }
            if(this.m_weaponUsesResource)
            {
               flooredResourceAmount = Math.floor(data.nResourceCurrentAmount);
               if(flooredResourceAmount > 0)
               {
                  if(!this.m_hasGadgetResources)
                  {
                     this.m_view.gadget_resource_icon_container_mc.alpha = 1;
                     this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.alpha = 1;
                     this.m_view.special_ammo_bar.end_pins_mc.alpha = 1;
                     this.m_hasGadgetResources = true;
                  }
                  if(this.m_outOfAmmoInGun)
                  {
                     this.m_view.weapon_container_mc.alpha = 1;
                  }
               }
               else if(this.m_hasGadgetResources)
               {
                  this.m_view.gadget_resource_icon_container_mc.alpha = 0.4;
                  this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.alpha = 0.4;
                  this.m_view.special_ammo_bar.end_pins_mc.alpha = 0.4;
                  if(this.m_outOfAmmoInGun && this.m_outOfAmmoInStash)
                  {
                     this.m_view.weapon_container_mc.alpha = 0.4;
                  }
                  this.m_hasGadgetResources = false;
               }
               if(flooredResourceAmount != this.m_previousResourceCount)
               {
                  this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.ammo_total_txt.text = this.addLeadingZero(flooredResourceAmount);
                  resourcesDecreased = flooredResourceAmount < this.m_previousResourceCount;
                  resourceI = resourcesDecreased ? flooredResourceAmount : this.m_previousResourceCount;
                  resourceLoopEnd = resourcesDecreased ? this.m_previousResourceCount : flooredResourceAmount;
                  resourceVisible = resourcesDecreased ? false : true;
                  while(resourceI < resourceLoopEnd)
                  {
                     if(resourceI < this.m_specialAmmoBarSegments.length)
                     {
                        this.m_specialAmmoBarSegments[resourceI].barSegment.visible = resourceVisible;
                     }
                     resourceI++;
                  }
                  this.m_previousResourceCount = flooredResourceAmount;
               }
               if(data.dischargeSpecialFirearmPromptData.controllerType != this.m_ESPPromptControllerType)
               {
                  if(this.m_ESPPromptInstantiated)
                  {
                     this.removeESPPrompt();
                  }
                  this.m_ESPPromptControllerType = data.dischargeSpecialFirearmPromptData.controllerType;
               }
               else if(this.m_ESPPromptInstantiated)
               {
                  if(!this.m_ESPPrompt.doesInputDataMatch(data.dischargeSpecialFirearmPromptData.aElements))
                  {
                     this.removeESPPrompt();
                  }
               }
               if(!this.m_ESPPromptInstantiated)
               {
                  this.m_ESPPrompt = new ButtonPromptWidget();
                  this.m_view.super_special_prompt_container_mc.addChild(this.m_ESPPrompt);
                  this.m_ESPPromptInstantiated = true;
               }
               if(this.m_ESPPromptInstantiated)
               {
                  if(data.bIsAiming != this.m_isPlayerAiming)
                  {
                     this.m_isPlayerAiming = data.bIsAiming;
                     this.updateESPPrompt(data);
                  }
                  if(data.specialFirearmPromptData.aElements[0].iconId != this.m_ESPPromptIconId)
                  {
                     this.m_ESPPromptPositionSet = false;
                     this.updateESPPrompt(data);
                     this.m_ESPPromptIconId = data.specialFirearmPromptData.aElements[0].iconId;
                  }
                  if(data.sDischargeSpecialFirearmPromptTitle != this.m_ESPPromptTitle)
                  {
                     this.m_ESPPromptTitle = data.sDischargeSpecialFirearmPromptTitle;
                     this.updateESPPrompt(data);
                  }
                  if(data.dischargeSpecialFirearmPromptData.aElements[0].invertColor != this.m_ESPPromptPressed && this.m_hasGadgetResources)
                  {
                     this.updateESPPrompt(data);
                     this.m_ESPPromptPressed = data.dischargeSpecialFirearmPromptData.aElements[0].invertColor;
                  }
                  if(!this.m_hasGadgetResources)
                  {
                     data.dischargeSpecialFirearmPromptData.isEnabled = false;
                     this.updateESPPrompt(data);
                     this.m_ESPPromptIsEnabled = false;
                  }
                  else if(data.dischargeSpecialFirearmPromptData.isEnabled != this.m_ESPPromptIsEnabled)
                  {
                     this.updateESPPrompt(data);
                     this.m_ESPPromptIsEnabled = data.dischargeSpecialFirearmPromptData.isEnabled;
                  }
               }
            }
         }
         else if(this.m_currentWeapon != "")
         {
            Animate.kill(this.m_reloadDelaySprite);
            Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc);
            this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleX = this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.scaleY = 1;
            this.runReloadDots(false);
            this.m_currentWeapon = "";
            this.removeWeapon();
         }
         this.m_view.secondary_container_mc.scaleX = this.m_view.secondary_container_mc.scaleY = 0.5 * this.ICON_SCALE_FACTOR;
         updatedSecondary = false;
         if(this.m_currentWeaponSecondary != data.sIconSecondaryResource)
         {
            this.removeImage(this.m_imageLoaderSecondary,this.m_view.secondary_container_mc);
            if(data.sIconSecondaryResource != "")
            {
               this.loadWeaponImage(data.sIconSecondaryResource,this.m_imageLoaderSecondary,this.m_view.secondary_container_mc);
               this.m_view.prompt_container_mc.visible = true;
               if(this.m_currentWeaponSecondary != "")
               {
                  updatedSecondary = true;
               }
            }
            else
            {
               this.m_view.prompt_container_mc.visible = false;
            }
            this.m_currentWeaponSecondary = data.sIconSecondaryResource;
         }
         this.m_view.special_container_mc.scaleX = this.m_view.special_container_mc.scaleY = 0.5 * this.ICON_SCALE_FACTOR;
         updatedSpecial = false;
         if(this.m_currentWeaponSpecial != data.sIconTertiaryResource)
         {
            this.removeImage(this.m_imageLoaderTertiary,this.m_view.special_container_mc);
            if(data.sIconTertiaryResource != "")
            {
               this.loadWeaponImage(data.sIconTertiaryResource,this.m_imageLoaderTertiary,this.m_view.special_container_mc);
               this.m_view.special_prompt_container_mc.visible = true;
               if(this.m_currentWeaponSpecial != "")
               {
                  updatedSpecial = true;
               }
            }
            else
            {
               this.m_view.special_prompt_container_mc.visible = false;
            }
            this.m_currentWeaponSpecial = data.sIconTertiaryResource;
         }
         if(this.m_currentWeaponSecondary != "" && this.m_currentWeaponSpecial != "")
         {
            this.m_view.secondary_container_mc.y = this.PROMPT_TOP_YPOS;
            this.m_view.special_container_mc.y = this.PROMPT_BOTTOM_YPOS;
            this.m_view.special_prompt_container_mc.y = this.PROMPT_BOTTOM_YPOS;
            if(!updatedSecondary)
            {
               this.m_view.prompt_container_mc.y = this.PROMPT_TOP_YPOS;
            }
         }
         else if(this.m_currentWeaponSecondary != "" && this.m_currentWeaponSpecial == "")
         {
            this.m_view.secondary_container_mc.y = this.PROMPT_TOP_YPOS;
            if(!updatedSecondary)
            {
               this.m_view.prompt_container_mc.y = this.PROMPT_TOP_YPOS;
            }
         }
         else if(this.m_currentWeaponSecondary == "" && this.m_currentWeaponSpecial != "")
         {
            this.m_view.special_container_mc.y = this.PROMPT_TOP_YPOS;
            this.m_view.special_prompt_container_mc.y = this.PROMPT_TOP_YPOS;
         }
      }
      
      private function loadWeaponImage(param1:String, param2:ImageLoader, param3:MovieClip) : void
      {
         var imagePath:String = param1;
         var imgLoader:ImageLoader = param2;
         var imgHolder:MovieClip = param3;
         while(imgHolder.numChildren > 0)
         {
            imgHolder.removeChildAt(0);
         }
         imgLoader = new ImageLoader();
         imgHolder.addChild(imgLoader);
         imgLoader.visible = false;
         imgLoader.loadImage(imagePath,function():void
         {
            onSuccessImage(imgLoader);
         },this.onFailedImage);
      }
      
      private function removeImage(param1:ImageLoader, param2:MovieClip) : void
      {
         if(param1 != null)
         {
            param1.cancelAndClearImage();
            param1 = null;
         }
         while(param2.numChildren > 0)
         {
            param2.removeChildAt(0);
         }
      }
      
      private function onSuccessImage(param1:ImageLoader) : void
      {
         param1.x = -param1.width + this.ICON_X_TRANSLATE;
         param1.y = -param1.height / 2;
         param1.visible = true;
      }
      
      private function onFailedImage() : void
      {
      }
      
      private function removeWeapon() : void
      {
         this.runReloadDots(false);
         Animate.kill(this.m_reloadDelaySprite);
         Animate.kill(this.m_view.weapon_container_mc);
         Animate.kill(this.m_view.ammo_info_mc);
         Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc);
         Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_total_mc.ammo_total_txt);
         Animate.kill(this.m_view.ammo_info_mc.ammo_txt_mc.ammo_pop_mc);
         this.removeImage(this.m_imageLoaderPrimary,this.m_view.weapon_container_mc);
         while(this.m_view.ammo_bar.ammo_container_mc.numChildren > 0)
         {
            this.m_view.ammo_bar.ammo_container_mc.removeChildAt(0);
         }
         while(this.m_view.special_ammo_bar.ammo_container_mc.numChildren > 0)
         {
            this.m_view.special_ammo_bar.ammo_container_mc.removeChildAt(0);
         }
         this.m_ammoBarSegments = [];
         this.m_specialAmmoBarSegments = [];
         this.m_ammoBarIndents = [];
         this.m_specialAmmoBarIndents = [];
         this.m_ammoBarReloadIndents = [];
         this.m_resourceIcon.gotoAndStop("default");
         this.m_view.ammo_info_mc.ammo_txt_mc.resource_mc.ammo_total_txt.text = "";
         this.m_ammoIcon.gotoAndStop("default");
         this.m_view.ammo_bar.visible = false;
         this.m_view.special_ammo_bar.visible = false;
         this.m_view.gradient_lines_mc.visible = false;
         this.m_view.gradient_lines_mc.gotoAndStop("double");
         this.m_view.ammo_info_mc.visible = false;
         this.m_weaponUsesResource = false;
         this.m_registeredAmmoTotal = 0;
         this.m_ammoArrayActiveBulletEnd = 0;
         this.m_previousResourceCount = 0;
         if(this.m_ESPPromptInstantiated)
         {
            this.removeESPPrompt();
         }
      }
      
      private function reload(param1:int, param2:Number) : void
      {
         var reloadNumAmmo:int = param1;
         var fReloadDuration:Number = param2;
         Animate.kill(this.m_reloadDelaySprite);
         Animate.delay(this.m_reloadDelaySprite,fReloadDuration + 0.1,function():void
         {
            TaskletSequencer.getGlobalInstance().addChunk(function():void
            {
               m_ammoArrayActiveBulletEnd = reloadNumAmmo;
            });
         });
      }
      
      private function showReloadTimer(param1:Number) : void
      {
         this.runReloadDots(true,param1 / this.m_ammoBarReloadIndents.length);
      }
      
      private function runReloadDots(param1:Boolean, param2:Number = 0, param3:int = 0) : void
      {
         var i:int = 0;
         var show:Boolean = param1;
         var speed:Number = param2;
         var index:int = param3;
         Animate.kill(this.m_reloadBarDelaySprite);
         if(show)
         {
            Animate.delay(this.m_reloadBarDelaySprite,speed,function():void
            {
               TaskletSequencer.getGlobalInstance().addChunk(function():void
               {
                  m_ammoBarReloadIndents[index].reloadBarIndent.visible = true;
                  index += 1;
                  runReloadDots(true,speed,index);
               });
            });
         }
         else
         {
            i = 0;
            while(i < this.m_ammoBarReloadIndents.length)
            {
               this.m_ammoBarReloadIndents[i].reloadBarIndent.visible = false;
               index = 0;
               i++;
            }
         }
      }
      
      private function interruptReload() : void
      {
         this.runReloadDots(false);
         Animate.kill(this.m_reloadDelaySprite);
      }
      
      private function drawSpecialAmmoBarSegments(param1:int, param2:Number, param3:Number, param4:Number, param5:int) : void
      {
         var _loc9_:* = undefined;
         var _loc10_:Sprite = null;
         this.m_specialAmmoBarIndents = [];
         var _loc6_:Sprite = new Sprite();
         this.m_view.special_ammo_bar.ammo_container_mc.addChild(_loc6_);
         this.m_specialAmmoBarSegments = [];
         var _loc7_:Sprite = new Sprite();
         this.m_view.special_ammo_bar.ammo_container_mc.addChild(_loc7_);
         this.m_view.special_ammo_bar.ammo_container_mc.rotation = param3 / -2;
         var _loc8_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < param1 + 1)
         {
            if(_loc8_ == 0 || _loc8_ == param1)
            {
               _loc9_ = new WeaponWidgetSpecialIndentLongPinView();
               _loc9_.alpha = 0.4;
            }
            else
            {
               _loc9_ = new WeaponWidgetSpecialIndentShortPinView();
               _loc9_.alpha = 0.4;
            }
            _loc6_.addChild(_loc9_);
            _loc9_.rotation = param3 / param1 * _loc8_;
            this.m_specialAmmoBarIndents.unshift({"barIndent":_loc9_});
            _loc8_++;
         }
         _loc8_ = 0;
         while(_loc8_ < param1)
         {
            _loc10_ = new Sprite();
            _loc7_.addChild(_loc10_);
            _loc10_.graphics.lineStyle(6,param5,1,false,"normal","none");
            this.drawSingleAmmoBarSegment(_loc10_,param2,param3 - param4 * param1,param1,0,0);
            _loc10_.rotation = param3 / param1 * _loc8_ + param4 / 2;
            this.m_specialAmmoBarSegments.unshift({"barSegment":_loc10_});
            _loc8_++;
         }
      }
      
      private function drawAmmoBarSegments(param1:int, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc9_:* = undefined;
         var _loc10_:* = undefined;
         var _loc11_:Sprite = null;
         this.m_ammoBarIndents = [];
         var _loc5_:Sprite = new Sprite();
         this.m_view.ammo_bar.ammo_container_mc.addChild(_loc5_);
         this.m_ammoBarReloadIndents = [];
         var _loc6_:Sprite = new Sprite();
         this.m_view.ammo_bar.ammo_container_mc.addChild(_loc6_);
         this.m_ammoBarSegments = [];
         var _loc7_:Sprite = new Sprite();
         this.m_view.ammo_bar.ammo_container_mc.addChild(_loc7_);
         this.m_view.ammo_bar.ammo_container_mc.rotation = param3 / -2;
         var _loc8_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < param1 + 1)
         {
            if(_loc8_ == 0 || _loc8_ == param1)
            {
               _loc9_ = new WeaponWidgetIndentLongPinView();
               _loc9_.alpha = 0.4;
            }
            else if(_loc8_ == 10 || _loc8_ == 20)
            {
               _loc9_ = new WeaponWidgetIndentLongPinView();
               _loc9_.alpha = 0.4;
            }
            else
            {
               _loc9_ = new WeaponWidgetIndentShortPinView();
               _loc9_.alpha = 0.4;
            }
            _loc5_.addChild(_loc9_);
            _loc9_.rotation = param3 / param1 * _loc8_;
            this.m_ammoBarIndents.unshift({"barIndent":_loc9_});
            _loc8_++;
         }
         _loc8_ = 0;
         while(_loc8_ < param1 + 1)
         {
            _loc10_ = new WeaponWidgetIndentLongPinView();
            _loc10_.visible = false;
            _loc6_.addChild(_loc10_);
            _loc10_.rotation = param3 / param1 * _loc8_;
            this.m_ammoBarReloadIndents.unshift({"reloadBarIndent":_loc10_});
            _loc8_++;
         }
         _loc8_ = 0;
         while(_loc8_ < param1)
         {
            _loc11_ = new Sprite();
            _loc7_.addChild(_loc11_);
            _loc11_.graphics.lineStyle(6,MenuConstantsKnt.COLOR_WHITE_KNT,1,false,"normal","none");
            this.drawSingleAmmoBarSegment(_loc11_,param2,param3 - param4 * param1,param1,0,0);
            _loc11_.rotation = param3 / param1 * _loc8_ + param4 / 2;
            this.m_ammoBarSegments.unshift({"barSegment":_loc11_});
            _loc8_++;
         }
      }
      
      private function drawSingleAmmoBarSegment(param1:Sprite, param2:Number, param3:Number, param4:int, param5:Number, param6:Number) : void
      {
         var _loc7_:Number = param3 / param4 * (Math.PI / 180);
         var _loc8_:Number = param2 / Math.cos(_loc7_ / 2);
         param3 = 0;
         var _loc9_:Number = 0;
         var _loc10_:Number = 0;
         var _loc11_:Number = 0;
         var _loc12_:Number = 0;
         param1.graphics.moveTo(param5 + param2,param6);
         param3 += _loc7_;
         _loc9_ = param5 + Math.cos(param3 - _loc7_ / 2) * _loc8_;
         _loc10_ = param6 + Math.sin(param3 - _loc7_ / 2) * _loc8_;
         _loc11_ = param5 + Math.cos(param3) * param2;
         _loc12_ = param6 + Math.sin(param3) * param2;
         param1.graphics.curveTo(_loc9_,_loc10_,_loc11_,_loc12_);
      }
      
      private function addLeadingZero(param1:Number) : String
      {
         return param1 < 10 ? "0" + param1 : param1.toString();
      }
      
      private function setPromptImage(param1:*, param2:Object) : void
      {
         while(param1.numChildren > 0)
         {
            param1.removeChildAt(0);
         }
         var _loc3_:ButtonPromptImage = new ButtonPromptImage();
         _loc3_.platform = param2.controllerType;
         _loc3_.scaleX = _loc3_.scaleY = _loc3_.platform == "key" ? 0.4 : 0.6;
         if((_loc3_.platform == "key" || param2.aElements[0].iconId == -1) && param2.aElements[0].keyGlyph != "")
         {
            _loc3_.customKey = param2.aElements[0].keyGlyph;
         }
         else
         {
            _loc3_.button = param2.aElements[0].iconId;
         }
         param1.addChild(_loc3_);
      }
      
      private function updateESPPrompt(param1:Object) : void
      {
         if(!param1.dischargeSpecialFirearmPromptData)
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(this.m_isPlayerAiming)
         {
            _loc2_ = Boolean(param1.dischargeSpecialFirearmPromptData.isEnabled);
         }
         else
         {
            param1.dischargeSpecialFirearmPromptData.aElements[0].invertColor = false;
            _loc2_ = false;
         }
         var _loc3_:Object = new Object();
         _loc3_.aElements = param1.dischargeSpecialFirearmPromptData.aElements;
         _loc3_.controllerType = param1.dischargeSpecialFirearmPromptData.controllerType;
         _loc3_.isEnabled = _loc2_;
         _loc3_.multiPromptSpacing = 0;
         _loc3_.multiPromptSpacingIcon = "";
         _loc3_.sTitle = param1.sDischargeSpecialFirearmPromptTitle;
         _loc3_.sStatus = "";
         _loc3_.sPromptType = "press";
         _loc3_.bCurrentlyActive = false;
         _loc3_.fProgress = 0;
         _loc3_.bBlocked = param1.m_blockedLabel != "" ? true : false;
         _loc3_.bIsAgencyPrompt = true;
         _loc3_.bIsSwap = false;
         _loc3_.bIsPickpocketing = false;
         _loc3_.bIsLegal = true;
         _loc3_.bIsTrespassing = true;
         _loc3_.eState = 0;
         _loc3_.fBluffProbability = 0;
         _loc3_.eAgilityType = 0;
         _loc3_.eResourceType = -1;
         this.m_ESPPrompt.onSetData(_loc3_);
         if(!this.m_ESPPromptPositionSet)
         {
            this.m_ESPPrompt.x = 14 - this.m_ESPPrompt.getPromptWidth();
            this.m_ESPPromptPositionSet = true;
         }
      }
      
      private function removeESPPrompt() : void
      {
         while(this.m_view.super_special_prompt_container_mc.numChildren > 0)
         {
            this.m_view.super_special_prompt_container_mc.removeChildAt(0);
         }
         this.m_ESPPrompt = null;
         this.m_ESPPromptIsEnabled = false;
         this.m_ESPPromptPressed = false;
         this.m_ESPPromptInstantiated = false;
         this.m_ESPPromptControllerType = "";
         this.m_ESPPromptIconId = -9;
         this.m_ESPPromptPositionSet = false;
      }
   }
}

