//
//  ContentView.swift
//  rambolitalentsCheckerApp
//
//  Created by Daniel Monteiro on 19/09/2023.
//

import SwiftUI

struct loadingView: View {
    @State var isWebsiteAccesible = false
    @State var displayMessage = false
    @State var textDisplayed = ""
    @State var isMistakes = false
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 200, height: 200)
            ProgressView(textDisplayed)
                .onAppear(){
                    initApp();
                    print(isWebsiteAccesible)
                }
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
                .fullScreenCover(isPresented: $isWebsiteAccesible, content: loginView.init)
                .alert("L'application ne peut pas établir de connexion avec le serveur.\n\nVeuillez vérifier votre connexion Internet et assurez-vous que vous êtes connecté à Internet. \n\nSi le problème persiste, veuillez contacter le support technique pour obtenir de l'aide.", isPresented: $displayMessage) {
                        Button("Réessayer", role: .cancel) {
                            textDisplayed = "Nous essayons à nouveau de nous connecter au serveur."
                            initApp()
                            displayMessage = false
                            
                        }
                        Button("Fermer l'application", role: .destructive) {
                            exit(0)
                            
                        }
                    
                    }
            
           
        }
        .padding()
    }
    
    func initApp(){
        if(isWorking()){
            if(isMistakes){
                textDisplayed = "Nous avons réussi à nous connecter au serveur avec succès."
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                isWebsiteAccesible = true
                displayMessage = false
                //UIView.setAnimationsEnabled(false)
            }
        }
        else{
            isMistakes = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                isWebsiteAccesible = false
                displayMessage = true
                
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        loadingView()
    }
}

func isWorking() -> Bool {
    struct Json: Decodable {
        let isWorking: Bool
    }

    var returnValue = false
    let url = URL(string: "https://checker.rambolitalents.daniel-monteiro.fr/checkConnection.php")!

    let group = DispatchGroup()

    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        defer {
            group.leave()
        }

        guard let jsonString = data else { return }
        let json: Json = try! JSONDecoder().decode(Json.self, from: jsonString)
        returnValue = json.isWorking
    }

    group.enter()
    task.resume()

    let timeoutResult = group.wait(timeout: .now() + 10) // Wait for a maximum of 10 seconds

    if timeoutResult == .timedOut {
        task.cancel() // Cancel the request if it times out
    }

    return returnValue
}

