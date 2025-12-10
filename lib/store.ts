import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { syncVoterToSupabase, syncVotersToSupabase, fetchVotersFromSupabase, deleteVoterFromSupabase, deleteAllVoters } from './supabase-helpers'
import { generateUUID } from './utils'

export interface Voter {
  id: string
  studentId: string
  email: string
  name: string
  voteCode: string
  hasVoted: boolean
  whatsapp?: string
  createdAt: string
}

interface VoterStore {
  voters: Voter[]
  addVoter: (studentId: string, name: string) => Promise<string>
  getVoterByCode: (code: string) => Voter | undefined
  markAsVoted: (code: string) => Promise<void>
  deleteVoter: (id: string) => Promise<void>
  getVoterStats: () => { total: number; voted: number; pending: number }
  resetVoteStats: () => Promise<void>
  syncFromSupabase: () => Promise<void>
}

// Génère un code de vote unique
function generateVoteCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789' // Exclut les caractères ambigus
  let code = ''
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return code
}

// Génère un code de vote unique
function generateVoteCodeForDefault(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let code = ''
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return code
}

// Plus de votants par défaut - les données doivent être ajoutées manuellement

export const useVoterStore = create<VoterStore>()(
  persist(
    (set, get) => ({
      voters: [],

      addVoter: async (studentId: string, name: string) => {
        const code = generateVoteCode()
        const newVoter: Voter = {
          id: generateUUID(),
          studentId,
          email: '', // Email non requis
          name,
          voteCode: code,
          hasVoted: false,
          createdAt: new Date().toISOString(),
        }
        set((state) => ({
          voters: [...state.voters, newVoter],
        }))
        // Synchroniser avec Supabase
        await syncVoterToSupabase(newVoter)
        return code
      },

      getVoterByCode: (code: string) => {
        return get().voters.find((v) => v.voteCode === code)
      },

      markAsVoted: async (code: string) => {
        const updatedVoters = get().voters.map((v) =>
          v.voteCode === code ? { ...v, hasVoted: true } : v
        )
        set({ voters: updatedVoters })
        const updatedVoter = updatedVoters.find(v => v.voteCode === code)
        if (updatedVoter) {
          // Synchroniser avec Supabase
          await syncVoterToSupabase(updatedVoter)
        }
      },

      deleteVoter: async (id: string) => {
        set((state) => ({
          voters: state.voters.filter((v) => v.id !== id),
        }))
        // Supprimer aussi dans Supabase
        await deleteVoterFromSupabase(id)
      },

      getVoterStats: () => {
        const voters = get().voters
        return {
          total: voters.length,
          voted: voters.filter((v) => v.hasVoted).length,
          pending: voters.filter((v) => !v.hasVoted).length,
        }
      },

      resetVoteStats: async () => {
        const updatedVoters = get().voters.map((v) => ({ ...v, hasVoted: false }))
        set({ voters: updatedVoters })
        // Synchroniser tous les votants avec Supabase
        await syncVotersToSupabase(updatedVoters)
      },

      syncFromSupabase: async () => {
        // Toujours charger depuis Supabase pour synchroniser avec la base de données
        const supabaseVoters = await fetchVotersFromSupabase()
        set({ voters: supabaseVoters }) // Même si vide, on synchronise
      },
    }),
    {
      name: 'voter-storage',
      storage: createJSONStorage(() => localStorage),
      onRehydrateStorage: () => (state) => {
        // Ne pas charger depuis localStorage, on chargera depuis Supabase
        // Retourner un état vide pour forcer le chargement depuis Supabase
        return { voters: [] }
      },
    }
  )
)

