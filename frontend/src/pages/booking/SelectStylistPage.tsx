import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { NavBar, Loading, Toast, Button, Popup } from 'react-vant'
import { Success } from '@react-vant/icons'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopStylistsAsync } from '@/store/slices/shopsSlice'
import { setStylist } from '@/store/slices/bookingSlice'
import { Stylist } from '@/types'

const SelectStylistPage: React.FC = () => {
  const { shopId } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { stylists, isLoading } = useAppSelector(state => state.shops)
  const { shop, service } = useAppSelector(state => state.booking)

  const [selectedStylist, setSelectedStylist] = useState<Stylist | null | 'none'>(null)
  const [showDetail, setShowDetail] = useState(false)
  const [detailStylist, setDetailStylist] = useState<Stylist | null>(null)

  useEffect(() => {
    if (shopId) {
      dispatch(fetchShopStylistsAsync(Number(shopId)))
    }
  }, [shopId, dispatch])

  const handleSelectStylist = (stylist: Stylist | 'none') => {
    // 单选机制：点击已选中的取消选中
    if (selectedStylist === stylist ||
        (selectedStylist === 'none' && stylist === 'none')) {
      setSelectedStylist(null)
    } else {
      setSelectedStylist(stylist)
    }
  }

  const handleShowDetail = (e: React.MouseEvent, stylist: Stylist) => {
    e.stopPropagation()
    setDetailStylist(stylist)
    setShowDetail(true)
  }

  const handleNext = () => {
    if (!selectedStylist) {
      Toast.info('请选择理发师')
      return
    }

    const stylistValue = selectedStylist === 'none' ? null : selectedStylist
    dispatch(setStylist(stylistValue))

    if (stylistValue) {
      Toast.info(`已选择：${stylistValue.name}`)
    } else {
      Toast.info('不指定理发师')
    }

    navigate(`/booking/select-time/${shopId}`)
  }

  const getStylistStatus = (stylist: Stylist): { text: string; color: string; canSelect: boolean } => {
    switch (stylist.status) {
      case 'active':
        return { text: '可约', color: '#07c160', canSelect: true }
      case 'busy':
        return { text: '已约满', color: '#ff6b6b', canSelect: false }
      case 'inactive':
        return { text: '休息中', color: '#999', canSelect: false }
      default:
        return { text: '可约', color: '#07c160', canSelect: true }
    }
  }

  if (isLoading) {
    return <Loading size="24px" style={{ marginTop: '100px' }} />
  }

  return (
    <div style={{ paddingBottom: '80px', background: '#f8f9fa', minHeight: '100vh' }}>
      <NavBar
        title="选择理发师"
        onClickLeft={() => navigate(-1)}
      />

      <div style={{ padding: '16px' }}>
        {/* 预约信息提示 */}
        <div style={{ marginBottom: '16px', padding: '12px', background: 'white', borderRadius: '8px' }}>
          <h3 style={{ margin: 0, fontSize: '16px', color: '#333' }}>{shop?.name}</h3>
          <p style={{ margin: '8px 0 0', fontSize: '14px', color: '#999' }}>
            服务：{service?.name} | ¥{service?.price}
          </p>
        </div>

        {/* 不指定理发师选项 */}
        <div
          onClick={() => handleSelectStylist('none')}
          style={{
            position: 'relative',
            padding: '16px',
            marginBottom: '16px',
            background: selectedStylist === 'none' ? '#f0f4ff' : 'white',
            borderRadius: '12px',
            border: selectedStylist === 'none' ? '2px solid #667eea' : '2px dashed #d0d0d0',
            cursor: 'pointer',
            transition: 'all 0.3s'
          }}
        >
          {selectedStylist === 'none' && (
            <div style={{
              position: 'absolute',
              top: '12px',
              right: '12px',
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

          <div style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{
              width: '60px',
              height: '60px',
              borderRadius: '50%',
              background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '28px'
            }}>
              👤
            </div>
            <div style={{ marginLeft: '16px', flex: 1 }}>
              <h4 style={{ margin: '0 0 8px 0', fontSize: '16px', fontWeight: 'bold', color: '#333' }}>
                不指定理发师
              </h4>
              <p style={{ margin: 0, fontSize: '13px', color: '#999' }}>
                由店铺安排合适的理发师为您服务
              </p>
            </div>
          </div>
        </div>

        {/* 理发师列表 */}
        <div style={{ marginBottom: '16px' }}>
          <h3 style={{ margin: '0 0 12px 0', fontSize: '15px', color: '#666' }}>或选择指定理发师</h3>
        </div>

        {stylists.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px 0', color: '#999', background: 'white', borderRadius: '12px' }}>
            暂无理发师信息
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {stylists.map(stylist => {
              const statusInfo = getStylistStatus(stylist)
              const isSelected = selectedStylist && typeof selectedStylist !== 'string' && selectedStylist.id === stylist.id
              const canSelect = statusInfo.canSelect

              return (
                <div
                  key={stylist.id}
                  onClick={() => canSelect && handleSelectStylist(stylist)}
                  style={{
                    position: 'relative',
                    padding: '16px',
                    background: isSelected ? '#f0f4ff' : 'white',
                    borderRadius: '12px',
                    border: isSelected ? '2px solid #667eea' : '1px solid #f0f0f0',
                    cursor: canSelect ? 'pointer' : 'not-allowed',
                    opacity: canSelect ? 1 : 0.6,
                    transition: 'all 0.3s',
                    transform: isSelected ? 'scale(0.98)' : 'scale(1)'
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
                      justifyContent: 'center',
                      zIndex: 1
                    }}>
                      <Success style={{ color: 'white', fontSize: '14px' }} />
                    </div>
                  )}

                  {/* 状态徽章 */}
                  <div style={{
                    position: 'absolute',
                    top: '12px',
                    right: '12px',
                    padding: '4px 12px',
                    borderRadius: '12px',
                    background: statusInfo.color,
                    color: 'white',
                    fontSize: '12px',
                    fontWeight: 'bold'
                  }}>
                    {statusInfo.text}
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center' }}>
                    {/* 头像 */}
                    <div
                      onClick={(e) => canSelect && handleShowDetail(e, stylist)}
                      style={{
                        width: '60px',
                        height: '60px',
                        borderRadius: '50%',
                        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '28px',
                        marginLeft: isSelected ? '24px' : '0',
                        cursor: canSelect ? 'pointer' : 'not-allowed',
                        transition: 'all 0.3s'
                      }}
                    >
                      👨‍🦰
                    </div>

                    {/* 理发师信息 */}
                    <div style={{ marginLeft: '16px', flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '8px' }}>
                        <h4 style={{ margin: 0, fontSize: '16px', fontWeight: 'bold', color: '#333' }}>
                          {stylist.name}
                        </h4>
                        {stylist.level && (
                          <span style={{
                            marginLeft: '8px',
                            padding: '2px 8px',
                            fontSize: '12px',
                            background: '#667eea',
                            color: 'white',
                            borderRadius: '4px'
                          }}>
                            {stylist.level}
                          </span>
                        )}
                      </div>

                      {stylist.title && (
                        <p style={{ margin: '0 0 4px 0', fontSize: '13px', color: '#999' }}>
                          {stylist.title}
                        </p>
                      )}

                      <div style={{ display: 'flex', gap: '12px', fontSize: '13px', color: '#666' }}>
                        {stylist.experience && (
                          <span>🎓 {stylist.experience}年经验</span>
                        )}
                        {stylist.specialty && (
                          <span>✨ 擅长：{stylist.specialty}</span>
                        )}
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
        <div style={{ marginBottom: '8px', fontSize: '14px', color: '#666' }}>
          {selectedStylist === 'none' && '已选：不指定理发师'}
          {selectedStylist && typeof selectedStylist !== 'string' && `已选：${selectedStylist.name}`}
          {!selectedStylist && '请选择理发师'}
        </div>
        <Button
          block
          type="primary"
          disabled={!selectedStylist}
          onClick={handleNext}
          style={{
            height: '48px',
            fontSize: '16px',
            fontWeight: 'bold',
            background: selectedStylist ? '#667eea' : '#d0d0d0',
            border: 'none'
          }}
        >
          下一步
        </Button>
      </div>

      {/* 理发师详情弹窗 */}
      <Popup
        visible={showDetail}
        onClose={() => setShowDetail(false)}
        position="bottom"
        round
        style={{ height: '70%' }}
      >
        {detailStylist && (
          <div style={{ padding: '24px' }}>
            {/* 头像和基本信息 */}
            <div style={{ textAlign: 'center', marginBottom: '24px' }}>
              <div style={{
                width: '100px',
                height: '100px',
                borderRadius: '50%',
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '48px',
                margin: '0 auto 16px'
              }}>
                👨‍🦰
              </div>
              <h2 style={{ margin: '0 0 8px 0', fontSize: '22px', color: '#333' }}>
                {detailStylist.name}
              </h2>
              {detailStylist.level && (
                <span style={{
                  padding: '4px 12px',
                  fontSize: '14px',
                  background: '#667eea',
                  color: 'white',
                  borderRadius: '6px'
                }}>
                  {detailStylist.level}
                </span>
              )}
            </div>

            {/* 详细信息 */}
            <div style={{ marginBottom: '24px' }}>
              {detailStylist.title && (
                <div style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  marginBottom: '16px',
                  padding: '12px',
                  background: '#f8f9fa',
                  borderRadius: '8px'
                }}>
                  <span style={{ color: '#999' }}>职称</span>
                  <span style={{ fontWeight: 'bold', color: '#333' }}>
                    {detailStylist.title}
                  </span>
                </div>
              )}

              {detailStylist.experience && (
                <div style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  marginBottom: '16px',
                  padding: '12px',
                  background: '#f8f9fa',
                  borderRadius: '8px'
                }}>
                  <span style={{ color: '#999' }}>从业年限</span>
                  <span style={{ fontWeight: 'bold', color: '#333' }}>
                    {detailStylist.experience}年
                  </span>
                </div>
              )}

              {detailStylist.specialty && (
                <div style={{ marginBottom: '16px' }}>
                  <h3 style={{ margin: '0 0 12px 0', fontSize: '16px', color: '#333' }}>擅长项目</h3>
                  <div style={{
                    padding: '12px',
                    background: '#f8f9fa',
                    borderRadius: '8px',
                    color: '#666',
                    lineHeight: '1.6'
                  }}>
                    {detailStylist.specialty}
                  </div>
                </div>
              )}
            </div>

            {/* 服务特色 */}
            <div style={{ marginBottom: '24px' }}>
              <h3 style={{ margin: '0 0 12px 0', fontSize: '16px', color: '#333' }}>服务特色</h3>
              <ul style={{
                margin: 0,
                paddingLeft: '20px',
                fontSize: '14px',
                color: '#666',
                lineHeight: '1.8'
              }}>
                <li>注重细节，精益求精</li>
                <li>根据顾客脸型推荐合适发型</li>
                <li>专业造型建议和护理指导</li>
              </ul>
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

export default SelectStylistPage
