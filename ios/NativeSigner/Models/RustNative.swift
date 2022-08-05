//
//  RustNative.swift
//  NativeSigner
//
//  Created by Alexander Slesarev on 22.7.2021.
//

import Foundation
import LocalAuthentication // to detect if password is set

/// Object to store all data; since the data really is mostly stored in RustNative side,
/// just one object (to describe it) is used here.
final class SignerDataModel: ObservableObject {
    // Action handler
    @Published var actionResult: ActionResult = ActionResult( // Screen state is stored here
        screenLabel: "",
        back: false,
        footer: false,
        footerButton: .settings,
        rightButton: .none,
        screenNameType: .h4,
        screenData: ScreenData.documents,
        modalData: nil,
        alertData: .none
    )
    @Published var parsingAlert: Bool = false

    // Data state
    @Published var seedNames: [String] = []
    @Published var onboardingDone: Bool = false
    @Published var authenticated: Bool = false

    // This just starts camera reset. Could be done cleaner probably.
    @Published var resetCamera: Bool = false

    // Alert indicator
    @Published var canaryDead: Bool = false
    @Published var alert: Bool = false
    @Published var alertShow: Bool = false

    /// debouncer
    var actionAvailable = true
    /// Debounce time
    let debounceTime: Double = 0.2
    /// version
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    /// did user set up password?
    let protected = LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)

    private let bundle: BundleProtocol
    private let connectivityMonitor: ConnectivityMonitoring
    private let databaseMediator: DatabaseMediating
    private let fileManager: FileManagingProtocol

    init(
        bundle: BundleProtocol = Bundle.main,
        connectivityMonitor: ConnectivityMonitoring = ConnectivityMonitoringAssembler().assemble(),
        databaseMediator: DatabaseMediating = DatabaseMediator(),
        fileManager: FileManagingProtocol = FileManager.default
    ) {
        self.bundle = bundle
        self.connectivityMonitor = connectivityMonitor
        self.databaseMediator = databaseMediator
        self.fileManager = fileManager
        onboardingDone = databaseMediator.isDatabaseAvailable()

        setUpConnectivityMonitoring()
        finaliseInitialisation()
    }

    /// Mild refresh for situations when no interaction with data was really performed.
    /// Should not call stuff in signer.h
    func refreshUI() {}

    /// refresh everything except for seedNames
    /// should be called as often as reasonably possible - on flow interrupts, changes, events, etc.
    func totalRefresh() {
        print("heavy reset")
        pushButton(action: .start)
        checkAlert()
        // self.refreshUI()
    }

    /// Should be called once on factory-new state of the app
    /// Populates database with starting values
    func onboard(jailbreak: Bool = false) {
        guard !canaryDead else { return }
        print("onboarding...")
        wipe()
        guard databaseMediator.recreateDatabaseFile() else {
            print("Databse could not be recreated")
            return
        }
        do {
            if jailbreak {
                try historyInitHistoryNoCert(dbname: databaseMediator.databaseName)
            } else {
                try historyInitHistoryWithCert(dbname: databaseMediator.databaseName)
            }
            onboardingDone = true
            // Mean app mode:
            // if self.canaryDead {
            // device_was_online(nil, self.dbName)
            // }
            initNavigation(dbname: databaseMediator.databaseName, seedNames: seedNames)
            totalRefresh()
            refreshSeeds()
        } catch {
            print("History init failed! This will not do.")
        }
    }
}

private extension SignerDataModel {
    func setUpConnectivityMonitoring() {
        connectivityMonitor.startMonitoring { isConnected in
            if isConnected, self.onboardingDone {
                do {
                    try historyDeviceWasOnline()
                } catch {
                    return
                }
                self.alert = true
            }
            self.canaryDead = isConnected
        }
    }

    func finaliseInitialisation() {
        guard onboardingDone else { return }
        refreshSeeds()
        initNavigation(dbname: databaseMediator.databaseName, seedNames: seedNames)
        totalRefresh()
    }
}

extension SignerDataModel {
    /// Restores the Signer to factory new state
    /// Should be called before app uninstall/upgrade!
    func wipe() {
        refreshSeeds()
        guard authenticated else { return }
        // remove secrets first
        let query = [
            kSecClass as String: kSecClassGenericPassword
        ] as CFDictionary
        SecItemDelete(query)
        // then everything else
        databaseMediator.wipeDatabase()
        onboardingDone = false
        seedNames = []
        initNavigation(dbname: databaseMediator.databaseName, seedNames: seedNames)
    }
}

extension SignerDataModel {
    /// Remove general verifier; wipes everything, obviously
    func jailbreak() {
        wipe()
        if !onboardingDone {
            onboard(jailbreak: true)
        }
    }
}
