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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1))
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        welcomeSection()
                        weekSummaryCard()
                        categoryBreakdownSection()
                        
                        if showRecommendations {
                            recommendationsSection()
                        }
                        
                        yourListsSection()
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                }
                
                NavigationLink(destination: SimpleListView(), isActive: $navigateToListView) {
                    EmptyView()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Bienvenue \(viewModel.userName)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 12)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showNotifications = true
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(.top, 12)
                    }
                }
            }
            .sheet(isPresented: $showDetailView) {
                if let list = selectedList {
                    DetailListView(list: list)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $viewModel.showNotifications) {
                NotificationsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .task {
                await viewModel.loadInitialData()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Calcul du budget total
    private var totalBudget: Double {
        viewModel.lists.compactMap { $0.price }.reduce(0, +)
    }
    
    private var totalItems: Int {
        viewModel.lists.count * 5
    }
    
    // MARK: - Sections
    @ViewBuilder
    private func welcomeSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Qu'est-ce qu'on achète aujourd'hui ?")
                .font(.system(size: 16))
                .foregroundColor(Color(UIColor.systemGray))
                .padding(.top, 12)
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func weekSummaryCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cette semaine")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Budget: \(String(format: "%.2f", totalBudget)) €")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Image(systemName: "cart")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 48, height: 48)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(12)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalItems)")
                        .font(.system(size: 16, weight: .bold))
                    Text("Items")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.lists.count)")
                        .font(.system(size: 16, weight: .bold))
                    Text("Listes")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button {
                // Basculer vers l'onglet ListView (index 1)
                tabSelection.wrappedValue = 1
            } label: {
                Text("Voir mes listes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func categoryBreakdownSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top catégories")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))
            
            VStack(spacing: 12) {
                ForEach(weeklyCategoryExpenses, id: \.0) { category, value, color in
                    HStack {
                        HStack(spacing: 4) {
                            Circle().fill(color).frame(width: 12, height: 12)
                            Text(category)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "000000", alpha: 0.7))
                        }
                        Spacer()
                        Text("\(String(format: "%.2f", value))€")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "000000", alpha: 0.7))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    @ViewBuilder
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
    
    @ViewBuilder
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
    @ViewBuilder
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
} 
