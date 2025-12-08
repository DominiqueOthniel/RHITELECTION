'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Vote, Lock, CheckCircle, ArrowLeft, Key, AlertCircle, XCircle, User, Award, BookOpen, Target, Sparkles, GraduationCap, Briefcase, UserCircle, Linkedin, Twitter, Instagram, Facebook, Globe, ExternalLink, X, Clock, ArrowRight, QrCode, Trophy } from 'lucide-react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import { useVoterStore } from '@/lib/store'
import { useCandidateStore } from '@/lib/candidateStore'
import { useVoteStore } from '@/lib/voteStore'
import { useElectionStore } from '@/lib/electionStore'
import QRCodeScanner from '@/components/QRCodeScanner'

export default function VotePage() {
  const router = useRouter()
  const { getVoterByCode, markAsVoted, syncFromSupabase: syncVotersFromSupabase } = useVoterStore()
  const { candidates, initializeDefaultCandidates } = useCandidateStore()
  const { addVote, syncFromSupabase: syncVotesFromSupabase } = useVoteStore()
  const { getTimeRemaining, isElectionEnded, isElectionStarted, syncFromSupabase: syncElectionFromSupabase } = useElectionStore()
  const [showAuthModal, setShowAuthModal] = useState(false)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [step, setStep] = useState<'browse' | 'vote' | 'confirm'>('browse')
  const [voteCode, setVoteCode] = useState('')
  const [error, setError] = useState('')
  const [voterInfo, setVoterInfo] = useState<{ name: string; email: string } | null>(null)
  const [selectedCandidate, setSelectedCandidate] = useState<string | null>(null)
  const [mounted, setMounted] = useState(false)
  const [timeRemaining, setTimeRemaining] = useState<{ days: number; hours: number; minutes: number; seconds: number; total: number } | null>(null)
  const [showQRScanner, setShowQRScanner] = useState(false)

  // S'assurer que le composant est monté avant d'afficher les données
  useEffect(() => {
    const init = async () => {
      try {
        // Synchroniser toutes les données depuis Supabase au démarrage en parallèle
        await Promise.all([
          syncElectionFromSupabase(), // Synchroniser la date de fin d'élection
          initializeDefaultCandidates(), // Charge les candidats depuis Supabase
          syncVotersFromSupabase(), // Charge les votants depuis Supabase
          syncVotesFromSupabase(), // Charge les votes depuis Supabase
        ])
        setMounted(true)

        // Vérifier si un code est passé en paramètre URL
        if (typeof window !== 'undefined') {
          const params = new URLSearchParams(window.location.search)
          const codeParam = params.get('code')
          const authParam = params.get('auth')
          
          // Si auth=true, ouvrir directement le modal d'authentification
          if (authParam === 'true') {
            if (!isElectionEnded()) {
              setShowAuthModal(true)
            } else {
              setError('Les votes sont terminés. L\'élection est fermée.')
            }
            return
          }
          
          if (codeParam) {
            // Ne pas authentifier automatiquement si l'élection est terminée
            if (isElectionEnded()) {
              setError('Les votes sont terminés. L\'élection est fermée.')
              setShowAuthModal(true)
              setVoteCode(codeParam.toUpperCase())
              return
            }
            setVoteCode(codeParam.toUpperCase())
            // Essayer d'authentifier automatiquement
            const voter = getVoterByCode(codeParam.toUpperCase())
            if (voter && !voter.hasVoted) {
              setVoterInfo({ name: voter.name, email: voter.email })
              setIsAuthenticated(true)
              setStep('vote')
            } else {
              // Si l'authentification automatique échoue, ouvrir le modal avec le code pré-rempli
              setShowAuthModal(true)
            }
          }
        }
      } catch (error) {
        console.error('Erreur lors de l\'initialisation:', error)
        setMounted(true) // Afficher quand même la page même en cas d'erreur
      }
    }
    init()
  }, [initializeDefaultCandidates, getVoterByCode, isElectionEnded, syncVotersFromSupabase, syncElectionFromSupabase, syncVotesFromSupabase])

  // Rafraîchir les données toutes les 5 secondes pour rester synchronisé
  useEffect(() => {
    const refreshInterval = setInterval(async () => {
      try {
        await Promise.all([
          syncElectionFromSupabase(), // Synchroniser la date de fin d'élection
          syncVotersFromSupabase(), // Synchroniser les votants
          syncVotesFromSupabase(), // Synchroniser les votes
        ])
      } catch (error) {
        console.error('Erreur lors du rafraîchissement:', error)
      }
    }, 5000) // Rafraîchir toutes les 5 secondes

    return () => clearInterval(refreshInterval)
  }, [syncElectionFromSupabase, syncVotersFromSupabase, syncVotesFromSupabase])

  // Mise à jour du compte à rebours
  useEffect(() => {
    const updateCountdown = () => {
      const remaining = getTimeRemaining()
      setTimeRemaining(remaining)
    }

    updateCountdown()
    const interval = setInterval(updateCountdown, 1000)

    return () => clearInterval(interval)
  }, [getTimeRemaining])

  const handleAuth = (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    
    // Vérifier si l'élection est terminée
    if (isElectionEnded()) {
      setError('Les votes sont terminés. L\'élection est fermée.')
      return
    }
    
    if (!voteCode) {
      setError('Veuillez entrer votre code de vote')
      return
    }

    const voter = getVoterByCode(voteCode.toUpperCase())
    
    if (!voter) {
      setError('Code de vote invalide. Veuillez vérifier votre code.')
      return
    }

    if (voter.hasVoted) {
      setError('Ce code a déjà été utilisé pour voter. Chaque code ne peut être utilisé qu\'une seule fois.')
      return
    }

    setVoterInfo({ name: voter.name, email: voter.email })
    setIsAuthenticated(true)
    setShowAuthModal(false)
    setStep('vote')
  }

  const handleOpenAuth = () => {
    // Vérifier si l'élection est terminée
    if (isElectionEnded()) {
      setError('Les votes sont terminés. L\'élection est fermée.')
      return
    }
    setShowAuthModal(true)
    setError('')
    setVoteCode('')
  }

  const handleQRScan = (decodedText: string) => {
    // Vérifier si l'élection est terminée
    if (isElectionEnded()) {
      setShowQRScanner(false)
      setError('Les votes sont terminés. L\'élection est fermée.')
      setShowAuthModal(true)
      return
    }

    // Extraire le code de vote de l'URL si c'est une URL, sinon utiliser directement
    let code = decodedText
    try {
      const url = new URL(decodedText)
      const codeParam = url.searchParams.get('code')
      if (codeParam) {
        code = codeParam
      } else if (url.pathname.includes('/vote')) {
        // Si c'est juste l'URL, on ouvre le modal
        setShowAuthModal(true)
        return
      }
    } catch {
      // Ce n'est pas une URL, utiliser directement comme code
    }
    
    setVoteCode(code.toUpperCase())
    setShowQRScanner(false)
    // Simuler la soumission du formulaire
    const voter = getVoterByCode(code.toUpperCase())
    if (voter) {
      if (voter.hasVoted) {
        setError('Ce code a déjà été utilisé pour voter.')
        setShowAuthModal(true)
      } else {
        setVoterInfo({ name: voter.name, email: voter.email })
        setIsAuthenticated(true)
        setStep('vote')
      }
    } else {
      setError('Code de vote invalide.')
      setShowAuthModal(true)
    }
  }

  const handleVote = async () => {
    // Vérifier si l'élection est terminée
    if (isElectionEnded()) {
      alert('Les votes sont terminés. L\'élection est fermée. Vous ne pouvez plus voter.')
      return
    }
    
    if (selectedCandidate && voteCode) {
      // Enregistrer le vote
      await addVote(selectedCandidate, voteCode.toUpperCase())
      // Marquer le code comme utilisé
      await markAsVoted(voteCode.toUpperCase())
      setStep('confirm')
      
      // Rediriger automatiquement vers les statistiques après 3 secondes
      setTimeout(() => {
        router.push('/')
      }, 3000)
    }
  }

  const handleGoToResults = () => {
    router.push('/')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-gray-50 to-white">
      {/* Header */}
      <header className="glass-effect sticky top-0 z-50 border-b border-bordeaux-200/20">
        <div className="container mx-auto px-4 sm:px-6 py-3 sm:py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-2 sm:space-x-3">
            <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl flex items-center justify-center shadow-bordeaux overflow-hidden">
              <Image 
                src="/logo.webp" 
                alt="RHIT Logo" 
                width={48} 
                height={48} 
                className="object-contain"
              />
            </div>
            <div>
              <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900">RHIT Élections</h1>
              <p className="text-xs sm:text-sm text-gray-600 hidden sm:block">Bureau des Étudiants</p>
            </div>
          </Link>
          <Link href="/">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="px-3 py-2 sm:px-4 sm:py-2 text-gray-700 hover:text-bordeaux-600 text-sm sm:text-base font-medium rounded-lg flex items-center space-x-1 sm:space-x-2"
            >
              <ArrowLeft className="w-4 h-4" />
              <span className="hidden sm:inline">Retour</span>
            </motion.button>
          </Link>
        </div>
      </header>

      <div className="container mx-auto px-4 sm:px-6 py-8 sm:py-12 max-w-6xl">
        {/* Compte à rebours */}
        {timeRemaining && timeRemaining.total > 0 && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-gradient-to-r from-bordeaux-600 to-bordeaux-700 rounded-2xl p-4 sm:p-6 mb-6 sm:mb-8 text-white shadow-bordeaux-lg"
          >
            <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
              <div className="flex items-center space-x-3">
                <Clock className="w-6 h-6 sm:w-8 sm:h-8" />
                <div>
                  <p className="text-sm sm:text-base font-semibold opacity-90">Temps restant pour voter</p>
                  <p className="text-xs sm:text-sm opacity-75">Les votes se terminent dans</p>
                </div>
              </div>
              <div className="flex items-center gap-3 sm:gap-6">
                {timeRemaining.days > 0 && (
                  <div className="text-center">
                    <div className="text-2xl sm:text-3xl md:text-4xl font-bold">{String(timeRemaining.days).padStart(2, '0')}</div>
                    <div className="text-xs sm:text-sm opacity-75">Jour{timeRemaining.days > 1 ? 's' : ''}</div>
                  </div>
                )}
                <div className="text-center">
                  <div className="text-2xl sm:text-3xl md:text-4xl font-bold">{String(timeRemaining.hours).padStart(2, '0')}</div>
                  <div className="text-xs sm:text-sm opacity-75">Heure{timeRemaining.hours > 1 ? 's' : ''}</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl sm:text-3xl md:text-4xl font-bold">{String(timeRemaining.minutes).padStart(2, '0')}</div>
                  <div className="text-xs sm:text-sm opacity-75">Min</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl sm:text-3xl md:text-4xl font-bold">{String(timeRemaining.seconds).padStart(2, '0')}</div>
                  <div className="text-xs sm:text-sm opacity-75">Sec</div>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {timeRemaining && timeRemaining.total <= 0 && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-red-500 rounded-2xl p-4 sm:p-6 mb-6 sm:mb-8 text-white text-center shadow-lg"
          >
            <AlertCircle className="w-8 h-8 sm:w-10 sm:h-10 mx-auto mb-2" />
            <p className="text-lg sm:text-xl font-bold">Les votes sont terminés</p>
            <p className="text-sm sm:text-base opacity-90 mt-1">Consultez les résultats maintenant</p>
          </motion.div>
        )}

        {/* Header Section */}
        <div className="text-center mb-8 sm:mb-10">
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="inline-flex items-center space-x-2 bg-bordeaux-50 px-3 sm:px-4 py-1.5 sm:py-2 rounded-full mb-3 sm:mb-4"
          >
            <Sparkles className="w-3 h-3 sm:w-4 sm:h-4 text-bordeaux-600" />
            <span className="text-xs sm:text-sm font-semibold text-bordeaux-700">Élection 2024</span>
          </motion.div>
          <h2 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 mb-2 sm:mb-3 px-2">
            Élection du{' '}
            <span className="text-bordeaux-600">
              Bureau des Étudiants
            </span>
          </h2>
          <p className="text-gray-600 text-base sm:text-lg px-2 mb-6 sm:mb-8">
            {isAuthenticated ? 'Sélectionnez votre candidat et confirmez votre vote' : 'Découvrez les candidats'}
          </p>
          
          {!isAuthenticated && (
            <>
              {isElectionEnded() ? (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="mb-8"
                >
                  <div className="bg-red-50 border-2 border-red-500 rounded-2xl p-6 text-center max-w-md mx-auto">
                    <AlertCircle className="w-12 h-12 text-red-600 mx-auto mb-3" />
                    <h3 className="text-xl font-bold text-red-900 mb-2">Les votes sont terminés</h3>
                    <p className="text-red-700 mb-4">L&apos;élection est fermée. Vous ne pouvez plus voter.</p>
                    <Link href="/results">
                      <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        className="px-6 py-3 bg-red-600 text-white font-semibold rounded-xl hover:bg-red-700 transition-colors flex items-center space-x-2 mx-auto"
                      >
                        <Trophy className="w-5 h-5" />
                        <span>Voir les résultats</span>
                      </motion.button>
                    </Link>
                  </div>
                </motion.div>
              ) : isElectionStarted() ? (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="mb-8"
                >
                  <motion.button
                    onClick={handleOpenAuth}
                    whileHover={{ scale: 1.05, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    className="px-8 py-4 sm:px-10 sm:py-5 gradient-bordeaux text-white text-base sm:text-lg font-semibold rounded-2xl shadow-bordeaux-lg hover:shadow-bordeaux-lg transition-all duration-300 flex items-center space-x-3 mx-auto"
                  >
                    <Vote className="w-5 h-5 sm:w-6 sm:h-6" />
                    <span>Voter maintenant</span>
                    <Lock className="w-4 h-4 sm:w-5 sm:h-5" />
                  </motion.button>
                </motion.div>
              ) : null}
            </>
          )}

          {isAuthenticated && voterInfo && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-bordeaux-50 border-2 border-bordeaux-200 rounded-xl p-4 sm:p-6 mb-6 sm:mb-8 max-w-2xl mx-auto"
            >
              <div className="flex items-center justify-center flex-wrap gap-3">
                <div className="text-center sm:text-left">
                  <p className="text-xs sm:text-sm text-bordeaux-700 mb-1">Vous votez en tant que:</p>
                  <p className="text-base sm:text-lg font-bold text-bordeaux-900">{voterInfo.name}</p>
                  <p className="text-xs sm:text-sm text-bordeaux-600">{voterInfo.email}</p>
                </div>
                <CheckCircle className="w-6 h-6 sm:w-8 sm:h-8 text-bordeaux-600 flex-shrink-0" />
              </div>
            </motion.div>
          )}
        </div>

        {/* Candidates Display */}
        {!mounted ? (
                <div className="bg-white rounded-2xl shadow-xl p-12 text-center">
                  <p className="text-gray-500 text-lg">Chargement des candidats...</p>
                </div>
              ) : candidates.length === 0 ? (
                <div className="bg-white rounded-2xl shadow-xl p-12 text-center">
                  <UserCircle className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <h3 className="text-xl font-bold text-gray-900 mb-2">Aucun candidat disponible</h3>
                  <p className="text-gray-600">Les candidats n&apos;ont pas encore été enregistrés par l&apos;administrateur.</p>
                </div>
              ) : (
              <div className="grid md:grid-cols-1 gap-6 mb-8">
                {candidates.map((candidate, index) => (
                  <motion.div
                    key={candidate.id}
                    initial={{ opacity: 0, y: 30 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.15, type: "spring", stiffness: 100 }}
                    onClick={() => {
                      if (isAuthenticated && !isElectionEnded()) {
                        setSelectedCandidate(candidate.id)
                      } else if (isElectionEnded()) {
                        alert('Les votes sont terminés. L\'élection est fermée.')
                      }
                    }}
                    className={`group relative bg-white rounded-2xl overflow-hidden border-2 transition-all duration-500 ${
                      isAuthenticated && !isElectionEnded() ? 'cursor-pointer' : 'cursor-default'
                    } ${
                      selectedCandidate === candidate.id
                        ? 'border-bordeaux-500 shadow-bordeaux-lg scale-[1.02]'
                        : isAuthenticated && !isElectionEnded()
                        ? 'border-gray-200 hover:border-bordeaux-300 hover:shadow-xl'
                        : 'border-gray-200 opacity-75'
                    }`}
                  >
                    {/* Gradient overlay when selected */}
                    {selectedCandidate === candidate.id && (
                      <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="absolute inset-0 bg-gradient-to-br from-bordeaux-50/50 to-transparent pointer-events-none"
                      />
                    )}

                    <div className="p-4 sm:p-6 md:p-8">
                      <div className="flex flex-col md:flex-row gap-4 sm:gap-6">
                        {/* Photo/Avatar Section */}
                        <div className="flex-shrink-0 flex justify-center md:justify-start">
                          <motion.div
                            whileHover={{ scale: 1.05, rotate: 2 }}
                            className={`relative w-28 h-28 sm:w-32 sm:h-32 md:w-40 md:h-40 rounded-2xl overflow-hidden shadow-lg ${
                              selectedCandidate === candidate.id
                                ? 'ring-4 ring-bordeaux-500 ring-offset-2'
                                : ''
                            }`}
                          >
                            {candidate.image ? (
                              // eslint-disable-next-line @next/next/no-img-element
                              <img
                                src={candidate.image}
                                alt={candidate.name}
                                className="w-full h-full object-cover"
                                onError={(e) => {
                                  // Fallback sur les initiales si l'image ne charge pas
                                  const target = e.target as HTMLImageElement
                                  target.style.display = 'none'
                                  const parent = target.parentElement
                                  if (parent && !parent.querySelector('.fallback-initials')) {
                                    const fallback = document.createElement('div')
                                    fallback.className = 'w-full h-full gradient-bordeaux flex items-center justify-center fallback-initials'
                                    fallback.innerHTML = `<span class="text-4xl md:text-5xl font-bold text-white">${candidate.initials}</span>`
                                    parent.appendChild(fallback)
                                  }
                                }}
                              />
                            ) : (
                              <div className="w-full h-full gradient-bordeaux flex items-center justify-center">
                                <span className="text-4xl md:text-5xl font-bold text-white">
                                  {candidate.initials}
                                </span>
                              </div>
                            )}
                            {selectedCandidate === candidate.id && (
                              <motion.div
                                initial={{ scale: 0 }}
                                animate={{ scale: 1 }}
                                className="absolute top-2 right-2 w-10 h-10 bg-green-500 rounded-full flex items-center justify-center shadow-lg"
                              >
                                <CheckCircle className="w-6 h-6 text-white" />
                              </motion.div>
                            )}
                          </motion.div>
                        </div>

                        {/* Content Section */}
                        <div className="flex-1">
                          <div className="flex items-start justify-between mb-3 sm:mb-4">
                            <div className="flex-1 min-w-0">
                              <h3 className="text-xl sm:text-2xl md:text-3xl font-bold text-gray-900 mb-1 break-words">
                                {candidate.name}
                              </h3>
                              <div className="flex flex-wrap items-center gap-2 sm:gap-3 mb-2 sm:mb-3">
                                <span className="inline-flex items-center px-2 sm:px-3 py-1 rounded-full text-xs sm:text-sm font-semibold bg-bordeaux-100 text-bordeaux-700">
                                  {candidate.position}
                                </span>
                                <span className="inline-flex items-center text-xs sm:text-sm text-gray-600">
                                  <GraduationCap className="w-3 h-3 sm:w-4 sm:h-4 mr-1" />
                                  {candidate.year}
                                </span>
                              </div>
                              <p className="text-base sm:text-lg text-gray-700 font-medium mb-3 sm:mb-4">
                                {candidate.description}
                              </p>
                            </div>
                          </div>

                          {/* Bio */}
                          <div className="mb-6">
                            <div className="flex items-center space-x-2 mb-2">
                              <User className="w-4 h-4 text-bordeaux-600" />
                              <h4 className="font-semibold text-gray-900">À propos</h4>
                            </div>
                            <p className="text-gray-600 leading-relaxed text-sm md:text-base">
                              {candidate.bio}
                            </p>
                          </div>

                          {/* Program */}
                          <div className="mb-4 sm:mb-6">
                            <div className="flex items-center space-x-2 mb-2 sm:mb-3">
                              <Target className="w-3 h-3 sm:w-4 sm:h-4 text-bordeaux-600" />
                              <h4 className="text-sm sm:text-base font-semibold text-gray-900">Programme électoral</h4>
                            </div>
                            <div className="grid sm:grid-cols-2 gap-2">
                              {candidate.program.map((item, idx) => (
                                <motion.div
                                  key={idx}
                                  initial={{ opacity: 0, x: -10 }}
                                  animate={{ opacity: 1, x: 0 }}
                                  transition={{ delay: index * 0.15 + idx * 0.05 }}
                                  className="flex items-start space-x-2 text-sm text-gray-700"
                                >
                                  <div className="w-1.5 h-1.5 rounded-full bg-bordeaux-500 mt-2 flex-shrink-0" />
                                  <span>{item}</span>
                                </motion.div>
                              ))}
                            </div>
                          </div>

                          {/* Experience */}
                          <div className="mb-4 sm:mb-6">
                            <div className="flex items-center space-x-2 mb-2 sm:mb-3">
                              <Award className="w-3 h-3 sm:w-4 sm:h-4 text-bordeaux-600" />
                              <h4 className="text-sm sm:text-base font-semibold text-gray-900">Expérience</h4>
                            </div>
                            <div className="space-y-2">
                              {candidate.experience.map((exp, idx) => (
                                <motion.div
                                  key={idx}
                                  initial={{ opacity: 0, x: -10 }}
                                  animate={{ opacity: 1, x: 0 }}
                                  transition={{ delay: index * 0.15 + idx * 0.05 }}
                                  className="flex items-start space-x-2 text-sm text-gray-600"
                                >
                                  <Briefcase className="w-4 h-4 text-bordeaux-400 mt-0.5 flex-shrink-0" />
                                  <span>{exp}</span>
                                </motion.div>
                              ))}
                            </div>
                          </div>

                          {/* Social Links */}
                          {candidate.socialLinks && Object.values(candidate.socialLinks).some(link => link) && (
                            <div>
                              <div className="flex items-center space-x-2 mb-2 sm:mb-3">
                                <Globe className="w-3 h-3 sm:w-4 sm:h-4 text-bordeaux-600" />
                                <h4 className="text-sm sm:text-base font-semibold text-gray-900">Réseaux sociaux</h4>
                              </div>
                              <div className="flex flex-wrap gap-2 sm:gap-3">
                                {candidate.socialLinks.linkedin && (
                                  <a
                                    href={candidate.socialLinks.linkedin}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="flex items-center space-x-2 px-3 py-2 bg-blue-50 text-blue-700 rounded-lg hover:bg-blue-100 transition-colors text-sm font-medium"
                                  >
                                    <Linkedin className="w-4 h-4" />
                                    <span>LinkedIn</span>
                                    <ExternalLink className="w-3 h-3" />
                                  </a>
                                )}
                                {candidate.socialLinks.twitter && (
                                  <a
                                    href={candidate.socialLinks.twitter}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="flex items-center space-x-2 px-3 py-2 bg-sky-50 text-sky-700 rounded-lg hover:bg-sky-100 transition-colors text-sm font-medium"
                                  >
                                    <Twitter className="w-4 h-4" />
                                    <span>Twitter</span>
                                    <ExternalLink className="w-3 h-3" />
                                  </a>
                                )}
                                {candidate.socialLinks.instagram && (
                                  <a
                                    href={candidate.socialLinks.instagram}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="flex items-center space-x-2 px-3 py-2 bg-pink-50 text-pink-700 rounded-lg hover:bg-pink-100 transition-colors text-sm font-medium"
                                  >
                                    <Instagram className="w-4 h-4" />
                                    <span>Instagram</span>
                                    <ExternalLink className="w-3 h-3" />
                                  </a>
                                )}
                                {candidate.socialLinks.facebook && (
                                  <a
                                    href={candidate.socialLinks.facebook}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="flex items-center space-x-2 px-3 py-2 bg-blue-50 text-blue-800 rounded-lg hover:bg-blue-100 transition-colors text-sm font-medium"
                                  >
                                    <Facebook className="w-4 h-4" />
                                    <span>Facebook</span>
                                    <ExternalLink className="w-3 h-3" />
                                  </a>
                                )}
                                {candidate.socialLinks.website && (
                                  <a
                                    href={candidate.socialLinks.website}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="flex items-center space-x-2 px-3 py-2 bg-gray-50 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors text-sm font-medium"
                                  >
                                    <Globe className="w-4 h-4" />
                                    <span>Site web</span>
                                    <ExternalLink className="w-3 h-3" />
                                  </a>
                                )}
                              </div>
                            </div>
                          )}
                        </div>
                      </div>

                      {/* Selection indicator */}
                      {selectedCandidate === candidate.id && (
                        <motion.div
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          className="mt-6 pt-6 border-t border-bordeaux-200 flex items-center justify-center space-x-2 text-bordeaux-700 font-semibold"
                        >
                          <CheckCircle className="w-5 h-5" />
                          <span>Votre sélection</span>
                        </motion.div>
                      )}
                    </div>
                  </motion.div>
                ))}
              </div>
              )}

              {/* Bouton de vote - seulement si authentifié */}
              {isAuthenticated && (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.3 }}
                  className="sticky bottom-4 sm:bottom-6 z-10 mt-8"
                >
                  {isElectionEnded() ? (
                    <div className="bg-red-50 border-2 border-red-500 rounded-2xl p-6 text-center">
                      <AlertCircle className="w-12 h-12 text-red-600 mx-auto mb-3" />
                      <h3 className="text-xl font-bold text-red-900 mb-2">Les votes sont terminés</h3>
                      <p className="text-red-700 mb-4">L&apos;élection est fermée. Vous ne pouvez plus voter.</p>
                      <Link href="/results">
                        <motion.button
                          whileHover={{ scale: 1.05 }}
                          whileTap={{ scale: 0.95 }}
                          className="px-6 py-3 bg-red-600 text-white font-semibold rounded-xl hover:bg-red-700 transition-colors flex items-center space-x-2 mx-auto"
                        >
                          <Trophy className="w-5 h-5" />
                          <span>Voir les résultats</span>
                        </motion.button>
                      </Link>
                    </div>
                  ) : (
                    <motion.button
                      onClick={handleVote}
                      disabled={!selectedCandidate || isElectionEnded()}
                      whileHover={selectedCandidate && !isElectionEnded() ? { scale: 1.02, y: -2 } : {}}
                      whileTap={selectedCandidate && !isElectionEnded() ? { scale: 0.98 } : {}}
                      className={`w-full py-4 sm:py-5 text-base sm:text-lg font-bold rounded-2xl transition-all duration-300 flex items-center justify-center space-x-2 sm:space-x-3 shadow-lg ${
                        selectedCandidate && !isElectionEnded()
                          ? 'gradient-bordeaux text-white shadow-bordeaux-lg hover:shadow-bordeaux-lg'
                          : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                      }`}
                    >
                      <Vote className="w-5 h-5 sm:w-6 sm:h-6" />
                      <span className="text-sm sm:text-base">{selectedCandidate ? 'Confirmer mon vote' : 'Sélectionnez un candidat pour voter'}</span>
                      {selectedCandidate && <CheckCircle className="w-5 h-5 sm:w-6 sm:h-6" />}
                    </motion.button>
                  )}
                </motion.div>
              )}

        {/* Confirmation */}
        <AnimatePresence>
          {step === 'confirm' && (
            <>
              {/* Overlay */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50"
              />
              
              {/* Modal de succès */}
              <motion.div
                key="confirm"
                initial={{ opacity: 0, scale: 0.8, y: 50 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.8, y: 50 }}
                className="fixed inset-0 z-50 flex items-center justify-center p-4"
              >
                <motion.div
                  className="bg-white rounded-3xl shadow-2xl p-8 sm:p-10 md:p-12 text-center max-w-md w-full relative"
                >
                  {/* Animation de succès */}
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ 
                      type: "spring", 
                      stiffness: 200, 
                      damping: 15,
                      delay: 0.2
                    }}
                    className="relative mb-6 sm:mb-8"
                  >
                    {/* Cercle de fond animé */}
                    <motion.div
                      initial={{ scale: 0, opacity: 0 }}
                      animate={{ scale: 1.2, opacity: 0.3 }}
                      transition={{ duration: 0.6 }}
                      className="absolute inset-0 gradient-bordeaux rounded-full"
                    />
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ 
                        type: "spring", 
                        stiffness: 200, 
                        damping: 15,
                        delay: 0.3
                      }}
                      className="relative w-24 h-24 sm:w-28 sm:h-28 gradient-bordeaux rounded-full flex items-center justify-center mx-auto shadow-bordeaux-lg"
                    >
                      <motion.div
                        initial={{ scale: 0, rotate: -180 }}
                        animate={{ scale: 1, rotate: 0 }}
                        transition={{ 
                          type: "spring", 
                          stiffness: 200, 
                          damping: 15,
                          delay: 0.4
                        }}
                      >
                        <CheckCircle className="w-12 h-12 sm:w-14 sm:h-14 text-white" strokeWidth={3} />
                      </motion.div>
                    </motion.div>
                    
                    {/* Particules de confetti */}
                    {[...Array(6)].map((_, i) => (
                      <motion.div
                        key={i}
                        initial={{ 
                          scale: 0, 
                          x: 0, 
                          y: 0,
                          opacity: 0
                        }}
                        animate={{ 
                          scale: [0, 1, 0],
                          x: Math.cos(i * 60 * Math.PI / 180) * 60,
                          y: Math.sin(i * 60 * Math.PI / 180) * 60,
                          opacity: [0, 1, 0]
                        }}
                        transition={{ 
                          duration: 1.5,
                          delay: 0.5 + i * 0.1,
                          repeat: 0
                        }}
                        className="absolute top-1/2 left-1/2 w-2 h-2 bg-bordeaux-500 rounded-full"
                      />
                    ))}
                  </motion.div>

                  <motion.h2
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.6 }}
                    className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4 sm:mb-5"
                  >
                    🎉 Vote enregistré !
                  </motion.h2>
                  
                  <motion.p
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.7 }}
                    className="text-gray-600 text-base sm:text-lg mb-2 sm:mb-3 px-2"
                  >
                    Merci d&apos;avoir participé aux élections.
                  </motion.p>
                  
                  <motion.p
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.8 }}
                    className="text-bordeaux-600 text-sm sm:text-base font-semibold mb-6 sm:mb-8 px-2"
                  >
                    Votre vote a été enregistré avec succès.
                  </motion.p>

                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.9 }}
                    className="flex flex-col gap-3 sm:gap-4"
                  >
                    <motion.button
                      onClick={handleGoToResults}
                      whileHover={{ scale: 1.05, y: -2 }}
                      whileTap={{ scale: 0.95 }}
                      className="px-8 py-4 sm:px-10 sm:py-5 gradient-bordeaux text-white text-base sm:text-lg font-semibold rounded-2xl shadow-bordeaux-lg hover:shadow-bordeaux-lg transition-all duration-300 flex items-center justify-center space-x-3 mx-auto"
                    >
                      <Trophy className="w-5 h-5 sm:w-6 sm:h-6" />
                      <span>Voir les statistiques</span>
                      <ArrowRight className="w-5 h-5 sm:w-6 sm:h-6" />
                    </motion.button>
                    
                    <motion.p
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: 1.2 }}
                      className="text-xs sm:text-sm text-gray-500"
                    >
                      Redirection automatique dans quelques secondes...
                    </motion.p>
                  </motion.div>
                </motion.div>
              </motion.div>
            </>
          )}
        </AnimatePresence>

        {/* Modal d'authentification */}
        <AnimatePresence>
          {showAuthModal && (
            <>
              {/* Overlay */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setShowAuthModal(false)}
                className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50"
              />
              
              {/* Modal */}
              <motion.div
                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.9, y: 20 }}
                className="fixed inset-0 z-50 flex items-center justify-center p-4"
              >
                <div className="bg-white rounded-2xl shadow-xl p-6 sm:p-8 md:p-12 max-w-md w-full relative">
                  {/* Bouton fermer */}
                  <button
                    onClick={() => setShowAuthModal(false)}
                    className="absolute top-4 right-4 p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>

                  <div className="text-center mb-6 sm:mb-8">
                    <div className="w-16 h-16 sm:w-20 sm:h-20 gradient-bordeaux rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6 shadow-bordeaux-lg">
                      <Lock className="w-8 h-8 sm:w-10 sm:h-10 text-white" />
                    </div>
                    <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2 sm:mb-3">Authentification</h2>
                    <p className="text-sm sm:text-base text-gray-600 px-2">Entrez votre code de vote unique pour voter</p>
                  </div>

                  {error && (
                    <motion.div
                      initial={{ opacity: 0, y: -10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="bg-red-50 border-2 border-red-500 rounded-xl p-4 mb-6 flex items-start space-x-3"
                    >
                      <XCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
                      <p className="text-red-800 text-sm">{error}</p>
                    </motion.div>
                  )}

                  <form onSubmit={handleAuth} className="space-y-6">
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">
                        <Key className="w-4 h-4 inline mr-2" />
                        Code de vote
                      </label>
                      <div className="flex gap-2">
                        <input
                          type="text"
                          value={voteCode}
                          onChange={(e) => {
                            setVoteCode(e.target.value.toUpperCase())
                            setError('')
                          }}
                          disabled={isElectionEnded()}
                          className={`flex-1 px-4 py-3 border-2 rounded-xl focus:ring-2 transition-all outline-none font-mono text-center text-lg tracking-widest ${
                            isElectionEnded()
                              ? 'border-gray-300 bg-gray-100 text-gray-500 cursor-not-allowed'
                              : 'border-gray-200 focus:border-bordeaux-500 focus:ring-bordeaux-200'
                          }`}
                          placeholder="XXXX-XXXX"
                          maxLength={8}
                          required
                          autoComplete="off"
                          autoFocus={!isElectionEnded()}
                        />
                        <motion.button
                          type="button"
                          onClick={() => {
                            if (isElectionEnded()) {
                              setError('Les votes sont terminés. L\'élection est fermée.')
                              return
                            }
                            setShowAuthModal(false)
                            setShowQRScanner(true)
                          }}
                          disabled={isElectionEnded()}
                          whileHover={!isElectionEnded() ? { scale: 1.05 } : {}}
                          whileTap={!isElectionEnded() ? { scale: 0.95 } : {}}
                          className={`px-4 py-3 rounded-xl transition-colors flex items-center justify-center ${
                            isElectionEnded()
                              ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                              : 'bg-bordeaux-600 text-white hover:bg-bordeaux-700'
                          }`}
                          title={isElectionEnded() ? 'Les votes sont terminés' : 'Scanner un QR code'}
                        >
                          <QrCode className="w-5 h-5" />
                        </motion.button>
                      </div>
                      <p className="text-xs text-gray-500 mt-2 text-center">
                        Entrez le code à 8 caractères ou scannez le QR code
                      </p>
                    </div>

                    <div className="flex gap-3">
                      <motion.button
                        type="button"
                        onClick={() => setShowAuthModal(false)}
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        className="flex-1 py-3 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition-all duration-300"
                      >
                        Annuler
                      </motion.button>
                      <motion.button
                        type="submit"
                        disabled={isElectionEnded()}
                        whileHover={!isElectionEnded() ? { scale: 1.02 } : {}}
                        whileTap={!isElectionEnded() ? { scale: 0.98 } : {}}
                        className={`flex-1 py-3 font-semibold rounded-xl transition-all duration-300 flex items-center justify-center space-x-2 ${
                          isElectionEnded()
                            ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                            : 'gradient-bordeaux text-white shadow-bordeaux-lg hover:shadow-bordeaux-lg'
                        }`}
                      >
                        <Key className="w-5 h-5" />
                        <span>{isElectionEnded() ? 'Élection terminée' : 'Vérifier'}</span>
                      </motion.button>
                    </div>
                  </form>
                </div>
              </motion.div>
            </>
          )}
        </AnimatePresence>

        {/* Scanner QR Code */}
        {showQRScanner && (
          <QRCodeScanner
            onScanSuccess={handleQRScan}
            onClose={() => setShowQRScanner(false)}
          />
        )}
      </div>
    </div>
  )
}

