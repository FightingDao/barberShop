import { useState } from 'react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { Badge } from '../ui/badge';
import { ArrowLeft, MapPin, Clock, Phone, Star, Share2, Heart, Scissors } from 'lucide-react';

interface ShopDetailProps {
  shopId: string;
  onBack: () => void;
  onBookNow: () => void;
}

const MOCK_SHOP_DETAILS = {
  '1': {
    name: '艺剪造型',
    address: '朝阳区三里屯路11号',
    phone: '010-12345678',
    hours: '9:00 - 21:00',
    rating: 4.8,
    reviewCount: 328,
    avgPrice: 31,
    soldCount: 902,
    distance: '2.1km',
    images: [
      'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&h=500&fit=crop',
      'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800&h=500&fit=crop',
    ],
    services: [
      { id: 's1', name: '男士剪发', price: 91, duration: 45, icon: '✂️' },
      { id: 's2', name: '女士造型', price: 117, duration: 60, icon: '✂️' },
      { id: 's3', name: '洗剪吹套餐', price: 68, duration: 60, icon: '✂️' },
      { id: 's4', name: '烫发', price: 288, duration: 120, icon: '✂️' },
      { id: 's5', name: '染发', price: 388, duration: 150, icon: '✂️' },
      { id: 's6', name: '儿童理发', price: 28, duration: 30, icon: '✂️' },
    ],
    stylists: [
      { id: 'st1', name: '张师傅', avatar: '👨', title: '高级发型师' },
      { id: 'st2', name: '李师傅', avatar: '👨', title: '资深发型师' },
      { id: 'st3', name: '王师傅', avatar: '👩', title: '首席发型师' },
    ],
  },
};

export default function ShopDetail({ shopId, onBack, onBookNow }: ShopDetailProps) {
  const shop = MOCK_SHOP_DETAILS[shopId as keyof typeof MOCK_SHOP_DETAILS] || MOCK_SHOP_DETAILS['1'];
  const [isFavorite, setIsFavorite] = useState(false);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 固定头部导航栏 */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-sm border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 py-3 flex items-center justify-between">
          <button
            onClick={onBack}
            className="w-10 h-10 flex items-center justify-center hover:bg-gray-100 rounded-full transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          
          <h1 className="text-gray-900 absolute left-1/2 -translate-x-1/2">店铺详情</h1>
          
          <button
            onClick={() => setIsFavorite(!isFavorite)}
            className="w-10 h-10 flex items-center justify-center hover:bg-gray-100 rounded-full transition-colors"
          >
            <Heart 
              className={`w-5 h-5 transition-colors ${
                isFavorite ? 'fill-[#FF385C] text-[#FF385C]' : 'text-gray-700'
              }`} 
            />
          </button>
        </div>
      </header>

      {/* 主内容区域 - 添加顶部和底部padding */}
      <div className="pt-14 pb-24">
        {/* 店铺大图 */}
        <div className="relative w-full h-64 md:h-80">
          <img
            src={shop.images[0]}
            alt={shop.name}
            className="w-full h-full object-cover"
          />
        </div>

        <div className="max-w-4xl mx-auto px-4">
          {/* 店铺基本信息卡片 */}
          <Card className="p-5 mb-4 -mt-6 relative z-10 border-0 shadow-lg bg-white rounded-2xl">
            <div className="flex items-start justify-between mb-3">
              <h2 className="text-gray-900 flex-1">{shop.name}</h2>
              <Badge className="bg-[#FF385C] text-white hover:bg-[#FF385C] ml-2 shrink-0">
                营业中
              </Badge>
            </div>

            {/* 评分、人均、已售 */}
            <div className="flex items-center gap-4 mb-4 text-sm">
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                <span className="text-gray-900">{shop.rating}分</span>
              </div>
              <span className="text-gray-400">|</span>
              <span className="text-gray-600">人均 ¥{shop.avgPrice}</span>
              <span className="text-gray-400">|</span>
              <span className="text-gray-600">已售{shop.soldCount}</span>
            </div>

            {/* 地址 */}
            <div className="flex items-start gap-2 mb-3 p-3 bg-gray-50 rounded-lg">
              <MapPin className="w-5 h-5 text-[#FF385C] mt-0.5 shrink-0" />
              <div className="flex-1">
                <p className="text-gray-900 mb-1">{shop.address}</p>
                <p className="text-sm text-gray-500">距离您 {shop.distance}</p>
              </div>
            </div>

            {/* 营业时间 */}
            <div className="flex items-center gap-2 p-3 bg-gray-50 rounded-lg">
              <Clock className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-600">营业时间</p>
                <p className="text-gray-900">{shop.hours}</p>
              </div>
            </div>
          </Card>

          {/* 服务项目 */}
          <div className="mb-4">
            <h3 className="text-gray-900 mb-4 px-2">服务项目</h3>
            <div className="grid grid-cols-2 gap-3">
              {shop.services.map((service) => (
                <Card
                  key={service.id}
                  className="p-4 border-0 shadow-sm hover:shadow-md transition-shadow cursor-pointer bg-gradient-to-br from-pink-50 to-white"
                >
                  <div className="flex flex-col items-center text-center">
                    <div className="w-12 h-12 bg-pink-100 rounded-full flex items-center justify-center mb-3">
                      <Scissors className="w-6 h-6 text-[#FF385C]" />
                    </div>
                    <p className="text-gray-900 mb-2">{service.name}</p>
                    <p className="text-[#FF385C]">¥{service.price}</p>
                  </div>
                </Card>
              ))}
            </div>
          </div>

          {/* 理发师团队 */}
          <div className="mb-6">
            <h3 className="text-gray-900 mb-4 px-2">理发师团队</h3>
            <Card className="p-5 border-0 shadow-sm">
              <div className="grid grid-cols-3 gap-4">
                {shop.stylists.map((stylist) => (
                  <div
                    key={stylist.id}
                    className="flex flex-col items-center"
                  >
                    <div className="w-16 h-16 bg-gradient-to-br from-pink-100 to-purple-100 rounded-full flex items-center justify-center text-3xl mb-2">
                      {stylist.avatar}
                    </div>
                    <p className="text-sm text-gray-900 mb-1">{stylist.name}</p>
                    <p className="text-xs text-gray-500">{stylist.title}</p>
                  </div>
                ))}
              </div>
            </Card>
          </div>
        </div>
      </div>

      {/* 固定底部预约按钮 */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 p-4 shadow-lg">
        <div className="max-w-4xl mx-auto">
          <Button
            onClick={onBookNow}
            className="w-full bg-[#FF385C] hover:bg-[#E31C5F] text-white h-14 rounded-full shadow-lg"
          >
            立即预约
          </Button>
        </div>
      </div>
    </div>
  );
}