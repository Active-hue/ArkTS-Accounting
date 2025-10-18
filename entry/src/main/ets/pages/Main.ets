import router from '@ohos.router';
import { BillItem, BillDataManager, BillStats } from '../common/BillData';
import { AccountDataManager, AccountItem } from '../common/AccountData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';

// 日统计数据接口
interface DayStats {
  expense: string;
  income: string;
}

// 日期分组接口
interface DateGroup {
  date: string;
  bills: BillItem[];
}

// 分类统计接口
interface CategoryStats {
  category: string;
  icon: string;
  amount: number;
  percentage: number;
  color: string;
}

// 分类汇总数据接口
interface CategorySum {
  amount: number;
  icon: string;
}

@Entry
@Component
struct Main {
  @State currentTabIndex: number = 0; // 当前选中的标签，0: 账单, 1: 统计, 2: 资产, 3: 我的
  @State billList: BillItem[] = []; // 账单列表
  @State monthExpense: string = '0.00'; // 本月支出
  @State monthIncome: string = '0.00'; // 本月收入
  @State monthBalance: string = '0.00'; // 本月结余（收入-支出）
  @State dateGroups: DateGroup[] = []; // 分组后的账单数据
  @State refreshFlag: number = 0; // 刷新标记
  @State showDatePicker: boolean = false; // 是否显示日期选择器
  @State selectedYear: number = new Date().getFullYear(); // 选中的年份
  @State selectedMonth: number = new Date().getMonth() + 1; // 选中的月份（1-12）
  @State avatarUri: string = ''; // 用户上传的头像URI
  @State totalDays: number = 0; // 记账天数
  @State totalRecords: number = 0; // 记账笔数
  @State showNicknameDialog: boolean = false; // 是否显示昵称修改弹窗
  @State nickname: string = '杂家猫'; // 用户昵称
  @State tempNickname: string = ''; // 临时存储输入的昵称
  @State accountList: AccountItem[] = []; // 账户列表
  @State netAssets: string = '0.00'; // 净资产
  @State totalAssets: string = '0.00'; // 总资产
  @State totalLiabilities: string = '0.00'; // 总负债
  @State accountRefreshFlag: number = 0; // 账户列表刷新标记
  @State categoryStatsList: CategoryStats[] = []; // 分类统计列表（支出）
  @State incomeCategoryStatsList: CategoryStats[] = []; // 分类统计列表（收入）
  @State statisticsTabIndex: number = 0; // 统计页面的 Tab 索引，0: 支出, 1: 收入
  
  // 生成年份列表
  private yearList: number[] = this.generateYearList();
  // 生成月份列表
  private monthList: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  
  // 生成年份列表方法
  generateYearList(): number[] {
    const currentYear = new Date().getFullYear();
    const years: number[] = [];
    for (let i = currentYear - 10; i <= currentYear + 19; i++) {
      years.push(i);
    }
    return years;
  }
  
  async aboutToAppear() {
    await AccountDataManager.init(getContext(this));
    this.loadBillData();
    this.loadAccountData();
  }
  
  onPageShow() {
    // 页面显示时刷新数据
    console.info('Main页面显示，刷新数据');
    this.loadBillData();
    this.loadAccountData();
  }
  
  // 加载账单数据
  async loadBillData() {
    console.info('开始加载账单数据');
    this.billList = await BillDataManager.getAllBills();
    console.info('账单数量:', this.billList.length);
    console.info('账单数据:', JSON.stringify(this.billList));
    
    // 过滤当前选择月份的账单
    const yearMonthStr = `${this.selectedYear}-${this.selectedMonth.toString().padStart(2, '0')}`;
    const currentMonthBills = this.billList.filter(bill => bill.date.startsWith(yearMonthStr));
    console.info('当前月份账单数量:', currentMonthBills.length);
    
    // 计算当前月份的统计数据
    let monthExpense = 0;
    let monthIncome = 0;
    currentMonthBills.forEach(bill => {
      const amount = parseFloat(bill.amount) || 0;
      if (bill.type === 0) {
        monthExpense += amount;
      } else {
        monthIncome += amount;
      }
    });
    
    this.monthExpense = monthExpense.toFixed(2);
    this.monthIncome = monthIncome.toFixed(2);
    
    // 计算结余（收入 - 支出）
    const balance = monthIncome - monthExpense;
    this.monthBalance = balance.toFixed(2);
    
    console.info('本月支出:', this.monthExpense, '本月收入:', this.monthIncome, '本月结余:', this.monthBalance);
    
    // 计算记账天数和记账笔数（只统计当前月份）
    this.totalRecords = currentMonthBills.length; // 记账笔数就是当前月份账单总数
    const uniqueDates = new Set<string>();
    currentMonthBills.forEach(bill => {
      uniqueDates.add(bill.date); // 收集所有不同的日期
    });
    this.totalDays = uniqueDates.size; // 记账天数就是不同日期的数量
    
    console.info('记账天数:', this.totalDays, '记账笔数:', this.totalRecords);
    
    // 更新分组数据（只分组当前月份的账单）
    const grouped = this.groupBillsByDate(currentMonthBills);
    const newGroups: DateGroup[] = [];
    grouped.forEach((bills, date) => {
      newGroups.push({ date: date, bills: [...bills] }); // 创建bills的副本
    });
    this.dateGroups = newGroups;
    this.refreshFlag++; // 增加刷新标记
    console.info('分组数量:', this.dateGroups.length);
    console.info('dateGroups内容:', JSON.stringify(this.dateGroups));
    console.info('刷新标记:', this.refreshFlag);
    
    // Calculate category statistics
    this.calculateCategoryStats();
    this.calculateIncomeCategoryStats();
  }
  
