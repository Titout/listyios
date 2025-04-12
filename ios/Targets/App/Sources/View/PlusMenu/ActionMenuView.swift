import SwiftUI
import Combine

// Vue du menu d'actions conforme à la maquette Figma
struct ActionMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    // État pour gérer les sous-vues
    @State private var activeView: ActiveView = .main
    
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
    
    // Énumération des vues actives
    enum ActiveView {
        case main
        case addList
        case addItem
        case instagramImport
        case scanList
        case cardShowcase
    }
    
    var body: some View {
        // Structure avec un seul ZStack et un seul fond opacifiant
        ZStack {
            // Fond semi-transparent (unique et partagé par toutes les vues)
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    dismissActiveView()
                }
            
            // Container pour le contenu actif
            VStack(spacing: 0) {
                Spacer() // Pour pousser le contenu vers le bas
                
                // Contenu variable selon l'état actif
                contentForActiveView()
                    .padding(.horizontal, 24)
                    .background(Color.white)
                    .customCornerRadius(20, corners: [.topLeft, .topRight])
                    .transition(.move(edge: .bottom))
                    .offset(y: activeView == .addItem ? -keyboardOffset : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: keyboardOffset)
                    .onTapGesture {
                        // Désactiver le clavier lorsqu'on tape sur le fond
                        if activeView == .addItem {
                            focusedField = nil
                        }
                    }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 20 {
                        dismissActiveView()
                    }
                }
        )
        .sheet(isPresented: $showListPicker) {
            ListPickerView(selectedList: $selectedList, onDismiss: {
                showListPicker = false
            })
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
    
    // Détermine le contenu à afficher selon l'état actif
    @ViewBuilder
    private func contentForActiveView() -> some View {
        switch activeView {
        case .main:
            mainMenu()
        case .addList:
            addListContent()
        case .addItem:
            addItemContent()
                .onAppear {
                    // Petite pause pour laisser l'animation de la modale se terminer avant de focaliser le champ
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        focusedField = .name
                    }
                }
        case .instagramImport:
            instagramImportContent()
        case .scanList:
            scanListContent()
        case .cardShowcase:
            cardShowcaseContent()
        }
    }
    
    // Menu principal d'actions
    private func mainMenu() -> some View {
                    VStack(spacing: 16) {
                        // Indicateur de pilule
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                            .cornerRadius(2.5)
                            .padding(.top, 16)
                        
                        // Boutons d'action
                        ActionButton(title: "Nouvelle liste", action: {
                            withAnimation(.spring()) {
                    activeView = .addList
                            }
                        })
                        
                        ActionButton(title: "Importer une recette de Instagram", action: {
                            withAnimation(.spring()) {
                    activeView = .instagramImport
                            }
                        })
                        
                        ActionButton(title: "Scanner une liste", action: {
                            withAnimation(.spring()) {
                    activeView = .scanList
                            }
                        })
                        
                        ActionButton(title: "Ajouter un produit à acheter", action: {
                            withAnimation(.spring()) {
                    activeView = .addItem
                }
            })
        }
        .padding(.bottom, 48)
    }
    
    // Contenu pour l'ajout de liste
    private func addListContent() -> some View {
            VStack(spacing: 16) {
            // Indicateur de pilule
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 16)
                
            // Titre
                Text("Nouvelle liste")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Section Catégorie
                VStack(alignment: .leading, spacing: 8) {
                    Text("SÉLECTIONNEZ UNE CATÉGORIE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    // Menu de sélection de catégorie
                    HStack {
                        Text("Catégorie")
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Picker("", selection: .constant(ListCategory.courses)) {
                            ForEach(ListCategory.allCases) { category in
                                HStack {
                                    category.imageView(size: 20)
                                    Text(category.rawValue)
                                }.tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(.black)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                
            // Texte informatif
                Text("Lorsque vous créerez cette liste, vous pourrez générer un lien de partage pour inviter des collaborateurs.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                
                // Bouton de création
                Button(action: {
                    // Créer une nouvelle liste (simulation)
                    let newList = ListItem(
                        title: ListCategory.courses.rawValue,
                        image: ListCategory.courses.imageName,
                        price: 0.0,
                        members: ["Utilisateur actuel"],
                        date: Date(),
                        category: ListCategory.courses.rawValue
                    )
                onNewList()
                withAnimation(.spring()) {
                    activeView = .main
                }
                }) {
                    Text("Créer la liste")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.bottom, 32)
        }
    }
    
    // Contenu pour l'ajout d'item - Amélioré avec gestion du clavier
    private func addItemContent() -> some View {
        VStack(spacing: 16) {
            // Indicateur de pilule
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 16)
                .onTapGesture {
                    focusedField = nil
                }
            
            // Titre
            Text("Ajouter un article")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Section Détails
            VStack(alignment: .leading, spacing: 8) {
                Text("DÉTAILS DE L'ARTICLE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                // Nom de l'article
                HStack {
                    Text("Nom")
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    TextField("Nom de l'article", text: $itemName)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .name)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
                
                // Prix de l'article
                HStack {
                    Text("Prix")
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    TextField("0.00", text: $itemPrice)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .price)
                    
                    Text("€")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
                
                // Quantité de l'article
                HStack {
                    Text("Quantité")
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    TextField("ex: 500g, 2L, x6", text: $itemQuantity)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .quantity)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
            }
            
            // Section Liste
            VStack(alignment: .leading, spacing: 8) {
                Text("SÉLECTIONNEZ UNE LISTE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                Button(action: {
                    focusedField = nil
                    showListPicker = true
                }) {
                    HStack {
                        Text("Liste")
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        if let list = selectedList {
                            HStack {
                                if let category = list.category, let listCategory = ListCategory(rawValue: category) {
                                    Image(systemName: listCategory.systemIconName)
                                        .foregroundColor(.black)
                                }
                                Text(list.title)
                                    .foregroundColor(.black)
                            }
                        } else {
                            Text("Sélectionner")
                                .foregroundColor(.gray)
                        }
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(10)
                }
            }
            
            // Texte informatif
            Text("L'article sera ajouté à la liste sélectionnée et pourra être modifié ultérieurement.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
            
            // Bouton d'ajout
            Button(action: {
                addItem()
            }) {
                Text("Ajouter l'article")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        (itemName.isEmpty || selectedList == nil) ? Color.gray : Color.black
                    )
                    .cornerRadius(10)
            }
            .disabled(itemName.isEmpty || selectedList == nil)
            .padding(.bottom, 32)
        }
    }
    
    // Contenu pour l'import Instagram
    private func instagramImportContent() -> some View {
        VStack(spacing: 16) {
            // Indicateur de pilule
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 16)
            
            // Titre
            Text("Importer une recette")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !importSuccess {
                // Contenu si pas encore importé
                VStack(alignment: .leading, spacing: 8) {
                    Text("LIEN INSTAGRAM")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    // Champ URL Instagram
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        TextField("https://www.instagram.com/reel/...", text: $instagramUrl)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            .background(Color.white)
                    .cornerRadius(10)
                    
                    // Message d'erreur
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                
                // Texte informatif
                Text("Collez l'URL d'un Reel Instagram contenant une recette pour en extraire les ingrédients automatiquement.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                
                // Bouton d'analyse
                Button(action: {
                    analyzeRecipe()
                }) {
                    ZStack {
                        Text("Analyser la recette")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .opacity(isLoading ? 0 : 1)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(instagramUrl.isEmpty ? Color.gray : Color.black)
                    .cornerRadius(10)
                }
                .disabled(instagramUrl.isEmpty || isLoading)
                .padding(.bottom, 32)
            } else {
                // Contenu après import réussi
                VStack(alignment: .leading, spacing: 8) {
                    Text("INGRÉDIENTS DÉTECTÉS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(0..<ingredients.count, id: \.self) { index in
                                IngredientRow(ingredient: $ingredients[index])
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .frame(height: 200)
                }
                
                // Section Liste
                VStack(alignment: .leading, spacing: 8) {
                    Text("SÉLECTIONNEZ UNE LISTE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showListPicker = true
                    }) {
                        HStack {
                            Text("Liste")
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if let list = selectedList {
                                HStack {
                                    if let category = list.category, let listCategory = ListCategory(rawValue: category) {
                                        Image(systemName: listCategory.systemIconName)
                                            .foregroundColor(.black)
                                    }
                                    Text(list.title)
                                        .foregroundColor(.black)
                                }
                            } else {
                                Text("Sélectionner")
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
                
                // Texte informatif
                Text("Les ingrédients seront ajoutés à la liste sélectionnée comme articles à acheter.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                
                // Bouton de création de liste
                Button(action: {
                    onInstagramImport()
                    withAnimation(.spring()) {
                        activeView = .main
                    }
                }) {
                    Text("Ajouter à ma liste")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedList == nil ? Color.gray : Color.black)
                        .cornerRadius(10)
                }
                .disabled(selectedList == nil)
                .padding(.bottom, 32)
            }
        }
    }
    
    // Contenu pour le scan de liste
    private func scanListContent() -> some View {
            VStack(spacing: 16) {
            // Indicateur de pilule
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 16)
                
            // Titre
                Text("Scanner une liste")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Contenu principal
                VStack {
                    Text("Appareil photo ouvert pour scanner")
                        .font(.system(size: 16))
                        .padding()
                    
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("Après le scan, les éléments détectés apparaîtront ici")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                
                // Bouton de fermeture
                Button(action: {
                onScanList()
                withAnimation(.spring()) {
                    activeView = .main
                }
                }) {
                    Text("Fermer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.bottom, 32)
        }
    }
    
    // Contenu pour le showcase des cartes
    private func cardShowcaseContent() -> some View {
            VStack(spacing: 16) {
            // Indicateur de pilule
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 16)
                
            // Titre
                Text("Cartes de liste")
                    .font(.headline)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                
                // Contenu principal (simplifié pour cette démo)
                VStack {
                    Text("Vitrine des cartes de liste")
                        .font(.system(size: 16))
                        .padding()
                    
                    Image(systemName: "rectangle.grid.2x2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("Choisissez un style pour vos listes")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                
                // Bouton de fermeture
                Button(action: {
                onShowCardShowcase()
                withAnimation(.spring()) {
                    activeView = .main
                }
                }) {
                    Text("Fermer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.bottom, 32)
            }
    }
    
    // Fonction pour analyser la recette Instagram (simulée)
    private func analyzeRecipe() {
        guard !instagramUrl.isEmpty else {
            errorMessage = "Veuillez entrer une URL Instagram"
            return
        }
        
        guard instagramUrl.contains("instagram.com") else {
            errorMessage = "URL invalide. Veuillez entrer un lien Instagram valide."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulation d'un appel d'API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            
            // Simuler une réponse avec des ingrédients
            ingredients = [
                IngredientItem(name: "Farine", quantity: "250", unit: "g"),
                IngredientItem(name: "Oeufs", quantity: "3", unit: "unités"),
                IngredientItem(name: "Lait", quantity: "500", unit: "ml"),
                IngredientItem(name: "Sucre", quantity: "100", unit: "g"),
                IngredientItem(name: "Sel", quantity: "1", unit: "pincée"),
                IngredientItem(name: "Beurre", quantity: "50", unit: "g")
            ]
            
            importSuccess = true
        }
    }
    
    // Fonction pour ajouter un item
    private func addItem() {
        // Convertir le prix en Double
        let price = Double(itemPrice.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        // Créer un nouvel élément
        let newItem = ListItemDetail(
            name: itemName,
            price: price > 0 ? price : nil,
            isCompleted: false,
            quantity: itemQuantity.isEmpty ? nil : itemQuantity, 
            image: nil
        )
        
        // Appeler le callback
        onAddItem()
        
        // Fermer la vue
        withAnimation(.spring()) {
            activeView = .main
        }
    }
    
    // Fonction pour revenir au menu principal ou fermer complètement
    private func dismissActiveView() {
        // Si une sous-vue est active, revenir au menu principal
        if activeView != .main {
            withAnimation(.spring()) {
                activeView = .main
            }
        } else {
            // Sinon, fermer complètement le menu
            isPresented = false
        }
    }
    
    // Fonction pour configurer les observateurs du clavier
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  activeView == .addItem else { return }
            
            let keyboardHeight = keyboardFrame.height
            
            // Récupérer la durée de l'animation du clavier
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            // Récupérer la courbe d'animation du clavier
            let curve = UIView.AnimationCurve(rawValue: notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 7) ?? .easeInOut
            
            // Calcul amélioré pour l'offset, basé sur les specs Figma
            // Assurons que le champ actif et le bouton "Ajouter" restent visibles
            let offset: CGFloat
            
            switch focusedField {
            case .name:
                // Déplacement minimal pour le premier champ
                offset = keyboardHeight * 0.3
            case .price:
                // Déplacement moyen pour le champ du milieu
                offset = keyboardHeight * 0.5
            case .quantity:
                // Déplacement plus important pour le dernier champ
                offset = keyboardHeight * 0.65
            case nil:
                // Valeur par défaut
                offset = keyboardHeight * 0.4
            }
            
            // Ajustement supplémentaire pour les petits écrans (iPhone SE, etc.)
            let finalOffset = screenHeight < 700 ? offset + 40 : offset
            
            // Animation synchro avec l'animation du clavier iOS
            let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
                self.keyboardOffset = finalOffset
            }
            animator.startAnimation()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { notification in
            // Récupérer la durée de l'animation du clavier
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            // Récupérer la courbe d'animation du clavier
            let curve = UIView.AnimationCurve(rawValue: notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 7) ?? .easeInOut
            
            // Animation synchro avec l'animation du clavier iOS
            let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
                self.keyboardOffset = 0
            }
            animator.startAnimation()
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

// Composant bouton d'action
struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.black)
                .cornerRadius(12)
        }
    }
}

#Preview {
    ActionMenuView(
        isPresented: .constant(true),
        onNewList: {},
        onAddItem: {},
        onInstagramImport: {},
        onScanList: {},
        onShowCardShowcase: {}
    )
} 
