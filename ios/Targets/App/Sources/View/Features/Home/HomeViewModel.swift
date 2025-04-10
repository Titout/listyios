import SwiftUI

// MARK: - ViewModel pour la HomeView
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var lists: [ListItem] = sampleLists
    @Published var recommendedItems: [RecommendedItem] = sampleRecommendedItems
    @Published var showNotifications: Bool = false
    @Published var userName: String = "Antoine"
    
    // Initialisation simple sans dépendances externes
    init() {
        // Charger les données initiales
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Public Methods
    func loadInitialData() async {
        // Pour l'instant, nous utilisons des données statiques
        // À remplacer par des appels API réels plus tard
        await loadRecommendations()
        await checkNotifications()
    }
    
    func loadRecommendations() async {
        // Utiliser les données statiques pour le moment
        recommendedItems = sampleRecommendedItems
    }
    
    func checkNotifications() async {
        // Simulation de vérification des notifications
        showNotifications = false
    }
    
    func deleteList(_ list: ListItem) async {
        // Simulation de suppression locale
        lists.removeAll { $0.id == list.id }
    }
} 