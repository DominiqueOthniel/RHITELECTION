'use client'

import { motion } from 'framer-motion'
import { Shield, Users, CheckCircle, Vote, ArrowRight, Lock, Eye, Zap, Clock, QrCode, Trophy, UserCircle, TrendingUp } from 'lucide-react'
import Link from 'next/link'
import Image from 'next/image'
import { useElectionStore } from '@/lib/electionStore'
import { useVoterStore } from '@/lib/store'
import { useVoteStore } from '@/lib/voteStore'
import { useCandidateStore } from '@/lib/candidateStore'
import { useEffect, useState } from 'react'
import QRCodeDisplay from '@/components/QRCodeDisplay'

export default function Home() {
  const { getTimeRemaining, isElectionEnded, isElectionStarted, syncFromSupabase: syncElectionFromSupabase } = useElectionStore()
  const { getVoterStats, syncFromSupabase: syncVotersFromSupabase } = useVoterStore()
  const { getTotalVotes, syncFromSupabase: syncVotesFromSupabase } = useVoteStore()
  const { initializeDefaultCandidates } = useCandidateStore()
  const [timeRemaining, setTimeRemaining] = useState<{ days: number; hours: number; minutes: number; seconds: number; total: number } | null>(null)
  const [electionEnded, setElectionEnded] = useState(false)
  const [electionStarted, setElectionStarted] = useState(false)
  const [mounted, setMounted] = useState(false)

  const stats = getVoterStats()
  const totalVotes = getTotalVotes()
  const participationRate = stats.total > 0 ? Math.round((stats.voted / stats.total) * 100) : 0

  // Synchroniser toutes les données depuis Supabase au chargement
  useEffect(() => {
    const syncAllData = async () => {
      try {
        // Synchroniser toutes les données en parallèle pour plus de rapidité
        await Promise.all([
          syncElectionFromSupabase(), // Synchroniser la date de fin d'élection
          initializeDefaultCandidates(), // Synchroniser les candidats
          syncVotersFromSupabase(), // Synchroniser les votants
          syncVotesFromSupabase(), // Synchroniser les votes
        ])
        setMounted(true)
      } catch (error) {
        console.error('Erreur lors de la synchronisation:', error)
        setMounted(true) // Afficher quand même la page même en cas d'erreur
      }
    }
    syncAllData()
  }, [syncElectionFromSupabase, initializeDefaultCandidates, syncVotersFromSupabase, syncVotesFromSupabase])

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

  // Mise à jour du compte à rebours chaque seconde
  useEffect(() => {
    const updateCountdown = () => {
      const remaining = getTimeRemaining()
      setTimeRemaining(remaining)
      setElectionEnded(isElectionEnded())
      setElectionStarted(isElectionStarted())
    }

    updateCountdown()
    const interval = setInterval(updateCountdown, 1000)

    return () => clearInterval(interval)
  }, [getTimeRemaining, isElectionEnded, isElectionStarted])

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-gray-50 to-white">
      {/* Header */}
      <header className="glass-effect sticky top-0 z-50 border-b border-bordeaux-200/20">
        <div className="container mx-auto px-4 sm:px-6 py-3 sm:py-4 flex items-center justify-between">
          <div className="flex items-center space-x-2 sm:space-x-3">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: "spring", stiffness: 200, damping: 15 }}
              className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl flex items-center justify-center shadow-bordeaux overflow-hidden"
            >
              <Image 
                src="/logo.webp" 
                alt="RHIT Logo" 
                width={48} 
                height={48} 
                className="object-contain"
              />
            </motion.div>
            <div>
              <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900">RHIT Élections</h1>
              <p className="text-xs sm:text-sm text-gray-600 hidden sm:block">Bureau des Étudiants</p>
            </div>
          </div>
          <div className="flex items-center space-x-2 sm:space-x-3">
            <Link href="/vote">
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="px-4 py-2 sm:px-6 sm:py-2.5 gradient-bordeaux text-white text-sm sm:text-base font-semibold rounded-xl shadow-bordeaux hover:shadow-bordeaux-lg transition-all duration-300 flex items-center space-x-2"
              >
                <span className="hidden sm:inline">Voir candidats</span>
                <span className="sm:hidden">Candidats</span>
                <ArrowRight className="w-4 h-4" />
              </motion.button>
            </Link>
          </div>
        </div>
      </header>

      {/* Compte à rebours */}
      {timeRemaining && timeRemaining.total > 0 && (
        <section className="container mx-auto px-4 sm:px-6 py-6 sm:py-8">
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-gradient-to-r from-bordeaux-600 to-bordeaux-700 rounded-2xl p-4 sm:p-6 text-white shadow-bordeaux-lg max-w-4xl mx-auto"
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
        </section>
      )}

      {/* Hero Section */}
      <section className="container mx-auto px-4 sm:px-6 py-12 sm:py-16 md:py-20">
        <div className="max-w-4xl mx-auto text-center">
          <motion.div
            initial={{ scale: 0, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ type: "spring", stiffness: 200, damping: 15, delay: 0.2 }}
            className="w-24 h-24 sm:w-32 sm:h-32 rounded-full flex items-center justify-center mx-auto mb-6 sm:mb-8 shadow-bordeaux-lg overflow-hidden bg-white p-3 sm:p-4"
          >
            <Image 
              src="/logo.webp" 
              alt="RHIT Logo" 
              width={128} 
              height={128} 
              className="object-contain"
            />
          </motion.div>

          <motion.h1
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-4 sm:mb-6 leading-tight px-2"
          >
            Votez pour le{' '}
            <span className="text-bordeaux-600">
              futur de RHIT
            </span>
          </motion.h1>

          <motion.p
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.4 }}
            className="text-base sm:text-lg md:text-xl text-gray-600 mb-8 sm:mb-10 max-w-2xl mx-auto leading-relaxed px-4"
          >
            Participez aux élections du bureau des étudiants. Votre voix compte pour façonner l&apos;avenir de notre université.
          </motion.p>

          <motion.div
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="flex flex-col items-center justify-center gap-4"
          >
            <Link href="/vote">
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                className="group relative px-6 py-4 sm:px-8 sm:py-4 md:px-10 md:py-5 gradient-bordeaux text-white text-base sm:text-lg font-semibold rounded-2xl shadow-bordeaux-lg hover:shadow-bordeaux-lg transition-all duration-300 flex items-center space-x-2 sm:space-x-3 overflow-hidden"
              >
                {/* Effet de brillance animé */}
                <motion.div
                  className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
                  initial={{ x: '-100%' }}
                  animate={{ x: '200%' }}
                  transition={{
                    repeat: Infinity,
                    duration: 3,
                    ease: 'linear'
                  }}
                />
                {/* Icône avec animation */}
                <motion.div
                  animate={{ 
                    rotate: [0, -5, 5, -5, 0],
                  }}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    repeatDelay: 3,
                    ease: "easeInOut"
                  }}
                >
                  <UserCircle className="w-6 h-6" />
                </motion.div>
                <span>Voir les candidats</span>
                <motion.div
                  animate={{ x: [0, 5, 0] }}
                  transition={{
                    duration: 1.5,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  <ArrowRight className="w-5 h-5" />
                </motion.div>
              </motion.button>
            </Link>
            
            {/* Bouton "Voir les résultats" - seulement si l'élection est terminée */}
            {electionEnded && (
              <Link href="/results">
                <motion.button
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  className="px-6 py-4 sm:px-8 sm:py-4 md:px-10 md:py-5 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white text-base sm:text-lg font-semibold rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 flex items-center space-x-2 sm:space-x-3"
                >
                  <Trophy className="w-5 h-5 sm:w-6 sm:h-6" />
                  <span>Voir les résultats</span>
                  <ArrowRight className="w-5 h-5" />
                </motion.button>
              </Link>
            )}
          </motion.div>

          {/* QR Code pour accès rapide - seulement quand les votes sont lancés */}
          {electionStarted && !electionEnded && (
            <motion.div
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ delay: 0.6 }}
              className="mt-8 sm:mt-10"
            >
              <div className="flex flex-col items-center space-y-3">
                <div className="flex items-center space-x-2 text-gray-600">
                  <QrCode className="w-4 h-4" />
                  <p className="text-sm font-medium">Scannez pour voter</p>
                </div>
                <div className="bg-white p-4 rounded-xl shadow-lg">
                  <QRCodeDisplay
                    value={`${typeof window !== 'undefined' ? window.location.origin : ''}/vote?auth=true`}
                    size={150}
                    showDownload={false}
                  />
                </div>
                <p className="text-xs text-gray-500 text-center max-w-xs">
                  Ce QR code vous mène directement à l&apos;authentification pour voter
                </p>
              </div>
            </motion.div>
          )}
        </div>
      </section>

      {/* Statistiques Section */}
      {mounted && (
        <section className="container mx-auto px-4 sm:px-6 py-8 sm:py-12">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="max-w-5xl mx-auto"
          >
            <h3 className="text-2xl sm:text-3xl font-bold text-gray-900 text-center mb-6 sm:mb-8">
              Statistiques de l&apos;élection
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
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
                <p className="text-gray-600 text-xs sm:text-sm mb-1">Total votants</p>
                <p className="text-2xl sm:text-3xl font-bold text-gray-900">{stats.total}</p>
              </motion.div>

              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="bg-white rounded-xl p-4 sm:p-6 shadow-lg border border-gray-100"
              >
                <div className="flex items-center justify-between mb-3 sm:mb-4">
                  <div className="w-10 h-10 sm:w-12 sm:h-12 bg-green-500 rounded-lg flex items-center justify-center">
                    <CheckCircle className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                  </div>
                </div>
                <p className="text-gray-600 text-xs sm:text-sm mb-1">Ont voté</p>
                <p className="text-2xl sm:text-3xl font-bold text-green-600">{stats.voted}</p>
              </motion.div>

              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="bg-white rounded-xl p-4 sm:p-6 shadow-lg border border-gray-100"
              >
                <div className="flex items-center justify-between mb-3 sm:mb-4">
                  <div className="w-10 h-10 sm:w-12 sm:h-12 bg-orange-500 rounded-lg flex items-center justify-center">
                    <Clock className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                  </div>
                </div>
                <p className="text-gray-600 text-xs sm:text-sm mb-1">En attente</p>
                <p className="text-2xl sm:text-3xl font-bold text-orange-600">{stats.pending}</p>
              </motion.div>

              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
                className="bg-white rounded-xl p-4 sm:p-6 shadow-lg border border-gray-100"
              >
                <div className="flex items-center justify-between mb-3 sm:mb-4">
                  <div className="w-10 h-10 sm:w-12 sm:h-12 bg-blue-500 rounded-lg flex items-center justify-center">
                    <TrendingUp className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                  </div>
                </div>
                <p className="text-gray-600 text-xs sm:text-sm mb-1">Taux participation</p>
                <p className="text-2xl sm:text-3xl font-bold text-blue-600">{participationRate}%</p>
              </motion.div>
            </div>
          </motion.div>
        </section>
      )}

      {/* Features Section */}
      <section className="bg-gradient-to-b from-gray-50 to-white py-12 sm:py-16 md:py-20">
        <div className="container mx-auto px-4 sm:px-6">
          <motion.div
            initial={{ y: 20, opacity: 0 }}
            whileInView={{ y: 0, opacity: 1 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="grid sm:grid-cols-2 md:grid-cols-3 gap-6 sm:gap-8 max-w-6xl mx-auto"
          >
            {/* Sécurisé Card */}
            <motion.div
              whileHover={{ y: -10, scale: 1.02 }}
              transition={{ type: "spring", stiffness: 300 }}
              className="bg-white rounded-2xl p-6 sm:p-8 shadow-lg hover:shadow-bordeaux-lg transition-all duration-300 border border-gray-100"
            >
              <div className="w-14 h-14 sm:w-16 sm:h-16 gradient-bordeaux rounded-xl flex items-center justify-center mb-4 sm:mb-6 shadow-bordeaux">
                <Shield className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
              </div>
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-3 sm:mb-4">Sécurisé</h3>
              <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                Vote anonyme et sécurisé avec authentification étudiante. Vos données sont protégées par un cryptage de niveau bancaire.
              </p>
            </motion.div>

            {/* Transparent Card */}
            <motion.div
              whileHover={{ y: -10, scale: 1.02 }}
              transition={{ type: "spring", stiffness: 300 }}
              className="bg-white rounded-2xl p-6 sm:p-8 shadow-lg hover:shadow-bordeaux-lg transition-all duration-300 border border-gray-100"
            >
              <div className="w-14 h-14 sm:w-16 sm:h-16 gradient-bordeaux rounded-xl flex items-center justify-center mb-4 sm:mb-6 shadow-bordeaux">
                <Eye className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
              </div>
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-3 sm:mb-4">Transparent</h3>
              <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                Processus électoral transparent avec résultats en temps réel. Chaque vote est vérifiable et traçable.
              </p>
            </motion.div>

            {/* Simple Card */}
            <motion.div
              whileHover={{ y: -10, scale: 1.02 }}
              transition={{ type: "spring", stiffness: 300 }}
              className="bg-white rounded-2xl p-6 sm:p-8 shadow-lg hover:shadow-bordeaux-lg transition-all duration-300 border border-gray-100 sm:col-span-2 md:col-span-1"
            >
              <div className="w-14 h-14 sm:w-16 sm:h-16 gradient-bordeaux rounded-xl flex items-center justify-center mb-4 sm:mb-6 shadow-bordeaux">
                <Zap className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
              </div>
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-3 sm:mb-4">Simple</h3>
              <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                Interface intuitive pour voter en quelques clics. Conçu pour être accessible à tous les étudiants.
              </p>
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gradient-to-r from-bordeaux-900 to-bordeaux-800 text-white py-8 sm:py-12 mt-12 sm:mt-16 md:mt-20">
        <div className="container mx-auto px-4 sm:px-6 text-center">
          <div className="flex items-center justify-center space-x-2 sm:space-x-3 mb-3 sm:mb-4">
            <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl flex items-center justify-center shadow-bordeaux overflow-hidden bg-white/10 p-1">
              <Image 
                src="/rhit.png" 
                alt="RHIT Logo" 
                width={48} 
                height={48} 
                className="object-contain"
              />
            </div>
            <h3 className="text-lg sm:text-xl font-bold">RHIT Élections</h3>
          </div>
          <p className="text-sm sm:text-base text-bordeaux-200">© 2024 Bureau des Étudiants - Tous droits réservés</p>
        </div>
      </footer>
    </div>
  )
}

