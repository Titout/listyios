import SwiftUI

// Clé pour l'environnement qui permet de communiquer avec MainTabView
struct TabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var tabSelection: Binding<Int> {
        get { self[TabSelectionKey.self] }
        set { self[TabSelectionKey.self] = newValue }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.tabSelection) private var tabSelection
    
    // État pour la sélection de liste et l'affichage de la vue détaillée
    @State private var selectedList: ListItem? = nil
    @State private var showDetailView = false
    @State private var showEditMenu = false
    @State private var selectedListForEdit: ListItem? = nil
    @State private var showRecommendations: Bool = false
    @State private var navigateToListView = false
    @State private var showNotifications = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Couleur de fond
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // En-tête avec message de bienvenue
                        welcomeSection()
                        
                        // Résumé hebdomadaire
                        weeklySummarySection()
                        
                        // Section des recommandations
                        recommendationsSection()
                        
                        // Section des listes
                        yourListsSection()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Bonjour \(viewModel.userName) 👋")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showDetailView) {
                if let list = selectedList {
                    DetailListView(list: list)
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }
    
    // MARK: - Sections
    private func welcomeSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bienvenue \(viewModel.userName)")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func weeklySummarySection() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Cette semaine")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
            
            HStack(spacing: 16) {
                // Budget total
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget total")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.2f", totalBudget)) €")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                
                // Nombre d'articles
                VStack(alignment: .leading, spacing: 8) {
                    Text("Articles")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("\(totalItems)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func recommendationsSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // En-tête de la section
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommandations")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
                
                Text("Vous aurez bientôt besoin de ça selon mon analyse")
                    .font(.system(size: 14))
                    .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
            }
            .padding(.bottom, 24)
            
            // Contenu des recommandations
            VStack(spacing: 16) {
                // Afficher les éléments recommandés
                ForEach(viewModel.recommendedItems.prefix(2)) { item in
                    ListItemRow(
                        image: item.image,
                        title: item.title,
                        quantity: item.quantity,
                        price: item.price,
                        isPurchased: false,
                        isInDetailView: false,
                        showShadow: false,
                        onAddButtonTap: {
                            // Action pour ajouter l'élément à une liste
                            print("Ajouter \(item.title) à la liste")
                        }
                    )
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Bouton "En voir plus"
                Button {
                    // Action pour voir plus
                    showRecommendations = true
                } label: {
                    Text("En voir plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func yourListsSection() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // En-tête de la section
            Text("Vos listes")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
            
            // Liste principale
            if !viewModel.lists.isEmpty {
                // Liste principale (première liste)
                listCard(list: viewModel.lists[0])
                
                // Liste secondaire (deuxième liste si disponible)
                if viewModel.lists.count > 1 {
                    listCard(list: viewModel.lists[1])
                }
            } else {
                Text("Aucune liste disponible")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // Carte pour chaque liste
    private func listCard(list: ListItem) -> some View {
        ListCardFactory(
            list: list,
            onTap: {
                selectedList = list
                showDetailView = true
            },
            onDelete: { deletedList in
                // Supprimer la liste de l'array
                Task {
                    await viewModel.deleteList(deletedList)
                }
            }
        )
    }
    
    // MARK: - Computed Properties
    private var totalBudget: Double {
        viewModel.lists.compactMap { $0.price }.reduce(0, +)
    }
    
    private var totalItems: Int {
        viewModel.lists.reduce(0) { $0 + $1.numberOfItems }
    }
} 
