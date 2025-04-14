import SwiftUI
import Combine
import SharedKit // Pour ListItemDetail
import UIKit

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    // États pour les champs du formulaire
    @State private var itemName: String = ""
    @State private var itemPrice: String = ""
    @State private var itemQuantity: String = ""
    @State private var itemUnit: String = ""
    @State private var selectedList: UUID? = nil
    @State private var selectedStore: String? = nil
    
    // Pour afficher le sélecteur de liste
    @State private var showListPicker: Bool = false
    
    // État pour gérer l'offset de la vue lorsque le clavier est visible
    @State private var keyboardOffset: CGFloat = 0
    @State private var keyboardVisible: Bool = false
    @FocusState private var focusedField: Field?
    
    // Hauteur de l'écran pour calculer un meilleur offset
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    private enum Field {
        case name, price, quantity, unit
    }
    
    var onDismiss: (() -> Void)?
    var onAddItem: ((ListItemDetail) -> Void)?
    
    var body: some View {
        ZStack {
            // Fond semi-transparent pour masquer le contenu en dessous
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismiss()
                }
            
            // Modal content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    // Indicateur de pilule pour fermer la modale
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .cornerRadius(2.5)
                        .padding(.top, 16)
                    
                    // Titre aligné à gauche comme dans Figma
                    Text("Ajouter un article")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Corps du formulaire
                    if keyboardVisible {
                        // Vue quand le clavier est visible - formulaire condensé
                        VStack(spacing: 12) {
                            // Nom de l'article uniquement visible
                            formField(title: "Nom de l'article", text: $itemName, keyboardType: .default, field: .name)
                            
                            // Prix (visible si focus sur prix)
                            if focusedField == .price {
                                formField(title: "Prix", text: $itemPrice, keyboardType: .decimalPad, field: .price, suffix: "€")
                            }
                            
                            // Quantité (visible si focus sur quantité/unité)
                            if focusedField == .quantity || focusedField == .unit {
                                HStack(spacing: 12) {
                                    formField(title: "Quantité", text: $itemQuantity, keyboardType: .default, field: .quantity)
                                        .frame(maxWidth: .infinity)
                                    
                                    formField(title: "Unité", text: $itemUnit, keyboardType: .default, field: .unit)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            // Liste sélectionnée (toujours visible)
                            listSelector()
                        }
                    } else {
                        // Vue complète quand le clavier n'est pas visible - comme dans Figma
                        VStack(spacing: 12) {
                            // Nom de l'article
                            formField(title: "Nom de l'article", text: $itemName, keyboardType: .default, field: .name)
                            
                            // Prix de l'article
                            formField(title: "Prix", text: $itemPrice, keyboardType: .decimalPad, field: .price, suffix: "€")
                            
                            // Quantité/unité sur la même ligne
                            HStack(spacing: 12) {
                                formField(title: "Quantité", text: $itemQuantity, keyboardType: .default, field: .quantity)
                                    .frame(maxWidth: .infinity)
                                
                                formField(title: "Unité", text: $itemUnit, keyboardType: .default, field: .unit)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Magasin
                            storeSelector()
                            
                            // Liste
                            listSelector()
                        }
                    }
                    
                    // Bouton d'ajout
                    Button(action: {
                        addItem()
                    }) {
                        Text("Ajouter")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .disabled(itemName.isEmpty || selectedList == nil)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, keyboardVisible ? 16 : 24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: -keyboardOffset)
                .animation(
                    .spring(
                        response: 0.3,
                        dampingFraction: 0.8,
                        blendDuration: 0
                    ),
                    value: keyboardOffset
                )
                .animation(
                    .spring(
                        response: 0.3,
                        dampingFraction: 0.8,
                        blendDuration: 0
                    ),
                    value: keyboardVisible
                )
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.height > 20 {
                                dismiss()
                            }
                        }
                )
            }
        }
        .sheet(isPresented: $showListPicker) {
            ListPickerView(selectedList: $selectedList)
        }
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Terminé") {
                    focusedField = nil
                }
            }
        }
    }
    
    // Composants d'UI réutilisables
    
    private func formField(title: String, text: Binding<String>, keyboardType: UIKeyboardType, field: Field?, suffix: String? = nil) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            if let field = field {
                TextField("", text: text)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: field)
            } else {
                TextField("", text: text)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
            }
            
            if let suffix = suffix {
                Text(suffix)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private func storeSelector() -> some View {
        Button(action: {
            // Action pour sélectionner un magasin (simulé)
            focusedField = nil
        }) {
            HStack {
                Text("Magasin")
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let store = selectedStore {
                    Text(store)
                        .foregroundColor(.black)
                } else {
                    Text("Sélectionner")
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
    
    private func listSelector() -> some View {
        Button(action: {
            focusedField = nil
            showListPicker = true
        }) {
            HStack {
                Text("Liste")
                    .foregroundColor(.gray)
                
                Spacer()
                
                if selectedList != nil {
                    // On va simplement afficher "Liste sélectionnée"
                    // car on n'a plus l'objet ListItem mais seulement l'UUID
                    Text("Liste sélectionnée")
                        .foregroundColor(.black)
                } else {
                    Text("Sélectionner")
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
    
    private func addItem() {
        // Convertir le prix en Double
        let price = Double(itemPrice.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        // Formater la quantité avec l'unité si présente
        var quantityText = itemQuantity
        if !itemUnit.isEmpty {
            quantityText += " \(itemUnit)"
        }
        
        // Créer un nouvel élément
        let newItem = ListItemDetail(
            name: itemName,
            price: price > 0 ? price : nil,
            isCompleted: false,
            quantity: quantityText.isEmpty ? nil : quantityText, 
            image: nil
        )
        
        // Appeler le callback
        onAddItem?(newItem)
        
        // Fermer la vue
        dismiss()
    }
    
    // Fonction pour configurer les observateurs du clavier
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            let keyboardHeight = keyboardFrame.height
            
            // Marquer le clavier comme visible
            withAnimation {
                self.keyboardVisible = true
            }
            
            // Calculer l'offset selon le champ actif
            var offsetFactor: CGFloat = 0
            
            switch focusedField {
            case .name:
                offsetFactor = 0.5
            case .price:
                offsetFactor = 0.6
            case .quantity, .unit:
                offsetFactor = 0.7
            case nil:
                offsetFactor = 0.5
            }
            
            // Ajuster en fonction de la taille de l'écran
            let screenRatio = keyboardHeight / screenHeight
            let baseOffset = screenRatio < 0.4 ? keyboardHeight * 0.8 : keyboardHeight * 0.95
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                self.keyboardOffset = baseOffset * offsetFactor
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Réinitialiser l'offset quand le clavier se cache
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                self.keyboardOffset = 0
                self.keyboardVisible = false
            }
        }
    }
    
    // Fonction pour supprimer les observateurs du clavier
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

#Preview {
    AddItemView(onDismiss: {})
} 
