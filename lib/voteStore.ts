import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { syncVoteToSupabase, fetchVotesFromSupabase } from './supabase-helpers'

export interface Vote {
  id: string
  candidateId: string
  voterCode: string
  createdAt: string
}

interface VoteStore {
  votes: Vote[]
  addVote: (candidateId: string, voterCode: string) => Promise<void>
  getVotesByCandidate: (candidateId: string) => number
  getTotalVotes: () => number
  clearAllVotes: () => void
  syncFromSupabase: () => Promise<void>
}

export const useVoteStore = create<VoteStore>()(
  persist(
    (set, get) => ({
      votes: [],

      addVote: async (candidateId: string, voterCode: string) => {
        const newVote: Vote = {
          id: Date.now().toString(),
          candidateId,
          voterCode,
          createdAt: new Date().toISOString(),
        }
        set((state) => ({
          votes: [...state.votes, newVote],
        }))
        // Synchroniser avec Supabase
        await syncVoteToSupabase(candidateId, voterCode)
      },

      getVotesByCandidate: (candidateId: string) => {
        return get().votes.filter((v) => v.candidateId === candidateId).length
      },

      getTotalVotes: () => {
        return get().votes.length
      },

      clearAllVotes: () => {
        set({ votes: [] })
      },

      syncFromSupabase: async () => {
        const supabaseVotes = await fetchVotesFromSupabase()
        set({ votes: supabaseVotes })
      },
    }),
    {
      name: 'vote-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
)





