import { useState } from 'react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { Badge } from '../ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '../ui/dialog';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '../ui/alert-dialog';
import { ArrowLeft, MapPin, Scissors, User, Calendar, Clock, Phone, Copy } from 'lucide-react';

interface Appointment {
  id: string;
  shopName: string;
  shopAddress: string;
  shopPhone: string;
  serviceName: string;
  servicePrice: number;
  stylistName: string;
  date: string;
  time: string;
  endTime: string;
  status: 'pending' | 'completed' | 'cancelled';
  appointmentCode: string;
  canCancel: boolean;
}

interface MyAppointmentsProps {
  onBack: () => void;
}

const MOCK_APPOINTMENTS: Appointment[] = [
  {
    id: '1',
    shopName: '艺剪造型',
    shopAddress: '朝阳区三里屯路11号',
    shopPhone: '010-12345678',
    serviceName: '洗剪吹套餐',
    servicePrice: 68,
    stylistName: '张师傅',
    date: '2025-11-15',
    time: '14:00',
    endTime: '15:00',
    status: 'pending',
    appointmentCode: 'A1B2C3D4',
    canCancel: true,
  },
  {
    id: '2',
    shopName: '时尚发艺',
    shopAddress: '海淀区中关村大街1号',
    shopPhone: '010-87654321',
    serviceName: '经典剪发',
    servicePrice: 38,
    stylistName: '李师傅',
    date: '2025-11-18',
    time: '10:00',
    endTime: '10:45',
    status: 'pending',
    appointmentCode: 'E5F6G7H8',
    canCancel: true,
  },
  {
    id: '3',
    shopName: '名匠理发',
    shopAddress: '东城区王府井大街88号',
    shopPhone: '010-11223344',
    serviceName: '烫发',
    servicePrice: 288,
    stylistName: '王师傅',
    date: '2025-11-05',
    time: '13:00',
    endTime: '15:00',
    status: 'completed',
    appointmentCode: 'I9J0K1L2',
    canCancel: false,
  },
];

