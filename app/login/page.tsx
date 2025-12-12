'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { Lock, User, Shield } from 'lucide-react'
import { supabase } from '@/lib/supabase'
import { hashPassword } from '@/lib/admin-auth'

export default function LoginPage() {
  const router = useRouter()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    // Vérifier si l'utilisateur est déjà connecté
    const isLoggedIn = sessionStorage.getItem('admin_logged_in')
    if (isLoggedIn === 'true') {
      router.push('/admin')
    }
  }, [router])

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      // Hasher le mot de passe
      const passwordHash = await hashPassword(password)
      
      // Vérifier les identifiants dans Supabase
      // @ts-ignore - Type issue avec Supabase RPC
      const { data, error: verifyError } = await supabase
        .rpc('verify_admin_credentials', {
          p_username: username,
          p_password_hash: passwordHash
        } as any) as { data: any[] | null; error: any }

      if (verifyError) {
        console.error('Erreur de vérification:', verifyError)
        // Fallback: vérification simple côté client (moins sécurisé)
        // En production, utilisez toujours Supabase avec des hash sécurisés
        const isValid = await verifyCredentialsSimple(username, password)
        
        if (isValid) {
          sessionStorage.setItem('admin_logged_in', 'true')
          sessionStorage.setItem('admin_username', username)
          router.push('/admin')
        } else {
          setError('Nom d\'utilisateur ou mot de passe incorrect')
        }
      } else if (data && (data as any[]).length > 0 && (data[0] as any).is_active) {
        // Mettre à jour la dernière connexion
        // @ts-ignore - Type issue avec Supabase RPC
        await supabase.rpc('update_admin_last_login', {
          p_admin_id: (data[0] as any).id
        } as any)
        
        sessionStorage.setItem('admin_logged_in', 'true')
        sessionStorage.setItem('admin_username', username)
        router.push('/admin')
      } else {
        setError('Nom d\'utilisateur ou mot de passe incorrect')
      }
    } catch (err) {
      console.error('Erreur lors de la connexion:', err)
      setError('Une erreur est survenue. Veuillez réessayer.')
    } finally {
      setLoading(false)
    }
  }

  // Vérification simple côté client (fallback)
  // En production, utilisez toujours Supabase
  const verifyCredentialsSimple = async (username: string, password: string): Promise<boolean> => {
    // Récupérer les admins depuis Supabase
    const { data, error } = await supabase
      .from('admin_users')
      .select('username, password_hash')
      .eq('username', username)
      .eq('is_active', true)
      .single()

    if (error || !data) {
      return false
    }

    // Comparer les hash
    const passwordHash = await hashPassword(password)
    return passwordHash === (data as any).password_hash || (data as any).password_hash === passwordHash
  }

  if (!mounted) {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-bordeaux-50 via-white to-bordeaux-50 flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md"
      >
        <div className="bg-white rounded-2xl shadow-2xl p-8 border-2 border-bordeaux-100">
          {/* Header */}
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-bordeaux-100 rounded-full mb-4">
              <Shield className="w-8 h-8 text-bordeaux-600" />
            </div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              Administration
            </h1>
            <p className="text-gray-600">
              Connectez-vous pour accéder au panneau d&apos;administration
            </p>
          </div>

          {/* Login Form */}
          <form onSubmit={handleLogin} className="space-y-6">
            {/* Username */}
            <div>
              <label htmlFor="username" className="block text-sm font-semibold text-gray-700 mb-2">
                Nom d&apos;utilisateur
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <User className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="username"
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                  className="block w-full pl-10 pr-3 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                  placeholder="Entrez votre nom d'utilisateur"
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label htmlFor="password" className="block text-sm font-semibold text-gray-700 mb-2">
                Mot de passe
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="block w-full pl-10 pr-3 py-3 border-2 border-gray-200 rounded-xl focus:border-bordeaux-500 focus:ring-2 focus:ring-bordeaux-200 transition-all outline-none"
                  placeholder="Entrez votre mot de passe"
                />
              </div>
            </div>

            {/* Error Message */}
            {error && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-red-50 border-2 border-red-200 text-red-700 px-4 py-3 rounded-xl"
              >
                {error}
              </motion.div>
            )}

            {/* Submit Button */}
            <motion.button
              type="submit"
              disabled={loading}
              whileHover={{ scale: loading ? 1 : 1.02 }}
              whileTap={{ scale: loading ? 1 : 0.98 }}
              className="w-full bg-bordeaux-600 text-white py-3 rounded-xl font-semibold hover:bg-bordeaux-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
            >
              {loading ? (
                <>
                  <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  <span>Connexion...</span>
                </>
              ) : (
                <>
                  <Lock className="w-5 h-5" />
                  <span>Se connecter</span>
                </>
              )}
            </motion.button>
          </form>
        </div>
      </motion.div>
    </div>
  )
}

