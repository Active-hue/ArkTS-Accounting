import router from '@ohos.router';

// 资产类型接口
interface AssetType {
  name: string;
  iconColor: string;
  iconText: string;
}

@Entry
@Component
struct SelectAssetType {
  @State showAssetAccount: boolean = true; // 资金账户是否展开
  @State showCreditAccount: boolean = true; // 信用账户是否展开
  
  // 资金账户列表
  private assetTypes: AssetType[] = [
    { name: '现金钱包', iconColor: '#FFB800', iconText: '现' },
    { name: '储蓄卡', iconColor: '#FFB800', iconText: '储' },
    { name: '支付宝', iconColor: '#1677FF', iconText: '支' },
    { name: '余额宝', iconColor: '#FF6B35', iconText: '余' },
    { name: '余利宝', iconColor: '#1890FF', iconText: '余' },
    { name: '小荷包', iconColor: '#FF8C42', iconText: '小' },
    { name: '微信钱包', iconColor: '#07C160', iconText: '微' },
    { name: '微信零钱通', iconColor: '#FFD700', iconText: '微' },
    { name: '腾讯理财通', iconColor: '#1677FF', iconText: '腾' },
    { name: 'QQ钱包', iconColor: '#000000', iconText: 'QQ' },
    { name: '抖音钱包', iconColor: '#000000', iconText: '抖' },
    { name: '多多钱包', iconColor: '#E02E24', iconText: '多' },
    { name: '美团钱包', iconColor: '#FFB800', iconText: '美' }
  ];
  
  // 信用账户列表
  private creditTypes: AssetType[] = [
    { name: '信用卡', iconColor: '#FFB800', iconText: '信' },
    { name: '贷款', iconColor: '#FFB800', iconText: '贷' },
    { name: '蚂蚁花呗', iconColor: '#1890FF', iconText: '花' },
    { name: '京东白条', iconColor: '#E02E24', iconText: '白' },
    { name: '京东金条', iconColor: '#D4AF37', iconText: '金' },
    { name: '借呗', iconColor: '#1890FF', iconText: '借' },
    { name: '微粒贷', iconColor: '#5B7FFF', iconText: '微' },
    { name: '美团借钱', iconColor: '#FFB800', iconText: '美' },
    { name: '美团月付', iconColor: '#FFB800', iconText: '美' },
    { name: '抖音放心借', iconColor: '#1890FF', iconText: '抖' },
    { name: '抖音月付', iconColor: '#00CED1', iconText: '抖' },
    { name: '微信分付', iconColor: '#52C41A', iconText: '微' },
    { name: '备用金', iconColor: '#1677FF', iconText: '备' }
  ];

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
          
          Text('资产')
            .fontSize(16)
            .fontColor('#5B7FFF')
            .margin({ left: 4 })
        }
        .width(80)
        
        Text('选择类型')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 右侧占位，保持标题居中
        Row()
          .width(80)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 内容区域
      Scroll() {
        Column() {
          // 资金账户分组
          Row() {
            Text('资金账户')
              .fontSize(14)
              .fontColor('#999999')
            
            Blank()
            
            Text(this.showAssetAccount ? '∨' : '>')
              .fontSize(14)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 12 })
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            this.showAssetAccount = !this.showAssetAccount;
          })
          
          // 资金账户列表
          if (this.showAssetAccount) {
            Column() {
              ForEach(this.assetTypes, (item: AssetType, index: number) => {
                Column() {
                  Row() {
                    // 左侧图标
                    Stack() {
                      Circle()
                        .width(40)
                        .height(40)
                        .fill(item.iconColor)
                      
                      Text(item.iconText)
                        .fontSize(16)
                        .fontColor('#FFFFFF')
                        .fontWeight(FontWeight.Bold)
                    }
                    .margin({ right: 12 })
                    
                    // 名称
                    Text(item.name)
                      .fontSize(16)
                      .fontColor('#333333')
                      .layoutWeight(1)
                    
                    // 右侧箭头
                    Text('›')
                      .fontSize(24)
                      .fontColor('#CCCCCC')
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/AddAccount',
                      params: {
                        name: item.name,
                        iconText: item.iconText,
                        iconColor: item.iconColor,
                        isCredit: 'false'
                      }
                    });
                  })
                  
                  // 分隔线（不是最后一项时显示）
                  if (index < this.assetTypes.length - 1) {
                    Divider()
                      .strokeWidth(1)
                      .color('#F0F0F0')
                      .margin({ left: 68 })
                  }
                }
              }, (item: AssetType) => item.name)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ top: 8, left: 16, right: 16 })
          }
          
          // 信用账户分组
          Row() {
            Text('信用账户')
              .fontSize(14)
              .fontColor('#999999')
            
            Blank()
            
            Text(this.showCreditAccount ? '∨' : '>')
              .fontSize(14)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 12 })
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            this.showCreditAccount = !this.showCreditAccount;
          })
          
          // 信用账户列表
          if (this.showCreditAccount) {
            Column() {
              ForEach(this.creditTypes, (item: AssetType, index: number) => {
                Column() {
                  Row() {
                    // 左侧图标
                    Stack() {
                      Circle()
                        .width(40)
                        .height(40)
                        .fill(item.iconColor)
                      
                      Text(item.iconText)
                        .fontSize(16)
                        .fontColor('#FFFFFF')
                        .fontWeight(FontWeight.Bold)
                    }
                    .margin({ right: 12 })
                    
                    // 名称
                    Text(item.name)
                      .fontSize(16)
                      .fontColor('#333333')
                      .layoutWeight(1)
                    
                    // 右侧箭头
                    Text('›')
                      .fontSize(24)
                      .fontColor('#CCCCCC')
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/AddAccount',
                      params: {
                        name: item.name,
                        iconText: item.iconText,
                        iconColor: item.iconColor,
                        isCredit: 'true'
                      }
                    });
                  })
                  
                  // 分隔线（不是最后一项时显示）
                  if (index < this.creditTypes.length - 1) {
                    Divider()
                      .strokeWidth(1)
                      .color('#F0F0F0')
                      .margin({ left: 68 })
                  }
                }
              }, (item: AssetType) => item.name)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ top: 8, left: 16, right: 16, bottom: 16 })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Auto)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

