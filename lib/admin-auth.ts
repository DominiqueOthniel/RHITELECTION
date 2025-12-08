// Fonction utilitaire pour hasher un mot de passe avec SHA-256
export async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(password)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
  return hashHex
}

// Vérifier si l'utilisateur est connecté
export function isAdminLoggedIn(): boolean {
  if (typeof window === 'undefined') return false
  return sessionStorage.getItem('admin_logged_in') === 'true'
}

// Obtenir le nom d'utilisateur de l'admin connecté
export function getAdminUsername(): string | null {
  if (typeof window === 'undefined') return null
  return sessionStorage.getItem('admin_username')
}

// Déconnecter l'admin
export function logoutAdmin(): void {
  if (typeof window === 'undefined') return
  sessionStorage.removeItem('admin_logged_in')
  sessionStorage.removeItem('admin_username')
}


