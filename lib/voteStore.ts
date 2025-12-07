import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'

export interface Vote {
  id: string
  candidateId: string
  voterCode: string
  createdAt: string
}

interface VoteStore {
  votes: Vote[]
  addVote: (candidateId: string, voterCode: string) => void
  getVotesByCandidate: (candidateId: string) => number
  getTotalVotes: () => number
  clearAllVotes: () => void
}

export const useVoteStore = create<VoteStore>()(
  persist(
    (set, get) => ({
      votes: [],

      addVote: (candidateId: string, voterCode: string) => {
        const newVote: Vote = {
          id: Date.now().toString(),
          candidateId,
          voterCode,
          createdAt: new Date().toISOString(),
        }
        set((state) => ({
          votes: [...state.votes, newVote],
        }))
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
    }),
    {
      name: 'vote-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
)





