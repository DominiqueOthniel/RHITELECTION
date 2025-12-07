import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { syncElectionEndDate, fetchElectionEndDate } from './supabase-helpers'

interface ElectionStore {
  endDate: string | null // ISO string
  setEndDate: (date: string | null) => Promise<void>
  getTimeRemaining: () => { days: number; hours: number; minutes: number; seconds: number; total: number } | null
  isElectionEnded: () => boolean
  isElectionStarted: () => boolean
  syncFromSupabase: () => Promise<void>
}

export const useElectionStore = create<ElectionStore>()(
  persist(
    (set, get) => ({
      endDate: null, // Par défaut, pas de date de fin

      setEndDate: async (date: string | null) => {
        set({ endDate: date })
        // Synchroniser avec Supabase
        await syncElectionEndDate(date)
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
        if (!endDate) return false // Si pas de date de fin, l'élection n'est jamais terminée
        
        const now = new Date().getTime()
        const end = new Date(endDate).getTime()
        return now >= end
      },

      isElectionStarted: () => {
        const endDate = get().endDate
        if (!endDate) return false // Si pas de date de fin, l'élection n'a pas commencé
        
        const now = new Date().getTime()
        const end = new Date(endDate).getTime()
        // L'élection a commencé si la date de fin est configurée et pas encore atteinte
        return now < end
      },

      syncFromSupabase: async () => {
        const supabaseEndDate = await fetchElectionEndDate()
        set({ endDate: supabaseEndDate })
      },
    }),
    {
      name: 'election-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
)


