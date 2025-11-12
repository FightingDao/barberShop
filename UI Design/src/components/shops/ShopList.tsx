import { useState } from "react";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { Card } from "../ui/card";
import { Badge } from "../ui/badge";
import { Search, MapPin, Clock } from "lucide-react";

interface Shop {
  id: string;
  name: string;
  address: string;
  distance: string;
  rating: number;
  reviewCount: number;
  avgPrice: number;
  status: "open" | "closed";
  image: string;
}

interface ShopListProps {
  onSelectShop: (shop: Shop) => void;
}

const MOCK_SHOPS: Shop[] = [
  {
    id: "1",
    name: "艺剪造型",
    address: "朝阳区三里屯路11号",
    distance: "500m",
    rating: 4.8,
    reviewCount: 328,
    avgPrice: 88,
    status: "open",
    image:
      "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400&h=300&fit=crop",
  },
  {
    id: "2",
    name: "时尚发艺",
    address: "海淀区中关村大街1号",
    distance: "1.2km",
    rating: 4.6,
    reviewCount: 256,
    avgPrice: 68,
    status: "open",
    image:
      "https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400&h=300&fit=crop",
  },
  {
    id: "3",
    name: "名匠理发",
    address: "东城区王府井大街88号",
    distance: "2.5km",
    rating: 4.9,
    reviewCount: 512,
    avgPrice: 128,
    status: "open",
    image:
      "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400&h=300&fit=crop",
  },
  {
    id: "4",
    name: "潮流发型",
    address: "西城区西单北大街120号",
    distance: "3km",
    rating: 4.5,
    reviewCount: 189,
    avgPrice: 58,
    status: "closed",
    image:
      "https://images.unsplash.com/photo-1521490878223-e3c3e0f2e0c5?w=400&h=300&fit=crop",
  },
];

export default function ShopList({
  onSelectShop,
}: ShopListProps) {
  const [searchQuery, setSearchQuery] = useState("");

  const filteredShops = MOCK_SHOPS.filter(
    (shop) =>
      shop.name
        .toLowerCase()
        .includes(searchQuery.toLowerCase()) ||
      shop.address
        .toLowerCase()
        .includes(searchQuery.toLowerCase()),
  );

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      {/* 固定顶部区域 */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-br from-pink-400 to-rose-400 pt-8 pb-6 px-4 shadow-md">
        <div className="max-w-7xl mx-auto">
          {/* Slogan */}
          <div className="text-center mb-6">
            <h1 className="text-white text-3xl mb-2">
              发现美好
            </h1>
            <p className="text-white/90">
              找到最适合你的理发店
            </p>
          </div>

          {/* 搜索栏 */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <Input
              type="text"
              placeholder="搜索理发店..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 h-12 bg-white border-0 shadow-lg rounded-full"
            />
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 pt-52 pb-6">
        {/* 店铺列表 */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredShops.map((shop) => (
            <Card
              key={shop.id}
              onClick={() => onSelectShop(shop)}
              className="overflow-hidden cursor-pointer transition-all duration-300 border-0 group rounded-2xl shadow-lg"
            >
              <div className="relative h-44 overflow-hidden">
                <img
                  src={shop.image}
                  alt={shop.name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                {shop.status === "closed" && (
                  <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                    <Badge
                      variant="secondary"
                      className="bg-white/90"
                    >
                      已打烊
                    </Badge>
                  </div>
                )}
                <div className="absolute top-3 right-3">
                  <Badge className="bg-white/90 text-gray-900 hover:bg-white/90 shadow-md">
                    <MapPin className="w-3 h-3 mr-1" />
                    {shop.distance}
                  </Badge>
                </div>
              </div>

              <div className="p-4">
                <h3 className="text-gray-900 mb-2">
                  {shop.name}
                </h3>

                <div className="flex items-center gap-1 text-sm text-gray-600 mb-3">
                  <MapPin className="w-4 h-4 shrink-0" />
                  <span className="truncate">
                    {shop.address}
                  </span>
                </div>

                <div className="flex items-center justify-between">
                  <div className="text-[#FF385C]">
                    ¥{shop.avgPrice}起
                  </div>

                  {shop.status === "open" && (
                    <div className="flex items-center gap-1 text-sm text-green-600">
                      <Clock className="w-4 h-4" />
                      <span>营业中</span>
                    </div>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>

        {filteredShops.length === 0 && (
          <div className="text-center py-20">
            <p className="text-gray-500 mb-4">
              未找到相关理发店
            </p>
            <Button
              variant="outline"
              onClick={() => setSearchQuery("")}
            >
              清除搜索
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}