//
//  ContentView.swift
//  NativeSigner
//
//  Created by Alexander Slesarev on 19.7.2021.
//

import SwiftUI

struct MainScreenContainer: View {
    @StateObject var data = SignerDataModel()
    @GestureState private var dragOffset = CGSize.zero
    var body: some View {
        if data.onboardingDone {
            if data.authenticated {
                VStack(spacing: 0) {
                    Header(
                        back: data.actionResult.back,
                        screenLabel: data.actionResult.screenLabel,
                        screenNameType: data.actionResult.screenNameType,
                        rightButton: data.actionResult.rightButton,
                        alert: data.alert,
                        canaryDead: data.canaryDead,
                        alertShow: { data.alertShow = true },
                        pushButton: { action, details, seedPhrase in data.pushButton(
                            action: action,
                            details: details,
                            seedPhrase: seedPhrase
                        ) }
                    )
                    ZStack {
                        VStack(spacing: 0) {
                            ScreenSelector(
                                screenData: data.actionResult.screenData,
                                appVersion: data.appVersion,
                                alert: data.alert,
                                pushButton: { action, details, seedPhrase in data.pushButton(
                                    action: action, details: details, seedPhrase: seedPhrase
                                ) },
                                getSeed: { seedName in data.getSeed(seedName: seedName) },
                                doJailbreak: data.jailbreak,
                                pathCheck: { seed, path, network in
                                    substratePathCheck(
                                        seedName: seed, path: path, network: network
                                    )
                                },
                                createAddress: { path, seedName in data.createAddress(path: path, seedName: seedName) },
                                checkSeedCollision: { seedName in data.checkSeedCollision(seedName: seedName) },
                                restoreSeed: { seedName, seedPhrase, createRoots in data.restoreSeed(
                                    seedName: seedName, seedPhrase: seedPhrase, createRoots: createRoots
                                ) },
                                sign: { seedName, comment in data.sign(seedName: seedName, comment: comment) },
                                doWipe: data.wipe,
                                alertShow: { data.alertShow = true },
                                increment: { seedName, _ in
                                    let seedPhrase = data.getSeed(seedName: seedName)
                                    if !seedPhrase.isEmpty {
                                        data.pushButton(action: .increment, details: "1", seedPhrase: seedPhrase)
                                    }
                                }
                            )
                            Spacer()
                        }
                        ModalSelector(
                            modalData: data.actionResult.modalData,
                            alert: data.alert,
                            alertShow: { data.alertShow = true },
                            pushButton: { action, details, seedPhrase in data.pushButton(
                                action: action, details: details, seedPhrase: seedPhrase
                            ) },
                            removeSeed: { seedName in data.removeSeed(seedName: seedName) },
                            restoreSeed: { seedName, seedPhrase, createSeedKeys in data.restoreSeed(
                                seedName: seedName, seedPhrase: seedPhrase, createRoots: createSeedKeys
                            ) },
                            createAddress: { path, seedName in data.createAddress(path: path, seedName: seedName) },
                            getSeedForBackup: { seedName in data.getSeed(seedName: seedName, backup: true) },
                            sign: { seedName, comment in data.sign(seedName: seedName, comment: comment) }
                        )
                        AlertSelector(
                            alertData: data.actionResult.alertData,
                            canaryDead: data.canaryDead,
                            resetAlert: data.resetAlert,
                            pushButton: { action, details, seedPhrase in data.pushButton(
                                action: action, details: details, seedPhrase: seedPhrase
                            ) }
                        )
                    }
                    .gesture(
                        DragGesture().updating($dragOffset, body: { value, _, _ in
                            if value.startLocation.x < 20, value.translation.width > 100 {
                                data.pushButton(action: .goBack)
                            }
                        })
                    )
                    // Certain places are better off without footer
                    if data.actionResult.footer {
                        Footer(
                            footerButton: data.actionResult.footerButton,
                            pushButton: { action, details, seedPhrase in data.pushButton(
                                action: action, details: details, seedPhrase: seedPhrase
                            ) }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Asset.bg000.swiftUIColor)
                    }
                }
                .gesture(
                    DragGesture().onEnded { drag in
                        if drag.translation.width < -20 {
                            data.pushButton(action: .goBack)
                        }
                    }
                )
                .alert("Navigation error", isPresented: $data.parsingAlert, actions: {})
            } else {
                Button(
                    action: { data.refreshSeeds() },
                    label: {
                        BigButton(
                            text: "Unlock app",
                            action: {
                                data.refreshSeeds()
                                data.totalRefresh()
                            }
                        )
                    }
                )
            }
        } else {
            if data.protected {
                if data.canaryDead /* || data.bsDetector.canaryDead)*/ {
                    Text(
                        "Please enable airplane mode, turn off bluetooth and wifi connection" +
                            " and disconnect all cables!"
                    ).background(Asset.bg000.swiftUIColor)
                } else {
                    LandingView(onboard: { data.onboard() })
                }
            } else {
                Text("Please protect device with pin or password!").background(Asset.bg000.swiftUIColor)
            }
        }
    }
}

// struct MainButtonScreen_Previews: PreviewProvider {
// static var previews: some View {
// MainScreenContainer()
// }
// }
