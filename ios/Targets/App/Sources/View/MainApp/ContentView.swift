//
//  ContentView.swift
//  App (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/app
//

import AIKit
import FirebaseKit
import InAppPurchaseKit
import NotifKit
import SharedKit
import SwiftUI

struct ContentView: View {
	@EnvironmentObject var db: DB
	@EnvironmentObject var iap: InAppPurchases
	
	@State private var selectedTab = 0
	@State private var showActionMenu = false
	@State private var showDeveloperView = false // Nouvel état pour la vue développeur
	
	init() { }
	
	var body: some View {
		ZStack {
			TabView(selection: $selectedTab) {
				// Vue d'accueil principale
				HomeView()
					.tabItem {
						Label("Accueil", systemImage: "house")
					}
					.tag(0)
					.environment(\.tabSelection, $selectedTab)

				// Vue des listes
				ListView()
					.tabItem {
						Label("Listes", systemImage: "list.bullet")
					}
					.tag(1)
					.environment(\.tabSelection, $selectedTab)
				
				// Vue d'ajout de liste (remplacée par un bouton qui ouvre la modale)
				Color.clear
					.tabItem {
						Label("Ajouter", systemImage: "plus.circle.fill")
					}
					.tag(2)
					.onAppear {
						if selectedTab == 2 {
							showActionMenu = true
							selectedTab = max(0, selectedTab - 1)
						}
					}
				
				// Vue des statistiques
				StatsView()
					.tabItem {
						Label("Statistiques", systemImage: "chart.bar.fill")
					}
					.tag(3)
					.environment(\.tabSelection, $selectedTab)
				
				// Vue des réglages
				SettingsView()
					.tabItem {
						Label("Réglages", systemImage: "gear")
					}
					.tag(4)
					.environment(\.tabSelection, $selectedTab)
			}
			
			// Bouton flottant pour accéder à la vue développeur en mode DEBUG
			#if DEBUG
			VStack {
				HStack {
					Spacer()
					Button(action: {
						showDeveloperView = true
					}) {
						Image(systemName: "hammer.circle.fill")
							.font(.system(size: 44))
							.foregroundColor(.blue)
							.padding()
							.background(Color.white.opacity(0.8))
							.clipShape(Circle())
							.shadow(radius: 3)
					}
					.padding(.trailing, 16)
				}
				.padding(.top, 50) // Ajout d'un padding en haut pour éviter le notch/status bar
				Spacer()
			}
			#endif
		}
		.sheet(isPresented: $showActionMenu) {
			ActionMenuView(
				isPresented: $showActionMenu,
				onNewList: {
					print("Nouvelle liste créée")
				},
				onAddItem: {
					print("Nouvel item ajouté")
				},
				onInstagramImport: {
					print("Import Instagram effectué")
				},
				onScanList: {
					print("Scan de liste effectué")
				},
				onShowCardShowcase: {
					print("Showcase de cartes affiché")
				}
			)
		}
		#if DEBUG
		.sheet(isPresented: $showDeveloperView) {
			DeveloperSettingsView()
		}
		#endif
	}
}

#Preview {
	ContentView()
		.environmentObject(DB())
		.environmentObject(InAppPurchases())
}
