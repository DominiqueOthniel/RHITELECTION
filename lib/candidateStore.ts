import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { syncCandidatesToSupabase, fetchCandidatesFromSupabase, deleteAllCandidates } from './supabase-helpers'
import { generateUUID } from './utils'

export interface Candidate {
  id: string
  name: string
  position: string
  description: string
  bio: string
  year: string
  program: string[]
  experience: string[]
  image?: string // URL ou base64 pour les images uploadées
  initials: string
  socialLinks?: {
    linkedin?: string
    twitter?: string
    instagram?: string
    facebook?: string
    website?: string
  }
  createdAt: string
}

type NewCandidateInput = Omit<Candidate, 'id' | 'createdAt'> & { initials?: string }

interface CandidateStore {
  candidates: Candidate[]
  addCandidate: (candidate: NewCandidateInput) => Promise<void>
  updateCandidate: (id: string, candidate: Partial<Candidate>) => Promise<void>
  deleteCandidate: (id: string) => Promise<void>
  getCandidateById: (id: string) => Candidate | undefined
  clearAllCandidates: () => Promise<void>
  initializeDefaultCandidates: () => Promise<void>
  syncFromSupabase: () => Promise<void>
}

// Génère les initiales à partir du nom
function generateInitials(name: string): string {
  const parts = name.trim().split(' ')
  if (parts.length >= 2) {
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

// Plus de candidats par défaut - les données doivent être ajoutées manuellement

export const useCandidateStore = create<CandidateStore>()(
  persist(
    (set, get) => ({
      candidates: [],

      addCandidate: async (candidateData) => {
        const newCandidate: Candidate = {
          ...candidateData,
          id: generateUUID(),
          initials: candidateData.initials ?? generateInitials(candidateData.name),
          createdAt: new Date().toISOString(),
        }
        set((state) => ({
          candidates: [...state.candidates, newCandidate],
        }))
        // Synchroniser avec Supabase (get().candidates contient déjà le nouveau candidat)
        await syncCandidatesToSupabase(get().candidates)
      },

      updateCandidate: async (id: string, updates: Partial<Candidate>) => {
        set((state) => ({
          candidates: state.candidates.map((c) =>
            c.id === id ? { ...c, ...updates } : c
          ),
        }))
        // Synchroniser avec Supabase
        await syncCandidatesToSupabase(get().candidates)
      },

      deleteCandidate: async (id: string) => {
        set((state) => ({
          candidates: state.candidates.filter((c) => c.id !== id),
        }))
        // Synchroniser avec Supabase
        await syncCandidatesToSupabase(get().candidates)
      },

      getCandidateById: (id: string) => {
        return get().candidates.find((c) => c.id === id)
      },

      clearAllCandidates: async () => {
        set({ candidates: [] })
        // Supprimer aussi dans Supabase
        await deleteAllCandidates()
      },

      initializeDefaultCandidates: async () => {
        // Toujours charger depuis Supabase pour synchroniser avec la base de données
        const supabaseCandidates = await fetchCandidatesFromSupabase()
        if (supabaseCandidates.length > 0) {
          set({ candidates: supabaseCandidates })
        } else {
          // Si Supabase est vide, s'assurer que le store local est aussi vide
          set({ candidates: [] })
        }
      },

      syncFromSupabase: async () => {
        // Toujours charger depuis Supabase pour synchroniser avec la base de données
        const supabaseCandidates = await fetchCandidatesFromSupabase()
        set({ candidates: supabaseCandidates }) // Même si vide, on synchronise
      },
    }),
    {
      name: 'candidate-storage',
      storage: createJSONStorage(() => localStorage),
      onRehydrateStorage: () => (state) => {
        // Ne pas charger depuis localStorage, on chargera depuis Supabase
        // Retourner un état vide pour forcer le chargement depuis Supabase
        return { candidates: [] }
      },
    }
  )
)

