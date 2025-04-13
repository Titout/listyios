import SwiftUI
import Foundation
import SharedKit // Pour accéder à ListItemDetail
// Pour accéder au composant ListItemRow
import UIKit // Pour UIColor

// ViewModel pour centraliser la logique de liste et le calcul du budget
class ListViewModel: ObservableObject {
    @Published var checkedItems: [ListItemDetail] = []
    @Published var uncheckedItems: [ListItemDetail] = []
    @Published var list: ListItem
    
    // État pour suivre l'animation en cours
    @Published var itemBeingToggled: UUID? = nil
    @Published var animateStrikethrough = false
    
    init(list: ListItem) {
        self.list = list
        
        // Données de test
        if uncheckedItems.isEmpty {
            populateTestData()
        }
    }
    
    // Données fictives pour tester le comportement
    private func populateTestData() {
        // Articles non cochés
        uncheckedItems = [
            ListItemDetail(name: "Bananes", price: 2.99, isCompleted: false, quantity: "1 kg", image: nil),
            ListItemDetail(name: "Lait Entier", price: 1.59, isCompleted: false, quantity: "1 L", image: nil),
            ListItemDetail(name: "Pain aux céréales", price: 2.20, isCompleted: false, quantity: "400g", image: nil),
            ListItemDetail(name: "Yaourt nature", price: 3.50, isCompleted: false, quantity: "Pack de 6", image: nil),
            ListItemDetail(name: "Pommes Gala", price: 4.20, isCompleted: false, quantity: "1.5 kg", image: nil)
        ]
        
        // Articles déjà cochés
        checkedItems = [
            ListItemDetail(name: "Oeufs bio", price: 3.80, isCompleted: true, quantity: "Boîte de 6", image: nil),
            ListItemDetail(name: "Fromage blanc", price: 1.99, isCompleted: true, quantity: "500g", image: nil)
        ]
        
        // Mise à jour du budget total
        updateListBudget()
    }
    
    // Calcule le montant total des items de la liste
    var totalBudget: Double {
        let checkedTotal = checkedItems.compactMap { $0.price }.reduce(0, +)
        let uncheckedTotal = uncheckedItems.compactMap { $0.price }.reduce(0, +)
        return checkedTotal + uncheckedTotal
    }
    
    // Ajouter un nouvel article à la liste
    func addItem(_ item: ListItemDetail) {
        if item.isCompleted {
            checkedItems.append(item)
        } else {
            uncheckedItems.append(item)
        }
        updateListBudget()
    }
    
    // Mettre à jour le budget total de la liste
    func updateListBudget() {
        list.price = totalBudget
    }
}

struct DetailListView: View {
    let list: ListItem
    @StateObject private var viewModel: ListViewModel
    @Environment(\.dismiss) private var dismiss
    
    // États pour gérer l'ajout d'un nouvel article
    @State private var showAddItemSheet = false
    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    @State private var newItemPrice = ""
    
    init(list: ListItem) {
        self.list = list
        _viewModel = StateObject(wrappedValue: ListViewModel(list: list))
    }
    
    var body: some View {
        NavigationView {
            List {
                // Récapitulatif du budget
                Section(header: Text("Récapitulatif")) {
                    HStack {
                        Text("Budget total")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f €", viewModel.totalBudget))
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Articles à acheter")
                        Spacer()
                        Text("\(viewModel.uncheckedItems.count)")
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("Articles achetés")
                        Spacer()
                        Text("\(viewModel.checkedItems.count)")
                            .foregroundColor(.green)
                    }
                }
                
                // Section des articles non cochés
                Section(header: Text("À acheter")) {
                    if viewModel.uncheckedItems.isEmpty {
                        Text("Aucun article à acheter")
                            .italic()
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.uncheckedItems) { item in
                            ListItemRow(
                                item: item,
                                isInDetailView: true,
                                onAddButtonTap: {
                                    withAnimation {
                                        viewModel.itemBeingToggled = item.id
                                        viewModel.animateStrikethrough = true
                                        // Déplacer l'item vers la liste des items cochés
                                        if let index = viewModel.uncheckedItems.firstIndex(where: { $0.id == item.id }) {
                                            var toggledItem = viewModel.uncheckedItems.remove(at: index)
                                            toggledItem.isCompleted = true
                                            viewModel.checkedItems.append(toggledItem)
                                            viewModel.updateListBudget()
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                
                // Section des articles cochés
                if !viewModel.checkedItems.isEmpty {
                    Section(header: Text("Achetés")) {
                        ForEach(viewModel.checkedItems) { item in
                            ListItemRow(
                                item: item,
                                isInDetailView: true,
                                onAddButtonTap: {
                                    withAnimation {
                                        viewModel.itemBeingToggled = item.id
                                        viewModel.animateStrikethrough = false
                                        // Déplacer l'item vers la liste des items non cochés
                                        if let index = viewModel.checkedItems.firstIndex(where: { $0.id == item.id }) {
                                            var toggledItem = viewModel.checkedItems.remove(at: index)
                                            toggledItem.isCompleted = false
                                            viewModel.uncheckedItems.append(toggledItem)
                                            viewModel.updateListBudget()
                                        }
                                    }
                                }
                            )
                        }
                    }
                } else {
                    Section(header: Text("Achetés")) {
                        Text("Aucun article acheté")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(list.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddItemSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddItemSheet) {
                addItemView
                    .interactiveDismissDisabled(false)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // Vue pour ajouter un nouvel article
    private var addItemView: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations de l'article")) {
                    TextField("Nom", text: $newItemName)
                    TextField("Quantité", text: $newItemQuantity)
                    TextField("Prix (€)", text: $newItemPrice)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Nouvel article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        showAddItemSheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        addNewItem()
                        showAddItemSheet = false
                    }
                    .disabled(newItemName.isEmpty)
                }
            }
        }
    }
    
    // Fonction pour ajouter un nouvel article à la liste
    private func addNewItem() {
        let price = Double(newItemPrice.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        let newItem = ListItemDetail(
            name: newItemName,
            price: price > 0 ? price : nil,
            isCompleted: false,
            quantity: newItemQuantity.isEmpty ? nil : newItemQuantity,
            image: nil
        )
        
        viewModel.addItem(newItem)
        
        // Réinitialiser les champs
        newItemName = ""
        newItemQuantity = ""
        newItemPrice = ""
    }
} 