import SwiftUI

struct ListView: View {
    @State private var searchText = ""
    @State private var lists: [ListItem] = []
    @State private var selectedList: ListItem? = nil
    @State private var showDetailView = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Couleur de fond
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Barre de recherche
                    searchBar
                    
                    // En-tête avec le budget total
                    budgetSection
                    
                    if filteredLists.isEmpty {
                        // Message si aucune liste n'est trouvée
                        VStack(spacing: 16) {
                            Spacer()
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("Aucune liste trouvée")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Essayez de modifier votre recherche")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .padding(.bottom, 100) // Espace pour la TabBar
                    } else {
                        // Liste des listes de courses
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(filteredLists) { list in
                                    ListCardFactory(
                                        list: list,
                                        onTap: {
                                            // Montrer l'indicateur de chargement et initialiser la transition
                                            isLoading = true
                                            selectedList = list
                                            
                                            // Court délai pour permettre à l'animation de commencer
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                showDetailView = true
                                                // Réinitialiser le chargement après un délai
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    isLoading = false
                                                }
                                            }
                                        },
                                        onDelete: { deletedList in
                                            // Supprimer la liste de l'array
                                            lists.removeAll { $0.id == deletedList.id }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 100) // Espace pour la TabBar
                        }
                    }
                }
                .padding(.top, 8)
                
                // Overlay de chargement
                if isLoading {
                    LoadingView()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .sheet(isPresented: $showDetailView, onDismiss: {
                // Mise à jour de la liste après fermeture de la vue détaillée
                if let updatedList = selectedList {
                    updateList(updatedList)
                }
                selectedList = nil
            }) {
                if let list = selectedList {
                    DetailListView(list: list)
                        .onDisappear {
                            // Assurons-nous que la liste sélectionnée est mise à jour avec les dernières modifications
                            if let index = lists.firstIndex(where: { $0.id == list.id }) {
                                selectedList = lists[index]
                            }
                        }
                }
            }
        }
        .onAppear {
            // Charger les listes au démarrage
            loadInitialLists()
        }
    }
    
    // Charger les listes initiales
    private func loadInitialLists() {
        // Pour le prototype, nous utilisons des données statiques
        // Ici, vous pourriez charger les données depuis un service ou une API
        lists = [
            ListItem(title: "Courses maison", icon: "house", numberOfItems: 12, price: 45.99, color: .blue),
            ListItem(title: "Courses enfants", icon: "person.2", numberOfItems: 8, price: 34.50, color: .orange),
            ListItem(title: "Courses de la semaine", icon: "cart", numberOfItems: 15, price: 62.75, color: .green),
            ListItem(title: "Soirée pizza", icon: "fork.knife", numberOfItems: 6, price: 25.30, color: .red)
        ]
    }
    
    // Mettre à jour une liste dans l'array des listes
    private func updateList(_ updatedList: ListItem) {
        if let index = lists.firstIndex(where: { $0.id == updatedList.id }) {
            lists[index] = updatedList
        }
    }
    
    // MARK: - Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(UIColor.systemGray2))
                .padding(.leading, 12)
            
            TextField("Rechercher une liste...", text: $searchText)
                .padding(10)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(UIColor.systemGray3))
                }
                .padding(.trailing, 12)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Section budget total
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget total de la semaine")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("\(String(format: "%.2f", totalBudget)) €")
                        .font(.system(size: 22, weight: .bold))
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
                    Text("Articles")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(lists.count)")
                        .font(.system(size: 16, weight: .bold))
                    Text("Listes")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 2)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // Calcul du budget total
    private var totalBudget: Double {
        lists.compactMap { $0.price }.reduce(0, +)
    }
    
    // Nombre d'articles estimé (fictif pour la démo)
    private var totalItems: Int {
        // Estimation: 5 articles par liste en moyenne
        return lists.count * 5
    }
    
    // Filtrer les listes selon la recherche
    private var filteredLists: [ListItem] {
        if searchText.isEmpty {
            return lists
        } else {
            return lists.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Tri des listes par date
    private func sortListsByDate() {
        lists.sort { ($0.date > $1.date) }
    }
    
    // Tri des listes par ordre alphabétique
    private func sortListsAlphabetically() {
        lists.sort { $0.title < $1.title }
    }
}

// Composant de chargement
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
                .padding(24)
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
        }
    }
}

#Preview {
    ListView()
} 