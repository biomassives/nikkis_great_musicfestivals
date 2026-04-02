// ─── Instance composable ──────────────────────────────────────────────────────
// Central access point for all instance-specific values (storage bucket,
// localStorage key prefix, theme tokens, season info, etc.).
//
// Usage:
//   import { useInstance, storageBucket, sessionKey } from 'src/lib/instance'
//
//   // inside a component or store:
//   const inst = useInstance()
//   inst.config.site_name          // "Nikki's Great Music Festivals"
//   inst.storageBucket()           // "festival-media"
//   inst.sessionKey('welcomed_v1') // "ngmf_welcomed_v1"
//
//   // or as bare helpers (no reactive context needed):
//   storageBucket()                // "festival-media"
//   sessionKey('page_draft_42')    // "ngmf_page_draft_42"

import { config } from 'instance/lovelight/config'
import type { InstanceConfig } from 'instance/lovelight/config'

export type { InstanceConfig }

export function useInstance() {
  return {
    config,
    storageBucket: () => config.storage_bucket,
    sessionKey:    (suffix: string) => `${config.session_prefix}${suffix}`,
  }
}

// Convenience bare helpers — can be called outside component setup()
export function storageBucket(): string {
  return config.storage_bucket
}

export function sessionKey(suffix: string): string {
  return `${config.session_prefix}${suffix}`
}
