import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { NavBar, Loading, Button, Popup, Notify } from 'react-vant'
import { InfoO, Success } from '@react-vant/icons'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopServicesAsync } from '@/store/slices/shopsSlice'
import { setService } from '@/store/slices/bookingSlice'
import { Service } from '@/types'

const SelectServicePage: React.FC = () => {
  const { shopId } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { services, isLoading } = useAppSelector(state => state.shops)
  const { shop } = useAppSelector(state => state.booking)

  const [selectedService, setSelectedService] = useState<Service | null>(null)
  const [showDetail, setShowDetail] = useState(false)
  const [detailService, setDetailService] = useState<Service | null>(null)

  useEffect(() => {
    if (shopId) {
      dispatch(fetchShopServicesAsync(Number(shopId)))
    }
  }, [shopId, dispatch])

  const handleSelectService = (service: Service) => {
    // 单选机制：点击已选中的服务取消选中
    if (selectedService?.id === service.id) {
      setSelectedService(null)
    } else {
      setSelectedService(service)
    }
  }

  const handleShowDetail = (e: React.MouseEvent, service: Service) => {
    e.stopPropagation() // 阻止冒泡，避免触发卡片选中
    setDetailService(service)
    setShowDetail(true)
  }

  const handleNext = () => {
    if (!selectedService) {
      Notify.show({ type: 'warning', message: '请选择服务项目' })
      return
    }

    dispatch(setService(selectedService))
    Notify.show({ type: 'success', message: `已选择：${selectedService.name}` })
    navigate(`/booking/select-stylist/${shopId}`)
  }

  if (isLoading) {
    return <Loading size="24px" style={{ marginTop: '100px' }} />
  }

  return (
    <div style={{ paddingBottom: '80px', background: '#f8f9fa', minHeight: '100vh' }}>
      <NavBar
        title="选择服务"
        onClickLeft={() => navigate(-1)}
      />

      <div style={{ padding: '16px' }}>
        <div style={{ marginBottom: '16px', padding: '12px', background: 'white', borderRadius: '8px' }}>
          <h3 style={{ margin: 0, fontSize: '16px', color: '#333' }}>{shop?.name}</h3>
          <p style={{ margin: '8px 0 0', fontSize: '14px', color: '#999' }}>请选择需要的服务</p>
        </div>

        {services.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px 0', color: '#999' }}>
            暂无服务
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {services.map(service => {
              const isSelected = selectedService?.id === service.id
              return (
                <div
                  key={service.id}
                  onClick={() => handleSelectService(service)}
                  style={{
                    position: 'relative',
                    padding: '16px',
                    background: isSelected ? '#f0f4ff' : 'white',
                    borderRadius: '12px',
                    border: isSelected ? '2px solid #667eea' : '1px solid #f0f0f0',
                    cursor: 'pointer',
                    transition: 'all 0.3s',
                    transform: isSelected ? 'scale(0.98)' : 'scale(1)',
                  }}
                >
                  {/* 选中标记 */}
                  {isSelected && (
                    <div style={{
                      position: 'absolute',
                      top: '12px',
                      left: '12px',
                      width: '24px',
                      height: '24px',
                      borderRadius: '50%',
                      background: '#667eea',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}>
                      <Success style={{ color: 'white', fontSize: '14px' }} />
                    </div>
                  )}

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    {/* 服务图标 */}
                    <div style={{
                      width: '60px',
                      height: '60px',
                      borderRadius: '12px',
                      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '28px',
                      marginLeft: isSelected ? '24px' : '0'
                    }}>
                      ✂️
                    </div>

                    {/* 服务信息 */}
                    <div style={{ flex: 1, marginLeft: '16px' }}>
                      <h4 style={{ margin: '0 0 8px 0', fontSize: '16px', fontWeight: 'bold', color: '#333' }}>
                        {service.name}
                      </h4>
                      {service.description && (
                        <p style={{ margin: '0 0 8px 0', fontSize: '13px', color: '#999', lineHeight: '1.5' }}>
                          {service.description.length > 30
                            ? service.description.substring(0, 30) + '...'
                            : service.description}
                        </p>
                      )}
                      <div style={{ display: 'flex', gap: '16px', fontSize: '13px', color: '#666' }}>
                        <span>⏱ {service.duration}分钟</span>
                      </div>
                    </div>

                    {/* 价格和详情按钮 */}
                    <div style={{ marginLeft: '16px', textAlign: 'right', display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '8px' }}>
                      <div style={{ fontSize: '20px', fontWeight: 'bold', color: '#ff6b6b' }}>
                        ¥{service.price}
                      </div>
                      <div
                        onClick={(e) => handleShowDetail(e, service)}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '4px',
                          fontSize: '13px',
                          color: '#667eea',
                          padding: '4px 8px',
                          borderRadius: '4px',
                          background: '#f0f4ff'
                        }}
                      >
                        <InfoO style={{ fontSize: '14px' }} />
                        详情
                      </div>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* 底部操作栏 */}
      <div style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        padding: '12px 16px',
        background: 'white',
        borderTop: '1px solid #f0f0f0',
        boxShadow: '0 -2px 8px rgba(0,0,0,0.05)'
      }}>
        <div style={{ marginBottom: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ fontSize: '14px', color: '#666' }}>
            {selectedService ? `已选：${selectedService.name}` : '请选择服务'}
          </span>
          {selectedService && (
            <span style={{ fontSize: '20px', fontWeight: 'bold', color: '#ff6b6b' }}>
              ¥{selectedService.price}
            </span>
          )}
        </div>
        <Button
          block
          type="primary"
          disabled={!selectedService}
          onClick={handleNext}
          style={{
            height: '48px',
            fontSize: '16px',
            fontWeight: 'bold',
            background: selectedService ? '#667eea' : '#d0d0d0',
            border: 'none'
          }}
        >
          下一步
        </Button>
      </div>

      {/* 服务详情弹窗 */}
      <Popup
        visible={showDetail}
        onClose={() => setShowDetail(false)}
        position="bottom"
        round
        style={{ height: '60%' }}
      >
        {detailService && (
          <div style={{ padding: '24px' }}>
            <h2 style={{ margin: '0 0 16px 0', fontSize: '20px', color: '#333' }}>
              {detailService.name}
            </h2>

            <div style={{ marginBottom: '24px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
                <span style={{ color: '#999' }}>服务价格</span>
                <span style={{ fontSize: '24px', fontWeight: 'bold', color: '#ff6b6b' }}>
                  ¥{detailService.price}
                </span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#999' }}>服务时长</span>
                <span style={{ fontWeight: 'bold', color: '#333' }}>
                  约 {detailService.duration} 分钟
                </span>
              </div>
            </div>

            {detailService.description && (
              <div style={{ marginBottom: '24px' }}>
                <h3 style={{ margin: '0 0 12px 0', fontSize: '16px', color: '#333' }}>服务说明</h3>
                <p style={{ margin: 0, fontSize: '14px', color: '#666', lineHeight: '1.8' }}>
                  {detailService.description}
                </p>
              </div>
            )}

            <div style={{ marginBottom: '24px' }}>
              <h3 style={{ margin: '0 0 12px 0', fontSize: '16px', color: '#333' }}>适用人群</h3>
              <p style={{ margin: 0, fontSize: '14px', color: '#666', lineHeight: '1.8' }}>
                适合所有需要{detailService.name}服务的顾客
              </p>
            </div>

            <Button
              block
              type="primary"
              onClick={() => setShowDetail(false)}
              style={{
                height: '48px',
                fontSize: '16px',
                background: '#667eea',
                border: 'none'
              }}
            >
              知道了
            </Button>
          </div>
        )}
      </Popup>
    </div>
  )
}

export default SelectServicePage
