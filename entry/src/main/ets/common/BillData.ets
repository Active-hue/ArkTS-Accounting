// 账单数据模型

export interface BillItem {
  id: string;              // 唯一ID
  type: number;            // 0: 支出, 1: 收入
  amount: string;          // 金额
  category: string;        // 分类
  categoryIcon: string;    // 分类图标编号
  remark: string;          // 备注
  date: string;            // 日期
  time: string;            // 时间
}

// 统计数据接口
export interface BillStats {
  monthExpense: string;
  monthIncome: string;
}

export class BillDataManager {
  private static readonly STORAGE_KEY = 'bill_list';
  
  // 保存账单
  static async saveBill(bill: BillItem): Promise<void> {
    try {
      console.info('BillDataManager: 开始保存账单');
      const bills = await BillDataManager.getAllBills();
      console.info('BillDataManager: 当前账单数量:', bills.length);
      bills.unshift(bill); // 添加到列表开头
      const jsonData = JSON.stringify(bills);
      console.info('BillDataManager: 保存数据:', jsonData);
      AppStorage.SetOrCreate(BillDataManager.STORAGE_KEY, jsonData);
      console.info('BillDataManager: 账单保存成功，新数量:', bills.length);
    } catch (err) {
      console.error('保存账单失败:', err);
    }
  }
  
  // 获取所有账单
  static async getAllBills(): Promise<BillItem[]> {
    try {
      const data = AppStorage.Get<string>(BillDataManager.STORAGE_KEY);
      console.info('BillDataManager: 读取数据:', data);
      if (data) {
        const bills: BillItem[] = JSON.parse(data as string) as BillItem[];
        console.info('BillDataManager: 解析后账单数量:', bills.length);
        return bills;
      }
      console.info('BillDataManager: 没有数据，返回空数组');
      return [];
    } catch (err) {
      console.error('获取账单失败:', err);
      return [];
    }
  }
  
  // Delete bill by ID
  static async deleteBill(billId: string): Promise<boolean> {
    try {
      console.info('BillDataManager: 开始删除账单, ID:', billId);
      const bills = await BillDataManager.getAllBills();
      const newBills = bills.filter(bill => bill.id !== billId);
      
      if (newBills.length === bills.length) {
        console.warn('BillDataManager: 未找到要删除的账单');
        return false;
      }
      
      const jsonData = JSON.stringify(newBills);
      AppStorage.SetOrCreate(BillDataManager.STORAGE_KEY, jsonData);
      console.info('BillDataManager: 账单删除成功，剩余数量:', newBills.length);
      return true;
    } catch (err) {
      console.error('删除账单失败:', err);
      return false;
    }
  }
  
  // 计算统计数据
  static calculateStats(bills: BillItem[]): BillStats {
    const now = new Date();
    const currentMonth = now.getMonth() + 1;
    
    let monthExpense = 0;
    let monthIncome = 0;
    
    bills.forEach(bill => {
      // 简单判断是否是本月（可以根据实际需求改进）
      if (bill.type === 0) {
        monthExpense += parseFloat(bill.amount) || 0;
      } else {
        monthIncome += parseFloat(bill.amount) || 0;
      }
    });
    
    const result: BillStats = {
      monthExpense: monthExpense.toFixed(2),
      monthIncome: monthIncome.toFixed(2)
    };
    
    return result;
  }
}

