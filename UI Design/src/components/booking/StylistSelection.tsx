import { useState } from 'react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { Badge } from '../ui/badge';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '../ui/dialog';
import { ArrowLeft, Check, Award, Sparkles } from 'lucide-react';

interface Stylist {
  id: string | null;
  name: string;
  avatar: string;
  title: string;
  experience?: number;
  specialty?: string[];
  status: 'available' | 'busy' | 'off';
  description?: string;
}

interface StylistSelectionProps {
  shopId: string;
  onBack: () => void;
  onNext: (stylist: Stylist) => void;
}

const STYLISTS: Stylist[] = [
  {
    id: null,
    name: '不指定理发师',
    avatar: '🎲',
    title: '系统自动分配',
    status: 'available',
  },
  {
    id: 'st1',
    name: '张师傅',
    avatar: '👨',
    title: '高级发型师',
    experience: 8,
    specialty: ['男士理发', '烫染', '造型设计'],
    status: 'available',
    description: '擅长各类男士发型设计，对流行趋势把握精准，曾多次获得区域发型设计大奖。',
  },
  {
    id: 'st2',
    name: '李师傅',
    avatar: '👨',
    title: '资深发型师',
    experience: 12,
    specialty: ['烫发', '染发', '护理'],
    status: 'available',
    description: '在烫染领域有着丰富经验，精通各类烫发技术，能够根据顾客需求打造理想发型。',
  },
  {
    id: 'st3',
    name: '王师傅',
    avatar: '👩',
    title: '首席发型师',
    experience: 15,
    specialty: ['女士造型', '新娘妆发', '时尚染发'],
    status: 'available',
    description: '首席发型师，专注女士发型设计，擅长打造优雅、时尚的造型，深受顾客喜爱。',
  },
  {
    id: 'st4',
    name: '赵师傅',
    avatar: '👨',
    title: '高级发型师',
    experience: 6,
    specialty: ['剪发', '造型'],
    status: 'busy',
    description: '年轻有活力的发型师，紧跟潮流趋势，擅长为年轻顾客打造时尚个性的发型。',
  },
];

