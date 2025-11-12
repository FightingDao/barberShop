import { useState } from 'react';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { Card } from '../ui/card';
import { Scissors, Eye, EyeOff } from 'lucide-react';

interface LoginProps {
  onLogin: () => void;
  onNavigateToRegister: () => void;
}

export default function Login({ onLogin, onNavigateToRegister }: LoginProps) {
  const [loginType, setLoginType] = useState<'password' | 'sms'>('password');
  const [showPassword, setShowPassword] = useState(false);
  
  // 密码登录
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  
  // 验证码登录
  const [smsPhone, setSmsPhone] = useState('');
  const [code, setCode] = useState('');
  const [countdown, setCountdown] = useState(0);

  const handlePasswordLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // 简单验证
    if (phone && password) {
      onLogin();
    }
  };

  const handleSmsLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (smsPhone && code) {
      onLogin();
    }
  };

  const sendCode = () => {
    if (smsPhone) {
      setCountdown(60);
      const timer = setInterval(() => {
        setCountdown(prev => {
          if (prev <= 1) {
            clearInterval(timer);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-pink-50 to-white flex flex-col items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo和标题 */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-[#FF385C] rounded-full mb-4">
            <Scissors className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-gray-900 mb-2">欢迎来到理发预约</h1>
          <p className="text-gray-600">随时随地，轻松预约您的专属造型师</p>
        </div>

        {/* 登录卡片 */}
        <Card className="p-6 shadow-lg border-0">
          <Tabs value={loginType} onValueChange={(v) => setLoginType(v as 'password' | 'sms')}>
            <TabsList className="grid w-full grid-cols-2 mb-6">
              <TabsTrigger value="password">密码登录</TabsTrigger>
              <TabsTrigger value="sms">验证码登录</TabsTrigger>
            </TabsList>

            {/* 密码登录 */}
            <TabsContent value="password">
              <form onSubmit={handlePasswordLogin} className="space-y-4">
                <div>
                  <Label htmlFor="phone">手机号</Label>
                  <Input
                    id="phone"
                    type="tel"
                    placeholder="请输入手机号"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="mt-1.5"
                  />
                </div>
                
                <div>
                  <Label htmlFor="password">密码</Label>
                  <div className="relative mt-1.5">
                    <Input
                      id="password"
                      type={showPassword ? 'text' : 'password'}
                      placeholder="请输入密码"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="pr-10"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    >
                      {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                    </button>
                  </div>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <label className="flex items-center">
                    <input type="checkbox" className="rounded border-gray-300 text-[#FF385C] focus:ring-[#FF385C]" />
                    <span className="ml-2 text-gray-600">记住我</span>
                  </label>
                  <button type="button" className="text-[#FF385C] hover:underline">
                    忘记密码？
                  </button>
                </div>

                <Button 
                  type="submit" 
                  className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-12"
                >
                  登录
                </Button>
              </form>
            </TabsContent>

            {/* 验证码登录 */}
            <TabsContent value="sms">
              <form onSubmit={handleSmsLogin} className="space-y-4">
                <div>
                  <Label htmlFor="phone">手机号</Label>
                  <Input
                    id="phone"
                    type="tel"
                    placeholder="请输入手机号"
                    value={smsPhone}
                    onChange={(e) => setSmsPhone(e.target.value)}
                    className="mt-1.5"
                  />
                </div>
                
                <div>
                  <Label htmlFor="code">验证码</Label>
                  <div className="flex gap-2 mt-1.5">
                    <Input
                      id="code"
                      type="text"
                      placeholder="请输入验证码"
                      value={code}
                      onChange={(e) => setCode(e.target.value)}
                      className="flex-1"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      onClick={sendCode}
                      disabled={countdown > 0 || !smsPhone}
                      className="w-28 shrink-0"
                    >
                      {countdown > 0 ? `${countdown}秒` : '获取验证码'}
                    </Button>
                  </div>
                </div>

                <Button 
                  type="submit" 
                  className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-12"
                >
                  登录
                </Button>
              </form>
            </TabsContent>
          </Tabs>
        </Card>

        {/* 注册链接 */}
        <div className="text-center mt-6">
          <span className="text-gray-600">还没有账号？</span>
          <button 
            onClick={onNavigateToRegister}
            className="ml-2 text-[#FF385C] hover:underline"
          >
            立即注册
          </button>
        </div>

        {/* 底部说明 */}
        <p className="text-center text-sm text-gray-500 mt-8">
          登录即表示同意
          <button className="text-[#FF385C] hover:underline mx-1">服务条款</button>
          和
          <button className="text-[#FF385C] hover:underline ml-1">隐私政策</button>
        </p>
      </div>
    </div>
  );
}