import { create } from 'zustand'
import { syncElectionEndDate, fetchElectionEndDate } from './supabase-helpers'

interface ElectionStore {
  endDate: string | null // ISO string — source de vérité : Supabase uniquement
  setEndDate: (date: string | null) => Promise<void>
  getTimeRemaining: () => { days: number; hours: number; minutes: number; seconds: number; total: number } | null
  isElectionEnded: () => boolean
  isElectionStarted: () => boolean
  syncFromSupabase: () => Promise<void>
}

export const useElectionStore = create<ElectionStore>()((set, get) => ({
  endDate: null,

  setEndDate: async (date: string | null) => {
    const result = await syncElectionEndDate(date)
    if (!result.success) {
      throw result.error ?? new Error('Impossible de sauvegarder la date de fin dans Supabase')
    }
    const confirmed = await fetchElectionEndDate()
    set({ endDate: confirmed })
  },

  getTimeRemaining: () => {
    const endDate = get().endDate
    if (!endDate) return null

    const now = new Date().getTime()
    const end = new Date(endDate).getTime()
    const total = end - now

    if (total <= 0) {
      return { days: 0, hours: 0, minutes: 0, seconds: 0, total: 0 }
    }

    const days = Math.floor(total / (1000 * 60 * 60 * 24))
    const hours = Math.floor((total % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((total % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((total % (1000 * 60)) / 1000)

    return { days, hours, minutes, seconds, total }
  },

  isElectionEnded: () => {
    const endDate = get().endDate
    if (!endDate) return false

    const now = new Date().getTime()
    const end = new Date(endDate).getTime()
    return now >= end
  },

  isElectionStarted: () => {
    const endDate = get().endDate
    if (!endDate) return false

    const now = new Date().getTime()
    const end = new Date(endDate).getTime()
    return now < end
  },

  syncFromSupabase: async () => {
    const supabaseEndDate = await fetchElectionEndDate()
    set({ endDate: supabaseEndDate })
  },
}))
