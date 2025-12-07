import { supabase } from './supabase'
import type { Candidate } from './candidateStore'
import type { Vote } from './voteStore'
import type { Database } from './supabase'

// ============================================
// HELPERS POUR CANDIDATES
// ============================================

export async function syncCandidatesToSupabase(candidates: Candidate[]) {
  try {
    // Récupérer tous les candidats existants
    const { data: existingCandidates, error: fetchError } = await supabase
      .from('candidates')
      .select('id')

    if (fetchError) {
      console.error('Erreur lors de la récupération des candidats:', fetchError)
      return { success: false, error: fetchError }
    }

    const existingIds = new Set((existingCandidates || []).map((c: { id: string }) => c.id))

    // Préparer les données pour Supabase (conversion des noms de propriétés)
    const candidatesToInsert: Database['public']['Tables']['candidates']['Insert'][] = candidates.map(candidate => ({
      id: candidate.id,
      name: candidate.name,
      position: candidate.position,
      description: candidate.description || null,
      bio: candidate.bio || null,
      year: candidate.year || null,
      program: candidate.program,
      experience: candidate.experience,
      image: candidate.image || null,
      initials: candidate.initials,
      social_links: candidate.socialLinks || {},
      created_at: candidate.createdAt,
      updated_at: new Date().toISOString(),
    }))

    // Insérer ou mettre à jour les candidats
    // @ts-ignore - Type issue avec Supabase
    const { error: upsertError } = await supabase
      .from('candidates')
      .upsert(candidatesToInsert as any, {
        onConflict: 'id',
        ignoreDuplicates: false,
      })

    if (upsertError) {
      console.error('Erreur lors de la synchronisation des candidats:', upsertError)
      return { success: false, error: upsertError }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la synchronisation:', error)
    return { success: false, error }
  }
}

export async function fetchCandidatesFromSupabase(): Promise<Candidate[]> {
  try {
    const { data, error } = await supabase
      .from('candidates')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erreur lors de la récupération des candidats:', error)
      return []
    }

    // Convertir les données Supabase vers le format de l'application
    return (data || []).map((candidate: any) => ({
      id: candidate.id,
      name: candidate.name,
      position: candidate.position,
      description: candidate.description || '',
      bio: candidate.bio || '',
      year: candidate.year || '',
      program: candidate.program || [],
      experience: candidate.experience || [],
      image: candidate.image,
      initials: candidate.initials,
      socialLinks: candidate.social_links || {},
      createdAt: candidate.created_at,
    }))
  } catch (error) {
    console.error('Erreur inattendue lors de la récupération:', error)
    return []
  }
}

// ============================================
// HELPERS POUR VOTES
// ============================================