export default function StylistSelection({ shopId, onBack, onNext }: StylistSelectionProps) {
  const [selectedStylist, setSelectedStylist] = useState<Stylist | null>(null);
  const [detailStylist, setDetailStylist] = useState<Stylist | null>(null);

  const handleSelectStylist = (stylist: Stylist) => {
    if (stylist.status === 'busy') return;
    setSelectedStylist(stylist);
  };

  const handleNext = () => {
    if (selectedStylist) {
      onNext(selectedStylist);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'available':
        return <Badge className="bg-green-100 text-green-700 hover:bg-green-100">可约</Badge>;
      case 'busy':
        return <Badge className="bg-red-100 text-red-700 hover:bg-red-100">已约满</Badge>;
      case 'off':
        return <Badge className="bg-gray-100 text-gray-700 hover:bg-gray-100">休息中</Badge>;
      default:
        return null;
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
          <h1 className="text-gray-900 ml-4">选择理发师</h1>
        </div>
      </header>

      {/* 理发师列表 */}
      <div className="max-w-4xl mx-auto px-4 py-6 pt-20 pb-32">
        <p className="text-gray-600 mb-6">选择您喜欢的理发师，或由系统自动分配</p>

        <div className="space-y-4">
          {/* 不指定理发师选项 */}
          <Card
            onClick={() => handleSelectStylist(STYLISTS[0])}
            className={`p-4 cursor-pointer transition-all duration-200 border-2 ${
              selectedStylist?.id === null
                ? 'border-[#FF385C] bg-pink-50/50'
                : 'border-dashed border-gray-300 hover:border-gray-400'
            }`}
          >
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 bg-gradient-to-br from-purple-100 to-pink-100 rounded-full flex items-center justify-center text-3xl shrink-0">
                {STYLISTS[0].avatar}
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="text-gray-900">{STYLISTS[0].name}</h3>
                  {selectedStylist?.id === null && (
                    <div className="w-5 h-5 bg-[#FF385C] rounded-full flex items-center justify-center">
                      <Check className="w-3 h-3 text-white" />
                    </div>
                  )}
                </div>
                <p className="text-sm text-gray-500">{STYLISTS[0].title}</p>
              </div>
            </div>
          </Card>

          {/* 具体理发师列表 */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {STYLISTS.slice(1).map((stylist) => (
              <Card
                key={stylist.id}
                onClick={() => handleSelectStylist(stylist)}
                className={`p-4 transition-all duration-200 border-2 ${
                  stylist.status === 'busy'
                    ? 'opacity-50 cursor-not-allowed'
                    : selectedStylist?.id === stylist.id
                    ? 'border-[#FF385C] bg-pink-50/50 cursor-pointer'
                    : 'border-transparent hover:border-gray-200 cursor-pointer'
                }`}
              >
                <div className="flex items-start gap-4">
                  {/* 头像 */}
                  <div 
                    onClick={(e) => {
                      if (stylist.status !== 'busy') {
                        e.stopPropagation();
                        setDetailStylist(stylist);
                      }
                    }}
                    className="w-16 h-16 bg-gradient-to-br from-pink-100 to-purple-100 rounded-full flex items-center justify-center text-3xl shrink-0 cursor-pointer hover:scale-105 transition-transform"
                  >
                    {stylist.avatar}
                  </div>

                  {/* 信息 */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-1">
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-gray-900">{stylist.name}</h3>
                          {selectedStylist?.id === stylist.id && (
                            <div className="w-5 h-5 bg-[#FF385C] rounded-full flex items-center justify-center">
                              <Check className="w-3 h-3 text-white" />
                            </div>
                          )}
                        </div>
                        <p className="text-sm text-gray-500">{stylist.title}</p>
                      </div>
                      {getStatusBadge(stylist.status)}
                    </div>

                    {stylist.experience && (
                      <div className="flex items-center gap-1 text-sm text-gray-600 mb-2">
                        <Award className="w-4 h-4" />
                        <span>从业{stylist.experience}年</span>
                      </div>
                    )}

                    {stylist.specialty && (
                      <div className="flex flex-wrap gap-1">
                        {stylist.specialty.slice(0, 3).map((item, index) => (
                          <Badge key={index} variant="secondary" className="text-xs">
                            {item}
                          </Badge>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>
      </div>

      {/* 理发师详情弹窗 */}
      <Dialog open={!!detailStylist} onOpenChange={(open) => !open && setDetailStylist(null)}>
        <DialogContent className="max-w-md">
          {detailStylist && (
            <>
              <DialogHeader>
                <DialogTitle>理发师详情</DialogTitle>
              </DialogHeader>
              <div className="space-y-4">
                {/* 头像和基本信息 */}
                <div className="flex items-center gap-4">
                  <div className="w-20 h-20 bg-gradient-to-br from-pink-100 to-purple-100 rounded-full flex items-center justify-center text-4xl">
                    {detailStylist.avatar}
                  </div>
                  <div>
                    <h3 className="text-gray-900 mb-1">{detailStylist.name}</h3>
                    <p className="text-gray-600 mb-2">{detailStylist.title}</p>
                    {getStatusBadge(detailStylist.status)}
                  </div>
                </div>

                {/* 从业年限 */}
                {detailStylist.experience && (
                  <div className="flex items-center gap-2 p-3 bg-gray-50 rounded-lg">
                    <Award className="w-5 h-5 text-[#FF385C]" />
                    <span className="text-gray-700">从业经验：{detailStylist.experience}年</span>
                  </div>
                )}

                {/* 擅长项目 */}
                {detailStylist.specialty && (
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <Sparkles className="w-5 h-5 text-[#FF385C]" />
                      <span className="text-gray-700">擅长项目</span>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {detailStylist.specialty.map((item, index) => (
                        <Badge key={index} variant="secondary">
                          {item}
                        </Badge>
                      ))}
                    </div>
                  </div>
                )}

                {/* 个人简介 */}
                {detailStylist.description && (
                  <div>
                    <p className="text-gray-600 leading-relaxed">{detailStylist.description}</p>
                  </div>
                )}
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* 固定底部操作栏 */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 p-4 shadow-lg">
        <div className="max-w-4xl mx-auto">
          {selectedStylist && (
            <div className="flex items-center justify-between mb-3">
              <span className="text-gray-600">
                已选：{selectedStylist.name}
              </span>
            </div>
          )}
          <Button
            onClick={handleNext}
            disabled={!selectedStylist}
            className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-14 rounded-full shadow-lg disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            下一步
          </Button>
        </div>
      </div>
    </div>
  );
}