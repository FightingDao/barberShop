import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { User, Calendar, LogOut, ChevronRight } from 'lucide-react';

interface ProfileProps {
  onNavigateToAppointments: () => void;
  onLogout: () => void;
}

export default function Profile({ onNavigateToAppointments, onLogout }: ProfileProps) {
  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      {/* 顶部个人信息区 */}
      <div className="bg-gradient-to-br from-pink-400 to-rose-400 pt-12 pb-16 px-4">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center gap-4">
            {/* 头像 */}
            <div className="w-20 h-20 bg-white rounded-full flex items-center justify-center shadow-lg">
              <User className="w-10 h-10 text-pink-500" />
            </div>
            
            {/* 用户信息 */}
            <div className="flex-1">
              <h2 className="text-white text-2xl mb-1">您好</h2>
              <p className="text-white/90">欢迎使用理发预约服务</p>
            </div>
          </div>
        </div>
      </div>

      {/* 功能列表 */}
      <div className="max-w-4xl mx-auto px-4 -mt-8">
        {/* 我的预约卡片 */}
        <Card 
          className="mb-4 border-0 shadow-lg rounded-2xl overflow-hidden cursor-pointer hover:shadow-xl transition-shadow"
          onClick={onNavigateToAppointments}
        >
          <div className="p-5 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-gradient-to-br from-pink-100 to-pink-200 rounded-xl flex items-center justify-center">
                <Calendar className="w-6 h-6 text-[#FF385C]" />
              </div>
              <div>
                <h3 className="text-gray-900 mb-1">我的预约</h3>
                <p className="text-sm text-gray-500">查看预约记录</p>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </div>
        </Card>

        {/* 退出登录按钮 */}
        <Card className="border-0 shadow-md rounded-2xl overflow-hidden">
          <button 
            onClick={onLogout}
            className="w-full p-5 flex items-center justify-center gap-2 text-red-600 hover:bg-red-50 transition-colors"
          >
            <LogOut className="w-5 h-5" />
            <span>退出登录</span>
          </button>
        </Card>

        {/* 版本信息 */}
        <div className="text-center mt-8 mb-4">
          <p className="text-sm text-gray-400">理发预约 v1.0.0</p>
        </div>
      </div>
    </div>
  );
}