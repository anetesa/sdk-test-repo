//
//  AtlantisManager.swift
//  Arise
//
//  Network debugging with Atlantis & Proxyman
//

import Foundation
#if DEBUG
import Atlantis
#endif

@objc(AtlantisManager)
class AtlantisManager: NSObject {
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  @objc
  func start() {
    #if DEBUG
    Atlantis.start()
    print("🔷 Atlantis started - Network traffic will be visible in Proxyman")
    #endif
  }
  
  @objc
  func stop() {
    #if DEBUG
    print("🔷 Atlantis stopped")
    #endif
  }
}