export async function syncVoteToSupabase(
  candidateId: string,
  voterCode: string,
  electionId?: string
) {
  try {
    // Récupérer l'élection active si aucune n'est fournie
    let activeElectionId = electionId
    if (!activeElectionId) {
      const { data: activeElection } = await supabase
        .from('elections')
        .select('id')
        .eq('is_active', true)
        .single()

      if (activeElection) {
        activeElectionId = (activeElection as any).id
      }
    }

    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('votes')
      .insert({
        candidate_id: candidateId,
        voter_code: voterCode,
        election_id: activeElectionId || null,
      } as any)

    if (error) {
      console.error('Erreur lors de l\'enregistrement du vote:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de l\'enregistrement du vote:', error)
    return { success: false, error }
  }
}

export async function fetchVotesFromSupabase(electionId?: string): Promise<Vote[]> {
  try {
    let query: any = supabase
      .from('votes')
      .select('*')
      .order('created_at', { ascending: false })

    if (electionId) {
      query = query.eq('election_id', electionId)
    }

    const { data, error } = await query

    if (error) {
      console.error('Erreur lors de la récupération des votes:', error)
      return []
    }

    return (data || []).map((vote: any) => ({
      id: vote.id,
      candidateId: vote.candidate_id,
      voterCode: vote.voter_code,
      createdAt: vote.created_at,
    }))
  } catch (error) {
    console.error('Erreur inattendue lors de la récupération des votes:', error)
    return []
  }
}

// ============================================
// HELPERS POUR VOTER CODES
// ============================================

export async function checkVoterCodeValid(
  code: string,
  electionId?: string
): Promise<boolean> {
  try {
    let query: any = supabase
      .from('voter_codes')
      .select('is_used')
      .eq('code', code)
      .single()

    if (electionId) {
      query = query.eq('election_id', electionId)
    }

    const { data, error } = await query

    if (error || !data) {
      return false
    }

    return !data.is_used
  } catch (error) {
    console.error('Erreur lors de la vérification du code:', error)
    return false
  }
}

export async function createVoterCodes(
  codes: string[],
  electionId?: string
) {
  try {
    // Récupérer l'élection active si aucune n'est fournie
    let activeElectionId = electionId
    if (!activeElectionId) {
      const { data: activeElection } = await supabase
        .from('elections')
        .select('id')
        .eq('is_active', true)
        .single()

      if (activeElection) {
        activeElectionId = (activeElection as any).id
      }
    }

    const codesToInsert = codes.map(code => ({
      code,
      election_id: activeElectionId || null,
      is_used: false,
    }))

    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('voter_codes')
      .insert(codesToInsert as any)

    if (error) {
      console.error('Erreur lors de la création des codes:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la création des codes:', error)
    return { success: false, error }
  }
}

// ============================================
// HELPERS POUR ELECTIONS
// ============================================

export async function syncElectionEndDate(endDate: string | null) {
  try {
    // Récupérer l'élection active
    const { data: activeElection } = await supabase
      .from('elections')
      .select('id')
      .eq('is_active', true)
      .single()

    if (!activeElection) {
      // Créer une nouvelle élection si aucune n'existe
      // @ts-ignore - Type issue avec Supabase
      const { data: newElection, error: createError } = await supabase
        .from('elections')
        .insert({
          name: 'Élection RHIT',
          is_active: true,
          end_date: endDate,
        } as any)
        .select()
        .single()

      if (createError) {
        console.error('Erreur lors de la création de l\'élection:', createError)
        return { success: false, error: createError }
      }

      return { success: true, election: newElection }
    }

    // Mettre à jour l'élection existante
    const supabaseClient = supabase as any
    const { error: updateError } = await supabaseClient
      .from('elections')
      .update({ end_date: endDate })
      .eq('id', (activeElection as any).id)

    if (updateError) {
      console.error('Erreur lors de la mise à jour de l\'élection:', updateError)
      return { success: false, error: updateError }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la synchronisation:', error)
    return { success: false, error }
  }
}

export async function fetchElectionEndDate(): Promise<string | null> {
  try {
    const { data, error } = await supabase
      .from('elections')
      .select('end_date')
      .eq('is_active', true)
      .single()

    if (error || !data) {
      return null
    }

    return (data as any).end_date
  } catch (error) {
    console.error('Erreur lors de la récupération de la date:', error)
    return null
  }
}

// ============================================
// HELPERS POUR SUPPRIMER LES DONNÉES
// ============================================

export async function deleteAllCandidates() {
  try {
    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('candidates')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000') // Supprimer tous (condition toujours vraie)

    if (error) {
      console.error('Erreur lors de la suppression des candidats:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la suppression:', error)
    return { success: false, error }
  }
}

export async function deleteAllVoterCodes() {
  try {
    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('voter_codes')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000') // Supprimer tous

    if (error) {
      console.error('Erreur lors de la suppression des codes de voteurs:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la suppression:', error)
    return { success: false, error }
  }
}

export async function deleteAllVotes() {
  try {
    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('votes')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000') // Supprimer tous

    if (error) {
      console.error('Erreur lors de la suppression des votes:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la suppression:', error)
    return { success: false, error }
  }
}

export async function deleteAllData() {
  try {
    // Supprimer dans l'ordre (votes d'abord à cause des foreign keys)
    await deleteAllVotes()
    await deleteAllVoterCodes()
    await deleteAllCandidates()

    return { success: true }
  } catch (error) {
    console.error('Erreur lors de la suppression de toutes les données:', error)
    return { success: false, error }
  }
}

// ============================================
// HELPERS POUR RÉSULTATS
// ============================================

export async function getElectionResults(electionId?: string) {
  try {
    let query = supabase
      .from('vote_results')
      .select('*')
      .order('vote_count', { ascending: false })

    const { data, error } = await query

    if (error) {
      console.error('Erreur lors de la récupération des résultats:', error)
      return []
    }

    return data || []
  } catch (error) {
    console.error('Erreur inattendue lors de la récupération des résultats:', error)
    return []
  }
}

