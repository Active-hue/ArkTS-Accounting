import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { AccountDataManager, AccountItem } from '../common/AccountData';

@Entry
@Component
struct AddAccount {
  @State accountName: string = ''; // 账户名称
  @State accountNote: string = ''; // 账户备注
  @State accountBalance: string = '0'; // 账户余额
  @State accountCurrency: string = '人民币 (CNY)'; // 账户币种
  @State includeInTotal: boolean = true; // 计入总资产
  @State canBeSelected: boolean = true; // 记账时可被选择
  
  // 接收传递过来的参数
  @State selectedType: string = ''; // 选择的账户类型名称
  @State selectedIcon: string = ''; // 选择的账户图标文字
  @State selectedColor: string = ''; // 选择的账户图标颜色
  @State isCredit: boolean = false; // 是否为信用账户

  async aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.selectedType = params['name'] || '';
      this.selectedIcon = params['iconText'] || '';
      this.selectedColor = params['iconColor'] || '#5B7FFF';
      this.isCredit = params['isCredit'] === 'true';
    }
    
    // 初始化数据存储
    await AccountDataManager.init(getContext(this));
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          Text('‹')
            .fontSize(32)
            .fontColor('#5B7FFF')
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              router.back();
            })
          
          Text('选择类型')
            .fontSize(16)
            .fontColor('#5B7FFF')
            .margin({ left: 4 })
            .onClick(() => {
              router.back();
            })
        }
        .width(100)
        
        Text('添加账户')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 保存按钮
        Text('保存')
          .fontSize(16)
          .fontColor('#5B7FFF')
          .width(60)
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.saveAccount();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 内容区域
      Scroll() {
        Column() {
          // 账户类型显示
          Row() {
            Stack() {
              Circle()
                .width(40)
                .height(40)
                .fill(this.selectedColor)
              
              Text(this.selectedIcon)
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
            }
            .margin({ right: 12 })
            
            Text(this.selectedType)
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)
            
            Text('›')
              .fontSize(24)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(60)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 16, bottom: 8 })
          .onClick(() => {
            router.back();
          })
          
          // 账户名称
          Column() {
            Row() {
              Text('账户名称')
                .fontSize(16)
                .fontColor('#333333')
                .width(100)
              
              TextInput({ placeholder: '请输入账户名称' })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(16)
                .textAlign(TextAlign.End)
                .onChange((value: string) => {
                  this.accountName = value;
                })
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            
            Divider()
              .strokeWidth(1)
              .color('#F0F0F0')
            
            // 账户备注
            Row() {
              Text('账户备注')
                .fontSize(16)
                .fontColor('#333333')
                .width(100)
              
              TextInput({ placeholder: '点击填写备注' })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(16)
                .textAlign(TextAlign.End)
                .placeholderColor('#CCCCCC')
                .onChange((value: string) => {
                  this.accountNote = value;
                })
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 8 })
          
          // 账户余额
          Row() {
            Text('账户余额')
              .fontSize(16)
              .fontColor('#333333')
              .width(100)
            
            TextInput({ placeholder: '请输入账户余额' })
              .layoutWeight(1)
              .backgroundColor('transparent')
              .fontSize(16)
              .textAlign(TextAlign.End)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.accountBalance = value;
              })
            
            Text('›')
              .fontSize(24)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 8 })
          
          // 账户币种
          Row() {
            Text('账户币种')
              .fontSize(16)
              .fontColor('#333333')
              .width(100)
            
            Blank()
            
            Text(this.accountCurrency)
              .fontSize(16)
              .fontColor('#999999')
            
            Text('›')
              .fontSize(24)
              .fontColor('#CCCCCC')
              .margin({ left: 8 })
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 8 })
          
          // 计入总资产
          Row() {
            Text('计入总资产')
              .fontSize(16)
              .fontColor('#333333')
            
            Blank()
            
            Toggle({ type: ToggleType.Switch, isOn: this.includeInTotal })
              .selectedColor('#52C41A')
              .onChange((isOn: boolean) => {
                this.includeInTotal = isOn;
              })
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 8 })
          
          // 记账时可被选择
          Row() {
            Text('记账时可被选择')
              .fontSize(16)
              .fontColor('#333333')
            
            Blank()
            
            Toggle({ type: ToggleType.Switch, isOn: this.canBeSelected })
              .selectedColor('#52C41A')
              .onChange((isOn: boolean) => {
                this.canBeSelected = isOn;
              })
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  // Save account
  saveAccount() {
    console.info('=== saveAccount called ===');
    console.info('accountName:', this.accountName);
    
    if (!this.accountName) {
      console.warn('Account name is empty');
      promptAction.showToast({
        message: '请输入账户名称',
        duration: 2000
      });
      return;
    }
    
    console.info('Creating account object...');
    // Create account object
    const account: AccountItem = {
      id: AccountDataManager.generateId(),
      name: this.accountName,
      type: this.selectedType,
      iconText: this.selectedIcon,
      iconColor: this.selectedColor,
      balance: this.accountBalance || '0',
      note: this.accountNote,
      currency: this.accountCurrency,
      includeInTotal: this.includeInTotal,
      canBeSelected: this.canBeSelected,
      isCredit: this.isCredit
    };
    
    console.info('Account object created:', JSON.stringify(account));
    console.info('Saving account...');
    
    // Save account
    AccountDataManager.saveAccount(account).then((success) => {
      console.info('Save result:', success);
      
      if (success) {
        console.info('Account saved successfully!');
        
        // Show toast
        promptAction.showToast({
          message: '保存成功',
          duration: 2000
        });
        
        // Navigate back after a short delay
        setTimeout(() => {
          console.info('Navigating back - first router.back()');
          router.back();
          
          setTimeout(() => {
            console.info('Navigating back - second router.back()');
            router.back();
          }, 100);
        }, 500);
      } else {
        console.error('Failed to save account');
        promptAction.showToast({
          message: '保存失败，请重试',
          duration: 2000
        });
      }
    }).catch((err: Error) => {
      console.error('Error saving account:', err.message);
      promptAction.showToast({
        message: '保存出错',
        duration: 2000
      });
    });
  }
}

