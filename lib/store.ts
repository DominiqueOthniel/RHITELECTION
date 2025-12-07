import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'

export interface Voter {
  id: string
  studentId: string
  email: string
  name: string
  voteCode: string
  hasVoted: boolean
  createdAt: string
}

interface VoterStore {
  voters: Voter[]
  addVoter: (studentId: string, email: string, name: string) => string
  getVoterByCode: (code: string) => Voter | undefined
  markAsVoted: (code: string) => void
  deleteVoter: (id: string) => void
  getVoterStats: () => { total: number; voted: number; pending: number }
  resetVoteStats: () => void
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

      addVoter: (studentId: string, email: string, name: string) => {
        const code = generateVoteCode()
        const newVoter: Voter = {
          id: Date.now().toString(),
          studentId,
          email,
          name,
          voteCode: code,
          hasVoted: false,
          createdAt: new Date().toISOString(),
        }
        set((state) => ({
          voters: [...state.voters, newVoter],
        }))
        return code
      },

      getVoterByCode: (code: string) => {
        return get().voters.find((v) => v.voteCode === code)
      },

      markAsVoted: (code: string) => {
        set((state) => ({
          voters: state.voters.map((v) =>
            v.voteCode === code ? { ...v, hasVoted: true } : v
          ),
        }))
      },

      deleteVoter: (id: string) => {
        set((state) => ({
          voters: state.voters.filter((v) => v.id !== id),
        }))
      },

      getVoterStats: () => {
        const voters = get().voters
        return {
          total: voters.length,
          voted: voters.filter((v) => v.hasVoted).length,
          pending: voters.filter((v) => !v.hasVoted).length,
        }
      },

      resetVoteStats: () => {
        set((state) => ({
          voters: state.voters.map((v) => ({ ...v, hasVoted: false })),
        }))
      },
    }),
    {
      name: 'voter-storage',
      storage: createJSONStorage(() => localStorage),
      onRehydrateStorage: () => (state) => {
        // Ne plus charger de votants par défaut
        return state || { voters: [] }
      },
    }
  )
)

