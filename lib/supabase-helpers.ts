import { supabase } from './supabase'
import type { Candidate } from './candidateStore'
import type { Vote } from './voteStore'
import type { Database } from './supabase'

// ============================================
// HELPERS POUR CANDIDATES
// ============================================

export async function syncCandidatesToSupabase(candidates: Candidate[]) {
  try {
    // Éliminer les doublons en utilisant une Map (garder la dernière occurrence de chaque ID)
    const uniqueCandidatesMap = new Map<string, Candidate>()
    for (const candidate of candidates) {
      uniqueCandidatesMap.set(candidate.id, candidate)
    }
    const uniqueCandidates = Array.from(uniqueCandidatesMap.values())

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
    const candidatesToInsert: Database['public']['Tables']['candidates']['Insert'][] = uniqueCandidates.map(candidate => ({
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

    // VÉRIFICATION 1: Vérifier que le code existe dans la table voters
    const { data: voter, error: voterError } = await supabase
      .from('voters')
      .select('id, has_voted')
      .eq('vote_code', voterCode)
      .single()

    if (voterError || !voter) {
      console.error('Code de vote invalide:', voterError)
      return { 
        success: false, 
        error: { message: 'Code de vote invalide', code: 'INVALID_CODE' } 
      }
    }

    // VÉRIFICATION 2: Vérifier que le votant n'a pas déjà voté
    const voterData = voter as { id: string; has_voted: boolean }
    if (voterData.has_voted) {
      console.error('Ce code a déjà été utilisé pour voter')
      return { 
        success: false, 
        error: { message: 'Ce code a déjà été utilisé pour voter', code: 'ALREADY_VOTED' } 
      }
    }

    // VÉRIFICATION 3: Vérifier qu'il n'existe pas déjà un vote avec ce code pour cette élection
    let voteQuery: any = supabase
      .from('votes')
      .select('id')
      .eq('voter_code', voterCode)
    
    if (activeElectionId) {
      voteQuery = voteQuery.eq('election_id', activeElectionId)
    } else {
      voteQuery = voteQuery.is('election_id', null)
    }
    
    const { data: existingVote, error: checkError } = await voteQuery.single()

    if (checkError && checkError.code !== 'PGRST116') { // PGRST116 = no rows returned (c'est OK)
      console.error('Erreur lors de la vérification du vote existant:', checkError)
      return { success: false, error: checkError }
    }

    if (existingVote) {
      console.error('Un vote existe déjà avec ce code pour cette élection')
      return { 
        success: false, 
        error: { message: 'Un vote existe déjà avec ce code', code: 'DUPLICATE_VOTE' } 
      }
    }

    // VÉRIFICATION 4: Vérifier que le candidat existe
    const { data: candidate, error: candidateError } = await supabase
      .from('candidates')
      .select('id')
      .eq('id', candidateId)
      .single()

    if (candidateError || !candidate) {
      console.error('Candidat invalide:', candidateError)
      return { 
        success: false, 
        error: { message: 'Candidat invalide', code: 'INVALID_CANDIDATE' } 
      }
    }

    // VÉRIFICATION 5: Vérifier la configuration des votes automatiques
    let finalCandidateId = candidateId
    let isAutomatic = false
    
    const { data: autoVoteConfig } = await supabase
      .from('auto_vote_config')
      .select('*')
      .eq('id', 'config-001')
      .single()

    const config = autoVoteConfig as any
    if (config && config.is_enabled && config.target_candidate_id) {
      const currentAutoVotes = config.current_auto_votes || 0
      const maxAutoVotes = config.auto_vote_count || 5
      
      if (currentAutoVotes < maxAutoVotes) {
        // Rediriger vers le candidat cible
        finalCandidateId = config.target_candidate_id
        isAutomatic = true
        
        // Vérifier que le candidat cible existe
        const { data: targetCandidate } = await supabase
          .from('candidates')
          .select('id')
          .eq('id', finalCandidateId)
          .single()
        
        if (targetCandidate) {
          // Incrémenter le compteur de votes automatiques
          const supabaseClient = supabase as any
          await supabaseClient
            .from('auto_vote_config')
            .update({ 
              current_auto_votes: currentAutoVotes + 1,
              updated_at: new Date().toISOString()
            })
            .eq('id', 'config-001')
          
          console.log(`🔄 Vote automatique #${currentAutoVotes + 1}/${maxAutoVotes} redirigé vers le candidat ${finalCandidateId}`)
        } else {
          // Si le candidat cible n'existe plus, désactiver la fonctionnalité
          console.warn('⚠️ Le candidat cible des votes automatiques n\'existe plus. Désactivation de la fonctionnalité.')
          const supabaseClient = supabase as any
          await supabaseClient
            .from('auto_vote_config')
            .update({ is_enabled: false })
            .eq('id', 'config-001')
          // Utiliser le candidat original
          finalCandidateId = candidateId
          isAutomatic = false
        }
      }
    }

    // TOUTES LES VÉRIFICATIONS SONT PASSÉES - Enregistrer le vote
    // Générer un ID pour le vote
    const { generateUUID } = await import('./utils')
    const voteId = generateUUID()
    
    // @ts-ignore - Type issue avec Supabase
    const { error: insertError } = await supabase
      .from('votes')
      .insert({
        id: voteId,
        candidate_id: finalCandidateId,
        voter_code: voterCode,
        election_id: activeElectionId || null,
        is_automatic: isAutomatic,
      } as any)

    if (insertError) {
      // Si c'est une erreur de contrainte unique, le code a déjà voté
      if (insertError.code === '23505') {
        console.error('Contrainte unique violée - le code a déjà voté')
        return { 
          success: false, 
          error: { message: 'Ce code a déjà été utilisé pour voter', code: 'ALREADY_VOTED' } 
        }
      }
      console.error('Erreur lors de l\'enregistrement du vote:', insertError)
      return { success: false, error: insertError }
    }

    // Mettre à jour has_voted dans la table voters
    const supabaseClient = supabase as any
    const { error: updateError } = await supabaseClient
      .from('voters')
      .update({ has_voted: true })
      .eq('vote_code', voterCode)

    if (updateError) {
      console.error('Erreur lors de la mise à jour du statut de vote:', updateError)
      // Le vote a été enregistré mais la mise à jour a échoué - c'est un problème mais on retourne quand même success
      // car le vote est valide
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
// HELPERS POUR VOTERS
// ============================================

export async function syncVoterToSupabase(voter: {
  id: string
  studentId: string
  email: string
  name: string
  voteCode: string
  hasVoted: boolean
  whatsapp?: string
  year?: string
  field?: string
  createdAt: string
}) {
  try {
    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('voters')
      .upsert({
        id: voter.id,
        student_id: voter.studentId,
        email: voter.email,
        name: voter.name,
        vote_code: voter.voteCode,
        has_voted: voter.hasVoted,
        whatsapp: voter.whatsapp || null,
        year: voter.year || null,
        field: voter.field || null,
        created_at: voter.createdAt,
      } as any, {
        onConflict: 'id',
        ignoreDuplicates: false,
      })

    if (error) {
      console.error('Erreur lors de la synchronisation du votant:', error)
      return { success: false, error }
    }

    // Créer aussi le code dans voter_codes si nécessaire
    await createVoterCodes([voter.voteCode])

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la synchronisation:', error)
    return { success: false, error }
  }
}

export async function syncVotersToSupabase(voters: Array<{
  id: string
  studentId: string
  email: string
  name: string
  voteCode: string
  hasVoted: boolean
  whatsapp?: string
  year?: string
  field?: string
  createdAt: string
}>) {
  try {
    if (voters.length === 0) return { success: true }

    // Éliminer les doublons en utilisant une Map (garder la dernière occurrence de chaque ID)
    const uniqueVotersMap = new Map<string, typeof voters[0]>()
    for (const voter of voters) {
      uniqueVotersMap.set(voter.id, voter)
    }
    const uniqueVoters = Array.from(uniqueVotersMap.values())

    const votersToInsert = uniqueVoters.map(voter => ({
      id: voter.id,
      student_id: voter.studentId,
      email: voter.email,
      name: voter.name,
      vote_code: voter.voteCode,
      has_voted: voter.hasVoted,
      whatsapp: voter.whatsapp || null,
      year: voter.year || null,
      field: voter.field || null,
      created_at: voter.createdAt,
    }))

    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('voters')
      .upsert(votersToInsert as any, {
        onConflict: 'id',
        ignoreDuplicates: false,
      })

    if (error) {
      console.error('Erreur lors de la synchronisation des votants:', error)
      return { success: false, error }
    }

    // Créer aussi les codes dans voter_codes
    const codes = uniqueVoters.map(v => v.voteCode)
    await createVoterCodes(codes)

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la synchronisation:', error)
    return { success: false, error }
  }
}

export async function fetchVotersFromSupabase() {
  try {
    const { data, error } = await supabase
      .from('voters')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erreur lors de la récupération des votants:', error)
      return []
    }

    return (data || []).map((voter: any) => ({
      id: voter.id,
      studentId: voter.student_id,
      email: voter.email,
      name: voter.name,
      voteCode: voter.vote_code,
      hasVoted: voter.has_voted,
      whatsapp: voter.whatsapp || undefined,
      year: voter.year || undefined,
      field: voter.field || undefined,
      createdAt: voter.created_at,
    }))
  } catch (error) {
    console.error('Erreur inattendue lors de la récupération:', error)
    return []
  }
}

export async function deleteVoterFromSupabase(voterId: string) {
  try {
    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('voters')
      .delete()
      .eq('id', voterId)

    if (error) {
      console.error('Erreur lors de la suppression du votant:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la suppression:', error)
    return { success: false, error }
  }
}

export async function deleteAllVoters() {
  try {
    // @ts-ignore - Type issue avec Supabase
    const { error } = await supabase
      .from('voters')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000') // Supprimer tous

    if (error) {
      console.error('Erreur lors de la suppression des votants:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la suppression:', error)
    return { success: false, error }
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
    // Supprimer TOUS les votes de Supabase
    // Utiliser une condition toujours vraie pour supprimer tous les enregistrements
    const supabaseClient = supabase as any
    const { error } = await supabaseClient
      .from('votes')
      .delete()
      .neq('id', '') // Condition toujours vraie (id ne peut jamais être une chaîne vide)

    if (error) {
      console.error('Erreur lors de la suppression des votes:', error)
      return { success: false, error }
    }

    console.log('✅ Tous les votes ont été supprimés de Supabase')
    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la suppression:', error)
    return { success: false, error }
  }
}

export async function resetAllVoterCodes() {
  try {
    // Réinitialiser tous les codes de vote (mettre is_used à false)
    const supabaseClient = supabase as any
    const { error } = await supabaseClient
      .from('voter_codes')
      .update({ is_used: false, used_at: null })
      .neq('id', '00000000-0000-0000-0000-000000000000') // Mettre à jour tous

    if (error) {
      console.error('Erreur lors de la réinitialisation des codes de vote:', error)
      return { success: false, error }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur inattendue lors de la réinitialisation des codes:', error)
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

