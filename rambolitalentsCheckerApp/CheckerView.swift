//
//  checkerView.swift
//  rambolitalentsCheckerApp
//
//  Created by Daniel Monteiro on 22/09/2023.
//

import SwiftUI
import Foundation
import AVFoundation

struct checkerView: View {
    @Binding var ticketCode : String
    @State var productId : Int
    @State var detailsArray : [String] = []
    @State var status : String = ""
    @State var name : String = ""
    @State var addr : String = ""
    @State var isLoading = true
    @State var isEncodedData : Bool
    @State var icon : String = ""
    @State var info : String = ""
    @State var red = 0.0
    @State var green = 0.0
    @State var blue = 0.0
    @State var audioPlayer: AVAudioPlayer!
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack{
            if isLoading {
                ProgressView("Verification billet en cours...")
                    .onAppear(){
                        if(isEncodedData){
                            print(ticketCode)
                            if let data = Data(base64Encoded: ticketCode) {
                                if let decodedString = String(data: data, encoding: .utf8) {
                                    print("Decoded String: \(decodedString)")
                                    ticketCode = decodedString
                                } else {
                                    print("Failed to decode as a UTF-8 string.")
                                }
                            } else {
                                print("Invalid Base64 input.")
                            }
                        }
                        detailsArray = checkTicket(ticketNum: ticketCode, id: productId)
                        isLoading = false
                    }
            }
            if !isLoading{
                Image(systemName: icon)
                    .font(.system(size: 250, weight: .ultraLight))
                    .foregroundColor(Color(red: red/255, green: green/255, blue: blue/255))
                Spacer()
                    .frame(height: 100)
                Text(info)
                    .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 40)
                Button("Retour") {
                    presentationMode.wrappedValue.dismiss()
                }
                    .onAppear(){
                        let status = detailsArray[0]
                        let wasScanned = Bool(detailsArray[1])
                        let name = detailsArray[2]
                        let address = detailsArray[3]
                        if(status == "invalid" && wasScanned == false && name.isEmpty && address.isEmpty){
                            icon = "x.circle.fill"
                            red = 255
                            green = 99
                            blue = 71
                            info = "Le billet est invalide."
                            playSounds(soundFileName: "sound/no")
                        }
                        else if (status == "correct" && wasScanned == false && !name.isEmpty && !address.isEmpty){
                            icon = "checkmark.circle.fill"
                            red = 144.0
                            green = 238.0
                            blue = 144.0
                            info = "Le billet est valide.\n\nNom : "+name+"\n\nAdresse : "+address
                            playSounds(soundFileName: "sound/ok")
                        }
                        else if (status == "correct" && wasScanned == true && !name.isEmpty && !address.isEmpty){
                            icon = "exclamationmark.triangle.fill"
                            red = 255.0
                            green = 204.0
                            blue = 0.0
                            info = "Billet valide, déjà scanné.\n\nNom : "+name+"\n\nAdresse : "+address
                            playSounds(soundFileName: "sound/scanned")
                        }
                    }
            }
        }
        
    }
    func playSounds(soundFileName : String) {
            guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: "wav") else {
                fatalError("Unable to find \(soundFileName) in bundle")
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print(error.localizedDescription)
            }
            audioPlayer.play()
        }
    func checkTicket(ticketNum: String, id: Int) -> [String] {
        print("LAUNCHING")
        struct ticketInfo: Decodable {
            let status: String
            let hasBeenScanned: Bool
            let name: String
            let address : String
        }
        
        var returnValue : [String] = []
        
        
        let parameters = "num="+ticketNum+"&id="+String(id)
        let postData =  parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://checker.rambolitalents.daniel-monteiro.fr/checkTickets.php")!,timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        let group = DispatchGroup()
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer {
                group.leave()
            }
            
            guard let jsonString = data else { return }
            let json: ticketInfo = try! JSONDecoder().decode(ticketInfo.self, from: jsonString)
            returnValue.append(json.status)
            returnValue.append(String(json.hasBeenScanned))
            returnValue.append(json.name)
            returnValue.append(json.address)
        }
        
        group.enter()
        task.resume()
        
        let timeoutResult = group.wait(timeout: .now() + 10) // Wait for a maximum of 10 seconds
        
        if timeoutResult == .timedOut {
            task.cancel() // Cancel the request if it times out
        }
        print(returnValue)
        return returnValue
    }
}




