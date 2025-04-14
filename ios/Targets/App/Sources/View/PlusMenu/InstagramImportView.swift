import SwiftUI
import SharedKit // Pour ListItemDetail

struct InstagramImportView: View {
    @Environment(\.dismiss) private var dismiss
    
    // États pour les champs du formulaire
    @State private var instagramUrl: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var ingredients: [ListItemDetail] = []
    @State private var importSuccess: Bool = false
    @State private var selectedList: UUID? = nil
    @State private var showListPicker: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Champ URL Instagram
                TextField("URL de la recette Instagram", text: $instagramUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Bouton d'import
                Button(action: {
                    importFromInstagram()
                }) {
                    Text("Importer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if !ingredients.isEmpty {
                    // Liste des ingrédients importés
                    List(ingredients) { ingredient in
                        ListItemRow(
                            title: ingredient.name,
                            quantity: ingredient.quantity ?? "",
                            price: ingredient.price != nil ? String(format: "%.2f €", ingredient.price!) : "",
                            image: nil,
                            isPurchased: ingredient.isCompleted,
                            isInDetailView: false,
                            showShadow: true
                        )
                    }
                    
                    // Bouton pour ajouter à une liste
                    Button(action: {
                        showListPicker = true
                    }) {
                        Text(selectedList == nil ? "Ajouter à une liste" : "Changer de liste")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if selectedList != nil {
                        Button(action: {
                            addIngredientsToList()
                        }) {
                            Text("Confirmer l'ajout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Recette Instagram")
            .navigationBarItems(leading: Button("Annuler") {
                dismiss()
            })
        }
        .sheet(isPresented: $showListPicker) {
            ListPickerView(selectedList: $selectedList)
        }
    }
    
    private func importFromInstagram() {
        isLoading = true
        errorMessage = nil
        
        // Simuler un délai réseau
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if instagramUrl.isEmpty {
                errorMessage = "Veuillez entrer une URL valide"
            } else {
                // Simuler des ingrédients importés
                ingredients = [
                    ListItemDetail(name: "Farine", price: nil, isCompleted: false, quantity: "500g", image: nil),
                    ListItemDetail(name: "Oeufs", price: nil, isCompleted: false, quantity: "3", image: nil),
                    ListItemDetail(name: "Lait", price: nil, isCompleted: false, quantity: "25cl", image: nil)
                ]
            }
            isLoading = false
        }
    }
    
    private func addIngredientsToList() {
        guard let listId = selectedList else { return }
        // TODO: Implémenter l'ajout des ingrédients à la liste sélectionnée
        importSuccess = true
        dismiss()
    }
}

#Preview {
    InstagramImportView()
} 
