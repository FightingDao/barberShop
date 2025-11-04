import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit'
import { User } from '@/types'
import { authApi, LoginParams } from '@/services'

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
  error: string | null
}

const initialState: AuthState = {
  user: null,
  token: localStorage.getItem('auth_token'),
  isAuthenticated: !!localStorage.getItem('auth_token'),
  isLoading: false,
  error: null,
}

// 异步actions
export const loginAsync = createAsyncThunk(
  'auth/login',
  async (params: LoginParams) => {
    const response = await authApi.login(params)
    if (response.success && response.data) {
      const { user, token } = response.data
      localStorage.setItem('auth_token', token)
      return { user, token }
    }
    throw new Error(response.error?.message || '登录失败')
  }
)

export const getProfileAsync = createAsyncThunk(
  'auth/getProfile',
  async () => {
    const response = await authApi.getProfile()
    if (response.success && response.data) {
      return response.data
    }
    throw new Error(response.error?.message || '获取用户信息失败')
  }
)

export const updateProfileAsync = createAsyncThunk(
  'auth/updateProfile',
  async (data: Partial<User>) => {
    const response = await authApi.updateProfile(data)
    if (response.success && response.data) {
      return response.data
    }
    throw new Error(response.error?.message || '更新用户信息失败')
  }
)

export const logoutAsync = createAsyncThunk(
  'auth/logout',
  async () => {
    await authApi.logout()
    localStorage.removeItem('auth_token')
  }
)

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null
    },
    setToken: (state, action: PayloadAction<string>) => {
      state.token = action.payload
      state.isAuthenticated = true
      localStorage.setItem('auth_token', action.payload)
    },
    clearAuth: (state) => {
      state.user = null
      state.token = null
      state.isAuthenticated = false
      localStorage.removeItem('auth_token')
    },
  },
  extraReducers: (builder) => {
    builder
      // Login
      .addCase(loginAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(loginAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.user = action.payload.user
        state.token = action.payload.token
        state.isAuthenticated = true
        state.error = null
      })
      .addCase(loginAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '登录失败'
      })
      // Get Profile
      .addCase(getProfileAsync.pending, (state) => {
        state.isLoading = true
      })
      .addCase(getProfileAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.user = action.payload
        state.error = null
      })
      .addCase(getProfileAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '获取用户信息失败'
      })
      // Update Profile
      .addCase(updateProfileAsync.pending, (state) => {
        state.isLoading = true
      })
      .addCase(updateProfileAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.user = action.payload
        state.error = null
      })
      .addCase(updateProfileAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '更新用户信息失败'
      })
      // Logout
      .addCase(logoutAsync.fulfilled, (state) => {
        state.user = null
        state.token = null
        state.isAuthenticated = false
      })
  },
})

export const { clearError, setToken, clearAuth } = authSlice.actions
export default authSlice.reducer