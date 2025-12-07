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

// Votants par défaut pour les tests
const defaultVoters: Voter[] = [
  {
    id: '1',
    studentId: '2024001',
    email: 'jean.dupont@rhit.edu',
    name: 'Jean Dupont',
    voteCode: 'A7B3C9D2',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '2',
    studentId: '2024002',
    email: 'marie.martin@rhit.edu',
    name: 'Marie Martin',
    voteCode: 'E5F8G1H4',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '3',
    studentId: '2024003',
    email: 'pierre.bernard@rhit.edu',
    name: 'Pierre Bernard',
    voteCode: 'J6K2L7M9',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '4',
    studentId: '2024004',
    email: 'sophie.dubois@rhit.edu',
    name: 'Sophie Dubois',
    voteCode: 'N3P5Q8R1',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '5',
    studentId: '2024005',
    email: 'lucas.leroy@rhit.edu',
    name: 'Lucas Leroy',
    voteCode: 'S4T7U2V6',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '6',
    studentId: '2024006',
    email: 'emma.petit@rhit.edu',
    name: 'Emma Petit',
    voteCode: 'W9X3Y5Z8',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '7',
    studentId: '2024007',
    email: 'thomas.moreau@rhit.edu',
    name: 'Thomas Moreau',
    voteCode: 'A2B6C4D7',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '8',
    studentId: '2024008',
    email: 'laura.simon@rhit.edu',
    name: 'Laura Simon',
    voteCode: 'E8F3G5H9',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '9',
    studentId: '2024009',
    email: 'antoine.roux@rhit.edu',
    name: 'Antoine Roux',
    voteCode: 'J1K7L3M5',
    hasVoted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '10',
    studentId: '2024010',
    email: 'camille.vincent@rhit.edu',
    name: 'Camille Vincent',
    voteCode: 'N8P2Q6R4',
    hasVoted: false,
    createdAt: new Date().toISOString()
  }
]

export const useVoterStore = create<VoterStore>()(
  persist(
    (set, get) => ({
      voters: defaultVoters,

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
        // Toujours réinitialiser avec les votants par défaut (pour forcer le reset)
        if (state) {
          return { ...state, voters: defaultVoters }
        }
        return { voters: defaultVoters }
      },
    }
  )
)

