import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Loading, Toast, Button, Popup } from 'react-vant'
import { Success } from '@react-vant/icons'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopStylistsAsync } from '@/store/slices/shopsSlice'
import { setStylist } from '@/store/slices/bookingSlice'
import { Stylist } from '@/types'
import { theme, commonStyles } from '@/styles/theme'

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
        return { text: '可约', color: theme.colors.success, canSelect: true }
      case 'busy':
        return { text: '已约满', color: theme.colors.primary, canSelect: false }
      case 'inactive':
        return { text: '休息中', color: theme.colors.textTertiary, canSelect: false }
      default:
        return { text: '可约', color: theme.colors.success, canSelect: true }
    }
  }

  if (isLoading) {
    return (
      <div style={commonStyles.loadingCenter}>
        <Loading size="24px" color={theme.colors.primary} />
      </div>
    )
  }

  return (
    <div style={{
      background: theme.colors.bgSecondary,
      minHeight: '100vh',
      paddingBottom: '100px'
    }}>
      {/* 自定义顶部导航 */}
      <div style={{
        position: 'sticky',
        top: 0,
        zIndex: 100,
        background: theme.colors.bgPrimary,
        boxShadow: theme.shadows.small,
        padding: `${theme.spacing.md} ${theme.spacing.lg}`,
        display: 'flex',
        alignItems: 'center'
      }}>
        <div
          onClick={() => navigate(-1)}
          style={{
            width: '32px',
            height: '32px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: theme.colors.bgSecondary,
            borderRadius: theme.borderRadius.round,
            cursor: 'pointer',
            marginRight: theme.spacing.md
          }}
        >
          <span style={{ fontSize: '18px' }}>←</span>
        </div>
        <h2 style={{
          margin: 0,
          fontSize: theme.fontSize.lg,
          fontWeight: 'bold',
          color: theme.colors.textPrimary
        }}>
          选择理发师
        </h2>
      </div>

      <div style={{ padding: theme.spacing.lg }}>
        {/* 预约信息提示 */}
        <div style={{
          ...commonStyles.card,
          marginBottom: theme.spacing.lg,
          background: theme.colors.primaryLight
        }}>
          <h3 style={{
            margin: 0,
            fontSize: theme.fontSize.lg,
            color: theme.colors.primary,
            fontWeight: 'bold'
          }}>
            {shop?.name}
          </h3>
          <p style={{
            margin: `${theme.spacing.sm} 0 0 0`,
            fontSize: theme.fontSize.sm,
            color: theme.colors.textSecondary
          }}>
            服务：{service?.name} | ¥{service?.price}
          </p>
        </div>

        {/* 不指定理发师选项 */}
        <div
          onClick={() => handleSelectStylist('none')}
          style={{
            position: 'relative',
            padding: theme.spacing.lg,
            marginBottom: theme.spacing.lg,
            background: selectedStylist === 'none' ? theme.colors.primaryLight : theme.colors.bgPrimary,
            borderRadius: theme.borderRadius.medium,
            border: selectedStylist === 'none'
              ? `2px solid ${theme.colors.primary}`
              : `2px dashed ${theme.colors.border}`,
            cursor: 'pointer',
            transition: 'all 0.3s ease',
            boxShadow: selectedStylist === 'none' ? theme.shadows.primary : theme.shadows.small
          }}
        >
          {selectedStylist === 'none' && (
            <div style={{
              position: 'absolute',
              top: theme.spacing.md,
              right: theme.spacing.md,
              width: '28px',
              height: '28px',
              borderRadius: theme.borderRadius.round,
              background: theme.colors.primary,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: theme.shadows.medium
            }}>
              <Success style={{ color: theme.colors.bgPrimary, fontSize: '16px' }} />
            </div>
          )}

          <div style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{
              width: '60px',
              height: '60px',
              borderRadius: theme.borderRadius.round,
              background: selectedStylist === 'none' ? theme.colors.primary : theme.colors.bgTertiary,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '28px',
              transition: 'all 0.3s ease'
            }}>
              👤
            </div>
            <div style={{ marginLeft: theme.spacing.lg, flex: 1 }}>
              <h4 style={{
                margin: `0 0 ${theme.spacing.sm} 0`,
                fontSize: theme.fontSize.lg,
                fontWeight: 'bold',
                color: theme.colors.textPrimary
              }}>
                不指定理发师
              </h4>
              <p style={{
                margin: 0,
                fontSize: theme.fontSize.sm,
                color: theme.colors.textSecondary
              }}>
                由店铺安排合适的理发师为您服务
              </p>
            </div>
          </div>
        </div>

        {/* 理发师列表 */}
        <div style={{ marginBottom: theme.spacing.lg }}>
          <h3 style={{
            margin: `0 0 ${theme.spacing.md} 0`,
            fontSize: theme.fontSize.md,
            color: theme.colors.textSecondary,
            fontWeight: 'bold'
          }}>
            或选择指定理发师
          </h3>
        </div>

        {stylists.length === 0 ? (
          <div style={commonStyles.empty}>
            <div style={{
              fontSize: '48px',
              marginBottom: theme.spacing.md,
              color: theme.colors.textTertiary
            }}>
              👨‍💼
            </div>
            <p style={{
              margin: 0,
              fontSize: theme.fontSize.base,
              color: theme.colors.textTertiary
            }}>
              暂无理发师信息
            </p>
          </div>
        ) : (
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            gap: theme.spacing.lg
          }}>
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
                    padding: theme.spacing.lg,
                    background: isSelected ? theme.colors.primaryLight : theme.colors.bgPrimary,
                    borderRadius: theme.borderRadius.medium,
                    border: isSelected
                      ? `2px solid ${theme.colors.primary}`
                      : `1px solid ${theme.colors.borderLight}`,
                    cursor: canSelect ? 'pointer' : 'not-allowed',
                    opacity: canSelect ? 1 : 0.6,
                    transition: 'all 0.3s ease',
                    transform: isSelected ? 'scale(0.98)' : 'scale(1)',
                    boxShadow: isSelected ? theme.shadows.primary : theme.shadows.small
                  }}
                >
                  {/* 选中标记 */}
                  {isSelected && (
                    <div style={{
                      position: 'absolute',
                      top: theme.spacing.md,
                      left: theme.spacing.md,
                      width: '28px',
                      height: '28px',
                      borderRadius: theme.borderRadius.round,
                      background: theme.colors.primary,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      zIndex: 1,
                      boxShadow: theme.shadows.medium
                    }}>
                      <Success style={{ color: theme.colors.bgPrimary, fontSize: '16px' }} />
                    </div>
                  )}

                  {/* 状态徽章 */}
                  <div style={{
                    position: 'absolute',
                    top: theme.spacing.md,
                    right: theme.spacing.md,
                    padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                    borderRadius: theme.borderRadius.small,
                    background: statusInfo.color,
                    color: theme.colors.bgPrimary,
                    fontSize: theme.fontSize.xs,
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
                        borderRadius: theme.borderRadius.round,
                        background: isSelected ? theme.colors.primary : theme.colors.bgTertiary,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '28px',
                        marginLeft: isSelected ? '36px' : '0',
                        cursor: canSelect ? 'pointer' : 'not-allowed',
                        transition: 'all 0.3s ease'
                      }}
                    >
                      👨‍🦰
                    </div>

                    {/* 理发师信息 */}
                    <div style={{ marginLeft: theme.spacing.lg, flex: 1 }}>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        marginBottom: theme.spacing.sm
                      }}>
                        <h4 style={{
                          margin: 0,
                          fontSize: theme.fontSize.lg,
                          fontWeight: 'bold',
                          color: theme.colors.textPrimary
                        }}>
                          {stylist.name}
                        </h4>
                        {stylist.level && (
                          <span style={{
                            marginLeft: theme.spacing.sm,
                            padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                            fontSize: theme.fontSize.xs,
                            background: theme.colors.primary,
                            color: theme.colors.bgPrimary,
                            borderRadius: theme.borderRadius.small,
                            fontWeight: 'bold'
                          }}>
                            {stylist.level}
                          </span>
                        )}
                      </div>

                      {stylist.title && (
                        <p style={{
                          margin: `0 0 ${theme.spacing.xs} 0`,
                          fontSize: theme.fontSize.sm,
                          color: theme.colors.textTertiary
                        }}>
                          {stylist.title}
                        </p>
                      )}

                      <div style={{
                        display: 'flex',
                        gap: theme.spacing.md,
                        fontSize: theme.fontSize.sm,
                        color: theme.colors.textSecondary
                      }}>
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
        padding: theme.spacing.lg,
        background: theme.colors.bgPrimary,
        borderTop: `1px solid ${theme.colors.borderLight}`,
        boxShadow: theme.shadows.large
      }}>
        <div style={{
          marginBottom: theme.spacing.md,
          fontSize: theme.fontSize.base,
          color: theme.colors.textSecondary
        }}>
          {selectedStylist === 'none' && '已选：不指定理发师'}
          {selectedStylist && typeof selectedStylist !== 'string' && `已选：${selectedStylist.name}`}
          {!selectedStylist && '请选择理发师'}
        </div>
        <Button
          block
          round
          disabled={!selectedStylist}
          onClick={handleNext}
          style={{
            ...commonStyles.primaryButton,
            opacity: selectedStylist ? 1 : 0.6,
            cursor: selectedStylist ? 'pointer' : 'not-allowed'
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
          <div style={{ padding: theme.spacing.xxl }}>
            {/* 头像和基本信息 */}
            <div style={{
              textAlign: 'center',
              marginBottom: theme.spacing.xxl
            }}>
              <div style={{
                width: '100px',
                height: '100px',
                borderRadius: theme.borderRadius.round,
                background: theme.button.primary.background,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '48px',
                margin: `0 auto ${theme.spacing.lg}`,
                boxShadow: theme.shadows.primary
              }}>
                👨‍🦰
              </div>
              <h2 style={{
                margin: `0 0 ${theme.spacing.sm} 0`,
                fontSize: theme.fontSize.huge,
                color: theme.colors.textPrimary,
                fontWeight: 'bold'
              }}>
                {detailStylist.name}
              </h2>
              {detailStylist.level && (
                <span style={{
                  padding: `${theme.spacing.xs} ${theme.spacing.md}`,
                  fontSize: theme.fontSize.sm,
                  background: theme.colors.primary,
                  color: theme.colors.bgPrimary,
                  borderRadius: theme.borderRadius.small,
                  fontWeight: 'bold'
                }}>
                  {detailStylist.level}
                </span>
              )}
            </div>

            {/* 详细信息 */}
            <div style={{ marginBottom: theme.spacing.xxl }}>
              {detailStylist.title && (
                <div style={{
                  ...commonStyles.card,
                  marginBottom: theme.spacing.lg
                }}>
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    <span style={{
                      fontSize: theme.fontSize.base,
                      color: theme.colors.textTertiary
                    }}>
                      职称
                    </span>
                    <span style={{
                      fontSize: theme.fontSize.md,
                      fontWeight: 'bold',
                      color: theme.colors.textPrimary
                    }}>
                      {detailStylist.title}
                    </span>
                  </div>
                </div>
              )}

              {detailStylist.experience && (
                <div style={{
                  ...commonStyles.card,
                  marginBottom: theme.spacing.lg
                }}>
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    <span style={{
                      fontSize: theme.fontSize.base,
                      color: theme.colors.textTertiary
                    }}>
                      从业年限
                    </span>
                    <span style={{
                      fontSize: theme.fontSize.md,
                      fontWeight: 'bold',
                      color: theme.colors.textPrimary
                    }}>
                      {detailStylist.experience}年
                    </span>
                  </div>
                </div>
              )}

              {detailStylist.specialty && (
                <div style={{ marginBottom: theme.spacing.lg }}>
                  <h3 style={{
                    margin: `0 0 ${theme.spacing.md} 0`,
                    fontSize: theme.fontSize.lg,
                    color: theme.colors.textPrimary,
                    fontWeight: 'bold'
                  }}>
                    擅长项目
                  </h3>
                  <div style={{
                    ...commonStyles.card,
                    color: theme.colors.textSecondary,
                    lineHeight: '1.6'
                  }}>
                    {detailStylist.specialty}
                  </div>
                </div>
              )}
            </div>

            {/* 服务特色 */}
            <div style={{ marginBottom: theme.spacing.xxl }}>
              <h3 style={{
                margin: `0 0 ${theme.spacing.md} 0`,
                fontSize: theme.fontSize.lg,
                color: theme.colors.textPrimary,
                fontWeight: 'bold'
              }}>
                服务特色
              </h3>
              <ul style={{
                margin: 0,
                paddingLeft: theme.spacing.xl,
                fontSize: theme.fontSize.base,
                color: theme.colors.textSecondary,
                lineHeight: '1.8'
              }}>
                <li>注重细节，精益求精</li>
                <li>根据顾客脸型推荐合适发型</li>
                <li>专业造型建议和护理指导</li>
              </ul>
            </div>

            <Button
              block
              round
              onClick={() => setShowDetail(false)}
              style={commonStyles.primaryButton}
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
