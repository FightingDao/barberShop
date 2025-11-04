import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Tabs, Card, Empty, Loading, NavBar } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchAppointmentsAsync } from '@/store/slices/appointmentsSlice'
import { theme, commonStyles } from '@/styles/theme'

const AppointmentsPage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { pendingAppointments, completedAppointments, isLoading } = useAppSelector(
    state => state.appointments
  )

  useEffect(() => {
    dispatch(fetchAppointmentsAsync())
  }, [dispatch])

  if (isLoading) {
    return (
      <div style={commonStyles.loadingCenter}>
        <Loading size="24px" color={theme.colors.primary} />
      </div>
    )
  }

  return (
    <div style={{ background: theme.colors.bgSecondary, minHeight: '100vh' }}>
      {/* 顶部导航 */}
      <NavBar
        title="我的预约"
        onClickLeft={() => navigate(-1)}
        style={{
          background: theme.colors.bgPrimary,
          boxShadow: theme.shadows.small
        }}
      />

      <Tabs
        color={theme.colors.primary}
        style={{
          background: theme.colors.bgSecondary
        }}
      >
        <Tabs.TabPane title="待服务" key="pending">
          <div style={{ padding: theme.spacing.lg }}>
            {pendingAppointments.length === 0 ? (
              <div style={commonStyles.empty}>
                <div style={{
                  fontSize: '48px',
                  marginBottom: theme.spacing.md,
                  color: theme.colors.textTertiary
                }}>
                  📅
                </div>
                <p style={{
                  margin: 0,
                  fontSize: theme.fontSize.base,
                  color: theme.colors.textTertiary
                }}>
                  暂无预约
                </p>
              </div>
            ) : (
              pendingAppointments.map(apt => (
                <Card
                  key={apt.id}
                  onClick={() => navigate(`/appointments/${apt.id}`)}
                  style={{
                    marginBottom: theme.spacing.lg,
                    cursor: 'pointer',
                    borderRadius: theme.borderRadius.large,
                    boxShadow: theme.shadows.medium,
                    border: 'none',
                    overflow: 'hidden',
                    background: theme.colors.bgPrimary,
                    padding: theme.spacing.lg
                  }}
                >
                  {/* 状态标签 */}
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: theme.spacing.md
                  }}>
                    <h3 style={{
                      margin: 0,
                      fontSize: theme.fontSize.lg,
                      fontWeight: 'bold',
                      color: theme.colors.textPrimary
                    }}>
                      {apt.shop?.name}
                    </h3>
                    <div style={{
                      padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                      borderRadius: theme.borderRadius.small,
                      background: theme.colors.primaryLight,
                      color: theme.colors.primary,
                      fontSize: theme.fontSize.xs,
                      fontWeight: 'bold'
                    }}>
                      待服务
                    </div>
                  </div>

                  <div style={{
                    background: theme.colors.bgTertiary,
                    padding: theme.spacing.md,
                    borderRadius: theme.borderRadius.small,
                    marginBottom: theme.spacing.sm
                  }}>
                    <p style={{
                      margin: 0,
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textSecondary,
                      marginBottom: theme.spacing.xs
                    }}>
                      服务：{apt.service?.name}
                    </p>
                    <p style={{
                      margin: 0,
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textSecondary,
                      marginBottom: theme.spacing.xs
                    }}>
                      理发师：{apt.stylist?.name || '不指定'}
                    </p>
                    <p style={{
                      margin: 0,
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.primary,
                      fontWeight: 'bold'
                    }}>
                      时间：{new Date(apt.appointmentDate).toLocaleDateString()} {new Date(apt.appointmentTime).toLocaleTimeString('zh-CN', {hour: '2-digit', minute: '2-digit'})}
                    </p>
                  </div>

                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    <span style={{
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textTertiary
                    }}>
                      预约编号：{apt.id}
                    </span>
                    <span style={{
                      fontSize: theme.fontSize.lg,
                      fontWeight: 'bold',
                      color: theme.colors.primary
                    }}>
                      ¥{apt.service?.price}
                    </span>
                  </div>
                </Card>
              ))
            )}
          </div>
        </Tabs.TabPane>

        <Tabs.TabPane title="已完成" key="completed">
          <div style={{ padding: theme.spacing.lg }}>
            {completedAppointments.length === 0 ? (
              <div style={commonStyles.empty}>
                <div style={{
                  fontSize: '48px',
                  marginBottom: theme.spacing.md,
                  color: theme.colors.textTertiary
                }}>
                  ✅
                </div>
                <p style={{
                  margin: 0,
                  fontSize: theme.fontSize.base,
                  color: theme.colors.textTertiary
                }}>
                  暂无记录
                </p>
              </div>
            ) : (
              completedAppointments.map(apt => (
                <Card
                  key={apt.id}
                  style={{
                    marginBottom: theme.spacing.lg,
                    opacity: 0.85,
                    borderRadius: theme.borderRadius.large,
                    boxShadow: theme.shadows.medium,
                    border: 'none',
                    overflow: 'hidden',
                    background: theme.colors.bgPrimary,
                    padding: theme.spacing.lg
                  }}
                >
                  {/* 状态标签 */}
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: theme.spacing.md
                  }}>
                    <h3 style={{
                      margin: 0,
                      fontSize: theme.fontSize.lg,
                      fontWeight: 'bold',
                      color: theme.colors.textSecondary
                    }}>
                      {apt.shop?.name}
                    </h3>
                    <div style={{
                      padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                      borderRadius: theme.borderRadius.small,
                      background: theme.colors.success + '20',
                      color: theme.colors.success,
                      fontSize: theme.fontSize.xs,
                      fontWeight: 'bold'
                    }}>
                      已完成
                    </div>
                  </div>

                  <div style={{
                    background: theme.colors.bgTertiary,
                    padding: theme.spacing.md,
                    borderRadius: theme.borderRadius.small,
                    marginBottom: theme.spacing.sm
                  }}>
                    <p style={{
                      margin: 0,
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textSecondary,
                      marginBottom: theme.spacing.xs
                    }}>
                      服务：{apt.service?.name}
                    </p>
                    <p style={{
                      margin: 0,
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textSecondary
                    }}>
                      时间：{new Date(apt.appointmentDate).toLocaleDateString()}
                    </p>
                  </div>

                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    <span style={{
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textTertiary
                    }}>
                      已完成服务
                    </span>
                    <span style={{
                      fontSize: theme.fontSize.md,
                      fontWeight: 'bold',
                      color: theme.colors.textSecondary
                    }}>
                      ¥{apt.service?.price}
                    </span>
                  </div>
                </Card>
              ))
            )}
          </div>
        </Tabs.TabPane>
      </Tabs>
    </div>
  )
}

export default AppointmentsPage