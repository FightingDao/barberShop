// 统一设计主题配置
export const theme = {
  // 主色调 - 红色/粉色
  colors: {
    primary: '#FF4D6A',
    primaryLight: '#FFE5EA',
    primaryDark: '#E63950',

    // 辅助色
    success: '#52C41A',
    warning: '#FAAD14',
    error: '#F5222D',
    info: '#1890FF',

    // 文字颜色
    textPrimary: '#333333',
    textSecondary: '#666666',
    textTertiary: '#999999',
    textDisabled: '#CCCCCC',

    // 背景色
    bgPrimary: '#FFFFFF',
    bgSecondary: '#F7F8FA',
    bgTertiary: '#F0F0F0',

    // 边框色
    border: '#E5E5E5',
    borderLight: '#F0F0F0',

    // 评分星星
    star: '#FF4D6A',
  },

  // 圆角
  borderRadius: {
    small: '8px',
    medium: '12px',
    large: '16px',
    round: '50%',
  },

  // 阴影
  shadows: {
    small: '0 2px 8px rgba(0, 0, 0, 0.04)',
    medium: '0 4px 12px rgba(0, 0, 0, 0.08)',
    large: '0 8px 24px rgba(0, 0, 0, 0.12)',
    primary: '0 4px 12px rgba(255, 77, 106, 0.3)',
  },

  // 间距
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '12px',
    lg: '16px',
    xl: '20px',
    xxl: '24px',
  },

  // 字体大小
  fontSize: {
    xs: '12px',
    sm: '13px',
    base: '14px',
    md: '15px',
    lg: '16px',
    xl: '18px',
    xxl: '20px',
    huge: '24px',
  },

  // 按钮样式
  button: {
    primary: {
      background: 'linear-gradient(135deg, #FF4D6A 0%, #FF6B7F 100%)',
      color: '#FFFFFF',
      boxShadow: '0 4px 12px rgba(255, 77, 106, 0.3)',
    },
    disabled: {
      background: '#E0E0E0',
      color: '#999999',
    },
  },
}

// 通用样式类
export const commonStyles = {
  // 卡片
  card: {
    background: theme.colors.bgPrimary,
    borderRadius: theme.borderRadius.medium,
    boxShadow: theme.shadows.small,
    padding: theme.spacing.lg,
  },

  // 容器
  container: {
    padding: theme.spacing.lg,
    background: theme.colors.bgSecondary,
    minHeight: '100vh',
  },

  // 按钮
  primaryButton: {
    height: '48px',
    fontSize: theme.fontSize.lg,
    fontWeight: 'bold',
    background: theme.button.primary.background,
    border: 'none',
    borderRadius: theme.borderRadius.medium,
    boxShadow: theme.button.primary.boxShadow,
    color: theme.button.primary.color,
  },

  // Loading居中
  loadingCenter: {
    display: 'flex',
    flexDirection: 'column' as const,
    alignItems: 'center',
    justifyContent: 'center',
    padding: '40px 0',
    textAlign: 'center' as const,
  },

  // 空状态
  empty: {
    display: 'flex',
    flexDirection: 'column' as const,
    alignItems: 'center',
    justifyContent: 'center',
    padding: '60px 20px',
    textAlign: 'center' as const,
  },
}

export default theme
