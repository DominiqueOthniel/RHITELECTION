'use client'

import { QRCodeSVG } from 'qrcode.react'
import { motion } from 'framer-motion'
import { Download, QrCode } from 'lucide-react'
import { useState } from 'react'

interface QRCodeDisplayProps {
  value: string
  size?: number
  showDownload?: boolean
  title?: string
}

export default function QRCodeDisplay({ 
  value, 
  size = 200, 
  showDownload = false,
  title 
}: QRCodeDisplayProps) {
  const [downloading, setDownloading] = useState(false)

  const handleDownload = () => {
    setDownloading(true)
    const svg = document.getElementById('qrcode-svg')
    if (svg) {
      const svgData = new XMLSerializer().serializeToString(svg)
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      const img = new Image()
      
      img.onload = () => {
        canvas.width = size
        canvas.height = size
        ctx?.drawImage(img, 0, 0)
        canvas.toBlob((blob) => {
          if (blob) {
            const url = URL.createObjectURL(blob)
            const link = document.createElement('a')
            link.href = url
            link.download = `qrcode-${Date.now()}.png`
            link.click()
            URL.revokeObjectURL(url)
          }
          setDownloading(false)
        })
      }
      
      img.src = 'data:image/svg+xml;base64,' + btoa(unescape(encodeURIComponent(svgData)))
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      className="flex flex-col items-center space-y-3"
    >
      {title && (
        <h3 className="text-sm font-semibold text-gray-700">{title}</h3>
      )}
      <div className="bg-white p-4 rounded-xl shadow-lg border-2 border-gray-200">
        <QRCodeSVG
          id="qrcode-svg"
          value={value}
          size={size}
          level="H"
          includeMargin={true}
        />
      </div>
      {showDownload && (
        <motion.button
          onClick={handleDownload}
          disabled={downloading}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="px-4 py-2 bg-bordeaux-600 text-white rounded-lg hover:bg-bordeaux-700 transition-colors flex items-center space-x-2 text-sm font-medium"
        >
          <Download className="w-4 h-4" />
          <span>{downloading ? 'Téléchargement...' : 'Télécharger QR'}</span>
        </motion.button>
      )}
    </motion.div>
  )
}


