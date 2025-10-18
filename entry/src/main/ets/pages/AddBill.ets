import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { BillItem, BillDataManager } from '../common/BillData';

// 定义分类接口
interface Category {
  name: string;
  icon: string;
}

@Entry
@Component
struct AddBill {
  @State billType: number = 0; // 0: 支出, 1: 收入
  @State amount: string = '';
  @State selectedCategory: string = '';
  @State remark: string = '';
  @State selectedDate: string = this.getTodayDate();
  @State paymentMethod: string = '微信支付';
  @State showKeyboard: boolean = false; // 是否显示数字键盘
  
  // 获取今天的日期（格式：10/16 星期四）
  getTodayDate(): string {
    const today = new Date();
    const month = today.getMonth() + 1;
    const day = today.getDate();
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const weekDay = weekDays[today.getDay()];
    return `${month}/${day} ${weekDay}`;
  }
  
  // 分类数据（图标+文字）
  private expenseCategories: Category[] = [
    {name: '餐饮', icon: '1'},
    {name: '交通', icon: '2'},
    {name: '服饰', icon: '3'},
    {name: '住宿', icon: '4'},
    {name: '购物', icon: '5'},
    {name: '水果', icon: '6'},
    {name: '娱乐', icon: '7'},
    {name: '医疗', icon: '8'},
    {name: '运动', icon: '9'},
    {name: '美容', icon: '10'}
  ];
  
  private incomeCategories: Category[] = [
    {name: '工资', icon: '11'},
    {name: '兼职', icon: '12'},
    {name: '理财', icon: '13'},
    {name: '礼金', icon: '14'},
    {name: '其他', icon: '15'},
    {name: '奖金', icon: '16'},
    {name: '股票', icon: '17'},
    {name: '租金', icon: '18'},
    {name: '报销', icon: '19'},
    {name: '红包', icon: '20'}
  ];

