import { useState } from 'react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { Textarea } from '../ui/textarea';
import { ArrowLeft, MapPin, Scissors, User, Calendar, Clock, MessageSquare } from 'lucide-react';
import { BookingData } from '../../App';

interface OrderConfirmationProps {
  bookingData: BookingData;
  onBack: () => void;
  onConfirm: (notes: string, appointmentId: string) => void;
}

export default function OrderConfirmation({ bookingData, onBack, onConfirm }: OrderConfirmationProps) {
  const [notes, setNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleConfirm = async () => {
    setIsSubmitting(true);
    
    // 模拟提交过程
    setTimeout(() => {
      const appointmentId = Math.random().toString(36).substring(2, 10).toUpperCase();
      onConfirm(notes, appointmentId);
      setIsSubmitting(false);
    }, 1000);
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekDay = weekDays[date.getDay()];
    return `${month}月${day}日 ${weekDay}`;
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 固定头部导航 */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-sm border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 py-3 flex items-center">
          <button
            onClick={onBack}
            className="w-10 h-10 flex items-center justify-center hover:bg-gray-100 rounded-full transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h1 className="text-gray-900 ml-4">确认预约</h1>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 py-6 pt-20 pb-32 space-y-4">
        {/* 店铺信息 */}
        <Card className="p-5 border-0 shadow-sm rounded-2xl">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-8 h-8 bg-pink-100 rounded-lg flex items-center justify-center">
              <MapPin className="w-5 h-5 text-[#FF385C]" />
            </div>
            <h2 className="text-gray-900">店铺信息</h2>
          </div>
          
          <div className="space-y-3">
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600">店铺名称</span>
              <span className="text-gray-900">{bookingData.shopName}</span>
            </div>
            <div className="border-t border-gray-100"></div>
            <div className="flex items-start justify-between py-2">
              <span className="text-gray-600">店铺地址</span>
              <span className="text-gray-900 text-right">{bookingData.shopAddress}</span>
            </div>
            <div className="border-t border-gray-100"></div>
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600">营业时间</span>
              <span className="text-gray-900">9:00 - 21:00</span>
            </div>
          </div>
        </Card>

        {/* 预约详情 */}
        <Card className="p-5 border-0 shadow-sm rounded-2xl">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-8 h-8 bg-pink-100 rounded-lg flex items-center justify-center">
              <Scissors className="w-5 h-5 text-[#FF385C]" />
            </div>
            <h2 className="text-gray-900">预约详情</h2>
          </div>
          
          <div className="space-y-3">
            {/* 服务项目 */}
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600">服务项目</span>
              <span className="text-gray-900">{bookingData.serviceName}</span>
            </div>
            <div className="border-t border-gray-100"></div>
            
            {/* 价格 */}
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600">服务价格</span>
              <span className="text-[#FF385C]">¥{bookingData.servicePrice}</span>
            </div>
            <div className="border-t border-gray-100"></div>
            
            {/* 时长 */}
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600">预计时长</span>
              <span className="text-gray-900">约{bookingData.serviceDuration}分钟</span>
            </div>
            <div className="border-t border-gray-100"></div>
            
            {/* 理发师 */}
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600 flex items-center gap-2">
                <User className="w-4 h-4" />
                理发师
              </span>
              <span className="text-gray-900">
                {bookingData.stylistName || '不指定'}
              </span>
            </div>
            <div className="border-t border-gray-100"></div>
            
            {/* 预约时间 */}
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600 flex items-center gap-2">
                <Calendar className="w-4 h-4" />
                预约日期
              </span>
              <span className="text-gray-900">{formatDate(bookingData.date)}</span>
            </div>
            <div className="border-t border-gray-100"></div>
            
            <div className="flex items-center justify-between py-2">
              <span className="text-gray-600 flex items-center gap-2">
                <Clock className="w-4 h-4" />
                预约时间
              </span>
              <span className="text-gray-900">
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
              </span>
            </div>
          </div>
        </Card>

        {/* 备注信息 */}
        <Card className="p-5 border-0 shadow-sm rounded-2xl">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-8 h-8 bg-pink-100 rounded-lg flex items-center justify-center">
              <MessageSquare className="w-5 h-5 text-[#FF385C]" />
            </div>
            <h2 className="text-gray-900">备注（选填）</h2>
          </div>
          
          <Textarea
            placeholder="请输入特殊需求，如发型要求等..."
            value={notes}
            onChange={(e) => {
              if (e.target.value.length <= 50) {
                setNotes(e.target.value);
              }
            }}
            className="min-h-[100px] resize-none rounded-xl"
          />
          <div className="flex justify-end mt-2">
            <span className={`text-sm ${notes.length >= 50 ? 'text-red-500' : 'text-gray-400'}`}>
              {notes.length}/50
            </span>
          </div>
        </Card>

        {/* 温馨提示 */}
        <Card className="p-4 bg-amber-50 border-amber-200 rounded-2xl">
          <div className="flex gap-3">
            <span className="text-xl shrink-0">💡</span>
            <p className="text-sm text-amber-800">
              温馨提示：预约后请提前5分钟到店，如需取消请至少提前2小时操作。
            </p>
          </div>
        </Card>
      </div>

      {/* 固定底部操作栏 */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 p-4 shadow-lg">
        <div className="max-w-4xl mx-auto">
          <Button
            onClick={handleConfirm}
            disabled={isSubmitting}
            className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-14 rounded-full shadow-lg disabled:bg-gray-300"
          >
            {isSubmitting ? '提交中...' : '确认预约'}
          </Button>
        </div>
      </div>
    </div>
  );
}