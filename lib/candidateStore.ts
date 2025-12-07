import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { syncCandidatesToSupabase, fetchCandidatesFromSupabase, deleteAllCandidates } from './supabase-helpers'

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

// Candidats par défaut
const defaultCandidates: Candidate[] = [
  {
    id: '1',
    name: 'Alexandre Moreau',
    position: 'Président',
    description: 'Leader visionnaire pour une communauté étudiante dynamique et unie',
    bio: 'Étudiant en 2ème année de Génie Civil, je suis passionné par le leadership et l\'engagement étudiant. Mon expérience en gestion de projets et ma vision pour l\'avenir de RHIT font de moi le candidat idéal pour représenter vos intérêts et améliorer la vie étudiante sur le campus.',
    year: '2ème année - Civil Engineering',
    program: [
      'Modernisation des infrastructures étudiantes',
      'Renforcement du soutien académique et mentorat',
      'Développement d\'activités culturelles et sportives',
      'Transparence totale dans la gestion du budget'
    ],
    experience: [
      'Représentant de classe (2 ans)',
      'Organisateur de 10+ événements étudiants',
      'Membre actif du club Génie Civil',
      'Tuteur bénévole en mathématiques'
    ],
    image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop&crop=faces&auto=format&q=80',
    initials: 'AM',
    socialLinks: {
      linkedin: 'https://linkedin.com/in/alexandre-moreau',
      twitter: 'https://twitter.com/alexmoreau',
      instagram: 'https://instagram.com/alex.moreau'
    },
    createdAt: new Date().toISOString()
  },
  {
    id: '2',
    name: 'Sarah Chen',
    position: 'Président',
    description: 'Stratège en business et communication pour connecter les étudiants',
    bio: 'Étudiante en 2ème année de Business, je souhaite mettre mes compétences en communication et stratégie au service de tous les étudiants. Mon objectif est de créer des ponts entre les différentes filières et de développer un réseau solide pour l\'avenir professionnel de chacun.',
    year: '2ème année - Business Administration',
    program: [
      'Création d\'un réseau d\'entreprises partenaires',
      'Organisation d\'événements networking mensuels',
      'Amélioration de la communication digitale',
      'Programme de développement professionnel'
    ],
    experience: [
      'Fondatrice du club entrepreneuriat',
      'Responsable communication (1 an)',
      'Organisatrice de conférences business',
      'Mentor pour les étudiants de 1ère année'
    ],
    image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&h=500&fit=crop&crop=faces&auto=format&q=80',
    initials: 'SC',
    socialLinks: {
      linkedin: 'https://linkedin.com/in/sarah-chen',
      instagram: 'https://instagram.com/sarah.chen',
      website: 'https://sarahchen.com'
    },
    createdAt: new Date().toISOString()
  },
  {
    id: '3',
    name: 'Lucas Rodriguez',
    position: 'Président',
    description: 'Organisateur passionné pour une administration efficace et transparente',
    bio: 'Étudiant en 2ème année d\'Informatique, je suis déterminé à améliorer l\'organisation et la transparence du Bureau des Étudiants. Mon expertise technique et mon sens de l\'organisation me permettront de moderniser les processus administratifs et de faciliter la communication avec tous les étudiants.',
    year: '2ème année - Computer Science',
    program: [
      'Digitalisation des processus administratifs',
      'Création d\'une plateforme de communication étudiante',
      'Amélioration de la gestion documentaire',
      'Formation des membres du BDE aux outils numériques'
    ],
    experience: [
      'Développeur web freelance',
      'Organisateur d\'hackathons étudiants',
      'Membre du club informatique',
      'Tuteur en programmation'
    ],
    image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=500&h=500&fit=crop&crop=faces&auto=format&q=80',
    initials: 'LR',
    socialLinks: {
      linkedin: 'https://linkedin.com/in/lucas-rodriguez',
      twitter: 'https://twitter.com/lucasrod',
      website: 'https://github.com/lucasrod'
    },
    createdAt: new Date().toISOString()
  },
  {
    id: '4',
    name: 'Emma Laurent',
    position: 'Président',
    description: 'Gestionnaire rigoureuse pour une transparence financière totale',
    bio: 'Étudiante en 2ème année de Finance, je souhaite apporter mon expertise en gestion budgétaire et ma rigueur au Bureau des Étudiants. Mon objectif est d\'assurer une transparence totale dans la gestion des finances et de maximiser l\'impact de chaque euro dépensé pour le bénéfice de tous les étudiants.',
    year: '2ème année - Finance',
    program: [
      'Transparence totale du budget étudiant',
      'Optimisation des dépenses et recherche de financements',
      'Création d\'un fonds d\'urgence pour les projets étudiants',
      'Rapports financiers mensuels accessibles à tous'
    ],
    experience: [
      'Trésorière adjointe du club finance',
      'Gestionnaire de budget pour événements étudiants',
      'Stage en comptabilité d\'entreprise',
      'Organisatrice de conférences financières'
    ],
    image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&h=500&fit=crop&crop=faces&auto=format&q=80',
    initials: 'EL',
    socialLinks: {
      linkedin: 'https://linkedin.com/in/emma-laurent',
      instagram: 'https://instagram.com/emma.laurent',
      website: 'https://emma-laurent.com'
    },
    createdAt: new Date().toISOString()
  },
  {
    id: '5',
    name: 'Mohamed Benali',
    position: 'Président',
    description: 'Créateur d\'expériences mémorables pour tous les étudiants',
    bio: 'Étudiant en 2ème année de Marketing, je suis passionné par l\'organisation d\'événements et la création de moments inoubliables. Mon objectif est de diversifier les activités proposées aux étudiants et de créer une vie étudiante riche et dynamique qui rassemble tous les membres de notre communauté.',
    year: '2ème année - Marketing',
    program: [
      'Organisation d\'événements variés chaque mois',
      'Création d\'un calendrier d\'activités annuel',
      'Partenariats avec des associations locales',
      'Système de suggestions d\'événements par les étudiants'
    ],
    experience: [
      'Organisateur de 20+ événements étudiants',
      'Coordinateur de festivals culturels',
      'Membre du comité d\'organisation de la rentrée',
      'Bénévole dans plusieurs associations'
    ],
    image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&h=500&fit=crop&crop=faces&auto=format&q=80',
    initials: 'MB',
    socialLinks: {
      linkedin: 'https://linkedin.com/in/mohamed-benali',
      twitter: 'https://twitter.com/mohamedbenali',
      instagram: 'https://instagram.com/mohamed.benali',
      facebook: 'https://facebook.com/mohamed.benali'
    },
    createdAt: new Date().toISOString()
  },
  {
    id: '6',
    name: 'Clara Rousseau',
    position: 'Président',
    description: 'Voix créative pour connecter et informer toute la communauté',
    bio: 'Étudiante en 2ème année de Communication, je souhaite mettre mes compétences en communication digitale et créativité au service de tous les étudiants. Mon objectif est d\'améliorer la visibilité des initiatives du BDE et de créer une communication claire, moderne et engageante avec toute la communauté étudiante.',
    year: '2ème année - Communication',
    program: [
      'Modernisation de la communication digitale',
      'Création d\'une newsletter hebdomadaire',
      'Développement de la présence sur les réseaux sociaux',
      'Formation des membres aux outils de communication'
    ],
    experience: [
      'Community manager pour plusieurs associations',
      'Créatrice de contenu digital',
      'Responsable communication du club média',
      'Organisatrice de campagnes de sensibilisation'
    ],
    image: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&h=500&fit=crop&crop=faces&auto=format&q=80',
    initials: 'CR',
    socialLinks: {
      linkedin: 'https://linkedin.com/in/clara-rousseau',
      instagram: 'https://instagram.com/clara.rousseau',
      twitter: 'https://twitter.com/clararousseau',
      website: 'https://clara-rousseau.com'
    },
    createdAt: new Date().toISOString()
  }
]