  build() {
    Column() {
      // 顶部类型切换栏
      Row() {
        Blank()
        
        Row() {
          Text('支出')
            .fontSize(16)
            .fontColor(this.billType === 0 ? '#333333' : '#999999')
            .fontWeight(this.billType === 0 ? FontWeight.Bold : FontWeight.Normal)
            .padding({ bottom: 8 })
            .border({
              width: { bottom: this.billType === 0 ? 2 : 0 },
              color: '#5B7FFF'
            })
            .onClick(() => {
              this.billType = 0;
              this.selectedCategory = '';
            })
          
          Text('收入')
            .fontSize(16)
            .fontColor(this.billType === 1 ? '#333333' : '#999999')
            .fontWeight(this.billType === 1 ? FontWeight.Bold : FontWeight.Normal)
            .padding({ bottom: 8 })
            .margin({ left: 24 })
            .border({
              width: { bottom: this.billType === 1 ? 2 : 0 },
              color: '#5B7FFF'
            })
            .onClick(() => {
              this.billType = 1;
              this.selectedCategory = '';
            })
        }
        
        Blank()
        
        Text('✕')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      // 分类图标网格模块
      Column() {
        Grid() {
          ForEach(this.billType === 0 ? this.expenseCategories : this.incomeCategories,
            (category: Category) => {
            GridItem() {
              Column() {
                Image($r(`app.media.category_${category.icon}`))
                  .width(28)
                  .height(28)
                  .fillColor(this.selectedCategory === category.name ? '#5B7FFF' : '#666666')
                  .margin({ bottom: 4 })
                Text(category.name)
                  .fontSize(11)
                  .fontColor(this.selectedCategory === category.name ? '#5B7FFF' : '#666666')
              }
              .width('100%')
              .padding(8)
              .backgroundColor(this.selectedCategory === category.name ? '#F0F4FF' : 'transparent')
              .borderRadius(8)
              .onClick(() => {
                this.selectedCategory = category.name;
                this.showKeyboard = true; // 点击分类后显示键盘
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(6)
        .width('100%')
        .height(170)
        .padding({ left: 16, right: 16, top: 16, bottom: 20 })
      }
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .border({ width: 1, color: '#E5E5E5' })
      .margin({ top: 16, bottom: 12 })

      // 备注输入模块
      Column() {
        Row() {
          Text('备注')
            .fontSize(13)
            .fontColor('#999999')
          
          TextInput({ placeholder: '添加备注吧~', text: this.remark })
            .fontSize(13)
            .backgroundColor('transparent')
            .layoutWeight(1)
            .margin({ left: 12 })
            .onChange((value: string) => {
              this.remark = value;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        
        Divider()
        
        // 快捷标签
        Row() {
          Text('📷')
            .fontSize(16)
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
          
          Text('早餐')
            .fontSize(11)
            .fontColor('#666666')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .margin({ left: 8 })
            .onClick(() => {
              this.remark = '早餐';
            })
          
          Text('午餐')
            .fontSize(11)
            .fontColor('#666666')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .margin({ left: 8 })
            .onClick(() => {
              this.remark = '午餐';
            })
          
          Text('办公')
            .fontSize(11)
            .fontColor('#666666')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .margin({ left: 8 })
            .onClick(() => {
              this.remark = '办公';
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 12 })
      }
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .border({ width: 1, color: '#E5E5E5' })
      .alignItems(HorizontalAlign.Start)

      Blank()
      
      // 金额输入和数字键盘区域（只有选择分类后才显示）
      if (this.showKeyboard) {
        this.KeyboardArea();
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E3ECFF')
  }
  
  // 金额输入和数字键盘区域
  @Builder
  KeyboardArea() {
    Column() {
      // 金额显示区域
      Column() {
        Text(this.amount || '0')
          .fontSize(60)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.End)
          .padding({ right: 20, top: 20, bottom: 20 })
      }
      .width('100%')
      .backgroundColor('#F5F5F5')

      // 数字键盘
      Column() {
        // 第一行：7, 8, 9, 今天
        Row() {
          this.NumberButton('7')
          this.NumberButton('8')
          this.NumberButton('9')
          this.NumberButton('今天')
        }
        .width('100%')
        
        // 第二行：4, 5, 6, +
        Row() {
          this.NumberButton('4')
          this.NumberButton('5')
          this.NumberButton('6')
          this.NumberButton('+')
        }
        .width('100%')
        
        // 第三行：1, 2, 3, -
        Row() {
          this.NumberButton('1')
          this.NumberButton('2')
          this.NumberButton('3')
          this.NumberButton('-')
        }
        .width('100%')
        
        // 第四行：., 0, 删除, 完成
        Row() {
          this.NumberButton('.')
          this.NumberButton('0')
          this.DeleteButton()
          Column() {
            Text('完成')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .width('25%')
          .height(55)
          .backgroundColor('#5B7FFF')
          .justifyContent(FlexAlign.Center)
          .border({ width: { top: 1 }, color: '#D0D0D0' })
          .onClick(() => {
            this.saveBill();
          })
        }
        .width('100%')
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
  }
  
  // 数字按钮组件
  @Builder
  NumberButton(text: string) {
    Column() {
      Text(text)
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
    }
    .width('25%')
    .height(55)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .border({ width: { top: 1, right: 1 }, color: '#D0D0D0' })
    .onClick(() => {
      if (text === '今天') {
        // 设置今天的日期
        this.selectedDate = this.getTodayDate();
      } else if (text === '+' || text === '-') {
        // 加减功能待实现
      } else {
        this.amount += text;
      }
    })
  }
  
  // 删除按钮组件
  @Builder
  DeleteButton() {
    Column() {
      Text('⌫')
        .fontSize(24)
        .fontColor('#333333')
    }
    .width('25%')
    .height(55)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .border({ width: { top: 1 }, color: '#D0D0D0' })
    .onClick(() => {
      if (this.amount.length > 0) {
        this.amount = this.amount.substring(0, this.amount.length - 1);
      }
    })
  }

  // 保存账单
  async saveBill() {
    if (!this.amount || parseFloat(this.amount) <= 0) {
      promptAction.showToast({
        message: '请输入有效金额',
        duration: 2000
      });
      return;
    }

    if (!this.selectedCategory) {
      promptAction.showToast({
        message: '请选择分类',
        duration: 2000
      });
      return;
    }

    // 查找选中分类的图标编号
    const categories = this.billType === 0 ? this.expenseCategories : this.incomeCategories;
    const selectedCat = categories.find(cat => cat.name === this.selectedCategory);
    
    // 创建账单对象
    // 将日期转换为 YYYY-MM-DD 格式
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;
    
    const bill: BillItem = {
      id: Date.now().toString(),
      type: this.billType,
      amount: this.amount,
      category: this.selectedCategory,
      categoryIcon: selectedCat?.icon || '1',
      remark: this.remark,
      date: dateStr,  // 使用标准日期格式 YYYY-MM-DD
      time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
    };

    console.info('准备保存账单:', JSON.stringify(bill));
    
    // 保存账单
    await BillDataManager.saveBill(bill);
    
    console.info('账单保存完成');
    
    promptAction.showToast({
      message: '保存成功',
      duration: 2000
    });

    // 返回主页面
    setTimeout(() => {
      console.info('返回主页面');
      router.back();
    }, 500);
  }
}

