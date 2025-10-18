import router from '@ohos.router';

interface HelpSection {
  title: string;
  icon: string;
  items: HelpItem[];
  expanded: boolean;
}

interface HelpItem {
  question: string;
  answer: string;
}

@Entry
@Component
struct HelpDocument {
  @State helpSections: HelpSection[] = [
    {
      title: '快速开始',
      icon: '🚀',
      expanded: true,
      items: [
        {
          question: '如何添加第一笔账单？',
          answer: '点击底部导航栏中间的 "+" 按钮，选择支出或收入类型，填写金额和分类信息，点击保存即可完成第一笔记账。'
        },
        {
          question: '如何创建资金账户？',
          answer: '进入"资产"页面，点击顶部的 "+" 按钮，选择账户类型（如银行卡、支付宝、微信等），输入账户名称和余额，保存即可。'
        },
        {
          question: '如何查看统计报表？',
          answer: '点击底部导航栏的"统计"标签，即可查看当月的收支统计、分类占比饼图和详细的分类排行榜。'
        }
      ]
    }
  ];

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
        
        Text('帮助文档')
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

      // 帮助内容区域
      Scroll() {
        Column() {
          // 欢迎卡片
          Column() {
            Text('👋')
              .fontSize(48)
              .margin({ bottom: 16 })
            
            Text('欢迎使用简易记账')
              .fontSize(24)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
            
            Text('这里有您需要的所有使用帮助')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ top: 40, bottom: 40 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16, bottom: 16 })

          // 帮助分类列表
          ForEach(this.helpSections, (section: HelpSection, sectionIndex: number) => {
            Column() {
              // 分类标题
              Row() {
                Text(section.icon)
                  .fontSize(24)
                  .margin({ right: 12 })
                
                Text(section.title)
                  .fontSize(18)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                
                Text(section.expanded ? '▼' : '▶')
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              .onClick(() => {
                // 切换展开/收起状态
                this.helpSections[sectionIndex].expanded = !this.helpSections[sectionIndex].expanded;
              })

              // 问答列表
              if (section.expanded) {
                Column() {
                  ForEach(section.items, (item: HelpItem, itemIndex: number) => {
                    Column() {
                      // 问题
                      Row() {
                        Text('Q')
                          .fontSize(16)
                          .fontColor('#FFFFFF')
                          .fontWeight(FontWeight.Bold)
                          .width(28)
                          .height(28)
                          .borderRadius(14)
                          .backgroundColor('#5B7FFF')
                          .textAlign(TextAlign.Center)
                          .margin({ right: 12 })
                        
                        Text(item.question)
                          .fontSize(15)
                          .fontColor('#333333')
                          .fontWeight(FontWeight.Medium)
                          .layoutWeight(1)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Top)
                      .margin({ bottom: 12 })

                      // 答案
                      Row() {
                        Text('A')
                          .fontSize(16)
                          .fontColor('#FFFFFF')
                          .fontWeight(FontWeight.Bold)
                          .width(28)
                          .height(28)
                          .borderRadius(14)
                          .backgroundColor('#52C41A')
                          .textAlign(TextAlign.Center)
                          .margin({ right: 12 })
                        
                        Text(item.answer)
                          .fontSize(14)
                          .fontColor('#666666')
                          .lineHeight(22)
                          .layoutWeight(1)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Top)
                      
                      // 分隔线
                      if (itemIndex < section.items.length - 1) {
                        Divider()
                          .strokeWidth(1)
                          .color('#F0F0F0')
                          .margin({ top: 16, bottom: 16, left: 40 })
                      }
                    }
                    .width('100%')
                    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                  }, (item: HelpItem) => item.question)
                }
                .width('100%')
                .animation({
                  duration: 300,
                  curve: Curve.EaseInOut
                })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: 12 })
          }, (section: HelpSection) => section.title)

          // 底部联系卡片
          Column() {
            Text('💡')
              .fontSize(36)
              .margin({ bottom: 12 })
            
            Text('还有其他问题？')
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 8 })
            
            Text('欢迎通过"关于我们"页面联系我们')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ bottom: 20 })
            
            Button('返回首页')
              .width(200)
              .height(44)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#5B7FFF')
              .borderRadius(22)
              .onClick(() => {
                router.back();
              })
          }
          .width('100%')
          .padding({ top: 30, bottom: 30 })
          .margin({ top: 8, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
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
}

