import SwiftUI
import Combine
import Foundation
import SharedKit // Pour accéder à Models.swift

// Énumération des différentes vues du menu d'actions
enum ActiveView {
    case main           // Vue principale du menu
    case addItem        // Vue d'ajout d'article
    case createList     // Vue de création de liste
    case instagram      // Vue d'import Instagram
    case scanList       // Vue de scan de liste
}

// Vue du menu d'actions conforme à la maquette Figma
struct ActionMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    // État pour gérer les sous-vues
    @State private var activeView: ActiveView = .main
    @State private var selectedCategory: ListCategory = .courses
    
    // États pour le formulaire d'ajout d'item
    @State private var itemName: String = ""
    @State private var itemPrice: String = ""
    @State private var itemQuantity: String = ""
    
    // États pour la gestion du clavier
    @State private var keyboardOffset: CGFloat = 0
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name, price, quantity
    }
    
    // États pour l'import Instagram
    @State private var instagramUrl: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var ingredients: [IngredientItem] = []
    @State private var importSuccess: Bool = false
    
    // États partagés avec les sous-vues
    @State private var selectedList: ListItem? = nil
    @State private var showListPicker = false
    
    // Callbacks externes
    var onNewList: () -> Void
    var onAddItem: () -> Void
    var onInstagramImport: () -> Void
    var onScanList: () -> Void
    var onShowCardShowcase: () -> Void
    
    var body: some View {
        ZStack {
            // Fond transparent pour voir l'arrière-plan
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Contenu principal
                VStack(spacing: 24) {
                    // Barre de fermeture
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 5)
                        .cornerRadius(2.5)
                    
                    if activeView == .main {
                        // Vue principale
                        // Titre avec espacement supplémentaire
                        Text("Que voulez vous faire ?")
                            .font(.system(size: 28, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)
                            .padding(.horizontal)
                        
                        // Boutons d'action avec style mis à jour
                        VStack(spacing: 16) {
                            ActionButton(
                                title: "Nouvelle liste",
                                action: {
                                    activeView = .createList
                                }
                            )
                            
                            ActionButton(
                                title: "Importer une recette de Instagram",
                                action: {
                                    activeView = .instagram
                                }
                            )
                            
                            ActionButton(
                                title: "Scanner une liste",
                                action: {
                                    activeView = .scanList
                                }
                            )
                            
                            ActionButton(
                                title: "Ajouter un produit à acheter",
                                action: {
                                    activeView = .addItem
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                    } else if activeView == .addItem {
                        // Vue d'ajout d'article
                        VStack(spacing: 20) {
                            Text("Ajouter un produit")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Formulaire d'ajout d'article
                            VStack(spacing: 16) {
                                TextField("Nom du produit", text: $itemName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .name)
                                
                                TextField("Prix (optionnel)", text: $itemPrice)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .price)
                                
                                TextField("Quantité (optionnel)", text: $itemQuantity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .quantity)
                            }
                            .padding(.horizontal, 24)
                            
                            // Boutons d'action
                            HStack(spacing: 16) {
                                Button("Annuler") {
                                    activeView = .main
                                }
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                                
                                Button("Ajouter") {
                                    // Logique d'ajout
                                    onAddItem()
                                    isPresented = false
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                        }
                    } else if activeView == .createList {
                        // Vue de création de liste
                        VStack(spacing: 20) {
                            Text("Créer une nouvelle liste")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Formulaire de création de liste
                            TextField("Nom de la liste", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 24)
                            
                            // Boutons d'action
                            HStack(spacing: 16) {
                                Button("Annuler") {
                                    activeView = .main
                                }
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                                
                                Button("Créer") {
                                    // Logique de création
                                    onNewList()
                                    isPresented = false
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                        }
                    } else if activeView == .instagram {
                        // Vue d'import Instagram
                        VStack(spacing: 20) {
                            Text("Importer depuis Instagram")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Champ URL Instagram
                            TextField("URL Instagram", text: $instagramUrl)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 24)
                            
                            // Boutons d'action
                            HStack(spacing: 16) {
                                Button("Annuler") {
                                    activeView = .main
                                }
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                                
                                Button("Importer") {
                                    // Logique d'import
                                    onInstagramImport()
                                    isPresented = false
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                        }
                    } else if activeView == .scanList {
                        // Vue de scan
                        VStack(spacing: 20) {
                            Text("Scanner une liste")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Boutons d'action
                            HStack(spacing: 16) {
                                Button("Annuler") {
                                    activeView = .main
                                }
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                                
                                Button("Scanner") {
                                    // Logique de scan
                                    onScanList()
                                    isPresented = false
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 48)
                .frame(maxWidth: .infinity)
                .background(
                    Color(.systemBackground)
                        .opacity(0.95)
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                )
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.height > 50 {
                                if activeView != .main {
                                    activeView = .main
                                } else {
                                    isPresented = false
                                }
                            }
                        }
                )
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            // Réinitialiser à la vue principale à chaque ouverture
            activeView = .main
        }
    }
}

struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.black)
                .cornerRadius(12)
        }
    }
}

// Extension pour appliquer le cornerRadius uniquement sur certains coins
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
} 
