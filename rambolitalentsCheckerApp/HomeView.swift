import SwiftUI
import CodeScanner


class SelectedProductDetails : ObservableObject {
    @Published var productIdSelected: Int = 0
    @Published var productNameSelected: String = ""
}


struct homeView: View {
    @State var isAnimating = false
    @State var nameUser : String
    @State var isOnSelect = true
    @State var isProductSelected = false
    @State private var selectedTab = 0
    @State var showSelectView = false
    @State var showTicketView = false
    @State var showTicketViewText = false
    @State var showErrorProduct = false
    @State var codeScanned = false
    @State var ticketCode = ""
    @StateObject private var selectedProductDetails = SelectedProductDetails()
    @State var selectText = "Veuillez sélectionner le produit."
    @State var firstButtonSelect = "Sélectionner"
    @State var secondButtonSelect = ""
    @State var typedTicket = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VStack{
                Text("  Bienvenue "+nameUser+" 👋")
                    .font(.system(size: 25, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(selectText).font(.system(size: 20)).multilineTextAlignment(.center)
                    .frame(height: 200)
                    .clipped()
                
                Image(systemName: isProductSelected ? "qrcode.viewfinder" : "hand.point.up.left.fill")
                    .font(.system(size: 250, weight: .ultraLight))
                    .foregroundColor(Color(red: 0/255, green: 122/255, blue: 100))
                    .opacity(isAnimating ? 1.0 : 0.1) // Adjust the opacity values as desired
                    .onAppear() {
                        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            isAnimating.toggle()
                        }
                    }
                
                Spacer()
                    .frame(height: 50)
                Button(firstButtonSelect) {
                    showSelectView = true
                }
                Spacer()
                    .frame(height: 50)
                Button(secondButtonSelect) {
                    selectedTab = 1
                }
                .sheet(isPresented: $showSelectView, onDismiss: {
                    if(selectedProductDetails.productIdSelected != 0 && selectedProductDetails.productNameSelected != ""){
                        print("test")
                        selectText = "Vous avez sélectionné  :\n"+selectedProductDetails.productNameSelected+". \nVous pouvez maintenant procéder au scan."
                        isProductSelected = true
                        firstButtonSelect = "Modifier le choix"
                        secondButtonSelect = "Accéder au scanner"
                    }
                }){
                    productsView()
                        .environmentObject(selectedProductDetails)
                    
                }
            }
            .onAppear(){
                UIView.setAnimationsEnabled(true)
            }
            .tabItem {
                Image(systemName: "hand.tap")
                Text("Sélectionner")
            }
            .tag(0)
            VStack{
                if(selectedTab == 1){
                    VStack{
                        CodeScannerView(codeTypes: [.qr], scanMode: .continuous, scanInterval: 5, showViewfinder : true, shouldVibrateOnSuccess: true) { response in
                        if case let .success(result) = response {
                            ticketCode = result.string
                            print(ticketCode)
                            showTicketView = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                codeScanned = true
                            }
                        }
                    }
                        .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 50)
                        .clipped()
                        
                    }.sheet(isPresented: $showTicketView, onDismiss: {
                        codeScanned = false
                    }){
                        checkerView(ticketCode: $ticketCode, productId: selectedProductDetails.productIdSelected, isEncodedData: true)
                        
                    }
                }
            }.onAppear(){
                if !isProductSelected{
                    selectedTab = 0
                    showErrorProduct = true
                }
            }
            .alert("Avant de vérifier les billets, veuillez d'abord choisir le produit.", isPresented: $showErrorProduct) {
                Button("D'accord", role: .cancel) {
                    showErrorProduct = false
                }
            }
            .tabItem {
                Image(systemName: "qrcode")
                Text("Scanner")
            }
            .tag(1)
            VStack{
                TextField("Entrer le numéro du billet", text: $typedTicket)
                    .disableAutocorrection(true)
                    .padding(.all, 15)
                    .overlay(
                        Rectangle().strokeBorder(
                            .black.opacity(0.2),
                            style: StrokeStyle(lineWidth: 2.0)
                        )
                    )
                
                    .submitLabel(.done)
                Button("Verifier") {
                    showTicketViewText = true
                }
            }.sheet(isPresented: $showTicketViewText){
                checkerView(ticketCode: $typedTicket, productId: selectedProductDetails.productIdSelected, isEncodedData: false)
                
            }
            .onAppear(){
                if !isProductSelected{
                    selectedTab = 0
                    showErrorProduct = true
                }
            }
            .tabItem {
                Image(systemName: "keyboard")
                Text("Ecrire")
            }
            .tag(2)
        }
    }
}

struct homeView_Previews: PreviewProvider {
    
    static var previews: some View {
        homeView(nameUser: "")
    }
}


