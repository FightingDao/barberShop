import { useState } from 'react';
import Login from './components/auth/Login';
import Register from './components/auth/Register';
import ShopList from './components/shops/ShopList';
import ShopDetail from './components/shops/ShopDetail';
import ServiceSelection from './components/booking/ServiceSelection';
import StylistSelection from './components/booking/StylistSelection';
import TimeSelection from './components/booking/TimeSelection';
import OrderConfirmation from './components/booking/OrderConfirmation';
import BookingSuccess from './components/booking/BookingSuccess';
import MyAppointments from './components/appointments/MyAppointments';
import Profile from './components/profile/Profile';
import BottomNav from './components/common/BottomNav';

export type View = 
  | 'login' 
  | 'register' 
  | 'shopList' 
  | 'shopDetail' 
  | 'serviceSelection'
  | 'stylistSelection'
  | 'timeSelection'
  | 'orderConfirmation'
  | 'bookingSuccess'
  | 'myAppointments'
  | 'profile';

export interface BookingData {
  shopId?: string;
  shopName?: string;
  shopAddress?: string;
  serviceId?: string;
  serviceName?: string;
  servicePrice?: number;
  serviceDuration?: number;
  stylistId?: string | null;
  stylistName?: string;
  date?: string;
  time?: string;
  notes?: string;
  appointmentId?: string;
}

export default function App() {
  const [currentView, setCurrentView] = useState<View>('login');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [bookingData, setBookingData] = useState<BookingData>({});

  const navigate = (view: View, data?: Partial<BookingData>) => {
    if (data) {
      setBookingData(prev => ({ ...prev, ...data }));
    }
    setCurrentView(view);
  };

  const handleLogin = () => {
    setIsLoggedIn(true);
    navigate('shopList');
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setBookingData({});
    navigate('login');
  };

  const resetBooking = () => {
    setBookingData({});
  };

  // 如果未登录，只显示登录/注册页面
  if (!isLoggedIn && currentView !== 'register') {
    return <Login onLogin={handleLogin} onNavigateToRegister={() => navigate('register')} />;
  }

  if (!isLoggedIn && currentView === 'register') {
    return <Register onRegister={handleLogin} onNavigateToLogin={() => navigate('login')} />;
  }

  // 已登录，根据当前视图渲染对应页面
  // 确定是否显示底部导航栏
  const showBottomNav = ['shopList', 'profile'].includes(currentView);
  
  return (
    <div className="min-h-screen bg-gray-50">
      {currentView === 'shopList' && (
        <ShopList 
          onSelectShop={(shop) => navigate('shopDetail', { 
            shopId: shop.id, 
            shopName: shop.name, 
            shopAddress: shop.address 
          })}
        />
      )}
      
      {currentView === 'shopDetail' && (
        <ShopDetail 
          shopId={bookingData.shopId!}
          onBack={() => navigate('shopList')}
          onBookNow={() => navigate('serviceSelection')}
        />
      )}
      
      {currentView === 'serviceSelection' && (
        <ServiceSelection 
          shopId={bookingData.shopId!}
          onBack={() => navigate('shopDetail')}
          onNext={(service) => navigate('stylistSelection', {
            serviceId: service.id,
            serviceName: service.name,
            servicePrice: service.price,
            serviceDuration: service.duration
          })}
        />
      )}
      
      {currentView === 'stylistSelection' && (
        <StylistSelection 
          shopId={bookingData.shopId!}
          onBack={() => navigate('serviceSelection')}
          onNext={(stylist) => navigate('timeSelection', {
            stylistId: stylist.id,
            stylistName: stylist.name
          })}
        />
      )}
      
      {currentView === 'timeSelection' && (
        <TimeSelection 
          shopId={bookingData.shopId!}
          stylistId={bookingData.stylistId}
          serviceId={bookingData.serviceId!}
          onBack={() => navigate('stylistSelection')}
          onNext={(date, time) => navigate('orderConfirmation', { date, time })}
        />
      )}
      
      {currentView === 'orderConfirmation' && (
        <OrderConfirmation 
          bookingData={bookingData}
          onBack={() => navigate('timeSelection')}
          onConfirm={(notes, appointmentId) => navigate('bookingSuccess', { notes, appointmentId })}
        />
      )}
      
      {currentView === 'bookingSuccess' && (
        <BookingSuccess 
          bookingData={bookingData}
          onViewAppointments={() => {
            resetBooking();
            navigate('myAppointments');
          }}
          onBackToHome={() => {
            resetBooking();
            navigate('shopList');
          }}
        />
      )}
      
      {currentView === 'myAppointments' && (
        <MyAppointments 
          onBack={() => navigate('profile')}
        />
      )}
      
      {currentView === 'profile' && (
        <Profile 
          onNavigateToAppointments={() => navigate('myAppointments')}
          onLogout={handleLogout}
        />
      )}
      
      {/* 底部导航栏 - 只在首页和我的页面显示 */}
      {showBottomNav && (
        <BottomNav 
          activeTab={currentView === 'shopList' ? 'home' : 'profile'}
          onTabChange={(tab) => navigate(tab === 'home' ? 'shopList' : 'profile')}
        />
      )}
    </div>
  );
}