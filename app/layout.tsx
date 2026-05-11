import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'RHIT Élections - Bureau des Étudiants',
  description: 'Système de vote en ligne sécurisé pour les élections du bureau des étudiants de RHIT',
  viewport: 'width=device-width, initial-scale=1, maximum-scale=5',
  themeColor: '#8B1538',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr" suppressHydrationWarning>
      <body suppressHydrationWarning>{children}</body>
    </html>
  )
}

