import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { syncVoteToSupabase, fetchVotesFromSupabase } from './supabase-helpers'
import { generateUUID } from './utils'

export interface Vote {
  id: string
  candidateId: string
  voterCode: string
  createdAt: string
}

interface VoteStore {
  votes: Vote[]
  addVote: (candidateId: string, voterCode: string) => Promise<{ success: boolean; error?: any }>
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
        // D'abord synchroniser avec Supabase (vérifications côté serveur)
        const result = await syncVoteToSupabase(candidateId, voterCode)
        
        // Si le vote a échoué côté serveur, ne pas l'ajouter localement
        if (!result.success) {
          return result
        }
        
        // Si le vote a réussi, l'ajouter localement
        const newVote: Vote = {
          id: generateUUID(),
          candidateId,
          voterCode,
          createdAt: new Date().toISOString(),
        }
        set((state) => ({
          votes: [...state.votes, newVote],
        }))
        
        return { success: true }
      },

      getVotesByCandidate: (candidateId: string) => {
        return get().votes.filter((v) => v.candidateId === candidateId).length
      },

      getTotalVotes: () => {
        return get().votes.length
      },

      clearAllVotes: async () => {
        set({ votes: [] })
        // Supprimer aussi dans Supabase
        const { deleteAllVotes } = await import('./supabase-helpers')
        await deleteAllVotes()
      },

      syncFromSupabase: async () => {
        // Toujours charger depuis Supabase pour synchroniser avec la base de données
        const supabaseVotes = await fetchVotesFromSupabase()
        set({ votes: supabaseVotes }) // Même si vide, on synchronise
      },
    }),
    {
      name: 'vote-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
)