  // 加载账户数据
  async loadAccountData() {
    console.info('开始加载账户数据');
    const accounts = await AccountDataManager.getAllAccounts();
    // Create a new array reference to trigger UI update
    this.accountList = [...accounts];
    console.info('账户数量:', this.accountList.length);
    
    // 计算总资产和总负债
    const assetsSummary = await AccountDataManager.calculateTotalAssets();
    this.totalAssets = assetsSummary.totalAssets.toFixed(2);
    this.totalLiabilities = assetsSummary.totalLiabilities.toFixed(2);
    this.netAssets = (assetsSummary.totalAssets - assetsSummary.totalLiabilities).toFixed(2);
    
    // Increment refresh flag to trigger UI update
    this.accountRefreshFlag++;
    
    console.info('净资产:', this.netAssets, '总资产:', this.totalAssets, '总负债:', this.totalLiabilities);
  }
  
  // 按日期分组账单
  groupBillsByDate(bills: BillItem[]): Map<string, BillItem[]> {
    const grouped = new Map<string, BillItem[]>();
    bills.forEach(bill => {
      console.info(`分组账单 - 日期:${bill.date}, 分类:${bill.category}, 金额:${bill.amount}, 类型:${bill.type}`);
      if (!grouped.has(bill.date)) {
        grouped.set(bill.date, []);
      }
      grouped.get(bill.date)?.push(bill);
    });
    
    // 打印分组结果
    grouped.forEach((bills, date) => {
      console.info(`日期 ${date} 有 ${bills.length} 条账单`);
      bills.forEach(bill => {
        console.info(`  - ${bill.category}: ${bill.amount} (类型:${bill.type})`);
      });
    });
    
    return grouped;
  }
  
  // 计算某一天的支出和收入
  calculateDayStats(bills: BillItem[]): DayStats {
    let expense = 0;
    let income = 0;
    bills.forEach(bill => {
      if (bill.type === 0) {
        expense += parseFloat(bill.amount) || 0;
      } else {
        income += parseFloat(bill.amount) || 0;
      }
    });
    const result: DayStats = {
      expense: expense.toFixed(2),
      income: income.toFixed(2)
    };
    return result;
  }
  
