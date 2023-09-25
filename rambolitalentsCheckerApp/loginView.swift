//
//  loginView.swift
//  rambolitalentsCheckerApp
//
//  Created by Daniel Monteiro on 20/09/2023.
//

import SwiftUI
import CustomAlert

struct loginView: View {
    enum Field {
        case username
        case password
    }
    @State var password = ""
    @State var login = ""
    @State var loadingShow = false
    @State var message = ""
    @State var isUserConnected = false
    @State var nameUser = ""
    @FocusState private var focusedField: Field?
    var body: some View {
        VStack{
            Image("logo")
                .resizable()
                .frame(width: 200, height: 200)
            VStack{
                Text("Utilisateur :")
                TextField("Entrer votre nom d'utilisateur", text: $login)
                    .disableAutocorrection(true)
                    .padding(.all, 15)
                    .overlay(
                        Rectangle().strokeBorder(
                            .black.opacity(0.2),
                            style: StrokeStyle(lineWidth: 2.0)
                        )
                    )
                    .focused($focusedField, equals: .username)
                    .textContentType(.username)
                    .submitLabel(.next)
                Text("Mot de passe :")
                SecureField("Entrer votre mot de passe",text: $password)
                    .padding(.all, 15)
                    .overlay(
                        Rectangle().strokeBorder(
                            .black.opacity(0.2),
                            style: StrokeStyle(lineWidth: 2.0)
                        )
                    )
                    .focused($focusedField, equals: .password)
                    .textContentType(.password)
                    .submitLabel(.done)
            }
            .onSubmit {
                switch focusedField {
                case .username:
                    focusedField = .password
                default:
                    loginButtonAction()
                }
            }
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .frame(height: 50)
            Button(action: {
                loginButtonAction()
            }) {
                ZStack {
                    Image("bgButton") // Replace with the name of your image asset
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 50) // Adjust the size of the image to fit the button
                        .clipped()
                        .cornerRadius(15)
                    
                    Text("Se connecter")
                        .foregroundColor(.white) // Text color
                }
            }
            .customAlert(isPresented: $loadingShow) {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Connexion en cours...")
                        .font(.headline)
                }
            }
        }.padding(30)
            .fullScreenCover(isPresented: $isUserConnected){
                homeView(nameUser: nameUser)
            }
        
    }
    func loginButtonAction(){
        if(!login.isEmpty && !password.isEmpty){
            loadingShow = true
            let result = userExists(username: login, password: password)
            let arrayResult = result.components(separatedBy: ",")
            let userExists = Bool(arrayResult[0])
            nameUser = arrayResult[1]
            print(nameUser)
            if(userExists == true && !nameUser.isEmpty){
                UIView.setAnimationsEnabled(false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    loadingShow = false
                    isUserConnected = true
                }
            }
            else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    loadingShow = false
                    message = "Le nom d'utilisateur ou le mot de passe est incorrect. Veuillez réessayer."
                }
            }
        }
        else{
            message = "Veuillez remplir les champs du formulaire correctement."
        }
    }
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}


func userExists(username: String, password: String) -> String {
    struct userInfo: Decodable {
        let userExists: Bool
        let name: String
    }
    
    var returnValue = "false,"
    
    
    let parameters = "user="+username+"&password="+password
    let postData =  parameters.data(using: .utf8)
    
    var request = URLRequest(url: URL(string: "https://checker.rambolitalents.daniel-monteiro.fr/checkUser.php")!,timeoutInterval: Double.infinity)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.httpMethod = "POST"
    request.httpBody = postData
    let group = DispatchGroup()
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        defer {
            group.leave()
        }
        
        guard let jsonString = data else { return }
        print(jsonString)
        let json: userInfo = try! JSONDecoder().decode(userInfo.self, from: jsonString)
        returnValue = String(json.userExists)+","+json.name
    }
    
    group.enter()
    task.resume()
    
    let timeoutResult = group.wait(timeout: .now() + 10) // Wait for a maximum of 10 seconds
    
    if timeoutResult == .timedOut {
        task.cancel() // Cancel the request if it times out
    }
    
    return returnValue
}
