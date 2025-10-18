import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ReminderSetting {
  @State reminderEnabled: boolean = true; // 提醒是否启用
  @State reminderHour: number = 9; // 提醒小时
  @State reminderMinute: number = 3; // 提醒分钟
  @State showTimePicker: boolean = false; // 是否显示时间选择器
  @State showDeleteDialog: boolean = false; // 是否显示删除确认对话框
  
  // 生成小时列表 0-23
  private hourList: number[] = this.generateHourList();
  // 生成分钟列表 0-59
  private minuteList: number[] = this.generateMinuteList();
  
  // 生成小时列表方法
  generateHourList(): number[] {
    const hours: number[] = [];
    for (let i = 0; i < 24; i++) {
      hours.push(i);
    }
    return hours;
  }
  
  // 生成分钟列表方法
  generateMinuteList(): number[] {
    const minutes: number[] = [];
    for (let i = 0; i < 60; i++) {
      minutes.push(i);
    }
    return minutes;
  }
  
  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Text('‹')
            .fontSize(32)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .width(40)
            .onClick(() => {
              router.back();
            })
          
          Text('记账提醒')
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 40 }) // 平衡左侧返回按钮
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        
        // 提醒时间设置项
        Column() {
          Row() {
            // 左侧图标和文字
            Row() {
              // 红色圆形图标（可点击删除）
              Stack() {
                Circle()
                  .width(24)
                  .height(24)
                  .fill('#FF6B6B')
                
                Text('—')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
              }
              .margin({ right: 12 })
              .onClick(() => {
                this.showDeleteDialog = true; // 显示删除确认对话框
              })
              
              Text('提醒时间')
                .fontSize(16)
                .fontColor('#333333')
            }
            
            Blank()
            
            // 右侧时间显示
            Row() {
              Text(`每天${this.formatTime(this.reminderHour)}:${this.formatTime(this.reminderMinute)}`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ right: 8 })
              
              Text('›')
                .fontSize(24)
                .fontColor('#CCCCCC')
            }
            .onClick(() => {
              this.showTimePicker = true;
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .margin({ top: 12 })
        
        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#E3ECFF')
      
      // 时间选择器弹窗
      if (this.showTimePicker) {
        this.TimePickerDialog();
      }
      
      // 删除确认对话框
      if (this.showDeleteDialog) {
        this.DeleteConfirmDialog();
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 格式化时间（补零）
  formatTime(time: number): string {
    return time < 10 ? `0${time}` : `${time}`;
  }
  
  // 时间选择器弹窗
  @Builder
  TimePickerDialog() {
    Stack() {
      // 半透明背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showTimePicker = false; // 点击遮罩关闭
        })
      
      // 时间选择器内容
      Column() {
        Text('设置提醒时间')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        
        // 小时和分钟选择器
        Row() {
          // 小时选择器
          Column() {
            List() {
              ForEach(this.hourList, (hour: number) => {
                ListItem() {
                  Row() {
                    Text(this.formatTime(hour))
                      .fontSize(this.reminderHour === hour ? 24 : 18)
                      .fontColor(this.reminderHour === hour ? '#5B7FFF' : '#666666')
                      .fontWeight(this.reminderHour === hour ? FontWeight.Bold : FontWeight.Normal)
                  }
                  .width('100%')
                  .height(48)
                  .justifyContent(FlexAlign.End)
                  .padding({ right: 20 })
                }
                .onClick(() => {
                  this.reminderHour = hour;
                })
              }, (hour: number) => hour.toString())
            }
            .width('100%')
            .height(250)
            .scrollBar(BarState.Off)
          }
          .layoutWeight(1)
          
          Text(':')
            .fontSize(28)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8, right: 8 })
          
          // 分钟选择器
          Column() {
            List() {
              ForEach(this.minuteList, (minute: number) => {
                ListItem() {
                  Row() {
                    Text(this.formatTime(minute))
                      .fontSize(this.reminderMinute === minute ? 24 : 18)
                      .fontColor(this.reminderMinute === minute ? '#5B7FFF' : '#666666')
                      .fontWeight(this.reminderMinute === minute ? FontWeight.Bold : FontWeight.Normal)
                  }
                  .width('100%')
                  .height(48)
                  .justifyContent(FlexAlign.Start)
                  .padding({ left: 20 })
                }
                .onClick(() => {
                  this.reminderMinute = minute;
                })
              }, (minute: number) => minute.toString())
            }
            .width('100%')
            .height(250)
            .scrollBar(BarState.Off)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        
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
              this.showTimePicker = false;
            })
          
          // 确定按钮
          Button('确定')
            .width('45%')
            .height(45)
            .backgroundColor('#5B7FFF')
            .fontColor('#FFFFFF')
            .fontSize(16)
            .onClick(() => {
              this.showTimePicker = false;
              promptAction.showToast({
                message: `提醒时间已设置为每天${this.formatTime(this.reminderHour)}:${this.formatTime(this.reminderMinute)}`,
                duration: 2000
              });
            })
        }
        .width('100%')
        .padding({ top: 20 })
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
  
  // 删除确认对话框
  @Builder
  DeleteConfirmDialog() {
    Stack() {
      // 半透明背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showDeleteDialog = false; // 点击遮罩关闭
        })
      
      // 对话框内容
      Column() {
        Text('提示')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 24 })
        
        Text('确认删除这条定时提醒?')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 32 })
        
        // 分隔线
        Divider()
          .strokeWidth(1)
          .color('#F0F0F0')
          .margin({ bottom: 0 })
        
        // 按钮区域
        Row() {
          // 取消按钮
          Text('取消')
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding({ top: 16, bottom: 16 })
            .onClick(() => {
              this.showDeleteDialog = false;
            })
          
          // 竖直分隔线
          Divider()
            .vertical(true)
            .strokeWidth(1)
            .color('#F0F0F0')
            .height(50)
          
          // 确定按钮
          Text('确定')
            .fontSize(16)
            .fontColor('#5B7FFF')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding({ top: 16, bottom: 16 })
            .onClick(() => {
              this.showDeleteDialog = false;
              promptAction.showToast({
                message: '已删除提醒',
                duration: 2000
              });
              // 可以在这里添加实际的删除逻辑
              // 例如：router.back() 返回上一页
            })
        }
        .width('100%')
      }
      .width('75%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding({ bottom: 0 })
    }
    .width('100%')
    .height('100%')
  }
}

