# Rambolitalents Checker App

The Rambolitalents Checker App is a SwiftUI-based mobile application that allows users to perform various actions related to ticket checking, product selection, and more.

## Features

- **LoadingView**: The app starts with a `LoadingView` that checks if the server is reachable via the URL "https://checker.rambolitalents.daniel-monteiro.fr/checkConnection.php." This endpoint returns a JSON response to indicate server availability. 
![LoadingView](https://i.ibb.co/6YNQbPm/Loading-View.png)

- **LoginView**: Upon successful server connection, users are presented with a `LoginView`. Here, users can enter their credentials, and the app sends a POST request to "https://checker.rambolitalents.daniel-monteiro.fr/checkUser.php" to validate the login. A custom alert system is implemented using the "CustomAlert" library.
![LoginView](https://i.ibb.co/pyZ8fWy/Login-View.png)

- **HomeView**: After successful login, users are directed to the `HomeView`. This view has three tabs: "Selectionner" (Select), "Scanner" (Scan), and "Ecrire" (Write).

    - **Selectionner Tab**: Allows users to choose a product from a list retrieved from "https://checker.rambolitalents.daniel-monteiro.fr/getProducts.php," which returns a JSON response containing product data.
![HomeView](https://i.ibb.co/8xQSY6J/HomeView.png)
    - **Scanner Tab**: In this tab, users can scan a ticket encoded in base64. This functionality is implemented using the "CodeScannerView" from the "CodeScanner" library.
![HomeView](https://i.ibb.co/8spKrdc/Scan.jpg) //TODO
    - **Ecrire Tab**: Allows users to manually enter a 15-character ticket code.
![HomeView](https://i.ibb.co/WFmBV7r/Ecrire.png)
- **CheckerView**: When a ticket is scanned in the "Scanner" tab, the `CheckerView` is presented as a sheet. It sends a POST request to "https://checker.rambolitalents.daniel-monteiro.fr/checkTickets.php" to validate the ticket. Depending on the result:
    
    - If the ticket is invalid, it displays an "x.circle.fill" system icon in red with the message "Le billet est invalide."
    
    - If the ticket is valid and not previously scanned, it displays a "checkmark.circle.fill" icon in green with the owner's name and address, along with the message "Le billet est valide."

    - If the ticket is valid but already scanned, it displays an "exclamationmark.triangle.fill" icon in orange with the message "Billet valide, déjà scanné."
![CheckerView](https://i.ibb.co/wLW2tzP/no.png)
![CheckerView](https://i.ibb.co/G00fwQb/ok.png)
![CheckerView](https://i.ibb.co/98JpGw9/scanned.png)

## Getting Started

To get started with the Rambolitalents Checker App, follow these steps:

1. Clone the repository:

 ```shell 
 git clone https://github.com/DanielDSM23/Tic-Tac-Toe_IOS.git
 ```


2. Open the project in Xcode and build/run it on a compatible iOS device or simulator.

## Requirements

- iOS 14.0+
- Xcode 12.0+

## License

This project is licensed under the [License Name] - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The app utilizes the [CustomAlert](https://github.com/divadretlaw/CustomAlert) library for custom alert presentations.
- The barcode scanning feature is implemented using the [CodeScanner](https://github.com/twostraws/CodeScanner) library.
