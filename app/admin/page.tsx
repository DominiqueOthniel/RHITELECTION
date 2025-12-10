'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { motion, AnimatePresence } from 'framer-motion'
import { 
  UserPlus, 
  Users, 
  CheckCircle, 
  Clock, 
  Trash2, 
  Copy, 
  Check, 
  ArrowLeft,
  Download,
  Shield,
  UserCircle,
  Edit,
  Plus,
  X,
  Upload,
  Linkedin,
  Twitter,
  Instagram,
  Facebook,
  Globe,
  Image as ImageIcon,
  RotateCcw,
  QrCode,
  Trophy,
  Medal,
  Award,
  MessageCircle
} from 'lucide-react'
import Link from 'next/link'
import Image from 'next/image'
import { useVoterStore } from '@/lib/store'
import { useCandidateStore, type Candidate } from '@/lib/candidateStore'
import { useVoteStore } from '@/lib/voteStore'
import { useElectionStore } from '@/lib/electionStore'
import QRCodeDisplay from '@/components/QRCodeDisplay'

export default function AdminPage() {
  const router = useRouter()
  const { voters, addVoter, deleteVoter, getVoterStats, resetVoteStats, syncFromSupabase: syncVotersFromSupabase } = useVoterStore()
  const { candidates, addCandidate, updateCandidate, deleteCandidate, clearAllCandidates, initializeDefaultCandidates } = useCandidateStore()
  const { clearAllVotes, getVotesByCandidate, getTotalVotes, votes, syncFromSupabase: syncVotesFromSupabase } = useVoteStore()
  const { endDate, setEndDate, getTimeRemaining, syncFromSupabase: syncElectionFromSupabase } = useElectionStore()
  const [activeTab, setActiveTab] = useState<'voters' | 'candidates'>('voters')
  const [mounted, setMounted] = useState(false)
  const [electionEndDate, setElectionEndDate] = useState('')
  const [electionEndTime, setElectionEndTime] = useState('')
  const [ranking, setRanking] = useState<Array<{
    id: string
    name: string
    position: string
    votes: number
    percentage: number
    image?: string
    initials: string
  }>>([])
  
  // Voter states
  const [studentId, setStudentId] = useState('')
  const [name, setName] = useState('')
  const [copiedCode, setCopiedCode] = useState<string | null>(null)
  const [showAddForm, setShowAddForm] = useState(false)
  const [newVoterCode, setNewVoterCode] = useState<string | null>(null)
  const [showQRCode, setShowQRCode] = useState<string | null>(null)
  
  // Candidate states
  const [showCandidateForm, setShowCandidateForm] = useState(false)
  const [editingCandidate, setEditingCandidate] = useState<Candidate | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)
  const [candidateForm, setCandidateForm] = useState({
    name: '',
    position: '',
    description: '',
    bio: '',
    year: '',
    program: [''],
    experience: [''],
    image: '',
    imageFile: null as File | null,
    initials: '',
    socialLinks: {
      linkedin: '',
      twitter: '',
      instagram: '',
      facebook: '',
      website: '',
      tiktok: '',
      whatsapp: ''
    }
  })

  const stats = getVoterStats()

  const handleAddVoter = async (e: React.FormEvent) => {
    e.preventDefault()
    if (studentId && name) {
      // Vérifier si le numéro étudiant existe déjà
      if (voters.some(v => v.studentId === studentId)) {
        alert('Ce numéro étudiant est déjà enregistré!')
        return
      }
      
      const code = await addVoter(studentId, name)
      setNewVoterCode(code)
      setStudentId('')
      setName('')
      setShowAddForm(false)
      
      // Réinitialiser le code affiché après 5 secondes
      setTimeout(() => setNewVoterCode(null), 5000)
    }
  }

  const handleSendWhatsApp = (voter: { name: string; voteCode: string; whatsapp?: string }) => {
    if (!voter.whatsapp) {
      alert('Aucun numéro WhatsApp enregistré pour ce votant.')
      return
    }
    
    // Nettoyer le numéro (enlever espaces, tirets, etc.)
    const cleanNumber = voter.whatsapp.replace(/[^0-9+]/g, '')
    
    // Message à envoyer
    const message = encodeURIComponent(
      `Bonjour ${voter.name},\n\n` +
      `Votre code de vote pour l'élection du Bureau des Étudiants RHIT est :\n\n` +
      `🔑 ${voter.voteCode}\n\n` +
      `Vous pouvez voter en utilisant ce code sur : ${typeof window !== 'undefined' ? window.location.origin : ''}/vote\n\n` +
      `Merci de votre participation !`
    )
    
    // Ouvrir WhatsApp avec le message
    const whatsappUrl = `https://wa.me/${cleanNumber}?text=${message}`
    window.open(whatsappUrl, '_blank')
  }

  const handleCopyCode = (code: string) => {
    navigator.clipboard.writeText(code)
    setCopiedCode(code)
    setTimeout(() => setCopiedCode(null), 2000)
  }

  const handleExportCSV = () => {
    const headers = ['Nom', 'Numéro étudiant', 'Email', 'Code de vote', 'Statut']
    const rows = voters.map(v => [
      v.name,
      v.studentId,
      v.email,
      v.voteCode,
      v.hasVoted ? 'A voté' : 'En attente'
    ])
    
    const csv = [headers, ...rows].map(row => row.join(',')).join('\n')
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `votants_${new Date().toISOString().split('T')[0]}.csv`
    link.click()
  }

  const handleResetVoteStats = async () => {
    if (confirm('Êtes-vous sûr de vouloir réinitialiser toutes les statistiques de vote ?\n\nCette action va :\n- Supprimer tous les votes enregistrés\n- Réinitialiser le statut "a voté" de tous les votants\n- Réinitialiser la date de fin de l\'élection\n- Permettre de démarrer un nouveau cycle d\'élection\n\nCette action est irréversible.')) {
      clearAllVotes()
      await resetVoteStats()
      await setEndDate(null) // Réinitialiser la date de fin pour permettre un nouveau cycle
      setElectionEndDate('')
      setElectionEndTime('')
      alert('Les statistiques de vote ont été réinitialisées avec succès. Vous pouvez maintenant configurer une nouvelle date de fin pour le prochain cycle d\'élection.')
    }
  }

  const handleSetElectionEndDate = async () => {
    if (electionEndDate && electionEndTime) {
      const dateTime = new Date(`${electionEndDate}T${electionEndTime}`)
      if (dateTime > new Date()) {
        await setEndDate(dateTime.toISOString())
        alert('Date de fin des votes configurée avec succès !')
      } else {
        alert('La date de fin doit être dans le futur.')
      }
    } else {
      alert('Veuillez remplir la date et l\'heure.')
    }
  }

  const handleClearElectionEndDate = async () => {
    if (confirm('Voulez-vous supprimer la date de fin des votes ?')) {
      await setEndDate(null)
      setElectionEndDate('')
      setElectionEndTime('')
    }
  }

  const handleLogout = () => {
    if (confirm('Voulez-vous vous déconnecter ?')) {
      sessionStorage.removeItem('admin_logged_in')
      sessionStorage.removeItem('admin_username')
      router.push('/login')
    }
  }

  const timeRemaining = getTimeRemaining()

  // Vérifier l'authentification et synchroniser les données
  useEffect(() => {
    const init = async () => {
      // TOUJOURS vérifier si l'utilisateur est connecté (protection obligatoire)
      if (typeof window !== 'undefined') {
        const isLoggedIn = sessionStorage.getItem('admin_logged_in')
        if (isLoggedIn !== 'true') {
          router.push('/login')
          return
        }
      } else {
        // Si window n'est pas disponible, rediriger vers login
        router.push('/login')
        return
      }

      setMounted(true)
      // Forcer la synchronisation depuis Supabase
      await initializeDefaultCandidates() // Charge les candidats depuis Supabase
      await syncVotersFromSupabase() // Charge les votants depuis Supabase
      await syncVotesFromSupabase() // Charge les votes depuis Supabase
      await syncElectionFromSupabase() // Charge la date de fin depuis Supabase
      
      // Initialiser les champs de date si une date existe
      if (endDate) {
        const date = new Date(endDate)
        setElectionEndDate(date.toISOString().split('T')[0])
        setElectionEndTime(date.toTimeString().slice(0, 5))
      }
    }
    init()
  }, [router, initializeDefaultCandidates, syncVotersFromSupabase, syncVotesFromSupabase, syncElectionFromSupabase, endDate])

  // Vérification périodique de l'authentification (toutes les 30 secondes)
  useEffect(() => {
    const checkAuth = () => {
      if (typeof window !== 'undefined') {
        const isLoggedIn = sessionStorage.getItem('admin_logged_in')
        if (isLoggedIn !== 'true') {
          router.push('/login')
        }
      }
    }

    // Vérifier immédiatement
    checkAuth()
    
    // Vérifier toutes les 30 secondes
    const authInterval = setInterval(checkAuth, 30000)

    // Vérifier aussi quand la fenêtre redevient visible
    const handleVisibilityChange = () => {
      if (document.visibilityState === 'visible') {
        checkAuth()
      }
    }
    document.addEventListener('visibilitychange', handleVisibilityChange)

    return () => {
      clearInterval(authInterval)
      document.removeEventListener('visibilitychange', handleVisibilityChange)
    }
  }, [router])

  // Mise à jour du classement en temps réel
  useEffect(() => {
    const updateRanking = () => {
      if (candidates.length > 0) {
        const totalVotes = getTotalVotes()
        const rankingData = candidates
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
          .sort((a, b) => b.votes - a.votes)
        
        setRanking(rankingData)
      }
    }

    updateRanking()
    // Mettre à jour toutes les secondes pour un affichage en temps réel
    const interval = setInterval(updateRanking, 1000)

    return () => clearInterval(interval)
  }, [candidates, getVotesByCandidate, getTotalVotes, votes])

  const handleAddProgramItem = () => {
    setCandidateForm({ ...candidateForm, program: [...candidateForm.program, ''] })
  }

  const handleRemoveProgramItem = (index: number) => {
    setCandidateForm({
      ...candidateForm,
      program: candidateForm.program.filter((_, i) => i !== index)
    })
  }

  const handleProgramChange = (index: number, value: string) => {
    const newProgram = [...candidateForm.program]
    newProgram[index] = value
    setCandidateForm({ ...candidateForm, program: newProgram })
  }

  const handleAddExperienceItem = () => {
    setCandidateForm({ ...candidateForm, experience: [...candidateForm.experience, ''] })
  }

  const handleRemoveExperienceItem = (index: number) => {
    setCandidateForm({
      ...candidateForm,
      experience: candidateForm.experience.filter((_, i) => i !== index)
    })
  }

  const handleExperienceChange = (index: number, value: string) => {
    const newExperience = [...candidateForm.experience]
    newExperience[index] = value
    setCandidateForm({ ...candidateForm, experience: newExperience })
  }

  const handleSubmitCandidate = async (e: React.FormEvent) => {
    e.preventDefault()
    const socialLinks = {
      linkedin: candidateForm.socialLinks.linkedin || undefined,
      twitter: candidateForm.socialLinks.twitter || undefined,
      instagram: candidateForm.socialLinks.instagram || undefined,
      facebook: candidateForm.socialLinks.facebook || undefined,
      website: candidateForm.socialLinks.website || undefined,
      tiktok: candidateForm.socialLinks.tiktok || undefined,
      whatsapp: candidateForm.socialLinks.whatsapp || undefined,
    }
    
    const candidateData = {
      name: candidateForm.name,
      position: candidateForm.position,
      description: candidateForm.description,
      bio: candidateForm.bio,
      year: candidateForm.year,
      program: candidateForm.program.filter(p => p.trim() !== ''),
      experience: candidateForm.experience.filter(e => e.trim() !== ''),
      image: candidateForm.image || undefined,
      initials: candidateForm.initials || candidateForm.name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2),
      socialLinks: Object.keys(socialLinks).some(key => socialLinks[key as keyof typeof socialLinks]) ? socialLinks : undefined
    }
    
    if (editingCandidate) {
      await updateCandidate(editingCandidate.id, candidateData)
    } else {
      await addCandidate(candidateData)
    }
    handleCancelCandidateForm()
  }

  const handleEditCandidate = (candidate: Candidate) => {
    setEditingCandidate(candidate)
    setCandidateForm({
      name: candidate.name,
      position: candidate.position,
      description: candidate.description,
      bio: candidate.bio,
      year: candidate.year,
      program: candidate.program.length > 0 ? candidate.program : [''],
      experience: candidate.experience.length > 0 ? candidate.experience : [''],
      image: candidate.image || '',
      imageFile: null,
      initials: candidate.initials,
      socialLinks: {
        linkedin: candidate.socialLinks?.linkedin || '',
        twitter: candidate.socialLinks?.twitter || '',
        instagram: candidate.socialLinks?.instagram || '',
        facebook: candidate.socialLinks?.facebook || '',
        website: candidate.socialLinks?.website || '',
        tiktok: candidate.socialLinks?.tiktok || '',
        whatsapp: candidate.socialLinks?.whatsapp || ''
      }
    })
    setImagePreview(candidate.image || null)
    setShowCandidateForm(true)
  }

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      if (file.size > 5 * 1024 * 1024) {
        alert('L\'image est trop grande. Taille maximale : 5MB')
        return
      }
      if (!file.type.startsWith('image/')) {
        alert('Veuillez sélectionner une image')
        return
      }
      
      const reader = new FileReader()
      reader.onloadend = () => {
        const base64String = reader.result as string
        setCandidateForm({ ...candidateForm, image: base64String, imageFile: file })
        setImagePreview(base64String)
      }
      reader.readAsDataURL(file)
    }
  }

  const handleRemoveImage = () => {
    setCandidateForm({ ...candidateForm, image: '', imageFile: null })
    setImagePreview(null)
  }

  const handleCancelCandidateForm = () => {
    setShowCandidateForm(false)
    setEditingCandidate(null)
    setImagePreview(null)
    setCandidateForm({
      name: '',
      position: '',
      description: '',
      bio: '',
      year: '',
      program: [''],
      experience: [''],
      image: '',
      imageFile: null,
      initials: '',
      socialLinks: {
        linkedin: '',
        twitter: '',
        instagram: '',
        facebook: '',
        website: '',
        tiktok: '',
        whatsapp: ''
      }
    })
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
              <p className="text-xs sm:text-sm text-gray-600 hidden sm:block">Administration</p>
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

      <div className="container mx-auto px-4 sm:px-6 py-8 sm:py-12 max-w-7xl">
        {/* Tabs */}
        <div className="flex space-x-2 sm:space-x-4 mb-6 sm:mb-8 border-b border-gray-200 overflow-x-auto">
          <button
            onClick={() => setActiveTab('voters')}
            className={`px-4 sm:px-6 py-2 sm:py-3 text-sm sm:text-base font-semibold transition-colors border-b-2 whitespace-nowrap ${
              activeTab === 'voters'
                ? 'border-bordeaux-500 text-bordeaux-600'
                : 'border-transparent text-gray-600 hover:text-gray-900'
            }`}
          >
            <Users className="w-4 h-4 sm:w-5 sm:h-5 inline mr-1 sm:mr-2" />
            Votants
          </button>
          <button
            onClick={() => setActiveTab('candidates')}
            className={`px-4 sm:px-6 py-2 sm:py-3 text-sm sm:text-base font-semibold transition-colors border-b-2 whitespace-nowrap ${
              activeTab === 'candidates'
                ? 'border-bordeaux-500 text-bordeaux-600'
                : 'border-transparent text-gray-600 hover:text-gray-900'
            }`}
          >
            <UserCircle className="w-4 h-4 sm:w-5 sm:h-5 inline mr-1 sm:mr-2" />
            Candidats
          </button>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
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
            transition={{ delay: 0.1 }}
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
            transition={{ delay: 0.2 }}
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
            transition={{ delay: 0.3 }}
            className="bg-white rounded-xl p-4 sm:p-6 shadow-lg border border-gray-100"
          >
            <div className="flex items-center justify-between mb-3 sm:mb-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-blue-500 rounded-lg flex items-center justify-center">
                <Shield className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
              </div>
            </div>
            <p className="text-gray-600 text-xs sm:text-sm mb-1">Taux participation</p>
            <p className="text-2xl sm:text-3xl font-bold text-blue-600">
              {stats.total > 0 ? Math.round((stats.voted / stats.total) * 100) : 0}%
            </p>
          </motion.div>
        </div>

        {/* Tableau de classement en temps réel */}
        <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 md:p-8 mb-6 sm:mb-8">
          <div className="flex items-center justify-between mb-4 sm:mb-6">
            <h2 className="text-xl sm:text-2xl font-bold text-gray-900 flex items-center space-x-2">
              <Trophy className="w-6 h-6 sm:w-7 sm:h-7 text-yellow-500" />
              <span>Classement en temps réel</span>
            </h2>
            <div className="flex items-center space-x-2 text-sm text-gray-600">
              <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              <span>En direct</span>
            </div>
          </div>
          
          {ranking.length === 0 ? (
            <div className="text-center py-8 sm:py-12">
              <Trophy className="w-12 h-12 sm:w-16 sm:h-16 text-gray-300 mx-auto mb-3 sm:mb-4" />
              <p className="text-gray-500 text-base sm:text-lg">Aucun candidat enregistré</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b-2 border-gray-200">
                    <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">Rang</th>
                    <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">Candidat</th>
                    <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700 hidden md:table-cell">Position</th>
                    <th className="text-center py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">Votes</th>
                    <th className="text-center py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">%</th>
                    <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700 hidden sm:table-cell">Barre</th>
                  </tr>
                </thead>
                <tbody>
                  {ranking.map((candidate, index) => {
                    const rank = index + 1
                    const getRankIcon = () => {
                      if (rank === 1) return <Trophy className="w-5 h-5 sm:w-6 sm:h-6 text-yellow-500" />
                      if (rank === 2) return <Medal className="w-5 h-5 sm:w-6 sm:h-6 text-gray-400" />
                      if (rank === 3) return <Award className="w-5 h-5 sm:w-6 sm:h-6 text-orange-500" />
                      return <span className="text-lg sm:text-xl font-bold text-gray-400">#{rank}</span>
                    }
                    
                    return (
                      <motion.tr
                        key={candidate.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className={`border-b border-gray-100 hover:bg-gray-50 transition-colors ${
                          rank === 1 ? 'bg-yellow-50/50' : ''
                        }`}
                      >
                        <td className="py-3 sm:py-4 px-3 sm:px-4">
                          <div className="flex items-center justify-center sm:justify-start">
                            {getRankIcon()}
                          </div>
                        </td>
                        <td className="py-3 sm:py-4 px-3 sm:px-4">
                          <div className="flex items-center space-x-3">
                            <div className="flex-shrink-0">
                              {candidate.image ? (
                                // eslint-disable-next-line @next/next/no-img-element
                                <img
                                  src={candidate.image}
                                  alt={candidate.name}
                                  className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl object-cover"
                                  onError={(e) => {
                                    const target = e.target as HTMLImageElement
                                    target.style.display = 'none'
                                    const parent = target.parentElement
                                    if (parent && !parent.querySelector('.fallback-initials')) {
                                      const fallback = document.createElement('div')
                                      fallback.className = 'w-10 h-10 sm:w-12 sm:h-12 gradient-bordeaux rounded-xl flex items-center justify-center fallback-initials'
                                      fallback.innerHTML = `<span class="text-sm sm:text-base font-bold text-white">${candidate.initials}</span>`
                                      parent.appendChild(fallback)
                                    }
                                  }}
                                />
                              ) : (
                                <div className="w-10 h-10 sm:w-12 sm:h-12 gradient-bordeaux rounded-xl flex items-center justify-center">
                                  <span className="text-sm sm:text-base font-bold text-white">{candidate.initials}</span>
                                </div>
                              )}
                            </div>
                            <div className="min-w-0">
                              <p className="font-semibold text-gray-900 text-sm sm:text-base truncate">{candidate.name}</p>
                              <p className="text-xs sm:text-sm text-gray-500 md:hidden">{candidate.position}</p>
                            </div>
                          </div>
                        </td>
                        <td className="py-3 sm:py-4 px-3 sm:px-4 text-gray-600 text-sm hidden md:table-cell">
                          {candidate.position}
                        </td>
                        <td className="py-3 sm:py-4 px-3 sm:px-4 text-center">
                          <span className="text-lg sm:text-xl font-bold text-gray-900">{candidate.votes}</span>
                        </td>
                        <td className="py-3 sm:py-4 px-3 sm:px-4 text-center">
                          <span className="text-lg sm:text-xl font-bold text-bordeaux-600">{candidate.percentage}%</span>
                        </td>
                        <td className="py-3 sm:py-4 px-3 sm:px-4 hidden sm:table-cell">
                          <div className="relative h-3 bg-gray-100 rounded-full overflow-hidden max-w-xs">
                            <motion.div
                              key={candidate.votes}
                              initial={{ width: 0 }}
                              animate={{ width: `${candidate.percentage}%` }}
                              transition={{ duration: 0.5 }}
                              className="absolute top-0 left-0 h-full gradient-bordeaux rounded-full"
                            />
                          </div>
                        </td>
                      </motion.tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Configuration de l'élection */}
        <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 md:p-8 mb-6 sm:mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 mb-4 sm:mb-6">Configuration de l&apos;élection</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Date et heure de fin des votes
              </label>
              <div className="flex flex-col sm:flex-row gap-3">
                <input
                  type="date"
                  value={electionEndDate}
                  onChange={(e) => setElectionEndDate(e.target.value)}
                  className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                  min={new Date().toISOString().split('T')[0]}
                />
                <input
                  type="time"
                  value={electionEndTime}
                  onChange={(e) => setElectionEndTime(e.target.value)}
                  className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                />
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={handleSetElectionEndDate}
                  className="px-6 py-3 gradient-bordeaux text-white font-semibold rounded-xl shadow-bordeaux hover:shadow-bordeaux-lg transition-all"
                >
                  Définir
                </motion.button>
                {endDate && (
                  <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={handleClearElectionEndDate}
                    className="px-6 py-3 bg-red-100 text-red-700 font-semibold rounded-xl hover:bg-red-200 transition-all"
                  >
                    Supprimer
                  </motion.button>
                )}
              </div>
              {endDate && (
                <div className="mt-3 p-3 bg-bordeaux-50 border border-bordeaux-200 rounded-lg">
                  <p className="text-sm text-bordeaux-700">
                    <strong>Date de fin configurée :</strong>{' '}
                    {new Date(endDate).toLocaleString('fr-FR', {
                      day: '2-digit',
                      month: 'long',
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit'
                    })}
                  </p>
                  {timeRemaining && timeRemaining.total > 0 && (
                    <p className="text-sm text-bordeaux-600 mt-1">
                      Temps restant : {timeRemaining.days}j {timeRemaining.hours}h {timeRemaining.minutes}m
                    </p>
                  )}
                  {timeRemaining && timeRemaining.total <= 0 && (
                    <p className="text-sm text-red-600 mt-1 font-semibold">
                      Les votes sont terminés
                    </p>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Success Message */}
        {newVoterCode && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-green-50 border-2 border-green-500 rounded-xl p-6 mb-6"
          >
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-lg font-bold text-green-800 mb-2">
                  Votant enregistré avec succès!
                </h3>
                <p className="text-green-700 mb-2">Code de vote généré:</p>
                <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
                  <div className="flex items-center space-x-3">
                    <code className="bg-green-100 text-green-800 px-4 py-2 rounded-lg font-mono text-lg font-bold">
                      {newVoterCode}
                    </code>
                    <button
                      onClick={() => handleCopyCode(newVoterCode)}
                      className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center space-x-2"
                    >
                      {copiedCode === newVoterCode ? (
                        <>
                          <Check className="w-4 h-4" />
                          <span>Copié!</span>
                        </>
                      ) : (
                        <>
                          <Copy className="w-4 h-4" />
                          <span>Copier</span>
                        </>
                      )}
                    </button>
                    <button
                      onClick={() => setShowQRCode(newVoterCode)}
                      className="px-4 py-2 bg-bordeaux-600 text-white rounded-lg hover:bg-bordeaux-700 transition-colors flex items-center space-x-2"
                    >
                      <QrCode className="w-4 h-4" />
                      <span>Voir QR</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {activeTab === 'voters' && (
          <>
        {/* Add Voter Section */}
        <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 md:p-8 mb-6 sm:mb-8">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-4 sm:mb-6 gap-3 sm:gap-0">
            <h2 className="text-xl sm:text-2xl font-bold text-gray-900">Gestion des votants</h2>
            <div className="flex flex-wrap items-center gap-2 sm:gap-3 w-full sm:w-auto">
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={handleResetVoteStats}
                className="px-3 sm:px-4 py-2 bg-orange-100 text-orange-700 text-sm sm:text-base rounded-lg hover:bg-orange-200 transition-colors flex items-center space-x-2"
              >
                <RotateCcw className="w-4 h-4" />
                <span className="hidden sm:inline">Réinitialiser votes</span>
                <span className="sm:hidden">Reset</span>
              </motion.button>
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={handleExportCSV}
                className="px-3 sm:px-4 py-2 bg-gray-100 text-gray-700 text-sm sm:text-base rounded-lg hover:bg-gray-200 transition-colors flex items-center space-x-2"
              >
                <Download className="w-4 h-4" />
                <span className="hidden sm:inline">Exporter CSV</span>
                <span className="sm:hidden">CSV</span>
              </motion.button>
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setShowAddForm(!showAddForm)}
                className="px-4 sm:px-6 py-2 gradient-bordeaux text-white text-sm sm:text-base rounded-lg shadow-bordeaux hover:shadow-bordeaux-lg transition-all flex items-center space-x-2"
              >
                <UserPlus className="w-4 h-4 sm:w-5 sm:h-5" />
                <span>{showAddForm ? 'Annuler' : 'Ajouter un votant'}</span>
              </motion.button>
            </div>
          </div>

          {showAddForm && (
            <motion.form
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              onSubmit={handleAddVoter}
              className="border-2 border-bordeaux-200 rounded-xl p-4 sm:p-6 space-y-4"
            >
              <div className="grid sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Nom complet *
                  </label>
                  <input
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                    placeholder="Jean Dupont"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Numéro étudiant *
                  </label>
                  <input
                    type="text"
                    value={studentId}
                    onChange={(e) => setStudentId(e.target.value)}
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                    placeholder="2024001"
                    required
                  />
                </div>
              </div>
              <motion.button
                type="submit"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className="w-full md:w-auto px-8 py-3 gradient-bordeaux text-white font-semibold rounded-xl shadow-bordeaux-lg hover:shadow-bordeaux-lg transition-all duration-300"
              >
                Générer le code de vote
              </motion.button>
            </motion.form>
          )}
        </div>

        {/* Voters List */}
        <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 md:p-8">
          <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-4 sm:mb-6">Liste des votants</h3>
          {voters.length === 0 ? (
            <div className="text-center py-8 sm:py-12">
              <Users className="w-12 h-12 sm:w-16 sm:h-16 text-gray-300 mx-auto mb-3 sm:mb-4" />
              <p className="text-gray-500 text-base sm:text-lg">Aucun votant enregistré</p>
            </div>
          ) : (
            <div className="overflow-x-auto -mx-4 sm:mx-0">
              <div className="min-w-full inline-block align-middle">
                <table className="w-full">
                  <thead>
                    <tr className="border-b-2 border-gray-200">
                      <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">Nom</th>
                      <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700 hidden md:table-cell">Numéro étudiant</th>
                      <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700 hidden lg:table-cell">Email</th>
                      <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">Code</th>
                      <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">Statut</th>
                      <th className="text-left py-3 sm:py-4 px-3 sm:px-4 text-xs sm:text-sm font-semibold text-gray-700">Actions</th>
                    </tr>
                  </thead>
                <tbody>
                  {voters.map((voter, index) => (
                    <motion.tr
                      key={voter.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="border-b border-gray-100 hover:bg-gray-50"
                    >
                      <td className="py-3 sm:py-4 px-3 sm:px-4 font-medium text-gray-900 text-sm">
                        <div className="font-semibold">{voter.name}</div>
                        <div className="text-xs text-gray-500 md:hidden mt-1">{voter.studentId}</div>
                        <div className="text-xs text-gray-500 lg:hidden mt-1 truncate">{voter.email}</div>
                      </td>
                      <td className="py-3 sm:py-4 px-3 sm:px-4 text-gray-600 text-sm hidden md:table-cell">{voter.studentId}</td>
                      <td className="py-3 sm:py-4 px-3 sm:px-4 text-gray-600 text-sm hidden lg:table-cell truncate max-w-xs">{voter.email}</td>
                      <td className="py-3 sm:py-4 px-3 sm:px-4">
                        <div className="flex items-center space-x-1 sm:space-x-2">
                          <code className="bg-gray-100 text-gray-800 px-2 sm:px-3 py-1 rounded font-mono text-xs sm:text-sm">
                            {voter.voteCode}
                          </code>
                          <button
                            onClick={() => handleCopyCode(voter.voteCode)}
                            className="p-1 hover:bg-gray-200 rounded transition-colors"
                            title="Copier le code"
                          >
                            {copiedCode === voter.voteCode ? (
                              <Check className="w-3 h-3 sm:w-4 sm:h-4 text-green-600" />
                            ) : (
                              <Copy className="w-3 h-3 sm:w-4 sm:h-4 text-gray-600" />
                            )}
                          </button>
                          <button
                            onClick={() => setShowQRCode(voter.voteCode)}
                            className="p-1 hover:bg-bordeaux-50 rounded transition-colors"
                            title="Voir le QR code"
                          >
                            <QrCode className="w-3 h-3 sm:w-4 sm:h-4 text-bordeaux-600" />
                          </button>
                          {voter.whatsapp && (
                            <button
                              onClick={() => handleSendWhatsApp(voter)}
                              className="p-1 hover:bg-green-50 rounded transition-colors"
                              title="Envoyer le code par WhatsApp"
                            >
                              <MessageCircle className="w-3 h-3 sm:w-4 sm:h-4 text-green-600" />
                            </button>
                          )}
                        </div>
                      </td>
                      <td className="py-3 sm:py-4 px-3 sm:px-4">
                        {voter.hasVoted ? (
                          <span className="inline-flex items-center px-2 sm:px-3 py-1 rounded-full text-xs sm:text-sm font-semibold bg-green-100 text-green-800">
                            <CheckCircle className="w-3 h-3 sm:w-4 sm:h-4 mr-1" />
                            <span className="hidden sm:inline">A voté</span>
                            <span className="sm:hidden">✓</span>
                          </span>
                        ) : (
                          <span className="inline-flex items-center px-2 sm:px-3 py-1 rounded-full text-xs sm:text-sm font-semibold bg-orange-100 text-orange-800">
                            <Clock className="w-3 h-3 sm:w-4 sm:h-4 mr-1" />
                            <span className="hidden sm:inline">En attente</span>
                            <span className="sm:hidden">⏱</span>
                          </span>
                        )}
                      </td>
                      <td className="py-3 sm:py-4 px-3 sm:px-4">
                        <button
                          onClick={async () => {
                            if (confirm('Êtes-vous sûr de vouloir supprimer ce votant?')) {
                              await deleteVoter(voter.id)
                            }
                          }}
                          className="p-1.5 sm:p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                          title="Supprimer"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </td>
                    </motion.tr>
                  ))}
                </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
          </>
        )}

        {activeTab === 'candidates' && (
          <>
            {/* Add Candidate Section */}
            <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 md:p-8 mb-6 sm:mb-8">
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-4 sm:mb-6 gap-3 sm:gap-0">
                <h2 className="text-xl sm:text-2xl font-bold text-gray-900">Gestion des candidats</h2>
                <div className="flex flex-wrap items-center gap-2 sm:gap-3 w-full sm:w-auto">
                  <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={async () => {
                      if (confirm('Êtes-vous sûr de vouloir supprimer toutes les données ? Tous les candidats et votants seront définitivement supprimés.')) {
                        // Supprimer toutes les données
                        const { deleteAllData } = await import('@/lib/supabase-helpers')
                        await deleteAllData()
                        await clearAllCandidates()
                        if (typeof window !== 'undefined') {
                          localStorage.removeItem('voter-storage')
                          localStorage.removeItem('candidate-storage')
                          localStorage.removeItem('vote-storage')
                          // Recharger la page pour réinitialiser
                          window.location.reload()
                        }
                      }
                    }}
                    className="px-4 py-2 bg-orange-100 text-orange-700 rounded-lg hover:bg-orange-200 transition-all flex items-center space-x-2"
                  >
                    <Trash2 className="w-4 h-4" />
                    <span>Réinitialiser tout</span>
                  </motion.button>
                  {candidates.length > 0 && (
                    <motion.button
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={async () => {
                        if (confirm('Êtes-vous sûr de vouloir supprimer tous les candidats ?')) {
                          await clearAllCandidates()
                        }
                      }}
                      className="px-4 py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition-all flex items-center space-x-2"
                    >
                      <Trash2 className="w-4 h-4" />
                      <span>Supprimer candidats</span>
                    </motion.button>
                  )}
                  <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => {
                      setShowCandidateForm(!showCandidateForm)
                      if (showCandidateForm) handleCancelCandidateForm()
                    }}
                    className="px-6 py-2 gradient-bordeaux text-white rounded-lg shadow-bordeaux hover:shadow-bordeaux-lg transition-all flex items-center space-x-2"
                  >
                    <Plus className="w-5 h-5" />
                    <span>{showCandidateForm ? 'Annuler' : 'Ajouter un candidat'}</span>
                  </motion.button>
                </div>
              </div>

              {showCandidateForm && (
                <motion.form
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                  onSubmit={handleSubmitCandidate}
                  className="border-2 border-bordeaux-200 rounded-xl p-4 sm:p-6 space-y-4 sm:space-y-6"
                >
                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Nom complet *
                      </label>
                      <input
                        type="text"
                        value={candidateForm.name}
                        onChange={(e) => setCandidateForm({ ...candidateForm, name: e.target.value })}
                        className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                        placeholder="Marie Dubois"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Position *
                      </label>
                      <input
                        type="text"
                        value={candidateForm.position}
                        onChange={(e) => setCandidateForm({ ...candidateForm, position: e.target.value })}
                        className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                        placeholder="Présidente"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Année d&apos;étude *
                      </label>
                      <input
                        type="text"
                        value={candidateForm.year}
                        onChange={(e) => setCandidateForm({ ...candidateForm, year: e.target.value })}
                        className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                        placeholder="3ème année"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Initiales (optionnel)
                      </label>
                      <input
                        type="text"
                        value={candidateForm.initials}
                        onChange={(e) => setCandidateForm({ ...candidateForm, initials: e.target.value.toUpperCase() })}
                        className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                        placeholder="MD"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Description courte *
                    </label>
                    <input
                      type="text"
                      value={candidateForm.description}
                      onChange={(e) => setCandidateForm({ ...candidateForm, description: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                      placeholder="Leader visionnaire et engagée pour l'avenir de RHIT"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Biographie *
                    </label>
                    <textarea
                      value={candidateForm.bio}
                      onChange={(e) => setCandidateForm({ ...candidateForm, bio: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                      rows={4}
                      placeholder="Description détaillée du candidat..."
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Programme électoral *
                    </label>
                    {candidateForm.program.map((item, index) => (
                      <div key={index} className="flex items-center space-x-2 mb-2">
                        <input
                          type="text"
                          value={item}
                          onChange={(e) => handleProgramChange(index, e.target.value)}
                          className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder={`Point ${index + 1} du programme`}
                          required={index === 0}
                        />
                        {candidateForm.program.length > 1 && (
                          <button
                            type="button"
                            onClick={() => handleRemoveProgramItem(index)}
                            className="p-3 text-red-600 hover:bg-red-50 rounded-xl transition-colors"
                          >
                            <X className="w-5 h-5" />
                          </button>
                        )}
                      </div>
                    ))}
                    <button
                      type="button"
                      onClick={handleAddProgramItem}
                      className="mt-2 px-4 py-2 text-bordeaux-600 hover:bg-bordeaux-50 rounded-lg transition-colors flex items-center space-x-2"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Ajouter un point</span>
                    </button>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Expérience *
                    </label>
                    {candidateForm.experience.map((item, index) => (
                      <div key={index} className="flex items-center space-x-2 mb-2">
                        <input
                          type="text"
                          value={item}
                          onChange={(e) => handleExperienceChange(index, e.target.value)}
                          className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder={`Expérience ${index + 1}`}
                          required={index === 0}
                        />
                        {candidateForm.experience.length > 1 && (
                          <button
                            type="button"
                            onClick={() => handleRemoveExperienceItem(index)}
                            className="p-3 text-red-600 hover:bg-red-50 rounded-xl transition-colors"
                          >
                            <X className="w-5 h-5" />
                          </button>
                        )}
                      </div>
                    ))}
                    <button
                      type="button"
                      onClick={handleAddExperienceItem}
                      className="mt-2 px-4 py-2 text-bordeaux-600 hover:bg-bordeaux-50 rounded-lg transition-colors flex items-center space-x-2"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Ajouter une expérience</span>
                    </button>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Photo du candidat
                    </label>
                    <div className="space-y-4">
                      {imagePreview || candidateForm.image ? (
                        <div className="relative">
                          <div className="w-32 h-32 rounded-xl overflow-hidden border-2 border-gray-200 relative">
                            <Image 
                              src={imagePreview || candidateForm.image || ''} 
                              alt="Preview" 
                              fill
                              className="object-cover"
                            />
                          </div>
                          <button
                            type="button"
                            onClick={handleRemoveImage}
                            className="absolute -top-2 -right-2 p-1 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </div>
                      ) : null}
                      <div>
                        <label className="flex flex-col items-center justify-center w-full h-32 border-2 border-gray-300 border-dashed rounded-xl cursor-pointer bg-gray-50 hover:bg-gray-100 transition-colors">
                          <div className="flex flex-col items-center justify-center pt-5 pb-6">
                            <Upload className="w-8 h-8 mb-2 text-gray-500" />
                            <p className="mb-2 text-sm text-gray-500">
                              <span className="font-semibold">Cliquez pour uploader</span> ou glissez-déposez
                            </p>
                            <p className="text-xs text-gray-500">PNG, JPG, WEBP (MAX. 5MB)</p>
                          </div>
                          <input
                            type="file"
                            className="hidden"
                            accept="image/*"
                            onChange={handleImageUpload}
                          />
                        </label>
                      </div>
                      <div className="text-sm text-gray-500">
                        <p>Ou entrez une URL d&apos;image :</p>
                        <input
                          type="url"
                          value={candidateForm.image && !imagePreview ? candidateForm.image : ''}
                          onChange={(e) => {
                            setCandidateForm({ ...candidateForm, image: e.target.value, imageFile: null })
                            setImagePreview(null)
                          }}
                          className="w-full mt-2 px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="https://example.com/photo.jpg"
                        />
                      </div>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-3">
                      Réseaux sociaux (optionnel)
                    </label>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <label className="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                          <Linkedin className="w-4 h-4 text-blue-600" />
                          <span>LinkedIn</span>
                        </label>
                        <input
                          type="url"
                          value={candidateForm.socialLinks.linkedin}
                          onChange={(e) => setCandidateForm({
                            ...candidateForm,
                            socialLinks: { ...candidateForm.socialLinks, linkedin: e.target.value }
                          })}
                          className="w-full px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="https://linkedin.com/in/..."
                        />
                      </div>
                      <div>
                        <label className="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                          <Twitter className="w-4 h-4 text-blue-400" />
                          <span>Twitter/X</span>
                        </label>
                        <input
                          type="url"
                          value={candidateForm.socialLinks.twitter}
                          onChange={(e) => setCandidateForm({
                            ...candidateForm,
                            socialLinks: { ...candidateForm.socialLinks, twitter: e.target.value }
                          })}
                          className="w-full px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="https://twitter.com/..."
                        />
                      </div>
                      <div>
                        <label className="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                          <Instagram className="w-4 h-4 text-pink-600" />
                          <span>Instagram</span>
                        </label>
                        <input
                          type="url"
                          value={candidateForm.socialLinks.instagram}
                          onChange={(e) => setCandidateForm({
                            ...candidateForm,
                            socialLinks: { ...candidateForm.socialLinks, instagram: e.target.value }
                          })}
                          className="w-full px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="https://instagram.com/..."
                        />
                      </div>
                      <div>
                        <label className="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                          <Facebook className="w-4 h-4 text-blue-700" />
                          <span>Facebook</span>
                        </label>
                        <input
                          type="url"
                          value={candidateForm.socialLinks.facebook}
                          onChange={(e) => setCandidateForm({
                            ...candidateForm,
                            socialLinks: { ...candidateForm.socialLinks, facebook: e.target.value }
                          })}
                          className="w-full px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="https://facebook.com/..."
                        />
                      </div>
                      <div className="md:col-span-2">
                        <label className="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                          <Globe className="w-4 h-4 text-gray-600" />
                          <span>Site web</span>
                        </label>
                        <input
                          type="url"
                          value={candidateForm.socialLinks.website}
                          onChange={(e) => setCandidateForm({
                            ...candidateForm,
                            socialLinks: { ...candidateForm.socialLinks, website: e.target.value }
                          })}
                          className="w-full px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="https://example.com"
                        />
                      </div>
                      <div>
                        <label className="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                          <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M19.59 6.69a4.83 4.83 0 0 1-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 0 1-5.2 1.79 2.89 2.89 0 0 1 2.31-4.64 2.93 2.93 0 0 1 .88.13V9.4a6.84 6.84 0 0 0-1-.05A6.33 6.33 0 0 0 5 20.1a6.34 6.34 0 0 0 10.86-4.43v-7a8.16 8.16 0 0 0 4.77 1.52v-3.4a4.85 4.85 0 0 1-1-.1z"/>
                          </svg>
                          <span>TikTok</span>
                        </label>
                        <input
                          type="url"
                          value={candidateForm.socialLinks.tiktok}
                          onChange={(e) => setCandidateForm({
                            ...candidateForm,
                            socialLinks: { ...candidateForm.socialLinks, tiktok: e.target.value }
                          })}
                          className="w-full px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="https://tiktok.com/@..."
                        />
                      </div>
                      <div>
                        <label className="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                          <MessageCircle className="w-4 h-4 text-green-600" />
                          <span>WhatsApp</span>
                        </label>
                        <input
                          type="text"
                          value={candidateForm.socialLinks.whatsapp}
                          onChange={(e) => setCandidateForm({
                            ...candidateForm,
                            socialLinks: { ...candidateForm.socialLinks, whatsapp: e.target.value }
                          })}
                          className="w-full px-4 py-2 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                          placeholder="+33 6 12 34 56 78"
                        />
                      </div>
                    </div>
                  </div>

                  <motion.button
                    type="submit"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className="w-full md:w-auto px-8 py-3 gradient-bordeaux text-white font-semibold rounded-xl shadow-bordeaux-lg hover:shadow-bordeaux-lg transition-all duration-300"
                  >
                    {editingCandidate ? 'Mettre à jour le candidat' : 'Ajouter le candidat'}
                  </motion.button>
                </motion.form>
              )}
            </div>

            {/* Candidates List */}
            <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 md:p-8">
              <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-4 sm:mb-6">Liste des candidats</h3>
              {!mounted ? (
                <div className="text-center py-12">
                  <p className="text-gray-500 text-lg">Chargement...</p>
                </div>
              ) : candidates.length === 0 ? (
                <div className="text-center py-12">
                  <UserCircle className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <p className="text-gray-500 text-lg">Aucun candidat enregistré</p>
                </div>
              ) : (
                <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
                  {candidates.map((candidate, index) => (
                    <motion.div
                      key={candidate.id}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className="border-2 border-gray-200 rounded-xl p-6 hover:border-bordeaux-300 hover:shadow-lg transition-all"
                    >
                      <div className="flex items-start justify-between mb-4">
                        <div className="w-16 h-16 rounded-xl overflow-hidden shadow-lg flex items-center justify-center bg-gradient-to-br from-bordeaux-500 to-bordeaux-700">
                          {candidate.image ? (
                            candidate.image.startsWith('data:') || candidate.image.startsWith('http') ? (
                              // eslint-disable-next-line @next/next/no-img-element
                              <img
                                src={candidate.image}
                                alt={candidate.name}
                                className="w-full h-full object-cover"
                              />
                            ) : (
                              <Image
                                src={candidate.image}
                                alt={candidate.name}
                                width={64}
                                height={64}
                                className="object-cover"
                                unoptimized
                              />
                            )
                          ) : (
                            <span className="text-white text-xl font-bold">
                              {candidate.initials}
                            </span>
                          )}
                        </div>
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handleEditCandidate(candidate)}
                            className="p-2 text-bordeaux-600 hover:bg-bordeaux-50 rounded-lg transition-colors"
                            title="Modifier"
                          >
                            <Edit className="w-4 h-4" />
                          </button>
                          <button
                            onClick={async () => {
                              if (confirm('Êtes-vous sûr de vouloir supprimer ce candidat?')) {
                                await deleteCandidate(candidate.id)
                              }
                            }}
                            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                            title="Supprimer"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                      <h4 className="text-lg font-bold text-gray-900 mb-1">{candidate.name}</h4>
                      <p className="text-bordeaux-600 font-semibold text-sm mb-2">{candidate.position}</p>
                      <p className="text-gray-600 text-sm line-clamp-2">{candidate.description}</p>
                    </motion.div>
                  ))}
                </div>
              )}
            </div>
          </>
        )}

        {/* Modal QR Code */}
        <AnimatePresence>
          {showQRCode && (
            <>
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setShowQRCode(null)}
                className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50"
              />
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className="fixed inset-0 z-50 flex items-center justify-center p-4"
              >
                <div className="bg-white rounded-2xl shadow-xl p-6 sm:p-8 max-w-md w-full relative">
                  <button
                    onClick={() => setShowQRCode(null)}
                    className="absolute top-4 right-4 p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                  <div className="text-center mb-6">
                    <h3 className="text-xl font-bold text-gray-900 mb-2">Code QR de vote</h3>
                    <p className="text-sm text-gray-600">Code: <code className="bg-gray-100 px-2 py-1 rounded font-mono">{showQRCode}</code></p>
                  </div>
                  <QRCodeDisplay
                    value={`${typeof window !== 'undefined' ? window.location.origin : ''}/vote?code=${showQRCode}`}
                    size={256}
                    showDownload={true}
                  />
                  <p className="text-xs text-gray-500 text-center mt-4">
                    L&apos;étudiant peut scanner ce code pour accéder directement à l&apos;authentification avec son code pré-rempli
                  </p>
                </div>
              </motion.div>
            </>
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}

