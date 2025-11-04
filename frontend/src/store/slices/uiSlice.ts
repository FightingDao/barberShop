import { createSlice, PayloadAction } from '@reduxjs/toolkit'

interface ToastState {
  message: string
  type: 'success' | 'error' | 'warning' | 'info'
  visible: boolean
  duration?: number
}

interface UIState {
  loading: boolean
  toast: ToastState
  bottomNavigationVisible: boolean
  headerVisible: boolean
  pageHeight: number
}

const initialState: UIState = {
  loading: false,
  toast: {
    message: '',
    type: 'info',
    visible: false,
    duration: 3000,
  },
  bottomNavigationVisible: true,
  headerVisible: true,
  pageHeight: window.innerHeight || 667,
}

const uiSlice = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.loading = action.payload
    },
    showToast: (
      state,
      action: PayloadAction<{
        message: string
        type?: ToastState['type']
        duration?: number
      }>
    ) => {
      state.toast = {
        message: action.payload.message,
        type: action.payload.type || 'info',
        visible: true,
        duration: action.payload.duration || 3000,
      }
    },
    hideToast: (state) => {
      state.toast.visible = false
    },
    setBottomNavigationVisible: (state, action: PayloadAction<boolean>) => {
      state.bottomNavigationVisible = action.payload
    },
    setHeaderVisible: (state, action: PayloadAction<boolean>) => {
      state.headerVisible = action.payload
    },
    setPageHeight: (state, action: PayloadAction<number>) => {
      state.pageHeight = action.payload
    },
  },
})

export const {
  setLoading,
  showToast,
  hideToast,
  setBottomNavigationVisible,
  setHeaderVisible,
  setPageHeight,
} = uiSlice.actions

export default uiSlice.reducer