export const useCandidateStore = create<CandidateStore>()(
  persist(
    (set, get) => ({
      candidates: defaultCandidates,

      addCandidate: async (candidateData) => {
        const newCandidate: Candidate = {
          ...candidateData,
          id: Date.now().toString(),
          initials: candidateData.initials ?? generateInitials(candidateData.name),
          createdAt: new Date().toISOString(),
        }
        set((state) => ({
          candidates: [...state.candidates, newCandidate],
        }))
        // Synchroniser avec Supabase
        await syncCandidatesToSupabase([...get().candidates, newCandidate])
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
        const currentCandidates = get().candidates
        if (!currentCandidates || currentCandidates.length === 0) {
          set({ candidates: defaultCandidates })
          // Synchroniser les candidats par défaut avec Supabase
          await syncCandidatesToSupabase(defaultCandidates)
        }
      },

      syncFromSupabase: async () => {
        const supabaseCandidates = await fetchCandidatesFromSupabase()
        if (supabaseCandidates.length > 0) {
          set({ candidates: supabaseCandidates })
        }
      },
    }),
    {
      name: 'candidate-storage',
      storage: createJSONStorage(() => localStorage),
      onRehydrateStorage: () => (state) => {
        // Charger les candidats par défaut si le store est vide ou n'existe pas
        if (!state || !state.candidates || state.candidates.length === 0) {
          return { candidates: defaultCandidates }
        }
        return state
      },
    }
  )
)

