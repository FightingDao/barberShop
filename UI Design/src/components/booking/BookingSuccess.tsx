import { useEffect, useState } from 'react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { MapPin, Scissors, User, Calendar, Clock, Phone, Copy, Check } from 'lucide-react';
import { BookingData } from '../../App';

interface BookingSuccessProps {
  bookingData: BookingData;
  onViewAppointments: () => void;
  onBackToHome: () => void;
}

export default function BookingSuccess({ bookingData, onViewAppointments, onBackToHome }: BookingSuccessProps) {
  const [showAnimation, setShowAnimation] = useState(false);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    // 进入动画
    setTimeout(() => setShowAnimation(true), 100);
  }, []);

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekDay = weekDays[date.getDay()];
    return `${month}月${day}日 ${weekDay}`;
  };

  const copyAppointmentCode = () => {
    if (bookingData.appointmentId) {
      navigator.clipboard.writeText(bookingData.appointmentId);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-pink-50 via-white to-pink-50/30">
      <div className="max-w-2xl mx-auto px-4 py-12">
        {/* 成功动画 - 完全居中 */}
        <div className={`text-center mb-8 transition-all duration-500 ${
          showAnimation ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4'
        }`}>
          <div className="inline-flex items-center justify-center w-24 h-24 bg-gradient-to-br from-green-100 to-green-200 rounded-full mb-6 animate-bounce shadow-lg">
            <Check className="w-12 h-12 text-green-600" />
          </div>
          <h1 className="text-gray-900 mb-3">预约成功！</h1>
          <p className="text-gray-600">您的预约已确认，期待为您服务</p>
        </div>

        {/* 预约码卡片 - 完全居中对齐 */}
        <Card className="p-8 mb-6 border-0 shadow-xl rounded-3xl text-center bg-white overflow-hidden relative">
          {/* 装饰性背景 */}
          <div className="absolute inset-0 bg-gradient-to-br from-pink-50/50 via-transparent to-purple-50/50 pointer-events-none"></div>
          
          <div className="relative z-10">
            <p className="text-gray-600 mb-6">请凭此预约码到店核销</p>
            
            {/* 预约码容器 - 完全居中 */}
            <div className="flex flex-col items-center justify-center mb-4">
              {/* 扫码区域 */}
              <div className="w-56 h-56 bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl flex items-center justify-center mb-6 border-4 border-dashed border-gray-300 shadow-inner">
                <div className="text-center">
                  <div className="text-7xl mb-3">📱</div>
                  <p className="text-sm text-gray-500">出示此码核销</p>
                </div>
              </div>
              
              {/* 预约码数字 */}
              <div className="bg-gradient-to-br from-pink-50 to-purple-50 px-8 py-4 rounded-2xl mb-4 shadow-sm">
                <div className="text-4xl tracking-widest text-gray-900 font-mono">
                  {bookingData.appointmentId}
                </div>
              </div>
              
              {/* 复制按钮 */}
              <button
                onClick={copyAppointmentCode}
                className="inline-flex items-center gap-2 px-6 py-3 bg-pink-50 hover:bg-pink-100 rounded-full text-[#FF385C] transition-colors"
              >
                {copied ? (
                  <>
                    <Check className="w-5 h-5" />
                    <span>已复制</span>
                  </>
                ) : (
                  <>
                    <Copy className="w-5 h-5" />
                    <span>复制预约码</span>
                  </>
                )}
              </button>
            </div>
          </div>
        </Card>

        {/* 预约详情卡片 */}
        <Card className="p-6 mb-6 border-0 shadow-lg rounded-3xl bg-white">
          <h2 className="text-gray-900 mb-6 pb-4 border-b border-gray-100 text-center">预约详情</h2>
          
          <div className="space-y-5">
            {/* 店铺 */}
            <div className="flex items-start gap-4">
              <div className="w-10 h-10 bg-gradient-to-br from-pink-100 to-pink-200 rounded-xl flex items-center justify-center shrink-0 shadow-sm">
                <MapPin className="w-5 h-5 text-[#FF385C]" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-gray-900 mb-1">{bookingData.shopName}</p>
                <p className="text-sm text-gray-500">{bookingData.shopAddress}</p>
              </div>
            </div>

            <div className="border-t border-gray-100"></div>

            {/* 服务 */}
            <div className="flex items-start gap-4">
              <div className="w-10 h-10 bg-gradient-to-br from-purple-100 to-purple-200 rounded-xl flex items-center justify-center shrink-0 shadow-sm">
                <Scissors className="w-5 h-5 text-purple-600" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-gray-900 mb-2">{bookingData.serviceName}</p>
                <div className="flex items-center gap-4 text-sm">
                  <span className="text-[#FF385C]">¥{bookingData.servicePrice}</span>
                  <span className="text-gray-500">约{bookingData.serviceDuration}分钟</span>
                </div>
              </div>
            </div>

            <div className="border-t border-gray-100"></div>

            {/* 理发师 */}
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-100 to-blue-200 rounded-xl flex items-center justify-center shrink-0 shadow-sm">
                <User className="w-5 h-5 text-blue-600" />
              </div>
              <div className="flex-1">
                <p className="text-gray-600 text-sm mb-1">理发师</p>
                <p className="text-gray-900">
                  {bookingData.stylistName || '不指定理发师'}
                </p>
              </div>
            </div>

            <div className="border-t border-gray-100"></div>

            {/* 时间 */}
            <div className="flex items-start gap-4">
              <div className="w-10 h-10 bg-gradient-to-br from-amber-100 to-amber-200 rounded-xl flex items-center justify-center shrink-0 shadow-sm">
                <Calendar className="w-5 h-5 text-amber-600" />
              </div>
              <div className="flex-1">
                <p className="text-gray-600 text-sm mb-1">预约时间</p>
                <p className="text-gray-900 mb-1">{formatDate(bookingData.date)}</p>
                <p className="text-sm text-gray-500">
                  {bookingData.time} - {
                    bookingData.time && bookingData.serviceDuration
                      ? (() => {
                          const [hours, minutes] = bookingData.time.split(':').map(Number);
                          const endMinutes = hours * 60 + minutes + bookingData.serviceDuration;
                          const endHours = Math.floor(endMinutes / 60);
                          const endMins = endMinutes % 60;
                          return `${endHours.toString().padStart(2, '0')}:${endMins.toString().padStart(2, '0')}`;
                        })()
                      : ''
                  }
                </p>
              </div>
            </div>

            {bookingData.notes && (
              <>
                <div className="border-t border-gray-100"></div>
                <div className="flex items-start gap-4">
                  <div className="w-10 h-10 bg-gradient-to-br from-green-100 to-green-200 rounded-xl flex items-center justify-center shrink-0 text-xl shadow-sm">
                    💬
                  </div>
                  <div className="flex-1">
                    <p className="text-gray-600 text-sm mb-1">备注</p>
                    <p className="text-gray-900">{bookingData.notes}</p>
                  </div>
                </div>
              </>
            )}
          </div>

          {/* 店铺电话 */}
          <div className="mt-6 pt-6 border-t border-gray-100 text-center">
            <a
              href="tel:010-12345678"
              className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-gray-50 hover:bg-gray-100 rounded-full text-gray-700 transition-colors"
            >
              <Phone className="w-5 h-5" />
              <span>联系店铺</span>
            </a>
          </div>
        </Card>

        {/* 温馨提示 */}
        <Card className="p-5 mb-8 bg-gradient-to-br from-amber-50 to-orange-50 border-0 rounded-3xl shadow-md">
          <div className="flex gap-4">
            <div className="w-10 h-10 bg-amber-100 rounded-xl flex items-center justify-center shrink-0 shadow-sm">
              <span className="text-2xl">💡</span>
            </div>
            <div className="flex-1 text-sm text-amber-900 space-y-2">
              <p className="font-medium">温馨提示</p>
              <div className="space-y-1 text-amber-800">
                <p>• 请提前5分钟到店，出示预约码</p>
                <p>• 如需取消，请至少提前2小时操作</p>
                <p>• 可在"我的预约"中查看详情</p>
              </div>
            </div>
          </div>
        </Card>

        {/* 操作按钮 - 统一居中 */}
        <div className="space-y-4">
          <Button
            onClick={onViewAppointments}
            className="w-full bg-gradient-to-r from-[#FF385C] to-[#E31C5F] hover:from-[#E31C5F] hover:to-[#C13053] text-white h-14 rounded-full shadow-xl text-base"
          >
            查看我的预约
          </Button>
          <Button
            onClick={onBackToHome}
            variant="outline"
            className="w-full h-14 rounded-full border-2 hover:bg-gray-50 text-base"
          >
            返回首页
          </Button>
        </div>
      </div>
    </div>
  );
}