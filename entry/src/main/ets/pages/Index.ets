import preferences from '@ohos.data.preferences';
import { promptAction } from '@kit.ArkUI';
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0; // 0: 登录, 1: 注册
  @State account: string = '';
  @State password: string = '';
  @State verifyCode: string = '';
  @State isPasswordLogin: boolean = true; // true: 密码登录, false: 验证码登录
  
  // 注册相关状态
  @State registerAccount: string = '';
  @State registerPassword: string = '';
  @State registerPasswordConfirm: string = '';
  
  private preferencesStore: preferences.Preferences | null = null;

  build() {
    Column() {
      // 顶部标签栏
      Row() {
        // 登录标签和下划线
        Column() {
          Text('登录')
            .fontSize(26)
            .fontWeight(this.currentTabIndex === 0 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentTabIndex === 0 ? '#333333' : '#999999')
            .onClick(() => {
              this.currentTabIndex = 0;
            })
          
          // 登录下划线
          Divider()
            .width(40)
            .strokeWidth(5)
            .color(this.currentTabIndex === 0 ? '#5B7FFF' : 'transparent')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 30 })
        
        // 注册标签和下划线
        Column() {
          Text('注册')
            .fontSize(26)
            .fontWeight(this.currentTabIndex === 1 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentTabIndex === 1 ? '#333333' : '#999999')
            .onClick(() => {
              this.currentTabIndex = 1;
            })
          
          // 注册下划线
          Divider()
            .width(40)
            .strokeWidth(5)
            .color(this.currentTabIndex === 1 ? '#5B7FFF' : 'transparent')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding({ left: 40, top: 60, bottom: 40 })
      
      // 内容区域
      if (this.currentTabIndex === 0) {
        this.LoginContent();
      } else {
        this.RegisterContent();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  @Builder
  LoginContent() {
    Column() {
      // 提示文字
      Text('请输入账号密码')
        .fontSize(18)
        .fontColor('#333333')
        .width('85%')
        .margin({ bottom: 40 })
      
      // 手机号/邮箱输入框
      TextInput({ placeholder: '手机号/邮箱' })
        .width('85%')
        .height(50)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .placeholderColor('#CCCCCC')
        .fontSize(16)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.account = value;
        })
      
      // 密码/验证码输入框
      Row() {
        if (this.isPasswordLogin) {
          TextInput({ placeholder: '密码' })
            .width('100%')
            .height(50)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .placeholderColor('#CCCCCC')
            .fontSize(16)
            .type(InputType.Password)
            .onChange((value: string) => {
              this.password = value;
            })
        } else {
          TextInput({ placeholder: '验证码' })
            .width('100%')
            .height(50)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .placeholderColor('#CCCCCC')
            .fontSize(16)
            .onChange((value: string) => {
              this.verifyCode = value;
            })
        }
      }
      .width('85%')
      .margin({ bottom: 10 })
      
      // 切换登录方式
      Row() {
        Text(this.isPasswordLogin ? '验证码登录' : '密码登录')
          .fontSize(14)
          .fontColor('#5B7FFF')
          .onClick(() => {
            this.isPasswordLogin = !this.isPasswordLogin;
          })
      }
      .width('85%')
      .justifyContent(FlexAlign.End)
      .margin({ bottom: 40 })
      
      // 登录按钮
      Button('登录')
        .width('85%')
        .height(50)
        .backgroundColor('#5B7FFF')
        .borderRadius(25)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .onClick(() => {
          this.handleLogin();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
  
  @Builder
  RegisterContent() {
    Column() {
      // 提示文字
      Text('请输入注册信息')
        .fontSize(18)
        .fontColor('#333333')
        .width('85%')
        .margin({ bottom: 40 })
      
      // 手机号/邮箱输入框
      TextInput({ placeholder: '手机号/邮箱' })
        .width('85%')
        .height(50)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .placeholderColor('#CCCCCC')
        .fontSize(16)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.registerAccount = value;
        })
      
      // 密码输入框
      TextInput({ placeholder: '密码' })
        .width('85%')
        .height(50)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .placeholderColor('#CCCCCC')
        .fontSize(16)
        .type(InputType.Password)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.registerPassword = value;
        })
      
      // 确认密码输入框
      TextInput({ placeholder: '确认密码' })
        .width('85%')
        .height(50)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .placeholderColor('#CCCCCC')
        .fontSize(16)
        .type(InputType.Password)
        .margin({ bottom: 40 })
        .onChange((value: string) => {
          this.registerPasswordConfirm = value;
        })
      
      // 注册按钮
      Button('注册')
        .width('85%')
        .height(50)
        .backgroundColor('#5B7FFF')
        .borderRadius(25)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .onClick(() => {
          this.handleRegister();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
  
  // 处理登录
  async handleLogin() {
    // 验证账号
    if (!this.account) {
      promptAction.showToast({
        message: '请输入账号',
        duration: 2000
      });
      return;
    }
    
    // 密码登录验证
    if (this.isPasswordLogin) {
      if (!this.password) {
        promptAction.showToast({
          message: '请输入密码',
          duration: 2000
        });
        return;
      }
      
      // 测试账号：允许test/123456直接登录
      if (this.account === 'test' && this.password === '123456') {
        promptAction.showToast({
          message: '登录成功！',
          duration: 1500
        });
        
        // 跳转到主页面
        setTimeout(() => {
          router.replaceUrl({
            url: 'pages/Main'
          }).catch((err: Error) => {
            console.error('路由跳转失败:', err);
            promptAction.showToast({
              message: '页面跳转失败',
              duration: 2000
            });
          });
        }, 300);
        return;
      }
      
      // 验证账号密码
      try {
        if (this.preferencesStore) {
          const savedPassword = await this.preferencesStore.get(`user_${this.account}`, '');
          if (!savedPassword) {
            promptAction.showToast({
              message: '账号不存在，请先注册（或使用测试账号：test/123456）',
              duration: 2500
            });
            return;
          }
          
          if (savedPassword !== this.password) {
            promptAction.showToast({
              message: '密码错误',
              duration: 2000
            });
            return;
          }
          
          // 登录成功
          promptAction.showToast({
            message: '登录成功！',
            duration: 1500
          });
          
          // 清空登录表单
          this.account = '';
          this.password = '';
          
          // 跳转到主页面
          setTimeout(() => {
            router.replaceUrl({
              url: 'pages/Main'
            }).catch((err: Error) => {
              console.error('路由跳转失败:', err);
              promptAction.showToast({
                message: '页面跳转失败',
                duration: 2000
              });
            });
          }, 300);
        } else {
          promptAction.showToast({
            message: '存储初始化失败，请重试',
            duration: 2000
          });
        }
      } catch (err) {
        console.error('登录失败:', err);
        promptAction.showToast({
          message: '登录失败，请重试',
          duration: 2000
        });
      }
    } else {
      // 验证码登录
      if (!this.verifyCode) {
        promptAction.showToast({
          message: '请输入验证码',
          duration: 2000
        });
        return;
      }
      
      // TODO: 实现验证码登录逻辑
      promptAction.showToast({
        message: '验证码登录功能待实现',
        duration: 2000
      });
    }
  }
  
  // 初始化数据存储
  async aboutToAppear() {
    try {
      const context = getContext(this);
      this.preferencesStore = await preferences.getPreferences(context, 'accountData');
    } catch (err) {
      console.error('初始化存储失败:', err);
    }
  }
  
  // 处理注册
  async handleRegister() {
    // 验证账号
    if (!this.registerAccount) {
      promptAction.showToast({
        message: '请输入账号',
        duration: 2000
      });
      return;
    }
    
    // 验证账号格式（简单验证：至少3个字符）
    if (this.registerAccount.length < 3) {
      promptAction.showToast({
        message: '账号至少需要3个字符',
        duration: 2000
      });
      return;
    }
    
    // 验证密码
    if (!this.registerPassword) {
      promptAction.showToast({
        message: '请输入密码',
        duration: 2000
      });
      return;
    }
    
    // 验证密码长度
    if (this.registerPassword.length < 6) {
      promptAction.showToast({
        message: '密码至少需要6个字符',
        duration: 2000
      });
      return;
    }
    
    // 验证确认密码
    if (!this.registerPasswordConfirm) {
      promptAction.showToast({
        message: '请确认密码',
        duration: 2000
      });
      return;
    }
    
    // 验证两次密码是否一致
    if (this.registerPassword !== this.registerPasswordConfirm) {
      promptAction.showToast({
        message: '两次密码输入不一致',
        duration: 2000
      });
      return;
    }
    
    // 保存用户信息
    try {
      if (this.preferencesStore) {
        // 检查账号是否已存在
        const existingPassword = await this.preferencesStore.get(`user_${this.registerAccount}`, '');
        if (existingPassword) {
          promptAction.showToast({
            message: '该账号已被注册',
            duration: 2000
          });
          return;
        }
        
        // 保存新用户
        await this.preferencesStore.put(`user_${this.registerAccount}`, this.registerPassword);
        await this.preferencesStore.flush();
        
        // 注册成功提示
        promptAction.showToast({
          message: '注册成功！',
          duration: 2000
        });
        
        // 清空注册表单
        this.registerAccount = '';
        this.registerPassword = '';
        this.registerPasswordConfirm = '';
        
        // 延迟跳转到登录页面
        setTimeout(() => {
          this.currentTabIndex = 0;
        }, 500);
      } else {
        promptAction.showToast({
          message: '存储初始化失败，请重试',
          duration: 2000
        });
      }
    } catch (err) {
      console.error('注册失败:', err);
      promptAction.showToast({
        message: '注册失败，请重试',
        duration: 2000
      });
    }
  }
}