  // 格式化日期显示 (YYYY-MM-DD -> MM月DD日 星期X)
  formatDateDisplay(dateStr: string): string {
    const date = new Date(dateStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const weekDay = weekDays[date.getDay()];
    return `${month}月${day}日 ${weekDay}`;
  }

  // Calculate start angle for pie chart
  getPieStartAngle(index: number): number {
    let angle = 0;
    for (let i = 0; i < index; i++) {
      angle += (this.categoryStatsList[i].percentage / 100) * 360;
    }
    return angle;
  }

  // Draw pie slice
  @Builder
  PieSlice(item: CategoryStats, index: number) {
    Path()
      .width(180)
      .height(180)
      .commands(this.getPieSlicePath(item.percentage, this.getPieStartAngle(index)))
      .fill(item.color)
  }

  // Calculate start angle for income pie chart
  getPieStartAngleIncome(index: number): number {
    let angle = 0;
    for (let i = 0; i < index; i++) {
      angle += (this.incomeCategoryStatsList[i].percentage / 100) * 360;
    }
    return angle;
  }

  // Draw income pie slice
  @Builder
  PieSliceIncome(item: CategoryStats, index: number) {
    Path()
      .width(180)
      .height(180)
      .commands(this.getPieSlicePath(item.percentage, this.getPieStartAngleIncome(index)))
      .fill(item.color)
  }

  // Get pie slice path (donut chart)
  getPieSlicePath(percentage: number, startAngle: number): string {
    const centerX = 90;
    const centerY = 90;
    const outerRadius = 90;
    const innerRadius = 58; // 内圈半径，控制环的粗细
    
    // 如果接近100%，稍微减小一点避免360度圆弧问题
    let angle = (percentage / 100) * 360;
    if (angle >= 359.9) {
      angle = 359.9;
    }
    const endAngle = startAngle + angle;
    
    // Convert angles to radians
    const startRad = (startAngle - 90) * Math.PI / 180;
    const endRad = (endAngle - 90) * Math.PI / 180;
    
    // Calculate outer arc points
    const outerX1 = centerX + outerRadius * Math.cos(startRad);
    const outerY1 = centerY + outerRadius * Math.sin(startRad);
    const outerX2 = centerX + outerRadius * Math.cos(endRad);
    const outerY2 = centerY + outerRadius * Math.sin(endRad);
    
    // Calculate inner arc points
    const innerX1 = centerX + innerRadius * Math.cos(startRad);
    const innerY1 = centerY + innerRadius * Math.sin(startRad);
    const innerX2 = centerX + innerRadius * Math.cos(endRad);
    const innerY2 = centerY + innerRadius * Math.sin(endRad);
    
    // Large arc flag
    const largeArc = angle > 180 ? 1 : 0;
    
    // Create donut path: outer arc -> line to inner arc -> inner arc (reverse) -> close
    return `M ${outerX1} ${outerY1} A ${outerRadius} ${outerRadius} 0 ${largeArc} 1 ${outerX2} ${outerY2} L ${innerX2} ${innerY2} A ${innerRadius} ${innerRadius} 0 ${largeArc} 0 ${innerX1} ${innerY1} Z`;
  }

  // Calculate category statistics
  calculateCategoryStats() {
    const categoryMap = new Map<string, CategorySum>();
    let totalExpense = 0;

    const yearMonthStr = `${this.selectedYear}-${this.selectedMonth.toString().padStart(2, '0')}`;
    console.info('=== 开始计算分类统计 ===');
    console.info('当前选择:', yearMonthStr);
    console.info('账单总数:', this.billList.length);

    // Only count expense bills from current selected month
    let matchCount = 0;
    this.billList.forEach(bill => {
      // 过滤当前选择的年月 - 使用字符串匹配更可靠
      const dateStr = bill.date; // 格式应该是 "YYYY-MM-DD"
      
      if (bill.type === 0 && dateStr.startsWith(yearMonthStr)) { // Expense only and current month
        const amount = parseFloat(bill.amount) || 0;
        totalExpense += amount;
        matchCount++;
        
        if (categoryMap.has(bill.category)) {
          const existing = categoryMap.get(bill.category)!;
          existing.amount += amount;
        } else {
          const categorySum: CategorySum = { amount: amount, icon: bill.categoryIcon };
          categoryMap.set(bill.category, categorySum);
        }
      }
    });

    console.info('匹配到', matchCount, '条支出账单');
    console.info('分类数量:', categoryMap.size, '总支出:', totalExpense);

    // Define colors for categories (10 colors)
    const colors = ['#5B7FFF', '#FF6B6B', '#FFA94D', '#9775FA', '#20C997', '#FF8787', '#51C4D3', '#FFD93D', '#6BCB77', '#F67280'];
    
    // Convert to array and calculate percentages
    const statsArray: CategoryStats[] = [];
    let colorIndex = 0;
    
    categoryMap.forEach((value, key) => {
      statsArray.push({
        category: key,
        icon: value.icon,
        amount: value.amount,
        percentage: totalExpense > 0 ? (value.amount / totalExpense) * 100 : 0,
        color: colors[colorIndex % colors.length]
      });
      colorIndex++;
    });

    // Sort by amount descending
    statsArray.sort((a, b) => b.amount - a.amount);
    
    this.categoryStatsList = statsArray;
    console.info('最终分类统计列表长度:', this.categoryStatsList.length);
    console.info('分类统计列表内容:', JSON.stringify(this.categoryStatsList));
  }

  // Calculate income category statistics
  calculateIncomeCategoryStats() {
    const categoryMap = new Map<string, CategorySum>();
    let totalIncome = 0;

    const yearMonthStr = `${this.selectedYear}-${this.selectedMonth.toString().padStart(2, '0')}`;
    console.info('=== 开始计算收入分类统计 ===');
    console.info('当前选择:', yearMonthStr);
    console.info('账单总数:', this.billList.length);

    // Only count income bills from current selected month
    let matchCount = 0;
    this.billList.forEach(bill => {
      const dateStr = bill.date; // 格式应该是 "YYYY-MM-DD"
      
      if (bill.type === 1 && dateStr.startsWith(yearMonthStr)) { // Income only and current month
        const amount = parseFloat(bill.amount) || 0;
        totalIncome += amount;
        matchCount++;
        
        if (categoryMap.has(bill.category)) {
          const existing = categoryMap.get(bill.category)!;
          existing.amount += amount;
        } else {
          const categorySum: CategorySum = { amount: amount, icon: bill.categoryIcon };
          categoryMap.set(bill.category, categorySum);
        }
      }
    });

    console.info('匹配到', matchCount, '条收入账单');
    console.info('分类数量:', categoryMap.size, '总收入:', totalIncome);

    // Define colors for categories (10 colors)
    const colors = ['#5B7FFF', '#FF6B6B', '#FFA94D', '#9775FA', '#20C997', '#FF8787', '#51C4D3', '#FFD93D', '#6BCB77', '#F67280'];
    
    // Convert to array and calculate percentages
    const statsArray: CategoryStats[] = [];
    let colorIndex = 0;
    
    categoryMap.forEach((value, key) => {
      statsArray.push({
        category: key,
        icon: value.icon,
        amount: value.amount,
        percentage: totalIncome > 0 ? (value.amount / totalIncome) * 100 : 0,
        color: colors[colorIndex % colors.length]
      });
      colorIndex++;
    });

    // Sort by amount descending
    statsArray.sort((a, b) => b.amount - a.amount);
    
    this.incomeCategoryStatsList = statsArray;
    console.info('最终收入分类统计列表长度:', this.incomeCategoryStatsList.length);
    console.info('收入分类统计列表内容:', JSON.stringify(this.incomeCategoryStatsList));
  }

  build() {
    Stack() {
      Column() {
        // 内容区域
        Stack() {
          if (this.currentTabIndex === 0) {
            this.BillPage();
          } else if (this.currentTabIndex === 1) {
            this.StatisticsPage();
          } else if (this.currentTabIndex === 2) {
            this.AssetPage();
          } else if (this.currentTabIndex === 3) {
            this.ProfilePage();
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#E3ECFF')

        // 底部导航栏
      Row() {
        // 明细
        Column() {
          Image($r('app.media.bill_icon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTabIndex === 0 ? '#5B7FFF' : '#999999')
          Text('明细')
            .fontSize(12)
            .fontColor(this.currentTabIndex === 0 ? '#5B7FFF' : '#999999')
            .margin({ top: 4 })
        }
        .width('20%')
        .onClick(() => {
          this.currentTabIndex = 0;
        })

        // 统计
        Column() {
          Image($r('app.media.statistics_icon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTabIndex === 1 ? '#5B7FFF' : '#999999')
          Text('统计')
            .fontSize(12)
            .fontColor(this.currentTabIndex === 1 ? '#5B7FFF' : '#999999')
            .margin({ top: 4 })
        }
        .width('20%')
        .onClick(() => {
          this.currentTabIndex = 1;
        })

        // 中间加号按钮
        Column() {
          Stack() {
            Circle()
              .width(56)
              .height(56)
              .fill('#5B7FFF')
            
            Text('+')
              .fontSize(32)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('20%')
        .offset({ y: -10 })
        .onClick(() => {
          // 跳转到添加账单页面
          router.pushUrl({
            url: 'pages/AddBill'
          });
        })

        // 资产
        Column() {
          Image($r('app.media.asset_icon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTabIndex === 2 ? '#5B7FFF' : '#999999')
          Text('资产')
            .fontSize(12)
            .fontColor(this.currentTabIndex === 2 ? '#5B7FFF' : '#999999')
            .margin({ top: 4 })
        }
        .width('20%')
        .onClick(() => {
          this.currentTabIndex = 2;
        })

        // 我的
        Column() {
          Image($r('app.media.profile_icon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTabIndex === 3 ? '#5B7FFF' : '#999999')
          Text('我的')
            .fontSize(12)
            .fontColor(this.currentTabIndex === 3 ? '#5B7FFF' : '#999999')
            .margin({ top: 4 })
        }
        .width('20%')
        .onClick(() => {
          this.currentTabIndex = 3;
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: -2 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#E3ECFF')
      
      // 年月选择器弹窗
      if (this.showDatePicker) {
        this.DatePickerDialog();
      }
      
      // 昵称修改弹窗
      if (this.showNicknameDialog) {
        this.NicknameDialog();
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 选择头像
  async selectAvatar() {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);
      
      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        this.avatarUri = photoSelectResult.photoUris[0];
        promptAction.showToast({
          message: '头像上传成功',
          duration: 2000
        });
      }
    } catch (err) {
      console.error('选择头像失败:', JSON.stringify(err));
      promptAction.showToast({
        message: '预览器环境不支持相册功能，请在真机或模拟器上测试',
        duration: 3000
      });
    }
  }

  // 账单页面
  @Builder
  BillPage() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('明细')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Row() {
          Image($r('app.media.search_icon'))
            .width(22)
            .height(22)
            .fillColor('#666666')
            .margin({ right: 16 })
          
          Image($r('app.media.calendar_icon'))
            .width(22)
            .height(22)
            .fillColor('#666666')
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      // 顶部统计卡片
      Column() {
        Row() {
          Text(`${this.selectedYear}年 ${this.selectedMonth}月`)
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.9)')
          Text('▼')
            .fontSize(10)
            .fontColor('rgba(255, 255, 255, 0.9)')
            .margin({ left: 6 })
        }
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 8 })
        .onClick(() => {
          this.showDatePicker = true; // 点击显示日期选择器
        })

        Text(this.monthExpense)
          .fontSize(36)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        Row() {
          Column() {
            Text('本月收入')
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .margin({ bottom: 4 })
            Text(this.monthIncome)
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('本月结余')
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .margin({ bottom: 4 })
            Text(this.monthBalance)
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 60 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('90%')
      .padding(20)
      .margin({ top: 16, bottom: 16 })
      .borderRadius(16)
      .alignItems(HorizontalAlign.Start)
      .linearGradient({
        angle: 135,
        colors: [[0x5B7FFF, 0.0], [0x4A6FEE, 1.0]]
      })

      // 账单列表区域
      if (this.billList.length === 0) {
        Column() {
          Image($r('app.media.empty_bill'))
            .width(120)
            .height(120)
            .objectFit(ImageFit.Contain)
            .opacity(0.5)
            .margin({ bottom: 20 })
          
          Text('暂无账单记录')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .offset({ y: -100 })
      } else {
        List() {
          ForEach(this.dateGroups, (group: DateGroup, groupIndex: number) => {
            ListItem() {
              Column() {
                // 日期标题行
                Row() {
                  Text(this.formatDateDisplay(group.date))
                    .fontSize(13)
                    .fontColor('#999999')
                  Blank()
                  Text(`支: ${this.calculateDayStats(group.bills).expense}`)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ left: 16 })
                  Text(`收: ${this.calculateDayStats(group.bills).income}`)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ left: 16 })
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                
                // 该日期下的所有账单
                List() {
                  ForEach(group.bills, (bill: BillItem, index: number) => {
                    ListItem() {
                      Column() {
                        // 账单项
                        Row() {
                          // 图标
                          Image($r(`app.media.category_${bill.categoryIcon}`))
                            .width(40)
                            .height(40)
                            .fillColor('#5B7FFF')
                            .margin({ right: 12 })
                          
                          // 分类和备注
                          Column() {
                            Text(bill.category)
                              .fontSize(15)
                              .fontColor('#333333')
                              .margin({ bottom: 4 })
                            if (bill.remark) {
                              Text(bill.remark)
                                .fontSize(12)
                                .fontColor('#999999')
                            }
                          }
                          .alignItems(HorizontalAlign.Start)
                          
                          Blank()
                          
                          // 金额
                          Text((bill.type === 0 ? '-' : '+') + bill.amount)
                            .fontSize(16)
                            .fontColor(bill.type === 0 ? '#333333' : '#FF6B6B')
                            .fontWeight(FontWeight.Medium)
                        }
                        .width('100%')
                        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                        .backgroundColor('#FFFFFF')
                        .borderRadius(index === group.bills.length - 1 ? 
                          { bottomLeft: 12, bottomRight: 12 } : 0)
                        
                        // 分隔线（不是最后一项时显示）
                        if (index < group.bills.length - 1) {
                          Divider()
                            .color('#F0F0F0')
                            .strokeWidth(1)
                            .margin({ left: 68, right: 16 })
                        }
                      }
                    }
                    .swipeAction({
                      end: this.DeleteBillButton(bill.id)
                    })
                  }, (bill: BillItem) => `${bill.id}_${this.refreshFlag}`)
                }
                .width('100%')
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .clip(true)
            }
            .margin({ bottom: 12 })
          }, (group: DateGroup) => `${group.date}_${this.refreshFlag}`)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 10 })
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#E3ECFF')
  }
  
  // 日期分组组件（一个大模块）
  @Builder
  DateGroupComponent(date: string, bills: BillItem[]) {
    Column() {
      // 日期标题行
      Row() {
        Text(this.formatDateDisplay(date))
          .fontSize(13)
          .fontColor('#999999')
        Blank()
        Text(`支: ${this.calculateDayStats(bills).expense}`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 16 })
        Text(`收: ${this.calculateDayStats(bills).income}`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      
      // 该日期下的所有账单
      Column() {
        ForEach(bills, (bill: BillItem, index: number) => {
          Column() {
            // 账单项
            Row() {
              // 图标
              Image($r(`app.media.category_${bill.categoryIcon}`))
                .width(40)
                .height(40)
                .fillColor('#5B7FFF')
                .margin({ right: 12 })
              
              // 分类和备注
              Column() {
                Text(bill.category)
                  .fontSize(15)
                  .fontColor('#333333')
                  .margin({ bottom: 4 })
                if (bill.remark) {
                  Text(bill.remark)
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .alignItems(HorizontalAlign.Start)
              
              Blank()
              
              // 金额
              Text((bill.type === 0 ? '-' : '+') + bill.amount)
                .fontSize(16)
                .fontColor(bill.type === 0 ? '#333333' : '#FF6B6B')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            
            // 分隔线（不是最后一项时显示）
            if (index < bills.length - 1) {
              Divider()
                .color('#F0F0F0')
                .strokeWidth(1)
                .margin({ left: 68, right: 16 })
            }
          }
        }, (bill: BillItem) => bill.id)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  // 统计页面
  @Builder
  StatisticsPage() {
    Column() {
      // 滚动内容区域
      Scroll() {
        Column() {
          // 支出/收入 Tab 切换
          Row() {
            // 支出 Tab
            Column() {
              Text('支出')
                .fontSize(18)
                .fontColor(this.statisticsTabIndex === 0 ? '#333333' : '#999999')
                .fontWeight(FontWeight.Bold)
                .padding({ bottom: 8 })
              
              // 下划线
              Divider()
                .strokeWidth(2)
                .color(this.statisticsTabIndex === 0 ? '#5B7FFF' : 'transparent')
                .width(40)
            }
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.statisticsTabIndex = 0;
            })
            
            // 收入 Tab
            Column() {
              Text('收入')
                .fontSize(18)
                .fontColor(this.statisticsTabIndex === 1 ? '#333333' : '#999999')
                .fontWeight(FontWeight.Bold)
                .padding({ bottom: 8 })
              
              // 下划线
              Divider()
                .strokeWidth(2)
                .color(this.statisticsTabIndex === 1 ? '#5B7FFF' : 'transparent')
                .width(40)
            }
            .alignItems(HorizontalAlign.Center)
            .margin({ left: 30 })
            .onClick(() => {
              this.statisticsTabIndex = 1;
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({ left: 20, right: 20, top: 16, bottom: 8 })

          // 月份选择器
          Row() {
            Text(`${this.selectedYear}年 ${this.selectedMonth}月`)
              .fontSize(14)
              .fontColor('#333333')
            Text('▼')
              .fontSize(10)
              .fontColor('#999999')
              .margin({ left: 6 })
          }
          .padding({ left: 20, right: 20, top: 0, bottom: 0 })
          .onClick(() => {
            this.showDatePicker = true;
          })

          // 收入支出统计卡片
          Row() {
            // 支出
            Column() {
              Text('支出')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ bottom: 4 })
              Text(this.monthExpense)
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            // 收入
            Column() {
              Text('收入')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ bottom: 4 })
              Text(this.monthIncome)
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            // 结余
            Column() {
              Text('结余')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ bottom: 4 })
              Text(this.monthBalance)
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.End)
          }
          .width('90%')
          .padding(24)
          .margin({ top: 4, bottom: 8 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 支出/收入占比
          if ((this.statisticsTabIndex === 0 && this.categoryStatsList.length > 0) ||
              (this.statisticsTabIndex === 1 && this.incomeCategoryStatsList.length > 0)) {
            Column() {
              // 标题
              Row() {
                Text(this.statisticsTabIndex === 0 ? '支出占比' : '收入占比')
                  .fontSize(16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text('›')
                  .fontSize(24)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 12 })

              // 环形图和金额
              Row() {
                // 环形图
                Stack() {
                  // 绘制环形图的各个部分
                  if (this.statisticsTabIndex === 0 && this.categoryStatsList.length > 0) {
                    ForEach(this.categoryStatsList, (item: CategoryStats, index: number) => {
                      this.PieSlice(item, index)
                    }, (item: CategoryStats) => item.category)
                  } else if (this.statisticsTabIndex === 1 && this.incomeCategoryStatsList.length > 0) {
                    ForEach(this.incomeCategoryStatsList, (item: CategoryStats, index: number) => {
                      this.PieSliceIncome(item, index)
                    }, (item: CategoryStats) => item.category)
                  }
                }
                .width(180)
                .height(180)
                
                // 金额文字 - 在圆环右侧紧挨着，使用负margin靠近
                Text(this.statisticsTabIndex === 0 ? this.monthExpense : this.monthIncome)
                  .fontSize(24)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: -90, top: -110 })
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .width('100%')
              .margin({ top: 16, bottom: -100 })

              // 分类列表
              Column() {
                ForEach(this.statisticsTabIndex === 0 ? this.categoryStatsList : this.incomeCategoryStatsList, 
                  (item: CategoryStats, index: number) => {
                  Row() {
                    // 颜色标识
                    Circle()
                      .width(8)
                      .height(8)
                      .fill(item.color)
                      .margin({ right: 8 })

                    Text(item.category)
                      .fontSize(14)
                      .fontColor('#666666')
                      .layoutWeight(1)

                    Text(`${item.percentage.toFixed(1)}%`)
                      .fontSize(14)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                }, (item: CategoryStats) => item.category)
              }
              .width('100%')
              .padding({ bottom: 12 })
            }
            .width('90%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 支出/收入榜单
            Column() {
              // 标题
              Row() {
                Text(this.statisticsTabIndex === 0 ? '支出榜单' : '收入榜单')
                  .fontSize(16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text('›')
                  .fontSize(24)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 12 })

              // 榜单列表
              Column() {
                ForEach(this.statisticsTabIndex === 0 ? this.categoryStatsList : this.incomeCategoryStatsList, 
                  (item: CategoryStats, index: number) => {
                  Column() {
                    Row() {
                      // 图标
                      Stack() {
                        Circle()
                          .width(40)
                          .height(40)
                          .fill(item.color)
                        
                        Image($r(`app.media.category_${item.icon}`))
                          .width(24)
                          .height(24)
                          .fillColor('#FFFFFF')
                      }
                      .margin({ right: 12 })

                      Column() {
                        Text(item.category)
                          .fontSize(15)
                          .fontColor('#333333')
                          .margin({ bottom: 4 })
                        Text(`${item.percentage.toFixed(1)}%`)
                          .fontSize(12)
                          .fontColor('#999999')
                      }
                      .alignItems(HorizontalAlign.Start)

                      Blank()

                      Text(`¥${item.amount.toFixed(2)}`)
                        .fontSize(16)
                        .fontColor('#333333')
                        .fontWeight(FontWeight.Medium)
                    }
                    .width('100%')
                    .padding({ left: 16, right: 16, top: 12, bottom: 12 })

                    // 分隔线
                    if (index < (this.statisticsTabIndex === 0 ? this.categoryStatsList.length : this.incomeCategoryStatsList.length) - 1) {
                      Divider()
                        .strokeWidth(1)
                        .color('#F0F0F0')
                        .margin({ left: 68, right: 16 })
                    }
                  }
                }, (item: CategoryStats) => item.category)
              }
              .width('100%')
            }
            .width('90%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 16 })
          } else {
            // 无数据提示
            Column() {
              Image($r('app.media.empty_bill'))
                .width(120)
                .height(120)
                .objectFit(ImageFit.Contain)
                .opacity(0.5)
                .margin({ bottom: 20 })
              
              Text(this.statisticsTabIndex === 0 ? '暂无支出数据' : '暂无收入数据')
                .fontSize(16)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ top: 40, bottom: 100 })
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E3ECFF')
  }

  // 资产页面
  @Builder
  AssetPage() {
    Column() {
      // 顶部标题栏（固定在顶部）
      Column() {
        // 加号按钮
        Stack() {
          Circle()
            .width(25)
            .height(25)
            .fill('#5B7FFF')
          
          Text('+')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .margin({ bottom: 8, top: 16 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SelectAssetType'
          });
        })
        
        // 标题
        Text('资产')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16, right: 16, top: 0, bottom: 12 })
      .backgroundColor('#E3ECFF')

      // 可滚动内容区域
      Scroll() {
        Column({ space: 0 }) {
          // 净资产卡片
          Column() {
            // 净资产标题和眼睛图标
            Row() {
              Text('净资产')
                .fontSize(14)
                .fontColor('#999999')
              
              Image($r('app.media.search_icon'))
                .width(18)
                .height(18)
                .fillColor('#999999')
                .margin({ left: 6 })
            }
            .margin({ bottom: 12 })
            
            // 金额
            Text(`¥${this.netAssets}`)
              .fontSize(40)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 })
            
            // 总资产和总负债
            Row() {
              Column() {
                Text('总资产')
                  .fontSize(13)
                  .fontColor('#999999')
                  .margin({ bottom: 6 })
                Text(`¥${this.totalAssets}`)
                  .fontSize(15)
                  .fontColor('#333333')
              }
              .alignItems(HorizontalAlign.Start)
              
              Column() {
                Text('总负债')
                  .fontSize(13)
                  .fontColor('#999999')
                  .margin({ bottom: 6 })
                Text(`¥${this.totalLiabilities}`)
                  .fontSize(15)
                  .fontColor('#333333')
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 60 })
            }
            .width('100%')
          }
          .width('90%')
          .padding({ left: 20, right: 20, top: 20, bottom: 20 })
          .margin({ top: 0, bottom: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)

          // 总借入和总借出卡片
          Row() {
            // 总借入
            Column() {
              Row() {
                Stack() {
                  Circle()
                    .width(32)
                    .height(32)
                    .fill('#666666')
                  
                  Text('↓')
                    .fontSize(20)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                }
                .margin({ right: 8 })
                
                Column() {
                  Text('总借入')
                    .fontSize(13)
                    .fontColor('#999999')
                    .margin({ bottom: 4 })
                  Text('¥0.00')
                    .fontSize(16)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .padding(16)
            }
            .width('48%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            
            Blank()
            
            // 总借出
            Column() {
              Row() {
                Stack() {
                  Circle()
                    .width(32)
                    .height(32)
                    .fill('#52C41A')
                  
                  Text('↑')
                    .fontSize(20)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                }
                .margin({ right: 8 })
                
                Column() {
                  Text('总借出')
                    .fontSize(13)
                    .fontColor('#999999')
                    .margin({ bottom: 4 })
                  Text('¥0.00')
                    .fontSize(16)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .padding(16)
            }
            .width('48%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .width('90%')
          .margin({ bottom: 12 })

          // 账户列表
          if (this.accountList.length > 0) {
            Column() {
              // 资金账户标题
              Row() {
                Text(`资金账户 (${this.accountList.filter(acc => !acc.isCredit).length})`)
                  .fontSize(14)
                  .fontColor('#999999')
                
                Blank()
                
                Text(`余额: ¥${this.totalAssets}`)
                  .fontSize(13)
                  .fontColor('#999999')
                
                Text('∨')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
                  .margin({ left: 6 })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              
              // 账户列表
              List() {
                ForEach(this.accountList.filter(acc => !acc.isCredit), (account: AccountItem, index: number) => {
                  ListItem() {
                    Row() {
                      Stack() {
                        Circle()
                          .width(40)
                          .height(40)
                          .fill(account.iconColor)
                        
                        Text(account.iconText)
                          .fontSize(16)
                          .fontColor('#FFFFFF')
                          .fontWeight(FontWeight.Bold)
                      }
                      .margin({ right: 12 })
                      
                      Column() {
                        Text(account.name)
                          .fontSize(16)
                          .fontColor('#333333')
                          .margin({ bottom: 4 })
                        Text(account.type)
                          .fontSize(12)
                          .fontColor('#999999')
                      }
                      .alignItems(HorizontalAlign.Start)
                      
                      Blank()
                      
                      Text(`¥${account.balance}`)
                        .fontSize(16)
                        .fontColor('#333333')
                        .fontWeight(FontWeight.Medium)
                    }
                    .width('100%')
                    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                    .backgroundColor('#FFFFFF')
                    .borderRadius(index === this.accountList.filter(acc => !acc.isCredit).length - 1 ? 
                      { bottomLeft: 12, bottomRight: 12 } : 0)
                  }
                  .swipeAction({
                    end: this.DeleteButton(account.id)
                  })
                }, (account: AccountItem) => `${account.id}_${this.accountRefreshFlag}`)
              }
              .width('100%')
            }
            .width('90%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 16 })
          } else {
            Column() {
              Image($r('app.media.empty_bill'))
                .width(120)
                .height(120)
                .objectFit(ImageFit.Contain)
                .opacity(0.5)
                .margin({ bottom: 20 })
              
              Text('暂无数据')
                .fontSize(16)
                .fontColor('#CCCCCC')
            }
            .width('100%')
            .padding({ top: 20, bottom: 100 })
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .padding({ top: 0 })
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E3ECFF')
  }

  // 我的页面
  @Builder
  ProfilePage() {
    Column() {
      // 用户信息卡片
      Column() {
        // 顶部用户名和头像
        Row() {
          // 头像
          if (this.avatarUri) {
            Image(this.avatarUri)
              .width(50)
              .height(50)
              .borderRadius(25)
              .margin({ right: 12 })
              .onClick(() => {
                this.selectAvatar(); // 点击选择头像
              })
          } else {
            Image($r('app.media.startIcon'))
              .width(50)
              .height(50)
              .borderRadius(25)
              .margin({ right: 12 })
              .onClick(() => {
                this.selectAvatar(); // 点击选择头像
              })
          }
          
          Column() {
            Text(this.nickname)
              .fontSize(18)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .onClick(() => {
                this.tempNickname = this.nickname; // 将当前昵称复制到临时变量
                this.showNicknameDialog = true; // 显示昵称修改弹窗
              })
            
            Text('发现我的蓝途~')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          
          Blank()
          
          Text('›')
            .fontSize(24)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 16 })
        
        // 统计数据
        Row() {
          Column() {
            Text(this.totalDays.toString())
              .fontSize(22)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 4 })
            Text('记账天数')
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('50%')
          .alignItems(HorizontalAlign.Center)
          
          Column() {
            Text(this.totalRecords.toString())
              .fontSize(22)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 4 })
            Text('记账笔数')
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('50%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
      }
      .width('100%')
      .backgroundColor('#E3EBFE')
      .margin({ bottom: 20 })

      // 菜单列表
      Column() {
        this.MenuItemWithIcon('记账提醒', 'reminder_icon', () => {
          router.pushUrl({
            url: 'pages/ReminderSetting'
          });
        })
        Divider().margin({ left: 50 })
        this.MenuItemWithIcon('帮助文档', 'help_icon', () => {
          router.pushUrl({
            url: 'pages/HelpDocument'
          });
        })
        Divider().margin({ left: 50 })
        this.MenuItemWithIcon('关于我们', 'about_icon', () => {
          router.pushUrl({
            url: 'pages/AboutUs'
          });
        })
        Divider().margin({ left: 50 })
        this.MenuItemWithIcon('设置', 'settings_icon', () => {
          router.pushUrl({
            url: 'pages/Settings'
          });
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .margin({ bottom: 20 })

      // 退出登录按钮
      Button('退出登录')
        .width('90%')
        .height(50)
        .backgroundColor('#FFFFFF')
        .fontColor('#FF3B30')
        .fontSize(16)
        .margin({ top: 20 })
        .onClick(() => {
          router.replaceUrl({
            url: 'pages/Index'
          });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E3ECFF')
  }

  // Delete account method
  async deleteAccount(accountId: string) {
    const success = await AccountDataManager.deleteAccount(accountId);
    if (success) {
      // Reload account data after deletion
      await this.loadAccountData();
      promptAction.showToast({
        message: '删除成功',
        duration: 2000
      });
    } else {
      promptAction.showToast({
        message: '删除失败，请重试',
        duration: 2000
      });
    }
  }

  // Delete bill method
  async deleteBill(billId: string) {
    const success = await BillDataManager.deleteBill(billId);
    if (success) {
      // Reload bill data after deletion
      await this.loadBillData();
      promptAction.showToast({
        message: '删除成功',
        duration: 2000
      });
    } else {
      promptAction.showToast({
        message: '删除失败，请重试',
        duration: 2000
      });
    }
  }

  // Delete button builder for account swipe action
  @Builder
  DeleteButton(accountId: string) {
    Row() {
      Text('删除')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
    }
    .width(80)
    .height('100%')
    .backgroundColor('#FF3B30')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.deleteAccount(accountId);
    })
  }

  // Delete button builder for bill swipe action
  @Builder
  DeleteBillButton(billId: string) {
    Row() {
      Text('删除')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
    }
    .width(80)
    .height('100%')
    .backgroundColor('#FF3B30')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.deleteBill(billId);
    })
  }

  // 菜单项组件
  @Builder
  MenuItem(title: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })
      
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
      
      Text('›')
        .fontSize(24)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      // TODO: 跳转到对应设置页面
    })
  }
  
  // 带点击事件的菜单项组件
  @Builder
  MenuItemWithAction(title: string, icon: string, action: () => void) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })
      
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
      
      Text('›')
        .fontSize(24)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      action();
    })
  }
  
  // 带SVG图标和点击事件的菜单项组件
  @Builder
  MenuItemWithIcon(title: string, iconName: string, action: () => void) {
    Row() {
      Image($r(`app.media.${iconName}`))
        .width(24)
        .height(24)
        .fillColor('#C2D0FF')
        .margin({ right: 12 })
      
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
      
      Text('›')
        .fontSize(24)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      action();
    })
  }
  
  // 年月选择器弹窗
  @Builder
  DatePickerDialog() {
    Stack() {
      // 半透明背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showDatePicker = false; // 点击遮罩关闭
        })
      
      // 日期选择器内容
      Column() {
        // 年份和月份选择器
        Row() {
          // 年份选择器
          Column() {
            List({ initialIndex: this.yearList.indexOf(this.selectedYear) }) {
              ForEach(this.yearList, (year: number, index: number) => {
                ListItem() {
                  Text(`${year}年`)
                    .fontSize(this.selectedYear === year ? 20 : 16)
                    .fontColor(this.selectedYear === year ? '#5B7FFF' : '#666666')
                    .fontWeight(this.selectedYear === year ? FontWeight.Bold : FontWeight.Normal)
                    .padding({ top: 12, bottom: 12 })
                }
                .onClick(() => {
                  this.selectedYear = year;
                })
              }, (year: number) => year.toString())
            }
            .width('50%')
            .height(250)
            .scrollBar(BarState.Off)
            .alignListItem(ListItemAlign.Center)
          }
          .width('50%')
          
          // 月份选择器
          Column() {
            List({ initialIndex: this.selectedMonth - 1 }) {
              ForEach(this.monthList, (month: number, index: number) => {
                ListItem() {
                  Text(`${month}月`)
                    .fontSize(this.selectedMonth === month ? 20 : 16)
                    .fontColor(this.selectedMonth === month ? '#5B7FFF' : '#666666')
                    .fontWeight(this.selectedMonth === month ? FontWeight.Bold : FontWeight.Normal)
                    .padding({ top: 12, bottom: 12 })
                }
                .onClick(() => {
                  this.selectedMonth = month;
                })
              }, (month: number) => month.toString())
            }
            .width('50%')
            .height(250)
            .scrollBar(BarState.Off)
            .alignListItem(ListItemAlign.Center)
          }
          .width('50%')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        
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
              this.showDatePicker = false;
            })
          
          // 确定按钮
          Button('确定')
            .width('45%')
            .height(45)
            .backgroundColor('#5B7FFF')
            .fontColor('#FFFFFF')
            .fontSize(16)
            .onClick(() => {
              this.showDatePicker = false;
              this.loadBillData(); // 重新加载数据
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('85%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }
  
  // 昵称修改弹窗
  @Builder
  NicknameDialog() {
    Stack() {
      // 半透明背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showNicknameDialog = false; // 点击遮罩关闭
        })
      
      // 昵称修改内容
      Column() {
        Text('修改昵称')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        
        // 昵称输入框
        TextInput({ text: this.tempNickname, placeholder: '请输入昵称' })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .fontSize(16)
          .maxLength(20)
          .onChange((value: string) => {
            this.tempNickname = value;
          })
          .margin({ bottom: 20 })
        
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
              this.showNicknameDialog = false;
            })
          
          // 确定按钮
          Button('确定')
            .width('45%')
            .height(45)
            .backgroundColor('#5B7FFF')
            .fontColor('#FFFFFF')
            .fontSize(16)
            .onClick(() => {
              if (this.tempNickname && this.tempNickname.trim().length > 0) {
                this.nickname = this.tempNickname.trim();
                this.showNicknameDialog = false;
                promptAction.showToast({
                  message: '昵称修改成功',
                  duration: 2000
                });
              } else {
                promptAction.showToast({
                  message: '昵称不能为空',
                  duration: 2000
                });
              }
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

