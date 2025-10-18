import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Settings {
  @State notificationEnabled: boolean = true;
  @State biometricEnabled: boolean = false;
  @State autoBackup: boolean = false;
  @State showClearDialog: boolean = false;

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('‹')
          .fontSize(32)
          .fontColor('#5B7FFF')
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            router.back();
          })
        
        Text('设置')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
        
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.08)', offsetY: 2 })

      // 内容区域
      Scroll() {
        Column() {
          // 通用设置
          Column() {
            Text('通用')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 20, top: 12, bottom: 12 })
            
            Column() {
              this.SettingItemWithSwitch('🔔', '消息通知', '开启后可接收记账提醒', this.notificationEnabled, (value: boolean) => {
                this.notificationEnabled = value;
                promptAction.showToast({
                  message: value ? '消息通知已开启' : '消息通知已关闭',
                  duration: 2000
                });
              })
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithSwitch('🔐', '生物识别', '使用指纹或面容解锁', this.biometricEnabled, (value: boolean) => {
                this.biometricEnabled = value;
                promptAction.showToast({
                  message: value ? '生物识别已开启' : '生物识别已关闭',
                  duration: 2000
                });
              })
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithArrow('🌙', '主题设置', '浅色')
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .width('100%')
          .margin({ top: 16 })

          // 数据管理
          Column() {
            Text('数据管理')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 20, top: 12, bottom: 12 })
            
            Column() {
              this.SettingItemWithSwitch('☁️', '自动备份', '每天自动备份数据', this.autoBackup, (value: boolean) => {
                this.autoBackup = value;
                promptAction.showToast({
                  message: value ? '自动备份已开启' : '自动备份已关闭',
                  duration: 2000
                });
              })
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithArrow('📤', '导出数据', '导出为Excel或PDF')
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithArrow('📥', '导入数据', '从文件导入账单数据')
              
              Divider().margin({ left: 68 })
              
              Row() {
                Text('🗑️')
                  .fontSize(24)
                  .margin({ right: 12 })
                
                Column() {
                  Text('清除缓存')
                    .fontSize(16)
                    .fontColor('#333333')
                    .margin({ bottom: 4 })
                  
                  Text('清理临时文件和缓存')
                    .fontSize(13)
                    .fontColor('#999999')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                
                Text('清除')
                  .fontSize(14)
                  .fontColor('#5B7FFF')
                  .onClick(() => {
                    this.showClearDialog = true;
                  })
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .width('100%')
          .margin({ top: 16 })

          // 隐私安全
          Column() {
            Text('隐私安全')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 20, top: 12, bottom: 12 })
            
            Column() {
              this.SettingItemWithArrow('🔒', '隐私政策', '查看隐私政策')
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithArrow('📜', '用户协议', '查看用户协议')
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithArrow('🛡️', '账号安全', '修改密码和安全设置')
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .width('100%')
          .margin({ top: 16 })

          // 其他
          Column() {
            Text('其他')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 20, top: 12, bottom: 12 })
            
            Column() {
              this.SettingItemWithArrow('⭐', '给我们评分', '在应用商店给个好评')
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithArrow('📢', '意见反馈', '告诉我们您的建议')
              
              Divider().margin({ left: 68 })
              
              this.SettingItemWithArrow('📱', '检查更新', 'Version 1.0.0')
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .width('100%')
          .margin({ top: 16, bottom: 20 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#E3ECFF')
      
      // 清除缓存确认对话框
      if (this.showClearDialog) {
        this.ClearCacheDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E3ECFF')
  }

  // 带开关的设置项
  @Builder
  SettingItemWithSwitch(icon: string, title: string, description: string, isOn: boolean, onChange: (value: boolean) => void) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })
      
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
          .margin({ bottom: 4 })
        
        Text(description)
          .fontSize(13)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor('#5B7FFF')
        .onChange((value: boolean) => {
          onChange(value);
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
  }

  // 带箭头的设置项
  @Builder
  SettingItemWithArrow(icon: string, title: string, subtitle: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })
      
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
          .margin({ bottom: 4 })
        
        Text(subtitle)
          .fontSize(13)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Text('›')
        .fontSize(24)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      promptAction.showToast({
        message: '功能开发中...',
        duration: 2000
      });
    })
  }

  // 清除缓存确认对话框
  @Builder
  ClearCacheDialog() {
    Stack() {
      // 半透明背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showClearDialog = false;
        })
      
      // 对话框内容
      Column() {
        Text('清除缓存')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        
        Text('确定要清除缓存吗？\n这将删除所有临时文件和缓存数据。')
          .fontSize(15)
          .fontColor('#666666')
          .lineHeight(24)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 30 })
        
        // 按钮区域
        Row() {
          // 取消按钮
          Button('取消')
            .width('45%')
            .height(45)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .fontSize(16)
            .onClick(() => {
              this.showClearDialog = false;
            })
          
          // 确定按钮
          Button('确定')
            .width('45%')
            .height(45)
            .backgroundColor('#5B7FFF')
            .fontColor('#FFFFFF')
            .fontSize(16)
            .onClick(() => {
              this.showClearDialog = false;
              promptAction.showToast({
                message: '缓存清除成功',
                duration: 2000
              });
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('85%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}

