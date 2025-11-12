import { useState } from 'react';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Card } from '../ui/card';
import { Scissors, Eye, EyeOff, Check } from 'lucide-react';

interface RegisterProps {
  onRegister: () => void;
  onNavigateToLogin: () => void;
}

export default function Register({ onRegister, onNavigateToLogin }: RegisterProps) {
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  
  const [formData, setFormData] = useState({
    phone: '',
    password: '',
    confirmPassword: '',
    code: '',
  });

  const [countdown, setCountdown] = useState(0);
  const [agreed, setAgreed] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // 简单验证
    if (!formData.phone || !formData.password) {
      alert('请填写完整信息');
      return;
    }
    
    if (formData.password !== formData.confirmPassword) {
      alert('两次密码不一致');
      return;
    }
    
    if (formData.password.length < 6) {
      alert('密码长度至少6位');
      return;
    }
    
    if (!agreed) {
      alert('请同意服务条款和隐私政策');
      return;
    }
    
    onRegister();
  };

  const sendCode = () => {
    if (formData.phone) {
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

  const updateField = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  // 密码强度检测
  const getPasswordStrength = () => {
    const pwd = formData.password;
    if (!pwd) return null;
    if (pwd.length < 6) return { text: '弱', color: 'text-red-500' };
    if (pwd.length < 10) return { text: '中', color: 'text-yellow-500' };
    return { text: '强', color: 'text-green-500' };
  };

  const strength = getPasswordStrength();

  return (
    <div className="min-h-screen bg-gradient-to-b from-pink-50 to-white flex flex-col items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo和标题 */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-[#FF385C] rounded-full mb-4">
            <Scissors className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-gray-900 mb-2">创建账号</h1>
          <p className="text-gray-600">加入我们，开启便捷预约之旅</p>
        </div>

        {/* 注册卡片 */}
        <Card className="p-6 shadow-lg border-0">
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* 手机号 */}
            <div>
              <Label htmlFor="phone">手机号 *</Label>
              <div className="flex gap-2 mt-1.5">
                <Input
                  id="phone"
                  type="tel"
                  placeholder="请输入手机号"
                  value={formData.phone}
                  onChange={(e) => updateField('phone', e.target.value)}
                  className="flex-1"
                  required
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={sendCode}
                  disabled={countdown > 0 || !formData.phone}
                  className="w-28 shrink-0"
                >
                  {countdown > 0 ? `${countdown}秒` : '获取验证码'}
                </Button>
              </div>
            </div>

            {/* 验证码 */}
            <div>
              <Label htmlFor="code">验证码 *</Label>
              <Input
                id="code"
                type="text"
                placeholder="请输入验证码"
                value={formData.code}
                onChange={(e) => updateField('code', e.target.value)}
                className="mt-1.5"
                required
              />
            </div>

            {/* 密码 */}
            <div>
              <Label htmlFor="password">密码 *</Label>
              <div className="relative mt-1.5">
                <Input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  placeholder="请输入密码（至少6位）"
                  value={formData.password}
                  onChange={(e) => updateField('password', e.target.value)}
                  className="pr-10"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
              {strength && (
                <p className={`text-sm mt-1 ${strength.color}`}>
                  密码强度：{strength.text}
                </p>
              )}
            </div>

            {/* 确认密码 */}
            <div>
              <Label htmlFor="confirmPassword">确认密码 *</Label>
              <div className="relative mt-1.5">
                <Input
                  id="confirmPassword"
                  type={showConfirmPassword ? 'text' : 'password'}
                  placeholder="请再次输入密码"
                  value={formData.confirmPassword}
                  onChange={(e) => updateField('confirmPassword', e.target.value)}
                  className="pr-10"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showConfirmPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
              {formData.confirmPassword && formData.password !== formData.confirmPassword && (
                <p className="text-sm text-red-500 mt-1">两次密码不一致</p>
              )}
            </div>

            {/* 同意条款 */}
            <div className="flex items-start gap-2 pt-2">
              <button
                type="button"
                onClick={() => setAgreed(!agreed)}
                className={`flex items-center justify-center w-5 h-5 rounded border-2 shrink-0 mt-0.5 transition-colors ${
                  agreed ? 'bg-[#FF385C] border-[#FF385C]' : 'border-gray-300'
                }`}
              >
                {agreed && <Check className="w-3 h-3 text-white" />}
              </button>
              <p className="text-sm text-gray-600">
                我已阅读并同意
                <button type="button" className="text-[#FF385C] hover:underline mx-1">
                  《服务条款》
                </button>
                和
                <button type="button" className="text-[#FF385C] hover:underline ml-1">
                  《隐私政策》
                </button>
              </p>
            </div>

            {/* 注册按钮 */}
            <Button 
              type="submit" 
              className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-12 mt-6"
            >
              注册
            </Button>
          </form>
        </Card>

        {/* 登录链接 */}
        <div className="text-center mt-6">
          <span className="text-gray-600">已有账号？</span>
          <button 
            onClick={onNavigateToLogin}
            className="ml-2 text-[#FF385C] hover:underline"
          >
            立即登录
          </button>
        </div>
      </div>
    </div>
  );
}