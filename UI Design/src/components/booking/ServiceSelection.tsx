import { useState } from 'react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { Badge } from '../ui/badge';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../ui/dialog';
import { ArrowLeft, Info, Check, Scissors, Sparkles, Palette, Wind } from 'lucide-react';

interface Service {
  id: string;
  name: string;
  price: number;
  duration: number;
  description: string;
  icon: string;
  details: string;
}

interface ServiceSelectionProps {
  shopId: string;
  onBack: () => void;
  onNext: (service: Service) => void;
}

const SERVICES: Service[] = [
  {
    id: 's1',
    name: '经典剪发',
    price: 38,
    duration: 45,
    description: '专业修剪，塑造清爽造型',
    icon: 'scissors',
    details: '包含洗发、剪发、吹风造型。适合需要定期修剪的顾客，我们的专业发型师会根据您的脸型和发质，为您打造最适合的发型。',
  },
  {
    id: 's2',
    name: '洗剪吹套餐',
    price: 68,
    duration: 60,
    description: '深层清洁+精致造型',
    icon: 'sparkles',
    details: '包含头皮按摩、深层洗发、专业剪发、精致吹风造型。使用专业洗护产品，让您的头发更加健康亮泽。',
  },
  {
    id: 's3',
    name: '烫发',
    price: 288,
    duration: 120,
    description: '时尚卷发，持久定型',
    icon: 'wind',
    details: '采用进口烫发药水，温和不伤发。包含造型设计、烫发护理、造型修剪。多种卷度可选，打造自然蓬松或浪漫卷发。',
  },
  {
    id: 's4',
    name: '染发',
    price: 388,
    duration: 150,
    description: '潮流发色，彰显个性',
    icon: 'palette',
    details: '使用植物染发剂，温和少刺激。包含发色咨询、染发护理、光泽护理。专业调色，为您定制专属发色。',
  },
  {
    id: 's5',
    name: '儿童理发',
    price: 28,
    duration: 30,
    description: '专为儿童设计，温柔呵护',
    icon: 'scissors',
    details: '专业儿童理发师，耐心细致。提供儿童专座和玩具，让宝宝在轻松愉快的氛围中完成理发。',
  },
  {
    id: 's6',
    name: '头皮护理',
    price: 128,
    duration: 45,
    description: '深层养护，舒缓放松',
    icon: 'sparkles',
    details: '专业头皮检测，定制护理方案。包含头皮清洁、精油按摩、营养补充，改善头皮环境，促进头发健康生长。',
  },
];

const getServiceIcon = (iconName: string) => {
  switch (iconName) {
    case 'scissors':
      return <Scissors className="w-6 h-6" />;
    case 'sparkles':
      return <Sparkles className="w-6 h-6" />;
    case 'palette':
      return <Palette className="w-6 h-6" />;
    case 'wind':
      return <Wind className="w-6 h-6" />;
    default:
      return <Scissors className="w-6 h-6" />;
  }
};

export default function ServiceSelection({ shopId, onBack, onNext }: ServiceSelectionProps) {
  const [selectedService, setSelectedService] = useState<Service | null>(null);

  const handleSelectService = (service: Service) => {
    setSelectedService(service);
  };

  const handleNext = () => {
    if (selectedService) {
      onNext(selectedService);
    }
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
          <h1 className="text-gray-900 ml-4">选择服务</h1>
        </div>
      </header>

      {/* 服务列表 */}
      <div className="max-w-4xl mx-auto px-4 py-6 pt-20 pb-32">
        <p className="text-gray-600 mb-6">请选择您需要的服务项目</p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {SERVICES.map((service) => (
            <Card
              key={service.id}
              onClick={() => handleSelectService(service)}
              className={`p-4 cursor-pointer transition-all duration-200 border-2 ${
                selectedService?.id === service.id
                  ? 'border-[#FF385C] bg-pink-50/50'
                  : 'border-transparent hover:border-gray-200'
              }`}
            >
              <div className="flex items-start gap-4">
                {/* 图标 */}
                <div className={`w-12 h-12 rounded-lg flex items-center justify-center shrink-0 ${
                  selectedService?.id === service.id
                    ? 'bg-[#FF385C] text-white'
                    : 'bg-gray-100 text-gray-600'
                }`}>
                  {getServiceIcon(service.icon)}
                </div>

                {/* 内容 */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2 mb-1">
                    <h3 className="text-gray-900">{service.name}</h3>
                    {selectedService?.id === service.id && (
                      <div className="w-5 h-5 bg-[#FF385C] rounded-full flex items-center justify-center shrink-0">
                        <Check className="w-3 h-3 text-white" />
                      </div>
                    )}
                  </div>
                  
                  <p className="text-sm text-gray-500 mb-2">{service.description}</p>
                  
                  <div className="flex items-center justify-between">
                    <div className="flex items-baseline gap-2">
                      <span className="text-[#FF385C]">¥{service.price}</span>
                      <span className="text-sm text-gray-500">约{service.duration}分钟</span>
                    </div>
                    
                    <Dialog>
                      <DialogTrigger asChild>
                        <button
                          onClick={(e) => e.stopPropagation()}
                          className="text-gray-400 hover:text-gray-600 transition-colors"
                        >
                          <Info className="w-5 h-5" />
                        </button>
                      </DialogTrigger>
                      <DialogContent className="max-w-md">
                        <DialogHeader>
                          <DialogTitle>{service.name}</DialogTitle>
                        </DialogHeader>
                        <div className="space-y-4">
                          <div className="flex items-center gap-2">
                            <Badge variant="secondary">¥{service.price}</Badge>
                            <Badge variant="secondary">约{service.duration}分钟</Badge>
                          </div>
                          <p className="text-gray-600 leading-relaxed">{service.details}</p>
                        </div>
                      </DialogContent>
                    </Dialog>
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </div>

      {/* 固定底部操作栏 */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 p-4 shadow-lg">
        <div className="max-w-4xl mx-auto">
          {selectedService && (
            <div className="flex items-center justify-between mb-3">
              <span className="text-gray-600">已选：{selectedService.name}</span>
              <span className="text-[#FF385C]">¥{selectedService.price}</span>
            </div>
          )}
          <Button
            onClick={handleNext}
            disabled={!selectedService}
            className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-14 rounded-full shadow-lg disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            下一步
          </Button>
        </div>
      </div>
    </div>
  );
}