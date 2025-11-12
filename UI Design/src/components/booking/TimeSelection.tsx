import { useState } from 'react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { ArrowLeft } from 'lucide-react';

interface TimeSelectionProps {
  onBack: () => void;
  onNext: (date: string, time: string) => void;
}

// 生成接下来7天的日期
const generateDates = () => {
  const dates = [];
  const today = new Date();
  
  for (let i = 0; i < 7; i++) {
    const date = new Date(today);
    date.setDate(today.getDate() + i);
    
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekday = weekdays[date.getDay()];
    
    let label = '';
    if (i === 0) label = '今天';
    else if (i === 1) label = '明天';
    else label = `${day}`;
    
    dates.push({
      id: `${month}-${day}`,
      label,
      weekday,
      fullDate: `${month}月${day}日`,
      date: `${month}-${day}`,
    });
  }
  
  return dates;
};

// 生成时间段
const generateTimeSlots = () => {
  const morningSlots = [];
  const afternoonSlots = [];
  
  // 上午时间段 09:00 - 11:30
  for (let hour = 9; hour <= 11; hour++) {
    morningSlots.push(`${hour.toString().padStart(2, '0')}:00`);
    if (hour < 11 || hour === 11) {
      morningSlots.push(`${hour.toString().padStart(2, '0')}:30`);
    }
  }
  
  // 下午时间段 12:00 - 20:30
  for (let hour = 12; hour <= 20; hour++) {
    afternoonSlots.push(`${hour.toString().padStart(2, '0')}:00`);
    if (hour < 20) {
      afternoonSlots.push(`${hour.toString().padStart(2, '0')}:30`);
    }
  }
  
  return { morningSlots, afternoonSlots };
};

export default function TimeSelection({ onBack, onNext }: TimeSelectionProps) {
  const dates = generateDates();
  const { morningSlots, afternoonSlots } = generateTimeSlots();
  
  const [selectedDate, setSelectedDate] = useState(dates[1].id); // 默认选择明天
  const [selectedTime, setSelectedTime] = useState('14:00');
  
  // 模拟不可用时间段
  const unavailableSlots = ['09:00', '09:30', '20:30'];

  const handleNext = () => {
    const selectedDateObj = dates.find(d => d.id === selectedDate);
    onNext(selectedDateObj?.fullDate || '', selectedTime);
  };

  const isSlotAvailable = (time: string) => {
    return !unavailableSlots.includes(time);
  };

  const selectedDateObj = dates.find(d => d.id === selectedDate);

  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* 固定头部 */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-sm border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 py-3 flex items-center">
          <button
            onClick={onBack}
            className="w-10 h-10 flex items-center justify-center hover:bg-gray-100 rounded-full transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h1 className="text-gray-900 ml-4">选择时间</h1>
        </div>
      </header>

      {/* 主内容区域 */}
      <div className="flex-1 overflow-y-auto pt-14 pb-32">
        <div className="max-w-4xl mx-auto px-4">
          {/* 提示文字 */}
          <p className="text-gray-400 text-sm mt-4 mb-6">请选择您方便的预约时间</p>

          {/* 日期选择 - 横向滚动 */}
          <div className="mb-6 -mx-4 px-4">
            <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
              {dates.map((date) => (
                <button
                  key={date.id}
                  onClick={() => setSelectedDate(date.id)}
                  className={`flex-shrink-0 w-16 h-20 rounded-2xl flex flex-col items-center justify-center transition-all ${
                    selectedDate === date.id
                      ? 'bg-[#FF385C] text-white shadow-lg scale-105'
                      : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
                  }`}
                >
                  <span className={`text-sm mb-1 ${
                    selectedDate === date.id ? 'text-white' : 'text-gray-900'
                  }`}>
                    {date.label}
                  </span>
                  <span className={`text-xs ${
                    selectedDate === date.id ? 'text-white/90' : 'text-gray-500'
                  }`}>
                    {date.weekday}
                  </span>
                </button>
              ))}
            </div>
          </div>

          {/* 上午时间段 */}
          <div className="mb-6">
            <h3 className="text-gray-900 mb-3">上午</h3>
            <div className="grid grid-cols-3 gap-3">
              {morningSlots.map((time) => {
                const available = isSlotAvailable(time);
                const selected = selectedTime === time;
                
                return (
                  <button
                    key={time}
                    onClick={() => available && setSelectedTime(time)}
                    disabled={!available}
                    className={`h-12 rounded-xl flex items-center justify-center transition-all ${
                      selected
                        ? 'bg-[#FF385C] text-white shadow-md scale-105'
                        : available
                        ? 'bg-gray-100 text-gray-900 hover:bg-gray-200'
                        : 'bg-gray-50 text-gray-300 cursor-not-allowed'
                    }`}
                  >
                    {time}
                  </button>
                );
              })}
            </div>
          </div>

          {/* 下午时间段 */}
          <div className="mb-6">
            <h3 className="text-gray-900 mb-3">下午</h3>
            <div className="grid grid-cols-3 gap-3">
              {afternoonSlots.map((time) => {
                const available = isSlotAvailable(time);
                const selected = selectedTime === time;
                
                return (
                  <button
                    key={time}
                    onClick={() => available && setSelectedTime(time)}
                    disabled={!available}
                    className={`h-12 rounded-xl flex items-center justify-center transition-all ${
                      selected
                        ? 'bg-[#FF385C] text-white shadow-md scale-105'
                        : available
                        ? 'bg-gray-100 text-gray-900 hover:bg-gray-200'
                        : 'bg-gray-50 text-gray-300 cursor-not-allowed'
                    }`}
                  >
                    {time}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* 固定底部 */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 p-4 shadow-lg">
        <div className="max-w-4xl mx-auto">
          {/* 已选时间显示 */}
          <p className="text-sm text-gray-900 mb-3">
            已选：<span className="text-gray-900">{selectedDateObj?.fullDate} {selectedTime}</span>
          </p>
          
          {/* 下一步按钮 */}
          <Button
            onClick={handleNext}
            className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-14 rounded-full shadow-lg"
          >
            下一步
          </Button>
        </div>
      </div>
    </div>
  );
}