export default function MyAppointments({ onBack }: MyAppointmentsProps) {
  const [appointments, setAppointments] = useState(MOCK_APPOINTMENTS);
  const [selectedTab, setSelectedTab] = useState<'pending' | 'completed'>('pending');
  const [detailAppointment, setDetailAppointment] = useState<Appointment | null>(null);
  const [cancelAppointment, setCancelAppointment] = useState<Appointment | null>(null);
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const pendingAppointments = appointments.filter(a => a.status === 'pending');
  const completedAppointments = appointments.filter(a => a.status === 'completed');

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekDay = weekDays[date.getDay()];
    return `${month}月${day}日 ${weekDay}`;
  };

  const handleCancelConfirm = () => {
    if (cancelAppointment) {
      setAppointments(prev =>
        prev.map(a =>
          a.id === cancelAppointment.id
            ? { ...a, status: 'cancelled' as const }
            : a
        ).filter(a => a.status !== 'cancelled')
      );
      setCancelAppointment(null);
    }
  };

  const copyCode = (code: string, id: string) => {
    navigator.clipboard.writeText(code);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const renderAppointmentCard = (appointment: Appointment) => (
    <Card key={appointment.id} className="p-4 border-0 shadow-md hover:shadow-lg transition-shadow">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h3 className="text-gray-900 mb-1">{appointment.shopName}</h3>
          <p className="text-sm text-gray-500">
            {appointment.serviceName} | {appointment.stylistName}
          </p>
        </div>
        {appointment.status === 'pending' && (
          <Badge className="bg-green-100 text-green-700 hover:bg-green-100">
            待服务
          </Badge>
        )}
        {appointment.status === 'completed' && (
          <Badge className="bg-gray-100 text-gray-700 hover:bg-gray-100">
            已完成
          </Badge>
        )}
      </div>

      <div className="flex items-center gap-2 text-sm text-gray-600 mb-4">
        <Clock className="w-4 h-4" />
        <span>{formatDate(appointment.date)} {appointment.time}</span>
      </div>

      <div className="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          className="flex-1"
          onClick={() => setDetailAppointment(appointment)}
        >
          查看详情
        </Button>
        {appointment.status === 'pending' && appointment.canCancel && (
          <Button
            variant="outline"
            size="sm"
            className="flex-1 text-red-600 hover:text-red-700 hover:bg-red-50"
            onClick={() => setCancelAppointment(appointment)}
          >
            取消预约
          </Button>
        )}
        {appointment.status === 'pending' && !appointment.canCancel && (
          <Button
            variant="outline"
            size="sm"
            className="flex-1"
            disabled
          >
            无法取消
          </Button>
        )}
      </div>
    </Card>
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 顶部导航 */}
      <header className="bg-white border-b sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center gap-4">
          <button
            onClick={onBack}
            className="w-10 h-10 flex items-center justify-center hover:bg-gray-100 rounded-full transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-gray-900">我的预约</h1>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 py-6">
        <Tabs value={selectedTab} onValueChange={(v) => setSelectedTab(v as 'pending' | 'completed')}>
          <TabsList className="grid w-full grid-cols-2 mb-6">
            <TabsTrigger value="pending">
              待服务
              {pendingAppointments.length > 0 && (
                <span className="ml-2 px-2 py-0.5 bg-[#FF385C] text-white text-xs rounded-full">
                  {pendingAppointments.length}
                </span>
              )}
            </TabsTrigger>
            <TabsTrigger value="completed">已完成</TabsTrigger>
          </TabsList>

          {/* 待服务列表 */}
          <TabsContent value="pending" className="space-y-4">
            {pendingAppointments.length > 0 ? (
              pendingAppointments.map(renderAppointmentCard)
            ) : (
              <Card className="p-12 text-center border-0 shadow-md">
                <div className="text-6xl mb-4">📅</div>
                <p className="text-gray-500 mb-4">暂无预约</p>
                <Button onClick={onBack} className="bg-[#FF385C] hover:bg-[#E31C5F] text-white">
                  去预约
                </Button>
              </Card>
            )}
          </TabsContent>

          {/* 已完成列表 */}
          <TabsContent value="completed" className="space-y-4">
            {completedAppointments.length > 0 ? (
              completedAppointments.map(renderAppointmentCard)
            ) : (
              <Card className="p-12 text-center border-0 shadow-md">
                <div className="text-6xl mb-4">📦</div>
                <p className="text-gray-500">暂无历史记录</p>
              </Card>
            )}
          </TabsContent>
        </Tabs>
      </div>

      {/* 预约详情弹窗 */}
      <Dialog open={!!detailAppointment} onOpenChange={(open) => !open && setDetailAppointment(null)}>
        <DialogContent className="max-w-md max-h-[90vh] overflow-y-auto">
          {detailAppointment && (
            <>
              <DialogHeader>
                <DialogTitle>预约详情</DialogTitle>
              </DialogHeader>
              
              <div className="space-y-4">
                {/* 预约码 */}
                <div className="p-4 bg-gray-50 rounded-lg text-center">
                  <p className="text-sm text-gray-600 mb-2">预约码</p>
                  <div className="text-2xl font-mono text-gray-900 mb-2">
                    {detailAppointment.appointmentCode}
                  </div>
                  <button
                    onClick={() => copyCode(detailAppointment.appointmentCode, detailAppointment.id)}
                    className="inline-flex items-center gap-1 text-sm text-[#FF385C] hover:underline"
                  >
                    {copiedId === detailAppointment.id ? (
                      <>已复制</>
                    ) : (
                      <>
                        <Copy className="w-3 h-3" />
                        复制
                      </>
                    )}
                  </button>
                </div>

                {/* 详细信息 */}
                <div className="space-y-3">
                  <div className="flex items-start gap-3">
                    <MapPin className="w-5 h-5 text-[#FF385C] mt-0.5 shrink-0" />
                    <div className="flex-1">
                      <p className="text-gray-900 mb-1">{detailAppointment.shopName}</p>
                      <p className="text-sm text-gray-500">{detailAppointment.shopAddress}</p>
                    </div>
                  </div>

                  <div className="border-t border-gray-100"></div>

                  <div className="flex items-start gap-3">
                    <Scissors className="w-5 h-5 text-[#FF385C] mt-0.5 shrink-0" />
                    <div className="flex-1">
                      <p className="text-gray-900 mb-1">{detailAppointment.serviceName}</p>
                      <p className="text-sm text-gray-500">¥{detailAppointment.servicePrice}</p>
                    </div>
                  </div>

                  <div className="border-t border-gray-100"></div>

                  <div className="flex items-center gap-3">
                    <User className="w-5 h-5 text-[#FF385C] shrink-0" />
                    <p className="text-gray-900">{detailAppointment.stylistName}</p>
                  </div>

                  <div className="border-t border-gray-100"></div>

                  <div className="flex items-start gap-3">
                    <Calendar className="w-5 h-5 text-[#FF385C] mt-0.5 shrink-0" />
                    <div className="flex-1">
                      <p className="text-gray-900 mb-1">{formatDate(detailAppointment.date)}</p>
                      <p className="text-sm text-gray-500">
                        {detailAppointment.time} - {detailAppointment.endTime}
                      </p>
                    </div>
                  </div>
                </div>

                {/* 联系店铺 */}
                <div className="pt-4 border-t border-gray-100">
                  <a
                    href={`tel:${detailAppointment.shopPhone}`}
                    className="flex items-center justify-center gap-2 text-[#FF385C] hover:underline"
                  >
                    <Phone className="w-5 h-5" />
                    <span>联系店铺：{detailAppointment.shopPhone}</span>
                  </a>
                </div>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* 取消预约确认弹窗 */}
      <AlertDialog open={!!cancelAppointment} onOpenChange={(open) => !open && setCancelAppointment(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>确认取消预约？</AlertDialogTitle>
            <AlertDialogDescription>
              取消后需要重新预约。如果您确定不需要此次服务，请点击确认取消。
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>再想想</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleCancelConfirm}
              className="bg-red-600 hover:bg-red-700"
            >
              确认取消
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
