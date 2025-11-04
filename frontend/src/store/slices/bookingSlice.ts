import { createSlice, PayloadAction } from '@reduxjs/toolkit'
import { Shop, Service, Stylist, TimeSlot, BookingFlowData } from '@/types'

interface BookingState extends BookingFlowData {
  step: number
  availableTimeSlots: TimeSlot[]
  selectedDate: string | null
  isLoadingTimeSlots: boolean
}

const initialState: BookingState = {
  step: 1,
  shop: null,
  service: null,
  stylist: null,
  date: null,
  selectedDate: null,
  timeSlot: null,
  notes: '',
  availableTimeSlots: [],
  isLoadingTimeSlots: false,
}

const bookingSlice = createSlice({
  name: 'booking',
  initialState,
  reducers: {
    setShop: (state, action: PayloadAction<Shop>) => {
      state.shop = action.payload
      state.step = 2
    },
    setService: (state, action: PayloadAction<Service>) => {
      state.service = action.payload
      state.step = 3
    },
    setStylist: (state, action: PayloadAction<Stylist | null>) => {
      state.stylist = action.payload
      state.step = 4
    },
    setDate: (state, action: PayloadAction<string>) => {
      state.date = action.payload
      state.selectedDate = action.payload
      state.timeSlot = null
      state.step = 4
    },
    setTimeSlot: (state, action: PayloadAction<TimeSlot>) => {
      state.timeSlot = action.payload
      state.step = 5
    },
    setNotes: (state, action: PayloadAction<string>) => {
      state.notes = action.payload
    },
    setAvailableTimeSlots: (state, action: PayloadAction<TimeSlot[]>) => {
      state.availableTimeSlots = action.payload
    },
    setLoadingTimeSlots: (state, action: PayloadAction<boolean>) => {
      state.isLoadingTimeSlots = action.payload
    },
    goToStep: (state, action: PayloadAction<number>) => {
      state.step = action.payload
    },
    nextStep: (state) => {
      if (state.step < 5) {
        state.step += 1
      }
    },
    previousStep: (state) => {
      if (state.step > 1) {
        state.step -= 1
      }
    },
    resetBooking: () => {
      return initialState
    },
    resetBookingFlow: (state) => {
      state.shop = null
      state.service = null
      state.stylist = null
      state.date = null
      state.selectedDate = null
      state.timeSlot = null
      state.notes = ''
      state.availableTimeSlots = []
      state.step = 1
    },
  },
})

export const {
  setShop,
  setService,
  setStylist,
  setDate,
  setTimeSlot,
  setNotes,
  setAvailableTimeSlots,
  setLoadingTimeSlots,
  goToStep,
  nextStep,
  previousStep,
  resetBooking,
  resetBookingFlow,
} = bookingSlice.actions

export default bookingSlice.reducer