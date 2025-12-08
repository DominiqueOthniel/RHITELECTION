import { createClient } from '@supabase/supabase-js'

// Types pour les tables Supabase
export interface Database {
  public: {
    Tables: {
      candidates: {
        Row: {
          id: string
          name: string
          position: string
          description: string | null
          bio: string | null
          year: string | null
          program: string[]
          experience: string[]
          image: string | null
          initials: string
          social_links: {
            linkedin?: string
            twitter?: string
            instagram?: string
            facebook?: string
            website?: string
          } | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          position: string
          description?: string | null
          bio?: string | null
          year?: string | null
          program?: string[]
          experience?: string[]
          image?: string | null
          initials: string
          social_links?: {
            linkedin?: string
            twitter?: string
            instagram?: string
            facebook?: string
            website?: string
          } | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          position?: string
          description?: string | null
          bio?: string | null
          year?: string | null
          program?: string[]
          experience?: string[]
          image?: string | null
          initials?: string
          social_links?: {
            linkedin?: string
            twitter?: string
            instagram?: string
            facebook?: string
            website?: string
          } | null
          created_at?: string
          updated_at?: string
        }
      }
      elections: {
        Row: {
          id: string
          name: string
          start_date: string | null
          end_date: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name?: string
          start_date?: string | null
          end_date?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          start_date?: string | null
          end_date?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      voters: {
        Row: {
          id: string
          student_id: string
          email: string
          name: string
          vote_code: string
          has_voted: boolean
          created_at: string
        }
        Insert: {
          id?: string
          student_id: string
          email: string
          name: string
          vote_code: string
          has_voted?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          student_id?: string
          email?: string
          name?: string
          vote_code?: string
          has_voted?: boolean
          created_at?: string
        }
      }
      voter_codes: {
        Row: {
          id: string
          code: string
          is_used: boolean
          used_at: string | null
          election_id: string | null
          voter_id: string | null
          created_at: string
        }
        Insert: {
          id?: string
          code: string
          is_used?: boolean
          used_at?: string | null
          election_id?: string | null
          voter_id?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          code?: string
          is_used?: boolean
          used_at?: string | null
          election_id?: string | null
          voter_id?: string | null
          created_at?: string
        }
      }
      votes: {
        Row: {
          id: string
          candidate_id: string
          voter_code: string
          election_id: string | null
          created_at: string
        }
        Insert: {
          id?: string
          candidate_id: string
          voter_code: string
          election_id?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          candidate_id?: string
          voter_code?: string
          election_id?: string | null
          created_at?: string
        }
      }
    }
    Views: {
      vote_results: {
        Row: {
          candidate_id: string
          name: string
          position: string
          initials: string
          vote_count: number
          vote_percentage: number
        }
      }
      election_stats: {
        Row: {
          election_id: string
          name: string
          start_date: string | null
          end_date: string | null
          is_active: boolean
          total_votes: number
          total_codes: number
          used_codes: number
          total_candidates: number
        }
      }
    }
    Functions: {
      is_voter_code_valid: {
        Args: {
          p_code: string
          p_election_id: string
        }
        Returns: boolean
      }
      get_election_results: {
        Args: {
          p_election_id: string
        }
        Returns: {
          candidate_id: string
          candidate_name: string
          position: string
          vote_count: number
          vote_percentage: number
        }[]
      }
    }
  }
}

// Initialisation du client Supabase
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY'
  )
}

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: false, // Désactiver la persistance de session pour cette app
  },
})

// Client admin (optionnel, pour les opérations côté serveur)
export const createAdminClient = () => {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!serviceRoleKey) {
    throw new Error('Missing SUPABASE_SERVICE_ROLE_KEY for admin operations')
  }
  return createClient<Database>(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  })
}


