import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { Appointment, AppointmentQueryParams } from '@/types'
import { bookingApi } from '@/services'

interface AppointmentsState {
  appointments: Appointment[]
  currentAppointment: Appointment | null
  pendingAppointments: Appointment[]
  completedAppointments: Appointment[]
  isLoading: boolean
  error: string | null
  pagination: {
    page: number
    limit: number
    total: number
  }
}

const initialState: AppointmentsState = {
  appointments: [],
  currentAppointment: null,
  pendingAppointments: [],
  completedAppointments: [],
  isLoading: false,
  error: null,
  pagination: {
    page: 1,
    limit: 10,
    total: 0,
  },
}

// 异步actions
export const fetchAppointmentsAsync = createAsyncThunk(
  'appointments/fetchAppointments',
  async (params?: AppointmentQueryParams) => {
    const response = await bookingApi.getAppointments(params)
    if (response.success && response.data) {
      return {
        appointments: response.data,
        pagination: response.pagination,
      }
    }
    throw new Error(response.error?.message || '获取预约列表失败')
  }
)

export const fetchAppointmentDetailAsync = createAsyncThunk(
  'appointments/fetchAppointmentDetail',
  async (appointmentId: number) => {
    const response = await bookingApi.getAppointmentDetail(appointmentId)
    if (response.success && response.data) {
      return response.data
    }
    throw new Error(response.error?.message || '获取预约详情失败')
  }
)

export const cancelAppointmentAsync = createAsyncThunk(
  'appointments/cancelAppointment',
  async (appointmentId: number) => {
    const response = await bookingApi.cancelAppointment(appointmentId)
    if (response.success) {
      return appointmentId
    }
    throw new Error(response.error?.message || '取消预约失败')
  }
)

const appointmentsSlice = createSlice({
  name: 'appointments',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null
    },
    clearCurrentAppointment: (state) => {
      state.currentAppointment = null
    },
    categorizeAppointments: (state) => {
      state.pendingAppointments = state.appointments.filter(
        (apt) => apt.status === 'pending'
      )
      state.completedAppointments = state.appointments.filter(
        (apt) => apt.status === 'completed'
      )
    },
    updateAppointmentStatus: (
      state,
      action: { payload: { id: number; status: Appointment['status'] } }
    ) => {
      const { id, status } = action.payload
      const appointment = state.appointments.find((apt) => apt.id === id)
      if (appointment) {
        appointment.status = status
      }
      // 重新分类
      state.pendingAppointments = state.appointments.filter(
        (apt) => apt.status === 'pending'
      )
      state.completedAppointments = state.appointments.filter(
        (apt) => apt.status === 'completed'
      )
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch Appointments
      .addCase(fetchAppointmentsAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(fetchAppointmentsAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.appointments = action.payload.appointments
        if (action.payload.pagination) {
          state.pagination = action.payload.pagination
        }
        // 自动分类
        state.pendingAppointments = action.payload.appointments.filter(
          (apt) => apt.status === 'pending'
        )
        state.completedAppointments = action.payload.appointments.filter(
          (apt) => apt.status === 'completed'
        )
      })
      .addCase(fetchAppointmentsAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '获取预约列表失败'
      })
      // Fetch Appointment Detail
      .addCase(fetchAppointmentDetailAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(fetchAppointmentDetailAsync.fulfilled, (state, action) => {
        state.isLoading = false
        state.currentAppointment = action.payload
      })
      .addCase(fetchAppointmentDetailAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '获取预约详情失败'
      })
      // Cancel Appointment
      .addCase(cancelAppointmentAsync.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(cancelAppointmentAsync.fulfilled, (state, action) => {
        state.isLoading = false
        const appointmentId = action.payload
        const appointment = state.appointments.find((apt) => apt.id === appointmentId)
        if (appointment) {
          appointment.status = 'cancelled'
        }
        // 从待服务中移除
        state.pendingAppointments = state.pendingAppointments.filter(
          (apt) => apt.id !== appointmentId
        )
      })
      .addCase(cancelAppointmentAsync.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.error.message || '取消预约失败'
      })
  },
})

export const {
  clearError,
  clearCurrentAppointment,
  categorizeAppointments,
  updateAppointmentStatus,
} = appointmentsSlice.actions

export default appointmentsSlice.reducer