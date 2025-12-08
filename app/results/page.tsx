'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Vote, TrendingUp, Users, ArrowLeft, BarChart3, Clock, AlertCircle, Trophy, Crown, Award } from 'lucide-react'
import Link from 'next/link'
import Image from 'next/image'
import { useCandidateStore } from '@/lib/candidateStore'
import { useVoteStore } from '@/lib/voteStore'
import { useVoterStore } from '@/lib/store'
import { useElectionStore } from '@/lib/electionStore'

interface Result {
  id: string
  name: string
  position: string
  votes: number
  percentage: number
  image?: string
  initials: string
}

export default function ResultsPage() {
  const { candidates, initializeDefaultCandidates } = useCandidateStore()
  const { getVotesByCandidate, getTotalVotes } = useVoteStore()
  const { getVoterStats, syncFromSupabase: syncVotersFromSupabase } = useVoterStore()
  const { getTimeRemaining } = useElectionStore()
  const [mounted, setMounted] = useState(false)
  const [results, setResults] = useState<Result[]>([])
  const [timeRemaining, setTimeRemaining] = useState<{ days: number; hours: number; minutes: number; seconds: number; total: number } | null>(null)

  useEffect(() => {
    const init = async () => {
      setMounted(true)
      // Synchroniser toutes les données depuis Supabase au démarrage
      await initializeDefaultCandidates() // Charge les candidats depuis Supabase
      await syncVotersFromSupabase() // Charge les votants depuis Supabase
    }
    init()
  }, [initializeDefaultCandidates, syncVotersFromSupabase])

  useEffect(() => {
    const updateCountdown = () => {
      const remaining = getTimeRemaining()
      setTimeRemaining(remaining)
    }

    updateCountdown()
    const interval = setInterval(updateCountdown, 1000)

    return () => clearInterval(interval)
  }, [getTimeRemaining])

  useEffect(() => {
    if (mounted && candidates.length > 0) {
      const totalVotes = getTotalVotes()
      const resultsData: Result[] = candidates
        .map((candidate) => {
          const votes = getVotesByCandidate(candidate.id)
          const percentage = totalVotes > 0 ? Math.round((votes / totalVotes) * 100) : 0
          return {
            id: candidate.id,
            name: candidate.name,
            position: candidate.position,
            votes,
            percentage,
            image: candidate.image,
            initials: candidate.initials,
          }
        })
        .sort((a, b) => b.votes - a.votes) // Trier par nombre de votes décroissant

      setResults(resultsData)
    }
  }, [mounted, candidates, getVotesByCandidate, getTotalVotes])

  const totalVotes = getTotalVotes()
  const stats = getVoterStats()
  const participationRate = stats.total > 0 ? Math.round((stats.voted / stats.total) * 100) : 0

  if (!mounted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-white via-gray-50 to-white flex items-center justify-center">
        <p className="text-gray-500 text-lg">Chargement des résultats...</p>
      </div>
    )
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

      <div className="container mx-auto px-4 sm:px-6 py-8 sm:py-12 max-w-5xl">
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
                  <div className="text-xs sm:text-sm opacity-75">H</div>
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
            <p className="text-sm sm:text-base opacity-90 mt-1">Consultez les résultats ci-dessous</p>
          </motion.div>
        )}

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8 sm:mb-12"
        >
          <div className="w-16 h-16 sm:w-20 sm:h-20 gradient-bordeaux rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6 shadow-bordeaux-lg">
            <BarChart3 className="w-8 h-8 sm:w-10 sm:h-10 text-white" />
          </div>
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-2 sm:mb-3 px-2">
            Résultats en{' '}
            <span className="text-bordeaux-600">
              temps réel
            </span>
          </h2>
          <p className="text-gray-600 text-base sm:text-lg px-2">Élection du Bureau des Étudiants</p>
        </motion.div>

        {/* Grand Gagnant - Section Proéminente */}
        {results.length > 0 && results[0].votes > 0 && (
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            transition={{ delay: 0.2, type: "spring", stiffness: 100 }}
            className="mb-8 sm:mb-12"
          >
            <div className="bg-gradient-to-br from-yellow-400 via-yellow-500 to-yellow-600 rounded-3xl p-6 sm:p-8 md:p-10 shadow-2xl relative overflow-hidden">
              {/* Effet de brillance */}
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent transform -skew-x-12 animate-shimmer"></div>
              
              <div className="relative z-10">
                <div className="flex flex-col items-center text-center mb-6">
                  <motion.div
                    initial={{ scale: 0, rotate: -180 }}
                    animate={{ scale: 1, rotate: 0 }}
                    transition={{ delay: 0.4, type: "spring", stiffness: 200 }}
                    className="w-20 h-20 sm:w-24 sm:h-24 bg-white/30 rounded-full flex items-center justify-center mb-4 shadow-lg"
                  >
                    <Crown className="w-10 h-10 sm:w-12 sm:h-12 text-white" />
                  </motion.div>
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.5 }}
                    className="inline-flex items-center space-x-2 bg-white/20 backdrop-blur-sm px-4 py-2 rounded-full mb-3"
                  >
                    <Trophy className="w-5 h-5 text-white" />
                    <span className="text-white font-bold text-sm sm:text-base">GRAND GAGNANT</span>
                  </motion.div>
                  <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-2">
                    {results[0].name}
                  </h1>
                  <p className="text-white/90 text-lg sm:text-xl mb-4">{results[0].position}</p>
                </div>

                <div className="flex flex-col sm:flex-row items-center justify-center gap-6 sm:gap-8">
                  {/* Photo du gagnant */}
                  <div className="flex-shrink-0">
                    {results[0].image ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={results[0].image}
                        alt={results[0].name}
                        className="w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48 rounded-2xl object-cover border-4 border-white shadow-2xl"
                        onError={(e) => {
                          const target = e.target as HTMLImageElement
                          target.style.display = 'none'
                          const parent = target.parentElement
                          if (parent && !parent.querySelector('.fallback-initials')) {
                            const fallback = document.createElement('div')
                            fallback.className = 'w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48 bg-white/30 rounded-2xl flex items-center justify-center border-4 border-white shadow-2xl fallback-initials'
                            fallback.innerHTML = `<span class="text-5xl sm:text-6xl md:text-7xl font-bold text-white">${results[0].initials}</span>`
                            parent.appendChild(fallback)
                          }
                        }}
                      />
                    ) : (
                      <div className="w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48 bg-white/30 rounded-2xl flex items-center justify-center border-4 border-white shadow-2xl">
                        <span className="text-5xl sm:text-6xl md:text-7xl font-bold text-white">{results[0].initials}</span>
                      </div>
                    )}
                  </div>

                  {/* Statistiques du gagnant */}
                  <div className="flex-1 text-center sm:text-left">
                    <div className="bg-white/20 backdrop-blur-sm rounded-2xl p-6 space-y-4">
                      <div>
                        <p className="text-white/80 text-sm sm:text-base mb-1">Nombre de votes</p>
                        <p className="text-4xl sm:text-5xl md:text-6xl font-bold text-white">{results[0].votes}</p>
                      </div>
                      <div>
                        <p className="text-white/80 text-sm sm:text-base mb-1">Pourcentage</p>
                        <p className="text-3xl sm:text-4xl md:text-5xl font-bold text-white">{results[0].percentage}%</p>
                      </div>
                      {totalVotes > 0 && (
                        <div className="pt-4 border-t border-white/30">
                          <div className="relative h-6 bg-white/30 rounded-full overflow-hidden">
                            <motion.div
                              initial={{ width: 0 }}
                              animate={{ width: `${results[0].percentage}%` }}
                              transition={{ duration: 1.5, delay: 0.6 }}
                              className="absolute top-0 left-0 h-full bg-white rounded-full"
                            />
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {/* Stats Cards */}
        <div className="grid sm:grid-cols-2 md:grid-cols-3 gap-4 sm:gap-6 mb-8 sm:mb-12">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white rounded-xl p-4 sm:p-6 shadow-lg border border-gray-100"
          >
            <div className="flex items-center justify-between mb-3 sm:mb-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 gradient-bordeaux rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
              </div>
            </div>
            <p className="text-gray-600 text-xs sm:text-sm mb-1">Total des votes</p>
            <p className="text-2xl sm:text-3xl font-bold text-gray-900">{totalVotes}</p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-white rounded-xl p-4 sm:p-6 shadow-lg border border-gray-100"
          >
            <div className="flex items-center justify-between mb-3 sm:mb-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 gradient-bordeaux rounded-lg flex items-center justify-center">
                <TrendingUp className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
              </div>
            </div>
            <p className="text-gray-600 text-xs sm:text-sm mb-1">Participation</p>
            <p className="text-2xl sm:text-3xl font-bold text-gray-900">{participationRate}%</p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white rounded-xl p-4 sm:p-6 shadow-lg border border-gray-100 sm:col-span-2 md:col-span-1"
          >
            <div className="flex items-center justify-between mb-3 sm:mb-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 gradient-bordeaux rounded-lg flex items-center justify-center">
                <Vote className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
              </div>
            </div>
            <p className="text-gray-600 text-xs sm:text-sm mb-1">Candidats</p>
            <p className="text-2xl sm:text-3xl font-bold text-gray-900">{candidates.length}</p>
          </motion.div>
        </div>

        {/* Results List */}
        <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 md:p-8">
          <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-4 sm:mb-6">Résultats détaillés</h3>
          {results.length === 0 ? (
            <div className="text-center py-12">
              <Vote className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-600 text-lg">Aucun vote enregistré pour le moment</p>
            </div>
          ) : (
            <div className="space-y-6">
              {results.map((result, index) => (
                <motion.div
                  key={result.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.1 * index }}
                  className="border-b border-gray-100 last:border-0 pb-6 last:pb-0"
                >
                  <div className="flex items-center gap-3 sm:gap-4 mb-3">
                    {/* Photo/Avatar */}
                    <div className="flex-shrink-0">
                      {result.image ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={result.image}
                          alt={result.name}
                          className="w-12 h-12 sm:w-16 sm:h-16 rounded-xl object-cover"
                          onError={(e) => {
                            const target = e.target as HTMLImageElement
                            target.style.display = 'none'
                            const parent = target.parentElement
                            if (parent && !parent.querySelector('.fallback-initials')) {
                              const fallback = document.createElement('div')
                              fallback.className = 'w-12 h-12 sm:w-16 sm:h-16 gradient-bordeaux rounded-xl flex items-center justify-center fallback-initials'
                              fallback.innerHTML = `<span class="text-lg sm:text-xl font-bold text-white">${result.initials}</span>`
                              parent.appendChild(fallback)
                            }
                          }}
                        />
                      ) : (
                        <div className="w-12 h-12 sm:w-16 sm:h-16 gradient-bordeaux rounded-xl flex items-center justify-center">
                          <span className="text-lg sm:text-xl font-bold text-white">{result.initials}</span>
                        </div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between mb-2 flex-wrap gap-2">
                        <div className="flex-1 min-w-0">
                          <h4 className="text-lg sm:text-xl font-bold text-gray-900 truncate">{result.name}</h4>
                          <p className="text-sm sm:text-base text-bordeaux-600 font-semibold truncate">{result.position}</p>
                        </div>
                        <div className="text-right flex-shrink-0">
                          <p className="text-xl sm:text-2xl font-bold text-gray-900">{result.votes}</p>
                          <p className="text-xs sm:text-sm text-gray-600">votes</p>
                        </div>
                      </div>
                      <div className="relative h-4 bg-gray-100 rounded-full overflow-hidden">
                        <motion.div
                          initial={{ width: 0 }}
                          animate={{ width: `${result.percentage}%` }}
                          transition={{ duration: 1, delay: 0.2 * index }}
                          className="absolute top-0 left-0 h-full gradient-bordeaux rounded-full"
                        />
                      </div>
                      <p className="text-sm text-gray-600 mt-2">{result.percentage}% des votes</p>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>

      </div>
    </div>
  )
}

