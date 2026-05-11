'use client'

import { useEffect } from 'react'
import { useElectionStore } from '@/lib/electionStore'

/** Réhydrate les stores persistés après le montage client (voir skipHydration sur electionStore). */
export function RehydrateStores() {
  useEffect(() => {
    void useElectionStore.persist.rehydrate()
  }, [])
  return null
}
