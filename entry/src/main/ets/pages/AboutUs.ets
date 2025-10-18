import router from '@ohos.router';

@Entry
@Component
struct AboutUs {
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
        
        Text('关于我们')
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
          // App Logo 和名称
          Column() {
            Image($r('app.media.startIcon'))
              .width(100)
              .height(100)
              .borderRadius(20)
              .margin({ bottom: 20 })
            
            Text('简易记账')
              .fontSize(28)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
            
            Text('Version 1.0.0')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 16 })
            
            Text('让记账变得简单而优雅')
              .fontSize(15)
              .fontColor('#666666')
              .fontStyle(FontStyle.Italic)
          }
          .width('100%')
          .padding({ top: 40, bottom: 40 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16, bottom: 16 })

          // 产品介绍卡片
          Column() {
            Row() {
              Text('📱')
                .fontSize(28)
                .margin({ right: 12 })
              
              Text('产品介绍')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            Text('简易记账是一款专注于个人财务管理的应用，帮助您轻松记录每一笔收支，清晰了解资金流向。我们致力于提供简洁、高效、美观的记账体验，让财务管理变得触手可及。')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(24)
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 })

          // 核心功能
          Column() {
            Row() {
              Text('✨')
                .fontSize(28)
                .margin({ right: 12 })
              
              Text('核心功能')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .margin({ bottom: 20 })
            
            // 功能列表
            Column({ space: 16 }) {
              this.FeatureItem('💰', '智能记账', '快速记录收支，支持多种分类和备注')
              this.FeatureItem('📊', '数据统计', '可视化图表，清晰展示财务状况')
              this.FeatureItem('🏦', '资产管理', '管理多个账户，实时查看净资产')
              this.FeatureItem('⏰', '记账提醒', '定时提醒，养成良好记账习惯')
              this.FeatureItem('🔒', '数据安全', '本地存储，保护您的隐私安全')
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 })

          // 团队信息
          Column() {
            Row() {
              Text('👥')
                .fontSize(28)
                .margin({ right: 12 })
              
              Text('开发团队')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            Text('我们是一支充满热情的开发团队，致力于打造最好用的记账应用。如果您在使用过程中有任何建议或问题，欢迎随时与我们联系。')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(24)
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 })

          // 联系方式
          Column() {
            Row() {
              Text('📮')
                .fontSize(28)
                .margin({ right: 12 })
              
              Text('联系我们')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .margin({ bottom: 20 })
            
            Column({ space: 12 }) {
              this.ContactItem('📧', '邮箱', 'support@simplebookkeeping.com')
              this.ContactItem('🌐', '官网', 'www.simplebookkeeping.com')
              this.ContactItem('💬', '微信公众号', '简易记账')
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 })

          // 版权信息
          Column() {
            Divider()
              .strokeWidth(1)
              .color('#F0F0F0')
              .margin({ bottom: 16 })
            
            Text('© 2024 简易记账')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ bottom: 4 })
            
            Text('All Rights Reserved')
              .fontSize(12)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#E3ECFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E3ECFF')
  }

  // 功能项组件
  @Builder
  FeatureItem(icon: string, title: string, description: string) {
    Row() {
      Text(icon)
        .fontSize(32)
        .width(48)
        .height(48)
        .textAlign(TextAlign.Center)
        .borderRadius(12)
        .backgroundColor('#F5F7FF')
        .margin({ right: 16 })
      
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 })
        
        Text(description)
          .fontSize(13)
          .fontColor('#999999')
          .lineHeight(20)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  // 联系项组件
  @Builder
  ContactItem(icon: string, label: string, value: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .width(36)
        .margin({ right: 12 })
      
      Column() {
        Text(label)
          .fontSize(13)
          .fontColor('#999999')
          .margin({ bottom: 4 })
        
        Text(value)
          .fontSize(15)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }
}

