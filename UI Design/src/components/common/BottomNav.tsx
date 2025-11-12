import { Home, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: 'home' | 'profile';
  onTabChange: (tab: 'home' | 'profile') => void;
}

export default function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 shadow-lg">
      <div className="max-w-7xl mx-auto px-4">
        <div className="grid grid-cols-2 gap-1 h-16">
          {/* 首页 Tab */}
          <button
            onClick={() => onTabChange('home')}
            className={`flex flex-col items-center justify-center gap-1 transition-colors ${
              activeTab === 'home' 
                ? 'text-[#FF385C]' 
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            <Home className={`w-6 h-6 ${activeTab === 'home' ? 'fill-[#FF385C]' : ''}`} />
            <span className="text-xs">首页</span>
          </button>

          {/* 我的 Tab */}
          <button
            onClick={() => onTabChange('profile')}
            className={`flex flex-col items-center justify-center gap-1 transition-colors ${
              activeTab === 'profile' 
                ? 'text-[#FF385C]' 
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            <User className={`w-6 h-6 ${activeTab === 'profile' ? 'fill-[#FF385C]' : ''}`} />
            <span className="text-xs">我的</span>
          </button>
        </div>
      </div>
    </div>
  );
}
