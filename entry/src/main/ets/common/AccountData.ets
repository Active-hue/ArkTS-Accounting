import preferences from '@ohos.data.preferences';

// 账户数据接口
export interface AccountItem {
  id: string;
  name: string; // 账户名称
  type: string; // 账户类型（如：微信钱包、支付宝等）
  iconText: string; // 图标文字
  iconColor: string; // 图标颜色
  balance: string; // 账户余额
  note: string; // 备注
  currency: string; // 币种
  includeInTotal: boolean; // 是否计入总资产
  canBeSelected: boolean; // 记账时是否可被选择
  isCredit: boolean; // 是否为信用账户
}

// 总资产统计接口
export interface AssetsSummary {
  totalAssets: number;
  totalLiabilities: number;
}

// 账户数据管理类
export class AccountDataManager {
  private static preferencesStore: preferences.Preferences | null = null;
  private static readonly ACCOUNT_KEY = 'accounts_data';

  // 初始化存储
  static async init(context: Context): Promise<void> {
    try {
      AccountDataManager.preferencesStore = await preferences.getPreferences(context, 'accountData');
    } catch (err) {
      console.error('初始化账户存储失败:', err);
    }
  }

  // 生成唯一ID
  static generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substring(2, 9);
  }

  // 保存账户
  static async saveAccount(account: AccountItem): Promise<boolean> {
    try {
      if (!AccountDataManager.preferencesStore) {
        console.error('存储未初始化');
        return false;
      }

      const accounts = await AccountDataManager.getAllAccounts();
      accounts.push(account);
      
      await AccountDataManager.preferencesStore.put(AccountDataManager.ACCOUNT_KEY, JSON.stringify(accounts));
      await AccountDataManager.preferencesStore.flush();
      
      console.info('账户保存成功:', account.name);
      return true;
    } catch (err) {
      console.error('保存账户失败:', err);
      return false;
    }
  }

  // 获取所有账户
  static async getAllAccounts(): Promise<AccountItem[]> {
    try {
      if (!AccountDataManager.preferencesStore) {
        console.error('存储未初始化');
        return [];
      }

      const data = await AccountDataManager.preferencesStore.get(AccountDataManager.ACCOUNT_KEY, '[]') as string;
      const accounts = JSON.parse(data) as AccountItem[];
      console.info('获取账户列表，数量:', accounts.length);
      return accounts;
    } catch (err) {
      console.error('获取账户列表失败:', err);
      return [];
    }
  }

  // 删除账户
  static async deleteAccount(id: string): Promise<boolean> {
    try {
      if (!AccountDataManager.preferencesStore) {
        return false;
      }

      const accounts = await AccountDataManager.getAllAccounts();
      const newAccounts = accounts.filter(account => account.id !== id);
      
      await AccountDataManager.preferencesStore.put(AccountDataManager.ACCOUNT_KEY, JSON.stringify(newAccounts));
      await AccountDataManager.preferencesStore.flush();
      
      return true;
    } catch (err) {
      console.error('删除账户失败:', err);
      return false;
    }
  }

  // 更新账户
  static async updateAccount(id: string, updatedAccount: AccountItem): Promise<boolean> {
    try {
      if (!AccountDataManager.preferencesStore) {
        return false;
      }

      const accounts = await AccountDataManager.getAllAccounts();
      const index = accounts.findIndex(account => account.id === id);
      
      if (index !== -1) {
        accounts[index] = updatedAccount;
        await AccountDataManager.preferencesStore.put(AccountDataManager.ACCOUNT_KEY, JSON.stringify(accounts));
        await AccountDataManager.preferencesStore.flush();
        return true;
      }
      
      return false;
    } catch (err) {
      console.error('更新账户失败:', err);
      return false;
    }
  }

  // 计算总资产和总负债
  static async calculateTotalAssets(): Promise<AssetsSummary> {
    const accounts = await AccountDataManager.getAllAccounts();
    let totalAssets = 0;
    let totalLiabilities = 0;

    accounts.forEach(account => {
      if (account.includeInTotal) {
        const balance = parseFloat(account.balance) || 0;
        if (account.isCredit) {
          totalLiabilities += balance;
        } else {
          totalAssets += balance;
        }
      }
    });

    const result: AssetsSummary = { totalAssets: totalAssets, totalLiabilities: totalLiabilities };
    return result;
  }
}

