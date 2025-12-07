'use client'

import { useEffect, useRef, useState } from 'react'
import { Html5Qrcode } from 'html5-qrcode'
import { motion, AnimatePresence } from 'framer-motion'
import { Camera, X, AlertCircle } from 'lucide-react'

interface QRCodeScannerProps {
  onScanSuccess: (decodedText: string) => void
  onClose: () => void
}

export default function QRCodeScanner({ onScanSuccess, onClose }: QRCodeScannerProps) {
  const [scanning, setScanning] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const scannerRef = useRef<Html5Qrcode | null>(null)
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const startScanning = async () => {
      try {
        const scanner = new Html5Qrcode('qr-reader')
        scannerRef.current = scanner

        await scanner.start(
          { facingMode: 'environment' },
          {
            fps: 10,
            qrbox: { width: 250, height: 250 },
          },
          (decodedText) => {
            scanner.stop()
            setScanning(false)
            onScanSuccess(decodedText)
          },
          (errorMessage) => {
            // Ignorer les erreurs de scan continu
          }
        )
        setScanning(true)
        setError(null)
      } catch (err: any) {
        setError(err.message || 'Impossible d\'accéder à la caméra')
        setScanning(false)
      }
    }

    startScanning()

    return () => {
      if (scannerRef.current && scanning) {
        scannerRef.current.stop().catch(() => {})
      }
    }
  }, [onScanSuccess, scanning])

  const handleClose = async () => {
    if (scannerRef.current && scanning) {
      try {
        await scannerRef.current.stop()
      } catch (err) {
        // Ignorer les erreurs d'arrêt
      }
    }
    setScanning(false)
    onClose()
  }

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
        {/* Overlay */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={handleClose}
          className="absolute inset-0 bg-black/80 backdrop-blur-sm"
        />

        {/* Scanner Modal */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.9 }}
          className="relative bg-white rounded-2xl p-6 max-w-md w-full"
        >
          {/* Close Button */}
          <button
            onClick={handleClose}
            className="absolute top-4 right-4 p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors z-10"
          >
            <X className="w-5 h-5" />
          </button>

          <div className="mb-4">
            <h3 className="text-xl font-bold text-gray-900 mb-2">Scanner le code QR</h3>
            <p className="text-sm text-gray-600">Positionnez le code QR dans le cadre</p>
          </div>

          {error && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-red-50 border-2 border-red-500 rounded-xl p-4 mb-4 flex items-start space-x-3"
            >
              <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-red-800 text-sm font-semibold">Erreur</p>
                <p className="text-red-700 text-sm">{error}</p>
              </div>
            </motion.div>
          )}

          <div
            ref={containerRef}
            id="qr-reader"
            className="w-full rounded-xl overflow-hidden bg-gray-100"
            style={{ minHeight: '300px' }}
          />

          {!scanning && !error && (
            <div className="mt-4 text-center">
              <Camera className="w-12 h-12 text-gray-300 mx-auto mb-2" />
              <p className="text-sm text-gray-500">Initialisation de la caméra...</p>
            </div>
          )}
        </motion.div>
      </div>
    </AnimatePresence>
  )
}


