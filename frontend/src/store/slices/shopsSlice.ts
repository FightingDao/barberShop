import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit'
import { Shop, Service, Stylist, ShopQueryParams } from '@/types'
import { shopApi } from '@/services'

interface ShopsState {
  shops: Shop[]
  currentShop: Shop | null
  services: Service[]
  stylists: Stylist[]
  isLoading: boolean
  error: string | null
  pagination: {
    page: number
    limit: number
    total: number
  }
}

const initialState: ShopsState = {
  shops: [],
  currentShop: null,
  services: [],
  stylists: [],
  isLoading: false,
  error: null,
  pagination: {
    page: 1,
    limit: 10,
    total: 0,
  },
}

// 异步actions
export const fetchShopsAsync = createAsyncThunk(
  'shops/fetchShops',
  async (params?: ShopQueryParams) => {
    const response = await shopApi.getShops(params)
    if (response.success && response.data) {
      return {
        shops: response.data,
        pagination: response.pagination,
      }
    }
    throw new Error(response.error?.message || '获取店铺列表失败')
  }
)

export const fetchShopDetailAsync = createAsyncThunk(
  'shops/fetchShopDetail',
  async (shopId: number) => {
    const response = await shopApi.getShopDetail(shopId)
    if (response.success && response.data) {
      return response.data
    }
    throw new Error(response.error?.message || '获取店铺详情失败')
  }
)

export const fetchShopServicesAsync = createAsyncThunk(
  'shops/fetchShopServices',
  async (shopId: number) => {
    const response = await shopApi.getShopServices(shopId)
    if (response.success && response.data) {
      return response.data
    }
    throw new Error(response.error?.message || '获取服务列表失败')
  }
)

export const fetchShopStylistsAsync = createAsyncThunk(
  'shops/fetchShopStylists',
  async (shopId: number) => {
    const response = await shopApi.getShopStylists(shopId)
    if (response.success && response.data) {
      return response.data
    }
    throw new Error(response.error?.message || '获取理发师列表失败')
  }
)

const shopsSlice = createSlice({
  name: 'shops',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null
    },
    clearCurrentShop: (state) => {
      state.currentShop = null
      state.services = []
      state.stylists = []
    },
    updateShopDistance: (state, action: PayloadAction<{ shopId: number; distance: number }>) => {
      const shop = state.shops.find((s) => s.id === action.payload.shopId)
      if (shop) {
        shop.distance = action.payload.distance
      }
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch Shops
      .addCase(fetchShopsAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(fetchShopsAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.shops = action.payload.shops
        if (action.payload.pagination) {
          state.pagination = action.payload.pagination
        }
      })
      .addCase(fetchShopsAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '获取店铺列表失败'
      })
      // Fetch Shop Detail
      .addCase(fetchShopDetailAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(fetchShopDetailAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.currentShop = action.payload
      })
      .addCase(fetchShopDetailAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '获取店铺详情失败'
      })
      // Fetch Shop Services
      .addCase(fetchShopServicesAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(fetchShopServicesAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.services = action.payload
      })
      .addCase(fetchShopServicesAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '获取服务列表失败'
      })
      // Fetch Shop Stylists
      .addCase(fetchShopStylistsAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(fetchShopStylistsAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.stylists = action.payload
      })
      .addCase(fetchShopStylistsAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '获取理发师列表失败'
      })
  },
})

export const { clearError, clearCurrentShop, updateShopDistance } = shopsSlice.actions
export default shopsSlice.reducer